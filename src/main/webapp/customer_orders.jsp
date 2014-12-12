<%@ page import="java.sql.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%@ page import="com.default.db_connect" %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="shortcut icon" href="../../assets/ico/favicon.ico">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
    <script src="lib/js/bootstrap.min.js"></script>
    <title>Order Status</title>

    <link href="css/bootstrap.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="css/dashboard.css" rel="stylesheet">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
	<script src="lib/js/jquery.transit.min.js"></script>
	
	<style type="text/css" media="screen, print, projection">
	table,th,td{
	border: 1px solid black;
	}
	table{
	width:100%;
	height:auto;
	}
	th{
	text-align:left;
	color:white;
	background-color:#0096fd;
	
	}
	#itemHeader{
	width:70%;
	}
	#statusHeader{
	width:30%;
	}
	.itemName{

	}
	.itemImg{
	margin-top:5px;
	margin-bottom:5px;
	margin-left:20px;
	box-shadow: 3px 3px 3px #888888;
	border: 2px #333 solid;
	border-radius: 50%; 
	margin-right: 20px;
	vertical-align:middle;
	width:50px;
	height: 50px;
	}
	</style>
  </head>
<%
//background-color:#0096fd;
 Class.forName("org.postgresql.Driver"); 
 Connection conn= null;
 conn = db_connect.getConnection();
 Statement stmt = conn.createStatement();
%>
  <body>

    <div class="navbar navbar-inverse navbar-fixed-top" role="navigation">
      <div class="container-fluid">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="../">Restaurant Management System</a>
        </div>
        <div class="collapse navbar-collapse">
          <ul class="nav navbar-nav navbar-right">
            <li><a href="#about">About Us</a></li>
            <li><a href="manage.jsp">Manage</a></li>
          </ul>
        </div><!--/.nav-collapse -->
      </div>
    </div>

    <div class="container">
      <div class="row">
        <center><h1>Status for Order Number # <%= request.getParameter("orderNum") %>:</h1></center>
      </div>
        <div class="row">
        	<table>
	        	<th id="itemHeader"><h4>Your Ordered Menu Items:</h4></th>
	        	<th id="statusHeader"><h4>Status</h4></th>
					<%
					String orderNum = request.getParameter("orderNum");
					String orderLineQry = "select dishes.name as name, status, order_lines.id as id, picture, quantity "+
					" from dishes, order_lines"+
					" where dishes.id=order_lines.dishid AND order_lines.orderid="+orderNum;
					ResultSet itemsRs = stmt.executeQuery(orderLineQry);
					while(itemsRs.next()){
						out.println("<tr>");
						
						out.print("<td>");
							out.print("<img class='itemImg' src="+itemsRs.getString("picture")+">");
							out.print("<strong>"+itemsRs.getString("name")+"</strong> - ");
							out.print("<i> Quantity: "+itemsRs.getString("quantity")+"</i>");
						out.println("</td>");
							
						out.print("<td class='itemStatus'>");%>
						<%if(itemsRs.getString("status").equals("Order placed")){ %>
						<div class="progress">
        					<div class="progress-bar progress-bar-info" role="progressbar" 
        						aria-valuenow="33" aria-valuemin="0" aria-valuemax="100" style="width: 33%" 
        						data-id='<%= itemsRs.getString("id")%>'
        						data-orderNum='<%= request.getParameter("orderNum") %>'
        						></div>
						</div>
						<%
						}
						else if(itemsRs.getString("status").equals("In progress")){
						%>
						<div class="progress">
        					<div class="progress-bar progress-bar-warning" role="progressbar" 
        					aria-valuenow="66" aria-valuemin="0" aria-valuemax="100" style="width: 66%"
        					data-id='<%= itemsRs.getString("id")%>'
        					data-orderNum='<%= request.getParameter("orderNum") %>'
        					></div>
						</div>
						<%
						}
						else{
						%>
						<div class="progress">
        					<div class="progress-bar progress-bar-success" role="progressbar" 
        					aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%"
        					data-id='<%= itemsRs.getString("id")%>'
        					data-orderNum='<%= request.getParameter("orderNum") %>'
        					></div>
						</div>
						<%
						}
							out.print("<span id='status'><center>"+itemsRs.getString("status")+"</center></span>");
						out.println("</td>");
						out.println("</tr>");
					}
					%>
					<tr><h4>Your Overall Order Status:</h4></tr>
					<tr><h4><div class="progress">
        						<div class="progress-bar progress-bar-warning" role="progressbar" 
        						aria-valuenow="40" aria-valuemin="0" aria-valuemax="100" style="width: 40%"></div>
						</div></h4>
					</tr>
        	</table>
      	</div>
      </div>
    </div><!-- /.container -->
      <div class="footer">
        <center><p>&copy; Company 2014</p></center>
      </div>
  </body>
<%
conn.close();
%>
</html>
