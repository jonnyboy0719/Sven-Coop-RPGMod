<?php
include_once('lib/config.php');
include('lib/steamid.php');

$menu_position = 0;

?>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>Index :: <?php echo $site_name; ?></title>
		<meta name="description" content="<?php echo $site_name; ?> :: About Page">

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
				<div class="ibox">
					<iframe style="float: left;margin-right: 15px;" src="http://cache.gametracker.com/components/html0/?host=31.186.250.26:27015&bgColor=060606&fontColor=F9F7F7&titleBgColor=060606&titleColor=FF4500&borderColor=555555&linkColor=00FFC1&borderLinkColor=060606&showMap=1&currentPlayersHeight=100&showCurrPlayers=1&topPlayersHeight=100&showTopPlayers=1&showBlogs=0&width=240" frameborder="0" scrolling="no" width="240" height="536"></iframe>
					<h3>Server Details</h3>
					<p>
						Location: <strong>Europe, Frankfurt</strong><br>
						Max Slots: <strong>20</strong><br>
						IP: <strong>31.186.250.26</strong><br>
						Port: <strong>27015</strong><br>
						<strong><a href="steam://connect/31.186.250.26:27015">Join via Steam</a></strong>
					</p>
				</div>
				<div class="ibox" style="float: right">
					<h3>Join our Community Today!</h3>
					<p>
						By <a href="http://theafterlife.eu/member.php?action=register" target="_blank">joining</a> our community today, you will gain access to *Community only items, and you will also gain some medals by doing so!
						<br><br>
						*After joining the community, you will need to link your Steam with your profile, more information can be found on our thread "<a href="http://theafterlife.eu/showthread.php?tid=17" target="_blank">Steam Integration</a>".
					</p>
					<br>
					<h3>Chat and Console Commands</h3>
					<p>
						We have moved all our chat and console commands over to our community forums, so its easier to find! You can find the thread <a href="http://theafterlife.eu/showthread.php?tid=47" target="_blank">right here</a>!
					</p>
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