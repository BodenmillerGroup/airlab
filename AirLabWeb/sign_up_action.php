<?php	
	require("db.php");

	$email = $_POST['email'];
	$pass = $_POST['password'];
	$repass = $_POST['re_password'];
	if($pass != $repass){
		header('Location: sign_up.php?success=differentPasswords&email='.$email);
		return;
	}
	if(strlen($pass)< 7){
		header('Location: sign_up.php?success=passwordShort&email='.$email);
		return;
	}
	
	$sql = "SELECT perEmail FROM tblPerson  WHERE perEmail='".$email."'";	
		
	$array = fetchDB($sql);	
	
	if(mysql_num_rows($array)>0){
		header('Location: sign_up.php?success=emailExists');
		return;
	}
?>

<?php
	include 'Messages/success_creation.php';
	//include('header.php');
?>

<script>
	var http = new XMLHttpRequest();
	var url = "/apiLabPad/api/person";
	var params = 'data={"email":"<?php echo $email; ?>","password":"<?php echo $pass; ?>"}';
	http.open("POST", url, true);

	//Send the proper header information along with the request
	http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
	http.setRequestHeader("Content-length", params.length);
	http.setRequestHeader("Connection", "close");
	
	http.onreadystatechange = function() {//Call a function when the state changes.
	    if(http.readyState == 4 && http.status == 200) {
	        //alert(http.responseText);
	    }
	}
	http.send(params);
</script>