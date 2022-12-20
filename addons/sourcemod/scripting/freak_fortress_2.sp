#include <morecolors>
#include <tf2_stocks>

#undef REQUIRE_PLUGIN
#include <vsh2>
#define REQUIRE_PLUGIN
#include <sdkhooks>

#define PLYR           35
#define PLUGIN_VERSION "1.1.3"

#include <cfgmap>
#include "modules/stocks.inc"

#pragma semicolon        1
#pragma newdecls         required

public Plugin myinfo = {
	name           = "VSH2/FF2 Compatibility Engine",
	author         = "Nergal/Assyrianic, BatFoxKid and 01Pollux",
	description    = "Implements FF2's forwards & natives using VSH2's API",
	version        = PLUGIN_VERSION,
	url            = "https://github.com/VSH2-Devs/Vs-Saxton-Hale-2"
};

enum {
	FF2OnMusic,
	FF2OnSpecial,
	FF2OnLoseLife,
	FF2OnBackstab,
	FF2OnPreAbility,
	FF2OnAbility,
	FF2OnQueuePoints,
	FF2OnTriggerHurt,
	MaxFF2Forwards
};

enum struct FF2ConVars {
	ConVar m_version;
	ConVar m_fljarate_rage;
	ConVar m_flairblast_rage;
	ConVar m_flscout_rage_gen;
	ConVar m_flmusicvol;
	ConVar m_companion_min;
	ConVar m_nextmap;
	ConVar m_pack_name;
	ConVar m_pack_limit;
	ConVar m_pack_scramble;
}

enum {
	HUD_Jump,
	HUD_Weighdown,
	HUD_Lives,
	HUD_TYPES
};

enum struct FF2CompatPlugin {
	FF2ConVars    m_cvars;
	ConfigMap     m_charcfg;
	GlobalForward m_forwards[MaxFF2Forwards];
	Handle        m_hud[HUD_TYPES];
	bool          m_vsh2;
	bool          m_cheats;
	int           m_queuePoints[PLYR];
}

FF2CompatPlugin ff2;
VSH2GameMode    vsh2_gm;
FF2PluginList   subplugins;

#include "modules/ff2/utils.sp"
#include "modules/ff2/gamemode.sp"
#include "modules/ff2/forwards.sp"

#include "modules/ff2/handler.sp"
#include "modules/ff2/vsh2_bridge.sp"

#include "modules/ff2/natives.sp"
#include "modules/ff2/console.sp"
#include "modules/ff2/formula_parser.sp"

#include "modules/ff2/extras/nopack_pickup.sp"
#include "modules/ff2/extras/multilives.sp"


public void OnPluginEnd()
{
	if( ff2.m_vsh2 ) {
		FF2PluginList.ForceUnloadAllSubPlugins();
		FF2GameMode.UnhookFromVSH2();
		ff2.m_vsh2 = false;
	}
}

public void OnLibraryAdded(const char[] name)
{
	if( StrEqual(name, "VSH2") && !ff2.m_vsh2 ) {
		InitConVars();
		ff2.m_vsh2 = true;
		FF2GameMode.LoadFF2();
		FF2GameMode.LateLoadSubplugins();
	}
}

public void OnMapEnd()
{
	if( ff2.m_vsh2 ) {
		FF2GameMode.RemoveSubPlugins();
		FF2GameMode.RemoveCfgMgr();

		char pack[48];
		ff2.m_cvars.m_pack_name.GetString(pack, sizeof(pack));
		ff2_cfgmgr = new FF2BossManager(pack);
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if( StrEqual(name, "VSH2") && ff2.m_vsh2 ) {
		ff2.m_vsh2 = false;

		FF2GameMode.RemoveSubPlugins(true);

		FF2GameMode.UnhookFromVSH2();    /// ff2_cfgmgr will be deleted here
		DeleteCfg(ff2.m_charcfg);
	}
}


void NextFrame_InitFF2Player(int client)
{
	if( ff2.m_vsh2 ) {
		/// vsh2_bridge.sp
		VSH2Player player = VSH2Player(client);
		// TODO
		player.SetPropAny("bNoCompanion", false);
		OnVariablesResetFF2(player);
	}
}

public void OnClientPutInServer(int client)
{
	RequestFrame(NextFrame_InitFF2Player, client);
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	InitNatives();

	ff2.m_forwards[FF2OnMusic] = new GlobalForward("FF2_OnMusic", ET_Hook, Param_Cell, Param_String, Param_FloatByRef);
	ff2.m_forwards[FF2OnSpecial] = new GlobalForward("FF2_OnBossSelected", ET_Hook, Param_Cell, Param_String, Param_Cell);
	ff2.m_forwards[FF2OnLoseLife] = new GlobalForward("FF2_OnLoseLife", ET_Hook, Param_Cell, Param_CellByRef, Param_Cell);
	ff2.m_forwards[FF2OnBackstab] = new GlobalForward("FF2_OnBackStabbed", ET_Hook, Param_Cell, Param_Cell);
	ff2.m_forwards[FF2OnPreAbility] = new GlobalForward("FF2_PreAbility", ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell, Param_CellByRef);
	ff2.m_forwards[FF2OnAbility] = new GlobalForward("FF2_OnAbility", ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell);
	ff2.m_forwards[FF2OnQueuePoints] = new GlobalForward("FF2_OnAddQueuePoints", ET_Hook, Param_Array);
	ff2.m_forwards[FF2OnTriggerHurt] = new GlobalForward("FF2_OnTriggerHurt", ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef);

	RegPluginLibrary("freak_fortress_2");

	return APLRes_Success;
}


public void OnEntityCreated(int entity, const char[] clsname)
{
	if( !ff2.m_vsh2 )
		return;
	if( StrContains(clsname, "healthkit") != -1 || 
	    StrContains(clsname, "ammo") != -1 )
		NoPackPickup_OnItemSpawn(entity);
}


#if defined _smac_included
public Action SMAC_OnCheatDetected(int client, const char[] module, DetectionType type, Handle info)
{
	if( type == Detection_CvarViolation ) {
		FF2Player player = FF2Player(client);
		if( player.GetPropInt("bNotifySMAC_CVars") ) {
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}
#endif