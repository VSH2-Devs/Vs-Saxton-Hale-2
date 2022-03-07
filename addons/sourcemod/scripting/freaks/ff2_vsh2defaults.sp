/**
	Default Abilities Pack:

	Rages:
	rage_cbs_bowrage
	rage_cloneattack
	rage_explosive_dance
	rage_instant_teleport
	rage_tradespam
	rage_matrix_attack
	rage_new_weapon
	rage_overlay
	rage_stun
	rage_stunsg
	rage_uber

	Charges:
	special_democharge

	Specials:
	model_projectile_replace
	spawn_many_objects_on_death
	spawn_many_objects_on_kill
	special_cbs_multimelee
	special_dissolve
	special_dropprop
	special_noanims
*/

#define FF2_USING_AUTO_PLUGIN

#include <tf2_stocks>
#include <sdkhooks>
#include <morecolors>
#include <freak_fortress_2>
#include "../modules/ff2/formula_parser.sp"

#undef REQUIRE_PLUGIN
#tryinclude <smac>
#define REQUIRE_PLUGIN

#pragma semicolon 1
#pragma newdecls required

#define MAXCLIENTS MAXPLAYERS + 1
typedef AbilityPoolFn = function void(const FF2Player player);

static FF2GameMode ff2_gm;

enum struct _ConVars {
	ConVar sv_cheats;
	ConVar host_timescale;
	ConVar mp_friendlyfire;
	ConVar ff2_base_jumper_stun;
	ConVar ff2_strangewep;
	ConVar ff2_solo_shame;

	void Init() {
		this.sv_cheats				= FindConVar("sv_cheats");
		this.host_timescale			= FindConVar("host_timescale");
		this.mp_friendlyfire 		= FindConVar("mp_friendlyfire");
		this.ff2_base_jumper_stun 	= FindConVar("ff2_base_jumper_stun");
		this.ff2_strangewep 		= FindConVar("ff2_strangewep");
		this.ff2_solo_shame 		= FindConVar("ff2_solo_shame");
	}
}
_ConVars ConVars;


#define EXPLOSIVE_DANCE_ABILITY	"rage_explosive_dance"
enum struct _ExplosiveDance_t {
	int iNumExplosion;
	float flDamage;
	float flRange;

	void Init(FF2Player player)
	{
		if( player.HasAbility(this_plugin_name, EXPLOSIVE_DANCE_ABILITY) ) {
			this.iNumExplosion = player.GetArgI(this_plugin_name, EXPLOSIVE_DANCE_ABILITY, "count", 35);
			this.flDamage = player.GetArgF(this_plugin_name, EXPLOSIVE_DANCE_ABILITY, "damage", 180.0);
			this.flRange = player.GetArgF(this_plugin_name, EXPLOSIVE_DANCE_ABILITY, "distance", 350.0);
		}
	}
}
_ExplosiveDance_t ExplosiveDance[MAXCLIENTS];


#define NEW_WEAPON_ABILITY 		"rage_new_weapon"

#define STUN_ABILITY			"rage_stun"

#define STUN_BUILDING_ABILITY	"rage_stunsg"

#define UBER_ABILITY			"rage_uber"

#define CBS_BOW_ABILITY			"rage_cbs_bowrage"

#define CLONE_ATK_ABILITY 		"rage_cloneattack"

#define INSTANT_TELE_ABILITY 	"rage_instant_teleport"
enum struct _InstantTele_t
{
	int flags;
	float slowdown;
	float time;
}

#define TRADE_SPAWN_ABILITY 	"rage_tradespam"

#define MATRIX_ABILITY			"rage_matrix_attack"
#define SOUND_SLOW_MO_START		"replay/enterperformancemode.wav"
#define SOUND_SLOW_MO_END		"replay/exitperformancemode.wav"

enum struct _MatrixAbility_t {
	Handle timer;
	int iOldTarget;

	void InValidate()
	{
		this.timer = null;
		this.iOldTarget = 0;
	}

	bool Validate(int iCurTarget)
	{
		if( iCurTarget != this.iOldTarget ) {
			this.iOldTarget = iCurTarget;
			return true;
		}
		return false;
	}
}
_MatrixAbility_t ma_data;

#define OVERLAY_ABILITY			"rage_overlay"

#define DEMOCHARGE_ABILITY		"special_democharge"
enum struct _DemoCharge_t {
	bool bThinkHooked;
	float flNextThink[MAXCLIENTS];
}
_DemoCharge_t democharge;


/// Specials
#define PROJECTILE_ABILITY 		"model_projectile_replace"
#define OBJECTS_DEATH			"spawn_many_objects_on_death"
#define OBJECTS_KILL			"spawn_many_objects_on_kill"
#define CBS_MULTIMELEE			"special_cbs_multimelee"
#define DISSOLVE				"special_dissolve"
#define DROP_PROP				"special_dropprop"
#define NO_ANIMS				"special_noanims"


enum struct Function_t {
	Function fn;
}

methodmap AbilityPool_t < StringMap
{
	public AbilityPool_t()
	{
		return view_as< AbilityPool_t >(new StringMap());
	}

	public void FindAndStartCall(const char[] name, const FF2Player player)
	{
		if( !this )
			return;
		Function_t _fn;
		if( this.GetArray(name, _fn, sizeof(Function_t)) ) {
			Call_StartFunction(null, _fn.fn);
			Call_PushCell(player);
			Call_Finish();
		}
	}

	public void Register(const char[] name, AbilityPoolFn fn)
	{
		Function_t _fn; _fn.fn = fn;
		this.SetArray(name, _fn, sizeof(Function_t));
	}
}
AbilityPool_t AbilityPool;



public Plugin myinfo =
{
	name		=	"Unofficial Freak Fortress 2: Defaults",
	author		=	"Many many people",
	description	=	"FF2: Combined subplugin of default abilities",
	version		=	"0.7.1"
};

public void OnMapStart()
{
	PrecacheSound(SOUND_SLOW_MO_START);
	PrecacheSound(SOUND_SLOW_MO_END);
	PrecacheSound("ui/notification_alert.wav");
}

void OnPluginStart2()
{
	ConVars.Init();

	AbilityPool = new AbilityPool_t();

	AbilityPool.Register(EXPLOSIVE_DANCE_ABILITY, 	Explosive_Dance);
	AbilityPool.Register(NEW_WEAPON_ABILITY, 		Rage_New_Weapon);
	AbilityPool.Register(STUN_ABILITY,		 		Rage_Stun);
	AbilityPool.Register(STUN_BUILDING_ABILITY,		Rage_Stun_Building);
	AbilityPool.Register(UBER_ABILITY,		 		Rage_Uber);
	AbilityPool.Register(CBS_BOW_ABILITY,			Rage_CBS_Bow);
	AbilityPool.Register(CLONE_ATK_ABILITY,			Rage_CloneAttack);
	AbilityPool.Register(INSTANT_TELE_ABILITY, 		Rage_Instant_Tele);
	AbilityPool.Register(TRADE_SPAWN_ABILITY, 		Rage_Trade_Spam);
	AbilityPool.Register(MATRIX_ABILITY,			Rage_Matrix);
	AbilityPool.Register(OVERLAY_ABILITY,			Rage_Overlay);

	VSH2_Hook(OnPlayerKilled, 		_OnPlayerKilled);
	VSH2_Hook(OnRoundStart,			_OnRoundStart);
	VSH2_Hook(OnRoundEndInfo, 		_OnRoundEnd);
	VSH2_Hook(OnMinionInitialized,  _OnMinionInitialized);

	if( ff2_gm.RoundState == StateRunning ) {

		FF2Player[] bosses = new FF2Player[MaxClients + 1];
		FF2Player[] mercs = new FF2Player[MaxClients + 1];
		int b_count = FF2GameMode.GetBosses(bosses, false);
		int m_count = FF2GameMode.GetBosses(mercs, false);

		_OnRoundStart(bosses, b_count, mercs, m_count);
	}
}

public void OnPluginEnd()
{
	VSH2_Unhook(OnPlayerKilled, 	 _OnPlayerKilled);
	VSH2_Unhook(OnRoundStart, 		 _OnRoundStart);
	VSH2_Unhook(OnRoundEndInfo, 	 _OnRoundEnd);
	VSH2_Unhook(OnMinionInitialized, _OnMinionInitialized);
}

stock void FF2_OnAbility2(const FF2Player player, const char[] abilityName, FF2CallType_t calltype)
{
	AbilityPool.FindAndStartCall(abilityName, player);
}


public void OnEntityCreated(int entity, const char[] classname)
{
	if( !StrContains(classname, "tf_projectile") )
		SDKHook(entity, SDKHook_SpawnPost, OnProjectileSpawned);
}

void OnProjectileSpawned(int entity)
{
	int launcher = GetEntPropEnt(entity, Prop_Send, "m_hLauncher");
	if( launcher < 0 )
		return;

	int client = GetEntPropEnt(launcher, Prop_Send, "m_hOwnerEntity");
	if( client > 0 && IsClientInGame(client) ) {
		FF2Player player = FF2Player(client);
		if( player.HasAbility(this_plugin_name, PROJECTILE_ABILITY) ) {
			static char projectile[PLATFORM_MAX_PATH], classname[PLATFORM_MAX_PATH];
			if( player.GetArgS(this_plugin_name, PROJECTILE_ABILITY, "projectile", projectile, sizeof(projectile)) &&
				GetEntityClassname(entity, classname, sizeof(classname)) &&
				StrContains(classname, projectile) != -1 ) {

				player.GetArgS(this_plugin_name, PROJECTILE_ABILITY, "model", classname, sizeof(classname));
				if( !IsModelPrecached(classname) ) {
					if( FileExists(classname, true) && classname[0] )
						PrecacheModel(classname);
					else {
						FF2GameMode.ReportError(player, "[Boss] Model '%s' doesn't exist!  Please check config", classname);
						return;
					}
				}
				SetEntityModel(entity, classname);
			}
		}
	}
}


/** VSH2 Events */
void _OnRoundStart(const VSH2Player[] bosses, const int boss_count, const VSH2Player[] red_players, const int red_count)
{
	FF2Player player;
	for( int i; i < boss_count; i++ ) {
		player = ToFF2Player(bosses[i]);
		ExplosiveDance[player.index].Init(player);
		if( !democharge.bThinkHooked && player.HasAbility(this_plugin_name, DEMOCHARGE_ABILITY) ) {
			VSH2_Hook(OnBossThinkPost, _RunDemoChargeThink);
			democharge.bThinkHooked = true;
		}
	}
	CreateTimer(0.41, Timer_Disable_Anims, .flags = TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(9.31, Timer_Disable_Anims, .flags = TIMER_FLAG_NO_MAPCHANGE);
}

void _OnMinionInitialized(const VSH2Player minion, const VSH2Player vsh2_owner)
{
	FF2Player owner = ToFF2Player(vsh2_owner);
	if( !FF2GameMode.Validate(vsh2_owner) )
		return;

	char classname[64], model[PLATFORM_MAX_PATH];
	int health = 250;

	/// Formula parser by nergal
	if( owner.GetArgS(this_plugin_name, CLONE_ATK_ABILITY, "health", model, sizeof(model)) ) {
		health = RoundToNearest(ParseFormula(model, ff2_gm.iLivingReds));
	}

	owner.GetArgS(this_plugin_name, CLONE_ATK_ABILITY, "attributes", model, sizeof(model));

	int ammo = owner.GetArgI(this_plugin_name, CLONE_ATK_ABILITY, "ammo", -1);
	int clip = owner.GetArgI(this_plugin_name, CLONE_ATK_ABILITY, "clip", -1);

	int client = minion.index;
	/// Handle minions class
	{
		int class = owner.GetArgI(this_plugin_name, CLONE_ATK_ABILITY, "class");
		TF2_SetPlayerClass(client, view_as< TFClassType >(class), .persistent = false);
	}
	minion.RemoveAllItems();

#if defined _tf2attributes_included
	if( VSH2GameMode.GetPropInt("bTF2Attribs") )
		TF2Attrib_RemoveAll(client);
#endif

	/// Handle minions weapon
	if(	owner.GetArgB(this_plugin_name, CLONE_ATK_ABILITY, "weapon mode") &&
		owner.GetArgS(this_plugin_name, CLONE_ATK_ABILITY, "classname",  classname, sizeof(classname)) ) {
		int index = owner.GetArgI(this_plugin_name, CLONE_ATK_ABILITY, "index", 191);
		int weapon = minion.SpawnWeapon( classname,
										 index,
										 100,
										 5,
										 model /** attributes */);
		if( IsValidEntity(weapon) ) {
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
			SetEntProp(weapon, Prop_Send, "m_iWorldModelIndex", -1);

			if( StrEqual(classname, "tf_weapon_builder") && index != 735 ) {  /// PDA, normal sapper
				for( int i = 0; i < 4; i++ )
					SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, .element = i);
			} else if( StrEqual(classname, "tf_weapon_sapper") || index == 735 ) { /// Sappers, normal sapper
				SetEntProp(weapon, Prop_Send, "m_iObjectType", 3);
				SetEntProp(weapon, Prop_Data, "m_iSubType", 3);
				for( int i = 0; i < 4; i++ )
					SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, .element = i);
			}

			if( ammo >= 0 || clip >= 0 )
				FF2_SetAmmo(client, weapon, ammo, clip);
		}
	}

	if( health ) {
		SetEntProp(client, Prop_Data, "m_iMaxHealth", health);
		SetEntityHealth(client, health);
	}

	{
		float position[3], velocity[3];
		GetEntPropVector(owner.index, Prop_Data, "m_vecOrigin", position);

		velocity[0] = GetRandomFloat(300.0, 500.0) * (GetRandomInt(0, 1) ? 1:-1);
		velocity[1] = GetRandomFloat(300.0, 500.0) * (GetRandomInt(0, 1) ? 1:-1);
		velocity[2] = GetRandomFloat(300.0, 500.0);

		TeleportEntity(client, position, NULL_VECTOR, velocity);
		TF2_AddCondition(client, TFCond_Ubercharged, 2.0);
	}

	if( !owner.GetArgB(this_plugin_name, CLONE_ATK_ABILITY, "custom model") ) {
		owner.GetString("model", model, sizeof(model));
	}
	else owner.GetArgS(this_plugin_name, CLONE_ATK_ABILITY, "model",  model, sizeof(model));

	if( model[0] ) {
		SetVariantString(model);
		AcceptEntityInput(client, "SetCustomModel");
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
	}

	if( owner.GetName(classname) )
		PrintHintText(client, "Now you are %s's minion! Attack other team", classname);

	SetEntProp(client, Prop_Send, "m_nBody", 0);
}

void _OnRoundEnd(const VSH2Player vsh2_player, bool bossBool, char message[MAXMESSAGE])
{
	if( !FF2GameMode.Validate(vsh2_player) )
		return;

	if( ma_data.timer ) {
		TriggerTimer(ma_data.timer);
	}

	if( ToFF2Player(vsh2_player).HasAbility(this_plugin_name, DEMOCHARGE_ABILITY) && democharge.bThinkHooked ) {
		VSH2_Unhook(OnBossThinkPost, _RunDemoChargeThink);
		democharge.bThinkHooked = false;
	}
}

void _RunDemoChargeThink(const VSH2Player vsh2_player)
{
	int index = vsh2_player.index;
	if( index <= 0 || !(GetClientButtons(index) & IN_RELOAD) )
		return;

	if( democharge.flNextThink[index] > GetGameTime() )
		return;

	FF2Player player = ToFF2Player(vsh2_player);
	float delay = ToFF2Player(player).GetArgF(this_plugin_name, DEMOCHARGE_ABILITY, "delay");

	if( delay < 0.1 )
		Do_DemoCharge(null, player);
	else {
		democharge.flNextThink[index] = GetGameTime() + delay;
		CreateTimer(delay, Do_DemoCharge, player);
	}
}

void _OnPlayerKilled(const VSH2Player vsh2_attacker, const VSH2Player victim, Event event)
{
	if( vsh2_attacker && FF2GameMode.Validate(vsh2_attacker) ) {	///	attacker is the boss
		HandleAttackerKill(ToFF2Player(victim), ToFF2Player(vsh2_attacker));
	} else if( victim && FF2GameMode.Validate(victim) ) {	///	victim is the boss
		HandleVictimKill(ToFF2Player(victim), event.GetInt("death_flags"));
	}
}


/** New Weapon */
void Rage_New_Weapon(const FF2Player player)
{
	int client = player.index;
	if( !IsClientInGame(client) || !IsPlayerAlive(client) )
		return;

	TF2_RemoveWeaponSlot(client, player.GetArgI(this_plugin_name, NEW_WEAPON_ABILITY, "weapon slot", -1));

	char classname[64], attributes[128];

	int index = player.GetArgI(this_plugin_name, NEW_WEAPON_ABILITY, "index", -1);
	if( !player.GetArgS(this_plugin_name, NEW_WEAPON_ABILITY, "classname", classname, sizeof(classname)) || index < 0 )
		return;

	player.GetArgS(this_plugin_name, NEW_WEAPON_ABILITY, "attributes", attributes, sizeof(attributes));

	int weapon = player.SpawnWeapon( classname,
									 index,player.GetArgI(this_plugin_name, NEW_WEAPON_ABILITY, "level", 39),
									 player.GetArgI(this_plugin_name, NEW_WEAPON_ABILITY, "quality", 5),
									 attributes );

	if( StrEqual(classname, "tf_weapon_builder") && index != 735 ) { /// PDA, normal sapper
		for( int i = 0; i < 4; i++ )
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, .element = i);
	} else if(StrEqual(classname, "tf_weapon_sapper") || index == 735) { /// Sappers, normal sapper
		SetEntProp(weapon, Prop_Send, "m_iObjectType", 3);
		SetEntProp(weapon, Prop_Data, "m_iSubType", 3);
		for( int i = 0; i < 4; i++ )
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, .element = i);
	}

	if( player.GetArgF(this_plugin_name, NEW_WEAPON_ABILITY, "force switch") )
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);

	int ammo = player.GetArgI(this_plugin_name, NEW_WEAPON_ABILITY, "ammo", 5);
	int clip = player.GetArgI(this_plugin_name, NEW_WEAPON_ABILITY, "clip", 7);

	if( ammo >= 0 || clip >= 0 )
		FF2_SetAmmo(client, weapon, ammo, clip);
}


/** Stun Player */
void Rage_Stun(const FF2Player player)
{
	float delay = player.GetArgF(this_plugin_name, STUN_ABILITY, "delay", 0.0);
	if( delay >= 0.1 )
		CreateTimer(delay, Timer_Rage_Stun, player);
	else Timer_Rage_Stun(null, player);
}

Action Timer_Rage_Stun(Handle timer, FF2Player cur_boss)
{
	int client = cur_boss.index;

	float bossPosition[3], targetPosition[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", bossPosition);

 /// Initial Duration
	float duration = cur_boss.GetArgF(this_plugin_name, STUN_ABILITY, "duration", 5.0);

 /// Distance
	float distance = cur_boss.GetArgF(this_plugin_name, STUN_ABILITY, "distance");
	if( distance <= 0 )
		distance = cur_boss.RageDist(this_plugin_name, STUN_ABILITY);

 /// Stun Flags
	char flagOverrideStr[12];
	cur_boss.GetArgS(this_plugin_name, STUN_ABILITY, "flags", flagOverrideStr, sizeof(flagOverrideStr));
	int flagOverride = StringToInt(flagOverrideStr, 16);
	if( !flagOverride )
		flagOverride = TF_STUNFLAGS_GHOSTSCARE | TF_STUNFLAG_NOSOUNDOREFFECT;

 /// Slowdown
	float slowdown = cur_boss.GetArgF(this_plugin_name, STUN_ABILITY, "slowdown");

 /// Sound To Boss
	bool sounds = cur_boss.GetArgB(this_plugin_name, STUN_ABILITY, "sound", true);

 /// Particle Effect
	char particleEffect[48];
	if( !cur_boss.GetArgS(this_plugin_name, STUN_ABILITY, "particle", particleEffect, sizeof(particleEffect)) )
		particleEffect = "yikes_fx";

 /// Ignore
	int ignore = cur_boss.GetArgI(this_plugin_name, STUN_ABILITY, "uber", 1);

 /// Friendly Fire
	bool friendly = cur_boss.GetArgB(this_plugin_name, STUN_ABILITY, "friendly", ConVars.mp_friendlyfire.BoolValue);

 /// Remove Parachute
	bool removeBaseJumperOnStun = cur_boss.GetArgB(this_plugin_name, STUN_ABILITY, "basejumper", ConVars.ff2_base_jumper_stun.BoolValue);

 /// Max Duration
	float maxduration = cur_boss.GetArgF(this_plugin_name, STUN_ABILITY, "max", 6.0);

 /// Add Duration
	float addduration = cur_boss.GetArgF(this_plugin_name, STUN_ABILITY, "add");
	if( maxduration <= 0 ) {
		maxduration = duration;
		addduration = 0.0;
	}

 /// Solo Rage Duration
	float soloduration = cur_boss.GetArgF(this_plugin_name, STUN_ABILITY, "solo");
	if( soloduration <= 0 )
		soloduration = duration;

	FF2Player[] victim_pool = new FF2Player[MaxClients + 1];
	int count;
	for( int target = 1; target <= MaxClients; target++ ) {
		if( IsClientInGame(target) && IsPlayerAlive(target) && target != client && (friendly || GetClientTeam(target) != GetClientTeam(client)) ) {
			GetEntPropVector(target, Prop_Send, "m_vecOrigin", targetPosition);
			if( (!TF2_IsPlayerInCondition(target, TFCond_Ubercharged)
				|| (ignore > 0 && ignore != 2)) && (!TF2_IsPlayerInCondition(target, TFCond_MegaHeal)
				|| ignore > 1) && GetVectorDistance(bossPosition, targetPosition) <= distance ) {
				victim_pool[count] = FF2Player(target);
				count++;
			}
		}
	}

	if( !count )
		return Plugin_Continue;

	if( count == 1 && (duration != soloduration || ConVars.ff2_solo_shame.BoolValue) ) {
		char bossName[MAX_BOSS_NAME_SIZE];
		if( cur_boss.GetName(bossName) )
			FPrintToChatAll("{blue}%s{default} used {red}solo rage{default}!", bossName);

		if( duration != soloduration )
			duration = soloduration;
	} else {
		duration += addduration * (count - 1);
		if( duration > maxduration )
			duration = maxduration;
	}

	CreateTimer(duration, Timer_SoloRageResult, victim_pool[count - 1]);

	/// Idealy we can use FF2Player.StunPlayers() but we want to change stun particles
	FF2Player cur_victim;
	while( count > 0 ) {
		count--;
		cur_victim = victim_pool[count];

		if( removeBaseJumperOnStun )
			TF2_RemoveCondition(cur_victim.index, TFCond_Parachute);

		TF2_StunPlayer(cur_victim.index, duration, slowdown, flagOverride, sounds ? client : 0);

		if( particleEffect[0] )
			AttachParticle(cur_victim.index, particleEffect, 75.0);
	}
	return Plugin_Continue;
}

Action Timer_SoloRageResult(Handle timer, FF2Player target)
{
	int client = target.index;
	if( !IsClientInGame(client) || ff2_gm.RoundState != StateRunning )
		return Plugin_Continue;

	if( IsPlayerAlive(client) )
		FPrintToChatAll("It's {red}not{default} very effective...");
	else FPrintToChatAll("It's {blue}super{default} effective...");
	return Plugin_Continue;
}


/** Stun Building */
enum BuildingType_t {
	SENTRY 		= 0b001,
	DISPENSER 	= 0b010,
	TELEPORTER 	= 0b100
};

void Rage_Stun_Building(const FF2Player player)
{
	int client = player.index;
	float bossPosition[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", bossPosition);

	float duration = player.GetArgF(this_plugin_name, STUN_BUILDING_ABILITY, "duration", 7.0);

	float distance = player.GetArgF(this_plugin_name, STUN_BUILDING_ABILITY, "distance");
	if( distance <= 0 )
		distance = player.RageDist(this_plugin_name, STUN_BUILDING_ABILITY);

	char strBuffer[48];
	float health;
 	bool destroy;

 	{
 		if( player.GetArgS(this_plugin_name, STUN_BUILDING_ABILITY, "health", strBuffer, sizeof(strBuffer)) )
 			health = ParseFormula(strBuffer, ff2_gm.iLivingReds);

 		if( health <= 0 )
 			destroy = true;
 	}

	float ammo = player.GetArgF(this_plugin_name, STUN_BUILDING_ABILITY, "ammo", 1.0);
	float rockets = player.GetArgF(this_plugin_name, STUN_BUILDING_ABILITY, "rocket", 1.0);

	if( player.GetArgS(this_plugin_name, STUN_BUILDING_ABILITY, "particle", strBuffer, sizeof(strBuffer)) )
		strBuffer = "yikes_fx";

	BuildingType_t buildingtype = view_as< BuildingType_t >(player.GetArgI(this_plugin_name, STUN_BUILDING_ABILITY, "building", 0b111));
	/**
	 *	1 = sentry
	 *	2 = dispenser
	 *	4 = teleporter
 	 */

	bool friendly = player.GetArgB(this_plugin_name, STUN_BUILDING_ABILITY, "friendly", ConVars.mp_friendlyfire.BoolValue);

	char full_clsname[64];

	{
		float buildingPos[3];
		int building = MaxClients + 1;
		bool target = false;
		int other_team = GetClientTeam(client) % 2;

		while( (building = FindEntityByClassname(building, "obj_*")) != -1 ) {

			target = ((GetEntProp(building, Prop_Send, "m_nSkin") % 2) != other_team) || friendly;
			target &= !GetEntProp(building, Prop_Send, "m_bCarried") && !GetEntProp(building, Prop_Send, "m_bPlacing");

			if( !target )
				continue;

			if( !GetEntityClassname(building, full_clsname, sizeof(full_clsname)) )
				continue;

			switch( full_clsname[4] ) {
				case 's': {
					if( !(buildingtype & SENTRY) )
						continue;
					target = false;
				}
				case 'd': {
					if( !(buildingtype & DISPENSER) )
						continue;
				}
				case 't': {
					if( !(buildingtype & TELEPORTER) )
						continue;
				}
				default: continue;
			}

			GetEntPropVector(building, Prop_Send, "m_vecOrigin", buildingPos);
			if( GetVectorDistance(bossPosition, buildingPos) <= distance ) {
				if( destroy ) {
					SDKHooks_TakeDamage(building, client, client, 9001.0, DMG_GENERIC, -1);
				} else {
					if( health != 1.0 )
						SDKHooks_TakeDamage(building, client, client, GetEntProp(building, Prop_Send, "m_iMaxHealth") * health, DMG_GENERIC, -1);

					if( !target ) {
						if( 0 <= ammo < 1.0 )
							SetEntProp(building, Prop_Send, "m_iAmmoShells", GetEntProp(building, Prop_Send, "m_iAmmoShells") * ammo);

						if( 0 <= rockets < 1.0 )
							SetEntProp(building, Prop_Send, "m_iAmmoRockets", GetEntProp(building, Prop_Send, "m_iAmmoRockets") * rockets);
					}

					if( duration > 0.0 ) {
						SetEntProp(building, Prop_Send, "m_bDisabled", 1);
						AttachParticle(building, strBuffer, 75.0, .time = duration);
						CreateTimer(duration, Timer_EnableBuilding, EntIndexToEntRef(building), TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
		}
	}
}

Action Timer_EnableBuilding(Handle timer, int ref)
{
	int building = EntRefToEntIndex(ref);
	if( IsValidEntity(building) )
		SetEntProp(building, Prop_Send, "m_bDisabled", 0);

	return Plugin_Continue;
}


/** Rage Uber */
void Rage_Uber(const FF2Player player)
{
	float duration = player.GetArgF(this_plugin_name, UBER_ABILITY, "duration", 5.0);
	if( duration <= 0 )
		return;

	int client = player.index;
	TF2_AddCondition(client, TFCond_Ubercharged, duration);
	SetEntProp(client, Prop_Data, "m_takedamage", 0);
	CreateTimer(duration, Timer_StopUber, player, TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_StopUber(Handle timer, FF2Player player)
{
	int client = player.index;
	if( client && IsClientInGame(client) )
		SetEntProp(client, Prop_Data, "m_takedamage", 2);
	return Plugin_Continue;
}


/** Explosive Dance */
void Explosive_Dance(const FF2Player player)
{
	SetEntityMoveType(player.index, MOVETYPE_NONE);
	CreateTimer(0.15, Timer_Prepare_Explosion_Rage, player);
}

Action Timer_Prepare_Explosion_Rage(Handle timer, FF2Player player)
{
	int client = player.index;
	if( !client || !IsClientInGame(client) )
		return Plugin_Continue;

	if( player.GetArgI(this_plugin_name, EXPLOSIVE_DANCE_ABILITY, "taunt", true) )
		ClientCommand(client, "+taunt");

	CreateTimer(player.GetArgF(this_plugin_name, EXPLOSIVE_DANCE_ABILITY, "delay", 0.12), Timer_Rage_Explosive_Dance, player, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

	float position[3];
	GetEntPropVector(client, Prop_Data, "m_vecOrigin", position);

	char sound[PLATFORM_MAX_PATH];

	if( player.GetArgS(this_plugin_name, EXPLOSIVE_DANCE_ABILITY, "sound", sound, sizeof(sound)) )
		EmitSoundToAll(sound, client, .speakerentity = client, .origin = position);

	return Plugin_Continue;
}

Action Timer_Rage_Explosive_Dance(Handle timer, FF2Player player)
{
	static int count[MAXCLIENTS];
	int client = player.index;
	if( !client || !IsClientInGame(client) ) {
		count[client] = 0;
		return Plugin_Stop;
	}

	count[client]++;
	if( count[client] <= ExplosiveDance[client].iNumExplosion && IsPlayerAlive(client) ) {
		SetEntityMoveType(client, MOVETYPE_NONE);
		float bossPosition[3], explosionPosition[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", bossPosition);
		explosionPosition[2] = bossPosition[2];
		float range;

		for( int i; i < 3; i++ ) {
			int explosion = CreateEntityByName("env_explosion");
			if( !IsValidEntity(explosion) )
				break;

			DispatchKeyValueFloat(explosion, "DamageForce", ExplosiveDance[client].flDamage);

			SetEntProp(explosion, Prop_Data, "m_iMagnitude", 280, 4);
			SetEntProp(explosion, Prop_Data, "m_iRadiusOverride", 200, 4);
			SetEntPropEnt(explosion, Prop_Data, "m_hOwnerEntity", client);

			DispatchSpawn(explosion);

			explosionPosition[0] = bossPosition[0] + GetRandomFloat(-ExplosiveDance[client].flRange, ExplosiveDance[client].flRange);
			explosionPosition[1] = bossPosition[1] + GetRandomFloat(-ExplosiveDance[client].flRange, ExplosiveDance[client].flRange);

			if( !(GetEntityFlags(client) & FL_ONGROUND) ) {
				range = ((ExplosiveDance[client].flRange * 3.0) / 7.0);
				explosionPosition[2] = bossPosition[2] + GetRandomFloat(-range, range);
			} else {
				range = ((ExplosiveDance[client].flRange * 2.0) / 7.0);
				explosionPosition[2] = bossPosition[2] + GetRandomFloat(0.0, range);
			}

			TeleportEntity(explosion, explosionPosition, NULL_VECTOR, NULL_VECTOR);
			AcceptEntityInput(explosion, "Explode");

			RemoveEntity(explosion);
		}
	} else {
		SetEntityMoveType(client, MOVETYPE_WALK);
		count[client] = 0;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}


/** Instant Teleport */
void Rage_Instant_Tele(const FF2Player player)
{
	float position[3];
	char strflags[12], particleEffect[48];

	float flstuntime = player.GetArgF(this_plugin_name, INSTANT_TELE_ABILITY, "stun", 2.0);
	//bool friendly = player.GetArgB(this_plugin_name, INSTANT_TELE_ABILITY, "friendly", true);
	float flslowdown = player.GetArgF(this_plugin_name, INSTANT_TELE_ABILITY, "slowdown");
	bool sounds = player.GetArgB(this_plugin_name, INSTANT_TELE_ABILITY, "sound", true);
	player.GetArgS(this_plugin_name, INSTANT_TELE_ABILITY, "particle",particleEffect, sizeof(particleEffect));

	int flags;
	if( !player.GetArgS(this_plugin_name, INSTANT_TELE_ABILITY, "flags", strflags, sizeof(strflags))
		|| !(flags = StringToInt(strflags, 16)) )
		flags = TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT;

	int count;
	FF2Player[] players = new FF2Player[MaxClients + 1];
	int client = player.index;
	for( int target=1; target <= MaxClients; target++ ) {
		if( IsClientInGame(target) && IsPlayerAlive(target) && target != client) {
			players[count] = FF2Player(target);
			count++;
		}
	}
	if( !count )
		return;

	FF2Player final_target = players[GetRandomInt(0, count - 1)];
	int target = final_target.index;

	if( particleEffect[0] ) {
		AttachParticle(target, particleEffect);
		AttachParticle(target, particleEffect, .battach = false);
	}

	GetEntPropVector(target, Prop_Send, "m_vecOrigin", position);
	SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + 2.0);

	if( GetEntProp(target, Prop_Send, "m_bDucked") ) {
		SetEntPropVector(client, Prop_Send, "m_vecMaxs", view_as< float >({ 24.0, 24.0, 62.0 }));
		SetEntProp(client, Prop_Send, "m_bDucked", 1);
		SetEntityFlags(client, GetEntityFlags(client) | FL_DUCKING);

		DataPack pack;
		CreateDataTimer(0.2, Timer_StunBoss, pack, TIMER_FLAG_NO_MAPCHANGE);

		pack.WriteCell(player);
		pack.WriteFloat(flstuntime);
		pack.WriteFloat(flslowdown);
		pack.WriteCell(flags);
		pack.Reset();
	} else {
		if( sounds )
			TF2_StunPlayer(client, flstuntime, flslowdown, flags, target);
		else TF2_StunPlayer(client, flstuntime, flslowdown, flags);
	}

	TeleportEntity(client, position, NULL_VECTOR, NULL_VECTOR);
}

public Action Timer_StunBoss(Handle timer, DataPack pack)
{
	int client = ToFF2Player(pack.ReadCell()).index;
	if( !IsClientInGame(client) || !IsPlayerAlive(client) )
		return Plugin_Continue;

	float fltime = pack.ReadFloat();
	float flslowdown = pack.ReadFloat();
	int flags = pack.ReadCell();

	TF2_StunPlayer(client, fltime, flslowdown, flags, 0);
	return Plugin_Continue;
}


/** Christian Brutal Sniper Bow */
void Rage_CBS_Bow(const FF2Player player)
{
	int client = player.index;
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);

	char attributes[64], classname[64];

	player.GetArgS(this_plugin_name, CBS_BOW_ABILITY, "attributes",  attributes, sizeof(attributes));
	if( !attributes[0] ) {
		attributes = ConVars.ff2_strangewep.BoolValue ?
					 "6 ; 0.5 ; 37 ; 0.0 ; 214 ; 333 ; 280 ; 19":
					 "6 ; 0.5 ; 37 ; 0.0 ; 280 ; 19";
	}

	int maximum = player.GetArgI(this_plugin_name, CBS_BOW_ABILITY, "max", 9);
	int ammo = player.GetArgI(this_plugin_name, CBS_BOW_ABILITY, "ammo", 1);
	int clip = player.GetArgI(this_plugin_name, CBS_BOW_ABILITY, "clip", 1);
	if( !player.GetArgS(this_plugin_name, CBS_BOW_ABILITY, "classname", classname, sizeof(classname)) )
		classname = "tf_weapon_compound_bow";

	int index = player.GetArgI(this_plugin_name, CBS_BOW_ABILITY, "index", 1005);
	int level = player.GetArgI(this_plugin_name, CBS_BOW_ABILITY, "level", 101);
	int quality = player.GetArgI(this_plugin_name, CBS_BOW_ABILITY, "quality", 5);
	int weapon = player.SpawnWeapon( classname,
									 index,
									 level,
									 quality,
									 attributes );

	if( player.GetArgI(this_plugin_name, CBS_BOW_ABILITY, "force switch", 1) )
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);

	ammo *= ff2_gm.iLivingReds; /// Ammo multiplied by alive players

	if( ammo > maximum ) /// Maximum or lower ammo
		ammo = maximum;

	ammo -= clip;  /// Ammo subtracted by clip

	while( ammo < 0 && clip >= 0 ) { /// Remove clip until ammo or clip is zero
		clip--;
		ammo++;
	}

	/// If clip is positive or zero
	if( clip >= 0 )
		FF2_SetAmmo(client, weapon, ammo, clip);
}


/** Clone Attack */
void Rage_CloneAttack(const FF2Player player)
{
	int client = player.index;

	float ratio = player.GetArgF(this_plugin_name, CLONE_ATK_ABILITY, "ratio");

	int alive;
	ArrayList list = new ArrayList();
	FF2Player cur_target;

	for( int i = 1; i <= MaxClients; i++ ) {
		if( IsClientInGame(i) ) {
			cur_target = FF2Player(i);

			TFTeam team = TF2_GetClientTeam(i);
			if( team != TF2_GetClientTeam(client) ) {
				if( IsPlayerAlive(i) )
					alive++;
				else if( !cur_target.GetPropInt("bIsBoss") ) {  /// Don't let dead bosses become clones
					list.Push(cur_target);
				}
			}
		}
	}

	int totalMinions = (ratio ? RoundToCeil(alive * ratio) : MaxClients);  //If ratio is 0, use MaxClients instead

	FF2Player minion;

	list.Sort(Sort_Random, Sort_Integer);

	while( list.Length > 0 && totalMinions > 0 ) {
		minion = ToFF2Player(list.Get(0));
		list.Erase(0);
		totalMinions--;

		minion.hOwnerBoss = player;
		minion.ConvertToMinion(0.1);
	}

	delete list;

	/// TODO: replace with VSH2 natives that deal with this?
	int entity, owner;
	while( (entity = FindEntityByClassname(entity, "tf_wearable*")) != -1 ) {
		if( (owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")) <= MaxClients && owner > 0 && GetClientTeam(owner) == GetClientTeam(client) )
			TF2_RemoveWearable(owner, entity);
	}
}


/** Trade Spam */
void Rage_Trade_Spam(const FF2Player player)
{
	CreateTimer(0.1, Trade_KeepSpamming, 1, TIMER_FLAG_NO_MAPCHANGE);
}

Action Trade_KeepSpamming(Handle timer, int count)
{
	if( count == 13 )  /// Rage has finished-reset it in 6 seconds (trade_0 is 100% transparent apparently)
		CreateTimer(6.0, Trade_KeepSpamming, 0, TIMER_FLAG_NO_MAPCHANGE);
	else {
		char overlay[PLATFORM_MAX_PATH];
		Format(overlay, sizeof(overlay), "r_screenoverlay \"freak_fortress_2/demopan/trade_%i\"", count);

		SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & ~FCVAR_CHEAT);  /// Allow normal players to use r_screenoverlay
		for( int client = 1; client <= MaxClients; client++ ) {
			if( IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) != VSH2Team_Boss ) {
				ClientCommand(client, overlay);
			}
		}
		SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & FCVAR_CHEAT);  /// Reset the cheat permissions

		if( count ) {
			EmitSoundToAll("ui/notification_alert.wav", .updatePos = false);
			CreateTimer(
				count == 1 ? 1.0 : 0.5 / float(count),
				Trade_KeepSpamming,
				count + 1,
				TIMER_FLAG_NO_MAPCHANGE
			);  /// Give a longer delay between the first and second overlay for "smoothness"
		}
		else return Plugin_Stop; /// Stop the rage
	}
	return Plugin_Continue;
}


/** Matrix */
void Rage_Matrix(const FF2Player player)
{
	float timescale = player.GetArgF(this_plugin_name, MATRIX_ABILITY, "timescale", 0.5);
	float duration = player.GetArgF(this_plugin_name, MATRIX_ABILITY, "duration", 1.0) + 1.0;

	player.SetPropInt("bNotifySMAC_CVars", 1);
	ConVars.host_timescale.FloatValue = 0.5;

	ma_data.timer = CreateTimer(duration * timescale, Timer_StopSlowMo, player, TIMER_FLAG_NO_MAPCHANGE);
	UpdateCheatValue("1");

	int client = player.index;
	AttachParticle(client, "scout_dodge_blue", 75.0, .time = duration);

	if( timescale != 1.0 )
		EmitSoundToAll(SOUND_SLOW_MO_START, .updatePos = false);

	SDKHook(client, SDKHook_PostThinkPost, Post_ClientSlowMoThink);
}

Action Timer_StopSlowMo(Handle timer, FF2Player player)
{
	int client = player.index;

	ma_data.InValidate();

	float timescale = ConVars.host_timescale.FloatValue;
	ConVars.host_timescale.FloatValue = 1.0;

	UpdateCheatValue("0");

	if( timescale != 1.0 )
		EmitSoundToAll(SOUND_SLOW_MO_END, .updatePos = false);

	if( client ) {
		player.SetPropInt("bNotifySMAC_CVars", 0);
		SDKUnhook(client, SDKHook_PostThinkPost, Post_ClientSlowMoThink);
	}
}

void Post_ClientSlowMoThink(int client)
{
	if( ff2_gm.RoundState != StateRunning ) {
		SDKUnhook(client, SDKHook_PostThinkPost, Post_ClientSlowMoThink);
		return;
	}

	static float flNextClick[MAXCLIENTS];
	if( GetClientButtons(client) & IN_ATTACK && flNextClick[client] < GetGameTime() ) {
		flNextClick[client] = GetGameTime() + FF2Player(client).GetArgF(this_plugin_name, MATRIX_ABILITY, "delay", 0.2);

		float bossPosition[3], endPosition[3], vecbuffer[3];
		GetClientEyePosition(client, bossPosition);
		GetClientEyeAngles(client, vecbuffer);

		Handle trace = TR_TraceRayFilterEx(bossPosition, vecbuffer, MASK_SOLID, RayType_Infinite, TraceRayDontHitSelf, EntIndexToEntRef(client));
		TR_GetEndPosition(endPosition, trace);
		endPosition[2] += 100;

		SubtractVectors(endPosition, bossPosition, vecbuffer);
		NormalizeVector(vecbuffer, vecbuffer);
		ScaleVector(vecbuffer, 2012.0);
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vecbuffer);

		int target = TR_GetEntityIndex(trace);
		delete trace;

		if( target > 0 && target <= MaxClients ) {
			DataPack pack;
			CreateDataTimer(0.15, Timer_Rage_SlowMo_Attack, pack);
			pack.WriteCell(GetClientUserId(client));
			pack.WriteCell(GetClientUserId(target));
			pack.Reset();
		}
	}
}

Action Timer_Rage_SlowMo_Attack(Handle timer, DataPack pack)
{
	int client = GetClientOfUserId(pack.ReadCell());
	int target = GetClientOfUserId(pack.ReadCell());
	if( client &&
		target &&
		IsClientInGame(client) &&
		IsClientInGame(target) &&
		GetClientTeam(client) != GetClientTeam(target) ) {

		float clientPosition[3], targetPosition[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", clientPosition);
		GetEntPropVector(target, Prop_Send, "m_vecOrigin", targetPosition);

		if( GetVectorDistance(clientPosition, targetPosition) <= 1500 && ma_data.Validate(target) ) {
			SetEntProp(client, Prop_Send, "m_bDucked", 1);
			SetEntityFlags(client, GetEntityFlags(client) | FL_DUCKING);

			SDKHooks_TakeDamage(target, client, client, 850.0);
			TeleportEntity(client, targetPosition, NULL_VECTOR, NULL_VECTOR);
		}
	}
}

bool TraceRayDontHitSelf(int entity, int mask, int ref)
{
	return EntIndexToEntRef(entity) != ref;
}


/** Overlay */
void Rage_Overlay(const FF2Player player)
{
	char overlay[PLATFORM_MAX_PATH];
	if( !player.GetArgS(this_plugin_name, OVERLAY_ABILITY, "path", overlay, sizeof(overlay)) )
		return;

	float duration = player.GetArgF(this_plugin_name, OVERLAY_ABILITY, "duration", 6.0);

	Format(overlay, PLATFORM_MAX_PATH, "r_screenoverlay \"%s\"", overlay);
	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") &~ FCVAR_CHEAT);

	for( int target = 1; target <= MaxClients; target++ )
		if( IsClientInGame(target) && IsPlayerAlive(target) && GetClientTeam(target) != VSH2Team_Boss )
			ClientCommand(target, overlay);

	if( duration >= 0 )
		CreateTimer(duration, Timer_Remove_Overlay, .flags = TIMER_FLAG_NO_MAPCHANGE);

	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & FCVAR_CHEAT);
}

Action Timer_Remove_Overlay(Handle timer)
{
	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & ~FCVAR_CHEAT);

	for( int target = 1; target <= MaxClients; target++ )
		if( IsClientInGame(target) && IsPlayerAlive(target) && GetClientTeam(target) != VSH2Team_Boss )
			ClientCommand(target, "r_screenoverlay off");

	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & FCVAR_CHEAT);
	return Plugin_Continue;
}


/** DemoCharge */
Action Do_DemoCharge(Handle timer, FF2Player player)
{
	int client = player.index;
	if( !client || !IsClientInGame(client) )
		return Plugin_Continue;

	float charge = player.GetPropFloat("flRAGE");
	float res = charge - player.GetArgF(this_plugin_name, DEMOCHARGE_ABILITY, "rage", 2.0);
	float flthink = player.GetArgF(this_plugin_name, DEMOCHARGE_ABILITY, "cooldown") / 2;

	if( charge > player.GetArgF(this_plugin_name, DEMOCHARGE_ABILITY, "minimum", 10.0) &&
	     charge <= player.GetArgF(this_plugin_name, DEMOCHARGE_ABILITY, "maximum", 100.0) &&
	     res >= 0.0 ) {

		float duration = player.GetArgF(this_plugin_name, DEMOCHARGE_ABILITY, "duration", 0.25);
		if( duration < 0 && duration != TFCondDuration_Infinite )
			duration = TFCondDuration_Infinite;

		SetEntPropFloat(client, Prop_Send, "m_flChargeMeter", 100.0);
		TF2_AddCondition(client, TFCond_Charging, duration);

		player.SetPropFloat("flRAGE", res);
		democharge.flNextThink[client] = GetGameTime() + flthink * 2;
	}
	else democharge.flNextThink[client] = GetGameTime() + flthink;
	return Plugin_Continue;
}


/** No Anims */
Action Timer_Disable_Anims(Handle timer)
{
	for( int client = MaxClients; client > 0; client-- ) {
		FF2Player player = FF2Player(client);
		if( player.index && player.HasAbility(this_plugin_name, NO_ANIMS) ) {
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", player.GetArgF(this_plugin_name, NO_ANIMS, "custom model animation"));
			SetEntProp(client, Prop_Send, "m_bCustomModelRotates", player.GetArgF(this_plugin_name, NO_ANIMS, "custom model rotates"));
		}
	}
}


/** Stocks */
int AttachParticle(const int ent, const char[] particleType, float offset = 0.0, bool battach = true, float time = 3.0)
{
	int particle = CreateEntityByName("info_particle_system");
	char tName[32];
	float pos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	pos[2] += offset;
	TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);

	FormatEx(tName, sizeof(tName), "target%i", ent);

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
	CreateTimer(time, Timer_RemoveEntity, EntIndexToEntRef(particle));

	return particle;
}

Action Timer_RemoveEntity(Handle timer, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if( IsValidEntity(ent) ) {
		RemoveEntity(ent);
	}
}

Action Timer_EquipModel(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = ToFF2Player(pack).index;
	if( client && IsClientInGame(client) && IsPlayerAlive(client) ) {

		char model[PLATFORM_MAX_PATH];
		pack.ReadString(model, sizeof(model));

		SetVariantString(model);
		AcceptEntityInput(client, "SetCustomModel");
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
	}
}
#pragma unused Timer_EquipModel

void UpdateCheatValue(const char[] value)
{
	for( int client = MaxClients; client > 0; client-- ) {
		if( IsClientInGame(client) && !IsFakeClient(client) )
			ConVars.sv_cheats.ReplicateToClient(client, value);
	}
}

int SpawnManyObjects(const char[] classname, const int client, const char[] model, const int skin=0, const int amount=14, const float distance=30.0)
{
	if( !client || !IsClientInGame(client) )
		return;

	static int m_iPackType = 0;
	if( !m_iPackType ) {
		m_iPackType = FindSendPropInfo("CTFAmmoPack", "m_vecInitialVelocity") - 4;
	}

	float position[3], velocity[3];
	GetClientAbsOrigin(client, position);
	position[2] += distance;

	for( int i; i < amount; i++ ){
		velocity[0] = GetRandomFloat(-400.0, 400.0);
		velocity[1] = GetRandomFloat(-400.0, 400.0);
		velocity[2] = GetRandomFloat(300.0, 500.0);
		position[0] += GetRandomFloat(-5.0, 5.0);
		position[1] += GetRandomFloat(-5.0, 5.0);

		int entity = CreateEntityByName(classname);
		if( !IsValidEntity(entity) ) {
			FF2GameMode.ReportError(FF2Player(client), "[Boss] Invalid entity while spawning objects for %s-check your configs!", this_plugin_name);
			break;
		}

		SetEntityModel(entity, model);
		DispatchKeyValue(entity, "OnPlayerTouch", "!self,Kill,,0,-1");

		SetEntProp(entity, Prop_Send, "m_nSkin", skin);
		SetEntProp(entity, Prop_Send, "m_nSolidType", 6);
		SetEntProp(entity, Prop_Send, "m_usSolidFlags", 152);
		SetEntProp(entity, Prop_Send, "m_triggerBloat", 24);
		SetEntProp(entity, Prop_Send, "m_CollisionGroup", 1);
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);

		SetEntProp(entity, Prop_Send, "m_iTeamNum", 2);
		DispatchSpawn(entity);
		TeleportEntity(entity, position, view_as< float >({90.0, 0.0, 0.0}), velocity);
		SetEntProp(entity, Prop_Data, "m_iHealth", 900);

		SetEntData(entity, m_iPackType, 1, .changeState = true);
	}
}

Action Timer_RemoveRagdoll(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	int ragdoll;
	if( client > 0 && (ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll")) > MaxClients )
		RemoveEntity(ragdoll);
}

Action Timer_DissolveRagdoll(Handle timer, FF2Player player)
{
	int client = player.index;
	int ragdoll = -1;
	if( client && IsClientInGame(client) )
		ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");

	if( IsValidEntity(ragdoll) ) {
		int dissolver = CreateEntityByName("env_entity_dissolver");
		if( dissolver != -1 ) {
			DispatchKeyValue(dissolver, "dissolvetype", "0");
			DispatchKeyValue(dissolver, "magnitude", "200");
			DispatchKeyValue(dissolver, "target", "!activator");

			AcceptEntityInput(dissolver, "Dissolve", ragdoll);
			RemoveEntity(dissolver);
		}
	}
}


void HandleAttackerKill(FF2Player victim, FF2Player player)
{
	if( player.HasAbility(this_plugin_name, OBJECTS_DEATH) ) {
		char model[PLATFORM_MAX_PATH], classname[PLATFORM_MAX_PATH];
		if( player.GetArgS(this_plugin_name, OBJECTS_DEATH, "classname", classname, sizeof(classname)) &&
			player.GetArgS(this_plugin_name, OBJECTS_DEATH, "model", model, sizeof(model)) ) {
			SpawnManyObjects(classname, victim.index, model, player.GetArgI(this_plugin_name, OBJECTS_DEATH, "skin"), player.GetArgI(this_plugin_name, OBJECTS_DEATH, "amount", 14), player.GetArgF(this_plugin_name, OBJECTS_DEATH, "distance", 30.0) );
		}
	}

	if( player.HasAbility(this_plugin_name, DISSOLVE) ) {
		CreateTimer(0.1, Timer_DissolveRagdoll, victim, TIMER_FLAG_NO_MAPCHANGE);
	}

	if( player.HasAbility(this_plugin_name, CBS_MULTIMELEE) ) {
		int attacker = player.index;
		if( GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon") == GetPlayerWeaponSlot(attacker, TFWeaponSlot_Melee) ) {
			TF2_RemoveWeaponSlot(attacker, TFWeaponSlot_Melee);
			char attributes[128];

			if(!player.GetArgS(this_plugin_name, CBS_MULTIMELEE, "attributes", attributes, sizeof(attributes)))
				attributes = "68 ; 2 ; 2 ; 3.1 ; 275 ; 1";

			int weapon;
			switch( GetRandomInt(0, 2) ) {
				case 0: weapon = player.SpawnWeapon("tf_weapon_club", 171, 101, 5, attributes);
				case 1: weapon = player.SpawnWeapon("tf_weapon_club", 193, 101, 5, attributes);
				case 2: weapon = player.SpawnWeapon("tf_weapon_club", 232, 101, 5, attributes);
			}

			SetEntPropEnt(attacker, Prop_Data, "m_hActiveWeapon", weapon);
		}
	}

	if( player.HasAbility(this_plugin_name, DROP_PROP) ) {
		char model[PLATFORM_MAX_PATH];
		if( player.GetArgS(this_plugin_name, DROP_PROP, "model", model, PLATFORM_MAX_PATH) ) {
			if( !IsModelPrecached(model) ) {
				if( !FileExists(model, true) ) {
					FF2GameMode.ReportError(player, "[Boss] Model '%s' doesn't exist!, (plugin: %s - ability: %s)", model, this_plugin_name, DROP_PROP);
					return;
				}
				else PrecacheModel(model);
			}
			if( player.GetArgF(this_plugin_name, DROP_PROP, "remove ragdolls") )
				CreateTimer(0.1, Timer_RemoveRagdoll, victim, TIMER_FLAG_NO_MAPCHANGE);

			int prop = CreateEntityByName("prop_physics_override");
			if( prop != -1 ) {
				SetEntityModel(prop, model);
				SetEntityMoveType(prop, MOVETYPE_VPHYSICS);
				SetEntProp(prop, Prop_Send, "m_CollisionGroup", 1);
				SetEntProp(prop, Prop_Send, "m_usSolidFlags", 16);
				DispatchSpawn(prop);
				float position[3];
				GetEntPropVector(victim.index, Prop_Send, "m_vecOrigin", position);
				position[2] += 20;
				TeleportEntity(prop, position, NULL_VECTOR, NULL_VECTOR);
				float duration = player.GetArgF(this_plugin_name, DROP_PROP, "duration");
				if( duration > 0.5 )
					CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}

void HandleVictimKill(FF2Player player, int flags)
{
	if(	player.HasAbility(this_plugin_name, CLONE_ATK_ABILITY) && player.GetArgI(this_plugin_name, CLONE_ATK_ABILITY, "slay on death", 1) && !(flags & TF_DEATHFLAG_DEADRINGER) ) {
		FF2Player iter;
		int client = player.index;
		for( int i = 1; i <= MaxClients; i++ ) {
			if( !IsClientInGame(i) || GetClientTeam(i) != GetClientTeam(client) )
				continue;

			iter = FF2Player(i);
			if( iter.hOwnerBoss == player ) {
				ChangeClientTeam(i, (GetClientTeam(client) == view_as< int >(TFTeam_Blue)) ? view_as< int >(TFTeam_Red) : view_as< int >(TFTeam_Blue));
			}
		}
	}

	if( player.HasAbility(this_plugin_name, OBJECTS_DEATH) ) {
		char classname[PLATFORM_MAX_PATH], model[PLATFORM_MAX_PATH];
		player.GetArgS(this_plugin_name, OBJECTS_DEATH, "classname", classname, PLATFORM_MAX_PATH);
		player.GetArgS(this_plugin_name, OBJECTS_DEATH, "model", model, PLATFORM_MAX_PATH);
		SpawnManyObjects(classname, player.index, model, player.GetArgI(this_plugin_name, OBJECTS_DEATH, "skin"), player.GetArgI(this_plugin_name, OBJECTS_DEATH, "count", 14), player.GetArgF(this_plugin_name, OBJECTS_DEATH, "distance", 30.0));
	}
}
