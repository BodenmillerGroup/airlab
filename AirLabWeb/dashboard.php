<?php
	require('cookiecheck.php');
	include('header.php');

?>
 
<html>
<head>
	<?php includes(); ?>
	<script src="web/dashboard.js"></script>
</head>
<body ng-App="Dashboard">
	<div class="check" id="check"></div>
	<?php cabecero(); ?>	
	<div class="main_container">
	<?php 
		echo '<h3>Hi '.$_COOKIE['USER_NAME'].' '.$_COOKIE['USER_LASTNAME'].'. Welcome to AirLab</h3>';
		$array = json_decode($_COOKIE['USER_DATA'], true);
		
		if(sizeof($array)>1){
			if(isset($_COOKIE['USER_USER_GROUP_ID'])){
				/*
foreach($array as $row){
					if($row['grpGroupId'] == $_COOKIE['USER_GROUP_ID']){
						echo '<div id="welcome_message">You are currently working on '.$row['grpName']."'s group".'</div>';
					}
				}
*/
				echo '<div id="welcome_message">You are currently working on '.$array[0]['grpName']."'s group".'</div><br>';
				echo '<div ng-view></div>';
			}else{
				echo '<center>Please choose your current working group:';
				echo '<br><br>';
				//echo '<table>';
				foreach($array as $row){
					//echo '<tr><td>';
					echo strval($row['grpName']);
					//echo '</td>';
					//echo '<td class="table_clean">';
					echo '<form method="post" action="select_group.php">
					<input type="hidden" name="ids" value="'.$row['grpGroupId'].'-'.$row['gpeGroupPersonId'].'">
					';
					if($row['gpeActiveInGroup'] == 1)
					echo '<button style="float:none;" type="submit" class="btn btn-success">Select</button>';
					else
					echo '(Activation Pending)';
					echo '</form>';
					//echo '</td><tr>';
					echo '<br>';
				}		
				//echo '</table>';
				echo '</center>';		
			}

		}else{
			if(json_decode($_COOKIE['USER_DATA'], true)[0]['grpGroupId']){
				setcookie('USER_GROUP_ID', json_decode($_COOKIE['USER_DATA'], true)[0]['grpGroupId']);
				setcookie('USER_USER_GROUP_ID', json_decode($_COOKIE['USER_DATA'], true)[0]['gpeGroupPersonId']);	
				echo '<div id="welcome_message">You are currently working on '.$array[0]['grpName']."'s group".'</div><br>';
				echo '<div ng-view></div>';	
			}else{
				setcookie('USER_GROUP_ID', json_decode($_COOKIE['USER_DATA'], true)[0]['grpGroupId']);
				echo '<center>';
				echo 'You don\'t belong to any group yet. You must create a group (laboratory) or request access to an already existing one';
				echo '<br><br>';
				echo '<a href="create_lab.php"><button class="btn btn-primary" style="float: none; width: 200px;">Create Group (lab)</button></a>';
				echo '<br><br>';
				echo '<a href="request_lab.php"><button class="btn btn-warning" style="float: none; width: 200px;">Request access to Group</button></a>';
				return;		
			}
		}
		
	?>
	</div>
	<?php footer(); ?>
</body>
</html>

