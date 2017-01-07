<?php
include_once('lib/config.php');
include('lib/steamid.php');

// Create connection
$con = mysqli_connect($mysql_host, $mysql_name, $mysql_pass, $mysql_db);
$getrank = 0;

// Check connection
if (mysqli_connect_errno())
	echo "Failed to connect to MySQLi: " . mysqli_connect_error();

$result_rewards = mysqli_query($con, "SELECT * FROM rpg_rewards_web ORDER BY name + 0 DESC");

$menu_position = 1;

?>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>Challenges :: <?php echo $site_name; ?></title>
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
						<h3>Challenges</h3>
						<p>Complete these challanges to earn EXP and medals!</p>
						<table class="pure-table pure-table-horizontal pure-table-striped">
							<thead>
								<tr>
									<th>Name</th>
									<th>Description</th>
								</tr>
							</thead>
							<tbody>
								<?php
								while($row = mysqli_fetch_array($result_rewards))
								{
								?>
								<tr>
									<td><?php echo $row['name']; ?></td>
									<td><?php echo $row['desc']; ?></td>
								</tr>
								<?php } ?>
							</tbody>
						</table>
					</div>
					<?php include('lib/footer.php'); ?>
				</div>
			</div>
		</div>
	</body>
</html>