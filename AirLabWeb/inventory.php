<?php
	require('cookiecheck.php');
	include('header.php');

?>

<html>
<head>
	<?php includes(); ?>
	<script src="web/inventory.js"></script>
</head>
<body ng-App="Inventory">
	<div class="check " id="check"/></div>
	<?php cabecero(); ?>	
	<div class="main_container">
	<div ng-view></div>
	</div>
	</div>
	<?php footer(); ?>
</body>
</html>