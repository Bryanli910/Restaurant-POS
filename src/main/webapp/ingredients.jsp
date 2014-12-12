<%@ page import="com.default.db_connect" %>
<%@ page import="java.sql.*" %>
<%
 Connection conn = db_connect.getConnection();
 
 int updatedId = -1;
%>
<%
//Form submitted action
if ("POST".equalsIgnoreCase(request.getMethod())) {
//Save data 

	Statement stmt = conn.createStatement();
	String req = "select MAX(id) from ingredients";
	ResultSet res = stmt.executeQuery(req);
	
	if(res.next()){
		
		if(request.getParameterMap().containsKey("id")){
			if(!request.getParameterMap().containsKey("delete")){
				if(request.getParameter("amount").equalsIgnoreCase("-1")){
					//Delete
					PreparedStatement ps = conn.prepareStatement("DELETE FROM ingredients WHERE id="+request.getParameter("id"));
					ps.executeUpdate();
					ps.close();
				}else{
					//Update
					updatedId = Integer.parseInt(request.getParameter("id"));
					PreparedStatement ps = conn.prepareStatement("UPDATE ingredients SET name='"+request.getParameter("name")+"', stock="+request.getParameter("amount")+", units='"+request.getParameter("units")+"' WHERE id="+request.getParameter("id"));
					ps.executeUpdate();
					ps.close();
				}
			}
		}else{
			//New
			PreparedStatement ps = conn.prepareStatement("INSERT INTO ingredients VALUES (?, ?, ?, ?)");
			ps.setInt(1, res.getInt(1) + 1);
			ps.setString(2, request.getParameter("name"));
			ps.setInt(3, Integer.parseInt(request.getParameter("amount")));
			ps.setString(4, request.getParameter("units"));
			ps.executeUpdate();
			ps.close();
		}
	
	}
	
	res.close();
} 

%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Manage Ingredients</title>
    <style type="text/css">
		body, html {
			height: 100%;
			margin: 0px;
			padding: 0px;
			overflow: hidden;
		}
		.leftPaneContainer{
			/*border: 1px black solid;*/
			height: 100%;
			width: 20%;
			left: 0px;
			float:left;
			top: 0px;
			
		}
		.rightPaneContainer{
			height: 100%;
			/*padding: 10px;*/
			top: 0px;
			float:left;
			width: 80%;
			display: block;
		}
		.rightPaneForm{
			border: 1px black solid;
			margin: 10px;
			height: 94%;
			box-shadow: 5px 5px 5px #888888;
			padding: 10px;
		}
		.accountList{
			height: 100%;
			overflow: scroll;
		}
		.accountListItem{
			border: 1px black solid;
			margin: 10px;
			/*width: 100%;*/
			padding: 10px;
			box-shadow: 5px 5px 5px #888888;
		}
		.addAccountButton{
			bottom: 50px;
			left: 75%;
			position: relative;
			font-size: 30px;
			background-color: white;
			text-align:center;
			border: 1px solid black;
			width: 40px;
			height: 40px;
			margin: 10px;
		}
		.editItemTitle{
			font-size: 30px;	
		}
		.editForm{
			margin-top: 10px;
		}
	</style>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
    <script src="plugin/jquery.transit.min.js"></script>
    <script type="text/javascript">
		function assignEventListeners(){
			$(".addAccountButton").click(function(){
				//Send ajax request here to create new account, open account editing form on created account
				alert("Create a new account here");
			});
			$(".accountListItem").click(function(){
				//Send ajax request here to create new account, open account editing form on created account
				//alert("Load account: "+$(this).html()+" here");
			});
		}
		$( document ).ready(function() {
			assignEventListeners();	   
		});
	</script>
</head>

<body>
    <div class="leftPaneContainer">
    	<div class="accountList">
			<%
			
			Statement stmt = conn.createStatement();
			String req = "select name, id from ingredients order by name asc";
			ResultSet res = stmt.executeQuery(req);
			while(res.next()){
				%>
                <div class="accountListItem">
                <a href="?ingredient=<%= res.getInt("id") %>">
				<%= res.getString("name") %>
                </a>
                </div>
				<%
			}
			res.close();
			%>
		</div>
        <div class="addAccountButton">
        	+
        </div>
    </div>
    <div class="rightPaneContainer">
    	<div class="rightPaneForm">
        	<%
			if (("GET".equalsIgnoreCase(request.getMethod()) && request.getParameterMap().containsKey("ingredient")) || updatedId != -1) {
					Statement stmt1 = conn.createStatement();
					String req1 = "select * from ingredients where id=" + ((updatedId == -1) ? request.getParameter("ingredient") : Integer.toString(updatedId));
					ResultSet res1 = stmt.executeQuery(req1);
					if(res1.next()){
						%>
                        
                        <div class="editItemTitle"><%= res1.getString("name") %></div>
                        <form class="editForm" method="post">
                        	<input type="hidden" name="id" value="<%= res1.getInt("id") %>" />
                            <label>Name:</label><br />
                            <input type="text" placeholder="Name" value="<%= res1.getString("name") %>" name="name" /><br /><br />
                            <label>Amount: (-1 to delete)</label><br />
                            <input type="text" placeholder="Amount" value="<%= res1.getInt("stock") %>" name="amount" /><br /><br />
                            <label>Units:</label><br />
                            <input type="text" placeholder="Units" value="<%= res1.getString("units") %>" name="units" /><br /><br />
                            <input type="submit"/><br /><br />
                        </form>
                 		</div>
                      
                        <%
					}
					
			}else{
					%>
                        
                          <div class="editItemTitle">New Ingredient</div>
                            <form class="editForm" method="post">
                                <label>Name:</label><br />
                                <input type="text" placeholder="Name" name="name" /><br /><br />
                                <label>Amount: (-1 to delete)</label><br />
                                <input type="text" placeholder="Amount" name="amount" /><br /><br />
                                <label>Units:</label><br />
                                <input type="text" placeholder="Units" name="units" /><br /><br />
                                <input type="submit"/><br /><br />
                            </form>
                      	  </div>
                          
                        <%
					
			}
			%>
      
    </div>
</body>
</html>
