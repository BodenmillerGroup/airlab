<?php
	if(isset($_COOKIE['TOKEN_PUBLIC_KEY']))header('Location: dashboard.php');
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
	        Create your AirLab account now!<br><br><br>
	        <form accept-charset="UTF-8" action="sign_up_action.php" method="post">
	        <input style="margin-bottom:10px;" autofocus="autofocus" value="<?php echo $_GET['email'];?>" class="form-control" id="user_login" name="email" placeholder="Username or Email" required="required" type="text" />
	        <br>
	        <input style="margin-bottom:10px;" class="form-control" id="user_password" name="password" placeholder="Password" required="required" type="password" />
	        <br>
	        <input style="margin-bottom:10px;" class="form-control" id="user_re_password" name="re_password" placeholder="Retype Password" required="required" type="password" />
	        <br>
	        <?php 
	        	if($_GET['success'] == strval('emailExists'))
	            echo '<p style="color:red">The email you indicated already exists in the system</p>';
	            if($_GET['success'] == strval('differentPasswords'))
	            echo '<p style="color:red">You must type the same password twice</p>';
	            if($_GET['success'] == strval('passwordShort'))
	            echo '<p style="color:red">The password must contain at least 7 characters</p>';
	            if($_GET['success'] == strval('no'))
	            echo '<p style="color:red">There was an error. Please try again</p>';
	        ?>
	        <input style="margin-bottom:10px;" id="submit" name="commit" type="submit" value="Create account" />
	        <br>
	                                
	        </form>
			</center>
	    </div>
	    <?php footer(); ?>
	</body>
</html>




