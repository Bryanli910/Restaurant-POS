<%@ page import="com.default.db_connect" %>
<%@ page import="java.sql.*" %>
<%! String[] ingredients; %>
<%! String newStatus; %>
<%
Connection conn = db_connect.getConnection();
PreparedStatement updateStatement;
Statement checkStatement; 
ResultSet objectResults;
int actionId = -1, selectedId = -1;


 int userRole = -1;
 if(null == session.getAttribute("role") && userRole != 0 && userRole != 1 && userRole != 3 && userRole != 4) response.sendRedirect("login.jsp");

if(request.getParameterMap().containsKey("id")) selectedId = Integer.parseInt(request.getParameter("id"));
if(request.getParameterMap().containsKey("action")) actionId = Integer.parseInt(request.getParameter("action"));

	
 if(null == session.getAttribute("role") && userRole != 0 && userRole != 1 && userRole != 3) actionId = -1; //Guest can't do anything
	


String[] statuscodes = {"Order placed", "In progress", "Completed"};
boolean completed = false;

if(selectedId != -1 && actionId != -1){ //An item was selected
	switch(actionId){
		case 1: //Set order to next step
			checkStatement = conn.createStatement();
			objectResults = checkStatement.executeQuery("SELECT orders.status FROM orders WHERE orders.ordernumber = "+selectedId);
		
				
			if(objectResults.next())
			for(int i = 0; i < statuscodes.length; i++){
				if(statuscodes[i].equalsIgnoreCase(objectResults.getString("status"))){
					newStatus = statuscodes[((i == statuscodes.length-1) ? i : (i+1))];
					if(newStatus.equalsIgnoreCase("completed")) completed = true;
					break;
				}
			}
			
			updateStatement = conn.prepareStatement("UPDATE orders SET status='"+newStatus+"' WHERE ordernumber="+selectedId);
			updateStatement.executeUpdate();
			updateStatement.close();
			
			if(completed){
				
				updateStatement = conn.prepareStatement("UPDATE order_lines SET status='"+newStatus+"' WHERE orderid="+selectedId);
				updateStatement.executeUpdate();
				updateStatement.close();
			
			};
		break;	
		
		case 2: //Set order line to next step
		
			checkStatement = conn.createStatement();
			int relatedOrder = -1;
			boolean complete = true;
			objectResults = checkStatement.executeQuery("SELECT status, orderid FROM order_lines WHERE id = "+selectedId);
			
			if(objectResults.next()){
				for(int i = 0; i < statuscodes.length; i++){
					if(statuscodes[i].equalsIgnoreCase(objectResults.getString("status"))){
						newStatus = statuscodes[((i == statuscodes.length-1) ? i : (i+1))];
						break;
					}
				}
				relatedOrder = objectResults.getInt("orderid");
			}
			objectResults.close();
			
			
			updateStatement = conn.prepareStatement("UPDATE order_lines SET status='"+newStatus+"' WHERE id="+selectedId);
			updateStatement.executeUpdate();
			updateStatement.close();
			
			
			
			objectResults = checkStatement.executeQuery("SELECT status FROM order_lines WHERE orderid = "+relatedOrder);
			
			while(objectResults.next()){
				if(!objectResults.getString("status").equalsIgnoreCase("completed")){
					complete = false;
				}
			}
			
			objectResults.close();
			
			if(complete) completed = true;
			
			updateStatement = conn.prepareStatement("UPDATE orders SET status='"+statuscodes[(complete ? 2 : 1)]+"' WHERE ordernumber="+relatedOrder);
			updateStatement.executeUpdate();
			updateStatement.close();
		break;	
		case 3: //Cancel order
			updateStatement = conn.prepareStatement("DELETE FROM order_lines WHERE orderid="+request.getParameter("id"));
			updateStatement.executeUpdate();
			updateStatement.close();
			
			updateStatement = conn.prepareStatement("DELETE FROM orders WHERE ordernumber="+request.getParameter("id"));
			updateStatement.executeUpdate();
			updateStatement.close();
		break;	
		case 4: //Cancel order line
			updateStatement = conn.prepareStatement("DELETE FROM order_lines WHERE id="+request.getParameter("id"));
			updateStatement.executeUpdate();
			updateStatement.close();
		break;	
	}
} %>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
	<title>Current Orders</title>
    
	<style type="text/css" media="screen, print, projection">
html,
body {
	margin:0;
	padding:0;
	background-image:url(assets/background.png);
	background-repeat: repeat;
}
.itemSpinner{
	float:right;
	height:100%;
	display: none;
}
#body {
	width:960px;
	margin:0 auto;
	background:#ddd;
}
#header {
	height:25px;
}
#content-2 {
	float:right;
	width:100%;
	height:100%;
}
.editItemTitleText{
	max-width: 50%;
	overflow: hidden;
	max-height: 35px;
	display: inline-block;
}
#content-2wrapper {
	float:right;
	height:100%;
	position: absolute;
	left: 0px;
	right: 0px;
	overflow-y: scroll;
	overflow-x: hidden;
	-webkit-overflow-scrolling: touch;
	-ms-overflow-style: none;
}

#content-2wrapper::-webkit-scrollbar { width: 0 !important }

#downArrow{
	width:100%;
	height:20px;
	background-image:url(assets/arrow.png);
	background-position:center;
	background-repeat: no-repeat;
	position:absolute;
	background-size: contain;
	bottom: 10px;

} 

#content-2wrapper::-webkit-scrollbar { width: 0 !important }
.editItemTitle{
	font-size: 30px;
	width: 100%;
	border-bottom: 1px #ddd solid;	
	margin-bottom: 10px;
}
.content-2-2 {
	background:#fff;
	margin: 10px;
	left: 0px;
	right: 0px;
	padding: 10px;
	border: 1px #999 solid;
	border-radius:5px;
	box-shadow: 3px 3px 3px #888888;
}
#footer {
	padding:10px;
}
.accountListItem{
	border: 1px #999 solid;
	margin: 10px;
	height: 20px;
	padding: 10px;
	background:#fff;
	box-shadow: 3px 3px 3px #888888;
	border-radius:5px;
	overflow:hidden;
}
#main{
	position:fixed !important;
	position:absolute;
	top:0px;
	bottom:0px;
	left: 0px;
	right: 0px;
	overflow:hidden;
}
.orderLineItem{
	padding: 10px;
	border-bottom: 1px #ddd solid;	
}
.orderLineItem:hover{
	background-color: #eee;
}
	</style>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
    <script type="text/javascript" src="lib/js/jquery.transit.min.js"></script>
<script type="text/javascript">
	if (typeof String.prototype.startsWith != 'function') {
  	String.prototype.startsWith = function (str){
    	return this.slice(0, str.length) == str;
 	 };
	}
		
		$(document).ready(function() {
			assignEvents();
			$.ajaxSetup({
    			timeout: 3000 //Time in milliseconds
			});
			$(document).ajaxError(function(event, request, settings) {
			 	$("#content-2-2").html("An ajax error has occured"); //TODO: fail gracefully
			});
			
			$(".order div:last-child" ).css('border','none');
			//$(".completedorder").parent().fadeOut(200);
			
			
			$( "#content-2wrapper" ).scroll(function() {
						 if($(this)[0].scrollHeight - $(this).scrollTop() < $(this).outerHeight()+100)
									$("#downArrow").fadeOut();
						else
									$("#downArrow").fadeIn();
							
						if( $(this).scrollTop() > 100)
									$("#upArrow").fadeIn();
						else
									$("#upArrow").fadeOut();
			});
		});
		function assignEvents(){

			
		}
		
		
		
		function ajaxActionData(id, action, wrapper, getelement){ 
			
			$(wrapper).transition({height : action == 3 ? 0 : 'auto', opacity: 0},200, function(getelement, wrapper, dataSet, action){
					$(wrapper).load(document.URL+" "+getelement, dataSet, function(){  //POST
						if(action != 3){
							
							$(".order div:last-child" ).css('border','none');
							$(wrapper).transition({height: 'auto', opacity: 1},200);
							
							setTimeout(function(){$(".completedorder").parent().fadeOut(200);},3000);
							
						}
						
					});
			}(getelement, wrapper, {'id' : id, 'action' : action}, action));
			
		}
	</script>
</head>
<body>
	<div id="body">
		<div id="main" class="cf">
            <div id="content-2wrapper">
                <div id="content-2">
                	<%
						Statement getSelectedStmt = conn.createStatement();
						
						ResultSet getSelectedResult = getSelectedStmt.executeQuery("select * from orders order by ordernumber desc");
						while(getSelectedResult.next()){
							
							if(!completed && getSelectedResult.getString("status").equalsIgnoreCase("completed"))
							continue;
							
							%>
							
                            
                            
                            <div id="orderWrapper<%= getSelectedResult.getInt("ordernumber") %>" class="content-2-2">
                                <div id="order<%= getSelectedResult.getInt("ordernumber") %>" class="order<%= ((((getSelectedResult.getInt("ordernumber") == selectedId) && completed) || getSelectedResult.getString("status").equalsIgnoreCase("completed")) ? " completedorder" : "") %>">
                                    <div class="editItemTitle">
                                        <span class="editItemTitleText">Order #<%= getSelectedResult.getInt("ordernumber") %> - <i><%= getSelectedResult.getString("status") %></i></span>							
                                        <img src="assets/ready.png" width="64" style="float:right;" alt="Complete" onclick="ajaxActionData(<%= getSelectedResult.getInt("ordernumber") %>, 1, '#orderWrapper<%= getSelectedResult.getInt("ordernumber") %>', '#order<%= getSelectedResult.getInt("ordernumber") %>');"/>
                                        <img src="assets/cancel.png" width="64" style="float:right;margin-right:10px;" alt="Cancel" onclick="ajaxActionData(<%= getSelectedResult.getInt("ordernumber") %>, 3, '#orderWrapper<%= getSelectedResult.getInt("ordernumber") %>', '#order<%= getSelectedResult.getInt("ordernumber") %>');"/>
                                    </div>
                                        <%
                                            Statement getLinesStmt = conn.createStatement();
                                            
                                            ResultSet getLinesResult = getLinesStmt.executeQuery("select * from order_lines where orderid="+getSelectedResult.getInt("ordernumber")+" ORDER BY id asc ");
                                            while(getLinesResult.next()){
                                               
											     Statement getDishStmt = conn.createStatement();
                                            
                                           		 ResultSet getDishResult = getDishStmt.executeQuery("select * from dishes where id="+getLinesResult.getInt("dishid"));
                                        	     if(getDishResult.next()){
											   
											   	 %>
                                                     <div id="orderLineWrapper" class="orderLineItem">
                                                        <div id="orderLine<%= getLinesResult.getInt("id") %>">
                                                            <img src="<%= getDishResult.getString("picture") %>" style="margin-bottom:10px;box-shadow: 3px 3px 3px #888888;border: 2px #333 solid;border-radius: 50%; margin-right: 20px;vertical-align:middle;width:50px;height: 50px;" alt="<%= getDishResult.getString("name") %>" > 
                                                            <span>
                                                                <strong><%= getDishResult.getString("name") %></strong> x <strong><%= getLinesResult.getInt("quantity") %></strong> - <i><%= getLinesResult.getString("status") %></i>
                                                            </span>
                                                            <span style="display:inline-block;position:absolute; right:50px;">
                                                            <img src="assets/inprogress.png" style="height: 29px;margin-right:10px;width:29px;vertical-align:middle;" onclick="ajaxActionData(<%= getLinesResult.getInt("id") %>, 2, '#orderWrapper<%= getSelectedResult.getInt("ordernumber") %>', '#order<%= getSelectedResult.getInt("ordernumber") %>');" alt="Next step" >
                                                            <img src="assets/remove.png" style="height: 29px;width:29px;vertical-align:middle;" alt="Remove item" onclick="ajaxActionData(<%= getLinesResult.getInt("id") %>, 4, '#orderWrapper<%= getSelectedResult.getInt("ordernumber") %>', '#order<%= getSelectedResult.getInt("ordernumber") %>');" > </span>
                                                        </div>
                                                     </div>
                                                 <%
												 }
                                            }
                                            getLinesResult.close();
                                        %>
                                </div>
                            
                            </div>
							<%
						}
						getSelectedResult.close();
					
					%>
                  	
                </div>
           	</div>
            
    		<div id="downArrow"></div>
		</div>
	</div>
</body>
</html>
<% conn.close(); %>