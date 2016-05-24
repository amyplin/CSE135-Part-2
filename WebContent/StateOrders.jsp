<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.sql.*, javax.naming.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet"
	href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"
	integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7"
	crossorigin="anonymous">
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
	String salesCategory = "";
	String salesCategoryMenu = "";

	try {
		Class.forName("org.postgresql.Driver");
	    String url = "jdbc:postgresql://localhost:5432/postgres";
	    String admin = "postgres";
	    String password = "password";
  	conn = DriverManager.getConnection(url, admin, password);
	}
	catch (Exception e) {}
	
	String productButton = request.getParameter("ProductButton");
	String stateButton = request.getParameter("StateButton");
	String action = request.getParameter("Rows");
	String selectedOrder = request.getParameter("Order");
	String selectedCategory = request.getParameter("Sales");
	String selectedButton = request.getParameter("Button");
	String salesDisplay = "";
	
	if (selectedOrder == null)
		session.setAttribute("order", "Alphabetical");
	if (selectedCategory == null || selectedCategory.equals("All")) {
		session.setAttribute("sales", "All");
	} else {
		Statement stmt5 = conn.createStatement();
		ResultSet getName = stmt5.executeQuery("select name from categories where id = " + selectedCategory);
		if (getName.next()) {
			session.setAttribute("sales", getName.getString("name"));
		}
	}
	
	if (productButton == null) {
		session.setAttribute("offsetProduct", 0);
	}
	if ("Products".equals(productButton)) {
		int num = (Integer) session.getAttribute("offsetProduct") + 10;
		session.setAttribute("offsetProduct", num);
		System.out.println("offset product = " + session.getAttribute("offsetProduct"));
	}
	
	if (stateButton == null) {
		session.setAttribute("offsetState", 0);
	}
	if ("States".equals(stateButton)) {
		int num = (Integer) session.getAttribute("offsetState") + 20;
		session.setAttribute("offsetState", num);
		System.out.println("offset state = " + session.getAttribute("offsetState"));
	}
	
	if ("Customers".equals(action)) {
		System.out.println("redirecting");
			response.sendRedirect("orders.jsp");
	}
	if ("Alphabetical".equals(selectedOrder)) {
		productOrder = orderName;
		stateOrder = orderState;
		if (!"All".equals(selectedCategory)) {
			salesCategory = "inner join products on orders.product_id = products.id where products.category_id = " + selectedCategory;
			salesCategoryMenu = "where id = " + selectedCategory;
			salesDisplay = "and products.category_id = " + selectedCategory;
		}
		session.setAttribute("order", "Alphabetical");
	}  
	if ("Top-K".equals(selectedOrder)) {
		productOrder = orderTopK;
		stateOrder = orderTopK;
		if (!"All".equals(selectedCategory)) {
			salesCategory = "inner join products on orders.product_id = products.id where products.category_id = " + selectedCategory;
			salesCategoryMenu = "where id = " + selectedCategory;
		} else {
			salesCategoryMenu = "";
		}
		session.setAttribute("order", "TopK");
	}

	Statement stmt = conn.createStatement();
	Statement stmt2 = conn.createStatement();
	Statement stmt3 = conn.createStatement();
	Statement stmt4 = conn.createStatement();
	Statement stmt6 = conn.createStatement();
	Statement stmt7 = conn.createStatement();
	
	ResultSet rsSum = null;
	ResultSet rsProducts = null; 
	ResultSet rsCategories = stmt6.executeQuery("SELECT name, id FROM categories");
	int product_id;
	ResultSet rsCatSize = stmt7.executeQuery("select count(*) as size from (select state from users group by state) a");
	if (rsCatSize.next()) {
		session.setAttribute("stateNum", rsCatSize.getInt("size"));
	}
	ResultSet rsProductSize = stmt4.executeQuery("select count(*) as size from (select name from products group by name) a");
	if (rsProductSize.next()) {
		session.setAttribute("productNum", rsProductSize.getInt("size"));
	}
	System.out.println("product size = " + session.getAttribute("productNum"));
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
		<div>
			<h1>Sales Analytics</h1>
		</div>

		<div class="form-group">
			<form action="StateOrders.jsp" method="POST">
				<label for="Rows">Rows:</label> <select name="Rows" id="rows"
					class="form-control">
					<option value="States">States</option>
					<option value="Customers">Customers</option>
				</select> <label for="Order">Order:</label> <select name="Order" id="order"
					class="form-control">
					<% if (session.getAttribute("order").equals("Alphabetical")) { %>
					<option value="Alphabetical">Alphabetical</option>
					<option value="Top-K">Top-K</option>
					<% } else { %>
					<option value="Top-K">Top-K</option>
					<option value="Alphabetical">Alphabetical</option>
					<% } %>
				</select> <label for="Sales">Sales-Filtering:</label> <select name="Sales"
					id="sales" class="form-control">
					<option value=<%=session.getAttribute("sales")%>><%=session.getAttribute("sales")%></option>
					<option value="All">All</option>
					<% while (rsCategories.next()) { 
  		String category = rsCategories.getString("name"); 
  		String category_id = rsCategories.getString("id");%>
					<option value=<%=category_id%> <%if(category.equals(session.getAttribute("sales"))){ %>selected="selected"<%} %>><%=category%></option>
					<% } %>
				</select>
				<td><input class="btn btn-primary" type="submit" name="submit"
					value="Run Query" /></td>
			</form>
		</div>


		<table class="table table-striped">
			<th></th>
			<%  

	rsProducts = stmt2.executeQuery("WITH productInfo(totals, product_id) AS (select sum(orders.price) as totals, product_id " +
				"FROM orders " + salesCategory + " group by product_id) SELECT products.name as name, CASE WHEN productInfo.totals IS NULL THEN 0 ELSE productInfo.totals end as totals, "
			+ "products.id FROM products LEFT OUTER JOIN productInfo " + 
				"ON products.id = productInfo.product_id" + productOrder + " LIMIT 10 OFFSET " + session.getAttribute("offsetProduct"));


	while (rsProducts.next()) {  //dispaly products %>
			<th><%=rsProducts.getString("name")%> (<%=rsProducts.getFloat("totals") %>)</th>
			<% 
	} 
	ResultSet rsState = stmt.executeQuery("WITH stateInfo(totals, state) AS (select sum(orders.price) as totals, users.state as state " +
				" from orders inner join users on orders.user_id = users.id " + salesCategory + " group by users.state order by totals desc)" + 
			" SELECT DISTINCT LEFT(users.state,10) as state, stateInfo.totals FROM users INNER JOIN stateInfo ON users.state = " + 
				"stateInfo.state" + stateOrder + " LIMIT 20 OFFSET " + session.getAttribute("offsetState"));
	int user_id;
	String state;
	ResultSet rs2 = null;
	ResultSet rs4 = null;
	%>
			<tbody>
				<% while (rsState.next()) { //loop through states %>
				<tr>
					<th><%=rsState.getString("state")%> (<%=rsState.getFloat("totals")%>)</th>
<%
								
					 		rsProducts = stmt2.executeQuery("WITH productInfo(totals, product_id) AS (select sum(orders.price) as totals, product_id " +
							"FROM orders " + salesCategory + " group by product_id) SELECT products.name as name, CASE WHEN productInfo.totals IS NULL THEN 0 ELSE productInfo.totals end as totals, "
							+ "products.id FROM products LEFT OUTER JOIN productInfo " + 
								"ON products.id = productInfo.product_id" + productOrder + " LIMIT 10 OFFSET " + session.getAttribute("offsetProduct"));
 				
						while (rsProducts.next()) {
							product_id = rsProducts.getInt("id");
							state = rsState.getString("state");		
							
							
							
							rs2 = stmt3.executeQuery("SELECT SUM(orders.price) AS display_price" + 
									" FROM orders INNER JOIN users ON orders.user_id=users.id inner join products on orders.product_id " + 
							" = products.id "+ salesCategory + " WHERE orders.product_id ='"
									+ product_id + "' AND users.state = '" + state + salesDisplay + "' GROUP BY orders.product_id, users.state");
						
				 if (rs2.next()) { //loop through to get products sum %>
					<td><%=rs2.getFloat("display_price")%></td>
					<%
						}
					%>

					<%
						}
						}
					%>


				</tr>
			</tbody>
		</table>

		<div class="form-group">
			<form action="StateOrders.jsp" method="POST">
			<% if ((Integer)session.getAttribute("offsetState") + 20 <= (Integer)session.getAttribute("stateNum")) { %>
				<td><input class="btn btn-primary" type="submit" name="submit"
					value="Next 20 States" /></td> 
				<input type="hidden" name="StateButton" value="States" />
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







