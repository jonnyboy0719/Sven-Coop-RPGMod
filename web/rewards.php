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
			<div class="left nav">
				<?php include('lib/menu.php'); ?>
			</div>
		</div>
		<header class="node <?php echo $bgdrop; ?>" data-stellar-background-ratio="0.2" ></header>
		<div class="content">
			<div class="body">
				<?php
				$rewardstatus = 0;
				while($rewards = mysqli_fetch_array($result_rewards))
				{
					$image = "default";
					
					if ( file_exists( 'img/reward/' . $rewards['reward'] . '.jpg' ) )
						$image = $rewards['reward'];
					
					echo '<div class="stats-base">
						<div class="stats-img"><img src="img/reward/' . $image . '.jpg" /></div>
						<div class="stats-desc-base">
							<div class="stats-desc">
							<h3>' . $rewards['name'] . '</h3>
							<h5>' . $rewards['desc'] . '</h5>
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