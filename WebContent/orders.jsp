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
		if (action.equals("States")) {
			response.sendRedirect("StateOrders.jsp");
		}
	
	} 
	Statement stmt = conn.createStatement();
	Statement stmt2 = conn.createStatement();
	Statement stmt3 = conn.createStatement();
	Statement stmt4 = conn.createStatement();
	Statement stmt5 = conn.createStatement();
	ResultSet rsSum = null;
	ResultSet rsProducts = stmt2.executeQuery("SELECT * FROM products LIMIT 20");
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
  	<select name="rows" id="rows" class="form-control">
	    <option value="Customers">Customers</option>
	    <option value="States">States</option>
	</select>	
	<td><input class="btn btn-primary" type="submit" name="submit" value="submit"/></td>
	</form>
  </div>


<table class="table table-striped">
	<th></th>
<%   while (rsProducts.next()) {  //dispaly products 
		product_id = rsProducts.getInt("id");
 		rsSum = stmt5.executeQuery("SELECT SUM(orders.price) as totals FROM orders WHERE product_id = " + product_id);
 		if (rsSum.next()) {%>
		<th><%=rsProducts.getString("name")%> (<%=rsSum.getFloat("totals") %>)</th>
		<% } else { %>
		<th><%=rsProducts.getString("name")%> (0)</th>
		<% } %>		
<% 
	} 
	rsProducts = stmt2.executeQuery("SELECT LEFT(products.name,10) as name, products.id from products LIMIT 20");
	ResultSet rs = stmt.executeQuery("select distinct LEFT(users.name,10) as name, users.id as user_id from users inner join orders on users.id = orders.user_id");
	int user_id;
	ResultSet rs2 = null;
	ResultSet rs4 = null;
	%>
			<tbody>
				<% while (rs.next()) { //loop through customers
					user_id = rs.getInt("user_id");
					rs4 = stmt4.executeQuery("SELECT SUM(orders.price) as totals FROM orders WHERE user_id = " + user_id);
					if (rs4.next()) {%>
					<tr>
					<th><%=rs.getString("name")%> ( <%=rs4.getFloat("totals")%>)</th>
					<% } else { %>
					<tr>
					<th><%=rs.getString("name")%> (0)</th>
					<% } %>
				<% 	rsProducts = stmt2.executeQuery("SELECT LEFT(products.name,10) as name, products.id from products LIMIT 20");	
						while (rsProducts.next()) {
							product_id = rsProducts.getInt("id");
							rs2 = stmt3.executeQuery("SELECT SUM(orders.price) AS display_price" + 
									" FROM orders where orders.product_id ='"
									+ product_id + "' AND orders.user_id = '" + user_id + "' GROUP BY orders.product_id, orders.user_id");
						
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




</body>
</html>