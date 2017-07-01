/*
	Simply show and hide the tabs.
*/
$(".tab_about").on("click", function(e) {
	$(".toggletab_about").show();
	$(".toggletab_stats").hide();
	$(".toggletab_rewards").hide();
});
$(".tab_stats").on("click", function(e) {
	$(".toggletab_about").hide();
	$(".toggletab_stats").show();
	$(".toggletab_rewards").hide();
});
$(".tab_challenges").on("click", function(e) {
	$(".toggletab_about").hide();
	$(".toggletab_stats").hide();
	$(".toggletab_rewards").show();
});