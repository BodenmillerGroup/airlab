<?php	
	require("db.php");

	$pass = $_POST['password'];
	$repass = $_POST['re_password'];
	if($pass != $repass){
		echo 'You must type the same password twice<br>';//<a href="javascript:history.back()">Go back</a>';
		die;
	}
	if(strlen($pass)< 7){
		echo 'The new password must be at least 7 characters long';
		die;
	}
	$id = $_POST['perPersonId'];
	$restoreKey = $_POST['zetActivationKey'];
		
	$sql = "UPDATE tblPerson SET perPassword = '".hash("sha1", $pass)."' WHERE zetActivationKey = '".$restoreKey."'";
	$bool = boolDB($sql);	

	if($bool == 1){
		
	}else{
		echo 'The action failed';
		die;
	}
?>

<?php
	require('cookiecheck.php');
	include('header.php');

?>

<html>
	<head>
    	<link rel="icon" sizes="16x16" href="pictures/favicon.png" />
    	<?php includes(); ?>
	</head>
	<body>
		<div class="container">
			<center>
    			<h1>AirLab</h1>
        		<img display="block" alt="airlablogo" src="pictures/airlablogo.png" width="200" /><br>
				Your password has been successfully restored<br><br>
				<a href="login.php">Back to home page</a>
			</center>
		</div>
	</body>
</html>