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
#tryinclude <goomba>
#define REQUIRE_PLUGIN

#undef REQUIRE_EXTENSIONS
#tryinclude <steamtools>
#define REQUIRE_EXTENSIONS

#undef REQUIRE_PLUGIN
#tryinclude <updater>
#define REQUIRE_PLUGIN

#define UPDATE_URL          "https://raw.githubusercontent.com/VSH2-Devs/Vs-Saxton-Hale-2/develop/updater.txt"

#pragma semicolon            1
#pragma newdecls             required

#define PLUGIN_VERSION       "2.3.16"
#define PLUGIN_DESCRIPT      "VS Saxton Hale 2"


#define IsClientValid(%1)    ( 0 < (%1) && (%1) <= MaxClients && IsClientInGame((%1)) )
#define PLYR                 MAXPLAYERS+1

/// misc.
#define PATH                 64
#define repeat(%1)           for( int __i=0; __i<(%1); ++__i )


public Plugin myinfo = {
	name            = "Vs Saxton Hale 2 Mod",
	author          = "nergal/assyrian, props to Flamin' Sarge, Chdata, & Buzzkillington",
	description     = "Allows Players to play as various bosses of TF2",
	version         = PLUGIN_VERSION,
	url             = "https://forums.alliedmods.net/showthread.php?t=286701"
};


enum /** CvarName */ {
	PointType = 0,
	PointDelay,
	AliveToEnable,
	FirstRound,
	DamagePoints,
	DamageQueue,
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
	CanBossGoomba,
	CanMantreadsGoomba,
	GoombaDamageAdd,
	GoombaLifeMultiplier,
	GoombaReboundPower,
	MultiBossHandicap,
	DroppedWeapons,
	BlockEureka,
	ForceLives,
	Anchoring,
	BlockRageSuicide,
	HealthKitLimitMax,
	HealthKitLimitMin,
	AmmoKitLimitMax,
	AmmoKitLimitMin,
	ShieldRegenDmgReq,
	AllowRandomMultiBosses,
	HHHMaxClimbs,
	HealthCheckInitialDelay,
	ScoutRageGen,
	SydneySleeperRageRemove,
	DamageForQueue,
	DeadRingerDamage,
	CloakDamage,
	Enabled,
	AllowLateSpawn,
	SuicidePercent,
	AirShotDist,
	MedicUberShield,
	HHHClimbVelocity,
	SniperClimbVelocity,
	ShowBossHPLiving,
	HHHTeleCooldown,
	MaxRandomMultiBosses,
	VersionNumber
};

/// Don't change this. Simply place any new CVARs above VersionNumber in the enum.
ConVar cvarVSH2[VersionNumber+1];

Handle
	hHudText,
	timeleftHUD,
	healthHUD,
	PointCookie,
	BossCookie,
	MusicCookie
;
/*
enum struct VSH2Objs {
	Handle
		HudText,
		TimeLeftHUD,
		PointCookies,
		BossCookies,
		MusicCookies
	;
};

VSH2Objs g_vsh2_handles;
*/

methodmap TF2Item < Handle {
	public TF2Item(int iFlags) {
		return view_as<TF2Item>( TF2Items_CreateItem(iFlags) );
	}
	/////////////////////////////// 
	
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
	
	public int GiveNamedItem(int iClient) {
		return TF2Items_GiveNamedItem(iClient, this);
	}
	public void SetClassname(char[] strClassName) {
		TF2Items_SetClassname(this, strClassName);
	}
	public void GetClassname(char[] strDest, int iDestSize) {
		TF2Items_GetClassname(this, strDest, iDestSize);
	}
	public void SetAttribute(int iSlotIndex, int iAttribDefIndex, float flValue) {
		TF2Items_SetAttribute(this, iSlotIndex, iAttribDefIndex, flValue);
	}
	public int GetAttribID(int iSlotIndex) {
		return TF2Items_GetAttributeId(this, iSlotIndex);
	}
	public float GetAttribValue(int iSlotIndex) {
		return TF2Items_GetAttributeValue(this, iSlotIndex);
	}
	/**************************************************************/
};


ArrayList g_hBossesRegistered;

#include "modules/stocks.inc" /// include stocks first.
#include "modules/handler.sp" /// Contains the game mode logic as well
#include "modules/events.sp"
#include "modules/commands.sp"

public void OnPluginStart()
{
	gamemode = VSHGameMode();
	gamemode.Init();
	
	/// in forwards.sp
	InitializeForwards();
	
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
	
	RegConsoleCmd("sm_setboss", SetBossMenu, "Sets your boss.");
	RegConsoleCmd("sm_sethale", SetBossMenu, "Sets your boss.");
	RegConsoleCmd("sm_ff2boss", SetBossMenu, "Sets your boss.");
	RegConsoleCmd("sm_haleboss", SetBossMenu, "Sets your boss.");
	
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
	
	RegConsoleCmd("sm_hale", HelpPanelCmd);
	RegConsoleCmd("sm_boss", HelpPanelCmd);
	RegConsoleCmd("sm_ff2", HelpPanelCmd);
	
	RegConsoleCmd("sm_resetq", ResetQueue);
	RegConsoleCmd("sm_resetqueue", ResetQueue);
	
	RegConsoleCmd("sm_vsh2wep", MakeWeapInvis);
	RegConsoleCmd("sm_vsh2vm", MakeWeapInvis);
	
	RegAdminCmd("sm_reloadbosscfg", CmdReloadCFG, ADMFLAG_GENERIC);
	RegAdminCmd("sm_hale_select", CommandBossSelect, ADMFLAG_VOTE, "hale_select <target> - Select a player to be next boss.");
	RegAdminCmd("sm_ff2_select", CommandBossSelect, ADMFLAG_VOTE, "ff2_select <target> - Select a player to be next boss.");
	RegAdminCmd("sm_boss_select", CommandBossSelect, ADMFLAG_VOTE, "boss_select <target> - Select a player to be next boss.");
	RegAdminCmd("sm_healthbarcolor", ChangeHealthBarColor, ADMFLAG_GENERIC);
	
	RegAdminCmd("sm_boss_force", ForceBossRealtime, ADMFLAG_VOTE, "boss_force <target> <bossID> - Force a player to the boss team as the specified boss. (Setup time only)");
	RegAdminCmd("sm_hale_force", ForceBossRealtime, ADMFLAG_VOTE, "hale_force <target> <bossID> - Force a player to the boss team as the specified boss. (Setup time only)");
	RegAdminCmd("sm_ff2_force", ForceBossRealtime, ADMFLAG_VOTE, "ff2_force <target> <bossID> - Force a player to the boss team as the specified boss. (Setup time only)");
	
	RegAdminCmd("sm_hale_addpoints", CommandAddPoints, ADMFLAG_GENERIC);
	RegAdminCmd("sm_vsh2_addpoints", CommandAddPoints, ADMFLAG_GENERIC);
	RegAdminCmd("sm_ff2_addpoints", CommandAddPoints, ADMFLAG_GENERIC);
	
	RegAdminCmd("sm_hale_setpoints", CommandSetPoints, ADMFLAG_GENERIC);
	RegAdminCmd("sm_vsh2_setpoints", CommandSetPoints, ADMFLAG_GENERIC);
	RegAdminCmd("sm_ff2_setpoints", CommandSetPoints, ADMFLAG_GENERIC);
	
	RegAdminCmd("sm_hale_classrush", MenuDoClassRush, ADMFLAG_GENERIC, "forces all red players to a class.");
	RegAdminCmd("sm_vsh2_classrush", MenuDoClassRush, ADMFLAG_GENERIC, "forces all red players to a class.");
	
	RegAdminCmd("sm_vsh2adwep", AdminMakeWeapInvis, ADMFLAG_GENERIC);
	RegAdminCmd("sm_vsh2advm", AdminMakeWeapInvis, ADMFLAG_GENERIC);
	
	AddCommandListener(BlockSuicide, "explode");
	AddCommandListener(BlockSuicide, "kill");
	AddCommandListener(BlockSuicide, "jointeam");
	AddCommandListener(CheckLateSpawn, "joinclass");
	AddCommandListener(CheckLateSpawn, "join_class");
	
	hHudText = CreateHudSynchronizer();
	timeleftHUD = CreateHudSynchronizer();
	healthHUD = CreateHudSynchronizer();
	
	cvarVSH2[Enabled] = CreateConVar("vsh2_enabled", "1", "Enable VSH 2 plugin", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarVSH2[VersionNumber] = CreateConVar("vsh2_version", PLUGIN_VERSION, "VSH 2 Plugin Version. (DO NOT CHANGE)", FCVAR_NOTIFY);
	cvarVSH2[PointType] = CreateConVar("vsh2_point_type", "0", "Select condition to enable point (0 - alive players, 1 - time)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarVSH2[PointDelay] = CreateConVar("vsh2_point_delay", "6", "Addition (for each player) delay before point's activation.", FCVAR_NOTIFY, true, 0.0, false);
	cvarVSH2[AliveToEnable] = CreateConVar("vsh2_point_alive", "5", "Enable control points when there are X people left alive.", FCVAR_NOTIFY, true, 1.0, true, 32.0);
	cvarVSH2[FirstRound] = CreateConVar("vsh2_firstround", "0", "If 1, allows the first round to start with VSH2 enabled.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarVSH2[DamagePoints] = CreateConVar("vsh2_damage_points", "600", "Amount of damage needed to gain 1 point on the scoreboard.", FCVAR_NOTIFY, true, 1.0, false);
	cvarVSH2[DamageQueue] = CreateConVar("vsh2_damage_queue", "1", "Allow damage to influence increase of queue points.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarVSH2[QueueGained] = CreateConVar("vsh2_queue_gain", "10", "How many queue points to give at the end of each round.", FCVAR_NOTIFY, true, 0.0, false);
	cvarVSH2[EnableMusic] = CreateConVar("vsh2_enable_music", "1", "Enables boss background music.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarVSH2[MusicVolume] = CreateConVar("vsh2_music_volume", "0.5", "How loud the background music should be, if enabled.", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	cvarVSH2[HealthPercentForLastGuy] = CreateConVar("vsh2_health_percentage_last_guy", "51", "If the health bar is lower than x out of 255, the last player timer will stop.", FCVAR_NOTIFY, true, 0.0, true, 255.0);
	cvarVSH2[HealthRegenForPlayers] = CreateConVar("vsh2_health_regen", "0", "Allow non-boss and non-minion players to have passive health regen.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarVSH2[HealthRegenAmount] = CreateConVar("vsh2_health_regen_amount", "1.0", "If health regen is enabled, how much health regen per second should players get?", FCVAR_NOTIFY, true, 0.0, false);
	cvarVSH2[MedigunReset] = CreateConVar("vsh2_medigun_reset_amount", "0.31", "How much Uber percentage should Mediguns, after Uber, reset to?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarVSH2[StopTickleTime] = CreateConVar("vsh2_stop_tickle_time", "1.0", "How long in seconds the tickle effect from the Holiday Punch lasts before being removed.", FCVAR_NOTIFY, true, 0.01, false);
	cvarVSH2[AirStrikeDamage] = CreateConVar("vsh2_airstrike_damage", "200", "How much damage needed for the Airstrike to gain +1 clipsize.", FCVAR_NOTIFY, true, 0.0, false);
	cvarVSH2[AirblastRage] = CreateConVar("vsh2_airblast_rage", "8.0", "How much Rage should airblast give/remove? (negative number to remove rage)", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	cvarVSH2[JarateRage] = CreateConVar("vsh2_jarate_rage", "8.0", "How much rage should Jarate give/remove? (negative number to add rage)", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	cvarVSH2[FanoWarRage] = CreateConVar("vsh2_fanowar_rage", "5.0", "How much rage should the Fan o' War give/remove? (negative number to add rage)", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	cvarVSH2[LastPlayerTime] = CreateConVar("vsh2_lastplayer_time", "180", "How many seconds to give the last player to fight the Boss(es) before a stalemate.", FCVAR_NOTIFY, true, 0.0, false);
	cvarVSH2[EngieBuildings] = CreateConVar("vsh2_killbuilding_engiedeath", "1", "If 0, no building dies when engie dies. If 1, only sentry dies. If 2, all buildings die.", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	cvarVSH2[MedievalLives] = CreateConVar("vsh2_medievalmode_lives", "3", "Amount of lives red players are entitled during Medieval Mode.", FCVAR_NOTIFY, true, 0.0, true, 99.0);
	cvarVSH2[MedievalRespawnTime] = CreateConVar("vsh2_medievalmode_respawntime", "5.0", "How long it takes for players to respawn after dying in medieval mode (if they have live left).", FCVAR_NOTIFY, true, 1.0, true, 999.0);
	cvarVSH2[PermOverheal] = CreateConVar("vsh2_permanent_overheal", "0", "If enabled, Mediguns give permanent overheal.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarVSH2[MultiCapture] = CreateConVar("vsh2_multiple_cp_captures", "1", "If enabled, allow control points to be captured more than once instead of ending the round instantly.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarVSH2[MultiCapAmount] = CreateConVar("vsh2_multiple_cp_capture_amount", "3", "If vsh2_allow_multiple_cp_captures is enabled, how many times must a team capture a Control Point to win.", FCVAR_NOTIFY, true, 1.0, true, 999.0);
	cvarVSH2[DemoShieldCrits] = CreateConVar("vsh2_demoman_shield_crits", "2", "Sets Demoman Shield crit behaviour. 0 - No crits, 1 - Mini-crits, 2 - Crits, 3 - Scale with Charge Meter (Losing the Shield results in no more (mini)crits.)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	cvarVSH2[CanBossGoomba] = CreateConVar("vsh2_goomba_can_boss_stomp", "1", "Can the Boss Goomba Stomp other players? (Requires Goomba Stomp plugin). NOTE: All the CVARs in VSH2 controlling Goomba damage, lifemultiplier and rebound power are for NON-BOSS PLAYERS STOMPING THE BOSS. If you enable this CVAR, use the Goomba Stomp plugin config file to control the Boss' Goomba Variables. Not recommended to enable this unless you've coded your own Goomba Stomp behaviour.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarVSH2[CanMantreadsGoomba] = CreateConVar("vsh2_goomba_can_mantreads_stomp", "0", "Can Soldiers/Demomen Goomba Stomp the Boss while using the Mantreads/Booties? (Requires Goomba Stomp plugin). NOTE: Enabling this may cause 'double' Stomps (Goomba Stomp and Mantreads stomp together).", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarVSH2[GoombaDamageAdd] = CreateConVar("vsh2_goomba_damage_add", "450.0", "How much damage to add to a Goomba Stomp on the Boss. (Requires Goomba Stomp plugin).", FCVAR_NOTIFY, true, 0.0, false);
	cvarVSH2[GoombaLifeMultiplier] = CreateConVar("vsh2_goomba_boss_life_multiplier", "0.025", "What percentage of the Boss' CURRENT HP to deal as damage on a Goomba Stomp. (Requires Goomba Stomp plugin).", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarVSH2[GoombaReboundPower] = CreateConVar("vsh2_rebound_power", "300.0", "How much upwards velocity (in Hammer Units) should players recieve upon Goomba Stomping the Boss? (Requires Goomba Stomp plugin).", FCVAR_NOTIFY, true, 0.0, false);
	cvarVSH2[MultiBossHandicap] = CreateConVar("vsh2_multiboss_handicap", "500", "How much Health is removed on every individual boss in a multiboss round at the start of said round. 0 disables it.", FCVAR_NONE, true, 0.0, true, 99999.0);
	cvarVSH2[DroppedWeapons] = CreateConVar("vsh2_allow_dropped_weapons", "0", "Enables/Disables dropped weapons. Recommended to keep this disabled to avoid players having weapons they shouldn't.", FCVAR_NONE, true, 0.0, true, 1.0);
	cvarVSH2[BlockEureka] = CreateConVar("vsh2_allow_eureka_effect", "0", "Enables/Disables the Eureka Effect for Engineers", FCVAR_NONE, true, 0.0, true, 1.0);
	cvarVSH2[ForceLives] = CreateConVar("vsh2_force_player_lives", "0", "Forces the gamemode to apply Medieval Mode lives on players, whether or not medieval mode is enabled", FCVAR_NONE, true, 0.0, true, 1.0);
	cvarVSH2[Anchoring] = CreateConVar("vsh2_allow_boss_anchor", "1", "When enabled, reduces all knockback bosses experience when crouching.", FCVAR_NONE, true, 0.0, true, 1.0);
	cvarVSH2[BlockRageSuicide] = CreateConVar("vsh2_block_raged_suicide", "1", "when enabled, stops raged players from suiciding.", FCVAR_NONE, true, 0.0, true, 1.0);
	cvarVSH2[HealthKitLimitMax] = CreateConVar("vsh2_spawn_health_kit_limit_max", "6", "max amount of health kits that can be produced in RED spawn. 0 for unlimited amount", FCVAR_NONE, true, 0.0, true, 50.0);
	cvarVSH2[HealthKitLimitMin] = CreateConVar("vsh2_spawn_health_kit_limit_min", "4", "minimum amount of health kits that can be produced in RED spawn. 0 for no minimum limit", FCVAR_NONE, true, 0.0, true, 50.0);
	cvarVSH2[AmmoKitLimitMax] = CreateConVar("vsh2_spawn_ammo_kit_limit_max", "6", "max amount of ammo kits that can be produced in RED spawn. 0 for unlimited amount", FCVAR_NONE, true, 0.0, true, 50.0);
	cvarVSH2[AmmoKitLimitMin] = CreateConVar("vsh2_spawn_ammo_kit_limit_min", "4", "minimum amount of ammo kits that can be produced in RED spawn. 0 for no minimum limit", FCVAR_NONE, true, 0.0, true, 50.0);
	cvarVSH2[ShieldRegenDmgReq] = CreateConVar("vsh2_shield_regen_damage", "2000", "damage required for demoknights to regenerate their shield, put 0 to disable.", FCVAR_NONE, true, 0.0, true, 99999.0);
	cvarVSH2[AllowRandomMultiBosses] = CreateConVar("vsh2_allow_random_multibosses", "1", "allows VSH2 to make random combinations of various bosses.", FCVAR_NONE, true, 0.0, true, 1.0);
	cvarVSH2[HHHMaxClimbs] = CreateConVar("vsh2_hhhjr_max_climbs", "10", "maximum amount of climbs HHH Jr. can do.", FCVAR_NONE, true, 0.0, false);
	cvarVSH2[HealthCheckInitialDelay] = CreateConVar("vsh2_initial_healthcheck_delay", "30.0", "Initial health check delay when the round starts so as to prevent wasting 10-second health checks.", FCVAR_NONE, true, 0.0, true, 999.0);
	cvarVSH2[ScoutRageGen] = CreateConVar("vsh2_scout_rage_gen", "0.2", "rate of how much rage a boss generates when there are only scouts left.", FCVAR_NONE, true, 0.0, true, 99.0);
	cvarVSH2[SydneySleeperRageRemove] = CreateConVar("vsh2_sydney_sleeper_rage_remove", "0.01", "how much rage (multiplied with damage) the Sydney Sleeper sniper rifle will remove from a boss' rage meter.", FCVAR_NONE, true, 0.0, true, 99.0);
	cvarVSH2[DamageForQueue] = CreateConVar("vsh2_damage_for_queue", "1000", "if 'vsh2_damage_queue' is enabled, how much queue to give per amount of damage done.", FCVAR_NONE, true, 0.0, false);
	cvarVSH2[DeadRingerDamage] = CreateConVar("vsh2_dead_ringer_damage", "90.0", "damage, divided by 0.25, that dead ringer spies will take from boss melee hits.", FCVAR_NONE, true, 0.0, false);
	cvarVSH2[CloakDamage] = CreateConVar("vsh2_cloak_damage", "70.0", "damage, divided by 0.8, that dead ringer spies will take from boss melee hits.", FCVAR_NONE, true, 0.0, false);
	cvarVSH2[AllowLateSpawn] = CreateConVar("vsh2_allow_late_spawning", "0", "allows if unassigned spectators can respawn during an active round.", FCVAR_NONE, true, 0.0, true, 1.0);
	cvarVSH2[SuicidePercent] = CreateConVar("vsh2_boss_suicide_percent", "0.3", "Allow the boss to suicide if their health percentage goes at or below this amount (0.3 == 30%).", FCVAR_NONE, true, 0.0, true, 1.0);
	cvarVSH2[AirShotDist] = CreateConVar("vsh2_airshot_dist", "80.0", "distance (from the air to the ground) to count as a skilled airshot.", FCVAR_NONE, true, 10.0, false);
	cvarVSH2[MedicUberShield] = CreateConVar("vsh2_use_uber_as_shield", "0", "If a medic has nearly full uber (90%+), use the uber as a shield to prevent the medic from getting killed.", FCVAR_NONE, true, 0.0, true, 1.0);
	cvarVSH2[HHHClimbVelocity] = CreateConVar("vsh2_hhh_climb_velocity", "600.0", "in hammer units, how high of a velocity HHH Jr. will climb.", FCVAR_NONE, true, 0.0, true, 9999.0);
	cvarVSH2[SniperClimbVelocity] = CreateConVar("vsh2_sniper_climb_velocity", "600.0", "in hammer units, how high of a velocity sniper melees will climb.", FCVAR_NONE, true, 0.0, false);
	cvarVSH2[ShowBossHPLiving] = CreateConVar("vsh2_show_boss_hp_alive_players", "1", "How many players must be alive for total boss hp to show.", FCVAR_NONE, true, 1.0, true, 64.0);
	cvarVSH2[HHHTeleCooldown] = CreateConVar("vsh2_hhh_tele_cooldown", "-1100.0", "Teleportation cooldown for HHH Jr. after teleporting. formula is '-seconds * 25' so -1100.0 is 44 seconds", FCVAR_NONE, true, -999999.0, true, 25.0);
	cvarVSH2[MaxRandomMultiBosses] = CreateConVar("vsh2_random_multibosses_limit", "2", "The maximum limit for hain", FCVAR_NONE, true, 1.0, true, 30.0);
	
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
	HookEvent("rocket_jump", OnHookedEvent);
	HookEvent("rocket_jump_landed", OnHookedEvent);
	HookEvent("sticky_jump", OnHookedEvent);
	HookEvent("sticky_jump_landed", OnHookedEvent);
	HookEvent("item_pickup", ItemPickedUp);
	HookEvent("player_chargedeployed", UberDeployed);
	HookEvent("arena_round_start", ArenaRoundStart);
	HookEvent("teamplay_point_captured", PointCapture, EventHookMode_Post);
	HookEvent("rps_taunt_event", RPSTaunt, EventHookMode_Post);
	
	AddCommandListener(cdVoiceMenu, "voicemenu");
	AddNormalSoundHook(HookSound);
	
	PointCookie = RegClientCookie("vsh2_queuepoints", "Amount of VSH2 Queue points a player has.", CookieAccess_Protected);
	BossCookie = RegClientCookie("vsh2_presetbosses", "Preset bosses for VSH2 players.", CookieAccess_Protected);
	MusicCookie = RegClientCookie("vsh2_music_settings", "HaleMusic setting.", CookieAccess_Public);
	
	/// in handler.sp
	ManageDownloads();
	
	for( int i=MaxClients; i; --i ) {
		if( !IsClientInGame(i) )
			continue;
		OnClientPutInServer(i);
	}
	
	AddMultiTargetFilter("@boss", HaleTargetFilter, "all Bosses", false);
	AddMultiTargetFilter("@hale", HaleTargetFilter, "all Bosses", false);
	AddMultiTargetFilter("@minion", MinionTargetFilter, "all Minions", false);
	AddMultiTargetFilter("@minions", MinionTargetFilter, "all Minions", false);
	AddMultiTargetFilter("@!boss", HaleTargetFilter, "all non-Boss players", false);
	AddMultiTargetFilter("@!hale", HaleTargetFilter, "all non-Boss players", false);
	AddMultiTargetFilter("@!minion", MinionTargetFilter, "all non-Minions", false);
	AddMultiTargetFilter("@!minions", MinionTargetFilter, "all non-Minions", false);
	
	hPlayerFields[0] = new StringMap();   /// This will be freed when plugin is unloaded again
	g_hBossesRegistered = new ArrayList(MAX_BOSS_NAME_SIZE);
}

public bool HaleTargetFilter(const char[] pattern, Handle clients)
{
	bool non = StrContains(pattern, "!", false) != -1;
	for( int i=MaxClients; i; i-- ) {
		if( IsClientValid(i) && FindValueInArray(clients, i) == -1 ) {
			if( cvarVSH2[Enabled].BoolValue && BaseBoss(i).bIsBoss ) {
				if( !non )
					PushArrayCell(clients, i);
			}
			else if( non )
				PushArrayCell(clients, i);
		}
	}
	return true;
}
public bool MinionTargetFilter(const char[] pattern, Handle clients)
{
	bool non = StrContains(pattern, "!", false) != -1;
	for( int i=MaxClients; i; i-- ) {
		if( IsClientValid(i) && FindValueInArray(clients, i) == -1 ) {
			if( cvarVSH2[Enabled].BoolValue && BaseBoss(i).bIsMinion ) {
				if( !non )
					PushArrayCell(clients, i);
			}
			else if( non )
				PushArrayCell(clients, i);
		}
	}
	return true;
}

public Action CheckLateSpawn(int client, const char[] command, int argc)
{
	if( !cvarVSH2[Enabled].BoolValue || gamemode.iRoundState != StateRunning )
		return Plugin_Continue;
	
	/// deal with late spawners, force them to spectator.
	if( !cvarVSH2[AllowLateSpawn].BoolValue && GetClientTeam(client) > VSH2Team_Spectator && TF2_GetPlayerClass(client)==TFClass_Unknown ) {
		char str_tfclass[20]; GetCmdArg(1, str_tfclass, sizeof(str_tfclass));
		TFClassType classtype = TF2_GetClass(str_tfclass);
		CPrintToChat(client, "{olive}[VSH 2]{default} Late Spawn Blocked");
		SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", view_as< int >(classtype));
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action BlockSuicide(int client, const char[] command, int argc)
{
	if( cvarVSH2[Enabled].BoolValue && gamemode.iRoundState == StateRunning ) {
		BaseBoss player = BaseBoss(client);
		if( player.bIsBoss ) {
			/// Allow bosses to suicide if their total health is under a certain percentage.
			float flhp_percent = float(player.iHealth) / float(player.iMaxHealth);
			if( flhp_percent > cvarVSH2[SuicidePercent].FloatValue ) {
				CPrintToChat(client, "{olive}[VSH 2]{default} You cannot suicide yet as a boss. Please Use '!resetq' instead.");
				return Plugin_Handled;
			}
		} else {
			/// stop rage-stunned players from suiciding.
			if( cvarVSH2[BlockRageSuicide].BoolValue ) {
				int stunflags = GetEntProp(client, Prop_Send, "m_iStunFlags");
				if( stunflags & (TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT) )
					return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;
}

public void OnLibraryAdded(const char[] name)
{
#if defined _steamtools_included
	if( !strcmp(name, "SteamTools", false) )
		gamemode.bSteam = true;
#endif
#if defined _tf2attributes_included
	if( !strcmp(name, "tf2attributes", false) )
		gamemode.bTF2Attribs = true;
#endif
#if defined _updater_included
	if( !strcmp(name, "updater") )
		Updater_AddPlugin(UPDATE_URL);
#endif
}
public void OnLibraryRemoved(const char[] name)
{
#if defined _steamtools_included
	if( !strcmp(name, "SteamTools", false) )
		gamemode.bSteam = false;
#endif
#if defined _tf2attributes_included
	if( !strcmp(name, "tf2attributes", false) )
		gamemode.bTF2Attribs = false;
#endif
}
/// UPDATER Stuff
public void OnAllPluginsLoaded()
{
#if defined _updater_included
	if( LibraryExists("updater") )
		Updater_AddPlugin(UPDATE_URL);
#endif
}

int
	tf_arena_use_queue,
	mp_teams_unbalance_limit,
	mp_forceautoteam,
	tf_arena_first_blood,
	mp_forcecamera
;

float
	tf_scout_hype_pep_max
;

public void OnConfigsExecuted()
{
	/// Config checker taken from VSH1
	static char szOldVersion[PATH];
	cvarVSH2[VersionNumber].GetString(szOldVersion, sizeof(szOldVersion));
	if( !StrEqual(szOldVersion, PLUGIN_VERSION) )
		LogMessage("[VSH2] Warning: your config is outdated. Back up your tf/cfg/sourcemod/VSHv2.cfg file and delete it, and this plugin will generate a new one that you can then modify to your original values.");
	cvarVSH2[VersionNumber].SetString(PLUGIN_VERSION, false, true);
	
	if( gamemode.IsVSHMap() ) {
		tf_arena_use_queue = FindConVar("tf_arena_use_queue").IntValue;
		mp_teams_unbalance_limit = FindConVar("mp_teams_unbalance_limit").IntValue;
		tf_arena_first_blood = FindConVar("tf_arena_first_blood").IntValue;
		mp_forcecamera = FindConVar("mp_forcecamera").IntValue;
		tf_scout_hype_pep_max = FindConVar("tf_scout_hype_pep_max").FloatValue;
		
		FindConVar("tf_arena_use_queue").IntValue = 0;
		FindConVar("mp_teams_unbalance_limit").IntValue = 0;
		FindConVar("mp_forceautoteam").IntValue = 0;
		FindConVar("mp_teams_unbalance_limit").IntValue =  cvarVSH2[FirstRound].BoolValue ? 0 : 1;
		FindConVar("mp_forceautoteam").IntValue = cvarVSH2[FirstRound].BoolValue ? 0 : 1;
		FindConVar("tf_arena_first_blood").IntValue =  0;
		FindConVar("mp_forcecamera").IntValue =  0;
		FindConVar("tf_scout_hype_pep_max").FloatValue =  100.0;
		
		gamemode.CheckDoors();
		gamemode.CheckTeleToSpawn();
#if defined _steamtools_included
		if( gamemode.bSteam ) {
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
	SDKHook(client, SDKHook_PreThinkPost, OnPreThinkPost);
	
	if( hPlayerFields[client] != null )
		delete hPlayerFields[client];
	
	hPlayerFields[client] = new StringMap();
	BaseBoss boss = BaseBoss(client);
	
	/// BaseFighter properties
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
	boss.iShieldDmg = 0;
	
	/// BaseBoss properties
	boss.iHealth = 0;
	boss.iMaxHealth = 0;
	boss.iBossType = -1;
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
	SetPawnTimer(ConnectionMessage, 5.0, GetClientUserId(client));
}

public void ConnectionMessage(const int userid)
{
	int client = GetClientOfUserId(userid);
	if( IsValidClient(client) )
		CPrintToChat(client, "{olive}[VSH 2]{default} Welcome to VSH2, type /bosshelp for help!");
}

public Action OnTouch(int client, int other)
{
	if( 0 < other <= MaxClients ) {
		BaseBoss player = BaseBoss(client);
		BaseBoss victim = BaseBoss(other);
		
		if( player.bIsBoss && !victim.bIsBoss )
			return ManageOnTouchPlayer(player, victim); /// in handler.sp
	} else if( other > MaxClients ) {
		BaseBoss player = BaseBoss(client);
		if( IsValidEntity(other) && player.bIsBoss ) {
			char ent[5];
			if( GetEntityClassname(other, ent, sizeof(ent)), !StrContains(ent, "obj_") ) {
				if( GetEntProp(other, Prop_Send, "m_iTeamNum") != GetClientTeam(client) )
					return ManageOnTouchBuilding(player, other); /// in handler.sp
			}
		}
	}
	return Plugin_Continue;
}

public void OnMapStart()
{
	ManageDownloads();    /// in handler.sp
	//gamemode.hMusic = null;
	CreateTimer(0.1, Timer_PlayerThink, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(1.0, MakeModelTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	gamemode.iHealthBar = FindEntityByClassname(-1, "monster_resource");
	if( gamemode.iHealthBar == -1 ) {
		gamemode.iHealthBar = CreateEntityByName("monster_resource");
		if( gamemode.iHealthBar != -1 )
			DispatchSpawn(gamemode.iHealthBar);
	}
	gamemode.iRoundCount = 0;
	gamemode.iRoundState = StateDisabled;
	gamemode.hNextBoss = view_as< BaseBoss >(0);
}
public void OnMapEnd()
{
	FindConVar("tf_arena_use_queue").IntValue = tf_arena_use_queue;
	FindConVar("mp_teams_unbalance_limit").IntValue = mp_teams_unbalance_limit;
	FindConVar("mp_forceautoteam").IntValue = mp_forceautoteam;
	FindConVar("tf_arena_first_blood").IntValue = tf_arena_first_blood;
	FindConVar("mp_forcecamera").IntValue = mp_forcecamera;
	FindConVar("tf_scout_hype_pep_max").FloatValue = tf_scout_hype_pep_max;
}

public void _MakePlayerBoss(const int userid)
{
	int client = GetClientOfUserId(userid);
	if( client && IsClientInGame(client) ) {
		BaseBoss player = BaseBoss(client);
		
		/// in handler.sp; sets health, model, and equips the boss
		ManageBossTransition(player);
	}
}

public void _MakePlayerMinion(const int userid)
{
	int client = GetClientOfUserId(userid);
	if( client && IsClientInGame(client) ) {
		BaseBoss player = BaseBoss(client);
		
		/// in handler.sp; sets health, model, and equips the boss
		ManageMinionTransition(player);
	}
}

public void _BossDeath(const any userid)
{
	int client = GetClientOfUserId(userid);
	if( IsValidClient(client, false) ) {
		BaseBoss player = BaseBoss(client);
		if( player.iHealth <= 0 )
			player.iHealth = 0; /// ded, not big soup rice!
		
		ManageBossDeath(player); /// in handler.sp
	}
}
public Action MakeModelTimer(Handle hTimer)
{
	BaseBoss player;
	for( int i=MaxClients; i; --i ) {
		if( !IsValidClient(i, false) || !IsPlayerAlive(i) )
			continue;
		
		player = BaseBoss(i);
		if( player.bIsBoss ) {
			ManageBossModels(player); /// in handler.sp
		}
	}
	return Plugin_Continue;
}


/// the main 'mechanics' of bosses
public Action Timer_PlayerThink(Handle hTimer)
{
	if( !cvarVSH2[Enabled].BoolValue || gamemode.iRoundState != StateRunning )
		return Plugin_Continue;
	
	gamemode.UpdateBossHealth();
	if( gamemode.flMusicTime <= GetGameTime() )
		_MusicPlay();
	
	BaseBoss player;
	for( int i=MaxClients; i; --i ) {
		if( !IsValidClient(i, false) )
			continue;
		
		player = BaseBoss(i);
		/** If player is a boss, force Boss think on them; if not boss or on blue team, force fighter think! */
		if( player.bIsBoss ) {
			ManageBossThink(player);    /// in handler.sp
			SetEntityHealth(i, player.iHealth);
			
			/// BUG PATCH: Bosses are not being 100% dead when the iHealth is at 0...
			if( player.iHealth <= 0 )
				SDKHooks_TakeDamage(player.index, 0, 0, 100.0, DMG_DIRECT, _, _, _); //ForcePlayerSuicide(i);
		}
		else ManageFighterThink(player);
		
		if( GetLivingPlayers(VSH2Team_Red) <= cvarVSH2[ShowBossHPLiving].IntValue ) {
			SetHudTextParams(-1.0, 0.20, 0.11, 255, 255, 255, 255);
			ShowSyncHudText(i, healthHUD, "Total Boss Health: %i", gamemode.GetTotalBossHealth());
		}
	}
	
	/// If there's no active, living bosses, then force RED to win
	if( !gamemode.CountBosses(true) )
		ForceTeamWin(VSH2Team_Red);
	
	return Plugin_Continue;
}

public Action CmdReloadCFG(int client, int args)
{
	ServerCommand("sm_rcon exec sourcemod/VSHv2.cfg");
	CReplyToCommand(client, "{olive}[VSH 2]{default} **** Reloaded ConVar Config ****");
	return Plugin_Handled;
}

public void OnPreThinkPost(int client)
{
	if( !cvarVSH2[Enabled].BoolValue || IsClientObserver(client) || !IsPlayerAlive(client) )
		return;
	
	//BaseBoss player = BaseBoss(client);
	if( IsNearSpencer(client) ) {
		if( TF2_IsPlayerInCondition(client, TFCond_Cloaked) ) {
			float cloak = GetEntPropFloat(client, Prop_Send, "m_flCloakMeter") - 0.5;
			if( cloak < 0.0 )
				cloak = 0.0;
			SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", cloak);
		}
	}
}


public Action TraceAttack(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup)
{
	if( !cvarVSH2[Enabled].BoolValue )
		return Plugin_Continue;
	else if( IsClientValid(attacker) && IsClientValid(victim) ) {
		BaseBoss player = BaseBoss(victim);
		BaseBoss enemy = BaseBoss(attacker);
		return Call_OnTraceAttack(player, enemy, inflictor, damage, damagetype, ammotype, hitbox, hitgroup);
	}
	return Plugin_Continue;
}
public Action OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if( !cvarVSH2[Enabled].BoolValue || !IsClientValid(victim) )
		return Plugin_Continue;
	
	BaseBoss BossVictim = BaseBoss(victim);
	if( BossVictim.bIsBoss ) /// in handler.sp
		return ManageOnBossTakeDamage(BossVictim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	
	/// BUG PATCH: Client index 0 is invalid
	if( !IsClientValid(attacker) ) {
		if( (damagetype & DMG_FALL) && !BossVictim.bIsBoss ) {
			int item = GetPlayerWeaponSlot(victim, (TF2_GetPlayerClass(victim) == TFClass_DemoMan ? TFWeaponSlot_Primary : TFWeaponSlot_Secondary));
			if( item <= 0 || !IsValidEntity(item) || (TF2_GetPlayerClass(victim)==TFClass_Spy && TF2_IsPlayerInCondition(victim, TFCond_Cloaked)) ) {
				damage /= 10;
				return Plugin_Changed;
			}
		}
		return Plugin_Continue;
	}
	
	BaseBoss BossAttacker = BaseBoss(attacker);
	if( BossAttacker.bIsBoss ) /// in handler.sp
		return ManageOnBossDealDamage(BossVictim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	return Plugin_Continue;
}

#if defined _goomba_included_
public Action OnStomp(int attacker, int victim, float& damageMultiplier, float& damageAdd, float& JumpPower)
{
	if( !cvarVSH2[Enabled].BoolValue ) {
		return Plugin_Continue;
	}
	return ManageOnGoombaStomp(attacker, victim, damageMultiplier, damageAdd, JumpPower);
}
#endif

public Action RemoveEnt(Handle timer, any entid)
{
	int ent = EntRefToEntIndex(entid);
	if( ent > 0 && IsValidEntity(ent) )
		AcceptEntityInput(ent, "Kill");
	return Plugin_Continue;
}

public Action cdVoiceMenu(int client, const char[] command, int argc)
{
	if( !cvarVSH2[Enabled].BoolValue )
		return Plugin_Continue;
	if( argc < 2 || !IsPlayerAlive(client) )
		return Plugin_Handled;
	
	char szCmd1[8]; GetCmdArg(1, szCmd1, sizeof(szCmd1));
	char szCmd2[8]; GetCmdArg(2, szCmd2, sizeof(szCmd2));
	
	/// Capture call for medic commands (represented by "voicemenu 0 0")
	BaseBoss boss = BaseBoss(client);
	if( szCmd1[0] == '0' && szCmd2[0] == '0' && boss.bIsBoss )
		ManageBossMedicCall(boss);
	
	return Plugin_Continue;
}

public Action DoTaunt(int client, const char[] command, int argc)
{
	if( !cvarVSH2[Enabled].BoolValue )
		return Plugin_Continue;
	
	BaseBoss boss = BaseBoss(client);
	if( boss.flRAGE >= 100.0 ) {
		ManageBossTaunt(boss);
	}
	return Plugin_Continue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if( !cvarVSH2[Enabled].BoolValue )
		return;
	else if( !strncmp(classname, "tf_weapon_", 10, false) && IsValidEntity(entity) )
		CreateTimer( 0.2, OnWeaponSpawned, EntIndexToEntRef(entity) );
	
	ManageEntityCreated(entity, classname);
}

public Action OnWeaponSpawned(Handle timer, any ref)
{
	int wep = EntRefToEntIndex(ref);
	if( IsValidEntity(wep) ) {
		int client = GetOwner(wep);
		if( IsValidClient(client) && GetClientTeam(client) == VSH2Team_Red ) {
			int slot = GetSlotFromWeapon(client, wep);
			if( slot<2 && slot>=0 ) {
				Munitions[client][slot][0] = GetWeaponAmmo(wep);
				Munitions[client][slot][1] = GetWeaponClip(wep);
			}
		}
	}
	return Plugin_Continue;
}

/// scores kept glitching out and I hate debugging so I made it its own func.
public void ShowPlayerScores()
{
	BaseBoss hTop[3];
	BaseBoss(0).iDamage = 0;
	BaseBoss player;
	for( int i=MaxClients; i; --i ) {
		if( !IsValidClient(i) || GetClientTeam(i) <= VSH2Team_Spectator )
			continue;
		
		player = BaseBoss(i);
		if( player.bIsBoss ) {
			player.iDamage = 0;
			continue;
		}
		else if( player.iDamage == 0 )
			continue;
		
		if( player.iDamage >= hTop[0].iDamage ) {
			hTop[2] = hTop[1];
			hTop[1] = hTop[0];
			hTop[0] = player;
		} else if( player.iDamage >= hTop[1].iDamage ) {
			hTop[2] = hTop[1];
			hTop[1] = player;
		}
		else if( player.iDamage >= hTop[2].iDamage )
			hTop[2] = player;
	}
	if( hTop[0].iDamage > 9000 )
		SetPawnTimer(OverNineThousand, 1.0);    /// in stocks.inc
	
	char score1[PATH], score2[PATH], score3[PATH];
	if( hTop[0].index )
		GetClientName(hTop[0].index, score1, PATH);
	else {
		strcopy(score1, PATH, "nil");
		hTop[0] = view_as< BaseBoss >(0);
	}
	
	if( hTop[1].index )
		GetClientName(hTop[1].index, score2, PATH);
	else {
		strcopy(score2, PATH, "nil");
		hTop[1] = view_as< BaseBoss >(0);
	}
	
	if( hTop[2].index )
		GetClientName(hTop[2].index, score3, PATH);
	else {
		strcopy(score3, PATH, "nil");
		hTop[2] = view_as< BaseBoss >(0);
	}
	SetHudTextParams(-1.0, 0.35, 10.0, 255, 255, 255, 255);
	
	/// Should clear center text
	PrintCenterTextAll("");
	
	for( int i=MaxClients; i; --i ) {
		if( !IsClientValid(i) )
			continue;
		if( !(GetClientButtons(i) & IN_SCORE) ) {
			player = BaseBoss(i);
			ShowHudText(i, -1, "Most damage dealt by:\n1)%i - %s\n2)%i - %s\n3)%i - %s\n\nDamage Dealt: %i", hTop[0].iDamage, score1, hTop[1].iDamage, score2, hTop[2].iDamage, score3, player.iDamage);
		}
	}
}

public void CalcScores()
{
	BaseBoss player;
	for( int i=MaxClients; i; --i ) {
		if( !IsClientValid(i) || GetClientTeam(i) < VSH2Team_Red )
			continue;
		
		/// We don't want the Bosses getting free points for doing damage.
		player = BaseBoss(i);
		if( player.bIsBoss )
			continue;
		else {
			int queue_gain = cvarVSH2[QueueGained].IntValue;
			int queue = (cvarVSH2[DamageQueue].BoolValue) ? queue_gain + (player.iDamage / cvarVSH2[DamageForQueue].IntValue) : queue_gain;
			int points = player.iDamage / cvarVSH2[DamagePoints].IntValue;
			
			Action act = Call_OnScoreTally(player, points, queue);
			if( act > Plugin_Changed )
				continue;
			
			Event scoring = CreateEvent("player_escort_score", true);
			scoring.SetInt("player", i);
			scoring.SetInt("points", points);
			scoring.Fire();
			
			player.iQueue += queue;
			CPrintToChat(i, "{olive}[VSH 2] Queue{default} You gained %i queue points.", queue);
			CPrintToChat(i, "{olive}[VSH 2] Queue{default} You scored %i points.", points);
		}
	}
}

public Action Timer_DrawGame(Handle timer)
{
	if( gamemode.iHealthBarPercent < cvarVSH2[HealthPercentForLastGuy].IntValue || gamemode.iRoundState != StateRunning || gamemode.iTimeLeft < 0 )
		return Plugin_Stop;
	
	int time = gamemode.iTimeLeft;
	gamemode.iTimeLeft--;
	char strTime[10];
	
	if( time/60 > 9 )
		IntToString(time/60, strTime, 6);
	else Format(strTime, sizeof(strTime), "0%i", time/60);
	
	if( time%60 > 9 )
		Format(strTime, sizeof(strTime), "%s:%i", strTime, time%60);
	else Format(strTime, sizeof(strTime), "%s:0%i" , strTime, time%60);
	
	SetHudTextParams(-1.0, 0.17, 1.1, 255, 255, 255, 255);
	for( int i=MaxClients; i; --i ) {
		if( !IsValidClient(i) )
			continue;
		ShowSyncHudText(i, timeleftHUD, strTime);
	}
	switch( time ) {
		case 60: EmitSoundToAll("vo/announcer_ends_60sec.mp3");
		case 30: EmitSoundToAll("vo/announcer_ends_30sec.mp3");
		case 10: EmitSoundToAll("vo/announcer_ends_10sec.mp3");
		case 1, 2, 3, 4, 5: {
			char sound[PLATFORM_MAX_PATH];
			Format(sound, PLATFORM_MAX_PATH, "vo/announcer_ends_%isec.mp3", time);
			EmitSoundToAll(sound);
		}
		
		/// Thx MasterOfTheXP
		case 0: {
			ForceTeamWin(VSH2Team_Boss);
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

public void _ResetMediCharge(const int entid)
{
	int medigun = EntRefToEntIndex(entid); 
	if( medigun > MaxClients && IsValidEntity(medigun) )
		SetMediCharge(medigun, GetMediCharge(medigun) + cvarVSH2[MedigunReset].FloatValue);
}

public Action Timer_UberLoop(Handle timer, any medigunid)
{
	int medigun = EntRefToEntIndex(medigunid);
	if( medigun && IsValidEntity(medigun) && gamemode.iRoundState == StateRunning ) {
		int medic = GetOwner(medigun);
		float charge = GetMediCharge(medigun);
		if( charge > 0.05 ) {
			BaseBoss med = BaseBoss(medic);
			int target = med.GetHealTarget();
			Action act = Call_OnUberLoop(med, BaseBoss(target));
			if( act==Plugin_Stop )
				return act;
			
			TF2_AddCondition(medic, TFCond_CritOnWin, 0.5);
			if( IsClientValid(target) && IsPlayerAlive(target) ) {
				TF2_AddCondition(target, TFCond_CritOnWin, 0.5);
				med.iUberTarget = GetClientUserId(target);
			}
			else med.iUberTarget = 0;
		} else if( charge < 0.05 ) {
			SetPawnTimer(_ResetMediCharge, 3.0, EntIndexToEntRef(medigun));
			return Plugin_Stop;
		}
	}
	else return Plugin_Stop;
	return Plugin_Continue;
}
public void _MusicPlay()
{
	if( !cvarVSH2[Enabled].BoolValue || !cvarVSH2[EnableMusic].BoolValue || gamemode.iRoundState != StateRunning )
		return;
	
	float currtime = GetGameTime();
	if( gamemode.flMusicTime > currtime )
		return;
	
	char sound[PLATFORM_MAX_PATH];
	float time = -1.0;
	ManageMusic(sound, time);	/// in handler.sp
	
	BaseBoss boss;
	float vol = cvarVSH2[MusicVolume].FloatValue;
	if( sound[0] != '\0' ) {
		strcopy(BackgroundSong, PLATFORM_MAX_PATH, sound);
		//Format(sound, PLATFORM_MAX_PATH, "#%s", sound);
		for( int i=MaxClients; i; --i ) {
			if( !IsClientValid(i) )
				continue;
			
			boss = BaseBoss(i);
			if( boss.bNoMusic )
				continue;
			EmitSoundToClient(i, sound, _, _, SNDLEVEL_NORMAL, SND_NOFLAGS, vol, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
			//ClientCommand(i, "playgamesound \"%s\"", sound);
		}
	}
	if( time != -1.0 ) {
		gamemode.flMusicTime = currtime+time;
	}
}


int GetRandomBossType(int[] boss_filter, int filter_size=0)
{
	int bosses_size = MAXBOSS + 1;
	int[] bosses = new int[bosses_size];
	
	int count;
	for( int i; i<MAXBOSS; i++ ) {
		bool filtered;
		for( int n; n<filter_size; n++ ) {
			if( boss_filter[n] >= bosses_size )
				continue;
			else if( boss_filter[n]==i ) {
				filtered = true;
				break;
			}
		}
		if( !filtered )
			bosses[count++] = i;
	}
	return bosses[GetRandomInt(0, count)];
}

public int RegisterBoss(const char modulename[MAX_BOSS_NAME_SIZE])
{
	if( !ValidateName(modulename) ) {
		LogError("VSH2 :: Boss Registrar: **** Invalid Name For Boss Module: '%s' ****", modulename);
		return -1;
	} else if( g_hBossesRegistered.FindString(modulename) != -1 ) {
		LogError("VSH2 :: Boss Registrar: **** Plugin '%s' Already Registered ****", modulename);
		return -1;
	}
	g_hBossesRegistered.PushString(modulename);
	return MAXBOSS;
}


public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("VSH2_RegisterPlugin", Native_RegisterBoss);
	CreateNative("VSH2_Hook", Native_Hook);
	CreateNative("VSH2_HookEx", Native_HookEx);
	
	CreateNative("VSH2_Unhook", Native_Unhook);
	CreateNative("VSH2_UnhookEx", Native_UnhookEx);
	CreateNative("VSH2_GetRandomBossType", Native_GetRandomBossType);
	
	CreateNative("VSH2Player.VSH2Player", Native_VSH2Instance);
	
	CreateNative("VSH2Player.userid.get", Native_VSH2GetUserid);
	CreateNative("VSH2Player.index.get", Native_VSH2GetIndex);
	
	CreateNative("VSH2Player.GetProperty", Native_VSH2_getProperty);
	CreateNative("VSH2Player.SetProperty", Native_VSH2_setProperty);
	
	/// type safe versions of VSH2Player::GetProperty & VSH2Player::SetProperty.
	CreateNative("VSH2Player.GetPropInt", Native_VSH2_getIntProp);
	CreateNative("VSH2Player.GetPropFloat", Native_VSH2_getFloatProp);
	CreateNative("VSH2Player.GetPropAny", Native_VSH2_getProperty);
	
	CreateNative("VSH2Player.SetPropInt", Native_VSH2_setIntProp);
	CreateNative("VSH2Player.SetPropFloat", Native_VSH2_setFloatProp);
	CreateNative("VSH2Player.SetPropAny", Native_VSH2_setProp);
	
	/// VSH2 Fighter Methods
	CreateNative("VSH2Player.ConvertToMinion", Native_VSH2_ConvertToMinion);
	CreateNative("VSH2Player.SpawnWeapon", Native_VSH2_SpawnWep);
	CreateNative("VSH2Player.GetWeaponSlotIndex", Native_VSH2_GetWeaponSlotIndex);
	CreateNative("VSH2Player.SetWepInvis", Native_VSH2_SetWepInvis);
	CreateNative("VSH2Player.SetOverlay", Native_VSH2_SetOverlay);
	CreateNative("VSH2Player.TeleToSpawn", Native_VSH2_TeleToSpawn);
	CreateNative("VSH2Player.IncreaseHeadCount", Native_VSH2_IncreaseHeadCount);
	CreateNative("VSH2Player.SpawnSmallHealthPack", Native_VSH2_SpawnSmallHealthPack);
	CreateNative("VSH2Player.ForceTeamChange", Native_VSH2_ForceTeamChange);
	CreateNative("VSH2Player.ClimbWall", Native_VSH2_ClimbWall);
	CreateNative("VSH2Player.HelpPanelClass", Native_VSH2_HelpPanelClass);
	CreateNative("VSH2Player.GetAmmoTable", Native_VSH2_GetAmmoTable);
	CreateNative("VSH2Player.SetAmmoTable", Native_VSH2_SetAmmoTable);
	CreateNative("VSH2Player.GetClipTable", Native_VSH2_GetClipTable);
	CreateNative("VSH2Player.SetClipTable", Native_VSH2_SetClipTable);
	CreateNative("VSH2Player.GetHealTarget", Native_VSH2_GetHealTarget);
	CreateNative("VSH2Player.IsNearDispenser", Native_VSH2_IsNearDispenser);
	CreateNative("VSH2Player.IsInRange", Native_VSH2_IsInRange);
	CreateNative("VSH2Player.RemoveBack", Native_VSH2_RemoveBack);
	CreateNative("VSH2Player.FindBack", Native_VSH2_FindBack);
	CreateNative("VSH2Player.ShootRocket", Native_VSH2_ShootRocket);
	
	/// VSH2 Boss Methods
	CreateNative("VSH2Player.ConvertToBoss", Native_VSH2_ConvertToBoss);
	CreateNative("VSH2Player.GiveRage", Native_VSH2_GiveRage);
	CreateNative("VSH2Player.MakeBossAndSwitch", Native_VSH2_MakeBossAndSwitch);
	CreateNative("VSH2Player.DoGenericStun", Native_VSH2_DoGenericStun);
	CreateNative("VSH2Player.RemoveAllItems", Native_VSH2_RemoveAllItems);
	CreateNative("VSH2Player.GetName", Native_VSH2_GetName);
	CreateNative("VSH2Player.SetName", Native_VSH2_SetName);
	CreateNative("VSH2Player.SuperJump", Native_VSH2_SuperJump);
	CreateNative("VSH2Player.WeighDown", Native_VSH2_WeighDown);
	CreateNative("VSH2Player.PlayVoiceClip", Native_VSH2_PlayVoiceClip);
	
	/// VSH2 Game Mode Managers Methods
	CreateNative("VSH2GameMode_GetProperty", Native_VSH2GameMode_GetProperty);
	CreateNative("VSH2GameMode_SetProperty", Native_VSH2GameMode_SetProperty);
	
	CreateNative("VSH2GameMode_FindNextBoss", Native_VSH2GameMode_FindNextBoss);
	CreateNative("VSH2GameMode_GetRandomBoss", Native_VSH2GameMode_GetRandomBoss);
	CreateNative("VSH2GameMode_GetBossByType", Native_VSH2GameMode_GetBossByType);
	CreateNative("VSH2GameMode_CountMinions", Native_VSH2GameMode_CountMinions);
	CreateNative("VSH2GameMode_CountBosses", Native_VSH2GameMode_CountBosses);
	CreateNative("VSH2GameMode_GetTotalBossHealth", Native_VSH2GameMode_GetTotalBossHealth);
	CreateNative("VSH2GameMode_SearchForItemPacks", Native_VSH2GameMode_SearchForItemPacks);
	CreateNative("VSH2GameMode_UpdateBossHealth", Native_VSH2GameMode_UpdateBossHealth);
	CreateNative("VSH2GameMode_GetBossType", Native_VSH2GameMode_GetBossType);
	CreateNative("VSH2GameMode_GetTotalRedPlayers", Native_VSH2GameMode_GetTotalRedPlayers);
	CreateNative("VSH2GameMode_GetHUDHandle", Native_VSH2GameMode_GetHUDHandle);
	CreateNative("VSH2GameMode_GetBosses", Native_VSH2GameMode_GetBosses);
	CreateNative("VSH2GameMode_IsVSHMap", Native_VSH2GameMode_IsVSHMap);
	
	CreateNative("VSH2_GetMaxBosses", Native_VSH2_GetMaxBosses);
#if defined _steamtools_included
	MarkNativeAsOptional("Steam_SetGameDescription");
#endif
#if defined _tf2attributes_included
	MarkNativeAsOptional("TF2Attrib_SetByDefIndex");
	MarkNativeAsOptional("TF2Attrib_RemoveByDefIndex");
#endif
	RegPluginLibrary("VSH2");
	return APLRes_Success;
}

public int Native_RegisterBoss(Handle plugin, int numParams)
{
	char module_name[MAX_BOSS_NAME_SIZE]; GetNativeString(1, module_name, sizeof(module_name));
	/// ALL PROPS TO COOKIES.NET AKA COOKIES.IO
	return RegisterBoss(module_name);
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
	any item;
	if( hPlayerFields[player.index].GetValue(prop_name, item) )
		return item;
	return 0;
}
public int Native_VSH2_setProperty(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	any item = GetNativeCell(3);
	hPlayerFields[player.index].SetValue(prop_name, item);
}

public int Native_VSH2_getIntProp(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	int item;
	if( hPlayerFields[player.index].GetValue(prop_name, item) )
		return item;
	return 0;
}
public int Native_VSH2_setIntProp(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	int item = GetNativeCell(3);
	return hPlayerFields[player.index].SetValue(prop_name, item);
}

public int Native_VSH2_getFloatProp(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	float item;
	if( hPlayerFields[player.index].GetValue(prop_name, item) )
		return view_as< int >(item);
	return 0;
}
public int Native_VSH2_setFloatProp(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	float item = GetNativeCell(3);
	return hPlayerFields[player.index].SetValue(prop_name, item);
}

public int Native_VSH2_setProp(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	any item = GetNativeCell(3);
	return hPlayerFields[player.index].SetValue(prop_name, item);
}

public int Native_Hook(Handle plugin, int numParams)
{
	int vsh2Hook = GetNativeCell(1);
	Function Func = GetNativeFunction(2);
	if( g_hForwards[vsh2Hook] != null )
		g_hForwards[vsh2Hook].Add(plugin, Func);
}

public int Native_HookEx(Handle plugin, int numParams)
{
	int vsh2Hook = GetNativeCell(1);
	Function Func = GetNativeFunction(2);
	if( g_hForwards[vsh2Hook] != null )
		return g_hForwards[vsh2Hook].Add(plugin, Func);
	return 0;
}

public int Native_Unhook(Handle plugin, int numParams)
{
	int vsh2Hook = GetNativeCell(1);
	if( g_hForwards[vsh2Hook] != null )
		g_hForwards[vsh2Hook].Remove(plugin, GetNativeFunction(2));
}
public int Native_UnhookEx(Handle plugin, int numParams)
{
	int vsh2Hook = GetNativeCell(1);
	if( g_hForwards[vsh2Hook] != null )
		return g_hForwards[vsh2Hook].Remove(plugin, GetNativeFunction(2));
	return 0;
}

public int Native_GetRandomBossType(Handle plugin, int numParams)
{
	int filter_size = GetNativeCell(2);
	int[] filter = new int[filter_size];
	GetNativeArray(1, filter, filter_size);
	return GetRandomBossType(filter, filter_size);
}


public int Native_VSH2_ConvertToMinion(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	float spawntime = view_as< float >( GetNativeCell(2) );
	player.ConvertToMinion(spawntime);
}
public int Native_VSH2_SpawnWep(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char classname[64]; GetNativeString(2, classname, 64);
	int itemindex = GetNativeCell(3);
	int level = GetNativeCell(4);
	int quality = GetNativeCell(5);
	char attributes[128]; GetNativeString(6, attributes, 128);
	return player.SpawnWeapon(classname, itemindex, level, quality, attributes);
}

public int Native_VSH2_GetWeaponSlotIndex(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int slot = GetNativeCell(2);
	return player.GetWeaponSlotIndex(slot);
}

public int Native_VSH2_SetWepInvis(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int alpha = GetNativeCell(2);
	player.SetWepInvis(alpha);
}

public int Native_VSH2_SetOverlay(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char overlay[256]; GetNativeString(2, overlay, 256);
	player.SetOverlay(overlay);
}

public int Native_VSH2_TeleToSpawn(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int team = GetNativeCell(2);
	return player.TeleToSpawn(team);
}

public int Native_VSH2_IncreaseHeadCount(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.IncreaseHeadCount();
}

public int Native_VSH2_SpawnSmallHealthPack(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int team = GetNativeCell(2);
	player.SpawnSmallHealthPack(team);
}

public int Native_VSH2_ForceTeamChange(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int team = GetNativeCell(2);
	player.ForceTeamChange(team);
}

public int Native_VSH2_ClimbWall(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int wep = GetNativeCell(2);
	float spawntime = view_as< float >( GetNativeCell(3) );
	float healthdmg = view_as< float >( GetNativeCell(4) );
	bool attackdelay = GetNativeCell(5);
	return view_as< int >(player.ClimbWall(wep, spawntime, healthdmg, attackdelay));
}

public int Native_VSH2_HelpPanelClass(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.HelpPanelClass();
}

public int Native_VSH2_GetAmmoTable(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int slot = GetNativeCell(2);
	return player.getAmmotable(slot);
}

public int Native_VSH2_SetAmmoTable(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.setAmmotable(GetNativeCell(2), GetNativeCell(3));
}

public int Native_VSH2_GetClipTable(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int slot = GetNativeCell(2);
	return player.getCliptable(slot);
}

public int Native_VSH2_SetClipTable(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.setCliptable(GetNativeCell(2), GetNativeCell(3));
}

public int Native_VSH2_GetHealTarget(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.GetHealTarget();
}

public int Native_VSH2_IsNearDispenser(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.IsNearDispenser();
}

public int Native_VSH2_IsInRange(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	float distance = GetNativeCell(3);
	return view_as< int >(player.IsInRange(GetNativeCell(2), distance, GetNativeCell(4)));
}

public int Native_VSH2_RemoveBack(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int length = GetNativeCell(3);
	any[] data = new any[length];
	GetNativeArray(2, data, length);
	player.RemoveBack(data, length);
}

public int Native_VSH2_FindBack(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int length = GetNativeCell(3);
	any[] data = new any[length];
	GetNativeArray(2, data, length);
	return player.FindBack(data, length);
}

public int Native_VSH2_ShootRocket(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	bool crit = GetNativeCell(2);
	float vpos[3]; GetNativeArray(3, vpos, 3);
	float vang[3]; GetNativeArray(4, vang, 3);
	float speed = GetNativeCell(5);
	float dmg = GetNativeCell(6);
	char modelname[PLATFORM_MAX_PATH]; GetNativeString(7, modelname, PLATFORM_MAX_PATH);
	bool arc = GetNativeCell(8);
	
	return player.ShootRocket(crit, vpos, vang, speed, dmg, modelname, arc);
}


public int Native_VSH2_ConvertToBoss(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.ConvertToBoss();
}

public int Native_VSH2_GiveRage(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int dmg = GetNativeCell(2);
	player.GiveRage(dmg);
}

public int Native_VSH2_MakeBossAndSwitch(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int bossid = GetNativeCell(2);
	bool callEvent = GetNativeCell(2);
	player.MakeBossAndSwitch(bossid, callEvent);
}

public int Native_VSH2_DoGenericStun(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	float rage_radius = GetNativeCell(2);
	player.DoGenericStun(rage_radius);
}

public int Native_VSH2_RemoveAllItems(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.RemoveAllItems();
}

public int Native_VSH2_GetName(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char name[MAX_BOSS_NAME_SIZE];
	bool res = player.GetName(name);
	SetNativeString(2, name, sizeof(name), true);
	return view_as< int >(res);
}

public int Native_VSH2_SetName(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char name[MAX_BOSS_NAME_SIZE];
	GetNativeString(2, name, sizeof(name));
	return view_as< int >(player.SetName(name));
}

public int Native_VSH2_SuperJump(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	float power = GetNativeCell(2);
	float reset = GetNativeCell(3);
	player.SuperJump(power, reset);
	return 0;
}

public int Native_VSH2_WeighDown(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	float reset = GetNativeCell(2);
	player.WeighDown(reset);
	return 0;
}

public int Native_VSH2_PlayVoiceClip(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char sound[PLATFORM_MAX_PATH]; GetNativeString(2, sound, sizeof(sound));
	int flags = GetNativeCell(3);
	player.PlayVoiceClip(sound, flags);
	return 0;
}


public int Native_VSH2GameMode_GetProperty(Handle plugin, int numParams)
{
	char prop_name[64]; GetNativeString(1, prop_name, sizeof(prop_name));
	any item;
	if( hGameModeFields.GetValue(prop_name, item) ) {
		return item;
	}
	return 0;
}
public int Native_VSH2GameMode_SetProperty(Handle plugin, int numParams)
{
	char prop_name[64]; GetNativeString(1, prop_name, sizeof(prop_name));
	any item = GetNativeCell(2);
	hGameModeFields.SetValue(prop_name, item);
}
public int Native_VSH2GameMode_GetRandomBoss(Handle plugin, int numParams)
{
	bool alive = GetNativeCell(1);
	return view_as< int >(gamemode.GetRandomBoss(alive));
}
public int Native_VSH2GameMode_GetBossByType(Handle plugin, int numParams)
{
	bool alive = GetNativeCell(1);
	int bossid = GetNativeCell(2);
	return view_as< int >(gamemode.GetBossByType(alive, bossid));
}
public int Native_VSH2GameMode_FindNextBoss(Handle plugin, int numParams)
{
	return view_as< int >(gamemode.FindNextBoss());
}
public int Native_VSH2GameMode_CountMinions(Handle plugin, int numParams)
{
	bool alive = GetNativeCell(1);
	return gamemode.CountMinions(alive);
}
public int Native_VSH2GameMode_CountBosses(Handle plugin, int numParams)
{
	bool alive = GetNativeCell(1);
	return gamemode.CountBosses(alive);
}
public int Native_VSH2GameMode_GetTotalBossHealth(Handle plugin, int numParams)
{
	return gamemode.GetTotalBossHealth();
}
public int Native_VSH2GameMode_SearchForItemPacks(Handle plugin, int numParams)
{
	gamemode.SearchForItemPacks();
}
public int Native_VSH2GameMode_UpdateBossHealth(Handle plugin, int numParams)
{
	gamemode.UpdateBossHealth();
}
public int Native_VSH2GameMode_GetBossType(Handle plugin, int numParams)
{
	gamemode.GetBossType();
}

public int Native_VSH2GameMode_GetTotalRedPlayers(Handle plugin, int numParams)
{
	return gamemode.iPlaying;
}

public int Native_VSH2GameMode_GetHUDHandle(Handle plugin, int numParams)
{
	return view_as< int >(hHudText);
}

public int Native_VSH2GameMode_GetBosses(Handle plugin, int numParams)
{
	BaseBoss[] bosses = new BaseBoss[MaxClients];
	bool balive = GetNativeCell(2);
	int numbosses = gamemode.GetBosses(bosses, balive);
	SetNativeArray(1, bosses, MaxClients);
	return numbosses;
}

public int Native_VSH2GameMode_IsVSHMap(Handle plugin, int numParams)
{
	return gamemode.IsVSHMap();
}

public int Native_VSH2_GetMaxBosses(Handle plugin, int numParams)
{
	return MAXBOSS;
}
