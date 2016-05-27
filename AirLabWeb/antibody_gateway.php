<?php
	require('cookiecheck.php');
	include('header.php');
?>

<html>
	<head>
		<?php includes() ?>
		<script src="web/isotope_masses.js"></script>		
		<script src="web/panel_generator.js"></script>
		<script src="http://d3js.org/d3.v3.min.js"></script>	
		<script src="web/plot.js"></script>
	</head>
	<body ng-App="AbGateway"><!--AbGateway for old-->
		<div class="check " id="check"/></div>
		<?php cabecero(); ?>	
		<div class="main_container">
			<div ng-view>
		</div>	
		<?php footer(); ?>
	</body>
</html>