<?php
include_once('lib/config.php');
include('lib/steamid.php');

// Create connection
$con = mysqli_connect($mysql_host, $mysql_name, $mysql_pass, $mysql_db);
$con_mybb = mysqli_connect($mysql_host, $mysql_name, $mysql_pass, "dark4557_gmod");
$getrank_cnt = true;
$getrank = 0;
$totalranks = 0;
$steamid = 0;

// Check connection
if (mysqli_connect_errno())
	echo "Failed to connect to MySQLi: " . mysqli_connect_error();

if ( !empty($_GET['steamid']) )
	$steamid = htmlspecialchars($_GET['steamid']);

$result_users = mysqli_query($con, "SELECT * FROM {$mysql_table} ORDER BY prestige DESC, lvl + 0 DESC");
$result_user = mysqli_query($con, "SELECT * FROM {$mysql_table} WHERE authid = '" . $steamid . "'");
$result_rewards = mysqli_query($con, "SELECT * FROM rpg_rewards_web ORDER BY name + 0 DESC");
$result_rewards_check = mysqli_query($con, "SELECT * FROM rpg_rewards_web ORDER BY name + 0 DESC");
$result_medals = mysqli_query($con, "SELECT * FROM rpg_rewards_web");
$row = mysqli_fetch_array($result_user);

$oSteamID = new SteamID($row['authid']);
$SteamID64 = "profile_not_found";

if ($row)
{
	$url = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key={$site_steamkey}&steamids=" . $oSteamID->getSteamID64();
	$jsonInfo = json_decode(file_get_contents($url), true);
	$userAvatar = $jsonInfo['response']['players'][0]['avatarfull'];
	$SteamID64 = $jsonInfo['response']['players'][0]['steamid'];

	$result_rank = mysqli_query($con, "SELECT * FROM rpg_ranks WHERE lvl <= (". $row['lvl'] . ") and lvl ORDER BY abs(lvl - ". $row['lvl'] . ") LIMIT 1");
	$rowrank = mysqli_fetch_array($result_rank);

}
else
	$userAvatar = "img/avatar_default.jpg";

// Check MyBB user
$result_mybb = mysqli_query($con_mybb, "SELECT * FROM mybb_users WHERE steamid = '" . $SteamID64 . "'");
$rowmybb = mysqli_fetch_array($result_mybb);

if ($row['name'] == "")
		$GetName = "Unknown";
else
	$GetName = $row['name'];

// Calculate current rank position
while($users = mysqli_fetch_array($result_users))
{
	// This will grab the total ranks
	$totalranks++;

	// Only count our rnak, if we haven't found this steamid!
	if ( $getrank_cnt )
		$getrank++;

	// User found, lets not count getrank anymore...
	if ($users['authid'] == $steamid)
		$getrank_cnt = false;
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
		<title><?php echo $GetName; ?> Profile :: <?php echo $site_name; ?></title>
		<meta name="description" content="<?php echo $site_name; ?> :: Player Statistics">

		<!-- CSS -->
		<link rel="stylesheet" href="css/main.css">
		<link rel="stylesheet" href="css/stats.css">
		<link rel="stylesheet" href="http://fonts.googleapis.com/css?family=Raleway:300%7cSource+Sans+Pro:400,700%7cSource+Code+Pro&amp;subset=latin,latin-ext">
		<link rel="stylesheet" type="text/css" href="css/jquery.dataTables.css">

		<!-- JS -->
		<script type="text/javascript" language="javascript" src="js/jquery.js"></script>
		<script type="text/javascript" language="javascript" src="js/jquery.dataTables.js"></script>
		<script type="text/javascript" src="js/progressbar.js"></script>
		<script src="js/stellar.js"></script>
		<script>
		$(function(){
			$.stellar({
				horizontalScrolling: false,
				verticalOffset: 40
			});
			$('a[href*=#]:not([href=#])').click(function() {
				if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') && location.hostname == this.hostname) {

					var target = $(this.hash);
					target = target.length ? target : $('[name=' + this.hash.slice(1) +']');

					if (target.length) {
					$('html,body').animate( {
						scrollTop: target.offset().top
						}, 1000);
						return false;
					}
				}
			});
		});
		</script>
	</head>
	<body>
		<div class="menu">
			<div class="span6 left nav">
				<?php include('lib/menu.php'); ?>
			</div>
		</div>
		<header class="node <?php echo $bgdrop; ?>" data-stellar-background-ratio="0.2" ></header>
		<div class="content">
			<div class="header">
				<?php
				echo "<div id=\"expcircle\" style=\"width: 188px;height: 188px;position: absolute;left: -1px;bottom: -1px;\"><span style=\"position: inherit;width: 100%;text-align: center;top: 70%;color: rgb(55,155,255);font-weight: bold;text-shadow: 1px 1px 5px black,-1px -1px 5px black,0px 0px 5px black,0px -1px 5px black,-1px 0px 5px black;\">level " . number_format( $row['lvl'] ) . "</span></div><img class=\"avatar\" alt=\"Avatar of {$GetName}\" title=\"Avatar of {$GetName}\" src=\"{$userAvatar}\">"
				. "<div class=\"clear_left\" ></div>" .
				"<div class=\"details\">" .
				"<div class=\"name\"><strong>{$GetName}</strong></div>";
				
				echo "<script>
					var bar = new ProgressBar.Circle(expcircle, {
						strokeWidth: 7,
						color: '#ff0000',
						trailColor: '#060606',
						trailWidth: 7,
						easing: 'easeInOut',
						duration: 1400,
						svgStyle: null,
						text: {
							value: '',
							alignToBottom: false
						},
						from: {color: '#ff0000'},
						to: {color: '#4dff00'},
						// Set default step function for all animate calls
						step: (state, bar) => {
							bar.path.setAttribute('stroke', state.color);
						}
					});";
					
					if ( $row['exp'] > 0 && $row['expmax'] > 0 )
						echo "bar.animate(" . $row['exp'] / $row['expmax'] . ");";
					else
						echo "bar.animate(0.0);";
				echo"</script>";
				
				// Show nice bg for the rank, if 10 or less
				if ( $getrank <= 3 )
					echo "<div class=\"pos\" id=\"rank-$getrank\" style=\"text-align: center;\" >" . number_format( $getrank ) . "</div>";
				elseif ( $getrank <= 10 )
					echo "<div class=\"pos\" id=\"rank-def\" style=\"text-align: center;\" >" . number_format( $getrank ) . "</div>";

				echo "<div class=\"steamid\"><strong>{$row['authid']}</strong></div>" .
				"</div>";
				?>
			</div>

			<!-- Clear all floats -->
			<div class="clear_both"></div>

			<!-- Our profile information etc... -->
			<div class="body">
				<div class="profile_tabs" style="width: 380px;">
					<div id="info_tab" class="tab_about" >About</div>
					<div id="info_tab" class="tab_stats" >Stats</div>
					<div id="info_tab" class="tab_challenges" >Challenges</div>
				</div>
				<?php
					// If we found some useful information
					if ( $rowmybb )
					{
						// Setup default value
						$xpos = 30;
						$ypos = -200;
						$IsDonor = false;
						
						// Lets check if we are a donator.
						if ($rowmybb['displaygroup'] == "11"
							|| $rowmybb['usergroup'] == "11"
							|| $row['settings_donated'] == 1
							|| strpos($rowmybb['additionalgroups'], '11') !== false )
							{
								$IsDonor = true;
								echo "<img style=\"display:block;float: left;margin-right: -150px;width: 140px;top: {$ypos}px;position: relative;left: {$xpos}px;\" alt=\"Donator\" title=\"Donator\" src=\"//theafterlife.eu/img/ranks/donor.png\">";
							}
						// Lets check if we are a moderator.
						if ($rowmybb['displaygroup'] == "8"
							|| $rowmybb['usergroup'] == "8"
							|| strpos($rowmybb['additionalgroups'], '8') !== false )
							{
								if ( $IsDonor )
								{
									$xpos = 30;
									$ypos = -175;
								}

								echo "<img style=\"display:block;float: left;margin-right: -150px;width: 140px;top: {$ypos}px;position: relative;left: {$xpos}px;\" alt=\"Moderator\" title=\"Moderator\" src=\"//theafterlife.eu/img/ranks/sc_mod.png\">";
							}
						// Lets check if we are a owner.
						if ($rowmybb['displaygroup'] == "4"
							|| $rowmybb['usergroup'] == "4"
							|| strpos($rowmybb['additionalgroups'], '4') !== false )
							{
								if ( $IsDonor )
								{
									$xpos = 30;
									$ypos = -175;
								}

								echo "<img style=\"display:block;float: left;margin-right: -150px;width: 140px;top: {$ypos}px;position: relative;left: {$xpos}px;\" alt=\"Administrator\" title=\"Administrator\" src=\"//theafterlife.eu/img/ranks/admin.png\">";
							}
					}
					else
					{
						$xpos = 30;
						$ypos = -200;

						if ($row['settings_donated'] == 1 )
							echo "<br><img style=\"display:block;float: left;margin-right: -150px;width: 140px;top: {$ypos}px;position: relative;left: {$xpos}px;\" alt=\"Donator\" title=\"Donator\" src=\"//theafterlife.eu/img/ranks/donor.png\">";
					}	
				?>
				<div class="toggletab_about" style="display: block;">
					<?php
						// Clear the mess
						echo '<div class="clear_both"></div>';
						
						$maxmedals = 0;
						// Calculate the max medals
						while($medals = mysqli_fetch_array($result_medals))
						{
							$maxmedals = $maxmedals + $medals['medals'];
						}
						
						$challenges_max = 0;
						$challenges_have = 0;
						while($grab_rewards = mysqli_fetch_array($result_rewards_check))
						{
							$challenges_max++;
							$result_user_rewards = mysqli_query($con, "SELECT * FROM rpg_rewards WHERE authid = '" . $steamid . "' AND reward = '" . $grab_rewards['reward'] . "'");
							$rows_reward = mysqli_fetch_array($result_user_rewards);
								if ( $rows_reward['value'] == $grab_rewards['value'] )
								{
									$challenges_have++;
								}
						}
						
						echo '
						<div class="InfoDiv" >
							<h2>Steam</h2>
							<p>SteamID: <strong>' . $row['authid'] . '</strong></p>
							<p>SteamID64: <strong>' . $oSteamID->getSteamID64() . '</strong></p>
							<br>
							<h2>Linked Accounts</h2>';
							if ( $rowmybb )
								echo "<strong><a href='//theafterlife.eu/member.php?action=profile&uid={$rowmybb['uid']}'>Forum Profile</a></strong><br>";
							echo '<strong><a href="//steamcommunity.com/profiles/' . $oSteamID->getSteamID64(). '">Steam Profile</a></strong>
						</div>
						<div class="InfoDiv" >
							<p>Title: <strong>' . $rowrank['title'] . '</strong></p>
							<p>Rank Position: <strong>' . number_format( $getrank ) . '</strong> of <strong>' . number_format( $totalranks ) . '</strong></p>
							<p>Prestige: <strong>' . $row['prestige'] . '/10</strong></p>
							<p>Medals: <strong>' . $row['medals'] . '/' . $maxmedals . '</strong></p>
							<p>Completed Challenges: <strong>' . $challenges_have . '/' . $challenges_max . '</strong></p>
						</div>';
					?>

					<!-- Clear all floats -->
					<div class="clear_both"></div>

				</div>
				<div class="toggletab_stats" style="display: none;">
				<?php
					echo '
					<div class="stats-base">
						<div class="stats-img"><img src="img/stat/stat1.jpg" /></div>
						<div class="stats-desc-base">
							<div class="stats-desc">
							<h3>Vitality</h3>
							<h5>Grants you more health points</h5>
							<div class="stats-progress-text">' . $row['skill_sethp'] . ' / ' . $stat_Health . '</div>
							<div class="stats-progress-bar">
								<img src="img/stat/bar.gif" style="position: relative;bottom: 5px;" height="14" width="' . $row['skill_sethp'] / $stat_Health * 100 . '%" > 
							</div>
							</div>
						</div>
					</div>
					<div class="stats-base">
						<div class="stats-img"><img src="img/stat/stat2.jpg" /></div>
						<div class="stats-desc-base">
							<div class="stats-desc">
							<h3>Superior Armor</h3>
							<h5>Grants you more armor points</h5>
							<div class="stats-progress-text">' . $row['skill_setarmor'] . ' / ' . $stat_Armor . '</div>
							<div class="stats-progress-bar">
								<img src="img/stat/bar.gif" style="position: relative;bottom: 5px;" height="14" width="' . $row['skill_setarmor'] / $stat_Armor * 100 . '%" > 
							</div>
							</div>
						</div>
					</div>
					<div class="clear_both"></div>
					<div class="stats-base">
						<div class="stats-img"><img src="img/stat/stat3.jpg" /></div>
						<div class="stats-desc-base">
							<div class="stats-desc">
							<h3>Health Regeneration</h3>
							<h5>Regenerates your health</h5>
							<div class="stats-progress-text">' . $row['skill_hp'] . ' / ' . $stat_HealthR . '</div>
							<div class="stats-progress-bar">
								<img src="img/stat/bar.gif" style="position: relative;bottom: 5px;" height="14" width="' . $row['skill_hp'] / $stat_HealthR * 100 . '%" > 
							</div>
							</div>
						</div>
					</div>
					<div class="stats-base">
						<div class="stats-img"><img src="img/stat/stat4.jpg" /></div>
						<div class="stats-desc-base">
							<div class="stats-desc">
							<h3>Nano Armor</h3>
							<h5>Regenerates your armor</h5>
							<div class="stats-progress-text">' . $row['skill_armor'] . ' / ' . $stat_ArmorR . '</div>
							<div class="stats-progress-bar">
								<img src="img/stat/bar.gif" style="position: relative;bottom: 5px;" height="14" width="' . $row['skill_armor'] / $stat_ArmorR * 100 . '%" > 
							</div>
							</div>
						</div>
					</div>
					<div class="clear_both"></div>
					<div class="stats-base">
						<div class="stats-img"><img src="img/stat/stat5.jpg" /></div>
						<div class="stats-desc-base">
							<div class="stats-desc">
							<h3>The Magic Pocket</h3>
							<h5>A magic pocket that genereates ammo for you</h5>
							<div class="stats-progress-text">' . $row['skill_ammo'] . ' / ' . $stat_Ammo . '</div>
							<div class="stats-progress-bar">
								<img src="img/stat/bar.gif" style="position: relative;bottom: 5px;" height="14" width="' . $row['skill_ammo'] / $stat_Ammo * 100 . '%" > 
							</div>
							</div>
						</div>
					</div>
					<div class="stats-base">
						<div class="stats-img"><img src="img/stat/stat6.jpg" /></div>
						<div class="stats-desc-base">
							<div class="stats-desc">
							<h3>Icarus Potion</h3>
							<h5>Grants you additional jumps</h5>
							<div class="stats-progress-text">' . $row['skill_doublejump'] . ' / ' . $stat_Jumps . '</div>
							<div class="stats-progress-bar">
								<img src="img/stat/bar.gif" style="position: relative;bottom: 5px;" height="14" width="' . $row['skill_doublejump'] / $stat_Jumps * 100 . '%" > 
							</div>
							</div>
						</div>
					</div>
					<div class="clear_both"></div>
					<div class="stats-base">
						<div class="stats-img"><img src="img/stat/stat7.jpg" /></div>
						<div class="stats-desc-base">
							<div class="stats-desc">
							<h3>A Gift From The Gods</h3>
							<h5>The gods grant you a random weapon at times</h5>
							<div class="stats-progress-text">' . $row['skill_weapon'] . ' / ' . $stat_Gifts . '</div>
							<div class="stats-progress-bar">
								<img src="img/stat/bar.gif" style="position: relative;bottom: 5px;" height="14" width="' . $row['skill_weapon'] / $stat_Gifts * 100 . '%" > 
							</div>
							</div>
						</div>
					</div>
					<div class="stats-base">
						<div class="stats-img"><img src="img/stat/stat8.jpg" /></div>
						<div class="stats-desc-base">
							<div class="stats-desc">
							<h3>The Warrior\'s Battlecry</h3>
							<h5>Ability to buff you and your teammates</h5>
							<div class="stats-progress-text">' . $row['skill_aura'] . ' / ' . $stat_Aura . '</div>
							<div class="stats-progress-bar">
								<img src="img/stat/bar.gif" style="position: relative;bottom: 5px;" height="14" width="' . $row['skill_aura'] / $stat_Aura * 100 . '%" > 
							</div>
							</div>
						</div>
					</div>
					<div class="clear_both"></div>
					<div class="stats-base">
						<div class="stats-img"><img src="img/stat/stat9.jpg" /></div>
						<div class="stats-desc-base">
							<div class="stats-desc">
							<h3>Holy Armor</h3>
							<h5>Ability to become invincible for a short period</h5>
							<div class="stats-progress-text">' . $row['skill_holyguard'] . ' / ' . $stat_HGuard . '</div>
							<div class="stats-progress-bar">
								<img src="img/stat/bar.gif" style="position: relative;bottom: 5px;" height="14" width="' . $row['skill_holyguard'] / $stat_HGuard * 100 . '%" > 
							</div>
							</div>
						</div>
					</div>
					<div class="clear_both"></div>';
				?>
				</div>
				<div class="toggletab_rewards" style="display: none;">
				<?php
				$rewardstatus = 0;
				while($rewards = mysqli_fetch_array($result_rewards))
				{
					$result_user_rewards = mysqli_query($con, "SELECT * FROM rpg_rewards WHERE authid = '" . $steamid . "' AND reward = '" . $rewards['reward'] . "'");
					$rows_reward = mysqli_fetch_array($result_user_rewards);
					
					$image = "default";
					
					if ( file_exists( 'img/reward/' . $rewards['reward'] . '.jpg' ) )
						$image = $rewards['reward'];
					
					$currentprogress = $rows_reward['value'];
					
					if ( empty($currentprogress) )
						$currentprogress = 0;
					
					echo '<div class="stats-base">
						<div class="stats-img"><img src="img/reward/' . $image . '.jpg" /></div>
						<div class="stats-desc-base">
							<div class="stats-desc">
							<h3>' . $rewards['name'] . '</h3>
							<h5>' . $rewards['desc'] . '</h5>
							<div class="stats-progress-text">' . $currentprogress . ' / ' . $rewards['value'] . '</div>
							<div class="stats-progress-bar">
								<img src="img/stat/bar.gif" style="position: relative;bottom: 5px;" height="14" width="' . $currentprogress / $rewards['value'] * 100 . '%" > 
							</div>
							</div>
						</div>
					</div>';
					
					$rewardstatus++;
					
					if ( $rewardstatus == 2)
					{
						echo '<div class="clear_both"></div>';
						$rewardstatus = 0;
					}
				}
				?>
				<div style="height: 200px;"></div>
				</div>
			</div>

			<!-- Clear all floats -->
			<div class="clear_both"></div>

		</div>

		<!-- Clear all floats -->
		<div class="clear_both"></div>

		<?php include('lib/footer.php'); ?>

		<!-- JS, loads after the content etc... -->
		<script src="js/profile.js"></script>
		<script src="js/blurify.js"></script>
		<script>
			(function () {
				blurify({
					images: document.querySelectorAll('.node'),
					blur: 6,
					mode: 'auto',
				});
			})();
		</script>
	</body>
</html>