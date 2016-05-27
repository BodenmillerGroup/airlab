<?php
	require('cookiecheck.php');
	include('header.php');

?>

<html>
<head>
	<?php includes(); ?>
	<script src="web/papers.js"></script>
</head>
<body ng-App = "Papers">
	<div class="check " id="check"/></div>
	<?php cabecero(); ?>	
	<div class="main_container">
	<div ng-view></div>
	</div>
	<?php footer(); ?>
</body>
</html>