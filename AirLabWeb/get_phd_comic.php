<?php
/*
	echo 'http://www.phdcomics.com/comics/archive/phd033016s.gif';
	return ;
*/
	$url = 'http://www.phdcomics.com';//http://www.phdcomics.com/comics/archive_print.php?comicid=1810
	$data =  file_get_contents($url);
	if ($result === FALSE) {  }
	else{
		$d = new DOMDocument();
		$d->loadHTML($data);
		$xpathsearch = new DOMXPath($d);
		$catnodes = $xpathsearch->query('//img[contains(@id,"comic")]');	
		
		foreach($catnodes as $node) {
			//echo $d->saveHTML($node);
			echo $node->getAttribute('src');
		}
	}	
	
