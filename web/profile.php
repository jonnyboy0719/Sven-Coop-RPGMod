<?php
include_once('lib/config.php');
include('lib/steamid.php');

// Create connection
$con = mysqli_connect($mysql_host, $mysql_name, $mysql_pass, $mysql_db);
$getrank = 0;
$steamid = 0;

// Check connection
if (mysqli_connect_errno())
	echo "Failed to connect to MySQLi: " . mysqli_connect_error();

if ($_GET['steamid'])
	$steamid = htmlspecialchars($_GET['steamid']);

$result_users = mysqli_query($con, "SELECT * FROM {$mysql_table} ORDER BY prestige DESC, lvl + 0 DESC");
$result_user = mysqli_query($con, "SELECT * FROM {$mysql_table} WHERE authid = '" . $steamid . "'");
$result_user_rewards = mysqli_query($con, "SELECT * FROM rpg_rewards WHERE authid = '" . $steamid . "'");
$result_rewards = mysqli_query($con, "SELECT * FROM rpg_rewards_web ORDER BY name + 0 DESC");
$row = mysqli_fetch_array($result_user);

$oSteamID = new SteamID($row['authid']);

if ($row)
{
	$url = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key={$site_steamkey}&steamids=" . $oSteamID->getSteamID64();
	$jsonInfo = json_decode(file_get_contents($url), true);
	$userAvatar = $jsonInfo['response']['players'][0]['avatarfull'];
}
else
	$userAvatar = "img/avatar_default.jpg";


if ($row['name'] == "")
		$GetName = "Unknown";
else
	$GetName = $row['name'];

// Calculate current rank position
while($users = mysqli_fetch_array($result_users))
{
	$getrank++;
	if ($users['authid'] == $steamid)
		break;
}

if ($allowlogin)
	$menu_position = 4;
else
	$menu_position = 2;

?>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>Player Profile :: <?php echo $site_name; ?></title>
		<meta name="description" content="<?php echo $site_name; ?> & Player Statistics">
		<link rel="stylesheet" href="css/pure-min.css">
		<link rel="stylesheet" href="css/style.css">
		<link rel="stylesheet" href="http://fonts.googleapis.com/css?family=Raleway:300%7cSource+Sans+Pro:400,700%7cSource+Code+Pro&amp;subset=latin,latin-ext">

		<script type="text/javascript" language="javascript" src="js/jquery.js"></script>
		<script type="text/javascript" language="javascript" src="js/jquery.dataTables.js"></script>
		<link rel="stylesheet" type="text/css" href="css/jquery.dataTables.css">
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
					<?php
					
						if (!$row)
							echo "This player does not exist.";
					?>
				</div>
				<div class="content">
					<div class="content-container">
						<?php
						echo "<img style=\"display:block;float: left;margin-right: 15px;width: 140px;\" alt=\"Avatar of {$GetName}\" title=\"Avatar of {$GetName}\" src=\"{$userAvatar}\">";
						echo "SteamID: <strong>{$row['authid']}</strong><br>";
						echo "SteamID64: <strong>{$oSteamID->getSteamID64()}</strong><br>";
						echo "<strong><a href='//steamcommunity.com/profiles/{$oSteamID->getSteamID64()}'>Steam Profile</a></strong>";
						?>
						<div style="width:100%;height:65px;"></div>
					</div>
					<div class="content-container">
						<?php
						echo "Rank Position: <strong>" . number_format( $getrank ) . "</strong><br>";
						echo "Prestige: <strong>{$row['prestige']}/10</strong><br>";
						echo "Medals: <strong>{$row['medals']}/15</strong><br>";
						echo "Level (Exp.): <strong>" . number_format( $row['lvl'] ) . " (" . number_format( $row['exp'] ) . ")</strong><br>";
						?>
					</div>
					<div class="content-container">
						<h3><?php echo $GetName; ?>'s Stats</h3>
						<p>Complete these challanges to earn EXP and medals!</p>
						<table class="pure-table pure-table-horizontal pure-table-striped">
							<thead>
								<tr>
									<th class="toprow">Value</th>
									<th class="toprow">Information</th>
								</tr>
							</thead>
							
							<tbody>
								<tr>
									<td>
										<?php echo $row['skill_sethp']; ?>
									</td>
									<td>
										Vitality
									</td>
								</tr>
								<tr>
									<td>
										<?php echo $row['skill_armor']; ?>
									</td>
									<td>
										Superior Armor
									</td>
								</tr>
								<tr>
									<td>
										<?php echo $row['skill_hp']; ?>
									</td>
									<td>
										Health Regeneration
									</td>
								</tr>
								<tr>
									<td>
										<?php echo $row['skill_setarmor']; ?>
									</td>
									<td>
										Nano Armor
									</td>
								</tr>
								<tr>
									<td>
										<?php echo $row['skill_ammo']; ?>
									</td>
									<td>
										The Magic Pocket
									</td>
								</tr>
								<tr>
									<td>
										<?php echo $row['skill_doublejump']; ?>
									</td>
									<td>
										Icarus Potion
									</td>
								</tr>
								<tr>
									<td>
										<?php echo $row['skill_weapon']; ?>
									</td>
									<td>
										A Gift From The Gods
									</td>
								</tr>
								<tr>
									<td>
										<?php echo $row['skill_aura']; ?>
									</td>
									<td>
										The Warrior's Battlecry
									</td>
								</tr>
								<tr>
									<td>
										<?php echo $row['skill_holyguard']; ?>
									</td>
									<td>
										Holy Armor
									</td>
								</tr>
							</tbody>
						</table>
					</div>
					<div class="content-container">
						<h3><?php echo $GetName; ?>'s Challenges</h3>
						<p>Complete these challenges to earn EXP and medals!</p>
						<table class="pure-table pure-table-horizontal pure-table-striped">
							<thead>
								<tr>
									<th>Name</th>
									<th>Description</th>
									<th>Completion</th>
								</tr>
							</thead>
							<tbody>
								<?php
								while($rewards = mysqli_fetch_array($result_user_rewards))
								{
									while($rows_reward = mysqli_fetch_array($result_rewards))
									{
										if ($rewards['reward'] != $rows_reward['reward'])
											continue;
								?>
								<tr>
									<td><?php echo $rows_reward['name']; ?></td>
									<td><?php echo $rows_reward['desc']; ?></td>
									<td><?php
										if ($rows_reward['value'] == $rewards['value'])
											echo "Completed.";
										else
											echo "{$rewards['value']}/{$rows_reward['value']}";
									?></td>
								</tr>
								<?php
										break;
									}
								}
								?>
							</tbody>
						</table>
					</div>
					<?php include('lib/footer.php'); ?>
				</div>
			</div>
		</div>
	</body>
</html>