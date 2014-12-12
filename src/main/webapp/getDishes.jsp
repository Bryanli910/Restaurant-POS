<%@ page language="java" contentType = "application/json; charset=UTF-8" 
pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.google.gson.*" %>
<%@ page import="com.default.db_connect" %>
<%
	 Class.forName("org.postgresql.Driver"); 
	 Connection conn= null;
	 conn = db_connect.getConnection();
	 Statement stmt = conn.createStatement();
%>

<% 

String ing = "0";
boolean parametersExist = false;
if(!request.getParameter("ingredients").isEmpty()){
//This will handle the ingredients 
	ing = request.getParameter("ingredients");
	parametersExist = true;
}

String [] ingredientsPassed = ing.split(",");
int amountOfIngredients = ingredientsPassed.length;

String ingQry = "SELECT * from dish_ingredients order by \"dishid\" asc, \"ingredientid\" asc";
if(parametersExist)
  ingQry = "Select * from dish_ingredients where \"ingredientid\" IN("+ing+") order by \"dishid\" asc, \"ingredientid\" asc";

ResultSet ingRs = stmt.executeQuery(ingQry);

//The stored results from dish_ingredients will be placed into a dictionary
Map<Integer,String> map = new HashMap<Integer,String>();

while(ingRs.next()){
	int dishId = ingRs.getInt("dishid");
	String ingId = Integer.toString(ingRs.getInt("ingredientid"));

	if(map.containsKey(dishId)){
		String newValue = map.get(dishId) + ", "+ingId;
		map.put(dishId, newValue);
	}
	else{
		map.put(dishId,ingId);
	}
}

//Go through each dish to see if ingredients chosen by user are in the dish
// 	then add to the 'dishesThatQualify' string the dishId that qualifies to be in the menu
//Create an iterator for each value in mapping
Iterator it = map.entrySet().iterator();
String dishesThatQualify = "";
while(it.hasNext()){
	Map.Entry pairs = (Map.Entry)it.next();
	
	//Create a string array to hold the ingredients for each dish
	String [] ingredients = map.get(pairs.getKey()).split(", ");

	
	//If more ingredients were chosen by user than a dish contains, then skip to next dish
	if(amountOfIngredients > ingredients.length)
		continue;
	int amtIngredMatch = 0;
	//Loop through each ingredients chosen from user
	for(int i=0;i<amountOfIngredients;i++){
		//loop through dish ingredient
		for(int j=0;j<ingredients.length;j++){
			if(Integer.parseInt(ingredientsPassed[i]) == Integer.parseInt(ingredients[i])){
				amtIngredMatch++;
				break;
			}
		}
	} // end ingredient loop
	
	// If the amount of ingredients passed equal the amount of ingredients match
	if(amtIngredMatch == amountOfIngredients)
		dishesThatQualify += pairs.getKey()+",";
} // end looping through map
if(dishesThatQualify.length() != 0)
	dishesThatQualify = dishesThatQualify.substring(0,dishesThatQualify.length()-1);
%>


<% 

String [] dishArray = dishesThatQualify.split(",");
//This part will handle querying the database for the right dishes to show
// 	then displays it as a json object

String dishQry = "select dishes.id as id, dishes.name as name, price, picture, menu_categories.name as category from dishes inner join menu_categories"+
    	" on dishes.categoryid =menu_categories.id";
String whereClause = " Where dishes.id IN (";

// build the where clause for ingredients chosen
if(parametersExist){
	for(int i=0;i<dishArray.length;i++){
		whereClause += dishArray[i] + ",";
	}
	whereClause = whereClause.substring(0,whereClause.length()-1);
	dishQry += whereClause + ")";
}
dishQry += " order by category, name asc";
ResultSet dishesRs = stmt.executeQuery(dishQry);

JsonArray data = new JsonArray();
JsonArray row = new JsonArray();

while(dishesRs.next()){
	JsonObject jsonResponse = new JsonObject();
	jsonResponse.addProperty("Name", dishesRs.getString("name"));
	jsonResponse.addProperty("Price", dishesRs.getDouble("price"));
	jsonResponse.addProperty("Picture", dishesRs.getString("picture"));
	jsonResponse.addProperty("Category", dishesRs.getString("category"));
	jsonResponse.addProperty("ID", dishesRs.getInt("id"));
	row.add(jsonResponse);
}

out.println(row);
conn.close();
%>


