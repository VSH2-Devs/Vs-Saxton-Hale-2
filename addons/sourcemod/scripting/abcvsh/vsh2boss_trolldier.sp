#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <vsh2>

#undef REQUIRE_PLUGIN
#tryinclude <tf2attributes>
#define REQUIRE_PLUGIN


#define TrolldierModel    "models/player/trolldier.mdl"

/// voicelines
char TrolldierIntro[][] = {
	"trolldier/intro1.mp3",
	"trolldier/intro2.mp3"
};

char TrolldierThemes[][] = {
	"trolldier/fly_frank_sinatra.mp3",
	"trolldier/maggot_kombat.mp3",
	"trolldier/rocktronica_quake_3_arena.mp3",
	"trolldier/rocket_jump_waltz.mp3",
};

float TrolldierThemesTime[] = {
	197.0,
	77.0,
	252.0,
	360.0
};


public Plugin myinfo = {
	name = "VSH2 Trolldier Module",
	author = "Nergal/Assyrian",
	description = "",
	version = "1.0",
	url = "sus"
};

int g_iTrolldierID;

ConVar
	g_vsh2_scout_rage_gen,
	g_vsh2_airblast_rage,
	g_vsh2_jarate_rage
;

public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		g_vsh2_scout_rage_gen = FindConVar("vsh2_scout_rage_gen");
		g_vsh2_airblast_rage = FindConVar("vsh2_airblast_rage");
		g_vsh2_jarate_rage = FindConVar("vsh2_jarate_rage");
		g_iTrolldierID = VSH2_RegisterPlugin("trolldier");
		LoadVSH2Hooks();
	}
}

public void LoadVSH2Hooks()
{
	if( !VSH2_HookEx(OnCallDownloads, Trolldier_OnCallDownloads) )
		LogError("Error loading OnCallDownloads forwards for Trolldier subplugin.");
	
	if( !VSH2_HookEx(OnBossMenu, Trolldier_OnBossMenu) )
		LogError("Error loading OnBossMenu forwards for Trolldier subplugin.");
	
	if( !VSH2_HookEx(OnBossSelected, Trolldier_OnBossSelected) )
		LogError("Error loading OnBossSelected forwards for Trolldier subplugin.");
	
	if( !VSH2_HookEx(OnBossThink, Trolldier_OnBossThink) )
		LogError("Error loading OnBossThink forwards for Trolldier subplugin.");
	
	if( !VSH2_HookEx(OnBossModelTimer, Trolldier_OnBossModelTimer) )
		LogError("Error loading OnBossModelTimer forwards for Trolldier subplugin.");
	
	if( !VSH2_HookEx(OnBossEquipped, Trolldier_OnBossEquipped) )
		LogError("Error loading OnBossEquipped forwards for Trolldier subplugin.");
	
	if( !VSH2_HookEx(OnBossInitialized, Trolldier_OnBossInitialized) )
		LogError("Error loading OnBossInitialized forwards for Trolldier subplugin.");
	
	if( !VSH2_HookEx(OnBossPlayIntro, Trolldier_OnBossPlayIntro) )
		LogError("Error loading OnBossPlayIntro forwards for Trolldier subplugin.");
	
	if( !VSH2_HookEx(OnPlayerKilled, Trolldier_OnPlayerKilled) )
		LogError("Error loading OnPlayerKilled forwards for Trolldier subplugin.");
	
	if( !VSH2_HookEx(OnPlayerHurt, Trolldier_OnPlayerHurt) )
		LogError("Error loading OnPlayerHurt forwards for Trolldier subplugin.");
	
	//if( !VSH2_HookEx(OnPlayerAirblasted, Trolldier_OnPlayerAirblasted) )
	//	LogError("Error loading OnPlayerAirblasted forwards for Trolldier subplugin.");
	
	//if( !VSH2_HookEx(OnBossMedicCall, Trolldier_OnBossMedicCall) )
	//	LogError("Error loading OnBossMedicCall forwards for Trolldier subplugin.");
	
	//if( !VSH2_HookEx(OnBossTaunt, Trolldier_OnBossMedicCall) )
	//	LogError("Error loading OnBossTaunt forwards for Trolldier subplugin.");
	
	//if( !VSH2_HookEx(OnBossJarated, Trolldier_OnBossJarated) )
	//	LogError("Error loading OnBossJarated forwards for Trolldier subplugin.");
	
	if( !VSH2_HookEx(OnRoundEndInfo, Trolldier_OnRoundEndInfo) )
		LogError("Error loading OnRoundEndInfo forwards for Trolldier subplugin.");
	
	//if( !VSH2_HookEx(OnBossTakeDamage_OnMarketGardened, Trolldier_Countered) )
	//	LogError("Error loading OnBossTakeDamage_OnMarketGardened forwards for Trolldier subplugin.");
	
	if( !VSH2_HookEx(OnBossTakeFallDamage, TrolldierStompBuilding) )
		LogError("Error loading OnBossTakeFallDamage forwards for Trolldier subplugin.");
	
	if( !VSH2_HookEx(OnBossDealDamage, Trolldier_DoMarketGarden) )
		LogError("Error loading OnBossDealDamage forwards for Trolldier subplugin.");
	
	if( !VSH2_HookEx(OnBossDealDamage_OnHitMedic, Trolldier_DoMarketGarden) )
		LogError("Error loading OnBossDealDamage_OnHitMedic forwards for Trolldier subplugin.");
	
	if( !VSH2_HookEx(OnMusic, TrolldierMusic) )
		LogError("Error loading OnBossDealDamage forwards for Trolldier subplugin.");
	
	if( !VSH2_HookEx(OnBossCalcHealth, TrolldierHealth) )
		LogError("Error loading OnBossCalcHealth forwards for Trolldier subplugin.");
	
	if( !VSH2_HookEx(OnBossDealDamage_OnHitShield, Trolldier_DoMarketGarden) )
		LogError("Error loading OnBossDealDamage_OnHitShield forwards for Trolldier subplugin.");
}

stock bool IsTrolldier(const VSH2Player player) {
	return player.GetPropInt("iBossType") == g_iTrolldierID;
}


public void Trolldier_OnCallDownloads()
{
	PrepareModel(TrolldierModel);
	DownloadSoundList(TrolldierIntro, sizeof(TrolldierIntro));
	DownloadSoundList(TrolldierThemes, sizeof(TrolldierThemes));
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/eyeball_l");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/eyeball_r");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/normal_blue");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/shirtless_blue");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/sh_soldier_normal");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/soldier_blue");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/soldier_head_blue");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/soldier_normal");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/soldier_normal_vest");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/soldier_sfm_hands");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/suit");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/suit_blue");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/suit_n");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/vest_blue");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/zipper");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/zipper_blue");
	PrepareMaterial("materials/models/maxxy/enhanced_soldier_v2/zipper_n");
}

public void Trolldier_OnBossMenu(Menu &menu)
{
	char tostr[10]; IntToString(g_iTrolldierID, tostr, sizeof(tostr));
	menu.AddItem(tostr, "Trolldier (_STAR)");
}

public void Trolldier_OnBossSelected(const VSH2Player player)
{
	if( !IsTrolldier(player) )
		return;
	
	Panel panel = new Panel();
	panel.SetTitle("Trolldier: Rocket Jump & Market Garden everybody to death!\nRocket Jumper.\nAnti-Sentry Shotgun, useful for enemies in tight spaces.\nOne-shotting Market Gardener:\n * Can also Reverse Market Garden (smack someone when they're in the air).\n * Pierces Shields.\n");
	panel.DrawItem("Exit");
	panel.Send(player.index, HintPanel, 90);
	delete panel;
}

public void Trolldier_OnBossThink(const VSH2Player player)
{
	int client = player.index;
	if( !IsPlayerAlive(client) || !IsTrolldier(player) )
		return;
	
	int jumper = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	if( jumper != -1 )
		SetWeaponClip(jumper, 4);
	
	int shotgun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if( shotgun != -1 )
		SetWeaponAmmo(shotgun, 32);
	
	SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", 240.0);
	VSH2_GlowThink(player, 0.1);
	if( VSH2_SuperJumpThink(player, 2.5, 25.0) ) {
		player.SuperJump(player.GetPropFloat("flCharge"), -100.0);
		player.SetPropAny("bInJump", true);
	}
	
	//if( OnlyScoutsLeft(VSH2Team_Red) )
	//	player.flRAGE += g_vsh2_scout_rage_gen.FloatValue;
	
	VSH2_WeighDownThink(player, 10.0, 0.1);
	
	if( GetEntityFlags(client) & FL_ONGROUND )
		player.SetPropAny("bInJump", false);
	
	/// hud code
	SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
	Handle hud = VSH2GameMode_GetHUDHandle();
	float jmp = player.GetPropFloat("flCharge");
	ShowSyncHudText(client, hud, "Jump: %i%%", player.GetPropInt("bSuperCharge") ? 1000 : RoundFloat(jmp) * 4);
}

public void Trolldier_OnBossModelTimer(const VSH2Player player)
{
	if( !IsTrolldier(player) )
		return;
	int client = player.index;
	SetVariantString(TrolldierModel);
	AcceptEntityInput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
}

public void Trolldier_OnBossEquipped(const VSH2Player player)
{
	if( !IsTrolldier(player) )
		return;
	
	player.RemoveAllItems();
	player.SetName("The Trolldier (_STAR)");
	player.SpawnWeapon("tf_weapon_shovel", 416, 100, 5, "267 ; 1 ; 114 ; 1 ; 265 ; 999 ; 179 ; 1 ; 259 ; 1 ; 360 ; 1 ; 329 ; 0.0; 68 ; 2.0");
	int wep = player.SpawnWeapon("tf_weapon_shotgun_soldier", 10, 100, 5, "4 ; 1.67; 137 ; 3.0; 25 ; 0.0");
	wep = player.SpawnWeapon("tf_weapon_rocketlauncher", 237, 100, 5, "1 ; 0.0 ; 181 ; 2.0 ; 37 ; 0.0 ; 252 ; 0.0 ; 169 ; 0.75");
	SetEntPropEnt(player.index, Prop_Send, "m_hActiveWeapon", wep);
}

public void Trolldier_OnBossInitialized(const VSH2Player player)
{
	if( !IsTrolldier(player) )
		return;
	SetEntProp(player.index, Prop_Send, "m_iClass", view_as<int>(TFClass_Soldier));
}

public void Trolldier_OnBossPlayIntro(const VSH2Player player)
{
	if( !IsTrolldier(player) )
		return;
	player.PlayVoiceClip(TrolldierIntro[GetRandomInt(0, sizeof(TrolldierIntro)-1)], VSH2_VOICE_INTRO);
}

public void Trolldier_OnPlayerKilled(const VSH2Player attacker, const VSH2Player victim, Event event)
{
	//int deathflags = event.GetInt("death_flags");
	victim.SetPropInt("iLives", 0);
}
public void Trolldier_OnPlayerHurt(const VSH2Player attacker, const VSH2Player victim, Event event)
{
	//int damage = event.GetInt("damageamount");
	//if( IsTrolldier(victim) && victim.GetPropInt("bIsBoss") )
	//	victim.GiveRage(damage);
}
public void Trolldier_OnPlayerAirblasted(const VSH2Player airblaster, const VSH2Player airblasted, Event event)
{
	if( !IsTrolldier(airblasted) )
		return;
	//float rage = airblasted.GetPropFloat("flRAGE");
	//airblasted.SetPropFloat("flRAGE", rage + g_vsh2_airblast_rage.FloatValue);
}
public void Trolldier_OnBossMedicCall(const VSH2Player rager)
{
	if( !IsTrolldier(rager) )
		return;
	/*
	float rage = rager.GetPropFloat("flRAGE");
	if( rage < 100.0 )
		return;
	
	ToCPlague(rager).RageAbility();
	rager.SetPropFloat("flRAGE", 0.0);
	*/
}
public void Trolldier_OnBossJarated(const VSH2Player victim, const VSH2Player thrower)
{
	if( !IsTrolldier(victim) )
		return;
	//float rage = victim.GetPropFloat("flRAGE");
	//victim.SetPropFloat("flRAGE", rage - g_vsh2_jarate_rage.FloatValue);
}


public void Trolldier_OnRoundEndInfo(const VSH2Player player, bool boss_win, char message[MAXMESSAGE])
{
	if( !IsTrolldier(player) )
		return;
	else if( boss_win ) {
		/// play Boss Wins sounds here!
	}
}
/*
public Action Trolldier_Countered(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if( !IsTrolldier(victim) )
		return Plugin_Continue;
	
	damage *= 1.5;
	return Plugin_Changed;
}
*/

public Action Trolldier_DoMarketGarden(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VSH2Player trolldier = VSH2Player(attacker);
	if( !IsTrolldier(trolldier) )
		return Plugin_Continue;
	
	bool injump = trolldier.GetPropAny("bInJump");
	if( (injump || !(GetEntityFlags(victim.index) & FL_ONGROUND)) && weapon == GetPlayerWeaponSlot(attacker, TFWeaponSlot_Melee) ) {
		damage = GetClientHealth(victim.index)+1.0;
		EmitSoundToClient(attacker, "player/doubledonk.wav");
		EmitSoundToClient(victim.index, "player/doubledonk.wav");
		return Plugin_Changed;
	}
	return Plugin_Continue;
}


public void TrolldierMusic(char song[PLATFORM_MAX_PATH], float &time, const VSH2Player player)
{
	if( !IsTrolldier(player) )
		return;
	
	int theme = GetRandomInt(0, sizeof(TrolldierThemes)-1);
	Format(song, sizeof(song), "%s", TrolldierThemes[theme]);
	time = TrolldierThemesTime[theme];
}

public void TrolldierHealth(const VSH2Player player, int& max_health, const int boss_count, const int red_players)
{
	if( !IsTrolldier(player) )
		return;
	
	max_health += (red_players * 500);
}

public Action TrolldierStompBuilding(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VSH2Player trolldier = VSH2Player(attacker);
	if( !IsTrolldier(trolldier) )
		return Plugin_Continue;
	
	int building = GetEntPropEnt(attacker, Prop_Send, "m_hGroundEntity");
	if( building > MaxClients && IsValidEntity(building) ) {
		char ent[5];
		if( GetEntityClassname(building, ent, sizeof(ent)), !StrContains(ent, "obj_") ) {
			damage = 1.0;
			if( GetEntProp(building, Prop_Send, "m_iTeamNum") != GetClientTeam(attacker) )
				SDKHooks_TakeDamage(building, attacker, 0, 500.0, DMG_CLUB);
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}


stock bool IsValidClient(const int client, bool nobots=false)
{ 
	if( client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)) )
		return false; 
	return IsClientInGame(client); 
}

stock int GetSlotFromWeapon(const int iClient, const int iWeapon)
{
	for( int i; i<5; i++ )
		if( iWeapon == GetPlayerWeaponSlot(iClient, i) )
			return i;
	return -1;
}

stock bool OnlyScoutsLeft(const int team)
{
	for( int i=MaxClients; i; --i ) {
		if( !IsValidClient(i) || !IsPlayerAlive(i) )
			continue;
		else if( GetClientTeam(i) == team && TF2_GetPlayerClass(i) != TFClass_Scout )
			return false;
	}
	return true;
}

stock void SetWeaponAmmo(const int weapon, const int ammo)
{
	int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if( owner <= 0 )
		return;
	else if( IsValidEntity(weapon) ) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(owner, iAmmoTable+iOffset, ammo, 4, true);
	}
}
stock int SetWeaponClip(const int weapon, const int ammo)
{
	if( IsValidEntity(weapon) ) {
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		SetEntData(weapon, iAmmoTable, ammo, 4, true);
	}
	return 0;
}


public int HintPanel(Menu menu, MenuAction action, int param1, int param2)
{
	return;
}
