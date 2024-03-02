<?php
include 'database.php';

$device_id = $_GET["ID"];
if ($device_id == "") {
	die("device id not provided");
}

$result = $database->execute_query("SELECT BLOCKED FROM DEVICE_TABLE WHERE DEVICE_ID=?", [$device_id]);

if (!$result->num_rows) {
	die("no divice in database with id: " . $device_id);
}

if ($result->fetch_assoc()["BLOCKED"] == "1") {
	die("device blocked");
}

$rele_state = $_GET["Rele"];
if ($rele_state != "") {
	$result = $database->execute_query("SELECT OUT_STATE FROM OUT_STATE_TABLE WHERE DEVICE_ID=?", [$device_id]);

	if ($result->num_rows) {
		$database->execute_query("UPDATE OUT_STATE_TABLE SET OUT_STATE=?, DATE_TIME=NOW() WHERE DEVICE_ID=?", [$rele_state, $device_id]);
	} else {
		$database->execute_query("INSERT OUT_STATE_TABLE SET DEVICE_ID=?, OUT_STATE=?, DATE_TIME=NOW()", [$device_id, $rele_state]);
	}
}

$temperature = $_GET["Term"];
if ($temperature != "") {
	$result = $database->execute_query("SELECT TEMPERATURE FROM TEMPERATURE_TABLE WHERE DEVICE_ID=?", [$device_id]);
	if ($result->num_rows) {
		$database->execute_query("UPDATE TEMPERATURE_TABLE SET TEMPERATURE=?, DATE_TIME=NOW() WHERE DEVICE_ID=?", [$temperature, $device_id]);
	} else {
		$database->execute_query("INSERT TEMPERATURE_TABLE SET DEVICE_ID=?, TEMPERATURE=?, DATE_TIME=NOW()", [$device_id, $temperature]);
	}
}

$database->execute_query("INSERT DEVICE_HISTORY_TABLE SET DEVICE_ID=?, OUT_STATE=?, TEMPERATURE=?, DATE_TIME=NOW()",
	[$device_id, $rele_state == "" ? NULL : $rele_state, $temperature == "" ? NULL : $temperature]);

$result = $database->execute_query("SELECT COMMAND FROM COMMAND_TABLE WHERE DEVICE_ID=?", [$device_id]);
if ($result->num_rows) {
	$Arr = $result->fetch_array();
	$Command = $Arr["COMMAND"];
}

if ($Command != -1) {
	echo "COMMAND $Command EOC";
} else {
	echo "COMMAND ? EOC";
}
?>
