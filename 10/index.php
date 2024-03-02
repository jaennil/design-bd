<?php

session_start();

$user_id = $_SESSION["user_id"];

if ($user_id == "") {
	header("Location: login.php");
	die("not authorized");
}

?>

<!DOCTYPE HTML>
<html id="App_interface">
<head>
    <title>MyApp</title>
    <script src="./autoupdate.js"></script>
</head>
<body>
<a href="logout.php">Logout</a>

<?php

include 'database.php';

$result = $database->execute_query("SELECT BLOCKED FROM USERS_TABLE WHERE USER_ID=?", [$user_id]);
$blocked = $result->fetch_assoc()["BLOCKED"];

if ($blocked) {
	exit("you blocked");
}

include 'device_state.php';

foreach ($devices as $id => $device) {
	$msg = "";
	if ($device["blocked"]) {
		$msg = "Подозрительная активность";
	}
	echo '
		<table>
			<tr>
				<td> Устройство:
				</td>
				<td>' . $device["name"] . '<font color="red"> ' . $msg . '</font></td>
			</tr>
		</table>

		<table border=1>
			<tr>
				<td width=100px> Tемпература
				</td>
				<td width=40px>' . $device["temperature"] . '</td>
				<td width=150px>' . $device["temperature_datetime"] . '</td>
			</tr>
			<tr>
				<td width=100px> Реле
				</td>
				<td width=40px>' . $device["out_state"] . '</td>
				<td width=150px>' . $device["out_state_datetime"] . '</td>
			</tr>
		</table>

		<form method="POST" action="device_control.php">
			<button type="submit" name="button_on" value="1">Включить реле</button>
			<input type="hidden" name="device_id" value="' . $id . '"/>
		</form>

		<form method="POST" action="device_control.php">
			<button type="submit" name="button_off" value="1">Выключить реле</button>
			<input type="hidden" name="device_id" value="' . $id . '"/>
		</form>
	';
}

?>

<a href="/history.php">history</a>
</body>
</html>
