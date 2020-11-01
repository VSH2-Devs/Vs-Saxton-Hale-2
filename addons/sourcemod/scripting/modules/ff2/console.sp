
void InitConVars()
{
	/// ConVars subplugins depend on
	CreateConVar("ff2_oldjump", "1", "Use old Saxton Hale jump equations", _, true, 0.0, true, 1.0);
	CreateConVar("ff2_base_jumper_stun", "0", "Whether or not the Base Jumper should be disabled when a player gets stunned", _, true, 0.0, true, 1.0);
	CreateConVar("ff2_solo_shame", "0", "Always insult the boss for solo raging", _, true, 0.0, true, 1.0);
	
	ff2.m_cvars.m_enabled = 	FindConVar("vsh2_enabled");
	ff2.m_cvars.m_version = 	FindConVar("vsh2_version");
	ff2.m_cvars.m_fljarate = 	FindConVar("vsh2_jarate_rage");
	ff2.m_cvars.m_flairblast = 	FindConVar("vsh2_airblast_rage");
	ff2.m_cvars.m_flmusicvol = 	FindConVar("vsh2_music_volume");
	ff2.m_cvars.m_packname = 	CreateConVar("ff2_current", "Freak Fortress 2", "Freak Fortress 2 current boss pack name", FCVAR_NOTIFY);
	
}
