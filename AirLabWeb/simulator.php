<html>
<head></head>
<body>

<div class="container">
	    	<center>
	    	<h1>AirLab - Login to iOS Web simulator</h1>
	        <img display="block" alt="airlablogo" src="pictures/airlablogo.png" width="200" />
	        <form accept-charset="UTF-8" action="login_simulator.php" method="post">
	        <input style="margin-bottom:10px;" autofocus="autofocus" class="form-control" id="user_login" name="email" placeholder="Username or Email" required="required" type="text" />
	        <br>
	        <input style="margin-bottom:10px;" class="form-control" id="user_password" name="password" placeholder="Password" required="required" type="password" />
	        <br>
	        <?php 
	        	if($_GET['success'] == strval('no'))
	            echo '<p style="color:red">Wrong email or password</p>';
	        ?>
	        <input style="margin-bottom:10px;" id="submit" name="commit" type="submit" value="Login" />
	        <br>
			<a href="new_password.php">Forgot password?</a>
	        <p>
	        Don't have an account yet?
	        <a href="sign_up.php">Sign up now</a>
	        </p>
	                                
	        </form>
			</center>
	    </div>

<!--
<center><h1>AirLab Web iOS Simulator</h1><br><br>
<iframe src="https://appetize.io/embed/zqnkb2v1ecxg9rntfzhubwd5ag?device=ipadair&scale=80&autoplay=false&orientation=landscape&deviceColor=white&screenOnly=true" width="900px" height="646px" frameborder="0" scrolling="no"></iframe>
<iframe src="https://appetize.io/embed/zqnkb2v1ecxg9rntfzhubwd5ag?device=iphone6&scale=100&autoplay=false&orientation=portrait&deviceColor=white&screenOnly=true" width="375px" height="668px" frameborder="0" scrolling="no"></iframe>
</center>
-->
</body>
</html>