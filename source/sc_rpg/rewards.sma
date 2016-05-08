// Our rewards
enum _:Rewards
{
	_Prestige_1,
	_Prestige_2,
	_Prestige_LJ,
	_TeamPlayer,
	_GodsDoing,
	_Secret1
};

// Time to setup our structure!
enum _:RewardStructData
{
    _Name[ MaxClients ], // the name of the achievement
    _Description[ 256 ], // the description of the achievement (cannot exceed 255 chars - limit set in api)
    _Save_Name[ MaxClients ], // the save key of the achievement
    _ExpGain, // the amount of EXP you will gain from this reward
    _Medals, // how many medals you will gain from this reward (recommended is 1-3!)
    _Max_Value // and finally the max value (also referred to as objective value in other achievement plugins)
};

// total medals as of current.
// 10

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
		"Praise The Alien Overlord!", //I'm Nihilanth's slave!
		"What even is this",
		"progress_secret1",
		800,
		1,
		1
	}
};

new RewardsPointer[ Rewards ];
new RewardsData[ Rewards ][ MaxClients ];
