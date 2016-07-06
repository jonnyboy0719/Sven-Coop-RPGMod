CREATE TABLE IF NOT EXISTS `rpg_ranks` (
  `lvl` int(11) NOT NULL,
  `title` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

INSERT INTO `rpg_ranks` (`lvl`, `title`) VALUES
	(30, 'Professional Free Agent'),
	(-1, 'Frightened Civilian'),
	(1, 'Civilian'),
	(3, 'Fighter'),
	(5, 'Private Third Class'),
	(7, 'Private Second Class'),
	(10, 'Private First Class'),
	(20, 'Free Agent'),
	(40, 'Professional Force Member'),
	(50, 'Professional Force Leader'),
	(60, 'Special Force Member'),
	(70, 'Special Force Leader'),
	(80, 'United Forces Member'),
	(90, 'United Forces Leader'),
	(100, 'Hidden Operations Member'),
	(200, 'Hidden Operations Scheduler'),
	(300, 'Hidden Operations Leader'),
	(400, 'General'),
	(500, 'Top 30 of most famous Leaders'),
	(600, 'Top 15 of most famous Leaders'),
	(700, 'Highest Force Member'),
	(800, 'Highest Force Leader');

CREATE TABLE IF NOT EXISTS `rpg_rewards` (
  `authid` varchar(64) NOT NULL,
  `reward` varchar(64) NOT NULL,
  `value` varchar(512) NOT NULL DEFAULT '0',
  PRIMARY KEY (`authid`,`reward`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `rpg_rewards_web` (
  `reward` varchar(100) NOT NULL DEFAULT '',
  `name` varchar(150) NOT NULL,
  `desc` varchar(150) NOT NULL,
  `value` varchar(50) NOT NULL,
  PRIMARY KEY (`reward`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `rpg_stats` (
  `authid` varchar(32) NOT NULL,
  `name` text,
  `exp` text,
  `lvl` int(11) DEFAULT '0',
  `skill_hp` int(11) DEFAULT '0',
  `skill_sethp` int(11) DEFAULT '0',
  `skill_armor` int(11) DEFAULT '0',
  `skill_setarmor` int(11) DEFAULT '0',
  `skill_doublejump` int(11) DEFAULT '0',
  `skill_aura` int(11) DEFAULT '0',
  `skill_holyguard` int(11) DEFAULT '0',
  `skill_ammo` int(11) DEFAULT '0',
  `skill_weapon` int(11) DEFAULT '0',
  `points` int(11) DEFAULT '0',
  `medals` int(11) DEFAULT '0',
  `prestige` int(11) DEFAULT '0',
  `date` int(11) DEFAULT '1112214021',
  `online` varchar(50) DEFAULT 'false',
  `country` varchar(50) DEFAULT NULL,
  `gametime` int(11) DEFAULT '0',
  PRIMARY KEY (`authid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
