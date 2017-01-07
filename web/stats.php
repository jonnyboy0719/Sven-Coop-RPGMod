<?php
include_once('lib/config.php');
include('lib/steamid.php');

// Create connection
$con = mysqli_connect($mysql_host, $mysql_name, $mysql_pass, $mysql_db);
$getrank = 0;

// Check connection
if (mysqli_connect_errno())
	echo "Failed to connect to MySQLi: " . mysqli_connect_error();

$result_users = mysqli_query($con, "SELECT * FROM {$mysql_table} ORDER BY prestige DESC, lvl + 0 DESC");

$menu_position = 2;

?>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>Player Statistics :: <?php echo $site_name; ?></title>
		<meta name="description" content="<?php echo $site_name; ?> & Player Statistics">
		<link rel="stylesheet" href="css/pure-min.css">
		<link rel="stylesheet" href="css/style.css">
		<link rel="stylesheet" href="http://fonts.googleapis.com/css?family=Raleway:300%7cSource+Sans+Pro:400,700%7cSource+Code+Pro&amp;subset=latin,latin-ext">

		<script type="text/javascript" language="javascript" src="js/jquery.js"></script>
		<script type="text/javascript" language="javascript" src="js/jquery.dataTables.js"></script>
		<link rel="stylesheet" type="text/css" href="css/jquery.dataTables.css">

		<script type="text/javascript" language="javascript" class="init">
			$(document).ready(function() {
				$('#stats_table').dataTable( {
					"paging":   true,
					"ordering": false,
					"info":     true,
					"lengthMenu": [[10, 25, 35, 45], [10, 25, 35, 45]],
					stateSave: true,
					"language": {
						"lengthMenu": "Display _MENU_ users per page",
						"zeroRecords": "Nothing found - sorry",
						"info": "Showing page _PAGE_ of _PAGES_",
						"infoEmpty": "No users available",
						"infoFiltered": "(filtered from _MAX_ total users)"
					}
				} );
			} );
		</script>
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
						<table id="stats_table" class="pure-table pure-table-horizontal pure-table-striped">
							<thead>
								<tr>
									<th class="toprow">Rank</th>
									<th class="toprow">Player</th>
									<th class="toprow">Level</th>
									<th class="toprow">Exp.</th>
								</tr>
							</thead>
							
							<tbody>
							<?php
								while($row = mysqli_fetch_array($result_users))
								{
									if ($row['lvl'] > 0)
									{
										if ($row['name'] == "")
											$GetName = "Unknown";
										else
											$GetName = $row['name'];
										
										$oSteamID = new SteamID($row['authid']);
										
										if ($site_friendlyurl)
											$oSteamURL = "profile/" . $row['authid'];
										else
											$oSteamURL = "profile.php?steamid=" . $row['authid'];
								?>
								<tr>
									<td>
										<?php
										// Everything gets listed, and orginized with the max EXP. So we don't really have todo anything here.
										$getrank++;
										echo number_format( $getrank );
										?>
									</td>
									<td title="<?php echo $GetName; ?>">
										<?php echo "<strong><a href='{$oSteamURL}'>" . $GetName . "</a></strong>"; ?>
									</td>
									<td>
										<?php
										echo number_format( $row['lvl'] );
										if ($row['prestige'] > 0)
											echo " (+{$row['prestige']})";
										?>
									</td>
									<td>
										<?php echo number_format( $row['exp'] ); ?>
									</td>
								</tr>
								<?php
									}
								}
								?>
							</tbody>
							
							<tfoot>
								<tr>
									<th class="toprow">Rank</th>
									<th class="toprow">Player</th>
									<th class="toprow">Level</th>
									<th class="toprow">Exp.</th>
								</tr>
							</tfoot>
						</table>
					</div>
					<?php include('lib/footer.php'); ?>
				</div>
			</div>
		</div>
	</body>
</html>