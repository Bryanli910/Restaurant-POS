function getIngredients(){
	$(".main").empty();
	var ingredients = "ingredients=";
	var ingredientsArray = new Array();
	$(".ingredients").each(function(){
		if(this.checked){
			ingredientsArray.push(this.id);
		}
	});
	ingredientsArray.sort(sortNumber);
	ingredients += ingredientsArray.toString();

	getDishes(ingredients);
}

function sortNumber(a,b) {
    return a - b;
}

function updateTotal(){
	var prices = document.getElementsByClassName("orderLinePrice");
	var quantity = document.getElementsByClassName("qtyTextBox");
	var subTotal = 0;
	for(var i=prices.length-1; i >= 0; i--){
		subTotal += parseInt(quantity[i].value) * parseFloat(prices[i].innerHTML.substring(1));
		if(quantity[i].value == 0){
			$(".orderLineItem:eq("+i+")").remove();
		}
	}
	document.getElementById("subTotal").innerHTML = "$ " + subTotal.toFixed(2);
}

function addToOrder(menuItem){
	var menuItem = menuItem.split(",");
	var itemName = menuItem[0];
	var price = menuItem[1];
	var dishId = menuItem[2];
	
	var prices = $('#qtyText'+dishId);
	if(prices.length){
			prices.val(parseInt(prices.val())+1);
			updateTotal();
	}else{
		$("#orderItems").append( 
			"<div class='orderLineItem'><li><div class='orderLineName'>"+itemName+"</div>" +
			"<div class='orderLinePrice'>$"+price+"</div>"+
			"<div class='orderLineQty'>Qty:<input class='qtyTextBox' id='qtyText"+dishId+"' type='number' maxlength='2' value=1></div></li>");
		updateTotal();
	}
	return false;
}

$( document ).ready(function() {
	//Assign click events
	$("#createOrderButton").click(function(){
		$(".welcomeScreenContainer").transition({left:'100%'}, 500, 'ease', function(){
		$(this).hide();
		$('html, body').css('overflowY', 'auto'); 
		});
	});
	
	$("#submitBtn").click(function(){
		updateTotal();
		var orderItems = "";
		$('.qtyTextBox').each(function(){
			var dishId = "";
			var qty = this.value;
			//itemName = this.id.substring(7,this.id.length-1);
			//itemName = itemName.replace(new RegExp("_","g")," ");
			dishId = this.id.substring(7,this.id.length);
			orderItems += dishId + ","+qty+",";
		}); // end of .qtyTextBox.each()
		
		//The following is the entire order as a string delimitted by a comma
		//The string is formed by: "dishID,Quantity"
		orderItems = orderItems.substring(0, orderItems.length-1);
		var orderNum = $("#orderNum").text().trim();

		//Begin ajax call to submit the order
		$.ajax({
			type:"POST",
			url:"submit_order.jsp",
			data: {order: orderItems, orderNumber:orderNum},
			success: function(data){
				window.location.replace("customer_orders.jsp?orderNum="+orderNum);
			}
		}); // end of ajax call
		
	}); // end of #submitBtn.click()
	
	//This function will clear the dishes on the main menu
	$("#clearBtn").click(function(){
		//$(".main").empty();
		$(".ingredients").each(function(){
			this.checked = false;
		});
		getIngredients();
	});
	
}); //end of document.Ready function

function getDishes(ingredients){
	var placeholderClass = "col-xs-6 col-sm-3 placeholder";
	var categoryClass = "page-header";
	var rowClass = "row placeholders";
	var firstRow = true;
	var price = 0.0;
	var name = "";
	var category = "";
	var id=0;
	$.ajax({
		type:"GET",
		url:"getDishes.jsp",
		data: ingredients,
		dataType:"json",
		success: function(data){
			$.each(data,function(index, value){
				price = value["Price"];
    			name = value["Name"];
    			id = value["ID"];
    			if(category.match(value["Category"])){	
					$('#'+category).append("<div class='"+placeholderClass + "'>"+
					"<img src='"+value["Picture"]+"'alt='Food_Placeholder_Thumbnail'>"+
					"<h4>"+name+"</h4><span class='text-muted'>Price: $"+price+"</span>"+
					"<br />"+
					"<button class='addToOrder' type='button' value='"+name+
        			","+price+","+ id+ "' onclick='addToOrder(this.value)'>Add To Order</button></div>");
    			}
    			//This else handles printing the category separators for first row etc.
    			else{
    				if(firstRow){
    					category = value["Category"];
    					$('#menu').append("<h1 class='"+categoryClass+"'>"+category+"</h1>"+
    							"<div class='"+rowClass+"' id='"+category+"'><div class='"+placeholderClass + "'>"+
    							"<img src='"+value["Picture"]+"'alt='Food_Placeholder_Thumbnail'>"+
    							"<h4>"+name+"</h4>"+
    							"<span class='text-muted'>Price: $"+price+"</span>"+
    							"<br />"+
    							"<button class='addToOrder' type='button' value='"+name
        					+","+price+","+ id+ "' onclick='addToOrder(this.value)'>Add To Order</button></div>");
        				firstRow = false;
    				}
    				else{
    					category = value["Category"];
    					$('#menu').append("</div><h1 class='"+categoryClass+"'>"+category+"</h1>"+
    							"<div class='"+rowClass+"' id='"+category+"'><div class='"+placeholderClass + "'>"+
    							"<img src='"+value["Picture"]+"'alt='Food_Placeholder_Thumbnail'>"+
    							"<h4>"+name+"</h4>"+
    							"<span class='text-muted'>Price: $"+price+"</span>"+
    							"<br />"+
    							"<button class='addToOrder' type='button' value='"+name+
    							","+price+","+ id+ "' onclick='addToOrder(this.value)'>Add To Order</button></div>");
    				}// end of else
    			}// end of else
			}); // end of $.each()
		}, //end success callback function
		error: function(data, errorThrown){
			if(errorThrown == "error"){
				$('#menu').append("<h1><center>Sorry, we don't offer any dishes with your selected ingredients!</center></h1>");
				$('#menu').append("<br />");
				$('#menu').append("<h4><center>Please select a different combination of ingredients.</center></h4>");
			}
		}
	}); //end ajax call
} // end of getDishes()

