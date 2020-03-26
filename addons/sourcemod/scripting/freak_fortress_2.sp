#include <morecolors>

#undef REQUIRE_PLUGIN
#include <vsh2>
#define REQUIRE_PLUGIN

#pragma semicolon        1
#pragma newdecls         required

public Plugin myinfo = {
	name           = "VSH2 to FF2 Compatibility layer.",
	author         = "Nergal/Assyrianic & BatFoxKid",
	description    = "Implements FF2's forwards & natives using VSH2's API",
	version        = "1.0a",
	url            = "https://github.com/VSH2-Devs/Vs-Saxton-Hale-2"
};


#define MAX_SUBPLUGIN_NAME    64
#define PLYR                  35

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
	MaxFF2Forwards
};

enum struct FF2CompatPlugin {
	GlobalForward  m_forwards[MaxFF2Forwards];
	ArrayList      m_subplugins;
	bool           m_vsh2;
	bool           m_cheats;
}

enum struct VSH2ConVars {
	ConVar m_enabled;
	ConVar m_version;
}

static FF2CompatPlugin ff2;
static VSH2ConVars     vsh2cvars;
static int queuePoints[PLYR];
static bool queueChecking;

public void OnPluginStart()
{
	/// ConVars subplugins depend on
	CreateConVar("ff2_oldjump", "1", "Use old Saxton Hale jump equations", _, true, 0.0, true, 1.0);
	CreateConVar("ff2_base_jumper_stun", "0", "Whether or not the Base Jumper should be disabled when a player gets stunned", _, true, 0.0, true, 1.0);
	CreateConVar("ff2_solo_shame", "0", "Always insult the boss for solo raging", _, true, 0.0, true, 1.0);
}

public void OnAllPluginsLoaded() 
{
	ff2.m_subplugins = new ArrayList(MAX_SUBPLUGIN_NAME);
	VSH2_Hook(OnMusic, OnMusicFF2);
	VSH2_Hook(OnBossSelected, OnBossSelectedFF2);
	VSH2_Hook(OnPlayerKilled, OnPlayerKilledFF2);
	VSH2_Hook(OnBossTakeDamage_OnStabbed, OnBossBackstabFF2);
	VSH2_Hook(OnBossTaunt, OnBossTauntFF2);
	VSH2_Hook(OnScoreTally, OnScoreTallyFF2);
	
	/// FF2 has a set max lives limit, VSH2 imposes no such limit on lives.
	/// Create iMaxLives property for FF2 to use exclusively.
	for( int i=MaxClients; i; i-- )
		if( 0 < i <= MaxClients && IsClientInGame(i) )
			VSH2Player(i).SetPropInt("iMaxLives", 0);
}

public void OnLibraryAdded(const char[] name) {
	if (StrEqual(name, "VSH2")) {
		ff2.m_vsh2 = true;
		vsh2cvars.m_enabled = FindConVar("vsh2cvars.m_enabled");
		vsh2cvars.m_version = FindConVar("vsh2cvars.m_version");
	}
}

public void OnLibraryRemoved(const char[] name) {
	if (StrEqual(name, "VSH2")) {
		ff2.m_vsh2 = false;
	}
}


public Action OnMusicFF2(char song[PLATFORM_MAX_PATH], float& time, const VSH2Player player)
{
	Action act;
	Call_StartForward(ff2.m_forwards[FF2OnMusic]);
	char song2[PLATFORM_MAX_PATH]; strcopy(song2, sizeof(song2), song);
	Call_PushStringEx(song, sizeof(song), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	float time2 = time;
	Call_PushFloatRef(time2);
	Call_Finish(act);
	if( act != Plugin_Continue ) {
		strcopy(song, sizeof(song), song2);
		time = time2;
		return act;
	}

	Call_StartForward(ff2.m_forwards[FF2OnMusic2]);
	strcopy(song2, sizeof(song2), song);
	Call_PushStringEx(song, sizeof(song), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	time2 = time;
	Call_PushFloatRef(time2);
	Call_PushStringEx("Unknown Song", 64, SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushStringEx("Unknown Artist", 64, SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
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

	if( victim.GetPropAny("bIsBoss") ) {
		Action act;
		Call_StartForward(ff2.m_forwards[FF2OnLoseLife]);
		int boss = ClientToBossIndex(victim.index);
		Call_PushCell(boss);
		int lives = victim.GetPropInt("iLives");
		Call_PushCellRef(bossLives);
		Call_PushCell(BossLivesMax[boss]);
		Call_Finish(act);
		if( act==Plugin_Changed ) {
			if( lives > victim.GetPropInt("iMaxLives") )
				victim.SetPropInt("iMaxLives", lives);

			victim.SetPropInt("iLives", lives);
		}
	}

	/// TODO: FF2_OnAlivePlayersChanged is called more ways, OnClientDisconnect, player_spawn, arena_round_start
	Call_StartForward(ff2.m_forwards[FF2OnAlive]);
	VSH2Player[] array = new VSH2Player[MaxClients];
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
	int boss = ClientToBossIndex(victim.index);
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
	queuePoints[player.index] = queue_earned;
	if (!queueChecking ) {
		RequestFrame(FinishQueueArray);
		queueChecking = true;
	}
}

public void FinishQueueArray()
{
	queueChecking = false;

	Call_StartForward(ff2.m_forwards[FF2OnQueuePoints]);
	int[] points = new int[MaxClients];
	for( int i=1; i<=MaxClients; i++ )
		points[i] = queuePoints[i];

	Call_PushArrayEx(points, MaxClients+1, SM_PARAM_COPYBACK);
	Call_Finish(action);
	if( action == Plugin_Changed ) {
		for( int i=1; i<=MaxClients; i++ ) {
			if( !IsClientInGame(i) )
				continue;

			VSH2Player player = VSH2Player(i);
			player.SetPropInt("iQueue", points[i]-queuePoints[i]+player.GetPropInt("iQueue"));
		}
	}
	else if( action != Plugin_Continue ) {
		for( int i=1; i<=MaxClients; i++ ) { 
			if( !IsClientInGame(i) )
				continue;

			VSH2Player player = VSH2Player(i);
			player.SetPropInt("iQueue", player.GetPropInt("iQueue")-queuePoints[i]);
		}
	}
}


public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if( !ff2.m_vsh2 || !vsh2cvars.m_enabled.BoolValue )
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
	if( boss < 0 || boss > MaxClients )
		return -1;
	else if( boss==0 ) {
		VSHPlayer player;
		if( ZeroBossToVSHPlayer(player) )
			return player.userid;
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
		VSHPlayer player;
		if( ZeroBossToVSHPlayer(player) )
			return player.GetPropInt("iHealth");
	}
	VSH2Player player = VSH2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.GetPropInt("iHealth") : 0;
}

/** void FF2_SetBossHealth(int boss, int health); */
public any Native_FF2_SetBossHealth(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( boss < 0 || boss > MaxClients )
		return 0;
	
	int new_health = GetNativeCell(2);
	if( boss==0 ) {
		VSHPlayer player;
		if( ZeroBossToVSHPlayer(player) )
			return player.SetPropInt("iHealth", new_health);
	}
	VSH2Player player = VSH2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.SetPropInt("iHealth", new_health) : false;
}

/** int FF2_GetBossMaxHealth(int boss=0); */
public int Native_FF2_GetBossMaxHealth(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( boss < 0 || boss > MaxClients )
		return 0;
	else if( boss==0 ) {
		VSHPlayer player;
		if( ZeroBossToVSHPlayer(player) )
			return player.GetPropInt("iMaxHealth");
	}
	VSH2Player player = VSH2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.GetPropInt("iMaxHealth") : 0;
}

/** void FF2_SetBossMaxHealth(int boss, int health); */
public any Native_FF2_SetBossMaxHealth(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( boss < 0 || boss > MaxClients )
		return 0;
	
	int new_maxhealth = GetNativeCell(2);
	if( boss==0 ) {
		VSHPlayer player;
		if( ZeroBossToVSHPlayer(player) )
			return player.SetPropInt("iMaxHealth", new_maxhealth);
	}
	VSH2Player player = VSH2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.SetPropInt("iMaxHealth", new_maxhealth) : false;
}

/** int FF2_GetBossLives(int boss); */
public int Native_FF2_GetBossLives(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( boss < 0 || boss > MaxClients )
		return 0;
	else if( boss==0 ) {
		VSHPlayer player;
		if( ZeroBossToVSHPlayer(player) )
			return player.GetPropInt("iLives");
	}
	VSH2Player player = VSH2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.GetPropInt("iLives") : 0;
}

/** void FF2_SetBossLives(int boss, int lives); */
public any Native_FF2_SetBossLives(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( boss < 0 || boss > MaxClients )
		return 0;
	
	int lives = GetNativeCell(2);
	if( boss==0 ) {
		VSHPlayer player;
		if( ZeroBossToVSHPlayer(player) )
			return player.SetPropInt("iLives", lives);
	}
	VSH2Player player = VSH2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.SetPropInt("iLives", lives) : false;
}

/** int FF2_GetBossMaxLives(int boss); */
public int Native_FF2_GetBossMaxLives(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( boss < 0 || boss > MaxClients )
		return 0;
	else if( boss==0 ) {
		VSHPlayer player;
		if( ZeroBossToVSHPlayer(player) )
			return player.GetPropInt("iMaxLives");
	}
	VSH2Player player = VSH2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.GetPropInt("iMaxLives") : 0;
}

/** void FF2_SetBossMaxLives(int boss, int lives); */
public any Native_FF2_SetBossMaxLives(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	if( boss < 0 || boss > MaxClients )
		return 0;
	
	int lives = GetNativeCell(2);
	if( boss==0 ) {
		VSHPlayer player;
		if( ZeroBossToVSHPlayer(player) )
			return player.SetPropInt("iMaxLives", lives);
	}
	VSH2Player player = VSH2Player(boss);
	return( player && player.GetPropAny("bIsBoss") ) ? player.SetPropInt("iMaxLives", lives) : false;
}

/** void FF2_SetQueuePoints(int client, int value); */
public any Native_FF2_SetQueuePoints(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if( client <= 0 || client > MaxClients )
		return 0;
	
	VSH2Player player = VSH2Player(client);
	return player.SetPropInt("iQueue", GetNativeCell(2));
}

/** int FF2_GetQueuePoints(int client); */
public any Native_FF2_GetQueuePoints(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if( client <= 0 || client > MaxClients )
		return -1;	/// Batfoxkid: In FF2, invalid client throws an error

	VSH2Player player = VSH2Player(client);
	return player.GetPropInt("iQueue");
}

/** void FF2_LogError(const char[] message, any ...); */
public any Native_FF2_LogError(Handle plugin, int numParams)
{
	char buffer[MAX_BUFFER_LENGTH], buffer2[MAX_BUFFER_LENGTH], message[192];
	SetNativeString(1, message, sizeof(message));
	Format(buffer, sizeof(buffer), "%s", message);
	VFormat(buffer2, sizeof(buffer2), buffer, 2);
	LogError(buffer2);
	return 0;
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

stock int ClientToBossIndex(int client)
{
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

stock bool ZeroBossToVSHPlayer(VSH2Player& player)
{
	VSH2Player[] players = new VSH2Player[MaxClients];
	if( VSH2GameMode_GetBosses(players, false) < 1 )
		return false;

	player = players[0];
	return true;
}
