<?php
	require('cookiecheck.php');
	include('header.php');

?>

<html>
<head>
	<?php includes(); ?>
</head>
<body>
	<div class="check " id="check"/>
	<?php cabecero(); ?>	
	<div class="main_container">
	
		<div class="panel-group" role="tablist" aria-multiselectable="true" style="width:49%;float:left;">
		  <div class="panel panel-default">
		    <a href="account_details.php"><button class="btn btn-default" ng-click="edit()"><span class="glyphicon glyphicon-edit"></span></button></a>		    			  
		    <div class="panel-heading" role="tab">
		      <h4 class="panel-title">
		        Personal Data
		      </h4>
		    </div>
			<div class="panel-body">
				<table>
					<style>
						td{padding-bottom: 10px;}
					</style>
					<tr class="clean_table">
						<td width="200px">
							Name
						</td>
						<td width="200px">
							<?php 
								$data = json_decode($_COOKIE['USER_DATA'], true);
								echo $data[0]['perName'];
							?>
						</td>
					</tr>
					<tr class="clean_table">
						<td width="200px">
							Lastname
						</td>
						<td width="200px">
							<?php 
								echo $data[0]['perLastname'];
							?>
						</td>
					</tr>
					<tr class="clean_table">
						<td width="200px">
							e-mail address
						</td>
						<td width="200px">
							<?php 
								echo $data[0]['perEmail'];
							?>
						</td>
					</tr>
				</table>
				<a href="reset_password.php"><button class="btn btn-primary">Change password</button></a>
			</div>
		  </div>
		</div>
		
		<div class="panel-group" role="tablist" aria-multiselectable="true" style="width:49%;float: right;">
		  <div class="panel panel-default">
		    <div class="panel-heading" role="tab">
		      <h4 class="panel-title">
		        Groups/Laboratories you belong to: 
		      </h4>
		    </div>
			<div class="panel-body">
				
				<?php 
					$array = json_decode($_COOKIE['USER_DATA'], true);
					echo '<table>';
					foreach($array as $item){
						echo '<tr class="clean_table"><td>';//<label class="label label-';
						if($item['grpGroupId'] == $_COOKIE['USER_GROUP_ID']){
							//echo 'info">';	
						}else{
							//echo 'default">';
						}
						echo $item['grpName'];
						if($item['grpGroupId'] == $_COOKIE['USER_GROUP_ID']){
							echo ' (Currently active)';	
						}
						//echo '</label>';
						echo '</td></tr>';
					}
					echo '</table><center>';
					if(sizeof($array)>1){
						echo '
							<a href="switch_lab_action.php"><button class="btn btn-default" style="float: none">Switch active lab</button></a>';
					}
					echo '<a href="create_lab.php"><button class="btn btn-primary" style="float: none">Create a new Group</button></a>
							<a href="request_lab.php"><button class="btn btn-warning" style="float: none">Request access to other...</button></a>';
					echo '</center></table>';
				?>
				
			</div>
		  </div>
		</div>	
	</div>
	<?php footer(); ?>
</body>
</html>