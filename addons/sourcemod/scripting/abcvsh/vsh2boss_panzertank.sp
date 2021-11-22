#include <sdktools>
#include <tf2_stocks>
#include <sdkhooks>
#include <vsh2>
#include <morecolors>

#pragma semicolon 1
#pragma newdecls required


public Plugin myinfo = {
	name           = "VSH2 - Tank", 
	author         = "Scag & Assyrian/Nergal", 
	description    = "VSH2 Boss Tank", 
	version        = "1.0.0", 
	url            = ""
};

int g_iTankIndex;

public void OnLibraryAdded(const char[] name)
{
	if( StrEqual(name, "VSH2", true) ) {
		g_iTankIndex = VSH2_RegisterPlugin("vsh2_panzertank");
		
		VSH2_Hook(OnCallDownloads, Tank_OnDownloadsCalled);
		VSH2_Hook(OnBossSelected, Tank_BossSelected);
		VSH2_Hook(OnBossThink, Tank_OnBossThink);
		VSH2_Hook(OnBossModelTimer, Tank_OnBossModelTimer);
		VSH2_Hook(OnBossEquipped, Tank_OnBossEquipped);
		VSH2_Hook(OnBossInitialized, Tank_OnBossInitialized);
		VSH2_Hook(OnBossPlayIntro, Tank_OnBossPlayIntro);
		//VSH2_Hook(OnBossTaunt, Tank_OnBossTaunt);
		VSH2_Hook(OnMusic, Tank_OnMusic);
		VSH2_Hook(OnBossMenu, Tank_OnBossMenu);
		VSH2_Hook(OnPlayerKilled, Tank_OnPlayerKilled);
		VSH2_Hook(OnTouchPlayer, Tank_OnTouchPlayer);
		VSH2_Hook(OnTouchBuilding, Tank_OnTouchBuilding);
		VSH2_Hook(OnVariablesReset, Tank_OnVariablesReset);
		VSH2_Hook(OnBossTakeDamage, Tank_OnBossTakeDamage);
		VSH2_Hook(OnBossDealDamage, Tank_OnBossDealDamage);
		VSH2_Hook(OnPlayerAirblasted, Tank_OnPlayerAirblasted);
		VSH2_Hook(OnBossDeath, Tank_OnBossDeath);
		VSH2_Hook(OnRoundEndInfo, Tank_OnRoundEndInfo);
	}
}


/// thx to Friagram for saving teh day!
#define TankModel           "models/custom/tanks/panzer.mdl"

#define TankReload          "acvshtank/reload.mp3"
#define TankCrush           "acvshtank/vehicle_hit_person.mp3"
#define TankMove            "acvshtank/tankdrive.mp3"
#define TankIdle            "acvshtank/tankidle.mp3"

#define ROCKET_DMG           100.0
#define TANK_ACCELERATION    7.0
#define TANK_SPEEDMAX        260.0
#define TANK_SPEEDMAXREV     240.0
#define TANK_INITSPEED       180.0
#define SMG_DAMAGE_MULT      1.25

char TankSpawn[][] = {
	"acvshtank/spawn1.mp3",
	"acvshtank/spawn2.mp3",
	"acvshtank/spawn3.mp3"
};

char TankDeath[][] = {
	"acvshtank/dead1.mp3",
	"acvshtank/dead2.mp3",
};

char TankShoot[][] = {
	"acvshtank/fire1.mp3",
	"acvshtank/fire2.mp3",
	"acvshtank/fire3.mp3"
};

char TankThemes[][] = {
	"acvshtank/theme1.mp3",
	"acvshtank/theme2.mp3"
};

float TankThemeTime[] = {
	225.0, 313.0
};

char VehicleHorns[][] = {
	"acvshtank/awooga.mp3",
	"acvshtank/dukesofhazzard.mp3",
	"acvshtank/lacucaracha.mp3",
	"acvshtank/twohonks.mp3"
};


enum struct TankData {
	float m_flMoveTime;
	float m_flIdleTime;
}

TankData g_tank_data[MAXPLAYERS+1];

methodmap CTank < VSH2Player {
	public CTank(const int index, bool userid=false) {
		return view_as< CTank >(VSH2Player(index, userid));
	}
	
	property bool bUsedUltimate {
		public get() {
			return this.GetPropAny("bUsedUltimate");
		}
		public set(bool val) {
			this.SetPropAny("bUsedUltimate", val);
		}
	}
	
	property float flSpeed {
		public get() {
			return this.GetPropFloat("flSpeed");
		}
		public set(float val) {
			this.SetPropFloat("flSpeed", val);
		}
	}
	
	property float flLastShot {
		public get() {
			return this.GetPropFloat("flLastShot");
		}
		public set(float val) {
			this.SetPropFloat("flLastShot", val);
		}
	}
	
	property float flMoveTime {
		public get() {
			return g_tank_data[this.index].m_flMoveTime;
		}
		public set(float val) {
			g_tank_data[this.index].m_flMoveTime = val;
		}
	}
	
	property float flIdleTime {
		public get() {
			return g_tank_data[this.index].m_flIdleTime;
		}
		public set(float val) {
			g_tank_data[this.index].m_flIdleTime = val;
		}
	}
}

public CTank ToCTank(VSH2Player p) {
	return view_as< CTank >(p);
}

public bool IsTank(VSH2Player p) {
	return p.GetPropInt("iBossType")==g_iTankIndex;
}


public void Tank_OnDownloadsCalled()
{
	char s[PLATFORM_MAX_PATH];
	PrepareModel(TankModel);
	PrepareMaterial("materials/models/custom/tanks/panzer");
	PrepareMaterial("materials/models/custom/tanks/panzer_blue");
	PrepareMaterial("materials/models/custom/tanks/panzer_track");
	PrepareMaterial("materials/models/custom/tanks/pziv_ausfg");
//	PrepareMaterial("materials/models/custom/tanks/pziv_ausfg_nm");
//	PrepareMaterial("materials/models/custom/tanks/pziv_ausfg_red");
	PrepareMaterial("materials/models/custom/tanks/hummel_track");
	PrepareMaterial("materials/models/custom/tanks/hummel_track_nm");
	for( int i=1; i<=5; i++ ) {
		Format(s, PLATFORM_MAX_PATH, "weapons/fx/rics/ric%i.wav", i);
		PrecacheSound(s);
	}
	DownloadSoundList(TankShoot, sizeof(TankShoot));
	DownloadSoundList(TankSpawn, sizeof(TankSpawn));
	DownloadSoundList(TankDeath, sizeof(TankDeath));
	PrepareSound(TankReload);
	PrepareSound(TankCrush);
	PrepareSound(TankMove);
	PrepareSound(TankIdle);
	
	PrecacheGeneric("fireSmoke_collumn_mvmAcres");
	PrecacheSound("misc/doomsday_missile_explosion.wav", true);
	PrecacheSound("mvm/ambient_mp3/mvm_siren.mp3", true);
	
	DownloadSoundList(TankThemes, sizeof(TankThemes));
	DownloadSoundList(VehicleHorns, sizeof(VehicleHorns));
}

public void Tank_BossSelected(const VSH2Player player)
{
	if( !IsTank(player) || IsVoteInProgress() )
		return;
	
	Panel panel = new Panel();
	panel.SetTitle("The Military Tank:\nSMG/Missile: Left-Click to shoot bullets, right-click to shoot rockets.\nWall Walking: Walk to and look at walls to climb them.\nMouse 3: Honks horn!");
	panel.DrawItem("Exit");
	panel.Send(player.index, PANEL, 10);
	delete panel;
	
	CTank tanker = ToCTank(player);
	tanker.flMoveTime = 0.0;
}
public int PANEL(Menu menu, MenuAction action, int client, int select)
{
	return;
}

public void Tank_OnBossThink(const VSH2Player player)
{
	if( !IsTank(player) || !IsPlayerAlive(player.index) )
		return;
	
	int client = player.index;
	int wep = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if( wep != -1 )
		SetWeaponAmmo(wep, 255);
	
	int buttons = GetClientButtons(client);
	float vell[3]; GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vell);
	float currtime = GetGameTime();
	
	VSH2_GlowThink(player, 0.1);
	CTank tanker = ToCTank(player);
	
	/** simulates vehicular physics; not as good as Valve does with vehicle entities though */
	if( (buttons & IN_FORWARD) && vell[0] != 0.0 && vell[1] != 0.0 ) {
		StopSound(client, SNDCHAN_AUTO, TankIdle);
		tanker.flSpeed += TANK_ACCELERATION;
		
		if( tanker.flSpeed > TANK_SPEEDMAX )
			tanker.flSpeed = TANK_SPEEDMAX;
		
		if( tanker.flIdleTime != 0.0 )
			tanker.flIdleTime = 0.0;
		if( tanker.flMoveTime < currtime ) {
			EmitSoundToAll(TankMove, client, SNDCHAN_AUTO);
			tanker.flMoveTime = currtime+31.0;
		}
	} else if( (buttons & IN_BACK) && vell[0] != 0.0 && vell[1] != 0.0 ) {
		StopSound(client, SNDCHAN_AUTO, TankIdle);
		tanker.flSpeed += TANK_ACCELERATION;
		if( tanker.flSpeed > TANK_SPEEDMAXREV )
			tanker.flSpeed = TANK_SPEEDMAXREV;
		
		if( tanker.flIdleTime != 0.0 )
			tanker.flIdleTime = 0.0;
		if( tanker.flMoveTime < currtime ) {
			//strcopy(snd, PLATFORM_MAX_PATH, TankMove);
			EmitSoundToAll(TankMove, client, SNDCHAN_AUTO);
			tanker.flMoveTime = currtime+31.0;
		}
	} else {
		StopSound(client, SNDCHAN_AUTO, TankMove);
		if( tanker.flMoveTime != 0.0 )
			tanker.flMoveTime = 0.0;
		if( tanker.flIdleTime < currtime ) {
			//strcopy(snd, PLATFORM_MAX_PATH, TankIdle);
			EmitSoundToAll(TankIdle, client, SNDCHAN_AUTO);
			tanker.flIdleTime = currtime+5.0;
		}
		
		tanker.flSpeed -= TANK_ACCELERATION;
		if( tanker.flSpeed < TANK_INITSPEED )
			tanker.flSpeed = TANK_INITSPEED;
	}
	SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", tanker.flSpeed);
	
	VSH2_WeighDownThink(player, 10.0, 0.25);
	
	SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
	Handle hud = VSH2GameMode_GetHUDHandle();
	ShowSyncHudText(client, hud, "Walk on walls | M2 to fire rocket");
	
	if( buttons & IN_FORWARD )
		tanker.ClimbWall(GetActiveWep(tanker.index), 350.0, 0.0, false);
	
	if( (buttons & IN_ATTACK2) ) {
		if( tanker.flLastShot < currtime ) {
			tanker.flLastShot = currtime+4.0;
			float vPosition[3], vAngles[3], vVec[3];
			GetClientEyePosition(client, vPosition);
			GetClientEyeAngles(client, vAngles);
			
			vVec[0] = Cosine( DegToRad(vAngles[1]) ) * Cosine( DegToRad(vAngles[0]) );
			vVec[1] = Sine( DegToRad(vAngles[1]) ) * Cosine( DegToRad(vAngles[0]) );
			vVec[2] = -Sine( DegToRad(vAngles[0]) );
			
			vPosition[0] += vVec[0] * 50.0;
			vPosition[1] += vVec[1] * 50.0;
			vPosition[2] += vVec[2] * 50.0;
			bool crit = ( TF2_IsPlayerInCondition(client, TFCond_Kritzkrieged) || TF2_IsPlayerInCondition(client, TFCond_CritOnWin) );
			TE_SetupMuzzleFlash(vPosition, vAngles, 9.0, 1);
			TE_SendToAll();
			tanker.ShootRocket(crit, vPosition, vAngles, 4000.0, ROCKET_DMG, "");
			
			/// sounds from Call of Duty 1
			player.PlayVoiceClip(TankShoot[GetRandomInt(0, sizeof(TankShoot)-1)], VSH2_VOICE_ABILITY);
			/// useless, only plays a 'reload' sound.
			CreateTimer(1.0, Timer_ReloadTank, tanker.userid, TIMER_FLAG_NO_MAPCHANGE);
			
			float PunchVec[3] = {100.0, 0.0, 90.0};
			SetEntPropVector(client, Prop_Send, "m_vecPunchAngleVel", PunchVec);
		}
	}
}

public void Tank_OnBossModelTimer(const VSH2Player player)
{
	if( !IsTank(player) )
		return;
	
	SetVariantString(TankModel);
	AcceptEntityInput(player.index, "SetCustomModel");
	SetEntProp(player.index, Prop_Send, "m_bUseClassAnimations", 1);
}
public void Tank_OnBossEquipped(const VSH2Player player)
{
	if( !IsTank(player) )
		return;
	
	player.RemoveAllItems();
	player.SetName("The Military Tank");
	//SetEntProp(player.index, Prop_Send, "m_bForcedSkin", 1);
	//SetEntProp(player.index, Prop_Send, "m_nForcedSkin", 1);
	char attribs[256];
	Format(attribs, sizeof(attribs), "6 ; 0.6; 326 ; 0.0; 252 ; 0.0; 66 ; 0.5; 25 ; 0.0; 53 ; 1.0; 59 ; 0.0; 60 ; 0.8; 65 ; 1.4; 62 ; 0.71; 4 ; 4.0; 99 ; 2.0; 521 ; 1.0; 68 ; 2.0; 214 ; %d; 2 ; %f", GetRandomInt(999, 9999), SMG_DAMAGE_MULT);
	
	CTank tanker = ToCTank(player);
	int turret = tanker.SpawnWeapon("tf_weapon_smg", 16, 100, 5, attribs);
	SetEntPropEnt(tanker.index, Prop_Send, "m_hActiveWeapon", turret);
	SetWeaponAmmo(turret, 256);
	tanker.SetWepInvis(150);
	tanker.SetOverlay("effects/combine_binocoverlay");
	tanker.flMoveTime = 0.0;
	tanker.flIdleTime = 0.0;
	tanker.bUsedUltimate = false;
}
public void Tank_OnBossInitialized(const VSH2Player player)
{
	if( !IsTank(player) )
		return;
		
	TF2_SetPlayerClass(player.index, TFClass_Pyro, _, false);
}
public void Tank_OnBossPlayIntro(const VSH2Player player)
{
	if( !IsTank(player) )
		return;
	
	//EmitSoundToAll("mvm/mvm_tank_horn.wav");
	player.PlayVoiceClip(TankSpawn[GetRandomInt(0, sizeof(TankSpawn)-1)], VSH2_VOICE_INTRO);
}

/*
public void Tank_OnBossTaunt(const VSH2Player player)
{
	if( !IsTank(player) )
		return;
	
	int client = player.index;
	TF2_AddCondition(client, view_as<TFCond>(42), 4.0);
	if( !GetEntProp(client, Prop_Send, "m_bIsReadyToHighFive")
		&& !IsValidEntity(GetEntPropEnt(client, Prop_Send, "m_hHighFivePartner")) )
	{
		TF2_RemoveCondition(client, TFCond_Taunting);
		Tank_OnBossModelTimer(player);
	}
	player.bUsedUltimate = true;
	EmitSoundToAll("mvm/ambient_mp3/mvm_siren.mp3");
}
*/

public void Tank_OnMusic(char song[PLATFORM_MAX_PATH], float &time, const VSH2Player player)
{
	if( !IsTank(player) )
		return;
	
	int theme = GetRandomInt(0, sizeof(TankThemes)-1);
	Format(song, sizeof(song), "%s", TankThemes[theme]);
	time = TankThemeTime[theme];
}

public void Tank_OnBossMenu(Menu& menu)
{
	char tostr[10]; IntToString(g_iTankIndex, tostr, sizeof(tostr));
	menu.AddItem(tostr, "The Military Tank (Vehicle Boss)");
}

public void Tank_OnPlayerKilled(const VSH2Player Attacker, const VSH2Player Victim, Event event)
{
	if( !IsTank(Attacker) || !IsPlayerAlive(Attacker.index) || Victim.index == Attacker.index )
		return;
	
	int dmgbits = event.GetInt("damagebits");
	if( dmgbits & (DMG_ALWAYSGIB) ) {
		event.SetString("weapon", "purgatory");
		event.SetInt("customkill", TF_WEAPON_ROCKETLAUNCHER);
	} else if( dmgbits & DMG_VEHICLE ) {
		event.SetString("weapon_logclassname", "vehicle_crush");
		event.SetString("weapon", "mantreads");
		//event.SetInt("customkill", TF_CUSTOM_TRIGGER_HURT);
		//event.SetInt("playerpenetratecount", 0);
		Attacker.PlayVoiceClip(TankCrush, VSH2_VOICE_SPREE);
	}
}
public void Tank_OnBossDeath(const VSH2Player player)
{
	if( !IsTank(player) )
		return;
	
	StopSound(player.index, SNDCHAN_AUTO, TankIdle);
	StopSound(player.index, SNDCHAN_AUTO, TankMove);
	player.SetOverlay("0");
	
	CTank tanker = ToCTank(player);
	tanker.flMoveTime = 0.0;
	tanker.flIdleTime = 0.0;
	tanker.flLastShot = 0.0;
	tanker.bUsedUltimate = false;
	
	AttachParticle(player.index, "buildingdamage_dispenser_fire1", 1.0);
	tanker.PlayVoiceClip(TankDeath[GetRandomInt(0, sizeof(TankDeath)-1)], VSH2_VOICE_LOSE);
}

public void Tank_OnRoundEndInfo(const VSH2Player player, bool boss_won, char message[MAXMESSAGE])
{
	if( !IsTank(player) )
		return;
	
	if( boss_won )
		player.PlayVoiceClip(VehicleHorns[GetRandomInt(0, sizeof(VehicleHorns)-1)], VSH2_VOICE_WIN);
}


public Action Tank_OnBossTakeDamage(const VSH2Player victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if( !IsTank(victim) )
		return Plugin_Continue;
	
	/// vehicles shouldn't be able to hurt themselves
	if( victim.index == attacker ) {
		damage *= 0.0;
	} else if( damagetype & (DMG_BULLET|DMG_CLUB|DMG_SLASH) ) {
		TE_SetupArmorRicochet(damagePosition, NULL_VECTOR);
		TE_SendToAll();
		char sound[PLATFORM_MAX_PATH];
		Format(sound, PLATFORM_MAX_PATH, "weapons/fx/rics/ric%i.wav", GetRandomInt(1, 5));
		EmitSoundToAll(sound, victim.index);
		EmitSoundToAll(sound, victim.index);
	}
	damagetype |= DMG_PREVENT_PHYSICS_FORCE;
	return Plugin_Changed;
}

public void Tank_OnPlayerAirblasted(const VSH2Player airblaster, const VSH2Player airblasted, Event event)
{
	if( !IsTank(airblasted) )
		return;
	
	float Vel[3];
	TeleportEntity(airblasted.index, NULL_VECTOR, NULL_VECTOR, Vel); /// Stops knockback
	TF2_RemoveCondition(airblasted.index, TFCond_Dazed); /// Stops slowdown
	SetEntPropVector(airblasted.index, Prop_Send, "m_vecPunchAngle", Vel);
	SetEntPropVector(airblasted.index, Prop_Send, "m_vecPunchAngleVel", Vel); /// Stops screen shake
}

public Action Tank_OnBossDealDamage(const VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VSH2Player fighter = VSH2Player(attacker);
	if( !IsTank(fighter) )
		return Plugin_Continue;
		
	if( damagetype & DMG_BLAST ) {
		TF2_AddCondition(victim.index, TFCond_LostFooting, 1.5, attacker);
		float Pos[3], Pos2[3];
		GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", Pos);
		GetEntPropVector(victim.index, Prop_Send, "m_vecOrigin", Pos2);
		float dist = GetVectorDistance(Pos, Pos2, false);
		if( dist > 966 )
			dist = 966.0;
		if( dist < 409 )
			dist = 409.6;
		damage *= dist/512.0;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	Action action = Plugin_Continue;
	VSH2Player player = VSH2Player(client);
	if( !player.GetPropAny("bIsBoss") || !IsTank(player) )
		return action;
	
	CTank base = ToCTank(player);
	int vehflags = GetEntityFlags(client);
	if( (buttons & IN_MOVELEFT) && (vehflags & FL_ONGROUND) ) {
		//angles[1] += 7.0;
		buttons &= ~IN_MOVELEFT;
		vel[1] = 1.0;
		action = Plugin_Changed;
	}
	if( (buttons & IN_MOVERIGHT) && (vehflags & FL_ONGROUND) ) {
		//angles[1] -= 7.0;
		buttons &= ~IN_MOVERIGHT;
		vel[1] = 1.0;
		action = Plugin_Changed;
	}
	
	/// novelty horn honking! It's the small details that really add to a mod :)
	if( (buttons & IN_ATTACK3) ) {
		if( !base.bUsedUltimate ) {
			base.bUsedUltimate = true;
			EmitSoundToAll(VehicleHorns[GetRandomInt(0, sizeof(VehicleHorns)-1)], client);
			SetPawnTimer(_ResetHorn, 4.0, base);
		}
	}
	
	/// Vehicles shouldn't be able to duck
	if( (buttons & IN_DUCK) && (vehflags & FL_ONGROUND) ) {
		buttons &= ~IN_DUCK;
		action = Plugin_Changed;
	}
	return action;
}

public void Tank_OnTouchPlayer(const VSH2Player boss, const VSH2Player victim)
{
	if( !IsTank(boss) )
		return;
	
	/// If human/vehicle on vehicle, ignore.
	else if( GetEntPropEnt(victim.index, Prop_Send, "m_hGroundEntity") == boss.index )
		return;
	
	/// Vehicle is standing on player, kill them!
	if( GetEntPropEnt(boss.index, Prop_Send, "m_hGroundEntity") == victim.index )
		SDKHooks_TakeDamage(victim.index, boss.index, boss.index, 500.0, DMG_VEHICLE);
	
	float vecShoveDir[3]; GetEntPropVector(boss.index, Prop_Data, "m_vecAbsVelocity", vecShoveDir);
	if( vecShoveDir[0] != 0.0 && vecShoveDir[1] != 0.0 ) {
		float entitypos[3]; GetEntPropVector(boss.index, Prop_Data, "m_vecAbsOrigin", entitypos);
		float targetpos[3]; GetEntPropVector(victim.index, Prop_Data, "m_vecAbsOrigin", targetpos);
		float vecTargetDir[3];
		vecTargetDir = Vec_SubtractVectors(entitypos, targetpos);
		vecShoveDir = Vec_NormalizeVector(vecShoveDir);
		vecTargetDir = Vec_NormalizeVector(vecTargetDir);
		
		if( GetVectorDotProduct(vecShoveDir, vecTargetDir) <= 0 )
			SDKHooks_TakeDamage(victim.index, boss.index, boss.index, 30.0, DMG_VEHICLE);
	}
}

public void Tank_OnTouchBuilding(const VSH2Player player, int building)
{
	if( !IsTank(player) )
		return;
	
	SDKHooks_TakeDamage(building, player.index, player.index, 5.0, DMG_VEHICLE);
}

public void Tank_OnVariablesReset(const VSH2Player player)
{
	StopSound(player.index, SNDCHAN_AUTO, TankIdle);
	StopSound(player.index, SNDCHAN_AUTO, TankMove);
}

public void TF2_OnConditionAdded(int client, TFCond cond)
{
	if( IsTank(VSH2Player(client)) ) {
		switch( cond ) {
			/** vehicles shouldn't bleed or be flammable */
			case TFCond_Bleeding, TFCond_OnFire, TFCond_Jarated: {
				TF2_RemoveCondition(client, cond);
				VSH2Player(client).SetOverlay("effects/combine_binocoverlay");
			}
		}
	}
}


public void _ResetHorn(const CTank client)
{
	if( IsClientValid(client.index) )
		client.bUsedUltimate = false;
}
public Action Timer_ReloadTank(Handle hTimer, any userid)
{
	int client = GetClientOfUserId(userid);
	VSH2Player tanker = VSH2Player(client);
	if( !IsTank(tanker) )
		return Plugin_Continue;
	if( client > 0 && IsClientInGame(client) )
		tanker.PlayVoiceClip(TankReload, VSH2_VOICE_ABILITY);
	return Plugin_Continue;
}

public bool WorldOnly(int entity, int contentsMask, any iExclude) {
	return entity <= 0;
}

public Action RemoveEnt(Handle timer, any entid) {
	int ent = EntRefToEntIndex(entid);
	if( ent > 0 && IsValidEntity(ent) )
		AcceptEntityInput(ent, "Kill");
	return Plugin_Continue;
}

public Action DeleteShake(Handle timer, any ref)
{
	int iEntity = EntRefToEntIndex(ref); 
	if( iEntity > MaxClients ) {
		AcceptEntityInput(iEntity, "Kill"); 
		AcceptEntityInput(iEntity, "StopShake");
	}
	return Plugin_Handled;
}

public void ShowParticle(float pos[3], char[] particlename, float time)
{
	int particle = CreateEntityByName("info_particle_system");
	if( IsValidEdict(particle) ) {
		TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(particle, "effect_name", particlename);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		CreateTimer(time, DeleteParticles, EntIndexToEntRef(particle));
	}
}
public Action DeleteParticles(Handle timer, any particle)
{
	int ent = EntRefToEntIndex(particle);
	if( ent != INVALID_ENT_REFERENCE ) {
		char classname[64]; GetEdictClassname(ent, classname, sizeof(classname));
		if( StrEqual(classname, "info_particle_system", false) )
			AcceptEntityInput(ent, "kill");
	}
}
stock int SetWeaponAmmo(const int weapon, const int ammo)
{
	int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if( owner <= 0 )
		return 0;
	if( IsValidEntity(weapon) ) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(owner, iAmmoTable+iOffset, ammo, 4, true);
	}
	return 0;
}
stock void SetPawnTimer(Function func, float thinktime = 0.1, any param1 = -999, any param2 = -999)
{
	DataPack thinkpack = new DataPack();
	thinkpack.WriteFunction(func);
	thinkpack.WriteCell(param1);
	thinkpack.WriteCell(param2);
	CreateTimer(thinktime, DoThink, thinkpack, TIMER_DATA_HNDL_CLOSE);
}

public Action DoThink(Handle hTimer, DataPack hndl)
{
	hndl.Reset();
	Function pFunc = hndl.ReadFunction();
	Call_StartFunction( null, pFunc );
	
	any param1 = hndl.ReadCell();
	if( param1 != -999 )
		Call_PushCell(param1);
	
	any param2 = hndl.ReadCell();
	if( param2 != -999 )
		Call_PushCell(param2);
	
	Call_Finish();
	return Plugin_Continue;
}

stock float[] Vec_SubtractVectors(const float vec1[3], const float vec2[3])
{
	float result[3]; SubtractVectors(vec1, vec2, result);
	return result;
}
stock float[] Vec_AddVectors(const float vec1[3], const float vec2[3])
{
	float result[3]; AddVectors(vec1, vec2, result);
	return result;
}
stock float[] Vec_ScaleVector(const float vec[3], const float scale)
{
	float result[3];
	result[0] = vec[0] * scale;
	result[1] = vec[1] * scale;
	result[2] = vec[2] * scale;
	return result;
}
stock float[] Vec_NegateVector(const float vec[3])
{
	float result[3];
	result[0] = -vec[0];
	result[1] = -vec[1];
	result[2] = -vec[2];
	return result;
}
stock float[] Vec_GetVectorAngles(const float vec[3])
{
	float angResult[3]; GetVectorAngles(vec, angResult);
	return angResult;
}
stock float[] Vec_GetVectorCrossProduct(const float vec1[3], const float vec2[3])
{
	float result[3]; GetVectorCrossProduct(vec1, vec2, result);
	return result;
}
stock float[] Vec_MakeVectorFromPoints(const float pt1[3], const float pt2[3])
{
	float output[3]; MakeVectorFromPoints(pt1, pt2, output);
	return output;
}
stock float[] Vec_GetEntPropVector(const int entity, const PropType type, const char[] prop, int element=0)
{
	float output[3]; GetEntPropVector(entity, type, prop, output, element);
	return output;
}
stock float[] Vec_NormalizeVector(const float vec[3])
{
	float output[3]; NormalizeVector(vec, output);
	return output;
}
stock float[] Vec_GetAngleVecForward(const float angle[3])
{
	float output[3]; GetAngleVectors(angle, output, NULL_VECTOR, NULL_VECTOR);
	return output;
}
stock float[] Vec_GetAngleVecRight(const float angle[3])
{
	float output[3]; GetAngleVectors(angle, NULL_VECTOR, output, NULL_VECTOR);
	return output;
}
stock float[] Vec_GetAngleVecUp(const float angle[3])
{
	float output[3]; GetAngleVectors(angle, NULL_VECTOR, NULL_VECTOR, output);
	return output;
}
stock int AttachParticle(const int ent, const char[] particleType, float offset = 0.0, bool battach = true)
{
	int particle = CreateEntityByName("info_particle_system");
	char tName[32];
	float pos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	pos[2] += offset;
	TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
	Format(tName, sizeof(tName), "target%i", ent);
	DispatchKeyValue(ent, "targetname", tName);
	DispatchKeyValue(particle, "targetname", "tf2particle");
	DispatchKeyValue(particle, "parentname", tName);
	DispatchKeyValue(particle, "effect_name", particleType);
	DispatchSpawn(particle);
	SetVariantString(tName);
	if( battach ) {
		AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		SetEntPropEnt(particle, Prop_Send, "m_hOwnerEntity", ent);
	}
	ActivateEntity(particle);
	AcceptEntityInput(particle, "start");
	CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(particle));
	return particle;
}
stock void CreateParticles(char[] particlename, float Pos[3] = NULL_VECTOR, float time)
{
	int particle = CreateEntityByName("info_particle_system");
	if( IsValidEntity(particle) ) {
		DispatchKeyValue(particle, "effect_name", particlename);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		TeleportEntity(particle, Pos, NULL_VECTOR, NULL_VECTOR);
		CreateTimer(time, RemoveEnt, EntIndexToEntRef(particle));
	}
	else LogError("CreateParticles: **** Couldn't Create 'info_particle_system Entity' ****");
}
stock int GetActiveWep(const int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	return( IsValidEntity(weapon) ) ? weapon : -1;
}

stock bool IsClientValid(int client)
{
	 return 0 < client && client <= MaxClients && IsClientInGame(client) )
}
