#include <morecolors>

#undef REQUIRE_PLUGIN
#include <vsh2>
#define REQUIRE_PLUGIN

#pragma semicolon        1
#pragma newdecls         required

public Plugin myinfo = {
	name           = "VSH2/VSH1 Compatibility Engine",
	author         = "Nergal/Assyrianic",
	description    = "Implements Old VSH forwards & natives using VSH2's API.",
	version        = "1.1",
	url            = "https://github.com/VSH2-Devs/Vs-Saxton-Hale-2"
};


enum {
	OnHaleJump,
	OnHaleRage,
	OnHaleWeighdown,
	OnVSHMusic,
	OnHaleNext,
	MaxVSHForwards
};

GlobalForward g_vsh_forwards[MaxVSHForwards];
ConVar vsh2_enabled;
bool g_vsh2;


public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		g_vsh2 = true;
		vsh2_enabled = FindConVar("vsh2_enabled");
		VSH2_Hook(OnBossSuperJump, VSH_OnBossSuperJump);
		VSH2_Hook(OnBossDoRageStun, VSH_OnBossDoRageStun);
		VSH2_Hook(OnBossWeighDown, VSH_OnBossWeighDown);
		VSH2_Hook(OnMusic, VSH_OnMusic);
		VSH2_Hook(OnVariablesReset, VSH_OnNextHale);
	}
}

public void OnLibraryRemoved(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		g_vsh2 = false;
	}
}

public Action VSH_OnBossSuperJump(const VSH2Player player)
{
	Action act = Plugin_Continue;
	bool super = player.GetPropAny("bSuperCharge");
	Call_StartForward(g_vsh_forwards[OnHaleJump]);
	Call_PushCellRef(super);
	Call_Finish(act);
	if( act==Plugin_Changed )
		player.SetPropAny("bSuperCharge", super);
}

public Action VSH_OnBossDoRageStun(VSH2Player player, float& distance)
{
	Action act = Plugin_Continue;
	float new_dist;
	Call_StartForward(g_vsh_forwards[OnHaleRage]);
	Call_PushFloatRef(new_dist);
	Call_Finish(act);
	if( act==Plugin_Changed )
		distance = new_dist;
	return Plugin_Continue;
}

public Action VSH_OnBossWeighDown(const VSH2Player player)
{
	Action act = Plugin_Continue;
	Call_StartForward(g_vsh_forwards[OnHaleWeighdown]);
	Call_Finish(act);
}

public void VSH_OnMusic(char song[PLATFORM_MAX_PATH], float& time, const VSH2Player player)
{
	Action act = Plugin_Continue;
	float new_time;
	char new_song[PLATFORM_MAX_PATH];
	
	Call_StartForward(g_vsh_forwards[OnVSHMusic]);
	Call_PushStringEx(new_song, PLATFORM_MAX_PATH, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushFloatRef(new_time);
	Call_Finish(act);
	if( act==Plugin_Changed ) {
		time = new_time;
		strcopy(song, sizeof(song), new_song);
	}
}

public Action VSH_OnNextHale(const VSH2Player player)
{
	if( VSH2GameMode_FindNextBoss()==player ) {
		Action act = Plugin_Continue;
		Call_StartForward(g_vsh_forwards[OnHaleNext]);
		Call_PushCell(player.index);
		Call_Finish(act);
	}
}


public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if( !g_vsh2 || !vsh2_enabled.BoolValue )
		return APLRes_Failure;
	
	CreateNative("VSH_IsSaxtonHaleModeMap", Native_IsVSHMap);
	CreateNative("VSH_IsSaxtonHaleModeEnabled", Native_IsEnabled);
	CreateNative("VSH_GetSaxtonHaleUserId", Native_GetHale);
	CreateNative("VSH_GetSaxtonHaleTeam", Native_GetTeam);
	CreateNative("VSH_GetSpecialRoundIndex", Native_GetSpecial);
	CreateNative("VSH_GetSaxtonHaleHealth", Native_GetHealth);
	CreateNative("VSH_GetSaxtonHaleHealthMax", Native_GetHealthMax);
	CreateNative("VSH_GetClientDamage", Native_GetDamage);
	CreateNative("VSH_GetRoundState", Native_GetRoundState);
	
	g_vsh_forwards[OnHaleJump] = new GlobalForward("VSH_OnDoJump", ET_Hook, Param_CellByRef);
	g_vsh_forwards[OnHaleRage] = new GlobalForward("VSH_OnDoRage", ET_Hook, Param_FloatByRef);
	g_vsh_forwards[OnHaleWeighdown] = new GlobalForward("VSH_OnDoWeighdown", ET_Hook);
	g_vsh_forwards[OnVSHMusic] = new GlobalForward("VSH_OnMusic", ET_Hook, Param_String, Param_FloatByRef);
	g_vsh_forwards[OnHaleNext] = new GlobalForward("VSH_OnHaleNext", ET_Hook, Param_Cell);
	
	RegPluginLibrary("saxtonhale");
	return APLRes_Success;
}


public int Native_IsVSHMap(Handle plugin, int numParams)
{
	return VSH2GameMode_IsVSHMap();
}

public int Native_IsEnabled(Handle plugin, int numParams)
{
	return vsh2_enabled.BoolValue;
}

public int Native_GetHale(Handle plugin, int numParams)
{
	VSH2Player[] boss = new VSH2Player[MaxClients];
	if( VSH2GameMode_GetBosses(boss) > 0 )
		return boss[0].userid;
	else return 0;
}

public int Native_GetTeam(Handle plugin, int numParams)
{
	return VSH2Team_Boss;
}

public int Native_GetSpecial(Handle plugin, int numParams)
{
	VSH2Player[] boss = new VSH2Player[MaxClients];
	if( VSH2GameMode_GetBosses(boss) > 0 )
		return boss[0].GetPropInt("iBossType");
	else return 0;
}

public int Native_GetHealth(Handle plugin, int numParams)
{
	VSH2Player[] boss = new VSH2Player[MaxClients];
	if( VSH2GameMode_GetBosses(boss) > 0 )
		return GetClientHealth(boss[0].index);
	else return 0;
}

public int Native_GetHealthMax(Handle plugin, int numParams)
{
	VSH2Player[] boss = new VSH2Player[MaxClients];
	if( VSH2GameMode_GetBosses(boss) > 0 )
		return boss[0].GetPropInt("iMaxHealth");
	else return 0;
}

public int Native_GetDamage(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if( client <= 0 || client > MaxClients || !IsClientInGame(client) )
		return 0;
	else return VSH2Player(client).GetPropInt("iDamage");
}

public int Native_GetRoundState(Handle plugin, int numParams)
{
	return VSH2GameMode_GetPropInt("iRoundState");
}
