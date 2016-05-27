<?php
	require('cookiecheck.php');
	include('header.php');

?>

<html>
<head>
	<?php includes() ?>
	
	<script src="//cdnjs.cloudflare.com/ajax/libs/interact.js/1.2.4/interact.min.js"></script>
    <script src="//ajax.googleapis.com/ajax/libs/angularjs/1.5.0/angular-animate.js"></script>
    <script src="//mattlewis92.github.io/angular-bootstrap-calendar/dist/js/angular-bootstrap-calendar-tpls.min.js"></script>
    <link href="//mattlewis92.github.io/angular-bootstrap-calendar/dist/css/angular-bootstrap-calendar.min.css" rel="stylesheet">  
	
	<script src="web/calendar.js"></script>
</head>

<body>
	<body ng-App = "Calendar">
	<div class="check " id="check"/></div>
	<?php cabecero(); ?>	
	<div class="main_container">
		<div ng-view style="top:200px;">
		</div>
	</div>
	<div ng-controller="ActiveCalendar as vm">
		<ng-include src="web/calendario.html">
	</div>
	<?php footer(); ?>
</body>
</html>