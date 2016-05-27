<?php
	require('cookiecheck.php');
	include('header.php');

?>

<html>


<head>
    <?php includes(); ?>
</head>


<body>
	<div id="container">
	<?php cabecero(); ?>
	<center>
	<br>
	<br>
	<br>
	<h3>Reset your password</h3>
	<br>
	<br>
	<br>
        <form accept-charset="UTF-8" action="reset_password_action.php" method="post" style="width: 30%;">
        <input style="margin-bottom:10px;" autofocus="autofocus" class="form-control" id="old_password" name="old_password" placeholder="Current Password" required="required" type="password" />
        <br>
        <input class="form-control" id="new_password" name="new_password" placeholder="New Password" required="required" type="password" />
        <br>
        <input class="form-control" id="repeat_new_password" name="repeat_new_password" placeholder="Repeat New Password" required="required" type="password" />
        <br>
        <?php 
        	if($_GET['success'] == strval('noequal'))
            echo '<p style="color:red">You must verify your new password in both fields</p>';
            if($_GET['success'] == strval('no'))
            echo '<p style="color:red">There was a problem reseting your password. Try later.</p>';
        ?>
        <input class="btn btn-success" style="margin-bottom:10px;" id="submit" name="commit" type="submit" value="Reset" />
        <br>
                                
        </form>
		</center>
    <?php footer(); ?>
</body>
</html>