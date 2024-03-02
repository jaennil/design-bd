<!DOCTYPE HTML>
<html>
<head>
    <title>MyApp</title>
</head>
<body>
<h1>Register</h1>
<a href="/login.php">Login</a>
<form method="POST">
	<div>
		<label for="username">username</label>
		<input name="username" id="username"/>
	</div>
	<div>
		<label for="password">password</label>
		<input name="password" id="password"/>
	</div>
	<button>Submit</button>
</form>

<?php

include 'database.php';

if($_POST["username"] && $_POST["password"]) {
	$username = $_POST["username"];
	$password = $_POST["password"];

	$database->execute_query("INSERT INTO USERS_TABLE SET USERNAME=?, PASSWORD=?", [$username, $password]);
	header("Location: login.php");
}

?>

</body>
</html>

