<?php
include_once('lib/config.php');
include('lib/steamid.php');

// Create connection
$con = mysqli_connect($mysql_host, $mysql_name, $mysql_pass, $mysql_db);

// Check connection
if (mysqli_connect_errno())
	echo "Failed to connect to MySQLi: " . mysqli_connect_error();

$result_gifts = mysqli_query($con, "SELECT * FROM rpg_rewards_weapons ORDER BY rarity desc");

$menu_position = 0.2;

?>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>Gifts From the Gods :: <?php echo $site_name; ?></title>
		<meta name="description" content="<?php echo $site_name; ?> :: Gifts From the Gods">

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
		<link rel="stylesheet" type="text/css" href="css/jquery.dataTables.css">
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

		<script type="text/javascript" language="javascript" class="init">
			$(document).ready(function() {
				$('#gifts_table').dataTable( {
					"paging":   true,
					"ordering": true,
					"info":     true,
					"lengthMenu": [[10, 25, 35, 45], [10, 25, 35, 45]],
					stateSave: true,
					"language": {
						"lengthMenu": "Display _MENU_ weapons per page",
						"zeroRecords": "Nothing found - sorry",
						"info": "Showing page _PAGE_ of _PAGES_",
						"infoEmpty": "No weapons available",
						"infoFiltered": "(filtered from _MAX_ total weapons)"
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
				<div class="bs-callout bs-callout-info">
					<h4>Information</h4>
					<p>The higher your level is, the more, and better weapons will you obtain!</p>
				</div>
				<table id="gifts_table" class="stat-table table table-striped table-bordered table-hover">
					<thead>
						<tr>
							<th>Level</th>
							<th>Reward</th>
							<th>Type</th>
						</tr>
					</thead>
					<tbody>
					<?php
						while($row = mysqli_fetch_array($result_gifts))
						{
						?>
						<tr>
							<td>
								<?php echo $row['lvl']; ?>
							</td>
							<td>
								<?php echo $row['name']; ?>
							</td>
							<td>
								<?php
									$result = "";
									
									switch ( $row['rarity'] )
									{
										case 0:
											$result = '<span style="color:whitesmoke">Common</span>';
										break;
										
										case 1:
											$result = '<span style="color:green">Un-Common</span>';
										break;
										
										case 2:
											$result = '<span style="color:orange">Rare</span>';
										break;
										
										case 3:
											$result = '<span style="color:purple">Super Rare</span>';
										break;
										
										case 4:
											$result = '<span style="color:red">Legendary</span>';
										break;
										
										case 5:
											$result = '<span style="color:cyan">Mythical</span>';
										break;
										
										default:
											$result = '<span style="color:whitesmoke">Unknown Rarity</span>';
										break;
										
									}
									
									echo $result;
								?>
							</td>
						</tr>
						<?php
						}
					?>
					</tbody>
				</table>
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