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

    <title>Restaurant Management System</title>

    <!-- Bootstrap core CSS -->
    <link href="css/bootstrap.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="css/dashboard.css" rel="stylesheet">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
    <script src="lib/js/main.js"></script>
	<script src="lib/js/jquery.transit.min.js"></script>
  </head>

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
          <a class="navbar-brand" href="#">Restaurant Management System</a>
        </div>
        <div class="navbar-collapse collapse">
          <ul class="nav navbar-nav navbar-right">
            <li><a href="#">About Us</a></li>
            <li><a href="manage.jsp">Manage</a></li>
          </ul>
        </div>
      </div>
    </div>
<%
 Class.forName("org.postgresql.Driver"); 
 Connection conn= null;
 conn = db_connect.getConnection();
%>
    <div class="container-fluid">
      <div class="row">
        <div class="col-sm-3 col-md-2 sidebar" style="padding-right: 1px; padding-left: 5px; width:218px;">
          <div class="sidebar_nav">
          <h4><strong>Search by Ingredients</strong></h4>
          <center><div id="ingredient_separator"><B> </B></div></center>
          <div class="ingredientsHolder">
          	<ol>
            	<%
            		Statement stmt = conn.createStatement();
            		String ingredQry = "SELECT NAME, ID from ingredients";
            		ResultSet ingredRs = stmt.executeQuery(ingredQry);
            		while(ingredRs.next()){
            			out.println("<li><input type='checkbox' class='ingredients' id='"+ingredRs.getInt("ID")+"' onclick='getIngredients()' unchecked>");
            			out.println("<label for='" +ingredRs.getInt("ID") + "'>" + ingredRs.getString("NAME") + "</label></li>");
            		}
            		
            	%>
          	</ol>
          	</div>
          </div>
          <div><center><button id="clearBtn" type="button">Clear All Ingredients</button></center></div>
          
          
          <div class="sidebar_nav_bottom">
          	<form><h4><strong>Order # 
          	<%
          	String orderNumQry = "SELECT MAX(ordernumber) as ordernum FROM orders";
          	ResultSet orderNumRs = stmt.executeQuery(orderNumQry);
          	orderNumRs.next();
          	%>
          	<span id="orderNum">
          	<%= (orderNumRs.getInt("ordernum")+1) %>
          	</span>
          	:</strong></h4>
          	<ol><div id="orderItems">
       		</div>	</ol>
          </div>
          
          <div class="subTotal">
          <h4><strong>Total: </strong></h4><h4 id="subTotal">$0.00</h4>
          <center><button id="updateBtn" type='button' onclick="updateTotal()">Update Total</button>&nbsp<button id="submitBtn" type='button'>Submit Order</button></center>
          </form></div>
        </div>
        <div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main" id="menu" style = "overflow-y:hidden;">
            <%
    		String dishesQry = "select dishes.id as id, dishes.name as name, price, picture, menu_categories.name as category from dishes inner join menu_categories"+
            	" on dishes.categoryid =menu_categories.id order by category, name asc";
    		ResultSet dishesRs = stmt.executeQuery(dishesQry);
    		//These variables will store various dish related values
    		String placeholderClass = "col-xs-6 col-sm-3 placeholder";
    		String categoryClass = "page-header";
    		String rowClass = "row placeholders";
    		Boolean firstRow = true;
    		Double price = 0.0;
    		String name = "";
    		String category = "";
    		int id = 0;
    		while(dishesRs.next()){
    			price = dishesRs.getDouble("price");
    			name = dishesRs.getString("name");
    			id = dishesRs.getInt("id");
    			if(category == dishesRs.getString("category") || category.equals(dishesRs.getString("category"))){	
    				out.println("<div class='"+placeholderClass + "'>");
        			out.println("<img src='"+dishesRs.getString("picture")+"'alt='Food_Placeholder_Thumbnail'>");
        			out.println("<h4>"+name+"</h4>");
        			out.println("<span class='text-muted'>Price: $"+price+"</span>");
        			out.println("<br />");
        			out.println("<button class='addToOrder' type='button' value='"+name
        					+","+price+","+ id+ "' onclick='addToOrder(this.value)'>Add To Order</button>");
        			out.println("</div>");
    			}
    			else{
    				if(firstRow){
    					category = dishesRs.getString("category");
    					out.println("<h1 class='"+categoryClass+"'>"+category+"</h1>");
    					out.println("<div class='"+rowClass+"'>");
    					out.println("<div class='"+placeholderClass + "'>");
        				out.println("<img src='"+dishesRs.getString("picture")+"'alt='Food_Placeholder_Thumbnail'>");
        				out.println("<h4>"+name+"</h4>");
        				out.println("<span class='text-muted'>Price: $"+price+"</span>");
        				out.println("<br />");
        				out.println("<button class='addToOrder' type='button' value='"+name
        					+","+price+","+ id+ "' onclick='addToOrder(this.value)'>Add To Order</button>");
        				out.println("</div>");
        				firstRow = false;
    				}
    				else{
    					category = dishesRs.getString("category");
    					out.println("</div>");
    					out.println("<h1 class='"+categoryClass+"'>"+category+"</h1>");
    					out.println("<div class='"+rowClass+"'>");
    					out.println("<div class='"+placeholderClass + "'>");
        				out.println("<img src='"+dishesRs.getString("picture")+"'alt='Food_Placeholder_Thumbnail'>");
        				out.println("<h4>"+name+"</h4>");
        				out.println("<span class='text-muted'>Price: $"+price+"</span>");
        				out.println("<br />");
        				out.println("<button class='addToOrder' type='button' value='"+name
        					+","+price+","+ id+ "' onclick='addToOrder(this.value)'>Add To Order</button>");
        				out.println("</div>");
    				}
    			}
    		}
            %>
        </div>
      </div>
    </div>
    
	<div class="welcomeScreenContainer" style="position: absolute; top: 0px; left: 0px; height: 0px; width: 100%; height: 100%; display:block; z-index:9999; background-color:white;">
    <div class="container">
      <div class="header">
        <h3 class="text-muted">Restaurant Management System</h3>
      </div>

      <div class="jumbotron">
        <center><h1>Welcome to our Restaurant</h1>
        <p class="lead">To get started with your order, please click the create order button below.</p>
        <p><a class="btn btn-lg btn-success" id="createOrderButton" role="button">Create New Order</a></p></center>
      </div>

      <div class="footer">
        <center><p>&copy; Company 2014</p></center>
      </div>

    </div> <!-- /container -->

    </div>

<% 
conn.close();
%>
  </body>
</html>
