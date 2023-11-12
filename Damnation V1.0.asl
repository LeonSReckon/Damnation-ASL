// Damnation AutoSplitter/Load-Remover Version 1.0.0 09/14/2023
// Supports LRT/RTA
// Supports All Difficulties
// Supports SinglePlayer && MultiPlayer!
// Main Script & Pointers <by> ||LeonSReckon||

state("DamnGame")
{
    byte  lvl     : 0x1A61170, 0x130, 0x1E4, 0x22C, 0x228, 0x3C, 0x4E4, 0x57C; // Changes between 0 to 16 when you enter a level, changes during gameplay
    byte  lvl2    : 0x19B3228, 0x8, 0xE8, 0x7C, 0xB8, 0x6C, 0x144, 0x7A8;      // Changes between 1 to 17 when you choose a level in the main menu, douesn't change during gameplay
    byte  CutLoa  : 0x1A5E7B4;                                                 // 1 During loading levels & cutscenes, 0 everywhere else
    byte  Pause   : 0x1A6312C, 0x14, 0x40, 0x4C, 0xC, 0x20, 0x18, 0xB99;       // 1 During Pausing screen & loading mid-game, 0 everywhere else
    byte  Load    : 0x1A6312C, 0x40, 0x4C, 0xC, 0x20, 0x18, 0xB99;             // 1 During loading levels, 0 everywhere else
    byte  Cut     : "binkw32.dll", 0x230E0;        	        	        	   // 1 During cutscenes, 0 everywhere else 
}

startup
{
	
	// vars
    vars.cutscenes_count  = 0;
    vars.crash            = 0;
	vars.lvlsplit         = new List<byte>();
    vars.timer_model      = new TimerModel{ CurrentState = timer };

    // actions
    Action reset_vars = () => {
    vars.cutscenes_count = 0;
    vars.crash           = 0;
    };

    vars.reset_vars = reset_vars;

}

start
{
    if(current.lvl == 0 && current.lvl2 == 1)
    {
    // update cutscenes_count
    if(current.Cut == 1 && old.Cut == 0) vars.cutscenes_count++;

    // final split
    if(vars.cutscenes_count == 1 && current.Cut == 0 && current.Load == 0 && current.CutLoa == 0 && current.Pause == 0) { vars.reset_vars(); return true; }
	}
}

split
{

	// Final Split
    if(current.lvl == 16)
    {
    // update cutscenes_count
    if(current.Cut == 1 && old.Cut == 0) vars.cutscenes_count++;
		
	// reset cutscenes_count
    if(current.lvl == 16 && old.lvl != 16) vars.cutscenes_count = 0;

    // final split
    if(vars.cutscenes_count == 2) { vars.reset_vars(); return true; }
	}

	// Level Split
	return current.lvl > old.lvl && current.lvl < 18 && !vars.lvlsplit.Contains(current.lvl);
	{
	vars.lvlsplit.Add(current.lvl);
	return true;
	}

}

isLoading 
{
    return current.Load == 1 || current.Pause == 1 || current.CutLoa == 1 || current.Cut == 1;
}

exit
{
    vars.reset_vars();

    // pause timer when the game exit
    if(timer.CurrentPhase > 0)
    {
        vars.timer_model.Pause();
    }
}