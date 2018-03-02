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
	
	//Apparently game uses this value to determine game speed in Masked Bunta :thinking:
	float bunta_speed : 0x167EE4, 0x60, 0x18, 0x698, 0x65C;
}

startup
{
	vars.game_time = 0;
	vars.started = false;
	vars.multiplier = 1;
	vars.fps = 60.0f;
}

init
{
	vars.nakazato_hotfix = false;
}

update
{
	//Reset game time value if real time was reset
	if (timer.CurrentTime.RealTime.HasValue)
	{
		if (timer.CurrentTime.RealTime.Value.Ticks == 0)
			vars.game_time = 0;
	}
	
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
				if (current.stage != 1)
					vars.multiplier = 1/current.game_speed;
				else
					vars.multiplier = 1/current.bunta_speed;
				
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
	return current.stage == 0 && current.mode == 130 && old.mode == 128;
}

split
{
	return current.cleared > old.cleared;
}

start
{
	if (current.stage == 0 && current.mode == 130 && old.mode == 128)
	{
		vars.game_time = 0;
	}
	return current.stage == 0 && current.mode == 130 && old.mode == 128;
}
