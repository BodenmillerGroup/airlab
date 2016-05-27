<?php

$array = explode('-', $_POST['ids']);
if(sizeof($array) == 2){
	setcookie('USER_GROUP_ID', $array[0], time() + (2880 * 30));
	setcookie('USER_USER_GROUP_ID', $array[1], time() + (2880 * 30));
	header("Location: dashboard.php");
}else{
	header("Location: logout.php");
}

?>