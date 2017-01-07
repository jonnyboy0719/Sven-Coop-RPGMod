<?php
include_once('lib/config.php');
include('lib/steamid.php');

// Create connection
$con = mysqli_connect($mysql_host, $mysql_name, $mysql_pass, $mysql_db);

// Check connection
if (mysqli_connect_errno())
	echo "Failed to connect to MySQLi: " . mysqli_connect_error();

$menu_position = 0.2;

?>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>Gift From The Gods :: <?php echo $site_name; ?></title>
		<meta name="description" content="<?php echo $site_name; ?> & Player Statistics">
		<link rel="stylesheet" href="css/pure-min.css">
		<link rel="stylesheet" href="css/style.css">
		<link rel="stylesheet" href="http://fonts.googleapis.com/css?family=Raleway:300%7cSource+Sans+Pro:400,700%7cSource+Code+Pro&amp;subset=latin,latin-ext">
	</head>
	<body>
		<div id="layout">
			<a href="#menu" id="menuLink" class="menu-link"><span></span></a>
			<div id="menu">
				<div class="pure-menu pure-menu-open">
					<a class="pure-menu-heading" href="//theafterlife.eu/"><?php echo $site_name_short; ?></a>
					<ul>
						<?php include('lib/menu.php'); ?>
					</ul>
				</div>
			</div>
			<div id="main">
				<div class="header">
					<h1><?php echo $site_name; ?></h1>
				</div>
				<div class="content">
					<div class="content-container">
						<h3>The Gifts From The Gods</h3>
						<p>The higher your level is, the more, and better weapons will you obtain!</p>
						<table class="pure-table pure-table-horizontal pure-table-striped">
							<thead>
								<tr>
									<th>Level</th>
									<th>Reward</th>
									<th>Rarity</th>
								</tr>
							</thead>
							<tbody>
								<tr>
									<td>1</td>
									<td>Pipe Wrench</td>
									<td><span style="color:green">70%</span></td>
								</tr>
								<tr>
									<td>1</td>
									<td>Glock</td>
									<td><span style="color:green">70%</span></td>
								</tr>
								<tr>
									<td>1</td>
									<td>357</td>
									<td><span style="color:green">65%</span></td>
								</tr>
								<tr>
									<td>2</td>
									<td>Uzi</td>
									<td><span style="color:green">65%</span></td>
								</tr>
								<tr>
									<td>2</td>
									<td>Desert Eagle</td>
									<td><span style="color:green">65%</span></td>
								</tr>
								<tr>
									<td>3</td>
									<td>MP5</td>
									<td><span style="color:green">65%</span></td>
								</tr>
								<tr>
									<td>3</td>
									<td>Crossbow</td>
									<td><span style="color:green">65%</span></td>
								</tr>
								<tr>
									<td>3</td>
									<td>Tommy Gun</td>
									<td><span style="color:green">75%</span></td>
								</tr>
								<tr>
									<td>4</td>
									<td>Shotgun</td>
									<td><span style="color:green">65%</span></td>
								</tr>
								<tr>
									<td>4</td>
									<td>M16</td>
									<td><span style="color:green">65%</span></td>
								</tr>
								<tr>
									<td>5</td>
									<td>Hand Grenades</td>
									<td><span style="color:green">65%</span></td>
								</tr>
								<tr>
									<td>5</td>
									<td>Tripmines</td>
									<td><span style="color:green">65%</span></td>
								</tr>
								<tr>
									<td>5</td>
									<td>Akimbo Uzi</td>
									<td><span style="color:green">65%</span></td>
								</tr>
								<tr>
									<td>5</td>
									<td>PPSH</td>
									<td><span style="color:green">65%</span></td>
								</tr>
								<tr>
									<td>6</td>
									<td>Hornet Gun</td>
									<td><span style="color:green">65%</span></td>
								</tr>
								<tr>
									<td>6</td>
									<td>Some Suicidal Aliens</td>
									<td><span style="color:darkorange">50%</span></td>
								</tr>
								<tr>
									<td>7</td>
									<td>Satchel Charges</td>
									<td><span style="color:darkorange">50%</span></td>
								</tr>
								<tr>
									<td>7</td>
									<td>Egon</td>
									<td><span style="color:darkorange">45%</span></td>
								</tr>
								<tr>
									<td>7</td>
									<td>Rocket Launcher</td>
									<td><span style="color:darkorange">45%</span></td>
								</tr>
								<tr>
									<td>7</td>
									<td>BAR</td>
									<td><span style="color:green">70%</span></td>
								</tr>
								<tr>
									<td>8</td>
									<td>M249</td>
									<td><span style="color:darkorange">40%</span></td>
								</tr>
								<tr>
									<td>8</td>
									<td>Garand</td>
									<td><span style="color:green">60%</span></td>
								</tr>
								<tr>
									<td>8</td>
									<td>Gauss Rifle</td>
									<td><span style="color:red">35%</span></td>
								</tr>
								<tr>
									<td>9</td>
									<td>Spore Launcher</td>
									<td><span style="color:red">25%</span></td>
								</tr>
								<tr>
									<td>9</td>
									<td>Displacer</td>
									<td><span style="color:red">25%</span></td>
								</tr>
								<tr>
									<td>10</td>
									<td>Sniper Rifle</td>
									<td><span style="color:red">20%</span></td>
								</tr>
								<tr>
									<td>10</td>
									<td>Grenade Launcher</td>
									<td><span style="color:red">15%</span></td>
								</tr>
								<tr>
									<td>10</td>
									<td>Scientist Rocket Shotgun</td>
									<td><span style="color:red">15%</span></td>
								</tr>
								<tr>
									<td>10</td>
									<td>Scientist Rocket Launcher</td>
									<td><span style="color:red">15%</span></td>
								</tr>
								<tr>
									<td>10</td>
									<td>Bio Rifle</td>
									<td><span style="color:red">10%</span></td>
								</tr>
								<tr>
									<td>10</td>
									<td>Gloun Gun</td>
									<td><span style="color:red">10%</span></td>
								</tr>
								<tr>
									<td>10</td>
									<td>Redeemer</td>
									<td><span style="color:red">2%</span></td>
								</tr>
								<tr>
									<td>10</td>
									<td>Thunderbolt</td>
									<td><span style="color:red">1%</span></td>
								</tr>
							</tbody>
						</table>
					</div>
					<?php include('lib/footer.php'); ?>
				</div>
			</div>
		</div>
	</body>
</html>