<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.sql.*, javax.naming.*,java.util.*"%>
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
	    String url = "jdbc:postgresql://localhost:5432/CSE135_small";
	    String admin = "postgres";
	    String password = "password";
  	conn = DriverManager.getConnection(url, admin, password);
	}
	catch (Exception e) {}
	
	Statement stmt = conn.createStatement();
	ResultSet s_p = stmt.executeQuery("SELECT p1.id AS product1, p2.id AS product2, " + 
											"(COALESCE((SELECT SUM(o1.price * o2.price) " +
											"FROM orders o1, orders o2 " +
											"WHERE o1.product_id = p1.id AND o2.product_id = p2.id AND o1.user_id = o2.user_id),0)) " +
											"/" +
											"(SQRT ((SELECT SUM(POWER(price,2)) FROM orders WHERE product_id = p1.id)) * " +
											"SQRT ((SELECT SUM(POWER(price,2)) FROM orders WHERE product_id = p2.id))) AS cos " +
										"FROM  products p1, products p2 " +
										"WHERE p1.id < p2.id " +
										"AND p1.id IN (Select product_id FROM orders) " +
										"AND p2.id IN (Select product_id FROM orders) " +
										"GROUP BY product1,product2 " +
										"ORDER BY cos DESC " +
										"LIMIT 100");
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

<div><h1>Similar Products</h1></div>

<table class="table table-striped">
<tr>
	<th>Product1</th>
	<th>Product2</th>
	<th>Cosine Similarity</th>
</tr>
<tbody>
	<% 			
	while (s_p.next()) {
	%>
	<tr>
	<td><%=s_p.getString("product1")%></td>
	<td><%=s_p.getString("product2")%></td>
	<td><%=s_p.getFloat("cos")%></td>
	</tr>
	<% 
	}
	%>	
</tbody>
</table>

</body>
</html>