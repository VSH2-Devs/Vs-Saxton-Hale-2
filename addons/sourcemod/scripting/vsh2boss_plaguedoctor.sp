#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <vsh2>

#undef REQUIRE_PLUGIN
#tryinclude <tf2attributes>
#define REQUIRE_PLUGIN


#if defined _tf2attributes_included
public void TF2AttribsRemove(int iEntity) {
	TF2Attrib_RemoveAll(iEntity);
}
#endif

public void RemoveWepFromSlot(int client, int wepslot) {
	TF2_RemoveWeaponSlot(client, wepslot);
}


public Plugin myinfo = {
	name        = "VSH2 Plague Doctor Subplugin",
	author      = "Nergal/Assyrian",
	description = "",
	version     = "1.0",
	url         = "https://github.com/VSH2-Devs/Vs-Saxton-Hale-2"
};

enum struct PlagueDoc {
	VSH2GameMode gm;
	ConfigMap    cfg;
	int          id;
	ConVar       scout_rage_gen;
	ConVar       airblast_rage;
	ConVar       jarate_rage;
	
	/// Boss custom cvars.
	ConVar       run_speed;
	ConVar       glow_iota;
	ConVar       charge_amnt;
	ConVar       max_jmp_charge;
	ConVar       jmp_reset;
	ConVar       wghdwn_time;
	ConVar       wghdwn_iota;
	ConVar       minion_uber_time;
	ConVar       minion_climb_vel;
	ConVar       minion_spawn;
	ConVar       rage_time;
}

PlagueDoc plague_doc;


public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		plague_doc.scout_rage_gen = FindConVar("vsh2_scout_rage_gen");
		plague_doc.airblast_rage  = FindConVar("vsh2_airblast_rage");
		plague_doc.jarate_rage    = FindConVar("vsh2_jarate_rage");
		plague_doc.cfg            = new ConfigMap("configs/saxton_hale/boss_cfgs/plague_doctor.cfg");
		
		plague_doc.run_speed = CreateConVar("vsh2_plaguedoc_speed", "340.0", "How fast, based on health, Plague Doctor can move.", FCVAR_NOTIFY, true, 1.0, true, 99999.0);
		plague_doc.glow_iota = CreateConVar("vsh2_plaguedoc_glow_iota", "0.1", "How fast Plague Doctor's glow time decreases.", FCVAR_NOTIFY, true, 0.0, true, 99999.0);
		plague_doc.charge_amnt = CreateConVar("vsh2_plaguedoc_jmp_charge", "2.5", "How much superjump charge should increase when holding jump buttons.", FCVAR_NOTIFY, true, 0.0, true, 99999.0);
		plague_doc.max_jmp_charge = CreateConVar("vsh2_plaguedoc_max_jmp_charge", "25.0", "maximum charge that superjump can charge to.", FCVAR_NOTIFY, true, 0.0, true, 99999.0);
		plague_doc.jmp_reset = CreateConVar("vsh2_plaguedoc_jmp_reset", "-100.0", "amount to reset the superjump charge after superjumping.", FCVAR_NOTIFY, false, _, true, 99999.0);
		plague_doc.wghdwn_time = CreateConVar("vsh2_plaguedoc_weighdown_time", "3.0", "how much time the plague doctor has to be in the air for weighdown to work.", FCVAR_NOTIFY, true, 0.0, true, 99999.0);
		plague_doc.wghdwn_iota = CreateConVar("vsh2_plaguedoc_weighdown_iota", "0.1", "How fast Plague Doctor's weighdown time decreases.", FCVAR_NOTIFY, true, 0.0, true, 99999.0);
		plague_doc.minion_uber_time = CreateConVar("vsh2_plaguedoc_minion_uber_time", "3.0", "How long plague doctor minion spawn ubers last.", FCVAR_NOTIFY, true, 0.0, true, 99999.0);
		plague_doc.minion_climb_vel = CreateConVar("vsh2_plaguedoc_minion_climb_vel", "400.0", "plague doctor minion upward climbing velocity (in hammer units).", FCVAR_NOTIFY, true, 0.0, true, 99999.0);
		plague_doc.rage_time = CreateConVar("vsh2_plaguedoc_rage_time", "10.0", "how long in seconds does the plague doctor rage boost (applies to minions as well) work for.", FCVAR_NOTIFY, true, 0.0, true, 99999.0);
		plague_doc.minion_spawn = CreateConVar("vsh2_plaguedoc_minion_spawn_time", "1.5", "amount, multiplied by the minion count, for minions to spawn.", FCVAR_NOTIFY, true, 0.0, true, 99999.0);
		
		/// If config is null, do not register boss.
		if( plague_doc.cfg==null ) {
			LogError("[VSH 2] ERROR :: **** couldn't find 'configs/saxton_hale/boss_cfgs/plague_doctor.cfg'. Failed to register Plague Doctor boss module. ****");
			return;
		}
		char plugin_name_str[MAX_BOSS_NAME_SIZE];
		plague_doc.cfg.Get("plugin name", plugin_name_str, sizeof(plugin_name_str));
		plague_doc.id = VSH2_RegisterPlugin(plugin_name_str);
		LoadVSH2Hooks();
	}
}


public void LoadVSH2Hooks() {
	if( !VSH2_HookEx(OnCallDownloads, PlagueDoc_OnCallDownloads) )
		LogError("Error loading OnCallDownloads forwards for Plague Doctor subplugin.");
	
	if( !VSH2_HookEx(OnBossMenu, PlagueDoc_OnBossMenu) )
		LogError("Error loading OnBossMenu forwards for Plague Doctor subplugin.");
	
	if( !VSH2_HookEx(OnBossSelected, PlagueDoc_OnBossSelected) )
		LogError("Error loading OnBossSelected forwards for Plague Doctor subplugin.");
	
	if( !VSH2_HookEx(OnBossThink, PlagueDoc_OnBossThink) )
		LogError("Error loading OnBossThink forwards for Plague Doctor subplugin.");
	
	if( !VSH2_HookEx(OnBossModelTimer, PlagueDoc_OnBossModelTimer) )
		LogError("Error loading OnBossModelTimer forwards for Plague Doctor subplugin.");
	
	if( !VSH2_HookEx(OnBossEquipped, PlagueDoc_OnBossEquipped) )
		LogError("Error loading OnBossEquipped forwards for Plague Doctor subplugin.");
	
	if( !VSH2_HookEx(OnBossInitialized, PlagueDoc_OnBossInitialized) )
		LogError("Error loading OnBossInitialized forwards for Plague Doctor subplugin.");
	
	if( !VSH2_HookEx(OnMinionInitialized, PlagueDoc_OnMinionInitialized) )
		LogError("Error loading OnMinionInitialized forwards for Plague Doctor subplugin.");
	
	if( !VSH2_HookEx(OnBossPlayIntro, PlagueDoc_OnBossPlayIntro) )
		LogError("Error loading OnBossPlayIntro forwards for Plague Doctor subplugin.");
	
	if( !VSH2_HookEx(OnPlayerKilled, PlagueDoc_OnPlayerKilled) )
		LogError("Error loading OnPlayerKilled forwards for Plague Doctor subplugin.");
	
	if( !VSH2_HookEx(OnPlayerHurt, PlagueDoc_OnPlayerHurt) )
		LogError("Error loading OnPlayerHurt forwards for Plague Doctor subplugin.");
	
	if( !VSH2_HookEx(OnPlayerAirblasted, PlagueDoc_OnPlayerAirblasted) )
		LogError("Error loading OnPlayerAirblasted forwards for Plague Doctor subplugin.");
	
	if( !VSH2_HookEx(OnBossMedicCall, PlagueDoc_OnBossMedicCall) )
		LogError("Error loading OnBossMedicCall forwards for Plague Doctor subplugin.");
	
	if( !VSH2_HookEx(OnBossTaunt, PlagueDoc_OnBossMedicCall) )
		LogError("Error loading OnBossTaunt forwards for Plague Doctor subplugin.");
	
	if( !VSH2_HookEx(OnBossJarated, PlagueDoc_OnBossJarated) )
		LogError("Error loading OnBossJarated forwards for Plague Doctor subplugin.");
	
	if( !VSH2_HookEx(OnRoundEndInfo, PlagueDoc_OnRoundEndInfo) )
		LogError("Error loading OnRoundEndInfo forwards for Plague Doctor subplugin.");
}


stock bool IsPlagueDoctor(VSH2Player player) {
	return player.GetPropInt("iBossType") == plague_doc.id;
}

public void PlagueDoc_OnCallDownloads() {
	{
		int boss_mdl_len = plague_doc.cfg.GetSize("model");
		char[] boss_mdl_str = new char[boss_mdl_len];
		if( plague_doc.cfg.Get("model", boss_mdl_str, boss_mdl_len) > 0 ) {
			PrepareModel(boss_mdl_str);
		}
		ConfigMap skins = plague_doc.cfg.GetSection("skins");
		PrepareAssetsFromCfgMap(skins, ResourceMaterial);
	}
	{
		int zomb_mdl_len = plague_doc.cfg.GetSize("minion model");
		char[] zomb_mdl_str = new char[zomb_mdl_len];
		if( plague_doc.cfg.Get("minion model", zomb_mdl_str, zomb_mdl_len) > 0 ) {
			PrepareModel(zomb_mdl_str);
		}
		ConfigMap skins = plague_doc.cfg.GetSection("minion skins");
		PrepareAssetsFromCfgMap(skins, ResourceMaterial);
	}
	{
		ConfigMap sounds_sect = plague_doc.cfg.GetSection("sounds");
		if( sounds_sect != null ) {
			PrepareAssetsFromCfgMap(sounds_sect.GetSection("intro"),     ResourceSound);
			PrepareAssetsFromCfgMap(sounds_sect.GetSection("rage"),      ResourceSound);
			PrepareAssetsFromCfgMap(sounds_sect.GetSection("superjump"), ResourceSound);
		}
	}
}

public void PlagueDoc_OnBossMenu(Menu &menu) {
	char tostr[10]; IntToString(plague_doc.id, tostr, sizeof(tostr));
	menu.AddItem(tostr, "Plague Doctor (Custom Boss)");
}

public void PlagueDoc_OnBossSelected(VSH2Player player) {
	if( !IsPlagueDoctor(player) || IsVoteInProgress() ) {
		return;
	}
	
	int help_len = plague_doc.cfg.GetSize("help panel");
	char[] help_str = new char[help_len];
	plague_doc.cfg.Get("help panel", help_str, help_len);
	
	Panel panel = new Panel();
	panel.SetTitle(help_str);
	panel.DrawItem("Exit");
	panel.Send(player.index, HintPanel, 10);
	delete panel;
}

public void PlagueDoc_OnBossThink(VSH2Player player) {
	int client = player.index;
	if( !IsPlayerAlive(client) || !IsPlagueDoctor(player) ) {
		return;
	}
	
	player.SpeedThink(plague_doc.run_speed.FloatValue);
	player.GlowThink(plague_doc.glow_iota.FloatValue);
	if( player.SuperJumpThink(plague_doc.charge_amnt.FloatValue, plague_doc.max_jmp_charge.FloatValue) ) {
		player.SuperJump(player.GetPropFloat("flCharge"), plague_doc.jmp_reset.FloatValue);
		ConfigMap superjump_sect = plague_doc.cfg.GetSection("sounds.superjump");
		player.PlayRandVoiceClipCfgMap(superjump_sect, VSH2_VOICE_ABILITY);
	}
	
	if( VSH2GameMode.AreScoutsLeft() ) {
		player.SetPropFloat("flRAGE", player.GetPropFloat("flRAGE") + plague_doc.scout_rage_gen.FloatValue);
	}
	player.WeighDownThink(plague_doc.wghdwn_time.FloatValue, plague_doc.wghdwn_iota.FloatValue);
	
	/// hud code
	SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
	Handle hud = plague_doc.gm.hHUD;
	float jmp = player.GetPropFloat("flCharge");
	float rage = player.GetPropFloat("flRAGE");
	if( rage >= 100.0 ) {
		ShowSyncHudText(client, hud, "Jump: %i%% | Rage: FULL - Call Medic (default: E) to activate", player.GetPropInt("bSuperCharge")? 1000 : RoundFloat(jmp) * 4);
	} else {
		ShowSyncHudText(client, hud, "Jump: %i%% | Rage: %0.1f", player.GetPropInt("bSuperCharge")? 1000 : RoundFloat(jmp) * 4, rage);
	}
}

public void PlagueDoc_OnBossModelTimer(VSH2Player player) {
	if( !IsPlagueDoctor(player) ) {
		return;
	}
	int client = player.index;
	int boss_mdl_len = plague_doc.cfg.GetSize("model");
	char[] boss_mdl = new char[boss_mdl_len];
	plague_doc.cfg.Get("model", boss_mdl, boss_mdl_len);
	SetVariantString(boss_mdl);
	AcceptEntityInput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
}

public void PlagueDoc_OnBossEquipped(VSH2Player player) {
	if( !IsPlagueDoctor(player) ) {
		return;
	}
	char boss_name_str[MAX_BOSS_NAME_SIZE];
	plague_doc.cfg.Get("name", boss_name_str, sizeof(boss_name_str));
	player.SetName(boss_name_str);
	player.RemoveAllItems();
	
	ConfigMap melee_wep = plague_doc.cfg.GetSection("melee");
	if( melee_wep==null ) {
		return;
	}
	
	int attribs_len = melee_wep.GetSize("attribs");
	char[] attribs_str = new char[attribs_len];
	melee_wep.Get("attribs", attribs_str, attribs_len);
	
	int classname_len = melee_wep.GetSize("classname");
	char[] classname_str = new char[classname_len];
	melee_wep.Get("classname", classname_str, classname_len);
	
	int index, level, quality;
	melee_wep.GetInt("index",   index);
	melee_wep.GetInt("level",   level);
	melee_wep.GetInt("quality", quality);
	
	int wep = player.SpawnWeapon(classname_str, index, level, quality, attribs_str);
	SetEntPropEnt(player.index, Prop_Send, "m_hActiveWeapon", wep);
}

public void PlagueDoc_OnBossInitialized(VSH2Player player) {
	if( !IsPlagueDoctor(player) )
		return;
	
	SetEntProp(player.index, Prop_Send, "m_iClass", view_as< int >(TFClass_Medic));
}

public void PlagueDoc_OnMinionInitialized(VSH2Player player, VSH2Player master) {
	if( !IsPlagueDoctor(master) )
		return;
	
	int client = player.index;
	TF2_SetPlayerClass(client, TFClass_Scout, _, false);
	player.RemoveAllItems();
#if defined _tf2attributes_included
	if( VSH2GameMode.GetPropInt("bTF2Attribs") ) {
		TF2Attrib_RemoveAll(client);
	}
#endif
	ConfigMap melee_wep = plague_doc.cfg.GetSection("minion melee");
	if( melee_wep==null ) {
		return;
	}
	
	int attribs_len = melee_wep.GetSize("attribs");
	char[] attribs_str = new char[attribs_len];
	melee_wep.Get("attribs", attribs_str, attribs_len);
	
	int classname_len = melee_wep.GetSize("classname");
	char[] classname_str = new char[classname_len];
	melee_wep.Get("classname", classname_str, classname_len);
	
	int index, level, quality;
	melee_wep.GetInt("index",   index);
	melee_wep.GetInt("level",   level);
	melee_wep.GetInt("quality", quality);
	int weapon = player.SpawnWeapon(classname_str, index, level, quality, attribs_str);
	
	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
	TF2_AddCondition(client, TFCond_Ubercharged, plague_doc.minion_uber_time.FloatValue);
	SetEntityHealth(client, 200);
	
	int zomb_mdl_len = plague_doc.cfg.GetSize("minion model");
	char[] zomb_mdl = new char[zomb_mdl_len];
	plague_doc.cfg.Get("minion model", zomb_mdl, zomb_mdl_len);
	SetVariantString(zomb_mdl);
	
	AcceptEntityInput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
	SetEntProp(client, Prop_Send, "m_nBody", 0);
	SetEntityRenderMode(client, RENDER_TRANSCOLOR);
	SetEntityRenderColor(client, 30, 160, 255, 255);
}

public void PlagueDoc_OnBossPlayIntro(VSH2Player player) {
	if( !IsPlagueDoctor(player) )
		return;
	
	ConfigMap intro_sect = plague_doc.cfg.GetSection("sounds.intro");
	player.PlayRandVoiceClipCfgMap(intro_sect, VSH2_VOICE_INTRO);
}

public void KilledPlayer(VSH2Player attacker, VSH2Player victim, Event event) {
	/// GLITCH: suiciding allows boss to become own minion.
	if( attacker.userid==victim.userid ) {
		return;
	} else if( event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER ) {
		/// PATCH: Hitting spy with active deadringer turns them into Minion...
		return;
	} else if( TF2_IsPlayerInCondition(victim.index, TFCond_Disguised) ) {
		/// PATCH: killing spy with teammate disguise kills both spy and the teammate he disguised as...
		TF2_RemovePlayerDisguise(victim.index); //event.SetInt("userid", victim.userid);
	}
	victim.hOwnerBoss = attacker;
	victim.ConvertToMinion(0.4);
}

public void PlagueDoc_OnPlayerKilled(VSH2Player attacker, VSH2Player victim, Event event) {
	//int deathflags = event.GetInt("death_flags");
	/// attacker is plague doctor!
	if( attacker.bIsBoss && IsPlagueDoctor(attacker) ) {
		KilledPlayer(attacker, victim, event);
	} else if( attacker.GetPropInt("bIsMinion") ) {
		/// attacker is a plague doctor minion!
		VSH2Player owner = attacker.hOwnerBoss;
		if( IsPlagueDoctor(owner) ) {
			KilledPlayer(owner, victim, event);
		}
	}
	
	if( victim.GetPropInt("bIsMinion") ) {
		/// Cap respawning minions by the amount of minions there are * 1.5.
		/// If 10 minions, then respawn them in 15 seconds.
		VSH2Player owner = victim.hOwnerBoss;
		if( IsPlagueDoctor(owner) && IsPlayerAlive(owner.index) ) {
			int minions = VSH2GameMode.CountMinions(false, owner);
			victim.ConvertToMinion(minions * plague_doc.minion_spawn.FloatValue);
		}
	}
}

public void PlagueDoc_OnPlayerHurt(VSH2Player attacker, VSH2Player victim, Event event) {
	int damage = event.GetInt("damageamount");
	if( !victim.bIsBoss && victim.GetPropInt("bIsMinion") && !attacker.GetPropInt("bIsMinion") ) {
		/// Have boss take damage if minions are hurt by players,
		/// this prevents bosses from hiding just because they gained minions.
		VSH2Player ownerBoss = victim.hOwnerBoss;
		if( IsPlagueDoctor(ownerBoss) ) {
			//ownerBoss.SetPropInt("iHealth", GetClientHealth(ownerBoss.index)-damage);
			SDKHooks_TakeDamage(ownerBoss.index, attacker.index, attacker.index, damage+0.0, DMG_DIRECT, 0);
			//ownerBoss.GiveRage(damage);
		}
		return;
	}
	
	if( IsPlagueDoctor(victim) && victim.bIsBoss ) {
		victim.GiveRage(damage);
	}
}

public void PlagueDoc_OnPlayerAirblasted(VSH2Player airblaster, VSH2Player airblasted, Event event) {
	if( !IsPlagueDoctor(airblasted) )
		return;
	
	float rage = airblasted.GetPropFloat("flRAGE");
	airblasted.SetPropFloat("flRAGE", rage + plague_doc.airblast_rage.FloatValue);
}

public void PlagueDoc_OnBossMedicCall(VSH2Player rager) {
	if( !IsPlagueDoctor(rager) )
		return;
	
	float rage = rager.GetPropFloat("flRAGE");
	if( rage < 100.0 )
		return;
	
	float rage_time = plague_doc.rage_time.FloatValue;
	int attribute = 0;
	float value = 0.0;
	TF2_AddCondition(rager.index, TFCond_MegaHeal, rage_time);
	switch( GetRandomInt(0, 2) ) {
		case 0: { attribute = 2;   value = 2.0;   } /// Extra damage
		case 1: { attribute = 26;  value = 100.0; } /// Extra health
		case 2: { attribute = 107; value = 2.0;   } /// Extra speed
	}
	
	VSH2Player[] minions = new VSH2Player[MaxClients];
	int minion_count = VSH2GameMode.GetMinions(minions, false, rager);
	for( int i; i < minion_count; i++ ) {
		if( minions[i].hOwnerBoss != rager ) {
			continue;
		}
		int m = minions[i].index;
	#if defined _tf2attributes_included
		bool tf2attribs_enabled = VSH2GameMode.GetPropAny("bTF2Attribs");
		if( tf2attribs_enabled ) {
			TF2Attrib_SetByDefIndex(m, attribute, value);
			SetPawnTimer(TF2AttribsRemove, rage_time, m);
		} else {
			char pdapower[32]; Format(pdapower, sizeof(pdapower), "%i ; %f", attribute, value);
			int wep = minions[i].SpawnWeapon("tf_weapon_builder", 28, 5, 10, pdapower);
			SetPawnTimer(RemoveWepFromSlot, rage_time, m, GetSlotFromWeapon(m, wep));
		}
	#else
		char pdapower[32]; Format(pdapower, sizeof(pdapower), "%i ; %f", attribute, value);
		int wep = minions[i].SpawnWeapon("tf_weapon_builder", 28, 5, 10, pdapower);
		SetPawnTimer(RemoveWepFromSlot, rage_time, m, GetSlotFromWeapon(m, wep));
	#endif
	}
	rager.SetPropFloat("flRAGE", 0.0);
	ConfigMap rage_sect = plague_doc.cfg.GetSection("sounds.rage");
	rager.PlayRandVoiceClipCfgMap(rage_sect, VSH2_VOICE_RAGE);
}

public void PlagueDoc_OnBossJarated(VSH2Player victim, VSH2Player thrower) {
	if( !IsPlagueDoctor(victim) )
		return;
	
	float rage = victim.GetPropFloat("flRAGE");
	victim.SetPropFloat("flRAGE", rage - plague_doc.jarate_rage.FloatValue);
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool &result) {
	VSH2Player player = VSH2Player(client);
	if( player.GetPropInt("bIsMinion") ) {
		if( IsPlagueDoctor(player.hOwnerBoss) ) {
			player.ClimbWall(weapon, plague_doc.minion_climb_vel.FloatValue, 0.0, false);
		}
		result = false;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public void PlagueDoc_OnRoundEndInfo(VSH2Player player, bool boss_won, char message[MAXMESSAGE]) {
	if( !IsPlagueDoctor(player) ) {
		return;
	}
	
	if( boss_won ) {
		/// play Boss Wins sounds here!
	}
}


stock bool IsValidClient(int client, bool nobots=false) {
	if( client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)) ) {
		return false;
	}
	return IsClientInGame(client);
}

stock int GetSlotFromWeapon(int iClient, int iWeapon) {
	for( int i; i < 5; i++ ) {
		if( iWeapon==GetPlayerWeaponSlot(iClient, i) ) {
			return i;
		}
	}
	return -1;
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

public int HintPanel(Menu menu, MenuAction action, int param1, int param2) {
	return 0;
}