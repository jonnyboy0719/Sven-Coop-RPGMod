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
$site_steamkey = "";

$bgdrop = "";
switch( rand(0, 3) )
{
	default:
	case 0:
		$bgdrop = "bg_drop1";
	break;
	
	case 1:
		$bgdrop = "bg_drop2";
	break;
	
	case 2:
		$bgdrop = "bg_drop3";
	break;
	
	case 3:
		$bgdrop = "bg_drop4";
	break;
}

// Stat values (MUST be the same as sc_rpg.sma!)
$stat_Health			= 400;
$stat_HealthR			= 50;
$stat_Armor				= 210;
$stat_ArmorR			= 55;
$stat_Ammo				= 30;
$stat_Jumps				= 5;
$stat_Gifts				= 10;
$stat_Aura				= 20;
$stat_HGuard			= 20;
