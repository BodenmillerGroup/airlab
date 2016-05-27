<?php	
	require("db.php");

	$email = $_POST['email'];
	$passClean = $_POST['password'];
	$pass = hash("sha1", $_POST['password']);

	$sql = "SELECT perPersonId,perLastname,perName,perEmail,zetActive,gpeActiveInGroup,grpGroupId,grpCoordinates,grpInstitution,grpName,grpUrl,createdBy,gpeGroupPersonId,gpeGroupId,gpePersonId,gpeRole, gpeOrders, gpeErase, gpeFinances FROM tblPerson A LEFT JOIN (SELECT grpGroupId,grpCoordinates,grpInstitution,grpUrl,grpName,createdBy,gpeGroupPersonId,gpeActiveInGroup,gpeGroupId,gpePersonId,gpeRole,gpeOrders,gpeErase,gpeFinances FROM tblGroup JOIN tblZGroupPerson ON tblGroup.grpGroupId = tblZGroupPerson.gpeGroupId) B ON A.perPersonId = B.gpePersonId WHERE perEmail='".$email."' AND perPassword='".$pass."'";	
		
	$array = fetchDB($sql);	
	
	$groups = array();
	if(mysql_num_rows($array)>0){
		while($row = mysql_fetch_array($array)){
			$groups[] = $row;
		}
	}else{
		//echo 'no sucess';
		header('Location: simulator.php?success=no');
		return;
	}
?>

<html>
<body>
<center><h1>AirLab Web iOS Simulator</h1><br><br>
<iframe src="https://appetize.io/embed/vvj5cq3mrd86exz6rex2tkv23c?device=ipadair&scale=80&autoplay=false&orientation=landscape&deviceColor=white&screenOnly=true&params=%7B%22foo%22%3A%22<? echo $email; ?>%22%2C%22bar%22%3A%22<? echo $passClean; ?>%22%7D" width="1500px" height="900px" frameborder="0" scrolling="no"></iframe>
<br>
<iframe src="https://appetize.io/embed/zqnkb2v1ecxg9rntfzhubwd5ag?device=ipadair&scale=80&autoplay=false&orientation=landscape&deviceColor=white&screenOnly=true&params=%7B%22foo%22%3A%22<? echo $email; ?>%22%2C%22bar%22%3A%22<? echo $passClean; ?>%22%7D" width="900px" height="646px" frameborder="0" scrolling="no"></iframe>
<iframe src="https://appetize.io/embed/zqnkb2v1ecxg9rntfzhubwd5ag?device=iphone6&scale=100&autoplay=false&orientation=portrait&deviceColor=white&screenOnly=true&params=%7B%22foo%22%3A%22<? echo $email; ?>%22%2C%22bar%22%3A%22<? echo $passClean; ?>%22%7D" width="375px" height="668px" frameborder="0" scrolling="no"></iframe>
</center>
</body>
</html>