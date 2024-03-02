<?php

session_start();

$user_id = $_SESSION["user_id"];

if($user_id == "") {
	die("not authorized");
}

include 'database.php';

$devices = array();

$query = "SELECT DEVICE_ID, NAME, BLOCKED FROM DEVICE_TABLE";
$result = $database->query($query);
while($row = $result->fetch_assoc()) {
	$devices[$row["DEVICE_ID"]] = array("name" => $row["NAME"],
										"blocked" => $row["BLOCKED"]);
}

$query = "SELECT DEVICE_ID, TEMPERATURE, DATE_TIME FROM TEMPERATURE_TABLE";
$result = $database->query($query);
while($row = $result->fetch_assoc()) {
	$devices[$row["DEVICE_ID"]]["temperature"] = $row["TEMPERATURE"];
	$devices[$row["DEVICE_ID"]]["temperature_datetime"] = $row["DATE_TIME"];
}

$query = "SELECT DEVICE_ID, OUT_STATE, DATE_TIME FROM OUT_STATE_TABLE";
$result = $database->query($query);
while($row = $result->fetch_assoc()) {
	$devices[$row["DEVICE_ID"]]["out_state"] = $row["OUT_STATE"];
	$devices[$row["DEVICE_ID"]]["out_state_datetime"] = $row["DATE_TIME"];
}

?>
