#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <vsh2>

#undef REQUIRE_PLUGIN
#tryinclude <tf2attributes>
#define REQUIRE_PLUGIN


public Plugin myinfo = {
	name        = "VSH2 Template Boss Module",
	author      = "Nergal/Assyrian",
	description = "",
	version     = "1.0",
	url         = "https://github.com/VSH2-Devs/Vs-Saxton-Hale-2"
};


enum struct TemplateBoss {
	int          id;
	VSH2GameMode gm;
	ConfigMap    cfg;
	ConVar       scout_rage_gen;
	ConVar       airblast_rage;
	ConVar       jarate_rage;
}
TemplateBoss template_boss;


public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		template_boss.scout_rage_gen = FindConVar("vsh2_scout_rage_gen");
		template_boss.airblast_rage  = FindConVar("vsh2_airblast_rage");
		template_boss.jarate_rage    = FindConVar("vsh2_jarate_rage");
		template_boss.cfg            = new ConfigMap("configs/saxton_hale/boss_cfgs/template_boss.cfg");
		if( template_boss.cfg==null ) {
			/// prevent template boss from registering if no config file was found.
			LogError("[VSH 2] ERROR :: **** couldn't find 'configs/saxton_hale/boss_cfgs/template_boss.cfg'. Failed to register Template Boss module. ****");
			return;
		}
		char plugin_name_str[MAX_BOSS_NAME_SIZE];
		template_boss.cfg.Get("boss.plugin name", plugin_name_str, sizeof(plugin_name_str));
		template_boss.id = VSH2_RegisterPlugin(plugin_name_str);
		LoadVSH2Hooks();
	}
}

public void LoadVSH2Hooks() {
	if( !VSH2_HookEx(OnCallDownloads, Template_OnCallDownloads) )
		LogError("Error loading OnCallDownloads forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossMenu, Template_OnBossMenu) )
		LogError("Error loading OnBossMenu forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossSelected, Template_OnBossSelected) )
		LogError("Error loading OnBossSelected forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossThink, Template_OnBossThink) )
		LogError("Error loading OnBossThink forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossModelTimer, Template_OnBossModelTimer) )
		LogError("Error loading OnBossModelTimer forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossEquipped, Template_OnBossEquipped) )
		LogError("Error loading OnBossEquipped forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossInitialized, Template_OnBossInitialized) )
		LogError("Error loading OnBossInitialized forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossPlayIntro, Template_OnBossPlayIntro) )
		LogError("Error loading OnBossPlayIntro forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnPlayerKilled, Template_OnPlayerKilled) )
		LogError("Error loading OnPlayerKilled forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnPlayerHurt, Template_OnPlayerHurt) )
		LogError("Error loading OnPlayerHurt forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnPlayerAirblasted, Template_OnPlayerAirblasted) )
		LogError("Error loading OnPlayerAirblasted forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossMedicCall, Template_OnBossMedicCall) )
		LogError("Error loading OnBossMedicCall forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossTaunt, Template_OnBossMedicCall) )
		LogError("Error loading OnBossTaunt forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossJarated, Template_OnBossJarated) )
		LogError("Error loading OnBossJarated forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnRoundEndInfo, Template_OnRoundEndInfo) )
		LogError("Error loading OnRoundEndInfo forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnMusic, Template_Music) )
		LogError("Error loading OnMusic forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossDeath, Template_OnBossDeath) )
		LogError("Error loading OnBossDeath forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnStabbed, Template_OnStabbed) )
		LogError("Error loading OnBossTakeDamage_OnStabbed forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnLastPlayer, Template_OnLastPlayer) )
		LogError("Error loading OnLastPlayer forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnSoundHook, Template_OnSoundHook) )
		LogError("Error loading OnSoundHook forwards for Template subplugin.");
}


stock bool IsTemplate(const VSH2Player player) {
	return player.GetPropInt("iBossType") == template_boss.id;
}

public void Template_OnCallDownloads() {
	{
		/// model.
		int boss_mdl_len = template_boss.cfg.GetSize("boss.model");
		char[] boss_mdl_str = new char[boss_mdl_len];
		if( template_boss.cfg.Get("boss.model", boss_mdl_str, boss_mdl_len) > 0 ) {
			PrepareModel(boss_mdl_str);
		}
		
		/// model skins.
		ConfigMap skins = template_boss.cfg.GetSection("boss.skins");
		PrepareAssetsFromCfgMap(skins, ResourceMaterial);
	}
	
	ConfigMap sounds_sect = template_boss.cfg.GetSection("boss.sounds");
	if( sounds_sect != null ) {
		PrepareAssetsFromCfgMap(sounds_sect.GetSection("intro"),      ResourceSound);
		PrepareAssetsFromCfgMap(sounds_sect.GetSection("rage"),       ResourceSound);
		PrepareAssetsFromCfgMap(sounds_sect.GetSection("jump"),       ResourceSound);
		PrepareAssetsFromCfgMap(sounds_sect.GetSection("backstab"),   ResourceSound);
		PrepareAssetsFromCfgMap(sounds_sect.GetSection("death"),      ResourceSound);
		PrepareAssetsFromCfgMap(sounds_sect.GetSection("lastplayer"), ResourceSound);
		PrepareAssetsFromCfgMap(sounds_sect.GetSection("kill"),       ResourceSound);
		PrepareAssetsFromCfgMap(sounds_sect.GetSection("spree"),      ResourceSound);
		PrepareAssetsFromCfgMap(sounds_sect.GetSection("win"),        ResourceSound);
		PrepareAssetsFromCfgMap(sounds_sect.GetSection("music"),      ResourceSound);
	}
}

public void Template_OnBossMenu(Menu& menu) {
	char tostr[10]; IntToString(template_boss.id, tostr, sizeof(tostr));
	/// ConfigMap can be used to store the boss name.
	int menu_name_len = template_boss.cfg.GetSize("boss.menu name");
	char[] menu_name_str = new char[menu_name_len];
	template_boss.cfg.Get("boss.menu name", menu_name_str, menu_name_len);
	menu.AddItem(tostr, menu_name_str);
}

public void Template_OnBossSelected(const VSH2Player player) {
	if( !IsTemplate(player) )
		return;
	
	player.SetPropInt("iCustomProp", 0);
	player.SetPropFloat("flCustomProp", 0.0);
	player.SetPropAny("hCustomProp", player);
	
	/// ConfigMap is also useful for automating custom prop creation.
	ConfigMap custom_props = template_boss.cfg.GetSection("boss.custom props");
	if( custom_props != null ) {
		for( int i; i<custom_props.Size; i++ ) {
			int prop_len = template_boss.cfg.GetIntKeySize(i);
			char[] prop_name = new char[prop_len];
			template_boss.cfg.GetIntKey(i, prop_name, prop_len);
			
			char prop[64]; strcopy(prop, sizeof prop, prop_name);
			player.SetPropInt(prop, 0);
		}
	}
	
	Panel panel = new Panel();
	int panel_len = template_boss.cfg.GetSize("boss.help panel");
	char[] panel_info = new char[panel_len];
	template_boss.cfg.Get("boss.help panel", panel_info, panel_len);
	panel.SetTitle(panel_info);
	panel.DrawItem("Exit");
	panel.Send(player.index, HintPanel, 999);
	delete panel;
}

public void Template_OnBossThink(const VSH2Player player) {
	int client = player.index;
	if( !IsPlayerAlive(client) || !IsTemplate(player) )
		return;
	
	player.SpeedThink(340.0);
	player.GlowThink(0.1);
	if( player.SuperJumpThink(2.5, 25.0) ) {
		player.PlayRandVoiceClipCfgMap(template_boss.cfg.GetSection("boss.sounds.jump"), VSH2_VOICE_ABILITY);
		player.SuperJump(player.GetPropFloat("flCharge"), -100.0);
	}
	
	if( OnlyScoutsLeft() ) {
		player.SetPropFloat("flRAGE", player.GetPropFloat("flRAGE") + template_boss.scout_rage_gen.FloatValue);
	}
	player.WeighDownThink(2.0, 0.1);
	
	/// hud code
	SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
	Handle hud = template_boss.gm.hHUD;
	float  jmp = player.GetPropFloat("flCharge");
	float  rage = player.GetPropFloat("flRAGE");
	if( rage >= 100.0 ) {
		ShowSyncHudText(client, hud, "Jump: %i%% | Rage: FULL - Call Medic (default: E) to activate", player.GetPropInt("bSuperCharge") ? 1000 : RoundFloat(jmp) * 4);
	} else {
		ShowSyncHudText(client, hud, "Jump: %i%% | Rage: %0.1f", player.GetPropInt("bSuperCharge") ? 1000 : RoundFloat(jmp) * 4, rage);
	}
}

public void Template_OnBossModelTimer(const VSH2Player player) {
	if( !IsTemplate(player) )
		return;
	
	int client = player.index;
	int boss_mdl_len = template_boss.cfg.GetSize("boss.model");
	char[] boss_mdl = new char[boss_mdl_len];
	template_boss.cfg.Get("boss.model", boss_mdl, boss_mdl_len);
	SetVariantString(boss_mdl);
	AcceptEntityInput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
}

public void Template_OnBossEquipped(const VSH2Player player) {
	if( !IsTemplate(player) )
		return;
	
	char name[MAX_BOSS_NAME_SIZE];
	template_boss.cfg.Get("boss.name", name, sizeof(name));
	player.SetName(name);
	
	player.RemoveAllItems();
	ConfigMap melee_wep = template_boss.cfg.GetSection("boss.melee");
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

public void Template_OnBossInitialized(const VSH2Player player) {
	if( !IsTemplate(player) )
		return;
	
	SetEntProp(player.index, Prop_Send, "m_iClass", view_as< int >(TFClass_Soldier));
}

public void Template_OnBossPlayIntro(const VSH2Player player) {
	if( !IsTemplate(player) )
		return;
	
	player.PlayRandVoiceClipCfgMap(template_boss.cfg.GetSection("boss.sounds.intro"), VSH2_VOICE_INTRO);
}

public void Template_OnPlayerKilled(const VSH2Player attacker, const VSH2Player victim, Event event) {
	if( !IsTemplate(attacker) )
		return;
	
	float curtime = GetGameTime();
	if( curtime <= attacker.GetPropFloat("flKillSpree") ) {
		attacker.SetPropInt("iKills", attacker.GetPropInt("iKills") + 1);
	} else {
		attacker.SetPropInt("iKills", 0);
	}
	
	attacker.PlayRandVoiceClipCfgMap(template_boss.cfg.GetSection("boss.sounds.kill"), VSH2_VOICE_SPREE);
	if( attacker.GetPropInt("iKills") == 3 && template_boss.gm.iLivingReds != 1 ) {
		attacker.PlayRandVoiceClipCfgMap(template_boss.cfg.GetSection("boss.sounds.spree"), VSH2_VOICE_SPREE);
		attacker.SetPropInt("iKills", 0);
	} else {
		attacker.SetPropFloat("flKillSpree", curtime + 5.0);
	}
}

public void Template_OnPlayerHurt(const VSH2Player attacker, const VSH2Player victim, Event event) {
	int damage = event.GetInt("damageamount");
	if( victim.bIsBoss && IsTemplate(victim) ) {
		victim.GiveRage(damage);
	}
}

public void Template_OnPlayerAirblasted(const VSH2Player airblaster, const VSH2Player airblasted, Event event) {
	if( !IsTemplate(airblasted) )
		return;
	
	float rage = airblasted.GetPropFloat("flRAGE");
	airblasted.SetPropFloat("flRAGE", rage + template_boss.airblast_rage.FloatValue);
}

public void Template_OnBossMedicCall(const VSH2Player player) {
	if( !IsTemplate(player) || player.GetPropFloat("flRAGE") < 100.0 )
		return;
	
	player.DoGenericStun(800.0);
	VSH2Player[] players = new VSH2Player[MaxClients];
	int in_range = player.GetPlayersInRange(players, 800.0);
	for( int i; i<in_range; i++ ) {
		if( players[i].bIsBoss || players[i].bIsMinion ) {
			continue;
		}
		/// do a distance based thing here.
	}
	player.PlayRandVoiceClipCfgMap(template_boss.cfg.GetSection("boss.sounds.rage"), VSH2_VOICE_RAGE);
	player.SetPropFloat("flRAGE", 0.0);
}

public void Template_OnBossJarated(const VSH2Player victim, const VSH2Player thrower) {
	if( !IsTemplate(victim) )
		return;
	
	float rage = victim.GetPropFloat("flRAGE");
	victim.SetPropFloat("flRAGE", rage - template_boss.jarate_rage.FloatValue);
}


public void Template_OnRoundEndInfo(const VSH2Player player, bool boss_won, char message[MAXMESSAGE]) {
	if( !IsTemplate(player) ) {
		return;
	} else if( boss_won ) {
		player.PlayRandVoiceClipCfgMap(template_boss.cfg.GetSection("boss.sounds.win"), VSH2_VOICE_WIN);
	}
}


public void Template_Music(char song[PLATFORM_MAX_PATH], float &time, const VSH2Player player) {
	if( !IsTemplate(player) )
		return;
	
	ConfigMap music_sect = template_boss.cfg.GetSection("boss.sounds.music");
	ConfigMap music_time_sect = template_boss.cfg.GetSection("boss.sounds.music time");
	if( music_sect==null || music_time_sect==null ) {
		return;
	}
	
	int size = (music_sect.Size > music_time_sect.Size)? music_time_sect.Size : music_sect.Size;
	static int index;
	index = ShuffleIndex(size, index);
	music_sect.GetIntKey(index, song, sizeof(song));
	music_time_sect.GetIntKeyFloat(index, time);
}

public void Template_OnBossDeath(const VSH2Player player) {
	if( !IsTemplate(player) )
		return;
	
	player.PlayRandVoiceClipCfgMap(template_boss.cfg.GetSection("boss.sounds.death"), VSH2_VOICE_LOSE);
}

public Action Template_OnStabbed(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if( !IsTemplate(victim) )
		return Plugin_Continue;
	
	victim.PlayRandVoiceClipCfgMap(template_boss.cfg.GetSection("boss.sounds.backstab"), VSH2_VOICE_STABBED);
	return Plugin_Continue;
}

public void Template_OnLastPlayer(const VSH2Player player) {
	if( !IsTemplate(player) )
		return;
	
	player.PlayRandVoiceClipCfgMap(template_boss.cfg.GetSection("boss.sounds.lastplayer"), VSH2_VOICE_LASTGUY);
}

public Action Template_OnSoundHook(const VSH2Player player, char sample[PLATFORM_MAX_PATH], int& channel, float& volume, int& level, int& pitch, int& flags)
{
	if( !IsTemplate(player) ) {
		return Plugin_Continue;
	} else if( IsVoiceLine(sample) ) {
		/// this code: returning Plugin_Handled blocks the sound, a voiceline in this case.
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

/// Stocks =============================================
stock bool IsValidClient(const int client, bool nobots=false) {
	if( client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)) )
		return false;
	return IsClientInGame(client);
}

stock int GetSlotFromWeapon(const int client, const int wep) {
	for( int i; i<5; i++ )
		if( wep==GetPlayerWeaponSlot(client, i) )
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

stock void SetPawnTimerEx(Function func, float thinktime = 0.1, const any[] args, const int len) {
	DataPack thinkpack = new DataPack();
	thinkpack.WriteFunction(func);
	thinkpack.WriteCell(len);
	for( int i; i<len; i++ ) {
		thinkpack.WriteCell(args[i]);
	}
	CreateTimer(thinktime, DoPawnTimer, thinkpack, TIMER_DATA_HNDL_CLOSE);
}

public Action DoPawnTimer(Handle t, DataPack pack) {
	pack.Reset();
	Function fn = pack.ReadFunction();
	Call_StartFunction(null, fn);
	
	int len = pack.ReadCell();
	for( int i; i<len; i++ ) {
		any param = pack.ReadCell();
		Call_PushCell(param);
	}
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
	return 0;
}
