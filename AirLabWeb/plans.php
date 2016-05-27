<?php
	require('cookiecheck.php');
	include('header.php');

?>

<html>
<head>
	<?php includes(); ?>
	<script src="web/plans.js"></script>
	<script src="/web/ace/ace.js" type="text/javascript" charset="utf-8"></script>	
	<script src="//cdn.tinymce.com/4/tinymce.min.js"></script>	
</head>
<body ng-App = "Plans">
	<div class="check " id="check"/></div>
	<?php cabecero(); ?>	
	<div class="main_container">
		<div ng-view style="top:200px;">
		</div>
	</div>
	<?php footer(); ?>
</body>
</html>