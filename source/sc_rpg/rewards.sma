// Our rewards
enum _:Rewards
{
	_Prestige_1,
	_Prestige_2,
	_TeamPlayer,
	_Secret1
};

// Time to setup our structure!
enum _:RewardStructData
{
    _Name[ MaxClients ], // the name of the achievement
    _Description[ 256 ], // the description of the achievement (cannot exceed 255 chars - limit set in api)
    _Save_Name[ MaxClients ], // the save key of the achievement
    _Max_Value // and finally the max value (also referred to as objective value in other achievement plugins)
};

new const RewardsInfo[ Rewards ][ RewardStructData ] = 
{
	// _Prestige_1
	{
		"Prestige Time!",
		"Prestige for the first time",
		"progress_prestige_1",
		1
	},
	// _Prestige_2
	{
		"Look at me go!",
		"Prestige 5 times",
		"progress_prestige_5",
		5
	},
	// _TeamPlayer
	{
		"Team Player",
		"Boost the whole team's HP & AP",
		"progress_teamplayer",
		10
	},
	// _Secret1
	{
		"Praise The Alien Overlord!",//I'm Nihilanth's slave!
		"What even is this",
		"progress_secret1",
		1
	}
};

new RewardsPointer[ Rewards ];
new RewardsData[ Rewards ][ MaxClients + 1 ];
