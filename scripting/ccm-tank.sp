#include <tf2>
#include <sdkhooks>
#include <morecolors>
#include <ccm>

#define PLUGIN_VERSION "1.5"
public Plugin myinfo = 
{
	name 			= "Be A Muffican Tank",
	author 			= "nergal/assyrian",
	description 		= "Allows Players to be a damn Tank!!!",
	version 		= PLUGIN_VERSION,
	url 			= "hue" //will fill later
}

//defines
#define TankModel		"models/custom/panzer/panzer.mdl" //thx to Friagram for saving teh day!
#define TankModelPrefix		"models/custom/panzer/panzer"
#define TankShoot		"acvshtank/fire"
#define TankDeath		"acvshtank/dead"
#define TankReload		"acvshtank/reload.mp3"
#define TankCrush		"acvshtank/vehicle_hit_person.mp3"
#define TankMove		"acvshtank/tankdrive.mp3"
#define TankIdle		"acvshtank/tankidle.mp3"

//cvar handles
Handle bEnabled = INVALID_HANDLE;
Handle bGasPowered = INVALID_HANDLE;
Handle iHealth = INVALID_HANDLE;
Handle BluLimit = INVALID_HANDLE;
Handle RedLimit = INVALID_HANDLE;
Handle HealthFromMetal = INVALID_HANDLE;
Handle HealthFromMetalMult = INVALID_HANDLE;
Handle HealthFromEngies = INVALID_HANDLE;
Handle NoFallOffRockets = INVALID_HANDLE;
Handle NoFallOffTurret = INVALID_HANDLE;
Handle RocketBaseDamage = INVALID_HANDLE;
Handle iAmmo = INVALID_HANDLE;
Handle RocketSpeed = INVALID_HANDLE;
Handle InitialTankSpeed = INVALID_HANDLE;
Handle MaxForwardSpeed = INVALID_HANDLE;
Handle MaxReverseSpeed = INVALID_HANDLE;
Handle CrushDmg = INVALID_HANDLE;
Handle RocketCooldown = INVALID_HANDLE;
Handle TankAcceleration = INVALID_HANDLE;
Handle TurretDamage = INVALID_HANDLE;
Handle NoTankRocketJump = INVALID_HANDLE;
Handle AllowTankTeleport = INVALID_HANDLE;
Handle StartingFuel = INVALID_HANDLE;
Handle AdminFlagByPass = INVALID_HANDLE;
Handle bSelfDamage = INVALID_HANDLE;
Handle HUDX = INVALID_HANDLE;
Handle HUDY = INVALID_HANDLE;

Handle hHudText;

Handle ThisPluginHandle = INVALID_HANDLE;

//bools
bool bIsTank[PLYR];
bool bSetTank[PLYR];

//floats
float flLastFire[PLYR];
float flLastHit[PLYR];
float flGasMeter[PLYR];

float flSpeedup[PLYR] = { 0.0, ... };
float flSoundDelay[PLYR];
float flIdleSound[PLYR];

//ints
int iTankHealth[PLYR]; //works very similar to VSH/FF2 but this is designed as a playable class rather than a boss
int iTankMaxHealth;

public void OnPluginStart()
{
	ThisPluginHandle = Handle:CCM_RegisterClass("MilitaryTank");

	RegAdminCmd("sm_reloadtankcfg", CmdReloadCFG, ADMFLAG_GENERIC);

	hHudText = CreateHudSynchronizer();

	bEnabled = CreateConVar("sm_betank_enabled", "1", "Enable Player-Tank plugin", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	
	bGasPowered = CreateConVar("sm_betank_gaspowered", "1", "Enable Tanks to be powered via 'gas' which is replenishable by dispensers+mediguns", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	iHealth = CreateConVar("sm_betank_health", "1000", "how much health Tanks will start with", FCVAR_PLUGIN, true, 1.0, true, 99999.0);

	iAmmo = CreateConVar("sm_betank_ammo", "1000", "how much ammo Tanks will start with", FCVAR_PLUGIN, true, 0.0, true, 99999.0);


	BluLimit = CreateConVar("sm_betank_blu_limit", "0", "how many Tanks blu team can have, '-1' for unlimited tanks", FCVAR_PLUGIN, true, 0.0, true, 16.0);

	RedLimit = CreateConVar("sm_betank_red_limit", "1", "how many Tanks red team can have, '-1' for unlimited tanks", FCVAR_PLUGIN, true, 0.0, true, 16.0);

	HealthFromMetal = CreateConVar("sm_betank_healthfrommetal", "25", "how much metal to heal/arm Tanks by Engineers", FCVAR_PLUGIN, true, 0.0, true, 999.0);

	HealthFromMetalMult = CreateConVar("sm_betank_healthfrommetal_mult", "4", "how much metal to heal/arm Tanks by Engineers mult", FCVAR_PLUGIN, true, 0.0, true, 999.0);

	HealthFromEngies = CreateConVar("sm_betank_hpfromengies", "1", "(Dis)Allow Engies to be able to repair+arm Tanks via wrench", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	NoFallOffRockets = CreateConVar("sm_betank_nofalloffrockets", "1", "(Dis)Allow Tank Rockets to have no Damage Fall-Off and no Damage Ramp-up", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	NoTankRocketJump = CreateConVar("sm_betank_norocketjump", "1", "(Dis)Allow Tanks from being able to rocket jump from MOUSE2 rockets", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	NoFallOffTurret = CreateConVar("sm_betank_nofalloffturret", "1", "(Dis)Allow Tank Turret to have no Damage Fall-Off and no Damage Ramp-up", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	bSelfDamage = CreateConVar("sm_betank_selfdamage", "0", "(Dis)Allow Tanks to damage their health when they hurt themselves", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	RocketBaseDamage = CreateConVar("sm_betank_rocketdamage", "100.0", "Base Damage for Rockets shot by Player-Tank", FCVAR_PLUGIN, true, 0.0, true, 9999.0);

	TurretDamage = CreateConVar("sm_betank_turretdamage", "1.0", "Base Damage for the SMG Turret shot by the Player-Tank", FCVAR_PLUGIN, true, 0.0, true, 9999.0);

	RocketSpeed = CreateConVar("sm_betank_rocketspeed", "4000.0", "Speed of Rockets shot by Player-Tank", FCVAR_PLUGIN, true, 0.0, true, 9999.0);

	RocketCooldown = CreateConVar("sm_betank_rocketcooldown", "4.0", "Time in seconds for Rocket Gun to be able to shoot another rocket, set to 4 by default to match with reload sound", FCVAR_PLUGIN, true, 0.0, true, 9999.0);

	InitialTankSpeed = CreateConVar("sm_betank_initialspeed", "40.0", "Initial Speed (in Hammer Units/second) of Tank", FCVAR_PLUGIN, true, 0.0, true, 9999.0);

	MaxForwardSpeed = CreateConVar("sm_betank_maxspeed", "100.0", "Max Forward Speed (in Hammer Units/second) of Tank", FCVAR_PLUGIN, true, 0.0, true, 9999.0);

	MaxReverseSpeed = CreateConVar("sm_betank_reversespeed", "80.0", "Max Backwards Speed (in Hammer Units/second) of Tank", FCVAR_PLUGIN, true, 0.0, true, 9999.0);

	TankAcceleration = CreateConVar("sm_betank_acceleration", "3.0", "Acceleration in speed every 0.2 seconds (in Hammer Units/second) of Tank", FCVAR_PLUGIN, true, 0.0, true, 9999.0);

	CrushDmg = CreateConVar("sm_betank_crushdamage", "30.0", "Crush Damage (ignores uber) done by Tank while it's moving", FCVAR_PLUGIN, true, 0.0, true, 9999.0);
	
	AllowTankTeleport = CreateConVar("sm_betank_allowtele", "1", "(Dis)Allow Tank to be able to use Engineer teleporters", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	HUDX = CreateConVar("sm_betank_hudx", "2.0", "x coordinate for the Gas Meter HUD", FCVAR_PLUGIN);

	HUDY = CreateConVar("sm_betank_hudy", "2.0", "y coordinate for the Gas Meter HUD", FCVAR_PLUGIN);

	StartingFuel = CreateConVar("sm_betank_startingfuel", "500.0", "If tanks are gas powered, how much gas they will start with", FCVAR_PLUGIN, true, 0.0, true, 9999.0);

	AdminFlagByPass = CreateConVar("sm_betank_adminflag_bypass", "a", "what flag admins need to bypass the tank class limit", FCVAR_PLUGIN);

	HookEvent("player_death", PlayerDeath, EventHookMode_Pre);

	AutoExecConfig(true, "CCM-TankClass");
}
public void OnClientPutInServer(int client)
{
	iTankHealth[client] = 0;
	flLastFire[client] = 0.0;
}
public void OnClientDisconnect(int client)
{
	iTankHealth[client] = 0;
	flLastFire[client] = 0.0;
	bIsTank[client] = false;
}
public void CCM_OnClassSelected(int client)
{
	bSetTank[client] = true;
	iTankHealth[client] = 0;
	flLastFire[client] = 0.0;
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_TraceAttack, TraceAttack);
	SDKHook(client, SDKHook_Touch, OnTouch);
	SDKHook(client, SDKHook_PreThink, OnPreThink);
}
public void CCM_OnClassDeselected(int client)
{
	bSetTank[client] = false;
	iTankHealth[client] = 0;
	flLastFire[client] = 0.0;
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKUnhook(client, SDKHook_TraceAttack, TraceAttack);
	SDKUnhook(client, SDKHook_Touch, OnTouch);
	SDKUnhook(client, SDKHook_PreThink, OnPreThink);
}
public Action PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	if (!GetConVarBool(bEnabled)) return Plugin_Continue;
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (bIsTank[client]) //if victim is a tank, kill him off and remove overlay
	{
		TF2_IgnitePlayer(client, attacker);
		CreateTimer(0.1, TimerTankDeath, GetEventInt(event, "userid"));
	}
	if (bIsTank[attacker] && !bIsTank[client]) //if tank is killer and victim is not a tank, check if player was crushed
	{
		if (flLastHit[client] != 0.0) //set kill icon to crush
		{
			if (GetGameTime()-flLastHit[client] <= 0.10)
			{
				int iDamageBits = GetEventInt(event, "damagebits");
				SetEventInt(event, "damagebits",  iDamageBits |= DMG_CRUSH);
				SetEventString(event, "weapon_logclassname", "tank_crush");
				SetEventString(event, "weapon", "mantreads"); // something environmental ??!! 
				SetEventInt(event, "customkill", TF_CUSTOM_TRIGGER_HURT);
				SetEventInt(event, "playerpenetratecount", 0);
				char s[PLATFORM_MAX_PATH];
				strcopy(s, PLATFORM_MAX_PATH, TankCrush);
				EmitSoundToAll(s, client);
				return Plugin_Continue;
			}
			flLastHit[client] = 0.0;
		}
	}
	return Plugin_Continue;
}
public Action CCM_OnClassTeleport(int client, int teleporter, bool &result)
{
	CPrintToChat(client, "{red}[CCM]{default} Test CCM_OnClassTeleport");
	if (!GetConVarBool(AllowTankTeleport))
	{
		result = false;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public void CCM_AddToDownloads()
{
	char s[PLATFORM_MAX_PATH];
	char extensions[][] = { ".mdl", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd", ".phy" };
	//char extensionsb[][] = { ".vtf", ".vmt" };
	int i;
	for (i = 0; i < sizeof(extensions); i++)
	{
		Format(s, PLATFORM_MAX_PATH, "%s%s", TankModelPrefix, extensions[i]);
		if (FileExists(s, true)) AddFileToDownloadsTable(s);
	}
	for (i = 1; i <= 3; i++)
	{
		if (i <= 2)
		{
			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TankDeath, i);
			PrecacheSound(s, true);
			Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
		}
		Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TankShoot, i);
		PrecacheSound(s, true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
	}
	AddFileToDownloadsTable("materials/models/custom/panzer/panzer.vmt");
	AddFileToDownloadsTable("materials/models/custom/panzer/panzer.vtf");
	AddFileToDownloadsTable("materials/models/custom/panzer/panzer_blue.vmt");
	AddFileToDownloadsTable("materials/models/custom/panzer/panzer_blue.vtf");
	AddFileToDownloadsTable("materials/models/custom/panzer/panzer_NM.vtf");
	AddFileToDownloadsTable("materials/models/custom/panzer/panzer_SM.vtf");
	AddFileToDownloadsTable("materials/models/custom/panzer/panzer_track.vmt");
	AddFileToDownloadsTable("materials/models/custom/panzer/panzer_track.vtf");
	AddFileToDownloadsTable("materials/models/custom/panzer/panzer_track_NM.vtf");
	AddFileToDownloadsTable("materials/models/custom/panzer/panzer_track_SM.vtf");

	PrecacheModel(TankModel, true);
	AddFileToDownloadsTable("sound/acvshtank/reload.mp3");
	AddFileToDownloadsTable("sound/acvshtank/vehicle_hit_person.mp3");
	AddFileToDownloadsTable("sound/acvshtank/tankidle.mp3");
	AddFileToDownloadsTable("sound/acvshtank/tankdrive.mp3");
	PrecacheSound(TankReload, true);
	PrecacheSound(TankCrush, true);
	PrecacheSound(TankMove, true);
	PrecacheSound(TankIdle, true);
}
public void CCM_OnClassResupply(int client)
{
	CPrintToChat(client, "{red}[CCM]{default} Test CCM_OnClassResupply");
	iTankHealth[client] = ( iTankMaxHealth = GetConVarInt(iHealth) );
	if (GetConVarBool(bGasPowered)) flGasMeter[client] = GetConVarFloat(StartingFuel);
	return;
}
public Action CCM_OnMakeClass(int client)
{
	CPrintToChat(client, "{red}[CCM]{default} Test CCM_OnMakeClass");
	bIsTank[client] = true;
	iTankHealth[client] = ( iTankMaxHealth = GetConVarInt(iHealth) );
	CreateTimer(0.1, TimerTankFunction, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	if (GetConVarBool(bGasPowered)) flGasMeter[client] = GetConVarFloat(StartingFuel);
	return Action:0;
}
public void CCM_OnClassEquip(int client)
{
	CPrintToChat(client, "{red}[CCM]{default} Test CCM_OnClassEquip");
	int Turret, maxhp = GetEntProp(client, Prop_Data, "m_iMaxHealth");
	char attribs[64];
	Format( attribs, sizeof(attribs), "2 ; %f ; 125 ; %i ; 6 ; 0.5 ; 326 ; 0.0 ; 252 ; 0.0 ; 25 ; 0.0 ; 402 ; 1.0 ; 53 ; 1 ; 59 ; 0.0", GetConVarFloat(TurretDamage), (1-maxhp) );
	Turret = SpawnWeapon(client, "tf_weapon_smg", 16, 1, 0, attribs);
	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", Turret);
	SetWeaponClip(Turret, GetConVarInt(iAmmo));
	SetWeaponAmmo(Turret, 0);

	SetWeaponInvis( client, 1 ); //makes SMG 99.67% transparent to simulate machine-gun turret
	SetClientOverlay( client, "effects/combine_binocoverlay" );
	return;
}
public void CCM_OnClassChangeClass(int client)
{
	CPrintToChat(client, "{red}[CCM]{default} Test CCM_OnClassChangeClass");
	if (!bSetTank[client]) //if player doesn't wanna be tank anymore, take him off tank
	{
		bIsTank[client] = false;
		SetVariantString("");
		AcceptEntityInput(client, "SetCustomModel");
		SetClientOverlay(client, "0");
		TF2_RegeneratePlayer(client);
	}
	else //refresh tank's supplies
	{
		TF2_RemoveAllWeapons2(client);
		CCM_OnClassEquip(client);
		iTankHealth[client] = ( iTankMaxHealth = GetConVarInt(iHealth) );
		if (GetConVarBool(bGasPowered)) flGasMeter[client] = GetConVarFloat(StartingFuel);
	}
	return;
}
public Action TimerTankDeath(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client))
	{
		if (iTankHealth[client] <= 0) iTankHealth[client] = 0; //ded, not big soup rice!
		StopSound(client, SNDCHAN_AUTO, TankIdle);
		StopSound(client, SNDCHAN_AUTO, TankMove);
		char s[PLATFORM_MAX_PATH];
		Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TankDeath, GetRandomInt(1, 2)); //sounds from Call of duty 1
		EmitSoundToAll(s, client);
		AttachParticle(client, "buildingdamage_dispenser_fire1", 1.0);
		SetClientOverlay(client, "0");
	}
	return Action:0;
}
public void CCM_OnClassKilled(int client, int attacker)
{
	CPrintToChat(client, "{red}[CCM]{default} Test CCM_OnClassKilled");
	TF2_IgnitePlayer(client, attacker);
	CreateTimer(0.1, TimerTankDeath, GetClientUserId(client));
	return;
}

public Action RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	if (!GetConVarBool(bEnabled)) return Plugin_Continue;
	for (int client = 1; client <= MaxClients; client++)
	{
		if ( IsValidClient(client, false) && bIsTank[client] )
		{
			TF2_RemoveAllWeapons2(client);
			CCM_OnClassEquip(client); //this code for VSH/FF2 replacing weapons
		}
	}
	return Plugin_Continue;
}
public Action CCM_OnModelTimer(int client, char ClassModel[64])
{
	CPrintToChat(client, "{red}[CCM]{default} Test CCM_OnModelTimer");
	ClassModel = TankModel;
	return Plugin_Continue;
}

public Action TimerTankFunction(Handle hTimer, any userid) //main 'mechanics' of tank
{
	int client = GetClientOfUserId(userid);
	if (client <= 0) return Plugin_Stop;
	if (client && IsClientInGame(client) && IsPlayerAlive(client))
	{
		if (bIsTank[client])
		{
			char s[PLATFORM_MAX_PATH];
			int buttons = GetClientButtons(client);
			if ( (buttons & IN_FORWARD) || ( (buttons & IN_FORWARD) && ( ( buttons & (IN_MOVELEFT|IN_MOVERIGHT) ) ) ) )
			{
				flSpeedup[client] += GetConVarFloat(TankAcceleration); /*simulates vehicular physics; not as good as Valve does with vehicle entities*/
				if (flSpeedup[client] > GetConVarFloat(MaxForwardSpeed)) flSpeedup[client] = GetConVarFloat(MaxForwardSpeed);
				StopSound(client, SNDCHAN_AUTO, TankIdle);
				flIdleSound[client] = 0.0;
				if (flSoundDelay[client] < GetGameTime())
				{
					strcopy(s, PLATFORM_MAX_PATH, TankMove);
					EmitSoundToAll(s, client);
					flSoundDelay[client] = GetGameTime()+31.0;
				}
				if (GetConVarBool(bGasPowered))
				{
					flGasMeter[client] -= 0.1;
					if (flGasMeter[client] <= 0.0) flGasMeter[client] = 0.0;
				}
			}
			else if ( buttons & (IN_MOVELEFT|IN_MOVERIGHT) )
			{
				flSpeedup[client] += GetConVarFloat(TankAcceleration);
				if (flSpeedup[client] > GetConVarFloat(MaxForwardSpeed)) flSpeedup[client] = GetConVarFloat(MaxForwardSpeed);
				StopSound(client, SNDCHAN_AUTO, TankIdle);
				flIdleSound[client] = 0.0;
				if (flSoundDelay[client] < GetGameTime())
				{
					strcopy(s, PLATFORM_MAX_PATH, TankMove);
					EmitSoundToAll(s, client);
					flSoundDelay[client] = GetGameTime()+31.0;
				}
				if (GetConVarBool(bGasPowered))
				{
					flGasMeter[client] -= 0.1;
					if (flGasMeter[client] <= 0.0) flGasMeter[client] = 0.0;
				}
			}
			else if ( (buttons & IN_BACK) || ( (buttons & IN_BACK) && ( buttons & (IN_MOVELEFT|IN_MOVERIGHT) ) ) )
			{
				flSpeedup[client] += GetConVarFloat(TankAcceleration);
				if (flSpeedup[client] > GetConVarFloat(MaxReverseSpeed)) flSpeedup[client] = GetConVarFloat(MaxReverseSpeed);
				StopSound(client, SNDCHAN_AUTO, TankIdle);
				flIdleSound[client] = 0.0;
				if (flSoundDelay[client] < GetGameTime())
				{
					strcopy(s, PLATFORM_MAX_PATH, TankMove);
					EmitSoundToAll(s, client);
					flSoundDelay[client] = GetGameTime()+31.0;
				}
				if (GetConVarBool(bGasPowered))
				{
					flGasMeter[client] -= 0.1;
					if (flGasMeter[client] <= 0.0) flGasMeter[client] = 0.0;
				}
			}
			else
			{
				StopSound(client, SNDCHAN_AUTO, TankMove);
				flSoundDelay[client] = 0.0;
				flGasMeter[client] += 0.001;
				if (flIdleSound[client] < GetGameTime())
				{
					strcopy(s, PLATFORM_MAX_PATH, TankIdle);
					EmitSoundToAll(s, client);
					flIdleSound[client] = GetGameTime()+5.0;
				}
				flSpeedup[client] = GetConVarFloat(InitialTankSpeed);
			}

			if (GetConVarBool(bGasPowered) && flGasMeter[client] <= 0.0) flSpeedup[client] = 1.0;
			SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", flSpeedup[client]);

			if (IsPlayerAlive(client) && (buttons & IN_ATTACK2) && !(buttons & IN_JUMP) ) //MOUSE2 Rocket firing mechanic
			{
				if ( flLastFire[client] <= GetGameTime() )
				{
					float vAngles[3], vPosition[3];
					GetClientEyeAngles(client, vAngles);
					GetClientEyePosition(client, vPosition);
					//vPosition[2] = vPosition[2]+11.0;
					ShootRocket(client, vPosition, vAngles, GetConVarFloat(RocketSpeed), GetConVarFloat(RocketBaseDamage));
					Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", TankShoot, GetRandomInt(1, 3)); //sounds from Call of duty 1
					EmitSoundToAll(s, client);
					CreateTimer(1.0, TimerReloadTank, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE); //useless, only plays a 'reload' sound
					flLastFire[client] = GetGameTime() + GetConVarFloat(RocketCooldown);
				}
			}
			//CreateTimer(0.1, Timer_TankCrush, client);
			TF2_AddCondition(client, TFCond_MegaHeal, 0.2); /*prevent tanks from being airblasted and gives a team colored aura to allow teams to tell who's on what side */
		}
		else return Plugin_Stop;
	}
	return Plugin_Continue;
}
public Action TimerReloadTank(Handle hTimer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (!bIsTank[client]) return Plugin_Stop;
	if (client && IsClientInGame(client))
	{
		char s[PLATFORM_MAX_PATH];
		strcopy(s, PLATFORM_MAX_PATH, TankReload);
		EmitSoundToAll(s, client);
	}
	return Plugin_Continue;
}
/*public void TankInitialize(int userid)
{
	if (!GetConVarBool(bEnabled)) return;
	int client = GetClientOfUserId(userid);
	if ( client <= 0 ) return;
	int iTeam = GetClientTeam(client);
	if ( (!GetConVarBool(AllowBlu) && (iTeam == 3)) || (!GetConVarBool(AllowRed) && (iTeam == 2)) )
	{
		switch (iTeam)
		{
			case 2: ReplyToCommand(client, "RED players are not allowed to play the Tank class");
			case 3: ReplyToCommand(client, "BLU players are not allowed to play the Tank class");
		}
		return;
	}
	int TankLimit, iCount = 0;
	switch (iTeam)
	{
		case 0, 1: TankLimit = -2;
		case 2: TankLimit = GetConVarInt(RedLimit);
		case 3: TankLimit = GetConVarInt(BluLimit);
	}
	if (TankLimit == -1)
	{
		bSetTank[client] = true;
		ReplyToCommand(client, "You will be a Tank the next time you respawn/touch a resupply locker");
		return;
	}
	else if (TankLimit == 0)
	{
		if (IsImmune(client))
		{
			bSetTank[client] = true;
			ReplyToCommand(client, "You will be a Tank the next time you respawn/touch a resupply locker");
		}
		else ReplyToCommand(client, "****Tank Class is Blocked for your team");
		return;
	}
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{	
			if ( (GetClientTeam(i) == 1 || GetClientTeam(i) == 0) && bSetTank[i] ) //remove players who played as tank then went spec
				bSetTank[i] = false;
			if ( ( (!GetConVarBool(AllowBlu) && GetClientTeam(i) == 3) || (!GetConVarBool(AllowRed) && GetClientTeam(i) == 2) ) && bSetTank[i] ) //remove players who were forced to switch teams while dead
				bSetTank[i] = false;
			if (GetClientTeam(i) == iTeam && bSetTank[i] && i != client) //get amount of tanks on team
				iCount++;
		}
	}
	if (iCount < TankLimit)
	{
		bSetTank[client] = true;
		ReplyToCommand(client, "You will be a Tank the next time you respawn/touch a resupply locker");
	}
	else if (iCount >= TankLimit)
	{
		if (IsImmune(client))
		{
			bSetTank[client] = true;
			ReplyToCommand(client, "You will be a Tank the next time you respawn/touch a resupply locker");
		}
		else ReplyToCommand(client, "****Tank Limit is Reached");
	}
	return;
}*/
public bool IsImmune(int iClient)
{
	if (!IsValidClient(iClient, false)) return false;
	char sFlags[32];
	GetConVarString(AdminFlagByPass, sFlags, sizeof(sFlags));
	// If flags are specified and client has generic or root flag, client is immune
	return !StrEqual(sFlags, "") && GetUserFlagBits(iClient) & (ReadFlagString(sFlags)|ADMFLAG_ROOT);
}
public Action CmdReloadCFG(int client, int iAction)
{
	ServerCommand("sm_rcon exec sourcemod/CCM-TankClass.cfg");
	ReplyToCommand(client, "**** Reloading CCM-TankClass Config ****");
	return Plugin_Handled;
}
public void UpdateGasHUD(int client)
{
	if (bIsTank[client] && GetConVarBool(bEnabled) && GetConVarBool(bGasPowered))
	{
		if (GetConVarBool(bGasPowered))
		{
			if (!IsClientObserver(client))
			{
				float x = GetConVarFloat(HUDX), y = GetConVarFloat(HUDY);
				int rounder = RoundFloat( flGasMeter[client] );
				if (rounder > 60)
				{
					SetHudTextParams(x, y, 1.0, 0, 255, 0, 255);
					ShowSyncHudText(client, hHudText, "Gas: %i", rounder);
				}
				if ( 30 < rounder < 60 )
				{
					SetHudTextParams(x, y, 1.0, 255, 255, 0, 255);
					ShowSyncHudText(client, hHudText, "Gas: %i", rounder);
				}
				if (rounder < 30)
				{
					SetHudTextParams(x, y, 1.0, 255, 0, 0, 255);
					ShowSyncHudText(client, hHudText, "Gas: %i", rounder);
				}
			}
		}
	}
	return;
}
public Action TraceAttack(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup)
{
	if ( GetConVarBool(bEnabled) && IsValidClient(attacker) && IsValidClient(victim))
	{
		if (GetClientTeam(attacker) == GetClientTeam(victim) && bIsTank[victim]) /*this is basically the same code from my Advanced armor plugin but with the difference of making it work for the Tank class*/
		{
			if (GetConVarBool(HealthFromEngies) && TF2_GetPlayerClass(attacker) == TFClass_Engineer)
			{
				int iCurrentMetal = GetEntProp(attacker, Prop_Data, "m_iAmmo", 4, 3);
				int repairamount = GetConVarInt(HealthFromMetal); //default 10
				int mult = GetConVarInt(HealthFromMetalMult); //default 10
				int m_nMaxTurretMunitions = GetConVarInt(iAmmo);

				int hClientWeapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
				int TankTurret = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
				//new wepindex = (IsValidEdict(hClientWeapon) && GetEntProp(hClientWeapon, Prop_Send, "m_iItemDefinitionIndex"));
				char classname[64];
				if (IsValidEdict(hClientWeapon)) GetEdictClassname(hClientWeapon, classname, sizeof(classname));
				
				if (StrEqual(classname, "tf_weapon_wrench", false) || StrEqual(classname, "tf_weapon_robot_arm", false))
				{
					if (iTankHealth[victim] > 0 && iTankHealth[victim] < iTankMaxHealth)
					{
						if (iCurrentMetal < repairamount) repairamount = iCurrentMetal;

						if ((iTankMaxHealth-iTankHealth[victim] < repairamount*mult))
						{
							repairamount = RoundToCeil(float((iTankMaxHealth-iTankHealth[victim])/mult));
						}

						if (repairamount < 1 && iCurrentMetal > 0) repairamount = 1;

						iTankHealth[victim] += repairamount*mult;

						if (iTankHealth[victim] > iTankMaxHealth) iTankHealth[victim] = iTankMaxHealth;

						iCurrentMetal -= repairamount;
						SetEntProp(attacker, Prop_Data, "m_iAmmo", iCurrentMetal, 4, 3);
					}
					if (GetWeaponClip(TankTurret) >= 0 && GetWeaponClip(TankTurret) < m_nMaxTurretMunitions)
					{
						if (iCurrentMetal < repairamount) repairamount = iCurrentMetal;
						if ((m_nMaxTurretMunitions-GetWeaponClip(TankTurret) < repairamount*mult))
						{
							repairamount = RoundToCeil(float((m_nMaxTurretMunitions-GetWeaponClip(TankTurret))/mult));
						}
						if (repairamount < 1 && iCurrentMetal > 0) repairamount = 1;

						SetWeaponClip(TankTurret, GetWeaponClip(TankTurret)+repairamount*mult);

						if (GetWeaponClip(TankTurret) > m_nMaxTurretMunitions)
							SetWeaponClip(TankTurret, m_nMaxTurretMunitions);

						iCurrentMetal -= repairamount;
						SetEntProp(attacker, Prop_Data, "m_iAmmo", iCurrentMetal, 4, 3);
					}
				}
			}
		}
		else return Plugin_Continue;
	}
	return Plugin_Continue;
}

///////////////////////
/////////stocks////////
///////////////////////
stock int GetHealingTarget(int client)
{
	char s[64];
	int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if (!IsValidEdict(medigun) || !IsValidEntity(medigun)) return -1;
	GetEdictClassname(medigun, s, sizeof(s));
	if (strcmp(s, "tf_weapon_medigun", false) == 0)
	{
		if (GetEntProp(medigun, Prop_Send, "m_bHealing"))
			return GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
	}
	return -1;
}
stock bool IsNearSpencer(int client)
{
	int medics = 0, healers = GetEntProp(client, Prop_Send, "m_nNumHealers");
	if (healers > 0)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && GetHealingTarget(i) == client)
				medics++;
		}
	}
	return ( (healers > medics) ? true : false );
}
stock int AttachParticle(int ent, char[] particleType, float offset = 0.0, bool battach = true)
{
	int particle = CreateEntityByName("info_particle_system");
	char tName[128];
	float pos[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	pos[2] += offset;
	TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
	Format(tName, sizeof(tName), "target%i", ent);
	DispatchKeyValue(ent, "targetname", tName);
	DispatchKeyValue(particle, "targetname", "tf2particle");
	DispatchKeyValue(particle, "parentname", tName);
	DispatchKeyValue(particle, "effect_name", particleType);
	DispatchSpawn(particle);
	SetVariantString(tName);
	if (battach)
	{
		AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		SetEntPropEnt(particle, Prop_Send, "m_hOwnerEntity", ent);
	}
	ActivateEntity(particle);
	AcceptEntityInput(particle, "start");
	CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(particle));
	return particle;
}
stock int ShootRocket(int client, float vPosition[3], float vAngles[3] = NULL_VECTOR, float flSpeed, float dmg)
{
	//new String:strEntname[45] = "tf_projectile_spellfireball";
	/*switch (spell)
	{
		case FIREBALL: 		strEntname = "tf_projectile_spellfireball";
		case LIGHTNING: 	strEntname = "tf_projectile_lightningorb";
		case PUMPKIN: 		strEntname = "tf_projectile_spellmirv";
		case PUMPKIN2: 		strEntname = "tf_projectile_spellpumpkin";
		case BATS: 			strEntname = "tf_projectile_spellbats";
		case METEOR: 		strEntname = "tf_projectile_spellmeteorshower";
		case TELE: 			strEntname = "tf_projectile_spelltransposeteleport";
		case BOSS:			strEntname = "tf_projectile_spellspawnboss";
		case ZOMBIEH:		strEntname = "tf_projectile_spellspawnhorde";
		case ZOMBIE:		strEntname = "tf_projectile_spellspawnzombie";
	}
	switch(spell)
	{
		//These spells have arcs.
		case BATS, METEOR, TELE:
		{
			vVelocity[2] += 32.0;
		}
	}

CTFGrenadePipebombProjectile m_bCritical
CTFProjectile_Rocket m_bCritical
CTFProjectile_SentryRocket m_bCritical
CTFWeaponBaseGrenadeProj m_bCritical
CTFMinigun m_bCritShot
CTFFlameThrower m_bCritFire
CTFProjectile_Syringe
CTFPlayer m_iCritMult
SetEntPropFloat(iProjectile, Prop_Send, "m_flDamage", dmg);
	}*/
	int iTeam = GetClientTeam(client);
	int iProjectile = CreateEntityByName("tf_projectile_rocket");
	
	if (!IsValidEdict(iProjectile)) return -1;

	float vVelocity[3];
	GetAngleVectors(vAngles, vVelocity, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(vVelocity, vVelocity);
	ScaleVector(vVelocity, flSpeed);
	
	SetEntPropEnt(iProjectile, Prop_Send, "m_hOwnerEntity", client);
	SetEntProp(iProjectile,    Prop_Send, "m_bCritical", 0);
	SetEntProp(iProjectile,    Prop_Send, "m_iTeamNum", iTeam, 1);
	SetEntProp(iProjectile,    Prop_Send, "m_nSkin", (iTeam-2));

	SetVariantInt(iTeam);
	AcceptEntityInput(iProjectile, "TeamNum", -1, -1, 0);
	SetVariantInt(iTeam);
	AcceptEntityInput(iProjectile, "SetTeam", -1, -1, 0);
	SetEntDataFloat(iProjectile, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, dmg, true);
	TeleportEntity(iProjectile, vPosition, vAngles, vVelocity); 
	DispatchSpawn(iProjectile);
	return iProjectile;
}

public int OnPreThink(int client) //powers the HUD
{
	if (bIsTank[client])
	{
		if ( IsPlayerAlive(client) ) SetEntityHealth(client, iTankHealth[client]);
		if ( GetConVarBool(bGasPowered) )
		{
			if ( IsNearSpencer(client) )
			{
				flGasMeter[client] += 0.1;
				if (flGasMeter[client] > GetConVarFloat(StartingFuel)) flGasMeter[client] = GetConVarFloat(StartingFuel);
			}
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && client == GetHealingTarget(i))
				{
					flGasMeter[client] += 0.1;
					if (flGasMeter[client] > GetConVarFloat(StartingFuel)) flGasMeter[client] = GetConVarFloat(StartingFuel);
				}
			}
			UpdateGasHUD(client);
		}
		//SetEntPropVector(client, Prop_Send, "m_vecMaxs", Float:{24.0,24.0,10.0} );
		//SetEntPropVector(client, Prop_Send, "m_vecSpecifiedSurroundingMins", Float:{-30.0,-30.0,0.0} ); // nullify bounding box
        	//SetEntPropVector(client, Prop_Send, "m_vecSpecifiedSurroundingMaxs", Float:{30.0,30.0,37.5} );
		//GetEntProp(client, Prop_Send, "m_iMaxHealth");
	}
	return;
}
public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if ( !GetConVarBool(bEnabled) || (damagetype & DMG_CRIT) ) return Plugin_Continue;

	float Pos[3], Pos2[3];
	GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", Pos);//Spot of attacker
	GetEntPropVector(victim, Prop_Send, "m_vecOrigin", Pos2); //Spot of victim
	float dist = GetVectorDistance(Pos, Pos2, false); //Calculate dist between target and attacker
	float min = 512.0;
	char classname[64], strEntname[32];

	if (IsValidEdict(inflictor)) GetEntityClassname(inflictor, strEntname, sizeof(strEntname));
	if (IsValidEdict(weapon)) GetEdictClassname(weapon, classname, sizeof(classname));

	if (bIsTank[victim])
	{
		if ( (victim == attacker && GetConVarBool(NoTankRocketJump)) || damagecustom == TF_CUSTOM_BACKSTAB )
		{
			damage = 0.0;
			return Plugin_Changed;
		}
		if (attacker > MaxClients || attacker <= 0)
		{
			char stringmap[64];
			if (GetEdictClassname(attacker, stringmap, sizeof(stringmap)) && strcmp(stringmap, "trigger_hurt", false) == 0)
			{
				iTankHealth[victim] = 0;
				TF2_IgnitePlayer(victim, attacker);
				CreateTimer(0.1, TimerTankDeath, GetClientUserId(victim));
			}
		}
	}
	else if (bIsTank[attacker])
	{
		if (victim != attacker && GetClientTeam(victim) != GetClientTeam(attacker))
		{
			if (strcmp(strEntname, "tf_projectile_rocket", false) == 0 && GetConVarBool(NoFallOffRockets))
			{
				if (dist > 966) dist = 966.0;
				if (dist < 409) dist = 409.6;
				damage *= dist/min;
				return Plugin_Changed;
			}
			if (strcmp(classname, "tf_weapon_smg", false) == 0 && GetConVarBool(NoFallOffTurret))
			{
				if (dist > 1024) dist = 1024.0;
				if (dist < 341) dist = 341.33;
				damage *= dist/min;
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}
public Action OnTouch(int client, int other) //simulates "crush" damage
{
	if (bIsTank[client])
	{
		if (other > 0 && other <= MaxClients)
		{
			int buttons = GetClientButtons(client);
			if ( buttons & (IN_FORWARD|IN_BACK|IN_MOVELEFT|IN_MOVERIGHT) )
			{
				flLastHit[other] = GetGameTime();
				SDKHooks_TakeDamage(other, client, client, GetConVarFloat(CrushDmg), DMG_CRUSH|DMG_ALWAYSGIB);
			}
		}
		else if (other > MaxClients)
		{
			if (IsValidEntity(other))
			{
				char ent[5];
				GetEdictClassname(other, ent, sizeof(ent));
				if (GetEntityClassname(other, ent, sizeof(ent)), StrContains(ent, "obj_") == 0)
				{
					//SetVariantInt(GetEntProp(other, Prop_Send, "m_iMaxHealth")+1);
					if (GetEntProp(other, Prop_Send, "m_iTeamNum") != GetClientTeam(client))
					{
						SetVariantInt(RoundToCeil(GetConVarFloat(CrushDmg)));
						AcceptEntityInput(other, "RemoveHealth");
					}
				}
			}
		}
	}
	return Plugin_Continue;
}