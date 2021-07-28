#include <sourcemod>
#include <sdktools>
#include <clientprefs>
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

#define UPDATE_URL    "https://raw.githubusercontent.com/VSH2-Devs/Vs-Saxton-Hale-2/develop/updater.txt"

#pragma semicolon            1
#pragma newdecls             required

#define PLUGIN_VERSION       "2.12.0"
#define PLUGIN_DESCRIPT      "VS Saxton Hale 2"


enum {
	PLYR = 35,
	PATH = 64
};


public Plugin myinfo = {
	name             = "Vs Saxton Hale 2 Mod",
	author           = "Nergal/assyrian, props to Flamin' Sarge, Chdata, Scags, & Buzzkillington",
	description      = "Allows Players to play as various bosses of TF2",
	version          = PLUGIN_VERSION,
	url              = "https://forums.alliedmods.net/showthread.php?t=286701"
};


enum struct VSH2Cvars {
	ConVar PointType;
	ConVar PointDelay;
	ConVar AliveToEnable;
	ConVar FirstRound;
	ConVar DamagePoints;
	ConVar DamageQueue;
	ConVar QueueGained;
	ConVar EnableMusic;
	ConVar MusicVolume;
	ConVar HealthPercentForLastGuy;
	ConVar HealthRegenForPlayers;
	ConVar HealthRegenAmount;
	ConVar MedigunReset;
	ConVar StopTickleTime;
	ConVar AirStrikeDamage;
	ConVar AirblastRage;
	ConVar JarateRage;
	ConVar FanoWarRage;
	ConVar LastPlayerTime;
	ConVar EngieBuildings;
	ConVar MedievalLives;
	ConVar MedievalRespawnTime;
	ConVar PermOverheal;
	ConVar MultiCapture;
	ConVar MultiCapAmount;
	ConVar DemoShieldCrits;
	ConVar CanBossGoomba;
	ConVar CanMantreadsGoomba;
	ConVar GoombaDamageAdd;
	ConVar GoombaLifeMultiplier;
	ConVar GoombaReboundPower;
	ConVar MultiBossHandicap;
	ConVar DroppedWeapons;
	ConVar BlockEureka;
	ConVar ForceLives;
	ConVar Anchoring;
	ConVar BlockRageSuicide;
	ConVar HealthKitLimitMax;
	ConVar HealthKitLimitMin;
	ConVar AmmoKitLimitMax;
	ConVar AmmoKitLimitMin;
	ConVar ShieldRegenDmgReq;
	ConVar AllowRandomMultiBosses;
	ConVar HHHMaxClimbs;
	ConVar HealthCheckInitialDelay;
	ConVar ScoutRageGen;
	ConVar SydneySleeperRageRemove;
	ConVar DamageForQueue;
	ConVar DeadRingerDamage;
	ConVar CloakDamage;
	ConVar Enabled;
	ConVar AllowLateSpawn;
	ConVar SuicidePercent;
	ConVar AirShotDist;
	ConVar MedicUberShield;
	ConVar HHHClimbVelocity;
	ConVar SniperClimbVelocity;
	ConVar ShowBossHPLiving;
	ConVar HHHTeleCooldown;
	ConVar MaxRandomMultiBosses;
	ConVar VagineerUberTime;
	ConVar VagineerUberAirBlast;
	ConVar CapReenableTime;
	ConVar AllowSniperClimbing;
	ConVar PreRoundSetBoss;
	ConVar ChangeAmmoPacks;
	ConVar ThirdDegreeUberGain;
	ConVar UberDeployChargeAmnt;
	ConVar StartUberChargeAmnt;
	ConVar SniperClimbDmg;
	ConVar AutoUpdate;
	ConVar PlayerMusic;
	ConVar LateSpawnDelay;
	ConVar MaxDemoKnightOverheal;
	ConVar SwordHeadHPAdd;
	ConVar TriggerHurtThreshold;
	ConVar MaxTriggerHurtDmg;
	ConVar MidRoundSpawnUber;
	ConVar MaxBossGlowTime;
	ConVar OnHitPhlogTaunt;
	ConVar SpyHeadMult;
	ConVar DiamondMelterBaseDmg;
	ConVar KatanaMaxOverheal;
	ConVar KatanaHealth;
	ConVar PowerJackHealth;
	ConVar PowerJackMaxOverheal;
	ConVar OnHitBattalions;
	ConVar KunaiHealthAdd;
	ConVar KunaiHealthGuard;
	ConVar KunaiHealthLimit;
	ConVar TeleFragLogic;
	ConVar TeleFragDamage;
	ConVar BootStompLogic;
	ConVar BootStompDamage;
	ConVar VersionNumber;
}

enum /** Cookies */ {
	Points, BossOpt, MusicOpt, MaxVSH2Cookies
};

enum struct BossModule {
	char   name[MAX_BOSS_NAME_SIZE];
	Handle plugin;
}

PrivateForward g_hForwards[2][MaxVSH2Forwards];
enum struct VSH2ModuleSys {
	ArrayList m_hBossesRegistered; /// []BossModule
	StringMap m_hBossMap;          /// map[Plugin]int
	
	bool IsPluginABoss(Handle plugin, int &index=-1) {
		char pl_hash[CELL_KEY_SIZE]; PackItem(plugin, pl_hash);
		return this.m_hBossMap.GetValue(pl_hash, index);
	}
	
	PrivateForward GetForward(bool bosses, int index) {
		if( !IsIntInBounds(index, MaxVSH2Forwards-1, 0) ) {
			return null;
		}
		return g_hForwards[view_as< int >(bosses)][index];
	}
}

enum struct VSH2Globals {
	Handle m_hHUDs[MaxVSH2HUDs];
	Cookie m_hCookies[MaxVSH2Cookies];
	VSH2Cvars m_hCvars;
	VSHGameMode m_hGamemode;
	char m_strCurrSong[PLATFORM_MAX_PATH];

	ConfigMap m_hCfg;
	/// When making new properties, remember to base it off this StringMap
	/// AND do NOT forget to initialize it in 'OnClientPutInServer'.
	StringMap m_hPlayerFields[PLYR];
}

VSH2Globals   g_vsh2;
VSH2ModuleSys g_modsys;

#include "modules/stocks.inc" /// include stocks first.
#include "modules/handler.sp" /// Contains the game mode logic as well
#include "modules/events.sp"
#include "modules/commands.sp"

public void OnPluginStart()
{
	g_vsh2.m_hGamemode = new VSHGameMode();
	g_vsh2.m_hGamemode.Init();

	/// in forwards.sp
	InitializeForwards();

	RegAdminCmd("sm_setspecial",   SetNextSpecial, ADMFLAG_GENERIC);
	RegAdminCmd("sm_halespecial",  SetNextSpecial, ADMFLAG_GENERIC);
	RegAdminCmd("sm_hale_special", SetNextSpecial, ADMFLAG_GENERIC);
	RegAdminCmd("sm_bossspecial",  SetNextSpecial, ADMFLAG_GENERIC);
	RegAdminCmd("sm_boss_special", SetNextSpecial, ADMFLAG_GENERIC);
	RegAdminCmd("sm_ff2special",   SetNextSpecial, ADMFLAG_GENERIC);
	RegAdminCmd("sm_ff2_special",  SetNextSpecial, ADMFLAG_GENERIC);

	RegConsoleCmd("sm_hale_next",  QueuePanelCmd);
	RegConsoleCmd("sm_halenext",   QueuePanelCmd);
	RegConsoleCmd("sm_boss_next",  QueuePanelCmd);
	RegConsoleCmd("sm_bossnext",   QueuePanelCmd);
	RegConsoleCmd("sm_ff2_next",   QueuePanelCmd);
	RegConsoleCmd("sm_ff2next",    QueuePanelCmd);

	RegConsoleCmd("sm_hale_hp",    Command_GetHPCmd);
	RegConsoleCmd("sm_halehp",     Command_GetHPCmd);
	RegConsoleCmd("sm_boss_hp",    Command_GetHPCmd);
	RegConsoleCmd("sm_bosshp",     Command_GetHPCmd);
	RegConsoleCmd("sm_ff2_hp",     Command_GetHPCmd);
	RegConsoleCmd("sm_ff2hp",      Command_GetHPCmd);

	RegConsoleCmd("sm_setboss",    SetBossMenu, "Sets your boss.");
	RegConsoleCmd("sm_sethale",    SetBossMenu, "Sets your boss.");
	RegConsoleCmd("sm_ff2boss",    SetBossMenu, "Sets your boss.");
	RegConsoleCmd("sm_haleboss",   SetBossMenu, "Sets your boss.");

	RegConsoleCmd("sm_halemusic",  MusicTogglePanelCmd);
	RegConsoleCmd("sm_hale_music", MusicTogglePanelCmd);
	RegConsoleCmd("sm_bossmusic",  MusicTogglePanelCmd);
	RegConsoleCmd("sm_boss_music", MusicTogglePanelCmd);
	RegConsoleCmd("sm_ff2music",   MusicTogglePanelCmd);
	RegConsoleCmd("sm_ff2_music",  MusicTogglePanelCmd);

	RegConsoleCmd("sm_halehelp",   HelpPanelCmd);
	RegConsoleCmd("sm_hale_help",  HelpPanelCmd);
	RegConsoleCmd("sm_bosshelp",   HelpPanelCmd);
	RegConsoleCmd("sm_boss_help",  HelpPanelCmd);
	RegConsoleCmd("sm_ff2help",    HelpPanelCmd);
	RegConsoleCmd("sm_ff2_help",   HelpPanelCmd);

	RegConsoleCmd("sm_hale",       HelpPanelCmd);
	RegConsoleCmd("sm_boss",       HelpPanelCmd);
	RegConsoleCmd("sm_ff2",        HelpPanelCmd);

	RegConsoleCmd("sm_resetq",     ResetQueue);
	RegConsoleCmd("sm_resetqueue", ResetQueue);

	RegAdminCmd("sm_vsh2_reloadcfg", CmdReloadCFG, ADMFLAG_GENERIC);

	RegAdminCmd("sm_hale_select",    CommandBossSelect, ADMFLAG_VOTE, "hale_select <target> - Select a player to be next boss.");
	RegAdminCmd("sm_ff2_select",     CommandBossSelect, ADMFLAG_VOTE, "ff2_select <target> - Select a player to be next boss.");
	RegAdminCmd("sm_boss_select",    CommandBossSelect, ADMFLAG_VOTE, "boss_select <target> - Select a player to be next boss.");
	RegAdminCmd("sm_healthbarcolor", ChangeHealthBarColor, ADMFLAG_GENERIC);

	RegAdminCmd("sm_boss_force", ForceBossRealtime, ADMFLAG_VOTE, "boss_force <target> <bossID> - Force a player to the boss team as the specified boss. (Setup time only)");
	RegAdminCmd("sm_hale_force", ForceBossRealtime, ADMFLAG_VOTE, "hale_force <target> <bossID> - Force a player to the boss team as the specified boss. (Setup time only)");
	RegAdminCmd("sm_ff2_force",  ForceBossRealtime, ADMFLAG_VOTE, "ff2_force <target> <bossID> - Force a player to the boss team as the specified boss. (Setup time only)");

	RegAdminCmd("sm_hale_addpoints", CommandAddPoints, ADMFLAG_GENERIC);
	RegAdminCmd("sm_vsh2_addpoints", CommandAddPoints, ADMFLAG_GENERIC);
	RegAdminCmd("sm_ff2_addpoints",  CommandAddPoints, ADMFLAG_GENERIC);

	RegAdminCmd("sm_hale_setpoints", CommandSetPoints, ADMFLAG_GENERIC);
	RegAdminCmd("sm_vsh2_setpoints", CommandSetPoints, ADMFLAG_GENERIC);
	RegAdminCmd("sm_ff2_setpoints",  CommandSetPoints, ADMFLAG_GENERIC);

	RegAdminCmd("sm_hale_classrush", MenuDoClassRush, ADMFLAG_GENERIC, "forces all red players to a class.");
	RegAdminCmd("sm_vsh2_classrush", MenuDoClassRush, ADMFLAG_GENERIC, "forces all red players to a class.");

	AddCommandListener(BlockSuicide,   "explode");
	AddCommandListener(BlockSuicide,   "kill");
	AddCommandListener(BlockSuicide,   "jointeam");
	AddCommandListener(CheckLateSpawn, "joinclass");
	AddCommandListener(CheckLateSpawn, "join_class");
	//AddCommandListener(DoTaunt,        "taunt");
	//AddCommandListener(DoTaunt,        "+taunt");
	
	for( int i; i<MaxVSH2HUDs; i++ ) {
		g_vsh2.m_hHUDs[i] = CreateHudSynchronizer();
	}
	
	g_vsh2.m_hCvars.Enabled = CreateConVar("vsh2_enabled", "1", "Enable VSH 2 plugin", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.VersionNumber = CreateConVar("vsh2_version", PLUGIN_VERSION, "VSH 2 Plugin Version. (DO NOT CHANGE)", FCVAR_NOTIFY);
	g_vsh2.m_hCvars.PointType = CreateConVar("vsh2_point_type", "0", "Select condition to enable point (0 - alive players, 1 - time)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.PointDelay = CreateConVar("vsh2_point_delay", "6", "Addition (for each player) delay before point's activation.", FCVAR_NOTIFY, true, 0.0, false);
	g_vsh2.m_hCvars.AliveToEnable = CreateConVar("vsh2_point_alive", "5", "Enable control points when there are X people left alive.", FCVAR_NOTIFY, true, 1.0, true, 32.0);
	g_vsh2.m_hCvars.FirstRound = CreateConVar("vsh2_firstround", "0", "If 1, allows the first round to start with VSH2 enabled.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.DamagePoints = CreateConVar("vsh2_damage_points", "600", "Amount of damage needed to gain 1 point on the scoreboard.", FCVAR_NOTIFY, true, 1.0, false);
	g_vsh2.m_hCvars.DamageQueue = CreateConVar("vsh2_damage_queue", "1", "Allow damage to influence increase of queue points.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.QueueGained = CreateConVar("vsh2_queue_gain", "10", "How many queue points to give at the end of each round.", FCVAR_NOTIFY, true, 0.0, false);
	g_vsh2.m_hCvars.EnableMusic = CreateConVar("vsh2_enable_music", "1", "Enables boss background music.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.MusicVolume = CreateConVar("vsh2_music_volume", "0.5", "How loud the background music should be, if enabled.", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_vsh2.m_hCvars.HealthPercentForLastGuy = CreateConVar("vsh2_health_percentage_last_guy", "51", "If the health bar is lower than x out of 255, the last player timer will stop.", FCVAR_NOTIFY, true, 0.0, true, 255.0);
	g_vsh2.m_hCvars.HealthRegenForPlayers = CreateConVar("vsh2_health_regen", "0", "Allow non-boss and non-minion players to have passive health regen.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.HealthRegenAmount = CreateConVar("vsh2_health_regen_amount", "1.0", "If health regen is enabled, how much health regen per second should players get?", FCVAR_NOTIFY, true, 0.0, false);
	g_vsh2.m_hCvars.MedigunReset = CreateConVar("vsh2_medigun_reset_amount", "0.31", "How much Uber percentage should Mediguns, after Uber, reset to?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.StopTickleTime = CreateConVar("vsh2_stop_tickle_time", "1.0", "How long in seconds the tickle effect from the Holiday Punch lasts before being removed.", FCVAR_NOTIFY, true, 0.01, false);
	g_vsh2.m_hCvars.AirStrikeDamage = CreateConVar("vsh2_airstrike_damage", "200", "How much damage needed for the Airstrike to gain +1 clipsize.", FCVAR_NOTIFY, true, 0.0, false);
	g_vsh2.m_hCvars.AirblastRage = CreateConVar("vsh2_airblast_rage", "8.0", "How much Rage should airblast give/remove? (negative number to remove rage)", FCVAR_NOTIFY, true, 0.0, false);
	g_vsh2.m_hCvars.JarateRage = CreateConVar("vsh2_jarate_rage", "8.0", "How much rage should Jarate give/remove? (negative number to add rage)", FCVAR_NOTIFY, true, 0.0, false);
	g_vsh2.m_hCvars.FanoWarRage = CreateConVar("vsh2_fanowar_rage", "5.0", "How much rage should the Fan o' War give/remove? (negative number to add rage)", FCVAR_NOTIFY, true, 0.0, false);
	g_vsh2.m_hCvars.LastPlayerTime = CreateConVar("vsh2_lastplayer_time", "180", "How many seconds to give the last player to fight the Boss(es) before a stalemate.", FCVAR_NOTIFY, true, 0.0, false);
	g_vsh2.m_hCvars.EngieBuildings = CreateConVar("vsh2_killbuilding_engiedeath", "1", "If 0, no building dies when engie dies. If 1, only sentry dies. If 2, all buildings die.", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	g_vsh2.m_hCvars.MedievalLives = CreateConVar("vsh2_medievalmode_lives", "3", "Amount of lives red players are entitled during Medieval Mode.", FCVAR_NOTIFY, true, 0.0, true, 99.0);
	g_vsh2.m_hCvars.MedievalRespawnTime = CreateConVar("vsh2_medievalmode_respawntime", "5.0", "How long it takes for players to respawn after dying in medieval mode (if they have lives left).", FCVAR_NOTIFY, true, 1.0, true, 999.0);
	
	/// This is unused.
	g_vsh2.m_hCvars.PermOverheal = CreateConVar("vsh2_permanent_overheal", "0", "If enabled, Mediguns give permanent overheal. (THIS CVAR NO LONGER WORKS.)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	g_vsh2.m_hCvars.MultiCapture = CreateConVar("vsh2_multiple_cp_captures", "1", "If enabled, allow control points to be captured more than once instead of ending the round instantly.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.MultiCapAmount = CreateConVar("vsh2_multiple_cp_capture_amount", "3", "If vsh2_allow_multiple_cp_captures is enabled, how many times must a team capture a Control Point to win.", FCVAR_NOTIFY, true, 1.0, true, 999.0);
	g_vsh2.m_hCvars.DemoShieldCrits = CreateConVar("vsh2_demoman_shield_crits", "2", "Sets Demoman Shield crit behaviour. 0 - No crits, 1 - Mini-crits, 2 - Crits, 3 - Scale with Charge Meter (Losing the Shield results in no more (mini)crits.)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	g_vsh2.m_hCvars.CanBossGoomba = CreateConVar("vsh2_goomba_can_boss_stomp", "1", "Can the Boss Goomba Stomp other players? (Requires Goomba Stomp plugin). NOTE: All the CVARs in VSH2 controlling Goomba damage, lifemultiplier and rebound power are for NON-BOSS PLAYERS STOMPING THE BOSS. If you enable this CVAR, use the Goomba Stomp plugin config file to control the Boss' Goomba Variables. Not recommended to enable this unless you've coded your own Goomba Stomp behaviour.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.CanMantreadsGoomba = CreateConVar("vsh2_goomba_can_mantreads_stomp", "0", "Can Soldiers/Demomen Goomba Stomp the Boss while using the Mantreads/Booties? (Requires Goomba Stomp plugin). NOTE: Enabling this may cause 'double' Stomps (Goomba Stomp and Mantreads stomp together).", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.GoombaDamageAdd = CreateConVar("vsh2_goomba_damage_add", "450.0", "How much damage to add to a Goomba Stomp on the Boss. (Requires Goomba Stomp plugin).", FCVAR_NOTIFY, true, 0.0, false);
	g_vsh2.m_hCvars.GoombaLifeMultiplier = CreateConVar("vsh2_goomba_boss_life_multiplier", "0.025", "What percentage of the Boss' CURRENT HP to deal as damage on a Goomba Stomp. (Requires Goomba Stomp plugin).", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.GoombaReboundPower = CreateConVar("vsh2_rebound_power", "300.0", "How much upwards velocity (in Hammer Units) should players recieve upon Goomba Stomping the Boss? (Requires Goomba Stomp plugin).", FCVAR_NOTIFY, true, 0.0, false);
	g_vsh2.m_hCvars.MultiBossHandicap = CreateConVar("vsh2_multiboss_handicap", "500", "How much Health is removed on every individual boss in a multiboss round at the start of said round. 0 disables it.", FCVAR_NONE, true, 0.0, true, 99999.0);
	g_vsh2.m_hCvars.DroppedWeapons = CreateConVar("vsh2_allow_dropped_weapons", "0", "Enables/Disables dropped weapons. Recommended to keep this disabled to avoid players having weapons they shouldn't.", FCVAR_NONE, true, 0.0, true, 1.0);
	
	/// unused.
	g_vsh2.m_hCvars.BlockEureka = CreateConVar("vsh2_allow_eureka_effect", "0", "Enables/Disables the Eureka Effect for Engineers (THIS CVAR NO LONGER WORKS.)", FCVAR_NONE, true, 0.0, true, 1.0);
	
	g_vsh2.m_hCvars.ForceLives = CreateConVar("vsh2_force_player_lives", "0", "Forces VSH2 to apply Medieval Mode lives on players, whether or not medieval mode is enabled", FCVAR_NONE, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.Anchoring = CreateConVar("vsh2_allow_boss_anchor", "1", "When enabled, reduces all knockback bosses experience when crouching.", FCVAR_NONE, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.BlockRageSuicide = CreateConVar("vsh2_block_raged_suicide", "1", "when enabled, stops raged players from suiciding.", FCVAR_NONE, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.HealthKitLimitMax = CreateConVar("vsh2_spawn_health_kit_limit_max", "6", "max amount of health kits that can be produced in RED spawn. -1 for unlimited amount", FCVAR_NONE, true, -1.0, true, 50.0);
	g_vsh2.m_hCvars.HealthKitLimitMin = CreateConVar("vsh2_spawn_health_kit_limit_min", "4", "minimum amount of health kits that can be produced in RED spawn. -1 for no minimum limit", FCVAR_NONE, true, -1.0, true, 50.0);
	g_vsh2.m_hCvars.AmmoKitLimitMax = CreateConVar("vsh2_spawn_ammo_kit_limit_max", "6", "max amount of ammo kits that can be produced in RED spawn. -1 for unlimited amount", FCVAR_NONE, true, -1.0, true, 50.0);
	g_vsh2.m_hCvars.AmmoKitLimitMin = CreateConVar("vsh2_spawn_ammo_kit_limit_min", "4", "minimum amount of ammo kits that can be produced in RED spawn. -1 for no minimum limit", FCVAR_NONE, true, -1.0, true, 50.0);
	g_vsh2.m_hCvars.ShieldRegenDmgReq = CreateConVar("vsh2_shield_regen_damage", "2000", "damage required for demoknights to regenerate their shield, put 0 to disable.", FCVAR_NONE, true, 0.0, true, 99999.0);
	g_vsh2.m_hCvars.AllowRandomMultiBosses = CreateConVar("vsh2_allow_random_multibosses", "1", "allows VSH2 to make random combinations of various bosses.", FCVAR_NONE, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.HHHMaxClimbs = CreateConVar("vsh2_hhhjr_max_climbs", "10", "maximum amount of climbs HHH Jr. can do.", FCVAR_NONE, true, 0.0, false);
	g_vsh2.m_hCvars.HealthCheckInitialDelay = CreateConVar("vsh2_initial_healthcheck_delay", "30.0", "Initial health check delay when the round starts so as to prevent wasting 10-second health checks.", FCVAR_NONE, true, 0.0, true, 999.0);
	g_vsh2.m_hCvars.ScoutRageGen = CreateConVar("vsh2_scout_rage_gen", "0.2", "rate of how much rage a boss generates when there are only scouts left.", FCVAR_NONE, true, 0.0, true, 99.0);
	g_vsh2.m_hCvars.SydneySleeperRageRemove = CreateConVar("vsh2_sydney_sleeper_rage_remove", "0.01", "how much rage (multiplied with damage) the Sydney Sleeper sniper rifle will remove from a boss' rage meter.", FCVAR_NONE, true, 0.0, false);
	g_vsh2.m_hCvars.DamageForQueue = CreateConVar("vsh2_damage_for_queue", "1000", "if 'vsh2_damage_queue' is enabled, how much queue to give per amount of damage done.", FCVAR_NONE, true, 0.0, false);
	g_vsh2.m_hCvars.DeadRingerDamage = CreateConVar("vsh2_dead_ringer_damage", "90.0", "damage that dead ringer spies will take from boss melee hits.", FCVAR_NONE, true, 0.0, false);
	g_vsh2.m_hCvars.CloakDamage = CreateConVar("vsh2_cloak_damage", "70.0", "damage that cloak spies will take from boss melee hits.", FCVAR_NONE, true, 0.0, false);
	g_vsh2.m_hCvars.AllowLateSpawn = CreateConVar("vsh2_allow_late_spawning", "0", "allows if unassigned spectators can respawn during an active round.", FCVAR_NONE, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.SuicidePercent = CreateConVar("vsh2_boss_suicide_percent", "0.3", "Allow the boss to suicide if their health percentage goes at or below this amount (0.3 == 30%).", FCVAR_NONE, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.AirShotDist = CreateConVar("vsh2_airshot_dist", "80.0", "distance (from the air to the ground) to count as a skilled airshot.", FCVAR_NONE, true, 10.0, false);
	g_vsh2.m_hCvars.MedicUberShield = CreateConVar("vsh2_use_uber_as_shield", "0", "If a medic has nearly full uber (90%+), use the uber as a shield to prevent the medic from getting killed.", FCVAR_NONE, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.HHHClimbVelocity = CreateConVar("vsh2_hhh_climb_velocity", "600.0", "in hammer units, how high of a velocity HHH Jr. will climb.", FCVAR_NONE, true, 0.0, true, 9999.0);
	g_vsh2.m_hCvars.SniperClimbVelocity = CreateConVar("vsh2_sniper_climb_velocity", "600.0", "in hammer units, how high of a velocity sniper melees will climb.", FCVAR_NONE, true, 0.0, false);
	g_vsh2.m_hCvars.ShowBossHPLiving = CreateConVar("vsh2_show_boss_hp_alive_players", "1", "How many players must be alive for total boss hp to show.", FCVAR_NONE, true, 0.0, true, 64.0);
	g_vsh2.m_hCvars.HHHTeleCooldown = CreateConVar("vsh2_hhh_tele_cooldown", "-1100.0", "Teleportation cooldown for HHH Jr. after teleporting. formula is '-seconds * 25' so -1100.0 is 44 seconds", FCVAR_NONE, true, -999999.0, true, 25.0);
	g_vsh2.m_hCvars.MaxRandomMultiBosses = CreateConVar("vsh2_random_multibosses_limit", "2", "The maximum limit of random multibosses", FCVAR_NONE, true, 1.0, true, 5.0);
	g_vsh2.m_hCvars.VagineerUberTime = CreateConVar("vsh2_vagineer_uber_time", "10.0", "The maximum length of the Vagineer boss' uber.", FCVAR_NONE, true, 1.0, false);
	g_vsh2.m_hCvars.VagineerUberAirBlast = CreateConVar("vsh2_vagineer_uber_time_airblast", "2.0", "extra time given to Vagineer's uber when airblasted.", FCVAR_NONE, true, 1.0, false);
	g_vsh2.m_hCvars.CapReenableTime = CreateConVar("vsh2_multiple_cp_capture_reenable_time", "30.0", "time to reenable the control pointer after being captured. Does nothing is 'vsh2_multiple_cp_captures' is disabled.", FCVAR_NONE, true, 1.0, false);
	g_vsh2.m_hCvars.AllowSniperClimbing = CreateConVar("vsh2_allow_sniper_climb", "1", "allow snipers to be able to climb using melee.", FCVAR_NONE, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.PreRoundSetBoss = CreateConVar("vsh2_preround_setboss", "0", "Allow players to change boss during round start phase.", FCVAR_NONE, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.ChangeAmmoPacks = CreateConVar("vsh2_change_ammopacks", "1", "changes all map ammopacks to specific size (1-small, 2-medium, 3-large, 0-no change).", FCVAR_NONE, true, 0.0, true, 3.0);
	g_vsh2.m_hCvars.ThirdDegreeUberGain = CreateConVar("vsh2_thirddegree_uber_gain", "0.1", "how much uber the pyro's third degree will gain for the medic healing said pyro (this value is divided by the amount of medics healing).", FCVAR_NONE, true, 0.0, true, 99.0);
	g_vsh2.m_hCvars.UberDeployChargeAmnt = CreateConVar("vsh2_uber_deploy_charge", "1.51", "how much uber percentage medics will have when they activate uber.", FCVAR_NONE, true, 0.0, true, 99.0);
	g_vsh2.m_hCvars.StartUberChargeAmnt = CreateConVar("vsh2_start_uber_charge", "0.41", "how much uber percentage medics start each round with.", FCVAR_NONE, true, 0.0, true, 99.0);
	g_vsh2.m_hCvars.SniperClimbDmg = CreateConVar("vsh2_sniper_climb_damage", "15.0", "how much damage players should take when using the sniper climb ability.", FCVAR_NONE, true, 0.0, true, 99999.0);
	g_vsh2.m_hCvars.AutoUpdate = CreateConVar("vsh2_auto_update", "1", "has VSH2 automatically update when newest versions are available. Does nothing if updater plugin isn't used.", FCVAR_NONE, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.PlayerMusic = CreateConVar("vsh2_player_specific_music", "0", "makes VSH2 play music on a player specific basis rather than play a set song to all players.", FCVAR_NONE, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.LateSpawnDelay = CreateConVar("vsh2_late_spawn_delay", "1.5", "the delay time after the round has started to allow people to spawn in.", FCVAR_NONE, true, 0.0, true, 10.0);
	
	g_vsh2.m_hCvars.MaxDemoKnightOverheal = CreateConVar("vsh2_sword_max_overheal", "300", "How much max overheal can hits, via demoknight swords, players can get.", FCVAR_NONE, true, 0.0, true, 99999.0);
	g_vsh2.m_hCvars.SwordHeadHPAdd = CreateConVar("vsh2_sword_health_add", "15", "How much health to give to demoknight sword players per successful hit.", FCVAR_NONE, true, 0.0, true, 999.0);
	
	g_vsh2.m_hCvars.TriggerHurtThreshold = CreateConVar("vsh2_trigger_hurt_threshold", "200.0", "How much damage trigger_hurts must do to trigger superduper-jumps.", FCVAR_NONE, true, 0.0, true, 99999.0);
	g_vsh2.m_hCvars.MaxTriggerHurtDmg = CreateConVar("vsh2_max_trigger_hurt_damage", "500.0", "the max damage cap trigger_hurts can register to boss health.", FCVAR_NONE, true, 0.0, true, 99999.0);
	g_vsh2.m_hCvars.MidRoundSpawnUber = CreateConVar("vsh2_midround_spawn_uber", "0.0", "how many seconds a player is ubered when spawned in the middle of a round.", FCVAR_NONE, true, 0.0, true, 60.0);
	g_vsh2.m_hCvars.MaxBossGlowTime = CreateConVar("vsh2_max_boss_glow_time", "30.0", "the max cap on glow time when a boss is shot with a sniper rifle.", FCVAR_NONE, true, 0.0, true, 9999.0);
	
	g_vsh2.m_hCvars.OnHitPhlogTaunt = CreateConVar("vsh2_phlog_taunt_dmg_mult", "0.25", "how much damage is applied to pyros when under phlogistinator effect.", FCVAR_NONE, true, 0.0, true, 999.0);
	g_vsh2.m_hCvars.SpyHeadMult = CreateConVar("vsh2_spy_headshot_dmg_mult", "2.5", "how much damage is applied to the headshotting revolvers for spy.", FCVAR_NONE, true, 0.0, true, 999.0);
	g_vsh2.m_hCvars.DiamondMelterBaseDmg = CreateConVar("vsh2_diamondback_mannmelter_dmg", "85.0", "how much base damage is applied for crit shots from the diamondback and mannmelter.", FCVAR_NONE, true, 0.0, true, 9999.0);
	
	g_vsh2.m_hCvars.KatanaMaxOverheal = CreateConVar("vsh2_katana_max_overheal_add", "35", "highest overheal amount from health added from the half-zatoichi.", FCVAR_NONE, true, 0.0, true, 9999.0);
	g_vsh2.m_hCvars.KatanaHealth = CreateConVar("vsh2_katana_health_add", "35", "how much health to give to a player for every successful half-zatoichi hit.", FCVAR_NONE, true, 0.0, true, 9999.0);
	
	g_vsh2.m_hCvars.PowerJackMaxOverheal = CreateConVar("vsh2_powerjack_max_overheal_add", "50", "highest overheal amount from health added from the powerjack.", FCVAR_NONE, true, 0.0, true, 9999.0);
	g_vsh2.m_hCvars.PowerJackHealth = CreateConVar("vsh2_powerjack_health_add", "25", "how much health to give to a player for every successful powerjack hit.", FCVAR_NONE, true, 0.0, true, 9999.0);
	
	g_vsh2.m_hCvars.OnHitBattalions = CreateConVar("vsh2_battalions_backup_dmg_mult", "0.3", "how much damage is applied to players under battalion's backup banner effect.", FCVAR_NONE, true, 0.0, true, 9999.0);

	g_vsh2.m_hCvars.KunaiHealthAdd = CreateConVar("vsh2_kunai_health_add", "180", "how much health is added to the players health after a successful kunai backstab.", FCVAR_NONE, true, 0.0, true, 9999.0);
	g_vsh2.m_hCvars.KunaiHealthGuard = CreateConVar("vsh2_kunai_health_guard", "195", "the higher health guard cap for when a player executes a successful kunai backstab.", FCVAR_NONE, true, 0.0, true, 9999.0);
	g_vsh2.m_hCvars.KunaiHealthLimit = CreateConVar("vsh2_kunai_health_cap", "250", "the max amount of health allowed for a player after executing a successful kunai backstab.", FCVAR_NONE, true, 0.0, true, 9999.0);
	
	g_vsh2.m_hCvars.TeleFragLogic = CreateConVar("vsh2_telefrag_logic", "3", "controller for how the telefrag damage ('vsh2_telefrag_dmg') will work. 0-value is dmg | 1-mult with dmg | 2-add with dmg | 3-boss health is dmg | 4-mult with boss health is dmg | 5-add with boss health is dmg.", FCVAR_NONE, true, 0.0, true, 5.0);
	g_vsh2.m_hCvars.TeleFragDamage = CreateConVar("vsh2_telefrag_dmg", "0.0", "damage done from telefrag, value given will work depending on the value of 'vsh2_telefrag_logic'.", FCVAR_NONE, true, 0.0, true, 999999.0);
	
	g_vsh2.m_hCvars.BootStompLogic = CreateConVar("vsh2_mantreads_stomp_logic", "3", "controller for how the mantreads stomp damage ('vsh2_mantreads_stomp_dmg') will work. 0-value is dmg | 1-mult with dmg | 2-add with dmg", FCVAR_NONE, true, 0.0, true, 2.0);
	g_vsh2.m_hCvars.BootStompDamage = CreateConVar("vsh2_mantreads_stomp_dmg", "1024.0", "damage done from mantreads-style stomp, value given will work depending on the value of 'vsh2_mantreads_stomp_logic'.", FCVAR_NONE, true, 0.0, true, 999999.0);
	
	g_vsh2.m_hGamemode.bSteam      = LibraryExists("SteamTools");
	g_vsh2.m_hGamemode.bTF2Attribs = LibraryExists("tf2attributes");
	
	AutoExecConfig(true, "VSHv2");
	HookEvent("player_death",               PlayerDeath, EventHookMode_Pre);
	HookEvent("player_hurt",                PlayerHurt, EventHookMode_Pre);
	HookEvent("teamplay_round_start",       RoundStart);
	HookEvent("teamplay_round_win",         RoundEnd);
	HookEvent("player_spawn",               ReSpawn);
	HookEvent("post_inventory_application", Resupply);
	HookEvent("object_deflected",           ObjectDeflected);
	HookEvent("object_destroyed",           ObjectDestroyed, EventHookMode_Pre);
	
	/// No longer functional.
	//HookEvent("player_jarated",             PlayerJarated);
	HookUserMessage(GetUserMessageId("PlayerJarated"), PlayerJarated);
	
	HookEvent("rocket_jump",                OnExplosiveJump);
	HookEvent("rocket_jump_landed",         OnExplosiveJump);
	HookEvent("sticky_jump",                OnExplosiveJump);
	HookEvent("sticky_jump_landed",         OnExplosiveJump);
	
	HookEvent("item_pickup",                ItemPickedUp);
	HookEvent("player_chargedeployed",      UberDeployed);
	HookEvent("arena_round_start",          ArenaRoundStart);
	HookEvent("teamplay_point_captured",    PointCapture, EventHookMode_Post);
	HookEvent("rps_taunt_event",            RPSTaunt, EventHookMode_Post);
	HookEvent("deploy_buff_banner",         DeployBuffBanner);
	HookEvent("player_buff",                OnPlayerBuff);
	
	AddCommandListener(cdVoiceMenu, "voicemenu");
	AddNormalSoundHook(HookSound);
	
	g_vsh2.m_hCookies[Points]   = new Cookie("vsh2_queuepoints", "Amount of VSH2 Queue points a player has.", CookieAccess_Protected);
	g_vsh2.m_hCookies[BossOpt]  = new Cookie("vsh2_presetbosses", "Preset bosses for VSH2 players.", CookieAccess_Protected);
	g_vsh2.m_hCookies[MusicOpt] = new Cookie("vsh2_music_settings", "HaleMusic setting.", CookieAccess_Public);
	
	for( int i=MaxClients; i; --i ) {
		if( !IsClientInGame(i) ) {
			continue;
		}
		OnClientPutInServer(i);
	}
	
	AddMultiTargetFilter("@boss",     HaleTargetFilter, "all Bosses", false);
	AddMultiTargetFilter("@hale",     HaleTargetFilter, "all Bosses", false);
	AddMultiTargetFilter("@minion",   MinionTargetFilter, "all Minions", false);
	AddMultiTargetFilter("@minions",  MinionTargetFilter, "all Minions", false);
	AddMultiTargetFilter("@!boss",    HaleTargetFilter, "all non-Boss players", false);
	AddMultiTargetFilter("@!hale",    HaleTargetFilter, "all non-Boss players", false);
	AddMultiTargetFilter("@!minion",  MinionTargetFilter, "all non-Minions", false);
	AddMultiTargetFilter("@!minions", MinionTargetFilter, "all non-Minions", false);
	AddMultiTargetFilter("@nextboss", NextHaleTargetFilter, "the Next Boss", false);
	
	g_vsh2.m_hPlayerFields[0]    = new StringMap();   /// This will be freed when plugin is unloaded again
	g_modsys.m_hBossesRegistered = new ArrayList(sizeof(BossModule));
	g_modsys.m_hBossMap          = new StringMap();
}

public bool HaleTargetFilter(const char[] pattern, ArrayList clients)
{
	bool non = StrContains(pattern, "!", false) != -1;
	for( int i=MaxClients; i; i-- ) {
		if( IsClientValid(i) && clients.FindValue(i) == -1 ) {
			if( g_vsh2.m_hCvars.Enabled.BoolValue && BaseBoss(i).bIsBoss ) {
				if( !non ) {
					clients.Push(i);
				}
			} else if( non ) {
				clients.Push(i);
			}
		}
	}
	return true;
}

public bool MinionTargetFilter(const char[] pattern, ArrayList clients)
{
	bool non = StrContains(pattern, "!", false) != -1;
	for( int i=MaxClients; i; i-- ) {
		if( IsClientValid(i) && clients.FindValue(i) == -1 ) {
			if( g_vsh2.m_hCvars.Enabled.BoolValue && BaseBoss(i).bIsMinion ) {
				if( !non )
					clients.Push(i);
			} else if( non )
				clients.Push(i);
		}
	}
	return true;
}

public bool NextHaleTargetFilter(const char[] pattern, ArrayList clients)
{
	bool non = StrContains(pattern, "!", false) != -1;
	for( int i=MaxClients; i; i-- ) {
		if( IsClientValid(i) && clients.FindValue(i) == -1 ) {
			if( g_vsh2.m_hCvars.Enabled.BoolValue && BaseBoss(i)==VSHGameMode.FindNextBoss() ) {
				if( !non ) {
					clients.Push(i);
				}
			} else if( non ) {
				clients.Push(i);
			}
		}
	}
	return true;
}

public Action CheckLateSpawn(int client, const char[] command, int argc)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || g_vsh2.m_hGamemode.iRoundState != StateRunning )
		return Plugin_Continue;
	
	/// deal with late spawners, force them to spectator.
	if( !g_vsh2.m_hCvars.AllowLateSpawn.BoolValue
		&& GetClientTeam(client) > VSH2Team_Spectator
		&& TF2_GetPlayerClass(client)==TFClass_Unknown
		&& (GetGameTime() - g_vsh2.m_hGamemode.flRoundStartTime) > g_vsh2.m_hCvars.LateSpawnDelay.FloatValue
	) {
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
	if( g_vsh2.m_hCvars.Enabled.BoolValue && g_vsh2.m_hGamemode.iRoundState == StateRunning ) {
		BaseBoss player = BaseBoss(client);
		if( player.bIsBoss ) {
			/// Allow bosses to suicide if their total health is under a certain percentage.
			float flhp_percent = float(player.iHealth) / float(player.iMaxHealth);
			if( flhp_percent > g_vsh2.m_hCvars.SuicidePercent.FloatValue ) {
				CPrintToChat(client, "{olive}[VSH 2]{default} You cannot suicide yet as a boss. Please Use '!resetq' instead.");
				return Plugin_Handled;
			}
		} else {
			/// stop rage-stunned players from suiciding.
			if( g_vsh2.m_hCvars.BlockRageSuicide.BoolValue ) {
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
	if( !strcmp(name, "SteamTools", false) )
		g_vsh2.m_hGamemode.bSteam = true;
	
	if( !strcmp(name, "tf2attributes", false) )
		g_vsh2.m_hGamemode.bTF2Attribs = true;
	
#if defined _updater_included
	if( !strcmp(name, "updater") )
		Updater_AddPlugin(UPDATE_URL);
#endif
}

public void OnLibraryRemoved(const char[] name)
{
	if( !strcmp(name, "SteamTools", false) )
		g_vsh2.m_hGamemode.bSteam = false;
	
	if( !strcmp(name, "tf2attributes", false) )
		g_vsh2.m_hGamemode.bTF2Attribs = false;
}

/// UPDATER Stuff
public void OnAllPluginsLoaded()
{
#if defined _updater_included
	if( LibraryExists("updater") )
		Updater_AddPlugin(UPDATE_URL);
#endif
}

#if defined _updater_included
public Action Updater_OnPluginDownloading() {
	if( !g_vsh2.m_hCvars.AutoUpdate.BoolValue ) {
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public void Updater_OnPluginUpdated()  {
	char filename[64]; GetPluginFilename(null, filename, sizeof(filename));
	ServerCommand("sm plugins unload %s", filename);
	ServerCommand("sm plugins load %s", filename);
}
#endif


enum struct CvarVals {
	int tf_arena_use_queue;
	int mp_teams_unbalance_limit;
	int mp_forceautoteam;
	int tf_arena_first_blood;
	int mp_forcecamera;
	float tf_scout_hype_pep_max;
}

CvarVals g_oldcvar_vals;

public void OnConfigsExecuted()
{
	/// Config checker taken from VSH1
	static char szOldVersion[PATH];
	g_vsh2.m_hCvars.VersionNumber.GetString(szOldVersion, sizeof(szOldVersion));
	if( !StrEqual(szOldVersion, PLUGIN_VERSION) ) {
		LogMessage("[VSH 2] Warning: your config is outdated (cfg version '%s'; your version '%s'). Back up your tf/cfg/sourcemod/VSHv2.cfg file and delete it, and this plugin will generate a new one that you can then modify to your original values.", szOldVersion, PLUGIN_VERSION);
	}
	g_vsh2.m_hCvars.VersionNumber.SetString(PLUGIN_VERSION, false, true);

	if( VSHGameMode.IsVSHMap() ) {
		ConVar cvar_tf_arena_use_queue       = FindConVar("tf_arena_use_queue");
		ConVar cvar_mp_teams_unbalance_limit = FindConVar("mp_teams_unbalance_limit");
		ConVar cvar_tf_arena_first_blood     = FindConVar("tf_arena_first_blood");
		ConVar cvar_mp_forcecamera           = FindConVar("mp_forcecamera");
		ConVar cvar_tf_scout_hype_pep_max    = FindConVar("tf_scout_hype_pep_max");
		
		g_oldcvar_vals.tf_arena_use_queue       = cvar_tf_arena_use_queue.IntValue;
		g_oldcvar_vals.mp_teams_unbalance_limit = cvar_mp_teams_unbalance_limit.IntValue;
		g_oldcvar_vals.tf_arena_first_blood     = cvar_tf_arena_first_blood.IntValue;
		g_oldcvar_vals.mp_forcecamera           = cvar_mp_forcecamera.IntValue;
		g_oldcvar_vals.tf_scout_hype_pep_max    = cvar_tf_scout_hype_pep_max.FloatValue;
		
		cvar_tf_arena_use_queue.IntValue       = 0;
		cvar_mp_teams_unbalance_limit.IntValue = g_vsh2.m_hCvars.FirstRound.BoolValue ? 0 : 1;
		cvar_mp_forcecamera.IntValue           = g_vsh2.m_hCvars.FirstRound.BoolValue ? 0 : 1;
		cvar_tf_arena_first_blood.IntValue     = 0;
		cvar_mp_forcecamera.IntValue           = 0;
		cvar_tf_scout_hype_pep_max.FloatValue  = 100.0;
		
		g_vsh2.m_hGamemode.CheckDoors();
		g_vsh2.m_hGamemode.CheckTeleToSpawn();
#if defined _steamtools_included
		if( g_vsh2.m_hGamemode.bSteam ) {
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
	SDKHook(client, SDKHook_GetMaxHealth, GetMaxHealth);
	SDKHook(client, SDKHook_TraceAttack, TraceAttack);
	SDKHook(client, SDKHook_Touch, OnTouch);
	SDKHook(client, SDKHook_PreThinkPost, OnPreThinkPost);
	
	if( g_vsh2.m_hPlayerFields[client] != null ) {
		delete g_vsh2.m_hPlayerFields[client];
	}
	g_vsh2.m_hPlayerFields[client] = new StringMap();
	BaseBoss boss = BaseBoss(client);
	
	/// BaseFighter properties
	g_vsh2.m_hPlayerFields[client].SetValue("iQueue", 0);
	g_vsh2.m_hPlayerFields[client].SetValue("iPresetType", -1);
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
	boss.iMaxHealth = 0;
	boss.iBossType = -1;
	boss.iClimbs = 0;
	boss.iStabbed = 0;
	boss.iMarketted = 0;
	boss.iDifficulty = 0;
	boss.bUsedUltimate = false;
	boss.flSpeed = 0.0;
	boss.flCharge = 0.0;
	boss.flRAGE = 0.0;
	boss.flKillSpree = 0.0;
	boss.flWeighDown = 0.0;
}

public void OnClientDisconnect(int client)
{
	if( client <= 0 || client > MaxClients || g_vsh2.m_hPlayerFields[client]==null )
		return;
	
	g_vsh2.m_hPlayerFields[client].SetValue("iBossType", -1);
	ManageDisconnect(client);
}

public void OnClientPostAdminCheck(int client) {
	SetPawnTimer(ConnectionMessage, 5.0, GetClientUserId(client));
}

public void ConnectionMessage(const int userid)
{
	int client = GetClientOfUserId(userid);
	if( IsValidClient(client) ) {
		CPrintToChat(client, "{olive}[VSH 2]{default} Welcome to VSH2, type /bosshelp for help!");
		if( g_vsh2.m_hGamemode.iRoundState==StateRunning ) {
			BaseBoss player = BaseBoss(userid, true);
			if( g_vsh2.m_hCvars.PlayerMusic.BoolValue ) {
				player.SetMusic(g_vsh2.m_strCurrSong);
			}
			player.PlayMusic(g_vsh2.m_hCvars.MusicVolume.FloatValue);
		}
	}
}

public Action OnTouch(int client, int other)
{
	if( 0 < other <= MaxClients ) {
		BaseBoss boss = BaseBoss(client);
		BaseBoss victim = BaseBoss(other);
		if( boss.bIsBoss && !victim.bIsBoss ) {
			return ManageOnTouchPlayer(boss, victim); /// in handler.sp
		}
	} else if( other > MaxClients ) {
		BaseBoss player = BaseBoss(client);
		if( IsValidEntity(other) && player.bIsBoss ) {
			char ent[5];
			if( GetEntityClassname(other, ent, sizeof(ent)), !StrContains(ent, "obj_") ) {
				if( GetEntProp(other, Prop_Send, "m_iTeamNum") != GetClientTeam(client) ) {
					return ManageOnTouchBuilding(player, other); /// in handler.sp
				}
			}
		}
	}
	return Plugin_Continue;
}

public void OnMapStart()
{
	ManageDownloads();    /// in handler.sp
	CreateTimer(0.1, Timer_PlayerThink, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(1.0, MakeModelTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	
	g_vsh2.m_hGamemode.iHealthBar = VSHHealthBar();
	g_vsh2.m_hGamemode.iRoundCount = 0;
	g_vsh2.m_hGamemode.iRoundState = StateDisabled;
	g_vsh2.m_hGamemode.hNextBoss = view_as< BaseBoss >(0);
	
	if( g_vsh2.m_hCfg != null ) {
		DeleteCfg(g_vsh2.m_hCfg);
	}
	g_vsh2.m_hCfg = new ConfigMap("configs/saxton_hale/vsh2.cfg");
	if( g_vsh2.m_hCfg==null ) {
		LogError("[VSH 2] ERROR :: **** couldn't find 'configs/saxton_hale/vsh2.cfg' ****");
	}
}

public void OnMapEnd()
{
	FindConVar("tf_arena_use_queue").IntValue       = g_oldcvar_vals.tf_arena_use_queue;
	FindConVar("mp_teams_unbalance_limit").IntValue = g_oldcvar_vals.mp_teams_unbalance_limit;
	FindConVar("mp_forceautoteam").IntValue         = g_oldcvar_vals.mp_forceautoteam;
	FindConVar("tf_arena_first_blood").IntValue     = g_oldcvar_vals.tf_arena_first_blood;
	FindConVar("mp_forcecamera").IntValue           = g_oldcvar_vals.mp_forcecamera;
	FindConVar("tf_scout_hype_pep_max").FloatValue  = g_oldcvar_vals.tf_scout_hype_pep_max;
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
		ManageBossDeath(player); /// in handler.sp
	}
}
public Action MakeModelTimer(Handle hTimer)
{
	BaseBoss player;
	for( int i=MaxClients; i; --i ) {
		if( !IsValidClient(i, false) || !IsPlayerAlive(i) ) {
			continue;
		}
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
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || g_vsh2.m_hGamemode.iRoundState != StateRunning ) {
		return Plugin_Continue;
	}
	
	g_vsh2.m_hGamemode.UpdateBossHealth();
	if( g_vsh2.m_hGamemode.flMusicTime <= GetGameTime() ) {
		_MusicPlay();
	}
	
	BaseBoss player;
	for( int i=MaxClients; i; i-- ) {
		if( !IsValidClient(i, false) ) {
			continue;
		}
		
		/**
		 * If player is a boss, force Boss think on them;
		 * if not boss or on blue team, force fighter think!
		 */
		player = BaseBoss(i);
		if( player.bIsBoss ) {
			ManageBossThink(player);    /// in handler.sp
		} else {
			ManageFighterThink(player); /// in handler.sp
		}
		
		if( GetLivingPlayers(VSH2Team_Red) <= g_vsh2.m_hCvars.ShowBossHPLiving.IntValue ) {
			SetHudTextParams(-1.0, 0.15, 0.11, 255, 255, 255, 255);
			ShowSyncHudText(i, g_vsh2.m_hHUDs[HealthHUD], "Total Boss Health: %i", VSHGameMode.GetTotalBossHealth());
		}
	}
	
	/// If there's no active, living bosses, then force RED to win
	if( !VSHGameMode.CountBosses(true) ) {
		ForceTeamWin(VSH2Team_Red);
	}
	return Plugin_Continue;
}

public Action CmdReloadCFG(int client, int args)
{
	if( g_vsh2.m_hCfg != null ) {
		DeleteCfg(g_vsh2.m_hCfg);
	}
	
	g_vsh2.m_hCfg = new ConfigMap("configs/saxton_hale/vsh2.cfg");
	if( g_vsh2.m_hCfg==null ) {
		CReplyToCommand(client, "{olive}[VSH 2] ERROR{default} :: **** {axis}couldn't find 'configs/saxton_hale/vsh2.cfg'{default} ****");
	} else {
		CReplyToCommand(client, "{olive}[VSH 2]{default} **** Reloaded VSH2 Config ****");
	}
	return Plugin_Handled;
}

public void OnPreThinkPost(int client)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || IsClientObserver(client) || !IsPlayerAlive(client) ) {
		return;
	} else if( TF2_IsPlayerInCondition(client, TFCond_Cloaked) && IsNearSpencer(client) ) {
		float cloak = GetEntPropFloat(client, Prop_Send, "m_flCloakMeter") - 0.5;
		if( cloak < 0.0 ) {
			cloak = 0.0;
		}
		SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", cloak);
	}
}

public Action TraceAttack(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	} else if( IsClientValid(attacker) && IsClientValid(victim) ) {
		BaseBoss player = BaseBoss(victim);
		BaseBoss enemy = BaseBoss(attacker);
		return Call_OnTraceAttack(player, enemy, inflictor, damage, damagetype, ammotype, hitbox, hitgroup);
	}
	return Plugin_Continue;
}
public Action OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || !IsClientValid(victim) ) {
		return Plugin_Continue;
	} else if( g_vsh2.m_hGamemode.iRoundState==StateStarting ) {
		damage = 0.0;
		return Plugin_Changed;
	}
	
	BaseBoss boss_victim = BaseBoss(victim);
	if( boss_victim.bIsBoss ) { /// in handler.sp
		return ManageOnBossTakeDamage(boss_victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	}
	/// BUG PATCH: Client index 0 is invalid
	if( !IsClientValid(attacker) ) {
		if( (damagetype & DMG_FALL) && !boss_victim.bIsBoss ) {
			Action act = Call_OnPlayerTakeFallDamage(boss_victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
			
			int item = GetPlayerWeaponSlot(victim, (boss_victim.iTFClass == TFClass_DemoMan ? TFWeaponSlot_Primary : TFWeaponSlot_Secondary));
			if( item <= 0 || !IsValidEntity(item) || (boss_victim.iTFClass==TFClass_Spy && TF2_IsPlayerInCondition(victim, TFCond_Cloaked)) ) {
				if( act != Plugin_Changed ) {
					damage /= 10;
				}
			}
			return Plugin_Changed;
		}
		return Plugin_Continue;
	}
	
	BaseBoss boss_attacker = BaseBoss(attacker);
	if( boss_attacker.bIsBoss ) { /// in handler.sp
		return ManageOnBossDealDamage(boss_victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	}
	return Plugin_Continue;
}

public Action GetMaxHealth(int entity, int &maxhealth)
{
	if( !IsClientValid(entity) )
		return Plugin_Continue;
	
	BaseBoss player = BaseBoss(entity);
	if( player.bIsBoss && player.iMaxHealth ) {
		maxhealth = player.iMaxHealth;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

#if defined _goomba_included_
public Action OnStomp(int attacker, int victim, float& damageMultiplier, float& damageAdd, float& JumpPower)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	}
	return ManageOnGoombaStomp(attacker, victim, damageMultiplier, damageAdd, JumpPower);
}
#endif

public Action RemoveEnt(Handle timer, any entid)
{
	int ent = EntRefToEntIndex(entid);
	if( ent > 0 && IsValidEntity(ent) ) {
		AcceptEntityInput(ent, "Kill");
	}
	return Plugin_Continue;
}

public Action cdVoiceMenu(int client, const char[] command, int argc)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	} else if( argc < 2 || !IsPlayerAlive(client) ) {
		return Plugin_Handled;
	}
	char szCmd1[8]; GetCmdArg(1, szCmd1, sizeof(szCmd1));
	char szCmd2[8]; GetCmdArg(2, szCmd2, sizeof(szCmd2));
	
	/// Capture call for medic commands (represented by "voicemenu 0 0")
	BaseBoss boss = BaseBoss(client);
	if( szCmd1[0]=='0' && szCmd2[0]=='0' && boss.bIsBoss ) {
		ManageBossMedicCall(boss);
	}
	return Plugin_Continue;
}

public Action DoTaunt(int client, const char[] command, int argc)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	}
	BaseBoss boss = BaseBoss(client);
	if( boss.flRAGE >= 100.0 ) {
		ManageBossTaunt(boss);
	}
	return Plugin_Continue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return;
	} else if( !strncmp(classname, "tf_weapon_", 10, false) && IsValidEntity(entity) ) {
		CreateTimer(0.5, OnWeaponSpawned, EntIndexToEntRef(entity));
	}
	ManageEntityCreated(entity, classname);
}

public Action OnWeaponSpawned(Handle timer, any ref) {
	int wep = EntRefToEntIndex(ref);
	if( IsValidEntity(wep) ) {
		int client = GetOwner(wep);
		if( IsValidClient(client) && GetClientTeam(client) == VSH2Team_Red ) {
			int slot = GetSlotFromWeapon(client, wep);
			if( IsIntInBounds(slot, 2, 0) ) {
				g_munitions[client].SetAmmo(slot, GetWeaponAmmo(wep));
				g_munitions[client].SetClip(slot, GetWeaponClip(wep));
			}
		}
	}
	return Plugin_Continue;
}

/// scores kept glitching out and I hate debugging so I made it its own func.
public void ShowPlayerScores() {
	BaseBoss top_players[3];
	BaseBoss(0).iDamage = 0;
	for( int i=MaxClients; i; --i ) {
		if( !IsValidClient(i) || GetClientTeam(i) <= VSH2Team_Spectator ) {
			continue;
		}
		
		BaseBoss player = BaseBoss(i);
		if( player.bIsBoss ) {
			//player.iDamage = 0;
			continue;
		} else if( player.iDamage==0 ) {
			continue;
		}
		
		if( player.iDamage >= top_players[0].iDamage ) {
			top_players[2] = top_players[1];
			top_players[1] = top_players[0];
			top_players[0] = player;
		} else if( player.iDamage >= top_players[1].iDamage ) {
			top_players[2] = top_players[1];
			top_players[1] = player;
		} else if( player.iDamage >= top_players[2].iDamage ) {
			top_players[2] = player;
		}
	}
	if( top_players[0].iDamage > 9000 ) {
		SetPawnTimer(OverNineThousand, 1.0); /// in stocks.inc
	}
	
	char names[3][PATH];
	int damages[3];
	for( int i; i<3; i++ ) {
		if( top_players[i].index && top_players[i].iDamage > 0 ) {
			GetClientName(top_players[i].index, names[i], sizeof(names[]));
			damages[i] = top_players[i].iDamage;
		} else {
			names[i] = "nil";
		}
	}
	
	/// Should clear center text
	PrintCenterTextAll("");
	Action act = Call_OnShowStats(top_players);
	if( act > Plugin_Changed ) {
		return;
	}
	
	SetHudTextParams(-1.0, 0.35, 10.0, 255, 255, 255, 255);
	char damage_list[512];
	Format(damage_list, sizeof(damage_list), "Most damage dealt by:\n1)%i - %s\n2)%i - %s\n3)%i - %s", damages[0], names[0], damages[1], names[1], damages[2], names[2]);
	for( int i=MaxClients; i; --i ) {
		if( !IsClientValid(i) || (GetClientButtons(i) & IN_SCORE) ) {
			continue;
		}
		BaseBoss player = BaseBoss(i);
		ShowHudText(i, -1, "%s\n\nDamage Dealt: %i", damage_list, player.iDamage);
	}
}

public void CalcScores()
{
	for( int i=MaxClients; i; --i ) {
		if( !IsClientValid(i) || GetClientTeam(i) < VSH2Team_Red ) {
			continue;
		}
		/// We don't want the Bosses getting free points for doing damage.
		BaseBoss player = BaseBoss(i);
		if( player.bIsBoss ) {
			continue;
		} else {
			int queue_gain = g_vsh2.m_hCvars.QueueGained.IntValue;
			int queue = (g_vsh2.m_hCvars.DamageQueue.BoolValue) ? queue_gain + (player.iDamage / g_vsh2.m_hCvars.DamageForQueue.IntValue) : queue_gain;
			int points = player.iDamage / g_vsh2.m_hCvars.DamagePoints.IntValue;
			
			Action act = Call_OnScoreTally(player, points, queue);
			if( act > Plugin_Changed ) {
				continue;
			}
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
	if( g_vsh2.m_hGamemode.iHealthBar.iPercent < g_vsh2.m_hCvars.HealthPercentForLastGuy.IntValue
		|| g_vsh2.m_hGamemode.iRoundState != StateRunning
		|| g_vsh2.m_hGamemode.iTimeLeft < 0 ) {
		return Plugin_Stop;
	}
	
	int time = g_vsh2.m_hGamemode.iTimeLeft;
	Action act = Call_OnDrawGameTimer(time);
	if( act > Plugin_Changed ) {
		return act;
	} else if( act==Plugin_Changed ) {
		g_vsh2.m_hGamemode.iTimeLeft = time;
	} else {
		g_vsh2.m_hGamemode.iTimeLeft--;
	}
	
	char strTime[10];
	if( time/60 > 9 ) {
		IntToString(time/60, strTime, 6);
	} else {
		Format(strTime, sizeof(strTime), "0%i", time/60);
	}
	
	Format(strTime, sizeof(strTime), ( time%60 > 9 )? "%s:%i" : "%s:0%i", strTime, time%60);
	SetHudTextParams(-1.0, 0.17, 1.1, 255, 255, 255, 255);
	for( int i=MaxClients; i; --i ) {
		if( !IsValidClient(i) )
			continue;
		
		ShowSyncHudText(i, g_vsh2.m_hHUDs[TimeLeftHUD], strTime);
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
			/*for( int i=MaxClients; i; i-- ) {
				if( !IsClientInGame(i) )
					continue;
				TF2_
			}*/
			ForceTeamWin(VSH2Team_Boss);
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

public void _ResetMediCharge(const int entid, const float val) {
	int medigun = EntRefToEntIndex(entid);
	if( medigun > MaxClients && IsValidEntity(medigun) ) {
		SetMediCharge(medigun, GetMediCharge(medigun) + val);
	}
}

public Action Timer_UberLoop(Handle timer, any medigunid)
{
	int medigun = EntRefToEntIndex(medigunid);
	if( medigun && IsValidEntity(medigun) && g_vsh2.m_hGamemode.iRoundState == StateRunning ) {
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
			} else {
				med.iUberTarget = 0;
			}
		} else if( charge < 0.05 ) {
			float reset_charge = g_vsh2.m_hCvars.MedigunReset.FloatValue;
			BaseBoss med = BaseBoss(medic);
			Call_OnUberLoopEnd(med, BaseBoss(med.GetHealTarget()), reset_charge);
			SetPawnTimer(_ResetMediCharge, 3.0, EntIndexToEntRef(medigun), reset_charge);
			return Plugin_Stop;
		}
	} else {
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public void _MusicPlay()
{
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || !g_vsh2.m_hCvars.EnableMusic.BoolValue || g_vsh2.m_hGamemode.iRoundState != StateRunning )
		return;
	
	float currtime = GetGameTime();
	bool use_player_music = g_vsh2.m_hCvars.PlayerMusic.BoolValue;
	if( !use_player_music && g_vsh2.m_hGamemode.flMusicTime > currtime )
		return;
	
	float vol = g_vsh2.m_hCvars.MusicVolume.FloatValue;
	if( use_player_music ) {
		for( int i=MaxClients; i; --i ) {
			if( !IsClientValid(i) )
				continue;
			
			BaseBoss player = BaseBoss(i);
			if( player.flMusicTime > currtime )
				continue;
			
			char bg_music[PLATFORM_MAX_PATH];
			float time = -1.0;
			ManageMusic(bg_music, time, vol);
			player.SetMusic(bg_music);
			player.PlayMusic(vol);
			if( time != -1.0 ) {
				player.flMusicTime = currtime + time;
			}
		}
	} else {
		char bg_music[PLATFORM_MAX_PATH];
		float time = -1.0;
		ManageMusic(bg_music, time, vol);    /// in handler.sp
		if( bg_music[0] != 0 ) {
			strcopy(g_vsh2.m_strCurrSong, PLATFORM_MAX_PATH, bg_music);
			for( int i=MaxClients; i; --i ) {
				if( !IsClientValid(i) )
					continue;
				BaseBoss(i).PlayMusic(vol);
			}
		}
		if( time != -1.0 ) {
			g_vsh2.m_hGamemode.flMusicTime = currtime + time;
		}
	}
}


int GetRandomBossType(int[] boss_filter, int filter_size=0)
{
	int bosses_size = MAXBOSS + 1;
	int[] bosses = new int[bosses_size];
	
	int count;
	for( int i; i<=MAXBOSS; i++ ) {
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


public int RegisterBoss(Handle plugin, const char modulename[MAX_BOSS_NAME_SIZE])
{
	if( !ValidateName(modulename) ) {
		LogError("VSH2 :: Boss Registrar: **** Invalid Name For Boss Module: '%s' ****", modulename);
		return -1;
	}
	char pl_hash[CELL_KEY_SIZE];
	PackItem(plugin, pl_hash);
	int index = -1;
	if( g_modsys.m_hBossMap.GetValue(pl_hash, index) && IsIntInBounds(index, MAXBOSS, MaxDefaultVSH2Bosses) ) {
		BossModule module;
		g_modsys.m_hBossesRegistered.GetArray(index, module, sizeof(module));
		if( !strcmp(module.name, modulename) ) {
			/// iterate through all plugins and see if it actually exists.
			Handle iter = GetPluginIterator();
			for( Handle p = ReadPlugin(iter); MorePlugins(iter); p = ReadPlugin(iter) ) {
				if( p==module.plugin ) {
					LogError("VSH2 :: Boss Registrar: **** Plugin '%s' Already Registered ****", modulename);
					delete iter;
					return index + MaxDefaultVSH2Bosses;
				}
			}
			delete iter;
			
			/// the boss being registered has the same name but it's of a different handle ID?
			/// override its plugin ID then, it was probably reloaded.
			module.plugin = plugin;
			g_modsys.m_hBossesRegistered.SetArray(index, module, sizeof(module));
			return index + MaxDefaultVSH2Bosses;
		}
	}
	
	/// Couldn't find boss of the name at all, assume it's a brand new boss being reg'd.
	BossModule module;
	module.name = modulename;
	module.plugin = plugin;
	index = g_modsys.m_hBossesRegistered.PushArray(module, sizeof(module));
	g_modsys.m_hBossMap.SetValue(pl_hash, index);
	return MAXBOSS;
}


public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("VSH2_RegisterPlugin",             Native_RegisterBoss);
	CreateNative("VSH2_Hook",                       Native_Hook);
	CreateNative("VSH2_HookEx",                     Native_HookEx);
	
	CreateNative("VSH2_Unhook",                     Native_Unhook);
	CreateNative("VSH2_UnhookEx",                   Native_UnhookEx);
	CreateNative("VSH2_GetRandomBossType",          Native_GetRandomBossType);
	CreateNative("VSH2_GetBossIDs",                 Native_GetBossIDs);
	CreateNative("VSH2_GetBossID",                  Native_GetBossID);
	CreateNative("VSH2_GetBossNameByIndex",         Native_GetBossNameByIndex);
	CreateNative("VSH2_StopMusic",                  Native_StopMusic);
	CreateNative("VSH2_GetConfigMap",               Native_GetMainConfig);
	
	CreateNative("VSH2Player.VSH2Player",           Native_VSH2Instance);
	
	CreateNative("VSH2Player.userid.get",           Native_VSH2GetUserid);
	CreateNative("VSH2Player.index.get",            Native_VSH2GetIndex);
	
	CreateNative("VSH2Player.GetProperty",          Native_VSH2_getProperty);
	CreateNative("VSH2Player.SetProperty",          Native_VSH2_setProperty);
	
	/// type safe versions of VSH2Player::GetProperty & VSH2Player::SetProperty.
	CreateNative("VSH2Player.GetPropInt",           Native_VSH2_getIntProp);
	CreateNative("VSH2Player.GetPropFloat",         Native_VSH2_getFloatProp);
	CreateNative("VSH2Player.GetPropAny",           Native_VSH2_getProperty);
	
	CreateNative("VSH2Player.SetPropInt",           Native_VSH2_setIntProp);
	CreateNative("VSH2Player.SetPropFloat",         Native_VSH2_setFloatProp);
	CreateNative("VSH2Player.SetPropAny",           Native_VSH2_setProp);
	
	/// VSH2 Fighter Methods
	CreateNative("VSH2Player.ConvertToMinion",      Native_VSH2_ConvertToMinion);
	CreateNative("VSH2Player.SpawnWeapon",          Native_VSH2_SpawnWep);
	CreateNative("VSH2Player.GetWeaponSlotIndex",   Native_VSH2_GetWeaponSlotIndex);
	CreateNative("VSH2Player.SetWepInvis",          Native_VSH2_SetWepInvis);
	CreateNative("VSH2Player.SetOverlay",           Native_VSH2_SetOverlay);
	CreateNative("VSH2Player.TeleToSpawn",          Native_VSH2_TeleToSpawn);
	CreateNative("VSH2Player.IncreaseHeadCount",    Native_VSH2_IncreaseHeadCount);
	CreateNative("VSH2Player.SpawnSmallHealthPack", Native_VSH2_SpawnSmallHealthPack);
	CreateNative("VSH2Player.ForceTeamChange",      Native_VSH2_ForceTeamChange);
	CreateNative("VSH2Player.ClimbWall",            Native_VSH2_ClimbWall);
	CreateNative("VSH2Player.HelpPanelClass",       Native_VSH2_HelpPanelClass);
	CreateNative("VSH2Player.GetAmmoTable",         Native_VSH2_GetAmmoTable);
	CreateNative("VSH2Player.SetAmmoTable",         Native_VSH2_SetAmmoTable);
	CreateNative("VSH2Player.GetClipTable",         Native_VSH2_GetClipTable);
	CreateNative("VSH2Player.SetClipTable",         Native_VSH2_SetClipTable);
	CreateNative("VSH2Player.GetHealTarget",        Native_VSH2_GetHealTarget);
	CreateNative("VSH2Player.IsNearDispenser",      Native_VSH2_IsNearDispenser);
	CreateNative("VSH2Player.IsInRange",            Native_VSH2_IsInRange);
	CreateNative("VSH2Player.RemoveBack",           Native_VSH2_RemoveBack);
	CreateNative("VSH2Player.FindBack",             Native_VSH2_FindBack);
	CreateNative("VSH2Player.ShootRocket",          Native_VSH2_ShootRocket);
	CreateNative("VSH2Player.Heal",                 Native_VSH2_Heal);
	CreateNative("VSH2Player.AddTempAttrib",        Native_VSH2_AddTempAttrib);
	
	/// VSH2 Boss Methods
	CreateNative("VSH2Player.ConvertToBoss",        Native_VSH2_ConvertToBoss);
	CreateNative("VSH2Player.GiveRage",             Native_VSH2_GiveRage);
	CreateNative("VSH2Player.MakeBossAndSwitch",    Native_VSH2_MakeBossAndSwitch);
	CreateNative("VSH2Player.DoGenericStun",        Native_VSH2_DoGenericStun);
	CreateNative("VSH2Player.StunPlayers",          Native_VSH2_StunPlayers);
	CreateNative("VSH2Player.StunBuildings",        Native_VSH2_StunBuildings);
	CreateNative("VSH2Player.RemoveAllItems",       Native_VSH2_RemoveAllItems);
	CreateNative("VSH2Player.GetName",              Native_VSH2_GetName);
	CreateNative("VSH2Player.SetName",              Native_VSH2_SetName);
	CreateNative("VSH2Player.SuperJump",            Native_VSH2_SuperJump);
	CreateNative("VSH2Player.WeighDown",            Native_VSH2_WeighDown);
	CreateNative("VSH2Player.PlayVoiceClip",        Native_VSH2_PlayVoiceClip);
	CreateNative("VSH2Player.PlayMusic",            Native_VSH2_PlayMusic);
	CreateNative("VSH2Player.StopMusic",            Native_VSH2_StopMusic);
	
	/// VSH2 Game Mode Managers Methods
	CreateNative("VSH2GameMode_GetProperty",        Native_VSH2GameMode_GetProperty);
	CreateNative("VSH2GameMode_SetProperty",        Native_VSH2GameMode_SetProperty);
	
	CreateNative("VSH2GameMode_FindNextBoss",       Native_VSH2GameMode_FindNextBoss);
	CreateNative("VSH2GameMode_GetRandomBoss",      Native_VSH2GameMode_GetRandomBoss);
	CreateNative("VSH2GameMode_GetBossByType",      Native_VSH2GameMode_GetBossByType);
	CreateNative("VSH2GameMode_CountMinions",       Native_VSH2GameMode_CountMinions);
	CreateNative("VSH2GameMode_CountBosses",        Native_VSH2GameMode_CountBosses);
	CreateNative("VSH2GameMode_GetTotalBossHealth", Native_VSH2GameMode_GetTotalBossHealth);
	CreateNative("VSH2GameMode_SearchForItemPacks", Native_VSH2GameMode_SearchForItemPacks);
	CreateNative("VSH2GameMode_UpdateBossHealth",   Native_VSH2GameMode_UpdateBossHealth);
	CreateNative("VSH2GameMode_GetBossType",        Native_VSH2GameMode_GetBossType);
	CreateNative("VSH2GameMode_GetTotalRedPlayers", Native_VSH2GameMode_GetTotalRedPlayers);
	CreateNative("VSH2GameMode_GetHUDHandle",       Native_VSH2GameMode_GetHUDHandle);
	CreateNative("VSH2GameMode_GetBosses",          Native_VSH2GameMode_GetBosses);
	CreateNative("VSH2GameMode_IsVSHMap",           Native_VSH2GameMode_IsVSHMap);
	CreateNative("VSH2GameMode_GetFighters",        Native_VSH2GameMode_GetFighters);
	CreateNative("VSH2GameMode_GetMinions",         Native_VSH2GameMode_GetMinions);
	CreateNative("VSH2GameMode_GetQueue",           Native_VSH2GameMode_GetQueue);
	CreateNative("VSH2GameMode_GetBossesByType",    Native_VSH2GameMode_GetBossesByType);
	
	CreateNative("VSH2_GetMaxBosses",               Native_VSH2_GetMaxBosses);
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
	return RegisterBoss(plugin, module_name);
}

public any Native_VSH2Instance(Handle plugin, int numParams)
{
	BaseBoss player = BaseBoss(GetNativeCell(1), GetNativeCell(2));
	return player;
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

public any Native_VSH2_getProperty(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	if( StrEqual(prop_name, "iHealth") ) {
		return player.iHealth;
	} else if( StrEqual(prop_name, "iQueue") ) {
		return player.iQueue;
	} else if( StrEqual(prop_name, "bIsBoss") || StrEqual(prop_name, "bSetOnSpawn") ) {
		return player.iBossType >= VSH2Boss_Hale;
	}
	any item;
	if( !g_vsh2.m_hPlayerFields[player.index].GetValue(prop_name, item) ) {
		LogError("VSH2 VSH2Player.GetPropAny :: missing prop '%s'", prop_name);
	}
	return item;
}
public int Native_VSH2_setProperty(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	any item = GetNativeCell(3);
	if( StrEqual(prop_name, "iHealth") ) {
		player.iHealth = view_as< int >(item);
	} else if( StrEqual(prop_name, "iQueue") ) {
		player.iQueue = view_as< int >(item);
	}
	else g_vsh2.m_hPlayerFields[player.index].SetValue(prop_name, item);
}

public int Native_VSH2_getIntProp(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	if( StrEqual(prop_name, "iHealth") ) {
		return player.iHealth;
	} else if( StrEqual(prop_name, "iQueue") ) {
		return player.iQueue;
	} else if( StrEqual(prop_name, "bIsBoss") || StrEqual(prop_name, "bSetOnSpawn") ) {
		return player.iBossType >= VSH2Boss_Hale;
	}
	int item;
	if( !g_vsh2.m_hPlayerFields[player.index].GetValue(prop_name, item) ) {
		LogError("VSH2 VSH2Player.GetIntProp :: missing prop '%s'", prop_name);
	}
	return item;
}
public int Native_VSH2_setIntProp(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	int item = GetNativeCell(3);
	if( StrEqual(prop_name, "iHealth") ) {
		player.iHealth = item;
		return true;
	} else if( StrEqual(prop_name, "iQueue") ) {
		player.iQueue = item;
		return true;
	} else if( StrEqual(prop_name, "bIsBoss") || StrEqual(prop_name, "bSetOnSpawn") ) {
		return false;
	}
	return g_vsh2.m_hPlayerFields[player.index].SetValue(prop_name, item);
}

public any Native_VSH2_getFloatProp(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	float item;
	if( !g_vsh2.m_hPlayerFields[player.index].GetValue(prop_name, item) ) {
		LogError("VSH2 VSH2Player.GetFloatProp :: missing prop '%s'", prop_name);
	}
	return item;
}
public int Native_VSH2_setFloatProp(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	float item = GetNativeCell(3);
	return g_vsh2.m_hPlayerFields[player.index].SetValue(prop_name, item);
}

public int Native_VSH2_setProp(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	any item = GetNativeCell(3);
	if( StrEqual(prop_name, "iHealth") ) {
		SetEntityHealth(player.index, view_as< int >(item));
		return true;
	} else if( StrEqual(prop_name, "iQueue") ) {
		player.iQueue = view_as< int >(item);
		return true;
	} else if( StrEqual(prop_name, "bIsBoss") || StrEqual(prop_name, "bSetOnSpawn") ) {
		return false;
	}
	return g_vsh2.m_hPlayerFields[player.index].SetValue(prop_name, item);
}

public int Native_Hook(Handle plugin, int numParams)
{
	bool is_boss_module = g_modsys.IsPluginABoss(plugin);
	int vsh2Hook = GetNativeCell(1);
	Function func = GetNativeFunction(2);
	PrivateForward pw = g_modsys.GetForward(is_boss_module, vsh2Hook);
	if( pw != null )
		pw.AddFunction(plugin, func);
}

public int Native_HookEx(Handle plugin, int numParams)
{
	bool is_boss_module = g_modsys.IsPluginABoss(plugin);
	int vsh2Hook = GetNativeCell(1);
	Function func = GetNativeFunction(2);
	PrivateForward pw = g_modsys.GetForward(is_boss_module, vsh2Hook);
	if( pw != null )
		return pw.AddFunction(plugin, func);
	return 0;
}

public int Native_Unhook(Handle plugin, int numParams)
{
	bool is_boss_module = g_modsys.IsPluginABoss(plugin);
	int vsh2Hook = GetNativeCell(1);
	Function func = GetNativeFunction(2);
	PrivateForward pw = g_modsys.GetForward(is_boss_module, vsh2Hook);
	if( pw != null )
		pw.RemoveFunction(plugin, func);
}
public int Native_UnhookEx(Handle plugin, int numParams)
{
	bool is_boss_module = g_modsys.IsPluginABoss(plugin);
	int vsh2Hook = GetNativeCell(1);
	Function func = GetNativeFunction(2);
	PrivateForward pw = g_modsys.GetForward(is_boss_module, vsh2Hook);
	if( pw != null )
		return pw.RemoveFunction(plugin, func);
	return 0;
}

public int Native_GetRandomBossType(Handle plugin, int numParams)
{
	int filter_size = GetNativeCell(2);
	int[] filter = new int[filter_size];
	GetNativeArray(1, filter, filter_size);
	return GetRandomBossType(filter, filter_size);
}

public any Native_GetBossIDs(Handle plugin, int numParams)
{
	bool registered_only = GetNativeCell(1);
	StringMap boss_map = new StringMap();
	
	if( !registered_only ) {
		boss_map.SetValue("saxton_hale",             VSH2Boss_Hale);
		boss_map.SetValue("vagineer",                VSH2Boss_Vagineer);
		boss_map.SetValue("christian_brutal_sniper", VSH2Boss_CBS);
		boss_map.SetValue("hhh_jr",                  VSH2Boss_HHHjr);
		boss_map.SetValue("easter_bunny",            VSH2Boss_Bunny);
	}
	
	for( int i; i<g_modsys.m_hBossesRegistered.Length; i++ ) {
		BossModule boss_plugin;
		g_modsys.m_hBossesRegistered.GetArray(i, boss_plugin, sizeof(boss_plugin));
		boss_map.SetValue(boss_plugin.name, i + MaxDefaultVSH2Bosses);
	}
	
	if( !boss_map.Size ) {
		delete boss_map;
	}
	return boss_map;
}

public int Native_GetBossID(Handle plugin, int numParams)
{
	char bossname[MAX_BOSS_NAME_SIZE]; GetNativeString(1, bossname, MAX_BOSS_NAME_SIZE);
	for( int i; i<g_modsys.m_hBossesRegistered.Length; i++ ) {
		BossModule module;
		g_modsys.m_hBossesRegistered.GetArray(i, module, sizeof(module));
		if( !strcmp(module.name, bossname) )
			return i + MaxDefaultVSH2Bosses;
	}
	
	/// -1 == boss not found
	return -1;
}

public int Native_GetBossNameByIndex(Handle plugin, int numParams)
{
	int index = GetNativeCell(1);
	if( index < 0 ) {
		return 0;
	} else if( index < MaxDefaultVSH2Bosses ) {
		char def_name[MAX_BOSS_NAME_SIZE];
		switch( index ) {
			case VSH2Boss_Hale:     def_name = "saxton_hale";
			case VSH2Boss_Vagineer: def_name = "vagineer";
			case VSH2Boss_CBS:      def_name = "christian_brutal_sniper";
			case VSH2Boss_HHHjr:    def_name = "hhh_jr";
			case VSH2Boss_Bunny:    def_name = "easter_bunny";
		}
		SetNativeString(2, def_name, sizeof(def_name));
		return 1;
	}
	
	int arr_idx = index - MaxDefaultVSH2Bosses;
	if( arr_idx >= g_modsys.m_hBossesRegistered.Length ) {
		return 0;
	}
	BossModule module;
	int read = g_modsys.m_hBossesRegistered.GetArray(arr_idx, module, sizeof(module));
	if( read < sizeof(module) ) {
		return 0;
	}
	SetNativeString(2, module.name, sizeof(BossModule::name));
	return 1;
}

public int Native_StopMusic(Handle plugin, int numParams)
{
	bool reset_time = GetNativeCell(1);
	StopBackGroundMusic();
	if( reset_time ) {
		if( g_vsh2.m_hCvars.PlayerMusic.BoolValue ) {
			for( int i=MaxClients; i; --i ) {
				if( !IsClientValid(i) ) {
					continue;
				}
				BaseBoss player = BaseBoss(i);
				player.flMusicTime = -1.0;
			}
		} else {
			g_vsh2.m_hGamemode.flMusicTime = -1.0;
		}
	}
	return 0;
}

public any Native_GetMainConfig(Handle plugin, int numParams)
{
	return g_vsh2.m_hCfg.Clone(plugin);
}

public int Native_VSH2_ConvertToMinion(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	float spawntime = GetNativeCell(2);
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
	bool addhealth = GetNativeCell(2);
	int head_count = GetNativeCell(3);
	player.IncreaseHeadCount(addhealth, head_count);
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

public any Native_VSH2_ClimbWall(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int wep = GetNativeCell(2);
	float spawntime = GetNativeCell(3);
	float healthdmg = GetNativeCell(4);
	bool attackdelay = GetNativeCell(5);
	return player.ClimbWall(wep, spawntime, healthdmg, attackdelay);
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

public any Native_VSH2_IsInRange(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	float distance = GetNativeCell(3);
	return player.IsInRange(GetNativeCell(2), distance, GetNativeCell(4));
}

public int Native_VSH2_RemoveBack(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int length = GetNativeCell(3);
	int[] data = new int[length];
	GetNativeArray(2, data, length);
	player.RemoveBack(data, length);
}

public int Native_VSH2_FindBack(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int length = GetNativeCell(3);
	int[] data = new int[length];
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

public int Native_VSH2_Heal(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int health = GetNativeCell(2);
	bool hud = GetNativeCell(3);
	bool hp_override = GetNativeCell(4);
	int overheal_limit = GetNativeCell(5);
	player.Heal(health, hud, hp_override, overheal_limit);
	return 0;
}

public any Native_VSH2_AddTempAttrib(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int attrib = GetNativeCell(2);
	float val = GetNativeCell(3);
	float dur = GetNativeCell(4);
	return player.AddTempAttrib(attrib, val, dur);
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
	bool run_event = GetNativeCell(2);
	player.MakeBossAndSwitch(bossid, run_event);
}

public int Native_VSH2_DoGenericStun(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	float rage_radius = GetNativeCell(2);
	player.DoGenericStun(rage_radius);
}

public int Native_VSH2_StunPlayers(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	float rage_radius = GetNativeCell(2);
	float stun_time = GetNativeCell(3);
	player.StunPlayers(rage_radius, stun_time);
}

public int Native_VSH2_StunBuildings(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	float rage_radius = GetNativeCell(2);
	float sentry_stun_time = GetNativeCell(3);
	player.StunBuildings(rage_radius, sentry_stun_time);
}



public int Native_VSH2_RemoveAllItems(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	bool weps = numParams <= 1 ? true : GetNativeCell(2);
	player.RemoveAllItems(weps);
}

public any Native_VSH2_GetName(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char name[MAX_BOSS_NAME_SIZE];
	bool res = player.GetName(name);
	SetNativeString(2, name, sizeof(name), true);
	return res;
}

public any Native_VSH2_SetName(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char name[MAX_BOSS_NAME_SIZE];
	GetNativeString(2, name, sizeof(name));
	return player.SetName(name);
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

public int Native_VSH2_PlayMusic(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	float vol = GetNativeCell(2);
	player.PlayMusic(vol);
	return 0;
}

public int Native_VSH2_StopMusic(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.StopMusic();
	return 0;
}


public int Native_VSH2GameMode_GetProperty(Handle plugin, int numParams)
{
	char prop_name[64]; GetNativeString(1, prop_name, sizeof(prop_name));
	any item;
	if( g_vsh2.m_hGamemode.GetValue(prop_name, item) ) {
		return item;
	}
	return 0;
}
public int Native_VSH2GameMode_SetProperty(Handle plugin, int numParams)
{
	char prop_name[64]; GetNativeString(1, prop_name, sizeof(prop_name));
	any item = GetNativeCell(2);
	g_vsh2.m_hGamemode.SetValue(prop_name, item);
}
public any Native_VSH2GameMode_GetRandomBoss(Handle plugin, int numParams)
{
	bool alive = GetNativeCell(1);
	return VSHGameMode.GetRandomBoss(alive);
}
public any Native_VSH2GameMode_GetBossByType(Handle plugin, int numParams)
{
	bool alive = GetNativeCell(1);
	int bossid = GetNativeCell(2);
	return VSHGameMode.GetBossByType(alive, bossid);
}
public any Native_VSH2GameMode_FindNextBoss(Handle plugin, int numParams)
{
	return VSHGameMode.FindNextBoss();
}
public int Native_VSH2GameMode_CountMinions(Handle plugin, int numParams)
{
	bool alive = GetNativeCell(1);
	BaseBoss owner = GetNativeCell(2);
	return VSHGameMode.CountMinions(alive, owner);
}
public int Native_VSH2GameMode_CountBosses(Handle plugin, int numParams)
{
	bool alive = GetNativeCell(1);
	return VSHGameMode.CountBosses(alive);
}
public int Native_VSH2GameMode_GetTotalBossHealth(Handle plugin, int numParams)
{
	return VSHGameMode.GetTotalBossHealth();
}
public int Native_VSH2GameMode_SearchForItemPacks(Handle plugin, int numParams)
{
	VSHGameMode.SearchForItemPacks();
}
public int Native_VSH2GameMode_UpdateBossHealth(Handle plugin, int numParams)
{
	g_vsh2.m_hGamemode.UpdateBossHealth();
}
public int Native_VSH2GameMode_GetBossType(Handle plugin, int numParams)
{
	g_vsh2.m_hGamemode.GetBossType();
}

public int Native_VSH2GameMode_GetTotalRedPlayers(Handle plugin, int numParams)
{
	return GetLivingPlayers(VSH2Team_Red);
}

public any Native_VSH2GameMode_GetHUDHandle(Handle plugin, int numParams)
{
	int hud_type = GetNativeCell(1);
	hud_type = IntClamp(hud_type, HealthHUD, PlayerHUD);
	return g_vsh2.m_hHUDs[hud_type];
}

public int Native_VSH2GameMode_GetBosses(Handle plugin, int numParams)
{
	BaseBoss[] bosses = new BaseBoss[MaxClients];
	bool balive = GetNativeCell(2);
	int numbosses = VSHGameMode.GetBosses(bosses, balive);
	SetNativeArray(1, bosses, MaxClients);
	return numbosses;
}

public int Native_VSH2GameMode_IsVSHMap(Handle plugin, int numParams)
{
	return VSHGameMode.IsVSHMap();
}

public int Native_VSH2_GetMaxBosses(Handle plugin, int numParams)
{
	return MAXBOSS;
}

public int Native_VSH2GameMode_GetFighters(Handle plugin, int numParams)
{
	BaseBoss[] reds = new BaseBoss[MaxClients];
	bool balive = GetNativeCell(2);
	int numreds = VSHGameMode.GetFighters(reds, balive);
	SetNativeArray(1, reds, MaxClients);
	return numreds;
}

public int Native_VSH2GameMode_GetMinions(Handle plugin, int numParams)
{
	BaseBoss[] minions = new BaseBoss[MaxClients];
	bool balive = GetNativeCell(2);
	BaseBoss owner = GetNativeCell(3);
	int numminions = VSHGameMode.GetMinions(minions, balive, owner);
	SetNativeArray(1, minions, MaxClients);
	return numminions;
}

public int Native_VSH2GameMode_GetQueue(Handle plugin, int numParams)
{
	BaseBoss[] players = new BaseBoss[MaxClients];
	int n = VSHGameMode.GetQueue(players);
	SetNativeArray(1, players, MaxClients);
	return n;
}

public int Native_VSH2GameMode_GetBossesByType(Handle plugin, int numParams)
{
	BaseBoss[] bosses = new BaseBoss[MaxClients];
	int type = GetNativeCell(2);
	bool alive = GetNativeCell(3);
	int n = VSHGameMode.GetBossesByType(bosses, type, alive);
	SetNativeArray(1, bosses, MaxClients);
	return n;
}