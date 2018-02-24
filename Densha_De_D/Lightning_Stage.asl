//電車でＤ_LightningStage
state("電車でＤ_LightningStage")
{
	byte stage : 0x167EE4, 0x38;
	byte cleared : 0x167EE4, 0x67C;
	byte mode : 0x167EE4, 0x8;
	// 0 - Menu ; 128 - Cutscene, no control ; 130 - Control ;
	// 131 - Win-Cutscene ; 138 - Exiting from stage (loss) ; 139 - Exiting from stage (win)
	
	byte pause_state : 0x167EE4, 0x11;
	float timer : 0x167EE4, 0x60, 0x18, 0x698, 0x664;
	float game_speed : 0x167EE4, 0x710, 0x74, 0x8, 0xB4;
}

startup
{
	vars.game_time = 0;
	vars.started = false;
	vars.multiplier = 1;
	vars.fps = 60.0f;
	vars.practice = false;
	settings.Add("practice_mode",false,"Practice mode");
	settings.SetToolTip("practice_mode","Resets the game_time every time you redo any race, useful for practice");
}

init
{
	vars.nakazato_hotfix = false;
	if (!vars.started || settings["practice_mode"])
	{
		vars.game_time = 0;
	}
}

update
{
	if((old.cleared & 4) == 0 && (current.cleared & 4) == 4) { // Nakazato Hotfix
		vars.nakazato_hotfix = true;
	}

	if(vars.nakazato_hotfix && old.mode != 130 && current.mode == 130) {
		vars.nakazato_hotfix = false;
	}
	
	if (!(current.mode != 130 || vars.nakazato_hotfix))
	{
		if (current.pause_state == 0)
		{
			if (current.timer != old.timer)
			{
				//Calculate game's slowdown scale
				vars.multiplier = 1/current.game_speed;
				if (current.timer > old.timer)
				{
					vars.game_time += (current.timer-old.timer)*(vars.multiplier/vars.fps);
				}
				else
				{
					vars.game_time += (60 % old.timer+current.timer)*(vars.multiplier/vars.fps);
				}
			}
		}
		else
		{
			vars.game_time += 1/vars.fps;
		}
	}
	vars.practice = settings["practice_mode"];
}

isLoading
{
	return current.mode != 130 || vars.nakazato_hotfix;
}

gameTime
{
	return TimeSpan.FromMilliseconds(vars.game_time*1000);
}

reset
{
	if (current.stage == 0 && current.mode == 130 && old.mode == 128)
	{
		vars.started = false;
	}
	return current.stage == 0 && current.mode == 130 && old.mode == 128;
}

split
{
	return current.cleared > old.cleared;
}

start
{
	if ((current.stage == 0 || settings["practice_mode"]) && current.mode == 130 && old.mode == 128)
	{
		vars.game_time = 0;
		vars.started = true;
	}
	return (current.stage == 0 || settings["practice_mode"]) && current.mode == 130 && old.mode == 128;
}
