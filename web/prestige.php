<?php
include_once('lib/config.php');
include('lib/steamid.php');

// Create connection
$con = mysqli_connect($mysql_host, $mysql_name, $mysql_pass, $mysql_db);

// Check connection
if (mysqli_connect_errno())
	echo "Failed to connect to MySQLi: " . mysqli_connect_error();

$menu_position = 0.1;

?>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>Index :: <?php echo $site_name; ?></title>
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
						<h3>Prestige</h3>
						<p>You can only prestige when you hit level 800, but when you do, you will earn some neat rewards. You will also get a permenant XP Booster. This Booster will upgrade each time you prestige!</p>
						<p>Remember, if the item is marked as (OnSpawn), it means it will only be given when you spawn, and not right away.</p>
						<table class="pure-table pure-table-horizontal pure-table-striped">
							<thead>
								<tr>
									<th>Level</th>
									<th>Reward</th>
									<th>Description</th>
									<th>OnSpawn</th>
								</tr>
							</thead>
							<tbody>
								<tr>
									<td>1</td>
									<td>Key Blade</td>
									<td>It's a bloody key.</td>
									<td><span style="color:green">Yes</span></td>
								</tr>
								<tr>
									<td>2</td>
									<td>Long Jump</td>
									<td>You will be able to jump further distances! (Crouch+Jump)</td>
									<td><span style="color:red">No</span></td>
								</tr>
								<tr>
									<td>3</td>
									<td>Golden Revolver</td>
									<td>Isn't it shiny?</td>
									<td><span style="color:green">Yes</span></td>
								</tr>
								<tr>
									<td>4</td>
									<td>Grease gun</td>
									<td>A Grease gun from the second world war.</td>
									<td><span style="color:green">Yes</span></td>
								</tr>
								<tr>
									<td>5</td>
									<td>M14</td>
									<td>A semi automatic Sniper Rifle.</td>
									<td><span style="color:green">Yes</span></td>
								</tr>
								<tr>
									<td>6</td>
									<td>Double Barrel Shotgun</td>
									<td>Double the barrel, double the damage!</td>
									<td><span style="color:green">Yes</span></td>
								</tr>
								<tr>
									<td>7</td>
									<td>Shotgun Grenade</td>
									<td>This isn't a normal shotgun, it shoots grenades instead.</td>
									<td><span style="color:green">Yes</span></td>
								</tr>
								<tr>
									<td>8</td>
									<td>Tesla Gun</td>
									<td>Hold it down for more power!</td>
									<td><span style="color:green">Yes</span></td>
								</tr>
								<tr>
									<td>9</td>
									<td>.500 Revolver</td>
									<td>One shot, one kill. (probably)</td>
									<td><span style="color:green">Yes</span></td>
								</tr>
								<tr>
									<td>10</td>
									<td>HMG</td>
									<td>It's deadlier than the minigun.</td>
									<td><span style="color:green">Yes</span></td>
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