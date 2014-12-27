#undef REQUIRE_EXTENSIONS
#tryinclude <steamtools>
#define REQUIRE_EXTENSIONS

#include <sourcemod>
#include <clientprefs>
#include <vsha>
#include <tf2attributes>
#include <morecolors>
#include <sdkhooks>

#pragma semicolon		1
#pragma newdecls		required
#define PLUGIN_VERSION		"1.0"

public Plugin myinfo = {
	name = "Versus Saxton Hale Engine",
	author = "Nergal, Chdata, Cookies, with special props to Powerlord + Flamin' Sarge",
	description = "Es Sexy-time beyechez",
	version = PLUGIN_VERSION,
	url = "https://bitbucket.org/assyrian/vsh-engine",
};


// V A R I A B L E S =========================================================================

//Handles
Handle Storage[PLYR];

//ints
int iBossUserID[PLYR];		//USERID NUM OVER CLIENT INT
int iBoss[PLYR];		//THIS IS NOT THE USER, IT'S THE SPECIAL BOSS IDs
int iDifficulty[PLYR];
int iPresetBoss[PLYR];
int iBossHealth[PLYR];
int iBossMaxHealth[PLYR];
int iPlayerKilled[PLYR][2];	//0 - kill count, 1 - killing spree
int iBossesKilled[PLYR];
int iDamage[PLYR];
int iAirDamage[PLYR];
int iMarketed[PLYR];
int iStabbed[PLYR];
int iUberedTarget[PLYR];
int iLives[PLYR];		//lives can work for BOTH Bosses & for players, get creative!
int iHits[PLYR];		//How many times a player has been hit lol
int AmmoTable[2049];
int ClipTable[2049];
int HaleTeam = 3;
int OtherTeam = 2;
int iNextBossPlayer;
int iTotalBossHP;
int iHealthBar = -1;
int iRedAlivePlayers;
int iBluAlivePlayers;
int iPlaying = 0;
int TeamRoundCounter;
int RoundCount;
int timeleft;

//floats
float flCharge[PLYR]; //SINGLE MEDIC-TAUNT/RAGE CHARGE, MAKE YOUR OWN CHARGE VARS IN YOUR OWN BOSS SUBPLUGINS
float flKillStreak[PLYR];
float flGlowTimer[PLYR];
float flHPTime;

//bools
bool Enabled;
bool bIsBoss[PLYR]; //EITHER IS BOSS OR NOT
bool bIsMinion[PLYR]; //is a minion :>
bool bInJump[PLYR];
bool bNoTaunt[PLYR];
bool bTenSecStart[2];
bool PointType;
bool PointReady;
bool steamtools;

//chars
char charBossName[PATH];

//================================================================================================

int tf_arena_use_queue;
int mp_teams_unbalance_limit;
int tf_arena_first_blood;
int mp_forcecamera;
float tf_scout_hype_pep_max;

//cvar Handles
ConVar bEnabled = null;
ConVar FirstRound = null;
ConVar MedigunReset = null;
ConVar AliveToEnable = null;
ConVar CountDownPlayerLimit = null;
ConVar CountDownHealthLimit = null;
ConVar LastPlayersTimerCountDown = null;
ConVar EnableEurekaEffect = null;
ConVar PointDelay = null;
ConVar QueueIncrement = null;
ConVar FallDmgSoldier = null;
//ConVar DifficultyAmount = null;

//non-cvar Handles
Handle hBossHUD;
Handle hPlayerHUD;
Handle TimeLeftHUD = null;
Handle MiscHUD = null; //for various other HUD additions
//Handle CustomHUD = null;
Handle hdoorchecktimer = null;
Handle PointCookie = null;
Handle MusicTimer = null;
Handle DrawGameTimer = null;

//Forward Handles
Handle AddToDownloads;

public void OnPluginStart()
{
	SetHandles();

	bEnabled = CreateConVar("vshe_enabled", "1", "Enable the VSH Engine", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	FirstRound = CreateConVar("vshe_firstround", "1", "Enable first round for VSH Engine", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	MedigunReset = CreateConVar("vshe_medigunreset", "0.40", "default ubercharge for when mediguns reset", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	AliveToEnable = CreateConVar("vshe_alivetoenable", "3", "how many players left to enable cap", FCVAR_PLUGIN, true, 0.0, true, 16.0);
	CountDownPlayerLimit = CreateConVar("vshe_countdownplayerlimit", "3", "how many players must be left to start the final countdown timer", FCVAR_PLUGIN, true, 0.0, true, 16.0);
	CountDownHealthLimit = CreateConVar("vshe_countdownbosshealth", "5000", "how low boss health must be to start the final countdown timer", FCVAR_PLUGIN, true, 0.0, true, 999999.0);
	LastPlayersTimerCountDown = CreateConVar("vshe_finalcountdowntimer", "120", "how long the final countdown timer is", FCVAR_PLUGIN, true, 0.0, true, 99999.0);
	EnableEurekaEffect = CreateConVar("vshe_alloweureka", "1", "(dis)allows the eureka wrench from being used", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	PointDelay = CreateConVar("vshe_capturepointdelay", "10", "time in seconds the cap is delayed from enabling", FCVAR_PLUGIN, true, 0.0, true, 999.0);
	QueueIncrement = CreateConVar("vshe_queueincrement", "10", "by how much queue increments", FCVAR_PLUGIN, true, 1.0, true, 999.0);
	FallDmgSoldier = CreateConVar("vshe_soldierfalldamage", "20.0", "divides fall damage by this number", FCVAR_PLUGIN, true, 0.0, true, 999.0);
	//DifficultyAmount = CreateConVar("vshe_difficultyamount", "3", "how many difficulty settings you want available for bosses to choose", FCVAR_PLUGIN, true, 0.0, true, 999.0);

	AddCommandListener(DoTaunt, "taunt");
	AddCommandListener(DoTaunt, "+taunt");
	AddCommandListener(CallMedVoiceMenu, "voicemenu");
	AddCommandListener(DoSuicide, "explode");
	AddCommandListener(DoSuicide, "kill");
	AddCommandListener(DoSuicide2, "jointeam");
	AddCommandListener(KillOwnShit, "destroy");

	HookEvent("teamplay_round_start", RoundStart);
	HookEvent("teamplay_round_win", RoundEnd);
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("post_inventory_application", Resupply);
	HookEvent("player_death", PlayerDeath, EventHookMode_Pre);
	HookEvent("player_hurt", PlayerHurt, EventHookMode_Pre);
	HookEvent("player_chargedeployed", UberDeployed);
	HookEvent("object_destroyed", Destroyed, EventHookMode_Pre);
	HookEvent("object_deflected", Deflected, EventHookMode_Pre);
	HookEvent("rocket_jump", OnHookedEvent);
	HookEvent("rocket_jump_landed", OnHookedEvent);
	HookEvent("sticky_jump", OnHookedEvent);
	HookEvent("sticky_jump_landed", OnHookedEvent);
	HookEvent("player_death", OnHookedEvent);
	//HookEvent("player_changeclass", ChangeClass);

	RegConsoleCmd("sm_vsha_special", CommandMakeNextSpecial);

	RegConsoleCmd("sm_setboss", PickBossMenu);
	RegConsoleCmd("sm_haleboss", PickBossMenu);
	RegConsoleCmd("sm_vshaboss", PickBossMenu);
	RegConsoleCmd("sm_vsheboss", PickBossMenu);

	hBossHUD = CreateHudSynchronizer();
	hPlayerHUD = CreateHudSynchronizer();
	TimeLeftHUD = CreateHudSynchronizer();
	MiscHUD = CreateHudSynchronizer();

	PointCookie = RegClientCookie("vshe_queuepoints", "Amount of VSH Engine Queue points, the player has", CookieAccess_Protected);

	LoadSubPlugins();

	AutoExecConfig(true, "VSH-Engine");

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) continue;
		OnClientPutInServer(i);
	}
}
public Action KillOwnShit(int client, const char[] command, int argc)
{
	if (!Enabled || bIsBoss[client]) return Plugin_Continue;
	if (client && TF2_GetPlayerClass(client) == TFClass_Engineer && TF2_IsPlayerInCondition(client, TFCond_Taunting) && GetIndexOfWeaponSlot(client, TFWeaponSlot_Melee) == 589) return Plugin_Handled;
	return Plugin_Continue;
}
public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_PreThink, OnPreThink);
	Storage[client] = null;
	iBoss[client] = -1;
	iPresetBoss[client] = -1;
	bIsBoss[client] = false;
	bIsMinion[client] = false;
	iDifficulty[client] = 0;
	iDamage[client] = 0;
	iBossesKilled[client] = 0;
	iPlayerKilled[client][0] = 0;
	iPlayerKilled[client][1] = 1;
	iHits[client] = 0;
}
public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if ( !Enabled || (victim == attacker && bIsBoss[victim]) ) return Plugin_Continue;

	if ( CheckRoundState() == 0 && bIsBoss[victim] )
	{
		damage *= 0.0;
		return Plugin_Changed;
	}
	if (!attacker && (damagetype & DMG_FALL) && bIsBoss[victim])
	{
		damage = (iBossHealth[victim] > 100) ? 10.0 : 100.0; //please don't fuck with this.
		return Plugin_Changed;
	}

	float AttackerPos[3];
	Action result;
	GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", AttackerPos); //Spot of attacker
	iHits[victim]++;
	if (bIsBoss[attacker])
	{
		if (!bIsBoss[victim] && !TF2_IsPlayerInCondition(victim, TFCond_Bonked) && !TF2_IsPlayerInCondition(victim, TFCond_Ubercharged))
		{
			Function BossDealtDmg = GetFunctionByName(Storage[attacker], "VSHA_OnBossDealDmg");
			if (BossDealtDmg != INVALID_FUNCTION)
			{
				Call_StartFunction(Storage[attacker], BossDealtDmg);
				Call_PushCell(victim);
				Call_PushCellRef(attacker);
				Call_PushCellRef(weapon);
				Call_PushCellRef(inflictor);
				Call_PushFloatRef(damage);
				Call_PushCellRef(damagetype);
				Call_PushCell(damagecustom);
				Call_Finish(result);
				return result;
			}
		}
	}
	else
	{
		if (attacker <= MaxClients && bIsBoss[victim])
		{
			if ( damagecustom == TF_CUSTOM_TELEFRAG )
			{
				if (!IsPlayerAlive(attacker))
				{
					damage = 1.0;
					return Plugin_Changed;
				}
				Function FuncBossTelefragged = GetFunctionByName(Storage[victim], "VSHA_OnBossTeleFragd");
				if (FuncBossTelefragged != INVALID_FUNCTION)
				{
					Call_StartFunction(Storage[victim], FuncBossTelefragged);
					Call_PushCell(victim);
					Call_PushCellRef(attacker);
					Call_PushFloatRef(damage);
					Call_Finish(result);
					return result;
				}
			}
			Function FuncBossTakeDmg = GetFunctionByName(Storage[victim], "VSHA_OnBossTakeDmg");
			if (FuncBossTakeDmg != INVALID_FUNCTION)
			{
				Call_StartFunction(Storage[victim], FuncBossTakeDmg);
				Call_PushCell(victim);
				Call_PushCellRef(attacker);
				Call_PushCellRef(weapon);
				Call_PushCellRef(inflictor);
				Call_PushFloatRef(damage);
				Call_PushCellRef(damagetype);
				Call_PushCell(damagecustom);
				Call_Finish(result);
				return result;
			}
			if (damagecustom == TF_CUSTOM_BACKSTAB)
			{
				//damage = ( (Pow(float(iBossMaxHealth[victim])*0.0014, 2.0) + 899.0) - (float(iBossMaxHealth[victim])*(iStabbed[victim]/100)) )/3;
				damagetype |= DMG_CRIT;

				EmitSoundToClient(victim, "player/spy_shield_break.wav", _, _, SNDLEVEL_TRAFFIC, _, 0.7, 100, _, AttackerPos, _, false);
				EmitSoundToClient(attacker, "player/spy_shield_break.wav", _, _, SNDLEVEL_TRAFFIC, _, 0.7, 100, _, AttackerPos, _, false);
				EmitSoundToClient(victim, "player/crit_received3.wav", _, _, SNDLEVEL_TRAFFIC, _, 0.7, 100, _, _, _, false);
				EmitSoundToClient(attacker, "player/crit_received3.wav", _, _, SNDLEVEL_TRAFFIC, _, 0.7, 100, _, _, _, false);
				//SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+2.0);
				//SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GetGameTime()+2.0);
				//SetEntPropFloat(attacker, Prop_Send, "m_flStealthNextChangeTime", GetGameTime()+1.0);

				int viewmodel = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
				if (viewmodel > MaxClients && IsValidEntity(viewmodel) && TF2_GetPlayerClass(attacker) == TFClass_Spy)
				{
					int melee = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Melee);
					int animation = 15;
					switch (melee)
					{
						case 727: animation = 41; //Black Rose
						case 4, 194, 665, 794, 803, 883, 892, 901, 910: animation = 10; //Knife, Strange Knife, Festive Knife, Botkiller Knifes
						case 638: animation = 31; //Sharp Dresser
					}
					SetEntProp(viewmodel, Prop_Send, "m_nSequence", animation);
				}
				PrintCenterText(attacker, "You Tickled The Boss!");
				PrintCenterText(victim, "You Were Just Tickled!");
				/*if (index == 356)  //Conniver's Kunai
				{
					int health = GetClientHealth(attacker)+350;
					if (health > 500) health = 500;
					SetEntProp(attacker, Prop_Data, "m_iHealth", health);
					SetEntProp(attacker, Prop_Send, "m_iHealth", health);
				}
				else if (index == 461) SetEntPropFloat(attacker, Prop_Send, "m_flCloakMeter", 100.0);  //Full cloak for Big Earner

				else if (index == 525) SetEntProp(attacker, Prop_Send, "m_iRevengeCrits", GetEntProp(attacker, Prop_Send, "m_iRevengeCrits")+2); //Diamondback*/

				iStabbed[victim]++;

				Function FuncBossStabbed = GetFunctionByName(Storage[victim], "VSHA_OnBossStabbed");
				if (FuncBossStabbed != INVALID_FUNCTION)
				{
					Call_StartFunction(Storage[victim], FuncBossStabbed);
					Call_PushCell(victim);
					Call_PushCellRef(attacker);
					Call_PushCellRef(weapon);
					Call_PushFloatRef(damage);
					Call_Finish(result);
					return result;
				}
			}
			/*else
			{
				char hurt[64];
				if (GetEdictClassname(attacker, hurt, sizeof(hurt)) && !strcmp(hurt, "trigger_hurt", false))
				{
					// Teleport the boss back to one of the spawns.
					// And during the first 30 seconds, he can only teleport to his own spawn.
					//TeleportToSpawn(victim, (bTenSecStart[1]) ? HaleTeam : 0);

					Function FuncBossTrigger = GetFunctionByName(Storage[victim], "VSHA_OnBossTriggerHurt");
					if (FuncBossTrigger != INVALID_FUNCTION)
					{
						int result;
						Call_StartFunction(Storage[victim], FuncBossTrigger);
						Call_PushCell(victim);
						Call_PushCell(attacker);
						Call_PushCell(weapon);
						Call_PushFloat(damage);
						Call_Finish(result);
						return result;
					}

					else if (damage >= 250.0) TeleportToSpawn(victim, (bTenSecStart[1]) ? HaleTeam : 0);

					float flMaxDmg = float(iBossMaxHealth[victim])*0.05;
					if (flMaxDmg > 500.0) flMaxDmg = 500.0;
					if (damage > flMaxDmg) damage = flMaxDmg;

					iBossHealth[victim] -= RoundFloat(damage);
					if (iBossHealth[victim] <= 0) damage *= 5;
					return Plugin_Changed;
				}
			}*/
			//if (flCharge[victim] > 100.0) flCharge[victim] = 100.0;
		}
		else  //TODO: LOOK AT THIS
		{
			if (IsValidClient(victim, false) && TF2_GetPlayerClass(victim) == TFClass_Soldier)
			{
				if (damagetype & DMG_FALL)
				{
					int secondary = GetPlayerWeaponSlot(victim, TFWeaponSlot_Secondary);
					if ( !IsValidEntity(secondary) )
					{
						damage /= FallDmgSoldier.FloatValue; //GetConVarFloat(FallDmgSoldier);
						return Plugin_Changed;
					}
				}
			}
		}
	}
	return Plugin_Continue;
}
public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKUnhook(client, SDKHook_PreThink, OnPreThink);
	iBoss[client] = -1;
	iPresetBoss[client] = -1;
	iDamage[client] = 0;
	iBossUserID[client] = -1;
	iHits[client] = 0;
	TF2Attrib_RemoveAll(client);
	if (Enabled)
	{
		if (bIsBoss[client])
		{
			switch ( CheckRoundState() )
			{
				case 2: SetClientQueuePoints(client, 0);
				case 1: ForceTeamWin(OtherTeam);
				case 0:
				{
					int tHale;
					if (iNextBossPlayer > 0)
					{
						tHale = iNextBossPlayer;
						iNextBossPlayer = -1;
					}
					else tHale = FindNextBoss(bIsBoss);
					bIsBoss[tHale] = true;
					iBossUserID[tHale] = GetClientUserId(tHale);
					Storage[tHale] = Storage[client];
					if (GetClientTeam(tHale) != HaleTeam) ForceTeamChange(tHale, HaleTeam);
					CreateTimer(0.1, MakeBoss, iBossUserID[tHale]);
					CPrintToChat(tHale, "{olive}[VSH Engine]{default} Surprise! You're on NOW!");
				}
			}
			bIsBoss[client] = false;
			CPrintToChatAll("{olive}[VSH Engine]{default} Boss just disconnected!");
			Storage[client] = null;
		}
		else
		{
			if ( IsClientInGame(client) )
			{
				if ( IsPlayerAlive(client) ) CreateTimer(0.1, CheckAlivePlayers);
				if ( client == FindNextBoss(bIsBoss) ) CreateTimer(1.0, Timer_SkipHalePanel, _, TIMER_FLAG_NO_MAPCHANGE);
			}
			if ( client == iNextBossPlayer ) iNextBossPlayer = -1;
		}
	}
}
stock void SetClientGlow(int client, float time1, float clampfl = -1.0)
{
	if (IsValidClient(client))
	{
		flGlowTimer[client] += time1;
		if (clampfl > 0.0) flGlowTimer[client] = clampfl;
		if (flGlowTimer[client] <= 0.0)
		{
			flGlowTimer[client] = 0.0;
			SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);
		}
		else SetEntProp(client, Prop_Send, "m_bGlowEnabled", 1);
	}
}
public void OnMapStart()
{
	if ( IsVSHMap() )
	{
		Enabled = true;
		tf_arena_use_queue = GetConVarInt(FindConVar("tf_arena_use_queue"));
		mp_teams_unbalance_limit = GetConVarInt(FindConVar("mp_teams_unbalance_limit"));
		tf_arena_first_blood = GetConVarInt(FindConVar("tf_arena_first_blood"));
		mp_forcecamera = GetConVarInt(FindConVar("mp_forcecamera"));
		tf_scout_hype_pep_max = GetConVarFloat(FindConVar("tf_scout_hype_pep_max"));
		CacheDownloads();
		FindHealthBar();
#if defined _steamtools_included
		if (steamtools)
		{
			char gameDesc[64];
			Format(gameDesc, sizeof(gameDesc), "VS Saxton Hale Advanced v%s", PLUGIN_VERSION);
			Steam_SetGameDescription(gameDesc);
		}
#endif
		SetConVarInt(FindConVar("tf_arena_use_queue"), 0);
		SetConVarInt(FindConVar("mp_teams_unbalance_limit"), FirstRound.BoolValue ? 0 : 1); //GetConVarBool(FirstRound)
		SetConVarInt(FindConVar("tf_arena_first_blood"), 0);
		SetConVarInt(FindConVar("mp_forcecamera"), 0);
		SetConVarFloat(FindConVar("tf_scout_hype_pep_max"), 100.0);
	}
	else Enabled = false; //enforcing strict arena only
}
public void OnMapEnd()
{
	if ( Enabled )
	{
		SetConVarInt(FindConVar("tf_arena_use_queue"), tf_arena_use_queue);
		SetConVarInt(FindConVar("mp_teams_unbalance_limit"), mp_teams_unbalance_limit);
		SetConVarInt(FindConVar("tf_arena_first_blood"), tf_arena_first_blood);
		SetConVarInt(FindConVar("mp_forcecamera"), mp_forcecamera);
		SetConVarFloat(FindConVar("tf_scout_hype_pep_max"), tf_scout_hype_pep_max);
#if defined _steamtools_included
		if (steamtools) Steam_SetGameDescription("Team Fortress");
#endif
	}
}
public void OnLibraryAdded(const char[] name) //:D
{
#if defined _steamtools_included
	if (strcmp(name, "SteamTools", false) == 0) steamtools = true;
#endif
}
public void OnLibraryRemoved(const char[] name)
{
#if defined _steamtools_included
	if (strcmp(name, "SteamTools", false) == 0) steamtools = false;
#endif
}
public void CacheDownloads()
{
	Call_StartForward(AddToDownloads);
	Call_Finish();
	AddFileToDownloadsTable("sound/saxton_hale/9000.wav");
	PrecacheSound("saxton_hale/9000.wav", true);
	PrecacheSound("vo/announcer_am_capincite01.wav", true);
	PrecacheSound("vo/announcer_am_capincite03.wav", true);
	PrecacheSound("vo/announcer_am_capenabled01.wav", true);
	PrecacheSound("vo/announcer_am_capenabled02.wav", true);
	PrecacheSound("vo/announcer_am_capenabled03.wav", true);
	PrecacheSound("vo/announcer_am_capenabled04.wav", true);
	PrecacheSound("weapons/barret_arm_zap.wav", true);
	PrecacheSound("vo/announcer_ends_2min.wav", true);
	PrecacheSound("player/doubledonk.wav", true);
}
public void FindHealthBar()
{
	iHealthBar = FindEntityByClassname2(-1, "monster_resource");
	if (iHealthBar == -1)
	{
		iHealthBar = CreateEntityByName("monster_resource");
		if (iHealthBar != -1) DispatchSpawn(iHealthBar);
	}
}
public Action RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (!Enabled)
	{
#if defined _steamtools_included
		if (steamtools) Steam_SetGameDescription("Team Fortress");
#endif
		return Plugin_Continue;
	}
	ClearTimer(MusicTimer);
	CheckArena();
	int i;
	iPlaying = 0;
	for (i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && GetClientTeam(i) > view_as<int>(TFTeam_Spectator))
		{
			if (bIsBoss[i] || bIsMinion[i]) ForceTeamChange(i, HaleTeam);
			else if (!bIsBoss[i] && !bIsMinion[i])
			{
				ForceTeamChange(i, OtherTeam);
				iDamage[i] = 0;
				iPlaying++;
			}
		}
	}
	if (GetClientCount() <= 1 || iPlaying < 2)
	{
		CPrintToChatAll("{olive}[VSH Engine]{default} Need more players to begin");
		Enabled = false;
		SetControlPoint(true);
		return Plugin_Continue;
	}
	if ( GetTeamPlayerCount(HaleTeam) <= 0 || GetTeamPlayerCount(OtherTeam) <= 0 )
	{
		for (i = 1; i <= MaxClients; i++)
		{
			if ( IsValidClient(i) && GetClientTeam(i) > view_as<int>(TFTeam_Spectator) )
			{
				if (bIsBoss[i]) ForceTeamChange(i, HaleTeam);
				else ForceTeamChange(i, OtherTeam);
			}
		}
	}
	PickBossSpecial( GetSingleBoss() );
	bTenSecStart[0] = true;
	bTenSecStart[1] = true;
	CreateTimer(29.1, tTenSecStart, 0);
	CreateTimer(60.0, tTenSecStart, 1);
	CreateTimer(0.0, TimerInitBoss); //one timer for all
	PointReady = false;

	i = -1;
	while ((i = FindEntityByClassname2(i, "func_regenerate")) != -1)
		AcceptEntityInput(i, "Disable");

	i = -1;
	while ((i = FindEntityByClassname2(i, "func_respawnroomvisualizer")) != -1)
		AcceptEntityInput(i, "Disable");

	i = -1;
	while ((i = FindEntityByClassname2(i, "obj_dispenser")) != -1)
	{
		SetVariantInt(OtherTeam);
		AcceptEntityInput(i, "SetTeam");
		AcceptEntityInput(i, "skin");
		SetEntProp(i, Prop_Send, "m_nSkin", OtherTeam-2);
	}

	i = -1;
	while ((i = FindEntityByClassname2(i, "mapobj_cart_dispenser")) != -1)
	{
		SetVariantInt(OtherTeam);
		AcceptEntityInput(i, "SetTeam");
		AcceptEntityInput(i, "skin");
	}
	SearchForItemPacks();
	return Plugin_Continue;
}
public Action tTenSecStart(Handle hTimer, any ofs)
{
	bTenSecStart[ofs] = false;
	return Plugin_Continue;
}
public Action PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if (!Enabled) return Plugin_Continue;
	int client = GetClientOfUserId(event.GetInt("userid"));
	SetVariantString("");
	AcceptEntityInput(client, "SetCustomModel");
	if (client && IsClientInGame(client) && (CheckRoundState() > -1 && CheckRoundState() < 2))
	{
		if (bIsBoss[client] || bIsMinion[client]) CreateTimer(0.1, MakeBoss, GetClientUserId(client));
		else
		{
			TF2_RemoveAllWeapons2(client);
			TF2_RegeneratePlayer(client);
			CreateTimer(0.1, TimerEquipPlayers, GetClientUserId(client));
		}
	}
	if ( CheckRoundState() == 1 ) CreateTimer(0.5, CheckAlivePlayers);
	return Plugin_Continue;
}
public Action Resupply(Event event, const char[] name, bool dontBroadcast)
{
	if (!Enabled) return Plugin_Continue;
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client && IsClientInGame(client) && (CheckRoundState() > -1 && CheckRoundState() < 2))
	{
		if (bIsBoss[client] || bIsMinion[client]) CreateTimer(0.1, MakeBoss, GetClientUserId(client));
		else
		{
			TF2_RemoveAllWeapons2(client);
			TF2_RegeneratePlayer(client);
			CreateTimer(0.1, TimerEquipPlayers, GetClientUserId(client));
		}
	}
	return Plugin_Continue;
}
public Action PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	if ( !Enabled ) return Plugin_Continue;
	int client = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int damage = event.GetInt("damageamount");

	if (bIsBoss[client])
	{
		if (client == attacker) return Plugin_Continue;
		if (event.GetBool("minicrit") && event.GetBool("allseecrit")) event.SetBool("allseecrit", false);
		iBossHealth[client] -= damage;
		iDamage[attacker] += damage;

		int iHealers[MAXPLAYERS];
		int iHealerCount;
		int target;
		for (target = 1; target <= MaxClients; target++)
		{
			if ( IsValidClient(target) && IsPlayerAlive(target) && (GetHealingTarget(target) == attacker) )
			{
				iHealers[iHealerCount] = target;
				iHealerCount++;
			}
		}

		for (target = 0; target < iHealerCount; target++)
		{
			if (IsValidClient(iHealers[target]) && IsPlayerAlive(iHealers[target]))
			{
				if (damage < 10 || iUberedTarget[iHealers[target]] == attacker) iDamage[iHealers[target]] += damage;
				else iDamage[iHealers[target]] += damage/(iHealerCount+1);
			}
		}
		if (TF2_GetPlayerClass(attacker) == TFClass_Soldier && GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Primary) == 1104)
		{
			iAirDamage[attacker] += damage;
			SetEntProp(attacker, Prop_Send, "m_iDecapitations", iAirDamage[attacker]/200);
		}
	}
	else iDamage[attacker] += damage; //increment boss' dmg
	return Plugin_Continue;
}
public Action PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if ( CheckRoundState() != 1 || !Enabled || (event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER) ) return Plugin_Continue;

	int client = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	CreateTimer(0.1, CheckAlivePlayers);
	SetClientOverlay(client, "");
	if (!bIsBoss[client])
	{
		CPrintToChat( client, "{olive}[VSH Engine]{default} Damage dealt: {red}%i{default}. Score for this round: {red}%i{default}", iDamage[client], RoundFloat(iDamage[client]/600.0) );
		if (bIsBoss[attacker])
		{
			if ( GetGameTime() <= flKillStreak[attacker] ) iPlayerKilled[attacker][1]++;
			else iPlayerKilled[attacker][1] = 0;

			Function FuncPlayerKilled = GetFunctionByName(Storage[attacker], "VSHA_OnPlayerKilled");
			if (FuncPlayerKilled != INVALID_FUNCTION) /*purpose of this forward is for kill specific mechanics*/
			{
				Call_StartFunction(Storage[attacker], FuncPlayerKilled);
				Call_PushCell(attacker);
				Call_PushCell(client);
				Call_Finish();
			}

			if ( iPlayerKilled[attacker][1] >= GetRandomInt(2, 3) )
			{
				Function FuncKillSpree = GetFunctionByName(Storage[attacker], "VSHA_OnKillingSpree");
				if (FuncKillSpree != INVALID_FUNCTION) /*purpose of this forward is for killing spree specific mechanics like killing spree boss sound clips*/
				{
					Call_StartFunction(Storage[attacker], FuncKillSpree);
					Call_PushCell(attacker);
					Call_PushCell(client);
					Call_Finish();
				}
				iPlayerKilled[attacker][1] = 0;
			}
			else flKillStreak[attacker] = GetGameTime() + 5.0;
			iPlayerKilled[attacker][0]++;
		}
		if (TF2_GetPlayerClass(client) == TFClass_Engineer) //Destroys sentry gun when Engineer dies before it.
		{
			FakeClientCommand(client, "destroy 2");
			int KillSentry = FindSentry(client);
			if ( KillSentry != -1 )
			{
				SetVariantInt(GetEntPropEnt(KillSentry, Prop_Send, "m_iMaxHealth")+1);
				AcceptEntityInput(KillSentry, "RemoveHealth");

				Event engieevent = CreateEvent("object_removed", true);
				engieevent.SetInt("userid", GetClientUserId(client));
				engieevent.SetInt("index", KillSentry);
				engieevent.Fire();
				AcceptEntityInput(KillSentry, "Kill");
			}
		}
	}
	else
	{
		iBossesKilled[attacker]++;
		if ( iBossHealth[client] < 0 ) iBossHealth[client] = 0;

		Function FuncBossKilled = GetFunctionByName(Storage[client], "VSHA_OnBossKilled");
		if (FuncBossKilled != INVALID_FUNCTION)
		{
			Call_StartFunction(Storage[client], FuncBossKilled);
			Call_PushCell(client);
			Call_PushCell(attacker);
			Call_Finish();
		}

		UpdateHealthBar();
		iStabbed[client] = 0;
		iMarketed[client] = 0;
		bIsBoss[client] = false;
	}
	return Plugin_Continue;
}
public Action RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (!Enabled) return Plugin_Continue;
	TeamRoundCounter++;
	RoundCount++;
	int i;
	bool playedwinsound = false;
	for (i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) continue;
		if (bIsBoss[i])
		{
			if (event.GetInt("team") == HaleTeam && !playedwinsound)
			{
				Function FuncBossWon = GetFunctionByName(Storage[i], "VSHA_OnBossWin");
				if (FuncBossWon != INVALID_FUNCTION)
				{
					Call_StartFunction(Storage[i], FuncBossWon);
					Call_Finish();
				} //stop music here, put win sound
				playedwinsound = true;
			}
			SetEntProp(i, Prop_Send, "m_bGlowEnabled", 0);
			flGlowTimer[i] = 0.0;
			if ( IsPlayerAlive(i) ) CPrintToChatAll("{olive}[VSH Engine]{default} %N had %i of %i", i, iBossHealth[i], iBossMaxHealth[i]);
			else
			{
				if (GetClientTeam(i) != HaleTeam) ForceTeamChange(i, HaleTeam);
			}
			bIsBoss[i] = false;
		}
		else // reset client shit heer
		{
		}
	}
	ClearTimer(MusicTimer);

	int top[3];
	iDamage[0] = 0;
	for (i = 1; i <= MaxClients; i++)
	{
		if ( iDamage[i] <= 0 ) continue;
		if ( iDamage[i] >= iDamage[top[0]] )
		{
			top[2] = top[1];
			top[1] = top[0];
			top[0] = i;
		}
		else if ( iDamage[i] >= iDamage[top[1]] )
		{
			top[2] = top[1];
			top[1] = i;
		}
		else if ( iDamage[i] >= iDamage[top[2]] )
		{
			top[2] = i;
		}
	}
	if ( iDamage[top[0]] > 9000 ) CreateTimer(1.0, TimerNineThousand, _, TIMER_FLAG_NO_MAPCHANGE);

	char first[32];
	if ( IsValidClient(top[0]) && (GetClientTeam(top[0]) == OtherTeam) ) GetClientName(top[0], first, 32);
	else
	{
		Format(first, sizeof(first), "---");
		top[0] = 0;
	}

	char second[32];
	if ( IsValidClient(top[1]) && (GetClientTeam(top[1]) == OtherTeam) ) GetClientName(top[1], second, 32);
	else
	{
		Format(second, sizeof(second), "---");
		top[1] = 0;
	}

	char third[32];
	if ( IsValidClient(top[2]) && (GetClientTeam(top[2]) == OtherTeam) ) GetClientName(top[2], third, 32);
	else
	{
		Format(third, sizeof(third), "---");
		top[2] = 0;
	}

        SetHudTextParams(-1.0, 0.3, 10.0, 255, 255, 255, 255);
        PrintCenterTextAll(""); //Should clear center text
	for (i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !(GetClientButtons(i) & IN_SCORE))
		{
			ShowHudText(i, -1, "Most Damage Dealt By:\n1)%i - %s\n2)%i - %s\n3)%i - %s\n\nDamage Dealt: %i\nScore for this round: %i", iDamage[top[0]], first, iDamage[top[1]], second, iDamage[top[2]], third, iDamage[i], RoundFloat(iDamage[i]/600.0));
		}
        }
	return Plugin_Continue;
}
public Action UberDeployed(Event event, const char[] name, bool dontBroadcast)
{
	if (!Enabled) return Plugin_Continue;
	int client = GetClientOfUserId(event.GetInt("userid"));
	//int target = GetClientOfUserId(event.GetInt("targetid"));
	if (IsPlayerAlive(client) )
	{
		int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
		if (GetItemQuality(medigun) == 10)
		{
			TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.5, client);
			int target = GetHealingTarget(client);
			if (IsValidClient(target) && IsPlayerAlive(target))
			{
				TF2_AddCondition(target, TFCond_HalloweenCritCandy, 0.5, client);
				iUberedTarget[client] = target;
			}
			else iUberedTarget[client] = -1;
			SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", 1.50);
			CreateTimer(0.4, Timer_Uber, EntIndexToEntRef(medigun), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return Plugin_Continue;
}
public Action Timer_Uber(Handle timer, any medigunid)
{
	int medigun = EntRefToEntIndex(medigunid);
	if (IsValidEntity(medigun) && CheckRoundState() == 1)
	{
		int medic = GetOwner(medigun);
		if (IsValidClient(medic) && IsPlayerAlive(medic) && GetEntPropEnt(medic, Prop_Send, "m_hActiveWeapon") == medigun)
		{
			int target = GetHealingTarget(medic);
			if ( GetMediCharge(medigun) > 0.05 )
			{
			//TF2_AddCondition(medic, TFCond_HalloweenCritCandy, 0.5); // what's the point in giving the ubering medic crits?
				if (IsValidClient(target) && IsPlayerAlive(target))
				{
					TF2_AddCondition(target, TFCond_HalloweenCritCandy, 0.5);
					iUberedTarget[medic] = target;

					int boss = GetRandomBossIndex();
					Function FuncHitUber = GetFunctionByName(Storage[boss], "VSHA_OnUberTimer");
					if (FuncHitUber != INVALID_FUNCTION)
					{
						Call_StartFunction(Storage[boss], FuncHitUber);
						Call_PushCell(medic);
						Call_PushCell(target);
						Call_Finish();
					}
				}
				else iUberedTarget[medic] = -1;
			}
		}
		if ( GetMediCharge(medigun) <= 0.05 )
		{
			CreateTimer(3.0, Timer_ResetUberCharge, EntIndexToEntRef(medigun));
			return Plugin_Stop;
		}
	}
	else return Plugin_Stop;
	return Plugin_Continue;
}
public Action Timer_ResetUberCharge(Handle timer, any medigunid)
{
	int medigun = EntRefToEntIndex(medigunid);
	if ( IsValidEntity(medigun) ) SetMediCharge(medigun, GetMediCharge(medigun)+MedigunReset.FloatValue);//GetConVarFloat(MedigunReset)); //40.0
	return Plugin_Continue;
}
public Action Destroyed(Event event, const char[] name, bool dontBroadcast)
{
	if (Enabled)
	{
		int attacker = GetClientOfUserId(event.GetInt("attacker"));
		if ( bIsBoss[attacker] ) //&& !GetRandomInt(0, 2) )
		{
			int building = event.GetInt("index");

			Function FuncBossKillToy = GetFunctionByName(Storage[attacker], "VSHA_OnBossKillBuilding");
			if (FuncBossKillToy != INVALID_FUNCTION)
			{
				Call_StartFunction(Storage[attacker], FuncBossKillToy);
				Call_PushCell(attacker);
				Call_PushCell(building);
				Call_Finish();
			}
		}
	}
	return Plugin_Continue;
}
public Action Deflected(Event event, const char[] name, bool dontBroadcast)
{
	if (!Enabled || event.GetInt("weaponid")) return Plugin_Continue;
	int client = GetClientOfUserId(event.GetInt("ownerid"));
	if ( bIsBoss[client] )
	{
		int airblaster = GetClientOfUserId(event.GetInt("userid"));

		Function FuncBossAirBlst = GetFunctionByName(Storage[client], "VSHA_OnBossAirblasted");
		if (FuncBossAirBlst != INVALID_FUNCTION)
		{
			Call_StartFunction(Storage[client], FuncBossAirBlst);
			Call_PushCell(client);
			Call_PushCell(airblaster);
			Call_Finish();
		}
	}
	return Plugin_Continue;
}
public Action OnHookedEvent(Event event, const char[] name, bool dontBroadcast)
{
	SetRJFlag(GetClientOfUserId(event.GetInt("userid")), StrEqual(name, "rocket_jump", false));
	return Plugin_Continue;
}
public Action TimerNineThousand(Handle timer)
{
	EmitSoundToAll("saxton_hale/9000.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, false, 0.0);
	return Plugin_Continue;
}
void SetClientOverlay(int client, char[] strOverlay)
{
	int iFlags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
	SetCommandFlags("r_screenoverlay", iFlags);
	ClientCommand(client, "r_screenoverlay \"%s\"", strOverlay);
}
int GetClientQueuePoints(int client)
{
	if (!IsValidClient(client)) return -1;
	if (!AreClientCookiesCached(client)) return -1;
	char strPoints[32];
	GetClientCookie(client, PointCookie, strPoints, sizeof(strPoints));
	return StringToInt(strPoints);
}
void SetClientQueuePoints(int client, int points)
{
	if (!IsValidClient(client)) return;
	if (IsFakeClient(client)) return;
	if (!AreClientCookiesCached(client)) return;
	char strPoints[32];
	IntToString(points, strPoints, sizeof(strPoints));
	SetClientCookie(client, PointCookie, strPoints);
}
public Action TimerInitBoss(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i) || !bIsBoss[i]) continue;
		bNoTaunt[i] = false;
		CreateTimer(0.3, MakeBoss, iBossUserID[i]);
	}
	CreateTimer(9.1, TimerBossStart);
	CreateTimer(3.5, TimerBossResponse);
	CreateTimer(9.5, CheckAlivePlayers);
	CreateTimer(9.6, MessageTimer);
	return Plugin_Continue;
}
public Action MessageTimer(Handle hTimer)
{
	if (CheckRoundState() != 0) return Plugin_Continue;
	int entity = -1;
	while ( (entity = FindEntityByClassname2(entity, "func_door")) != -1 )
	{
		AcceptEntityInput(entity, "Open");
		AcceptEntityInput(entity, "Unlock");
	}
	if ( hdoorchecktimer == null )
	{
		hdoorchecktimer = CreateTimer(5.0, Timer_CheckDoors, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}

	SetHudTextParams(-1.0, 0.4, 10.0, 255, 255, 255, 255);
	char text[PATHX];
	for (int client = 1; bIsBoss[client]; client++)
	{
		if ( !IsValidClient(client) ) continue;
		Format(text, sizeof(text), "%s\n%N became %s with %i HP", text, client, charBossName, iBossMaxHealth[client]);
	}
	for (int client = 1; client <= MaxClients; client++)
	{
		if ( IsValidClient(client) ) ShowHudText(client, -1, text);
	}
	return Plugin_Continue;
}
public Action Timer_CheckDoors(Handle hTimer)
{
	if ( (!Enabled && CheckRoundState() != -1) || (Enabled && CheckRoundState() != 1) )
	{
		ClearTimer(hdoorchecktimer);
		return Plugin_Stop;
	}
	int ent = -1;
	while ( (ent = FindEntityByClassname2(ent, "func_door")) != -1 )
	{
		AcceptEntityInput(ent, "Open");
		AcceptEntityInput(ent, "Unlock");
	}
	return Plugin_Continue;
}
public Action CommandMakeNextSpecial(int client, int args)
{
	char arg[32];
	char name[64];
	if (args < 1)
	{
		ReplyToCommand(client, "[VSH Engine] Usage: vsha_special <boss name>");
		return Plugin_Handled;
	}
	GetCmdArgString(arg, sizeof(arg));

	if (GetArraySize(hArrayBossSubplugins) < 1) return Plugin_Handled;
	int count = GetArraySize(hArrayBossSubplugins);
	for (int i = 0; i < count; i++)
	{
		GetTrieString(GetArrayCell(hArrayBossSubplugins, i), "BossName", name, sizeof(name));
		if (StrContains(arg, name, false) != -1)
		{
			iPresetBoss[FindNextBoss(bIsBoss)] = i;
			break;
		}
	}
	ReplyToCommand(client, "[VSH Engine] Set the next Special to %s", name);
	return Plugin_Handled;
}
public Action PickBossMenu(int client, int args)
{
	if (Enabled && IsClientInGame(client))
	{
		if (GetArraySize(hArrayBossSubplugins) < 1) return Plugin_Handled;
		char bossnameholder[32];
		Menu classpick = new Menu(MenuHandler_PickBoss);
		//Handle MainMenu = CreateMenu(MenuHandler_Perks);
		classpick.SetTitle("[VSH Engine] Choose A Boss");
		int count = GetArraySize(hArrayBossSubplugins);
		for (int i = 0; i < count; i++)
		{
			GetTrieString(GetArrayCell(hArrayBossSubplugins, i), "BossName", bossnameholder, sizeof(bossnameholder));
			classpick.AddItem("pickclass", bossnameholder);
		}
		classpick.Display(client, MENU_TIME_FOREVER);
	}
	return view_as<Action>(0);
}
public int MenuHandler_PickBoss(Menu menu, MenuAction action, int param1, int param2)
{
	char blahblah[32];
	menu.GetItem(param2, blahblah, sizeof(blahblah));
	if (action == MenuAction_Select)
        {
		char bossnameholder[32];
		GetTrieString(GetArrayCell(hArrayBossSubplugins, param2), "BossName", bossnameholder, sizeof(bossnameholder));
		ReplyToCommand(param1, "[VSH Engine] You selected %s as your boss!", bossnameholder);
		iPresetBoss[param1] = param2;
        }
	else if (action == MenuAction_End) delete menu;
}
stock void PickBossSpecial(int client)
{
	if (GetArraySize(hArrayBossSubplugins) < 1)
	{
		LogError("**** PickBossSpecial: There are no Boss subplugins registered! ****");
		return;
	}
	if (iPresetBoss[client] != -1) iBoss[client] = GetRandomInt( 0, GetArraySize(hArrayBossSubplugins) );
	else
	{
		iBoss[client] = iPresetBoss[client];
		iPresetBoss[client] = -1;
	}
	Storage[client] = GetBossSubPlugin(GetArrayCell(hArrayBossSubplugins, iBoss[client]));

	Function FuncBossSelect = GetFunctionByName(Storage[client], "VSHA_OnBossSelected");
	if (FuncBossSelect != INVALID_FUNCTION)
	{
		Call_StartFunction(Storage[client], FuncBossSelect);
		Call_PushCell(client);
		Call_Finish();
	}
}

/*public void OnItemSpawned(int entity)
{
	SDKHook(entity, SDKHook_StartTouch, OnItemTouch);
	SDKHook(entity, SDKHook_Touch, OnItemTouch);
}

public Action OnItemTouch(int item, int entity)
{
	if (IsValidClient(entity) && GetClientTeam(entity) == HaleTeam) return Plugin_Handled;
	return Plugin_Continue;
}*/
public Action TimerBossResponse(Handle timer)
{
	int client = GetRandomBossIndex();
	Function FuncBossTalk = GetFunctionByName(Storage[client], "VSHA_OnBossIntroTalk");
	if (FuncBossTalk != INVALID_FUNCTION)
	{
		Call_StartFunction(Storage[client], FuncBossTalk);
		Call_Finish();
	}
	return Plugin_Continue;
}
public Action TimerBossStart(Handle hTimer)
{
	iPlaying = 0;
	for (int client = 1; client <= MaxClients; client++) //loop clients first for health calculation
	{
		if (!IsValidClient(client) || !IsPlayerAlive(client) || bIsBoss[client]) continue;
		iPlaying++;
		SetEntityMoveType(client, MOVETYPE_WALK); // >_>
		CreateTimer(0.1, TimerEquipPlayers, GetClientUserId(client)); //SUIT UP!
	}
	for (int boss = 1; boss <= MaxClients; boss++)
	{
		if ( !IsValidClient(boss) || !bIsBoss[boss] ) continue;
		if ( !IsPlayerAlive(boss) ) TF2_RespawnPlayer(boss);
		SetEntityMoveType(boss, MOVETYPE_WALK);

		Function FuncSetBossHP = GetFunctionByName(Storage[boss], "VSHA_OnBossSetHP");
		if (FuncSetBossHP != INVALID_FUNCTION)
		{
			Call_StartFunction(Storage[boss], FuncSetBossHP);
			Call_PushCell(boss);
			Call_Finish();
		}
		GetTrieString(GetArrayCell(hArrayBossSubplugins, iBoss[boss]), "BossName", charBossName, sizeof(charBossName));

		if (iBossMaxHealth[boss] <= 0) iBossMaxHealth[boss] = HealthCalc(760.8, float(iPlaying), 1.0, 1.0341, 2046.0);
		if (iBossMaxHealth[boss] < 2500) iBossMaxHealth[boss] = 2500; //fallback incase accident

		int maxhp = GetEntProp(boss, Prop_Data, "m_iMaxHealth");
		TF2Attrib_RemoveAll(boss);
		TF2Attrib_SetByDefIndex( boss, 26, float(iBossMaxHealth[boss]-maxhp) );
		SetEntityHealth( boss, (iBossHealth[boss] = iBossMaxHealth[boss]) );
	}
	CreateTimer(0.2, ClientTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.2, BossTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	if ( !PointType && iPlaying > AliveToEnable.IntValue ) SetControlPoint(false); //GetConVarInt(AliveToEnable)
	if ( CheckRoundState() == 0 ) CreateTimer(2.0, TimerMusicPlay, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}
public Action CheckAlivePlayers(Handle timer)
{
	if ( CheckRoundState() == 2 ) return Plugin_Continue;
	iRedAlivePlayers = 0, iBluAlivePlayers = 0;
	for (int client = 1; client <= MaxClients; client++)
	{
		if ( IsClientInGame(client) && IsPlayerAlive(client) )
		{
			if (GetClientTeam(client) == OtherTeam) iRedAlivePlayers++;
			else if (GetClientTeam(client) == HaleTeam) iBluAlivePlayers++;
		}
	}

	if (iRedAlivePlayers <= 0) ForceTeamWin(HaleTeam);
	else if (iRedAlivePlayers == 1 && iBluAlivePlayers)
	{
		char message[PATH];
		for (int boss = 1; bIsBoss[boss]; boss++)
		{
			if (IsValidClient(boss)) Format(message, sizeof(message), "%s\n%N's Health is %i of %i", message, boss, iBossHealth[boss], iBossMaxHealth[boss]);
		}
		for (int target = 1; target <= MaxClients; target++)
		{
			if (IsValidClient(target)) PrintCenterText(target, message);
		}
		/*decl String:sound[PLATFORM_MAX_PATH];
		if(RandomSound("sound_lastman", sound, PLATFORM_MAX_PATH))
		{
			EmitSoundToAll(sound);
			EmitSoundToAll(sound);
		}*/
	}
	else if ( !PointType && (iRedAlivePlayers <= AliveToEnable.IntValue) && !PointReady ) //GetConVarInt(AliveToEnable)
	{
		if (iRedAlivePlayers == AliveToEnable.IntValue) //GetConVarInt(AliveToEnable))
		{
			char sound[PATH];
			if (GetRandomInt(0, 1))
			{
				Format(sound, sizeof(sound), "vo/announcer_am_capenabled0%i.wav", GetRandomInt(1, 4));
				EmitSoundToAll(sound);
			}
			else
			{
				int i = GetRandomInt(1, 4);
				if ( !(i % 2) ) i--;
				Format(sound, sizeof(sound), "vo/announcer_am_capincite0%i.wav", i);
				EmitSoundToAll(sound);
			}
		}
		SetControlPoint(true);
		PointReady = true; //:>
	}
	if (iRedAlivePlayers <= CountDownPlayerLimit.IntValue && iTotalBossHP > CountDownHealthLimit.IntValue && LastPlayersTimerCountDown.IntValue > 1 && !DrawGameTimer) //GetConVarInt(CountDownPlayerLimit) GetConVarInt(CountDownHealthLimit) GetConVarInt(LastPlayersTimerCountDown)
	{
		if (FindEntityByClassname2(-1, "team_control_point") != -1)
		{
			timeleft = LastPlayersTimerCountDown.IntValue; //GetConVarInt(LastPlayersTimerCountDown);
			DrawGameTimer = CreateTimer(1.0, Timer_DrawGame, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return Plugin_Continue;
}
public Action Timer_DrawGame(Handle timer)
{
	if (iTotalBossHP < CountDownHealthLimit.IntValue || CheckRoundState() != 1) return Plugin_Stop;
	//GetConVarInt(CountDownHealthLimit)
	int time = timeleft;
	timeleft--;
	char timeDisplay[6];
	if (time/60 > 9) IntToString(time/60, timeDisplay, sizeof(timeDisplay));
	else Format(timeDisplay, sizeof(timeDisplay), "0%i", time/60);

	if (time%60 > 9) Format(timeDisplay, sizeof(timeDisplay), "%s:%i", timeDisplay, time%60);
	else Format(timeDisplay, sizeof(timeDisplay), "%s:0%i", timeDisplay, time%60);

	SetHudTextParams(-1.0, 0.17, 1.1, 255, 255, 255, 200);
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client) && !(GetClientButtons(client) & IN_SCORE)) ShowSyncHudText(client, TimeLeftHUD, timeDisplay);
	}
	switch (time)
	{
		case 300: EmitSoundToAll("vo/announcer_ends_5min.wav");
		case 120: EmitSoundToAll("vo/announcer_ends_2min.wav");
		case 60: EmitSoundToAll("vo/announcer_ends_60sec.wav");
		case 30: EmitSoundToAll("vo/announcer_ends_30sec.wav");
		case 10: EmitSoundToAll("vo/announcer_ends_10sec.wav");
		case 1, 2, 3, 4, 5:
		{
			char sound[PATHX];
			Format(sound, PATHX, "vo/announcer_ends_%isec.wav", time);
			EmitSoundToAll(sound);
		}
		case 0:  //Thx MasterOfTheXP
		{
			for (int client = 1; client <= MaxClients; client++)
			{
				if ( IsClientInGame(client) && IsPlayerAlive(client) ) ForcePlayerSuicide(client);
			}
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}
public Action BossTimer(Handle timer)
{
	if ( !Enabled || CheckRoundState() == 2 ) return Plugin_Stop;
	flHPTime -= 0.2;
	if ( flHPTime < 0.0 ) flHPTime = 0.0;
	for ( int client = 1; client <= MaxClients; client++ )
	{
		if ( !IsValidClient(client) || !IsPlayerAlive(client) || !bIsBoss[client] ) continue;

		SetEntityHealth(client, iBossHealth[client]);

		Function FuncBossTimer = GetFunctionByName(Storage[client], "VSHA_OnBossTimer");
		if (FuncBossTimer != INVALID_FUNCTION)
		{
			Call_StartFunction(Storage[client], FuncBossTimer);
			Call_PushCell(client);
			Call_Finish();
		}
		SetClientGlow(client, -0.2);

		/*if ( flCharge[client] < 100.0 add convar here)
		{
			flCharge[client] += OnlyScoutsLeft()*0.2;
			if (flCharge[client] > 100.0) flCharge[client] = 100.0;
		}*/
	}
	UpdateHealthBar();
	return Plugin_Continue;
}
public Action TF2Items_OnGiveNamedItem(int client, char[] classname, int iItemDefinitionIndex, Handle &hItem)
{
	if (!Enabled) return Plugin_Continue;
	switch (iItemDefinitionIndex)
	{
		case 40: //backburner
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "165 ; 1.0");
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 349: //sun on a stick
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "208 ; 1");
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 648: //wrap assassin
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "279 ; 2.0");
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 224: //Letranger
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "166 ; 15 ; 1 ; 0.8", true);
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 225, 574: //YER
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "155 ; 1 ; 160 ; 1", true);
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 232, 401: // Bushwacka + Shahanshah
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "236 ; 1");
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 226: // The Battalion's Backup
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "252 ; 0.25 ; 125 -20"); //125 ; -10
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 305, 1079: // Medic Xbow
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "17 ; 0.12 ; 2 ; 1.45 ; 6 ; 1.5"); // ; 266 ; 1.0");
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 56, 1005, 1092: // Huntsman
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "2 ; 1.5 ; 76 ; 2.0");
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 38, 457: // Axetinguisher
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "", true);
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 43, 239, 1084, 1100: //gru
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "107 ; 1.65 ; 1 ; 0.5 ; 128 ; 1 ; 191 ; -7", true);
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 415: //reserve shooter
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "179 ; 1 ; 265 ; 999.0 ; 178 ; 0.6 ; 2 ; 1.1 ; 3 ; 0.66", true);
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
	}
	if (TF2_GetPlayerClass(client) == TFClass_Soldier)
	{
		Handle hItemOverride = null;
		if ( !strncmp(classname, "tf_weapon_rocketlauncher", 24, false) )
		{
			switch (iItemDefinitionIndex)
			{
				case 127: hItemOverride = PrepareItemHandle(hItem, _, _, "265 ; 999.0 ; 179 ; 1.0");
				default: hItemOverride = PrepareItemHandle(hItem, _, _, "265 ; 999.0");
			}
		}
		if (hItemOverride != null)
		{
			hItem = hItemOverride;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}
public Action TimerEquipPlayers(Handle hTimer, any clientid)
{
	int client = GetClientOfUserId(clientid);
	if ( client <= 0 || !IsPlayerAlive(client) || CheckRoundState() == 2) return Plugin_Continue;
	TF2Attrib_RemoveAll(client);
	if (GetClientTeam(client) != OtherTeam)
	{
		ForceTeamChange(client, OtherTeam);
		TF2_RegeneratePlayer(client); // Added fix by Chdata to correct team colors
	}
	int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	int index = -1;
	if (IsValidEdict(weapon) && IsValidEntity(weapon))
	{
		index = GetItemIndex(weapon);
		switch (index)
		{
			case 588:
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Primary);
				weapon = SpawnWeapon(client, "tf_weapon_shotgun_primary", 415, 10, 6, "265 ; 999.0 ; 179 ; 1.0 ; 178 ; 0.6 ; 2 ; 1.1 ; 3 ; 0.66");
			}
			case 237:
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Primary);
				weapon = SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 1, 0, "265 ; 999.0");
				SetWeaponAmmo(weapon, 20);
			}
			case 17, 204, 36, 412:
			{
				if (GetItemQuality(weapon) != 10)
				{
					TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Primary);
					SpawnWeapon(client, "tf_weapon_syringegun_medic", 36, 1, 10, "17 ; 0.05 ; 144 ; 1");
				}
			}
		}
	}
	weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if (IsValidEdict(weapon) && IsValidEntity(weapon))
	{
		index = GetItemIndex(weapon);
		switch (index)
		{
			case 57, 231:
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Secondary);
				weapon = SpawnWeapon(client, "tf_weapon_smg", 16, 1, 0, "");
			}
			case 265:
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Secondary);
				weapon = SpawnWeapon(client, "tf_weapon_pipebomblauncher", 20, 1, 0, "");
				SetWeaponAmmo(weapon, 24);
			}
			case 735, 736, 810, 831, 933, 1080, 1102: //NAILGUN FOR SAPPER, trust me it's more useful........
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Secondary);
				weapon = SpawnWeapon(client, "tf_weapon_handgun_scout_secondary", 23, 5, 10, "280 ; 5 ; 6 ; 0.7 ; 2 ; 0.66 ; 4 ; 4.167 ; 78 ; 8.333 ; 137 ; 6.0");
				SetWeaponAmmo(weapon, (GetMaxAmmo(client, 0)*200/GetMaxAmmo(client, 0)));
			}
			case 39, 351, 1081:
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Secondary);
				weapon = SpawnWeapon(client, "tf_weapon_flaregun", index, 5, 10, "25 ; 0.5 ; 207 ; 1.33 ; 144 ; 1.0 ; 58 ; 3.2");
				SetWeaponAmmo(weapon, 16);
			}
		}
	}
	if (IsValidEntity(FindPlayerBack(client, { 57 , 231 }, 2)))
	{
		RemovePlayerBack(client, { 57 , 231 }, 2);
		weapon = SpawnWeapon(client, "tf_weapon_smg", 16, 1, 0, "");
	}
	weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if (IsValidEdict(weapon) && IsValidEntity(weapon))
	{
		index = GetItemIndex(weapon);
		switch (index)
		{
			case 331:
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Melee);
				weapon = SpawnWeapon(client, "tf_weapon_fists", 195, 1, 6, "");
			}
			case 357: CreateTimer(1.0, Timer_RemoveHonorBound, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			case 589:
			{
				if ( !EnableEurekaEffect.BoolValue ) //!GetConVarBool(EnableEurekaEffect))
				{
					TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Melee);
					weapon = SpawnWeapon(client, "tf_weapon_wrench", 7, 1, 0, "");
				}
			}
		}
	}
	weapon = GetPlayerWeaponSlot(client, 4);
	if (IsValidEdict(weapon) && IsValidEntity(weapon) && GetItemIndex(weapon) == 60)
	{
		TF2_RemoveWeaponSlot2(client, 4);
		weapon = SpawnWeapon(client, "tf_weapon_invis", 30, 1, 0, "");
	}
	TFClassType equip = TF2_GetPlayerClass(client);
	switch (equip)
	{
		case TFClass_Medic:
		{
			weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
			int mediquality = (IsValidEdict(weapon) && IsValidEntity(weapon) ? GetItemQuality(weapon) : -1);
			if (mediquality != 10)
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Secondary);
				weapon = SpawnWeapon(client, "tf_weapon_medigun", 998, 5, 10, "18 ; 0.0 ; 10 ; 1.25 ; 178 ; 0.75 ; 144 ; 2.0");  
//200 ; 1 for area of effect healing  ; 178 ; 0.75 Faster switch-to ; 14 ; 0.0 perm overheal
				SetMediCharge(weapon, 0.41);
			}
		}
		default: TF2Attrib_SetByDefIndex( client, 57, float(GetClientHealth(client)/50) ); //make by cvar
	}
	return Plugin_Continue;
}
public Action Timer_RemoveHonorBound(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client) && IsPlayerAlive(client))
	{
		int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		int index = GetItemIndex(weapon);
		int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		char classname[64];
		if (IsValidEdict(active)) GetEdictClassname(active, classname, sizeof(classname));
		if (index == 357 && active == weapon && strcmp(classname, "tf_weapon_katana", false) == 0)
		{
			SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
			if (GetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy") < 1) SetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
		}
	}
	return Plugin_Continue;
}
public Action ClientTimer(Handle hTimer)
{
	if (CheckRoundState() > 1 ||CheckRoundState() == -1) return Plugin_Stop;
	for (int i = 1; i <= MaxClients; i++)
        {
		if (!IsValidClient(i) || GetClientTeam(i) == HaleTeam) continue;
		char wepclassname[32];
		//int killstreaker = iDamage[i] / 500;
		//if (killstreaker >= 1) SetEntProp(i, Prop_Send, "m_iKillStreak", killstreaker);

		TFClassType class = TF2_GetPlayerClass(i);
		int weapon = GetEntPropEnt(i, Prop_Send, "m_hActiveWeapon");
		int index = GetItemIndex(weapon);
		if (TF2_IsPlayerInCondition(i, TFCond_Cloaked))
		{
			if (GetClientCloakIndex(i) == 59)
			{
				if (TF2_IsPlayerInCondition(i, TFCond_DeadRingered)) TF2_RemoveCondition(i, TFCond_DeadRingered);
			}
			else TF2_AddCondition(i, TFCond_DeadRingered, 0.3);
		}
		switch (iRedAlivePlayers)
		{
			case 1:
			{
				if ( iRedAlivePlayers == 1 && !TF2_IsPlayerInCondition(i, TFCond_Cloaked) )
				{
					TF2_AddCondition(i, TFCond_HalloweenCritCandy, 0.3);
					int primary = GetPlayerWeaponSlot(i, TFWeaponSlot_Primary);
					if (class == TFClass_Engineer && weapon == primary && StrEqual(wepclassname, "tf_weapon_sentry_revenge", false))
						SetEntProp(i, Prop_Send, "m_iRevengeCrits", 3);

					TF2_AddCondition(i, TFCond_Buffed, 0.3);

					int boss = GetRandomBossIndex();
					Function FuncLastSurvivor = GetFunctionByName(Storage[boss], "VSHA_OnLastSurvivor");
					if (FuncLastSurvivor != INVALID_FUNCTION)
					{
						Call_StartFunction(Storage[boss], FuncLastSurvivor);
						Call_PushCell(i);
						Call_Finish();
					}
					//if (bAllowSuperWeap && HaleHealth >= 7000) PickSuperWeapon(i, -1); later
					continue;
				}
			}
			case 2: if (!TF2_IsPlayerInCondition(i, TFCond_Cloaked)) TF2_AddCondition(i, TFCond_Buffed, 0.3);
		}
//==============================	C R I T S  P A R T S	=======================================
		TFCond cond = TFCond_HalloweenCritCandy;
		if (TF2_IsPlayerInCondition(i, TFCond_CritCola) && (class == TFClass_Scout || class == TFClass_Heavy))
		{
			TF2_AddCondition(i, cond, 0.1);
			return Plugin_Continue;
		}
		bool EnableCrits[2] = {false, false}; //0 - minicrits, 1 - full crits
		if (weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Melee))
		{
			//slightly longer check but makes sure that any weapon that can backstab will not crit (e.g. Saxxy)
			if (strcmp(wepclassname, "tf_weapon_knife", false) != 0 && index != 416) EnableCrits[1] = true;
		}
		switch (index)
		{
			case 305, 1079, 1081, 56, 16, 203, 58, 1083, 1105, 1100, 1005, 1092, 812, 833, 997, 39, 351, 740, 588, 595: //Critlist
			{
				int flindex = GetIndexOfWeaponSlot(i, TFWeaponSlot_Primary);
				// No crits if using phlog
				if (TF2_GetPlayerClass(i) == TFClass_Pyro && flindex == 594) EnableCrits[1] = false;
				else EnableCrits[1] = true;
			}
			case 22, 23, 160, 209, 294, 449, 773:
			{
				EnableCrits[1] = true;
				if (class == TFClass_Scout && cond == TFCond_HalloweenCritCandy) cond = TFCond_Buffed;
			}
			case 656:
			{
				EnableCrits[1] = true;
				cond = TFCond_Buffed;
			}
		}
		if (index == 16 && EnableCrits[1] && IsValidEntity(FindPlayerBack(i, { 642 }, 1))) EnableCrits[1] = false;
		if (EnableCrits[1])
		{
			TF2_AddCondition(i, cond, 0.3);
			if (EnableCrits[0] && cond != TFCond_Buffed) TF2_AddCondition(i, TFCond_Buffed, 0.3);
		}
		switch (class)
		{
			case TFClass_Spy:
			{
				if (weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Primary))
				{
					if (!TF2_IsPlayerCritBuffed(i) && !TF2_IsPlayerInCondition(i, TFCond_Buffed) && !TF2_IsPlayerInCondition(i, TFCond_Cloaked) && !TF2_IsPlayerInCondition(i, TFCond_Disguised) && !GetEntProp(i, Prop_Send, "m_bFeignDeathReady"))
					{
						TF2_AddCondition(i, TFCond_CritCola, 0.3);
					}
				}
			}
			case TFClass_Engineer:
			{
				if (weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Primary) && StrEqual(wepclassname, "tf_weapon_sentry_revenge", false))
				{
					int sentry = FindSentry(i);
					if (IsValidEntity(sentry))
					{
						int TargettedBoss = GetEntPropEnt(sentry, Prop_Send, "m_hEnemy");
						if (bIsBoss[TargettedBoss])
						{
							SetEntProp(i, Prop_Send, "m_iRevengeCrits", 3);
							TF2_AddCondition(i, TFCond_Kritzkrieged, 0.3);
						}
					}
					else
					{
						if (GetEntProp(i, Prop_Send, "m_iRevengeCrits")) SetEntProp(i, Prop_Send, "m_iRevengeCrits", 0);
						else if (TF2_IsPlayerInCondition(i, TFCond_Kritzkrieged) && !TF2_IsPlayerInCondition(i, TFCond_Healing))
						{
							TF2_RemoveCondition(i, TFCond_Kritzkrieged);
						}
					}
				}
			}
			case TFClass_Medic:
			{
				if (weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary))
				{
					int healtarget = GetHealingTarget(i);
					if (IsValidClient(healtarget) && TF2_GetPlayerClass(healtarget) == TFClass_Scout)
					{
						TF2_AddCondition(i, TFCond_SpeedBuffAlly, 0.3);
					}
				}
			}
			case TFClass_DemoMan:
			{
				if (!IsValidEntity(GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary)))
				{
					EnableCrits[1] = true;
					if (/*!bDemoShieldCrits &&*/ GetEntPropEnt(i, Prop_Send, "m_hActiveWeapon") != GetPlayerWeaponSlot(i, TFWeaponSlot_Melee)) cond = TFCond_Buffed;
				}
			}
		}
	}
	return Plugin_Continue;
}
public Action MakeBoss(Handle hTimer, any userid)
{
	int client = GetClientOfUserId(userid);
	if ( client <= 0 || !IsClientInGame(client) || !bIsBoss[client] || !bIsMinion[client]) return Plugin_Continue;

	if (GetClientTeam(client) != HaleTeam) ForceTeamChange(client, HaleTeam);
	if (!IsPlayerAlive(client))
	{
		if ( CheckRoundState() == 0 ) TF2_RespawnPlayer(client);
		else return Plugin_Continue;
	}
	int ent = -1, index = -1;
	while ((ent = FindEntityByClassname2(ent, "tf_wearable")) != -1)
	{
		if (GetOwner(ent) == client)
		{
			index = GetItemIndex(ent);
			switch (index)
			{
				case 167, 438, 463, 477, 1015, 1106, 1107, 1108, 1109, 1110, 1111, 1112, 1113, 1114, 1115, 1116, 1117, 1118, 1119, 1120: {}
				default: TF2_RemoveWearable(client, ent); //AcceptEntityInput(ent, "kill");
			}
		}
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "tf_powerup_bottle")) != -1)
	{
		if (GetOwner(ent) == client) TF2_RemoveWearable(client, ent); //AcceptEntityInput(ent,
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "tf_wearable_demoshield")) != -1)
	{
		if (GetOwner(ent) == client) TF2_RemoveWearable(client, ent);
	}
	TF2_RemoveAllWeapons2(client);
	TF2_RemovePlayerDisguise(client);

	Function FuncPrepBossTimer = GetFunctionByName(Storage[client], "VSHA_OnPrepBoss");
	if (FuncPrepBossTimer != INVALID_FUNCTION)
	{
		Call_StartFunction(Storage[client], FuncPrepBossTimer);
		Call_PushCell(client);
		Call_Finish();
	}

	CreateTimer(0.0, TimerCleanScreen, iBossUserID[client]);
	CreateTimer(0.2, MakeModelTimer, iBossUserID[client]);
	CreateTimer(20.0, MakeModelTimer, iBossUserID[client], TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}
public Action TimerMusicPlay(Handle timer)
{
	if (CheckRoundState() != 1) return Plugin_Stop;
	char sound[PATHX];
	float time = -1.0;
	ClearTimer(MusicTimer);

	int client = GetRandomBossIndex();
	sound[0] = '\0';
	Function FuncMusicTimer = GetFunctionByName(Storage[client], "VSHA_OnMusic");
	if (FuncMusicTimer != INVALID_FUNCTION)
	{
		Call_StartFunction(Storage[client], FuncMusicTimer);
		Call_PushStringEx(sound, sizeof(sound), 0, SM_PARAM_COPYBACK);
		Call_PushFloatRef(time);
		Call_Finish();
	}
	if (sound[0] != '\0')
	{
	//      Format(sound, sizeof(sound), "#%s", sound);
		EmitSoundToAll(sound, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	}
	if (time != -1.0)
	{
		Handle pack;
		MusicTimer = CreateDataTimer(time, Timer_MusicTheme, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		WritePackString(pack, sound);
	}
	return Plugin_Continue;
}
public Action Timer_MusicTheme(Handle timer, any pack)
{
	if (Enabled && CheckRoundState() == 1)
	{
		char sound[PATHX];
		ResetPack(pack);
		ReadPackString(pack, sound, sizeof(sound));
		if (sound[0] != '\0') EmitSoundToAll(sound, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	}
	else
	{
		ClearTimer(MusicTimer);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public Action TimerCleanScreen(Handle hTimer, any userid)
{
	int client = GetClientOfUserId(userid);
	if ( client <= 0 || !bIsBoss[client] ) return Plugin_Continue;
	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT));
	ClientCommand(client, "r_screenoverlay \"\"");
	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & FCVAR_CHEAT);
	return Plugin_Continue;
}
public Action MakeModelTimer(Handle hTimer, any userid)
{
	int client = GetClientOfUserId(userid);
	if ( client <= 0 || !bIsBoss[client] || (!IsPlayerAlive(client) && bIsBoss[client]) || CheckRoundState() == 2 )
	{
		return Plugin_Stop;
	}
	Action result;
	Function FuncModelTimer = GetFunctionByName(Storage[client], "VSHA_OnModelTimer");
	if (FuncModelTimer != INVALID_FUNCTION)
	{
		Call_StartFunction(Storage[client], FuncModelTimer);
		Call_PushCell(client);
		char model[PATH];
		Call_PushStringEx(model, sizeof(model), 0, SM_PARAM_COPYBACK);
		Call_Finish(result);

		SetVariantString(model);
		AcceptEntityInput(client, "SetCustomModel");
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
		return result;
	}
	else LogError("**** VSH Engine Error: Cannot find 'VSHA_OnModelTimer' Function ****");
	return Plugin_Continue;
}
public Action Timer_SkipHalePanel(Handle hTimer)
{
	int i, j, client;
	do
	{
		client = FindNextBoss(bIsBoss);
		if (IsValidClient(client) && !bIsBoss[client])
		{
			if (!IsFakeClient(client))
			{
				CPrintToChat(client, "{olive}[VSH Engine]{default} You are going to be Hale soon! Type {olive}/halenext{default} to check/reset your queue points.");
				if (i == 0) SkipHalePanelNotify(client);
			}
			i++;
		}
		j++;
	}
	while (i < 3 && j < PLYR);
	return Plugin_Continue;
}
public void SkipHalePanelNotify(int client)
{
	if (!Enabled || !IsValidClient(client) || IsVoteInProgress()) return;
	Handle panel = CreatePanel();
	char s[PATH];
	SetPanelTitle(panel, "[VSH Engine] You're the next Boss!");
	Format(s, sizeof(s), "You are going to be Hale soon! Type {olive}/halenext{default} to check/reset your queue points.\nAlternatively, use !resetq.");
	CRemoveTags(s, sizeof(s));
	ReplaceString(s, sizeof(s), "{olive}", "");
	ReplaceString(s, sizeof(s), "{default}", "");
	DrawPanelItem(panel, s);
	SendPanelToClient(panel, client, SkipHalePanelH, 30);
	CloseHandle(panel);
	return;
}
//(Handle:panel, client, MenuHandler:handler, time)
public int SkipHalePanelH(Menu menu, MenuAction action, int client, int selection)
{
	//for later
	//if ( IsValidAdmin(client, "b") ) Command_SetBoss( client, -1 );
	//else Command_SetSkill(client, -1);
	return;
}
public void UpdateHealthBar()
{
	int dohealth = 0, domaxhealth = 0, bosscount = 0;
	iTotalBossHP = 0;
	for (int client = 1; client <= MaxClients; client++)
	{
		if ( IsValidClient(client) && IsPlayerAlive(client) && bIsBoss[client] )
		{
			dohealth += iBossHealth[client]-iBossMaxHealth[client];
			domaxhealth += iBossMaxHealth[client];
			bosscount++;
			iTotalBossHP += iBossHealth[client];
		}
	}
	if ( bosscount > 0 )
	{
		int percenthp = RoundToCeil( float(dohealth) / float(domaxhealth) * 255.0 );
		if (percenthp > 255) percenthp = 255;
		else if (percenthp <= 0) percenthp = 1;
		SetEntProp(iHealthBar, Prop_Send, "m_iBossHealthPercentageByte", percenthp);
	}
}
public void CheckArena()
{
	if (PointType) SetArenaCapEnableTime(view_as<float>(45+PointDelay.IntValue*(iPlaying-1)));
	else //GetConVarInt(PointDelay)
	{
		SetArenaCapEnableTime(0.0);
		SetControlPoint(false);
	}
}
stock int GetRandomBossIndex() //purpose is for the Storage client Handle
{
	for ( int i = 1; i <= MaxClients; i++ )
	{
		if ( IsValidClient(i) && bIsBoss[i] ) return i;
	}
	return -1;
}
stock void SearchForItemPacks()
{
	//bool foundAmmo = false, foundHealth = false;
	int ent = -1;
	float pos[3];
	while ((ent = FindEntityByClassname2(ent, "item_ammopack_full")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
		if (Enabled)
		{
			GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
			AcceptEntityInput(ent, "Kill");
			int ent2 = CreateEntityByName("item_ammopack_small");
			TeleportEntity(ent2, pos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(ent2);
			SetEntProp(ent2, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
			//foundAmmo = true;
		}
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "item_ammopack_medium")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
		if (Enabled)
		{
			GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
			AcceptEntityInput(ent, "Kill");
			int ent2 = CreateEntityByName("item_ammopack_small");
			TeleportEntity(ent2, pos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(ent2);
			SetEntProp(ent2, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
		}
		//foundAmmo = true;
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "Item_ammopack_small")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
		//foundAmmo = true;
	}

	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "item_healthkit_small")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
		//foundHealth = true;
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "item_healthkit_medium")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
		//foundHealth = true;
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "item_healthkit_large")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
		//foundHealth = true;
	}
}
public void OnPreThink(int client) //better than a retarded 0.2s timer looping through all non-boss players...
{
	if (Enabled)
	{
		if ( !(GetClientButtons(client) & IN_SCORE) )
		{
			if (bIsBoss[client] || bIsMinion[client])
			{
				Function FuncBossPreThink = GetFunctionByName(Storage[client], "VSHA_BossPreThink");
				if (FuncBossPreThink != INVALID_FUNCTION)
				{
					Call_StartFunction(Storage[client], FuncBossPreThink);
					Call_PushCell(client);
					Call_Finish();
				}
				else BossHUD(client); //revert to default hud if PreThink not used.
			}
			else PlayerHUD(client); //fuck players :>
		}
		if (IsNearSpencer(client) && TF2_IsPlayerInCondition(client, TFCond_Cloaked))
		{
			float cloak = GetEntPropFloat(client, Prop_Send, "m_flCloakMeter")-0.5; //PUT CVAR HEER
			if (cloak < 0.0) cloak = 0.0;
			SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", cloak);
		}
	}
}
public void BossHUD(int client)
{
	SetHudTextParams(-1.0, 0.88, 1.0, 90, 255, 90, 200);
	if (IsPlayerAlive(client))
	{
		ClampCharge(client); //automatically clamp the rage charge so it never goes over in subplugins :>
		if (flCharge[client] == 100.0) ShowSyncHudText(client, hBossHUD, "[Health]: {%i/%i} | [Charge]: FULL", iBossHealth[client], iBossMaxHealth[client]);
		else ShowSyncHudText(client, hBossHUD, "[Health]: {%i/%i} | [Charge]: %i%", iBossHealth[client], iBossMaxHealth[client], RoundFloat(flCharge[client]));
	}
	else
	{
		int spec = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
		if (IsValidClient(spec) && bIsBoss[spec]) ShowSyncHudText(client, hBossHUD, "[Health]: {%i/%i} | [Charge]: %i", iBossHealth[spec], iBossMaxHealth[spec], RoundFloat(flCharge[spec]));
	}
}
public void PlayerHUD(int client)
{
	TFClassType class = TF2_GetPlayerClass(client);
	if (!IsClientObserver(client))
	{
		switch (class)
		{
			case TFClass_Spy:
			{
				if (GetClientCloakIndex(client) == 59)
				{
					int drstatus = TF2_IsPlayerInCondition(client, TFCond_Cloaked) ? 2 : GetEntProp(client, Prop_Send, "m_bFeignDeathReady") ? 1 : 0;
					char s[32];
					switch (drstatus)
					{
						case 1:
						{
							SetHudTextParams(-1.0, 0.83, 0.35, 90, 255, 90, 255, 0, 0.0, 0.0, 0.0);
							Format(s, sizeof(s), "Status: Feign-Death Ready");
						}
						case 2:
						{
							SetHudTextParams(-1.0, 0.83, 0.35, 255, 64, 64, 255, 0, 0.0, 0.0, 0.0);
							Format(s, sizeof(s), "Status: Dead-Ringered");
						}
						default:
						{
							SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.0, 0.0, 0.0);
							Format(s, sizeof(s), "Status: Inactive");
						}
					}
					ShowSyncHudText(client, MiscHUD, "%s", s);
				}
	    		}
			case TFClass_Medic:
			{
				int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
				if (GetItemQuality(medigun) == 10)
				{
					SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);
					int charge = RoundToFloor(GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel")*100);
					ShowSyncHudText(client, MiscHUD, "ÜberCharge: %i%", charge);
				}
			}
			case TFClass_Soldier:
			{
				if (GetIndexOfWeaponSlot(client, TFWeaponSlot_Primary) == 1104)
				{
					SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);
					ShowSyncHudText(client, MiscHUD, "Air-Strike Damage: %i", iAirDamage[client]);
				}
			}
		}
		SetHudTextParams(-1.0, 0.88, 1.0, 90, 255, 90, 200, 0, 0.0, 0.0, 0.0);
		ShowSyncHudText(client, hPlayerHUD, "[Damage]: {%i}", iDamage[client]);
	}
	else if ( IsClientObserver(client) || !IsPlayerAlive(client) )
	{
		SetHudTextParams(-1.0, 0.88, 1.0, 90, 255, 90, 200, 0, 0.0, 0.0, 0.0);
		int spec = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
		if (IsValidClient(spec)) ShowSyncHudText(client, hPlayerHUD, "[Damage]: {%i} | [%N's Damage]: {%i}", iDamage[spec], spec, iDamage[spec]);
		else ShowSyncHudText(client, hPlayerHUD, "[Damage]: {%i}", iDamage[client]);
	}
}
public Action DoSuicide(int client, const char[] command, int argc)
{
	if ( Enabled && (CheckRoundState() == 0 || CheckRoundState() == 1) )
	{
		if (bIsBoss[client] && bTenSecStart[0])
		{
			CPrintToChat(client, "Do not suicide as a Boss, asshole!. Use !resetq instead.");
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}
public Action DoSuicide2(int client, const char[] command, int argc)
{
	if (Enabled && bIsBoss[client] && bTenSecStart[0])
	{
		CPrintToChat(client, "You Can't Change Teams This Early!!");
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
stock void ClampCharge(int client)
{
	if (IsValidClient(client))
	{
		if (flCharge[client] > 100.0) flCharge[client] = 100.0;
		if (flCharge[client] < 0.0) flCharge[client] = 0.0;
	}
}
public Action CommandQueuePoints(int client, int args)
{
	if (!Enabled) return Plugin_Continue;
	if (args != 2)
	{
		ReplyToCommand(client, "[VSH Engine] Usage: vsha_addpoints <target> <points>");
		return Plugin_Handled;
	}
	char s2[80];
	char targetname[PLATFORM_MAX_PATH];
	GetCmdArg(1, targetname, sizeof(targetname));
	GetCmdArg(2, s2, sizeof(s2));
	int points = StringToInt(s2);
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	if ( (target_count = ProcessTargetString(
			targetname,
			client,
			target_list,
			MAXPLAYERS,
			0,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0 )
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (int i = 0; i < target_count; i++)
	{
		SetClientQueuePoints(target_list[i], GetClientQueuePoints(target_list[i])+points);
		LogAction(client, target_list[i], "\"%L\" added %d VSHA queue points to \"%L\"", client, points, target_list[i]);
	}
	ReplyToCommand(client, "[VSH Engine] Added %d queue points to %s", points, target_name);
	return Plugin_Handled;
}
public Action CommandBossSelect(int client, int args)
{
	if (!Enabled) return Plugin_Continue;
	if (args < 1)
	{
		ReplyToCommand(client, "[VSH] Usage: hale_select <target> [\"hidden\"]");
		return Plugin_Handled;
	}
	char s2[32];
	char targetname[32];
	GetCmdArg(1, targetname, sizeof(targetname));
	GetCmdArg(2, s2, sizeof(s2));
	if ( strcmp(targetname, "@me", false) == 0 && IsValidClient(client) ) iNextBossPlayer = client;
	else
	{
		int target = FindTarget(client, targetname);
		if (IsValidClient(target)) iNextBossPlayer = target;
	}
	return Plugin_Handled;
}
public Action CallMedVoiceMenu(int iClient, const char[] sCommand, int iArgc)
{
	if (iArgc < 2) return Plugin_Handled;
	char sCmd1[8];
	char sCmd2[8];
	GetCmdArg(1, sCmd1, sizeof(sCmd1));
	GetCmdArg(2, sCmd2, sizeof(sCmd2));
	//Capture call for medic commands (represented by "voicemenu 0 0")
	if (sCmd1[0] == '0' && sCmd2[0] == '0' && IsPlayerAlive(iClient) && bIsBoss[iClient])
	{
		DoTaunt(iClient, "", 0);
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

public Action DoTaunt(int client, const char[] command, int argc)
{
	if ( !Enabled || !bIsBoss[client] ) return Plugin_Continue;
	if (bNoTaunt[client]) return Plugin_Handled;
	//TF2_AddCondition(client, TFCond:42, 4.0); //use this in the forward
	if (flCharge[client] >= 100.0)
	{
		Function FuncBossRage = GetFunctionByName(Storage[client], "VSHA_OnBossRage");
		if (FuncBossRage != INVALID_FUNCTION)
		{
			Call_StartFunction(Storage[client], FuncBossRage);
			Call_PushCell(client);
			Call_Finish();
		}
		bNoTaunt[client] = true;
		CreateTimer(1.5, TimerNoTaunting, iBossUserID[client], TIMER_FLAG_NO_MAPCHANGE);
		flCharge[client] = 0.0;
	}
	return Plugin_Continue;
}
public Action TimerNoTaunting(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client)) bNoTaunt[client] = false;
	return Plugin_Continue;
}
public void OnEntityCreated(int entity, const char[] classname)
{
	if ( !StrContains(classname, "tf_weapon_") ) CreateTimer( 0.4, OnWeaponSpawned, EntIndexToEntRef(entity) );

	//if ( StrContains(classname, "item_healthkit") != -1 || StrContains(classname, "item_ammopack") != -1 || StrEqual(classname, "tf_ammo_pack") ) SDKHook(entity, SDKHook_Spawn, OnItemSpawned);
}
public Action OnWeaponSpawned(Handle timer, any ref)
{
	int wep = EntRefToEntIndex(ref);
	if ( IsValidEntity(wep) && IsValidEdict(wep) )
	{
		int client = GetOwner(wep);
		if (!IsValidClient(client)) return Plugin_Continue;
		AmmoTable[wep] = GetWeaponAmmo(wep);
		ClipTable[wep] = GetWeaponClip(wep);
	}
	return Plugin_Continue;
}
public void OnConfigsExecuted()
{
	Enabled = bEnabled.BoolValue;
}
public void TF2_OnConditionAdded(int client, TFCond condition)
{
	if ( Enabled && IsValidClient(client) && (bIsBoss[client] || bIsMinion[client]) )
	{
		Function FuncBossConditioned = GetFunctionByName(Storage[client], "VSHA_OnBossConditionAdded");
		if (FuncBossConditioned != INVALID_FUNCTION)
		{
			Call_StartFunction(Storage[client], FuncBossConditioned);
			Call_PushCell(client);
			Call_PushCell(condition);
			Call_Finish();
		}
	}
}
stock int HealthCalc(float initial, float playing, float subtract, float exponent, float additional)
{
	return RoundFloat( Pow((((initial/CountBosses())+playing)*(playing-subtract)), exponent)+additional );
}
public void CalcScores()
{
	int j, damage;
	for (int i = 1; i <= MaxClients; i++)
	{
		if ( IsValidClient(i) && GetClientTeam(i) > view_as<int>(TFTeam_Spectator) )
		{
			damage = iDamage[i];

			Event aevent = CreateEvent("player_escort_score", true);
			aevent.SetInt("player", i);

			for (j = 0; damage-600 > 0; damage -= 600, j++){}
			aevent.SetInt("points", j);
			aevent.Fire();

			if ( bIsBoss[i] ) SetClientQueuePoints(i, 0);
			else
			{
				CPrintToChat(i, "{olive}[VSH Engine]{default} You get %i queue points.", QueueIncrement.IntValue); //GetConVarInt(QueueIncrement));
				SetClientQueuePoints( i, (GetClientQueuePoints(i)+QueueIncrement.IntValue) );
			}
		}
	}
}
stock int CountBosses()
{
	int NumBosses = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if ( IsValidClient(i) && IsPlayerAlive(i) && bIsBoss[i] ) NumBosses++;
	}
	return NumBosses;
}
stock bool GetRJFlag(int client)
{
	return (IsValidClient(client, false) && IsPlayerAlive(client) ? bInJump[client] : false);
}
stock void SetRJFlag(int client, bool bState)
{
	if (IsValidClient(client, false)) bInJump[client] = bState;
}
stock int GetSingleBoss()
{
	int NextBoss;
	if (iNextBossPlayer > 0) NextBoss = iNextBossPlayer;
	else NextBoss = FindNextBoss(bIsBoss);
	iBossUserID[NextBoss] = GetClientUserId(NextBoss); //should work better than just a normal client int
	bIsBoss[NextBoss] = true;
	return NextBoss;
}
stock bool OnlyScoutsLeft()
{
	for (int client; client <= MaxClients; client++)
	{
		if (IsValidClient(client) && IsPlayerAlive(client) && !bIsBoss[client] && !bIsMinion[client])
		{
			if (TF2_GetPlayerClass(client) != TFClass_Scout) break;
			return true;
		}
	}
	return false;
}
stock int CountScoutsLeft()
{
	int scunts = 0;
	for (int client; client <= MaxClients; client++)
	{
		if (IsValidClient(client) && IsPlayerAlive(client) && !bIsBoss[client] && !bIsMinion[client])
		{
			if (TF2_GetPlayerClass(client) != TFClass_Scout) continue;
			scunts++;
		}
	}
	return scunts;
}
public void LoadSubPlugins() //"stolen" from ff2 lol
{
	char path[PATHX], filename[PATHX];
	BuildPath(Path_SM, path, PATHX, "plugins/");
	FileType filetype;
	DirectoryListing directory = OpenDirectory(path);
	while ( ReadDirEntry(directory, filename, PATHX, filetype) )
	{
		if ( filetype == FileType_File && StrContains(filename, ".smx", false) != -1 )
		{
			ServerCommand("sm plugins load %s", filename);
		}
	}
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////// N A T I V E S  &  F O R W A R D S //////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// F O R W A R D S ==============================================================================================
	AddToDownloads = CreateGlobalForward("VSHA_AddToDownloads", ET_Ignore);
	//===========================================================================================================================

	// N A T I V E S ============================================================================================================
	CreateNative("VSHA_RegisterBoss", Native_RegisterBossSubplugin);

	CreateNative("VSHA_GetBossUserID", Native_GetBossUserID);
	CreateNative("VSHA_SetBossUserID", Native_SetBossUserID);

	CreateNative("VSHA_GetDifficulty", Native_GetDifficulty);
	CreateNative("VSHA_SetDifficulty", Native_SetDifficulty);

	CreateNative("VSHA_GetLives", Native_GetLives);
	CreateNative("VSHA_SetLives", Native_SetLives);

	CreateNative("VSHA_GetPresetBoss", Native_GetPresetBoss);
	CreateNative("VSHA_SetPresetBoss", Native_SetPresetBoss);

	CreateNative("VSHA_GetBossHealth", Native_GetBossHealth);
	CreateNative("VSHA_SetBossHealth", Native_SetBossHealth);

	CreateNative("VSHA_GetBossMaxHealth", Native_GetBossMaxHealth);
	CreateNative("VSHA_SetBossMaxHealth", Native_SetBossMaxHealth);

	CreateNative("VSHA_GetBossPlayerKills", Native_GetBossPlayerKills);
	CreateNative("VSHA_SetBossPlayerKills", Native_SetBossPlayerKills);

	CreateNative("VSHA_GetBossKillstreak", Native_GetBossKillstreak);
	CreateNative("VSHA_SetBossKillstreak", Native_SetBossKillstreak);

	CreateNative("VSHA_GetPlayerBossKills", Native_GetPlayerBossKills);
	CreateNative("VSHA_SetPlayerBossKills", Native_SetPlayerBossKills);

	CreateNative("VSHA_GetDamage", Native_GetDamage);
	CreateNative("VSHA_SetDamage", Native_SetDamage);

	CreateNative("VSHA_GetBossMarkets", Native_GetBossMarkets);
	CreateNative("VSHA_SetBossMarkets", Native_SetBossMarkets);

	CreateNative("VSHA_GetBossStabs", Native_GetBossStabs);
	CreateNative("VSHA_SetBossStabs", Native_SetBossStabs);

	CreateNative("VSHA_GetHits", Native_GetHits);
	CreateNative("VSHA_SetHits", Native_SetHits);

	CreateNative("VSHA_GetMaxWepAmmo", Native_GetMaxWepAmmo);
	CreateNative("VSHA_SetMaxWepAmmo", Native_SetMaxWepAmmo);

	CreateNative("VSHA_GetMaxWepClip", Native_GetMaxWepClip);
	CreateNative("VSHA_SetMaxWepClip", Native_SetMaxWepClip);

	CreateNative("VSHA_GetPresetBossPlayer", Native_GetPresetBossPlayer);
	CreateNative("VSHA_SetPresetBossPlayer", Native_SetPresetBossPlayer);

	CreateNative("VSHA_GetAliveRedPlayers", Native_GetAliveRedPlayers);
	CreateNative("VSHA_GetAliveBluPlayers", Native_GetAliveBluePlayers);

	CreateNative("VSHA_GetBossRage", Native_GetBossRage);
	CreateNative("VSHA_SetBossRage", Native_SetBossRage);

	CreateNative("VSHA_GetGlowTimer", Native_GetGlowTimer);
	CreateNative("VSHA_SetGlowTimer", Native_SetGlowTimer);

	CreateNative("VSHA_IsBossPlayer", Native_IsBossPlayer);
	CreateNative("VSHA_IsPlayerInJump", Native_IsPlayerInJump);
	CreateNative("VSHA_CanBossTaunt", Native_CanBossTaunt);

	CreateNative("VSHA_GetSingleBoss", Native_GetSingleBoss);

	CreateNative("VSHA_PickBossSpecial", Native_PickBossSpecial);

	CreateNative("VSHA_IsMinion", Native_IsMinion);
	CreateNative("VSHA_SetMinion", Native_SetMinion);

	CreateNative("VSHA_CalcBossHealth", Native_CalcBossHealth);

	CreateNative("VSHA_CountScoutsLeft", Native_CountScoutsLeft);

	//===========================================================================================================================

	RegPluginLibrary("vsha");
#if defined _steamtools_included
	MarkNativeAsOptional("Steam_SetGameDescription");
#endif
	return APLRes_Success;
}

public int Native_RegisterBossSubplugin(Handle plugin, int numParams)
{
	char BossSubPluginName[32];
	GetNativeString(1, BossSubPluginName, sizeof(BossSubPluginName));
	VSHAError erroar;
	Handle BossHandle = RegisterBoss(plugin, BossSubPluginName, erroar); //ALL PROPS TO COOKIES.NET AKA COOKIES.IO
	return view_as<int>(BossHandle);
}

public int Native_GetBossUserID(Handle plugin, int numParams)
{
	return iBossUserID[GetNativeCell(1)];
}
public int Native_SetBossUserID(Handle plugin, int numParams)
{
	iBossUserID[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetDifficulty(Handle plugin, int numParams)
{
	return iDifficulty[GetNativeCell(1)];
}
public int Native_SetDifficulty(Handle plugin, int numParams)
{
	iDifficulty[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetLives(Handle plugin, int numParams)
{
	return iLives[GetNativeCell(1)];
}
public int Native_SetLives(Handle plugin, int numParams)
{
	iLives[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetPresetBoss(Handle plugin, int numParams)
{
	return iPresetBoss[GetNativeCell(1)];
}
public int Native_SetPresetBoss(Handle plugin, int numParams)
{
	iPresetBoss[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetBossHealth(Handle plugin, int numParams)
{
	return iBossHealth[GetNativeCell(1)];
}
public int Native_SetBossHealth(Handle plugin, int numParams)
{
	iBossHealth[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetBossMaxHealth(Handle plugin, int numParams)
{
	return iBossMaxHealth[GetNativeCell(1)];
}
public int Native_SetBossMaxHealth(Handle plugin, int numParams)
{
	iBossMaxHealth[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetBossPlayerKills(Handle plugin, int numParams)
{
	return iPlayerKilled[GetNativeCell(1)][0];
}
public int Native_SetBossPlayerKills(Handle plugin, int numParams)
{
	iPlayerKilled[GetNativeCell(1)][0] = GetNativeCell(2);
	return 0;
}

public int Native_GetBossKillstreak(Handle plugin, int numParams)
{
	return iPlayerKilled[GetNativeCell(1)][1];
}
public int Native_SetBossKillstreak(Handle plugin, int numParams)
{
	iPlayerKilled[GetNativeCell(1)][1] = GetNativeCell(2);
	return 0;
}

public int Native_GetPlayerBossKills(Handle plugin, int numParams)
{
	return iBossesKilled[GetNativeCell(1)];
}
public int Native_SetPlayerBossKills(Handle plugin, int numParams)
{
	iBossesKilled[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetDamage(Handle plugin, int numParams)
{
	return iDamage[GetNativeCell(1)];
}
public int Native_SetDamage(Handle plugin, int numParams)
{
	iDamage[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetBossMarkets(Handle plugin, int numParams)
{
	return iMarketed[GetNativeCell(1)];
}
public int Native_SetBossMarkets(Handle plugin, int numParams)
{
	iMarketed[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetBossStabs(Handle plugin, int numParams)
{
	return iStabbed[GetNativeCell(1)];
}
public int Native_SetBossStabs(Handle plugin, int numParams)
{
	iStabbed[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetHits(Handle plugin, int numParams)
{
	return iHits[GetNativeCell(1)];
}
public int Native_SetHits(Handle plugin, int numParams)
{
	iHits[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetMaxWepAmmo(Handle plugin, int numParams)
{
	return AmmoTable[GetNativeCell(1)];
}
public int Native_SetMaxWepAmmo(Handle plugin, int numParams)
{
	AmmoTable[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetMaxWepClip(Handle plugin, int numParams)
{
	return ClipTable[GetNativeCell(1)];
}
public int Native_SetMaxWepClip(Handle plugin, int numParams)
{
	ClipTable[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetPresetBossPlayer(Handle plugin, int numParams)
{
	return iNextBossPlayer;
}
public int Native_SetPresetBossPlayer(Handle plugin, int numParams)
{
	iNextBossPlayer = GetNativeCell(1);
	return 0;
}

public int Native_GetAliveRedPlayers(Handle plugin, int numParams)
{
	return iRedAlivePlayers;
}
public int Native_GetAliveBluePlayers(Handle plugin, int numParams)
{
	return iBluAlivePlayers;
}

public int Native_GetBossRage(Handle plugin, int numParams)
{
	return view_as<int>(flCharge[GetNativeCell(1)]);
}
public int Native_SetBossRage(Handle plugin, int numParams)
{
	flCharge[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetGlowTimer(Handle plugin, int numParams)
{
	return view_as<int>(flGlowTimer[GetNativeCell(1)]);
}
public int Native_SetGlowTimer(Handle plugin, int numParams)
{
	flGlowTimer[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_IsBossPlayer(Handle plugin, int numParams)
{
	return bIsBoss[GetNativeCell(1)];
}
public int Native_IsPlayerInJump(Handle plugin, int numParams)
{
	return bInJump[GetNativeCell(1)];
}
public int Native_CanBossTaunt(Handle plugin, int numParams)
{
	return bNoTaunt[GetNativeCell(1)];
}

public int Native_GetSingleBoss(Handle plugin, int numParams)
{
	return GetSingleBoss();
}

public int Native_PickBossSpecial(Handle plugin, int numParams)
{
	PickBossSpecial(GetNativeCell(1));
	return 0;
}

public int Native_IsMinion(Handle plugin, int numParams)
{
	return bIsMinion[GetNativeCell(1)];
}
public int Native_SetMinion(Handle plugin, int numParams)
{
	bIsMinion[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_CalcBossHealth(Handle plugin, int numParams)
{
	return HealthCalc(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3), GetNativeCell(4), GetNativeCell(5));
}
public int Native_CountScoutsLeft(Handle plugin, int numParams)
{
	return CountScoutsLeft();
}