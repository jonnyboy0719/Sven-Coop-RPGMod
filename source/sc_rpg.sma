//=============================================================================
//
//	This plugin is using BB Stats and BDEF Stats as a base, so you will see some leftover codes here and there.
//
//	RPG Mod for Sven Co-op 5.x
//
//	Created by JonnyBoy0719
//	Additional help:
//				Swampdog
//				Shadow Knight/Dark-fox
//				Daybreaker
//
//	SourceCode can be found available @
//					https://github.com/jonnyboy0719/Sven-Coop-RPGMod
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

//------------------
//	Defines
//------------------

// Defined Sounds
#define SND_LVLUP					"sc_rpg/levelup.wav"
#define SND_LVLUP_800				"sc_rpg/levelup_last.wav"
#define SND_PRESTIGE				"sc_rpg/prestige.wav"
#define SND_READY					"sc_rpg/ready.wav"
#define SND_AURA01					"sc_rpg/bttlcry01.wav"
#define SND_AURA02					"sc_rpg/bttlcry02.wav"
#define SND_AURA03					"sc_rpg/bttlcry03.wav"
#define SND_HOLYGUARD				"sc_rpg/harmor.wav"
#define SND_HOLYWEP					"sc_rpg/wepdrop.wav"
#define SND_JUMP					"sc_rpg/jump.wav"
#define SND_JUMP_LAND				"sc_rpg/jump_land.wav"
#define SND_NULL					"null.wav"

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

// Define value
#define MDL_PRECACHE				"models/player/%s%s/%s%s.mdl"
#define SND_PRECACHE				"my_community/player/%s"
#define MODEL_TAG					"my_community_"

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

#define MAX_LEVEL					800
#define MAX_PRESTIGE				10

// Plugin
#define PLUGIN						"Sven Co-op RPG Mod"
#define AUTHOR						"JonnyBoy0719"
#define VERSION						"23.0"

#define WEBSITE						"www.my_community.eu/sc_rpg/stats.php"

// Adverts
#define AdvertSetup_Max				30
new AdvertSetup = 0;

//------------------
//	Handles & more
//------------------

new ShouldFullReset[33],
	ResetConvarTime[33],
	lastfrags[33],
	lastDeadflag[33],
	bool:HasSpawnedFirstTime[33],
	bool:HasSpawned[33],
	bool:HasLoadedStats[33],
	bool:enable_ranking = false,
	bool:MapJustBegun = true,
	max_medals = 0,
	bool:ArrayBuilt = false;

// Stats
new stats_increment[33],
	stats_xp[33],
	stats_xp_cap[33],
	stats_xp_temp[33],	// Used only for the stats_xp_cap
	stats_xp_bonus[33],
	stats_neededxp[33],
	stats_neededxp_temp[33],
	bool:IsWaiting[33],
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

new hook_grenade_wait[33],
	hook_medic_wait[33];

new bool:IsCommunityMember[33] = false,
	bool:HasReadCommunityData[33] = false;

new stats_settings_sound[33],
	stats_steamidmodel[33][185],
	stats_steamidmodel_saved[33][185],
	hurtsound_delay[33] = 0;

// Model menu
new g_ModelMenu;

// Temp values
new temp_value_medic[33]

// Booleans
new bool:PlayerIsHurt[33] = false,
	PlayerHasDied[33] = 0,
	IsHurt_Timer[33] = 0,
	bool:IsJumping[33] = false,
	bool:HasAura[33] = false,
	bool:HasHolyGuard[33] = false,
	bool:CanPlayPain[33] = false

// Global stuff
new mysqlx_host,
	mysqlx_user,
	mysqlx_db,
	mysqlx_db_mybb,
	mysqlx_table,
	mysqlx_pass,
	mysqlx_type,
	Handle:sql_db,
	Handle:sql_api,
	Handle:sql_mybb_db,
	Handle:sql_mybb_api,
	sql_cache[1024],
	sql_error[128],
	sql_table[64],
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
	rank_name[33][185],
	ply_rank[33],
	top_rank,
	rank_max,
	SetExtraBonus = 0;

new g_array[80][228],
	array_plysnds[80][228],
	plysnds_count = 0;

new array_plysnds_temp[80][228];

//------------------
//	Includes
//------------------

#include "sc_rpg/natives.sma"
#include "sc_rpg/rewards.sma"

//------------------
//	Skills Setup
//------------------

enum _:Skills
{
	SK_HEALTH = 0,
	SK_ARMOR,
	SK_HEALTH_REGEN,
	SK_ARMOR_REGEN,
	SK_AMMO,
	SK_JUMP,
	SK_WEAPON,
	SK_AURA,
	SK_HOLYGUARD
};

enum _:SkillsStructData
{
	_Name[ MaxClients ],
	_Value
};

new const SkillsInfo[ Skills ][ SkillsStructData ] = 
{
	// SK_HEALTH
	{
		AB_HEALTH,
		AB_HEALTH_MAX
	},
	// SK_ARMOR
	{
		AB_ARMOR,
		AB_ARMOR_MAX
	},
	// SK_HEALTH_REGEN
	{
		AB_HEALTH_REGEN,
		AB_HEALTH_REGEN_MAX
	},
	// SK_ARMOR_REGEN
	{
		AB_ARMOR_REGEN,
		AB_ARMOR_REGEN_MAX
	},
	// SK_AMMO
	{
		AB_AMMO,
		AB_AMMO_MAX
	},
	// SK_JUMP
	{
		AB_DOUBLEJUMP,
		AB_DOUBLEJUMP_MAX
	},
	// SK_WEAPON
	{
		AB_WEAPON,
		AB_WEAPON_MAX
	},
	// SK_AURA
	{
		AB_AURA,
		AB_AURA_MAX
	},
	// SK_HOLYGUARD
	{
		AB_HOLYGUARD,
		AB_HOLYGUARD_MAX
	}
};

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

	register_event("Damage", "EVENT_Damage", "b")

	register_menucmd(register_menuid("Select Skill"),(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9),"RPGSkillChoice");
	register_menucmd(register_menuid("Select Increment"),(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5),"RPGIncrementChoice");

	register_concmd("selectskills","RPGSkill",0,"- Opens the Skill Choice Menu, if you have Skillpoints available");
	register_concmd("selectskill","RPGSkill",0,"- Opens the Skill Choice Menu, if you have Skillpoints available");
	register_concmd("rpg_skillinfo", "CVAR_SkillsInfo", 0, "Prints the info about the skills")
	register_concmd("skillsinfo", "CVAR_SkillsInfo", 0, "Prints the info about the skills")
	register_concmd("challenges", "CVAR_Challenges", 0, "Prints the challenges")
	register_concmd("rpg_sound", "CVAR_SetSoundSettings", 0, "Disables or Enables the sounds (RPG Mod custom sounds only!)")
	register_concmd("rpg_commands", "CVAR_CMMNDS", 0, "Prints the available commands")
	register_concmd("rpg_model", "CVAR_OpenModelSelection")
	register_concmd("statusc", "CVAR_StatusCommunity")

	// Sets the stuff
	register_concmd("rpg_setmodel", "CVAR_SetPlyModel", ADMIN_RCON, "<name or #userid> <model>")
	register_concmd("rpg_exp_bonus", "CVAR_SetEXPBonus", ADMIN_RCON, "[amount] [0|1]")
	register_concmd("rpg_set_level", "CVAR_SetStatsLevel", ADMIN_RCON, "<name or #userid> [amount]")
	register_concmd("rpg_set_prestige", "CVAR_SetStatsPrestige", ADMIN_RCON, "<name or #userid> [amount]")
	register_concmd("rpg_skill_gift", "CVAR_Skill_GiftFromTheGods", ADMIN_RCON, "<name or #userid>")
	register_concmd("rpg_give_weapon", "CVAR_Give_Weapon", ADMIN_RCON, "<name or #userid> <weapon>")
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
	mysqlx_db_mybb = register_cvar ("rpg_dbname_mybb", ""); // Community intergration -- Null by default, so it won't load the info.
	register_cvar ("rpg_table_api_web", "rpg_rewards_web"); // The Challenges API table
	register_cvar ("rpg_table_api", "rpg_rewards"); // The Challenges API table
	mysqlx_table = register_cvar ("rpg_table", "rpg_stats"); // The table where it will save the information
	register_cvar ("rpg_rank_table", "rpg_ranks"); // The table where it will save the information
	register_cvar ("rpg_gameinfo", "1"); // This will enable GameInformation to be overwritten.
	setranking = register_cvar ("rpg_ranking", "1"); // This will enable ranking, or simply disable it.

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
	glb_PlyTime = 25;
	//-----------------------------
	glb_AuraIsActivated = false;
	//glb_HolyGuardIsActivated = false;

	g_ModelMenu = menu_makecallback( "modelmenu_callback" );
}

//------------------
//	plugin_cfg()
//------------------

public plugin_cfg()
{
	// Check if the map is blacklisted
	CheckIfBlacklisted(false);

	// Lets delay the connection
	set_task( 2.3, "SQL_Init", 0 );
	set_task( 4.8, "Register_Rewards", 0 );

	// If it somehow is false, set to true
	MapJustBegun = true;

	// Now we wait 15 seconds until we enable the ranks to show (so it won't spam on map change)
	set_task( 15.0, "EndMapBegun", 0 );
}

//------------------
//	EndMapBegun()
//------------------

public EndMapBegun()
{
	MapJustBegun = false;
}

//------------------
//	Register_Rewards()
//------------------

public Register_Rewards()
{
	// Natives & Forwards
	ForwardClientReward = CreateMultiForward("Forward_ClientEarnedReward", ET_IGNORE, FP_CELL, FP_CELL);

	Reward = ArrayCreate(RewardsStruct);

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

	ArrayBuilt = true;

	set_task( 0.8, "CheckMaxMedals", 0 );
}

//------------------
//	plugin_end()
//------------------

public plugin_end()
{
	// Lets disable the plugin (so we don't save and load our information)
	glb_MapDefined_IsDisabled = true;

	// Destroy all arrays
	new TotalRewards = ArraySize( Reward );
	new RewardData[ RewardsStruct ];

	for( new Index = 0; Index < TotalRewards; Index++ )
	{
		ArrayGetArray( Reward, Index, RewardData );
		ArrayDestroy( RewardData[ _Data ] );
	}

	if (Reward)
		ArrayDestroy(Reward);

	// Lets close down the connection
	if (sql_db)
		SQL_FreeHandle(sql_db);
	if (sql_mybb_db)
		SQL_FreeHandle(sql_mybb_db);
	if (sql_api)
		SQL_FreeHandle(sql_api);
	if (sql_mybb_api)
		SQL_FreeHandle(sql_mybb_api);
}

//------------------
//	plugin_precache()
//------------------

public plugin_precache()
{
	precache_sound(SND_LVLUP)
	precache_sound(SND_LVLUP_800)
	precache_sound(SND_PRESTIGE)
	precache_sound(SND_READY)
	precache_sound(SND_AURA01)
	precache_sound(SND_AURA02)
	precache_sound(SND_AURA03)
	precache_sound(SND_HOLYGUARD)
	precache_sound(SND_HOLYWEP)
	precache_sound(SND_JUMP)
	precache_sound(SND_JUMP_LAND)
	precache_sound(SND_NULL)
	
	SetupCustomPlayerModels();
}
//------------------
//	CVAR_SkillsInfo()
//------------------

public CVAR_SkillsInfo(id)
{
	client_print(id, print_console, "===================================================================");
	client_print(id, print_console, "Skills Information");
	client_print(id, print_console, "===================================================================");
	client_print(id, print_console, "1. %s:^n	Starting HP + 1 * Strengthlevel.^n", AB_HEALTH);
	client_print(id, print_console, "2. %s:^n	Starting AP + 1 * Armorlevel.^n", AB_ARMOR);
	client_print(id, print_console, "3. %s:^n	Regens HP every (35.5-level) Seconds.^n	(Doesn't regen if damaged)^n", AB_HEALTH_REGEN);
	client_print(id, print_console, "4. %s:^n	Regens AP every (35.5-level) Seconds.^n	(Doesn't regen if damaged)^n", AB_ARMOR_REGEN);
	client_print(id, print_console, "5. %s:^n	Ammunition for current Weapon every (*65-level) Seconds.", AB_AMMO);
	client_print(id, print_console, "	(*Depends if the map isn't on the 'blacklist')^n");
	client_print(id, print_console, "6. %s:^n	Grants you 1 more extra jump per level.^n", AB_DOUBLEJUMP);
	client_print(id, print_console, "7. %s:^n	Gives you random weapon drop, the higher the level, greater the loot!^n", AB_WEAPON);
	client_print(id, print_console, "8. %s:^n	Supports nearby Teammates with HP and AP for a short period of time!.", AB_AURA);
	client_print(id, print_console, "	(Can be activated when pressing the 'take cover' button)^n");
	client_print(id, print_console, "9. %s:^n	Gives you temporarily god mode, use it while it lasts!", AB_HOLYGUARD);
	client_print(id, print_console, "	(Can be activated when pressing the 'medic' button)^n");
	client_print(id, print_console, "Special - Medals:^n	Given from completing hard or 'special' rewards.^n");
	client_print(id, print_console, "Special - Prestige:^n	When on max level, you can reset your level back to zero,");
	client_print(id, print_console, "	but you gain more EXP & rewards.");
	client_print(id, print_console, "===================================================================");
	client_print(id, print_chat, "Skill information has been printed on the console!")
}

//------------------
//	CVAR_SetSoundSettings()
//------------------

public CVAR_SetSoundSettings(id)
{
	new String[33];
	if (stats_settings_sound[id] >= 1)
	{
		String = "Disabled";
		stats_settings_sound[id] = 0
	}
	else
	{
		String = "Enabled";
		stats_settings_sound[id] = 1
	}
	
	client_print(id, print_chat, "[RPG Mod] The custom sounds are now %s!", String);
}

//------------------
//	CVAR_SetPlyModel()
//------------------

public CVAR_SetPlyModel(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	new arg[32],
		arg2[32]

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

	// Check if the model exist
	if (equali(arg2, GrabCustomPlayerModel(arg2)))
	{
		stats_steamidmodel[player] = arg2;
		stats_steamidmodel_saved[player] = arg2;
		
		if (equali(arg2, ""))
			arg2 = "nothing (Custom model removed!)";

		log_amx("RPG MOD CMD: ^"%s<%d><%s><>^" set ^"%s<%d><%s><>^" custom player model to %s", name, get_user_userid(id), authid, name2, get_user_userid(player), authid2, arg2)
		client_print(id, print_console, "[RPG Mod] You have set ^"%s<%s>^" custom player model to %s", name2, authid2, arg2)
		
		SaveCustomModel(player, authid2, true);
	}
	else
		client_print(id, print_console, "The model ^"%s^" was not found!", arg2)
	
	return PLUGIN_HANDLED
}

//------------------
//	SaveCustomModel()
//------------------

public SaveCustomModel(id, auth[], bool:SaveSettings)
{
	if (!id)
		return;
	
	new table[32]

	get_cvar_string("rpg_table", table, 31)

	new Handle:query = SQL_PrepareQuery(sql_api, "SELECT * FROM `%s` WHERE (`authid` = '%s')", table, auth)

	if (!SQL_Execute(query))
	{
		server_print("query not saved")
		SQL_QueryError(query, sql_error, 127)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_LOAD_ADMINS", sql_error)
	} else {
		new plyname[32]
		get_user_name(id, plyname, 31)
		if (SaveSettings)
			SQL_QueryAndIgnore(sql_api,
				"UPDATE `%s` SET `settings_plymodel` = '%s', `settings_plymodel_saved` = '%s' WHERE `authid` = '%s';",
				table,
				stats_steamidmodel[id],
				stats_steamidmodel_saved[id],
				auth
			)
		else
			SQL_QueryAndIgnore(sql_api,
				"UPDATE `%s` SET `settings_plymodel` = '%s' WHERE `authid` = '%s';",
				table,
				stats_steamidmodel[id],
				auth
			)

		// Set the model & play the spawn sound!
		new custom_plymdl[501];
		format(custom_plymdl, sizeof(custom_plymdl), "%s%s", MODEL_TAG, stats_steamidmodel[id]);
		set_user_info(id, "model", custom_plymdl);
		PlaySound_Spawn(id);
	}

	SQL_FreeHandle(query)
}

//------------------
//	ReadCommunityData()
//------------------

public ReadCommunityData(id, auth[])
{
	if (!id)
		return;

	// If MyBB Intergration is not connected, then it will not load the info.
	if (!sql_mybb_api)
		return;

	new steamid64[18];

	getSteam64(auth, steamid64)

	// Note, if you use another Forum Software, you can easily change this.
	// Just make sure you either use SteamID aor SteamID64.
	// ---
	// For MyBB, I used v1.8.x, with "MySteam Powered" plugin (Modfied one to work with the latest MyBB (As of writting) 1.8.x, head to this URL:
	// https://github.com/JonnyBoy0719/MySteam-Powered-for-MyBB-1.8.x
	new Handle:query = SQL_PrepareQuery(sql_mybb_api, "SELECT steamid FROM `mybb_users` WHERE (`steamid` = '%s')", steamid64)

	if (!SQL_Execute(query))
	{
		server_print("query not saved")
		SQL_QueryError(query, sql_error, 127)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_LOAD_ADMINS", sql_error)
	}
	else if (SQL_NumResults(query) >= 1)
		IsCommunityMember[id] = true;

	if(IsCommunityMember[id])
		server_print("%s (%s) is a community member!", auth, steamid64)

	SQL_FreeHandle(query)
}

//------------------
//	CheckMedals()
//------------------

public CheckMedals(id)
{
	if (!id)
		return;
	
	new steamid[35];
	get_user_authid(id, steamid, charsmax(steamid))
	
	// Set medals to zero
	stats_medals[id] = 0;
	
	// Now, lets recheck our medals!
	for( new m_iReward; m_iReward < Rewards; m_iReward++ )
	{
		RewardsData[ m_iReward ][ id ] = GetRewardData(steamid, RewardsInfo[ m_iReward ][ _Save_Name ]);
		
		if( GetClientRewardStatus( RewardsPointer[ m_iReward ], RewardsData[ m_iReward ][ id ] ) == _Unlocked )
			stats_medals[id] = stats_medals[id] + RewardsInfo[ m_iReward ][ _Medals ];
	}
}

//------------------
//	CheckMaxMedals()
//------------------

public CheckMaxMedals()
{
	// Now, lets recheck our medals!
	for( new m_iReward; m_iReward < Rewards; m_iReward++ )
		max_medals = max_medals + RewardsInfo[ m_iReward ][ _Medals ];
}

//------------------
//	CVAR_ShowWeb()
//------------------

public CVAR_ShowWeb(id)
{
	client_print(id, print_chat, "[RPG Mod WEB] url: %s", WEBSITE);
}

//------------------
//	CVAR_StatusCommunity()
//------------------

public CVAR_StatusCommunity(id)
{
	client_print(id, print_console, "===================================================================");
	client_print(id, print_console, "# id     name     steamid     steamid64");

	new iPlayers[32],iNum
	get_players(iPlayers, iNum)
	for(new i = 0;i < iNum; i++)
	{
		new player = iPlayers[i]
		if(is_user_connected(player)
			&& is_user_alive(player)
			&& IsCommunityMember[player])
		{
			new plyauth[32],
				plyname[32],
				steamid64[18];

			get_user_authid(player, plyauth, sizeof(plyauth));
			get_user_name(player, plyname, sizeof(plyname));
			getSteam64(plyauth, steamid64);

			client_print(id, print_console, "# %d     ^"%s^"     %s     %s", player, plyname, plyauth, steamid64);
		}
	}

	client_print(id, print_console, "===================================================================");
}

//------------------
//	CVAR_OpenModelSelection()
//------------------

public CVAR_OpenModelSelection(id)
{
	// If we are loading our stats, don't allow this to open!
	if (equali(rank_name[id], "Loading..."))
	{
		client_print(id, print_chat, "You can't open this menu while your stats are loading!")
		return;
	}

	new menu = menu_create( "\rCharacter Selection Menu!:", "modelmenu_handler" );

	new configsDir[64];

	get_configsdir(configsDir, 63);

	format(configsDir, 63, "%s/sc_rpg/modelmenu.ini", configsDir);

	if (!file_exists(configsDir))
	{
		server_print("[CVAR_OpenModelSelection] File ^"%s^" doesn't exist.", configsDir);
		return;
	}

	new File = fopen(configsDir,"r");

	// first added item, unset the player model (if the user wishes todo so
	menu_additem( menu, "== Unset Model ==^n", "unset", 0, g_ModelMenu );

	// second added item, the personal model, if there is any.
	if (!equali(stats_steamidmodel_saved[id], ""))
		menu_additem( menu, "Personal model", stats_steamidmodel_saved[id], 0, g_ModelMenu );

	if (File)
	{
		new Text[512],
			ModelID[32],
			ModelName[32],
			ModelPrestige[512];

		while (!feof(File))
		{
			fgets(File, Text, sizeof(Text)-1);

			trim(Text);

			// comment
			if (Text[0]==';')
				continue;

			ModelID[0]=0;
			ModelName[0]=0;
			ModelPrestige[0]=0;

			// not enough parameters
			if (parse(Text, ModelID, sizeof(ModelID)-1, ModelName, sizeof(ModelName)-1, ModelPrestige, sizeof(ModelPrestige)-1) < 2)
				continue;

			new PrestigeID = str_to_num(ModelPrestige);
			if (IsPrestige(ModelID) && PrestigeID > stats_prestige[id])
				continue;

			if (equali(ModelID, "uboa") && !IsRewardCompleted(id, _Map_UBOA))
				continue;

			menu_additem( menu, ModelName, ModelID, 0, g_ModelMenu );
		}
		fclose(File);
	}

	menu_display( id, menu, 0 );
}

//------------------
//	IsPrestige()
//------------------

stock IsPrestige(model[])
{
	new bool:bReturnValue = false,
		configsDir[64];
	
	get_configsdir(configsDir, 63);
	
	format(configsDir, 63, "%s/sc_rpg/customplayers.ini", configsDir);
	
	if (!file_exists(configsDir))
	{
		server_print("[IsPrestige] File ^"%s^" doesn't exist.", configsDir);
		return bReturnValue;
	}
	
	new File = fopen(configsDir,"r");
	
	if (File)
	{
		new Text[512],
			ModelID[32],
			TypeID[32],
			Sounds[512];

		while (!feof(File))
		{
			fgets(File, Text, sizeof(Text)-1);

			trim(Text);

			// comment
			if (Text[0]==';')
				continue;

			ModelID[0]=0;
			TypeID[0]=0;
			Sounds[0]=0;

			// not enough parameters
			if (parse(Text, ModelID, sizeof(ModelID)-1, TypeID, sizeof(TypeID)-1, Sounds, sizeof(Sounds)-1) < 2)
				continue;

			if (!equali(model, ModelID))
				continue;

			if(str_to_num(TypeID) == 1)
				bReturnValue = true;
		}
		fclose(File);
	}
	
	return bReturnValue;
}

//------------------
//	modelmenu_callback()
//------------------

// Return ITEM_ENABLED, ITEM_DISABLED, or ITEM_IGNORE.
public modelmenu_callback( id, menu, item )
{
	new szData[32], szName[64];
	new item_access, item_callback;

	menu_item_getinfo( menu, item, item_access, szData,charsmax( szData ), szName,charsmax( szName ), item_callback );

	// If we have no model selected, and its on "unset", disable it.
	if ( equali(stats_steamidmodel[id], "")
		&& equali(szData, "unset") )
		return ITEM_DISABLED;

	// If we are using the model, become disabled.
	if ( equali(szData, stats_steamidmodel[id]) )
		return ITEM_DISABLED;

	return ITEM_IGNORE;
}

//------------------
//	modelmenu_handler()
//------------------

public modelmenu_handler( id, menu, item )
{
	if ( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}

	new szData[32], szName[64];
	new item_access, item_callback;
	menu_item_getinfo( menu, item, item_access, szData,charsmax( szData ), szName,charsmax( szName ), item_callback );

	// If we set it to "unset", then replace it with nothing.
	// ELse proceed as normal.
	if (equali(szData, "unset"))
		stats_steamidmodel[id] = "";
	else
		stats_steamidmodel[id] = szData;

	new authid[32]
	get_user_authid(id, authid, 31)
	SaveCustomModel(id, authid, false);

	menu_destroy( menu );
	return PLUGIN_HANDLED;
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
			client_print(id, print_console, "%s (%d/%d):^n	%s^n", RewardsInfo[ m_iReward ][ _Name ], RewardsData[ m_iReward ][ id ], RewardsInfo[ m_iReward ][ _Max_Value ], RewardsInfo[ m_iReward ][ _Description ]);
		else
		{
			Challenges_count++;
			client_print(id, print_console, "%s (Completed):^n	%s^n", RewardsInfo[ m_iReward ][ _Name ], RewardsInfo[ m_iReward ][ _Description ]);
		}
	}
	
	if (Challenges_count >= Challenges_total)
		client_print(id, print_console, "Progress:^n	All %d challenges has been completed!", Challenges_total);
	else
		client_print(id, print_console, "Progress:^n	You have completed %d out of %d challenges.", Challenges_count, Challenges_total);
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
		client_print(id, print_console, "rpg_exp_bonus [amount] [0|1]^n	This will set an extra amount of EXP you will gain per frag.^n");
		client_print(id, print_console, "rpg_set_level <name or #userid> [amount]^n	This will set the level of a user (and reset their skills).^n");
		client_print(id, print_console, "rpg_set_prestige <name or #userid> [amount]^n	This will set the prestige level of a user.^n");
		client_print(id, print_console, "rpg_skill_gift <name or #userid>^n	This will forcefully use the skill %s on the user,", AB_WEAPON);
		client_print(id, print_console, "	even if the player doesn't have it.^n");
		client_print(id, print_console, "rpg_give_weapon <name or #userid> <weapon>^n	This will forcefully give the player a weapon.^n");
		client_print(id, print_console, "rpg_reloadblacklist^n	This will reload the whole blacklist.");
	}
	else
		client_print(id, print_console, "ERROR^n	You do not have access for these commands.");
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
	else if (str_to_num(arg2) >= MAX_LEVEL)
		setvalue = MAX_LEVEL
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
	if (!cmd_access(id, level, cid, 1))
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
	if (!cmd_access(id, level, cid, 0))
		return PLUGIN_HANDLED

	new authid[32],
		name[32]

	get_user_authid(id, authid, 31)
	get_user_name(id, name, 31)

	CheckIfBlacklisted(true);

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
//	CVAR_Give_Weapon()
//------------------

public CVAR_Give_Weapon(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	new arg[32],
		arg2[32]

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

	new m_iSecretKey = random_num(0, 9000000000);

	// Sets the secret key
	client_cmd(player, ".rpg_mod_skey %d", m_iSecretKey);

	// Lets use AngelScript for this part, so we don't spawn weapons on the world...
	client_cmd(player, ".rpg_mod_gwep %s %d", arg2, m_iSecretKey);

	log_amx("RPG MOD CMD: ^"%s<%d><%s><>^" gave ^"%s<%d><%s><>^" weapon %s", name, get_user_userid(id), authid, name2, get_user_userid(player), authid2, arg2)

	return PLUGIN_HANDLED
}

//------------------
//	hook_grenade()
//------------------

public hook_grenade(id)
{
	if (!equali(stats_steamidmodel[id], "")
		&& hook_grenade_wait[id] <= 0
		&& stats_auro_wait[id] > 0)
	{
		hook_grenade_wait[id] = 3;
		PlaySound_Grenade(id);
		return PLUGIN_HANDLED;
	}

	if(stats_auro_wait[id] <= 0)
	{
		if (stats_auro[id] <= 0)
			return PLUGIN_CONTINUE;
		if(!is_user_alive(id))
			return PLUGIN_CONTINUE;
		if(glb_AuraIsActivated)
			return PLUGIN_CONTINUE;
	
		switch(random_num(0, 2))
		{
			case 0:
				PlaySound(id, SND_AURA01)
			case 1:
				PlaySound(id, SND_AURA02)
			case 2:
				PlaySound(id, SND_AURA03)
		}
		
		new iPlayers[32], iNum
		get_players(iPlayers, iNum)
		CheckReward(id, _WarrierInside);
		
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
		CheckReward(id, _Secret2);
	
	set_task(1.8, "RemoveTempValues", id)

	if (!equali(stats_steamidmodel[id], "")
		&& hook_medic_wait[id] <= 0
		&& stats_holyguard_wait[id] > 0)
	{
		hook_medic_wait[id] = 3;
		PlaySound_Medic(id);
		return PLUGIN_HANDLED;
	}

	if(stats_holyguard_wait[id] <= 0)
	{
		if (stats_holyguard[id] <= 0)
			return PLUGIN_CONTINUE;
		if(!is_user_alive(id))
			return PLUGIN_CONTINUE;
		if(HasHolyGuard[id])
			return PLUGIN_CONTINUE;

		PlaySound(id, SND_HOLYGUARD)

		CheckReward(id, _GodsDoing);

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
		"Select Skills - Skillpoints available: %i^n^n^n^n 1.	%s  [ %i / %i ]^n^n 2.	%s  [ %i / %i ]^n^n 3.	%s  [ %i / %i ]^n^n 4.	%s  [ %i / %i ]^n^n 5.	%s  [ %i / %i ]^n^n 6.	%s  [ %i / %i ]^n^n 7.	%s  [ %i / %i ]^n^n 8.	%s  [ %i / %i ]^n^n 9.	%s  [ %i / %i ]^n^n^n 0.	Done",
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
		format(menuBody,1023,"Increment your skill with^n^n^n^n1.	1  point^n^n2.	5  points^n^n3.	10 points^n^n4.	25 points");
	else if (stats_points[id] >= 50 && stats_points[id] < 100)
		format(menuBody,1023,"Increment your skill with^n^n^n^n1.	1  point^n^n2.	5  points^n^n3.	10 points^n^n4.	25 points^n^n5.	50 points");
	else if (stats_points[id] >= 100)
		format(menuBody,1023,"Increment your skill with^n^n^n^n1.	1  point^n^n2.	5  points^n^n3.	10 points^n^n4.	25 points^n^n5.	50 points^n^n6.	100 points");
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
	// We don't want to apply negative points.
	if (stats_increment[id] > stats_points[id] && stats_points[id] > 0)
	{
		RPGSkill(id)
		return PLUGIN_HANDLED;
	}

	new auth[33],
		temp_value_set;
	get_user_authid(id, auth, 32);

	if (key < 9)
	{
		// Lets grab the value needed
		switch(key)
		{
			case 0:
				temp_value_set = stats_health_set[id];
			case 1:
				temp_value_set = stats_armor_set[id];
			case 2:
				temp_value_set = stats_health[id];
			case 3:
				temp_value_set = stats_armor[id];
			case 4:
				temp_value_set = stats_ammo[id];
			case 5:
				temp_value_set = stats_doublejump[id];
			case 6:
				temp_value_set = stats_randomweapon[id];
			case 7:
				temp_value_set = stats_auro[id];
			case 8:
				temp_value_set = stats_holyguard[id];
		}

		if (stats_points[id] > 0)
		{
			if (temp_value_set < SkillsInfo[ key ][ _Value ])
			{
				if (stats_increment[id] + temp_value_set >= SkillsInfo[ key ][ _Value ])
					stats_increment[id] = SkillsInfo[ key ][ _Value ] - temp_value_set;
				stats_points[id] -= stats_increment[id];

				switch(key)
				{
					case 0:
						temp_value_set = stats_health_set[id] += stats_increment[id];
					case 1:
						temp_value_set = stats_armor_set[id] += stats_increment[id];
					case 2:
						temp_value_set = stats_health[id] += stats_increment[id];
					case 3:
						temp_value_set = stats_armor[id] += stats_increment[id];
					case 4:
						temp_value_set = stats_ammo[id] += stats_increment[id];
					case 5:
						temp_value_set = stats_doublejump[id] += stats_increment[id];
					case 6:
						temp_value_set = stats_randomweapon[id] += stats_increment[id];
					case 7:
						temp_value_set = stats_auro[id] += stats_increment[id];
					case 8:
						temp_value_set = stats_holyguard[id] += stats_increment[id];
				}

				client_print(id, print_chat, "[RPG MOD] You spent %i Skillpoints to enhance '%s' to Level %i!", stats_increment[id], SkillsInfo[ key ][ _Name ], temp_value_set);
				SaveLevel(id, auth);

				if (is_user_alive(id))
				{
					switch(key)
					{
						case 0:
							set_user_health(id, get_user_health(id) + stats_increment[id]);
						case 1:
							set_user_armor(id,get_user_armor(id)+stats_increment[id]);
					}
				}
			}
			else
				client_print(id, print_chat, "[RPG MOD] You have mastered already '%s'.", SkillsInfo[ key ][ _Name ])

			if (stats_points[id] > 0)
				RPGSkill(id);
		}
		else
			client_print(id,print_chat,"[RPG MOD] You need one Skillpoint for enhancing '%s'.", SkillsInfo[ key ][ _Name ])
	}
	return PLUGIN_HANDLED;
}

//------------------
//	CheckIfBlacklisted()
//------------------

public CheckIfBlacklisted(bool:IsCommand)
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

	BeginBlackListing_Map(map_folder, IsCommand);
}

//------------------
//	BeginBlackListing_Map()
//------------------

public BeginBlackListing_Map(szFilename[], bool:IsCommand)
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

	if (IsCommand)
	{
		new players[32],
			num,
			i,
			id;

		get_players(players, num);

		if (glb_MapDefined_SetEXPCap > 0)
		{
			for (i = 0; i<num; i++)
			{
				id = players[i];
				if (is_user_connected(id))
				{
					glb_MapDefined_HasSetCap[id] = true;
					if (stats_level[id] > 1)
						stats_xp_cap[id] = floatround( 8.25 + stats_neededxp[id] + glb_MapDefined_SetEXPCap );
					else
						stats_xp_cap[id] = stats_neededxp[id] + glb_MapDefined_SetEXPCap;
				}
			}
		}
		else
		{
			for (i = 0; i<num; i++)
			{
				id = players[i];
				if (is_user_connected(id))
					glb_MapDefined_HasSetCap[id] = false;
			}
		}
	}
}

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
	
	set_task(0.1, "HurtSound", id);

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
//	HurtSound()
//------------------

public HurtSound(id)
{
	if (hurtsound_delay[id] > 0)
		return;
	
	if (!equali(stats_steamidmodel[id], ""))
		PlaySound_Pain(id)
	
	hurtsound_delay[id] = 3;
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
		return PLUGIN_CONTINUE;

	PlayerHasSpawned(id)

	if ( !HasLoadedStats[id] )
		set_task(3.8, "LateJoin", id)

	// The title will take awhile to load, so instead of having a blank text, lets have a 'Loading' text instead.
	rank_name[id] = "Loading...";

	return PLUGIN_CONTINUE;
}

//------------------
//	LateJoin()
//------------------

public LateJoin(id)
{
	if (glb_MapDefined_IsDisabled)
		return PLUGIN_CONTINUE;

	// If the player has died, lets save his stuff first.
	new auth[33];
	get_user_authid( id, auth, 32);

	if ( !HasLoadedStats[id] )
		CreateStats(id, auth);

	set_task(4.0, "ShowInfo", id)

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
			stats_xp_cap[id] = stats_neededxp[id] + glb_MapDefined_SetEXPCap;
	}

	if (!HasSpawnedFirstTime[id])
		HasSpawnedFirstTime[id] = true;

	StatsVersion(id)
	if( enable_ranking )
		set_task(5.0, "ShowStatsOnSpawn", id)
}

//------------------
//	GameInformation()
//------------------

public GameInformation()
{
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
	format(formated_text, 500, "This server is running Sven Co-Op RPG Version {VERSION}")
	PrintToChat(id, formated_text)
	return PLUGIN_HANDLED
}

//------------------
//	GetCurrentRankTitle()
//------------------

GetCurrentRankTitle(id)
{
	if (!id)
		return;
	
	new table[32]

	get_cvar_string("rpg_rank_table", table, 31)

	// This will read the player LVL and then give him the title he needs
	new Handle:query = SQL_PrepareQuery(sql_api, "SELECT * FROM `%s` WHERE `lvl` <= (%d) and `lvl` ORDER BY abs(`lvl` - %d) LIMIT 1", table, stats_level[id], stats_level[id])
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
}

//------------------
//	ShowMyRank()
//------------------

public ShowMyRank(id)
{
	if (!id)
		return PLUGIN_HANDLED;
	
	GetPosition(id);
	// Lets call the GetCurrentRankTitle(id) to make sure we get the title for the player
	GetCurrentRankTitle(id);

	new auth[33];

	get_user_authid( id, auth, 32);
	LoadLevel(id, auth, false);

	set_task(1.0, "Delay_ShowMyRank", id);

	return PLUGIN_HANDLED
}

//------------------
//	Delay_ShowMyRank()
//------------------

public Delay_ShowMyRank(id)
{
	if (!id)
		return PLUGIN_HANDLED;
	
	new formated_text[501];
	
	format(
		formated_text,
		500,
		"you are on rank %d of %d with the title: ^"%s^"",
		ply_rank[id],
		top_rank,
		rank_name[id]
	);
	PrintToChat(id, formated_text);

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

	if (stats_level[id] < MAX_LEVEL)
	{
		client_print( id, print_chat, "[RPG MOD] You must be level %d to prestige!", MAX_LEVEL );
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

	CheckReward(id, _Prestige_1);
	CheckReward(id, _Prestige_LJ);
	CheckReward(id, _Prestige_2);

	//===================================================
	//===================================================

	// Setup extra pointsss
	new medalpoints = stats_medals[id] > 0 ? floatround(stats_medals[id] * 25 / 0.1) : 0;

	// Lets add the goodies
	stats_xp_bonus[id] = floatround(stats_prestige[id] / 0.1 * 25) + medalpoints + SetExtraBonus;

	// Lets calculate our EXP again.
	CalculateEXP_Needed(id);
	
	// Play prestige sound
	PlaySound(id, SND_PRESTIGE);

	// Delay the rank title, else it will bug out and think we still have the highest rank.
	rank_name[id] = "Loading...";
	set_task(1.1, "Prestige_DelaySetRank", id);

	// Lets tell everyone that this person have just prestieged!
	new name[32],
		shrtname[10],
		prestigestatus[125];

	if (stats_prestige[id] == 1)
		shrtname = "st";
	else
		shrtname = stats_prestige[id] > 2 ? "th" : "nd";

	formatex(prestigestatus, sizeof(prestigestatus), " for the %d%s time!", stats_prestige[id], shrtname)

	get_user_name(id, name, 31);
	client_print(0, print_chat, "[RPG MOD] %s have prestiged%s!", name, prestigestatus);
	return PLUGIN_HANDLED
}

//------------------
//	SetupCustomPlayerModels()
//------------------

public SetupCustomPlayerModels()
{
	new configsDir[64];
	
	get_configsdir(configsDir, 63);
	
	format(configsDir, 63, "%s/sc_rpg/customplayers.ini", configsDir);
	
	if (!file_exists(configsDir))
	{
		server_print("[SetupCustomPlayerModels] File ^"%s^" doesn't exist.", configsDir)
		return;
	}
	
	new File = fopen(configsDir,"r");
	
	if (File)
	{
		new Text[512],
			ModelID[32],
			TypeID[32],
			Sounds[32];

		while (!feof(File))
		{
			fgets(File, Text, sizeof(Text)-1);

			trim(Text);

			// comment
			if (Text[0]==';')
				continue;

			ModelID[0]=0;
			TypeID[0]=0;
			Sounds[0]=0;

			// not enough parameters
			if (parse(Text, ModelID, sizeof(ModelID)-1, TypeID, sizeof(TypeID)-1, Sounds, sizeof(Sounds)-1) < 2)
				continue;
			
			new precachemodel[125]
			
			// Lets format the crap!
			format(precachemodel, sizeof(precachemodel), MDL_PRECACHE, MODEL_TAG, ModelID, MODEL_TAG, ModelID)
			//log_amx(precachemodel);
			
			//MDL_PRECACHE
			precache_model(precachemodel);
			
			array_plysnds[plysnds_count] = ModelID;
			
			plysnds_count++;
		}
		fclose(File);
	}
	
	PrecacheSounds();
}

//------------------
//	PrecacheSounds()
//------------------

public PrecacheSounds()
{
	new configsDir[64];
	
	get_configsdir(configsDir, 63);
	
	format(configsDir, 63, "%s/sc_rpg/customplayers.ini", configsDir);
	
	if (!file_exists(configsDir))
	{
		server_print("[PrecacheSounds] File ^"%s^" doesn't exist.", configsDir)
		return;
	}
	
	new File = fopen(configsDir,"r");
	
	if (File)
	{
		new Text[512],
			ModelID[32],
			TypeID[32];
		new Sounds[512];

		while (!feof(File))
		{
			fgets(File, Text, sizeof(Text)-1);

			trim(Text);

			// comment
			if (Text[0]==';')
				continue;

			ModelID[0]=0;
			TypeID[0]=0;
			Sounds[0]=0;

			// not enough parameters
			if (parse(Text, ModelID, sizeof(ModelID)-1, TypeID, sizeof(TypeID)-1, Sounds, sizeof(Sounds)-1) < 3)
				continue;
			
			ExplodeString( array_plysnds, 80, 227, Sounds, ',' );
			new iSound = -1;
			while(iSound++ < sizeof(array_plysnds)-1)
			{
				if(containi(array_plysnds[iSound], "pain=") != -1
				|| containi(array_plysnds[iSound], "death=") != -1
				|| containi(array_plysnds[iSound], "spawn=") != -1
				|| containi(array_plysnds[iSound], "medic=") != -1
				|| containi(array_plysnds[iSound], "grenade=") != -1)
				{
					replace_all(array_plysnds[iSound], 226, "pain=", "");
					replace_all(array_plysnds[iSound], 226, "death=", "");
					replace_all(array_plysnds[iSound], 226, "spawn=", "");
					replace_all(array_plysnds[iSound], 226, "grenade=", "");
					replace_all(array_plysnds[iSound], 226, "medic=", "");
					new precachesound[125]
					format(precachesound, sizeof(precachesound), SND_PRECACHE, array_plysnds[iSound])
					//log_amx(precachesound);
					precache_sound(precachesound);
				}
			}
		}
		fclose(File);
	}
}

//------------------
//	Prestige_DelaySetRank()
//------------------

public Prestige_DelaySetRank(id)
{
	// Lets grab our new rank title
	GetCurrentRankTitle(id);
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
				stats_xp_cap[id] = stats_neededxp[id] + glb_MapDefined_SetEXPCap;
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
		client_print ( id, print_console, "/version		 --	  Shows the current version" )
		client_print ( id, print_console, "/prestige		--	  If on max level, you will reset to level 0, but gain some new cool shit." )
		client_print ( id, print_console, "/model			--	  Open up the model selection menu" )
		client_print ( id, print_console, "/reset			--	  Resets your stats (Points only)" )
		client_print ( id, print_console, "/fullreset		--	  Full Reset of your stats" )
		client_print ( id, print_console, "/challenges	  --	  Shows your challange progress" )
		client_print ( id, print_console, "/skills		  --	  Set your skillpoints" )
		client_print ( id, print_console, "/sound			--	  Disables or Enables the sounds (RPG Mod custom sounds only!)" )
		client_print ( id, print_console, "/skillsinfo	  --	  Grabs all the information of what the skills do (will print all info on the console!)" )
		client_print ( id, print_console, "/web			 --	  Prints the website for the stats" )
		if ( enable_ranking )
		{
			client_print ( id, print_console, "/top10			--	  Shows the top10 players" )
			client_print ( id, print_console, "/rank			--	  Shows your rank" )
		}
		client_print ( id, print_console, "==--------------------------------------==" )
	}
	else
	{
		if ( enable_ranking )
			client_print ( id, print_chat, "Available commands: /version /rank /top10 /reset /fullreset /prestige /skills /challenges /sound /web" )
		else
			client_print ( id, print_chat, "Available commands: /version /reset /fullreset /prestige /skills /challenges /sound /web" )
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
	else if (equali(arg1[0], "/sound"))
		CVAR_SetSoundSettings(id)
	else if (equali(arg1[0], "/web"))
		CVAR_ShowWeb(id)
	else if (equali(arg1[0], "/model"))
		CVAR_OpenModelSelection(id)
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
	
	if(equali(arg1[0], "/praise")
		|| equali(arg1[0], "/praise slave")
		|| equali(arg1[0], "/praise nihilanth")
		|| equali(arg1[0], "/praise truth")
		|| equali(arg1[0], "/praise real")
		|| equali(arg1[0], "/praise existence")
		|| equali(arg1[0], "/praise exist"))
	{
		new crypticmsg[1024]
		if(equali(arg1[0], "/praise slave"))
			formatex( crypticmsg, sizeof(crypticmsg), "Once a slave, always a slave." )
		else if(equali(arg1[0], "/praise nihilanth"))
		{
			switch(random_num(0, 1))
			{
				case 0: formatex( crypticmsg, sizeof(crypticmsg), "- .... .	 .- -. ... .-- . .-.	 .. ...	 .-- .. - .... .. -.	 -.-- --- ..- .-.	 --. .-. .- ... .--. --··--	 ..-. .. -. -..	 - .... .	 --- -. .	 -.-- --- ..-	 ... . . -.-	 .-- .. - ....	 - .... . .. .-.	 . -..- .. ... - . -. -.-. .	 .. -. - .- -.-. -" );
				case 1: formatex( crypticmsg, sizeof(crypticmsg), ". -..- .. ... - . -. -.-. . --··--	 .. ...	 -- -.-- - .... ·-·-·-	 - .... .	 -- -.-- - ....	 .. ...	 . -..- .. ... - . -. -.-. . ·-·-·-	 -.-- . -	 -... --- - ....	 -.-. .- -. -. --- -	 . -..- .. ... -	 .. ..-.	 -. --- - .... .. -. --.	 .. ...	 .-. . .- .-.. ·-·-·-" );
			}
		}
		else if(equali(arg1[0], "/praise truth"))
		{
			switch(random_num(0, 1))
			{
				case 0: formatex( crypticmsg, sizeof(crypticmsg), "..	 ... . .	 - .... .	 - .-. ..- - .... --··--	 -... ..- -	 ..	 ... - .. .-.. .-..	 -.-. .- -. ·----· -	 .-. . .- -.-. ....	 .. -" );
				case 1: formatex( crypticmsg, sizeof(crypticmsg), "..	 -.-. .- -. -. --- -	 ..-. .. -. -..	 - .... .	 . -..- .. ... - . -. -.-. .	 ..	 -. . . -.." );
			}
		}
		else if(equali(arg1[0], "/praise real"))
			formatex( crypticmsg, sizeof(crypticmsg), "..	 .- --	 - .... .	 ... .-.. .- ...- .	 --- ..-.	 -. .. .... .. .-.. .- -. - ...." )
		else if(equali(arg1[0], "/praise exist") || equali(arg1[0], "/praise existence"))
			formatex( crypticmsg, sizeof(crypticmsg), ".. ·----· --	 -. .. .... .. .-.. .- -. - .... ·----· ...	 ... .-.. .- ...- . -·-·--" )
		else
		{
			switch(random_num(0, 6))
			{
				case 0: formatex( crypticmsg, sizeof(crypticmsg), "The truth. Hidden, beneath the old. By seeking thy code, your salvation will be within your grasp." );
				case 1: formatex( crypticmsg, sizeof(crypticmsg), "One who sees, will open the gates, for thy who cannot." );
				case 2: formatex( crypticmsg, sizeof(crypticmsg), "The Old. The New. The Future. All the same, but you, you see only black." );
				case 3: formatex( crypticmsg, sizeof(crypticmsg), "Obey the unknown, for he is your new salvation." );
				case 4: formatex( crypticmsg, sizeof(crypticmsg), "Alone. Decived. Thy who demand, will not. Thy who shall, will. Hidden, but not gone. Forgotten is what he is." );
				case 5: formatex( crypticmsg, sizeof(crypticmsg), "Thy slave, must do as told. If not, thy shall never see blessing." );
				case 6: formatex( crypticmsg, sizeof(crypticmsg), "The path to salvation, is thy sentence of existence. You may not need to use thy givings to bring you salvation" );
			}
		}
		client_print(id, print_chat, crypticmsg)
		
		// Da sound
		switch(random_num(0, 3))
		{
			case 0: PlaySound(id, "nihilanth/nil_deceive.wav");
			case 1: PlaySound(id, "nihilanth/nil_alone.wav");
			case 2: PlaySound(id, "nihilanth/nil_thetruth.wav");
			case 3: PlaySound(id, "nihilanth/nil_man_notman.wav");
		}
	}

	if(equali(arg1[0], "I'm Nihilanth's slave!"))
	{
		CodeCracked(id);
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE
}

//------------------
//	CodeCracked() -- for da secret
//------------------

public CodeCracked(id)
{
	client_print(id, print_console, "He gives his blessings, for thy who sees." )

	new steamid[35];
	get_user_authid(id, steamid, charsmax(steamid))

	CheckReward(id, _Secret1);
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

	new Handle:query = SQL_PrepareQuery(sql_api, "SELECT `name`, `lvl`, `medals`, `prestige` FROM `%s` ORDER BY `prestige` DESC, `lvl` + 0 DESC LIMIT 10", table)

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
		return PLUGIN_CONTINUE;

	new iPlayers[32],iNum
	get_players(iPlayers, iNum)
	for(new i = 0;i < iNum; i++)
	{
		new id = iPlayers[i]
		if(is_user_connected(id) && is_user_alive(id))
		{
			RegenSystem(id);

			GiveSpecialItems(id);

			if (hook_grenade_wait[id] <= 0)
				hook_grenade_wait[id] = 0;
			else
				hook_grenade_wait[id]--;

			if (hook_medic_wait[id] <= 0)
				hook_medic_wait[id] = 0;
			else
				hook_medic_wait[id]--;

			if (hurtsound_delay[id] <= 0)
				hurtsound_delay[id] = 0;
			else
				hurtsound_delay[id]--;

			if (stats_auro_wait[id] == 1 || stats_holyguard_wait[id] == 1)
				PlaySound(id, SND_READY)

			if (stats_auro_wait[id] > 0)
				stats_auro_wait[id]--;

			if (stats_holyguard_wait[id] > 0)
				stats_holyguard_wait[id]--;

			if(get_user_frags(id) > lastfrags[id]
				|| stats_xp[id] >= stats_neededxp[id]
				&& stats_neededxp[id] > 100
				&& get_user_time(id) > glb_PlyTime
				)
			{
				lastfrags[id] = get_user_frags(id)
				if (stats_level[id] < MAX_LEVEL
					&& PlayerNotReachedCap(id)
					&& !glb_MapDefined_IsBlacklisted)
				{
					CalculateEXP_Add(id);
					if(stats_xp[id] >= stats_neededxp[id] && !IsWaiting[id])
					{
						// Lets grab the exp & needed exp and save them to temp values
						new temp_exp = stats_xp[id];
						stats_neededxp_temp[id] = stats_neededxp[id];
						
						// Wait before we run this again.
						IsWaiting[id] = true;
						set_task(1.8, "PlayerStopWaiting", id);

						// Reset the EXP, calculate the new needed EXP and increase our level.
						stats_xp[id] = 0;

						// Calculate the new needed EXP, and increase the level for the user
						CalculateEXP_Needed(id);
						stats_level[id]++;

						// If our current EXP goes over the needed EXP, lets remove the EXP we need, so we get correct number of EXP we have left.
						// Example:
						// temp_exp - stats_neededxp_temp = leftover
						if (temp_exp > stats_neededxp_temp[id] && stats_neededxp[id] != stats_neededxp_temp[id])
							stats_xp[id] = temp_exp - stats_neededxp_temp[id];

						// Lets grab our new rank title
						GetCurrentRankTitle(id);

						// Add some points!
						stats_points[id]++;

						// Showmenu
						RPGSkill(id);

						new name[32];
						get_user_name( id, name, 31 );
						if ( stats_level[id] == MAX_LEVEL )
						{
							// Last level! wooo!
							PlaySound(id, SND_LVLUP_800);
							client_print(0, print_chat, "[RPG MOD] Everyone say ^"Congratulations!!!^" to %s, who has reached Level %d!", name, MAX_LEVEL)
						}
						else
						{
							PlaySound(id, SND_LVLUP);
							client_print(id, print_chat, "[RPG MOD] Congratulations, %s, you are now Level %i", name, stats_level[id])
						}
					}

					new auth[33];
					get_user_authid( id, auth, 32);
					SaveLevel(id, auth);
				}
			}
			if (HasSpawnedFirstTime[id])
			{
				HasSpawnedFirstTime[id] = false;
				new auth[33];
				get_user_authid( id, auth, 32);
				LoadLevel(id, auth);
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
//	PlayerStopWaiting()
//------------------

public PlayerStopWaiting(id)
{
	CalculateEXP_Needed(id);
	IsWaiting[id] = false;
}

//------------------
//	PlaySound()
//------------------

public PlaySound(id, SoundString[])
{
	if (stats_settings_sound[id] >= 1)
		client_cmd(id, "spk ^"sound/%s^"", SoundString)
}

//------------------
//	PlayPlayerModelSound()
//------------------

public PlayPlayerModelSound(id, SoundString[])
{
	client_cmd(id, "spk ^"%s^"", SoundString)
}

//------------------
//	client_PreThink()
//------------------

public client_PreThink(id)
{
	if (glb_MapDefined_IsDisabled)
		return PLUGIN_CONTINUE;

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
		return PLUGIN_CONTINUE;

	if(!is_user_alive(id))
		return PLUGIN_CONTINUE;

	UsedSpecials(id)

	if(IsJumping[id])
	{
		new Float:velocity[3];
		entity_get_vector(id, EV_VEC_velocity, velocity);
		velocity[2] = random_float(265.0, 285.0);
		entity_set_vector(id, EV_VEC_velocity, velocity);
		IsJumping[id] = false;
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
	
	// Reads the player health, aura (+200)
	new value = rpg_get_health(id) + 200 + stats_auro[id];
	
	// Grabs our health and armor values
	new value_self = rpg_get_health(id) + 300 + stats_auro[id];
	new value_self_armor = rpg_get_armor(id) + 300 + stats_auro[id];

	// If the player has less health or armor, override it.
	if (get_user_health(id) < value_self)
		set_user_health(id, value_self)
	
	if (get_user_armor(id) < value_self_armor)
		set_user_armor(id, value_self_armor)

	// Cycles trough the players around the person with the aura
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
				// Sets for everyone within range
				if (get_user_health(pPlayers) < value)
					set_user_health(pPlayers, value + stats_auro[id])
				if (get_user_armor(pPlayers) < value)
					set_user_armor(pPlayers, value + stats_auro[id])
			}
		}
	}

	// 4 or more people? Add to the challange reward
	if (iPlyamount > 3)
		CheckReward(id, _TeamPlayer);
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
			PlaySound(id, SND_JUMP)
			IsJumping[id] = true;
			stats_doublejump_temp[id]++;
			return PLUGIN_CONTINUE;
		}
	}
	if(stats_doublejump_temp[id] > 0 && (get_entity_flags(id) & FL_ONGROUND))
	{
		PlaySound(id, SND_JUMP_LAND)
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
//	UsedSpecials()
//------------------

public UsedSpecials(id)
{
	if(HasAura[id])
	{
		// If it becomes more than it should be, take it down to the max value.
		if (stats_auro_timer[id] > 300)
			stats_auro_timer[id] = 300;

		IsInRange(id);
		if (stats_auro_timer[id] <= 0)
		{
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0);
			HasAura[id] = false;
			stats_auro_wait[id] = 180 - stats_auro[id];
		}
		else
			stats_auro_timer[id]--;
	}

	if(HasHolyGuard[id])
	{
		// If it becomes more than it should be, take it down to the max value.
		if (stats_holyguard_timer[id] > 2000)
			stats_holyguard_timer[id] = 2000;

		if (stats_holyguard_timer[id] <= 0)
		{
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0);
			set_user_godmode(id, 0);
			HasHolyGuard[id] = false;
		}
		else
			stats_holyguard_timer[id]--;
	}
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

	// Check the ammo wait, if its not a dumb numbers.
	// We will only allow 100 seconds. So we don't wait forever, and never get anything.
	if (stats_ammo_wait[id] > 100)
		stats_ammo_wait[id] = 100;

	// Regens the ammo
	if (stats_ammo[id] > 0 && stats_ammo_wait[id] <= 0)
	{
		if (glb_MapDefined_AmmoRegen > 0 && glb_MapDefined_AmmoRegen > 65)
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
//	GiveSpecialItems()
//------------------

public GiveSpecialItems(id)
{
	// This gives the items all the time, since if we are on a moving platform, it refuses to give it.
	// Prestige rewards!
	if (stats_prestige[id] >= 2)
		give_item(id, "item_longjump")
}

//------------------
//	GiveSpecialWeapons()
//------------------

public GiveSpecialWeapons(id)
{
	// Prestige rewards!
	if (stats_prestige[id] >= 1)
		rpg_give_weapon(id, "weapon_rpg_crowbar")
	if (stats_prestige[id] >= 3)
		rpg_give_weapon(id, "weapon_357golden")
	if (stats_prestige[id] >= 4)
		rpg_give_weapon(id, "weapon_greasegun")
	if (stats_prestige[id] >= 5)
		rpg_give_weapon(id, "weapon_m14")
	if (stats_prestige[id] >= 6)
		rpg_give_weapon(id, "weapon_doublebarrel")
	if (stats_prestige[id] >= 7)
		rpg_give_weapon(id, "weapon_rpg_shotnade")
	if (stats_prestige[id] >= 8)
		rpg_give_weapon(id, "weapon_teslagun")
	if (stats_prestige[id] >= 9)
		rpg_give_weapon(id, "weapon_500")
	if (stats_prestige[id] >= 10)
		rpg_give_weapon(id, "weapon_hmg")
}

//------------------
//	rpg_give_weapon()
//------------------

public rpg_give_weapon(id, weapon_string[])
{
	new m_iSecretKey = random_num(0, 9000000000);

	// Sets the secret key
	client_cmd(id, ".rpg_mod_skey %d", m_iSecretKey);

	// Lets use AngelScript for this part, so we don't spawn weapons on the world...
	client_cmd(id, ".rpg_mod_gwep %s %d", weapon_string, m_iSecretKey);
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

	new clip, ammo;
	new CurrentWeaponID = get_user_weapon(id, clip, ammo);

	ObtainAmmo_Grab(configsDir, id, CurrentWeaponID)
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
	//	strWeapons[32],
	//	iWeaponNum,
		m_iWeapon = 0;
	
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
	
	/*
	// Check if he has the weapon
	get_user_weapons(id, strWeapons, iWeaponNum);
	
	for (new i = 0; i < iWeaponNum; i++) 
	{
		get_weaponname(strWeapons[i], strWeapon, 31);
		
		if(equali(strWeapon, g_array[rndnum])
			|| !equali(strWeapon, "weapon_snark")	// We do not want to set this to true, if its 1 of these
			|| !equali(strWeapon, "weapon_tripmine")
			|| !equali(strWeapon, "weapon_satchel"))
		{
			bHasWeapon = true;
			m_iWeapon = i;
		}
	}
	*/
	
	/*
	get_user_weapons(id, strWeapons, iWeaponNum);
	for (new i = 0; i < 128; i++) 
	{
		new weapon = get_weaponname( strWeapons[i], strWeapon, sizeof( strWeapon ) );
		
		if (!weapon)
			continue;
		
		PrintToChat(id, strWeapon);
		
		if(equali(strWeapon, g_array[rndnum])
			|| !equali(strWeapon, "weapon_snark")	// We do not want to set this to true, if its 1 of these
			|| !equali(strWeapon, "weapon_tripmine")
			|| !equali(strWeapon, "weapon_satchel"))
		{
			bHasWeapon = true;
			m_iWeapon = i;
		}
	}
	*/
	
	new clip, ammo;
	new CurrentWeaponID = get_user_weapon(id, clip, ammo);
	
	if ( CurrentWeaponID > 0 )
	{
		get_weaponname(CurrentWeaponID, strWeapon, 31);
		if(equali(strWeapon, g_array[rndnum]))
		{
			bHasWeapon = true;
			m_iWeapon = CurrentWeaponID;
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
		PlaySound(id, SND_HOLYWEP)

		client_print(id, print_chat, "You have been gifted ^"%s^" by the gods!", rpg_get_weapontitle(g_array[rndnum]))

		new m_iSecretKey = random_num(0, 9000000000);

		// Sets the secret key
		client_cmd(id, ".rpg_mod_skey %d", m_iSecretKey);

		// Lets use AngelScript for this part, so we don't spawn weapons on the world...
		client_cmd(id, ".rpg_mod_gwep %s %d", g_array[rndnum], m_iSecretKey);

		// 5 more snarks!
		if ( stats_randomweapon[id] >= AB_WEAPON_MAX && equali(g_array[rndnum], "weapon_snark") )
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

ObtainAmmo_Grab(szFilename[], id, CurrentWeaponID)
{
	if (!file_exists(szFilename))
	{
		server_print("[ObtainAmmo_Grab] File ^"%s^" doesn't exist.", szFilename)
		return;
	}

	new File=fopen(szFilename,"r");

	// if the highest ammo level
	// and weapon string is displacer, lets give some more ammo
	if (stats_ammo[id] >= AB_AMMO_MAX && equali(rpg_get_weapon_string(CurrentWeaponID), "weapon_displacer"))
		give_item(id, "ammo_gaussclip")

	// Force 0, because Sven Co-op just breaks the "get_current_weapon" if we use custom weapons
	//CurrentWeaponID = 0;

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
				ExplodeString( g_array, 80, 227, Ammo, ',' );
				new iAmmo = -1;
				while(iAmmo++ < sizeof(g_array)-1)
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
		fclose(File);
	}

	if (CurrentWeaponID == 0)
		GiveRandomAmmo(id);

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
			give_item(id, "ammo_crossbow")
			give_item(id, "ammo_9mmAR")
			give_item(id, "ammo_scientist")
		}
		case 2:
		{
			give_item(id, "ammo_rpgclip")
			give_item(id, "ammo_357")
		}
		case 3:
		{
			give_item(id, "ammo_scientist")
			give_item(id, "ammo_762")
			give_item(id, "ammo_sporeclip")
			give_item(id, "ammo_scientist")
			give_item(id, "ammo_357")
		}
		case 5:
		{
			give_item(id, "ammo_357")
			give_item(id, "ammo_9mmAR")
			give_item(id, "ammo_buckshot")
		}
		case 6:
		{
			give_item(id, "ammo_sporeclip")
			give_item(id, "ammo_357")
			give_item(id, "ammo_762")
		}
		default:
		{
			give_item(id, "ammo_762")
			give_item(id, "ammo_556")
			give_item(id, "ammo_9mmAR")
			give_item(id, "ammo_gp25")
			give_item(id, "ammo_sporeclip")
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
			
			new SetStringValue[3583];
			
			// Map Cap, blacklisted or can we gain more EXP?
			if (!glb_MapDefined_IsBlacklisted)
			{
				// Show our Exp.
				format(SetStringValue, sizeof( SetStringValue ), "Exp.:	%i / %i", stats_xp[i], stats_neededxp[i]);
				
				// If we haven't reached the map cap
				if ( PlayerNotReachedCap(i) )
				{
					format(SetStringValue, sizeof( SetStringValue ), "%s  (+%i)^n", SetStringValue, stats_neededxp[i] - stats_xp[i]);
					
					// Is the extra bonus active?
					if (SetExtraBonus > 0)
						format(SetStringValue, sizeof( SetStringValue ), "%sBonus Exp.:	+%i^n", SetStringValue, SetExtraBonus);
				}
				else
					format(SetStringValue, sizeof( SetStringValue ), "%s  (Reached Map Cap)^n", SetStringValue);
			}
			
			// Show our level
			format(SetStringValue, sizeof( SetStringValue ), "%sLevel:	%i / %i^n", SetStringValue, stats_level[i], MAX_LEVEL);
			
			// Show our current rank
			format(SetStringValue, sizeof( SetStringValue ), "%sRank:	%s^n", SetStringValue, rank_name[i]);
			
			// Show our current medals
			format(SetStringValue, sizeof( SetStringValue ), "%sMedals:	%i / %i^n", SetStringValue, stats_medals[i], max_medals);
			
			// Show our current health
			format(SetStringValue, sizeof( SetStringValue ), "%sHealth:	%i^n", SetStringValue, get_user_health( i ));
			
			// Show our current armor
			format(SetStringValue, sizeof( SetStringValue ), "%sArmor:	%i^n", SetStringValue, get_user_armor( i ));
			
			// Show our current prestige
			format(SetStringValue, sizeof( SetStringValue ), "%sPrestige:	%i / %i^n", SetStringValue, stats_prestige[i], MAX_PRESTIGE);
			
			// Show our steamid
			format(SetStringValue, sizeof( SetStringValue ), "%sYour SteamID:	%s", SetStringValue, steamid);
			
			show_hudmessage(i, "%s", SetStringValue);
			
			// Reset!
			// Skill info load last, so we don't want to show player stats there.
			format(SetStringValue, sizeof( SetStringValue ), "")
			
			/*
			if(stats_auro_wait[i] <= 0 && !glb_AuraIsActivated || stats_holyguard_wait[i] <= 0 && !HasHolyGuard[i]) // Ready
				set_hudmessage(85, 255, 0, 0.02, 0.70, 0, 6.0, 1.2, 0.5, 0.15, -1)
			else if (stats_auro_wait[i] > 0 || stats_holyguard_wait[i] > 0) // Charging
				set_hudmessage(0, 200, 196, 0.02, 0.70, 0, 6.0, 1.2, 0.5, 0.15, -1)
			else // Default
				set_hudmessage(85, 255, 0, 0.02, 0.70, 0, 6.0, 1.2, 0.5, 0.15, -1)
			*/
			set_hudmessage(0, 200, 196, 0.02, 0.70, 0, 6.0, 0.8, 0.5, 0.15, -1)

			if(stats_points[i] > 0)
				format(SetStringValue, sizeof( SetStringValue ), "You have %d skillpoints available!^nWrite /skills to access the menu!^n^n", stats_points[i])
			
			// Aura (Boosts HP & AP)
			if(stats_auro_wait[i] <= 0)
			{
				if (stats_auro[i] > 0)
					if (glb_AuraIsActivated)
						format(SetStringValue, sizeof( SetStringValue ), "%s%s can't be used right now!", SetStringValue, AB_AURA)
					else
						format(SetStringValue, sizeof( SetStringValue ), "%s%s^n[Press 'take cover' to use]", SetStringValue, AB_AURA)
			}
			else// if(stats_auro_wait[i] > 0)
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

				format(SetStringValue, sizeof( SetStringValue ), "%s%s^n%s", SetStringValue, AB_AURA, SetValue)
			}
			
			// Holy Armor/Guard (Godmode for a brief moment)
			if(stats_holyguard_wait[i] <= 0)
			{
				if (stats_holyguard[i] > 0)
					if (HasHolyGuard[i])
						format(SetStringValue, sizeof( SetStringValue ), "%s^n^n%s can't be used right now!", SetStringValue, AB_HOLYGUARD)
					else
						format(SetStringValue, sizeof( SetStringValue ), "%s^n^n%s^n[Press 'medic' to use]", SetStringValue, AB_HOLYGUARD)
			}
			else// if(stats_holyguard_wait[i] > 0)
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

				format(SetStringValue, sizeof( SetStringValue ), "%s^n^n%s^n%s", SetStringValue, AB_HOLYGUARD, SetValue)
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
		return PLUGIN_CONTINUE;
	
	AdvertSetup++;
	
	// It can't go over the max amount.
	if (AdvertSetup > AdvertSetup_Max)
		AdvertSetup = 0;

	new iPlayers[32],
		iNum,
		formated_text[500]
	
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
					format(formated_text, sizeof(formated_text), "[RPG MOD] Want to see what commands you can write? write /help")
				case 5:
					format(formated_text, sizeof(formated_text), "[RPG MOD] You can view your stats online!: %s", WEBSITE)
				case 10:
					format(formated_text, sizeof(formated_text), "New to the server? make sure you read our /rules first!")
				case 15:
					format(formated_text, sizeof(formated_text), "[RPG MOD] Want to reset your stats? write /reset")
				case 20:
					format(formated_text, sizeof(formated_text), "Join our community over at www.theafterlife.eu")
				case 30:
					format(formated_text, sizeof(formated_text), "This server is using Sven Co-op RPG Mod Version {VERSION} by JonnyBoy0719")
			}
			if (!equali(formated_text, ""))
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
	if (glb_MapDefined_IsDisabled)
		return;

	HasSpawned[id] = false;
	HasLoadedStats[id] = false;
	stats_level[id] = 0;
}

//------------------
//	TaskDelayConnect()
//------------------

public TaskDelayConnect( id )
{
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
}

//------------------
//	PluginThink()
//------------------

public PluginThink(id)
{
	if (glb_MapDefined_IsDisabled)
		return;

	if (!equali(rank_name[id], "Loading..."))
		CheckCurrentMap(id);

	// Crappy work around... :/
	if(PlayerHasDied[id] == 1)
	{
		CheckReward(id, _KillYourself);
		if (!equali(stats_steamidmodel[id], ""))
			PlaySound_Death(id);
		PlayerHasDied[id] = 0;
		CanPlayPain[id] = false;
	}

	// Change the model to helmet right away, and tell the player that this model is exclusive to community members only.
	new custom_plymdl[501];
	get_user_info(id, "model", custom_plymdl, sizeof(custom_plymdl));
	if (!CanAccessModel(id, custom_plymdl))
	{
		set_user_info(id, "model", "helmet");
		if (!equali(stats_steamidmodel[id], ""))
		{
			stats_steamidmodel[id] = "";
			// Clear the model
			new authid[32]
			get_user_authid(id, authid, 31)
			SaveCustomModel(id, authid, false);
		}
	}

	new deadflag = pev(id, pev_deadflag)

	if( !deadflag && lastDeadflag[id] )
		OnPlayerSpawn(id);

	// We died, lets reset the stuff
	if( deadflag && lastDeadflag[id] && !is_user_alive(id) )
	{
		if(CanPlayPain[id])
			PlayerHasDied[id] = 1;

		PlayerIsHurt[id] = false;
		IsJumping[id] = false;
		HasAura[id] = false;

		CanPlayPain[id] = false

		stats_doublejump_temp[id] = 0;
	}

	lastDeadflag[id] = deadflag
}

//------------------
//	CheckCurrentMap()
//------------------

public CheckCurrentMap(id)
{
	new currentmap[33];
	get_mapname(currentmap, 32);

	if (equali(currentmap, "sc_psyko"))
		CheckReward(id, _Map_Psyko);

	if (equali(currentmap, "extreme_uboa"))
		CheckReward(id, _Map_UBOA);

	// BreakFree
	if (equali(currentmap, "breakfree") && GrabAwardProgress(id, _Map_BreakFree) == 0)
		CheckReward(id, _Map_BreakFree);
	else if (equali(currentmap, "breakfree2") && GrabAwardProgress(id, _Map_BreakFree) == 1)
		CheckReward(id, _Map_BreakFree);
	else if (equali(currentmap, "breakfree3") && GrabAwardProgress(id, _Map_BreakFree) == 2)
		CheckReward(id, _Map_BreakFree);

	// Source of Life
	if (equali(currentmap, "source_of_life") && GrabAwardProgress(id, _Map_SourceOfLife) == 0)
		CheckReward(id, _Map_SourceOfLife);
	else if (equali(currentmap, "source_of_life_1_a_v2") && GrabAwardProgress(id, _Map_SourceOfLife) == 1)
		CheckReward(id, _Map_SourceOfLife);
	else if (equali(currentmap, "source_of_life_2_a_v2") && GrabAwardProgress(id, _Map_SourceOfLife) == 2)
		CheckReward(id, _Map_SourceOfLife);
	else if ((equali(currentmap, "source_of_life_3_a") || equali(currentmap, "source_of_life_3_b")) && GrabAwardProgress(id, _Map_SourceOfLife) == 3)
		CheckReward(id, _Map_SourceOfLife);
	else if ((equali(currentmap, "source_of_life_4_a") || equali(currentmap, "source_of_life_4_b_v2")) && GrabAwardProgress(id, _Map_SourceOfLife) == 4)
		CheckReward(id, _Map_SourceOfLife);
	else if (equali(currentmap, "source_of_life_5_a") && GrabAwardProgress(id, _Map_SourceOfLife) == 5)
		CheckReward(id, _Map_SourceOfLife);
	else if (equali(currentmap, "source_of_life_end") && GrabAwardProgress(id, _Map_SourceOfLife) == 6)
		CheckReward(id, _Map_SourceOfLife);

	// If we are a community member
	if (IsCommunityMember[id] && GrabAwardProgress(id, _CommunityJoined) == 0)
		CheckReward(id, _CommunityJoined);
}

//------------------
//	PlayerHasSpawned()
//------------------

public PlayerHasSpawned(id)
{
	if (!is_user_connected(id))
		return;

	PlayerIsHurt[id] = false;
	IsJumping[id] = false;
	HasAura[id] = false;
	HasHolyGuard[id] = false;

	stats_doublejump_temp[id] = 0;

	GiveSpecialWeapons(id);

	if (!HasReadCommunityData[id])
	{
		new steamid[35];
		get_user_authid(id, steamid, charsmax(steamid))
		ReadCommunityData(id, steamid);
		HasReadCommunityData[id] = true;
	}

	if (!equali(stats_steamidmodel[id], ""))
	{
		new custom_plymdl[501];
		format(custom_plymdl, sizeof(custom_plymdl), "%s%s", MODEL_TAG, stats_steamidmodel[id]);
		set_user_info(id, "model", custom_plymdl);
		PlaySound_Spawn(id);
	}

	new medalpoints = stats_medals[id] > 0 ? floatround(stats_medals[id] * 25 / 0.1) : 0;

	// Lets calculate
	if (stats_prestige[id] > 0)
		stats_xp_bonus[id] = floatround(stats_prestige[id] / 0.1 * 25) + medalpoints + SetExtraBonus;
	else
		stats_xp_bonus[id] = medalpoints;

	set_user_health(id, rpg_get_health(id));
	set_user_armor(id, rpg_get_armor(id));
	
	// Now we should enable pain sounds
	// For some strange reason, it plays the pain sound on spawn. (Has todo with set_user_health or armor??)
	set_task(0.8, "FixPainBug", id);
}

//------------------
//	FixPainBug()
//------------------

public FixPainBug(id)
{
	CanPlayPain[id] = true;
	hurtsound_delay[id] = 3;
}

//------------------
//	OnPlayerSpawn()
//------------------

public OnPlayerSpawn(id)
{
	if (glb_MapDefined_IsDisabled)
		return;

	// If the player isn't on "Loading..." on the text, we will give the player the health, armor and the other stuff
	if (!equali(rank_name[id], "Loading..."))
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
	new hostname[101],
		plyname[32],
		formated_text[501]

	get_user_name(0, hostname, 100)
	get_user_name(id, plyname, 31)

	if ( enable_ranking )
	{
		GetPosition(id);
		format(formated_text, 500, "Welcome %s to %s! You are on rank %d.", plyname, hostname, ply_rank[id])
	}
	else
		format(formated_text, 500, "Welcome %s to %s!", plyname, hostname)

	PrintToChat(id, formated_text)
	
	set_task(0.8, "PlayerHasSpawned", id);

	BBHelp(id, false)
	CheckMedals(id);
}

//------------------
//	ShowStatsOnSpawn()
//------------------

public ShowStatsOnSpawn(id)
{
	TaskDelayConnect(id);
	ShowMyRank(id);
	set_task(1.1, "Delay_ShowStatsOnSpawn", id);
}

//------------------
//	Delay_ShowStatsOnSpawn()
//------------------

public Delay_ShowStatsOnSpawn(id)
{
	// Shitty code, but yeah.
	new players[32],
		num,
		i,
		plyname[32],
		formated_text[501]

	GetCurrentRankTitle(id)
	get_user_name(id, plyname, 31)

	get_players(players, num)
	for (i=0; i<num; i++)
	{
		if (is_user_connected(players[i]))
		{
			if (players[i] == id)
				continue;

			if (ply_rank[id] == 0)
				continue;

			if (MapJustBegun)
				continue;

			if (!equali(rank_name[id], "Loading..."))
				format(formated_text, 500, "%s is %s. Ranked %d of %d.", plyname, rank_name[id], ply_rank[id], top_rank)

			if (!equali(formated_text, ""))
				PrintToChat(players[i], formated_text)
		}
	}

	HelpOnConnect(id)

	return PLUGIN_HANDLED
}

//------------------
//	PrintToChat()
//------------------

public PrintToChat(id, string[])
{
	new FormatedText[523],
		map_time_int = get_timeleft();
	
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
	
	// Plugin Version
	replace_all(string, 500, "{VERSION}", VERSION);
	
	// Current Map
	get_mapname( FormatedText, sizeof( FormatedText ) )
	replace_all(string, 500, "{CURMAP}", FormatedText);
	
	// Timeleft
	format(FormatedText, sizeof( FormatedText ), "%d", map_time_int)
	replace_all(string, 500, "{TIMELEFT}", FormatedText);

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
		myfrags_divider = 2;
	else if (get_user_frags(id) >= 10000)
		myfrags_divider = 2;
	else if (get_user_frags(id) >= 100000)
		myfrags_divider = 20;
	else if (get_user_frags(id) >= 1000000)
		myfrags_divider = 200;
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

	// Calculate Temp EXP for the max cap
	if (glb_MapDefined_SetEXPCap > 0 && stats_xp_temp[id] > stats_xp_cap[id])
		stats_xp_temp[id] = floatround( m_fgrb_vlues + rndnum ) + stats_xp_bonus[id] + SetExtraBonus;
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

	if (HasAura[id])
		glb_AuraIsActivated = false;
	
	PlayerIsHurt[id] = false;
	IsJumping[id] = false;
	HasAura[id] = false;
	HasHolyGuard[id] = false;

	IsCommunityMember[id] = false;
	HasReadCommunityData[id] = false;

	stats_doublejump_temp[id] = 0;
	stats_randomweapon_wait[id] = 0;
	stats_auro_timer[id] = 0;
	stats_holyguard_timer[id] = 0;
	stats_ammo_wait[id] = 0;
}

//------------------
//	CheckReward()
//------------------

public CheckReward(id, Reward)
{
	if (!ArrayBuilt)
		return;

	new steamid[35];
	get_user_authid(id, steamid, charsmax(steamid))

	if(GetClientRewardStatus(RewardsPointer[ Reward ], RewardsData[ Reward ][ id ]) == _In_Progress)
	{
		RewardsData[ Reward ][ id ]++;
		SetRewardData( steamid, RewardsInfo[ Reward ][ _Save_Name ], RewardsData[ Reward ][ id ] );

		// check if client just unlocked the achievement
		if(GetClientRewardStatus(RewardsPointer[ Reward ], RewardsData[ Reward ][ id ]) == _Unlocked)
		{
			stats_xp[id] = stats_xp[id] + RewardsInfo[ Reward ][ _ExpGain ];
			stats_medals[id] = stats_medals[id] + RewardsInfo[ Reward ][ _Medals ];
			ClientRewardCompleted( id, RewardsPointer[ Reward ], .Announce = true );
		}
	}
}

//------------------
//	IsRewardCompleted()
//------------------

public IsRewardCompleted(id, Reward)
{
	if (!ArrayBuilt)
		return false;

	if(GetClientRewardStatus(RewardsPointer[ Reward ], RewardsData[ Reward ][ id ]) == _Unlocked)
		return true;

	return false;
}

//------------------
//	GrabAwardProgress()
//------------------

stock GrabAwardProgress(id, Reward)
{
	new iProgress,
		steamid[35];
	get_user_authid(id, steamid, charsmax(steamid))

	if(GetClientRewardStatus(RewardsPointer[ Reward ], RewardsData[ Reward ][ id ]) == _In_Progress)
		iProgress = RewardsData[ Reward ][ id ];

	return iProgress;
}

// ============================================================//
//						  [~ Saving datas ~]					//
// ============================================================//

//------------------
//	SQL_Init()
//------------------
public SQL_Init()
{
	static szHost[64], szUser[32], szPass[32], szDB[32], szDB_MYBB[32];
	static get_type[12], set_type[12]

	get_pcvar_string( mysqlx_host, szHost, sizeof(szHost) );
	get_pcvar_string( mysqlx_user, szUser, sizeof(szUser) );
	get_pcvar_string( mysqlx_type, set_type, sizeof(set_type) );
	get_pcvar_string( mysqlx_pass, szPass, sizeof(szPass) );
	get_pcvar_string( mysqlx_db, szDB, sizeof(szDB) );
	get_pcvar_string( mysqlx_db_mybb, szDB_MYBB, sizeof(szDB_MYBB) );
	get_pcvar_string( mysqlx_table, sql_table, sizeof(sql_table) );
	
	SQL_GetAffinity(get_type, 12);
	
	sql_db = SQL_MakeDbTuple( szHost, szUser, szPass, szDB );

	// MyBB Intergration
	if (!equali(szDB_MYBB, ""))
		sql_mybb_db = SQL_MakeDbTuple( szHost, szUser, szPass, szDB_MYBB );

	sql_api = SQL_Connect(sql_db, sql_errno, sql_error, 127);

	// MyBB Intergration
	if (!equali(szDB_MYBB, ""))
		sql_mybb_api = SQL_Connect(sql_mybb_db, sql_errno, sql_error, 127);

	if (sql_api == Empty_Handle)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_CON", sql_error);

	if (sql_mybb_api == Empty_Handle
		&& !equali(szDB_MYBB, ""))
		server_print("[AMXX -- MYBB] %L", LANG_SERVER, "SQL_CANT_CON", sql_error);

	// check if the table exist
	formatex( sql_cache, 1023, "show tables like '%s'", sql_table );
	SQL_ThreadQuery( sql_db, "ShowTableHandle", sql_cache );	
}

//------------------
//	ShowTableHandle()
//------------------
public ShowTableHandle(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
	if(FailState==TQUERY_CONNECT_FAILED){
		log_amx( "[RPGMOD SQL] Could not connect to SQL database." );
		log_amx( "[RPGMOD SQL] Stats won't be saved" );
		glb_MapDefined_IsDisabled = true;
		return PLUGIN_CONTINUE;
	}
	else if (FailState == TQUERY_QUERY_FAILED)
	{
		log_amx( "[RPGMOD SQL] Query failed." );
		log_amx( "[RPGMOD SQL] Stats won't be saved" );
		glb_MapDefined_IsDisabled = true;
		return PLUGIN_CONTINUE;
	}

	if (Errcode)
	{
		log_amx( "[RPGMOD SQL] Error on query: %s", Error );
		log_amx( "[RPGMOD SQL] Stats won't be saved" );
		glb_MapDefined_IsDisabled = true;
		return PLUGIN_CONTINUE;
	}

	if (SQL_NumResults(Query) > 0)
		log_amx( "[RPGMOD DEBUG] Database table found: %s", sql_table );
	else
	{
		log_amx( "[RPGMOD SQL] Could not find the table: %s", sql_table );
		log_amx( "[RPGMOD SQL] Stats won't be saved" );
		glb_MapDefined_IsDisabled = true;
	}
	return PLUGIN_CONTINUE;
}

//------------------
//	LoadDataHandle()
//------------------
public LoadDataHandle(FailState,Handle:Query,Error[],Errcode,Data[],DataSize) {
	if (FailState == TQUERY_CONNECT_FAILED)
		return set_fail_state("Could not connect to SQL database.")
	else if (FailState == TQUERY_QUERY_FAILED)
		return set_fail_state("Query failed.")

	if (Errcode)
		return log_amx("Error on query: %s",Error)

	new id = Data[0];

	if (SQL_NumResults(Query) >= 1)
	{
		new auth_self[33];
		get_user_authid(id, auth_self, 32);
		server_print("loaded stats for:^nID: ^"%s^"", auth_self)
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
			settings_sound,
			settings_plymodel,
			settings_plymodel_saved,
			exp;

		exp = SQL_FieldNameToNum(Query, "exp");
		lvl = SQL_FieldNameToNum(Query, "lvl");
		hps = SQL_FieldNameToNum(Query, "skill_hp");
		hps_set = SQL_FieldNameToNum(Query, "skill_sethp");
		armor = SQL_FieldNameToNum(Query, "skill_armor");
		armor_set = SQL_FieldNameToNum(Query, "skill_setarmor");
		holyguard = SQL_FieldNameToNum(Query, "skill_holyguard");
		ammo = SQL_FieldNameToNum(Query, "skill_ammo");
		doublejump = SQL_FieldNameToNum(Query, "skill_doublejump");
		auro = SQL_FieldNameToNum(Query, "skill_aura");
		weapon = SQL_FieldNameToNum(Query, "skill_weapon");
		points = SQL_FieldNameToNum(Query, "points");
		medals = SQL_FieldNameToNum(Query, "medals");
		prestige = SQL_FieldNameToNum(Query, "prestige");
		settings_sound = SQL_FieldNameToNum(Query, "settings_sound");
		settings_plymodel = SQL_FieldNameToNum(Query, "settings_plymodel");
		settings_plymodel_saved = SQL_FieldNameToNum(Query, "settings_plymodel_saved");

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
			sql_prestige,
			sql_settings_sound,
			sql_settings_plymodel[185],
			sql_settings_plymodel_saved[185];

		while (SQL_MoreResults(Query))
		{
			sql_lvl = SQL_ReadResult(Query, lvl);
			sql_exp = SQL_ReadResult(Query, exp);
			sql_ammo = SQL_ReadResult(Query, ammo);
			sql_hps = SQL_ReadResult(Query, hps);
			sql_hps_set = SQL_ReadResult(Query, hps_set);
			sql_armor = SQL_ReadResult(Query, armor);
			sql_armor_set = SQL_ReadResult(Query, armor_set);
			sql_holyguard = SQL_ReadResult(Query, holyguard);
			sql_doublejump = SQL_ReadResult(Query, doublejump);
			sql_auro = SQL_ReadResult(Query, auro);
			sql_weapon = SQL_ReadResult(Query, weapon);
			sql_points = SQL_ReadResult(Query, points);
			sql_medals = SQL_ReadResult(Query, medals);
			sql_prestige = SQL_ReadResult(Query, prestige);
			sql_settings_sound = SQL_ReadResult(Query, settings_sound);
			SQL_ReadResult(Query, settings_plymodel, sql_settings_plymodel, 31);
			SQL_ReadResult(Query, settings_plymodel_saved, sql_settings_plymodel_saved, 31);

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
			stats_settings_sound[id] = sql_settings_sound;
			stats_steamidmodel[id] = sql_settings_plymodel;
			stats_steamidmodel_saved[id] = sql_settings_plymodel_saved;
			//-----

			SQL_NextRow(Query);
		}
	}
	
	// Calculate the needed EXP
	CalculateEXP_Needed(id);
	
	return PLUGIN_CONTINUE;
}

//------------------
//	LoadDataTitle()
//------------------
public LoadDataTitle(FailState,Handle:Query,Error[],Errcode,Data[],DataSize) {
	if (FailState == TQUERY_CONNECT_FAILED)
		return set_fail_state("Could not connect to SQL database.")
	else if (FailState == TQUERY_QUERY_FAILED)
		return set_fail_state("Query failed.")

	if (Errcode)
		return log_amx("Error on query: %s",Error)

	new id = Data[0];

	while (SQL_MoreResults(Query))
	{
		// Not the best code, this needs improvements...
		new ranktitle[185]
		SQL_ReadResult(Query, 1, ranktitle, 31)
		// This only gets the max players on the database
		top_rank = rank_max
		// This reads the players EXP, and then checks with other players EXP to get the players rank
		GetPosition(id);
		// Sets the title
		rank_name[id] = ranktitle;
		SQL_NextRow(Query);
	}
	return PLUGIN_CONTINUE;
}

//------------------
//	CreatePlayerData()
//------------------
public CreatePlayerData(FailState,Handle:Query,Error[],Errcode,Data[],DataSize) {
	if (FailState == TQUERY_CONNECT_FAILED)
		return set_fail_state("Could not connect to SQL database.")
	else if (FailState == TQUERY_QUERY_FAILED)
		return set_fail_state("Query failed.")

	if (Errcode)
		return log_amx("Error on query: %s",Error)

	new id = Data[0];
	new auth[33];
	get_user_authid(id, auth, 32);

	if (!SQL_NumResults(Query)) {
		console_print(id, "Adding to database:^nID: ^"%s^"", auth)
		server_print("Adding to database:^nID: ^"%s^"", auth)

		HasLoadedStats[id] = true;

		new plyname[32]
		get_user_name(id, plyname, 31)

		// Escape strings
		replace_all( plyname, charsmax(plyname), "`", "");
		replace_all( plyname, charsmax(plyname), "'", "");
		replace_all( plyname, charsmax(plyname), "\", "");

		formatex(sql_cache, 1023, "INSERT INTO `%s` (`authid`, `name`) VALUES ('%s', '%s')", sql_table, auth, plyname);
		new send_id[1];
		send_id[0] = id;
		SQL_ThreadQuery(sql_db, "QueryHandle", sql_cache);
	}
	return PLUGIN_CONTINUE;
}

//------------------
//	QueryHandle()
//------------------
public QueryHandle( FailState, Handle:Query, Error[], Errcode, Data[], DataSize ) {
	// lots of error checking
	if ( FailState == TQUERY_CONNECT_FAILED ) {
		log_amx( "[RPGMOD SQL] Could not connect to SQL database." );
		return set_fail_state("[RPGMOD SQL] Could not connect to SQL database.");
	}
	else if ( FailState == TQUERY_QUERY_FAILED ) {
		new sql[1024];
		SQL_GetQueryString ( Query, sql, 1024 );
		log_amx( "[RPGMOD SQL] SQL Query failed: %s", sql );
		return set_fail_state("[RPGMOD SQL] SQL Query failed.");
	}

	if ( Errcode )
		return log_amx( "[RPGMOD SQL] SQL Error on query: %s", Error );
	return PLUGIN_CONTINUE;
}

//------------------
//	LoadDataPosition()
//------------------
public LoadDataPosition(FailState,Handle:Query,Error[],Errcode,Data[],DataSize) {
	if (FailState == TQUERY_CONNECT_FAILED)
		return set_fail_state("Could not connect to SQL database.")
	else if (FailState == TQUERY_QUERY_FAILED)
		return set_fail_state("Query failed.")

	if (Errcode)
		return log_amx("Error on query: %s",Error)

	new id = Data[0];
	
	static Position;

	// If used, lets reset it
	Position = 0;

	while (SQL_MoreResults(Query))
	{
		Position++
		new authid[33]
		SQL_ReadResult(Query, 0, authid, 32)
		new auth_self[33];
		get_user_authid(id, auth_self, 32);
		if (equal(auth_self, authid))
			ply_rank[id] = Position;
		SQL_NextRow(Query);
	}
	return PLUGIN_CONTINUE;
}

//------------------
//	LoadDataRank()
//------------------
public LoadDataRank(FailState,Handle:Query,Error[],Errcode,Data[],DataSize) {
	if (FailState == TQUERY_CONNECT_FAILED)
		return set_fail_state("Could not connect to SQL database.")
	else if (FailState == TQUERY_QUERY_FAILED)
		return set_fail_state("Query failed.")

	if (Errcode)
		return log_amx("Error on query: %s",Error)
	
	// Reset the max rank
	rank_max = 0;

	while (SQL_MoreResults(Query))
	{
		rank_max++;
		SQL_NextRow(Query);
	}
	return PLUGIN_CONTINUE;
}

//------------------
//	SaveLevel()
//------------------

SaveLevel(id, auth[])
{
	if (glb_MapDefined_IsDisabled)
		return;

	if (!HasLoadedStats[id])
		return;

	new table[32]

	get_cvar_string("rpg_table", table, 31)

	new Handle:query = SQL_PrepareQuery(sql_api, "SELECT * FROM `%s` WHERE (`authid` = '%s')", table, auth)

	if (!SQL_Execute(query))
	{
		server_print("query not saved")
		SQL_QueryError(query, sql_error, 127)
		server_print("[AMXX] %L", LANG_SERVER, "SQL_CANT_LOAD_ADMINS", sql_error)
	} else {
		new plyname[32]
		get_user_name(id, plyname, 31)
		
		// Escape strings
		replace_all( plyname, charsmax(plyname), "`", "");
		replace_all( plyname, charsmax(plyname), "'", "");
		replace_all( plyname, charsmax(plyname), "\", "");

		SQL_QueryAndIgnore(sql_api,
			"UPDATE `%s` SET `name` = '%s', `lvl` = %d, `skill_hp` = %i, `skill_sethp` = %i, `skill_armor` = %i, `skill_setarmor` = %i, `skill_doublejump` = %d, `skill_aura` = %d, `skill_holyguard` = %d, `skill_ammo` = %d, `skill_weapon` = %d, `points` = %d, `medals` = %d, `prestige` = %d, `exp` = %d, `settings_sound` = %d WHERE `authid` = '%s';",
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
			stats_settings_sound[id],
			auth
		)
	}

	SQL_FreeHandle(query)
}

//------------------
//	LoadLevel()
//------------------

LoadLevel(id, auth[], LoadMyStats = true)
{
	if (!id)
		return;
	
	if (glb_MapDefined_IsDisabled)
		return;

	if (LoadMyStats)
	{
		formatex( sql_cache, 1023, "SELECT * FROM `%s` WHERE (`authid` = '%s')", sql_table, auth);
		new send_id[1];
		send_id[0] = id;
		SQL_ThreadQuery(sql_db, "LoadDataHandle", sql_cache, send_id, 1);
	}
	else
	{
		formatex( sql_cache, 1023, "SELECT `authid` FROM `%s`", sql_table);
		SQL_ThreadQuery(sql_db, "LoadDataRank", sql_cache);
		set_task(0.5, "DisplayLevel", id)
	}
}

//------------------
//	DisplayLevel()
//------------------

public DisplayLevel(id)
{
	if (!id)
		return;
	
	new table[32]
	get_cvar_string("rpg_rank_table", table, 31)
	
	formatex( sql_cache, 1023, "SELECT * FROM `%s` WHERE `lvl` <= (%d) and `lvl` ORDER BY abs(`lvl` - %d) LIMIT 1", table, stats_level[id], stats_level[id]);
	new send_id[1];
	send_id[0] = id;
	SQL_ThreadQuery(sql_db, "LoadDataTitle", sql_cache, send_id, 1);
}

//------------------
//	GetPosition()
//------------------

GetPosition(id)
{
	if (!id)
		return;
	
	formatex( sql_cache, 1023, "SELECT `authid` FROM `%s` ORDER BY `prestige` DESC, `lvl` + 0 DESC", sql_table);
	new send_id[1];
	send_id[0] = id;
	SQL_ThreadQuery(sql_db, "LoadDataPosition", sql_cache, send_id, 1);
}

//------------------
//	CreateStats()
//------------------

CreateStats(id, auth[])
{
	if (glb_MapDefined_IsDisabled)
		return;
	
	formatex( sql_cache, 1023, "SELECT * FROM `%s` WHERE (`authid` = '%s')", sql_table, auth);
	new send_id[1];
	send_id[0] = id;
	SQL_ThreadQuery(sql_db, "CreatePlayerData", sql_cache, send_id, 1);
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
//	PlaySound_Spawn()
//------------------

stock PlaySound_Spawn(id)
{
	emit_sound(id, CHAN_STATIC, GrabCustomPlayerSound(id, "spawn"), VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

//------------------
//	PlaySound_Death()
//------------------

stock PlaySound_Death(id)
{
	emit_sound(id, CHAN_STATIC, GrabCustomPlayerSound(id, "death"), VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

//------------------
//	PlaySound_Pain()
//------------------

stock PlaySound_Pain(id)
{
	if (CanPlayPain[id])
		emit_sound(id, CHAN_STATIC, GrabCustomPlayerSound(id, "pain"), VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

//------------------
//	PlaySound_Medic()
//------------------

stock PlaySound_Medic(id)
{
	emit_sound(id, CHAN_STATIC, GrabCustomPlayerSound(id, "medic"), VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

//------------------
//	PlaySound_Grenade()
//------------------

stock PlaySound_Grenade(id)
{
	emit_sound(id, CHAN_STATIC, GrabCustomPlayerSound(id, "grenade"), VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

//------------------
//	GrabCustomPlayerSound()
//------------------

stock GrabCustomPlayerSound(id, sndvalue[])
{
	new return_string[512],
		temp_string[125],
		configsDir[64],
		m_iRandomID;

	// Set num as 0 each time.
	m_iRandomID = 0;

	// Always start with SND_NULL
	format(return_string, sizeof(return_string), SND_NULL);

	// Lets add the = in the format.
	// So that pain becomes pain= etc
	format(temp_string, 500, "%s=", sndvalue)

	get_configsdir(configsDir, 63);

	format(configsDir, 63, "%s/sc_rpg/customplayers.ini", configsDir);

	if (!file_exists(configsDir))
	{
		server_print("[GrabCustomPlayerSound] File ^"%s^" doesn't exist.", configsDir);
		server_print("[GrabCustomPlayerSound] plays default sound: null.wav instead");
		return return_string;
	}

	// If its empty, return null.wav
	if (equali(temp_string, "="))
		return return_string;

	new File = fopen(configsDir,"r");

	if (File)
	{
		new Text[512],
			ModelID[32],
			TypeID[32];
		new Sounds[512];

		while (!feof(File))
		{
			fgets(File, Text, sizeof(Text)-1);

			trim(Text);

			// comment
			if (Text[0]==';')
				continue;

			ModelID[0]=0;
			TypeID[0]=0;
			Sounds[0]=0;

			// not enough parameters
			if (parse(Text, ModelID, sizeof(ModelID)-1, TypeID, sizeof(TypeID)-1, Sounds, sizeof(Sounds)-1) < 3)
				continue;

			if(equali(stats_steamidmodel[id], ModelID))
			{
				ExplodeString( array_plysnds, 80, 227, Sounds, ',' );
				new iSound = -1;
				while(iSound++ < sizeof(array_plysnds)-1)
				{
					if(containi(array_plysnds[iSound], temp_string) != -1)
					{
						replace_all(array_plysnds[iSound], 226, temp_string, "");
						new playprecachedsound[125]
						format(playprecachedsound, sizeof(playprecachedsound), "afterlife/player/%s", array_plysnds[iSound])
						//log_amx(playprecachedsound);
						array_plysnds_temp[m_iRandomID] = playprecachedsound;
						m_iRandomID++;
					}
					// Reset the current array of player sound
					array_plysnds[iSound][0] = 0;
				}
			}
		}
		fclose(File);
	}

	// if m_iRandomID is still 0, just return "null.wav"
	if (m_iRandomID == 0)
		return return_string;

	new rndnum = random_num(0, m_iRandomID-1);
	format(return_string, sizeof(return_string), "%s", array_plysnds_temp[rndnum]);

	// Lets clear the temp array, before we return the string.
	for( new i = 0; i <= m_iRandomID; i++ )
		array_plysnds_temp[i][0] = 0;

	return return_string;
}

//------------------
//	GrabCustomPlayerModel()
//------------------

stock GrabCustomPlayerModel(model[])
{
	new return_string[512],
		configsDir[64];
	
	get_configsdir(configsDir, 63);
	
	format(configsDir, 63, "%s/sc_rpg/customplayers.ini", configsDir);
	
	if (!file_exists(configsDir))
	{
		server_print("[GrabCustomPlayerModel] File ^"%s^" doesn't exist.", configsDir);
		format(return_string, 63, "");
		return return_string;
	}
	
	new File = fopen(configsDir,"r");
	
	if (File)
	{
		new Text[512],
			ModelID[32],
			TypeID[32],
			Sounds[512];

		while (!feof(File))
		{
			fgets(File, Text, sizeof(Text)-1);

			trim(Text);

			// comment
			if (Text[0]==';')
				continue;

			ModelID[0]=0;
			TypeID[0]=0;
			Sounds[0]=0;

			// not enough parameters
			if (parse(Text, ModelID, sizeof(ModelID)-1, TypeID, sizeof(TypeID)-1, Sounds, sizeof(Sounds)-1) < 2)
				continue;
			
			if(equali(model, ModelID))
				format(return_string, sizeof(return_string), "%s", ModelID);
		}
		fclose(File);
	}
	
	return return_string;
}

//------------------
//	CanAccessModel()
//------------------

stock CanAccessModel(id, model[])
{
	// If we are an admin/owner or w/e, we can use these models no matter what.
	if ( access(id, ADMIN_ADMIN) )
		return true;

	new configsDir[64],
		bool:ReturnValue = true;

	get_configsdir(configsDir, 63);

	format(configsDir, 63, "%s/sc_rpg/customplayers.ini", configsDir);

	if (!file_exists(configsDir))
	{
		server_print("[CanAccessModel] File ^"%s^" doesn't exist.", configsDir);
		return false;
	}

	new File = fopen(configsDir,"r");

	if (File)
	{
		new Text[512],
			ModelID[32],
			ModelIDFormated[32],
			TypeID[32],
			Sounds[512];

		while (!feof(File))
		{
			fgets(File, Text, sizeof(Text)-1);

			trim(Text);

			// comment
			if (Text[0]==';')
				continue;

			ModelID[0]=0;
			TypeID[0]=0;
			Sounds[0]=0;

			// not enough parameters
			if (parse(Text, ModelID, sizeof(ModelID)-1, TypeID, sizeof(TypeID)-1, Sounds, sizeof(Sounds)-1) < 2)
				continue;

			// Lets make sure the ModelID is the same as our player model
			format(ModelIDFormated, sizeof(ModelIDFormated), "%s%s", MODEL_TAG, ModelID);

			// not the correct model
			if(!equali(model, ModelIDFormated))
				continue;

			// Types:
			//	0 - Community
			//	1 - Prestige
			//	2 - Special (Must be applied by rpg_setmodel)
			//	3 - Donator only

			new TypeNum = str_to_num(TypeID);

			// The model is Type 0
			if ( TypeNum == 0 && !IsCommunityMember[id])
			{
				client_print(id, print_chat, "You must be a community member to use this model.");
				ReturnValue = false;
			}

			// The model is Type 1
			if ( TypeNum == 1 && stats_prestige[id] < 10)
			{
				client_print(id, print_chat, "You need to be prestige 10 to use this model.");
				ReturnValue = false;
			}

			// The model is Type 2
			if ( TypeNum == 2 && !equali(ModelID, stats_steamidmodel_saved[id]))
			{
				client_print(id, print_chat, "You do not have permission to use this model.");
				ReturnValue = false;
			}
		}
		fclose(File);
	}

	return ReturnValue;
}

//------------------
//	PlayerNotReachedCap()
//------------------

PlayerNotReachedCap(id)
{
	if (!glb_MapDefined_HasSetCap[id]) return true;
	// Lets check if the temp is higher or equals to the cap.
	if (stats_xp_temp[id] > stats_xp_cap[id]) return false;
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

//------------------
//	getSteam2()
//------------------

new const szBase[] = "76561197960265728";

stock getSteam2(const szSteam64[], szSteam2[], iLen)
{
	new iBorrow = 0;
	new szSteam[18];
	new szAccount[18];
	new iY = 0;
	new iZ = 0;
	new iTemp = 0;
	
	arrayset(szAccount, '0', charsmax(szAccount));
	copy(szSteam, charsmax(szSteam), szSteam64);
	
	
	if (intval(szSteam[16]) % 2 == 1)
	{
		iY = 1;
		szSteam[16] = strval(intval(szSteam[16]) - 1);
	}
	
	for (new k = 16; k >= 0; k--)
	{
		if (iBorrow > 0)
		{
			iTemp = intval(szSteam[k]) - 1;
			
			if (iTemp >= intval(szBase[k]))
			{
				iBorrow = 0;
				szAccount[k] = strval(iTemp - intval(szBase[k]));
			}
			else
			{
				iBorrow = 1;
				szAccount[k] = strval((iTemp + 10) - intval(szBase[k]));
			}
		}
		else
		{
			if (intval(szSteam[k]) >= intval(szBase[k]))
			{
				iBorrow = 0;
				szAccount[k] = strval(intval(szSteam[k]) - intval(szBase[k]));
			}
			else
			{
				iBorrow = 1;
				szAccount[k] = strval((intval(szSteam[k]) + 10) - intval(szBase[k]));
			}
		}
	}
	
	iZ = str_to_num(szAccount);
	iZ /= 2;
	
	formatex(szSteam2, iLen, "STEAM_0:%d:%d", iY, iZ);
}

//------------------
//	getSteam64()
//------------------

stock getSteam64(const szSteam2[], szSteam64[18])
{
	new iCarry = 0;
	new szAccount[18];
	new iTemp = 0;
	
	copy(szSteam64, charsmax(szSteam64), szBase);
	formatex(szAccount, charsmax(szAccount), "%s", szSteam2[10]);
	formatex(szAccount, charsmax(szAccount), "%017d", str_to_num(szAccount));
	
	szSteam64[16] = strval(intval(szSteam64[16]) + intval(szSteam2[8]));
	
	for (new j = 0; j < 2; j++)
	{
		for (new k = 16; k >= 0; k--)
		{
			if (iCarry > 0)
			{
				iTemp = intval(szSteam64[k-iCarry+1]) + 1;
				
				if (iTemp > 9)
				{
					iTemp -= 10;
					szSteam64[k-iCarry+1] = strval(iTemp);
					iCarry += 1;
				}
				else
				{
					szSteam64[k-iCarry+1] = strval(iTemp);
					iCarry = 0;
				}
				
				k++;
			}
			else
			{
				iTemp = intval(szSteam64[k]) + intval(szAccount[k]);
				
				if (iTemp > 9)
				{
					iCarry = 1;
					iTemp -= 10;
				}
				
				szSteam64[k] = strval(iTemp);
			}
		}
	}
}

//------------------
//	strval()
//------------------

stock strval(const iNum)
{
	return '0' + ((iNum >= 0 && iNum <= 9) ? iNum : 0);
}

//------------------
//	intval()
//------------------

stock intval(cNum)
{
	return (cNum >= '0' && cNum <= '9') ? (cNum - '0') : 0;
}
