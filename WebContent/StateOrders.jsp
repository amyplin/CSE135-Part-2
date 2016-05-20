<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.sql.*, javax.naming.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
<title>CSE135 Project</title>
</head>
<body>


<%
	Connection conn = null;
	String orderName = " ORDER BY name ";
	String orderState = " ORDER BY state ";
	String orderTopK = " ORDER BY totals desc";
	String productOrder = orderName;
	String stateOrder = orderState;

	try {
		Class.forName("org.postgresql.Driver");
	    String url = "jdbc:postgresql://localhost:5433/postgres";
	    String admin = "postgres";
	    String password = "alin";
  	conn = DriverManager.getConnection(url, admin, password);
	}
	catch (Exception e) {}
	
	
	if ("POST".equalsIgnoreCase(request.getMethod())) {
		String action = request.getParameter("rows");
		if (action.equals("Customers")) {
			response.sendRedirect("orders.jsp");
		}
	} 
	
	
	String selectedOrder = request.getParameter("Order");
	System.out.println("selected order = " + selectedOrder);
	String selectedCategory = request.getParameter("sales");
	if ("Alphabetical".equals(selectedOrder)) {
		productOrder = orderName;
		stateOrder = orderState;
	} else {
		productOrder = orderTopK;
		stateOrder = orderTopK;
	}
	
	Statement stmt = conn.createStatement();
	Statement stmt2 = conn.createStatement();
	Statement stmt3 = conn.createStatement();
	Statement stmt4 = conn.createStatement();
	Statement stmt5 = conn.createStatement();
	Statement stmt6 = conn.createStatement();
	ResultSet rsSum = null;
	ResultSet rsProducts = null; 
	ResultSet rsCategories = stmt6.executeQuery("SELECT name FROM categories");
	int product_id;
%>


<div class="collapse navbar-collapse">
	<ul class="nav navbar-nav">
		<li><a href="index.jsp">Home</a></li>
		<li><a href="categories.jsp">Categories</a></li>
		<li><a href="products.jsp">Products</a></li>
		<li><a href="orders.jsp">Orders</a></li>
		<li><a href="login.jsp">Logout</a></li>
	</ul>
</div>
<div>
<div><h1>Sales Analytics</h1></div>

 <div class="form-group">
  	<form action="orders.jsp" method="POST">
  	<label for="Rows">Rows:</label>
  	<select name="rows" id="rows" class="form-control">
	    <option value="States">States</option>  	
	    <option value="Customers">Customers</option>
	</select>	
  	<label for="Order">Order:</label>
  	<select name="Order" id="order" class="form-control">
	    <option value="Alphabetical">Alphabetical</option>
	    <option value="Top-K">Top-K</option>
	</select>
	<label for="Sales">Sales-Filtering:</label>
  	<select name="Sales" id="sales" class="form-control">
  		<option value="All">All</option>
  	<% while (rsCategories.next()) { 
  		String category = rsCategories.getString("name"); %>
  		<option value=<%=category%>><%=category%></option>
  	<% } %>
	</select>
	<td><input class="btn btn-primary" type="submit" name="submit" value="Run Query"/></td>
	</form>
  </div>


<table class="table table-striped">
	<th></th>
<%  

	rsProducts = stmt2.executeQuery("WITH productInfo(totals, product_id) AS (select sum(orders.price) as totals, product_id " +
				"FROM orders group by product_id) SELECT products.name as name, productInfo.totals as totals, products.id FROM products INNER JOIN productInfo " + 
				"ON products.id = productInfo.product_id" + productOrder + " LIMIT 20");

	while (rsProducts.next()) {  //dispaly products %>
		<th><%=rsProducts.getString("name")%> (<%=rsProducts.getFloat("totals") %>)</th>	
<% 
	} 
	ResultSet rsState = stmt.executeQuery("WITH stateInfo(totals, state) AS (select sum(orders.price) as totals, users.state as state " +
				" from orders inner join users on orders.user_id = users.id group by users.state order by totals desc)" + 
			" SELECT DISTINCT LEFT(users.state,10) as state, stateInfo.totals FROM users INNER JOIN stateInfo ON users.state = " + 
				"stateInfo.state" +  stateOrder + " limit 10");
	int user_id;
	String state;
	ResultSet rs2 = null;
	ResultSet rs4 = null;
	%>
			<tbody>
				<% while (rsState.next()) { //loop through states %>
					<tr>
					<th><%=rsState.getString("state")%> (<%=rsState.getFloat("totals")%>)</th>

					<% 	rsProducts = stmt2.executeQuery("WITH productInfo(totals, product_id) AS (select sum(orders.price) as totals, product_id " +
 						"FROM orders group by product_id) SELECT products.name as name, productInfo.totals as totals, products.id FROM products INNER JOIN productInfo " + 
 						"ON products.id = productInfo.product_id" + productOrder + " LIMIT 20");
 				
						while (rsProducts.next()) {
							product_id = rsProducts.getInt("id");
							state = rsState.getString("state");
							rs2 = stmt3.executeQuery("SELECT SUM(orders.price) AS display_price" + 
									" FROM orders INNER JOIN users ON orders.user_id=users.id WHERE orders.product_id ='"
									+ product_id + "' AND users.state = '" + state + "' GROUP BY orders.product_id, users.state");
						
				 if (rs2.next()) { //loop through to get products sum %>
					<td><%=rs2.getFloat("display_price")%></td>
					<% } %>

					<% } 
					}%>
					

				</tr>
			</tbody>
		</table>




</body>
</html>