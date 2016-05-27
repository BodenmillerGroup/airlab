<?php
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
				<img display="block" alt="airlablogo" src="pictures/airlablogo.png" width="200" />
				<br>
				Set up your new password<br>
				<form accept-charset="UTF-8" action="password_restore_action.php" method="post">
					<input type="hidden" name="perPersonId" value="<?php echo $_GET['id'];?>" />
					<input type="hidden" name="zetActivationKey" value="<?php echo $_GET['restore_key'];?>" />
					<input style="margin-bottom:10px;" autofocus="autofocus" class="form-control" id="new_pass" name="password" placeholder="New Password" required="required" type="password" />
					<br>
					<input style="margin-bottom:10px;" autofocus="autofocus" class="form-control" id="new_pass_re" name="re_password" placeholder="Repeat Password" required="required" type="password" />
					<br>
	
					<input style="margin-bottom:10px;" id="submit" name="commit" type="submit" value="Submit" />
					<br>
	                 <?php 
			        	if($_GET['success'] == strval('noequal'))
			            echo '<p style="color:red">You must verify your new password in both fields</p>';
			            if($_GET['success'] == strval('no'))
			            echo '<p style="color:red">There was a problem reseting your password. Try later.</p>';
					?>             
				</form>
			</center>
	    </div>
	    <?php footer(); ?>
	</body>
</html>




