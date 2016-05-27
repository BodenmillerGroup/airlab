<?php
	$uri = $_SERVER['HTTP_HOST'];
	if(strpos($uri, 'localhost') !== false) {
	    require('dbLocal.php');
	}else{
		require('dbGAE.php');
	}
?>