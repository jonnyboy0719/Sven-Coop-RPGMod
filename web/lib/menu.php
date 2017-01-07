<li class="menu-item-divided <?php echo $menu_position == 0 ? "pure-menu-selected" : ""; ?>"><a title="Info" href="index.php">Info</a></li>
						<li class="menu-item-divided <?php echo $menu_position == 0.1 ? "pure-menu-selected" : ""; ?>"><a title="Prestiges" href="<?php echo $link_prestige; ?>">Prestiges</a></li>
						<li class="menu-item-divided <?php echo $menu_position == 0.2 ? "pure-menu-selected" : ""; ?>"><a title="Gift from the gods" href="<?php echo $link_gifts; ?>">Gift from the gods</a></li>
						<li class="menu-item-divided <?php echo $menu_position == 1 ? "pure-menu-selected" : ""; ?>"><a title="Challenges" href="<?php echo $link_rewards; ?>">Challenges</a></li>
						<li class="menu-item-divided <?php echo $menu_position == 2 ? "pure-menu-selected" : ""; ?>"><a title="Stats" href="<?php echo $link_stats; ?>">Stats</a></li>
<?php if ($allowlogin) { ?>
						<li class="menu-item-divided"><a title="Login" href="<?php echo $link_login; ?>">Login</a></li>
						<li class="menu-item-divided <?php echo $menu_position == 4 ? "pure-menu-selected" : ""; ?>"><a title="Login" href="<?php echo $link_profile; ?>">Profile</a></li>
<?php } ?>