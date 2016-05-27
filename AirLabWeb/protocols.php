<?php
	require('cookiecheck.php');
	include('header.php');

?>

<html>
<head>
	<?php includes(); ?>
	<script src="web/protocols.js"></script>
</head>
<body ng-App = "Protocols">
	<div class="check " id="check"/></div>
	<?php cabecero(); ?>	
	<div class="main_container">
	<div ng-view></div>
	</div>
	<?php footer(); ?>
</body>
</html>