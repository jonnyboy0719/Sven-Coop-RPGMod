# Sven Co-op RPG Mod

This plugin is a replacement for the old, crappy, SCXPM mod for Sven Co-op. SCRPG Mod is more balanced and more Challenging than SCXPM, and all the skills has been re-created from scratch with a more clean code.


Credits
-----------

`JonnyBoy0719` - Programming  
`Xellath` - API  
`Swampdog` - Testing  
`Shadow Knight/Dark-fox` - Testing  
`Daybreaker` - Testing  

###### Custom Sounds
`Deathmatch Classic`  
`Hellmouth (Map Series)`  
`Warcraft 3/Blizzard`  
`Master Sword: Continued (MS:C)`  
`The Specialists`  


Skills
-----------

`Vitality` - Grants more health  
`Superior Armor` - Grants more armor  
`Health Regeneration` - Regenerates the user's health  
`Nano Armor` - Regenerates the user's armor  
`The Magic Pocket` - Gives the user ammunition for the current weapon  
`Icarus Potion` - Grants the user 1 extra jump per level  
`A Gift From The Gods` - Grants the user 1 random weapon  
`The Warrior's Battlecry` - Boosts everyone around them with health & armor  
`Holy Armor` - Grants the user godmode for a short period of time  


Commands
-----------

`/help` - Prints all the available commands on the console  
`/challenges` - Shows your challange progress  
`/reset` - To reset your skills  
`/rpg` - Shows the admin commands (Only works if you have admin access)  
`/fullreset` - To reset your level, skills and experience back to 0 (can't be undone!)  
`/skillsinfo` - Prints the info about the skills  
`/rpgmod or /version` - To show the version  
`/top10` - Shows the top10 players  
`/rank` - Shows your rank  
`/prestige` - If you're on max level, you will reset to level 0, but you'll gain some new cool shit.  
`/sound` - Disables or Enables the sounds (RPG Mod custom sounds only!)  


Server Commands
-----------

`rpg_ranking` - This will enable ranking, or simply disable it.  
`rpg_gameinfo` - This will enable GameInformation to be overwritten.  
`rpg_exp_bonus` - This will set an extra amount of EXP you will gain per frag  
`rpg_set_level` - This will set the level of a user (and reset their skills)  
`rpg_set_prestige` - This will set the prestige level of a user  
`rpg_skill_gift` - This will activate the `A Gift From The Gods`, even if the user doesn't have it  


How it Works
-----------

Simply copy the `sc_rpg.amxx` to your plugins folder and add `sc_rpg.amxx` under `configs/plugins.ini` file.  

Now open `configs/sql.cfg` and add the new commands:  
`rpg_host			"127.0.0.1"`  
`rpg_user			"root"`  
`rpg_pass			""`  
`rpg_type			"mysql"`  
`rpg_dbname			"my_database"`  
`rpg_table			"sc_rpg"`  
`rpg_table_api_web		"rpg_rewards_web"`  
`rpg_table_api			"rpg_rewards"`  
`rpg_rank_table			"sc_rpg_rank"`  


**Note:**  
`If it doesn't work as it should, make sure to hardcode the connection on the SMA file instead. (This issue can happen randomly on Sven Co-op 5.x)`


Setting up the AngelScript portion
-----------

Now we need to setup the angelscript portion of the plugin. Yes, we use angelscript for RPG Mod, which is only for the `A Gift From The Gods` skill. We really don't want them to be spawned on the world itself, only for the player.  
Now, let's locate the `default_plugins.txt` under svencoop folder, and add the following: 
```
	"plugin"
	{
		"name" "rpg_mod"
		"script" "rpg_mod"
	}
```
   
See, it wasn't that hard!


Database setup
-----------

All the SQL is under `web/database.sql` since the string were to long for AMXX compiler. Simple copy paste it to your PhpMyAdmin, 
or any SQL Manager that you have installed, into its query, and hit run. But make sure its inside a database, otherwise it'll throw errors at you!


Web GUI
-----------

The Web GUI is currently being developed.
