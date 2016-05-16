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
		if (action.equals("Customers")) {
			Statement stmt = conn.createStatement();
			String sql = "SELECT users.name FROM users INNER JOIN orders ON user.id = orders.user_id";
			try {
				ResultSet rs = stmt.executeQuery(sql);
			}
			catch(Exception e) {out.println("<script>alert('error!');</script>");} 
		} else {
			System.out.println("GOOOOODBYE");
		}
/* 		else if (action.equals("update")) {
			int id = Integer.parseInt(request.getParameter("id"));
			String name = request.getParameter("name");
			String description = request.getParameter("description");
			Statement stmt = conn.createStatement();
			String sql = "UPDATE categories SET name = '" + name +
					"', description = '" + description + "' where id = " + id;
			int result = stmt.executeUpdate(sql);
			if (result == 1) out.println("<script>alert('update category sucess!');</script>");
		    else out.println("<script>alert('update category fail!');</script>");
		}
		else if (action.equals("insert")) {
			String name = request.getParameter("name");
			String description = request.getParameter("description");
			Statement stmt = conn.createStatement();
			String sql = "INSERT into categories(name, description) values('" + name +
					"', '" + description + "')";
			int result = stmt.executeUpdate(sql);
			if (result == 1) out.println("<script>alert('insert into category sucess!');</script>");
		    else out.println("<script>alert('insert into category fail!');</script>");
		} */
	
	} 
	Statement stmt = conn.createStatement();
	String sql = "select distinct users.name from users inner join orders on users.id = orders.user_id";
	ResultSet rs = stmt.executeQuery(sql);
	Statement stmt2 = conn.createStatement();
	String sqlProducts = "SELECT * from products";
	ResultSet rsProducts = stmt2.executeQuery(sqlProducts);
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
<%   while (rsProducts.next()) {  %>
	<th><%=rsProducts.getString("name")%></th>
<% } %>
	
	 <tbody>
 <% while (rs.next()) { 
/*  	String customerID = rs.getString("user_id");
 	String sql2 = "SELECT Products.name FROM Products INNER JOIN Orders ON Orders.Product_ID = Products.ID WHERE Orders.User_ID = " + customerID;
 	ResultSet rs2 = stmt.executeQuery(sql2); */
 %>
	<tr>
	<form action="categories.jsp" method="POST">
		<td><input value="<%=rs.getString("name")%>" name="customer_name"/></td>
	</form>
	</tr>
	
<% } %> 
</tbody>
</table>




</body>
</html>