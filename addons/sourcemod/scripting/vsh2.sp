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

#define PLUGIN_VERSION       "2.13.0"
#define PLUGIN_DESCRIPT      "VS Saxton Hale 2"


enum {
	PLYR = 256,
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
	ConVar CloakDrain;
	ConVar VersionNumber;
}

enum /** Cookies */ {
	Points,
	BossOpt,
	MusicOpt,
	BossPartnerOpt,
	MaxVSH2Cookies
};

enum struct BossModule {
	char   name[MAX_BOSS_NAME_SIZE];
	Handle plugin;
}

enum struct AbilityModule {
	int    bit_id[COMPONENT_LEN];
	Handle plugin;
}

PrivateForward g_hForwards[2][MaxVSH2Forwards];
enum struct VSH2ModuleSys {
	ArrayList m_hBossesRegistered; /// []BossModule
	StringMap m_hPluginMap;        /// map[Plugin]int
	StringMap m_hModuleMap;        /// map[string]Plugin
	StringMap m_hSharedMap;        /// data to share between addons & boss plugins.
	
	int       m_arriGenBits[COMPONENT_LEN];
	int       m_iBitSetIdx;        /// this is the array index.
	int       m_iBitIdx;           /// this is the bit index.
	StringMap m_hAbilityMap;       /// map[string]AbilityModule
	StringMap m_hAbilityBitIdxs;   /// map[string]int
	
	
	void init() {
		this.m_hBossesRegistered = new ArrayList(sizeof(BossModule));
		this.m_hPluginMap        = new StringMap();
		this.m_hModuleMap        = new StringMap();
		this.m_hSharedMap        = new StringMap();
		this.m_hAbilityMap       = new StringMap();
		this.m_hAbilityBitIdxs   = new StringMap();
	}
	
	bool IsPluginABoss(Handle plugin, int &index=(-1)) {
		char pl_hash[CELL_KEY_SIZE]; PackItem(plugin, pl_hash);
		return this.m_hPluginMap.GetValue(pl_hash, index);
	}
	
	PrivateForward GetForward(bool bosses, int index) {
		if( !IsIntInBounds(index, MaxVSH2Forwards-1, 0) ) {
			return null;
		}
		return g_hForwards[view_as< int >(bosses)][index];
	}
	
	void SetupDefaultAbilities() {
		RegisterAbility(null, ABILITY_RAGE);
		RegisterAbility(null, ABILITY_CLIMB_WALLS);
		RegisterAbility(null, ABILITY_SPAWN_HEALTH);
		RegisterAbility(null, ABILITY_SUPERJUMP);
		RegisterAbility(null, ABILITY_WEIGHDOWN);
		RegisterAbility(null, ABILITY_GLOW);
		RegisterAbility(null, ABILITY_ESCAPE_PLAN);
		RegisterAbility(null, ABILITY_STUN_PLYRS);
		RegisterAbility(null, ABILITY_STUN_BUILDS);
		RegisterAbility(null, ABILITY_TELEPORT);
		RegisterAbility(null, ABILITY_AUTO_FIRE);
		RegisterAbility(null, ABILITY_POWER_UBER);
		RegisterAbility(null, ABILITY_ANCHOR);
		RegisterAbility(null, ABILITY_GET_WEP);
		RegisterAbility(null, ABILITY_EXPLODE_AMMO);
	}
	
	int GetIndexOfPlugin(Handle pl) {
		char pl_hash[CELL_KEY_SIZE];
		PackItem(pl, pl_hash);
		int index = -1;
		this.m_hPluginMap.GetValue(pl_hash, index);
		return index;
	}
}

enum struct VSH2Globals {
	Handle    m_hHUDs[MaxVSH2HUDs];
	Cookie    m_hCookies[MaxVSH2Cookies];
	VSH2Cvars m_hCvars;
	char      m_strCurrSong[PLATFORM_MAX_PATH];
	ConfigMap m_hCfg;
	ConfigMap m_hBossCfgs[MaxDefaultVSH2Bosses];
	
	/// When making new properties, remember to base it off this StringMap
	/// AND do NOT forget to initialize it in 'OnClientPutInServer'.
	StringMap m_hPlayerFields[PLYR];
	
	void LoadBossCfgs() {
		char boss_names[][] = {
			"saxton_hale", "vagineer",
			"cbs", "hhh_jr", "easter_bunny"
		};
		for( int i; i < MaxDefaultVSH2Bosses; i++ ) {
			char cfg_path[PLATFORM_MAX_PATH];
			Format(cfg_path, sizeof(cfg_path), "configs/saxton_hale/boss_cfgs/%s.cfg", boss_names[i]);
			this.m_hBossCfgs[i] = new ConfigMap(cfg_path);
		}
	}
	
	ConfigMap GetPlayerCfg(BasePlayer player) {
		int boss_type = player.iBossType;
		if( boss_type < VSH2Boss_Hale ) {
			return this.m_hCfg;
		} else if( VSH2Boss_Hale <= boss_type < MaxDefaultVSH2Bosses ) {
			return this.m_hBossCfgs[boss_type];
		} else {
			return player.hConfig;
		}
	}
}

VSH2Globals   g_vsh2;
VSH2ModuleSys g_modsys;
VSHGameMode   g_vshgm;

#include "modules/stocks.inc" /// include stocks first.
#include "modules/handler.sp" /// Contains the game mode logic as well
#include "modules/events.sp"
#include "modules/commands.sp"

public void OnPluginStart() {
	g_vshgm = new VSHGameMode();
	g_vshgm.Init();
	
	/// in forwards.sp
	InitializeForwards();
	
	RegAdminCmd("sm_setspecial",     SetNextSpecial, ADMFLAG_GENERIC);
	RegAdminCmd("sm_halespecial",    SetNextSpecial, ADMFLAG_GENERIC);
	RegAdminCmd("sm_hale_special",   SetNextSpecial, ADMFLAG_GENERIC);
	RegAdminCmd("sm_bossspecial",    SetNextSpecial, ADMFLAG_GENERIC);
	RegAdminCmd("sm_boss_special",   SetNextSpecial, ADMFLAG_GENERIC);
	RegAdminCmd("sm_ff2special",     SetNextSpecial, ADMFLAG_GENERIC);
	RegAdminCmd("sm_ff2_special",    SetNextSpecial, ADMFLAG_GENERIC);
	
	RegConsoleCmd("sm_hale_next",    QueuePanelCmd);
	RegConsoleCmd("sm_halenext",     QueuePanelCmd);
	RegConsoleCmd("sm_boss_next",    QueuePanelCmd);
	RegConsoleCmd("sm_bossnext",     QueuePanelCmd);
	RegConsoleCmd("sm_ff2_next",     QueuePanelCmd);
	RegConsoleCmd("sm_ff2next",      QueuePanelCmd);
	
	RegConsoleCmd("sm_hale_hp",      Command_GetHPCmd);
	RegConsoleCmd("sm_halehp",       Command_GetHPCmd);
	RegConsoleCmd("sm_boss_hp",      Command_GetHPCmd);
	RegConsoleCmd("sm_bosshp",       Command_GetHPCmd);
	RegConsoleCmd("sm_ff2_hp",       Command_GetHPCmd);
	RegConsoleCmd("sm_ff2hp",        Command_GetHPCmd);
	
	RegConsoleCmd("sm_setboss",      SetBossMenu, "Sets your boss.");
	RegConsoleCmd("sm_sethale",      SetBossMenu, "Sets your boss.");
	RegConsoleCmd("sm_ff2boss",      SetBossMenu, "Sets your boss.");
	RegConsoleCmd("sm_haleboss",     SetBossMenu, "Sets your boss.");
	
	RegConsoleCmd("sm_halepartner",  BePartnerMenu, "Become a boss partner or not.");
	RegConsoleCmd("sm_bosspartner",  BePartnerMenu, "Become a boss partner or not.");
	RegConsoleCmd("sm_ff2partner",   BePartnerMenu, "Become a boss partner or not.");
	RegConsoleCmd("sm_vshpartner",   BePartnerMenu, "Become a boss partner or not.");
	
	RegConsoleCmd("sm_halemusic",    MusicTogglePanelCmd);
	RegConsoleCmd("sm_hale_music",   MusicTogglePanelCmd);
	RegConsoleCmd("sm_bossmusic",    MusicTogglePanelCmd);
	RegConsoleCmd("sm_boss_music",   MusicTogglePanelCmd);
	RegConsoleCmd("sm_ff2music",     MusicTogglePanelCmd);
	RegConsoleCmd("sm_ff2_music",    MusicTogglePanelCmd);
	
	RegConsoleCmd("sm_halehelp",     HelpPanelCmd);
	RegConsoleCmd("sm_hale_help",    HelpPanelCmd);
	RegConsoleCmd("sm_bosshelp",     HelpPanelCmd);
	RegConsoleCmd("sm_boss_help",    HelpPanelCmd);
	RegConsoleCmd("sm_ff2help",      HelpPanelCmd);
	RegConsoleCmd("sm_ff2_help",     HelpPanelCmd);
	
	RegConsoleCmd("sm_hale",         HelpPanelCmd);
	RegConsoleCmd("sm_boss",         HelpPanelCmd);
	RegConsoleCmd("sm_ff2",          HelpPanelCmd);
	
	RegConsoleCmd("sm_resetq",       ResetQueue);
	RegConsoleCmd("sm_resetqueue",   ResetQueue);
	
	RegAdminCmd("sm_vsh2_reloadcfg", CmdReloadCFG, ADMFLAG_GENERIC);
	
	RegAdminCmd("sm_hale_select",    CommandBossSelect, ADMFLAG_VOTE, "hale_select <target> - Select a player to be next boss.");
	RegAdminCmd("sm_ff2_select",     CommandBossSelect, ADMFLAG_VOTE, "ff2_select <target> - Select a player to be next boss.");
	RegAdminCmd("sm_boss_select",    CommandBossSelect, ADMFLAG_VOTE, "boss_select <target> - Select a player to be next boss.");
	RegAdminCmd("sm_vsh2_ability",   CmdAbility,        ADMFLAG_VOTE, "vsh2_ability <target> <ability name> <+/-/0> - Gives, Removes, or Removes all abilities from a player or players.");
	
	RegAdminCmd("sm_healthbarcolor", ChangeHealthBarColor, ADMFLAG_GENERIC);
	
	RegAdminCmd("sm_boss_force",     ForceBossRealtime, ADMFLAG_VOTE, "boss_force <target> <bossID> - Force a player to the boss team as the specified boss. (Setup time only)");
	RegAdminCmd("sm_hale_force",     ForceBossRealtime, ADMFLAG_VOTE, "hale_force <target> <bossID> - Force a player to the boss team as the specified boss. (Setup time only)");
	RegAdminCmd("sm_ff2_force",      ForceBossRealtime, ADMFLAG_VOTE, "ff2_force <target> <bossID> - Force a player to the boss team as the specified boss. (Setup time only)");
	
	RegAdminCmd("sm_hale_addpoints", CommandAddPoints, ADMFLAG_GENERIC);
	RegAdminCmd("sm_vsh2_addpoints", CommandAddPoints, ADMFLAG_GENERIC);
	RegAdminCmd("sm_ff2_addpoints",  CommandAddPoints, ADMFLAG_GENERIC);
	
	RegAdminCmd("sm_hale_setpoints", CommandSetPoints, ADMFLAG_GENERIC);
	RegAdminCmd("sm_vsh2_setpoints", CommandSetPoints, ADMFLAG_GENERIC);
	RegAdminCmd("sm_ff2_setpoints",  CommandSetPoints, ADMFLAG_GENERIC);
	
	RegAdminCmd("sm_hale_classrush", MenuDoClassRush, ADMFLAG_GENERIC, "forces all red players to a class.");
	RegAdminCmd("sm_vsh2_classrush", MenuDoClassRush, ADMFLAG_GENERIC, "forces all red players to a class.");
	
	AddCommandListener(BlockSuicide, "explode");
	AddCommandListener(BlockSuicide, "kill");
	AddCommandListener(BlockSuicide, "jointeam");
	
	AddCommandListener(CheckLateSpawn, "joinclass");
	AddCommandListener(CheckLateSpawn, "join_class");
	
	//AddCommandListener(DoTaunt,        "taunt");
	//AddCommandListener(DoTaunt,        "+taunt");
	
	for( int i; i < MaxVSH2HUDs; i++ ) {
		g_vsh2.m_hHUDs[i] = CreateHudSynchronizer();
	}
	
	g_vsh2.m_hCvars.Enabled = CreateConVar("vsh2_enabled", "1", "Enable VSH 2 plugin", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.VersionNumber = CreateConVar("vsh2_version", PLUGIN_VERSION, "VSH 2 Plugin Version. (DO NOT CHANGE)", FCVAR_NOTIFY);
	g_vsh2.m_hCvars.PointType = CreateConVar("vsh2_point_type", "0", "Select condition to enable point (0 - alive players, 1 - time)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_vsh2.m_hCvars.PointDelay = CreateConVar("vsh2_point_delay", "6", "Addition (for each player) delay before point's activation.", FCVAR_NOTIFY, true, 0.0, false);
	g_vsh2.m_hCvars.AliveToEnable = CreateConVar("vsh2_point_alive", "5", "Enable control points when there are X people left alive.", FCVAR_NOTIFY, true, 1.0, true, PLYR+0.0);
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
	g_vsh2.m_hCvars.CloakDrain = CreateConVar("vsh2_dispenser_cloak_drain_rate", "0.5", "how much cloak will be drained when a spy is using the invisiwatches near dispensers.", FCVAR_NONE, true, 0.0, true, 999999.0);
	
	g_vshgm.bSteam      = LibraryExists("SteamTools");
	g_vshgm.bTF2Attribs = LibraryExists("tf2attributes");
	
	g_modsys.init();
	g_modsys.SetupDefaultAbilities();
	
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
	g_vsh2.m_hCookies[BossPartnerOpt] = new Cookie("vsh2_boss_partner_settings", "BossPartner setting.", CookieAccess_Public);
	
	for( int i=1; i<=MaxClients; i++ ) {
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
	
	LoadTranslations("vsh2.phrases");
	LoadTranslations("common.phrases");
	LoadTranslations("core.phrases");
	
	g_vsh2.LoadBossCfgs();
}

public bool HaleTargetFilter(const char[] pattern, ArrayList clients) {
	bool non = StrContains(pattern, "!", false) != -1;
	for( int i=1; i<=MaxClients; i++ ) {
		if( IsClientValid(i) && clients.FindValue(i) == -1 ) {
			if( g_vsh2.m_hCvars.Enabled.BoolValue && BasePlayer(i).bIsBoss ) {
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

public bool MinionTargetFilter(const char[] pattern, ArrayList clients) {
	bool non = StrContains(pattern, "!", false) != -1;
	for( int i=1; i<=MaxClients; i++ ) {
		if( IsClientValid(i) && clients.FindValue(i) == -1 ) {
			if( g_vsh2.m_hCvars.Enabled.BoolValue && BasePlayer(i).bIsMinion ) {
				if( !non )
					clients.Push(i);
			} else if( non )
				clients.Push(i);
		}
	}
	return true;
}

public bool NextHaleTargetFilter(const char[] pattern, ArrayList clients) {
	bool non = StrContains(pattern, "!", false) != -1;
	for( int i=1; i<=MaxClients; i++ ) {
		if( IsClientValid(i) && clients.FindValue(i) == -1 ) {
			if( g_vsh2.m_hCvars.Enabled.BoolValue && BasePlayer(i)==VSHGameMode.FindNextBoss() ) {
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

public Action CheckLateSpawn(int client, const char[] command, int argc) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || g_vshgm.iRoundState != StateRunning )
		return Plugin_Continue;

	/// deal with late spawners, force them to spectator.
	if( !g_vsh2.m_hCvars.AllowLateSpawn.BoolValue
		&& GetClientTeam(client) > VSH2Team_Spectator
		&& TF2_GetPlayerClass(client)==TFClass_Unknown
		&& (GetGameTime() - g_vshgm.flRoundStartTime) > g_vsh2.m_hCvars.LateSpawnDelay.FloatValue
	) {
		char str_tfclass[20]; GetCmdArg(1, str_tfclass, sizeof(str_tfclass));
		TFClassType classtype = TF2_GetClass(str_tfclass);
		CPrintToChat(client, "{olive}[VSH 2]{default} %t", "late_spawn_blocked");
		SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", view_as< int >(classtype));
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action BlockSuicide(int client, const char[] command, int argc) {
	if( g_vsh2.m_hCvars.Enabled.BoolValue && g_vshgm.iRoundState == StateRunning ) {
		BasePlayer player = BasePlayer(client);
		if( player.bIsBoss ) {
			/// Allow bosses to suicide if their total health is under a certain percentage.
			float flhp_percent = float(player.iHealth) / float(player.iMaxHealth);
			if( flhp_percent > g_vsh2.m_hCvars.SuicidePercent.FloatValue ) {
				CPrintToChat(client, "{olive}[VSH 2]{default} %t", "cant_suicide_as_boss");
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

public void OnLibraryAdded(const char[] name) {
	if( !strcmp(name, "SteamTools", false) )
		g_vshgm.bSteam = true;

	if( !strcmp(name, "tf2attributes", false) )
		g_vshgm.bTF2Attribs = true;

#if defined _updater_included
	if( !strcmp(name, "updater") )
		Updater_AddPlugin(UPDATE_URL);
#endif
}

public void OnLibraryRemoved(const char[] name) {
	if( !strcmp(name, "SteamTools", false) )
		g_vshgm.bSteam = false;

	if( !strcmp(name, "tf2attributes", false) )
		g_vshgm.bTF2Attribs = false;
}

/// UPDATER Stuff
public void OnAllPluginsLoaded() {
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

public void OnConfigsExecuted() {
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
		cvar_mp_teams_unbalance_limit.IntValue = g_vsh2.m_hCvars.FirstRound.BoolValue? 0 : 1;
		cvar_mp_forcecamera.IntValue           = g_vsh2.m_hCvars.FirstRound.BoolValue? 0 : 1;
		cvar_tf_arena_first_blood.IntValue     = 0;
		cvar_mp_forcecamera.IntValue           = 0;
		cvar_tf_scout_hype_pep_max.FloatValue  = 100.0;
		
		g_vshgm.CheckDoors();
		g_vshgm.CheckTeleToSpawn();
#if defined _steamtools_included
		if( g_vshgm.bSteam ) {
			char gameDesc[128];
			Format(gameDesc, sizeof(gameDesc), "%t (v%s)", "server_descriptor", PLUGIN_VERSION);
			Steam_SetGameDescription(gameDesc);
		}
#endif
	}
}

public void OnClientPutInServer(int client) {
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_GetMaxHealth, GetMaxHealth);
	SDKHook(client, SDKHook_TraceAttack, TraceAttack);
	SDKHook(client, SDKHook_Touch, OnTouch);
	SDKHook(client, SDKHook_PreThinkPost, OnPreThinkPost);
	
	if( g_vsh2.m_hPlayerFields[client] != null ) {
		delete g_vsh2.m_hPlayerFields[client];
	}
	g_vsh2.m_hPlayerFields[client] = new StringMap();
	
	BasePlayer boss = BasePlayer(client);
	/// BasePlayer properties
	g_vsh2.m_hPlayerFields[client].SetValue("iQueue", 0);
	g_vsh2.m_hPlayerFields[client].SetValue("iPresetType", -1);
	g_vsh2.m_hPlayerFields[client].SetValue("bCanBossPartner", true);
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
	boss.iBossWins = 0;
	boss.iBossLosses = 0;
	boss.iBossKills = 0;
	
	/// BasePlayer properties
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
	boss.RemoveAllAbilities();
}

public void OnClientDisconnect(int client) {
	if( client <= 0 || client > MaxClients || g_vsh2.m_hPlayerFields[client]==null ) {
		return;
	}
	g_vsh2.m_hPlayerFields[client].SetValue("iBossType", -1);
	ManageDisconnect(client);
}

public void OnClientPostAdminCheck(int client) {
	SetPawnTimer(ConnectionMessage, 5.0, GetClientUserId(client));
}

public void ConnectionMessage(int userid) {
	int client = GetClientOfUserId(userid);
	if( IsClientValidExtra(client) && g_vsh2.m_hCvars.Enabled.BoolValue) {
		CPrintToChat(client, "{olive}[VSH 2]{default} %t", "vsh2_welcome");
		if( g_vshgm.iRoundState==StateRunning ) {
			BasePlayer player = BasePlayer(userid, true);
			if( g_vsh2.m_hCvars.PlayerMusic.BoolValue ) {
				player.SetMusic(g_vsh2.m_strCurrSong);
			}
			player.PlayMusic(g_vsh2.m_hCvars.MusicVolume.FloatValue);
		}
	}
}

public Action OnTouch(int client, int other) {
	if( 0 < other <= MaxClients ) {
		BasePlayer boss = BasePlayer(client);
		BasePlayer victim = BasePlayer(other);
		if( boss.bIsBoss && !victim.bIsBoss ) {
			return ManageOnTouchPlayer(boss, victim); /// in handler.sp
		}
	} else if( IsValidEntity(other) ) {
		BasePlayer player = BasePlayer(client);
		if( player.bIsBoss ) {
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

public void OnMapStart() {
	ManageDownloads();    /// in handler.sp
	CreateTimer(0.1, Timer_PlayerThink, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(1.0, MakeModelTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	
	g_vshgm.iHealthBar  = VSHHealthBar();
	g_vshgm.iRoundCount = 0;
	g_vshgm.iRoundState = StateDisabled;
	g_vshgm.hNextBoss   = view_as< BasePlayer >(0);
	
	if( g_vsh2.m_hCfg != null ) {
		DeleteCfg(g_vsh2.m_hCfg);
	}
	g_vsh2.m_hCfg = new ConfigMap("configs/saxton_hale/vsh2.cfg");
	if( g_vsh2.m_hCfg==null ) {
		LogError("[VSH 2] ERROR :: **** couldn't find 'configs/saxton_hale/vsh2.cfg' ****");
	}
}

public void OnMapEnd() {
	FindConVar("tf_arena_use_queue").IntValue       = g_oldcvar_vals.tf_arena_use_queue;
	FindConVar("mp_teams_unbalance_limit").IntValue = g_oldcvar_vals.mp_teams_unbalance_limit;
	FindConVar("mp_forceautoteam").IntValue         = g_oldcvar_vals.mp_forceautoteam;
	FindConVar("tf_arena_first_blood").IntValue     = g_oldcvar_vals.tf_arena_first_blood;
	FindConVar("mp_forcecamera").IntValue           = g_oldcvar_vals.mp_forcecamera;
	FindConVar("tf_scout_hype_pep_max").FloatValue  = g_oldcvar_vals.tf_scout_hype_pep_max;
}

public void _MakePlayerBoss(int userid) {
	int client = GetClientOfUserId(userid);
	if( IsClientValid(client) ) {
		BasePlayer player = BasePlayer(userid, true);
		/// in handler.sp; sets health, model, and equips the boss
		ManageBossTransition(player);
	}
}

public void _MakePlayerMinion(int userid) {
	int client = GetClientOfUserId(userid);
	if( IsClientValid(client) ) {
		BasePlayer player = BasePlayer(userid, true);
		/// in handler.sp; sets health, model, and equips the boss
		ManageMinionTransition(player);
	}
}

public void _BossDeath(any userid) {
	int client = GetClientOfUserId(userid);
	if( IsClientValid(client) ) {
		BasePlayer player = BasePlayer(userid, true);
		ManageBossDeath(player); /// in handler.sp
	}
}
public Action MakeModelTimer(Handle hTimer) {
	for( int i=1; i<=MaxClients; i++ ) {
		if( !IsClientValidExtra(i, false) || !IsPlayerAlive(i) ) {
			continue;
		}
		BasePlayer player = BasePlayer(i);
		if( player.bIsBoss ) {
			ManageBossModels(player); /// in handler.sp
		}
	}
	return Plugin_Continue;
}

/// the main 'mechanics' of bosses
public Action Timer_PlayerThink(Handle hTimer) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || g_vshgm.iRoundState != StateRunning ) {
		return Plugin_Continue;
	}
	
	g_vshgm.UpdateBossHealth();
	if( g_vshgm.flMusicTime <= GetGameTime() ) {
		_MusicPlay();
	}
	
	int total_boss_health = VSHGameMode.GetTotalBossHealth();
	int show_bosshp_alive = g_vsh2.m_hCvars.ShowBossHPLiving.IntValue;
	float scout_rage_gen  = g_vsh2.m_hCvars.ScoutRageGen.FloatValue;
	float tele_cooldown   = g_vsh2.m_hCvars.HHHTeleCooldown.FloatValue;
	for( int i=1; i <= MaxClients; i++ ) {
		if( !IsClientValidExtra(i, false) ) {
			continue;
		}
		/**
		 * If player is a boss, force Boss think on them;
		 * if not boss or on blue team, force fighter think!
		 */
		BasePlayer player = BasePlayer(i);
		bool is_boss = player.bIsBoss;
		if( is_boss ) {
			TF2_AddCondition(i, TFCond_GrapplingHookSafeFall, 0.2);
		}
		
		//Action act = is_boss? Call_OnBossThink(player) : Call_OnRedPlayerThink(player);
		if( (is_boss? Call_OnBossThink(player) : Call_OnRedPlayerThink(player)) > Plugin_Changed ) {
			continue;
		}
		
		/// Abilities need to work **BEFORE** HUD logic.
		ConfigMap cfg = g_vsh2.GetPlayerCfg(player);
		ConfigMap abilities = cfg.GetSection("abilities");
		if( player.HasAbility(ABILITY_ESCAPE_PLAN) ) {
			ConfigMap ability = abilities.GetSection(ABILITY_ESCAPE_PLAN);
			float iota_speed  = ability.GetIntKeyFloatEx(0, 300.0);
			float min_speed   = ability.GetIntKeyFloatEx(1, 100.0);
			float args[2];
			args[0] = iota_speed;
			args[1] = min_speed;
			Action act = player.RunPreAbility(ABILITY_ESCAPE_PLAN, args, sizeof(args));
			if( act==Plugin_Changed ) {
				iota_speed = args[0];
				min_speed  = args[1];
			}
			player.SpeedThink(iota_speed, min_speed);
			player.PlayRandVoiceClipFromCfg(ability.GetSection("sounds"), VSH2_VOICE_ABILITY);
			player.RunPostAbility(ABILITY_ESCAPE_PLAN, args, sizeof(args), act==Plugin_Changed);
		}
		if( player.HasAbility(ABILITY_GLOW) ) {
			ConfigMap ability = abilities.GetSection(ABILITY_GLOW);
			float decr_rate   = ability.GetIntKeyFloatEx(0, 0.1);
			float args[1];
			args[0] = decr_rate;
			Action act = player.RunPreAbility(ABILITY_GLOW, args, sizeof(args));
			player.GlowThink(decr_rate);
			player.PlayRandVoiceClipFromCfg(ability.GetSection("sounds"), VSH2_VOICE_ABILITY);
			player.RunPostAbility(ABILITY_GLOW, args, sizeof(args), act==Plugin_Changed);
		}
		if( player.HasAbility(ABILITY_SUPERJUMP) ) {
			ConfigMap ability = abilities.GetSection(ABILITY_SUPERJUMP);
			float charge_rate = ability.GetIntKeyFloatEx(0, 2.5);
			float max_charge  = ability.GetIntKeyFloatEx(1, 25.0);
			if( player.SuperJumpThink(charge_rate, max_charge) ) {
				player.SuperJump(player.flCharge, ability.GetIntKeyFloatEx(2, -100.0));
				player.PlayRandVoiceClipFromCfg(ability.GetSection("sounds"), VSH2_VOICE_ABILITY);
			}
		} else if( player.HasAbility(ABILITY_TELEPORT) ) {
			float curr_charge  = player.flCharge;
			bool super_charged = player.bSuperCharge;
			float angle_eyes[3]; GetClientEyeAngles(i, angle_eyes);
			
			ConfigMap ability = abilities.GetSection(ABILITY_TELEPORT);
			float charge_rate = ability.GetIntKeyFloatEx(0, 2.5);
			float max_charge  = ability.GetIntKeyFloatEx(1, 50.0);
			float cooldown    = ability.GetIntKeyFloatEx(2, tele_cooldown);
			if( player.ChargedAbilityThink(charge_rate, curr_charge, max_charge, max_charge, IN_DUCK|IN_ATTACK2, angle_eyes[0] < -5.0, super_charged) ) {
				float args[3];
				args[0] = charge_rate;
				args[1] = max_charge;
				args[2] = cooldown;
				Action act = player.RunPreAbility(ABILITY_TELEPORT, args, sizeof(args));
				if( act==Plugin_Changed ) {
					cooldown = args[2];
				}
				player.TeleToRandomPlayer(cooldown, true);
				player.RunPostAbility(ABILITY_TELEPORT, args, sizeof(args), act==Plugin_Changed);
				player.PlayRandVoiceClipFromCfg(ability.GetSection("sounds"), VSH2_VOICE_ABILITY);
			} else {
				player.flCharge = curr_charge;
			}
		}
		if( player.HasAbility(ABILITY_RAGE) && OnlyScoutsLeft(VSH2Team_Red) ) {
			player.flRAGE += scout_rage_gen;
		}
		if( player.HasAbility(ABILITY_WEIGHDOWN) ) {
			ConfigMap ability = abilities.GetSection(ABILITY_WEIGHDOWN);
			float time = ability.GetIntKeyFloatEx(0, 2.0);
			player.WeighDownThink(time);
			player.PlayRandVoiceClipFromCfg(ability.GetSection("sounds"), VSH2_VOICE_ABILITY);
		}
		
		if( player.HasAbility(ABILITY_POWER_UBER) ) {
			SetEntProp(i, Prop_Data, "m_takedamage", 2 * view_as< int >(!TF2_IsPlayerInCondition(i, TFCond_Ubercharged)));
		}
		
		int flags = GetEntityFlags(i);
		if( flags & FL_ONGROUND ) {
			player.iClimbs = 0;
		}
		
		if( is_boss ) {
			ManageBossHUD(player);
			Call_OnBossThinkPost(player);
		} else {
			if( HasEntProp(i, Prop_Send, "m_iKillStreak") ) {
				/// killstreak support code.
				/// TODO: put a cvar for killstreak divider.
				int killstreaker = player.iDamage / 1000;
				if( killstreaker > 0 && GetEntProp(i, Prop_Send, "m_iKillStreak") >= 0 ) {
					SetEntProp(i, Prop_Send, "m_iKillStreak", killstreaker);
				}
			}
			ManageFighterHUD(player);
			ManageFighterCrits(player);
			Call_OnRedPlayerThinkPost(player);
		}
		
		if( GetLivingPlayers(VSH2Team_Red) <= show_bosshp_alive ) {
			/// TODO: put this to cvar.
			SetHudTextParams(-1.0, 0.15, 0.11, 255, 255, 255, 255);
			ShowSyncHudText(i, g_vsh2.m_hHUDs[HealthHUD], "%t%i", "total_boss_health", total_boss_health);
		}
	}
	
	/// If there's no active, living bosses then force RED to win
	if( !VSHGameMode.CountBosses(true) ) {
		/// Put vsh2 event here `OnBossAllDead`?
		g_vshgm.iRoundResult = RoundResBossDied;
		ForceTeamWin(VSH2Team_Red);
	}
	return Plugin_Continue;
}

public void OnPreThinkPost(int client) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || IsClientObserver(client) || !IsPlayerAlive(client) ) {
		return;
	} else if( TF2_IsPlayerInCondition(client, TFCond_Cloaked) && IsNearSpencer(client) ) {
		float cloak_drain_rate = g_vsh2.m_hCvars.CloakDrain.FloatValue;
		float cloak = GetEntPropFloat(client, Prop_Send, "m_flCloakMeter") - cloak_drain_rate;
		if( cloak < 0.0 ) {
			cloak = 0.0;
		}
		SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", cloak);
	}
}

public Action TraceAttack(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	} else if( IsClientValid(attacker) && IsClientValid(victim) ) {
		BasePlayer player = BasePlayer(victim);
		BasePlayer enemy  = BasePlayer(attacker);
		return Call_OnTraceAttack(player, enemy, inflictor, damage, damagetype, ammotype, hitbox, hitgroup);
	}
	return Plugin_Continue;
}
public Action OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || !IsClientValid(victim) ) {
		return Plugin_Continue;
	} else if( g_vshgm.iRoundState==StateStarting ) {
		damage = 0.0;
		return Plugin_Changed;
	}
	
	BasePlayer boss_victim = BasePlayer(victim);
	if( boss_victim.bIsBoss ) { /// in handler.sp
		return ManageOnBossTakeDamage(boss_victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	}
	/// BUG PATCH: Client index 0 is invalid
	if( !IsClientValid(attacker) ) {
		if( (damagetype & DMG_FALL) && !boss_victim.bIsBoss ) {
			Action act = Call_OnPlayerTakeFallDamage(boss_victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
			int item = GetPlayerWeaponSlot(victim, (boss_victim.iTFClass==TFClass_DemoMan? TFWeaponSlot_Primary : TFWeaponSlot_Secondary));
			if( item <= 0 || !IsValidEntity(item)
				|| (boss_victim.iTFClass==TFClass_Spy && TF2_IsPlayerInCondition(victim, TFCond_Cloaked)) ) {
				if( act != Plugin_Changed ) {
					/// TODO: cvar for fall damage logic.
					//g_vsh2.m_hCvars.PlayerFallDmgAmnt.IntValue;
					//g_vsh2.m_hCvars.PlayerFallDmgLogic.IntValue;
					damage /= 10;
				}
			}
			return Plugin_Changed;
		}
		return Plugin_Continue;
	}
	
	BasePlayer boss_attacker = BasePlayer(attacker);
	if( boss_attacker.bIsBoss ) { /// in handler.sp
		return ManageOnBossDealDamage(boss_victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	}
	return Plugin_Continue;
}

public Action GetMaxHealth(int entity, int &maxhealth) {
	if( !IsClientValid(entity) ) {
		return Plugin_Continue;
	}
	
	BasePlayer player = BasePlayer(entity);
	if( player.bIsBoss && player.iMaxHealth ) {
		maxhealth = player.iMaxHealth;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

#if defined _goomba_included_
public Action OnStomp(int attacker, int victim, float& damageMultiplier, float& damageAdd, float& JumpPower) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	}
	return ManageOnGoombaStomp(attacker, victim, damageMultiplier, damageAdd, JumpPower);
}
#endif

public Action cdVoiceMenu(int client, const char[] command, int argc) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	} else if( argc < 2 || !IsPlayerAlive(client) ) {
		return Plugin_Handled;
	}
	char szCmd1[8]; GetCmdArg(1, szCmd1, sizeof(szCmd1));
	char szCmd2[8]; GetCmdArg(2, szCmd2, sizeof(szCmd2));
	
	/// Capture call for medic commands (represented by "voicemenu 0 0")
	BasePlayer boss = BasePlayer(client);
	if( szCmd1[0]=='0' && szCmd2[0]=='0' ) {
		ManageBossMedicCall(boss);
	}
	return Plugin_Continue;
}

public Action DoTaunt(int client, const char[] command, int argc) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	}
	
	BasePlayer boss = BasePlayer(client);
	if( boss.HasAbility(ABILITY_RAGE) && boss.flRAGE >= 100.0 ) {
		ManageBossTaunt(boss);
	}
	return Plugin_Continue;
}

public void OnEntityCreated(int entity, const char[] classname) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return;
	} else if( !strncmp(classname, "tf_weapon_", 10, false) && IsValidEntity(entity) ) {
		CreateTimer(0.5, OnWeaponSpawned, EntIndexToEntRef(entity));
	}
	ManageEntityCreated(entity, classname);
}

public Action OnWeaponSpawned(Handle timer, any ref) {
	int wep = EntRefToEntIndex(ref);
	if( !IsValidEntity(wep) ) {
		return Plugin_Continue;
	}
	
	int client = GetOwner(wep);
	if( !IsClientValidExtra(client) ) {
		return Plugin_Continue;
	}
	
	if( GetClientTeam(client)==VSH2Team_Red ) {
		int slot = GetSlotFromWeapon(client, wep);
		if( IsIntInBounds(slot, 2, 0) ) {
			g_munitions[client].SetAmmo(slot, GetWeaponAmmo(wep));
			g_munitions[client].SetClip(slot, GetWeaponClip(wep));
		}
	}
	return Plugin_Continue;
}

/// scores kept glitching out and I hate debugging so I made it its own func.
public void ShowPlayerScores() {
	BasePlayer top_players[3];
	BasePlayer(0).iDamage = 0;
	for( int i=1; i<=MaxClients; i++ ) {
		if( !IsClientValidExtra(i) || GetClientTeam(i) <= VSH2Team_Spectator ) {
			continue;
		}
		
		BasePlayer player = BasePlayer(i);
		if( player.bIsBoss || player.iDamage==0 ) {
			//player.iDamage = 0;
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
	int damages[3], num_valid;
	for( int i; i < 3; i++ ) {
		if( IsClientValid(top_players[i].index) && top_players[i].iDamage > 0 ) {
			GetClientName(top_players[i].index, names[i], sizeof(names[]));
			damages[i] = top_players[i].iDamage;
			num_valid++;
		} else {
			names[i] = "nil";
		}
	}
	
	/// Should clear center text
	PrintCenterTextAll("");
	if( Call_OnShowStats(top_players) > Plugin_Changed ) {
		return;
	}
	
	SetHudTextParams(-1.0, 0.35, 10.0, 255, 255, 255, 255);
	char damage_list[512];
	Format(damage_list, sizeof(damage_list), "%T", "top_3", LANG_SERVER);
	/// could this possibly glitch out?
	for( int i; i < num_valid; i++ ) {
		Format(damage_list, sizeof(damage_list), "%s\n%i)%i - %s", damage_list, i+1, damages[i], names[i]);
	}
	
	for( int i=1; i<=MaxClients; i++ ) {
		if( !IsClientValid(i) || (GetClientButtons(i) & IN_SCORE) ) {
			continue;
		}
		BasePlayer player = BasePlayer(i);
		ShowHudText(i, -1, "%s\n\n%t %i", damage_list, "damage_dealt", player.iDamage);
	}
}

public void CalcScores() {
	int queue_gain     = g_vsh2.m_hCvars.QueueGained.IntValue;
	int damage_gain    = g_vsh2.m_hCvars.DamageForQueue.IntValue;
	int damage_points  = g_vsh2.m_hCvars.DamagePoints.IntValue;
	bool use_dmg_queue = g_vsh2.m_hCvars.DamageQueue.BoolValue;
	for( int i=1; i<=MaxClients; i++ ) {
		if( !IsClientValid(i) || GetClientTeam(i) < VSH2Team_Red ) {
			continue;
		}
		/// We don't want the Bosses getting free points for doing damage.
		BasePlayer player = BasePlayer(i);
		if( player.bIsBoss ) {
			continue;
		}
		
		/// Questioning this system because basically hard-hitters like Spies and Snipers
		/// will have a higher likelihood of becomes bosses most of the time.
		int dmg    = player.iDamage;
		int queue  = use_dmg_queue? (queue_gain + (dmg / damage_gain)) : queue_gain;
		int points = dmg / damage_points;
		if( Call_OnScoreTally(player, points, queue) > Plugin_Changed ) {
			continue;
		}
		Event scoring = CreateEvent("player_escort_score", true);
		scoring.SetInt("player", i);
		scoring.SetInt("points", points);
		scoring.Fire();
		
		player.iQueue += queue;
		CPrintToChat(i, "{olive}[VSH 2] Queue{default} %t", "gained_points", queue);
		CPrintToChat(i, "{olive}[VSH 2] Queue{default} %t", "scored_points", points);
	}
}

public Action Timer_DrawGame(Handle timer) {
	if( g_vshgm.iHealthBar.iPercent < g_vsh2.m_hCvars.HealthPercentForLastGuy.IntValue
		|| g_vshgm.iRoundState != StateRunning
		|| g_vshgm.iTimeLeft < 0
		|| GetLivingPlayers(VSH2Team_Red) > 1
	) {
		g_vshgm.iTimeLeft = 0;
		return Plugin_Stop;
	}
	
	int time = g_vshgm.iTimeLeft;
	Action act = Call_OnDrawGameTimer(time);
	if( act > Plugin_Changed ) {
		return act;
	} else if( act==Plugin_Changed ) {
		g_vshgm.iTimeLeft = time;
	} else {
		g_vshgm.iTimeLeft--;
	}
	
	char strTime[10];
	SecondsToTime(time, strTime);
	SetHudTextParams(-1.0, 0.17, 1.1, 255, 255, 255, 255);
	for( int i=1; i<=MaxClients; i++ ) {
		if( !IsClientValidExtra(i) ) {
			continue;
		}
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
			/// TODO: add cvar for what team wins when time is up.
			g_vshgm.iRoundResult = RoundResTimer;
			ForceTeamWin(VSH2Team_Spectator);
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

public void _ResetMediCharge(int entid, float val) {
	int medigun = EntRefToEntIndex(entid);
	if( IsValidEntity(medigun) ) {
		SetMediCharge(medigun, GetMediGunCharge(medigun) + val);
	}
}

public Action TimerUberLoop(Handle timer, any medigunid) {
	if( g_vshgm.iRoundState != StateRunning ) {
		return Plugin_Stop;
	}
	
	int medigun = EntRefToEntIndex(medigunid);
	if( IsValidEntity(medigun) ) {
		int medic          = GetOwner(medigun);
		float charge       = GetMediGunCharge(medigun);
		BasePlayer med     = BasePlayer(medic);
		int target         = med.GetHealTarget();
		BasePlayer patient = BasePlayer(target);
		if( charge > 0.05 ) {
			Action act = Call_OnUberLoop(med, patient);
			if( act==Plugin_Stop ) {
				return act;
			}
			
			TF2_AddCondition(medic, TFCond_CritOnWin, 0.5);
			if( IsClientValid(target) && IsPlayerAlive(target) ) {
				TF2_AddCondition(target, TFCond_CritOnWin, 0.5);
				med.iUberTarget = GetClientUserId(target);
			} else {
				med.iUberTarget = 0;
			}
		} else if( charge < 0.05 ) {
			float reset_charge = g_vsh2.m_hCvars.MedigunReset.FloatValue;
			Call_OnUberLoopEnd(med, patient, reset_charge);
			SetPawnTimer(_ResetMediCharge, 3.0, EntIndexToEntRef(medigun), reset_charge);
			return Plugin_Stop;
		}
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

public void _MusicPlay() {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || !g_vsh2.m_hCvars.EnableMusic.BoolValue || g_vshgm.iRoundState != StateRunning ) {
		return;
	}
	
	float currtime = GetGameTime();
	bool use_player_music = g_vsh2.m_hCvars.PlayerMusic.BoolValue;
	if( !use_player_music && g_vshgm.flMusicTime > currtime ) {
		return;
	}
	
	float vol = g_vsh2.m_hCvars.MusicVolume.FloatValue;
	if( use_player_music ) {
		for( int i=1; i<=MaxClients; i++ ) {
			if( !IsClientValid(i) ) {
				continue;
			}
			
			BasePlayer player = BasePlayer(i);
			if( player.flMusicTime > currtime ) {
				continue;
			}
			
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
			for( int i=1; i<=MaxClients; i++ ) {
				if( !IsClientValid(i) ) {
					continue;
				}
				BasePlayer(i).PlayMusic(vol);
			}
		}
		if( time != -1.0 ) {
			g_vshgm.flMusicTime = currtime + time;
		}
	}
}


int GetRandomBossType(int[] boss_id_filter, int filter_size=0) {
	int bosses_size = g_vshgm.MAXBOSS + 1;
	int[] bosses_id = new int[bosses_size];
	int count;
	for( int i; i <= g_vshgm.MAXBOSS; i++ ) {
		bool filtered;
		for( int n; n < filter_size; n++ ) {
			if( boss_id_filter[n] >= bosses_size ) {
				continue;
			} else if( boss_id_filter[n]==i ) {
				filtered = true;
				break;
			}
		}
		if( !filtered ) {
			bosses_id[count++] = i;
		}
	}
	return bosses_id[GetRandomInt(0, count)];
}


public int RegisterBossPlugin(Handle plugin, const char modulename[MAX_BOSS_NAME_SIZE]) {
	if( !ValidateName(modulename) ) {
		LogError("VSH2 :: Boss Plugin Registrar: **** Invalid Name For Boss Module: '%s' ****", modulename);
		return -1;
	}
	
	/// Technically a single plugin can register multiple bosses.
	/// However, the plugin hash value will have the very newest
	/// registered boss index.
	
	/// So far with the way this function has been written,
	/// this doesn't interfere with the operations of having multiple
	/// bosses in one plugin aka a boss pack, however it's important
	/// to keep this in mind what's going on here.
	
	
	/// A boss name maps to a plugin.
	/// If something weird happens...
	/// ...it's either another plugin mapping to an existing boss.
	/// ...or it's the SAME plugin (different handle, same  name) but mapping again so that means it was reloaded.
	/// ...or it's the same plugin (same handle & name) and mapping again (perhaps VSH2 was reloaded).
	
	/// For the 1st scenario, we check if the plugin, mapping to an existing boss, exists and is valid.
	/// For the 2nd scenario, we update the plugin handle and reuse the index.
	/// For the 3rd scenario, we just return the index.
	/// Otherwise, register as a new boss.
	
	
	
	char pl_hash[CELL_KEY_SIZE];
	PackItem(plugin, pl_hash);
	int index = g_modsys.GetIndexOfPlugin(plugin);
	if( IsIntInBounds(index, g_vshgm.MAXBOSS, MaxDefaultVSH2Bosses) ) {
		BossModule module;
		g_modsys.m_hBossesRegistered.GetArray(index, module, sizeof(module));
		if( !strcmp(module.name, modulename) ) {
			if( IsValidPlugin(module.plugin) ) {
				LogError("VSH2 :: Boss Plugin Registrar: **** Plugin '%s' Already Registered ****", modulename);
				return index + MaxDefaultVSH2Bosses;
			}
			
			/// the boss being registered has the same name but it's of a different handle ID?
			/// override its plugin ID then, it was probably reloaded.
			module.plugin = plugin;
			g_modsys.m_hBossesRegistered.SetArray(index, module, sizeof(module));
			return index + MaxDefaultVSH2Bosses;
		}
	}
	/*
	Handle checked_plugin;
	if( UpdatePluginHandle(checked_plugin, modulename) && checked_plugin != plugin ) {
		char pl_hash2[CELL_KEY_SIZE];
		PackItem(checked_plugin, pl_hash2);
		
	}
	*/
	/// Couldn't find boss of the name at all, assume it's a brand new boss being reg'd.
	BossModule module;
	module.name = modulename;
	module.plugin = plugin;
	index = g_modsys.m_hBossesRegistered.PushArray(module, sizeof(module));
	g_modsys.m_hPluginMap.SetValue(pl_hash, index);
	g_modsys.m_hModuleMap.SetValue(modulename, plugin);
	return g_vshgm.MAXBOSS;
}


public bool RegisterAbility(Handle plugin, const char[] ability_name) {
	AbilityModule module;
	if( g_modsys.m_hAbilityMap.GetArray(ability_name, module, sizeof(module)) ) {
		if( IsValidPlugin(module.plugin) ) {
			LogError("VSH2 :: Ability Registrar: **** Ability '%s' Already Registered ****", ability_name);
			return false;
		}
		module.plugin = plugin;
		return g_modsys.m_hAbilityMap.SetArray(ability_name, module, sizeof(module));
	}
	
	GenerateBitID(g_modsys.m_arriGenBits, sizeof(VSH2ModuleSys::m_arriGenBits), g_modsys.m_iBitSetIdx, g_modsys.m_iBitIdx);
	module.bit_id  = g_modsys.m_arriGenBits;
	module.plugin  = plugin;
	g_modsys.m_hAbilityBitIdxs.SetValue(ability_name, g_modsys.m_iBitIdx);
	return g_modsys.m_hAbilityMap.SetArray(ability_name, module, sizeof(module));
}

#include "modules/natives.sp"