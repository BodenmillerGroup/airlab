<?php
	
	//Getting the protocols. Page by page
	
/*
	for($i = 0; $i<121; $i++){
		echo $i.'<br>';
		$url = 'https://www.protocols.io/api/v1/protocols';
		//$data = array('key' => '', 'filter' => '', 'hide_mixtures' => '0', 'order_by' => 'publish_date' , 'reagent_id' => '0' , 'page_id' => $_GET['page'], 'page_size' => $_GET['size']);
		$data = array('key' => '', 'filter' => '', 'hide_mixtures' => '0', 'order_by' => 'publish_date' , 'reagent_id' => '0' , 'page_id' => $i, 'page_size' => '5');
		echo http_build_query($data);
		echo '<br>';
	
		$options = array(
		    'http' => array(
		        'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
		        'method'  => 'POST',
		        'content' => http_build_query($data)
		    )
		);
		$context  = stream_context_create($options);
		$result = file_get_contents($url, false, $context);
		if ($result === FALSE) {  }
		else{
			$username = "root";
			$password = "root";
			$hostname = "127.0.0.1"; 
			$dbname = "AirLab";
			$dbhandle = mysql_connect($hostname, $username, $password) 
			or die("Unable to connect to MySQL");
			$selected = mysql_select_db("AirLab", $dbhandle)
			or die("Could not select examples");
			
			
			$protss = json_decode($result, true);
			$prots = $protss['protocols'];		
			foreach($prots as $aProt){
				$sql = 'INSERT INTO tblRecipe (dump, groupId, createdBy) VALUES (\''.json_encode($aProt, true).'\', 3, 4)';
				echo $sql.'<br>';
				$result = mysql_query($sql);
				//echo json_encode($aProt);
				echo $result;
				echo '<hr>';
			}
			mysql_close();
		}		
	}
*/
		

	//Parsing name and URI
	/*
	$username = "root";
	$password = "root";
	$hostname = "127.0.0.1"; 
	$dbname = "AirLab";
	$dbhandle = mysql_connect($hostname, $username, $password) 
	or die("Unable to connect to MySQL");
	$selected = mysql_select_db("AirLab", $dbhandle)
	or die("Could not select examples");
	//$sql = 'SELECT * FROM tblRecipe WHERE groupId = 3 AND createdBy = 4 AND dump IS NOT NULL';
	//$sql = 'SELECT * FROM tblRecipe WHERE groupId = 3 AND createdBy = 4 AND dump IS NOT NULL AND uriio = ""';
	$result = mysql_query($sql);
	
	while($row = mysql_fetch_array($result)){
		echo $row['dump'];
		$array = json_decode($row['dump'], true);
		echo '<br>'.$array['protocol_name'].'<br>';
		$otherSql = 'UPDATE tblRecipe SET rcpTitle = \''.$array['protocol_name'].'\', uriio = \''.$array['uri'].'\' WHERE rcpRecipeId = '.$row['rcpRecipeId'];
		echo '<br><br>';
		echo $otherSql.'<br>';
		$aresult = mysql_query($otherSql);
		echo $aresult;
		echo '<hr>';
	}
	*/

	//Getting Steps
	/*
	$username = "root";
	$password = "root";
	$hostname = "127.0.0.1"; 
	$dbname = "AirLab";
	$dbhandle = mysql_connect($hostname, $username, $password) 
	or die("Unable to connect to MySQL");
	$selected = mysql_select_db("AirLab", $dbhandle)
	or die("Could not select examples");
	$sql = 'SELECT * FROM tblRecipe WHERE groupId = 3 AND createdBy = 4 AND dump IS NOT NULL AND LENGTH(uriio) > 0';// LIMIT 485, 100';
	//$sql = 'SELECT * FROM tblRecipe WHERE dumpsteps LIKE \'%141605%\'';
	$result = mysql_query($sql);
	
	while($row = mysql_fetch_array($result)){
		echo $row['uriio'];
		$url = 'https://www.protocols.io/api/v2/load_protocol_steps';
		$data = array('protocol_uri' => $row['uriio']);
		//echo http_build_query($data);
		echo '<br>';
	
		$options = array(
		    'http' => array(
		        'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
		        'method'  => 'POST',
		        'content' => http_build_query($data)
		    )
		);
		$context  = stream_context_create($options);
		$result2 = file_get_contents($url, false, $context);
		if ($result2 === FALSE) {  }
		else{
			//echo $result2;
			$otherSql = 'UPDATE tblRecipe SET dumpsteps = \''.$result2.'\' WHERE rcpRecipeId = '.$row['rcpRecipeId'];
			//echo $otherSql.'<br>';
			$result3 = mysql_query($otherSql);
		}
		sleep(1);
	}
	*/

	//Extract steps and put to catchedInfo
	$username = "root";
	$password = "root";
	$hostname = "127.0.0.1"; 
	$dbname = "AirLab";
	$dbhandle = mysql_connect($hostname, $username, $password) 
	or die("Unable to connect to MySQL");
	$selected = mysql_select_db("AirLab", $dbhandle)
	or die("Could not select examples");
	$sql = 'SELECT * FROM tblRecipe WHERE groupId = 3 AND createdBy = 4 AND dump IS NOT NULL AND LENGTH(dumpsteps) > 0';
	//$sql = 'SELECT * FROM tblRecipe WHERE dumpsteps LIKE \'%141605%\'';
	$result = mysql_query($sql);
	
	while($row = mysql_fetch_array($result)){
		$collected = array();
		$arrayAll = json_decode($row['dumpsteps'], true);
		//echo $row['dumpsteps'];
		$steps = $arrayAll['steps'];
		foreach($steps as $step){
			$comps = $step['components'];
			foreach($comps as $comp){
				if($comp['name'] == 'Description'){
					$collected[] = $comp['data'];
				}
			}
		}
		$defCI = array();			
		$ind = 1;
		foreach($collected as $stp){
			$defStp = array();
			$defStp['stpTime'] = '';
			$defStp['stpPosition'] = $ind;
			$defStp['stpText'] = $stp;								
			$ind++;	
			$defCI[] = $defStp; 			
		}
		
		$sql = 'UPDATE tblRecipe SET catchedInfo = \''.json_encode($defCI, true).'\' WHERE rcpRecipeId = '.$row['rcpRecipeId'];
		$resultB = mysql_query($sql);
		echo '<hr>';
		echo $resultB;
		echo '<hr>';			
	}
?>