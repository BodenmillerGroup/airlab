<?php
/*
	$url = 'https://www.protocols.io/api/v2/load_protocol_steps';
	$data = array('protocol_uri' => $_GET['protocol_uri']);

	// use key 'http' even if you send the request to https://...
	$options = array(
	    'http' => array(
	        'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
	        'method'  => 'POST',
	        'content' => http_build_query($data)
	    )
	);
	
	$result = file_get_contents($url, false, $context);
	if ($result === FALSE) {  }
	else{
		echo $result;
	}
*/
	
	$url = 'https://www.protocols.io/api/v2/load_protocol_steps';
	$data = array('protocol_id' => $_GET['protocol_id']);

	// use key 'http' even if you send the request to https://...
	$options = array(
	    'http' => array(
	        'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
	        'method'  => 'POST',
	        'content' => http_build_query($data)
	    )
	);
	
	$result = file_get_contents($url, false, $context);
	if ($result === FALSE) { /* Handle error */ }
	else{
		$prots = json_decode($result)['protocols'];
		foreach($prots as $aProt)
		echo json_encode($aProt);
	}
	

?>