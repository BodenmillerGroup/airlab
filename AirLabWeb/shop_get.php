<?php
	require('cookiecheck.php');
	include('header.php');
	header('Origin: ');
	$searchTerm = $_GET['q'];
	if($searchTerm){
		$xml = file_get_contents("http://www.biocompare.com/General-Search/?search=".$searchTerm);
		if($xml){
			$d = new DOMDocument();
			$d->loadHTML($xml);
			$xpathsearch = new DOMXPath($d);
			$catnodes = $xpathsearch->query('//div[contains(@class,"searchResultsModule")]//li/a//text()');//[@href]');	
			$linknodes = $xpathsearch->query('//div[contains(@class,"searchResultsModule")]//li/a/@href');
			$anodes = $xpathsearch->query('//div[contains(@class,"searchResultsModule")]//li/a');					
		}
	}
	
	$catTerm = $_GET['cat'];
	if($catTerm){
		$catTerm = $catTerm.'&vcmpv=true';
		$xml = file_get_contents("http://www.biocompare.com".$catTerm);
		if($xml){
			$d = new DOMDocument();
			$d->loadHTML($xml);
			$xpathsearch = new DOMXPath($d);
			$resultsnodes = $xpathsearch->query('//div[contains(@class,"pageTitle")]');
			$linknodes = $xpathsearch->query('//a[contains(@class, "url")]');
			$anodes = $xpathsearch->query('//div[contains(@class,"searchResultsModule")]//li/a');
			$productnodes = $xpathsearch->query('//*[starts-with(@class,"productRow")]//*[contains(@class,"first") or contains(@class,"product")]//a');			
		}
	}
	$artTerm = $_GET['art'];
	if($artTerm){
		$xml = file_get_contents("http://www.biocompare.com".$artTerm);
		if($xml){
			$d = new DOMDocument();
			$d->loadHTML($xml);
			$xpathsearch = new DOMXPath($d);
			$articleInfo = $xpathsearch->query('//ul[contains(@class,"productDetailUL")]//span');				
		}
	}	
?>

<html>
<head>
	<?php includes(); ?>
	<script src="web/shopper.js"></script>
	<script>
		<?php //Preload for purchase
			$json = '{';
			$isItem = false;
			$item = '';
			$isCatNumber = false;
			$catNumber = '';
			$isCompany = false;				
			$company = '';
			foreach($articleInfo as $node){
				$theClass = $node->getAttribute('class');
				if($theClass == 'label_header'){
					if($node->nodeValue == 'Item')$isItem = true;
					if($node->nodeValue == 'Catalog Number')$isCatNumber = true;
					if($node->nodeValue == 'Company')$isCompany = true;										
					//$json .= '\"'.$d->saveHTML($node).'\":';
					$json .= '\"'.$node->nodeValue.'\":';
				}else{
					if($isItem == true){
						$item = $node->nodeValue;
						$isItem = false;
					}
					if($isCatNumber == true){
						$catNumber = $node->nodeValue;
						$isCatNumber = false;
					}
					if($isCompany == true){
						$company = $node->nodeValue;
						$isCompany = false;
					}					
					$json .= '\"'.$node->nodeValue.'\",';
				}
			}
			if(strlen($json)>1)$json = rtrim($json, ",");
			$json .= '}';
		?>
		var reagentData = '<?php echo $json; ?>';
	</script>	
</head>
<body ng-App = "Shopper">
	<?php cabecero(); ?>		
	<div class="main_container">
	<div ng-view></div>

	<div>

		<?php	
			if($searchTerm){
				echo '<br><br><h3>Categories found</h3>';
				echo '<table class="table">';
				foreach($anodes as $node) {
					$subXPath = $node->getNodePath();
					$theHref = $node->getAttribute('href'); 
					if(strpos($theHref, 'Life-Science-News') == true)continue;
					if(strpos($theHref, 'Product-Reviews') == true)continue;
					if(strpos($theHref, 'Application-Notes') == true)continue;
					if(strpos($theHref, 'Editorial-Articles') == true)continue;							
					$node->setAttribute('href', 'shop.php?cat='.$theHref.'&vcmpv=true');
					//echo $node->getAttribute('href');
					//echo '<br>';
					echo '<tr><td>'.$d->saveHTML($node).'</td></tr>';
					//echo '<hr>';
				}			
				echo '</table>';									
			}
		?>
		<?php
			if($catTerm){
				$results = '';
				foreach($resultsnodes as $node){
					$string = $d->saveHTML($node);
					$comps = explode(' Products', $string);
					$comps2 = explode(' ', $comps[0]);
					$results = $comps2[4];
				}
				//echo $catTerm;
				echo '<br><br><h3>'.$results.' Results</h3>';
				echo '<table class="table">';
				foreach($productnodes as $node) {
					$subXPath = $node->getNodePath();
					
					$theClass = $node->getAttribute('class');
					if($theClass === 'firstReview' || $theClass === 'compare' || $theClass === 'requestSelected')continue;
					$url = $node->getAttribute('href');
					if(strpos($url, 'start-your-review') == true)continue;
					str_replace('false', 'true', $url);
					$node->setAttribute('href', 'shop.php?art='.$url);
					//echo $node->getAttribute('href');
					//echo '<br>';
					echo '<tr><td>'.$d->saveHTML($node).'</td></tr>';
					//echo '<hr>';
				}			
				echo '</table>';
			}	
	
		?>
		<?php
			if($artTerm){
				echo '<br><br><h3>Details</h3>';
				echo '<table class="table">';
				foreach($articleInfo as $node){
					$theClass = $node->getAttribute('class');
					if($theClass == 'label_header'){
						echo '<tr>';	
					}
					echo '<td>';
					echo $d->saveHTML($node);
					echo '</td>';
					if($theClass != 'label_header'){
						echo '</tr>';	
					}
				}
				echo '</table>';
			}	
	
		?>
	
	</div>
	<br>
	<br>
	<?php //echo $xml ?>
	<?php footer(); ?>
	
</body>
</html>