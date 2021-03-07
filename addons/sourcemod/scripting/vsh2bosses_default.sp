#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>
#include <vsh2>
#include <cfgmap>

char boss_names[][] = {
	"saxton_hale",
	"vagineer",
	"christian_brutal_sniper",
	"hhh_jr",
	"easter_bunny"
};

enum struct VSH2CVars {
	ConVar scout_rage_gen;
	ConVar airblast_rage;
	ConVar jarate_rage;
	ConVar hhh_max_climbs;
	ConVar hhh_tele_cooldown;
}

enum struct BossData {
	float move_speed;
	float glow_time;
	float jump_charge_rate;
	float jump_max;
	float jump_reset;
	float weighdown_time;
	float weighdown_incr;
	
	void Load(ConfigMap cfg) {
		cfg.GetFloat("boss data.move speed",        this.move_speed);
		cfg.GetFloat("boss data.glow time iota",    this.glow_time);
		cfg.GetFloat("boss data.jump charge",       this.jump_charge_rate);
		cfg.GetFloat("boss data.jump charge max",   this.jump_max);
		cfg.GetFloat("boss data.jump charge reset", this.jump_reset);
		cfg.GetFloat("boss data.weighdown time",    this.weighdown_time);
		cfg.GetFloat("boss data.weighdown incr",    this.weighdown_incr);
	}
}

enum struct DefVSH2Bosses {
	int       m_iBossID[MaxDefaultVSH2Bosses];
	ConfigMap m_hBossCfgs[MaxDefaultVSH2Bosses];
}

public Plugin myinfo = {
	name=        "VSH2 Default Bosses Module",
	author=      "Nergal/Assyrian",
	description= "",
	version=     "1.0",
	url=         "sus"
};

VSH2CVars     g_vsh2_cvars;
VSH2GameMode  g_vsh2_gm;
DefVSH2Bosses g_defbosses;
BossData      g_boss_data[MaxDefaultVSH2Bosses];


stock int GetDefBoss(VSH2Player player) {
	int boss_type = player.GetPropInt("iBossType");
	for( int i; i<MaxDefaultVSH2Bosses; i++ ) {
		if( boss_type==g_defbosses.m_iBossID[i] ) {
			return i;
		}
	}
	return -1;
}

stock bool IsDefBoss(int id) {
	return id >= VSH2Boss_Hale && id < MaxDefaultVSH2Bosses;
}

public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		g_vsh2_cvars.scout_rage_gen    = FindConVar("vsh2_scout_rage_gen");
		g_vsh2_cvars.airblast_rage     = FindConVar("vsh2_airblast_rage");
		g_vsh2_cvars.jarate_rage       = FindConVar("vsh2_jarate_rage");
		g_vsh2_cvars.hhh_max_climbs    = FindConVar("vsh2_hhhjr_max_climbs");
		g_vsh2_cvars.hhh_tele_cooldown = FindConVar("vsh2_hhh_tele_cooldown");
		
		for( int i; i<MaxDefaultVSH2Bosses; i++ ) {
			char cfg_path[PLATFORM_MAX_PATH];
			Format(cfg_path, sizeof(cfg_path), "configs/saxton_hale/%s.cfg", boss_names[i]);
			g_defbosses.m_hBossCfgs[i] = new ConfigMap(cfg_path);
			if( g_defbosses.m_hBossCfgs[i]==null ) {
				LogError("Error Adding Default VSH2 Bosses, missing cfg: 'configs/saxton_hale/boss_cfgs/%s.cfg'.", boss_names[i]);
				continue;
			}
			g_defbosses.m_iBossID[i] = VSH2_RegisterPlugin(boss_names[i]);
		}
		LoadVSH2Hooks();
	}
}

public void LoadVSH2Hooks() {
	if( !VSH2_HookEx(OnCallDownloads, DefaultBosses_OnDownloads) ) {
		LogError("Error loading OnCallDownloads forwards for Template subplugin.");
	}
	
	if( !VSH2_HookEx(OnBossMenu, DefaultBosses_OnMenu) ) {
		LogError("Error loading OnBossMenu forwards for Template subplugin.");
	}
	
	if( !VSH2_HookEx(OnBossSelected, DefaultBosses_OnSelected) ) {
		LogError("Error loading OnBossSelected forwards for Template subplugin.");
	}
	
	if( !VSH2_HookEx(OnBossThink, DefaultBosses_OnThink) ) {
		LogError("Error loading OnBossThink forwards for Template subplugin.");
	}
	
	if( !VSH2_HookEx(OnBossModelTimer, DefaultBosses_OnModel) ) {
		LogError("Error loading OnBossModelTimer forwards for Template subplugin.");
	}
	
	if( !VSH2_HookEx(OnBossEquipped, DefaultBosses_OnEquip) ) {
		LogError("Error loading OnBossEquipped forwards for Template subplugin.");
	}
	
	if( !VSH2_HookEx(OnBossInitialized, DefaultBosses_OnInit) ) {
		LogError("Error loading OnBossInitialized forwards for Template subplugin.");
	}
	
	if( !VSH2_HookEx(OnBossPlayIntro, DefaultBosses_OnIntro) ) {
		LogError("Error loading OnBossPlayIntro forwards for Template subplugin.");
	}
	
	if( !VSH2_HookEx(OnPlayerKilled, DefaultBosses_OnKill) ) {
		LogError("Error loading OnPlayerKilled forwards for Template subplugin.");
	}
	
	if( !VSH2_HookEx(OnPlayerHurt, DefaultBosses_OnHurt) ) {
		LogError("Error loading OnPlayerHurt forwards for Template subplugin.");
	}
	
	if( !VSH2_HookEx(OnPlayerAirblasted, DefaultBosses_OnAirblasted) ) {
		LogError("Error loading OnPlayerAirblasted forwards for Template subplugin.");
	}
	
	if( !VSH2_HookEx(OnBossMedicCall, DefaultBosses_OnMedCall) ) {
		LogError("Error loading OnBossMedicCall forwards for Template subplugin.");
	}
	
	if( !VSH2_HookEx(OnBossTaunt, DefaultBosses_OnMedCall) ) {
		LogError("Error loading OnBossTaunt forwards for Template subplugin.");
	}
	
	if( !VSH2_HookEx(OnBossJarated, DefaultBosses_OnJarated) ) {
		LogError("Error loading OnBossJarated forwards for Template subplugin.");
	}
	
	if( !VSH2_HookEx(OnRoundEndInfo, DefaultBosses_OnRoundEnd) ) {
		LogError("Error loading OnRoundEndInfo forwards for Template subplugin.");
	}
	
	if( !VSH2_HookEx(OnMusic, DefaultBosses_OnMusic) ) {
		LogError("Error loading OnMusic forwards for Template subplugin.");
	}
	
	if( !VSH2_HookEx(OnBossDeath, DefaultBosses_OnDeath) ) {
		LogError("Error loading OnBossDeath forwards for Template subplugin.");
	}
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnStabbed, DefaultBosses_OnStabbed) ) {
		LogError("Error loading OnBossTakeDamage_OnStabbed forwards for Template subplugin.");
	}
	
	if( !VSH2_HookEx(OnLastPlayer, DefaultBosses_OnLastPlayer) ) {
		LogError("Error loading OnLastPlayer forwards for Template subplugin.");
	}
	
	if( !VSH2_HookEx(OnSoundHook, DefaultBosses_OnVoice) ) {
		LogError("Error loading OnSoundHook forwards for Template subplugin.");
	}
}

public void DefaultBosses_OnMenu(Menu& menu) {
	for( int i; i<MaxDefaultVSH2Bosses; i++ ) {
		char cfg_path[PLATFORM_MAX_PATH];
		char tostr[10];
		IntToString(g_defbosses.m_iBossID[i], tostr, sizeof(tostr));
		int name_len = g_defbosses.m_hBossCfgs[i].GetSize("boss data.menu name");
		char[] name = new char[name_len];
		g_defbosses.m_hBossCfgs[i].Get("boss data.menu name", name, name_len);
		menu.AddItem(tostr, name);
	}
}

public void DefaultBosses_OnSelected(VSH2Player player) {
	int id = GetDefBoss(player);
	if( !IsDefBoss(id) )
		return;
	
	Panel panel = new Panel();
	int panel_len = g_defbosses.m_hBossCfgs[id].GetSize("boss data.panel msg");
	char[] panel_info = new char[panel_len];
	g_defbosses.m_hBossCfgs[id].Get("boss data.panel msg", panel_info, panel_len);
	panel.SetTitle(panel_info);
	panel.DrawItem("Exit");
	panel.Send(player.index, _panel_hint, 999);
	delete panel;
	
	g_boss_data[id].Load(g_defbosses.m_hBossCfgs[id]);
}

public int _panel_hint(Menu menu, MenuAction action, int param1, int param2) {
	return 0;
}

public void DefaultBosses_OnModel(VSH2Player player) {
	int id = GetDefBoss(player);
	if( !IsDefBoss(id) )
		return;
	
	int client = player.index;
	int model_len = g_defbosses.m_hBossCfgs[id].GetSize("boss data.models.body");
	char[] model_str = new char[model_len];
	g_defbosses.m_hBossCfgs[id].Get("boss data.models.body", model_str, model_len);
	SetVariantString(model_str);
	AcceptEntityInput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
}


public void DefaultBosses_OnDownloads() {
	for( int i; i<MaxDefaultVSH2Bosses; i++ ) {
		ConfigMap models_sect = g_defbosses.m_hBossCfgs[i].GetSection("boss data.models");
		if( models_sect != null ) {
			StringMapSnapshot snap = models_sect.Snapshot();
			int entries = snap.Length;
			for( int n; n<entries; n++ ) {
				int strsize = snap.KeyBufferSize(n) + 1;
				char[] key_buffer = new char[strsize];
				snap.GetKey(n, key_buffer, strsize);
				
				int file_len = models_sect.GetSize(key_buffer);
				char[] filepath = new char[file_len];
				if( models_sect.Get(key_buffer, filepath, file_len) > 0 ) {
					PrepareModel(filepath);
				}
			}
			delete snap;
		}
		
		ConfigMap skins_sect = g_defbosses.m_hBossCfgs[i].GetSection("boss data.skins");
		if( skins_sect != null ) {
			int sect_size = skins_sect.Size;
			for( int n; n<sect_size; n++ ) {
				int file_len = skins_sect.GetIntKeySize(n);
				char[] filepath = new char[file_len];
				if( skins_sect.GetIntKey(n, filepath, file_len) > 0 ) {
					PrepareMaterial(filepath);
				}
			}
		}
		
		ConfigMap sounds_sect = g_defbosses.m_hBossCfgs[i].GetSection("boss data.sounds");
		if( sounds_sect != null ) {
			StringMapSnapshot snap = sounds_sect.Snapshot();
			int entries = snap.Length;
			for( int x; x<entries; x++ ) {
				int strsize = snap.KeyBufferSize(x) + 1;
				char[] key_buffer = new char[strsize];
				snap.GetKey(x, key_buffer, strsize);
				ConfigMap sound_sect = sounds_sect.GetSection(key_buffer);
				if( sound_sect != null ) {
					int sect_size = sound_sect.Size;
					for( int n; n<sect_size; n++ ) {
						int file_len = sound_sect.GetIntKeySize(n);
						char[] filepath = new char[file_len];
						if( sound_sect.GetIntKey(n, filepath, file_len) > 0 ) {
							PrepareSound(filepath);
						}
					}
				}
			}
			delete snap;
		}
	}
}


public void DefaultBosses_OnThink(VSH2Player player) {
	int id = GetDefBoss(player);
	if( !IsDefBoss(id) )
		return;
	
	int client = player.index
	if( !IsPlayerAlive(client) )
		return;
	
	player.SpeedThink(g_boss_data[id].move_speed);
	player.GlowThink(g_boss_data[id].glow_time);
	if( id != VSH2Boss_HHHjr ) {
		/// Default Boss Super jump code.
		if( player.SuperJumpThink(g_boss_data[id].jump_charge_rate, g_boss_data[id].jump_max) ) {
			ConfigMap jmp_sect = g_defbosses.m_hBossCfgs[id].GetSection("boss data.sounds.super jump");
			if( jmp_sect != null ) {
				int jump_sound_count = jmp_sect.Size;
				if( jump_sound_count > 0 ) {
					int i = GetRandomInt(0, jump_sound_count-1);
					int jmp_sound_len = jmp_sect.GetIntKeySize(i);
					char[] jmp_sound = new char[jmp_sound_len];
					if( jmp_sect.GetIntKey(i, jmp_sound, jmp_sound_len) > 0 )
						player.PlayVoiceClip(jmp_sound, VSH2_VOICE_ABILITY);
				}
			}
			player.SuperJump(player.GetPropFloat("flCharge"), g_boss_data[id].jump_reset);
		}
	} else {
		/// HHH Jr's Teleport code here.
	}
	
	if( OnlyScoutsLeft(VSH2Team_Red) ) {
		player.SetPropFloat("flRAGE", player.GetPropFloat("flRAGE") + g_vsh2_cvars.scout_rage_gen.FloatValue);
	}
	
	player.WeighDownThink(g_boss_data[id].weighdown_time, g_boss_data[id].weighdown_incr);
	
	/// HUD code
	SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
	
	float jmp = player.GetPropFloat("flCharge");
	if( player.GetPropInt("bSuperCharge") > 0 ) {
		jmp *= 10.0;
	}

	float rage = player.GetPropFloat("flRAGE");
	char rage_text[] = " - Call Medic (default: E) to Activate"
	if( rage < 100.0 ) {
		Format(rage_text, sizeof(rage_text), "%0.1f", rage);
	}

	Handle hud = g_vsh2_gm.hHUD;
	switch( id ) {
		case VSH2Boss_Hale, VSH2Boss_Vagineer, VSH2Boss_CBS, VSH2Boss_Bunny: {
			ShowSyncHudText(client, hud, "Super Jump: %i%% | Rage: %s", RoundFloat(jmp / g_boss_data[id].jump_max), rage_text);
		}
		case VSH2Boss_HHHjr: {
			int max_climbs = g_vsh2_cvars.hhh_max_climbs.IntValue;
			int climbs = player.GetPropInt("iClimbs");
			ShowSyncHudText(client, hud, "Teleport: %i | Climbs: %i / %i | Rage: %s", RoundFloat(jmp / g_boss_data[id].jump_max), climbs, max_climbs, rage_text);
		}
	}
	
	if( id==VSH2Boss_Vagineer ) {
		SetEntProp(client, Prop_Data, "m_takedamage", TF2_IsPlayerInCondition(client, TFCond_Ubercharged) ? 0 : 2);
	}
}

public void DefaultBosses_OnEquip(VSH2Player player) {
	int id = GetDefBoss(player);
	if( !IsDefBoss(id) )
		return;
	
	char name[MAX_BOSS_NAME_SIZE];
	g_defbosses.m_hBossCfgs[id].Get("boss data.name", name, sizeof(name));
	player.SetName(name);
	player.RemoveAllItems();
	
	int attribs_len = g_defbosses.m_hBossCfgs[id].GetSize("boss data.attribs") + 64;
	char[] attribs = new char[attribs_len];
	g_defbosses.m_hBossCfgs[id].Get("boss data.attribs", attribs, attribs_len);
	
	int wep;
	switch( id ) {
		case VSH2Boss_Hale: {
			Format(attribs, attribs_len, "%s; 214 ; %i", attribs, GetRandomInt(9999, 99999));
			wep = player.SpawnWeapon("tf_weapon_shovel", 5, 100, 5, attribs);
		}
		case VSH2Boss_Vagineer:
			wep = player.SpawnWeapon("tf_weapon_wrench", 169, 100, 5, attribs);
		case VSH2Boss_CBS:
			wep = player.SpawnWeapon("tf_weapon_club", 171, 100, 5, attribs);
		case VSH2Boss_HHHjr: {
			wep = player.SpawnWeapon("tf_weapon_sword", 266, 100, 5, attribs);
			/// TODO: add config key-value for starting percentage?
			player.SetPropFloat("flCharge", g_vsh2_cvars.hhh_tele_cooldown.FloatValue * 0.9091);
		}
		case VSH2Boss_Bunny:
			wep = player.SpawnWeapon("tf_weapon_bottle", 609, 100, 5, attribs);
	}
	if( wep != 0 )
		SetEntPropEnt(player.index, Prop_Send, "m_hActiveWeapon", wep);
}

public void DefaultBosses_OnInit(VSH2Player player) {
	int id = GetDefBoss(player);
	if( !IsDefBoss(id) )
		return;
	
	int client = player.index;
	switch( id ) {
		case VSH2Boss_Hale:
			SetEntProp(client, Prop_Send, "m_iClass", view_as< int >(TFClass_Soldier));
		case VSH2Boss_Vagineer:
			SetEntProp(client, Prop_Send, "m_iClass", view_as< int >(TFClass_Engineer));
		case VSH2Boss_CBS:
			SetEntProp(client, Prop_Send, "m_iClass", view_as< int >(TFClass_Sniper));
		case VSH2Boss_HHHjr, VSH2Boss_Bunny:
			SetEntProp(client, Prop_Send, "m_iClass", view_as< int >(TFClass_DemoMan));
	}
}

public void DefaultBosses_OnIntro(VSH2Player player) {
	int id = GetDefBoss(player);
	if( !IsDefBoss(id) )
		return;
	
	ConfigMap intro_sounds = g_defbosses.m_hBossCfgs[id].GetSection("boss data.sounds.intros");
	if( intro_sounds != null ) {
		int intro_count = intro_sounds.Size;
		if( intro_count > 0 ) {
			int i = GetRandomInt(0, intro_count-1);
			int intro_len = intro_sounds.GetIntKeySize(i);
			char[] intro_sound = new char[intro_len];
			if( intro_sounds.GetIntKey(i, intro_sound, intro_len) > 0 )
				player.PlayVoiceClip(intro_sound, VSH2_VOICE_INTRO);
		}
	}
}

public void DefaultBosses_OnKill(VSH2Player attacker, VSH2Player victim, Event event) {
	int id = GetDefBoss(attacker);
	if( !IsDefBoss(id) )
		return;
	
	float curtime = GetGameTime();
	if( curtime <= attacker.GetPropFloat("flKillSpree") ) {
		attacker.SetPropInt("iKills", attacker.GetPropInt("iKills") + 1);
	} else {
		attacker.SetPropInt("iKills", 0);
	}
	
	ConfigMap kill_sounds = g_defbosses.m_hBossCfgs[id].GetSection("boss data.sounds.kill");
	if( kill_sounds != null ) {
		int kill_snd_count = kill_sounds.Size;
		if( kill_snd_count > 0 ) {
			int i = GetRandomInt(0, kill_snd_count-1);
			int kill_snd_len = kill_sounds.GetIntKeySize(i);
			char[] kill_sound = new char[kill_snd_len];
			if( kill_sounds.GetIntKey(i, kill_sound, kill_snd_len) > 0 )
				attacker.PlayVoiceClip(kill_sound, VSH2_VOICE_SPREE);
		}
	}
	
	if( attacker.GetPropInt("iKills") == 3 && g_vsh2_gm.iLivingReds != 1 ) {
		ConfigMap spree_sounds = g_defbosses.m_hBossCfgs[id].GetSection("boss data.sounds.spree");
		if( spree_sounds != null ) {
			int spree_snd_count = spree_sounds.Size;
			if( spree_snd_count > 0 ) {
				int i = GetRandomInt(0, spree_snd_count-1);
				int spree_snd_len = spree_sounds.GetIntKeySize(i);
				char[] spree_sound = new char[spree_snd_len];
				if( spree_sounds.GetIntKey(i, spree_sound, spree_snd_len) > 0 )
					attacker.PlayVoiceClip(spree_sound, VSH2_VOICE_SPREE);
			}
		}
		attacker.SetPropInt("iKills", 0);
	} else {
		attacker.SetPropFloat("flKillSpree", curtime + 5.0);
	}
}

public void DefaultBosses_OnHurt(VSH2Player attacker, VSH2Player victim, Event event) {
	int id = GetDefBoss(victim);
	if( !IsDefBoss(id) ) {
		return;
	} else if( victim.bIsBoss ) {
		int damage = event.GetInt("damageamount");
		victim.GiveRage(damage);
	}
}

public void DefaultBosses_OnAirblasted(VSH2Player airblaster, VSH2Player airblasted, Event event) {
	int id = GetDefBoss(airblasted);
	if( !IsDefBoss(id) )
		return;
	
	float rage = airblasted.GetPropFloat("flRAGE");
	airblasted.SetPropFloat("flRAGE", rage + g_vsh2_cvars.airblast_rage.FloatValue);
}

public void DefaultBosses_OnMedCall(VSH2Player player) {
	int id = GetDefBoss(player);
	if( !IsDefBoss(id) || player.GetPropFloat("flRAGE") < 100.0 )
		return;
	
	float rage_radius;
	g_defbosses.m_hBossCfgs[id].GetFloat("boss data.rage dist", rage_radius);
	player.DoGenericStun(rage_radius);
	
	switch( id ) {
		//case VSH2Boss_Hale:
			/// make hale have rage besides stunning?
		//case VSH2Boss_HHHjr:
			/// make hhhjr have rage besides stunning?
		case VSH2Boss_Vagineer:
			/// do uber here.
		case VSH2Boss_CBS:
			/// equip huntsmans here.
			/// TODO: get arrow amount from cfg or cvar.
		case VSH2Boss_Bunny:
			/// spew eggz here.
	}
	
	ConfigMap rage_sounds = g_defbosses.m_hBossCfgs[id].GetSection("boss data.sounds.rage");
	if( rage_sounds != null ) {
		int rage_snd_count = rage_sounds.Size;
		if( rage_snd_count > 0 ) {
			int i = GetRandomInt(0, rage_snd_count-1);
			int rage_snd_len = rage_sounds.GetIntKeySize(i);
			char[] rage_sound = new char[rage_snd_len];
			if( rage_sounds.GetIntKey(i, rage_sound, rage_snd_len) > 0 )
				player.PlayVoiceClip(rage_sound, VSH2_VOICE_RAGE);
		}
	}
	player.SetPropFloat("flRAGE", 0.0);
}

public void DefaultBosses_OnJarated(VSH2Player victim, VSH2Player thrower) {
	int id = GetDefBoss(victim);
	if( !IsDefBoss(id) )
		return;
	
	float rage = victim.GetPropFloat("flRAGE");
	victim.SetPropFloat("flRAGE", rage - g_vsh2_cvars.jarate_rage.FloatValue);
}

public void DefaultBosses_OnRoundEnd(VSH2Player player, bool boss_win, char message[MAXMESSAGE]) {
	int id = GetDefBoss(player);
	if( !IsDefBoss(id) ) {
		return;
	} else if( boss_win ) {
		ConfigMap win_sounds = g_defbosses.m_hBossCfgs[id].GetSection("boss data.sounds.win");
		if( win_sounds != null ) {
			int win_snd_count = win_sounds.Size;
			if( win_snd_count > 0 ) {
				int i = GetRandomInt(0, win_snd_count-1);
				int win_snd_len = win_sounds.GetIntKeySize(i);
				char[] win_sound = new char[win_snd_len];
				if( win_sounds.GetIntKey(i, win_sound, win_snd_len) > 0 )
					player.PlayVoiceClip(win_sound, VSH2_VOICE_WIN);
			}
		}
	}
}

public void DefaultBosses_OnMusic(char song[PLATFORM_MAX_PATH], float& time, VSH2Player player) {
	int id = GetDefBoss(player);
	if( !IsDefBoss(id) )
		return;
	
	ConfigMap music_sect = g_defbosses.m_hBossCfgs[id].GetSection("boss data.sounds.music");
	if( music_sect != null ) {
		int music_count = music_sect.Size;
		if( music_count > 0 ) {
			int i = GetRandomInt(0, music_count-1);
			ConfigMap music_times = g_defbosses.m_hBossCfgs[id].GetSection("boss data.music time");
			if( music_times != null ) {
				int music_len = music_sect.GetIntKeySize(i);
				char[] music_path = new char[music_len];
				if( music_sect.GetIntKey(i, music_path, music_len) > 0 ) {
					Format(song, sizeof(song), "%s", music_path);
					float music_time;
					if( music_times.GetIntKeyFloat(i, music_time) )
						time = music_time;
				}
			}
		}
	}
}

public void DefaultBosses_OnDeath(VSH2Player player) {
	int id = GetDefBoss(player);
	if( !IsDefBoss(id) )
		return;
	
	ConfigMap lose_sounds = g_defbosses.m_hBossCfgs[id].GetSection("boss data.sounds.lose");
	if( lose_sounds != null ) {
		int lose_snd_count = lose_sounds.Size;
		if( lose_snd_count > 0 ) {
			int i = GetRandomInt(0, lose_snd_count-1);
			int lose_snd_len = lose_sounds.GetIntKeySize(i);
			char[] lose_sound = new char[lose_snd_len];
			if( lose_sounds.GetIntKey(i, lose_sound, lose_snd_len) > 0 )
				player.PlayVoiceClip(lose_sound, VSH2_VOICE_LOSE);
		}
	}
}

public Action DefaultBosses_OnStabbed(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	int id = GetDefBoss(victim);
	if( !IsDefBoss(id) )
		return Plugin_Continue;
	
	ConfigMap stab_sounds = g_defbosses.m_hBossCfgs[id].GetSection("boss data.sounds.backstab");
	if( stab_sounds != null ) {
		int stab_snd_count = stab_sounds.Size;
		if( stab_snd_count > 0 ) {
			int i = GetRandomInt(0, stab_snd_count-1);
			int stab_snd_len = stab_sounds.GetIntKeySize(i);
			char[] stab_sound = new char[stab_snd_len];
			if( stab_sounds.GetIntKey(i, stab_sound, stab_snd_len) > 0 )
				victim.PlayVoiceClip(stab_sound, VSH2_VOICE_STABBED);
		}
	}
	return Plugin_Continue;
}

public void DefaultBosses_OnLastPlayer(VSH2Player player) {
	int id = GetDefBoss(player);
	if( !IsDefBoss(id) )
		return;
	
	ConfigMap last_sounds = g_defbosses.m_hBossCfgs[id].GetSection("boss data.sounds.last guy");
	if( last_sounds != null ) {
		int last_snd_count = last_sounds.Size;
		if( last_snd_count > 0 ) {
			int i = GetRandomInt(0, last_snd_count-1);
			int last_snd_len = last_sounds.GetIntKeySize(i);
			char[] last_sound = new char[last_snd_len];
			if( last_sounds.GetIntKey(i, last_sound, last_snd_len) > 0 )
				player.PlayVoiceClip(last_sound, VSH2_VOICE_LASTGUY);
		}
	}
}

public Action DefaultBosses_OnVoice(const VSH2Player player, char sample[PLATFORM_MAX_PATH], int& channel, float& volume, int& level, int& pitch, int& flags) {
	int id = GetDefBoss(player);
	if( !IsDefBoss(id) )
		return Plugin_Continue;
	
	switch( id ) {
		case VSH2Boss_Hale: {
			if( !strncmp(sample, "vo", 2, false) )
				return Plugin_Handled;
		}
		case VSH2Boss_Vagineer: {
			if( StrContains(sample, "vo/engineer_laughlong01", false) != -1 ) {
				strcopy(sample, PLATFORM_MAX_PATH, VagineerKSpree);
				return Plugin_Changed;
			}
			if( !strncmp(sample, "vo", 2, false) ) {
				/// For backstab sound
				if( StrContains(sample, "positivevocalization01", false) != -1 )
					return Plugin_Continue;
				
				if( StrContains(sample, "engineer_moveup", false) != -1 )
					Format(sample, PLATFORM_MAX_PATH, "%s%i.wav", VagineerJump, GetRandomInt(1, 2));
				else if( StrContains(sample, "engineer_no", false) != -1 || GetRandomInt(0, 9) > 6 )
					strcopy(sample, PLATFORM_MAX_PATH, "vo/engineer_no01.mp3");
				else strcopy(sample, PLATFORM_MAX_PATH, "vo/engineer_jeers02.mp3");
				return Plugin_Changed;
			}
			else return Plugin_Continue;
		}
		case VSH2Boss_HHHjr: {
			if( !strncmp(sample, "vo", 2, false) ) {
				if( GetRandomInt(0, 30) <= 10 ) {
					Format(sample, PLATFORM_MAX_PATH, "%s0%i.mp3", HHHLaught, GetRandomInt(1, 4));
					return Plugin_Changed;
				}
				if( StrContains(sample, "halloween_boss") == -1 )
					return Plugin_Handled;
			}
		}
		case VSH2Boss_Bunny: {
			if( StrContains(sample, "gibberish", false) == -1
				&& StrContains(sample, "burp", false) == -1
				&& !GetRandomInt(0, 2) ) /// Do sound things
			{
				strcopy(sample, PLATFORM_MAX_PATH, BunnyRandomVoice[GetRandomInt(0, sizeof(BunnyRandomVoice)-1)]);
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

/// Stocks =============================================
stock bool IsValidClient(int client) {
	if( client <= 0 || client > MaxClients || !IsClientConnected(client) || IsFakeClient(client) )
		return false;
	return IsClientInGame(client);
}

stock int GetSlotFromWeapon(int client, int wep) {
	for( int i; i<5; i++ )
		if( wep==GetPlayerWeaponSlot(client, i) )
			return i;
	
	return -1;
}

stock bool OnlyScoutsLeft(int team) {
	for( int i=MaxClients; i > 0; i-- ) {
		if( !IsValidClient(i) || !IsPlayerAlive(i) ) {
			continue;
		} else if( GetClientTeam(i)==team && TF2_GetPlayerClass(i) != TFClass_Scout ) {
			return false;
		}
	}
	return true;
}

stock void SetWeaponClip(int weapon, int ammo) {
	if( IsValidEntity(weapon) ) {
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		SetEntData(weapon, iAmmoTable, ammo, 4, true);
	}
}
