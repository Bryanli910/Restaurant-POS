<%@ page import="com.default.db_connect" %>
<%@ page import="java.sql.*" %>
<%! String[] ingredients; %>
<%! String newStatus; %>
<%
Connection conn = db_connect.getConnection();
PreparedStatement updateStatement;
Statement checkStatement; 
ResultSet objectResults;
String username = "", password = "";
boolean success = false;

String[] roles = {"admin", "manager", "kitchen", "guest"};


if(request.getParameterMap().containsKey("logout")){
	session.invalidate();
    response.sendRedirect("login.jsp");
    return; 
}

if(request.getParameterMap().containsKey("username")){	
	 username = request.getParameter("username");
	 if(request.getParameterMap().containsKey("password")) password = request.getParameter("password");
	 
	 
		checkStatement = conn.createStatement();
	 
	 	objectResults = checkStatement.executeQuery("SELECT * FROM accounts WHERE UPPER(username)='"+username.toUpperCase()+"' AND UPPER(password)='"+password.toUpperCase()+"';");
			
		if(objectResults.next()){
			success = true;
			session.setAttribute( "username", username );
			session.setAttribute( "rolestring", objectResults.getString("role").toLowerCase());
			
			for(int i = 0; i < roles.length; i++){
				if(objectResults.getString("role").equalsIgnoreCase(roles[i])) session.setAttribute( "role", i);
			}
			
		}
		
		objectResults.close();
}


if(success){
	switch((Integer) session.getAttribute("role")){
		case 0: //admin
    		response.sendRedirect("manage.jsp");
		break;
		case 1: //manager
    		response.sendRedirect("manage.jsp");
		break;
		case 2: //kitchen staff
    		response.sendRedirect("view_orders.jsp");
		break;
		case 3: //guest
		//No need for implementation here
		break;
	}
}



%>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
	<title>Log in</title>
    
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
	left: 30%;
	right: 30%;
	position: absolute;
	top: 30%;
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
			$.ajaxSetup({
    			timeout: 3000 //Time in milliseconds
			});
			$(document).ajaxError(function(event, request, settings) {
			 	$("#content-2-2").html("An ajax error has occured"); //TODO: fail gracefully
			});
			
			
		});
		
		function ajaxActionData(username, password, wrapper, getelement){ 
			
			$(wrapper).transition({opacity: 0}, 200, function(getelement, wrapper, dataSet){
					$(wrapper).load(document.URL+" "+getelement, dataSet, function(){  //POST
							$(wrapper).transition({height: 'auto', opacity: 1},200);
						
					});
			}(getelement, wrapper, {'username' : username, 'password' : password}));
			
		}
	</script>
</head>
<body>
	<div id="body">
		<div id="main" class="cf">
            <div id="content-2wrapper">
                <div id="content-2">
                            <div  class="content-2-2">
                            	<%if(success || null != session.getAttribute( "username")){%>
                                	Welcome. You are logged in. You can view <% if((Integer) session.getAttribute("role") != 2){ %><a href="manage.jsp">manage</a> and <% } %><a href="view_orders.jsp">orders</a> pages or <a href="login.jsp?logout=true">logout</a>.
                            	<%}else{%>
                            		Welcome to restauraunt management system, please log in to continue.<br><br>
                              		<form class="loginForm" method="POST">
                                    	<label>Username: </label><br>
                                        <input type="text" style="width:50%" name="username" placeholder="Username"><br><br>
                                    	<label>Password: </label><br>
                                        <input type="password" style="width:50%" name="password" placeholder="Password">
                                        <input type="submit" value="Log in" style="float:right;">
                                    </form>
                            	<%}%>
                            </div>
				
                </div>
           	</div>
		</div>
	</div>
</body>
</html>
<% conn.close(); %>