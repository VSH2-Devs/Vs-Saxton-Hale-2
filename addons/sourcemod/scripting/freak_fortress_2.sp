#include <morecolors>
#include <tf2_stocks>

#undef REQUIRE_PLUGIN
#include <vsh2>
#define REQUIRE_PLUGIN
#include <sdkhooks>

#define MAX_SUBPLUGIN_NAME		64
#define MAX_ABILITIES_PL		30
#define PLYR					35

#include <cfgmap>
#include "modules/stocks.inc"

#pragma semicolon        1
#pragma newdecls         required



public Plugin myinfo = {
	name           = "VSH2/FF2 Compatibility Engine",
	author         = "Nergal/Assyrianic, BatFoxKid and 01Pollux",
	description    = "Implements FF2's forwards & natives using VSH2's API",
	version        = "1.0b",
	url            = "https://github.com/VSH2-Devs/Vs-Saxton-Hale-2"
};


enum m_iRageInfo {
	iRageMode,
	iRageMin,
	iRageMax
};

enum {
	FF2OnMusic,
	FF2OnMusic2,
	FF2OnSpecial,
	FF2OnAlive,
	FF2OnLoseLife,
	FF2OnBackstab,
	FF2OnPreAbility,
	FF2OnAbility,
	FF2OnQueuePoints,
	FF2OnHurtShield,
	FF2PostRoundStart,
	FF2OnBossJarated,
	MaxFF2Forwards
};

enum struct FF2CompatPlugin {
	ConfigMap	   m_charcfg;
	GlobalForward  m_forwards[MaxFF2Forwards];
	bool           m_vsh2;
	bool           m_cheats;
	int            m_queuePoints[PLYR];
	bool           m_queueChecking;
}

enum struct VSH2ConVars {
	ConVar m_enabled;
	ConVar m_version;
	ConVar m_fljarate;
	ConVar m_flairblast;
	ConVar m_flmusicvol;
}

FF2CompatPlugin ff2;
VSH2ConVars     vsh2cvars;
VSH2GameMode    vsh2_gm;

#include "modules/ff2/utils.sp"
#include "modules/ff2/handles.sp"
#include "modules/ff2/formula_parser.sp"
#include "modules/ff2/vsh2_bridge.sp"
#include "modules/ff2/natives.sp"

public void OnPluginStart()
{
	/// ConVars subplugins depend on
	CreateConVar("ff2_oldjump", "1", "Use old Saxton Hale jump equations", _, true, 0.0, true, 1.0);
	CreateConVar("ff2_base_jumper_stun", "0", "Whether or not the Base Jumper should be disabled when a player gets stunned", _, true, 0.0, true, 1.0);
	CreateConVar("ff2_solo_shame", "0", "Always insult the boss for solo raging", _, true, 0.0, true, 1.0);
	
	Reg_ConCmds();
}

public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		ff2.m_vsh2 = true;
		
		ff2.m_charcfg = new ConfigMap("data/freak_fortress_2/characters.cfg");
		InitVSH2Bridge();
		
		vsh2cvars.m_enabled = FindConVar("vsh2_enabled");
		vsh2cvars.m_version = FindConVar("vsh2_version");
		vsh2cvars.m_fljarate = FindConVar("vsh2_jarate_rage");
		vsh2cvars.m_flairblast = FindConVar("vsh2_airblast_rage");
		vsh2cvars.m_flmusicvol = FindConVar("vsh2_music_volume");
		
		for( int i=MaxClients; i; i-- )
			if( 0 < i <= MaxClients && IsClientInGame(i) )
				OnClientPutInServer(i);
	}
}

public void OnClientPutInServer(int client)
{
	if ( !ff2.m_vsh2 ) return;
	
	FF2Player player = FF2Player(client);
	player.iMaxLives = 0;
	player.iRageDmg = 0;
	player.iShieldId = -1;
	player.iShieldHP = 0.0;
	player.iFlags = 0;
	player.iCfg = null;
	player.HookedAbilities = null;
}

public void OnLibraryRemoved(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		ff2.m_vsh2 = false;
		
		delete ff2.m_charcfg;
		RemoveVSH2Bridge();
	}
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	InitNatives();
	
	ff2.m_forwards[FF2OnMusic] = 		new GlobalForward("FF2_OnMusic", ET_Hook, Param_String, Param_FloatByRef);
	ff2.m_forwards[FF2OnMusic2] = 		new GlobalForward("FF2_OnMusic2", ET_Hook, Param_String, Param_FloatByRef, Param_String, Param_String);
	ff2.m_forwards[FF2OnSpecial] = 		new GlobalForward("FF2_OnSpecialSelected", ET_Hook, Param_CellByRef, Param_String, Param_Cell);
	ff2.m_forwards[FF2OnAlive] = 		new GlobalForward("FF2_OnAlivePlayersChanged", ET_Hook, Param_Cell, Param_Cell);
	ff2.m_forwards[FF2OnLoseLife] = 	new GlobalForward("FF2_OnLoseLife", ET_Hook, Param_Cell, Param_CellByRef, Param_Cell);
	ff2.m_forwards[FF2OnBackstab] = 	new GlobalForward("FF2_OnBackStabbed", ET_Hook, Param_Cell, Param_Cell, Param_Cell);
	ff2.m_forwards[FF2OnPreAbility] = 	new GlobalForward("FF2_PreAbility", ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell, Param_CellByRef);
	ff2.m_forwards[FF2OnAbility] = 		new GlobalForward("FF2_OnAbility", ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell);
	ff2.m_forwards[FF2OnQueuePoints] = 	new GlobalForward("FF2_OnAddQueuePoints", ET_Hook, Param_Array);
	ff2.m_forwards[FF2OnHurtShield] = 	new GlobalForward("FF2_OnHurtShield", ET_Hook, Param_Cell, Param_CellByRef, Param_Cell, Param_Cell, Param_CellByRef);
	ff2.m_forwards[FF2PostRoundStart] = new GlobalForward("FF2_OnPostRoundStart", ET_Ignore, Param_Array, Param_Cell, Param_Array, Param_Cell);
	ff2.m_forwards[FF2OnBossJarated] = 	new GlobalForward("FF2_OnBossJarated", ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef);
	
	RegPluginLibrary("freak_fortress_2");
	
	return APLRes_Success;
}
