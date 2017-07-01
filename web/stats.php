<?php
include_once('lib/config.php');
include('lib/steamid.php');

$menu_position = 2;

// Create connection
$con = mysqli_connect($mysql_host, $mysql_name, $mysql_pass, $mysql_db);

// Top10 Players
$result_users = mysqli_query($con, "SELECT * FROM {$mysql_table} ORDER BY prestige DESC, lvl + 0 DESC LIMIT 10");
$result_prestiges = mysqli_query($con, "SELECT * FROM {$mysql_table} ORDER BY prestige DESC, lvl + 0 DESC LIMIT 5");
$getrank = 0;

?>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>Statistics :: <?php echo $site_name; ?></title>
		<meta name="description" content="<?php echo $site_name; ?> :: Player Statistics">

		<!-- CSS -->
		<link rel="stylesheet" href="css/bootstrap.css">
		<link rel="stylesheet" href="css/bootstrap_extensions.css">
		<link rel="stylesheet" href="css/bootstrap_responsive.css">
		
		<link rel="stylesheet" href="css/main.css">
		<link rel="stylesheet" href="css/stats.css">
		<link rel="stylesheet" href="http://fonts.googleapis.com/css?family=Raleway:300%7cSource+Sans+Pro:400,700%7cSource+Code+Pro&amp;subset=latin,latin-ext">
		<link rel="stylesheet" type="text/css" href="css/jquery.dataTables.css">

		<!-- JS -->
		<script type="text/javascript" language="javascript" src="js/jquery.js"></script>
		<script type="text/javascript" language="javascript" src="js/jquery.dataTables.js"></script>
		<script type="text/javascript" src="js/progressbar.js"></script>
		<script src="js/stellar.js"></script>
		<script src="js/bootstrap.min.js"></script>
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
		
		<script type="text/javascript" language="javascript" class="init">
			$(document).ready(function() {
				$('#stats_table').dataTable( {
					"paging":   true,
					"ordering": false,
					"info":     true,
					"lengthMenu": [[10, 25, 35, 45], [10, 25, 35, 45]],
					stateSave: true,
					"processing": true,
					"serverSide": true,
					"ajax": "js/tables/users.php",
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
		<div class="menu">
			<div class="left nav">
				<?php include('lib/menu.php'); ?>
			</div>
		</div>
		<header class="node <?php echo $bgdrop; ?>" data-stellar-background-ratio="0.2" ></header>
		<div class="content">
			<div class="body">
				<div class="span" style="width: 50%;">
					<table id="stats_table" class="stat-table table table-striped table-bordered table-hover">
						<thead>
							<tr>
								<th class="toprow">Player</th>
								<th class="toprow">Level</th>
							</tr>
						</thead>
						
						<tfoot>
							<tr>
								<th class="toprow">Player</th>
								<th class="toprow">Level</th>
							</tr>
						</tfoot>
					</table>
				</div>
				<div class="span55" style="margin-left: 5%;margin-top: 2px;text-align: center;">
					<h3>Top 10 Players</h3>
					<table class="stat-table table table-striped table-bordered table-hover">
						<thead>
							<tr>
								<th class="toprow">Rank</th>
								<th class="toprow">Player</th>
								<th class="toprow">Level</th>
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
									<?php echo "<strong>" . $GetName . "</strong>"; ?>
								</td>
								<td>
									<?php
									echo number_format( $row['lvl'] );
									if ($row['prestige'] > 0)
										echo " (+{$row['prestige']})";
									?>
								</td>
							</tr>
							<?php
								}
							}
							?>
						</tbody>
					</table>
				</div>
				<div class="span55" style="margin-left: 5%;margin-top: 2px;text-align: center;">
					<h3>Top 5 Prestiged Players</h3>
					<table class="stat-table table table-striped table-bordered table-hover">
						<thead>
							<tr>
								<th class="toprow">Rank</th>
								<th class="toprow">Player</th>
								<th class="toprow">Prestige</th>
							</tr>
						</thead>
						
						<tbody>
						<?php
							// Reset
							$getrank = 0;
							while($row = mysqli_fetch_array($result_prestiges))
							{
								if ($row['prestige'] > 0)
								{
									if ($row['name'] == "")
										$GetName = "Unknown";
									else
										$GetName = $row['name'];
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
									<?php echo "<strong>" . $GetName . "</strong>"; ?>
								</td>
								<td style="text-align: center;">
									<?php
										echo $row['prestige'];
									?>
								</td>
							</tr>
							<?php
								}
							}
							?>
						</tbody>
					</table>
				</div>
				<div style="height: 200px;"></div>
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