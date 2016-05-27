<?php
	//require('cookiecheck.php');
	include('header.php');

?>

<html>
<head>
	<?php includes(); ?>
	<script src="web/home.js"></script>
</head>
<body ng-App = "Home" class="home_body">
	<div class="check " id="check"/></div>
	<?php cabeceroHome(); ?>	
	<div class="main_container">
		<div ng-view style="top:200px;">
		</div>
	</div>
	<?php footer(); ?>
</body>
</html>