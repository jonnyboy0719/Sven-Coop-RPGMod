<?php

//==================================================
//==================================================
// SQL Setup

$mysql_host = "localhost";			// hostname
$mysql_db	= "sc_rpg";				// database
$mysql_name	= "sc_rpg";				// user
$mysql_pass = "sc_rpg";				// password
$mysql_table = "rpg_stats";			// table

//==================================================
//==================================================
// Site Setup

$site_name = "SC RPG Mod";
$site_name_short = "SC RPG";
$site_friendlyurl = false;		// Only toggle this on if you have Mod-Rewerite module installed!
$site_baseurl = "localhost/sc_stats";
$site_steamkey = "946923BA2F3BE49EF80D667C4C993412";
$allowlogin = false;			// Can the user login with their steam account? (NOT YET IMPLEMENTED)

if ($site_friendlyurl)
{
	$link_rewards = "rewards";
	$link_stats = "stats";
	$link_login = "login";
	$link_profile = "profile";
	$link_prestige = "prestige";
	$link_gifts = "gifts";
}
else
{
	$link_rewards = "rewards.php";
	$link_stats = "stats.php";
	$link_login = "login.php";
	$link_profile = "profile.php";
	$link_prestige = "prestige.php";
	$link_gifts = "gifts.php";
}
?>