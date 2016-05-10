//=============================================================================
//
// This plugin is using BB Stats and BDEF Stats as a base, so you will see some leftover codes here and there.
//
//=============================================================================

//------------------
//	Include Files
//------------------

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <geoip>
#include <fakemeta>
#include <sqlx>
#include <fun>
#include <sc_rpg_api>

#include <sqlvault>
#include <sqlvault_ex>

//------------------
//	Defines
//------------------

// Defined Sounds
#define SND_LVLUP					"sound/sc_rpg/levelup.wav"
#define SND_READY					"sound/sc_rpg/ready.wav"
#define SND_AURA01					"sound/sc_rpg/bttlcry01.wav"
#define SND_AURA02					"sound/sc_rpg/bttlcry02.wav"
#define SND_AURA03					"sound/sc_rpg/bttlcry03.wav"
#define SND_HOLYGUARD				"sound/sc_rpg/harmor.wav"
#define SND_HOLYWEP					"sound/sc_rpg/wepdrop.wav"
#define SND_JUMP					"sound/sc_rpg/jump.wav"
#define SND_JUMP_LAND				"sound/sc_rpg/jump_land.wav"

// Precache Sounds
#define SND_LVLUP_CACHE				"sc_rpg/levelup.wav"
#define SND_READY_CACHE				"sc_rpg/ready.wav"
#define SND_AURA01_CACHE			"sc_rpg/bttlcry01.wav"
#define SND_AURA02_CACHE			"sc_rpg/bttlcry02.wav"
#define SND_AURA03_CACHE			"sc_rpg/bttlcry03.wav"
#define SND_HOLYGUARD_CACHE			"sc_rpg/harmor.wav"
#define SND_HOLYWEP_CACHE			"sc_rpg/wepdrop.wav"
#define SND_JUMP_CACHE				"sc_rpg/jump.wav"
#define SND_JUMP_LAND_CACHE			"sc_rpg/jump_land.wav"

// Power Names
#define AB_HEALTH					"Vitality"
#define AB_ARMOR					"Superior Armor"
#define AB_HEALTH_REGEN				"Health Regeneration"
#define AB_ARMOR_REGEN				"Nano Armor"
#define AB_AMMO						"The Magic Pocket"
#define AB_DOUBLEJUMP				"Icarus Potion"
#define AB_WEAPON					"A Gift From The Gods"
#define AB_AURA						"The Warrior's Battlecry"
#define AB_HOLYGUARD				"Holy Armor"

// Max Defined Values

#define AB_HEALTH_MAX				400
#define AB_ARMOR_MAX				210
#define AB_HEALTH_REGEN_MAX			50
#define AB_ARMOR_REGEN_MAX			55
#define AB_AMMO_MAX					30
#define AB_DOUBLEJUMP_MAX			5
#define AB_WEAPON_MAX				10
#define AB_AURA_MAX					20
#define AB_HOLYGUARD_MAX			20

// Plugin
#define PLUGIN						"Sven Co-op RPG Mod"
#define AUTHOR						"JonnyBoy0719"
#define VERSION						"20.4"

// Adverts
#define AdvertSetup_Max				10
new AdvertSetup = 0;

//------------------
//	Handles & more
//------------------

new ShouldFullReset[33],
	ResetConvarTime[33],
	lastfrags[33],
	lastDeadflag[33],
	bool:FirstTimeJoining[33],
	bool:HasSpawned[33],
	bool:HasLoadedStats[33],
	bool:enable_ranking = false;

// Stats
new stats_increment[33],
	stats_xp[33],
	stats_xp_cap[33],
	stats_xp_temp[33],	// Used only for the stats_xp_cap
	stats_xp_bonus[33],
	stats_neededxp[33],
	stats_level[33] = -1,
	stats_medals[33],
	stats_prestige[33],
	stats_points[33],
	stats_ammo[33],
	stats_ammo_wait[33],
	stats_randomweapon[33],
	stats_randomweapon_wait[33],
	stats_auro[33],
	stats_auro_timer[33],
	stats_auro_wait[33],
	stats_health[33],
	stats_health_set[33],
	stats_armor[33],
	stats_armor_set[33],
	stats_holyguard[33],
	stats_holyguard_wait[33],
	stats_holyguard_timer[33],
	stats_doublejump[33],
	stats_doublejump_temp[33] = 0;

// Temp values
new temp_value_medic[33]

// Booleans
new bool:PlayerIsHurt[33] = false,
	IsHurt_Timer[33] = 0,
	bool:IsJumping[33] = false,
	bool:HasAura[33] = false,
	bool:HasHolyGuard[33] = false

// Global stuff
new mysqlx_host,
	mysqlx_user,
	mysqlx_db,
	mysqlx_pass,
	mysqlx_type,
	Handle:sql,
	Handle:sql_db,
	sql_error[128],
	sql_errno

new glb_MapDefined_AmmoRegen = 0,
	glb_MapDefined_WepRandomizer = 0,
	glb_MapDefined_MaxJumps = 0,
	glb_MapDefined_SetEXPCap = 0,
	glb_AuraTimer = 0,
	glb_PlyTime = 0,
	//glb_HolyGuardTimer = 0,
	bool:glb_MapDefined_HasSetCap[33] = false,
	bool:glb_MapDefined_IsDisabled = false,	// Disables everything
	bool:glb_MapDefined_IsBlacklisted = false,
	bool:glb_MapDefined_IsWildCard = false,
	bool:glb_AuraIsActivated = false;
	//bool:glb_HolyGuardIsActivated = false;

new setranking,
	_debug,
	rank_name[33][185],
	ply_rank[33],
	top_rank,
	rank_max,
	SetExtraBonus = 0;

new g_array[80][228];

new SQLVault:VaultHandle;

//------------------
//	Includes
//------------------

#include "sc_rpg/natives.sma"
#include "sc_rpg/rewards.sma"

//------------------
//	plugin_init()
//------------------

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_cvar("rpgmod_version", VERSION, FCVAR_SPONLY|FCVAR_SERVER)

	set_cvar_string("rpgmod_version", VERSION)

	register_forward(FM_PlayerPreThink,"PluginThink")
	register_forward(FM_GetGameDescription,"GameInformation")

	register_event("DeathMsg", "EVENT_PlayerDeath", "a")
	//register_event("ItemPickup", "EVENT_ItemPickup", "b")
	register_event("Damage", "EVENT_Damage", "b")

	register_menucmd(register_menuid("Select Skill"),(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9),"RPGSkillChoice");
	register_menucmd(register_menuid("Select Increment"),(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5),"RPGIncrementChoice");

	register_concmd("selectskills","RPGSkill",0,"- Opens the Skill Choice Menu, if you have Skillpoints available");
	register_concmd("selectskill","RPGSkill",0,"- Opens the Skill Choice Menu, if you have Skillpoints available");
	register_concmd("rpg_skillinfo", "CVAR_SkillsInfo", 0, "Prints the info about the skills")
	register_concmd("skillsinfo", "CVAR_SkillsInfo", 0, "Prints the info about the skills")
	register_concmd("challenges", "CVAR_Challenges", 0, "Prints the challenges")
	register_concmd("rpg_commands", "CVAR_CMMNDS", 0, "Prints the available commands")

	// Sets the stuff
	register_concmd("rpg_exp_bonus", "CVAR_SetEXPBonus", ADMIN_RCON, "[amount] [0|1]")
	register_concmd("rpg_set_level", "CVAR_SetStatsLevel", ADMIN_RCON, "<name or #userid> [amount]")
	register_concmd("rpg_set_prestige", "CVAR_SetStatsPrestige", ADMIN_RCON, "<name or #userid> [amount]")
	register_concmd("rpg_skill_gift", "CVAR_Skill_GiftFromTheGods", ADMIN_RCON, "<name or #userid>")
	register_concmd("rpg_reloadblacklist", "CVAR_ReloadBlacklist", ADMIN_RCON, "Reloads the blacklist")

	register_concmd("grenade", "hook_grenade")
	register_concmd("medic", "hook_medic")

	set_task(1.0,"PluginThinkLoop",0,"",0,"b")
	set_task(60.0,"PluginAdverts",0,"",0,"b")

	mysqlx_host = register_cvar ("rpg_host", "127.0.0.1"); // The host from the db
	mysqlx_user = register_cvar ("rpg_user", "rpg_mod"); // The username from the db login
	mysqlx_pass = register_cvar ("rpg_pass", "rpg_mod"); // The password from the db password
	mysqlx_type = register_cvar ("rpg_type", "mysql"); // The password from the db type
	mysqlx_db = register_cvar ("rpg_dbname", "sc_rpg"); // The database name
	register_cvar ("rpg_table", "rpg_stats"); // The table where it will save the information
	register_cvar ("rpg_rank_table", "rpg_ranks"); // The table where it will save the information
	register_cvar ("rpg_gameinfo", "1"); // This will enable GameInformation to be overwritten.
	setranking = register_cvar ("rpg_ranking", "1"); // This will enable ranking, or simply disable it.
	_debug = register_cvar ("rpg_debug", "0"); // This will enable the debugging

	// Client commands
	register_clcmd("say","hook_say")
	register_clcmd("say_team","hook_say")

	// Fixup
	glb_MapDefined_IsWildCard = false;
	glb_MapDefined_IsDisabled = false;
	glb_MapDefined_IsBlacklisted = false;
	glb_MapDefined_AmmoRegen = 0;
	glb_MapDefined_WepRandomizer = 0;
	glb_MapDefined_MaxJumps = 0;
	glb_MapDefined_SetEXPCap = 0;
	glb_PlyTime = 15;
	//-----------------------------
	glb_AuraIsActivated = false;
	//glb_HolyGuardIsActivated = false;

	// Check if the map is blacklisted
	CheckIfBlacklisted();

	// Natives & Forwards
	ForwardClientReward = CreateMultiForward("Forward_ClientEarnedReward", ET_IGNORE, FP_CELL, FP_CELL);

	Reward = ArrayCreate(RewardsStruct);

	VaultHandle = sqlv_open_default("sc_rpg_api", false);
	sqlv_init_ex(VaultHandle);

	// Time to register the rewards!
	// To create your own, add them on your own plugin, and use the API.
	for( new m_iReward; m_iReward < Rewards; m_iReward++ )
	{
		RewardsPointer[ m_iReward ] = RegisterReward(
			RewardsInfo[ m_iReward ][ _Name ],
			RewardsInfo[ m_iReward ][ _Description ],
			RewardsInfo[ m_iReward ][ _Save_Name ],
			RewardsInfo[ m_iReward ][ _Max_Value ]
			);
	}
	
	// Lets delay the connection
	set_task( 0.3, "SQL_Init" );
}

//------------------
//	plugin_end()
//------------------

public plugin_end()
{
	if ( sql_db )
		SQL_FreeHandle( sql_db );

	if ( sql )
		SQL_FreeHandle( sql );

	sqlv_close( VaultHandle );

	new TotalRewards = ArraySize( Reward );
	new RewardData[ RewardsStruct ];

	for( new Index = 0; Index < TotalRewards; Index++ )
	{
		ArrayGetArray( Reward, Index, RewardData );
		ArrayDestroy( RewardData[ _Data ] );
	}

	ArrayDestroy( Reward );
}

//------------------
//	plugin_precache()
//------------------

public plugin_precache()
{
	precache_sound(SND_LVLUP_CACHE)
	precache_sound(SND_READY_CACHE)
	precache_sound(SND_AURA01_CACHE)
	precache_sound(SND_AURA02_CACHE)
	precache_sound(SND_AURA03_CACHE)
	precache_sound(SND_HOLYGUARD_CACHE)
	precache_sound(SND_HOLYWEP_CACHE)
	precache_sound(SND_JUMP_CACHE)
	precache_sound(SND_JUMP_LAND_CACHE)
}

//------------------
//	CVAR_SkillsInfo()
//------------------

public CVAR_SkillsInfo(id)
{
	client_print(id, print_console, "===================================================================");
	client_print(id, print_console, "Skills Information");
	client_print(id, print_console, "===================================================================");
	client_print(id, print_console, "1. %s:^n   Starting HP + 1 * Strengthlevel.^n", AB_HEALTH);
	client_print(id, print_console, "2. %s:^n   Starting AP + 1 * Armorlevel.^n", AB_ARMOR);
	client_print(id, print_console, "3. %s:^n   Regens HP every (35.5-level) Seconds.^n   (Doesn't regen if damaged)^n", AB_HEALTH_REGEN);
	client_print(id, print_console, "4. %s:^n   Regens AP every (35.5-level) Seconds.^n   (Doesn't regen if damaged)^n", AB_ARMOR_REGEN);
	client_print(id, print_console, "5. %s:^n   Ammunition for current Weapon every (*65-level) Seconds.", AB_AMMO);
	client_print(id, print_console, "   (*Depends if the map isn't on the 'blacklist')^n");
	client_print(id, print_console, "6. %s:^n   Grants you 1 more extra jump per level.^n", AB_DOUBLEJUMP);
	client_print(id, print_console, "7. %s:^n   Gives you random weapon drop, the higher the level, greater the loot!^n", AB_WEAPON);
	client_print(id, print_console, "8. %s:^n   Supports nearby Teammates with HP and AP for a short period of time!.", AB_AURA);
	client_print(id, print_console, "   (Can be activated when pressing the 'take cover' button)^n");
	client_print(id, print_console, "9. %s:^n   Gives you temporarily god mode, use it while it lasts!", AB_HOLYGUARD);
	client_print(id, print_console, "   (Can be activated when pressing the 'medic' button)^n");
	client_print(id, print_console, "Special - Medals:^n   Given from completing hard or 'special' rewards.^n");
	client_print(id, print_console, "Special - Prestige:^n   When on max level, you can reset your level back to zero,");
	client_print(id, print_console, "   but you gain more EXP & rewards.");
	client_print(id, print_console, "===================================================================");
	client_print(id, print_chat, "Skill information has been printed on the console!")
}

//------------------
//	CVAR_Challenges()
//------------------

public CVAR_Challenges(id)
{
	new steamid[35],
		Challenges_total = 0,
		Challenges_count = 0;
	get_user_authid(id, steamid, charsmax(steamid))

	client_print(id, print_console, "===================================================================");
	client_print(id, print_console, "Challenges");
	client_print(id, print_console, "===================================================================");
	
	for( new m_iReward; m_iReward < Rewards; m_iReward++ )
	{
		Challenges_total++;
		RewardsData[ m_iReward ][ id ] = GetRewardData(steamid, RewardsInfo[ m_iReward ][ _Save_Name ]);
		
		if( GetClientRewardStatus( RewardsPointer[ m_iReward ], RewardsData[ m_iReward ][ id ] ) == _In_Progress )
			client_print(id, print_console, "%s (%d/%d):^n   %s^n", RewardsInfo[ m_iReward ][ _Name ], RewardsData[ m_iReward ][ id ], RewardsInfo[ m_iReward ][ _Max_Value ], RewardsInfo[ m_iReward ][ _Description ]);
		else
		{
			Challenges_count++;
			client_print(id, print_console, "%s (Completed):^n   %s^n", RewardsInfo[ m_iReward ][ _Name ], RewardsInfo[ m_iReward ][ _Description ]);
		}
	}
	
	if (Challenges_count >= Challenges_total)
		client_print(id, print_console, "Progress:^n   All %d challenges has been completed!", Challenges_total);
	else
		client_print(id, print_console, "Progress:^n   You have completed %d out of %d challenges.", Challenges_count, Challenges_total);
	client_print(id, print_console, "===================================================================");
	client_print(id, print_chat, "The challenges has been printed on the console!")
}

//------------------
//	CVAR_CMMNDS()
//------------------

public CVAR_CMMNDS(id)
{
	client_print(id, print_console, "===================================================================");
	client_print(id, print_console, "RPG Mod Commands");
	client_print(id, print_console, "===================================================================");
	if(is_user_admin(id))
	{
		client_print(id, print_console, "rpg_exp_bonus [amount] [0|1]^n   This will set an extra amount of EXP you will gain per frag.^n");
		client_print(id, print_console, "rpg_set_level <name or #userid> [amount]^n   This will set the level of a user (and reset their skills).^n");
		client_print(id, print_console, "rpg_set_prestige <name or #userid> [amount]^n   This will set the prestige level of a user.^n");
		client_print(id, print_console, "rpg_skill_gift <name or #userid>^n   This will forcefully use the skill %s on the user,", AB_WEAPON);
		client_print(id, print_console, "   even if the player doesn't have it.^n");
		client_print(id, print_console, "rpg_reloadblacklist^n   This will reload the whole blacklist.");
	}
	else
		client_print(id, print_console, "ERROR^n   You do not have access for these commands.");
	client_print(id, print_console, "===================================================================");
	client_print(id, print_chat, "The commands has been printed on the console!")
}

//------------------
//	CVAR_SetEXPBonus()
//------------------

public CVAR_SetEXPBonus(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	new arg[32],
		arg2[32] = "0";

	read_argv(1, arg, 31)
	read_argv(2, arg2, 31)

	new authid[32], name[32]

	get_user_authid(id, authid, 31)
	get_user_name(id, name, 31)

	if (str_to_num(arg2) == 0)
	{
		if (SetExtraBonus == 0)
			client_print(id, print_chat, "Extra XP is now active, current amount: (+%dXP)", str_to_num(arg));
		else if(str_to_num(arg) <= 0 && SetExtraBonus > 0)
			client_print(id, print_chat, "Extra XP has been turned off");
		else
			client_print(id, print_chat, "Extra XP was changed from (+%dXP) to (+%dXP)!", SetExtraBonus, str_to_num(arg));
	}
	else if (str_to_num(arg2) == 1)
	{
		if (SetExtraBonus == 0)
			client_print(0, print_chat, "Extra XP Bonus Event is now active! (+%dXP)", str_to_num(arg));
		else if(str_to_num(arg) <= 0 && SetExtraBonus > 0)
			client_print(0, print_chat, "Extra XP Bonus Event is now over!");
		else
			client_print(0, print_chat, "Extra XP Bonus has changed from (+%dXP) to (+%dXP)!", SetExtraBonus, str_to_num(arg));
	}
	else
	{
		client_print(id, print_console, "[RPG MOD] %d is not valid! The valid types are the following:", str_to_num(arg2))
		client_print(id, print_console, "[RPG MOD] 0 = Will only show the changes for you (default)")
		client_print(id, print_console, "[RPG MOD] 1 = Will display for everyone on the server")
		return PLUGIN_HANDLED
	}

	SetExtraBonus = str_to_num(arg);

	log_amx("RPG MOD CMD: ^"%s<%d><%s><>^" added set the extra EXP bonus to: %d", name, get_user_userid(id), authid, SetExtraBonus)

	return PLUGIN_HANDLED
}

//------------------
//	CVAR_SetStatsLevel()
//------------------

public CVAR_SetStatsLevel(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	new arg[32],
		arg2[32],
		setvalue

	read_argv(1, arg, 31)
	read_argv(2, arg2, 31)
	new player = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)

	if (!player)
	{
		client_print(id, print_console, "Player ^"%s^" was not found!", arg)
		return PLUGIN_HANDLED
	}

	new authid[32],
		authid2[32],
		name[32],
		name2[32]

	stats_health_set[player] = 0
	stats_armor_set[player] = 0
	stats_health[player] = 0
	stats_armor[player] = 0
	stats_ammo[player] = 0
	stats_doublejump[player] = 0
	stats_randomweapon[player] = 0
	stats_auro[player] = 0
	stats_holyguard[player] = 0
	stats_xp[player] = 0

	get_user_authid(id, authid, 31)
	get_user_authid(player, authid2, 31)
	get_user_name(id, name, 31)
	get_user_name(player, name2, 31)

	if (str_to_num(arg2) <= 0)
		setvalue = 0
	else if (str_to_num(arg2) >= 800)
		setvalue = 800
	else
		setvalue = str_to_num(arg2)

	stats_level[player] = setvalue;
	stats_points[player] = setvalue;

	GetCurrentRankTitle(player)
	CalculateEXP_Needed(player)
	SaveLevel(player, authid2)

	log_amx("RPG MOD CMD: ^"%s<%d><%s><>^" set ^"%s<%d><%s><>^" level to %s", name, get_user_userid(id), authid, name2, get_user_userid(player), authid2, arg2)

	return PLUGIN_HANDLED
}

//------------------
//	CVAR_Skill_GiftFromTheGods()
//------------------

public CVAR_Skill_GiftFromTheGods(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	new arg[32]

	read_argv(1, arg, 31)
	new player = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)

	if (!player)
	{
		client_print(id, print_console, "Player ^"%s^" was not found!", arg)
		return PLUGIN_HANDLED
	}

	new authid[32],
		authid2[32],
		name[32],
		name2[32]

	get_user_authid(id, authid, 31)
	get_user_authid(player, authid2, 31)
	get_user_name(id, name, 31)
	get_user_name(player, name2, 31)

	ObtainWeapon_Find(player)

	log_amx("RPG MOD CMD: ^"%s<%d><%s><>^" forcefully used the skills %s on ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, AB_WEAPON, name2, get_user_userid(player), authid2)

	return PLUGIN_HANDLED
}

//------------------
//	CVAR_ReloadBlacklist()
//------------------

public CVAR_ReloadBlacklist(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	new authid[32],
		name[32]

	get_user_authid(id, authid, 31)
	get_user_name(id, name, 31)

	CheckIfBlacklisted();

	client_print(id, print_console, "The blacklist has been reloaded!")

	log_amx("RPG MOD CMD: ^"%s<%d><%s><>^" reloaded the blacklist", name, get_user_userid(id), authid)

	return PLUGIN_HANDLED
}

//------------------
//	CVAR_SetStatsPrestige()
//------------------

public CVAR_SetStatsPrestige(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	new arg[32],
		arg2[32],
		setvalue

	read_argv(1, arg, 31)
	read_argv(2, arg2, 31)
	new player = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)

	if (!player)
	{
		client_print(id, print_console, "Player ^"%s^" was not found!", arg)
		return PLUGIN_HANDLED
	}

	new authid[32],
		authid2[32],
		name[32],
		name2[32]

	get_user_authid(id, authid, 31)
	get_user_authid(player, authid2, 31)
	get_user_name(id, name, 31)
	get_user_name(player, name2, 31)

	if (str_to_num(arg2) <= 0)
		setvalue = 0
	else if (str_to_num(arg2) >= 10)
		setvalue = 10
	else
		setvalue = str_to_num(arg2)

	stats_prestige[player] = setvalue;
	
	SaveLevel(player, authid2)

	log_amx("RPG MOD CMD: ^"%s<%d><%s><>^" set ^"%s<%d><%s><>^" prestige to %s", name, get_user_userid(id), authid, name2, get_user_userid(player), authid2, arg2)

	return PLUGIN_HANDLED
}

//------------------
//	hook_grenade()
//------------------

public hook_grenade(id)
{
	if (stats_auro[id] <= 0)
		return PLUGIN_CONTINUE;
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE;
	if(glb_AuraIsActivated)
		return PLUGIN_CONTINUE;
	if(stats_auro_wait[id] <= 0)
	{
		switch(random_num(0, 2))
		{
			case 0:
				client_cmd(id, "spk ^"%s^"", SND_AURA01)
			case 1:
				client_cmd(id, "spk ^"%s^"", SND_AURA02)
			case 2:
				client_cmd(id, "spk ^"%s^"", SND_AURA03)
		}
		
		new iPlayers[32], iNum
		get_players(iPlayers, iNum)
		
		for(new i = 0; i < iNum; i++)
		{
			new pPlayers = iPlayers[i]
			if(is_user_alive(id) && is_user_alive(pPlayers) && pPlayers != id)
			{
				new distanceRange = 580 + stats_auro[id],
					Float:origin_i[3],
					Float:origin_pPlayers[3]

				pev(id, pev_origin, origin_i)
				pev(pPlayers, pev_origin, origin_pPlayers)

				if(get_distance_f(origin_i, origin_pPlayers) <= distanceRange)
				{
					switch(random_num(0, 2))
					{
						case 0:
							client_cmd(pPlayers, "spk ^"%s^"", SND_AURA01)
						case 1:
							client_cmd(pPlayers, "spk ^"%s^"", SND_AURA02)
						case 2:
							client_cmd(pPlayers, "spk ^"%s^"", SND_AURA03)
					}
				}
			}
		}
		
		new r = 181,
			g = 148,
			b = 16,
			name[32];
		get_user_name(id, name, 31);
		client_print(0, print_chat, "[RPG MOD] %s has activated their %s!", name, AB_AURA);

		set_user_rendering(id, kRenderFxGlowShell, r, g, b, kRenderNormal, 0);

		glb_AuraTimer = 10;
		glb_AuraIsActivated = true;
		HasAura[id] = true;
		stats_auro_timer[id] = 200 + stats_auro[id];
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

//------------------
//	hook_medic()
//------------------

public hook_medic(id)
{
	new steamid[35];
	get_user_authid(id, steamid, charsmax(steamid))
	
	temp_value_medic[id]++;
	
	// Is alive, and pressed hook_medic 5 times
	if (temp_value_medic[id] > 4)
	{
		if(GetClientRewardStatus(RewardsPointer[ _Secret2 ], RewardsData[ _Secret2 ][ id ]) == _In_Progress)
		{
			RewardsData[ _Secret2 ][ id ]++;
			SetRewardData( steamid, RewardsInfo[ _Secret2 ][ _Save_Name ], RewardsData[ _Secret2 ][ id ] );

			// check if client just unlocked the achievement
			if(GetClientRewardStatus(RewardsPointer[ _Secret2 ], RewardsData[ _Secret2 ][ id ]) == _Unlocked)
			{
				stats_xp[id] = stats_xp[id] + RewardsInfo[ _Secret2 ][ _ExpGain ];
				stats_medals[id] = stats_medals[id] + RewardsInfo[ _Secret2 ][ _Medals ];
				ClientRewardCompleted( id, RewardsPointer[ _Secret2 ], .Announce = true );
			}
		}
	}
	
	set_task(1.8, "RemoveTempValues", id)
	
	if (stats_holyguard[id] <= 0)
		return PLUGIN_CONTINUE;
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE;
	if(HasHolyGuard[id])
		return PLUGIN_CONTINUE;
	if(stats_holyguard_wait[id] <= 0)
	{
		client_cmd(id, "spk ^"%s^"", SND_HOLYGUARD)

		if(GetClientRewardStatus(RewardsPointer[ _GodsDoing ], RewardsData[ _GodsDoing ][ id ]) == _In_Progress)
		{
			RewardsData[ _GodsDoing ][ id ]++;
			SetRewardData( steamid, RewardsInfo[ _GodsDoing ][ _Save_Name ], RewardsData[ _GodsDoing ][ id ] );

			// check if client just unlocked the achievement
			if(GetClientRewardStatus(RewardsPointer[ _GodsDoing ], RewardsData[ _GodsDoing ][ id ]) == _Unlocked)
			{
				stats_xp[id] = stats_xp[id] + RewardsInfo[ _GodsDoing ][ _ExpGain ];
				stats_medals[id] = stats_medals[id] + RewardsInfo[ _GodsDoing ][ _Medals ];
				ClientRewardCompleted( id, RewardsPointer[ _GodsDoing ], .Announce = true );
			}
		}

		new r = 140,
			g = 255,
			b = 219,
			name[32];
		get_user_name(id, name, 31);
		client_print(0, print_chat, "[RPG MOD] %s has activated their %s!", name, AB_HOLYGUARD);

		set_user_godmode(id, 1);
		set_user_rendering(id, kRenderFxGlowShell, r, g, b, kRenderNormal, 0);

		stats_holyguard_wait[id] = 300 - stats_holyguard[id];

		HasHolyGuard[id] = true;
		stats_holyguard_timer[id] = 1800 + stats_holyguard[id];
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

//------------------
//	RemoveTempValues()
//------------------

public RemoveTempValues(id)
{
	if (temp_value_medic[id] > 0) temp_value_medic[id] = 0;
	return PLUGIN_HANDLED
}

//------------------
//	The Skill Menu
//------------------
//	The code is a modified version of the SCXPM one.
//------------------
//	RPGSkill()
//------------------

public RPGSkill(id)
{
	stats_increment[id] = 1;
	if (stats_points[id] > 20 )
		RPGIncrementMenu( id );
	else
		RPGSkillMenu( id );
}

//------------------
//	RPGSkillMenu()
//------------------

public RPGSkillMenu(id)
{
	new menuBody[1224];
	format(
		menuBody,
		1223,
		"Select Skills - Skillpoints available: %i^n^n^n^n 1.   %s  [ %i / %i ]^n^n 2.   %s  [ %i / %i ]^n^n 3.   %s  [ %i / %i ]^n^n 4.   %s  [ %i / %i ]^n^n 5.   %s  [ %i / %i ]^n^n 6.   %s  [ %i / %i ]^n^n 7.   %s  [ %i / %i ]^n^n 8.   %s  [ %i / %i ]^n^n 9.   %s  [ %i / %i ]^n^n^n 0.   Done",
		stats_points[id],
		AB_HEALTH,
		stats_health_set[id],
		AB_HEALTH_MAX,
		AB_ARMOR,
		stats_armor_set[id],
		AB_ARMOR_MAX,
		AB_HEALTH_REGEN,
		stats_health[id],
		AB_HEALTH_REGEN_MAX,
		AB_ARMOR_REGEN,
		stats_armor[id],
		AB_ARMOR_REGEN_MAX,
		AB_AMMO,
		stats_ammo[id],
		AB_AMMO_MAX,
		AB_DOUBLEJUMP,
		stats_doublejump[id],
		AB_DOUBLEJUMP_MAX,
		AB_WEAPON,
		stats_randomweapon[id],
		AB_WEAPON_MAX,
		AB_AURA,
		stats_auro[id],
		AB_AURA_MAX,
		AB_HOLYGUARD,
		stats_holyguard[id],
		AB_HOLYGUARD_MAX
	);
	show_menu(id,(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9),menuBody,13,"Select Skill");
}

//------------------
//	RPGIncrementMenu()
//------------------

public RPGIncrementMenu( id )
{
	new menuBody[1024];
	if (stats_points[id] >= 20 && stats_points[id] < 50)
		format(menuBody,1023,"Increment your skill with^n^n^n^n1.    1  point^n^n2.    5  points^n^n3.    10 points^n^n4.    25 points");
	else if (stats_points[id] >= 50 && stats_points[id] < 100)
		format(menuBody,1023,"Increment your skill with^n^n^n^n1.    1  point^n^n2.    5  points^n^n3.    10 points^n^n4.    25 points^n^n5.    50 points");
	else if (stats_points[id] >= 100)
		format(menuBody,1023,"Increment your skill with^n^n^n^n1.    1  point^n^n2.    5  points^n^n3.    10 points^n^n4.    25 points^n^n5.    50 points^n^n6.    100 points");
	show_menu(id,(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5),menuBody,13,"Select Increment");
}

//------------------
//	RPGIncrementChoice()
//------------------

public RPGIncrementChoice( id, key )
{
	switch(key)
	{
		case 0:
			stats_increment[id] = 1;
		case 1:
			stats_increment[id] = 5;
		case 2:
			stats_increment[id] = 10;
		case 3:
			stats_increment[id] = 25;
		case 4:
			stats_increment[id] = 50;
		case 5:
			stats_increment[id] = 100;
	}
	RPGSkillMenu(id);
}

//------------------
//	RPGSkillChoice()
//------------------

public RPGSkillChoice( id, key )
{
	// We won't want to apply negative points.
	if (stats_increment[id] > stats_points[id] && stats_points[id] > 0)
	{
		RPGSkill(id)
		return PLUGIN_HANDLED;
	}

	new auth[33];
	get_user_authid(id, auth, 32);
	switch(key)
	{
		case 0:
		{
			if(stats_points[id]>0)
			{
				if(stats_health_set[id]<AB_HEALTH_MAX)
				{
					if (stats_increment[id] + stats_health_set[id] >= AB_HEALTH_MAX)
						stats_increment[id] = AB_HEALTH_MAX - stats_health_set[id];
					stats_points[id] -= stats_increment[id];
					stats_health_set[id] += stats_increment[id];
					client_print(id,print_chat,"[RPG MOD] You spent %i Skillpoints to enhance your %s to Level %i!", stats_increment[id], AB_HEALTH, stats_health_set[id]);
					SaveLevel(id, auth)
					if(is_user_alive(id))
						set_user_health(id, get_user_health(id) + stats_increment[id]);
				}
				else
					client_print(id,print_chat,"[RPG MOD] You have mastered your %s already.",AB_HEALTH)
				if(stats_points[id]>0)
					RPGSkill(id);
			}
			else
				client_print(id,print_chat,"[RPG MOD] You need one Skillpoint for enhancing your %s.",AB_HEALTH)
		}
		case 1:
		{
			if(stats_points[id]>0)
			{
				if(stats_armor_set[id]<AB_ARMOR_MAX)
				{
					if (stats_increment[id] + stats_armor_set[id] >= AB_ARMOR_MAX)
						stats_increment[id] = AB_ARMOR_MAX - stats_armor_set[id];
					stats_points[id]-= stats_increment[id];
					stats_armor_set[id] += stats_increment[id];
					client_print(id,print_chat,"[RPG MOD] You spent %i Skillpoints to enhance your %s to Level %i!", stats_increment[id], AB_ARMOR, stats_armor_set[id]);
					SaveLevel(id, auth)
					if(is_user_alive(id))
						set_user_armor(id,get_user_armor(id)+stats_increment[id]);
				}
				else
					client_print(id,print_chat,"[RPG MOD] You have mastered your %s already.",AB_ARMOR)
				if(stats_points[id]>0)
					RPGSkill(id)
			}
			else
				client_print(id,print_chat,"[RPG MOD] You need one Skillpoint for enhancing your %s.",AB_ARMOR)
		}
		case 2:
		{
			if(stats_points[id]>0)
			{
				if(stats_health[id]<AB_HEALTH_REGEN_MAX)
				{
					if (stats_increment[id] + stats_health[id] >= AB_HEALTH_REGEN_MAX)
						stats_increment[id] = AB_HEALTH_REGEN_MAX - stats_health[id];
					stats_points[id] -= stats_increment[id];
					stats_health[id] += stats_increment[id];
					SaveLevel(id, auth)
					client_print(id,print_chat,"[RPG MOD] You spent %i Skillpoints to enhance your %s to Level %i!", stats_increment[id], AB_HEALTH_REGEN, stats_health[id])
				}
				else
					client_print(id,print_chat,"[RPG MOD] You have mastered your %s already.",AB_HEALTH_REGEN)
				if(stats_points[id]>0)
					RPGSkill(id)
			}
			else
				client_print(id,print_chat,"[RPG MOD] You need one Skillpoint for enhancing your %s.",AB_HEALTH_REGEN)
		}
		case 3:
		{
			if(stats_points[id]>0)
			{
				if(stats_armor[id]<AB_ARMOR_REGEN_MAX)
				{
					if (stats_increment[id] + stats_armor[id] >= AB_ARMOR_REGEN_MAX)
						stats_increment[id] = AB_ARMOR_REGEN_MAX - stats_armor[id];
					stats_points[id] -= stats_increment[id];
					stats_armor[id] += stats_increment[id];
					SaveLevel(id, auth)
					client_print(id,print_chat,"[RPG MOD] You spent %i Skillpoint to enhance your %s to Level %i!", stats_increment[id], AB_ARMOR_REGEN, stats_armor[id]);
				}
				else
					client_print(id,print_chat,"[RPG MOD] You have mastered your %s already.",AB_ARMOR_REGEN)
				if(stats_points[id]>0)
					RPGSkill(id)
			}
			else
				client_print(id,print_chat,"[RPG MOD] You need one Skillpoint for enhancing your %s.",AB_ARMOR_REGEN)
		}
		case 4:
		{
			if(stats_points[id]>0)
			{
				if(stats_ammo[id]<AB_AMMO_MAX)
				{
					if (stats_increment[id] + stats_ammo[id] >= AB_AMMO_MAX)
						stats_increment[id] = AB_AMMO_MAX - stats_ammo[id];
					stats_points[id] -= stats_increment[id];
					stats_ammo[id] += stats_increment[id];
					SaveLevel(id, auth)
					client_print(id,print_chat,"[RPG MOD] You spent %i Skillpoints to enhance your %s to Level %i!", stats_increment[id], AB_AMMO, stats_ammo[id]);
				}
				else
					client_print(id,print_chat,"[RPG MOD] You have mastered your %s already.",AB_AMMO)
				if(stats_points[id]>0)
					RPGSkill(id)
			}
			else
				client_print(id,print_chat,"[RPG MOD] You need one Skillpoint for enhancing your %s.",AB_AMMO)
		}
		case 5:
		{
			if(stats_points[id]>0)
			{
				if(stats_doublejump[id]<AB_DOUBLEJUMP_MAX)
				{
					if (stats_increment[id] + stats_doublejump[id] >= AB_DOUBLEJUMP_MAX)
						stats_increment[id] = AB_DOUBLEJUMP_MAX - stats_doublejump[id];
					stats_points[id] -= stats_increment[id];
					stats_doublejump[id] += stats_increment[id];
					SaveLevel(id, auth)
					client_print(id,print_chat,"[RPG MOD] You spent %i Skillpoints to enhance your %s to Level %i!", stats_increment[id], AB_DOUBLEJUMP, stats_doublejump[id]);
				}
				else
					client_print(id,print_chat,"[RPG MOD] You have mastered your %s already.",AB_DOUBLEJUMP)
				if(stats_points[id]>0)
					RPGSkill(id)
			}
			else
				client_print(id,print_chat,"[RPG MOD] You need one Skillpoint for enhancing your %s.",AB_DOUBLEJUMP)
		}
		case 6:
		{
			if(stats_points[id]>0)
			{
				if(stats_randomweapon[id]<AB_WEAPON_MAX)
				{
					if (stats_increment[id] + stats_randomweapon[id] >= AB_WEAPON_MAX)
						stats_increment[id] = AB_WEAPON_MAX - stats_randomweapon[id];
					stats_points[id] -= stats_increment[id];
					stats_randomweapon[id] += stats_increment[id];
					SaveLevel(id, auth)
					client_print(id,print_chat,"[RPG MOD] You spent %i Skillpoints to enhance your %s to Level %i!", stats_increment[id], AB_WEAPON, stats_randomweapon[id])
				}
				else
					client_print(id,print_chat,"[RPG MOD] You have mastered your %s already.",AB_WEAPON)
				if(stats_points[id]>0)
					RPGSkill(id)
			}
			else
				client_print(id,print_chat,"[RPG MOD] You need one Skillpoint for enhancing your %s.",AB_WEAPON)
		}
		case 7:
		{
			if(stats_points[id]>0)
			{
				if(stats_auro[id]<AB_AURA_MAX)
				{
					if (stats_increment[id] + stats_auro[id] >= AB_AURA_MAX)
						stats_increment[id] = AB_AURA_MAX - stats_auro[id];
					stats_points[id] -= stats_increment[id];
					stats_auro[id] += stats_increment[id];
					SaveLevel(id, auth)
					client_print(id,print_chat,"[RPG MOD] You spent %i Skillpoints to enhance your %s to Level %i!", stats_increment[id], AB_AURA, stats_auro[id])
				}
				else
					client_print(id,print_chat,"[RPG MOD] You have mastered your %s already.",AB_AURA)
				if(stats_points[id]>0)
					RPGSkill(id)
			}
			else
				client_print(id,print_chat,"[RPG MOD] You need one Skillpoint for enhancing your %s.",AB_AURA)
		}
		case 8:
		{
			if(stats_points[id]>0)
			{
				if(stats_holyguard[id]<AB_HOLYGUARD_MAX)
				{
					if (stats_increment[id] + stats_holyguard[id] >= AB_HOLYGUARD_MAX)
						stats_increment[id] = AB_HOLYGUARD_MAX - stats_holyguard[id];
					stats_points[id] -= stats_increment[id];
					stats_holyguard[id] += stats_increment[id];
					SaveLevel(id, auth)
					client_print(id,print_chat,"[RPG MOD] You spent %i Skillpoint to enhance your %s to Level %i!", stats_increment[id], AB_HOLYGUARD, stats_holyguard[id]);
				}
				else
					client_print(id,print_chat,"[RPG MOD] You have mastered your %s already.",AB_HOLYGUARD)
				if(stats_points[id]>0)
					RPGSkill(id)
			}
			else
				client_print(id,print_chat,"[RPG MOD] You need one Skillpoint for enhancing your %s.",AB_HOLYGUARD)
		}
		case 9:
		{
		}
	}
	return PLUGIN_HANDLED;
}

//------------------
//	CheckIfBlacklisted()
//------------------

public CheckIfBlacklisted()
{
	new currentmap[33],
		map_folder[33],
		SetCurrentMapID[32],
		GetconfigsDir[64],
		configsDir[64],
		bool:FoundMap = false;

	get_mapname(currentmap, 32);
	get_configsdir(GetconfigsDir, 63);

	format(configsDir, 63, "%s/sc_rpg/maps/blacklist.ini", GetconfigsDir);

	if (!file_exists(configsDir))
	{
		server_print("[CheckIfBlacklisted] File ^"%s^" doesn't exist.", configsDir)
		return;
	}

	new File=fopen(configsDir,"r");
	if (File)
	{
		new MapID[32];

		while (!feof(File))
		{
			fgets(File, MapID, sizeof(MapID)-1);

			trim(MapID);

			// comment
			if (MapID[0]==';')
				continue;

			if (MapID[0]=='*')
				glb_MapDefined_IsWildCard = true;

			if(containi(currentmap, MapID) != -1)
			{
				SetCurrentMapID = MapID;
				FoundMap = true;
			}
		}
		fclose(File);
	}

	if (FoundMap)
		format(map_folder, 63, "%s/sc_rpg/maps/%s/settings.cfg", GetconfigsDir, SetCurrentMapID);
	else if(glb_MapDefined_IsWildCard)
		format(map_folder, 63, "%s/sc_rpg/maps/global_settings.cfg", GetconfigsDir);

	BeginBlackListing_Map(map_folder);
}

//------------------
//	BeginBlackListing_Map()
//------------------

public BeginBlackListing_Map(szFilename[])
{
	// If we don't have a wildcard or the actual map is not blacklisted.
	if (equali(szFilename, ""))
		return;

	if (!file_exists(szFilename))
	{
		server_print("[BeginBlackListing_Map] File ^"%s^" doesn't exist.", szFilename)
		return;
	}

	new File=fopen(szFilename,"r");
	if (File)
	{
		new ConfigString[512],
			CommandID[32],
			ValueID[32];

		while (!feof(File))
		{
			fgets(File, ConfigString, sizeof(ConfigString)-1);

			trim(ConfigString);

			// comment
			if (ConfigString[0]==';' || ConfigString[0]==' ')
				continue;

			CommandID[0]=0;
			ValueID[0]=0;

			// not enough parameters
			if (parse(ConfigString, CommandID, sizeof(CommandID)-1, ValueID, sizeof(ValueID)-1) < 2)
				continue;

			if (equali(CommandID, "disable") && equali(ValueID, "true"))
				glb_MapDefined_IsDisabled = true;

			if (equali(CommandID, "block_map") && equali(ValueID, "true"))
				glb_MapDefined_IsBlacklisted = true;

			if (equali(CommandID, "cap_playtime"))
				glb_PlyTime = str_to_num(ValueID);
			
			if (equali(CommandID, "cap_exp"))
				glb_MapDefined_SetEXPCap = str_to_num(ValueID);

			if (equali(CommandID, "cap_jump"))
				glb_MapDefined_MaxJumps = str_to_num(ValueID);

			if (equali(CommandID, "regen_ammo"))
				glb_MapDefined_AmmoRegen = str_to_num(ValueID);

			if (equali(CommandID, "regen_weapon"))
				glb_MapDefined_WepRandomizer = str_to_num(ValueID);
		}
		fclose(File);
	}
}

//------------------
//	EVENT_PlayerDeath()
//------------------

public EVENT_PlayerDeath()
{
	new killer = read_data(1);	// Killer
	new victim = read_data(2);	// Victim
	new weapon = read_data(3);	// Weapon

	new players[32],
		num,
		i;
	
	get_players(players, num)
	
	for (i = 0; i<num; i++)
	{
		if (is_user_connected(players[i])
			&& is_user_admin(players[i])
			&& _debug >= 1)
		{
			client_print ( players[i], print_console, "Killer: %d", killer )
			client_print ( players[i], print_console, "Victim: %d", victim )
			client_print ( players[i], print_console, "Weapon: %s", weapon )
		}
	}

	PlayerIsHurt[victim] = false;
	IsJumping[victim] = false;
	HasAura[victim] = false;

	stats_doublejump_temp[victim] = 0;

	return PLUGIN_CONTINUE
}

//------------------
//	EVENT_ItemPickup()
//------------------

/*
public EVENT_ItemPickup(id)
{
	new classname[55];
	read_data(1, classname, 54);	// Classname

	// If the player has picked up the backpack
	if (equali(classname, "item_backpack"))
		HasBackpack[id] = true
	
	return PLUGIN_CONTINUE
}
*/

//------------------
//	EVENT_Damage()
//------------------

public EVENT_Damage(id)
{
	// If the timer has aleady stopped or less than 0, lets start it again.
	if (!PlayerIsHurt[id])
	{
		set_task(1.0, "RegenTimer", id);
		PlayerIsHurt[id] = true;
	}

	new m_iTimer,
		health_value;

	if (stats_health[id] >= 25)
		health_value = 25;
	else
		health_value = stats_health[id];

	m_iTimer = 35 - health_value;

	IsHurt_Timer[id] = m_iTimer;

	return PLUGIN_CONTINUE;
}

//------------------
//	HealthRegen_Continue()
//------------------

public RegenTimer(id)
{
	if (IsHurt_Timer[id] <= 0)
		PlayerIsHurt[id] = false;
	else
	{
		IsHurt_Timer[id]--;
		set_task(1.0, "RegenTimer", id);
	}
}

//------------------
//	client_putinserver()
//------------------

public client_putinserver(id)
{
	if (glb_MapDefined_IsDisabled)
		return PLUGIN_HANDLED;

	if (is_user_bot(id))
		return PLUGIN_HANDLED;

	PlayerHasSpawned(id)

	// If the player has died, lets save his stuff first.
	new auth[33];
	get_user_authid( id, auth, 32);

	if ( !HasLoadedStats[id] )
		CreateStats(id, auth);

	set_task(2.0, "ShowInfo", id)

	return PLUGIN_CONTINUE;
}

//------------------
//	ShowInfo()
//------------------

public ShowInfo(id)
{
	if (glb_MapDefined_SetEXPCap > 0 && !glb_MapDefined_HasSetCap[id])
	{
		glb_MapDefined_HasSetCap[id] = true;
		if (stats_level[id] > 1)
			stats_xp_cap[id] = floatround( 8.25 + stats_neededxp[id] + glb_MapDefined_SetEXPCap );
		else
			stats_xp_cap[id] = glb_MapDefined_SetEXPCap;
	}

	StatsVersion(id)
	HelpOnConnect(id)
	if( enable_ranking )
		set_task(3.0, "ShowStatsOnSpawn", id)
}

//------------------
//	GameInformation()
//------------------

public GameInformation()
{
	if (glb_MapDefined_IsDisabled)
		return PLUGIN_HANDLED;

	new bb_getinfo = get_cvar_num ( "rpg_gameinfo" )
	if (bb_getinfo>=1)
	{
		new gameinfo[55]
		format( gameinfo, 54, "SCRPG %s", VERSION )
		forward_return( FMV_STRING, gameinfo )
		return FMRES_SUPERCEDE;
	}
	return PLUGIN_HANDLED
}

//------------------
//	StatsVersion()
//------------------

public StatsVersion(id)
{
	new formated_text[501];
	format(formated_text, 500, "This server is running Sven Co-Op RPG Version %s", VERSION)
	PrintToChat(id, formated_text)
	return PLUGIN_HANDLED
}

//------------------
//	GetCurrentRankTitle()
//------------------

GetCurrentRankTitle(id)
{
	new table[32]

	get_cvar_string("rpg_rank_table", table, 31)

	// This will read the player LVL and then give him the title he needs
	new Handle:query = SQL_PrepareQuery(sql, "SELECT * FROM `%s` WHERE `lvl` <= (%d) and `lvl` ORDER BY abs(`lvl` - %d) LIMIT 1", table, stats_level[id], stats_level[id])
	if (!SQL_Execute(query))
	{
		server_print("query not loaded [title]")
		SQL_QueryError(query, sql_error, 127)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_LOAD_ADMINS", sql_error)
	} else {
		while (SQL_MoreResults(query))
		{
			new ranktitle[185]
			SQL_ReadResult(query, 1, ranktitle, 31)
			top_rank = rank_max
			rank_name[id] = ranktitle;
			SQL_NextRow(query);
		}
	}
	SQL_FreeHandle(query);
	return 0;
}

//------------------
//	ShowMyRank()
//------------------

public ShowMyRank(id)
{
	GetPosition(id);
	// Lets call the GetCurrentRankTitle(id) to make sure we get the title for the player
	GetCurrentRankTitle(id);
	new auth[33], formated_text[501];
	get_user_authid( id, auth, 32);
	LoadLevel(id, auth, false);

	format(formated_text, 500, "{DEFAULT}you are on rank {GREEN}%d{DEFAULT} of {GREEN}%d{DEFAULT} with the title: ^"{LIGHTBLUE}%s{DEFAULT}^"", ply_rank[id], top_rank, rank_name[id])
	PrintToChat(id, formated_text)
	return PLUGIN_HANDLED
}

//------------------
//	Prestige()
//------------------

public Prestige(id)
{
	if (stats_prestige[id] >= 10)
	{
		client_print( id, print_chat, "[RPG MOD] You have hit the limit, you can no longer prestige!" );
		return PLUGIN_HANDLED;
	}

	if (stats_level[id] < 800)
	{
		client_print( id, print_chat, "[RPG MOD] You must be level %d to prestige!", 800 );
		return PLUGIN_HANDLED;
	}

	// Lets reset the stuff
	stats_points[id] = 0
	stats_health_set[id] = 0
	stats_armor_set[id] = 0
	stats_health[id] = 0
	stats_armor[id] = 0
	stats_ammo[id] = 0
	stats_doublejump[id] = 0
	stats_randomweapon[id] = 0
	stats_auro[id] = 0
	stats_holyguard[id] = 0
	stats_level[id] = 0
	stats_xp[id] = 0
	stats_xp_bonus[id] = 0;

	if ( get_user_health( id ) > 100 + stats_medals[id] )
		set_user_health( id, 100 + stats_medals[id] )
	if ( get_user_armor(id) > 100 + stats_medals[id] )
		set_user_armor( id, 100 + stats_medals[id] )

	// We want to make sure he gets more prestiege
	stats_prestige[id]++;

	//===================================================
	//===================================================
	// Rewards

	new steamid[35];
	get_user_authid(id, steamid, charsmax(steamid))

	if(GetClientRewardStatus(RewardsPointer[ _Prestige_1 ], RewardsData[ _Prestige_1 ][ id ]) == _In_Progress)
	{
		RewardsData[ _Prestige_1 ][ id ]++;
		SetRewardData( steamid, RewardsInfo[ _Prestige_1 ][ _Save_Name ], RewardsData[ _Prestige_1 ][ id ] );

		// check if client just unlocked the achievement
		if(GetClientRewardStatus(RewardsPointer[ _Prestige_1 ], RewardsData[ _Prestige_1 ][ id ]) == _Unlocked)
		{
			stats_xp[id] = stats_xp[id] + RewardsInfo[ _Prestige_1 ][ _ExpGain ];
			stats_medals[id] = stats_medals[id] + RewardsInfo[ _Prestige_1 ][ _Medals ];
			ClientRewardCompleted( id, RewardsPointer[ _Prestige_1 ], .Announce = true );
		}
	}
	
	if(GetClientRewardStatus(RewardsPointer[ _Prestige_LJ ], RewardsData[ _Prestige_LJ ][ id ]) == _In_Progress)
	{
		RewardsData[ _Prestige_LJ ][ id ]++;
		SetRewardData( steamid, RewardsInfo[ _Prestige_LJ ][ _Save_Name ], RewardsData[ _Prestige_LJ ][ id ] );

		// check if client just unlocked the achievement
		if(GetClientRewardStatus(RewardsPointer[ _Prestige_LJ ], RewardsData[ _Prestige_LJ ][ id ]) == _Unlocked)
		{
			stats_xp[id] = stats_xp[id] + RewardsInfo[ _Prestige_LJ ][ _ExpGain ];
			stats_medals[id] = stats_medals[id] + RewardsInfo[ _Prestige_LJ ][ _Medals ];
			give_item(id,"item_longjump")
			ClientRewardCompleted( id, RewardsPointer[ _Prestige_LJ ], .Announce = true );
		}
	}

	if(GetClientRewardStatus(RewardsPointer[ _Prestige_2 ], RewardsData[ _Prestige_2 ][ id ]) == _In_Progress)
	{
		RewardsData[ _Prestige_2 ][ id ]++;
		SetRewardData( steamid, RewardsInfo[ _Prestige_2 ][ _Save_Name ], RewardsData[ _Prestige_2 ][ id ] );

		// check if client just unlocked the achievement
		if(GetClientRewardStatus(RewardsPointer[ _Prestige_2 ], RewardsData[ _Prestige_2 ][ id ]) == _Unlocked)
		{
			stats_xp[id] = stats_xp[id] + RewardsInfo[ _Prestige_2 ][ _ExpGain ];
			stats_medals[id] = stats_medals[id] + RewardsInfo[ _Prestige_2 ][ _Medals ];
			ClientRewardCompleted( id, RewardsPointer[ _Prestige_2 ], .Announce = true );
		}
	}

	//===================================================
	//===================================================

	// Lets add the goodies
	stats_xp_bonus[id] = floatround(stats_prestige[id] / 0.25) + SetExtraBonus;

	// Lets calculate our EXP again.
	CalculateEXP_Needed(id);

	// Lets grab our new rank title
	GetCurrentRankTitle(id);

	// Lets tell everyone that this person have just prestieged!
	new name[32];
	get_user_name(id, name, 31);
	client_print(0, print_chat, "[RPG MOD] %s have prestiged!", name);
	return PLUGIN_HANDLED
}

//------------------
//	ResetStats()
//------------------

public ResetStats(id, FullReset)
{
	new formated_text[501],
		auth[33];
	get_user_authid( id, auth, 32);
	if (FullReset)
	{
		if(ResetConvarTime[id])
			return PLUGIN_HANDLED;

		// If they wrote it by mistake, lets have a message saying (write /fullreset again before X amount of seconds)
		if(!ShouldFullReset[id])
		{
			format(formated_text, 500, "[RPG MOD] To make a full reset of your stats, write /fullreset again.")
			PrintToChat(id, formated_text)
			format(formated_text, 500, "You have 5 seconds to confirm your reset, type /fullreset if your absolutely sure.")
			PrintToChat(id, formated_text)
			ShouldFullReset[id] = true;
			set_task(5.0, "ResetConvarStatus", id)
			return PLUGIN_HANDLED;
		}
		else
			ShouldFullReset[id] = false;

		ResetConvarTime[id] = true;

		format(formated_text, 500, "[RPG MOD] Everything has now been fully reset.")
		PrintToChat(id, formated_text)

		// Now the last bit, lets reset everything
		stats_points[id] = 0
		stats_health_set[id] = 0
		stats_armor_set[id] = 0
		stats_health[id] = 0
		stats_armor[id] = 0
		stats_ammo[id] = 0
		stats_doublejump[id] = 0
		stats_randomweapon[id] = 0
		stats_auro[id] = 0
		stats_holyguard[id] = 0
		stats_level[id] = 0
		stats_xp[id] = 0
		stats_medals[id] = 0
		stats_prestige[id] = 0

		// Lets calculate our EXP again.
		CalculateEXP_Needed(id);

		// Lets grab our new rank title
		GetCurrentRankTitle(id);

		// Resets the rewards
		for( new m_iReward; m_iReward < Rewards; m_iReward++ )
			SetRewardData( auth, RewardsInfo[ m_iReward ][ _Save_Name ], 0);

		// Already have the SetCap? Lets turn it off
		if (glb_MapDefined_HasSetCap[id])
			glb_MapDefined_HasSetCap[id] = false;

		// If here is a cap, we have to redo the calculations on that.
		if (glb_MapDefined_SetEXPCap > 0 && !glb_MapDefined_HasSetCap[id])
		{
			glb_MapDefined_HasSetCap[id] = true;
			if (stats_level[id] > 1)
				stats_xp_cap[id] = floatround( 8.25 + stats_neededxp[id] + glb_MapDefined_SetEXPCap );
			else
				stats_xp_cap[id] = glb_MapDefined_SetEXPCap;
		}
	}
	else
	{
		// Now, lets convert them into points!
		new GetPoints = stats_points[id]+(stats_health_set[id]+stats_armor_set[id]+stats_health[id]+stats_armor[id]+stats_ammo[id]+stats_doublejump[id]+stats_randomweapon[id]+stats_auro[id]+stats_holyguard[id])
		stats_points[id] = GetPoints

		format(formated_text, 500, "[RPG MOD] Your abilities have been reset, and turned them into %d Skillpoints Points(s).", GetPoints)
		PrintToChat(id, formated_text)

		// Now the last bit, lets reset the abilities
		stats_health_set[id] = 0
		stats_armor_set[id] = 0
		stats_health[id] = 0
		stats_armor[id] = 0
		stats_ammo[id] = 0
		stats_doublejump[id] = 0
		stats_randomweapon[id] = 0
		stats_auro[id] = 0
		stats_holyguard[id] = 0
	}

	// Lets save the stuff on the Database
	SaveLevel(id, auth)
	return PLUGIN_HANDLED
}

//------------------
//	ResetConvarStatus()
//------------------

public ResetConvarStatus(id)
{
	if(ShouldFullReset[id]) ShouldFullReset[id] = false;
	ResetConvarTime[id] = false;
	return PLUGIN_HANDLED
}

//------------------
//	BBHelp()
//------------------

public BBHelp(id, ShowCommands)
{
	// Chat Print
	if (ShowCommands)
	{
		client_print ( id, print_chat, "The commands have been printed on your console." )
		client_print ( id, print_console, "==----------[[ SC RPG MOD ]]-------------==" )
		client_print ( id, print_console, "/version			--		Shows the current version" )
		client_print ( id, print_console, "/prestige		--		If on max level, you will reset to level 0, but gain some new cool shit." )
		client_print ( id, print_console, "/reset			--		Resets your stats (Points only)" )
		client_print ( id, print_console, "/fullreset		--		Full Reset of your stats" )
		client_print ( id, print_console, "/challenges		--		Shows your challange progress" )
		client_print ( id, print_console, "/skills			--		Set your skillpoints" )
		client_print ( id, print_console, "/skillsinfo		--		Grabs all the information of what the skills do (will print all info on the console!)" )
		if ( enable_ranking )
		{
			client_print ( id, print_console, "/top10		--		Shows the top10 players" )
			client_print ( id, print_console, "/rank		--		Shows your rank" )
		}
		client_print ( id, print_console, "==--------------------------------------==" )
	}
	else
	{
		if ( enable_ranking )
			client_print ( id, print_chat, "Available commands: /version /rank /top10 /reset /fullreset /prestige /skills /challenges" )
		else
			client_print ( id, print_chat, "Available commands: /version /reset /fullreset /prestige /skills /challenges" )
	}
	return PLUGIN_HANDLED
}

//------------------
//	hook_say()
//------------------

public hook_say(id)
{
	if (glb_MapDefined_IsDisabled)
		return PLUGIN_CONTINUE;

	new arg1[32]
	read_argv(1, arg1, 31)
	remove_quotes(arg1)

	if (equali(arg1[0], "/rpgmod") || equali(arg1[0], "/version"))
		StatsVersion(id)
	else if (equali(arg1[0], "/help"))
		BBHelp(id, true)
	else if (equali(arg1[0], "/prestige"))
		Prestige(id)
	else if (equali(arg1[0], "/reset"))
		ResetStats(id, false)
	else if (equali(arg1[0], "/fullreset"))
		ResetStats(id, true)
	else if (equali(arg1[0], "/skills"))
		RPGSkill(id)
	else if (equali(arg1[0], "/skillsinfo"))
		CVAR_SkillsInfo(id)
	else if (equali(arg1[0], "/challenges")
		|| equali(arg1[0], "/rewards")
		|| equali(arg1[0], "/progress")
	)
		CVAR_Challenges(id)
	else if (equali(arg1[0], "/rpg"))
	{
		CVAR_CMMNDS(id)
		return PLUGIN_HANDLED;
	}

	if ( enable_ranking )
	{
		if (equali(arg1[0], "/top10"))
			ShowTop10(id)
		else if (equali(arg1[0], "/rank"))
			ShowMyRank(id)
	}

	if(equali(arg1[0], "I'm Nihilanth's slave!"))
	{
		client_print(id, print_console, "Secret!!" )
		
		new steamid[35];
		get_user_authid(id, steamid, charsmax(steamid))

		if(GetClientRewardStatus(RewardsPointer[ _Secret1 ], RewardsData[ _Secret1 ][ id ]) == _In_Progress)
		{
			RewardsData[ _Secret1 ][ id ]++;
			SetRewardData( steamid, RewardsInfo[ _Secret1 ][ _Save_Name ], RewardsData[ _Secret1 ][ id ] );

			// check if client just unlocked the achievement
			if(GetClientRewardStatus(RewardsPointer[ _Secret1 ], RewardsData[ _Secret1 ][ id ]) == _Unlocked)
			{
				stats_xp[id] = stats_xp[id] + RewardsInfo[ _Secret1 ][ _ExpGain ];
				stats_medals[id] = stats_medals[id] + RewardsInfo[ _Secret1 ][ _Medals ];
				ClientRewardCompleted( id, RewardsPointer[ _Secret1 ], .Announce = true );
			}
		}
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE
}

//------------------
//	ShowTop10()
//------------------

public ShowTop10(id)
{
	static getnum

	// Lets not bug the top10 by adding more when we write /top10
	getnum = 0

	new menuBody[1515]
	new len = format(menuBody, 1514, "SC Stats -- Top10^n^n")

	new table[32],
		name[33],
		prestige[33],
		hasprestiged[33]

	get_cvar_string("rpg_table", table, 31)

	new Handle:query = SQL_PrepareQuery(sql, "SELECT `name`, `lvl`, `medals`, `prestige` FROM `%s` ORDER BY `prestige` DESC, `lvl` + 0 DESC LIMIT 10", table)

	// This is a pretty basic code, get all people from the database.
	if (!SQL_Execute(query))
	{
		server_print("GetPosition not loaded")
		SQL_QueryError(query, sql_error, 127)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_LOAD_ADMINS", sql_error)
	} else {
		while (SQL_MoreResults(query))
		{
			SQL_ReadResult(query, 0, name, 32)
			SQL_ReadResult(query, 3, prestige, 32)

			if (str_to_num(prestige) > 0)
				format(hasprestiged, 32, "(%d)", str_to_num(prestige));
			else
				hasprestiged = "";

			len += format(
				menuBody[len],
				1514-len,
				"#%d. %s %s^n",
				++getnum,
				name,
				hasprestiged
			)

			SQL_NextRow(query);
		}
	}
	SQL_FreeHandle(query);

	show_menu(id, getnum, menuBody, 8)

	return PLUGIN_CONTINUE;
}

//------------------
//	PluginThinkLoop()
//------------------

public PluginThinkLoop()
{
	if (glb_MapDefined_IsDisabled)
		return PLUGIN_HANDLED;

	new iPlayers[32],iNum
	get_players(iPlayers, iNum)
	for(new i = 0;i < iNum; i++)
	{
		new id = iPlayers[i]
		if(is_user_connected(id) && is_user_alive(id))
		{
			RegenSystem(id);

			if (stats_auro_wait[id] == 1 || stats_holyguard_wait[id] == 1)
				client_cmd(id, "spk ^"%s^"", SND_READY)

			if (stats_auro_wait[id] > 0)
				stats_auro_wait[id]--;

			if (stats_holyguard_wait[id] > 0)
				stats_holyguard_wait[id]--;
			else
				HasHolyGuard[id] = false;

			if(get_user_frags(id) > lastfrags[id]
				|| stats_xp[id] >= stats_neededxp[id]
				&& stats_neededxp[id] > 100
				&& get_user_time(id) > glb_PlyTime
				)
			{
				//Only save after every 10 frags
				lastfrags[id] = get_user_frags(id) + 10
				if (stats_level[id] < 800
					&& PlayerNotReachedCap(id,false)
					&& !glb_MapDefined_IsBlacklisted)
				{
					CalculateEXP_Add(id);
					if(stats_xp[id] >= stats_neededxp[id])
					{
						// Lets grab the exp & needed exp and save them to temp values
						new temp_exp = stats_xp[id];
						new temp_neededexp = stats_neededxp[id];

						// Reset the EXP, calculate the new needed EXP and increase our level.
						stats_xp[id] = 0;

						// Calculate the new needed EXP, and increase the level for the user
						CalculateEXP_Needed(id);
						stats_level[id]++;

						// If our current EXP goes over the needed EXP, lets remove the EXP we need, so we get correct number of EXP we have left.
						// Example:
						// temp_exp - temp_neededexp = leftover
						if (temp_exp > temp_neededexp)
							stats_xp[id] = temp_exp - temp_neededexp;

						// Lets grab our new rank title
						GetCurrentRankTitle(id);

						// Add some points!
						stats_points[id]++;

						// Play sound
						client_cmd(id, "spk ^"%s^"", SND_LVLUP)

						// Showmenu
						RPGSkill(id)

						new name[32];
						get_user_name( id, name, 31 );
						if ( stats_level[id] == 800 )
							client_print(0, print_chat, "[RPG MOD] Everyone say ^"Congratulations!!!^" to %s, who has reached Level 800!", name)
						else
							client_print(id, print_chat, "[RPG MOD] Congratulations, %s, you are now Level %i", name, stats_level[id])
					}

					new auth[33];
					get_user_authid( id, auth, 32);
					SaveLevel(id, auth)
				}
			}
			if (!FirstTimeJoining[id])
			{
				FirstTimeJoining[id] = true;
				new auth[33];
				get_user_authid( id, auth, 32);
				LoadLevel(id, auth)
				CalculateEXP_Needed(id);
				PlayerHasSpawned(id);
			}
		}
	}

	ShowPlayerInfo();

	if (glb_AuraTimer <= 0)
		glb_AuraIsActivated = false;
	else
		glb_AuraTimer--;

	if ( setranking >= 1 )
		enable_ranking = true;
	else
		enable_ranking = false;

	return PLUGIN_CONTINUE;
}

//------------------
//	client_PreThink()
//------------------

public client_PreThink(id)
{
	if (glb_MapDefined_IsDisabled)
		return PLUGIN_HANDLED;

	if(!is_user_alive(id))
		return PLUGIN_CONTINUE;

	if (stats_doublejump[id] > 0)
		SetJumping(id);

	return PLUGIN_CONTINUE;
}

//------------------
//	client_PostThink()
//------------------

public client_PostThink(id)
{
	if (glb_MapDefined_IsDisabled)
		return PLUGIN_HANDLED;

	if(!is_user_alive(id))
		return PLUGIN_CONTINUE;

	if(IsJumping[id])
	{
		new Float:velocity[3];
		entity_get_vector(id, EV_VEC_velocity, velocity);
		velocity[2] = random_float(265.0, 285.0);
		entity_set_vector(id, EV_VEC_velocity, velocity);
		IsJumping[id] = false;
	}

	if(HasAura[id])
	{
		IsInRange(id);
		stats_auro_timer[id]--;
		if (stats_auro_timer[id] <= 0)
		{
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0);
			HasAura[id] = false;
			stats_auro_wait[id] = 180 - stats_auro[id];
		}
	}
	if(HasHolyGuard[id])
	{
		stats_holyguard_timer[id]--;
		if (stats_holyguard_timer[id] <= 0)
		{
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0);
			set_user_godmode(id);
		}
	}
	return PLUGIN_CONTINUE;
}

//------------------
//	IsInRange()
//------------------

public IsInRange(id)
{
	new iPlayers[32],
		iNum,
		iPlyamount
	get_players(iPlayers, iNum)

	iPlyamount = 0;

	// Sets for the player
	set_user_health(id, rpg_get_health(id) + 300 + stats_auro[id])
	set_user_armor(id, rpg_get_armor(id) + 300 + stats_auro[id])

	for(new h=0; h < iNum; h++)
	{
		new pPlayers = iPlayers[h]
		if(is_user_alive(id) && is_user_alive(pPlayers) && pPlayers != id)
		{
			new distanceRange = 580 + stats_auro[id],
				Float:origin_i[3],
				Float:origin_pPlayers[3]

			pev(id, pev_origin, origin_i)
			pev(pPlayers, pev_origin, origin_pPlayers)

			if(get_distance_f(origin_i, origin_pPlayers) <= distanceRange)
			{
				iPlyamount++;
				new value = rpg_get_health(id) + 200 + stats_auro[id]
				// Sets for everyone
				if (get_user_health(pPlayers) < value)
					set_user_health(pPlayers, value + stats_auro[id])
				if (get_user_armor(pPlayers) < value)
					set_user_armor(pPlayers, value + stats_auro[id])
			}
		}
	}

	if (iPlyamount > 3)
	{
		new steamid[35];
		get_user_authid(id, steamid, charsmax(steamid))

		if(GetClientRewardStatus(RewardsPointer[ _TeamPlayer ], RewardsData[ _TeamPlayer ][ id ]) == _In_Progress)
		{
			RewardsData[ _TeamPlayer ][ id ]++;
			SetRewardData( steamid, RewardsInfo[ _TeamPlayer ][ _Save_Name ], RewardsData[ _TeamPlayer ][ id ] );

			// check if client just unlocked the achievement
			if(GetClientRewardStatus(RewardsPointer[ _TeamPlayer ], RewardsData[ _TeamPlayer ][ id ]) == _Unlocked)
			{
				stats_xp[id] = stats_xp[id] + RewardsInfo[ _TeamPlayer ][ _ExpGain ];
				stats_medals[id] = stats_medals[id] + RewardsInfo[ _TeamPlayer ][ _Medals ];
				ClientRewardCompleted( id, RewardsPointer[ _TeamPlayer ], .Announce = true );
			}
		}
	}
}

//------------------
//	SetJumping()
//------------------

public SetJumping(id)
{
	new button_pressed = get_user_button(id);
	new button_pressed_old = get_user_oldbutton(id);

	if((button_pressed & IN_JUMP) && !(get_entity_flags(id) & FL_ONGROUND) && !(button_pressed_old & IN_JUMP))
	{
		if(stats_doublejump_temp[id] < stats_doublejump[id] && PlayerNotReachedJumpCap(id))
		{
			client_cmd(id, "spk ^"%s^"", SND_JUMP)
			IsJumping[id] = true;
			stats_doublejump_temp[id]++;
			return PLUGIN_CONTINUE;
		}
	}
	if(stats_doublejump_temp[id] > 0 && (get_entity_flags(id) & FL_ONGROUND))
	{
		client_cmd(id, "spk ^"%s^"", SND_JUMP_LAND)
		stats_doublejump_temp[id] = 0;
		return PLUGIN_CONTINUE;
	}
	if((button_pressed & IN_JUMP) && (get_entity_flags(id) & FL_ONGROUND))
	{
		stats_doublejump_temp[id] = 0;
		return PLUGIN_CONTINUE;
	}
	
	return PLUGIN_CONTINUE;
}

//------------------
//	RegenSystem()
//------------------

public RegenSystem(id)
{
	// Regens the health
	if (stats_health[id] > 0 && !PlayerIsHurt[id])
		if(get_user_health(id) < rpg_get_health(id))
			set_user_health(id, get_user_health(id) + 5 + stats_health[id])

	// Regens the armor
	if (stats_armor[id] > 0 && !PlayerIsHurt[id])
		if(get_user_armor(id) < rpg_get_armor(id))
			set_user_armor(id, get_user_armor(id) + 5 + stats_armor[id])

	// Regens the ammo
	if (stats_ammo[id] > 0 && stats_ammo_wait[id] <= 0)
	{
		if (glb_MapDefined_AmmoRegen > 0 || glb_MapDefined_AmmoRegen > stats_ammo[id])
			stats_ammo_wait[id] = glb_MapDefined_AmmoRegen - stats_ammo[id] - stats_prestige[id];
		else
			stats_ammo_wait[id] = 65 - stats_ammo[id] - stats_prestige[id];
		ObtainAmmo_Find(id);
	}
	else
		stats_ammo_wait[id]--;

	// Random Weapon
	if (stats_randomweapon[id] > 0 && stats_randomweapon_wait[id] <= 0)
	{
		if (glb_MapDefined_WepRandomizer > 0)
			stats_randomweapon_wait[id] = glb_MapDefined_WepRandomizer - stats_randomweapon[id];
		else
			stats_randomweapon_wait[id] = 185 - stats_randomweapon[id];
		ObtainWeapon_Find(id);
	}
	else
		stats_randomweapon_wait[id]--;
}

//------------------
//	ObtainAmmo_Find()
//------------------

public ObtainAmmo_Find(id)
{
	new configsDir[64];
	get_configsdir(configsDir, 63);

	format(configsDir, 63, "%s/sc_rpg/randomammo.ini", configsDir);

	// Lets have the weaponid on -1, so it will be random
	ObtainAmmo_Grab(configsDir, id, 0)
}

//------------------
//	ObtainWeapon_Find()
//------------------

public ObtainWeapon_Find(id)
{
	new configsDir[64],
		m_iRandomID = 0,
		bool:bHasWeapon = false,
		strWeapon[32],
		strWeapons[32],
		m_iWeapon = 0,
		iWeaponNum;
	
	get_configsdir(configsDir, 63);
	
	format(configsDir, 63, "%s/sc_rpg/randomweapon.ini", configsDir);
	
	if (!file_exists(configsDir))
	{
		server_print("[ObtainWeapon_Find] File ^"%s^" doesn't exist.", configsDir)
		return;
	}
	
	new File=fopen(configsDir,"r");
	
	if (File)
	{
		new Text[512],
			WeaponID[32],
			RandomID[32];

		while (!feof(File))
		{
			fgets(File, Text, sizeof(Text)-1);

			trim(Text);

			// comment
			if (Text[0]==';')
				continue;

			WeaponID[0]=0;
			RandomID[0]=0;

			// not enough parameters
			if (parse(Text, WeaponID, sizeof(WeaponID)-1, RandomID, sizeof(RandomID)-1) < 2)
				continue;

			if(str_to_num(RandomID) <= stats_randomweapon[id])
			{
				g_array[m_iRandomID] = WeaponID;
				m_iRandomID++;
			}
		}
		fclose(File);
	}
	
	new rndnum = random_num(0, m_iRandomID-1);
	
	/*
	JonnyBoy0719:
		get_user_weapons does not work, and will hopefully be replaced with an Angelscript system later on.
		This code will still be in here, if it will be used for any other goldsrc mod (converting it over to another mod)
	*/
	
	// Check if he has the weapon
	get_user_weapons(id, strWeapons, iWeaponNum);
	
	for (new i = 0; i < iWeaponNum; i++) 
	{
		get_weaponname(strWeapons[i], strWeapon,31);
		
		if(equali(strWeapon, g_array[rndnum])
			|| !equali(strWeapon, "weapon_snark")	// We do not want to set this to true, if its 1 of these
			|| !equali(strWeapon, "weapon_tripmine")
			|| !equali(strWeapon, "weapon_satchel"))
		{
			bHasWeapon = true;
			m_iWeapon = i;
		}
	}
	
	// its true, he has da weapon!
	if(bHasWeapon)
	{
		new strdir[64];
		get_configsdir(strdir, 63);
		
		format(strdir, 63, "%s/sc_rpg/randomammo.ini", strdir);
		
		ObtainAmmo_Grab(strdir, id, m_iWeapon)
	}
	else // if false, run this instead!
	{
		client_cmd(id, "spk ^"%s^"", SND_HOLYWEP)
		
		client_print(id, print_chat, "You have been gifted ^"%s^" by the gods!", rpg_get_weapontitle(g_array[rndnum]))
		
		new m_iSecretKey = random_num(0, 9000000000);
		
		// Sets the secret key
		client_cmd(id, ".rpg_mod_skey %d", m_iSecretKey);
		
		// Lets use AngelScript for this part, so we don't spawn weapons on the world...
		client_cmd(id, ".rpg_mod_gwep %s %d", g_array[rndnum], m_iSecretKey);
		
		// 5 more snarks!
		if (stats_randomweapon[id] >= AB_WEAPON_MAX && equali(g_array[rndnum], "weapon_snark"))
			client_cmd(id, ".rpg_mod_gwep %s %d", g_array[rndnum], m_iSecretKey);
		else if (equali(g_array[rndnum], "weapon_tripmine"))
		{
			// gives 3 more
			client_cmd(id, ".rpg_mod_gwep %s %d", g_array[rndnum], m_iSecretKey);
			client_cmd(id, ".rpg_mod_gwep %s %d", g_array[rndnum], m_iSecretKey);
			client_cmd(id, ".rpg_mod_gwep %s %d", g_array[rndnum], m_iSecretKey);
		}
		else if (equali(g_array[rndnum], "weapon_satchel"))
		{
			// gives 4 more
			client_cmd(id, ".rpg_mod_gwep %s %d", g_array[rndnum], m_iSecretKey);
			client_cmd(id, ".rpg_mod_gwep %s %d", g_array[rndnum], m_iSecretKey);
			client_cmd(id, ".rpg_mod_gwep %s %d", g_array[rndnum], m_iSecretKey);
			client_cmd(id, ".rpg_mod_gwep %s %d", g_array[rndnum], m_iSecretKey);
		}
	}
}

//------------------
//	ObtainAmmo_Grab()
//------------------

ObtainAmmo_Grab(szFilename[], id, weaponid)
{
	if (!file_exists(szFilename))
	{
		server_print("[ObtainAmmo_Grab] File ^"%s^" doesn't exist.", szFilename)
		return;
	}
	
	new File=fopen(szFilename,"r");
	
	new clip, ammo;
	new CurrentWeaponID = get_user_weapon(id, clip, ammo);
	
	// Its more than -1, lets use our defined id
	if(weaponid > 0)
		CurrentWeaponID = weaponid;
	
	// if the highest ammo level
	// and weapon string is displacer, lets give some more ammo
	if (stats_ammo[id] >= AB_AMMO_MAX && equali(rpg_get_weapon_string(CurrentWeaponID), "weapon_displacer"))
		give_item(id, "ammo_gaussclip")
	
	if (File)
	{
		new Text[512],
			WeaponID[32],
			Ammo[230];

		while (!feof(File))
		{
			fgets(File, Text, sizeof(Text)-1);

			trim(Text);

			// comment
			if (Text[0]==';')
				continue;

			WeaponID[0]=0;
			Ammo[0]=0;

			// not enough parameters
			if (parse(Text, WeaponID, sizeof(WeaponID)-1, Ammo, sizeof(Ammo)-1) < 2)
				continue;

			if(equali(rpg_get_weapon_string(CurrentWeaponID), WeaponID))
			{
				ExplodeString( g_array, 10, 227, Ammo, ',' );
				new iAmmo = -1;
				while(iAmmo++ < sizeof(g_array)-1)
				{
					get_user_ammo(id, CurrentWeaponID, clip, ammo)
					if(ammo < rpg_get_weapon_maxammo(CurrentWeaponID))
					{
						if(containi(g_array[iAmmo], "weapon_") != -1)
							continue;
						if(equali(g_array[iAmmo], "random"))
							GiveRandomAmmo(id);
						else
							give_item(id, g_array[iAmmo])
					}
				}
			}
		}
		fclose(File);
	}
	
	return;
}

//------------------
//	GiveRandomAmmo()
//------------------

public GiveRandomAmmo(id)
{
	new number = random_num(0,6)
	switch (number)
	{
		case 1:
		{
			give_item(id,"ammo_crossbow")
			give_item(id,"ammo_9mmAR")
		}
		case 2:
		{
			give_item(id,"ammo_rpgclip")
			give_item(id,"ammo_357")
		}
		case 5:
		{
			give_item(id,"ammo_357")
			give_item(id,"ammo_9mmAR")
			give_item(id,"ammo_buckshot")
		}
		case 6:
		{
			give_item(id,"ammo_sporeclip")
			give_item(id,"ammo_357")
			give_item(id,"ammo_762")
		}
		default:
		{
			give_item(id,"ammo_762")
			give_item(id,"ammo_556")
			give_item(id,"ammo_9mmAR")
			give_item(id,"ammo_sporeclip")
		}
	}
}

//------------------
//	ShowPlayerInfo()
//------------------

public ShowPlayerInfo()
{
	new iPlayers[32],
		iNum

	get_players(iPlayers, iNum)
	for(new g = 0; g < iNum; g++)
	{
		new i = iPlayers[g]
		if(is_user_connected(i) && !glb_MapDefined_IsDisabled)
		{
			new steamid[35];
			get_user_authid(i, steamid, charsmax(steamid))
			set_hudmessage(50,135,180,0.7,0.04,0,1.0,255.0,0.0,0.0,0)
			//set_hudmessage(50,135,180,-1.0,0.04,0,1.0,255.0,0.0,0.0,get_cvar_num("scxpm_hud_channel"))
			switch(stats_level[i])
			{
				case 800:
				{
					show_hudmessage(i,
						"Level:   800 / 800^nRank:   Highest Force Leader^nMedals:   %i / 15^nHealth:   %i^nArmor:   %i^nPrestige:   %i / 10^nYour SteamID:   %s",
						stats_medals[i],
						get_user_health( i ),
						get_user_armor( i ),
						stats_prestige[i],
						steamid
					)
				}
				default:
				{
					if (glb_MapDefined_IsBlacklisted)
					{
						show_hudmessage(i,
							"Level:   %i / 800^nRank:   %s^nMedals:   %i / 15^nHealth:   %i^nArmor:   %i^nPrestige:   %i / 10^nYour SteamID:   %s",
							stats_level[i],
							rank_name[i],
							stats_medals[i],
							get_user_health( i ),
							get_user_armor( i ),
							stats_prestige[i],
							steamid
						)
					}
					else
					{
						if (PlayerNotReachedCap(i))
						{
							show_hudmessage(i,
								"Exp.:   %i / %i  (+%i)^nLevel:   %i / 800^nRank:   %s^nMedals:   %i / 15^nHealth:   %i^nArmor:   %i^nPrestige:   %i / 10^nYour SteamID:   %s",
								stats_xp[i],
								stats_neededxp[i],
								stats_neededxp[i] - stats_xp[i],
								stats_level[i],
								rank_name[i],
								stats_medals[i],
								get_user_health( i ),
								get_user_armor( i ),
								stats_prestige[i],
								steamid
							)
						}
						else
						{
							show_hudmessage(i,
								"Exp.:   %i / %i  (Reached Map Cap)^nLevel:   %i / 800^nRank:   %s^nMedals:   %i / 15^nHealth:   %i^nArmor:   %i^nPrestige:   %i / 10^nYour SteamID:   %s",
								stats_xp[i],
								stats_neededxp[i],
								stats_level[i],
								rank_name[i],
								stats_medals[i],
								get_user_health( i ),
								get_user_armor( i ),
								stats_prestige[i],
								steamid
							)
						}
					}
				}
			}

			new Float:SetTime = 1.2,
				SetStringValue[3583];
			/*
			if(stats_auro_wait[i] <= 0 && !glb_AuraIsActivated || stats_holyguard_wait[i] <= 0 && !HasHolyGuard[i]) // Ready
				set_hudmessage(85, 255, 0, 0.02, 0.70, 0, 6.0, SetTime, 0.5, 0.15, -1)
			else if (stats_auro_wait[i] > 0 || stats_holyguard_wait[i] > 0) // Charging
				set_hudmessage(0, 200, 196, 0.02, 0.70, 0, 6.0, SetTime, 0.5, 0.15, -1)
			else // Default
				set_hudmessage(85, 255, 0, 0.02, 0.70, 0, 6.0, SetTime, 0.5, 0.15, -1)
			*/
			set_hudmessage(0, 200, 196, 0.02, 0.70, 0, 6.0, SetTime, 0.5, 0.15, -1)

			if(stats_points[i] > 0)
				format(SetStringValue, 3582, "You have %d skillpoints available!^nWrite /skills to access the menu!", stats_points[i])
			else
			{
				if(stats_auro_wait[i] <= 0)
				{
					if (stats_auro[i] > 0)
						if (glb_AuraIsActivated)
							format(SetStringValue, 3582, "%s can't be used right now!", AB_AURA)
						else
							format(SetStringValue, 3582, "%s^n[Press 'take cover' to use]",AB_AURA)
				}
				else if(stats_auro_wait[i] > 0)
				{
					new SetValue[32];

					if (stats_auro_wait[i] >= 120)
						SetValue = "[----------]";
					else if (stats_auro_wait[i] >= 90)
						SetValue = "[#---------]";
					else if (stats_auro_wait[i] >= 80)
						SetValue = "[##--------]";
					else if (stats_auro_wait[i] >= 70)
						SetValue = "[###-------]";
					else if (stats_auro_wait[i] >= 60)
						SetValue = "[####------]";
					else if (stats_auro_wait[i] >= 50)
						SetValue = "[#####-----]";
					else if (stats_auro_wait[i] >= 40)
						SetValue = "[######----]";
					else if (stats_auro_wait[i] >= 30)
						SetValue = "[#######---]";
					else if (stats_auro_wait[i] >= 20)
						SetValue = "[########--]";
					else if (stats_auro_wait[i] >= 10)
						SetValue = "[#########-]";
					else
						SetValue = "[##########]";

					format(SetStringValue, 3582, "%s^n%s", AB_AURA, SetValue)
				}
				if(stats_holyguard_wait[i] <= 0)
				{
					if (stats_holyguard[i] > 0)
						if (HasHolyGuard[i])
							format(SetStringValue, 3582, "%s^n^n%s can't be used right now!", SetStringValue, AB_HOLYGUARD)
						else
							format(SetStringValue, 3582, "%s^n^n%s^n[Press 'medic' to use]", SetStringValue, AB_HOLYGUARD)
				}
				else if(stats_holyguard_wait[i] > 0)
				{
					new SetValue[32];

					if (stats_holyguard_wait[i] >= 300)
						SetValue = "[----------]";
					else if (stats_holyguard_wait[i] >= 290)
						SetValue = "[|---------]";
					else if (stats_holyguard_wait[i] >= 280)
						SetValue = "[#---------]";
					else if (stats_holyguard_wait[i] >= 270)
						SetValue = "[#|--------]";
					else if (stats_holyguard_wait[i] >= 260)
						SetValue = "[##--------]";
					else if (stats_holyguard_wait[i] >= 250)
						SetValue = "[##|-------]";
					else if (stats_holyguard_wait[i] >= 200)
						SetValue = "[###-------]";
					else if (stats_holyguard_wait[i] >= 150)
						SetValue = "[###|------]";
					else if (stats_holyguard_wait[i] >= 100)
						SetValue = "[####------]";
					else if (stats_holyguard_wait[i] >= 90)
						SetValue = "[####|-----]";
					else if (stats_holyguard_wait[i] >= 80)
						SetValue = "[#####-----]";
					else if (stats_holyguard_wait[i] >= 70)
						SetValue = "[#####|----]";
					else if (stats_holyguard_wait[i] >= 60)
						SetValue = "[######----]";
					else if (stats_holyguard_wait[i] >= 50)
						SetValue = "[######|---]";
					else if (stats_holyguard_wait[i] >= 40)
						SetValue = "[#######---]";
					else if (stats_holyguard_wait[i] >= 30)
						SetValue = "[#######|--]";
					else if (stats_holyguard_wait[i] >= 20)
						SetValue = "[########|-]";
					else if (stats_holyguard_wait[i] >= 10)
						SetValue = "[#########-]";
					else
						SetValue = "[##########]";

					format(SetStringValue, 3582, "%s^n^n%s^n%s", SetStringValue, AB_HOLYGUARD, SetValue)
				}
			}
			show_hudmessage(i, "%s", SetStringValue)
		}
	}
}

//------------------
//	PluginAdverts()
//------------------

public PluginAdverts()
{
	if (glb_MapDefined_IsDisabled)
		return PLUGIN_HANDLED;
	
	AdvertSetup++;
	
	// It can't go over the max amount.
	if (AdvertSetup >= AdvertSetup_Max)
		AdvertSetup = 0;

	new iPlayers[32],
		iNum,
		formated_text[501]
	
	get_players(iPlayers, iNum)
	for(new i = 0; i < iNum; i++)
	{
		new id=iPlayers[i]
		if(is_user_connected(id))
		{
			switch (AdvertSetup)
			{
				// Here you can setup your adverts, here are the pre-defined ones.
				case 0:
					format(formated_text, 500, "[RPG MOD] Want to see what commands you can write? write /help")
				case 5:
					format(formated_text, 500, "[RPG MOD] Want to reset your stats? write /reset")
				case 10:
					format(formated_text, 500, "This server is using Sven Co-op RPG Mod Version %s by JonnyBoy0719", VERSION)
			}
			PrintToChat(id, formated_text)
		}
	}
	return PLUGIN_CONTINUE;
}

//------------------
//	client_connect()
//------------------

public client_connect(id)
{
	// Connected
	new players[32],
		num,
		i,
		formated_text[501],
		plyname[32],
		auth[33];
	
	get_user_name(id, plyname, 31)
	get_players(players, num)
	
	for (i = 0; i<num; i++)
	{
		if (is_user_connected(players[i]) && !is_user_bot(players[i]))
		{
			get_user_authid(id, auth, 32)
			if (is_user_admin(players[i]))
				format(formated_text, 500, "Player %s <^"%s^"> is now connecting...", plyname, auth)
			else
				format(formated_text, 500, "Player %s is now connecting...", plyname)
			PrintToChat(players[i], formated_text)
		}
	}
	
	if (glb_MapDefined_IsDisabled)
		return;
	
	FirstTimeJoining[id] = false;
	HasSpawned[id] = false;
	HasLoadedStats[id] = false;
	stats_level[id] = 0;
}

//------------------
//	TaskDelayConnect()
//------------------

public TaskDelayConnect( id )
{
	// our client id (id) = (TaskId - TaskIdDelayConnect (3799))
	//new id = TaskId - 3799;

	new steamid[35];
	get_user_authid(id, steamid, charsmax(steamid))

	for( new m_iReward; m_iReward < Rewards; m_iReward++ )
	{
		RewardsData[ m_iReward ][ id ] = GetRewardData(steamid, RewardsInfo[ m_iReward ][ _Save_Name ]);

		if( GetClientRewardStatus( RewardsPointer[ m_iReward ], RewardsData[ m_iReward ][ id ] ) == _In_Progress )
			SetRewardData( steamid, RewardsInfo[ m_iReward ][ _Save_Name ], RewardsData[ m_iReward ][ id ]);
		else
			ClientRewardCompleted( id, RewardsPointer[ m_iReward ], .Announce = false );
	}

	// remove task
	//remove_task( id + 3799 );
}

//------------------
//	PluginThink()
//------------------

public PluginThink(id)
{
	if (glb_MapDefined_IsDisabled)
		return;

	new deadflag = pev(id, pev_deadflag)
	if( !deadflag && lastDeadflag[id] )
		OnPlayerSpawn(id)
	lastDeadflag[id] = deadflag
}

//------------------
//	PlayerHasSpawned()
//------------------

public PlayerHasSpawned(id)
{
	PlayerIsHurt[id] = false;
	IsJumping[id] = false;
	HasAura[id] = false;
	HasHolyGuard[id] = false;

	stats_doublejump_temp[id] = 0;
	
	// Prestige rewards!
	if (stats_prestige[id] >= 2)
		give_item(id,"item_longjump")

	// Lets calculate
	if (stats_prestige[id] > 0)
		stats_xp_bonus[id] = floatround(stats_prestige[id] / 0.25) + SetExtraBonus;
	else
		stats_xp_bonus[id] = 0;

	set_user_health(id, rpg_get_health(id));
	set_user_armor(id, rpg_get_armor(id));
}
//------------------
//	OnPlayerSpawn()
//------------------

public OnPlayerSpawn(id)
{
	if (glb_MapDefined_IsDisabled)
		return;
	
	PlayerHasSpawned(id);
	
	// Checks if the player has spawned (so we don't save the player stats when they join and then just leaves directly after)
	if ( !HasSpawned[id] )
	{
		stats_randomweapon_wait[id] = 30;
		stats_holyguard_timer[id] = 30;
		stats_auro_timer[id] = 30;
		stats_ammo_wait[id] = 30;
		
		HasSpawned[id] = true;
	}
}

//------------------
//	HelpOnConnect()
//------------------

public HelpOnConnect(id)
{
	new hostname[101], plyname[32], formated_text[501]
	get_user_name(0,hostname,100)
	get_user_name(id, plyname, 31)

	if ( enable_ranking )
	{
		GetPosition(id);
		format(formated_text, 500, "Welcome %s to %s! You are on rank %d.", plyname, hostname, ply_rank[id])
		PrintToChat(id, formated_text)
	}
	else
	{
		format(formated_text, 500, "Welcome %s to %s!", plyname, hostname)
		PrintToChat(id, formated_text)
	}

	BBHelp(id,false)
}

//------------------
//	ShowStatsOnSpawn()
//------------------

public ShowStatsOnSpawn(id)
{
	TaskDelayConnect(id);
	
	new players[32],num,i;
	get_players(players, num)
	for (i=0; i<num; i++)
	{
		if (is_user_connected(players[i]) && !is_user_bot(players[i]))
		{
			if (players[i] == id)
			{
				ShowMyRank(id);
				continue;
			}
			new plyname[32], formated_text[501]
			get_user_name(id, plyname, 31)
			GetCurrentRankTitle(id)
			if (!equali(rank_name[id], "Loading..."))
				format(formated_text, 500, "%s is %s. Ranked %d of %d.", plyname, rank_name[id], ply_rank[id], top_rank)
			else
				format(formated_text, 500, "%s has joined for the first time!", plyname)
			PrintToChat( players[i], formated_text)
		}
	}
}

public PrintToChat(id, string[])
{
	// SC doesn't support custom chat colors...
	replace_all(string, 500, "{NORMAL}", "");
	replace_all(string, 500, "{ADDITIVE}", "");
	replace_all(string, 500, "{DEFAULT}", "");
	replace_all(string, 500, "{RED}", "");
	replace_all(string, 500, "{GREEN}", "");
	replace_all(string, 500, "{BLUE}", "");
	replace_all(string, 500, "{ORANGE}", "");
	replace_all(string, 500, "{BROWN}", "");
	replace_all(string, 500, "{LIGHTBLUE}", "");
	replace_all(string, 500, "{GRAY}", "");
	
	// Engine specific
	new map_cur[33],
		map_time_int = get_timeleft(),
		map_time[33]
	
	get_mapname(map_cur, 32)
	format(map_time, 32, "%d", map_time_int)
	
	replace_all(string, 500, "{CURMAP}", map_cur);
	replace_all(string, 500, "{TIMELEFT}", map_time);

	client_print(id, print_chat, string);

	return PLUGIN_CONTINUE;
}

//------------------
//	CalculateEXP_Add()
//------------------

public CalculateEXP_Add(id)
{
	new myfrags_divider;

	if (get_user_frags(id) >= 1000)
		myfrags_divider = 20;
	else if (get_user_frags(id) >= 10000)
		myfrags_divider = 200;
	else if (get_user_frags(id) >= 100000)
		myfrags_divider = 2000;
	else if (get_user_frags(id) >= 1000000)
		myfrags_divider = 20000;
	else
		myfrags_divider = 2;

	new rndnum = random_num(8, 100);
	new rndnum_medium = random_num(150, 400);
	new rndnum_big = random_num(500, 2500);

	new Float:m_fgrb_vlues = float( stats_xp[id] + stats_level[id] ) + float( get_user_frags(id) / myfrags_divider ) * 5.35;

	if (stats_level[id] < 100)
		if (stats_level[id] > 5)
			m_fgrb_vlues = m_fgrb_vlues * float(stats_level[id]) / 2.25;
		else
			m_fgrb_vlues = m_fgrb_vlues * float(stats_level[id]);
	else if (stats_level[id] >= 100)
		m_fgrb_vlues = m_fgrb_vlues + float(rndnum + rndnum_big - rndnum_medium);

	stats_xp[id] = floatround( m_fgrb_vlues + rndnum ) + stats_xp_bonus[id] + SetExtraBonus;
}

//------------------
//	CalculateEXP_Needed()
//------------------

public CalculateEXP_Needed(id)
{
	new Float:m_fgrb_lvl = float( stats_level[id] ) * 70.0;
	new Float:m_fgrb_lvlt = float( stats_level[id] ) * float( stats_level[id] ) * 3.5;
	stats_neededxp[id] = floatround( m_fgrb_lvl + m_fgrb_lvlt + 30.0 );
}

//------------------
//	client_disconnect()
//------------------

public client_disconnect(id)
{
	// reset variable in case played indexes are magically switched and another client gets another set of connections
	for( new m_iReward; m_iReward < Rewards; m_iReward++ )
		RewardsData[m_iReward][id] = 0;
	
	if(HasSpawned[id])
		HasSpawned[id] = false;
	
	if(HasLoadedStats[id])
		HasLoadedStats[id] = false;
	
	FirstTimeJoining[id] = false;
	
	if (HasAura[id])
		glb_AuraIsActivated = false;
	
	PlayerIsHurt[id] = false;
	IsJumping[id] = false;
	HasAura[id] = false;
	HasHolyGuard[id] = false;
	
	stats_doublejump_temp[id] = 0;
	stats_randomweapon_wait[id] = 0;
	stats_auro_timer[id] = 0;
	stats_holyguard_timer[id] = 0;
	stats_ammo_wait[id] = 0;
	
	// Disconnected
	new players[32],
		num,
		i,
		plyname[32],
		formated_text[501],
		auth[33];
	
	get_players(players, num)
	get_user_name(id, plyname, 31)
	
	for (i = 0; i<num; i++)
	{
		if (is_user_connected(players[i]) && !is_user_bot(players[i]))
		{
			get_user_authid(id, auth, 32)
			if (is_user_admin(players[i]))
				format(formated_text, 500, "Player %s <^"%s^"> has left the game...", plyname, auth)
			else
				format(formated_text, 500, "Player %s has left the game...", plyname)
			PrintToChat(players[i], formated_text)
		}
	}
}

// ============================================================//
//                          [~ Saving datas ~]			       //
// ============================================================//

//------------------
//	SQL_Init()
//------------------
public SQL_Init()
{
	static szHost[64], szUser[32], szPass[32], szDB[128];
	static get_type[12], set_type[12]

	get_pcvar_string( mysqlx_host, szHost, 63 );
	get_pcvar_string( mysqlx_user, szUser, 31 );
	get_pcvar_string( mysqlx_type, set_type, 11);
	get_pcvar_string( mysqlx_pass, szPass, 31 );
	get_pcvar_string( mysqlx_db, szDB, 127 );
	
	SQL_GetAffinity(get_type, 12);
	
	sql_db = SQL_MakeDbTuple( szHost, szUser, szPass, szDB );
	
	sql = SQL_Connect(sql_db, sql_errno, sql_error, 127)

	if (sql == Empty_Handle)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_CON", sql_error)

	if (!equali(get_type, set_type))
		if (!SQL_SetAffinity(set_type))
			log_amx("Failed to set affinity from %s to %s.", get_type, set_type);
}

//------------------
//	SaveLevel()
//------------------

SaveLevel(id, auth[])
{
	new table[32]

	get_cvar_string("rpg_table", table, 31)

	new Handle:query = SQL_PrepareQuery(sql, "SELECT * FROM `%s` WHERE (`authid` = '%s')", table, auth)

	if (!SQL_Execute(query))
	{
		server_print("query not saved")
		SQL_QueryError(query, sql_error, 127)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_LOAD_ADMINS", sql_error)
	} else {
		new plyname[32]
		get_user_name(id, plyname, 31)
		SQL_QueryAndIgnore(sql,
			"UPDATE `%s` SET `name` = '%s', `lvl` = %d, `skill_hp` = %i, `skill_sethp` = %i, `skill_armor` = %i, `skill_setarmor` = %i, `skill_doublejump` = %d, `skill_aura` = %d, `skill_holyguard` = %d, `skill_ammo` = %d, `skill_weapon` = %d, `points` = %d, `medals` = %d, `prestige` = %d, `exp` = %d WHERE `authid` = '%s';",
			table,
			plyname,
			stats_level[id],
			stats_health[id],
			stats_health_set[id],
			stats_armor[id],
			stats_armor_set[id],
			stats_doublejump[id],
			stats_auro[id],
			stats_holyguard[id],
			stats_ammo[id],
			stats_randomweapon[id],
			stats_points[id],
			stats_medals[id],
			stats_prestige[id],
			stats_xp[id],
			auth
		)
	}

	SQL_FreeHandle(query)
	SQL_FreeHandle(sql)
}

//------------------
//	LoadLevel()
//------------------

LoadLevel(id, auth[], LoadMyStats = true)
{
	// This will fix some minor bugs when joining.
	rank_max = 0

	new table[32], table2[32]

	get_cvar_string("rpg_table", table, 31)
	get_cvar_string("rpg_rank_table", table2, 31)

	new Handle:query = SQL_PrepareQuery(sql, "SELECT * FROM `%s` WHERE (`authid` = '%s')", table, auth)
	new Handle:query_g = SQL_PrepareQuery(sql, "SELECT `authid` FROM `%s`", table)

	// This is a pretty basic code, get all people from the database.
	if (!SQL_Execute(query_g))
	{
		server_print("rpg_table doesn't exist?")
		SQL_QueryError(query_g, sql_error, 127)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_LOAD_ADMINS", sql_error)
	} else {
		while (SQL_MoreResults(query_g))
		{
			rank_max++;
			SQL_NextRow(query_g);
		}
	}
	SQL_FreeHandle(query_g);

	if (!SQL_Execute(query))
	{
		server_print("LoadStats query has stopped due to errors.")
		SQL_QueryError(query, sql_error, 127)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_LOAD_ADMINS", sql_error)
	} else if (SQL_NumResults(query)) {
		server_print("loaded stats for:^nID: ^"%s^"", auth)

		HasLoadedStats[id] = true;

		new hps,
			hps_set,
			armor,
			armor_set,
			lvl,
			ammo,
			holyguard,
			doublejump,
			auro,
			weapon,
			points,
			medals,
			prestige,
			exp;

		exp = SQL_FieldNameToNum(query, "exp");
		lvl = SQL_FieldNameToNum(query, "lvl");
		hps = SQL_FieldNameToNum(query, "skill_hp");
		hps_set = SQL_FieldNameToNum(query, "skill_sethp");
		armor = SQL_FieldNameToNum(query, "skill_armor");
		armor_set = SQL_FieldNameToNum(query, "skill_setarmor");
		holyguard = SQL_FieldNameToNum(query, "skill_holyguard");
		ammo = SQL_FieldNameToNum(query, "skill_ammo");
		doublejump = SQL_FieldNameToNum(query, "skill_doublejump");
		auro = SQL_FieldNameToNum(query, "skill_aura");
		weapon = SQL_FieldNameToNum(query, "skill_weapon");
		points = SQL_FieldNameToNum(query, "points");
		medals = SQL_FieldNameToNum(query, "medals");
		prestige = SQL_FieldNameToNum(query, "prestige");

		new sql_lvl,
			sql_exp,
			sql_ammo,
			sql_hps,
			sql_hps_set,
			sql_armor,
			sql_armor_set,
			sql_holyguard,
			sql_doublejump,
			sql_auro,
			sql_weapon,
			sql_points,
			sql_medals,
			sql_prestige;

		while (SQL_MoreResults(query))
		{
			if (LoadMyStats)
			{
				sql_lvl = SQL_ReadResult(query, lvl);
				sql_exp = SQL_ReadResult(query, exp);
				sql_ammo = SQL_ReadResult(query, ammo);
				sql_hps = SQL_ReadResult(query, hps);
				sql_hps_set = SQL_ReadResult(query, hps_set);
				sql_armor = SQL_ReadResult(query, armor);
				sql_armor_set = SQL_ReadResult(query, armor_set);
				sql_holyguard = SQL_ReadResult(query, holyguard);
				sql_doublejump = SQL_ReadResult(query, doublejump);
				sql_auro = SQL_ReadResult(query, auro);
				sql_weapon = SQL_ReadResult(query, weapon);
				sql_points = SQL_ReadResult(query, points);
				sql_medals = SQL_ReadResult(query, medals);
				sql_prestige = SQL_ReadResult(query, prestige);

				//-----
				stats_health[id] = sql_hps;
				stats_health_set[id] = sql_hps_set;
				stats_armor[id] = sql_armor;
				stats_armor_set[id] = sql_armor_set;
				stats_holyguard[id] = sql_holyguard;
				stats_doublejump[id] = sql_doublejump;
				stats_auro[id] = sql_auro;
				stats_ammo[id] = sql_ammo;
				stats_randomweapon[id] = sql_weapon;
				//-----
				stats_level[id] = sql_lvl;
				stats_xp[id] = sql_exp;
				//-----
				stats_medals[id] = sql_medals;
				stats_prestige[id] = sql_prestige;
				stats_points[id] = sql_points;
				//-----

				//SaveDate(auth);
				//UpdateConnection(id, auth);
			}

			SQL_NextRow(query);
		}
	} else {
		// The user doesn't exist, lets stop the process.
		return;
	}

	// This will read the player LVL and then give him the title he needs
	new Handle:query2 = SQL_PrepareQuery(sql, "SELECT * FROM `%s` WHERE `lvl` <= (%d) and `lvl` ORDER BY abs(`lvl` - %d) LIMIT 1", table2, stats_level[id], stats_level[id])
	if (!SQL_Execute(query2))
	{
		server_print("query not loaded [query2]")
		SQL_QueryError(query2, sql_error, 127)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_LOAD_ADMINS", sql_error)
	} else {
		while (SQL_MoreResults(query2))
		{
			// Not the best code, this needs improvements...
			new ranktitle[185]
			SQL_ReadResult(query2, 1, ranktitle, 31)
			// This only gets the max players on the database
			top_rank = rank_max
			// This reads the players EXP, and then checks with other players EXP to get the players rank
			new Position = GetPosition(id);
			ply_rank[id] = Position;
			// Sets the title
			rank_name[id] = ranktitle;
			SQL_NextRow(query2);
		}
	}

	SQL_FreeHandle(query2);
	SQL_FreeHandle(query);
}

//------------------
//	GetPosition()
//------------------

GetPosition(id)
{
	static Position;

	// If used, lets reset it
	Position = 0;

	new table[32]

	get_cvar_string("rpg_table", table, 31)

	new Handle:query = SQL_PrepareQuery(sql, "SELECT `authid` FROM `%s` ORDER BY `prestige` DESC, `lvl` + 0 DESC", table)

	// This is a pretty basic code, get all people from the database.
	if (!SQL_Execute(query))
	{
		server_print("GetPosition not loaded")
		SQL_QueryError(query, sql_error, 127)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_LOAD_ADMINS", sql_error)
	} else {
		while (SQL_MoreResults(query))
		{
			Position++
			new authid[33]
			SQL_ReadResult(query, 0, authid, 32)
			new auth_self[33];
			get_user_authid(id, auth_self, 32);
			if (equal(auth_self, authid))
				return Position;
			SQL_NextRow(query);
		}
	}
	SQL_FreeHandle(query);
	return 0;
}

//------------------
//	CreateStats()
//------------------

CreateStats(id, auth[])
{
	new table[32]

	get_cvar_string("rpg_table", table, 31)

	new Handle:query = SQL_PrepareQuery(sql, "SELECT * FROM `%s` WHERE (`authid` = '%s')", table, auth)

	if (!SQL_Execute(query))
	{
		server_print("query not saved")
		SQL_QueryError(query, sql_error, 127)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_LOAD_ADMINS", sql_error)
	} else if (SQL_NumResults(query)) {
		// If we already created one, lets continnue
	} else {
		console_print(id, "Adding to database:^nID: ^"%s^"", auth)
		server_print("Adding to database:^nID: ^"%s^"", auth)

		new plyname[32]
		get_user_name(id,plyname,31)

		SQL_QueryAndIgnore(sql, "INSERT INTO `%s` (`authid`, `name`) VALUES ('%s', '%s')", table, auth, plyname)
	}

	HasLoadedStats[id] = true;

	SQL_FreeHandle(query)
}

//------------------
//	rpg_get_weapon_string()
//------------------

stock rpg_get_weapon_string( m_iWeaponID )
{
	new weapon_string[32];
	switch( m_iWeaponID )
	{
		case 1:
			weapon_string = "weapon_crowbar";
		case 2:
			weapon_string = "weapon_glock";
		case 3:
			weapon_string = "weapon_357";
		case 4:
			weapon_string = "weapon_mp5";
		case 6:
			weapon_string = "weapon_crossbow";
		case 7:
			weapon_string = "weapon_shotgun";
		case 8:
			weapon_string = "weapon_rpg";
		case 9:
			weapon_string = "weapon_gauss";
		case 10:
			weapon_string = "weapon_egon";
		case 11:
			weapon_string = "weapon_hornetgun";
		case 12:
			weapon_string = "weapon_handgrenade";
		case 13:
			weapon_string = "weapon_tripmine";
		case 14:
			weapon_string = "weapon_satchel";
		case 15:
			weapon_string = "weapon_snarks";
		case 16:
			weapon_string = "weapon_uziakimbo";
		case 17:
			weapon_string = "weapon_uzi";
		case 18:
			weapon_string = "weapon_medkit";
		case 20:
			weapon_string = "weapon_pipewrench";
		case 21:
			weapon_string = "weapon_minigun";
		case 22:
			weapon_string = "weapon_grapple";
		case 23:
			weapon_string = "weapon_sniperrifle";
		case 24:
			weapon_string = "weapon_m249";
		case 25:
			weapon_string = "weapon_m16";
		case 26:
			weapon_string = "weapon_sporelauncher";
		case 27:
			weapon_string = "weapon_eagle";
		case 28:
			weapon_string = "weapon_shockroach";
		case 29:
			weapon_string = "weapon_displacer";
		default:
			weapon_string = "";
	}
	return weapon_string
}

//------------------
//	rpg_get_weapontitle()
//------------------

stock rpg_get_weapontitle( weapon_string[] )
{
	new return_string[32];
	if (equali(weapon_string, "weapon_crowbar"))
		return_string = "Crowbar"
	else if (equali(weapon_string, "weapon_glock"))
		return_string = "Glock"
	else if (equali(weapon_string, "weapon_357"))
		return_string = "Revolver"
	else if (equali(weapon_string, "weapon_mp5"))
		return_string = "MP5"
	else if (equali(weapon_string, "weapon_crossbow"))
		return_string = "Crossbow"
	else if (equali(weapon_string, "weapon_shotgun"))
		return_string = "Shotgun"
	else if (equali(weapon_string, "weapon_rpg"))
		return_string = "RPG"
	else if (equali(weapon_string, "weapon_gauss"))
		return_string = "Gauss Cannon"
	else if (equali(weapon_string, "weapon_egon"))
		return_string = "Gloun Gun"
	else if (equali(weapon_string, "weapon_hornetgun"))
		return_string = "Hornet Gun"
	else if (equali(weapon_string, "weapon_handgrenade"))
		return_string = "Hand Grenades"
	else if (equali(weapon_string, "weapon_tripmine"))
		return_string = "HECU Laser Tripmine"
	else if (equali(weapon_string, "weapon_satchel"))
		return_string = "Satchel Charges"
	else if (equali(weapon_string, "weapon_snark"))
		return_string = "Some Suicidal Aliens"
	else if (equali(weapon_string, "weapon_uziakimbo"))
		return_string = "Akimbo Uzi"
	else if (equali(weapon_string, "weapon_uzi"))
		return_string = "Uzi"
	else if (equali(weapon_string, "weapon_medkit"))
		return_string = "Medkit"
	else if (equali(weapon_string, "weapon_pipewrench"))
		return_string = "Pipe Wrench"
	else if (equali(weapon_string, "weapon_minigun"))
		return_string = "Minigun"
	else if (equali(weapon_string, "weapon_grapple"))
		return_string = "Grapple"
	else if (equali(weapon_string, "weapon_sniperrifle"))
		return_string = "Sniper Rifle"
	else if (equali(weapon_string, "weapon_m249"))
		return_string = "M249"
	else if (equali(weapon_string, "weapon_m16"))
		return_string = "M16"
	else if (equali(weapon_string, "weapon_sporelauncher"))
		return_string = "Spore Launcher"
	else if (equali(weapon_string, "weapon_eagle"))
		return_string = "Desert Eagle"
	else if (equali(weapon_string, "weapon_shockroach"))
		return_string = "Shockroach"
	else if (equali(weapon_string, "weapon_displacer"))
		return_string = "Displacer"
	else
		return_string = "Absolutely Nothing"
	return return_string
}

//------------------
//	rpg_get_weapon_maxammo()
//------------------

stock rpg_get_weapon_maxammo( m_iWeaponID )
{
	new max_ammo
	switch( m_iWeaponID )
	{
		case 2:
			max_ammo = 250;
		case 3:
			max_ammo = 36;
		case 4:
			max_ammo = 250;
		case 6:
			max_ammo = 50;
		case 7:
			max_ammo = 125;
		case 8:
			max_ammo = 5;
		case 9:
			max_ammo = 100;
		case 10:
			max_ammo = 100;
		case 16:
			max_ammo = 250;
		case 17:
			max_ammo = 250;
		case 21:
			max_ammo = 600;
		case 23:
			max_ammo = 15;
		case 24:
			max_ammo = 600;
		case 25:
			max_ammo = 600;
		case 26:
			max_ammo = 30;
		case 27:
			max_ammo = 36;
		case 29:
			max_ammo = 100;
		default:
			max_ammo = 0;
	}
	return max_ammo
}

//------------------
//	ExplodeString()
//------------------

stock ExplodeString( p_szOutput[][], p_nMax, p_nSize, p_szInput[], p_szDelimiter )
{
	new nIdx = 0, l = strlen(p_szInput)
	new nLen = (1 + copyc( p_szOutput[nIdx], p_nSize, p_szInput, p_szDelimiter ))
	while( (nLen < l) && (++nIdx < p_nMax) )
		nLen += (1 + copyc( p_szOutput[nIdx], p_nSize, p_szInput[nLen], p_szDelimiter ))
	return nIdx
}

//------------------
//	rpg_get_armor()
//------------------

stock rpg_get_armor(id)
{
	new value;
	if (stats_armor_set[id] > 0)
		value = 100 + stats_armor_set[id] + stats_medals[id] + stats_prestige[id];
	else
		value = 100;
	return value
}

//------------------
//	rpg_get_health()
//------------------

stock rpg_get_health(id)
{
	new value;
	if (stats_health_set[id] > 0)
		value = 100 + stats_health_set[id] + stats_medals[id] + stats_prestige[id];
	else
		value = 100;
	return value
}

//------------------
//	PlayerNotReachedCap()
//------------------

PlayerNotReachedCap(id,bool:IsHud=true)
{
	if (glb_MapDefined_SetEXPCap <= 0) return true;
	// Lets check if the temp is higher or equals to the cap.
	if (stats_xp_temp[id] >= stats_xp_cap[id]) return false;
	// Lets add some numbers into the temp value.
	if (!IsHud)
		stats_xp_temp[id] = stats_xp_temp[id] + stats_xp[id];
	return true;
}

//------------------
//	PlayerNotReachedJumpCap()
//------------------

PlayerNotReachedJumpCap(id)
{
	// If its 0, then its the default amount. But if someone adds more than the max amount, it goes back to the defined max.
	if (glb_MapDefined_MaxJumps == 0)
		glb_MapDefined_MaxJumps = AB_DOUBLEJUMP_MAX;
	else if (glb_MapDefined_MaxJumps > AB_DOUBLEJUMP_MAX)
		glb_MapDefined_MaxJumps = AB_DOUBLEJUMP_MAX;

	if (stats_doublejump_temp[id] >= glb_MapDefined_MaxJumps)
		return false;
	return true;
}
