#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <vsh2>

#undef REQUIRE_PLUGIN
#tryinclude <tf2attributes>
#define REQUIRE_PLUGIN


#define BruteModel    "models/player/brute.mdl"
#define GruntModel    "models/freak_fortress_2/servantgrunt/servantgrunt.mdl"
#define TerrorSound   "brute/terror.mp3"

/// Grunt voicelines
char GruntIntro[][] = {
	"grunt/intro1.mp3",
	"grunt/intro2.mp3",
	"grunt/intro3.mp3"
};

char GruntStab[][] = {
	"grunt/stab1.mp3",
	"grunt/stab2.mp3"
};

char GruntDeath[][] = {
	"grunt/dead1.mp3",
	"grunt/dead2.mp3"
};

char GruntLast[][] = {
	"grunt/last1.mp3",
	"grunt/last2.mp3",
	"grunt/last3.mp3"
};

char GruntRage[][] = {
	"grunt/rage1.mp3",
	"grunt/rage2.mp3"
};

char GruntSwing[][] = {
	"grunt/swing1.mp3",
	"grunt/swing2.mp3",
	"grunt/swing3.mp3"
};

char GruntKill[][] = {
	"grunt/kill1.mp3",
	"grunt/kill2.mp3",
	"grunt/kill3.mp3"
};

char GruntWin[][] = {
	"grunt/win1.mp3",
	"grunt/win2.mp3"
};

char GruntThemes[][] = {
	"grunt/theme1.mp3"
};

float GruntThemesTime[] = {
	25.0
};


/// Brute voicelines
char BruteDeath[][] = {
	"brute/dead1.mp3",
	"brute/dead2.mp3"
};

char BruteKill[][] = {
	"brute/kill1.mp3",
	"brute/kill2.mp3",
	"brute/kill3.mp3"
};

char BruteIntro[][] = {
	"brute/intro1.mp3",
	"brute/intro2.mp3",
	"brute/intro3.mp3",
	"brute/intro4.mp3"
};

char BruteSwing[][] = {
	"brute/swing1.mp3",
	"brute/swing2.mp3",
	"brute/swing3.mp3"
};

char BruteLast[][] = {
	"brute/lastguy1.mp3",
	"brute/lastguy2.mp3",
	"brute/lastguy3.mp3"
};

char BruteRage[][] = {
	"brute/rage1.mp3",
	"brute/rage2.mp3"
};

char BruteSpree[][] = {
	"brute/spree1.mp3",
	"brute/spree2.mp3",
	"brute/spree3.mp3",
	"brute/spree4.mp3",
	"brute/spree5.mp3"
};

char BruteStab[][] = {
	"brute/stab1.mp3",
	"brute/stab2.mp3",
	"brute/stab3.mp3"
};

char BruteWin[][] = {
	"brute/win1.mp3",
	"brute/win2.mp3",
	"brute/win3.mp3"
};

char BruteThemes[][] = {
	"brute/theme1.mp3",
	"brute/theme2.mp3"
};

float BruteThemesTime[] = {
	97.0,
	60.0
};


public Plugin myinfo = {
	name        = "VSH2 Grunt & Brute Bosses",
	author      = "Nergal/Assyrian",
	description = "",
	version     = "1.0",
	url         = "sus"
};


enum struct AmnesiaBoss {
	int       grunt_id;
	int       brute_id;
	float     terror_time[35];
	float     swing_time[35];
	ConfigMap cfg;
	ConVar    scout_rage_gen;
	ConVar    airblast_rage;
	ConVar    jarate_rage;
}

AmnesiaBoss amnesia_boss;


public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		g_vsh2_cvars.scout_rage_gen = FindConVar("vsh2_scout_rage_gen");
		g_vsh2_cvars.airblast_rage = FindConVar("vsh2_airblast_rage");
		g_vsh2_cvars.jarate_rage = FindConVar("vsh2_jarate_rage");
		g_iGruntID = VSH2_RegisterPlugin("servant_grunt");
		g_iBruteID = VSH2_RegisterPlugin("servant_brute");
		LoadVSH2Hooks();
	}
}

public void LoadVSH2Hooks() {
	if( !VSH2_HookEx(OnCallDownloads, Amnesia_OnCallDownloads) )
		LogError("Error loading OnCallDownloads forwards for Amnesia subplugin.");
	
	if( !VSH2_HookEx(OnBossMenu, Amnesia_OnBossMenu) )
		LogError("Error loading OnBossMenu forwards for Amnesia subplugin.");
	
	if( !VSH2_HookEx(OnBossSelected, Amnesia_OnBossSelected) )
		LogError("Error loading OnBossSelected forwards for Amnesia subplugin.");
	
	if( !VSH2_HookEx(OnBossThink, Amnesia_OnBossThink) )
		LogError("Error loading OnBossThink forwards for Amnesia subplugin.");
	
	if( !VSH2_HookEx(OnBossModelTimer, Amnesia_OnBossModelTimer) )
		LogError("Error loading OnBossModelTimer forwards for Amnesia subplugin.");
	
	if( !VSH2_HookEx(OnBossEquipped, Amnesia_OnBossEquipped) )
		LogError("Error loading OnBossEquipped forwards for Amnesia subplugin.");
	
	if( !VSH2_HookEx(OnBossInitialized, Amnesia_OnBossInitialized) )
		LogError("Error loading OnBossInitialized forwards for Amnesia subplugin.");
	
	if( !VSH2_HookEx(OnBossPlayIntro, Amnesia_OnBossPlayIntro) )
		LogError("Error loading OnBossPlayIntro forwards for Amnesia subplugin.");
	
	if( !VSH2_HookEx(OnPlayerKilled, Amnesia_OnPlayerKilled) )
		LogError("Error loading OnPlayerKilled forwards for Amnesia subplugin.");
	
	if( !VSH2_HookEx(OnPlayerHurt, Amnesia_OnPlayerHurt) )
		LogError("Error loading OnPlayerHurt forwards for Amnesia subplugin.");
	
	if( !VSH2_HookEx(OnPlayerAirblasted, Amnesia_OnPlayerAirblasted) )
		LogError("Error loading OnPlayerAirblasted forwards for Amnesia subplugin.");
	
	if( !VSH2_HookEx(OnBossMedicCall, Amnesia_OnBossMedicCall) )
		LogError("Error loading OnBossMedicCall forwards for Amnesia subplugin.");
	
	if( !VSH2_HookEx(OnBossTaunt, Amnesia_OnBossMedicCall) )
		LogError("Error loading OnBossTaunt forwards for Amnesia subplugin.");
	
	if( !VSH2_HookEx(OnBossJarated, Amnesia_OnBossJarated) )
		LogError("Error loading OnBossJarated forwards for Amnesia subplugin.");
	
	if( !VSH2_HookEx(OnRoundEndInfo, Amnesia_OnRoundEndInfo) )
		LogError("Error loading OnRoundEndInfo forwards for Amnesia subplugin.");
	
	if( !VSH2_HookEx(OnMusic, Amnesia_Music) )
		LogError("Error loading OnBossDealDamage forwards for Amnesia subplugin.");
	
	if( !VSH2_HookEx(OnBossDeath, Amnesia_OnBossDeath) )
		LogError("Error loading OnBossDeath forwards for Amnesia subplugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnStabbed, Amnesia_OnStabbed) )
		LogError("Error loading OnBossTakeDamage_OnStabbed forwards for Amnesia subplugin.");
	
	if( !VSH2_HookEx(OnLastPlayer, Amnesia_OnLastPlayer) )
		LogError("Error loading OnLastPlayer forwards for Amnesia subplugin.");
	
	if( !VSH2_HookEx(OnSoundHook, Amnesia_OnSoundHook) )
		LogError("Error loading OnSoundHook forwards for Amnesia subplugin.");
	
	AddNormalSoundHook(HookSound);
}


stock bool IsGrunt(const VSH2Player player) {
	return player.GetPropInt("iBossType") == g_iGruntID;
}

stock bool IsBrute(const VSH2Player player) {
	return player.GetPropInt("iBossType") == g_iBruteID;
}

stock bool IsGatherer(const VSH2Player player) {
	return IsGrunt(player) || IsBrute(player);
}


public void Amnesia_OnCallDownloads()
{
	PrepareModel(GruntModel);
	PrepareModel(BruteModel);
	
	DownloadSoundList(GruntIntro, sizeof(GruntIntro));
	DownloadSoundList(GruntStab, sizeof(GruntStab));
	DownloadSoundList(GruntDeath, sizeof(GruntDeath));
	DownloadSoundList(GruntLast, sizeof(GruntLast));
	DownloadSoundList(GruntRage, sizeof(GruntRage));
	DownloadSoundList(GruntSwing, sizeof(GruntSwing));
	DownloadSoundList(GruntKill, sizeof(GruntKill));
	DownloadSoundList(GruntWin, sizeof(GruntWin));
	DownloadSoundList(GruntThemes, sizeof(GruntThemes));
	
	DownloadSoundList(BruteDeath, sizeof(BruteDeath));
	DownloadSoundList(BruteKill, sizeof(BruteKill));
	DownloadSoundList(BruteIntro, sizeof(BruteIntro));
	DownloadSoundList(BruteSwing, sizeof(BruteSwing));
	DownloadSoundList(BruteLast, sizeof(BruteLast));
	DownloadSoundList(BruteRage, sizeof(BruteRage));
	DownloadSoundList(BruteSpree, sizeof(BruteSpree));
	DownloadSoundList(BruteStab, sizeof(BruteStab));
	DownloadSoundList(BruteWin, sizeof(BruteWin));
	DownloadSoundList(BruteThemes, sizeof(BruteThemes));
	
	PrepareSound(TerrorSound);
	
	PrepareMaterial("materials/freak_fortress_2/servantgrunt/servant_grunt");
	PrepareMaterial("materials/freak_fortress_2/servantgrunt/servant_grunt_hair");
	PrepareMaterial("materials/freak_fortress_2/servantgrunt/servant_grunt_hair_nrm");
	
	PrepareMaterial("materials/models/player/demo-brute/brute_blu");
	PrepareMaterial("materials/models/player/demo-brute/brute_blu_charged");
	PrepareMaterial("materials/models/player/demo-brute/brute_exponent");
	PrepareMaterial("materials/models/player/demo-brute/brute_ivuln_blu");
	PrepareMaterial("materials/models/player/demo-brute/brute_normals");
}

public void Amnesia_OnBossMenu(Menu &menu) {
	char tostr[10];
	IntToString(g_iGruntID, tostr, sizeof(tostr)); menu.AddItem(tostr, "Servant Grunt");
	IntToString(g_iBruteID, tostr, sizeof(tostr)); menu.AddItem(tostr, "Servant Brute");
}

public void Amnesia_OnBossSelected(const VSH2Player player) {
	if( !IsGatherer(player) )
		return;
	
	bool is_grunt = IsGrunt(player);
	Panel panel = new Panel();
	panel.SetTitle(is_grunt
		? "Servant Grunt:\nClaws: fast firerate but slightly weak.\nClimb Walls."
		: "Servant Brute:\nArm Grafted Blade: slow firerate but powerful.\nSuperJump: Right click or crouch to charge, look up, then release the buttons."
	);
	panel.DrawItem("Exit");
	panel.Send(player.index, HintPanel, 50);
	delete panel;
}

public void Amnesia_OnBossThink(const VSH2Player player) {
	int client = player.index;
	if( !IsPlayerAlive(client) || !IsGatherer(player) )
		return;
	
	player.GlowThink(0.1);
	player.SpeedThink(340.0);
	
	if( OnlyScoutsLeft() )
		player.SetPropFloat("flRAGE", player.GetPropFloat("flRAGE") + g_vsh2_cvars.scout_rage_gen.FloatValue);
	
	player.WeighDownThink(2.0, 0.1);
	
	float vecShoveDir[3]; GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vecShoveDir);
	if( vecShoveDir[0] != 0.0 && vecShoveDir[1] != 0.0 ) {
		VSH2Player[] reds = new VSH2Player[MaxClients];
		int count = player.GetPlayersInRange(reds, 250.0, true);
		for( int i; i<count; i++ ) {
			int me = reds[i].index;
			if( GetClientTeam(me)==GetClientTeam(client) )
				continue;
			
			float entitypos[3];    GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", entitypos);
			float targetpos[3];    GetEntPropVector(me, Prop_Data, "m_vecAbsOrigin", targetpos);
			float vecTargetDir[3]; SubtractVectors(entitypos, targetpos, vecTargetDir);
			NormalizeVector(vecShoveDir, vecShoveDir);
			NormalizeVector(vecTargetDir, vecTargetDir);
			if( GetVectorDotProduct(vecShoveDir, vecTargetDir) <= 0 ) {
				float curr_time = GetGameTime();
				if( g_amn_data[me].m_flTerrorTime <= curr_time ) {
					EmitSoundToClient(me, TerrorSound);
					g_amn_data[me].m_flTerrorTime = curr_time + 5.0;
				}
			}
		}
	}
	
	/// hud code
	SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
	Handle hud = VSH2GameMode.GetHUDHandle();
	//float jmp = player.GetPropFloat("flCharge");
	float rage = player.GetPropFloat("flRAGE");
	if( rage >= 100.0 ) {
		ShowSyncHudText(client, hud, "Rage: FULL - Call Medic (default: E) to activate");
	} else {
		ShowSyncHudText(client, hud, "Rage: %0.1f", rage);
	}
}

public void Amnesia_OnBossModelTimer(const VSH2Player player) {
	if( !IsGatherer(player) )
		return;
	
	int client = player.index;
	SetVariantString(IsGrunt(player) ? GruntModel : BruteModel);
	AcceptEntityInput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
}

public void Amnesia_OnBossEquipped(const VSH2Player player) {
	if( !IsGatherer(player) )
		return;
	
	player.RemoveAllItems();
	if( IsGrunt(player) ) {
		player.SetName("The Servant Grunt");
		int wep = player.SpawnWeapon("tf_weapon_shovel", 426, 100, 5, "2 ; 2.23; 68 ; 2.0; 259 ; 1.0; 61 ; 1.25; 252 ; 0.6");
		SetEntPropEnt(player.index, Prop_Send, "m_hActiveWeapon", wep);
	} else {
		player.SetName("The Servant Brute");
		int wep = player.SpawnWeapon("tf_weapon_sword", 132, 100, 5, "68 ; 2.0; 2 ; 3.5; 5 ; 1.5; 259 ; 1.0; 61 ; 1.5; 65 ; 1.5; 252 ; 0.6");
		SetEntPropEnt(player.index, Prop_Send, "m_hActiveWeapon", wep);
		SetEntProp(wep, Prop_Send, "m_bValidatedAttachedEntity", 0);
	}
}

public void Amnesia_OnBossInitialized(const VSH2Player player) {
	if( !IsGatherer(player) )
		return;
	
	SetEntProp(player.index, Prop_Send, "m_iClass", view_as<int>(IsGrunt(player) ? TFClass_Medic : TFClass_DemoMan));
}

public void Amnesia_OnBossPlayIntro(const VSH2Player player) {
	if( !IsGatherer(player) )
		return;
	
	player.PlayVoiceClip(IsGrunt(player) ? GruntIntro[GetRandomInt(0, sizeof(GruntIntro)-1)] : BruteIntro[GetRandomInt(0, sizeof(BruteIntro)-1)], VSH2_VOICE_INTRO);
	bool is_grunt = IsGrunt(player);
	int players = VSH2GameMode.GetTotalRedPlayers();
	/// check if we have enough players and there's no complimentary amnesia boss already existing.
	if( players > 6 && !VSH2GameMode.GetBossByType(false, is_grunt ? g_iBruteID : g_iGruntID) ) {
		VSH2Player partner = VSH2GameMode.FindNextBoss();
		if( partner ) {
			partner.MakeBossAndSwitch(is_grunt ? g_iBruteID : g_iGruntID, true);
		}
	}
}

public void Amnesia_OnPlayerKilled(const VSH2Player attacker, const VSH2Player victim, Event event)
{
	if( !IsGatherer(attacker) )
		return;
	
	if( IsBrute(attacker) && attacker.index != victim.index ) {
		attacker.PlayVoiceClip(BruteKill[GetRandomInt(0, sizeof(BruteKill)-1)], VSH2_VOICE_SPREE);
		float curtime = GetGameTime();
		int kills = attacker.GetPropInt("iKills");
		if( curtime <= attacker.GetPropFloat("flKillSpree") ) {
			attacker.SetPropInt("iKills", kills + 1);
		} else {
			attacker.SetPropInt("iKills", 0);
		}
		
		if( kills == 3 && VSH2GameMode.GetTotalRedPlayers() != 1 ) {
			attacker.PlayVoiceClip(BruteSpree[GetRandomInt(0, sizeof(BruteSpree)-1)], VSH2_VOICE_SPREE);
			attacker.SetPropInt("iKills", 0);
		} else {
			attacker.SetPropFloat("flKillSpree", curtime+7.0);
		}
	} else {
		attacker.PlayVoiceClip(GruntKill[GetRandomInt(0, sizeof(GruntKill)-1)], VSH2_VOICE_SPREE);
	}
}

public void Amnesia_OnPlayerHurt(const VSH2Player attacker, const VSH2Player victim, Event event) {
	int damage = event.GetInt("damageamount");
	if( IsGatherer(victim) && victim.GetPropInt("bIsBoss") )
		victim.GiveRage(damage);
}

public void Amnesia_OnPlayerAirblasted(const VSH2Player airblaster, const VSH2Player airblasted, Event event) {
	if( !IsGatherer(airblasted) )
		return;
	
	float rage = airblasted.GetPropFloat("flRAGE");
	airblasted.SetPropFloat("flRAGE", rage + g_vsh2_cvars.airblast_rage.FloatValue);
}

public void Amnesia_OnBossMedicCall(const VSH2Player player) {
	if( !IsGatherer(player) || player.GetPropFloat("flRAGE") < 100.0 )
		return;
	
	TF2_AddCondition(player.index, TFCond_RuneResist, 10.0);
	player.PlayVoiceClip(IsGrunt(player) ? GruntRage[GetRandomInt(0, sizeof(GruntRage)-1)] : BruteRage[GetRandomInt(0, sizeof(BruteRage)-1)], VSH2_VOICE_RAGE);
	player.SetPropFloat("flRAGE", 0.0);
}

public void Amnesia_OnBossJarated(const VSH2Player victim, const VSH2Player thrower) {
	if( !IsGatherer(victim) )
		return;
	
	float rage = victim.GetPropFloat("flRAGE");
	victim.SetPropFloat("flRAGE", rage - g_vsh2_cvars.jarate_rage.FloatValue);
}

public void Amnesia_OnRoundEndInfo(const VSH2Player player, bool boss_won, char message[MAXMESSAGE]) {
	if( !IsGatherer(player) ) {
		return;
	} else if( boss_won ) {
		player.PlayVoiceClip(IsGrunt(player) ? GruntWin[GetRandomInt(0, sizeof(GruntWin)-1)] : BruteWin[GetRandomInt(0, sizeof(BruteWin)-1)], VSH2_VOICE_WIN);
	}
}

public void Amnesia_Music(char song[PLATFORM_MAX_PATH], float &time, const VSH2Player player)
{
	if( !IsGatherer(player) )
		return;
	
	if( IsGrunt(player) ) {
		int theme = GetRandomInt(0, sizeof(GruntThemes)-1);
		Format(song, sizeof(song), "%s", GruntThemes[theme]);
		time = GruntThemesTime[theme];
	} else {
		int theme = GetRandomInt(0, sizeof(BruteThemes)-1);
		Format(song, sizeof(song), "%s", BruteThemes[theme]);
		time = BruteThemesTime[theme];
	}
}

public void Amnesia_OnBossDeath(const VSH2Player player) {
	if( !IsGatherer(player) )
		return;
	
	player.PlayVoiceClip(IsGrunt(player) ? GruntDeath[GetRandomInt(0, sizeof(GruntDeath)-1)] : BruteDeath[GetRandomInt(0, sizeof(BruteDeath)-1)], VSH2_VOICE_LOSE);
}

public Action Amnesia_OnStabbed(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if( !IsGatherer(victim) )
		return Plugin_Continue;
	
	victim.PlayVoiceClip(IsGrunt(victim) ? GruntStab[GetRandomInt(0, sizeof(GruntStab)-1)] : BruteStab[GetRandomInt(0, sizeof(BruteStab)-1)], VSH2_VOICE_STABBED);
	return Plugin_Continue;
}

public void Amnesia_OnLastPlayer(const VSH2Player player) {
	if( !IsGatherer(player) )
		return;
	
	player.PlayVoiceClip(IsGrunt(player) ? GruntLast[GetRandomInt(0, sizeof(GruntLast)-1)] : BruteLast[GetRandomInt(0, sizeof(BruteLast)-1)], VSH2_VOICE_LASTGUY);
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool &result)
{
	VSH2Player player = VSH2Player(client);
	if( !IsGatherer(player) )
		return Plugin_Continue;
	
	player.ClimbWall(weapon, IsGrunt(player) ? 800.0 : 1200.0, 0.0, false);
	
	if( g_amn_data[player.index].m_flSwingTime <= GetGameTime() ) {
		player.PlayVoiceClip(IsGrunt(player) ? GruntSwing[GetRandomInt(0, sizeof(GruntSwing)-1)] : BruteSwing[GetRandomInt(0, sizeof(BruteSwing)-1)], VSH2_VOICE_ABILITY);
		g_amn_data[player.index].m_flSwingTime = GetGameTime() + 6;
	}
	player.SetPropFloat("flWeighDown", 0.0);
	result = false;
	return Plugin_Changed;
}

public Action Amnesia_OnSoundHook(const VSH2Player player, char sample[PLATFORM_MAX_PATH], int& channel, float& volume, int& level, int& pitch, int& flags)
{
	if( !IsGatherer(player) ) {
		return Plugin_Continue;
	} else if( !strncmp(sample, "vo", 2, false) ) {
		if( IsGrunt(player) ) {
			switch( GetRandomInt(0, 3) ) {
				case 0: strcopy(sample, PLATFORM_MAX_PATH, GruntRage[GetRandomInt(0, sizeof(GruntRage)-1)]);
				case 1: strcopy(sample, PLATFORM_MAX_PATH, GruntWin[GetRandomInt(0, sizeof(GruntWin)-1)]);
				case 2: strcopy(sample, PLATFORM_MAX_PATH, GruntStab[GetRandomInt(0, sizeof(GruntStab)-1)]);
				case 3: strcopy(sample, PLATFORM_MAX_PATH, GruntLast[GetRandomInt(0, sizeof(GruntLast)-1)]);
			}
		} else {
			switch( GetRandomInt(0, 3) ) {
				case 0: strcopy(sample, PLATFORM_MAX_PATH, BruteRage[GetRandomInt(0, sizeof(BruteRage)-1)]);
				case 1: strcopy(sample, PLATFORM_MAX_PATH, BruteSpree[GetRandomInt(0, sizeof(BruteSpree)-1)]);
				case 2: strcopy(sample, PLATFORM_MAX_PATH, BruteWin[GetRandomInt(0, sizeof(BruteWin)-1)]);
				case 3: strcopy(sample, PLATFORM_MAX_PATH, BruteLast[GetRandomInt(0, sizeof(BruteLast)-1)]);
			}
		}
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

stock bool IsValidClient(const int client, bool nobots=false) {
	if( client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)) )
		return false;
	return IsClientInGame(client);
}

stock int GetSlotFromWeapon(const int iClient, const int iWeapon) {
	for( int i=0; i<5; i++ )
		if( iWeapon == GetPlayerWeaponSlot(iClient, i) )
			return i;
	
	return -1;
}

stock bool OnlyScoutsLeft() {
	VSH2Player[] players = new VSH2Player[MaxClients];
	int len = VSH2GameMode.GetFighters(players);
	for( int i; i<len; i++ ) {
		if( players[i].iTFClass != TFClass_Scout ) {
			return false;
		}
	}
	return true;
}

stock void SetPawnTimer(Function func, float thinktime = 0.1, any param1 = -999, any param2 = -999) {
	DataPack thinkpack = new DataPack();
	thinkpack.WriteFunction(func);
	thinkpack.WriteCell(param1);
	thinkpack.WriteCell(param2);
	CreateTimer(thinktime, DoThink, thinkpack, TIMER_DATA_HNDL_CLOSE);
}

public Action DoThink(Handle hTimer, DataPack hndl) {
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
stock void SetWeaponClip(const int weapon, const int ammo) {
	if( IsValidEntity(weapon) ) {
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		SetEntData(weapon, iAmmoTable, ammo, 4, true);
	}
}


public int HintPanel(Menu menu, MenuAction action, int param1, int param2) {
	return;
}

public int GetPlayersInSight(VSH2Player boss, VSH2Player[] players, const float dist) {
	int client = boss.index;
	float flMyPos[3]; GetClientEyePosition(client, flMyPos);
	float flMaxAngle = 999.0;
	//float flAimingPercent;
	float flMyEyeAng[3]; GetClientEyeAngles(client, flMyEyeAng);
	float vForward[3]; GetAngleVectors(flMyEyeAng, vForward, NULL_VECTOR, NULL_VECTOR);
	
	int count;
	for( int i=MaxClients; i; --i ) {
		if( !IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i)==GetClientTeam(client) || i==client )
			continue;
		
		float flTheirPos[3]; GetClientEyePosition(i, flTheirPos);
		TR_TraceRayFilter(flMyPos, flTheirPos, MASK_SHOT|CONTENTS_GRATE, RayType_EndPoint, AimTargetFilter, client);
		if( TR_DidHit() ) {
			int entity = TR_GetEntityIndex();
			if( entity==i && GetVectorDistance(flMyPos, flTheirPos) <= dist ) {
				float vDistance[3];
				SubtractVectors(flMyPos, flTheirPos, vDistance);
				NormalizeVector(vDistance, vDistance);
				
				float flAngle = RadToDeg(ArcCosine(GetVectorDotProduct(vForward, vDistance)));
				if( flMaxAngle > flAngle && flAngle <= 60 ) {
					flMaxAngle = flAngle;
					//flAimingPercent = 100 - (flMaxAngle * (100 / 60));
					players[count++] = VSH2Player(i);
				}
			}
		}
	}
	return count;
}

public bool AimTargetFilter(int entity, int contentsMask, any iExclude)
{
	char plclass[64]; GetEntityClassname(entity, plclass, sizeof(plclass));
	if( StrEqual(plclass, "player") ) {
		if( GetClientTeam(entity) == GetClientTeam(iExclude) )
			return false;
	} else if( StrEqual(plclass, "entity_medigun_shield") ) {
		if( GetEntProp(entity, Prop_Send, "m_iTeamNum") == GetClientTeam(iExclude) )
			return false;
	} else if( StrEqual(plclass, "func_respawnroomvisualizer") )
		return false;
	else if( StrContains(plclass, "tf_projectile_", false) != -1 )
		return false;
	return !( entity==iExclude );
}
