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
	String order = " ORDER BY name ";
	String korder = " ORDER BY totals DESC ";
	String salesCategory = "";

	try {
		Class.forName("org.postgresql.Driver");
	    String url = "jdbc:postgresql://localhost:5432/postgres";
	    String admin = "postgres";
	    String password = "password";
  	conn = DriverManager.getConnection(url, admin, password);
	}
	catch (Exception e) {}
	
	if ("POST".equalsIgnoreCase(request.getMethod())) {
		String action = request.getParameter("Rows");
		if ("States".equals(action)) {
			response.sendRedirect("StateOrders.jsp");
		}	
	} 

	String ordering = request.getParameter("Order");
	String selectedCategory = request.getParameter("Sales");
	String ordering_filter = order;
	
	//initialize for drop down menu
	if (ordering == null)
		session.setAttribute("order", "Alphabetical");
	if (selectedCategory == null || selectedCategory.equals("All")) {
		System.out.println("in here");
		session.setAttribute("sales", "All");
	} else {
		Statement stmt5 = conn.createStatement();
		ResultSet getName = stmt5.executeQuery("select name from categories where id = " + selectedCategory);
		if (getName.next()) {
			session.setAttribute("sales", getName.getString("name"));
		}
	}

	if ("Alphabetical".equals(ordering)) {
		System.out.println("alphabetical");
		ordering_filter = order;
		session.setAttribute("order", "Alphabetical");
	}  
	if ("Top-K".equals(ordering)) {
		System.out.println("selected category = " + selectedCategory);
		ordering_filter = korder;
		if (!"All".equals(selectedCategory)) {
			salesCategory = "inner join products on orders.product_id = products.id where products.category_id = " + selectedCategory;
		}
		session.setAttribute("order", "TopK");
	}
	
	String productButton = request.getParameter("ProductButton");
	String customerButton = request.getParameter("CustomerButton");
	
	if (productButton == null) {
		session.setAttribute("offsetProduct", 0);
	}
	if ("Products".equals(productButton)) {
		int num = (Integer) session.getAttribute("offsetProduct") + 10;
		session.setAttribute("offsetProduct", num);
		System.out.println("offset product = " + session.getAttribute("offsetProduct"));
	}
	
	if (customerButton == null) {
		session.setAttribute("offsetCustomer", 0);
	}
	if ("Customers".equals(customerButton)) {
		int num = (Integer) session.getAttribute("offsetCustomer") + 20;
		session.setAttribute("offsetCustomer", num);
		System.out.println("offset customer = " + session.getAttribute("offsetCustomer"));
	}
	
	Statement stmt = conn.createStatement();
	Statement stmt2 = conn.createStatement();
	Statement stmt3 = conn.createStatement();
	Statement stmt4 = conn.createStatement();
	Statement stmt5 = conn.createStatement();
	Statement stmt6 = conn.createStatement();
	Statement stmt7 = conn.createStatement();
	ResultSet rsCategories = stmt6.executeQuery("SELECT DISTINCT ON(name) name, id FROM categories");
	ResultSet rsSum = null;
	ResultSet rsProducts = stmt2.executeQuery("SELECT * FROM products" + order + "LIMIT 20");
	int product_id;
	
	ResultSet rsCustSize = stmt7.executeQuery("select count(*) as size from (select name from users group by name) a");
	if (rsCustSize.next()) {
		session.setAttribute("customerNum", rsCustSize.getInt("size"));
	}
	ResultSet rsProductSize = stmt4.executeQuery("select count(*) as size from (select name from products group by name) a");
	if (rsProductSize.next()) {
		session.setAttribute("productNum", rsProductSize.getInt("size"));
	}
	System.out.println("customer size = " + session.getAttribute("customerNum"));

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
  	<select name="Rows" id="rows" class="form-control">
  		<option value="Customers">Customers</option>
	    <option value="States">States</option>  	
	</select>	
  	<label for="Order">Order:</label>
  	<select name="Order" id="order" class="form-control">
	    <option value="Alphabetical">Alphabetical</option>
	    <option value="Top-K" <%if("TopK".equals(session.getAttribute("order"))) {%> selected="selected"<% } %>>Top-K</option>
	</select>
	<label for="Sales">Sales-Filtering:</label>
  	<select name="Sales" id="sales" class="form-control">
  	<% System.out.println("sales = " + session.getAttribute("sales"));
  	System.out.println("order = " + session.getAttribute("order"));
  	%>
  	<option value="All">All</option>
  	<% while (rsCategories.next()) { 
  		String category = rsCategories.getString("name"); 
  		String category_id = rsCategories.getString("id");
  		%>
  		<option value=<%=category_id%> <%if(category.equals(session.getAttribute("sales"))){ %>selected="selected"<%} %>><%=category%></option>
  	<% } %>
	</select>
	<td><input class="btn btn-primary" type="submit" name="submit" value="Run Query"/></td>
	</form>
  </div>


<table class="table table-striped">
	<th></th>
	
	<%  
	
	rsProducts = stmt2.executeQuery("WITH productInfo(totals, product_id) AS (select sum(orders.price) as totals, product_id " +
				" FROM orders " + salesCategory + " group by product_id) SELECT products.name as name, CASE WHEN productInfo.totals " + 
				"IS NULL THEN 0 ELSE productInfo.totals end as totals, products.id FROM products INNER JOIN productInfo" + 
				" ON products.id = productInfo.product_id" + ordering_filter + " LIMIT 10");


	while (rsProducts.next()) {  //dispaly products %>
		<th><%=rsProducts.getString("name")%> (<%=rsProducts.getFloat("totals") %>)</th>	
<% 
	} 

	
ResultSet rs = stmt.executeQuery("WITH customerInfo(totals, name, id) AS (select sum(orders.price) as totals, users.name as name, users.id as id " +
			"from orders inner join users on orders.user_id = users.id " + salesCategory + " group by users.id) select distinct left(users.name,10) as name," + 
			"customerInfo.totals, users.id as id from users inner join customerInfo on users.name = customerInfo.name " + ordering_filter + "LIMIT 20");
	
	int user_id;
	ResultSet rs2 = null;
	ResultSet rs4 = null;
	%>
			<tbody>
				<% while (rs.next()) { //loop through customers
				%>
					<tr>
					<th><%=rs.getString("name")%> ( <%=rs.getFloat("totals")%>)</th>
				<% 		
				rsProducts = stmt2.executeQuery("WITH productInfo(totals, product_id) AS (select sum(orders.price) as totals, product_id " +
						"FROM orders " + salesCategory + " group by product_id) SELECT products.name as name, productInfo.totals as totals, products.id FROM products INNER JOIN productInfo " + 
						"ON products.id = productInfo.product_id" + ordering_filter + " LIMIT 10");
				
						while (rsProducts.next()) {
							product_id = rsProducts.getInt("id");
							rs2 = stmt3.executeQuery("SELECT SUM(orders.price) AS display_price" + 
									" FROM orders where orders.product_id ='"
									+ product_id + "' AND orders.user_id = '" + rs.getString("id") + "' GROUP BY orders.product_id, orders.user_id");
						
				 if (rs2.next()) { //loop through to get products sum %>
						<td><%=rs2.getFloat("display_price")%></td>
					<% } else { %>
						<td>0</td>
					<% } %>

				<% }
				}%>
								
				</tr>
			</tbody>
		</table>
		
		<div class="form-group">
			<form action="orders.jsp" method="POST">
			<% if ((Integer)session.getAttribute("offsetCustomer") + 20 <= (Integer)session.getAttribute("customerNum")) { %>
				<td><input class="btn btn-primary" type="submit" name="submit"
					value="Next 20 Customers" /></td> 
				<input type="hidden" name="CustomerButton" value="Customers" />
			<% } %>
			<% if ((Integer)session.getAttribute("offsetProduct") + 10 <= (Integer)session.getAttribute("productNum")) { %>
				<td><input class="btn btn-primary" type="submit" name="submit"
					value="Next 10 Products" /></td>
				<input type="hidden" name="ProductButton" value="Products" />
			<% } %>
			</form>			
		</div>



</body>
</html>