<?php

function fetchDB($sql){
	//DB work
	$username = "";
	$password = "";
	$hostname = "137.0.0.1"; 
	

	//connection to the database
	// $dbhandle = mysql_connect($hostname, $username, $password) 
	//or die("Unable to connect to MySQL");
	//$selected = mysql_select_db("labpad", $dbhandle) 
	//or die("Could not select examples");
	
	//From Inside GAE
	$conn = mysql_connect(':/cloudsql/XXXXXX:labpadnew',//Remove appspot pointer
  		'', // username
  		''      // password
  	);
	mysql_select_db('labpad_new');
	
	$result = mysql_query($sql);
	return $result;
}

function boolDB($sql){
	//DB work
	$username = "";//Remove credentials in public repo
	$password = "";
	$hostname = ""; 
	$dbname = "";

	// Create connection from outside GAE
	//$conn = new mysqli($hostname, $username, $password, $dbname);
	
	//From inside GAE
	$conn = new mysqli(null,
  		'', // username
  		'',     // password
 		 '',
  		null,
  		'/cloudsql/XXXXX:labpadnew'//Remove name of DB here
  	);
	
	
	// Check connection
	if ($conn->connect_error) {
	    die("Connection failed: " . $conn->connect_error);
	} 

	$outcome = true;
	if ($conn->query($sql) === TRUE) {
		//echo "New record created successfully";
		$outcome = true;
	} else {
		//echo "Error: " . $sql . "<br>" . $conn->error;
		$outcome = false;
	}

	$conn->close();
	return $outcome;
}

?>