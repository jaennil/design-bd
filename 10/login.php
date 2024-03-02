<!DOCTYPE HTML>
<html>
<head>
    <title>MyApp</title>
</head>
<body>
<h1>Login</h1>
<a href="/register.php">Register</a>
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

	$stmt = $database->execute_query("SELECT USER_ID FROM USERS_TABLE WHERE USERNAME=? AND PASSWORD=?", [$username, $password]);
	if($stmt->num_rows > 0) {
		session_start();
		$_SESSION["user_id"] = $stmt->fetch_assoc()["USER_ID"];
		header("Location: /");
	}
}

?>

</body>
</html>

