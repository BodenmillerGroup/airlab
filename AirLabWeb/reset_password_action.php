<?php	
	
	require("db.php");

	$old = $_POST['old_password'];
	$new = $_POST['new_password'];
	$repeat = $_POST['repeat_new_password'];
	
	if($new != $repeat){header('Location: reset_password.php?success=noequal');return;}

	$oldhash = hash("sha1", $old);		
	$newhash = hash("sha1", $new);
	
	$sql = "UPDATE tblPerson SET perPassword = '".$newhash."' WHERE perPassword ='".$oldhash."' AND perPersonId =".$_COOKIE['USER_ID'];// and zetActive = 1?
		
	if($array = boolDB($sql)){
		header('Location: dashboard.php?message=passwordchanged');return;
	}else{
		header('Location: reset_password.php?success=no');return;
	}	
?>