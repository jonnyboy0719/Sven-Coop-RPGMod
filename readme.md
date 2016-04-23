# Sven Co-op RPG Mod

This plugin is a replacement for the old, crappy, SCXPM mod for Sven Co-op. SCRPG Mod is more balanced and more challanging than SCXPM, and all the skills has been re-created from scratch with a more clean code.


Credits
-----------

`JonnyBoy0719` - Programming  
`Shadow Knight` - Testing  

###### Custom Sounds
`Deathmatch Classic`  
`Hellmouth(map)`  
`Warcraft3/Blizzard`  
`Master Sword: Continued(MS:C)`  
`The Specialists`  


Skills
-----------

`Strength` - Grants more health  
`Superior Armor` - Grants more armor  
`Health Regeneration` - Regenerates the user health  
`Nano Armor` - Regenerates the user armor  
`The Magic Pocket` - Gives the user ammunition for the current weapon  
`Icarus Potion` - Grants the user 1 extra jump per level  
`The Gift From The Gods` - Grants the user 1 random weapon  
`The Warrior's Battlecry` - Boosts everyone around them with health & armor  
`Holy Armor` - Grants the user godmode for a short period of time  


Commands
-----------

`/help` - Prints all the available commands on the console  
`/reset` - To reset your skills  
`/fullreset` - To reset your level, skills and experience back to 0 (can't be undone!)  
`/skillsinfo` - Prints the info about the skills  
`/rpgmod or /version` - To show the correction  
`/top10` - Shows the top10 players  
`/rank` - Shows your rank  
`/prestige` - If on max level, you will reset to level 0, but gain some new cool shit.  


Server Commands
-----------

`rpg_ranking` - This will enable ranking, or simply disable it.  
`rpg_gameinfo` - This will enable GameInformation to be overwritten.  
`rpg_exp_bonus` - This will set extra amount of EXP you will gain per frag  
`rpg_set_level` - This will set the level (and reset their skills)  
`rpg_set_prestige` - This will set the user prestige level  


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
`rpg_rank_table			"sc_rpg_rank"`  


**Note:**  
`If it doesn't work as it should, make sure to hardcode the connection on the SMA file instead. (This issue can happen randomly on Sven Co-op 5.x)`


Setting up the AngelScript portion
-----------

Now we need to setup the angelscript portion of the plugin. Yes, we use angelscript for RPG Mod, which is only for the `The Gift From The Gods` skill. We really don't want them to be spawned on the world itself, only for the player.  
Now, lets locate the `default_plugins.txt` under svencoop folder, and add the following: 
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

All the sql is under `web/database.sql` since the string were to long for AMXX compiler. Simple copy paste it to your PhpMyAdmin, 
or any SQL Manager that you have installed, into its query, and hit run. But make sure its inside a database, else it will throw errors!


Web GUI
-----------

Make sure you install the web gui on your apache folder (you can find all files under `web/` folder) and not copying it to your actual Sven Co-op server!  
You also need to make sure to setup the configurations on the config.php.


Web GUI Demo
-----------

If you want to see how the Web GUI looks like, you can do so by going to our official Sven Co-op Stats page for our server!  
Demo: [Click here!](http://de.modriot.com/sc_rpg/)