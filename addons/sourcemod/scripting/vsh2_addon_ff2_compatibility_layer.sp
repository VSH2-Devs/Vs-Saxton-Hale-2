#include <morecolors>

#undef REQUIRE_PLUGIN
#include <vsh2>
#define REQUIRE_PLUGIN

#pragma semicolon        1
#pragma newdecls         required

public Plugin myinfo = {
	name           = "VSH2 to FF2 Compatibility layer.",
	author         = "Nergal/Assyrianic",
	description    = "Implements FF2's forwards & natives using VSH2's API",
	version        = "1.0a",
	url            = "https://github.com/VSH2-Devs/Vs-Saxton-Hale-2"
};


#define MAX_SUBPLUGIN_NAME    64

enum {
	FF2OnMusic,
	MaxFF2Forwards
};

Handle g_ff2_forwards[MaxFF2Forwards];

ConVar
	vsh2_enabled,
	vsh2_version
;
bool g_vsh2;



public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		g_vsh2 = true;
		vsh2_enabled = FindConVar("vsh2_enabled");
		vsh2_version = FindConVar("vsh2_version");
		
		VSH2_Hook(OnMusic, FF2_OnMusic);
		
		/// FF2 has a set max lives limit, VSH2 imposes no such limit on lives.
		/// Create iMaxLives property for FF2 to use exclusively.
		for( int i=MaxClients; i; i-- )
			if( 0 < i <= MaxClients && IsClientInGame(i) )
				VSH2Player(i).SetPropInt("iMaxLives", 0);
	}
}

public void OnLibraryRemoved(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		g_vsh2 = false;
	}
}


public Action FF2_OnMusic(char song[PLATFORM_MAX_PATH], float& time, const VSH2Player player)
{
	Action act;
	Call_StartForward(g_ff2_forwards[FF2OnMusic]);
	Call_PushStringEx(song, sizeof(song), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushFloatRef(time);
	Call_Finish(act);
	return act;
}



public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if( !g_vsh2 || !vsh2_enabled.BoolValue )
		return APLRes_Failure;
	
	CreateNative("FF2_IsFF2Enabled", Native_FF2_IsFF2Enabled);
	CreateNative("FF2_GetFF2Version", Native_FF2_GetFF2Version);
	
	g_ff2_forwards[FF2OnMusic] = CreateGlobalForward("FF2_OnMusic", ET_Hook, Param_String, Param_FloatByRef);
	
	RegPluginLibrary("freak_fortress_2");
	return APLRes_Success;
}

/** bool FF2_IsFF2Enabled(); */
public int Native_FF2_IsFF2Enabled(Handle plugin, int numParams)
{
	return vsh2_enabled.BoolValue;
}

/** bool FF2_GetFF2Version(int[] version=0); */
public int Native_FF2_GetFF2Version(Handle plugin, int numParams)
{
	char version_str[10];
	vsh2_version.GetString(version_str, sizeof(version_str));
	
	char digit[3][10];
	int version_ints[3];
	if( ExplodeString(version_str, ".", digit, sizeof(digit[]), sizeof(digit[][])) == 3 ) {
		for( int i; i<3; i++ )
			version_ints[i] = StringToInt(digit[i]);
	}
	SetNativeArray(1, version_ints, sizeof(version_ints));
	return 1;
}

/** bool FF2_GetForkVersion(int[] fversion=0); */
public int Native_FF2_GetForkVersion(Handle plugin, int numParams)
{
	int version_ints[3]; SetNativeArray(1, version_ints, sizeof(version_ints));
	return 1;
}

/** int FF2_GetRoundState(); */
public int Native_FF2_GetRoundState(Handle plugin, int numParams)
{
	return VSH2GameMode_GetPropInt("iRoundState");
}

/** int FF2_GetBossUserId(int boss=0); */
public int Native_FF2_GetBossUserId(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( boss < 0 || boss > MaxClients )
		return -1;
	else if( boss==0 ) {
		VSH2Player[] players = new VSH2Player[MaxClients];
		int amount_of_bosses = VSH2GameMode_GetBosses(players, false);
		if( amount_of_bosses > 0 )
			return players[0].userid;
		else return -1;
	}
	VSH2Player player = VSH2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.userid : -1;
}

/** int FF2_GetBossIndex(int client); */
public int Native_FF2_GetBossIndex(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if( client <= 0 || client > MaxClients )
		return -1;
	
	VSH2Player[] players = new VSH2Player[MaxClients];
	int amount_of_bosses = VSH2GameMode_GetBosses(players, false);
	if( amount_of_bosses > 0 ) {
		for( int i; i<amount_of_bosses; i++ ) {
			if( players[i].index==client ) {
				if( i==0 )
					return 0;
				else return players[i].index;
			}
		}
	}
	return -1;
}

/** int FF2_GetBossTeam(); */
public int Native_FF2_GetBossTeam(Handle plugin, int numParams)
{
	return VSH2Team_Boss;
}

/** bool FF2_GetBossSpecial(int boss=0, char[] buffer, int bufferLength, int bossMeaning=0); */
public int Native_FF2_GetBossSpecial(Handle plugin, int numParams)
{
	/// TODO
	return 1;
}

/** int FF2_GetBossHealth(int boss=0); */
public int Native_FF2_GetBossHealth(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( boss < 0 || boss > MaxClients )
		return 0;
	else if( boss==0 ) {
		VSH2Player[] players = new VSH2Player[MaxClients];
		int amount_of_bosses = VSH2GameMode_GetBosses(players, false);
		return( amount_of_bosses > 0 ) ? players[boss].GetPropInt("iHealth") : 0;
	}
	VSH2Player player = VSH2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.GetPropInt("iHealth") : 0;
}

/** void FF2_SetBossHealth(int boss, int health); */
public int Native_FF2_SetBossHealth(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( boss < 0 || boss > MaxClients )
		return 0;
	
	int new_health = GetNativeCell(2);
	if( boss==0 ) {
		VSH2Player[] players = new VSH2Player[MaxClients];
		int amount_of_bosses = VSH2GameMode_GetBosses(players, false);
		return( amount_of_bosses > 0 ) ? players[boss].SetPropInt("iHealth", new_health) : 0;
	}
	VSH2Player player = VSH2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.SetPropInt("iHealth", new_health) : 0;
}

/** int FF2_GetBossMaxHealth(int boss=0); */
public int Native_FF2_GetBossMaxHealth(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( boss < 0 || boss > MaxClients )
		return 0;
	else if( boss==0 ) {
		VSH2Player[] players = new VSH2Player[MaxClients];
		int amount_of_bosses = VSH2GameMode_GetBosses(players, false);
		if( amount_of_bosses > 0 )
			return players[0].GetPropInt("iMaxHealth");
	}
	VSH2Player player = VSH2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.GetPropInt("iMaxHealth") : 0;
}

/** void FF2_SetBossMaxHealth(int boss, int health); */
public int Native_FF2_SetBossMaxHealth(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( boss < 0 || boss > MaxClients )
		return 0;
	
	int new_maxhealth = GetNativeCell(2);
	if( boss==0 ) {
		VSH2Player[] players = new VSH2Player[MaxClients];
		int amount_of_bosses = VSH2GameMode_GetBosses(players, false);
		if( amount_of_bosses > 0 )
			return players[0].SetPropInt("iMaxHealth", new_maxhealth);
	}
	VSH2Player player = VSH2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.SetPropInt("iMaxHealth", new_maxhealth) : 0;
}

/** int FF2_GetBossLives(int boss); */
public int Native_FF2_GetBossLives(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( boss < 0 || boss > MaxClients )
		return 0;
	else if( boss==0 ) {
		VSH2Player[] players = new VSH2Player[MaxClients];
		int amount_of_bosses = VSH2GameMode_GetBosses(players, false);
		if( amount_of_bosses > 0 )
			return players[0].GetPropInt("iLives");
	}
	VSH2Player player = VSH2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.GetPropInt("iLives") : 0;
}

/** void FF2_SetBossLives(int boss, int lives); */
public int Native_FF2_SetBossLives(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( boss < 0 || boss > MaxClients )
		return 0;
	
	int lives = GetNativeCell(2);
	if( boss==0 ) {
		VSH2Player[] players = new VSH2Player[MaxClients];
		int amount_of_bosses = VSH2GameMode_GetBosses(players, false);
		if( amount_of_bosses > 0 )
			return players[0].SetPropInt("iLives", lives);
	}
	VSH2Player player = VSH2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.SetPropInt("iLives", lives) : 0;
}

/** int FF2_GetBossMaxLives(int boss); */
public int Native_FF2_GetBossMaxLives(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( boss < 0 || boss > MaxClients )
		return 0;
	else if( boss==0 ) {
		VSH2Player[] players = new VSH2Player[MaxClients];
		int amount_of_bosses = VSH2GameMode_GetBosses(players, false);
		if( amount_of_bosses > 0 )
			return players[0].GetPropInt("iMaxLives");
	}
	VSH2Player player = VSH2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.GetPropInt("iMaxLives") : 0;
}

/** void FF2_SetBossMaxLives(int boss, int lives); */
public int Native_FF2_SetBossMaxLives(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( boss < 0 || boss > MaxClients )
		return 0;
	
	int lives = GetNativeCell(2);
	if( boss==0 ) {
		VSH2Player[] players = new VSH2Player[MaxClients];
		int amount_of_bosses = VSH2GameMode_GetBosses(players, false);
		if( amount_of_bosses > 0 ) {
			return players[0].SetPropInt("iMaxLives", lives);
		}
	}
	VSH2Player player = VSH2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.SetPropInt("iMaxLives", lives) : 0;
}
