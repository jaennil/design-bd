<?php

session_start();

$user_id = $_SESSION["user_id"];

if ($user_id == "") {
	die("not authorized");
}

?>

<!DOCTYPE HTML>
<html>
<head>
    <title>MyApp</title>
</head>
<body>
<h1>History</h1>
<a href="/">Home</a><br>

<table>
	<tr>
		<td>Устройство</td>
		<td>Команда</td>
		<td>Время</td>
	</tr>
<?php

include 'database.php';

$result = $database->execute_query("SELECT DEVICE_ID, NAME, COMMAND, DATE_TIME FROM DEVICE_TABLE JOIN COMMAND_HISTORY_TABLE USING(DEVICE_ID) WHERE USER_ID=?", [$user_id]);
while ($row = $result->fetch_assoc()) {
	echo '
		<tr>
			<td>' . $row["NAME"] . '</td>
			<td>' . $row["COMMAND"] . '</td>
			<td>' . $row["DATE_TIME"] . '</td>
		</tr>
	';
}

?>

</table>

</body>
</html>

