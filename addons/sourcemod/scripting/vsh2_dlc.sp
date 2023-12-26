#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <vsh2>
#include <morecolors>
#include <tf2attributes>        ///If we need to adjust anything outside of Vsh which doesnt always like tf2attributes.
#include <tf2items>
#include <tf2_stocks>
//#include <stocks>
#include <dhooks>
//#include <smlib>

enum struct ExtendedData {
	bool      vsh2;
	ConfigMap cfg;
	ConVar    melee_heal_building;
	ConVar    upgrademax_building;
	ConVar 	  upgrade_amount;
	ConVar    pyrometal;
    ConVar    DamageStab;
    ConVar    DamageMarket;
    ConVar    jumperammo;
    ConVar    jumperammo_nonmg;
    ConVar    GasPasser;
    ConVar    ThrusterAdd;
    ConVar    bfdrain;
    ConVar    stockboost;
    ConVar    KGBCritLength;
    ConVar    SHCCLength;
    ConVar    FTAA;
    ConVar    BrokenHale;
    ConVar    VSH2C_MedigunResetCvar;
    ConVar    HuntStunOverride;
    ConVar    MaxBossGlowTime;
	ConVar    CakeCond;
	ConVar    SteakCond;
	ConVar    MonkeyCond;
	ConVar    healthmult;
	ConVar 	  DLCPiss;
	ConVar    stickystart;
	ConVar 	  rockystart;
	ConVar 	  FanWar;
	float     health_boost;
}

/*
enum struct Token {
	char  lexeme[64];
	int   size;
	int   tag;
	float val;
}

enum struct LexState {
	Token tok;
	int   i;
	char  syms[11];
	float values[10];
}


enum {
	TokenInvalid = 0,
	TokenNum = 1,
	TokenLParen = 2,
	TokenRParen = 3,
	TokenLBrack = 4,
	TokenRBrack = 5,
	TokenPlus = 6,
	TokenSub = 7,
	TokenMul = 8,
	TokenDiv = 9,
	TokenPow = 10,
	TokenVar = 11,
	LEXEME_SIZE = 64,
	dot_flag = 1,
};
*/
//END OF VSH2CS MISC VARS

int BallEnt;
int SentryCounter;
bool IsAttackPasser;
//bool IsHuntsmanStun;
bool IsAttackSentry;
bool EnableBoostedSpeed;
float BoostArr[2];
new oldDisguise[MAXPLAYERS+1][3];
int scout_airdash_count[MAXPLAYERS+1];
int scout_airdash_value[MAXPLAYERS+1];
ExtendedData g_data;
float DamagePool;

public Plugin myinfo = {
	name        = "VSH2 DLC" ,
	author      = "DatOpb, Mub",
	description = "VSH2-E",
	version     = "1.0.1",
	url         = ""
};

public void OnLibraryAdded(const char[] name)
{
    if( StrEqual(name, "VSH2") ) {
        LoadVSH2Hooks();
    }
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("GetDamagePool", Native_GetDamagePool);
	CreateNative("SetDamagePool", Native_SetDamagePool);
	return APLRes_Success;
}


public void LoadVSH2Hooks()
{
    g_data.vsh2 = true;
    //g_data.cfg = new ConfigMap("configs/saxton_hale/vsh2extension.cfg"); WIP
    g_data.VSH2C_MedigunResetCvar = FindConVar("vsh2_medigun_reset_amount");
    if( !VSH2_HookEx(OnBossDealDamage, OBDD) )
		LogError("Error Hooking OnBossDealDamage forward for VSH2 Extension Plugin");
    if( !VSH2_HookEx(OnBossTakeDamage_OnStabbed, vshStab) )
		LogError("Error Hooking OnBossTakeDamage_OnStabbed forward for VSH2 Extension Plugin");
    if( !VSH2_HookEx(OnBossTakeDamage_OnMarketGardened, ExtMarket) )
		LogError("Error Hooking OnBossTakeDamage_OnMarketGardened forward for VSH2 Extension Plugin");
    if( !VSH2_HookEx(OnRedPlayerCrits, RedCritThink) )
		LogError("Error Hooking OnRedPlayerCrits forward for VSH2 Extension Plugin");
    if( !VSH2_HookEx(OnPrepRedTeam, BushJumper) )
		LogError("Error Hooking OnPrepRedTeam forward for VSH2 Extension Plugin");  
    if( !VSH2_HookEx(OnBossTakeDamage, vshBlurt) )
		LogError("Error Hooking OnBossTakeDamage forward for VSH2 Extension Plugin");
    if( !VSH2_HookEx(OnBossThink, vshHandles) )
		LogError("Error Hooking OnBossTakeDamage forward for VSH2 Extension Plugin");
    if( !VSH2_HookEx(OnRedPlayerThink, RedPlayThink) )
		LogError("Error Hooking OnBossTakeDamage forward for VSH2 Extension Plugin");
    if( !VSH2_HookEx(OnUberDeployed, GermanEngineering) )
		LogError("Error Hooking OnUberDeployed forward for VSH2 Extension Plugin");
    if( !VSH2_HookEx(OnBossTakeDamage_OnTelefragged, vshFrag) )
		LogError("Error Hooking OnUberDeployed forward for VSH2 Extension Plugin");
    if( !VSH2_HookEx(OnUberLoopEnd, OnEndUber) )
		LogError("Error Hooking OnUberLoopEnd forward for VSH2 Extension Plugin");
    if( !VSH2_HookEx(OnBossThink, BossBoy) )
	    LogError("Error Hooking OnBossThink forward for VSH2 Extension Plugin");
    if( !VSH2_HookEx(OnBossCalcHealth, BossCalcHealth) )
		LogError("Error Hooking OnBossCalcHealth forward for VSH2 Extension Plugin.");
    if( !VSH2_HookEx(OnBossTakeDamage_OnSniped, BossSniped) )
		LogError("Error Hooking OnBossTakeDamage_OnSniped forward for VSH2 Extension Plugin.");
    if( !VSH2_HookEx(OnRoundStart, OnNormStart) )
		LogError("Error Hooking OnUberDeployed forward.");
    if( !VSH2_HookEx(OnPlayerHurt, DLCRageGain) )
		LogError("Error Hooking OnPlayerHurt forward for DLC-VSH2 plugin.");

    if( !VSH2_HookEx(OnPlayerTakeFallDamage, OnTakeFallDmg) )
		LogError("Error Hooking OnPlayerTakeFallDamage forward.");
    if( !VSH2_HookEx(OnBossMedicCall, DLCRageReset) )
		LogError("Error Hooking OnBossMedicCall forward for VSH2 DLC plugin.");
    if( !VSH2_HookEx(OnPlayerAirblasted, DLCRageAirblast) )
		LogError("Error Hooking OnPlayerAirblasted forward for VSH2 DLC plugin.");
    if( !VSH2_HookEx(OnBossJarated, DLCPissed) )
		LogError("Error Hooking OnBossJarated forward for VSH2 DLC plugin.");
    if( !VSH2_HookEx(OnBossTakeDamage_OnHitFanOWar, DLCSucky) )
		LogError("Error Hooking OnBossTakeDamage_OnHitFanOWar forward for VSH2 DLC plugin.");
    if( !VSH2_HookEx(OnBossGiveRage, DLRageHookout) )
		LogError("Error Hooking OnBossGiveRage forward for VSH2 DLC plugin.");


    g_data.healthmult = CreateConVar("vsh2_bosshealth_base", "2250.0", "Hale Health Multiply Based on red player count, Def: 2000.0", FCVAR_NOTIFY, true, 1.0, true, 8000.0);
    g_data.MaxBossGlowTime = CreateConVar("vsh2_enforcer_glowtime", "5.0", "How long should enforcer glow time last, Def: 5.0", FCVAR_NOTIFY, true, 0.0, true, 150.0);
    g_data.melee_heal_building = CreateConVar("vsh2_heal_building", "50", "Pyro Heal buildings, Def: 50", FCVAR_NOTIFY, true, 0.0, true, 150.0);
    g_data.upgrademax_building = CreateConVar("vsh2_upgrademax_building", "100", "The max amount of metal a pyro can put in, Def: 100", FCVAR_NOTIFY, true, 0.0, true, 200.0);
    g_data.upgrade_amount	   = CreateConVar("vsh2_upgrade_amount", "15", "Pyro Upgrade Amount, Def: 15", FCVAR_NOTIFY, true, 0.0, true, 50.0);
    g_data.pyrometal		   = CreateConVar("vsh2_pyrometal", "200", "Pyro Metal Pool size, Def: 200", FCVAR_NOTIFY, true, 50.0, true, 200.0);
    g_data.BrokenHale = CreateConVar("vsh2_brokenhale_legs", "5.0", "How long should hales legs be stumps for?", FCVAR_NOTIFY, true, 0.0)
    g_data.FTAA = CreateConVar("vsh2_meleeammo_add", "100","How much ammo should a melee hit with the NH grant." , FCVAR_NOTIFY, true, 0.0);
    g_data.KGBCritLength = CreateConVar("vsh2_kgb_critlength", "5.0", "Number of seconds of crits gained from a KGB hit.", FCVAR_NOTIFY, true, 0.5, true, 10.0);
    g_data.SHCCLength = CreateConVar("vsh2_shcc_length", "1.0", "Number of seconds of Crit Canteen boost gained from a SH hit.", FCVAR_NOTIFY, true, 0.5, true, 10.0);
    g_data.DamageStab = CreateConVar("vsh2_backstab_damage", "2500.0", "How much fixed damage a spy should deal to the hale.", FCVAR_NOTIFY, true, 0.0);
    g_data.stockboost = CreateConVar("vsh2_stock_damage_boost", "250.0", "How much should the stock knife add on over the base backstab damage.", FCVAR_NOTIFY, true, 0.0);
    g_data.DamageMarket = CreateConVar("vsh2_marketgarden_damage", "1250", "How much fixed damage a solly market garden should deal to the hale.", FCVAR_NOTIFY, true, 0.0);
	///cdcloakdmg = CreateConVar("vsh2_cloakdagger_dmgtaken", "195", "How much fixed damage should a cloak and dagger spy take from the hale.", FCVAR_NOTIFY, true, 0.0);
    g_data.jumperammo = CreateConVar("vsh2_rocketjumperammo_mg", "8", "How much ammo should a rocket jumper soldier get from a market garden", FCVAR_NOTIFY, true, 0.0);
    g_data.jumperammo_nonmg = CreateConVar("vsh2_rocketjumperammo_nonmg", "4", "How much ammo should a rocket jumper soldier get from a market garden", FCVAR_NOTIFY, true, 0.0);
    g_data.GasPasser = CreateConVar("vsh2_gaspasser_dmg", "450.0", "How damage should a Gas Passer Ignite do. Def: 400.0", FCVAR_NOTIFY, true, 0.0);
    ///bfboost = CreateConVar("vsh2_bfb_boost_amount", "15.0", "How much boost should a BFB scout get from a melee hit.", FCVAR_NOTIFY, true, 0.0);
    g_data.bfdrain = CreateConVar("vsh2_bfb_drain_amount", "5.0", "How much should BFB meter drain per second.", FCVAR_NOTIFY, true, 0.0);
    g_data.HuntStunOverride = CreateConVar("vsh2_huntsman_stundmg", "750.0", "How much damage should huntsman stun do?", FCVAR_NOTIFY, true, 0.0);
    g_data.ThrusterAdd = CreateConVar("vsh2_thruster_charge_add", "2.5", "How much boost should thermal thruster get from a successful stomp.", FCVAR_NOTIFY, true, 0.0);
    g_data.SteakCond = CreateConVar("vsh2_steakcond_duration", "19.0", "How long should the steak cond last?");
    g_data.MonkeyCond = CreateConVar("vsh2_monkeycond_duration", "6.5", "How long should the MonkeyBanana Cond last?");
    g_data.DLCPiss = CreateConVar("vsh2_jarate_rageR", "200.0", "Hale Rage remove from Jarate, Def 200.0", FCVAR_NOTIFY, true, 1.0, true, 10000.0);
    g_data.CakeCond = CreateConVar("vsh2_cakecond_duration", "2.0", "How long should the Choc/Fish cond last?");
    g_data.FanWar = CreateConVar("vsh2_fanowar_rageR", "400.0", "Hale Rage remove on FanoWar, Def 400.0", FCVAR_NOTIFY, true, 1.0, true, 10000.0);
    g_data.stickystart = CreateConVar("vsh2_stickystart", "2", "How much ammo should a sticky jumper get at the start of the round.", FCVAR_NOTIFY, true, 0.0);
    g_data.rockystart = CreateConVar("vsh2_rockystart", "2", "How much ammo should a rocket jumper get at the start of the round.", FCVAR_NOTIFY, true, 0.0);
    HookEventEx("gas_doused_player_ignited", GasPasserDamage, EventHookMode_Pre);
    HookEventEx("teamplay_point_captured", ExtensionOnCap);	///Some strangeness is occuring in the VSH2 hook.
    AddNormalSoundHook(NormalSHook:Hook_EntitySound);			///Sound hook for homewrecker
    //HookEventEx("player_stunned", HuntsmanStun, EventHookMode_Pre);
}

public void OnLibraryRemoved(const char[] name)
{
	g_data.vsh2 = false;
	delete g_data.cfg;
}

///Custom Rage code.
public Action DLRageHookout(VSH2Player player, int damage, float& calcd_rage)
{
	return Plugin_Handled;
}

public Action DLCPissed(VSH2Player jarateed, VSH2Player jarateer)
{
	float GetDamPool = DamagePool;
	if (GetDamPool > float(g_data.DLCPiss.IntValue))
	{
		DamagePool = GetDamPool - float(g_data.DLCPiss.IntValue);
	}
	else
	{
		DamagePool = 0.0;
	}
	return Plugin_Continue;
}

public Action DLCRageGain(VSH2Player attacker, VSH2Player victim, Event event)
{
	int boss_type = victim.GetPropInt("iBossType");		///Fetches Hale Boss type (Used to verify if that player is a boss)
	if( victim.bIsBoss || boss_type > 0) {
		int damage = event.GetInt("damageamount");
		DamagePool += float(damage);
	}
	return Plugin_Continue;
}

public Action DLCSucky(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	float GetDamPool = DamagePool;
	if (GetDamPool > float(g_data.FanWar.IntValue))
	{
		DamagePool = GetDamPool - float(g_data.FanWar.IntValue);
	}
	else
	{
		DamagePool = 0.0;
	}
	return Plugin_Continue;
}
public Action DLCRageAirblast(VSH2Player airblaster, VSH2Player airblasted, Event event)
{
	float GetDamPool = DamagePool;
	DamagePool = GetDamPool + 600.0;
	///CPrintToChatAll("DamagePool %f", DamagePool)
	return Plugin_Continue;
}
public void DLCRageReset(const VSH2Player player)
{
	//int boss_type = player.GetPropInt("iBossType");
	///CPrintToChatAll("Damage Pool reset.")
	if (player.bIsBoss)
	{
		float curr_rage = player.GetPropFloat("flRAGE");
		if (curr_rage >= 100.0)
		{
			DamagePool = 0.0;
			TF2_AddCondition(player.index, TFCond_MegaHeal, 5.0);
			TF2_AddCondition(player.index, TFCond_InHealRadius, 5.0);
		}
	}
}
///---------------------------------------

//BOSS HEALTH FORMULA "THE SAXTON HALE SECRET FORMULA"
public Action BossCalcHealth(const VSH2Player player, int& max_health, const int boss_count, const int red_players)
{
	///int AdaptHealth = red_players * HealthMult.IntValue;
	max_health = red_players * ((g_data.healthmult.IntValue) * red_players/31) + (g_data.healthmult.IntValue * 2);
	return Plugin_Changed;
}

public void OnNormStart(const VSH2Player[] bosses, const int boss_count, const VSH2Player[] red_players, const int red_count)
{
	for(int client=1; client<=MaxClients; client++)
	{
		if ( !IsValidClient(client))
		{
			return;
		}
		VSH2Player gamer = VSH2Player(client);
		if ( !gamer.bIsBoss)
			CreateTimer(0.9, preroundsetammo, gamer);
	}
}

public Action preroundsetammo(Handle timer, VSH2Player gamer)
{
	int primary = GetPlayerWeaponSlot(gamer.index, TFWeaponSlot_Primary);
	int secondary = GetPlayerWeaponSlot(gamer.index, TFWeaponSlot_Secondary);
	if ( IsValidEntity(secondary) && GetItemIndex(secondary) == 265)		///S Jumper
	{
		SetAmmo(gamer.index, TFWeaponSlot_Secondary, 8);
		//PrintToServer("Sticky Jumper ammo call. %i", g_data.jumperammo.IntValue);
	}
	if ( IsValidEntity(primary) && GetItemIndex(primary) == 237)		///R Jumper
	{
		SetAmmo(gamer.index, TFWeaponSlot_Primary, 8);
		//PrintToServer("Rocket Jumper ammo call.");
	}
	return Plugin_Continue;
}

public Action OnTakeFallDmg(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)		///Class Specific Fall Damage controller.
{
	return Plugin_Changed;
}

public Action BossSniped(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	return Plugin_Changed;
}

public void ExtensionOnCap(Event event, const char[] name, bool dontBroadcast)
{
	if( VSH2GameMode.GetPropInt("iRoundState") != StateRunning)
	{
		return;
	}
	int iCapTeam = event.GetInt("team");

	if (iCapTeam == 3) //Blue, Aka boss team.
	{
		for (new i = 1; i <= 33; i++)
		{
			if(IsValidClient(i) && IsPlayerAlive(i))
			{
				VSH2Player Boss = VSH2Player(i);
				if (Boss.bIsBoss)
				{
					TF2_AddCondition(i, TFCond_RegenBuffed, 20.0);
					TF2_AddCondition(i, TFCond_Buffed, 20.0);
					EnableBoostedSpeed = true;
					CreateTimer(0.07, SetHaleSpeed, i, TIMER_REPEAT);
					CreateTimer(20.0, RemoveSpeed, i)
					CreateTimer(20.0, RemoveOutline, i)
				}
				if (GetClientTeam(i) == 2)  ///For the reds
				{
					//VSH2Player UnluckyTestSubject = VSH2Player(i);
					//UnluckyTestSubject.SetPropFloat("flGlowtime", 20.0)
					SetEntProp(i, Prop_Send, "m_bGlowEnabled", 1);
					CreateTimer(20.0, RemoveOutline, i)
				}
			}
		}
	}
	if (iCapTeam == 2) //Red, Aka Fighter Team.
	{
		for (new i = 1; i <= 33; i++)
		{
			if(IsValidClient(i) && IsPlayerAlive(i))
			{
				VSH2Player BadBoss = VSH2Player(i);
				if (GetClientTeam(i) == 2)  ///Targeting red team
				{
					TF2_AddCondition(i, TFCond_Buffed, 20.0);
					TF2_AddCondition(i, TFCond_RegenBuffed, 20.0);
					CreateTimer(20.1, ResetSpeed, i);
				}
				if (BadBoss.bIsBoss)  ///For the hale
				{
					//VSH2Player BadBoss = VSH2Player(i);
					BadBoss.SetPropFloat("flGlowtime", 20.0)
					//SetEntProp(BadBoss.index, Prop_Send, "m_bGlowEnabled", 1);
					//CreateTimer(20.0, RemoveOutline, BadBoss.index);
				}
			}
		}
	}
}

public Action ResetSpeed(Handle timer, int client)
{
	TF2_RecalculateSpeed(client);
	return Plugin_Continue;
}

public Action RemoveOutline(Handle timer, int client)
{
	SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);
	return Plugin_Continue;
}

public Action SetHaleSpeed(Handle timer, int client)
{
	if(!EnableBoostedSpeed)
	{
		return Plugin_Stop;
	}
	VSH2Player BadBoss = VSH2Player(client);
	BadBoss.SpeedThink(500.0);
	return Plugin_Continue;
}

public Action RemoveSpeed(Handle timer)
{
	EnableBoostedSpeed = false;
	return Plugin_Continue;
}
/**
Homewrecker code merged from the plugin Pyrogineer, all credits to the original author.
Link: "https://forums.alliedmods.net/showthread.php?t=282110"
**/

public Action Hook_EntitySound(int clients[64],
  int &numClients,
  char sample[PLATFORM_MAX_PATH],
  int &client,
  int &channel,
  float &volume,
  int &level,
  int &pitch,
  int &flags,
  char soundEntry[PLATFORM_MAX_PATH],
  int &seed) //Yes, a sound hook is literally the best way to hook this event.
{
	if(StrContains(sample, "cbar_hit1", false) != -1
	|| StrContains(sample, "cbar_hit2", false) != -1
	//|| StrContains(sample, "neon_sign_hit_world_01", false) != -1
	//|| StrContains(sample, "neon_sign_hit_world_02", false) != -1
	//|| StrContains(sample, "neon_sign_hit_world_03", false) != -1
	//|| StrContains(sample, "neon_sign_hit_world_04", false) != -1
	) //When a Homewrecker or Neon sign sound goes off
	{
		new Float:angles[3];
		new Float:eyepos[3];
		GetClientEyeAngles(client, angles);
		GetClientEyePosition(client, eyepos);
				
		TR_TraceRayFilter(eyepos, angles, MASK_SOLID_BRUSHONLY, RayType_Infinite, TraceRayDontHitSelf, client);
		new ent = TR_GetEntityIndex();

		if (IsValidEntity(ent))
		{
			decl Float:EntPos[3];
			decl Float:ClientPos[3];
			GetEntPropVector(ent, Prop_Send, "m_vecOrigin", EntPos);
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
			new Float:Distance = GetVectorDistance(EntPos, ClientPos, false);
			if (Distance < 100.0) //Make sure they're close enough to the building, it's pretty easy to trigger the sound without being in range
			{
				if(!IsValidEntity(ent))
				{
					return Plugin_Continue;
				}
				else
				{
					//CPrintToChat(client, "Building Hit! Client:%d Entity:%d", client, ent);
					BuildingHit(ent, client);
					return Plugin_Continue;
				}
			}
		}
	}
	///Start of Custom Heavy Lunchbox Code
	if(StrContains(sample, "SandwichEat09", false) != -1)
	{
        if ( !IsValidClient(client))
        {
            return Plugin_Stop;
        }
        int secondary = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
        int secint = GetItemIndex(secondary);
        if( IsValidEntity(secondary) && secint == 159 
        || IsValidEntity(secondary) && secint == 433 )       ///Chocolate and fish in a single cake is not real...
	    {
            TF2_AddCondition(client, TFCond_HalloweenQuickHeal, g_data.CakeCond.FloatValue)
            TF2_AddCondition(client, TFCond_MegaHeal, g_data.CakeCond.FloatValue)
	    }
        if( IsValidEntity(secondary) && secint == 311)		/// Knockout MfD Beef
	    {
            TF2_AddCondition(client, TFCond_RuneKnockout, g_data.SteakCond.FloatValue)
            TF2_AddCondition(client, TFCond_MarkedForDeath, g_data.SteakCond.FloatValue)         
            TF2_AddCondition(client, TFCond_Buffed, g_data.SteakCond.FloatValue)
	    }
        if( IsValidEntity(secondary) && secint == 1190)		/// Banana Crit Boost
	    {
            TF2_AddCondition(client, TFCond_CritCanteen, g_data.MonkeyCond.FloatValue)
            TF2_AddCondition(client, TFCond_Buffed, g_data.MonkeyCond.FloatValue)
	    }
    }
	///End of Custom Heavy Lunchbox Code
	return Plugin_Continue;
}

public Action:BuildingHit(ent, client) 
{
	new PlayerWeapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	new index = GetEntProp(PlayerWeapon, Prop_Send, "m_iItemDefinitionIndex");
	if (index == 153 || index == 466 ) //If using Homewrecker, Maul
	{
		decl String:classname[32];
		GetEdictClassname(ent, classname, sizeof(classname));
		if ((StrContains(classname, "obj_dispenser", false) != -1 || StrContains(classname, "obj_sentry", false) != -1) && (FindBuildingOwnerTeam(ent) == GetClientTeam(client)))
		{
			if  (GetEntPropFloat(ent, Prop_Send, "m_flPercentageConstructed") >= 1.0)
			{
				new health = GetEntProp(ent, Prop_Send, "m_iHealth");
				new maxhealth = GetEntProp(ent, Prop_Send, "m_iMaxHealth");
				new newhealth;
				
				if (health < maxhealth) //Heal building
				{
					newhealth = health + g_data.melee_heal_building.IntValue;
					
					if (newhealth > maxhealth)
						newhealth = maxhealth;
					
					SetEntProp(ent, Prop_Data, "m_iHealth", newhealth);
					SetEntProp(ent, Prop_Send, "m_iHealth", newhealth);
					
					return Plugin_Continue;
				}
				new buildlevel = GetEntProp(ent, Prop_Send, "m_iUpgradeLevel");
				new buildmetal = GetEntProp(ent, Prop_Send, "m_iUpgradeMetal");
				new metal = GetEntProp(client, Prop_Send, "m_iAmmo", _, 3);
				
				//CPrintToChat(client, "UpgLevel: %i | UpgMetal: %i | My Metal: %i | Constructed: %f", buildlevel, buildmetal, metal, Pconstructed);
				
				if (buildlevel < 3) //Don't build up max level building
				{
					if (metal >= g_data.upgrade_amount.IntValue) //Enough metal for a full hit
					{
						if (buildmetal+g_data.upgrade_amount.IntValue < g_data.upgrademax_building.IntValue) //If this hit won't make the building hit max upgrade level
						{
							SetEntProp(ent, Prop_Send, "m_iUpgradeMetal", buildmetal+g_data.upgrade_amount.IntValue);
							SetEntProp(client, Prop_Send, "m_iAmmo", metal-g_data.upgrade_amount.IntValue, _, 3);
								
							return Plugin_Continue;
						}
						else if (buildmetal+g_data.upgrade_amount.IntValue >= g_data.upgrademax_building.IntValue) // if it will take the building to max upgrade level (199)
						{
							SetEntProp(client, Prop_Send, "m_iAmmo", metal-(g_data.upgrademax_building.IntValue-buildmetal), _, 3);
							SetEntProp(ent, Prop_Send, "m_iUpgradeMetal", g_data.upgrademax_building.IntValue);
								
							return Plugin_Continue;
						}
					}
					else //if you have less than 25 metal
					{
						if (buildmetal+metal < g_data.upgrademax_building.IntValue) //If this hit won't make the building hit max upg level
						{
							SetEntProp(ent, Prop_Send, "m_iUpgradeMetal", buildmetal+metal);
							SetEntProp(client, Prop_Send, "m_iAmmo", 0, _, 3);
							
							return Plugin_Continue;
						}
						else //If it will make the building hit max upg level
						{
							SetEntProp(client, Prop_Send, "m_iAmmo", metal-(g_data.upgrademax_building.IntValue-buildmetal), _, 3);
							SetEntProp(ent, Prop_Send, "m_iUpgradeMetal", g_data.upgrademax_building.IntValue);
								
							return Plugin_Continue;
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}


public Action:Homewrecker_MetalHud(Handle:timer, client)
{
	if (IsClientValid(client) && IsPlayerAlive(client))
	{
		int melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		new Handle:metalHudText = CreateHudSynchronizer();
		new metal = GetEntProp(client, Prop_Send, "m_iAmmo", _, 3);
		SetHudTextParams(-1.0, 0.83, 0.35, 90, 255, 90, 255, 0, 0.2, 0.0, 0.1);
		ShowSyncHudText(client, metalHudText, "Metal: %i", metal);
		CloseHandle(metalHudText);
		if( TF2_GetPlayerClass(client) != TFClass_Pyro && (GetItemIndex(melee) == 153 || GetItemIndex(melee) == 466))
		{
			return Plugin_Stop;
		}
		VSH2Player gamer = VSH2Player(client);
		if( gamer.bIsBoss)
		{
			return Plugin_Stop;
		}
		CreateTimer(0.25, Homewrecker_MetalHud, client);
		
		return Plugin_Handled;
	}
	return Plugin_Handled;
}
public Action:TF2Items_OnGiveNamedItem(client, String:classname[], iItemDefinitionIndex, &Handle:hItem)
{
	switch (iItemDefinitionIndex)
	{
		case 153, 466:
		{	
			new String:MetalGiven[16] = "80 ; x.x";
			SetEntProp(client, Prop_Send, "m_iAmmo",g_data.pyrometal.IntValue , _, 3);
			CreateTimer(0.1, Homewrecker_MetalHud, client, TIMER_FLAG_NO_MAPCHANGE);
			ReplaceString(MetalGiven, sizeof(MetalGiven), "x.x", "2.0", false);
				
			new Handle:hItemOverride = PrepareItemHandle(hItem, _, _, MetalGiven);
			if (hItemOverride != INVALID_HANDLE)
			{
				hItem = hItemOverride;
				
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

stock Handle:PrepareItemHandle(Handle:hItem, String:name[] = "", index = -1, const String:att[] = "", bool:dontpreserve = false)
{
	static Handle:hWeapon;
	new addattribs = 0;

	new String:weaponAttribsArray[32][32];
	new attribCount = ExplodeString(att, " ; ", weaponAttribsArray, 32, 32);

	new flags = OVERRIDE_ATTRIBUTES;
	if (!dontpreserve) flags |= PRESERVE_ATTRIBUTES;
	if (hWeapon == INVALID_HANDLE) hWeapon = TF2Items_CreateItem(flags);
	else TF2Items_SetFlags(hWeapon, flags);
//	new Handle:hWeapon = TF2Items_CreateItem(flags);	//INVALID_HANDLE;
	if (hItem != INVALID_HANDLE)
	{
		addattribs = TF2Items_GetNumAttributes(hItem);
		if (addattribs > 0)
		{
			for (new i = 0; i < 2 * addattribs; i += 2)
			{
				new bool:dontAdd = false;
				new attribIndex = TF2Items_GetAttributeId(hItem, i);
				for (new z = 0; z < attribCount+i; z += 2)
				{
					if (StringToInt(weaponAttribsArray[z]) == attribIndex)
					{
						dontAdd = true;
						break;
					}
				}
				if (!dontAdd)
				{
					IntToString(attribIndex, weaponAttribsArray[i+attribCount], 32);
					FloatToString(TF2Items_GetAttributeValue(hItem, i), weaponAttribsArray[i+1+attribCount], 32);
				}
			}
			attribCount += 2 * addattribs;
		}
		CloseHandle(hItem);	//probably returns false but whatever
	}

	if (name[0] != '\0')
	{
		flags |= OVERRIDE_CLASSNAME;
		TF2Items_SetClassname(hWeapon, name);
	}
	if (index != -1)
	{
		flags |= OVERRIDE_ITEM_DEF;
		TF2Items_SetItemIndex(hWeapon, index);
	}
	if (attribCount > 0)
	{
		TF2Items_SetNumAttributes(hWeapon, (attribCount/2));
		new i2 = 0;
		for (new i = 0; i < attribCount && i2 < 16; i += 2)
		{
			TF2Items_SetAttribute(hWeapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
			i2++;
		}
	}
	else
	{
		TF2Items_SetNumAttributes(hWeapon, 0);
	}
	TF2Items_SetFlags(hWeapon, flags);
	return hWeapon;
}

stock FindBuildingOwnerTeam(ent)
{
	new owner = GetEntPropEnt(ent, Prop_Send, "m_hBuilder");
	new ownerteam = GetClientTeam(owner);
	return ownerteam;
}

//END OF HOMEWRECKER PLUGIN


//BEGIN VSH2CS MISC FUNCS
public void BossBoy(VSH2Player player)
{
    int client = player.index;
    int buttons = GetClientButtons(client);
    new Float:clientVel[3];
    Entity_GetAbsVelocity(client, clientVel);
    new Float:speed = GetVectorLength(clientVel);
    if(buttons & IN_DUCK && GetEntityFlags(client) & FL_ONGROUND && speed <= 250)
	{
		TF2_AddCondition(client, TFCond_MegaHeal, 1.0);
		TF2_AddCondition(client, TFCond_InHealRadius, 1.0);
	}
    new waterlevel = GetEntProp(client, Prop_Data, "m_nWaterLevel");
    if (waterlevel >= 2)
    {
		TF2_AddCondition(client, TFCond_MegaHeal, 1.0);
		TF2_AddCondition(client, TFCond_InHealRadius, 1.0);
	}
}

public Action HaltThemBastards(Handle timer, client)
{
	int buttons = GetClientButtons(client);
	if ( buttons == IN_JUMP)
	{
		return Plugin_Stop;
	}
	else{
		TF2_AddCondition(client, TFCond_MegaHeal, 0.2);
		TF2_AddCondition(client, TFCond_InHealRadius, 0.2);
	}
	return Plugin_Continue;
}

public Action OnEndUber(const VSH2Player medic, const VSH2Player target, float& charge)  ///Wep: Vita Saw Melee Code.
{
	int client = medic.index;
	int vitasaw = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if( vitasaw > MaxClients && IsValidEntity(vitasaw) && GetItemIndex(vitasaw)==173 ) {
		float def_charge = 41.0;
		if( g_data.cfg.GetFloat("ext.vitasaw post uber charge", def_charge) > 0 )
			charge = def_charge / 100.0;
	}
	return Plugin_Continue;
}



//END OF VSH2CS MISC

/*


WEP MODIFIER PLUGIN CODE SECTION


*/
public void TF2_OnConditionAdded(int client, TFCond condition)
{
    if ( condition == TFCond_Milked) 
	{
		SetConditionDuration (client, TFCond_Milked, 5.0)
	}	
    if( condition == TFCond_CritCola)
    {
        int iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
        if(!IsValidEntity(iWeapon)) 
            return;

        int index = GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex");
        if(index == 751) // The Cleaner's Carbine definition index
        {
			TF2_AddCondition(client, TFCond_CritOnWin, 8.0 )
        }
    }
    if ( condition == TFCond_CritHype) /// DOES NOT WORK STILL! :( USE JUMP LIMITER
	{
		TF2_AddCondition(client, TFCond_Buffed, 10.0 )
	}
    if ( IsValidClient(client) && TF2_GetPlayerClass(client) == TFClass_Spy)
	{
		if(condition == TFCond_Disguised )
		{
			oldDisguise[client][0] = GetEntProp(client, Prop_Send, "m_nDisguiseClass");
			oldDisguise[client][1] = GetEntProp(client, Prop_Send, "m_nDisguiseTeam");
			//oldDisguise[client][2] = GetEntProp(client, Prop_Send, "m_iDisguiseTargetIndex");
		}
	}
}

public void TF2_OnConditionRemoved(int client, TFCond condition)
{
	if( condition == TFCond_InHealRadius)
	{
		TF2_AddCondition(client, TFCond_HalloweenQuickHeal, 0.5 ) 
	}
}

public void OnEntityCreated(int entity, const char[] classname) 
{		///Sandman Ball hook.
    if(strcmp(classname, "tf_projectile_stun_ball") == 0) {
        SDKHook(entity, SDKHook_Touch, BallHit);
    }
}

public void BallHit(int entity, int other)  
{

	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");		///sets a global int to the entity value of the ball.
	if(entity == INVALID_ENT_REFERENCE || !IsValidEntity(entity))
		return;

	if (1 <= owner <= MaxClients && IsValidEntity(entity))
	{
		int ref = EntIndexToEntRef(entity);
		BallEnt = ref;
	}
}  

public Action GasPasserDamage(Event event, const char[] namep, bool dontBroadcast)
{
	///PrintToChatAll("Gas Passer attack");
	IsAttackPasser = true;
	return Plugin_Continue;
}

public void vshHandles(VSH2Player player)		///Check to ensure gas passer damage isnt carried over to another player once the gas effect expires.
{
    int client = player.index;
    int stunflag = GetEntProp(client, Prop_Send, "m_iStunFlags")
    int stunint = GetEntProp(client, Prop_Send, "m_iStunIndex")
    if ( !TF2_IsPlayerInCondition(client, TFCond_Gas))
	{
		IsAttackPasser = false;
	}
    if ( stunflag == 35 && stunint > -1)
	{
		TF2_AddCondition(client, TFCond_MegaHeal, 5.0);
		TF2_AddCondition(client, TFCond_InHealRadius, 5.0);
	}
    int buttons = GetClientButtons(client);
    new Float:clientVel[3];
    Entity_GetAbsVelocity(client, clientVel);
    new Float:speed = GetVectorLength(clientVel);
    if(buttons & IN_DUCK && GetEntityFlags(client) & FL_ONGROUND && speed <= 250)
	{
		TF2_AddCondition(client, TFCond_MegaHeal, 1.0);
		TF2_AddCondition(client, TFCond_InHealRadius, 1.0);
	}
    new waterlevel = GetEntProp(client, Prop_Data, "m_nWaterLevel");
    if (waterlevel >= 2)
    {
		TF2_AddCondition(client, TFCond_MegaHeal, 1.0);
		TF2_AddCondition(client, TFCond_InHealRadius, 1.0);
	}
}


public Action ExtMarket(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	int floater = g_data.DamageMarket.IntValue;
	int primary = GetPlayerWeaponSlot(attacker, TFWeaponSlot_Primary);
	int SetClipAmmo = GetAmmo(attacker, TFWeaponSlot_Primary) + g_data.jumperammo.IntValue;
	damage = float(floater / 3);
	if ( IsValidEntity(primary) && GetItemIndex(primary) == 237 )		///Check for if rocket jumper is equipped.
	{
		if (SetClipAmmo >= 20)
		{
			SetClipAmmo = 20;
		}
		SetAmmo(attacker, TFWeaponSlot_Primary, SetClipAmmo);			///Market Garden Ammo fill.
	}
	return Plugin_Changed;
}

///OnBossTakeDamage
public Action vshBlurt(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
    VSH2Player player = VSH2Player(attacker);
    int IsJumping = player.GetPropInt("bInJump");
    int primary = GetPlayerWeaponSlot(attacker, TFWeaponSlot_Primary);
    int secondary = GetPlayerWeaponSlot(attacker, TFWeaponSlot_Secondary);
    int melee = GetPlayerWeaponSlot(attacker, TFWeaponSlot_Melee);
    int wepindex = GetItemIndex(weapon);
	///Sentry KB experiment
    if (IsClientInGame(attacker)) {   
        char iAttackerObject[128];
        GetEdictClassname(inflictor, iAttackerObject, sizeof(iAttackerObject));
     
        // Sentry damage (bullets and rockets)
        if (StrEqual(iAttackerObject, "obj_sentrygun")) {		//Patch to reduce KB from sentries.
            if ( IsAttackSentry && SentryCounter < 3)
			{
				damagetype = DMG_PREVENT_PHYSICS_FORCE;
				SentryCounter += 1;
			}
			else{
				if ( SentryCounter >= 3)
				{
					IsAttackSentry = true;
					SentryCounter = 0;
				}
				else {
					SentryCounter += 1;
				}
			}
        }
    }
    if (wepindex == 224)
	{
		CreateTimer(0.02, FireDisguise, attacker);
	}
    if ( wepindex == 460)
	{
		float bossGlow = victim.GetPropFloat("flGlowtime");
		float time = (bossGlow > 10 ? 1.0 : 2.0);
		time += 2.0;
		bossGlow += RoundToCeil(time);
		float max_time_cap = g_data.MaxBossGlowTime.FloatValue;
		if( bossGlow > max_time_cap ) {
			bossGlow = max_time_cap;
		}
		//victim.flGlowtime = bossGlow;
		victim.SetPropFloat("flGlowtime", bossGlow)
	}
    if( IsValidEntity(primary) && damage == 1.0 && wepindex == 220)
	{
		damage = 37.0;
	}
    if( IsValidEntity(primary) && damage == 500.0 && (wepindex == 56 || wepindex == 1005 || wepindex == 1092) && TF2_GetPlayerClass(attacker) == TFClass_Sniper)
	{
		damage = (g_data.HuntStunOverride.FloatValue / 1.351728) + 1.0;
		damagetype = DMG_GENERIC;
	}
    if( IsValidEntity(melee) && wepindex == 43)		///Crits for sucessful KGB hit
	{
		TF2_AddCondition(attacker, TFCond_CritOnWin, g_data.KGBCritLength.FloatValue)
	}
    if( IsValidEntity(melee) && wepindex == 155)		///CritCanteen for successful SH hit.
	{
		TF2_AddCondition(attacker, TFCond_CritCanteen, g_data.SHCCLength.FloatValue)
	}
    if( IsValidEntity(primary) && !(GetEntityFlags(victim.index) & FL_ONGROUND) && wepindex == 127 && TF2_GetPlayerClass(attacker) == TFClass_Soldier)		///Experimental Minicrits for DH
	{
		damagetype = DMG_ACID;
	}
    if( IsValidEntity(secondary) && (wepindex == 812 || wepindex == 833) && TF2_IsPlayerInCondition(victim.index, TFCond_Dazed) &&TF2_GetPlayerClass(attacker) == TFClass_Scout)		///Cleaver crits
	{
		damagetype = DMG_ACID;
	}
    if( IsValidEntity(secondary) && !(GetEntityFlags(victim.index) & FL_ONGROUND) && wepindex == 415 && TF2_GetPlayerClass(attacker) == TFClass_Pyro)		///Experimental Minicrits for Reserve Shooter (pyro)
	{
		damagetype = DMG_ACID;
	}
    if( IsValidEntity(secondary) && !(GetEntityFlags(victim.index) & FL_ONGROUND) && wepindex == 415 && TF2_GetPlayerClass(attacker) == TFClass_Soldier)		///Experimental Minicrits for Reserve Shooter (solly)
	{
		damagetype = DMG_ACID;
	}
	/*
	///For the Caber Damage Boost.
    if ( IsValidEntity(melee) && TF2_GetPlayerClass(attacker) == TFClass_DemoMan && GetItemIndex(melee) == 307 && wepindex == 307 && damagecustom == TF_CUSTOM_STICKBOMB_EXPLOSION)
	{
		damage = CaberSmash.FloatValue;
		damagetype &= ~DMG_CRIT;
		FakeClientCommand(attacker, "explode");
	}
	*/
    if ( IsValidEntity(secondary) && TF2_GetPlayerClass(attacker) == TFClass_Pyro && GetItemIndex(secondary) == 1179) 
	{
		float ThrusterPre = GetEntPropFloat(attacker, Prop_Send, "m_flItemChargeMeter", 1)
		///PrintToChatAll("Chargemeter %f", GetEntPropFloat(attacker, Prop_Send, "m_flItemChargeMeter", 1))
		///CPrintToChatAll("FlameThrower Range? %i", FindSendPropInfo("CTFFlameThrower", "m_fMaxRange2"))
		if ( ThrusterPre <= 85.0)
			SetEntPropFloat(attacker, Prop_Send, "m_flItemChargeMeter", ThrusterPre + g_data.ThrusterAdd.FloatValue, 1)
		if ( ThrusterPre >= 85.0)
			SetEntPropFloat(attacker, Prop_Send, "m_flItemChargeMeter", 100.0, 1)
	}	
    if ( IsValidEntity(secondary) && TF2_GetPlayerClass(attacker) == TFClass_Pyro && GetItemIndex(secondary) == 1180) 
	{
		if (IsAttackPasser == true)
		{
			damage = g_data.GasPasser.FloatValue;
			damagetype &= ~DMG_CRIT;
			IsAttackPasser = false;
			TF2_AddCondition(victim.index, TFCond_Slowed, g_data.BrokenHale.FloatValue); ///Hale Slowness
			TF2_AddCondition(victim.index, TFCond_Dazed, g_data.BrokenHale.FloatValue); ///Hale Slowness
		}
	}
    if ( IsValidEntity(primary) && GetItemIndex(primary) == 237 )		///Check for if rocket jumper is equipped.
	{
		int SetClipAmmo = GetAmmo(attacker, TFWeaponSlot_Primary) + g_data.jumperammo_nonmg.IntValue;
		if (SetClipAmmo >= 20)
		{
			SetClipAmmo = 20;
		}
		switch(wepindex)
		{
			case 6,
			196, 
			128, 
			154, 
			264, 
			357, 
			416, 
			423, 
			447, 
			474, 
			775, 
			880, 
			939, 
			954,
			1013,
			1071,
			1123,
			1127,
			30758: {
				SetAmmo(attacker, TFWeaponSlot_Primary, SetClipAmmo);
			}
		}
    }
	//if( GetClientWeapon(player.index, cls, sizeof(cls)), !strncmp(cls, "tf_weapon_smg", 16, false)
    if ( GetItemIndex(primary) != 1178 && IsWeaponSlotActive(attacker, TFWeaponSlot_Melee)
		&& TF2_GetPlayerClass(attacker) == TFClass_Pyro && damage > 20.0)
    {
		int SetClipAmmo = GetAmmo(attacker, TFWeaponSlot_Primary) + g_data.FTAA.IntValue;
		if (SetClipAmmo >= 200)
		{
			SetClipAmmo = 200;
		}
		SetAmmo(attacker, TFWeaponSlot_Primary, SetClipAmmo);
	}
    if ( IsValidEntity(melee) && IsWeaponSlotActive(attacker, TFWeaponSlot_Melee) && GetItemIndex(primary) == 1178 && damage > 10.0) 		/// Neon check for if Dragon's Fury is equipped.
    {
		int SetClipAmmo = GetAmmo(attacker, TFWeaponSlot_Primary) + 20;
		if (SetClipAmmo >= 40)
		{
			SetClipAmmo = 40;
		}
		SetAmmo(attacker, TFWeaponSlot_Primary, SetClipAmmo);
	}
    if ( IsValidEntity(secondary) && GetItemIndex(secondary) == 265)		///Check for if sticky jumper is equipped.
	{
		int SetClipAmmoDemo = GetAmmo(attacker, TFWeaponSlot_Secondary) + g_data.jumperammo_nonmg.IntValue;
		if (SetClipAmmoDemo >= 20)
		{
			SetClipAmmoDemo = 20;
		}
		switch(wepindex)
		{
			case 1,
			191, 
			132, 
			154, 
			172, 
			264, 
			266, 
			307, 
			327, 
			357, 
			404, 
			423, 
			474, 
			482,
			609,
			880,
			939,
			954,
			1013,
			1071,
			1082,
			1123,
			1127,
			30758: {
				SetAmmo(attacker, TFWeaponSlot_Secondary, SetClipAmmoDemo);
			}
		}
	}
    if( IsJumping == 1 && wepindex == 609)			///Port of some Market Garden Code to enable Demo MG with the Scottish Handshake.
	{
		char name[MAX_BOSS_NAME_SIZE]; victim.GetName(name);
		int SetClipAmmo = GetAmmo(attacker, TFWeaponSlot_Secondary) + g_data.jumperammo.IntValue;
		damage = g_data.DamageMarket.FloatValue / 3;
		damagetype |= DMG_CRIT;
		PrintCenterText(victim.index, "You Were Just Market Gardened!");
		PrintCenterText(attacker, "You Market Gardened %s!", name);
		if (SetClipAmmo >= 20)
		{
			SetClipAmmo = 20;
		}
		SetAmmo(attacker, TFWeaponSlot_Secondary, SetClipAmmo - 2);			///Market Garden Ammo fill.
		EmitSoundToAll("player/doubledonk.wav", victim.index, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);	///Market Garden Sound.

	}
    if (IsValidEntity(melee) && TF2_GetPlayerClass(attacker) == TFClass_Scout && GetItemIndex(melee) == 44 && wepindex == 44) /// SANDMAN!
	{
		if (TF2_IsPlayerInCondition(victim.index, TFCond_Dazed))
		{
			int ballint = EntRefToEntIndex(BallEnt);
			AcceptEntityInput( ballint, "Kill");
			TF2_AddCondition(attacker, TFCond_CritCanteen, 3.0)
		}
	}
    return Plugin_Changed;
}

public Action vshStab(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	int wepindex = GetItemIndex(weapon);		///Spy Weapon Check.
	int floater = g_data.DamageStab.IntValue;
	if ( wepindex != 4){
		damage = float(RoundFloat(g_data.DamageStab.FloatValue) / 3);   //Pain and suffering.
	}
	if ( wepindex == 4 || 
	wepindex == 194 ||  
	wepindex == 638 ||
	wepindex == 665 ||
	wepindex == 727 ||
	wepindex == 423 ||
	wepindex == 794 ||
	wepindex == 803 ||
	wepindex == 883 ||
	wepindex == 892 ||
	wepindex == 901 ||
	wepindex == 910 ||
	wepindex == 959 ||
	wepindex == 968 ||
	wepindex == 1071 ||
	wepindex == 15062 || 
	wepindex == 15094 || 
	wepindex == 15095 || 
	wepindex == 15096 || 
	wepindex == 15118 || 
	wepindex == 15119 || 
	wepindex == 15143 || 
	wepindex == 15144 || 
	wepindex == 30758) {
		damage = float(RoundFloat(floater + g_data.stockboost.FloatValue) / 3) + 0.3;
	}
	if (wepindex == 225 || wepindex == 574)
	{
		CreateTimer(0.011, FireDisguise, attacker);
	}
	
	if (wepindex == 649)
	{
		TF2_AddCondition(attacker, TFCond_Stealthed, 2.0);
	}
	return Plugin_Changed;
}

public Action FireDisguise(Handle timer, client)
{
	if (!IsValidClient(client))
		return Plugin_Continue;
	FastDisguise(client, TFTeam:oldDisguise[client][1], TFClassType:oldDisguise[client][0], oldDisguise[client][2])
	return Plugin_Continue;
}

///RedPlayerCrits stuff
public Action RedCritThink(const VSH2Player player, int& crit_flags)
{
	int weapon = GetActiveWep(player.index);
	bool validwep = (weapon != -1 && IsValidEntity(weapon));
	if (validwep) {
		switch( GetItemIndex(weapon) ) {			///Remove Crits and Give Full crits;
			case 812, 154, 232, 56, 1005, 1092, 595, 43, 24, 93, 39, 1081: 
			{
				crit_flags = 0;
			}
			case 442:
			{
				crit_flags = CRITFLAG_FULL;
			}
		}
		if ( TF2_GetPlayerClass(player.index) == TFClass_DemoMan && GetItemIndex(GetPlayerWeaponSlot(player.index, TFWeaponSlot_Melee)) == GetItemIndex(weapon) && GetItemIndex(weapon) == 609) //Check for demo melee and disable crits if not 
		{
			crit_flags = 0;
			//PrintToChat(player.index, "Critflag value is %i", crit_flags);
		}
		else if ( TF2_GetPlayerClass(player.index) == TFClass_DemoMan && GetItemIndex(GetPlayerWeaponSlot(player.index, TFWeaponSlot_Melee)) == GetItemIndex(weapon) && GetItemIndex(weapon) != 609)
		{
			crit_flags = CRITFLAG_FULL;
			//PrintToChat(player.index, "Critflag value is %i", crit_flags);
		}
	}
	char cls[32];
	if( GetClientWeapon(player.index, cls, sizeof(cls)), !strncmp(cls, "tf_weapon_smg", 16, false) ) {
		crit_flags = CRITFLAG_FULL;
	}
	if( validwep && ( weapon == 23 
	|| weapon == 209
	|| weapon == 160
	|| weapon == 294
	|| weapon == 449
	|| weapon == 773
	|| weapon == 15013
	|| weapon == 15018
	|| weapon == 15035
	|| weapon == 15041
	|| weapon == 15046
	|| weapon == 15056
	|| weapon == 15060
	|| weapon == 15061
	|| weapon == 15100
	|| weapon == 15101
	|| weapon == 15102
	|| weapon == 15126
	|| weapon == 15148
	|| weapon == 30666 ) && TF2_GetPlayerClass(player.index) == TFClass_Scout) 
	{
		crit_flags = 0;
	}
	if( validwep && ( weapon == 24
	|| weapon == 210
	|| weapon == 61
	|| weapon == 161
	|| weapon == 224
	|| weapon == 460
	|| weapon == 525
	|| weapon == 1006
	|| weapon == 1142
	|| weapon == 15011
	|| weapon == 15027
	|| weapon == 15042
	|| weapon == 15051
	|| weapon == 15062
	|| weapon == 15063
	|| weapon == 15064
	|| weapon == 15103
	|| weapon == 15128
	|| weapon == 15127
	|| weapon == 15149)) 
	{
		crit_flags = 0;
	}
	if ( validwep && weapon == 10)	///Solly Shotty
	{
		crit_flags = CRITFLAG_MINI;
	}
	if ( validwep && weapon == 9)	///Engie Shotty
	{
		crit_flags = CRITFLAG_MINI;
	}
	if ( validwep && weapon == 12)	///Pyro Stock shotgun
	{
		crit_flags = CRITFLAG_MINI;
	}
	if ( validwep && weapon == 656 && TF2_IsPlayerInCondition(player.index, TFCond_CritCola)) 
	{
		crit_flags = CRITFLAG_FULL;
	}
	return Plugin_Changed;
}

public Action BushJumper(const VSH2Player player)
{
    int primary = GetPlayerWeaponSlot(player.index, TFWeaponSlot_Primary);
    if ( IsValidEntity(primary) && GetItemIndex(primary) == 237 )		///Check for if rocket jumper is equipped.
	{
		TF2Attrib_SetByDefIndex(player.index, 258, 1.0);
		TF2Attrib_SetByDefIndex(player.index, 421, 1.0);
	}
    return Plugin_Continue;
}

///OnUberDeployed	(Victim is medic, Attacker is healing target)
public Action GermanEngineering(const VSH2Player victim, const VSH2Player attacker)
{
	int medic = victim.index;
	int patient = attacker.index;
	int medigun = GetPlayerWeaponSlot(victim.index, TFWeaponSlot_Secondary);
	if( IsValidEntity(medigun) ) {
		char strMedigun[32]; GetEdictClassname(medigun, strMedigun, sizeof(strMedigun));
		if( !strcmp(strMedigun, "tf_weapon_medigun", false) ) {
			if ( GetItemIndex(medigun) == 29 || 
			GetItemIndex(medigun) == 211 ||
			GetItemIndex(medigun) == 35 ||
			GetItemIndex(medigun) == 663 ||
			GetItemIndex(medigun) == 796 ||
			GetItemIndex(medigun) == 805 ||
			GetItemIndex(medigun) == 885 ||
			GetItemIndex(medigun) == 894 || 
			GetItemIndex(medigun) == 903 || 
			GetItemIndex(medigun) == 912 ||
			GetItemIndex(medigun) == 961 ||
			GetItemIndex(medigun) == 970 ||
			GetItemIndex(medigun) == 15008 ||
			GetItemIndex(medigun) == 15010 ||
			GetItemIndex(medigun) == 15025 ||
			GetItemIndex(medigun) == 15039 ||
			GetItemIndex(medigun) == 15050 ||
			GetItemIndex(medigun) == 15078 ||
			GetItemIndex(medigun) == 15097 || 
			GetItemIndex(medigun) == 15121 ||
			GetItemIndex(medigun) == 15122 ||
			GetItemIndex(medigun) == 15123 ||
			GetItemIndex(medigun) == 15145 ||
			GetItemIndex(medigun) == 15146)
			{
				//TF2_AddCondition(medic, TFCond_RuneHaste, 0.5, medic);
				if( IsClientValid(patient) && IsPlayerAlive(patient) ) {
					//TF2_AddCondition(patient, TFCond_RuneHaste, 0.5, medic);
					victim.SetPropInt("iUberTarget", attacker.userid);
				} else {
					victim.SetPropInt("iUberTarget", 0);
				}
				CreateTimer(0.1, Timer_UberLoop, EntIndexToEntRef(medigun), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}
			if ( GetItemIndex(medigun) == 998)
			{
				CreateTimer(0.2, VaccHandle, medic);
			}
			if ( GetItemIndex(medigun) == 411)
			{
				TF2_AddCondition(medic, TFCond_HalloweenQuickHeal, 0.5, medic);
				if( IsClientValid(patient) && IsPlayerAlive(patient) ) {
					TF2_AddCondition(patient, TFCond_HalloweenQuickHeal, 0.5, medic);
					victim.SetPropInt("iUberTarget", attacker.userid);
				} else {
					victim.SetPropInt("iUberTarget", 0);
				}
				CreateTimer(0.1, Timer_UberLoop, EntIndexToEntRef(medigun), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	return Plugin_Handled;
}
public Action VaccHandle(Handle timer, medic)
{
	//PrintToChatAll("Vaccinator Deploy")
	VSH2Player med = VSH2Player(medic);
	int target = med.GetHealTarget();
	int medigun = GetPlayerWeaponSlot(medic, TFWeaponSlot_Secondary);
	if ( TF2_IsPlayerInCondition(medic, TFCond_UberBlastResist))
	{
		//PrintToChatAll("UberBR");
		TF2_RemoveCondition(medic, TFCond_UberBlastResist);
		TF2_AddCondition(medic, TFCond_CritOnWin, 2.5 )
		if( target > 0)
		{
			TF2_RemoveCondition(target, TFCond_UberBlastResist);
			TF2_AddCondition(target, TFCond_CritOnWin, 2.5 )
		}
	}
	if ( TF2_IsPlayerInCondition(medic, TFCond_UberBulletResist))
	{
		//PrintToChatAll("UberBulR");
		TF2_RemoveCondition(medic, TFCond_UberBulletResist);
		TF2_AddCondition(medic, TFCond_Ubercharged, 2.5 )
		if( target > 0)
		{
			TF2_RemoveCondition(target, TFCond_UberBulletResist);
			TF2_AddCondition(target, TFCond_Ubercharged, 2.5 )
		}
	}
	if ( TF2_IsPlayerInCondition(medic, TFCond_UberFireResist))
	{
		//PrintToChatAll("UberFR");
		TF2_RemoveCondition(medic, TFCond_UberFireResist);
		TF2_AddCondition(medic, TFCond_HalloweenQuickHeal, 2.5 )
		if( target > 0)
		{
			TF2_RemoveCondition(target, TFCond_UberFireResist);
			TF2_AddCondition(target, TFCond_HalloweenQuickHeal, 2.5 )
		}	
	}
	CreateTimer(0.1, Timer_UberLoop, EntIndexToEntRef(medigun), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}
public Action Timer_UberLoop(Handle timer, any medigunid)
{
	int medigun = EntRefToEntIndex(medigunid);
	if( medigun && IsValidEntity(medigun) && VSH2GameMode_GetProperty("iRoundState") == StateRunning ) {
		int medic = GetOwner(medigun);
		float charge = GetMediCharge(medigun);
		if( GetItemIndex(medigun) != 998)
		{
			if( charge > 0.05 ) {
			VSH2Player med = VSH2Player(medic);
			int target = med.GetHealTarget();
			//TF2_AddCondition(medic, TFCond_CritOnWin, 0.5);
			if( IsClientValid(target) && IsPlayerAlive(target) ) {
				//TF2_AddCondition(target, TFCond_CritOnWin, 0.5);

				med.hUberTarget = VSH2Player(GetClientUserId(target));
			} else {
				med.hUberTarget = VSH2Player(0);
			}
			} else if( charge < 0.05 ) {
			float reset_charge = g_data.VSH2C_MedigunResetCvar.FloatValue;
			SetPawnTimer(_ResetMediCharge, 3.0, EntIndexToEntRef(medigun), reset_charge);
			return Plugin_Stop;
			}
		}
		if( GetItemIndex(medigun) == 29 ||
		GetItemIndex(medigun) == 211 ||
		GetItemIndex(medigun) == 663 ||
		GetItemIndex(medigun) == 796 ||
		GetItemIndex(medigun) == 805 ||
		GetItemIndex(medigun) == 885 ||
		GetItemIndex(medigun) == 894 ||
		GetItemIndex(medigun) == 903 ||
		GetItemIndex(medigun) == 912 ||
		GetItemIndex(medigun) == 961 ||
		GetItemIndex(medigun) == 970 ||
		GetItemIndex(medigun) == 15008 ||
		GetItemIndex(medigun) == 15050 ||
		GetItemIndex(medigun) == 15078 ||
		GetItemIndex(medigun) == 15097 ||
		GetItemIndex(medigun) == 15121 ||
		GetItemIndex(medigun) == 15122 ||
		GetItemIndex(medigun) == 15123 ||
		GetItemIndex(medigun) == 15145 ||
		GetItemIndex(medigun) == 15146)
		{
			if( charge > 0.05 ) {
				VSH2Player med = VSH2Player(medic);
				int target = med.GetHealTarget();
				TF2_AddCondition(medic, TFCond_CritOnWin, 0.5);
				if( IsClientValid(target) && IsPlayerAlive(target) ) {
					TF2_AddCondition(target, TFCond_CritOnWin, 0.5);
				}
			}
		}
		if( GetItemIndex(medigun) == 998)
		{
			//VSH2Player med = VSH2Player(medic);
			//int target = med.GetHealTarget();
			if( charge < 0.05 ) {
				return Plugin_Stop;
			}
		}
		if (GetItemIndex(medigun) == 411)
		{
			if( charge > 0.05 ) {
				VSH2Player med = VSH2Player(medic);
				int target = med.GetHealTarget();
				TF2_AddCondition(medic, TFCond_HalloweenQuickHeal, 0.5);
				if( IsClientValid(target) && IsPlayerAlive(target) ) {
					TF2_AddCondition(target, TFCond_HalloweenQuickHeal, 0.5);
				}
			}
		}
	} else {
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

///RedPlayerThink
public void RedPlayThink(VSH2Player player)
{
    int client = player.index
    int primary = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
    int secondary = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
    int PDA = GetPlayerWeaponSlot(client, TFWeaponSlot_Building);
    char weapondata[64];
    GetClientWeapon(player.index, weapondata, sizeof(weapondata))
    if ( IsValidEntity(primary) && TF2_GetPlayerClass(client) == TFClass_Scout && GetItemIndex(primary) == 772) 
	{
		float booster = GetEntPropFloat(client, Prop_Send, "m_flHypeMeter");	///Fetches the scouts current boost amount. (To ensure no overflows)
		if ( booster > 1.0 )
		{
			SetEntPropFloat(client, Prop_Send, "m_flHypeMeter", booster - g_data.bfdrain.FloatValue);
			TF2_RecalculateSpeed(client);
		}
	}
    if( VSH2GameMode.AreScoutsLeft() ) 
	{
		TF2_AddCondition(client, view_as< TFCond >(42), 0.75);
	}
    if ( IsWeaponSlotActive(client, TFWeaponSlot_Building) && (GetItemIndex(PDA) == 735 
	|| GetItemIndex(PDA) == 736 
	|| GetItemIndex(PDA) == 933
	|| GetItemIndex(PDA) == 1080
	|| GetItemIndex(PDA) == 1102))
	{
		TF2_AddCondition(client, TFCond_CritCanteen, 0.5); /// TEST
	}
    if (IsValidEntity(secondary) && TF2_GetPlayerClass(client) == TFClass_Scout && GetItemIndex(secondary) == 46 || 1145) /// Bonk! Atomic Punch Cond Replacement (TEST) WORKS! NEEDS POLISH
	{
		if ( TF2_IsPlayerInCondition(client, TFCond_Bonked))
		{
			TF2_RemoveCondition(client, TFCond_Bonked);
			TF2_AddCondition(client, TFCond_RadiusHealOnDamage, 1.5 ) 
			TF2_AddCondition(client, TFCond_MarkedForDeath, 8.0 ) 
		}
	}
 
    if (IsValidEntity(primary) && TF2_GetPlayerClass(client) == TFClass_Scout && GetItemIndex(primary) == 772) /// Baby Face's Blaster Passive Cond Add-on
	{
		if ( IsPlayerAlive(client))
		{
			TF2_AddCondition(client, TFCond_Buffed, TFCondDuration_Infinite)
		}
		else
		{
			TF2_RemoveCondition(client, TFCond_Buffed)
		}
	}
    if (IsValidEntity(primary) && TF2_GetPlayerClass(client) == TFClass_Heavy && GetItemIndex(primary) == 41) /// Natascha Passive Cond Add-on
	{
		if ( IsPlayerAlive(client))
		{
			TF2_AddCondition(client, TFCond_Buffed, TFCondDuration_Infinite)
		}
		else
		{
			TF2_RemoveCondition(client, TFCond_Buffed)
		}
	}
    if (TF2_GetPlayerClass(client) == TFClass_Scout) {		//Adapted from Reverts plugin for handling HalloweenSpeedBoost Cond. 
	    int airdash_limit_new = 1;
	    int airdash_limit_old = 1; // multijumps allowed by game
	    int airdash_value = GetEntProp(client, Prop_Send, "m_iAirDash");
	    if (GetPlayerWeaponSlot(client, TFWeaponSlot_Melee) == 450) {
			if (GetActiveWep(client) == 450) {
				airdash_limit_old = 2;
				airdash_limit_new = 2;
			}
		}
	    if (TF2_IsPlayerInCondition(client, TFCond_CritHype) && GetActiveWep(client) != 450) {
			//PrintToChatAll("Hype Event Fired")
			airdash_limit_old = 2;
			airdash_limit_new = 2;
		}
	    if (airdash_value > scout_airdash_value[client]) {
			// airdash happened this frame			
			scout_airdash_count[client]++;
		} else {
			if ((GetEntityFlags(client) & FL_ONGROUND) != 0) {
				scout_airdash_count[client] = 0;
			}	
		}	
	    if (airdash_value >= 1) {
			if (
				airdash_value >= airdash_limit_old &&
				scout_airdash_count[client] < airdash_limit_new
			) {
				airdash_value = (airdash_limit_old - 1);
			}
							
			if (
				airdash_value < airdash_limit_old &&
				scout_airdash_count[client] >= airdash_limit_new
			) {
				airdash_value = airdash_limit_old;
			}
		}				
	    scout_airdash_value[client] = airdash_value;
						
	    if (airdash_value != GetEntProp(client, Prop_Send, "m_iAirDash")) {
			SetEntProp(client, Prop_Send, "m_iAirDash", airdash_value);
		}
	}
    if (TF2_GetPlayerClass(client) != TFClass_Scout) {		//Adapted from Reverts plugin for handling HalloweenSpeedBoost Cond. 
		int airdash_value_new = 1;
		if (TF2_IsPlayerInCondition(client, TFCond_HalloweenSpeedBoost)) {
			airdash_value_new = 1;
			SetEntProp(client, Prop_Send, "m_iAirDash", airdash_value_new);
			return;
		}					
		if (airdash_value_new != GetEntProp(client, Prop_Send, "m_iAirDash")) {
			SetEntProp(client, Prop_Send, "m_iAirDash", airdash_value_new);
		}
	}
}

public Action OBDD(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	int client = victim.index;
	int secondary = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if ( IsValidEntity(secondary) && TF2_GetPlayerClass(client) == TFClass_Heavy && TF2_IsPlayerInCondition(client, TFCond_CritCola))
	{
		damage = 170.0;
		damagetype = DMG_GENERIC;
	}
	if( victim.GetTFClass()==TFClass_DemoMan && IsValidEntity(victim.FindBack({405, 608}, 2)) ) {
		ScaleVector(damageForce, 9.0);
		return Plugin_Changed;
	}
	return Plugin_Changed;
}

public Action vshFrag(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//TF2_AddCondition(attacker, <something>, 20.0);
	TF2_AddCondition(attacker, TFCond_DefenseBuffed, 20.0);
	TF2_AddCondition(attacker, TFCond_MegaHeal, 20.0);
	TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, 20.0);
	TF2_AddCondition(attacker, TFCond_CritOnWin, 20.0);
	TF2_AddCondition(attacker, TFCond_UberchargedCanteen, 20.0);
	TF2_AddCondition(attacker, TFCond_HalloweenSpeedBoost, 20.0);
	SetEntProp(attacker, Prop_Send, "m_CollisionGroup", 2);
	CreateTimer(4.0, TeleCollisionReset, attacker)
	return Plugin_Continue;
}

public Action TeleCollisionReset(Handle timer, int client) {
	if( !IsClientValid(client) )
		return Plugin_Continue;
	
	/// Fix HHH's clipping.
	SetEntProp(client, Prop_Send, "m_CollisionGroup", 5);
	return Plugin_Continue;
}

///Some extra stocks
public Action blaster (Handle Timer)
{
	int attacker = RoundFloat(BoostArr[1]);
	float booster = BoostArr[0];
	SetEntPropFloat(attacker, Prop_Send, "m_flHypeMeter", booster);
	TF2_RecalculateSpeed(attacker);
	///PrintToChatAll("blasterrun func")
	return Plugin_Continue;
}


public void _ResetMediCharge(const int entid, const float val) {
	int medigun = EntRefToEntIndex(entid);
	if( medigun > MaxClients && IsValidEntity(medigun) ) {
		SetMediCharge(medigun, GetMediCharge(medigun) + val);
	}
}

stock TF2_RecalculateSpeed(client)
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);



//Function written by CHData
stock FastDisguise(iClient, TFTeam:iTeam, TFClassType:iClass, iTarget)
{
    if(!IsValidClient(iClient))
	{
		return;
	}
    //TF2_DisguisePlayer(iClient, iTeam, iClass); // SetEntProp(iClient, Prop_Send, "m_hDisguiseWeapon", iWeapon);

    SetEntProp(iClient, Prop_Send, "m_nDisguiseTeam", _:iTeam);
    SetEntProp(iClient, Prop_Send, "m_nMaskClass", _:iClass);
    SetEntProp(iClient, Prop_Send, "m_nDisguiseClass", _:iClass);
    SetEntProp(iClient, Prop_Send, "m_nDesiredDisguiseClass", _:iClass);
    //SetEntProp(iClient, Prop_Send, "m_iDisguiseTargetIndex", iTarget);

    SetEntProp(iClient, Prop_Send, "m_iDisguiseHealth", 125);
 
    TF2_AddCondition(iClient, TFCond_Disguised);
}
stock GetClassBaseHP(client)
{
	switch(TF2_GetPlayerClass(client))
	{
		case TFClass_Scout:		return 125;
		case TFClass_Soldier:	return 200;
		case TFClass_Pyro:		return 175;
		case TFClass_DemoMan:	return 175;
		case TFClass_Heavy:		return 300;
		case TFClass_Engineer:	return 125;
		case TFClass_Medic:		return 150;
		case TFClass_Sniper:	return 125;
		case TFClass_Spy:		return 125;
	}
	return 125;
}

stock bool IsValidClient(const int client, bool replaycheck=true)
{
	if( client <= 0 || client > MaxClients || !IsClientInGame(client) )
		return false;
	else if( GetEntProp(client, Prop_Send, "m_bIsCoaching") )
		return false;
	else if( replaycheck && (IsClientSourceTV(client) || IsClientReplay(client)) )
		return false;
	else if( TF2_GetPlayerClass(client)==TFClass_Unknown )
		return false;
	return true;
}

stock int GetOwner(const int ent)
{
	return( IsValidEntity(ent) ) ? GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") : -1;
}
stock int GetBuilder(const int ent)
{
	return( IsValidEntity(ent) ) ? GetEntPropEnt(ent, Prop_Send, "m_hBuilder") : -1;
}
stock int GetGroundEntity(const int client)
{
	return( IsValidClient(client) ) ? GetEntPropEnt(client, Prop_Send, "m_hGroundEntity") : -1;
}

stock int GetHealingTarget(const int client) {
	int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if( !IsValidEntity(medigun) ) {
		return -1;
	} else if( HasEntProp(medigun, Prop_Send, "m_bHealing")
			&& GetEntProp(medigun, Prop_Send, "m_bHealing")
		) {
		return GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
	}
	return -1;
}

stock int GetActiveWep(const int client) {
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	return( IsValidEntity(weapon) ) ? weapon : -1;
}

stock float GetMediCharge(const int medigun) {
	return( IsValidEntity(medigun) ) ? GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel") : -1.0;
}

stock void SetMediCharge(const int medigun, const float val) {
	if( IsValidEntity(medigun) ) {
		SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", val);
	}
}

stock int GetItemIndex(const int item)
{
	return( IsValidEntity(item) ) ? GetEntProp(item, Prop_Send, "m_iItemDefinitionIndex") : -1;
}

stock void SetPawnTimer(Function func, float thinktime = 0.1, any param1 = -999, any param2 = -999)
{
	DataPack thinkpack = new DataPack();
	thinkpack.WriteFunction(func);
	thinkpack.WriteCell(param1);
	thinkpack.WriteCell(param2);
	CreateTimer(thinktime, DoThink, thinkpack, TIMER_DATA_HNDL_CLOSE);
}

public Action DoThink(Handle t, DataPack pack)
{
	pack.Reset();
	Function fn = pack.ReadFunction();
	Call_StartFunction(null, fn);

	any param = pack.ReadCell();
	if( param != -999 )
		Call_PushCell(param);

	param = pack.ReadCell();
	if( param != -999 )
		Call_PushCell(param);

	Call_Finish();
	return Plugin_Continue;
}

stock bool IsClientValid(const int client) {
	return( 0 < client <= MaxClients && IsClientInGame(client) );
}

stock bool IsWeaponSlotActive(const int client, const int slot)
{
	return GetPlayerWeaponSlot(client, slot) == GetActiveWep(client);
}

stock void SetAmmo(const int client, const int slot, const int ammo)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	if( IsValidEntity(weapon) ) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(client, iAmmoTable+iOffset, ammo, 4, true);
	}
}
stock void SetClip(const int client, const int slot, const int ammo)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	if( IsValidEntity(weapon) ) {
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		SetEntData(weapon, iAmmoTable, ammo, 4, true);
	}
}
stock int GetAmmo(const int client, const int slot)
{
	if( !IsValidClient(client) )
		return 0;
	int weapon = GetPlayerWeaponSlot(client, slot);
	if( IsValidEntity(weapon) ) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		return GetEntData(client, iAmmoTable+iOffset);
	}
	return 0;
}
stock int GetClip(const int client, const int slot)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	if( IsValidEntity(weapon) ) {
		int AmmoClipTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		return GetEntData(weapon, AmmoClipTable);
	}
	return 0;
}

stock void SetConditionDuration(const int client, const TFCond cond, const float duration)
{
	if( !TF2_IsPlayerInCondition(client, cond) )
		return;
	
	int m_Shared = FindSendPropInfo("CTFPlayer", "m_Shared");
	Address aCondSource   = view_as< Address >(LoadFromAddress(GetEntityAddress(client) + view_as< Address >(m_Shared + 8), NumberType_Int32));
	Address aCondDuration = view_as< Address >(view_as< int >(aCondSource) + (view_as< int >(cond) * 20) + (2 * 4));
	StoreToAddress(aCondDuration, view_as< int >(duration), NumberType_Int32);
}

public bool TraceRayDontHitSelf(int entity, int mask, any data) {
	return( entity != data );
}

stock Entity_GetAbsVelocity(entity, Float:vec[3])
{
	GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vec);
}

any Native_GetDamagePool(Handle plugin, int params)
{
	return DamagePool;
}

any Native_SetDamagePool(Handle plugin, int params)
{
	DamagePool = view_as<float>(GetNativeCell(1));
	return Plugin_Continue;
}