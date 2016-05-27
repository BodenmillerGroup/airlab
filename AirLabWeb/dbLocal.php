<?php

function fetchDB($sql){
	//DB work
	$username = "";
	$password = "";
	$hostname = "127.0.0.1"; 
	$dbname = "AirLab";

	//connection to the database
	$dbhandle = mysql_connect($hostname, $username, $password) 
	or die("Unable to connect to MySQL");
	$selected = mysql_select_db("AirLab", $dbhandle)
	or die("Could not select examples");
	$result = mysql_query($sql);

	return $result;
}

function boolDB($sql){
	//DB work
	$username = "";
	$password = "";
	$hostname = "127.0.0.1"; 
	$dbname = "AirLab";

	// Create connection from outside GAE
	$conn = new mysqli($hostname, $username, $password, $dbname);
	
	
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