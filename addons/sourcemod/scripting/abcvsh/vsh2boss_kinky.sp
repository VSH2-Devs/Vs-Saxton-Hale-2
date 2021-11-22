#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <vsh2>

#undef REQUIRE_PLUGIN
#tryinclude <tf2attributes>
#define REQUIRE_PLUGIN


#define KinkyModel    "models/capnkinky/capnkinky.mdl"
//#define KinkyJump     "capnkinky/jump.wav"

/// voicelines
char KinkyIntro[][] = {
	"capnkinky/start1.mp3",
	"capnkinky/start2.mp3",
	"capnkinky/start3.mp3",
	"capnkinky/start4.mp3",
	"capnkinky/start5.mp3"
};

char KinkyJump[][] = {
	"capnkinky/jump.mp3"
};

char KinkyStab[][] = {
	"capnkinky/stab1.mp3"
};

char KinkyDeath[][] = {
	"capnkinky/death1.mp3",
	"capnkinky/death2.mp3"
};

char KinkyLast[][] = {
	"capnkinky/lastguy1.mp3",
	"capnkinky/lastguy2.mp3",
	"capnkinky/lastguy3.mp3",
	"capnkinky/lastguy4.mp3",
	"capnkinky/lastguy5.mp3"
};

char KinkyRage[][] = {
	"capnkinky/rage1.mp3",
	"capnkinky/rage2.mp3"
};

char KinkySpree[][] = {
	"capnkinky/spree1.mp3",
	"capnkinky/spree2.mp3",
	"capnkinky/spree3.mp3",
	"capnkinky/spree4.mp3"
};

char KinkyWin[][] = {
	"capnkinky/win1.mp3",
	"capnkinky/win2.mp3",
	"capnkinky/win3.mp3",
	"capnkinky/win4.mp3"
};

char KinkyThemes[][] = {
	"capnkinky/sexyback.mp3",
	"capnkinky/king_conga_crypt_of_the_necrodancer.mp3",
	"capnkinky/pac_baby.mp3",
};

float KinkyThemesTime[] = {
	145.0,
	193.0,
	166.0
};


public Plugin myinfo = {
	name = "VSH2 Kinky Module",
	author = "Nergal/Assyrian",
	description = "",
	version = "1.0",
	url = "sus"
};

int g_iKinkyID;

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
		g_iKinkyID = VSH2_RegisterPlugin("capnkinky");
		LoadVSH2Hooks();
	}
}

public void LoadVSH2Hooks()
{
	if( !VSH2_HookEx(OnCallDownloads, Kinky_OnCallDownloads) )
		LogError("Error loading OnCallDownloads forwards for Kinky subplugin.");
	
	if( !VSH2_HookEx(OnBossMenu, Kinky_OnBossMenu) )
		LogError("Error loading OnBossMenu forwards for Kinky subplugin.");
	
	if( !VSH2_HookEx(OnBossSelected, Kinky_OnBossSelected) )
		LogError("Error loading OnBossSelected forwards for Kinky subplugin.");
	
	if( !VSH2_HookEx(OnBossThink, Kinky_OnBossThink) )
		LogError("Error loading OnBossThink forwards for Kinky subplugin.");
	
	if( !VSH2_HookEx(OnBossModelTimer, Kinky_OnBossModelTimer) )
		LogError("Error loading OnBossModelTimer forwards for Kinky subplugin.");
	
	if( !VSH2_HookEx(OnBossEquipped, Kinky_OnBossEquipped) )
		LogError("Error loading OnBossEquipped forwards for Kinky subplugin.");
	
	if( !VSH2_HookEx(OnBossInitialized, Kinky_OnBossInitialized) )
		LogError("Error loading OnBossInitialized forwards for Kinky subplugin.");
	
	if( !VSH2_HookEx(OnBossPlayIntro, Kinky_OnBossPlayIntro) )
		LogError("Error loading OnBossPlayIntro forwards for Kinky subplugin.");
	
	if( !VSH2_HookEx(OnPlayerKilled, Kinky_OnPlayerKilled) )
		LogError("Error loading OnPlayerKilled forwards for Kinky subplugin.");
	
	if( !VSH2_HookEx(OnPlayerHurt, Kinky_OnPlayerHurt) )
		LogError("Error loading OnPlayerHurt forwards for Kinky subplugin.");
	
	if( !VSH2_HookEx(OnPlayerAirblasted, Kinky_OnPlayerAirblasted) )
		LogError("Error loading OnPlayerAirblasted forwards for Kinky subplugin.");
	
	if( !VSH2_HookEx(OnBossMedicCall, Kinky_OnBossMedicCall) )
		LogError("Error loading OnBossMedicCall forwards for Kinky subplugin.");
	
	if( !VSH2_HookEx(OnBossTaunt, Kinky_OnBossMedicCall) )
		LogError("Error loading OnBossTaunt forwards for Kinky subplugin.");
	
	if( !VSH2_HookEx(OnBossJarated, Kinky_OnBossJarated) )
		LogError("Error loading OnBossJarated forwards for Kinky subplugin.");
	
	if( !VSH2_HookEx(OnRoundEndInfo, Kinky_OnRoundEndInfo) )
		LogError("Error loading OnRoundEndInfo forwards for Kinky subplugin.");
	
	if( !VSH2_HookEx(OnMusic, KinkyMusic) )
		LogError("Error loading OnBossDealDamage forwards for Kinky subplugin.");
	
	if( !VSH2_HookEx(OnBossDeath, Kinky_OnBossDeath) )
		LogError("Error loading OnBossDeath forwards for Kinky subplugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnStabbed, Kinky_OnStabbed) )
		LogError("Error loading OnBossTakeDamage_OnStabbed forwards for Kinky subplugin.");
	
	if( !VSH2_HookEx(OnLastPlayer, Kinky_OnLastPlayer) )
		LogError("Error loading OnLastPlayer forwards for Kinky subplugin.");
}

stock bool IsKinky(const VSH2Player player) {
	return player.GetPropInt("iBossType") == g_iKinkyID;
}


public void Kinky_OnCallDownloads()
{
	PrepareModel(KinkyModel);
	DownloadSoundList(KinkyIntro, sizeof(KinkyIntro));
	DownloadSoundList(KinkyJump, sizeof(KinkyJump));
	DownloadSoundList(KinkyStab, sizeof(KinkyStab));
	DownloadSoundList(KinkyDeath, sizeof(KinkyDeath));
	DownloadSoundList(KinkyLast, sizeof(KinkyLast));
	DownloadSoundList(KinkyRage, sizeof(KinkyRage));
	DownloadSoundList(KinkySpree, sizeof(KinkySpree));
	DownloadSoundList(KinkyWin, sizeof(KinkyWin));
	DownloadSoundList(KinkyThemes, sizeof(KinkyThemes));
	
	PrepareMaterial("materials/models/capnkinky/soldier");
	PrepareMaterial("materials/models/capnkinky/soldier_blu");
	PrepareMaterial("materials/models/capnkinky/soldier_blu_uber");
	PrepareMaterial("materials/models/capnkinky/soldier_exponent");
	PrepareMaterial("materials/models/capnkinky/soldier_head");
	PrepareMaterial("materials/models/capnkinky/soldier_head_blue");
	PrepareMaterial("materials/models/capnkinky/soldier_head_blue_invun");
	PrepareMaterial("materials/models/capnkinky/soldier_normals");
	PrepareMaterial("materials/models/capnkinky/soldier_officer");
	PrepareMaterial("materials/models/capnkinky/soldier_officer_blue_uber");
	PrepareMaterial("materials/models/capnkinky/soldier_uber");
	PrepareMaterial("materials/models/capnkinky/zzzzzzzzzzzzzzzzzzzzz");
}

public void Kinky_OnBossMenu(Menu &menu)
{
	char tostr[10]; IntToString(g_iKinkyID, tostr, sizeof(tostr));
	menu.AddItem(tostr, "Cpt. Kinky");
}

public void Kinky_OnBossSelected(const VSH2Player player)
{
	if( !IsKinky(player) )
		return;
	
	Panel panel = new Panel();
	panel.SetTitle("Cpt. Kinky:\n\nSuper Jump: crouch, look up and stand up.\nWeigh-down: in midair, look down and crouch\nRage (force to melee): taunt when the Rage is full to force all nearby enemies to melee only.");
	panel.DrawItem("Exit");
	panel.Send(player.index, HintPanel, 50);
	delete panel;
}

public void Kinky_OnBossThink(const VSH2Player player)
{
	int client = player.index;
	if( !IsPlayerAlive(client) || !IsKinky(player) )
		return;
	
	VSH2_SpeedThink(player, 340.0);
	VSH2_GlowThink(player, 0.1);
	if( VSH2_SuperJumpThink(player, 2.5, 25.0) ) {
		player.PlayVoiceClip(KinkyJump[GetRandomInt(0, sizeof(KinkyJump)-1)], VSH2_VOICE_ABILITY);
		player.SuperJump(player.GetPropFloat("flCharge"), -100.0);
	}
	
	if( OnlyScoutsLeft(VSH2Team_Red) )
		player.SetPropFloat("flRAGE", player.GetPropFloat("flRAGE") + g_vsh2_scout_rage_gen.FloatValue);
	
	VSH2_WeighDownThink(player, 2.0, 0.1);
	
	/// hud code
	SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
	Handle hud = VSH2GameMode_GetHUDHandle();
	float jmp = player.GetPropFloat("flCharge");
	float rage = player.GetPropFloat("flRAGE");
	if( rage >= 100.0 )
		ShowSyncHudText(client, hud, "Jump: %i%% | Rage: FULL - Call Medic (default: E) to activate", player.GetPropInt("bSuperCharge") ? 1000 : RoundFloat(jmp) * 4);
	else ShowSyncHudText(client, hud, "Jump: %i%% | Rage: %0.1f", player.GetPropInt("bSuperCharge") ? 1000 : RoundFloat(jmp) * 4, rage);
}

public void Kinky_OnBossModelTimer(const VSH2Player player)
{
	if( !IsKinky(player) )
		return;
	int client = player.index;
	SetVariantString(KinkyModel);
	AcceptEntityInput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
}

public void Kinky_OnBossEquipped(const VSH2Player player)
{
	if( !IsKinky(player) )
		return;
	
	player.RemoveAllItems();
	player.SetName("Cpt. Kinky");
	char attribs[80]; Format(attribs, sizeof(attribs), "68 ; 2.0; 2 ; 3.1; 259 ; 1.0; 252 ; 0.7; 64 ; 0.75; 206 ; 1.25");
	int wep = player.SpawnWeapon("tf_weapon_shovel", 447, 69, 5, attribs);
	SetEntPropEnt(player.index, Prop_Send, "m_hActiveWeapon", wep);
}

public void Kinky_OnBossInitialized(const VSH2Player player)
{
	if( !IsKinky(player) )
		return;
	SetEntProp(player.index, Prop_Send, "m_iClass", view_as<int>(TFClass_Soldier));
}

public void Kinky_OnBossPlayIntro(const VSH2Player player)
{
	if( !IsKinky(player) )
		return;
	player.PlayVoiceClip(KinkyIntro[GetRandomInt(0, sizeof(KinkyIntro)-1)], VSH2_VOICE_INTRO);
}

public void Kinky_OnPlayerKilled(const VSH2Player attacker, const VSH2Player victim, Event event)
{
	if( !IsKinky(attacker) )
		return;
	
	float curtime = GetGameTime();
	if( curtime <= attacker.GetPropFloat("flKillSpree") )
		attacker.SetPropInt("iKills", attacker.GetPropInt("iKills") + 1);
	else attacker.SetPropInt("iKills", 0);
	
	if( attacker.GetPropInt("iKills") == 3 && VSH2GameMode_GetTotalRedPlayers() != 1 ) {
		attacker.PlayVoiceClip(KinkySpree[GetRandomInt(0, sizeof(KinkySpree)-1)], VSH2_VOICE_SPREE);
		attacker.SetPropInt("iKills", 0);
	}
	else attacker.SetPropFloat("flKillSpree", curtime+5.0);
}

public void Kinky_OnPlayerHurt(const VSH2Player attacker, const VSH2Player victim, Event event)
{
	int damage = event.GetInt("damageamount");
	if( IsKinky(victim) && victim.GetPropInt("bIsBoss") )
		victim.GiveRage(damage);
}
public void Kinky_OnPlayerAirblasted(const VSH2Player airblaster, const VSH2Player airblasted, Event event)
{
	if( !IsKinky(airblasted) )
		return;
	float rage = airblasted.GetPropFloat("flRAGE");
	airblasted.SetPropFloat("flRAGE", rage + g_vsh2_airblast_rage.FloatValue);
}
public void Kinky_OnBossMedicCall(const VSH2Player rager)
{
	if( !IsKinky(rager) || rager.GetPropFloat("flRAGE") < 100.0 )
		return;
	
	VSH2Player[] players = new VSH2Player[MaxClients];
	int in_range = rager.GetPlayersInRange(players, 800.0);
	for( int i; i<in_range; i++ ) {
		/// don't rage other bosses and minions.
		if( players[i].GetPropAny("bIsBoss") || players[i].GetPropAny("bIsMinion") )
			continue;
		
		int red = players[i].index;
		int melee = GetPlayerWeaponSlot(red, TFWeaponSlot_Melee);
		if( melee <= 0 || !IsValidEntity(melee) )
			continue;
		
		SetEntPropEnt(red, Prop_Send, "m_hActiveWeapon", melee);
		TF2_AddCondition(red, TFCond_RestrictToMelee, 10.0);
	}
	TF2_AddCondition(rager.index, TFCond_Buffed, 10.0);
	TF2_AddCondition(rager.index, TFCond_RuneHaste, 10.0);
	rager.PlayVoiceClip(KinkyRage[GetRandomInt(0, sizeof(KinkyRage)-1)], VSH2_VOICE_RAGE);
	rager.SetPropFloat("flRAGE", 0.0);
}

public void Kinky_OnBossJarated(const VSH2Player victim, const VSH2Player thrower)
{
	if( !IsKinky(victim) )
		return;
	float rage = victim.GetPropFloat("flRAGE");
	victim.SetPropFloat("flRAGE", rage - g_vsh2_jarate_rage.FloatValue);
}


public void Kinky_OnRoundEndInfo(const VSH2Player player, bool bossBool, char message[MAXMESSAGE])
{
	if( !IsKinky(player) )
		return;
	else if( bossBool )
		player.PlayVoiceClip(KinkyWin[GetRandomInt(0, sizeof(KinkyWin)-1)], VSH2_VOICE_WIN);
}


public void KinkyMusic(char song[PLATFORM_MAX_PATH], float &time, const VSH2Player player)
{
	if( !IsKinky(player) )
		return;
	
	int theme = GetRandomInt(0, sizeof(KinkyThemes)-1);
	Format(song, sizeof(song), "%s", KinkyThemes[theme]);
	time = KinkyThemesTime[theme];
}

public void Kinky_OnBossDeath(const VSH2Player player)
{
	if( !IsKinky(player) )
		return;
	
	player.PlayVoiceClip(KinkyDeath[GetRandomInt(0, sizeof(KinkyDeath)-1)], VSH2_VOICE_LOSE);
}

public Action Kinky_OnStabbed(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if( !IsKinky(victim) )
		return Plugin_Continue;
	
	victim.PlayVoiceClip(KinkyStab[GetRandomInt(0, sizeof(KinkyStab)-1)], VSH2_VOICE_STABBED);
	return Plugin_Continue;
}

public void Kinky_OnLastPlayer(const VSH2Player player)
{
	if( !IsKinky(player) )
		return;
	player.PlayVoiceClip(KinkyLast[GetRandomInt(0, sizeof(KinkyLast)-1)], VSH2_VOICE_LASTGUY);
}


stock bool IsValidClient(const int client, bool nobots=false)
{ 
	if( client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)) )
		return false; 
	return IsClientInGame(client); 
}

stock int GetSlotFromWeapon(const int iClient, const int iWeapon)
{
	for (int i=0; i<5; i++) {
		if( iWeapon == GetPlayerWeaponSlot(iClient, i) )
			return i;
	}
	return -1;
}
stock bool OnlyScoutsLeft(const int team)
{
	for (int i=MaxClients; i; --i) {
		if( !IsValidClient(i) || !IsPlayerAlive(i) )
			continue;
		else if( GetClientTeam(i) == team && TF2_GetPlayerClass(i) != TFClass_Scout )
			return false;
	}
	return true;
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
