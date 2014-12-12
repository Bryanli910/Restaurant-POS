<%@ page import="java.sql.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%@ page import="com.default.db_connect" %>

<%
Class.forName("org.postgresql.Driver"); 
Connection conn= null;
conn = db_connect.getConnection();
Statement stmt = conn.createStatement();
%>
<%
//This is the current order number to be submitted to the database
String orderNum = request.getParameter("orderNumber");

//Insert the order as a whole into the 'orders' table
//This will insert just the order number and the status of the order which is "Sent To Kitchen"
String newOrderQry = "insert into orders (ordernumber, status) values ("+orderNum+",'Sent To Kitchen')";
stmt.executeUpdate(newOrderQry);

//Get the current max orderlineitemId
String maxOrderIdQry = "select max(id) as id from order_lines";
ResultSet maxId = stmt.executeQuery(maxOrderIdQry);
maxId.next();

int maxID = maxId.getInt("id")+1;
//out.println(maxID);

//Decompose parameter "order" into [id,qty,id,qty,..,etc]
String orderString = request.getParameter("order");
String[] orderLineItem = orderString.split(",");

//Variables used to insert the dish id with the order qty into order_lines table
String dishId = null;
String orderQty = null;

//Query for getting the max order_line item
String olMaxId = "select max(id) as id from order_lines";
ResultSet orderLineRs = stmt.executeQuery(olMaxId);
orderLineRs.next();
int orderLineMaxId = orderLineRs.getInt("id");

for(int i=0;i<orderLineItem.length;i++){
	if(i%2 == 0){
		dishId = orderLineItem[i];
	}
	else{
		orderQty = orderLineItem[i];
		orderLineMaxId++;
		String insertOrderLineQry = "insert into order_lines (dishid,orderid,status,id,quantity) values ("+dishId+","+orderNum+",'Order placed',"+orderLineMaxId+","+orderQty+")";
		stmt.executeUpdate(insertOrderLineQry);
		//out.println("dish: "+dishId +" qty: "+ orderQty+" lineId:" + orderLineMaxId);
	}
}
out.println("Success");
conn.close();
%>