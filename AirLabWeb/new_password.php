<?php
	//if(isset($_COOKIE['TOKEN_PUBLIC_KEY']))header('Location: dashboard.php');
?>

<?php
	//require('cookiecheck.php');
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
        <img display="block" alt="airlablogo" src="pictures/airlablogo.png" width="200" />
        <br>
        Recover password
        <form accept-charset="UTF-8" action="new_password_action.php" method="post">
        <input style="margin-bottom:10px;" autofocus="autofocus" class="form-control" id="user_email" name="email" placeholder="Email" required="required" type="text" />
        <br>
        <input style="margin-bottom:10px;" id="submit" name="commit" type="submit" value="Send recovery email" />
        <br>
                                
        </form>
		</center>
    </div>
    <?php footer(); ?>
</body>
</html>




