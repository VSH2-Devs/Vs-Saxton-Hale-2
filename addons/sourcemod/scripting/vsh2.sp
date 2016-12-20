#include <sourcemod>
#include <sdktools>
#include <clientprefs>
#include <tf2_stocks>
#include <tf2items>
#include <sdkhooks>
#include <morecolors>
#include <vsh2>

#undef REQUIRE_PLUGIN
#tryinclude <tf2attributes>
#define REQUIRE_PLUGIN

#undef REQUIRE_EXTENSIONS
#tryinclude <steamtools>
#define REQUIRE_EXTENSIONS

#pragma semicolon			1
#pragma newdecls			required

#define PLUGIN_VERSION			"1.5.7 BETA"
#define PLUGIN_DESCRIPT			"VS Saxton Hale 2"
#define CODEFRAMES			(1.0/30.0)	/* 30 frames per second means 0.03333 seconds or 33.33 ms */

#define IsClientValid(%1)		( 0 < (%1) and (%1) <= MaxClients and IsClientInGame((%1)) )
#define PLYR				MAXPLAYERS+1

//Team number defines
#define UNASSIGNED 0
#define NEUTRAL 0
#define SPEC 1
#define RED 2
#define BLU 3

//Python+C style operators
#define and				&&
#define and_eq				&=
#define bitand				&
#define bitor				|
#define compl				~
#define not				!
#define not_eq				!=
#define or				||
#define or_eq				|=
#define xor				^
#define xor_eq				^=
#define bitl				<<
#define bitr				>>
#define is				==

//functional-style typecasting
#define int(%1)				view_as<int>(%1)
#define Handle(%1)			view_as<Handle>(%1)

//misc.
#define nullfunc			INVALID_FUNCTION
#define nullvec				NULL_VECTOR
#define nullstr				NULL_STRING
#define toggle(%1)			%1 = not %1

#define _buffer(%1)			%1, sizeof(%1)
#define _strbuffer(%1)			%1, sizeof(%1)
#define PLYR				MAXPLAYERS+1
#define PATH				64
#define FULLPATH			PLATFORM_MAX_PATH
#define repeat(%1)			for (int xyz=0; xyz<%1; ++xyz)	// laziness is real lmao


public Plugin myinfo = {
	name 			= "TF2Bosses Mod",
	author 			= "nergal/assyrian, props to Flamin' Sarge, Chdata, & Buzzkillington",
	description 		= "Allows Players to play as various bosses of TF2",
	version 		= PLUGIN_VERSION,
	url 			= "https://forums.alliedmods.net/showthread.php?t=286701"
};

enum /*CvarName*/
{
	PointType = 0,
	PointDelay,
	AliveToEnable,
	FirstRound,
	DamagePoints,
	DamageForQueue,
	QueueGained,
	EnableMusic,
	MusicVolume,
	HealthPercentForLastGuy,
	HealthRegenForPlayers,
	HealthRegenAmount,
	MedigunReset,
	StopTickleTime,
	AirStrikeDamage,
	AirblastRage,
	JarateRage,
	FanoWarRage,
	LastPlayerTime,
	EngieBuildings,
	MedievalLives,
	MedievalRespawnTime,
	PermOverheal,
	MultiCapture,
	MultiCapAmount,
	DemoShieldCrits,
	MultiBossHandicap
};

// cvar + handles
ConVar
	bEnabled = null
;

ConVar cvarVSH2[MultiBossHandicap+1];

Handle
	hHudText,
	jumpHUD,
	rageHUD,
	timeleftHUD,
	PointCookie,
	BossCookie,
	MusicCookie
;

methodmap TF2Item < Handle
{
	/* [*C*O*N*S*T*R*U*C*T*O*R*] */

	public TF2Item(int iFlags) {
		return view_as<TF2Item>( TF2Items_CreateItem(iFlags) );
	}
	/////////////////////////////// 

	/* [ P R O P E R T I E S ] */

	property int iFlags {
		public get()			{ return TF2Items_GetFlags(this); }
		public set( int iVal )		{ TF2Items_SetFlags(this, iVal); }
	}

	property int iItemIndex {
		public get()			{return TF2Items_GetItemIndex(this);}
		public set( int iVal )		{TF2Items_SetItemIndex(this, iVal);}
	}

	property int iQuality {
		public get()			{return TF2Items_GetQuality(this);}
		public set( int iVal )		{TF2Items_SetQuality(this, iVal);}
	}

	property int iLevel {
		public get()			{return TF2Items_GetLevel(this);}
		public set( int iVal )		{TF2Items_SetLevel(this, iVal);}
	}

	property int iNumAttribs {
		public get()			{return TF2Items_GetNumAttributes(this);}
		public set( int iVal )		{TF2Items_SetNumAttributes(this, iVal);}
	}
	///////////////////////////////

	/* [ M E T H O D S ] */

	public int GiveNamedItem(int iClient)
	{
		return TF2Items_GiveNamedItem(iClient, this);
	}

	public void SetClassname(char[] strClassName)
	{
		TF2Items_SetClassname(this, strClassName);
	}

	public void GetClassname(char[] strDest, int iDestSize)
	{
		TF2Items_GetClassname(this, strDest, iDestSize);
	}

	public void SetAttribute(int iSlotIndex, int iAttribDefIndex, float flValue)
	{
		TF2Items_SetAttribute(this, iSlotIndex, iAttribDefIndex, flValue);
	}

	public int GetAttribID(int iSlotIndex)
	{
		return TF2Items_GetAttributeId(this, iSlotIndex);
	}

	public float GetAttribValue(int iSlotIndex)
	{
		return TF2Items_GetAttributeValue(this, iSlotIndex);
	}
	/**************************************************************/
};

//ArrayList ptrBosses ;

#include "modules/stocks.inc"
#include "modules/handler.sp"	// Contains the game mode logic as well
#include "modules/events.sp"
#include "modules/commands.sp"

ArrayList g_hPluginsRegistered;

public void OnPluginStart()
{
	//RegConsoleCmd("sm_onboss", MakeBoss);
	//RegConsoleCmd("sm_offboss", MakeNotBoss);
	gamemode = VSHGameMode();
	gamemode.Init();

	RegAdminCmd("sm_setspecial", SetNextSpecial, ADMFLAG_GENERIC);
	RegAdminCmd("sm_halespecial", SetNextSpecial, ADMFLAG_GENERIC);
	RegAdminCmd("sm_hale_special", SetNextSpecial, ADMFLAG_GENERIC);
	RegAdminCmd("sm_bossspecial", SetNextSpecial, ADMFLAG_GENERIC);
	RegAdminCmd("sm_boss_special", SetNextSpecial, ADMFLAG_GENERIC);
	RegAdminCmd("sm_ff2special", SetNextSpecial, ADMFLAG_GENERIC);
	RegAdminCmd("sm_ff2_special", SetNextSpecial, ADMFLAG_GENERIC);
	
	RegConsoleCmd("sm_hale_next", QueuePanelCmd);
	RegConsoleCmd("sm_halenext", QueuePanelCmd);
	RegConsoleCmd("sm_boss_next", QueuePanelCmd);
	RegConsoleCmd("sm_bossnext", QueuePanelCmd);
	RegConsoleCmd("sm_ff2_next", QueuePanelCmd);
	RegConsoleCmd("sm_ff2next", QueuePanelCmd);
	
	RegConsoleCmd("sm_hale_hp", Command_GetHPCmd);
	RegConsoleCmd("sm_halehp", Command_GetHPCmd);
	RegConsoleCmd("sm_boss_hp", Command_GetHPCmd);
	RegConsoleCmd("sm_bosshp", Command_GetHPCmd);
	RegConsoleCmd("sm_ff2_hp", Command_GetHPCmd);
	RegConsoleCmd("sm_ff2hp", Command_GetHPCmd);
	
	RegConsoleCmd("sm_setboss", SetBossMenu, "sets your boss");
	RegConsoleCmd("sm_sethale", SetBossMenu, "sets your boss");
	RegConsoleCmd("sm_ff2boss", SetBossMenu, "sets your boss");
	RegConsoleCmd("sm_haleboss", SetBossMenu, "sets your boss");
	
	RegConsoleCmd("sm_halemusic", MusicTogglePanelCmd);
	RegConsoleCmd("sm_hale_music", MusicTogglePanelCmd);
	RegConsoleCmd("sm_bossmusic", MusicTogglePanelCmd);
	RegConsoleCmd("sm_boss_music", MusicTogglePanelCmd);
	RegConsoleCmd("sm_ff2music", MusicTogglePanelCmd);
	RegConsoleCmd("sm_ff2_music", MusicTogglePanelCmd);
	
	RegConsoleCmd("sm_halehelp", HelpPanelCmd);
	RegConsoleCmd("sm_hale_help", HelpPanelCmd);
	RegConsoleCmd("sm_bosshelp", HelpPanelCmd);
	RegConsoleCmd("sm_boss_help", HelpPanelCmd);
	RegConsoleCmd("sm_ff2help", HelpPanelCmd);
	RegConsoleCmd("sm_ff2_help", HelpPanelCmd);
	
	RegAdminCmd("sm_reloadbosscfg", CmdReloadCFG, ADMFLAG_GENERIC);
	RegAdminCmd("sm_hale_select", CommandBossSelect, ADMFLAG_VOTE, "hale_select <target> - Select a player to be next boss");
	RegAdminCmd("sm_ff2_select", CommandBossSelect, ADMFLAG_VOTE, "ff2_select <target> - Select a player to be next boss");
	RegAdminCmd("sm_boss_select", CommandBossSelect, ADMFLAG_VOTE, "boss_select <target> - Select a player to be next boss");
	RegAdminCmd("sm_healthbarcolor", ChangeHealthBarColor, ADMFLAG_GENERIC);
	
	RegAdminCmd("sm_hale_force", ForceBossRealtime, ADMFLAG_VOTE, "hale_select <target> - Select a player to be next boss");
	RegAdminCmd("sm_boss_force", ForceBossRealtime, ADMFLAG_VOTE, "hale_select <target> - Select a player to be next boss");
	RegAdminCmd("sm_ff2_force", ForceBossRealtime, ADMFLAG_VOTE, "hale_select <target> - Select a player to be next boss");
	
	AddCommandListener(BlockSuicide, "explode");
	AddCommandListener(BlockSuicide, "kill");
	AddCommandListener(BlockSuicide, "jointeam");

	hHudText = CreateHudSynchronizer();
	jumpHUD = CreateHudSynchronizer();
	rageHUD = CreateHudSynchronizer();
	timeleftHUD = CreateHudSynchronizer();

	bEnabled = CreateConVar("vsh2_enabled", "1", "Enable VSH 2 plugin", FCVAR_NONE, true, 0.0, true, 1.0);
	cvarVSH2[PointType] = CreateConVar("vsh2_point_type", "0", "Select condition to enable point (0 - alive players, 1 - time)", FCVAR_NONE, true, 0.0, true, 1.0);
	cvarVSH2[PointDelay] = CreateConVar("vsh2_point_delay", "6", "Addition (for each player) delay before point's activation.", FCVAR_NONE);
	cvarVSH2[AliveToEnable] = CreateConVar("vsh2_point_alive", "5", "Enable control points when there are X people left alive.", FCVAR_NONE, true, 1.0, true, 32.0);
	cvarVSH2[FirstRound] = CreateConVar("vsh2_firstround", "0", "if 1, allows the first round to start with VSH2 enabled", FCVAR_NONE, true, 0.0, true, 1.0);
	cvarVSH2[DamagePoints] = CreateConVar("vsh2_damage_points", "600", "amount of damage needed to gain 1 point score", FCVAR_NONE);
	cvarVSH2[DamageForQueue] = CreateConVar("vsh2_damage_queue", "1", "allow damage to influence increase of queue points", FCVAR_NONE, true, 0.0, true, 1.0);
	cvarVSH2[QueueGained] = CreateConVar("vsh2_queue_gain", "10", "how much queue to give at end of round", FCVAR_NONE, true, 0.0, true, 9999.0);
	cvarVSH2[EnableMusic] = CreateConVar("vsh2_enable_music", "1", "enable or disable background music", FCVAR_NONE, true, 0.0, true, 1.0);
	cvarVSH2[MusicVolume] = CreateConVar("vsh2_music_volume", "0.5", "how loud the music should be", FCVAR_NONE, true, 0.0, true, 20.0);
	cvarVSH2[HealthPercentForLastGuy] = CreateConVar("vsh2_health_percentage_last_guy", "51", "if the health bar is lower than x out of 255, the last player timer will stop", FCVAR_NONE, true, 0.0, true, 255.0);
	cvarVSH2[HealthRegenForPlayers] = CreateConVar("vsh2_health_regen", "0", "allow non-boss and non-minion players to have health regen", FCVAR_NONE, true, 0.0, true, 1.0);
	cvarVSH2[HealthRegenAmount] = CreateConVar("vsh2_health_regen_amount", "2.0", "if health regen is allowed, how much health regen should players get?", FCVAR_NONE);
	cvarVSH2[MedigunReset] = CreateConVar("vsh2_medigun_reset_amount", "0.31", "how much uber percentage should mediguns, after uber, reset to?", FCVAR_NONE, true, 0.0, true, 1.0);
	cvarVSH2[StopTickleTime] = CreateConVar("vsh2_stop_tickle_time", "3.0", "how much time for the ticklefists tickle to be removed from boss", FCVAR_NONE);
	cvarVSH2[AirStrikeDamage] = CreateConVar("vsh2_airstrike_damage", "200", "how much damage using the airstrike needed to gain clipsize", FCVAR_NONE);
	cvarVSH2[AirblastRage] = CreateConVar("vsh2_airblast_rage", "8.0", "how much rage should airblast give/remove? (negative number to remove rage)", FCVAR_NONE, true, 0.0, true, 100.0);
	cvarVSH2[JarateRage] = CreateConVar("vsh2_jarate_rage", "8.0", "how much rage should jarate give/remove? (negative number to add rage)", FCVAR_NONE, true, 0.0, true, 100.0);
	cvarVSH2[FanoWarRage] = CreateConVar("vsh2_fanowar_rage", "5.0", "how much rage should the fanowar give/remove? (negative number to add rage)", FCVAR_NONE);
	cvarVSH2[LastPlayerTime] = CreateConVar("vsh2_lastplayer_time", "180", "how many seconds to give the last player to fight the Boss(es) until said seconds are over", FCVAR_NONE);
	cvarVSH2[EngieBuildings] = CreateConVar("vsh2_killbuilding_engiedeath", "0", "if 0, no building dies when engie dies. If 1, only sentry dies. If 2, all buildings die.", FCVAR_NONE, true, 0.0, true, 2.0);
	cvarVSH2[MedievalLives] = CreateConVar("vsh2_medievalmode_lives", "3", "amount of lives red players are entitled during Medieval Mode", FCVAR_NONE, true, 0.0, true, 99.0);
	cvarVSH2[MedievalRespawnTime] = CreateConVar("vsh2_medievalmode_respawntime", "5.0", "how long it takes for players to respawn after dying in medieval mode", FCVAR_NONE, true, 1.0, true, 999.0);
	cvarVSH2[PermOverheal] = CreateConVar("vsh2_permanent_overheal", "1", "set if Mediguns give permanent overheal", FCVAR_NONE, true, 0.0, true, 1.0);
	cvarVSH2[MultiCapture] = CreateConVar("vsh2_multiple_cp_captures", "0", "if enabled, allow control points to be captured more than once instead of ending the round.", FCVAR_NONE, true, 0.0, true, 1.0);
	cvarVSH2[MultiCapAmount] = CreateConVar("vsh2_multiple_cp_capture_amount", "3", "if vsh2_allow_multiple_cp_captures is enabled, how many times must a team capture a Control Point to win", FCVAR_NONE, true, 1.0, true, 999.0);
	cvarVSH2[DemoShieldCrits] = CreateConVar("vsh2_demoman_shield_crits", "3", "Sets Demoman Shield crit behaviour. 0 - No crits, 1 - Mini-crits, 2 - Crits, 3 - Scale with Charge Meter (Losing the Shield results in no more (mini)crits.)", FCVAR_NONE, true, 0.0, true, 3.0);
	cvarVSH2[MultiBossHandicap] = CreateConVar("vsh2_multiboss_handicap", "500", "How much Health is removed on every individual boss in a multiboss round at the start of said round. 0 disables it.", FCVAR_NONE, true, 0.0, true, 99999.0);
	
#if defined _steamtools_included
	gamemode.bSteam = LibraryExists("SteamTools");
#endif
#if defined _tf2attributes_included
	gamemode.bTF2Attribs = LibraryExists("tf2attributes");
#endif
	AutoExecConfig(true, "VSHv2");
	HookEvent("player_death", PlayerDeath, EventHookMode_Pre);
	HookEvent("player_hurt", PlayerHurt, EventHookMode_Pre);
	HookEvent("teamplay_round_start", RoundStart);
	HookEvent("teamplay_round_win", RoundEnd);
	HookEvent("player_spawn", ReSpawn);
	HookEvent("post_inventory_application", Resupply);
	HookEvent("object_deflected", ObjectDeflected);
	HookEvent("object_destroyed", ObjectDestroyed, EventHookMode_Pre);
	HookEvent("player_jarated", PlayerJarated);
	//HookEvent("player_changeclass", ChangeClass);
	HookEvent("rocket_jump", OnHookedEvent);
	HookEvent("rocket_jump_landed", OnHookedEvent);
	HookEvent("sticky_jump", OnHookedEvent);
	HookEvent("sticky_jump_landed", OnHookedEvent);
	HookEvent("item_pickup", ItemPickedUp);
	HookEvent("player_chargedeployed", UberDeployed);
	HookEvent("arena_round_start", ArenaRoundStart);
	HookEvent("teamplay_point_captured", PointCapture, EventHookMode_Post);
	
	AddCommandListener(DoTaunt, "+taunt");
	AddCommandListener(cdVoiceMenu, "voicemenu");
	AddNormalSoundHook(HookSound);
	
	PointCookie = RegClientCookie("vsh2_queuepoints", "Amount of VSH2 Queue points player has", CookieAccess_Protected);
	BossCookie = RegClientCookie("vsh2_presetbosses", "Preset bosses for VSH2 players", CookieAccess_Protected);
	MusicCookie = RegClientCookie("vsh2_music_settings", "HaleMusic setting", CookieAccess_Public);

	ManageDownloads(); // in handler.sp

	for (int i=MaxClients ; i ; --i) {
		if ( not IsValidClient(i) )
			continue;
		OnClientPutInServer(i);
	}
	
	AddMultiTargetFilter("@boss", HaleTargetFilter, "the current Boss/Bosses", false);
	AddMultiTargetFilter("@hale", HaleTargetFilter, "the current Boss/Bosses", false);
	AddMultiTargetFilter("@minion", MinionTargetFilter, "the Minions", false);
	AddMultiTargetFilter("@minions", MinionTargetFilter, "the Minions", false);
	AddMultiTargetFilter("@!boss", HaleTargetFilter, "all non-Boss players", false);
	AddMultiTargetFilter("@!hale", HaleTargetFilter, "all non-Boss players", false);
	hPlayerFields[0] = new StringMap();	// This will be freed when plugin is unloaded again
	g_hPluginsRegistered = new ArrayList();
}
public bool HaleTargetFilter(const char[] pattern, Handle clients)
{
	bool non = StrContains(pattern, "!", false) not_eq -1;
	for (int i=MaxClients ; i ; i--) {
		if (IsClientValid(i) and FindValueInArray(clients, i) is -1)
        	{
			if (bEnabled.BoolValue and BaseBoss(i).bIsBoss) {
				if (!non)
					PushArrayCell(clients, i);
			}
			else if (non)
				PushArrayCell(clients, i);
		}
	}
	return true;
}
public bool MinionTargetFilter(const char[] pattern, Handle clients)
{
	bool non = StrContains(pattern, "!", false) not_eq -1;
	for (int i=MaxClients ; i ; i--) {
		if (IsClientValid(i) and FindValueInArray(clients, i) is -1)
        	{
			if (bEnabled.BoolValue and BaseBoss(i).bIsMinion) {
				if (!non)
					PushArrayCell(clients, i);
			}
			else if (non)
				PushArrayCell(clients, i);
		}
	}
	return true;
}

public Action BlockSuicide(int client, const char[] command, int argc)
{
	if (bEnabled.BoolValue and gamemode.iRoundState == StateRunning)
	{
		BaseBoss player = BaseBoss(client);
		if (player.bIsBoss) {
			float flhp_percent = float(player.iHealth) / float(player.iMaxHealth);
			if (flhp_percent > 0.15) {	// Allow bosses to suicide if their health is under 15%.
				CPrintToChat(client, "Do not suicide as a Boss. Please Use '!resetq' instead.");
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;
}

public void OnLibraryAdded(const char[] name)
{
#if defined _steamtools_included
	if (not strcmp(name, "SteamTools", false))
		gamemode.bSteam = true;
#endif
#if defined _tf2attributes_included
	if (not strcmp(name, "tf2attributes", false))
		gamemode.bTF2Attribs = true;
#endif
}
public void OnLibraryRemoved(const char[] name)
{
#if defined _steamtools_included
	if (not strcmp(name, "SteamTools", false))
		gamemode.bSteam = false;
#endif
#if defined _tf2attributes_included
	if (not strcmp(name, "tf2attributes", false))
		gamemode.bTF2Attribs = false;
#endif
}

int
	tf_arena_use_queue,
	mp_teams_unbalance_limit,
	tf_arena_first_blood,
	mp_forcecamera
;

float
	tf_scout_hype_pep_max
;

public void OnConfigsExecuted()
{
	if ( IsVSHMap() ) {
		tf_arena_use_queue = GetConVarInt(FindConVar("tf_arena_use_queue"));
		mp_teams_unbalance_limit = GetConVarInt(FindConVar("mp_teams_unbalance_limit"));
		tf_arena_first_blood = GetConVarInt(FindConVar("tf_arena_first_blood"));
		mp_forcecamera = GetConVarInt(FindConVar("mp_forcecamera"));
		tf_scout_hype_pep_max = GetConVarFloat(FindConVar("tf_scout_hype_pep_max"));
		SetConVarInt(FindConVar("tf_arena_use_queue"), 0);
		SetConVarInt(FindConVar("mp_teams_unbalance_limit"), 0);
		SetConVarInt(FindConVar("mp_teams_unbalance_limit"), cvarVSH2[FirstRound].BoolValue ? 0 : 1);
		SetConVarInt(FindConVar("tf_arena_first_blood"), 0);
		SetConVarInt(FindConVar("mp_forcecamera"), 0);
		SetConVarFloat(FindConVar("tf_scout_hype_pep_max"), 100.0);
		//SetConVarInt(FindConVar("tf_damage_disablespread"), 1);
#if defined _steamtools_included
		if (gamemode.bSteam) {
			char gameDesc[64];
			Format(gameDesc, sizeof(gameDesc), "%s (v%s)", PLUGIN_DESCRIPT, PLUGIN_VERSION);
			Steam_SetGameDescription(gameDesc);
		}
#endif
	}
}
public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_TraceAttack, TraceAttack);
	SDKHook(client, SDKHook_Touch, OnTouch);
	SDKHook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitchPost);
	
	flHolstered[client][0] = flHolstered[client][1] = flHolstered[client][2] = 0.0;
	//SDKHook(client, SDKHook_PreThink, OnPreThink);
	
	if (hPlayerFields[client] != null)
		delete hPlayerFields[client] ;
	
	hPlayerFields[client] = new StringMap();
	BaseBoss boss = BaseBoss(client);
	
	// BaseFighter properties
	hPlayerFields[client].SetValue("iQueue", 0);
	hPlayerFields[client].SetValue("iPresetType", -1);
	boss.iKills = 0;
	boss.iHits = 0;
	boss.iLives = 0;
	boss.iState = -1;
	boss.iDamage = 0;
	boss.iAirDamage = 0;
	boss.iSongPick = 0;
	boss.iOwnerBoss = 0;
	boss.iUberTarget = 0;
	boss.bIsMinion = false;
	boss.bInJump = false;
	boss.flGlowtime = 0.0;
	boss.flLastHit = 0.0;
	boss.flLastShot = 0.0;
	
	// BaseBoss properties
	boss.iHealth = 0;
	boss.iMaxHealth = 0;
	boss.iType = -1;
	boss.iClimbs = 0;
	boss.iStabbed = 0;
	boss.iMarketted = 0;
	boss.iDifficulty = -1;
	boss.bIsBoss = false;
	boss.bSetOnSpawn = false;
	boss.bUsedUltimate = false;
	boss.flSpeed = 0.0;
	boss.flCharge = 0.0;
	boss.flRAGE = 0.0;
	boss.flKillSpree = 0.0;
	boss.flWeighDown = 0.0;
}
public void OnClientDisconnect(int client)
{
	ManageDisconnect(client);
}
public void OnClientPostAdminCheck(int client)
{
	CPrintToChat(client, "{olive}[VSH 2]{default} Welcome to VSH2, type /bosshelp for help!");
}

public Action OnTouch(int client, int other)
{
	if (0 < other <= MaxClients) {
		BaseBoss player = BaseBoss(client);
		BaseBoss victim = BaseBoss(other);

		if ( player.bIsBoss and not victim.bIsBoss )
			ManageOnTouchPlayer(player, victim); // in handler.sp
	}
	else if (other > MaxClients) {
		BaseBoss player = BaseBoss(client);
		if (IsValidEntity(other) and player.bIsBoss)
		{
			char ent[5];
			if (GetEntityClassname(other, ent, sizeof(ent)), not StrContains(ent, "obj_") )
			{
				if (GetEntProp(other, Prop_Send, "m_iTeamNum") not_eq GetClientTeam(client))
					ManageOnTouchBuilding(player, other); // in handler.sp
			}
		}
	}
	return Plugin_Continue;
}

public void OnMapStart()
{
	ManageDownloads();	// in handler.sp
	//gamemode.hMusic = null;
	CreateTimer(0.1, Timer_PlayerThink, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(5.0, MakeModelTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	gamemode.iHealthBar = FindEntityByClassname(-1, "monster_resource");
	if (gamemode.iHealthBar is -1) {
		gamemode.iHealthBar = CreateEntityByName("monster_resource");
		if (gamemode.iHealthBar not_eq -1)
			DispatchSpawn(gamemode.iHealthBar);
	}
	gamemode.iRoundCount = 0;
}
public void OnMapEnd()
{
	SetConVarInt(FindConVar("tf_arena_use_queue"), tf_arena_use_queue);
	SetConVarInt(FindConVar("mp_teams_unbalance_limit"), mp_teams_unbalance_limit);
	SetConVarInt(FindConVar("tf_arena_first_blood"), tf_arena_first_blood);
	SetConVarInt(FindConVar("mp_forcecamera"), mp_forcecamera);
	SetConVarFloat(FindConVar("tf_scout_hype_pep_max"), tf_scout_hype_pep_max);
}

public void _MakePlayerBoss(const int userid)
{
	int client = GetClientOfUserId(userid);
	if ( client and IsClientInGame(client) ) {
		BaseBoss player = BaseBoss(client);
		ManageBossTransition(player);	// in handler.sp; sets health, model, and equips the boss
	}
}
public void _MakePlayerMinion(const int userid)
{
	int client = GetClientOfUserId(userid);
	if ( client and IsClientInGame(client) ) {
		BaseBoss player = BaseBoss(client);
		ManageMinionTransition(player);	// in handler.sp; sets health, model, and equips the boss
	}
}

public void _BossDeath(const int userid)
{
	int client = GetClientOfUserId(userid);
	if ( IsValidClient(client, false) ) {
		BaseBoss player = BaseBoss(client);
		if (player.iHealth <= 0)
			player.iHealth = 0; //ded, not big soup rice!

		ManageBossDeath(player); // in handler.sp
	}
}
public Action MakeModelTimer(Handle hTimer)
{
	BaseBoss player;
	for (int i=MaxClients ; i ; --i) {
		if ( not IsValidClient(i, false) )
			continue;

		player = BaseBoss(i);
		if (player.bIsBoss) {
			if ( not IsPlayerAlive(i) )
				continue;
			ManageBossModels(player); // in handler.sp
		}
	}
	return Plugin_Continue;
}
public void SetGravityNormal(const int userid)
{
	int i = GetClientOfUserId(userid);
	if ( IsValidClient(i) )
		SetEntityGravity(i, 1.0);
}
public Action Timer_PlayerThink(Handle hTimer) //the main 'mechanics' of bosses
{
	if (not bEnabled.BoolValue or gamemode.iRoundState != StateRunning)
		return Plugin_Continue;

	gamemode.UpdateBossHealth();
	if ( gamemode.flMusicTime <= GetGameTime() )
		_MusicPlay();

	BaseBoss player;
	for (int i=MaxClients ; i ; --i) {
		if ( not IsValidClient(i, false) )
			continue;

		player = BaseBoss(i);
		if (player.bIsBoss) {	/* If player is a boss, force Boss think on them; if not boss or on blue team, force fighter think! */
			ManageBossThink(player); // in handler.sp
			SetEntityHealth(i, player.iHealth);
			if (player.iHealth <= 0)	// BUG PATCH: Bosses are not being 100% dead when the iHealth is at 0...
				SDKHooks_TakeDamage(player.index, 0, 0, 100.0, DMG_DIRECT, _, _, _); //ForcePlayerSuicide(i);
		}
		else ManageFighterThink(player);
	}
	if ( !gamemode.CountBosses(true) )	// If there's no active, living bosses, then force RED to win
		ForceTeamWin(RED);

	return Plugin_Continue;
}

/*
float lastFrameTime = 0.0;
public void OnGameFrame()
{
	if ( not bEnabled.BoolValue )
		return;

	float curtime = GetGameTime();
	float deltatime = curtime - lastFrameTime;
	//float frametime = 1.0 / CODEFRAMES; //cvarFrameTime.FloatValue;
	if ( deltatime > CODEFRAMES ) {
		BaseBoss player;
		for (int i=MaxClients ; i ; --i) {
			if ( not IsValidClient(i, false) or not IsPlayerAlive(i) or IsClientObserver(i) )
				continue;
			player = BaseBoss(i);
			if (player.bIsBoss) {
				ManageBossThink(player); // in handler.sp
				PrintToConsole(i, "Think Frame| curtime = %f, lastFrameTime = %f, deltatime = %f", curtime, lastFrameTime, deltatime);
				SetEntProp(player.index, Prop_Send, "m_iHealth", player.iHealth);
			}
		}
		lastFrameTime = curtime;
	}
}
*/

public Action CmdReloadCFG(int client, int args)
{
	ServerCommand("sm_rcon exec sourcemod/VSHv2.cfg");
	ReplyToCommand(client, "**** Reloading VSH 2 ConVar Config ****");
	return Plugin_Handled;
}

/*
public void OnPreThink(int client) //powers the HUD and riding mechanics
{
	if ( not bEnabled.BoolValue )
		return;
	if ( IsClientObserver(client) or !IsPlayerAlive(client) )
		return;

	BaseBoss player = BaseBoss(client);
	if (player.bIsBoss) {

	}
	return;
}
*/

public Action TraceAttack(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup)
{
	if ( not bEnabled.BoolValue )
		return Plugin_Continue;

	if ( IsClientValid(attacker) and IsClientValid(victim) ) {
		BaseBoss player = BaseBoss(victim);
		BaseBoss enemy = BaseBoss(attacker);
		ManageTraceHit(player, enemy, inflictor, damage, damagetype, ammotype, hitbox, hitgroup); // in handler.sp
	}
	return Plugin_Continue;
}
public Action OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if ( not bEnabled.BoolValue or not IsClientValid(victim) )
		return Plugin_Continue;

	BaseBoss BossVictim = BaseBoss(victim);
	int bFallDamage = (damagetype & DMG_FALL);
	if (BossVictim.bIsBoss and attacker <= 0 and bFallDamage) {
		damage = (BossVictim.iHealth > 100) ? 1.0 : 30.0;
		return Plugin_Changed;
	}
	
	if (BossVictim.bIsBoss) // in handler.sp
		return ManageOnBossTakeDamage(BossVictim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

	if (!IsClientValid(attacker))	// BUG PATCH: Client index 0 is invalid
		return Plugin_Continue;
	
	BaseBoss BossAttacker = BaseBoss(attacker);
	if (BossAttacker.bIsBoss) // in handler.sp
		return ManageOnBossDealDamage(BossVictim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

	return Plugin_Continue;
}
public Action RemoveEnt(Handle timer, any entid)
{
	int ent = EntRefToEntIndex(entid);
	if ( ent > 0 and IsValidEntity(ent) )
		AcceptEntityInput(ent, "Kill");
	return Plugin_Continue;
}
public Action cdVoiceMenu(int client, const char[] command, int argc)
{
	if ( not bEnabled.BoolValue )
		return Plugin_Continue;
	if (argc < 2 or not IsPlayerAlive(client))
		return Plugin_Handled;

	char szCmd1[8]; GetCmdArg(1, szCmd1, sizeof(szCmd1));
	char szCmd2[8]; GetCmdArg(2, szCmd2, sizeof(szCmd2));

	// Capture call for medic commands (represented by "voicemenu 0 0")
	BaseBoss boss = BaseBoss(client);
	if ( szCmd1[0] is '0' and szCmd2[0] is '0' and boss.bIsBoss )
		ManageBossMedicCall(boss);

	return Plugin_Continue;
}
public Action DoTaunt(int client, const char[] command, int argc)
{
	if (not bEnabled.BoolValue)
		return Plugin_Continue;

	BaseBoss boss = BaseBoss(client);
	if ( boss.flRAGE >= 100.0 ) {
		ManageBossTaunt(boss);
		boss.flRAGE = 0.0;
	}
	return Plugin_Continue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if ( not bEnabled.BoolValue )
		return;

	ManageEntityCreated(entity, classname);

	if ( not strncmp(classname, "tf_weapon_", 10, false) and IsValidEntity(entity) )
		CreateTimer( 0.6, OnWeaponSpawned, EntIndexToEntRef(entity) );

}
public Action OnWeaponSpawned(Handle timer, any ref)
{
	int wep = EntRefToEntIndex(ref);
	if ( IsValidEntity(wep) and IsValidEdict(wep) )
	{
		char name[32]; GetEntityClassname(wep, name, sizeof(name));
		if ( not strncmp(name, "tf_weapon_", 10, false) )
		{
			int client = GetOwner(wep);
			if ( IsValidClient(client) and GetClientTeam(client) is RED) {
				int slot = GetSlotFromWeapon(client, wep);
				if (slot not_eq -1 and slot < 3)
					flHolstered[client][slot] = GetGameTime();

				AmmoTable[wep] = GetWeaponAmmo(wep);
				ClipTable[wep] = GetWeaponClip(wep);
			}
		}
	}
	return Plugin_Continue;
}
public void OnWeaponSwitchPost(int client, int weapon)
{
	static int iActiveSlot[PLYR];
	if ( (client > 0 && client <= MaxClients) && IsValidEntity(weapon) )
	{
		switch (iActiveSlot[client]) // This will be the previous slot at this time, that you switched FROM
		{
			case 0, 1: flHolstered[client][iActiveSlot[client]] = GetGameTime();
		}
		iActiveSlot[client] = GetSlotFromWeapon(client, weapon);
	}
}
public void ShowPlayerScores()	// scores kept glitching out and I hate debugging so I made it its own func.
{
	BaseBoss hTop[3];
	
	BaseBoss(0).iDamage = 0;
	BaseBoss player;
	for (int i=MaxClients ; i ; --i) {
		if (!IsClientValid(i))
			continue;
		
		player = BaseBoss(i);
		if (player.bIsBoss) {
			player.iDamage = 0;
			continue;
		}
		
		if (player.iDamage >= hTop[0].iDamage /*Damage[top[0]]*/) {
			hTop[2] = hTop[1];
			hTop[1] = hTop[0];
			hTop[0] = BaseBoss(i);
		}
		else if (player.iDamage >= hTop[1].iDamage /*Damage[top[1]]*/) {
			hTop[2] = hTop[1];
			hTop[1] = BaseBoss(i);
		}
		else if (player.iDamage >= hTop[2].iDamage /*Damage[top[2]]*/)
			hTop[2] = BaseBoss(i);
	}
	if (hTop[0].iDamage > 9000) //if (Damage[top[0]] > 9000)
		SetPawnTimer(OverNineThousand, 1.0);	// in stocks.inc

	char score1[PATH], score2[PATH], score3[PATH];
	if (IsValidClient(hTop[0].index) and (GetClientTeam(hTop[0].index) > 1))
		GetClientName(hTop[0].index, score1, PATH);
	else {
		Format(score1, PATH, "---");
		hTop[0] = view_as< BaseBoss >(0);
	}

	if (IsValidClient(hTop[1].index) and (GetClientTeam(hTop[1].index) > 1))
		GetClientName(hTop[1].index, score2, PATH);
	else {
		Format(score2, PATH, "---");
		hTop[1] = view_as< BaseBoss >(0);
	}

	if (IsValidClient(hTop[2].index) and (GetClientTeam(hTop[2].index) > 1))
		GetClientName(hTop[2].index, score3, PATH);
	else {
		Format(score3, PATH, "---");
		hTop[2] = view_as< BaseBoss >(0);
	}
	SetHudTextParams(-1.0, 0.4, 10.0, 255, 255, 255, 255);
	PrintCenterTextAll("");	// Should clear center text
	
	for (int i=MaxClients ; i ; --i) {
		if (!IsClientValid(i))
			continue;
		if (not (GetClientButtons(i) & IN_SCORE)) {
			player = BaseBoss(i);
			SetGlobalTransTarget(i);
			ShowHudText(i, -1, "Most damage dealt by:\n1)%i - %s\n2)%i - %s\n3)%i - %s\n\nDamage Dealt: %i\nScore for this round: %i", hTop[0].iDamage, score1, hTop[1].iDamage, score2, hTop[2].iDamage, score3, player.iDamage, (player.iDamage/600));
			//PrintToConsole(i, "did damage dealth stuff.");
		}
	}
}
public void CalcScores()
{
	int j, damage, amount, queue;
	BaseBoss player;
	Event scoring = CreateEvent("player_escort_score", true);
	for (int i=MaxClients ; i ; --i) {
		if (not IsClientValid(i))
			continue;
		else if (GetClientTeam(i) < RED)
			continue;
		
		player = BaseBoss(i);
		if ( player.bIsBoss )
			player.iQueue = 0;
		else {
			if (cvarVSH2[DamageForQueue].BoolValue)
				queue = cvarVSH2[QueueGained].IntValue+(player.iDamage/1000);
			else queue = cvarVSH2[QueueGained].IntValue;
			player.iQueue += queue; //(i, GetClientQueuePoints(i)+queue);
			CPrintToChat(i, "{olive}[VSH 2] Queue{default} You gained %i queue points.", queue);
			
			// We don't want the Bosses getting free points for doing damage.
			damage = player.iDamage;
			scoring.SetInt("player", i);
			amount = cvarVSH2[DamagePoints].IntValue;
			for (j=0 ; damage-amount > 0 ; damage -= amount, j++) {}
			scoring.SetInt("points", j);
			scoring.FireToClient(i);
			CPrintToChat(i, "{olive}[VSH 2] Queue{default} You scored %i points.", j);
		}
		//PrintToConsole(i, "CalcScores running.");
	}
	delete scoring;
}
public Action Timer_DrawGame(Handle timer)
{
	if (gamemode.iHealthBarPercent < cvarVSH2[HealthPercentForLastGuy].IntValue or gamemode.iRoundState not_eq StateRunning)
		return Plugin_Stop;

	int time = gamemode.iTimeLeft;
	gamemode.iTimeLeft--;
	char strTime[6];

	if (time/60 > 9)
		IntToString(time/60, strTime, 6);
	else Format(strTime, 6, "0%i", time/60);

	if (time%60 > 9)
		Format(strTime, 6, "%s:%i", strTime, time%60);
	else Format(strTime, 6, "%s:0%i" , strTime, time%60);

	SetHudTextParams(-1.0, 0.17, 1.1, 255, 255, 255, 255);
	for (int i=MaxClients ; i ; --i) {
		if ( not IsValidClient(i) or not IsClientConnected(i) )
			continue;
		ShowSyncHudText(i, timeleftHUD, strTime);
	}
	switch ( time ) {
		case 60: EmitSoundToAll("vo/announcer_ends_60sec.mp3");
		case 30: EmitSoundToAll("vo/announcer_ends_30sec.mp3");
		case 10: EmitSoundToAll("vo/announcer_ends_10sec.mp3");
		case 1, 2, 3, 4, 5: {
			char sound[FULLPATH];
			Format(sound, FULLPATH, "vo/announcer_ends_%isec.mp3", time);
			EmitSoundToAll(sound);
		}
		case 0:  //Thx MasterOfTheXP
		{
			ForceTeamWin(BLU);
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}
public void _ResetMediCharge(const int entid)
{
	int medigun = EntRefToEntIndex(entid); 
	if (medigun > MaxClients and IsValidEntity(medigun))
		SetMediCharge(medigun, GetMediCharge(medigun)+cvarVSH2[MedigunReset].FloatValue);
}
public Action TimerLazor(Handle timer, any medigunid)
{
	int medigun = EntRefToEntIndex(medigunid);
	if (medigun and IsValidEntity(medigun) and gamemode.iRoundState is StateRunning)
	{
		int client = GetOwner(medigun);
		float charge = GetMediCharge(medigun);
		if (charge > 0.05) {
			TF2_AddCondition(client, TFCond_CritOnWin, 0.5);

			int target = GetHealingTarget(client);
			if (IsClientValid(target) and IsPlayerAlive(target))
			{
				TF2_AddCondition(target, TFCond_CritOnWin, 0.5);
				BaseBoss(client).iUberTarget = GetClientUserId(target);
			}
			else BaseBoss(client).iUberTarget = 0;
		}
		else if (charge < 0.05) {
			SetPawnTimer(_ResetMediCharge, 3.0, EntIndexToEntRef(medigun)); //CreateTimer(3.0, TimerLazor2, EntIndexToEntRef(medigun));
			return Plugin_Stop;
		}
	}
	else return Plugin_Stop;
	return Plugin_Continue;
}
public void _MusicPlay()
{
	if ( not bEnabled.BoolValue or gamemode.iRoundState not_eq StateRunning)
		return;

	float currtime = GetGameTime();
	if (!cvarVSH2[EnableMusic].BoolValue or gamemode.flMusicTime > currtime)
		return;

	/*if (gamemode.hMusic != null) {
		KillTimer(gamemode.hMusic);
		gamemode.hMusic = null;
	}*/
	char sound[FULLPATH] = "";
	float time = -1.0;

	ManageMusic(sound, time);	// in handler.sp

	BaseBoss boss;
	float vol = cvarVSH2[MusicVolume].FloatValue;
	if (sound[0] not_eq '\0') {
		strcopy(BackgroundSong, FULLPATH, sound);
		//Format(sound, FULLPATH, "#%s", sound);
		for (int i=MaxClients ; i ; --i) {
			if (!IsClientValid(i))
				continue;
			boss = BaseBoss(i);
			if (boss.bNoMusic)
				continue;
			EmitSoundToClient(i, sound, _, _, SNDLEVEL_NORMAL, SND_NOFLAGS, vol, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
			//ClientCommand(i, "playgamesound \"%s\"", sound);
		}
	}
	if (time not_eq -1.0) {
		gamemode.flMusicTime = currtime+time;
		//DataPack pack = new DataPack();
		//pack.WriteString(sound);
		//pack.WriteFloat(time);
		//int timerFlags = TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT|TIMER_DATA_HNDL_CLOSE;
		//gamemode.hMusic = CreateTimer(time, Timer_MusicTheme, pack, timerFlags);
	}
}

/*public Action Timer_MusicTheme(Handle timer, DataPack pack)
{
	if (bEnabled.BoolValue and gamemode.iRoundState is StateRunning)
	{
		char music[FULLPATH];
		pack.Reset();
		pack.ReadString(music, sizeof(music));
		//float time = pack.ReadFloat();
		BaseBoss boss;
		float vol = cvarVSH2[MusicVolume].FloatValue;
		if (music[0] not_eq '\0') {
			for (int i=MaxClients ; i ; --i) {
				if (!IsValidClient(i))
					continue;
				boss = BaseBoss(i);
				if (boss.bNoMusic)
					continue;
				EmitSoundToClient(i, music, _, _, SNDLEVEL_NORMAL, SND_NOFLAGS, vol, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
			}
		}
	}
	//else gamemode.hMusic = null;
	return Plugin_Continue;
}*/


stock Handle FindPluginByName(const char name[64])	// searches in linear time or O(n) but it only searches when vsh plugin's loaded
{
	char dictVal[64];
	Handle thisPlugin;
	StringMap pluginMap;
	int arraylen = g_hPluginsRegistered.Length;
	for (int i=0 ; i<arraylen ; ++i) {
		pluginMap = g_hPluginsRegistered.Get(i);
		if ( pluginMap.GetString("PluginName", dictVal, 64) )
		{
			if ( !strcmp(name, dictVal, false) ) {
				pluginMap.GetValue("PluginHandle", thisPlugin);
				return thisPlugin;
			}
		}
	}
	return null;
}

stock Handle GetPluginByIndex(const int index)
{
	Handle thisPlugin;
	StringMap pluginMap = g_hPluginsRegistered.Get(index);
	if ( pluginMap.GetValue("PluginHandle", thisPlugin) )
		return thisPlugin;
	return null;
}

public int RegisterPlugin(const Handle pluginhndl, const char modulename[64] )
{
	if (!ValidateName(modulename)) {
		LogError("VSH2 :: Register Plugin  **** Invalid Name For Plugin Registration ****");
		return -1;
	}
	else if (FindPluginByName(modulename) != null) {
		LogError("VSH2 :: Register Plugin  **** Plugin Already Registered ****");
		return -1;
	}
	
	// create dictionary to hold necessary data about plugin
	StringMap PluginMap = new StringMap();
	PluginMap.SetValue("PluginHandle", pluginhndl);
	PluginMap.SetString("PluginName", modulename);

	// push to global vector
	g_hPluginsRegistered.Push(PluginMap);

	return g_hPluginsRegistered.Length-1;	// Return the index of registered plugin!
}


public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("VSH2_RegisterPlugin", Native_RegisterPlugin);
	CreateNative("VSH2Player.VSH2Player", Native_VSH2Instance);
	
	CreateNative("VSH2Player.userid.get", Native_VSH2GetUserid);
	CreateNative("VSH2Player.index.get", Native_VSH2GetIndex);
	
	CreateNative("VSH2Player.GetProperty", Native_VSH2_getProperty);
	CreateNative("VSH2Player.SetProperty", Native_VSH2_setProperty);
	
	/*CreateNative("VSH2Player.m_iQueue.get", Native_VSH2_getQueue);
	CreateNative("VSH2Player.m_iQueue.set", Native_VSH2_setQueue);
	
	CreateNative("VSH2Player.m_iPresetType.get", Native_VSH2_getPreset);
	CreateNative("VSH2Player.m_iPresetType.set", Native_VSH2_setPreset);
	
	CreateNative("VSH2Player.m_iKills.get", Native_VSH2_getKills);
	CreateNative("VSH2Player.m_iKills.set", Native_VSH2_setKills);
	
	CreateNative("VSH2Player.m_iHits.get", Native_VSH2_getHits);
	CreateNative("VSH2Player.m_iHits.set", Native_VSH2_setHits);
	
	CreateNative("VSH2Player.m_iLives.get", Native_VSH2_getLives);
	CreateNative("VSH2Player.m_iLives.set", Native_VSH2_setLives);
	
	CreateNative("VSH2Player.m_iState.get", Native_VSH2_getState);
	CreateNative("VSH2Player.m_iState.set", Native_VSH2_setState);
	
	CreateNative("VSH2Player.m_iDamage.get", Native_VSH2_getDamage);
	CreateNative("VSH2Player.m_iDamage.set", Native_VSH2_setDamage);
	
	CreateNative("VSH2Player.m_iAirDamage.get", Native_VSH2_getAirDamage);
	CreateNative("VSH2Player.m_iAirDamage.set", Native_VSH2_setAirDamage);
	
	CreateNative("VSH2Player.m_iSongPick.get", Native_VSH2_getSongPick);
	CreateNative("VSH2Player.m_iSongPick.set", Native_VSH2_setSongPick);
	
	CreateNative("VSH2Player.m_iHealTarget.get", Native_VSH2_getHealTarget);
	
	CreateNative("VSH2Player.m_iOwnerBoss.get", Native_VSH2_getOwnerBoss);
	CreateNative("VSH2Player.m_iOwnerBoss.set", Native_VSH2_setOwnerBoss);
	
	CreateNative("VSH2Player.m_iUberTarget.get", Native_VSH2_getUberTarget);
	CreateNative("VSH2Player.m_iUberTarget.set", Native_VSH2_setUberTarget);
	
	CreateNative("VSH2Player.m_iGlow.get", Native_VSH2_getGlow);
	CreateNative("VSH2Player.m_iGlow.set", Native_VSH2_setGlow);
	
	CreateNative("VSH2Player.m_bNearDispenser.get", Native_VSH2_getNearDispenser);
	
	CreateNative("VSH2Player.m_bIsMinion.get", Native_VSH2_getIsMinion);
	CreateNative("VSH2Player.m_bIsMinion.set", Native_VSH2_setIsMinion);
	
	CreateNative("VSH2Player.m_bInJump.get", Native_VSH2_getInJump);
	CreateNative("VSH2Player.m_bInJump.set", Native_VSH2_setInJump);
	
	CreateNative("VSH2Player.m_flGlowtime.get", Native_VSH2_getGlowtime);
	CreateNative("VSH2Player.m_flGlowtime.set", Native_VSH2_setGlowtime);
	
	CreateNative("VSH2Player.m_flLastHit.get", Native_VSH2_getLastHit);
	CreateNative("VSH2Player.m_flLastHit.set", Native_VSH2_setLastHit);
	
	CreateNative("VSH2Player.m_flLastShot.get", Native_VSH2_getLastShot);
	CreateNative("VSH2Player.m_flLastShot.set", Native_VSH2_setLastShot);
	
	CreateNative("VSH2Player.m_iHealth.get", Native_VSH2_getHealth);
	CreateNative("VSH2Player.m_iHealth.set", Native_VSH2_setHealth);
	
	CreateNative("VSH2Player.m_iMaxHealth.get", Native_VSH2_getMaxHealth);
	CreateNative("VSH2Player.m_iMaxHealth.set", Native_VSH2_setMaxHealth);
	
	CreateNative("VSH2Player.m_iType.get", Native_VSH2_getType);
	CreateNative("VSH2Player.m_iType.set", Native_VSH2_setType);
	
	CreateNative("VSH2Player.m_iClimbs.get", Native_VSH2_getClimbs);
	CreateNative("VSH2Player.m_iClimbs.set", Native_VSH2_setClimbs);
	
	CreateNative("VSH2Player.m_iStabbed.get", Native_VSH2_getStabbed);
	CreateNative("VSH2Player.m_iStabbed.set", Native_VSH2_setStabbed);
	
	CreateNative("VSH2Player.m_iMarketted.get", Native_VSH2_getMarketted);
	CreateNative("VSH2Player.m_iMarketted.set", Native_VSH2_setMarketted);
	
	CreateNative("VSH2Player.m_iDifficulty.get", Native_VSH2_getDifficulty);
	CreateNative("VSH2Player.m_iDifficulty.set", Native_VSH2_setDifficulty);
	
	CreateNative("VSH2Player.m_bIsBoss.get", Native_VSH2_getIsBoss);
	CreateNative("VSH2Player.m_bIsBoss.set", Native_VSH2_setIsBoss);
	
	CreateNative("VSH2Player.m_bSetOnSpawn.get", Native_VSH2_getSetOnSpawn);
	CreateNative("VSH2Player.m_bSetOnSpawn.set", Native_VSH2_setSetOnSpawn);
	
	CreateNative("VSH2Player.m_bUsedUltimate.get", Native_VSH2_getUsedUltimate);
	CreateNative("VSH2Player.m_bUsedUltimate.set", Native_VSH2_setUsedUltimate);
	
	CreateNative("VSH2Player.m_flSpeed.get", Native_VSH2_getSpeed);
	CreateNative("VSH2Player.m_flSpeed.set", Native_VSH2_setSpeed);
	
	CreateNative("VSH2Player.m_flCharge.get", Native_VSH2_getCharge);
	CreateNative("VSH2Player.m_flCharge.set", Native_VSH2_setCharge);
	
	CreateNative("VSH2Player.m_flRAGE.get", Native_VSH2_getRAGE);
	CreateNative("VSH2Player.m_flRAGE.set", Native_VSH2_setRAGE);
	
	CreateNative("VSH2Player.m_flKillSpree.get", Native_VSH2_getKillSpree);
	CreateNative("VSH2Player.m_flKillSpree.set", Native_VSH2_setKillSpree);
	
	CreateNative("VSH2Player.m_flWeighDown.get", Native_VSH2_getWeighDown);
	CreateNative("VSH2Player.m_flWeighDown.set", Native_VSH2_setWeighDown);*/
	
	//CreateNative("VSH2Player.ConvertToMinion", Native_VSH2_ConvertToMinion);

	RegPluginLibrary("VSH2");

	return APLRes_Success;
}

public int Native_RegisterPlugin(Handle plugin, int numParams)
{
	char ModuleName[64]; GetNativeString(1, ModuleName, sizeof(ModuleName));
	int plugin_index = RegisterPlugin(plugin, ModuleName );		// ALL PROPS TO COOKIES.NET AKA COOKIES.IO
	return plugin_index;
}

public int Native_VSH2Instance(Handle plugin, int numParams)
{
	BaseBoss player = BaseBoss(GetNativeCell(1), GetNativeCell(2));
	return view_as< int >(player);
}

public int Native_VSH2GetUserid(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.userid;
}
public int Native_VSH2GetIndex(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.index;
}
public int Native_VSH2_getProperty(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	any item = GetNativeCellRef(3);
	if (hPlayerFields[player.index].GetValue(prop_name, item)) {
		SetNativeCellRef(3, item);
		return true;
	}
	return false;
}
public int Native_VSH2_setProperty(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	any item = GetNativeCell(3);
	hPlayerFields[player.index].SetValue(prop_name, item);
}

/*
public int Native_VSH2_getQueue(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.iQueue;
}
public int Native_VSH2_setQueue(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.iQueue = GetNativeCell(2);
}

public int Native_VSH2_getPreset(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.iPresetType;
}
public int Native_VSH2_setPreset(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.iPresetType = GetNativeCell(2);
}

public int Native_VSH2_getKills(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.iKills;
}
public int Native_VSH2_setKills(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.iKills = GetNativeCell(2);
}

public int Native_VSH2_getHits(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.iHits;
}
public int Native_VSH2_setHits(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.iHits = GetNativeCell(2);
}

public int Native_VSH2_getLives(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.iLives;
}
public int Native_VSH2_setLives(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.iLives = GetNativeCell(2);
}

public int Native_VSH2_getState(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.iState;
}
public int Native_VSH2_setState(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.iState = GetNativeCell(2);
}

public int Native_VSH2_getDamage(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.iDamage;
}
public int Native_VSH2_setDamage(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.iDamage = GetNativeCell(2);
}

public int Native_VSH2_getAirDamage(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.iAirDamage;
}
public int Native_VSH2_setAirDamage(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.iAirDamage = GetNativeCell(2);
}

public int Native_VSH2_getSongPick(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.iSongPick;
}
public int Native_VSH2_setSongPick(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.iSongPick = GetNativeCell(2);
}

public int Native_VSH2_getHealTarget(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.iHealTarget;
}

public int Native_VSH2_getOwnerBoss(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.iOwnerBoss;
}
public int Native_VSH2_setOwnerBoss(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.iOwnerBoss = GetNativeCell(2);
}

public int Native_VSH2_getUberTarget(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.iUberTarget;
}
public int Native_VSH2_setUberTarget(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.iUberTarget = GetNativeCell(2);
}

public int Native_VSH2_getGlow(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.bGlow;
}
public int Native_VSH2_setGlow(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.bGlow = GetNativeCell(2);
}

public int Native_VSH2_getNearDispenser(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.bNearDispenser;
}

public int Native_VSH2_getIsMinion(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.bIsMinion;
}
public int Native_VSH2_setIsMinion(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.bIsMinion = GetNativeCell(2);
}

public int Native_VSH2_getInJump(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.bInJump;
}
public int Native_VSH2_setInJump(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.bInJump = GetNativeCell(2);
}

public int Native_VSH2_getGlowtime(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return view_as< int >(player.flGlowtime);
}
public int Native_VSH2_setGlowtime(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.flGlowtime = GetNativeCell(2);
}

public int Native_VSH2_getLastHit(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return view_as< int >(player.flLastHit);
}
public int Native_VSH2_setLastHit(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.flLastHit = GetNativeCell(2);
}

public int Native_VSH2_getLastShot(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return view_as< int >(player.flLastShot);
}
public int Native_VSH2_setLastShot(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.flLastShot = GetNativeCell(2);
}

public int Native_VSH2_getHealth(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.iHealth;
}
public int Native_VSH2_setHealth(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.iHealth = GetNativeCell(2);
}

public int Native_VSH2_getMaxHealth(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.iMaxHealth;
}
public int Native_VSH2_setMaxHealth(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.iMaxHealth = GetNativeCell(2);
}

public int Native_VSH2_getType(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.iType;
}
public int Native_VSH2_setType(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.iType = GetNativeCell(2);
}

public int Native_VSH2_getClimbs(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.iClimbs;
}
public int Native_VSH2_setClimbs(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.iClimbs = GetNativeCell(2);
}

public int Native_VSH2_getStabbed(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.iStabbed;
}
public int Native_VSH2_setStabbed(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.iStabbed = GetNativeCell(2);
}

public int Native_VSH2_getMarketted(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.iMarketted;
}
public int Native_VSH2_setMarketted(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.iMarketted = GetNativeCell(2);
}

public int Native_VSH2_getDifficulty(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.iDifficulty;
}
public int Native_VSH2_setDifficulty(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.iDifficulty = GetNativeCell(2);
}

public int Native_VSH2_getIsBoss(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return view_as< int >(player.bIsBoss);
}
public int Native_VSH2_setIsBoss(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.bIsBoss = GetNativeCell(2);
}

public int Native_VSH2_getSetOnSpawn(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return view_as< int >(player.bSetOnSpawn);
}
public int Native_VSH2_setSetOnSpawn(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.bSetOnSpawn = GetNativeCell(2);
}

public int Native_VSH2_getUsedUltimate(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return view_as< int >(player.bUsedUltimate);
}
public int Native_VSH2_setUsedUltimate(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.bUsedUltimate = GetNativeCell(2);
}

public int Native_VSH2_getSpeed(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return view_as< int >(player.flSpeed);
}
public int Native_VSH2_setSpeed(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.flSpeed = GetNativeCell(2);
}

public int Native_VSH2_getCharge(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return view_as< int >(player.flCharge);
}
public int Native_VSH2_setCharge(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.flCharge = GetNativeCell(2);
}

public int Native_VSH2_getRAGE(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return view_as< int >(player.flRAGE);
}
public int Native_VSH2_setRAGE(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.flRAGE = GetNativeCell(2);
}

public int Native_VSH2_getKillSpree(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return view_as< int >(player.flKillSpree);
}
public int Native_VSH2_setKillSpree(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.flKillSpree = GetNativeCell(2);
}

public int Native_VSH2_getWeighDown(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return view_as< int >(player.flWeighDown);
}
public int Native_VSH2_setWeighDown(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.flWeighDown = GetNativeCell(2);
}

public int Native_VSH2_ConvertToMinion(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.ConvertToMinion(GetNativeCell(2));
}
*/
