<?php
include_once('lib/config.php');
include('lib/steamid.php');

$menu_position = 0.1;

?>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>Prestiges :: <?php echo $site_name; ?></title>
		<meta name="description" content="<?php echo $site_name; ?> :: Prestiges">

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
				<div class="bs-callout bs-callout-info">
					<h4>Information</h4>
					<p>You can only prestige when you hit level 800, but when you do, you will earn some neat rewards. You will also get a permenant XP Booster. This Booster will upgrade each time you prestige!</p>
					<p>Remember, if the item is marked as (OnSpawn), it means it will only be given when you spawn, and not right away.</p>
				</div>
				<table class="stat-table table table-striped table-bordered table-hover">
					<thead>
						<tr>
							<th>Level</th>
							<th>Reward</th>
							<th>Description</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>1</td>
							<td>Key Blade</td>
							<td>It's a bloody key.</td>
						</tr>
						<tr>
							<td>2</td>
							<td>Long Jump</td>
							<td>You will be able to jump further distances! (Crouch+Jump)</td>
						</tr>
						<tr>
							<td>3</td>
							<td>Golden Revolver</td>
							<td>Isn't it shiny?</td>
						</tr>
						<tr>
							<td>4</td>
							<td>Grease gun</td>
							<td>A Grease gun from the second world war.</td>
						</tr>
						<tr>
							<td>5</td>
							<td>M14</td>
							<td>A semi automatic Sniper Rifle.</td>
						</tr>
						<tr>
							<td>6</td>
							<td>Double Barrel Shotgun</td>
							<td>Double the barrel, double the damage!</td>
						</tr>
						<tr>
							<td>7</td>
							<td>Shotgun Grenade</td>
							<td>This isn't a normal shotgun, it shoots grenades instead.</td>
						</tr>
						<tr>
							<td>8</td>
							<td>Tesla Gun</td>
							<td>Hold it down for more power!</td>
						</tr>
						<tr>
							<td>9</td>
							<td>.500 Revolver</td>
							<td>One shot, one kill. (probably)</td>
						</tr>
						<tr>
							<td>10</td>
							<td>HMG</td>
							<td>It's deadlier than the minigun.</td>
						</tr>
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