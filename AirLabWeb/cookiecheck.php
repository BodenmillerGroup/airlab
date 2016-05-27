<?php
	
	if(!isset($_COOKIE['TOKEN_PUBLIC_KEY']) && !isset($_COOKIE['USER_USER_GROUP_ID']))header('Location: home.php');
	if(!isset($_COOKIE['TOKEN_PUBLIC_KEY']))header('Location: login.php');
	
	if(!isset($_COOKIE['USER_USER_GROUP_ID'])){
		$array = json_decode($_COOKIE['USER_DATA'], true);
		
		if(sizeof($array) > 1 && $_SERVER[REQUEST_URI] != '/dashboard.php'){
				header('Location: dashboard.php');	
		}else{
			if($_SERVER[REQUEST_URI] != '/create_lab.php' && $_SERVER[REQUEST_URI] != '/dashboard.php' && $_SERVER[REQUEST_URI] != '/account.php' && $_SERVER[REQUEST_URI] != '/request_lab.php'){
				header('Location: dashboard.php');
			}		
		}
		//if(!isset($_COOKIE['USER_USER_GROUP_ID']) && $_SERVER[REQUEST_URI] != '/dashboard.php'){
		
			//if(sizeof($array) > 1)
		//	header('Location: dashboard.php');
			//else setcookie('TOKEN_PUBLIC_KEY', '');
		//}
		//header('Location: dashboard.php');
		//else setcookie('TOKEN_PUBLIC_KEY', '');//Have to give the chance to create group
	}
?>