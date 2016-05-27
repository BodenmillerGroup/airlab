<?php
	if(isset($_COOKIE['TOKEN_PUBLIC_KEY']))header('Location: dashboard.php');
?>
<?php
	//require('cookiecheck.php');
	include('header.php');
?>

<html>


<head>
    <link rel="icon" sizes="16x16" href="pictures/favicon.png" />
    <?php includes(); ?>
</head>
	<body>
	
	    <div class="main_container">
	    	<center>
	    	<h1>AirLab</h1>
	        <img display="block" alt="airlablogo" src="pictures/airlablogo.png" width="200" />
	        <form accept-charset="UTF-8" action="login_action.php" method="post">
	        	<input style="margin-bottom:10px; width:200px;" autofocus="autofocus" class="form-control" id="user_login" name="email" placeholder="Username or Email" required="required" type="text" />
				<input style="margin-bottom:10px; width:200px;" class="form-control" id="user_password" name="password" placeholder="Password" required="required" type="password" />
				<br>
		        <?php 
		        	if($_GET['success'] == strval('no'))
		            echo '<p style="color:red">Wrong email or password</p>';
		            if($_GET['success'] == strval('noactive'))
		            echo '<p style="color:red">Your account is pending activation. Please check your email.</p>';
		            if($_GET['success'] == strval('newgroup'))
		            echo '<p style="color:green">Your created a new group. Please log in again.</p>';
		        ?>
				<input class="btn btn-primary" style="margin-bottom:10px;" id="submit" name="commit" type="submit" value="Login" />
				<br>
				<br>
				<a href="new_password.php">Forgot password?</a>
				<p>
				Don't have an account yet?
				<a href="sign_up.php">Sign up now</a>
				</p>                    
	        </form>
			</center>
	    </div>
	    <?php footer(); ?>
	</body>
</html>




