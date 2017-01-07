<?php
include_once('lib/config.php');
include('lib/steamid.php');

// Create connection
$con = mysqli_connect($mysql_host, $mysql_name, $mysql_pass, $mysql_db);

// Check connection
if (mysqli_connect_errno())
	echo "Failed to connect to MySQLi: " . mysqli_connect_error();

$menu_position = 0;

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
						<!--
							Replace this with our own!
						<a href="http://www.gametracker.com/server_info/31.186.250.26:27015/" target="_blank" style="float: left;margin-right: 15px;">
							<img src="http://cache.www.gametracker.com/server_info/31.186.250.26:27015/b_160_400_1_ffffff_c5c5c5_ffffff_000000_0_1_0.png" alt="" width="160" height="248" border="0">
						</a>-->
						<h3>Server Details</h3>
						<p>
							Location: <strong>SET_LOCATION</strong><br>
							Max Slots: <strong>PLY_SLOTS</strong><br>
							IP: <strong>OUR_IP</strong><br>
							Port: <strong>27015</strong><br>
							<!--<strong><a href="steam://connect/OUR_IP:27015" >Join via Steam</a></strong>-->
						</p>
						<div style="width:100%;height:65px;"></div>
					</div>
					<div class="content-container">
						<h3>Chat Commands</h3>
						<p>All commands are chat commands. To use, type them into the in-game chat as you would talk to other players.</p>
						<table class="pure-table pure-table-horizontal pure-table-striped">
							<thead>
								<tr>
									<th>Command</th>
									<th>Description</th>
								</tr>
							</thead>
							<tbody>
								<tr>
									<td>/rules, !rules or rules</td>
									<td>Shows the rules on the server (prints to your console!)</td>
								</tr>
								<tr>
									<td>/web</td>
									<td>Shows the web ui version (This one right here!)</td>
								</tr>
								<tr>
									<td>/model</td>
									<td>Opens up the character selection menu!</td>
								</tr>
								<tr>
									<td>/version</td>
									<td>Shows the current version</td>
								</tr>
								<tr>
									<td>/prestige</td>
									<td>If on max level, you will reset to level 0, but gain some new cool shit.</td>
								</tr>
								<tr>
									<td>/reset</td>
									<td>Resets your stats (Points only)</td>
								</tr>
								<tr>
									<td>/fullreset</td>
									<td>Resets your stats to zero (All your progress will be lost!)</td>
								</tr>
								<tr>
									<td>/challenges or /rewards</td>
									<td>Shows your challange progress</td>
								</tr>
								<tr>
									<td>/skills</td>
									<td>Set your skillpoints"</td>
								</tr>
								<tr>
									<td>/sound</td>
									<td>Disables or Enables the sounds (RPG Mod custom sounds only!)</td>
								</tr>
								<tr>
									<td>/skillsinfo</td>
									<td>Grabs all the information of what the skills do (will print all info on the console!)</td>
								</tr>
								<tr>
									<td>/top10</td>
									<td>Shows the top10 players.</td>
								</tr>
								<tr>
									<td>/rank</td>
									<td>Shows your current rank in-game.</td>
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