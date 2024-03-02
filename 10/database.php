<?php
$db_host = "localhost";
$db_user = "jaennil";
$db_password = "naen";
$db_name = "design_bd_10";
$database = new mysqli($db_host, $db_user, $db_password, $db_name);

if ($database->connect_error) {
	die("Connection to database failed: " . $database->connect_error);
}
?>
