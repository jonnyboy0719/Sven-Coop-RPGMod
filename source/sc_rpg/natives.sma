// API by Xellath
// Modified by JonnyBoy0719

//#define DebugMode

const MaxClients = 33;
const MaxSteamIdChars = 35;

enum Status
{
	_In_Progress = 0,
	_Unlocked
};

enum _:RewardsStruct
{
	_Name[ MaxClients ],
	_Description[ 256 ],
	Array:_Data
};

enum _:RewardDataStruct
{
	_Save_Name[ MaxClients ],
	_Max_Value
};

new Array:Reward;

new RewardsCompleted[ MaxClients + 1 ];

new ForwardClientReward;
new ForwardRewardReturn;

public plugin_natives()
{
	register_library( "sc_rpg_api" );
	
	register_native( "RegisterReward", "_RegisterReward" );
	
	register_native( "ClientRewardCompleted", "_ClientRewardCompleted" );
	
	register_native( "GetClientRewardStatus", "_GetClientRewardStatus" );
	
	register_native( "GetClientRewardsCompleted", "_GetClientRewardsCompleted" );
	register_native( "GetMaxRewards", "_GetMaxRewards" );
	
	register_native( "GetRewardName", "_GetRewardName" );
	register_native( "GetRewardDesc", "_GetRewardDesc" );
	
	register_native( "GetRewardSaveKey", "_GetRewardSaveKey" );
	register_native( "GetRewardMaxValue", "_GetRewardMaxValue" );

	register_native( "SetRewardData", "_SetRewardData" );
	register_native( "GetRewardData", "_GetRewardData" );
}

public _RegisterReward( Plugin, Params )
{
	new RewardData[ RewardsStruct ];
	get_string( 1, RewardData[ _Name ], charsmax( RewardData[ _Name ] ) );
	get_string( 2, RewardData[ _Description ], charsmax( RewardData[ _Description ] ) );
	
	RewardData[ _Data ] = _:ArrayCreate( RewardDataStruct );
	
	ArrayPushArray( Reward, RewardData );
	
	new CurrentReward = ArraySize( Reward );
	
	new Data[ RewardDataStruct ];
	get_string( 3, Data[ _Save_Name ], charsmax( Data[ _Save_Name ] ) );
	
	Data[ _Max_Value ] = get_param( 4 );
	
	ArrayPushArray( RewardData[ _Data ], Data );
	
	#if defined DebugMode
		log_amx( "debug: %i CurrentReward", CurrentReward );
	#endif
	
	return ( CurrentReward - 1 );
}

public _ClientRewardCompleted( Plugin, Params )
{
	new Client = get_param( 1 );
	new RewardPointer = get_param( 2 );
	
	RewardsCompleted[ Client ]++;
	
	if( get_param( 3 ) )
	{
		new RewardData[ RewardsStruct ];
		ArrayGetArray( Reward, RewardPointer, RewardData );
		
		new Data[ RewardDataStruct ];
		ArrayGetArray( RewardData[ _Data ], 0, Data );
		
		new ClientName[ MaxClients ];
		get_user_name( Client, ClientName, charsmax( ClientName ) );
		
		// Example:
		// <player> has unlocked the challange "My first challenge!" - 5 out of 10 challenge(s) completed
		
		client_print( 0, print_chat, 
			"%s has unlocked the challenge ^"%s^" - %i out of %i challenge(s) completed",
			ClientName,
			RewardData[ _Name ],
			RewardsCompleted[ Client ],
			ArraySize( Reward )
		);
		
		ExecuteForward( ForwardClientReward, ForwardRewardReturn, RewardPointer, Client );
	}
}

public Status:_GetClientRewardStatus( Plugin, Params )
{
	new RewardPointer = get_param( 1 );
	
	#if defined DebugMode
		log_amx( "debug: %i RewardPointer", RewardPointer );
	#endif
	
	new RewardData[ RewardsStruct ];
	ArrayGetArray( Reward, RewardPointer, RewardData );
	
	new Data[ RewardDataStruct ];
	ArrayGetArray( RewardData[ _Data ], 0, Data );
	
	if( get_param( 2 ) >= Data[ _Max_Value ] )
		return _Unlocked;
	
	return _In_Progress;
}

public _GetClientRewardsCompleted( Plugin, Params )
{
	return RewardsCompleted[ get_param( 1 ) ];
}

public _GetMaxRewards( Plugin, Params )
{
	return ArraySize( Reward );
}

public _GetRewardName( Plugin, Params )
{
	new RewardPointer = get_param( 1 );
	new RewardData[ RewardsStruct ];
	ArrayGetArray( Reward, RewardPointer, RewardData );
	
	set_string( 2, RewardData[ _Name ], charsmax( RewardData[ _Name ] ) );
}

public _GetRewardDesc( Plugin, Params )
{
	new RewardPointer = get_param( 1 );
	new RewardData[ RewardsStruct ];
	ArrayGetArray( Reward, RewardPointer, RewardData );
	
	set_string( 2, RewardData[ _Description ], charsmax( RewardData[ _Description ] ) );
}

public _GetRewardSaveKey( Plugin, Params )
{
	new RewardPointer = get_param( 1 );
	new RewardData[ RewardsStruct ];
	ArrayGetArray( Reward, RewardPointer, RewardData );
	
	new Data[ RewardDataStruct ];
	ArrayGetArray( RewardData[ _Data ], 0, Data );
	
	set_string( 2, Data[ _Save_Name ], charsmax( Data[ _Save_Name ] ) );
}

public _GetRewardMaxValue( Plugin, Params )
{
	new RewardPointer = get_param( 1 );
	new RewardData[ RewardsStruct ];
	ArrayGetArray( Reward, RewardPointer, RewardData );
	
	new Data[ RewardDataStruct ];
	ArrayGetArray( RewardData[ _Data ], 0, Data );
	
	return Data[ _Max_Value ];
}

public _SetRewardData( Plugin, Params )
{
	new Key[ MaxSteamIdChars ],
		SaveName[ MaxClients ];
	get_string( 1, Key, charsmax( Key ) );
	get_string( 2, SaveName, charsmax( SaveName ) );
	
	sqlv_connect( VaultHandle );
	
	sqlv_set_num_ex( VaultHandle, Key, SaveName, get_param( 3 ) );
	
	sqlv_disconnect( VaultHandle );
}

public _GetRewardData( Plugin, Params )
{
	new Key[ MaxSteamIdChars ], SaveName[ MaxClients ];
	get_string( 1, Key, charsmax( Key ) );
	get_string( 2, SaveName, charsmax( SaveName ) );
	
	new Data;
	
	sqlv_connect( VaultHandle );
	
	Data = sqlv_get_num_ex( VaultHandle, Key, SaveName );
	
	sqlv_disconnect( VaultHandle );
	
	if( !Data )
		return 0;
	
	return Data;
}