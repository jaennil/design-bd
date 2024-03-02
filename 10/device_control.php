<?php

session_start();

$user_id = $_SESSION["user_id"];
if ($user_id == "") {
	header("Location: login.php");
	die("not authorized");
}

include 'database.php';

$device_id = $_POST["device_id"];

$enabled = 1;
$disabled = 0;

if ($_POST["button_on"]) {
	$database->execute_query("UPDATE COMMAND_TABLE SET COMMAND=?, DATE_TIME=NOW() WHERE DEVICE_ID=?", [$enabled, $device_id]);
    if ($database->affected_rows == 0) {
		$database->execute_query("INSERT COMMAND_TABLE SET DEVICE_ID=?, COMMAND=?, DATE_TIME=NOW()", [$device_id, $enabled]);
    }
	
	$database->execute_query("INSERT COMMAND_HISTORY_TABLE SET USER_ID=?, DEVICE_ID=?, COMMAND=?, DATE_TIME=NOW()", [$user_id, $device_id, $enabled]);
}

if ($_POST["button_off"]) {
	$database->execute_query("UPDATE COMMAND_TABLE SET COMMAND=?, DATE_TIME=NOW() WHERE DEVICE_ID=?", [$disabled, $device_id]);
    if ($database->affected_rows == 0) {
		$database->execute_query("INSERT COMMAND_TABLE SET DEVICE_ID=?, COMMAND=?, DATE_TIME=NOW()", [$device_id, $disabled]);
    }

	$database->execute_query("INSERT COMMAND_HISTORY_TABLE SET USER_ID=?, DEVICE_ID=?, COMMAND=?, DATE_TIME=NOW()", [$user_id, $device_id, $disabled]);
}

header("Location: index.php");
exit();
?>
