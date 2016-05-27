<?php	
	require("db.php");

	$email = $_POST['email'];
	$sql = "SELECT zetActivationKey, perPersonId FROM tblPerson WHERE perEmail='".$email."'"; 	
	$array = fetchDB($sql);	
	
	if(mysql_num_rows($array) == 1){
		while($row = mysql_fetch_array($array)){
			$link = 'http:/www.airlaboratory.ch/password_restore.php?id='.$row['perPersonId'].'&restore_key='.$row['zetActivationKey'];
			mail($email, 'AirLab - Restore password', $link);
		}
	}else if(mysql_num_rows($array) == 0){
		echo 'The email does not exist in the system';
		die;
	}else{
		echo 'There is an error, your email is duplicate in the system.<br> Please contact the system administrator';
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
		<title><h3 class="home_title">Airlab</h3></title>
	</head>
	<body>
		<div class="container">
			<center>
    			<h1>AirLab</h1>
        		<img display="block" alt="airlablogo" src="pictures/airlablogo.png" width="200" /><br>
				We sent you an email to your address (<?php echo $email ?>) with the information to restore your password<br><br>
				<a href="login.php">Back to home page</a>
			</center>
		</div>
	</body>
</html>