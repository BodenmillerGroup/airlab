<?php

function fetchDB($sql){
	
	//From Inside GAE
	$conn = mysql_connect(':/cloudsql/XXXXX:XXXX',//Removed name of appspot app domain and DB name
  		'', // username
  		''      // password
  	);
	mysql_select_db('');//Remove DB name
	
	$result = mysql_query($sql);
	return $result;
}

function boolDB($sql){
	//DB work
	
	//From inside GAE
	$conn = new mysqli(null,
  		'', // username
  		'',     // password
 		 '',
  		null,
  		'/cloudsql/XXXXX:XXXX'//Removed name of appspot app domain and DB name
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