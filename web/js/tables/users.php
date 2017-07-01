<?php
 
/*
 * DataTables example server-side processing script.
 *
 * Please note that this script is intentionally extremely simply to show how
 * server-side processing can be implemented, and probably shouldn't be used as
 * the basis for a large complex system. It is suitable for simple use cases as
 * for learning.
 *
 * See http://datatables.net/usage/server-side for full details on the server-
 * side processing requirements of DataTables.
 *
 * @license MIT - http://datatables.net/license_mit
 */
 
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Easy set variables
 */
include_once('../../lib/config.php');
 
// DB table to use
$table = $mysql_table;
 
// Table's primary key
$primaryKey = 'authid';
 
// Array of database columns which should be read and sent back to DataTables.
// The `db` parameter represents the column name in the database, while the `dt`
// parameter represents the DataTables column identifier. In this case simple
// indexes
$columns = array(
	array(
		'db' => 'prestige',
		'dt' => -2,
		'formatter' => function( $d, $row ) {
			return "";
		}
	),
	array(
		'db' => 'authid',
		'dt' => -1,
		'formatter' => function( $d, $row ) {
			return "";
		}
	),
	array(
		'db' => 'name',
		'dt' => 0,
		'formatter' => function( $d, $row ) {
			
			if ($row['name'] == "")
				$GetName = "Unknown";
			else
				$GetName = $row['name'];
			
			$oSteamURL = "profile.php?steamid=" . $row['authid'];
			return "<center><strong><a href='{$oSteamURL}'>" . $GetName . "</a></strong></center>";
		}
	),
	array(
		'db'		=> 'lvl',
		'dt'		=> 1,
		'formatter' => function( $d, $row ) {
			$text = '<center>'.number_format( $row['lvl'] );
			
			if ( $row['prestige'] > 0 )
				$text = $text." (+{$row['prestige']})";
			
			$text = $text."</center>";
			return $text;
		}
	),
);
 
// SQL server connection information
$sql_details = array(
	'user' => $mysql_name,
	'pass' => $mysql_pass,
	'db'   => $mysql_db,
	'host' => $mysql_host
);
 
 
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * If you just want to use the basic configuration for DataTables with PHP
 * server-side, there is no need to edit below this line.
 */
 
require( 'ssp.class.php' );
 
echo json_encode(
	SSP::simple( $_GET, $sql_details, $table, $primaryKey, $columns )
);