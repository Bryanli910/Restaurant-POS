<%@ page import="com.default.db_connect" %>
<%@ page import="java.sql.*" %>
<%! String[] ingredients; %>
<%
Connection conn = db_connect.getConnection();
 
 int userRole = session.getAttribute("role") == null ? -1 : (Integer) session.getAttribute("role");
 if(session.getAttribute("role") == null ) response.sendRedirect("login.jsp");
 if(userRole != 0 && userRole != 1 && userRole != 4) response.sendRedirect("login.jsp"); //Make sure kitchen staff can't get here
 
String[] modeDefinition = {"#manage_accounts", "#manage_ingredients", "#manage_categories", "#manage_dishes", "#manage_ingredient_categories"}, 
modeTableDefinition = {"accounts", "ingredients", "menu_categories", "dishes", "ingredient_categories"},
modeTableKeys = {"accountid", "id", "id", "id", "id"},
modeString = {"Account", "Ingredient", "Dish_Category", "Dish", "Ingredient_Category"};

//Used to load details of selectedId, perhaps a json map is better - construct forms dynamically
String username = "New User", password = "", firstname = "", lastname = "", role = "",
		ingredientname = "New Ingredient", ingredientunit = "", categoryname = "New Dish Category", name = "New Dish", description = "", pictureurl = "",
		ingredientcategoryname = "New Ingredient Category";
int formActionId = 1, ingredientamount = 0, categoryid = 0, managementMode = 0, selectedId = -1, newId = 1, actionId = -1, ingredientcategory = -1;
double price = 0;

if(request.getParameterMap().containsKey("mode")) managementMode = Integer.parseInt(request.getParameter("mode"));
if(request.getParameterMap().containsKey("id")) selectedId = Integer.parseInt(request.getParameter("id"));
if(request.getParameterMap().containsKey("action")) actionId = Integer.parseInt(request.getParameter("action"));
	
	
 if(null == session.getAttribute("role") || userRole != 0 && userRole != 1) actionId = -1; //Guest can't do anything
	
	
PreparedStatement updateStatement;

if(actionId == 1 || actionId == 4 || actionId == 6){
		Statement stmt = conn.createStatement();
		ResultSet res = stmt.executeQuery("SELECT MAX("+(actionId == 1 ? modeTableKeys[managementMode] : ( actionId == 4 ? "optionid" : "choiceoptionid" ))+") FROM "+(actionId == 1 ? modeTableDefinition[managementMode] : (actionId == 4 ? "dish_customization_options" : "dish_customization_option_choices")));
		if(res.next()) newId += res.getInt(1);
		res.close();
}

if(managementMode == 0 && actionId != -1){
	switch(actionId){
		case 1: //Action 1: Add
			updateStatement = conn.prepareStatement("INSERT INTO accounts VALUES (?, ?, ?, ?, ?, ?, ?)");
			updateStatement.setString(1, request.getParameter("username"));
			updateStatement.setString(2, request.getParameter("password"));
			updateStatement.setString(3, request.getParameter("firstname"));
			updateStatement.setString(4, request.getParameter("lastname"));
			updateStatement.setTimestamp(5, new Timestamp(new java.util.Date().getTime()));
			updateStatement.setInt(6, newId);
			updateStatement.setString(7, request.getParameter("role"));
			updateStatement.executeUpdate();
			updateStatement.close();
			selectedId = newId;
		break;
		case 2: //Action 2: Update
			updateStatement = conn.prepareStatement("UPDATE accounts SET username='"+request.getParameter("username")+"', password='"+request.getParameter("password")+"', firstname='"+request.getParameter("firstname")+"', lastname='"+request.getParameter("lastname")+"', role='"+request.getParameter("role")+"' WHERE accountid="+request.getParameter("id"));
			updateStatement.executeUpdate();
			updateStatement.close();
		break;
	}
}else if(managementMode == 1 && actionId != -1){
	switch(actionId){
		case 1: //Action 1: Add
			updateStatement = conn.prepareStatement("INSERT INTO ingredients VALUES (?, ?, ?, ?, ?)");
			updateStatement.setInt(1, newId);
			updateStatement.setString(2, request.getParameter("name"));
			updateStatement.setInt(3, Integer.parseInt(request.getParameter("amount")));
			updateStatement.setString(4, request.getParameter("units"));
			updateStatement.setInt(5, Integer.parseInt(request.getParameter("categoryid")));
			updateStatement.executeUpdate();
			updateStatement.close();
			selectedId = newId;
		break;
		case 2: //Action 2: Update
			updateStatement = conn.prepareStatement("UPDATE ingredients SET name='"+request.getParameter("name")+"', stock="+request.getParameter("amount")+", units='"+request.getParameter("units")+"', categoryid="+Integer.parseInt(request.getParameter("categoryid"))+" WHERE id="+request.getParameter("id"));
			updateStatement.executeUpdate();
			updateStatement.close();
		break;
	}
}else if(managementMode == 2 && actionId != -1){
	switch(actionId){
		case 1: //Action 1: Add
			updateStatement = conn.prepareStatement("INSERT INTO menu_categories VALUES (?, ?)");
			updateStatement.setString(1, request.getParameter("name"));
			updateStatement.setInt(2, newId);
			updateStatement.executeUpdate();
			updateStatement.close();
			selectedId = newId;
		break;
		case 2: //Action 2: Update
			updateStatement = conn.prepareStatement("UPDATE menu_categories SET name='"+request.getParameter("name")+"' WHERE id="+request.getParameter("id"));
			updateStatement.executeUpdate();
			updateStatement.close();
		break;
	}

}else if(managementMode == 3 && actionId != -1){
	switch(actionId){
		case 1: //Action 1: Add
			updateStatement = conn.prepareStatement("INSERT INTO dishes VALUES (?, ?, ?, ?, ?, ?)");
			updateStatement.setInt(1, newId);
			updateStatement.setString(2, request.getParameter("name"));
			updateStatement.setDouble(3, Double.parseDouble(request.getParameter("price")));
			updateStatement.setString(4, request.getParameter("description"));
			updateStatement.setInt(5, Integer.parseInt(request.getParameter("categoryid")));
			updateStatement.setString(6, request.getParameter("pictureurl"));
			updateStatement.executeUpdate();
			updateStatement.close();
   
   			ingredients = request.getParameterValues("ingredients");
			for (int i = 0; i < ingredients.length; i++){				
				updateStatement = conn.prepareStatement("INSERT INTO dish_ingredients VALUES (?, ?, ?)");
				updateStatement.setInt(1, 0);
				updateStatement.setInt(2, newId);
				updateStatement.setInt(3, Integer.parseInt(ingredients[i]));
				updateStatement.executeUpdate();
				updateStatement.close();
			}
				
			selectedId = newId;
		break;
		case 2: //Action 2: Update
			updateStatement = conn.prepareStatement("UPDATE dishes SET name='"+request.getParameter("name")+"', price='"+request.getParameter("price")+"', description='"+request.getParameter("description")+"', categoryid='"+request.getParameter("categoryid")+"', picture='"+request.getParameter("pictureurl")+"' WHERE id="+request.getParameter("id"));
			updateStatement.executeUpdate();
			updateStatement.close();
		
			updateStatement = conn.prepareStatement("DELETE FROM dish_ingredients WHERE dishid="+request.getParameter("id"));
			updateStatement.executeUpdate();
			updateStatement.close();
			
			if(request.getParameterMap().containsKey("ingredients")){
			ingredients = request.getParameterValues("ingredients");
			for (int i = 0; i < ingredients.length; i++){
				updateStatement = conn.prepareStatement("INSERT INTO dish_ingredients VALUES (?, ?, ?)");
				updateStatement.setInt(1, 0);
				updateStatement.setInt(2, Integer.parseInt(request.getParameter("id")));
				updateStatement.setInt(3, Integer.parseInt(ingredients[i]));
				updateStatement.executeUpdate();
				updateStatement.close();
			}
			}
		break;
		case 4: //Add option
			updateStatement = conn.prepareStatement("INSERT INTO dish_customization_options VALUES (?, ?, ?)");
			updateStatement.setInt(1, newId);
			updateStatement.setString(2, request.getParameter("optionname"));
			updateStatement.setInt(3, selectedId);
			updateStatement.executeUpdate();
			updateStatement.close();
		break;
		case 5: //Remove option
			updateStatement = conn.prepareStatement("DELETE FROM dish_customization_option_choices WHERE optionid="+request.getParameter("optionid"));
			updateStatement.executeUpdate();
			updateStatement.close();
		
			updateStatement = conn.prepareStatement("DELETE FROM dish_customization_options WHERE optionid="+request.getParameter("optionid"));
			updateStatement.executeUpdate();
			updateStatement.close();
		break;
		case 6: //Add option choice
			updateStatement = conn.prepareStatement("INSERT INTO dish_customization_option_choices VALUES (?, ?, ?)");
			updateStatement.setInt(1, newId);
			updateStatement.setString(2, request.getParameter("choicename"));
			updateStatement.setInt(3, Integer.parseInt(request.getParameter("optionid")));
			updateStatement.executeUpdate();
			updateStatement.close();
		break;
		case 7: //Remove option choice
			updateStatement = conn.prepareStatement("DELETE FROM dish_customization_option_choices WHERE choiceoptionid="+request.getParameter("choiceid"));
			updateStatement.executeUpdate();
			updateStatement.close();
		break;
	}
}else if(managementMode == 4 && actionId != -1){
	switch(actionId){
		case 1: //Action 1: Add
			updateStatement = conn.prepareStatement("INSERT INTO ingredient_categories VALUES (?, ?)");
			updateStatement.setInt(1,newId);
			updateStatement.setString(2, request.getParameter("name"));
			updateStatement.executeUpdate();
			updateStatement.close();
			selectedId = newId;
		break;
		case 2: //Action 2: Update
			updateStatement = conn.prepareStatement("UPDATE ingredient_categories SET name='"+request.getParameter("name")+"' WHERE id="+request.getParameter("id"));
			updateStatement.executeUpdate();
			updateStatement.close();
		break;
	}

}

if(actionId == 3){ //Delete is same for all modes
	if(managementMode == 3){ //Delete food needs delete ingredients relations
		updateStatement = conn.prepareStatement("DELETE FROM dish_ingredients WHERE dishid="+request.getParameter("id"));
		updateStatement.executeUpdate();
		updateStatement.close();
	}
	
	updateStatement = conn.prepareStatement("DELETE FROM "+modeTableDefinition[managementMode]+" WHERE "+modeTableKeys[managementMode]+"="+request.getParameter("id"));
	updateStatement.executeUpdate();
	updateStatement.close();
	selectedId = -1;
}else if(selectedId != -1){ //An item was selected
	
	formActionId = 2; //Selected means we are editing
	Statement getSelectedStmt = conn.createStatement();
	String[] getSelectedRequest = {"select * from accounts where accountid=" + Integer.toString(selectedId), 
	"select * from ingredients where id=" + Integer.toString(selectedId),
	"select * from menu_categories where id=" + Integer.toString(selectedId),
	"select * from dishes where id=" + Integer.toString(selectedId),
	"select * from ingredient_categories where id=" + Integer.toString(selectedId) };
	
	ResultSet getSelectedResult = getSelectedStmt.executeQuery(getSelectedRequest[managementMode]);
	if(getSelectedResult.next())
		switch(managementMode){
			case 0:
				username = getSelectedResult.getString("username");
				password = getSelectedResult.getString("password");
				firstname = getSelectedResult.getString("firstname");
				lastname = getSelectedResult.getString("lastname");
				role = getSelectedResult.getString("role");
			break;
			case 1:
				ingredientname = getSelectedResult.getString("name");
				ingredientunit = getSelectedResult.getString("units");
				ingredientamount = getSelectedResult.getInt("stock");
				ingredientcategory = getSelectedResult.getInt("categoryid");
			break;
			case 2:
				categoryname = getSelectedResult.getString("name");
			break;
			case 3:
				name = getSelectedResult.getString("name");
				price = getSelectedResult.getDouble("price");
				description = getSelectedResult.getString("description");
				categoryid = getSelectedResult.getInt("categoryid");
				pictureurl = getSelectedResult.getString("picture");
			break;
			case 4:
				ingredientcategoryname = getSelectedResult.getString("name");
			break;
		}
	getSelectedResult.close();
} %>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
	<title>Management</title>
    
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
.inner-container::-webkit-scrollbar {
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
#content-1 {
	float:left;
	width:220px;
	height:100%;
	overflow-y:scroll;
	border-right: 1px #ddd solid;
	-webkit-overflow-scrolling: touch;
	-ms-overflow-style: none;
}
#content-1::-webkit-scrollbar { width: 0 !important }
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
.accountListItemText{
	width: 148px;
	height: 17px;
	overflow: hidden;
	display: inline-block;
}
#content-2wrapper {
	float:right;
	height:100%;
	position: absolute;
	left: 221px;
	right: 0px;
}
#content-2-1 {
	float:left;
	width:220px;
	height: 100%;
	overflow-y:scroll;
	border-right: 1px #ddd solid;
	display:block;
	-webkit-overflow-scrolling: touch;
	-ms-overflow-style: none;
}
#content-2-1::-webkit-scrollbar { width: 0 !important }
#content-2-2wrapper {
	right: 0px;
	left: 221px;
	padding:10px;
	position: absolute;
	top: 0px;
	bottom: 0px;
}
.editItemTitle{
	font-size: 30px;
	width: 100%;
	border-bottom: 1px #ddd solid;	
	margin-bottom: 10px;
}
#content-2-2 {
	background:#fff;
	position:absolute;
	top: 10px;
	bottom: 10px;
	left: 10px;
	right: 10px;
	padding: 10px;
	border: 1px #999 solid;
	border-radius:5px;
	box-shadow: 3px 3px 3px #888888;
}
.editFormContainer{
	position: absolute;
	top:60px;
	bottom: 10px;
	width: 99%;
	overflow-y:scroll;
	-webkit-overflow-scrolling: touch;
	-ms-overflow-style: none;
}
.editFormContainer::-webkit-scrollbar { width: 0 !important }
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
<%= modeDefinition[managementMode] %>{
	background-color: #ddd;
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
		var selectedMode = 0, selectedId = <%= selectedId %>;
		<%
			String print = "";
			for(int i = 0; i < modeDefinition.length; i++) print += (i == 0 ? "" : ",")+"\""+modeDefinition[i]+"\"";
		%>
		var modes = [<%= print %>];
		<%
			print = "";
			for(int i = 0; i < modeString.length; i++) print += (i == 0 ? "" : ",")+"\""+modeString[i]+"\"";
		%>
		var modeString = [<%= print %>];
		$(document).ready(function() {
			assignEvents();
			$.ajaxSetup({
    			timeout: 3000 //Time in milliseconds
			});
			$(document).ajaxError(function(event, request, settings) {
			 	$("#content-2-2").html("An ajax error has occured"); //TODO: fail gracefully
			});
		});
		function assignEvents(){
			for(var i = 0; i < modes.length; i++){
				$(modes[i]).click(function(){
					if($(this).css("backgroundColor", "#ddd"))
					for(var i = 0; i < modes.length; i++)
						if(modes[i] != "#"+$(this).attr("id"))
							$(modes[i]).css("backgroundColor", "#fff");
						else{
							$(modes[i]).css("backgroundColor", "#ddd");
							if(modes[selectedMode] != "#"+$(this).attr("id")){
								$(modes[selectedMode]+"_spinner").fadeOut(100);
								selectedMode = i;
								selectedId = -1;
								ajaxAction(null);
							}
						}
				});
			}
			
			$(".accountListItem").click(function(){
				$("#"+modeString[selectedMode].toLowerCase()+selectedId+"_spinner").fadeOut(100);
				if(!$(this).attr("id").startsWith("manage") && selectedId != $(this).attr("id").replace(modeString[selectedMode].toLowerCase(), "") && !($(this).attr("id") == "newObject" && selectedId == -1)){
					$("#"+modeString[selectedMode].toLowerCase()+selectedId).css("backgroundColor", "#fff"); //Deselect old item
					$("#newObject").css("backgroundColor", "#fff"); //Deselect new tab
					$(".newestItem").css("backgroundColor", "#fff"); //Deselect newest item
					$(this).css("backgroundColor", "#ddd"); //Select clicked item
					($(this).attr("id") == "newObject") ? (selectedId = -1) : (selectedId = $(this).attr("id").replace(modeString[selectedMode].toLowerCase(), ""));
					$("#"+$(this).attr("id")+"_spinner").fadeIn(100);
					$("#content-2-2wrapper").fadeOut(100, function(spinner){
						$("#content-2-2wrapper").load(document.URL+"?mode="+selectedMode+(($(this).attr("id") == "newObject") ? ("&action=0") : ("&id="+selectedId))+" #content-2-2", function(){ $("#content-2-2wrapper").fadeIn(100, function(){ $(spinner).fadeOut(100);}); });
					}("#"+$(this).attr("id")+"_spinner"));
				}
			});
		}
		
		function ajaxAction(form){ ajaxActionData((form == null) ? null : $(form).serializeArray()); }
		function addOptions(dishid){ ajaxActionData({'mode' : 3, 'id' : dishid, 'action' : 4, 'optionname' : $("#newOption").val()}); }
		function removeOptions(dishid, optionid){ ajaxActionData({'mode' : 3, 'id' : dishid, 'action' : 5, 'optionid' : optionid}); }
		function addOptionChoices(dishid, optionid, choicename){ ajaxActionData({'mode' : 3, 'id' : dishid, 'action' : 6, 'optionid' : optionid, 'choicename' : $("#newChoice"+optionid).val()}); }
		function removeChoices(dishid, choiceid){ ajaxActionData({'mode' : 3, 'id' : dishid, 'action' : 7, 'choiceid' : choiceid}); }
		
		function ajaxActionData(dataSet){ 
			$(modes[selectedMode]+"_spinner").fadeIn(100);
			$("#content-2-2wrapper").fadeOut(100, function(){
				$("#content-2wrapper").fadeOut(100, function(){
					$(this).load(document.URL+"?mode="+selectedMode+" #content-2", dataSet, function(){  //POST
									assignEvents();
									$("#content-2-2wrapper").hide();
									$("#content-2wrapper").fadeIn(100, function(){ $("#content-2-2wrapper").fadeIn(100, function(){ $(modes[selectedMode]+"_spinner").fadeOut(100);}); });
					});
					
				});
			});
		}
	</script>
</head>
<body>
	<div id="body">
		<div id="main" class="cf">
			<div id="content-1">
                <div id="manage_accounts" class="accountListItem">Accounts
                <img src="assets/spinner.gif" id="manage_accounts_spinner" alt="-" class="itemSpinner"/></div>
                <div id="manage_ingredient_categories" class="accountListItem">Ingredient Categories
                <img src="assets/spinner.gif" id="manage_ingredient_categories_spinner" alt="-" class="itemSpinner"/></div>
                <div id="manage_ingredients" class="accountListItem">Ingredients
                <img src="assets/spinner.gif" id="manage_ingredients_spinner" alt="-" class="itemSpinner"/></div>
                <div id="manage_categories" class="accountListItem">Dish Categories
                <img src="assets/spinner.gif" id="manage_categories_spinner" alt="-" class="itemSpinner"/></div>
                <div id="manage_dishes" class="accountListItem">Dishes
                <img src="assets/spinner.gif" id="manage_dishes_spinner" alt="-" class="itemSpinner"/></div>
                <div id="logout_button" class="accountListItem" onclick="location.href='login.jsp?logout=true'"><strong>Logout</strong></div>
			</div>
            <div id="content-2wrapper">
                <div id="content-2">
                        <div id="newObject" class="accountListItem" style="<%= (selectedId == -1) ? "background-color: #ddd;" : "" %>z-index:9999;bottom: 0px; width:178px; height: 20px; position:absolute; ">
                        	<strong>+</strong> New...<!--New <%= modeString[managementMode].replaceAll("_", " ") %>-->
                			<img src="assets/spinner.gif" id="newObject_spinner" alt="-" class="itemSpinner"/>
                        </div>
                        
                    <div id="content-2-1"><%
                            Statement getAccountsStatement = conn.createStatement();
                            
                            String[] objectQueries = {"select username, firstname, lastname, accountid from accounts order by username asc",
                                "select name, id from ingredients order by name asc",
                                "select name, id from menu_categories order by name asc",
                                "select name, id from dishes order by name asc",
								"select name, id from ingredient_categories order by name asc"};
                            
                            ResultSet objectResults = getAccountsStatement.executeQuery(objectQueries[managementMode]);
                            while(objectResults.next()){%>
                                <div <%= (objectResults.getInt(managementMode == 0 ? "accountId" : "id") == selectedId) ? "style=\"background-color:#ddd;\"" : "" %> id="<%= modeString[managementMode].toLowerCase() %><%= objectResults.getInt(managementMode == 0 ? "accountId" : "id") %>" class="accountListItem newestItem"><span class="accountListItemText">
                                <%
                                switch(managementMode){
                                    case 0:
                                    	if(objectResults.getInt("accountId") != 1){ %>
										<%= objectResults.getString("firstname") %> <%= objectResults.getString("lastname") %>
										<% }else{ %><%= objectResults.getString("username") %><% }
                                    break;
                                    default: %><%= objectResults.getString("name") %><% break;
                                }
                                %>
                                </span>
                                <img src="assets/spinner.gif" id="<%= modeString[managementMode].toLowerCase() %><%= objectResults.getInt(managementMode == 0 ? "accountId" : "id") %>_spinner" alt="-" class="itemSpinner"/>
                                </div>
                        <% }
                        objectResults.close(); %><br><br><br>
                  </div>
                  <div id="content-2-2wrapper">
                  <div id="content-2-2">
                  
                        <div class="editItemTitle">
                            <span class="editItemTitleText"><%
                                switch(managementMode){
                                    case 0: %><%= username %><% break;
                                    case 1: %><%= ingredientname %><% break;
                                    case 2: %><%= categoryname %><% break;
                                    case 3: %><%= name %><% break;
                                    case 4: %><%= ingredientcategoryname %><% break;
                                }
							%></span>
                        
                        	<% 
							if(userRole != -1 && (userRole == 0 || userRole == 1)){
							if(selectedId != -1 && !(managementMode == 0 && selectedId == 1)){
							
								 %>
                            <form class="deleteForm" style="float:right;margin-left:5px;" method="post">
                                <input type="hidden" name="mode" value="<%= managementMode %>" />
                                <input type="hidden" name="id" value="<%= selectedId %>" />
                                <input type="hidden" name="action" value="3" />
                                <img src="assets/delete.png" width="64" alt="Delete" onclick="ajaxAction('.deleteForm');"/>
                            </form>
                            <% } %>
                        	<img src="assets/save.png" width="64" style="float:right;" alt="Save" onclick="ajaxAction('.editForm');"/>
                            <%
							}
							%>
                        </div>
                        <div class="editFormContainer">
                         	<form class="editForm" method="post">
										<% if(selectedId != -1){ %><input type="hidden" name="id" value="<%= selectedId %>" /><% } %>	
                                    	<input type="hidden" name="mode" value="<%= managementMode %>" />
                                        <input type="hidden" name="action" value="<%= formActionId %>" />
                        <% switch(managementMode){
							case 0: %>
                                        <label>Username:</label><br />
                                        <input type="text" placeholder="Username" name="username" value="<%= username %>" /><br /><br />
                                        <label>Name:</label><br />
                                        <input type="text" placeholder="First" name="firstname" value="<%= firstname %>"/> <input type="text" placeholder="Last" name="lastname" value="<%= lastname %>"/><br /><br />
                                        <%
										if(userRole == 0 || userRole == 1){
										%>
                                        <label>Password:</label><br />
                                        <input type="password" placeholder="Username" name="password" value="<%= password %>"/><br /><br />
                                        <%
										}
										%>
                                        <label>Role:</label> <br />
                                        <input type="text" name="role" placeholder="Role" value="<%= role %>"/><br /><br />
                                        <label>Last login: Never</label><br /><br />
                            <% break;
							case 1: %>
                                    <label>Name:</label><br />
                                    <input type="text" placeholder="Name" value="<%= ingredientname %>" name="name" /><br /><br />
                                    <label>Amount:</label><br />
                                    <input type="text" placeholder="Amount" value="<%= ingredientamount %>" name="amount" /><br /><br />
                                    <label>Units:</label><br />
                                    <input type="text" placeholder="Units" value="<%= ingredientunit %>" name="units" /><br /><br />
                                    <label>Category:</label> <br />
                                    <select name="categoryid">
                                    
										<%
                                        Statement stmti22 = conn.createStatement();
                                        ResultSet resi22 = stmti22.executeQuery("select name, id from ingredient_categories order by name asc");
                                        while(resi22.next()){
                                        %>
                                        <option <%= (ingredientcategory == resi22.getInt("id") ? "selected" : "") %> value="<%= resi22.getInt("id") %>"><%= resi22.getString("name") %></option>
                                        <%
                                        }
                                        resi22.close();
                                        %>
                                    </select><br /><br />
                            <% break;
							case 2: %>
                                    <label>Name:</label><br />
                                    <input type="text" placeholder="Name" name="name" value="<%= categoryname %>" /><br /><br />
                            <% break;
							case 3: %>
                                    <label>Name:</label><br />
                                    <input type="text" placeholder="Name" name="name" value="<%= name %>" /><br /><br />
                                    <label>Price:</label><br />
                                    <input type="text" placeholder="Price" name="price" value="<%= price %>"/><br /><br />
                                    <label>Description:</label><br />
                                    <input type="text" placeholder="Description" name="description" value="<%= description %>"/><br /><br />
                                    <label>Category:</label> <br />
                                    <select name="categoryid">
                                    
                                    <%
                                    Statement stmti2 = conn.createStatement();
                                    String reqi2 = "select name, id from menu_categories order by name asc";
                                    ResultSet resi2 = stmti2.executeQuery(reqi2);
                                    while(resi2.next()){
                                    %>
                                    <option <%= (categoryid == resi2.getInt("id") ? "selected" : "") %> value="<%= resi2.getInt("id") %>"><%= resi2.getString("name") %></option>
                                    <%
                                    }
                                    resi2.close();
                                    %>
                                    </select><br /><br />
                                    <label>Picture URL:</label><br />
                                    <input type="text" name="pictureurl" placeholder="Picture URL" value="<%= pictureurl %>"/><br /><br />
                                    <label>Ingredients:</label><br /><br />
                                    <%
                                    
                                    if(selectedId == -1){
                                    Statement stmti = conn.createStatement();
                                    String reqi = "select name, id from ingredients order by name asc";
                                    ResultSet resi = stmti.executeQuery(reqi);
                                    while(resi.next()){
                                    %>
                                    
                                    <INPUT NAME="ingredients" TYPE="CHECKBOX" VALUE="<%= resi.getInt("id") %>">
                                    <%= resi.getString("name") %><BR>
                                    <%
                                    }
                                    resi.close();
                                    
                                    }else{
                                    
                                    Statement stmti = conn.createStatement();
                                    ResultSet resi = stmti.executeQuery("SELECT ingredients.id, ingredients.name FROM public.dish_ingredients, public.dishes, public.ingredients WHERE dish_ingredients.dishId = dishes.id AND ingredients.id = dish_ingredients.ingredientId AND dishes.id = "+selectedId + " ORDER BY ingredients.name asc");
                                    while(resi.next()){
                                    %>
                                    
                                    <INPUT NAME="ingredients" TYPE="CHECKBOX" CHECKED="TRUE" VALUE="<%= resi.getInt("id") %>">
                                    <%= resi.getString("name") %><BR>
                                    <% 
                                    }
                                    resi.close();
                                    
                                    Statement stmti1 = conn.createStatement();
                                    ResultSet resi1 = stmti.executeQuery("SELECT ingredients.id, ingredients.name FROM public.ingredients WHERE ingredients.id NOT IN (SELECT ingredients.id FROM public.dish_ingredients, public.dishes, public.ingredients WHERE dish_ingredients.dishId = dishes.id AND ingredients.id = dish_ingredients.ingredientId AND dishes.id = "+selectedId + ") ORDER BY ingredients.name asc");
                                    while(resi1.next()){
                                    %>
                                    
                                    <INPUT NAME="ingredients" TYPE="CHECKBOX" VALUE="<%= resi1.getInt("id") %>">
                                    <%= resi1.getString("name") %><BR/>
                                    <%
                                    }
                                    resi1.close();
                                    }
                                    %>
                                    
                                    <br />
                                    <label>Options:</label> <br />
                                        <ul style="list-style-type: none;">
                                            <% if(selectedId != -1){ %>
                                                <%
                                                Statement getOptionNames = conn.createStatement();
                                                ResultSet resi3 = getOptionNames.executeQuery("SELECT * FROM dish_customization_options WHERE dish_customization_options.dishid = "+selectedId + " ORDER BY dish_customization_options.name asc");
                                                while(resi3.next()){
                                                %>
                                                    <li id="option<%= resi3.getInt("optionid") %>">
                                                    <span id="deleteOption<%= resi3.getInt("optionid") %>" onclick="removeOptions(selectedId,<%= resi3.getInt("optionid") %>);"><img src="assets/remove.png" style="vertical-align:middle; height:29px;" alt="Remove Option"/></span> <%= resi3.getString("name") %>
                                                        <ul style="list-style-type: none;">
                                                        <%
                                                        Statement getOptionChoices = conn.createStatement();
                                                        ResultSet getOptionChoicesResults = getOptionChoices.executeQuery("SELECT * FROM dish_customization_option_choices WHERE dish_customization_option_choices.optionid = "+resi3.getInt("optionid") + " ORDER BY dish_customization_option_choices.name asc");	
                                                        while(getOptionChoicesResults.next()){
                                                            
                                                    %>
                                                    <li id="optionChoice<%= getOptionChoicesResults.getInt("choiceoptionid") %>">
                                                    <span id="deleteOptionChoice<%= getOptionChoicesResults.getInt("choiceoptionid") %>"  onclick="removeChoices(selectedId,<%= getOptionChoicesResults.getInt("choiceoptionid") %>);"><img src="assets/remove.png" style="vertical-align:middle; height:29px;" alt="Remove Choice"/></span> <%= getOptionChoicesResults.getString("name") %>
                                                    </li>
                                                    <% } %>
                                                    
                                                    <li><strong onclick="addOptionChoices(selectedId, <%= resi3.getInt("optionid") %>);"><img src="assets/add.png" style="vertical-align:middle; height:29px;" alt="Add Choice"/></strong> <input type="text" placeholder="New choice" id="newChoice<%= resi3.getInt("optionid") %>" value="" /></li>
                                                    </ul>
                                                </li>                                    
                                                <%
                                                }
                                                resi3.close();
                                                %>
                                            <% } %>
                                            <li><strong onclick="addOptions(selectedId);"><img src="assets/add.png" style="vertical-align:middle; height:29px;" alt="Add Options"/></strong> <input type="text" placeholder="New option" id="newOption" value="" /></li>
                                        </ul>
                            <% break;
							case 4: %>
                                    <label>Name:</label><br />
                                    <input type="text" placeholder="Name" name="name" value="<%= ingredientcategoryname %>" /><br /><br />
                            <% break;
                        } %>
                         </form>
                        </div>
                    </div>
                    </div>
                </div>
                </div>
		</div>
	</div>
</body>
</html>
<% conn.close(); %>