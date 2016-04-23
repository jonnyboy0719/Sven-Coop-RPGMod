dictionary g_PlayerData;

CClientCommand c_rpg_mod_skey( "rpg_mod_skey", "", @CVAR_SetSecretKey );
CClientCommand c_rpg_mod_gwep( "rpg_mod_gwep", "", @CVAR_GrabWeapon );

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "JonnyBoy0719" );
	g_Module.ScriptInfo.SetContactInfo( "n/a" );
	
	g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
}

HookReturnCode ClientDisconnect(CBasePlayer@ pPlayer)
{
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	if(g_PlayerData.exists(szSteamId))
		g_PlayerData.delete(szSteamId);
	return HOOK_CONTINUE;
}

void CVAR_SetSecretKey( const CCommand@ args )
{
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
	
	const string SetKey = args[ 1 ];
	
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	PlayerData data;
	data.sKey = SetKey;
	g_PlayerData[szSteamId] = data;
	
	g_Scheduler.SetTimeout("DeleteKey", 0.01f, g_EngineFuncs.IndexOfEdict(pPlayer.edict()));
}

void CVAR_GrabWeapon( const CCommand@ args )
{
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
	
	const string GetWeapon = args[ 1 ];
	const string GetKey = args[ 2 ];
	
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	
	if(g_PlayerData.exists(szSteamId))
	{
		PlayerData@ data = cast<PlayerData@>(g_PlayerData[szSteamId]);
		if (data.sKey == GetKey)
		{
			bool validItem = false;
			if (args[0].Find("weapon_") == 0) validItem = true;
			if (args[0].Find("ammo_") == 0) validItem = true;
			if (args[0].Find("item_") == 0) validItem = true;
				
			if (validItem)
				pPlayer.GiveNamedItem(GetWeapon, 0, 0);
			g_Scheduler.SetTimeout("DeleteKey", 0.5f, g_EngineFuncs.IndexOfEdict(pPlayer.edict()));
		}
	}
}

void DeleteKey(int &in pIndex)
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(pIndex);
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	if(g_PlayerData.exists(szSteamId))
		g_PlayerData.delete(szSteamId);
}

class PlayerData
{
	string sKey;
}