<?php
	require('cookiecheck.php');
	include('header.php');

?>

<html>
<head>
	<?php includes(); ?>
	<script src="web/create_lab.js"></script>
</head>
<body ng-App="CreateLab">
	<div class="check " id="check"/>
	<?php cabecero(); ?>	
		<div class="main_container">
	    	<div ng-view>
	    </div>
	<?php footer(); ?>
</body>
</html>