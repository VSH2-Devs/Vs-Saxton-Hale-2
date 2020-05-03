#include <morecolors>
#include <tf2_stocks>

#undef REQUIRE_PLUGIN
#include <vsh2>
#define REQUIRE_PLUGIN
#include <sdkhooks>

#define MAX_SUBPLUGIN_NAME    64
#define PLYR                  35

#include "modules/cfg.sp"
#include "modules/stocks.inc"

#pragma semicolon        1
#pragma newdecls         required

#define IsClientValid(%1)    ( 0 < (%1) && (%1) <= MaxClients && IsClientInGame((%1)) )
#define IsBossValid(%1)    ( 0 <= (%1) && (%1) <= MaxClients && IsClientInGame((%1)) )


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
	GlobalForward  m_forwards[MaxFF2Forwards];
	ArrayList      m_subplugins;
	ArrayList      m_bosscfgs;
	bool           m_vsh2;
	bool           m_cheats;
	int            m_queuePoints[PLYR];
	bool           m_queueChecking;
}

enum struct VSH2ConVars {
	ConVar m_enabled;
	ConVar m_version;
	ConVar m_fljarate;
	ConVar m_flmusicvol;
}

FF2CompatPlugin ff2;
VSH2ConVars     vsh2cvars;

#include "modules/ff2/utils.sp"
#include "modules/ff2/handles.sp"
#include "modules/ff2/formula_parser.sp"
#include "modules/ff2/vsh2_bridge.sp"

public void OnPluginStart()
{
	/// ConVars subplugins depend on
	CreateConVar("ff2_oldjump", "1", "Use old Saxton Hale jump equations", _, true, 0.0, true, 1.0);
	CreateConVar("ff2_base_jumper_stun", "0", "Whether or not the Base Jumper should be disabled when a player gets stunned", _, true, 0.0, true, 1.0);
	CreateConVar("ff2_solo_shame", "0", "Always insult the boss for solo raging", _, true, 0.0, true, 1.0);
	
	/// GameData
	Prep_GameDataFF2();
}

public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		ff2.m_vsh2 = true;
		vsh2cvars.m_enabled = FindConVar("vsh2_enabled");
		vsh2cvars.m_version = FindConVar("vsh2_version");
		vsh2cvars.m_fljarate = FindConVar("vsh2_jarate_rage");
		vsh2cvars.m_flmusicvol = FindConVar("vsh2_music_volume");
		
		ff2.m_subplugins = new ArrayList(MAX_SUBPLUGIN_NAME);
		ff2.m_bosscfgs = new ArrayList();
		VSH2_Hook(OnMusic, OnMusicFF2);
		VSH2_Hook(OnBossSelected, OnBossSelectedFF2);
		VSH2_Hook(OnPlayerKilled, OnPlayerKilledFF2);
		VSH2_Hook(OnBossTakeDamage_OnStabbed, OnBossBackstabFF2);
		VSH2_Hook(OnBossTaunt, OnBossTauntFF2);
		VSH2_Hook(OnScoreTally, OnScoreTallyFF2);
		VSH2_Hook(OnBossDealDamage_OnHitShield, OnHurtShieldFF2);
		VSH2_Hook(OnRoundStart, PostRoundStartFF2);
		VSH2_Hook(OnBossJarated, OnBossJaratedFF2);
		
		VSH2_Hook(OnCallDownloads, OnCallDownloadsFF2);
		
		for( int i=MaxClients; i; i-- )
			if( 0 < i <= MaxClients && IsClientInGame(i) )
				OnClientPutInServer(i);
	}
}

public void OnClientPutInServer(int client)
{
	FF2Player player = FF2Player(client);
	player.iMaxLives = 0;
	player.iRageDmg = 0;
	player.iShieldId = -1;
	player.iShieldHP = 0.0;
	player.iFlags = 0;
}

public void OnLibraryRemoved(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		ff2.m_vsh2 = false;
	}
}


public Action OnMusicFF2(char song[PLATFORM_MAX_PATH], float& time, const VSH2Player player)
{
	Action act;
	Call_StartForward(ff2.m_forwards[FF2OnMusic2]);
	char song2[PLATFORM_MAX_PATH]; strcopy(song2, sizeof(song2), song);
	Call_PushStringEx(song, sizeof(song), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	float time2 = time;
	Call_PushFloatRef(time2);
	Call_PushStringEx("Unknown Song", 64, SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushStringEx("Unknown Artist", 64, SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish(act);
	if( act != Plugin_Continue ) {
		strcopy(song, sizeof(song), song2);
		time = time2;
		return act;
	}

	Call_StartForward(ff2.m_forwards[FF2OnMusic]);
	strcopy(song2, sizeof(song2), song);
	Call_PushStringEx(song, sizeof(song), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	time2 = time;
	Call_PushFloatRef(time2);
	Call_Finish(act);
	if( act != Plugin_Continue ) {
		strcopy(song, sizeof(song), song2);
		time = time2;
	}
	return act;
}

public Action OnBossSelectedFF2(const VSH2Player player)
{
	Action act;
	Call_StartForward(ff2.m_forwards[FF2OnSpecial]);
	int boss = player.GetPropInt("iBossType");
	Call_PushCellRef(boss);
	char name[MAX_BOSS_NAME_SIZE]; player.GetName(name);
	Call_PushStringEx(name, sizeof(name), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushCell(true); /// True if the boss is the primary boss
	Call_Finish(act);
	if( act != Plugin_Changed )
		return Plugin_Continue;
	
	/// if( name[0] ) {
		/// Here we would search boss's names to try to find the matching boss
	/// }
	
	player.SetPropInt("iBossType", boss);
	return Plugin_Changed;
}

public void OnPlayerKilledFF2(const VSH2Player player, const VSH2Player victim, Event event)
{
	if( event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER )
		return;
	else if( victim.GetPropAny("bIsBoss") ) {
		Action act;
		Call_StartForward(ff2.m_forwards[FF2OnLoseLife]);
		int boss = ClientToBossIndex(victim.index);
		Call_PushCell(boss);
		int lives = victim.GetPropInt("iLives");
		Call_PushCellRef(lives);
		int maxlives = ToFF2Player(victim).iMaxLives;
		Call_PushCell(maxlives);
		Call_Finish(act);
		if( act==Plugin_Changed ) {
			if( lives > ToFF2Player(victim).iMaxLives )
				ToFF2Player(victim).iMaxLives = lives;
			victim.SetPropInt("iLives", lives);
		}
	}
	
	/// TODO: FF2_OnAlivePlayersChanged is called more ways, OnClientDisconnect, player_spawn, arena_round_start
	Call_StartForward(ff2.m_forwards[FF2OnAlive]);
	FF2Player[] array = new FF2Player[MaxClients];
	Call_PushCell(VSH2GameMode_GetFighters(array, true));
	int bosses = VSH2GameMode_GetBosses(array, true);
	Call_PushCell(bosses+VSH2GameMode_GetMinions(array, true));
	Call_Finish();
}

public Action OnBossBackstabFF2(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act;
	Call_StartForward(ff2.m_forwards[FF2OnLoseLife]);
	int client = victim.index;
	int boss = ClientToBossIndex(client);
	Call_PushCell(boss);
	Call_PushCell(client);
	Call_PushCell(attacker);
	Call_Finish(act);
	if( act==Plugin_Stop )
		return Plugin_Changed;
	else if( act==Plugin_Handled )
		damage = 0.0;
	
	return Plugin_Continue;
}

public Action OnBossTiggerHurtFF2(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act;
	Call_StartForward(ff2.m_forwards[FF2OnLoseLife]);
	int boss = ClientToBossIndex(victim.index);
	Call_PushCell(boss);
	Call_PushCell(attacker);
	float damage2 = damage;
	Call_PushFloatRef(damage2);
	Call_Finish(act);
	if( act==Plugin_Continue )
		return Plugin_Continue;
	else if( act==Plugin_Changed ) {
		damage = damage2;
		return Plugin_Changed;
	}
	
	damage = 0.0;
	return Plugin_Changed;
}

public Action OnBossTauntFF2(const VSH2Player player)
{
	int boss = ClientToBossIndex(player.index);
	Call_StartForward(ff2.m_forwards[FF2OnPreAbility]);
	Call_PushCell(boss);
	Call_PushString("vsh2");
	Call_PushString("vsh2_rage");
	Call_PushCell(0);
	bool enabled = true;
	Call_PushCellRef(enabled); /// TODO: Make it possible to prevent a rage
	Call_Finish();
	
	Action act;
	Call_StartForward(ff2.m_forwards[FF2OnAbility]);
	Call_PushCell(boss);
	Call_PushString("vsh2");
	Call_PushString("vsh2_rage");
	Call_PushCell(3);
	Call_Finish(act);
}

public void OnScoreTallyFF2(const VSH2Player player, int& points_earned, int& queue_earned)
{
	ff2.m_queuePoints[player.index] = queue_earned;
	if( !ff2.m_queueChecking ) {
		RequestFrame(FinishQueueArray);
		ff2.m_queueChecking = true;
	}
}

public void FinishQueueArray()
{
	ff2.m_queueChecking = false;
	
	Call_StartForward(ff2.m_forwards[FF2OnQueuePoints]);
	int[] points = new int[MaxClients];
	for( int i=1; i<=MaxClients; i++ )
		points[i] = ff2.m_queuePoints[i];
	
	Action action;
	Call_PushArrayEx(points, MaxClients+1, SM_PARAM_COPYBACK);
	Call_Finish(action);
	if( action == Plugin_Changed ) {
		for( int i=1; i<=MaxClients; i++ ) {
			if( !IsClientInGame(i) )
				continue;
			
			FF2Player player = FF2Player(i);
			player.SetPropInt("iQueue", points[i] - ff2.m_queuePoints[i] + player.GetPropInt("iQueue"));
		}
	} else if( action != Plugin_Continue ) {
		for( int i=1; i<=MaxClients; i++ ) { 
			if( !IsClientInGame(i) )
				continue;
			
			FF2Player player = FF2Player(i);
			player.SetPropInt("iQueue", player.GetPropInt("iQueue") - ff2.m_queuePoints[i]);
		}
	}
}

public Action OnHurtShieldFF2(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act;
	Call_StartForward(ff2.m_forwards[FF2OnHurtShield]);
	Call_PushCell(victim.index);
	int shield = GetEquippedWearableForLoadoutSlot(victim.index, TFWeaponSlot_Secondary);
	Call_PushCellRef(shield);
	int boss = ClientToBossIndex(attacker);
	Call_PushCell(boss);
	Call_PushCell(attacker);
	float damage2 = damage;
	Call_PushCellRef(damage2);
	Call_Finish(act);
	if( act==Plugin_Stop )
		return Plugin_Changed;
	else if( act!=Plugin_Continue )
		damage = damage2;
	
	return Plugin_Continue;
}

public void PostRoundStartFF2(const VSH2Player[] bosses, const int boss_count, const VSH2Player[] red_players, const int red_count)
{
	Call_StartForward(ff2.m_forwards[FF2PostRoundStart]);
	Call_PushArray(bosses, boss_count);
	Call_PushCell(boss_count);
	Call_PushArray(red_players, red_count);
	Call_PushCell(red_count);
	Call_Finish();
}

public Action OnBossJaratedFF2(const VSH2Player victim, const VSH2Player attacker)
{
	Action act;
	Call_StartForward(ff2.m_forwards[FF2OnBossJarated]);
	int boss = ClientToBossIndex(victim.index);
	Call_PushCell(boss);
	Call_PushCell(attacker.index);
	float rage = victim.GetPropFloat("flRAGE");
	Call_PushFloatRef(rage);
	Call_Finish(act);
	if( act==Plugin_Stop )
		return Plugin_Changed;
	
	rage -= vsh2cvars.m_fljarate.FloatValue;
	if( rage <= 0.0 )
		rage = 0.0;
	
	victim.SetPropFloat("flRAGE", rage);
	return Plugin_Continue;
}


public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if( !ff2.m_vsh2 )
		return APLRes_Failure;
	
	CreateNative("FF2_IsFF2Enabled", Native_FF2_IsFF2Enabled);
	CreateNative("FF2_GetFF2Version", Native_FF2_GetFF2Version);
	
	ff2.m_forwards[FF2OnMusic] = new GlobalForward("FF2_OnMusic", ET_Hook, Param_String, Param_FloatByRef);
	ff2.m_forwards[FF2OnMusic2] = new GlobalForward("FF2_OnMusic2", ET_Hook, Param_String, Param_FloatByRef, Param_String, Param_String);
	ff2.m_forwards[FF2OnSpecial] = new GlobalForward("FF2_OnSpecialSelected", ET_Hook, Param_Cell, Param_CellByRef, Param_String, Param_Cell);
	ff2.m_forwards[FF2OnAlive] = new GlobalForward("FF2_OnAlivePlayersChanged", ET_Hook, Param_Cell, Param_Cell);
	ff2.m_forwards[FF2OnLoseLife] = new GlobalForward("FF2_OnLoseLife", ET_Hook, Param_Cell, Param_CellByRef, Param_Cell);
	ff2.m_forwards[FF2OnBackstab] = new GlobalForward("FF2_OnBackStabbed", ET_Hook, Param_Cell, Param_Cell, Param_Cell);
	ff2.m_forwards[FF2OnPreAbility] = new GlobalForward("FF2_PreAbility", ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell, Param_CellByRef);
	ff2.m_forwards[FF2OnAbility] = new GlobalForward("FF2_OnAbility", ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell);
	ff2.m_forwards[FF2OnQueuePoints] = new GlobalForward("FF2_OnAddQueuePoints", ET_Hook, Param_Array);
	ff2.m_forwards[FF2OnHurtShield] = new GlobalForward("FF2_OnHurtShield", ET_Hook, Param_Cell, Param_CellByRef, Param_Cell, Param_Cell, Param_CellByRef);
	ff2.m_forwards[FF2PostRoundStart] = new GlobalForward("FF2_OnPostRoundStart", ET_Ignore, Param_Array, Param_Cell, Param_Array, Param_Cell);
	ff2.m_forwards[FF2OnBossJarated] = new GlobalForward("FF2_OnBossJarated", ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef);
	
	RegPluginLibrary("freak_fortress_2");
	return APLRes_Success;
}

/** bool FF2_IsFF2Enabled(); */
public int Native_FF2_IsFF2Enabled(Handle plugin, int numParams)
{
	return vsh2cvars.m_enabled.BoolValue;
}

/** bool FF2_GetFF2Version(int[] version=0); */
public int Native_FF2_GetFF2Version(Handle plugin, int numParams)
{
	char version_str[10];
	vsh2cvars.m_version.GetString(version_str, sizeof(version_str));
	
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
	if( !IsBossValid(boss) )
		return -1;
	else if( boss==0 ) {
		FF2Player player;
		return( ZeroBossToFF2Player(player) ) ? player.userid : -1;
	}
	FF2Player player = FF2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.userid : -1;
}

/** int FF2_GetBossIndex(int client); */
public int Native_FF2_GetBossIndex(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if( client <= 0 || client > MaxClients )
		return -1;

	return ClientToBossIndex(client);
}

/** int FF2_GetBossTeam(); */
public int Native_FF2_GetBossTeam(Handle plugin, int numParams)
{
	return VSH2Team_Boss;
}

/** bool FF2_GetBossSpecial(int boss=0, char[] buffer, int bufferLength, int bossMeaning=0); */
public int Native_FF2_GetBossSpecial(Handle plugin, int numParams)
{
	int
		index = GetNativeCell(1),
		buflen = GetNativeCell(3),
		meaning = GetNativeCell(4)
	;
	char[] name = new char[buflen];
	
	ConfigMap cfg = GetFF2Config(index, view_as<bool>(meaning));
	if( cfg != null ) {
		bool result = view_as<bool>(cfg.Get("character.name", name, buflen));
		if( result )
			SetNativeString(2, name, buflen);
		return result;
	}
	return false;
}

/** int FF2_GetBossHealth(int boss=0); */
public int Native_FF2_GetBossHealth(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( !IsBossValid(boss) )
		return 0;
	else if( boss==0 ) {
		FF2Player player;
		return( ZeroBossToFF2Player(player) ) ? player.iHealth : 0;
	}
	FF2Player player = FF2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.iHealth : 0;
}

/** void FF2_SetBossHealth(int boss, int health); */
public any Native_FF2_SetBossHealth(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( !IsBossValid(boss) )
		return false;
	
	int new_health = GetNativeCell(2);
	if( boss==0 ) {
		FF2Player player;
		return( ZeroBossToFF2Player(player) ) ? player.SetPropInt("iHealth", new_health) : false;
	}
	FF2Player player = FF2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.SetPropInt("iHealth", new_health) : false;
}

/** int FF2_GetBossMaxHealth(int boss=0); */
public int Native_FF2_GetBossMaxHealth(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( !IsBossValid(boss) )
		return 0;
	else if( boss==0 ) {
		FF2Player player;
		return( ZeroBossToFF2Player(player) ) ? player.GetPropInt("iMaxHealth") : 0;
	}
	FF2Player player = FF2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.GetPropInt("iMaxHealth") : 0;
}

/** void FF2_SetBossMaxHealth(int boss, int health); */
public any Native_FF2_SetBossMaxHealth(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( !IsBossValid(boss) )
		return 0;
	
	int new_maxhealth = GetNativeCell(2);
	if( boss==0 ) {
		FF2Player player;
		return( ZeroBossToFF2Player(player) ) ? player.SetPropInt("iMaxHealth", new_maxhealth) : false;
	}
	FF2Player player = FF2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.SetPropInt("iMaxHealth", new_maxhealth) : false;
}

/** int FF2_GetBossLives(int boss); */
public int Native_FF2_GetBossLives(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( !IsBossValid(boss) )
		return 0;
	else if( boss==0 ) {
		FF2Player player;
		return( ZeroBossToFF2Player(player) ) ? player.GetPropInt("iLives") : 0;
	}
	FF2Player player = FF2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.GetPropInt("iLives") : 0;
}

/** void FF2_SetBossLives(int boss, int lives); */
public any Native_FF2_SetBossLives(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( !IsBossValid(boss) )
		return 0;
	
	int lives = GetNativeCell(2);
	if( boss==0 ) {
		FF2Player player;
		return( ZeroBossToFF2Player(player) ) ? player.SetPropInt("iLives", lives) : false;
	}
	FF2Player player = FF2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.SetPropInt("iLives", lives) : false;
}

/** int FF2_GetBossMaxLives(int boss); */
public int Native_FF2_GetBossMaxLives(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( !IsBossValid(boss) )
		return 0;
	else if( boss==0 ) {
		FF2Player player;
		return( ZeroBossToFF2Player(player) ) ? player.GetPropInt("iMaxLives") : 0;
	}
	FF2Player player = FF2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.GetPropInt("iMaxLives") : 0;
}

/** void FF2_SetBossMaxLives(int boss, int lives); */
public any Native_FF2_SetBossMaxLives(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( !IsBossValid(boss) )
		return 0;
	
	int lives = GetNativeCell(2);
	if( boss==0 ) {
		FF2Player player;
		return( ZeroBossToFF2Player(player) ) ? player.SetPropInt("iMaxLives", lives) : false;
	}
	FF2Player player = FF2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.SetPropInt("iMaxLives", lives) : false;
}

/** void FF2_SetQueuePoints(int client, int value); */
public any Native_FF2_SetQueuePoints(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if( !IsClientValid(client) )
		return 0;
	int q = GetNativeCell(2);
	FF2Player player = FF2Player(client);
	return player.SetPropInt("iQueue", q);
}

/** int FF2_GetQueuePoints(int client); */
public any Native_FF2_GetQueuePoints(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if( !IsClientValid(client) )
		return -1;    /// Batfoxkid: In FF2, invalid client throws an error
	
	FF2Player player = FF2Player(client);
	return player.GetPropInt("iQueue");
}

/** void FF2_LogError(const char[] message, any ...); */
public any Native_FF2_LogError(Handle plugin, int numParams)
{
	char buffer[MAX_BUFFER_LENGTH];
	int error = FormatNativeString(0, 1, 2, sizeof(buffer), .fmt_string=buffer);
	if( error != SP_ERROR_NONE ) {
		ThrowNativeError(error, "Failed to format");
		return;
	}
	LogError(buffer);
	return;
}

/** bool FF2_Debug(); */
public any Native_FF2_Debug(Handle plugin, int numParams)
{
	return 1; /// Batfoxkid: Not sure what you want to do here, this mainly just tells the plugin when to print out Debug messages
}

/** void FF2_SetCheats(bool status); */
public any Native_FF2_SetCheats(Handle plugin, int numParams)
{
	ff2.m_cheats = GetNativeCell(1);
}

/** bool FF2_GetCheats(); */
public any Native_FF2_GetCheats(Handle plugin, int numParams)
{
	return ff2.m_cheats;
}

/** float FF2_GetBossCharge(int boss, int slot); */
public any Native_FF2_GetBossCharge(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if( !IsBossValid(client) )
		return 0.0;
	
	int slot = GetNativeCell(2);
	switch( slot ) {
		case 0: { /// Rage
			FF2Player player = FF2Player(client);
			return player.GetPropFloat("flRAGE");
		}
		default: {
			return FF2_GetCustomCharge(client, slot);
		}
	}
}

/** void FF2_SetBossCharge(int boss, int slot, float value); */
public any Native_FF2_SetBossCharge(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if( !IsBossValid(client) )
		return 0;
	
	int slot = GetNativeCell(2);
	float value = GetNativeCell(3);
	switch( slot ) {
		case 0: { /// Rage
			FF2Player player = FF2Player(client);
			return player.SetPropFloat("flRAGE", value);
		}
		default: {
			return FF2_SetCustomCharge(client, slot, value);
		}
	}
}

/** int FF2_GetBossRageDamage(int boss); */
public int Native_FF2_GetBossRageDamage(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	FF2Player player = FF2Player(client);
	return player.iRageDmg;
}

/** void FF2_SetBossRageDamage(int boss, int damage); */
public any Native_FF2_SetBossRageDamage(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	FF2Player player = FF2Player(client);
	int damage = GetNativeCell(2);
	player.iRageDmg = damage;
	return 0;
}

/** int FF2_GetClientDamage(int client); */
public int Native_FF2_GetClientDamage(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if( !IsClientValid(client) )
		return 0;
	FF2Player player = FF2Player(client);
	return player.GetPropInt("iDamage");
}

/** void FF2_SetClientDamage(int client, int val); */
public int Native_FF2_SetClientDamage(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if( !IsClientValid(client) )
		return 0;
	FF2Player player = FF2Player(client);
	return player.SetPropInt("iDamage", GetNativeCell(2));
}

/** float FF2_GetRageDist(int boss=0, const char[] pluginName="", const char[] abilityName=""); */
public any Native_FF2_GetRageDist(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( !IsBossValid(boss) )
		return 0.0;
	
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));
	
	ConfigMap cfg = GetFF2Config(boss);
	
	if( ability_name[0]==0 ) {
		float f;
		/// GetFloat + GetInt return number of characters used in conversion.
		return( cfg.GetFloat("character.ragedist", f) > 0 ) ? f : 0.0;
	}
	
	ConfigMap section = JumpToAbility(cfg.GetSection("character"), plugin_name, ability_name);
	float see;
	if( !section.GetFloat("dist", see) ) {
		section.GetFloat("ragedist", see);
	}
	
	return view_as<int>(see);
}

/** bool FF2_HasAbility(int boss, const char[] pluginName, const char[] abilityName); */
public any Native_FF2_HasAbility(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( !IsBossValid(boss) ) {
		return false;
	}
	
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));
	
	bool result = JumpToAbility(GetMyCharacterCfg(boss), plugin_name, ability_name) != null;
	
	return result;
}

/** bool FF2_DoAbility(int boss, const char[] pluginName, const char[] abilityName, int slot, int buttonMode=0); */
public any Native_FF2_DoAbility(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( !IsBossValid(boss) ) {
		LogError("[VSH2/FF2] Invalid boss index (%d) for FF2_DoAbility()!", boss);
		return false;
	}
	
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));
	
	int slot = GetNativeCell(4);
	int button = GetNativeCell(5);
	
	return UseAbility(plugin_name, ability_name, boss, slot, button);
}

/** int FF2_GetAbilityArgument(int boss, const char[] pluginName, const char[] abilityName, int argument, int defValue=0); */
public int Native_FF2_GetAbilityArgument(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( !IsBossValid(boss) )
		return 0;
	
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));
	char argument[8]; int key = GetNativeCell(4); FormatEx(argument, sizeof(argument), "arg%i", key);
	
	int defval = GetNativeCell(5);
	
	return GetArgNamedI(boss, plugin_name, ability_name, argument, defval);
}

/** float FF2_GetAbilityArgumentFloat(int boss, const char[] plugin_name, const char[] ability_name, int argument, float defValue=0.0); */
public any Native_FF2_GetAbilityArgumentFloat(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( !IsBossValid(boss) )
		return 0.0;
	
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));
	char argument[8]; int key = GetNativeCell(4); FormatEx(argument, sizeof(argument), "arg%i", key);
	
	float defval = GetNativeCell(5);
	
	return GetArgNamedF(boss, plugin_name, ability_name, argument, defval);
}

/** void FF2_GetAbilityArgumentString(int boss, const char[] pluginName, const char[] abilityName, int argument, char[] buffer, int bufferLength); */
public any Native_FF2_GetAbilityArgumentString(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( !IsBossValid(boss) )
		return;
	
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));
	char argument[8]; int key = GetNativeCell(4); FormatEx(argument, sizeof(argument), "arg%i", key);
	int length; length = GetNativeCell(6);
	char[] result = new char[length];
	
	GetArgNamedS(boss, plugin_name, ability_name, argument, result, length);
	SetNativeString(5, result, length);
}

/** int FF2_GetArgNamedI(int boss, const char[] pluginName, const char[] abilityName, const char[] argument, int defValue=0); */
public int Native_FF2_GetArgNamedI(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( !IsBossValid(boss) )
		return 0;
	
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));
	char argument[32]; GetNativeString(4, argument, sizeof(argument));
	
	int defval = GetNativeCell(5);
	
	return GetArgNamedI(boss, plugin_name, ability_name, argument, defval);
}

/** float FF2_GetArgNamedF(int boss, const char[] plugin_name, const char[] ability_name, const char[] argument, float defValue=0.0); */
public any Native_FF2_GetArgNamedF(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( !IsBossValid(boss) )
		return 0.0;
	
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));
	char argument[32]; GetNativeString(4, argument, sizeof(argument));
	
	float defval = GetNativeCell(5);
	
	return GetArgNamedF(boss, plugin_name, ability_name, argument, defval);
}

/** void FF2_GetArgNamedS(int boss, const char[] pluginName, const char[] abilityName, const char[] argument, char[] buffer, int bufferLength); */
public any Native_FF2_GetArgNamedS(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( !IsBossValid(boss) )
		return;
	
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));
	char argument[32]; GetNativeString(4, argument, sizeof(argument));
	int length; length = GetNativeCell(6);
	char[] result = new char[length];
	
	GetArgNamedS(boss, plugin_name, ability_name, argument, result, length);
	SetNativeString(5, result, length);
}

/** bool FF2_RandomSound(const char[] keyvalue, char[] buffer, int bufferLength, int boss=0, int slot=0); */
public any Native_FF2_RandomSound(Handle plugin, int numParams)
{
	int boss = GetNativeCell(4);
	
	if( !IsBossValid(boss) ) {
		LogError("[VSH2/FF2] Invalid boss index (%d) for FF2_DoAbility()!", boss);
		return false;
	}
	
	int slot = GetNativeCell(5);
	int size = GetNativeCell(3); ++size;
	char[] sound = new char[size];
	
	int key_size; GetNativeStringLength(1, key_size); ++key_size;

	char[] key = new char[key_size];
	GetNativeString(1, key, key_size);

	bool soundExists;
	if( !strncmp(key, "sound_ability", 13, false) ) {
		soundExists = RandomSoundAbility(key, sound, size, boss, slot);
	} else {
		soundExists = RandomSound(key, sound, size, boss);
	}
	
	if( !soundExists )
		return false;
	
	return SetNativeString(2, sound, size) == SP_ERROR_NONE;
}

/** void FF2_StartMusic(int client=0); */
public any Native_FF2_StartMusic(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if( !IsClientValid(client) )
		return 0;
	FF2Player player = FF2Player(client);
	player.PlayMusic(vsh2cvars.m_flmusicvol.FloatValue);
	return 0;
}

/** void FF2_StopMusic(int client=0); */
public any Native_FF2_StopMusic(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if( !IsClientValid(client) )
		return 0;
	FF2Player player = FF2Player(client);
	player.StopMusic();
	return 0;
}

/** Handle FF2_GetBossKV(int boss=0); */
public any Native_FF2_GetBossKV(Handle plugin, int numParams)
{
	/// Return null KV for now.
	return 0;
}

/** Handle FF2_GetSpecialKV(int boss, int specialIndex=0); */
public any Native_FF2_GetSpecialKV(Handle plugin, int numParams)
{
	/// Return null KV for now.
	return 0;
}

/** int FF2_GetFF2flags(int client); */
public int Native_FF2_GetFF2flags(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if( !IsClientValid(client) )
		return 0;
	
	FF2Player player = FF2Player(client);
	return player.iFlags;
}

/** void FF2_SetFF2flags(int client, int flags); */
public any Native_FF2_SetFF2flags(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if( !IsClientValid(client) )
		return 0;
	
	int flags = GetNativeCell(2);
	
	FF2Player player = FF2Player(client);
	return player.iFlags = flags;
}

/** float FF2_GetClientGlow(int client); */
public any Native_FF2_GetClientGlow(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if(!GetEntProp(client, Prop_Send, "m_bGlowEnabled"))
		return 0.0;
	
	FF2Player player = FF2Player(client);
	return (player.GetPropFloat("flGlowtime"));
}

/** void FF2_SetClientGlow(int client, float time1, float time2=-1.0); */
public any Native_FF2_SetClientGlow(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if( !IsClientValid(client) )
		return 0;
	
	FF2Player player = FF2Player(client);
	float time1 = GetNativeCell(2);
	float time2 = GetNativeCell(3);
	float glowt = player.GetPropFloat("flGlowtime");
	player.SetPropFloat("fl_GLowTime", glowt + time1);
	
	if( time2 > 0.0 )
		player.SetPropFloat("fl_GLowTime", time2);
	
	return 0;
}

/** TODO int FF2_GetAlivePlayers(); */
public any Native_FF2_GetAlivePlayers(Handle plugin, int numParams)
{
	return 0;
}

/** TODO int FF2_GetBossPlayers(); */
public any Native_FF2_GetBossPlayers(Handle plugin, int numParams)
{
	return 0;
}

/** float FF2_GetClientShield(int client); */
public any Native_FF2_GetClientShieldHealth(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if( !IsClientValid(client) )
		return 0.0;
	
	FF2Player player = FF2Player(client);
	return (player.iShieldId == -1) ? -1:RoundFloat(player.iShieldHP);
}

/** void FF2_SetClientShield(int client, int entity=0, float health=0.0, float reduction=-1.0); */
public any Native_FF2_SetClientShield(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if( !IsClientValid(client) )
		return 0;
	
	int shield = GetNativeCell(2);
	if( !IsValidEntity(shield) )
		return 0;
		
	FF2Player player = FF2Player(client);
	float health = GetNativeCell(3);
	
	player.iShieldId = ( GetOwner(shield)!=client || shield==0 ) ? player.iShieldId : EntIndexToEntRef(shield);
	player.iShieldHP = health;
	
	return 0;
}

/** bool FF2_RemoveClientShield(int client); */
public any Native_FF2_RemoveClientShield(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if( !IsClientValid(client) )
		return false;
	
	FF2Player player = FF2Player(client);
	player.iShieldHP = 0.0;
	
	int shield = GetEquippedWearableForLoadoutSlot(client, TFWeaponSlot_Secondary);
	if( shield == -1 || player.iShieldId == -1 )
		return false;
	
	TF2_RemoveWearable(client, shield);
	player.iShieldId = -1;
	
	return true;
}

/** TODO void FF2_MakeBoss(int client, int boss, int special=-1, bool rival=false); */
public any Native_FF2_MakeBoss(Handle plugin, int numParams)
{
	return 0;
}

/** TODO bool FF2_SelectBoss(int client, const char[] boss, bool access=true); */
public any Native_FF2_SelectBoss(Handle plugin, int numParams)
{
	return 0;
}

/** ConfigMap FF2_GetSpecialConfig(int boss=0, bool meaning=false); */
public any Native_FF2_GetSpecialConfig(Handle plugin, int numParams)
{
	int index = GetNativeCell(1);
	bool meaning = GetNativeCell(2);
	return GetFF2Config(index, meaning);
}

/** TODO ZZZZZZZZZZZZZZZZZZZZZZZZZZZ */
/*
public any Native_ZZZ(Handle plugin, int numParams)
{
	return 0;
}
*/


/**
 * GameDataFF2, SDKCalls
 */

Handle hGetEquippedWearable = null;

static void Prep_GameDataFF2()
{
	GameData config = new GameData("freak_fortress_2");
	if( config==null ) {
		LogError("[VSH/FF2] Failed to Load \"freak_fortress_2.txt\" GameData.");
		return;
	}
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(config, SDKConf_Signature, "CTFPlayer::GetEquippedWearableForLoadoutSlot");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	if( (hGetEquippedWearable = EndPrepSDKCall()) == null ) {
		LogError("[VSH/FF2] Invalid SDKCall Handle for \"CTFPlayer::GetEquippedWearableForLoadoutSlot()\"!");
	}
	delete config;
}

stock int GetEquippedWearableForLoadoutSlot(int client, int slot)
{
	return ( hGetEquippedWearable == null ) ? -1:SDKCall(hGetEquippedWearable, client, slot);
}
