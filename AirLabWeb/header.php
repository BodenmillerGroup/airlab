<?php
	
function loginBox(){
	echo '
			<a href="plans.php" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false" onclick="return false;">Log in
              <!--<span class="glyphicon glyphicon-user"></span>-->
              <span class="caret"></span>
            </a>
            <ul class="dropdown-menu">
				<div style="margin:20px;">
					<form accept-charset="UTF-8" action="login_action.php" method="post">
						<input style="margin-bottom:10px; width:200px;" 
						autofocus="autofocus" class="form-control" id="user_login" name="email" placeholder="Username or Email" required="required" type="text" />
						<input style="margin-bottom:10px; width:200px;" class="form-control" id="user_password" name="password" placeholder="Password" 
						required="required" type="password" />
						<br>';
						if($_GET['success'] == strval('no'))
			            echo '<p style="color:red">Wrong email or password</p>';
			            if($_GET['success'] == strval('noactive'))
			            echo '<p style="color:red">Your account is pending activation. Please check your email.</p>';
			            if($_GET['success'] == strval('newgroup'))
			            echo '<p style="color:green">Your created a new group. Please log in again.</p>';
						echo '<input class="btn btn-primary" style="width:100%;" id="submit" name="commit" type="submit" value="Login" />
					</form>
					<br>
					<a href="new_password.php">Forgot password?</a>
					<br>
					<br>
					Don\'t have an account yet?
					<a href="sign_up.php">Sign up now</a>
				</div>
			</ul>';
}


function accountBox(){
	echo '<ul class="nav navbar-nav navbar-right">
            <li>
            	<a href="account.php" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false" onclick="return false;">'
            	.$_COOKIE['USER_EMAIL']
            	.'</a>
            	<ul class="dropdown-menu">
					<li><a href="dashboard.php">Go to my Airlab</a></li>
					<li><a href="logout.php">Logout <span class="glyphicon glyphicon-off"></span></a></li>
              </ul>
            </li>
		 </ul>';
}

function cabeceroHome(){
	echo '<nav class="navbar navbar-default navbar-fixed-top">
      <div class="container">
        <!--<div class="navbar-header">
          <a class="navbar-brand" href="dashboard.php">
		    <img alt="Brand" src="pictures/airlablogo.png" width="27px" height="27px">
		  </a>
        
          <a class="navbar-brand" href="dashboard.php">AirLab</a>
        </div>-->
        <div id="navbar" class="navbar-collapse collapse">
            
          <ul class="nav navbar-nav navbar-right">
           <li>';
              
                if(isset($_COOKIE['TOKEN_PUBLIC_KEY']))accountBox();
                else loginBox();
				
              
            echo '</li>
          </ul>
        </div>
      </div>
    </nav><br><br><br><br>
    <div id="progress" class="progress" style="display:none;">
		<div class="progress-bar progress-bar-warning progress-bar-striped active" id="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 10%;">
			
		</div>
	</div>';
}

function newCabecero(){
	$uri = $_SERVER['REQUEST_URI'];
	$comps = split('.php', $uri);
	$firstComp = $comps[0];
	$recomps = split('/', $firstComp);
	$lastComp = $recomps[sizeof($recomps) - 1];
	$toPass = 0;
	switch($lastComp){
		case 'inventory':
			$toPass = 1;
			break;
		case 'antibody_gateway':
			$toPass = 1;
			break;
		case 'shop':
			$toPass = 1;
			break;
		case 'samples':
			$toPass = 1;
			break;
		case 'protocols':
			$toPass = 2;
			break;
		case 'plans':
			$toPass = 3;
			break;
		case 'papers':
			$toPass = 4;
			break;
		case 'calendar':
			$toPass = 5;
			break;
		default:
			$toPass = 0;
	}
	navbar($toPass);
}

function cabecero(){
	newCabecero();return ;	
}


function includes(){
	echo '
	<title>AirLab</title>
	<meta content="utf-8" http-equiv="encoding">
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />	
	
	<!--jQuery-->
	<script type="text/javascript" src="web/jquery.min.js"></script>
	
	<!-- BOOTSTRAP -->
	
		<!--Working-->
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js" integrity="sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS" crossorigin="anonymous"></script>

		<!-- BootStrap other
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap-theme.min.css" 
	integrity="sha384-fLW2N01lMqjakBkx3l/M9EahuwpSfeNvV63J5ezn3uZzapT0u7EYsXMjQV+0En5r" crossorigin="anonymous">
		-->
	
	<link type="text/css" rel="stylesheet" media"screen"="" href="css/airlab.css">
	
	<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.5.0/angular.min.js"></script>
	<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.5.0/angular-resource.min.js"></script>
	<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.5.0/angular-route.min.js"></script>
	
	<!-- For the calendar, will adopt angular-ui-bootstrap for everything else in the future-->
    <script src="//cdnjs.cloudflare.com/ajax/libs/angular-ui-bootstrap/0.14.3/ui-bootstrap-tpls.min.js"></script>
	
	<script src="web/newController.js"></script>
	<script src="web/boilerplate.js"></script>
	<script src="web/getters.js"></script>
	<script src="web/generaljs.js"></script>
	<script src="web/angular-drag-and-drop-lists.min.js"></script>	
	<script src="http://www.datejs.com/build/date.js" type="text/javascript"></script>
	<script src="//cdnjs.cloudflare.com/ajax/libs/moment.js/2.10.6/moment.min.js"></script>	
	
	<!-- Favicons -->
	<link rel="apple-touch-icon" sizes="57x57" href="/pictures/favs/apple-icon-57x57.png">
	<link rel="apple-touch-icon" sizes="60x60" href="/pictures/favs/apple-icon-60x60.png">
	<link rel="apple-touch-icon" sizes="72x72" href="/pictures/favs/apple-icon-72x72.png">
	<link rel="apple-touch-icon" sizes="76x76" href="/pictures/favs/apple-icon-76x76.png">
	<link rel="apple-touch-icon" sizes="114x114" href="/pictures/favs/apple-icon-114x114.png">
	<link rel="apple-touch-icon" sizes="120x120" href="/pictures/favs/apple-icon-120x120.png">
	<link rel="apple-touch-icon" sizes="144x144" href="/pictures/favs/apple-icon-144x144.png">
	<link rel="apple-touch-icon" sizes="152x152" href="/pictures/favs/apple-icon-152x152.png">
	<link rel="apple-touch-icon" sizes="180x180" href="/pictures/favs/apple-icon-180x180.png">
	<link rel="icon" type="image/png" sizes="192x192"  href="/pictures/favs/android-icon-192x192.png">
	<link rel="icon" type="image/png" sizes="32x32" href="/pictures/favs/favicon-32x32.png">
	<link rel="icon" type="image/png" sizes="96x96" href="/pictures/favs/favicon-96x96.png">
	<link rel="icon" type="image/png" sizes="16x16" href="/pictures/favs/favicon-16x16.png">
	<link rel="manifest" href="/pictures/favs/manifest.json">
	<meta name="msapplication-TileColor" content="#ffffff">
	<meta name="msapplication-TileImage" content="/pictures/favs/ms-icon-144x144.png">
	<meta name="theme-color" content="#ffffff">
	';
	
}

function navbar($section){
	$first = '';
	$second = '';
	$third = '';
	$fourth = '';
	$fifth = '';
	$sixth = '';
	
	switch ($section) {
    	case 0:
        	$first = ' class="active"';
			break;
		case 1:
        	$second = ' class="active"';
			break;
		case 2:
        	$third = ' class="active"';
			break;
		case 3:
        	$fourth = ' class="active"';
			break;
		case 4:
        	$fifth = ' class="active"';
			break;
		case 5:
        	$sixth = ' class="active"';
			break;
		default:
	}	
	
	$groupName = '';
	$array = json_decode($_COOKIE['USER_DATA'], true);
	if(isset($_COOKIE['USER_USER_GROUP_ID'])){
		foreach($array as $row){
			if($row['grpGroupId'] == $_COOKIE['USER_GROUP_ID']){
				$groupName = $row['grpName'];
				$role = $row['gpeRole'];
			}			
		}
	}
	
	echo '<nav class="navbar navbar-default navbar-fixed-top">
      <div class="container">
        <div class="navbar-header">
          <a class="navbar-brand" href="home.php">
		    <img alt="Brand" src="pictures/airlablogo.png" width="27px" height="27px">
		  </a>
        
          <a class="navbar-brand" href="home.php"'.$first.'>AirLab</a>
        </div>
        <div id="navbar" class="navbar-collapse collapse">
          <ul class="nav navbar-nav">
            <li'.$first.'><a href="dashboard.php">Dashboard</a></li>
            <li'.$second.'>
              <a class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false" onclick="return false;">Inventory <span class="caret"></span></a>
              <ul class="dropdown-menu">
                <li><a href="inventory.php#/inventory">Reagents Inventory</a></li>
                <li><a href="shop.php">Shop</a></li>
                <li><a href="samples.php">Samples</a></li>
                <li><a href="places.php">Storage</a></li>
                <!--<li><a href="shop.php">Animals</a></li>-->
                <li role="separator" class="divider"></li>
                <li class="dropdown-header">Antibody Gateway</li>
                <li><a href="antibody_gateway.php#/clones">Clones</a></li>
                <li><a href="antibody_gateway.php#/panels">Panels</a></li>
                <li><a href="antibody_gateway.php#/conjugates">All Conjugates</a></li>
                <li><a href="antibody_gateway.php#/lots">All Lots</a></li>
              </ul>
            </li>
            <li'.$third.'><a href="protocols.php">Protocols</a></li>
            <li'.$fourth.'>
              <a class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false" onclick="return false;">Experiments <span class="caret"></span></a>
              <ul class="dropdown-menu">
                <li><a href="plans.php#/plans">My Projects</a></li>
                <li><a href="plans.php#/shared">Shared with me</a></li>
              </ul>
            </li>
            <li'.$fifth.'>
              <a class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false" onclick="return false;">
              Papers <span class="caret"></span></a>
              <ul class="dropdown-menu">
                <li><a href="papers.php#/pubmed_search">Search Pubmed</a></li>
                <li><a href="papers.php#/my_papers">My Papers</a></li>
                <li><a href="papers.php#/papers_lab">Lab Papers</a></li>
              </ul>
            </li>
            <li'.$sixth.'>
              <a class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false" onclick="return false;">
              Cals/Links <span class="caret"></span></a>
              <ul class="dropdown-menu">
                <li><a href="calendar.php">Calendars</a></li>
                <li><a href="calendar.php#/links">Web links</a></li>
              </ul>            
            </li>
          </ul>
          <ul class="nav navbar-nav navbar-right">
            <li><a href="account.php">'.$_COOKIE['USER_EMAIL'].' | '.$groupName.'</a></li>
			';
			if($role < 2 && $role >=0) echo '<li><a href="administration.php"><span style="margin:2px;" class="glyphicon glyphicon-briefcase"></span></a></li>';
            echo '<li><a href="logout.php"><span style="margin:2px;" class="glyphicon glyphicon-off"></span></a></li>
          </ul>
        </div>
      </div>
    </nav><br><br><br><br>
    <div id="progress" class="progress" style="display:none;">
		<div class="progress-bar progress-bar-warning progress-bar-striped active" id="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 10%;">
			
		</div>
	</div>';
//    <span class="badge" id="return_up" onclick="scrollToTop();">^</div>';
}

function footer(){
	echo '
	<div id="messages"></div>
	<div id="footer">
  AirLab | <a href="mailto:raulcatena@gmail.com">email webmaster</a>
</div>';
}
	

?>