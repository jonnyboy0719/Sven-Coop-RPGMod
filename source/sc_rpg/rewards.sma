// Our rewards
enum _:Rewards
{
	_Prestige_1,
	_Prestige_2,
	_Prestige_LJ,
	_TeamPlayer,
	_GodsDoing,
	_Secret1,
	_Secret2,
	_Map_UBOA,
	_Map_BreakFree,
	_KillYourself,
	_WarrierInside,
	_CommunityJoined,
	_Map_SourceOfLife,
	_Map_Psyko
};

// Time to setup our structure!
enum _:RewardStructData
{
    _Name[ 256 ], // the name of the achievement
    _Description[ 256 ], // the description of the achievement (cannot exceed 255 chars - limit set in api)
    _Save_Name[ 256 ], // the save key of the achievement
    _ExpGain, // the amount of EXP you will gain from this reward
    _Medals, // how many medals you will gain from this reward (recommended is 1-3!)
    _Max_Value // and finally the max value (also referred to as objective value in other achievement plugins)
};

// 47

new const RewardsInfo[ Rewards ][ RewardStructData ] = 
{
	// _Prestige_1
	{
		"Prestige Time!",
		"Prestige for the first time",
		"progress_prestige_1",
		500,
		1,
		1
	},
	// _Prestige_2
	{
		"Look at me go!",
		"Prestige 5 times",
		"progress_prestige_5",
		9500,
		2,
		5
	},
	// _Prestige_LJ
	{
		"LongJump Module",
		"Gotta get that long jump module!",
		"progress_prestige_lj",
		800,
		2,
		2
	},
	// _TeamPlayer
	{
		"Team Player",
		"Boost the whole team's HP & AP",
		"progress_teamplayer",
		2500,
		3,
		10
	},
	// _GodsDoing
	{
		"I HAVE THE POWER!!",
		"Become god 10 times",
		"progress_godsdoing",
		3600,
		1,
		10
	},
	// _Secret1
	{
		"Praise The Alien Overlord!", //note: write on the console say "I'm Nihilanth's slave!"
		"What even is this",
		"progress_secret1",
		9800,
		5,
		1
	},
	// _Secret2
	{
		"I'm dying over here!", //note: Spam 'medic' 5 times
		"If it bleeds, you can heal it",
		"progress_secret2",
		1250,
		3,
		1
	},
	// _Map_UBOA
	{
		"UBOA!?!",
		"( ﾟДﾟ) TOO EXTREME!! (´･ω･)",
		"progress_extreme_uboa",
		8000,
		2,
		1
	},
	// _Map_BreakFree
	{
		"I WANT TO BREAK FREE!",
		"Play breakfree series",
		"progress_breakfree",
		50000,
		4,
		3
	},
	// _KillYourself
	{
		"Depressed",
		"Just end it all..",
		"progress_endyourlife",
		5,
		1,
		1
	},
	// _WarrierInside
	{
		"I'm the one with the warrior inside!",
		"Use warrior's battlecry 10 times!",
		"progress_warriorinside",
		15250,
		3,
		10
	},
	// _CommunityJoined
	{
		"Community Member",
		"Join our community forums!",
		"progress_joincommunity",
		500000,
		5,
		1
	},
	// _Map_SourceOfLife
	{
		"Source of Life!",
		"Complete the Source of Life maps!",
		"progress_sourceoflife",
		156200,
		3,
		7
	},
	// _Map_Psyko
	{
		"Maaan, am I on LSD?",
		"Play sc_psyko",
		"progress_psyko",
		1800,
		2,
		1
	}
};

new RewardsPointer[ Rewards ];
new RewardsData[ Rewards ][ MaxClients ];
