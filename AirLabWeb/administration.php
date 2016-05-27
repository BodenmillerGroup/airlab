<?php
	require('cookiecheck.php');
	include('header.php');
?>

<html>
<head>
	<?php includes() ?>
	<script src="web/administration.js"></script>	
</head>
<body ng-App="Admin">
	<div class="check " id="check"/></div>
	<?php cabecero(); ?>	
	<?php 
		$data = json_decode($_COOKIE['USER_DATA'], true);
		$stay = false;
		foreach($data as $item){
			if($item['grpGroupId'] == $_COOKIE['USER_GROUP_ID'])$stay = true;
			
		}
		if($stay == false)header('Location: dashboard.php');
	?>
	<div class="main_container">
	<div ng-view>
	</div>
	<?php footer(); ?>
</body>
</html>