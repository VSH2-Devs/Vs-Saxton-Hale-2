#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>
#include <vsh2>
#include <sdkhooks>


public Plugin myinfo = {
	name             = "VSH2 Default Bosses Module",
	author           = "Nergal/Assyrian, DatOpb",
	description      = "",
	version          = "1.1-dev-d",
	url              = "https://github.com/VSH2-Devs/Vs-Saxton-Hale-2"
};
///Hale Boss Themes (Reverted due to Configmap issues reading data).
//static const char CBSTheme[] = "saxton_hale/the_millionaires_holiday.mp3";
//static const char HHHTheme[] = "ui/holiday/gamestartup_halloween.mp3";
//static const char HaleTheme[] = "saxton_hale/hale-theme.mp3";
//static const char VagTheme[] = "saxton_hale/vag-theme.mp3";
#define EggModel		"models/player/saxton_hale/w_easteregg.mdl"
///static const char EBTheme[] = "";

static const char boss_names[][] = {
	"saxton_hale",
	"vagineer",
	"cbs",
	"hhh_jr",
	"easter_bunny"
};

enum struct DefVSH2Bosses {
	int          ids[MaxDefaultVSH2Bosses];
	ConfigMap    cfgs[MaxDefaultVSH2Bosses];
	VSH2GameMode gm;
	
	/// these are from VSH2.
	ConVar       enabled;
	ConVar       scout_rage_gen;
	ConVar       airblast_rage;
	ConVar       jarate_rage;
	ConVar       hhh_max_climbs;
	ConVar       hhh_tele_cooldown;
	ConVar       hhh_climb_vel;
	ConVar       vag_uber_time;
	ConVar       vag_uber_airblast;
	ConVar       cbs_max_arrows;
	ConVar       bunny_max_eggs;
	ConVar       no_random_crits;
	ConVar       hale_scout_speed;
	ConVar       BossMarkFD;
	
	ConVar       move_speed[MaxDefaultVSH2Bosses];
	ConVar       glow_time[MaxDefaultVSH2Bosses];
	ConVar       jmp_rate[MaxDefaultVSH2Bosses];
	ConVar       jmp_max[MaxDefaultVSH2Bosses];
	ConVar       jmp_reset[MaxDefaultVSH2Bosses];
	ConVar       wghdwn_time[MaxDefaultVSH2Bosses];
	ConVar       wghdwn_iota[MaxDefaultVSH2Bosses];
	ConVar       rage_dist[MaxDefaultVSH2Bosses];
	ConVar       kspree_count[MaxDefaultVSH2Bosses];
	ConVar       kspree_time[MaxDefaultVSH2Bosses];
	ConVar       building_stun[MaxDefaultVSH2Bosses];
	ConVar       player_stun[MaxDefaultVSH2Bosses];
	ConVar       jmp_btns[MaxDefaultVSH2Bosses];
	
	char         egg_model[PLATFORM_MAX_PATH];
	
	int GetDefBoss(VSH2Player player) {
		int boss_type = player.GetPropInt("iBossType");
		for( int i; i<MaxDefaultVSH2Bosses; i++ ) {
			if( this.cfgs[i]==null || boss_type != this.ids[i] )
				continue;
			
			return i;
		}
		return -1;
	}
}

DefVSH2Bosses g_defbosses;


stock bool IsDefBoss(int id) {
	return IsIntInBounds(id, VSH2Boss_Bunny, VSH2Boss_Hale);
}

public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		g_defbosses.enabled           = FindConVar("vsh2_enabled");
		g_defbosses.scout_rage_gen    = FindConVar("vsh2_scout_rage_gen");
		g_defbosses.airblast_rage     = FindConVar("vsh2_airblast_rage");
		g_defbosses.jarate_rage       = FindConVar("vsh2_jarate_rage");
		g_defbosses.hhh_max_climbs    = FindConVar("vsh2_hhhjr_max_climbs");
		g_defbosses.hhh_tele_cooldown = FindConVar("vsh2_hhh_tele_cooldown");
		g_defbosses.hhh_climb_vel     = FindConVar("vsh2_hhh_climb_velocity");
		g_defbosses.vag_uber_time     = FindConVar("vsh2_vagineer_uber_time");
		g_defbosses.vag_uber_airblast = FindConVar("vsh2_vagineer_uber_time_airblast");
		g_defbosses.cbs_max_arrows    = CreateConVar("vsh2_cbs_max_arrows", "9", "the maximum amount of arrows Christian Brutal Sniper can get for his bow rage.", FCVAR_NOTIFY, true, 1.0, true, 999999.0);
		g_defbosses.bunny_max_eggs    = CreateConVar("vsh2_bunny_max_eggs", "50", "amount of eggs Bunny's autogrenader spews.", FCVAR_NOTIFY, true, 1.0, true, 999999.0);
		g_defbosses.no_random_crits   = CreateConVar("vsh2_default_bosses_no_random_crits", "1", "Blocks the default bosses from being able to randomly crit.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
		g_defbosses.hale_scout_speed   = CreateConVar("vsh2_hale_scouts_left_speed", "460.0", "How fast should a Hale move (in HU) when scouts are last alive.", FCVAR_NOTIFY, true, 0.0, true, 1000.0);
		g_defbosses.BossMarkFD    = CreateConVar("vsh2_boss_mfd_time", "3.0", "How long should bosses be marked for death in seconds after superjump.", FCVAR_NOTIFY, true, 1.0, true, 999999.0);

		bool got_one;
		for( int i; i<MaxDefaultVSH2Bosses; i++ ) {
			char cvar_name[1024];
			Format(cvar_name, sizeof(cvar_name), "vsh2_%s_move_speed", boss_names[i]);
			g_defbosses.move_speed[i] = CreateConVar(cvar_name, "340.0", "boss move speed.", FCVAR_NOTIFY, true, 1.0, true, 999999.0);
			
			Format(cvar_name, sizeof(cvar_name), "vsh2_%s_glow_iota", boss_names[i]);
			g_defbosses.glow_time[i] = CreateConVar(cvar_name, "0.1", "how fast to drain the boss glow.", FCVAR_NOTIFY, true, 0.0, true, 9999.0);
			
			Format(cvar_name, sizeof(cvar_name), "vsh2_%s_jump_charge", boss_names[i]);
			g_defbosses.jmp_rate[i] = CreateConVar(cvar_name, "2.5", "how fast to charge up the boss jump charge.", FCVAR_NOTIFY, true, 0.0, true, 9999.0);
			
			Format(cvar_name, sizeof(cvar_name), "vsh2_%s_jump_max", boss_names[i]);
			char jump_max[] = "0000";
			if( i==VSH2Boss_HHHjr ) {
				jump_max = "50";
			} else {
				jump_max = "25";
			}
			g_defbosses.jmp_max[i] = CreateConVar(cvar_name, jump_max, "max jump charge a boss can have.", FCVAR_NOTIFY, true, 0.0, true, 9999.0);
			
			Format(cvar_name, sizeof(cvar_name), "vsh2_%s_jump_reset", boss_names[i]);
			g_defbosses.jmp_reset[i] = CreateConVar(cvar_name, "-100.0", "jump charge reset value.", FCVAR_NOTIFY, true, -99999.0, true, 99999.0);
			
			Format(cvar_name, sizeof(cvar_name), "vsh2_%s_weighdown_time", boss_names[i]);
			char weighdown_time_def_str[] = "0000";
			switch( i ) {
				case VSH2Boss_Hale, VSH2Boss_CBS, VSH2Boss_Vagineer, VSH2Boss_Bunny: {
					weighdown_time_def_str = "3.0";
				}
				case VSH2Boss_HHHjr: weighdown_time_def_str = "1.0";
			}
			
			g_defbosses.wghdwn_time[i] = CreateConVar(cvar_name, weighdown_time_def_str, "time in the air to allow a boss to use weighdown.", FCVAR_NOTIFY, true, 0.0, true, 9999.0);
			
			Format(cvar_name, sizeof(cvar_name), "vsh2_%s_weighdown_iota", boss_names[i]);
			g_defbosses.wghdwn_iota[i] = CreateConVar(cvar_name, "0.2", "how much to charge weighdown when in the air and using activation button.", FCVAR_NOTIFY, true, 0.0, true, 9999.0);
			
			Format(cvar_name, sizeof(cvar_name), "vsh2_%s_rage_dist", boss_names[i]);
			char rage_dist_def_str[] = "000000000";
			switch( i ) {
				case VSH2Boss_Hale, VSH2Boss_HHHjr:     rage_dist_def_str = "800.0";
				case VSH2Boss_CBS:                      rage_dist_def_str = "320.0";
				case VSH2Boss_Vagineer, VSH2Boss_Bunny: rage_dist_def_str = "533.333";
			}
			g_defbosses.rage_dist[i] = CreateConVar(cvar_name, rage_dist_def_str, "how far can boss' rage reach players.", FCVAR_NOTIFY, true, 0.0, true, 9999.9);
			
			Format(cvar_name, sizeof(cvar_name), "vsh2_%s_killing_spree_amount", boss_names[i]);
			g_defbosses.kspree_count[i] = CreateConVar(cvar_name, "3", "how many kills a boss must get in a certain time to count as a killing spree.", FCVAR_NOTIFY, true, 0.0, true, 9999.9);
			
			Format(cvar_name, sizeof(cvar_name), "vsh2_%s_killing_spree_time", boss_names[i]);
			g_defbosses.kspree_time[i] = CreateConVar(cvar_name, "5.0", "how much time a boss has to get kills to count as a killing spree.", FCVAR_NOTIFY, true, 0.0, true, 9999.9);
			
			Format(cvar_name, sizeof(cvar_name), "vsh2_%s_sentry_stun_time", boss_names[i]);
			g_defbosses.building_stun[i] = CreateConVar(cvar_name, "8.0", "how much time a sentry is stunned for when a boss rages.", FCVAR_NOTIFY, true, 0.0, true, 9999.9);
			
			Format(cvar_name, sizeof(cvar_name), "vsh2_%s_player_stun_time", boss_names[i]);
			g_defbosses.player_stun[i] = CreateConVar(cvar_name, "5.0", "how much time players are stunned for when a boss rages.", FCVAR_NOTIFY, true, 0.0, true, 9999.9);
			
			Format(cvar_name, sizeof(cvar_name), "vsh2_%s_jump_buttons", boss_names[i]);
			g_defbosses.jmp_btns[i] = CreateConVar(cvar_name, "3", "what buttons players can use to activate superjump, 1-crouch, 2-right click, 3-both crouch & right click.", FCVAR_NOTIFY, true, 0.0, true, 9999.9);
			
			char cfg_path[PLATFORM_MAX_PATH];
			Format(cfg_path, sizeof(cfg_path), "configs/saxton_hale/boss_cfgs/%s.cfg", boss_names[i]);
			g_defbosses.cfgs[i] = new ConfigMap(cfg_path);
			if( g_defbosses.cfgs[i]==null ) {
				LogError("[VSH 2] ERROR :: **** couldn't find cfg 'configs/saxton_hale/boss_cfgs/%s.cfg'. Failed to register boss. ****", boss_names[i]);
				continue;
			}
			
			got_one = true;
			int flags;
			bool disable;
			if( g_defbosses.cfgs[i].GetBool("boss.disabled", disable) && disable ) {
				flags = VSH2PluginFlag_NonRand;
			}
			char boss[MAX_BOSS_NAME_SIZE]; strcopy(boss, MAX_BOSS_NAME_SIZE, boss_names[i]);
			g_defbosses.ids[i] = VSH2_RegisterBoss(boss, flags);
		}
		AutoExecConfig(true, "VSH2-DefaultBosses");
		
		/// if at least ONE default boss loaded fine, load up our hooks.
		if( got_one ) {
			LoadVSH2Hooks();
		}
	}
}

public void LoadVSH2Hooks() {
	if( !VSH2_HookEx(OnCallDownloads, DefaultBosses_OnDownloads) )
		LogError("Error hooking OnCallDownloads forwards for Default Bosses subplugin.");
	
	if( !VSH2_HookEx(OnBossMenu, DefaultBosses_OnMenu) )
		LogError("Error hooking OnBossMenu forwards for Default Bosses subplugin.");
	
	if( !VSH2_HookEx(OnBossSelected, DefaultBosses_OnSelected) )
		LogError("Error hooking OnBossSelected forwards for Default Bosses subplugin.");
	
	if( !VSH2_HookEx(OnBossThink, DefaultBosses_OnThink) )
		LogError("Error hooking OnBossThink forwards for Default Bosses subplugin.");
	
	if( !VSH2_HookEx(OnBossModelTimer, DefaultBosses_OnModel) )
		LogError("Error hooking OnBossModelTimer forwards for Default Bosses subplugin.");
	
	if( !VSH2_HookEx(OnBossEquipped, DefaultBosses_OnEquip) )
		LogError("Error hooking OnBossEquipped forwards for Default Bosses subplugin.");
	
	if( !VSH2_HookEx(OnBossInitialized, DefaultBosses_OnInit) )
		LogError("Error hooking OnBossInitialized forwards for Default Bosses subplugin.");
	
	if( !VSH2_HookEx(OnBossPlayIntro, DefaultBosses_OnIntro) )
		LogError("Error hooking OnBossPlayIntro forwards for Default Bosses subplugin.");
	
	if( !VSH2_HookEx(OnPlayerKilled, DefaultBosses_OnKill) )
		LogError("Error hooking OnPlayerKilled forwards for Default Bosses subplugin.");
	
	if( !VSH2_HookEx(OnPlayerHurt, DefaultBosses_OnHurt) )
		LogError("Error hooking OnPlayerHurt forwards for Default Bosses subplugin.");
	
	if( !VSH2_HookEx(OnPlayerAirblasted, DefaultBosses_OnAirblasted) )
		LogError("Error hooking OnPlayerAirblasted forwards for Default Bosses subplugin.");
	
	if( !VSH2_HookEx(OnBossMedicCall, DefaultBosses_OnMedCall) )
		LogError("Error hooking OnBossMedicCall forwards for Default Bosses subplugin.");
	
	if( !VSH2_HookEx(OnBossTaunt, DefaultBosses_OnMedCall) )
		LogError("Error hooking OnBossTaunt forwards for Default Bosses subplugin.");
	
	if( !VSH2_HookEx(OnBossJarated, DefaultBosses_OnJarated) )
		LogError("Error hooking OnBossJarated forwards for Default Bosses subplugin.");
	
	if( !VSH2_HookEx(OnRoundEndInfo, DefaultBosses_OnRoundEnd) )
		LogError("Error hooking OnRoundEndInfo forwards for Default Bosses subplugin.");
	
	if( !VSH2_HookEx(OnMusic, DefaultBosses_OnMusic) )
		LogError("Error hooking OnMusic forwards for Default Bosses subplugin.");
	
	if( !VSH2_HookEx(OnBossDeath, DefaultBosses_OnDeath) )
		LogError("Error hooking OnBossDeath forwards for Default Bosses subplugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnStabbed, DefaultBosses_OnStabbed) )
		LogError("Error hooking OnBossTakeDamage_OnStabbed forwards for Default Bosses subplugin.");
	
	if( !VSH2_HookEx(OnLastPlayer, DefaultBosses_OnLastPlayer) )
		LogError("Error hooking OnLastPlayer forwards for Default Bosses subplugin.");
	
	if( !VSH2_HookEx(OnSoundHook, DefaultBosses_OnVoice) )
		LogError("Error hooking OnSoundHook forwards for Default Bosses subplugin.");
	
	if( !VSH2_HookEx(OnBossKillBuilding, DefaultBosses_OnKillBuilding) )
		LogError("Error hooking OnBossKillBuilding forwards for Default Bosses subplugin.");
		
	if( !VSH2_HookEx(OnRoundEndInfo, DefaultBosses_OnRoundEnd) )
		LogError("Error loading OnRoundEndInfo forwards for Default Bosses subplugin.");
}

public void DefaultBosses_OnMenu(Menu& menu) {
	for( int i; i<MaxDefaultVSH2Bosses; i++ ) {
		if( g_defbosses.cfgs[i]==null )
			continue;
		
		char tostr[10]; IntToString(g_defbosses.ids[i], tostr, sizeof(tostr));
		int name_len = g_defbosses.cfgs[i].GetSize("boss.menu name");
		char[] name = new char[name_len];
		g_defbosses.cfgs[i].Get("boss.menu name", name, name_len);
		menu.AddItem(tostr, name);
	}
}

public void DefaultBosses_OnSelected(VSH2Player player) {
	int id = g_defbosses.GetDefBoss(player);
	if( !IsDefBoss(id) || g_defbosses.cfgs[id]==null )
		return;
	
	Panel panel = new Panel();
	int panel_len = g_defbosses.cfgs[id].GetSize("boss.help panel");
	char[] panel_str = new char[panel_len];
	g_defbosses.cfgs[id].Get("boss.help panel", panel_str, panel_len);
	panel.SetTitle(panel_str);
	panel.DrawItem("Exit");
	panel.Send(player.index, _panel_hint, 999);
	delete panel;
}

public int _panel_hint(Menu menu, MenuAction action, int param1, int param2) {
	return 0;
}

public void DefaultBosses_OnModel(VSH2Player player) {
	int id = g_defbosses.GetDefBoss(player);
	if( !IsDefBoss(id) || g_defbosses.cfgs[id]==null )
		return;
	
	int client = player.index;
	int model_len = g_defbosses.cfgs[id].GetSize("boss.model");
	char[] model_str = new char[model_len];
	g_defbosses.cfgs[id].Get("boss.model", model_str, model_len);
	SetVariantString(model_str);
	AcceptEntityInput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
}


public void DefaultBosses_OnDownloads() {
	for( int i; i<MaxDefaultVSH2Bosses; i++ ) {
		if( g_defbosses.cfgs[i]==null )
			continue;
		
		int boss_mdl_len = g_defbosses.cfgs[i].GetSize("boss.model");
		char[] boss_mdl_str = new char[boss_mdl_len];
		if( g_defbosses.cfgs[i].Get("boss.model", boss_mdl_str, boss_mdl_len) > 0 ) {
			PrepareModel(boss_mdl_str);
		}
		
		PrepareAssetsFromCfgMap(g_defbosses.cfgs[i].GetSection("boss.skins"), ResourceMaterial);
		
		ConfigMap sounds_sect = g_defbosses.cfgs[i].GetSection("boss.sounds");
		if( sounds_sect != null ) {
			int size = sounds_sect.Size;
			ConfigMap[] sound_sects = new ConfigMap[size];
			int sect_count = sounds_sect.GetSections(sound_sects);
			for( int n; n < sect_count; n++ ) {
				PrepareAssetsFromCfgMap(sound_sects[n], ResourceSound);
			}
		}
		
		ConfigMap vo_sect = g_defbosses.cfgs[i].GetSection("boss.vo");
		if( vo_sect != null ) {
			int size = vo_sect.Size;
			ConfigMap[] vo_sects = new ConfigMap[size];
			int sect_count = vo_sect.GetSections(vo_sects);
			for( int n; n < sect_count; n++ ) {
				PrepareAssetsFromCfgMap(vo_sects[n], ResourceSound);
			}
		}
		
		ConfigMap killclass_sounds = g_defbosses.cfgs[i].GetSection("boss.sounds.kill class");
		if( killclass_sounds != null ) {
			char class_name[][] = {
				"scout", "soldier", "pyro",
				"demo",  "heavy",   "engie",
				"medic", "sniper",  "spy"
			};
			for( int c; c < sizeof(class_name); c++ ) {
				ConfigMap class_sounds = killclass_sounds.GetSection(class_name[c]);
				PrepareAssetsFromCfgMap(class_sounds, ResourceSound);
			}
		}
		{
			ConfigMap music_sect = g_defbosses.cfgs[i].GetSection("boss.music");
			/*
			int    max_songs;
			int    count        = music_sect.GetCombinedKeyValLens(max_songs);
			
			char[] songs        = new char[max_songs];
			int[]  song_offsets = new int[count];
			int    offcount1    = music_sect.GetKeys(songs, song_offsets);
			for( int n; n < offcount1; n++ ) {
				PrepareSound(songs[song_offsets[n]]);
			}
			*/
			if( music_sect != null ) {
				//PrepareAssetsFromCfgMap(music_sect, ResourceSound);
				int num_sound_sects = music_sect.Size;
				for( int x; x < num_sound_sects; x++ ) {
					int sect_len = music_sect.GetKeySize(x);
					char[] sect_name = new char[sect_len + 1];
					music_sect.GetKey(x, sect_name, sect_len);
					if ( !StrEqual(sect_name, "")) //Check if the section we are getting is empty, failsafe in case music section does exist but contains nothing
					{
						PrepareSound(sect_name)
						//PrintToServer("Section Name is %s (nonempty)", sect_name);
					}
					else if ( StrEqual(sect_name, ""))
					{
						PrintToServer("[VSH2-DefBoss]: A null name was parsed for music_sect, Discarding...")
						//PrintToServer("Section Name is %s (Empty)", sect_name);
					}
					//PrintToServer("Section Name is %s", sect_name);
					//PrepareSound(sect_name)
				}
			}
		}

		if( StrEqual(boss_names[i], "easter_bunny" )) {
			int egg_mdl_len = g_defbosses.cfgs[i].GetSize("boss.egg model");
			if( egg_mdl_len > 0 ) {
				g_defbosses.cfgs[i].Get("boss.egg model", g_defbosses.egg_model, egg_mdl_len)
				PrepareModel(EggModel);
				PrecacheModel(EggModel);
				//PrintToServer("EB Egg Model: %s", g_defbosses.egg_model);
			}
			PrepareMaterial("materials/models/props_easteregg/c_easteregg");
			CheckDownload("materials/models/props_easteregg/c_easteregg_gold.vmt");
		}
		PrepareModel(EggModel);
		PrecacheModel(EggModel);
		PrepareMaterial("materials/models/props_easteregg/c_easteregg");
		CheckDownload("materials/models/props_easteregg/c_easteregg_gold.vmt");
		//PrintToServer("The I value is %i", i)
		PrintToServer("The boss cfg processed is %s", boss_names[i])
	}
	PrepareModel(EggModel);
	PrecacheModel(EggModel);
	PrepareMaterial("materials/models/props_easteregg/c_easteregg");
	CheckDownload("materials/models/props_easteregg/c_easteregg_gold.vmt");
	PrecacheSound("saxton_hale/9000.wav", true); //Why wasnt this cached before?
	PrecacheSound("misc/halloween/spell_teleport.wav", true);
	//PrepareSound(CBSTheme);			///Default Theme
	//PrepareSound(HHHTheme);			///Default Theme
	//PrepareSound(HaleTheme);		///Custom Theme
	//PrepareSound(VagTheme);			///Custom Theme
}


public void DefaultBosses_OnThink(VSH2Player player) {
	int id = g_defbosses.GetDefBoss(player);
	if( !IsDefBoss(id) || g_defbosses.cfgs[id]==null )
		return;
	
	int client = player.index
	if( !IsPlayerAlive(client) )
		return;
	
	int flags = GetEntityFlags(client);
	player.SpeedThink(g_defbosses.move_speed[id].FloatValue);
	player.GlowThink(g_defbosses.glow_time[id].FloatValue);
	
	int jmp_button;
	switch( g_defbosses.jmp_btns[id].IntValue ) {
		case 1:  jmp_button = IN_DUCK;
		case 2:  jmp_button = IN_ATTACK2;
		case 3:  jmp_button = (IN_ATTACK2|IN_RELOAD|IN_ATTACK3);
		default: jmp_button = (IN_ATTACK2|IN_DUCK);
	}
	
	if( id != VSH2Boss_HHHjr ) {
		if( player.SuperJumpThink(g_defbosses.jmp_rate[id].FloatValue, g_defbosses.jmp_max[id].FloatValue, jmp_button) ) {
			ConfigMap jmp_sect = g_defbosses.cfgs[id].GetSection("boss.sounds.jump");
			player.PlayRandVoiceClipCfgMap(jmp_sect, VSH2_VOICE_ALL);
			player.SuperJump(player.GetPropFloat("flCharge"), g_defbosses.jmp_reset[id].FloatValue);
			//TF2_AddCondition(player.index, TFCond_MarkedForDeathSilent, 3.0);
			TF2_AddCondition(player.index, TFCond_MarkedForDeathSilent, g_defbosses.BossMarkFD.FloatValue);
		}
	} else {
		float EyeAngles[3]; GetClientEyeAngles(player.index, EyeAngles);
		float max_charge = g_defbosses.jmp_max[id].FloatValue;
		float charge_rate = g_defbosses.jmp_rate[id].FloatValue;
		float cur_charge = player.GetPropFloat("flCharge");
		bool cond_to_tele = (cur_charge==max_charge || player.GetPropAny("bSuperCharge")) && EyeAngles[0] < -5.0;
		if( player.ChargeThink(charge_rate, "flCharge", max_charge, jmp_button, cond_to_tele) ) {
			TeleToRandomPlayer(player);
			TF2_AddCondition(player.index, TFCond_MarkedForDeathSilent, g_defbosses.BossMarkFD.FloatValue);
		}
	}
	
	if( VSH2GameMode.AreScoutsLeft() ) {
		player.SetPropFloat("flRAGE", player.GetPropFloat("flRAGE") + g_defbosses.scout_rage_gen.FloatValue);
		player.SpeedThink(g_defbosses.hale_scout_speed.FloatValue);
	}
	
	player.WeighDownThink(g_defbosses.wghdwn_time[id].FloatValue, g_defbosses.wghdwn_iota[id].FloatValue);
	
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
	
	Handle hud = g_defbosses.gm.hHUD;
	switch( id ) {
		case VSH2Boss_HHHjr: {
			if( flags & FL_ONGROUND ) {
				player.SetPropInt("iClimbs", 0);
			}
			int max_climbs = g_defbosses.hhh_max_climbs.IntValue;
			int climbs     = player.GetPropInt("iClimbs");
			ShowSyncHudText(client, hud, "Teleport: %i | Climbs: %i / %i | Rage: %s", RoundFloat(jmp) * 2, climbs, max_climbs, rage_text);
		}
		case VSH2Boss_Vagineer: {
			SetEntProp(client, Prop_Data, "m_takedamage", TF2_IsPlayerInCondition(client, TFCond_Ubercharged) ? 0 : 2);
			float dur_left;
			float max_dur  = g_defbosses.vag_uber_time.FloatValue;
			if( TF2_IsPlayerInCondition(client, TFCond_Ubercharged) ) {
				float dur      = GetConditionDuration(client, TFCond_Ubercharged);
				dur_left       = max_dur - dur;
			}
			ShowSyncHudText(client, hud, "Uber Time: %0.2f/%0.2f | Super Jump: %i%% | Rage: %s", dur_left, max_dur, RoundFloat(jmp) * 4, rage_text);
		}
		default: {
			ShowSyncHudText(client, hud, "Super Jump: %i%% | Rage: %s", RoundFloat(jmp) * 4, rage_text);
		}
	}
}

public void DefaultBosses_OnEquip(VSH2Player player) {
	int id = g_defbosses.GetDefBoss(player);
	if( !IsDefBoss(id) || g_defbosses.cfgs[id]==null )
		return;
	
	ConfigMap boss_cfg = g_defbosses.cfgs[id];
	char name[MAX_BOSS_NAME_SIZE];
	boss_cfg.Get("boss.name", name, sizeof(name));
	player.SetName(name);
	player.RemoveAllItems();
	
	ConfigMap melee_wep = boss_cfg.GetSection("boss.melee");
	if( melee_wep==null )
		return;
	
	int attribs_len = melee_wep.GetSize("attribs") + 12;
	char[] attribs_str = new char[attribs_len];
	melee_wep.Get("attribs", attribs_str, attribs_len - 12);
	
	if( id==VSH2Boss_Hale ) {
		/// Randomize Hale's kill count.
		Format(attribs_str, attribs_len, "%s; 214 ; %i", attribs_str, GetRandomInt(9999, 99999));
	}
	
	int classname_len = melee_wep.GetSize("classname");
	char[] classname_str = new char[classname_len];
	melee_wep.Get("classname", classname_str, classname_len);
	
	int index, level, quality;
	melee_wep.GetInt("index",   index);
	melee_wep.GetInt("level",   level);
	melee_wep.GetInt("quality", quality);
	
	int wep = player.SpawnWeapon(classname_str, index, level, quality, attribs_str);
	SetEntPropEnt(player.index, Prop_Send, "m_hActiveWeapon", wep);
	
	if( id==VSH2Boss_HHHjr ) {
		player.SetPropFloat("flCharge", g_defbosses.hhh_tele_cooldown.FloatValue * 0.9091);
	}
}

public void DefaultBosses_OnInit(VSH2Player player) {
	int id = g_defbosses.GetDefBoss(player);
	if( !IsDefBoss(id) || g_defbosses.cfgs[id]==null )
		return;
	int client = player.index;
	switch( id ) {
		case VSH2Boss_Hale:
			SetEntProp(client, Prop_Send, "m_iClass", view_as< int >(TFClass_Soldier));
			//TF2_SetPlayerClass(client, TFClass_Soldier);
		case VSH2Boss_Vagineer:
			SetEntProp(client, Prop_Send, "m_iClass", view_as< int >(TFClass_Engineer));
			//TF2_SetPlayerClass(client, TFClass_Engineer);
		case VSH2Boss_CBS:
			SetEntProp(client, Prop_Send, "m_iClass", view_as< int >(TFClass_Sniper));
			//TF2_SetPlayerClass(client, TFClass_Sniper);
		case VSH2Boss_HHHjr, VSH2Boss_Bunny:
			SetEntProp(client, Prop_Send, "m_iClass", view_as< int >(TFClass_DemoMan));
			//TF2_SetPlayerClass(client, TFClass_DemoMan);
	}
}

public void DefaultBosses_OnIntro(VSH2Player player) {
	int id = g_defbosses.GetDefBoss(player);
	if( !IsDefBoss(id) || g_defbosses.cfgs[id]==null )
		return;
	
	ConfigMap intro_sounds = g_defbosses.cfgs[id].GetSection("boss.sounds.intro");
	player.PlayRandVoiceClipCfgMap(intro_sounds, VSH2_VOICE_INTRO);
}

public void DefaultBosses_OnKill(VSH2Player attacker, VSH2Player victim, Event event) {
	if( !attacker || victim==attacker )
		return;
	
	int id = g_defbosses.GetDefBoss(attacker);
	if( !IsDefBoss(id) || g_defbosses.cfgs[id]==null )
		return;
	
	if( id==VSH2Boss_Bunny ) {
		/*
		if( g_defbosses.egg_model[0] != 0 ) {
			SpawnManyAmmoPacks(victim.index, EggModel, 1);
		}
		*/
		SpawnManyAmmoPacks(victim.index, EggModel, 1);
	}
	
	float curtime = GetGameTime();
	if( curtime <= attacker.GetPropFloat("flKillSpree") ) {
		attacker.SetPropInt("iKills", attacker.GetPropInt("iKills") + 1);
	} else {
		attacker.SetPropInt("iKills", 0);
	}
	
	if( id==VSH2Boss_Hale ) {
		event.SetString("weapon", "fists");
	}
	
	ConfigMap killclass_sounds = g_defbosses.cfgs[id].GetSection("boss.sounds.kill class");
	if( killclass_sounds != null && !GetRandomInt(0, 2) ) {
		TFClassType playerclass = victim.iTFClass;
		char class_name[32];
		switch( playerclass ) {
			case TFClass_Scout:    class_name = "scout" ;
			case TFClass_Pyro:     class_name = "pyro"  ;
			case TFClass_DemoMan:  class_name = "demo"  ;
			case TFClass_Heavy:    class_name = "heavy" ;
			case TFClass_Medic:    class_name = "medic" ;
			case TFClass_Sniper:   class_name = "sniper";
			case TFClass_Spy:      class_name = "spy"   ;
			case TFClass_Engineer: class_name = "engie" ;
		}
		if( class_name[0] != 0 ) {
			ConfigMap class_sounds = killclass_sounds.GetSection(class_name);
			attacker.PlayRandVoiceClipCfgMap(class_sounds, VSH2_VOICE_SPREE);
		}
	} else {
		ConfigMap kill_sounds = g_defbosses.cfgs[id].GetSection("boss.sounds.kill");
		attacker.PlayRandVoiceClipCfgMap(kill_sounds, VSH2_VOICE_SPREE);
	}
	
	if( attacker.GetPropInt("iKills") == g_defbosses.kspree_count[id].IntValue && g_defbosses.gm.iLivingReds != 1 ) {
		ConfigMap spree_sounds = g_defbosses.cfgs[id].GetSection("boss.sounds.spree");
		attacker.PlayRandVoiceClipCfgMap(spree_sounds, VSH2_VOICE_SPREE);
		attacker.SetPropInt("iKills", 0);
	} else {
		attacker.SetPropFloat("flKillSpree", curtime + g_defbosses.kspree_time[id].FloatValue);
	}
}

public void DefaultBosses_OnKillBuilding(const VSH2Player attacker, const int building, Event event) {
	int id = g_defbosses.GetDefBoss(attacker);
	if( !IsDefBoss(id) || g_defbosses.cfgs[id]==null )
		return;

	if( id==VSH2Boss_Hale )
		event.SetString("weapon", "fists");
	
	ConfigMap kill_toy_sounds = g_defbosses.cfgs[id].GetSection("boss.sounds.kill building");
	attacker.PlayRandVoiceClipCfgMap(kill_toy_sounds, VSH2_VOICE_SPREE);
}

public void DefaultBosses_OnHurt(VSH2Player attacker, VSH2Player victim, Event event) {
	int id = g_defbosses.GetDefBoss(victim);
	if( !IsDefBoss(id) || g_defbosses.cfgs[id]==null ) {
		return;
	} else if( victim.bIsBoss ) {
		int damage = event.GetInt("damageamount");
		victim.GiveRage(damage);
	}
}

public void DefaultBosses_OnAirblasted(VSH2Player airblaster, VSH2Player airblasted, Event event) {
	int id = g_defbosses.GetDefBoss(airblasted);
	if( !IsDefBoss(id) || g_defbosses.cfgs[id]==null )
		return;
	
	float rage = airblasted.GetPropFloat("flRAGE");
	if( id==VSH2Boss_Vagineer && TF2_IsPlayerInCondition(airblasted.index, TFCond_Ubercharged) ) {
		float dur      = GetConditionDuration(airblasted.index, TFCond_Ubercharged);
		float max_dur  = g_defbosses.vag_uber_time.FloatValue;
		float increase = g_defbosses.vag_uber_airblast.FloatValue;
		SetConditionDuration(airblasted.index, TFCond_Ubercharged, dur + increase < max_dur ? dur + increase : max_dur);
		return;
	}
	airblasted.SetPropFloat("flRAGE", rage + g_defbosses.airblast_rage.FloatValue);
}

public void DefaultBosses_OnMedCall(VSH2Player player) {
	int id = g_defbosses.GetDefBoss(player);
	if( !IsDefBoss(id) || g_defbosses.cfgs[id]==null || player.GetPropFloat("flRAGE") < 100.0 )
		return;
	
	int client = player.index;
	float rage_radius      = g_defbosses.rage_dist[id].FloatValue;
	float sentry_stun_time = g_defbosses.building_stun[id].FloatValue;
	float player_stun_time = g_defbosses.player_stun[id].FloatValue;
	TF2_AddCondition(client, view_as< TFCond >(42), 4.0);
	player.StunPlayers(rage_radius, player_stun_time);
	player.StunBuildings(rage_radius, sentry_stun_time);
	switch( id ) {
		case VSH2Boss_Vagineer: {
			TF2_AddCondition(client, TFCond_Ubercharged, g_defbosses.vag_uber_time.FloatValue);
		}
		case VSH2Boss_CBS: {
			ConfigMap rage_wep = g_defbosses.cfgs[id].GetSection("boss.rage weapon");
			if( rage_wep==null )
				return;
			
			int attribs_len = rage_wep.GetSize("attribs");
			char[] attribs_str = new char[attribs_len];
			rage_wep.Get("attribs", attribs_str, attribs_len);
			
			int classname_len = rage_wep.GetSize("classname");
			char[] classname_str = new char[classname_len];
			rage_wep.Get("classname", classname_str, classname_len);
			
			int index, level, quality;
			rage_wep.GetInt("index",   index);
			rage_wep.GetInt("level",   level);
			rage_wep.GetInt("quality", quality);
			
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
			int bow = player.SpawnWeapon(classname_str, index, level, quality, attribs_str);
			SetEntPropEnt(player.index, Prop_Send, "m_hActiveWeapon", bow); /// 266; 1.0 - penetration
			
			int living = g_defbosses.gm.iLivingReds;
			int max_arrows = g_defbosses.cbs_max_arrows.IntValue;
			SetWeaponAmmo(bow, (living >= max_arrows)? max_arrows : living);
		}
		case VSH2Boss_Bunny: {
			ConfigMap rage_wep = g_defbosses.cfgs[id].GetSection("boss.rage weapon");
			if( rage_wep==null )
				return;
			
			int attribs_len = rage_wep.GetSize("attribs");
			char[] attribs_str = new char[attribs_len];
			rage_wep.Get("attribs", attribs_str, attribs_len);
			
			int classname_len = rage_wep.GetSize("classname");
			char[] classname_str = new char[classname_len];
			rage_wep.Get("classname", classname_str, classname_len);
			
			int index, level, quality;
			rage_wep.GetInt("index",   index);
			rage_wep.GetInt("level",   level);
			rage_wep.GetInt("quality", quality);
			
			//TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary); 
			int secondary = GetPlayerWeaponSlot(player.index, TFWeaponSlot_Secondary);
			int egg_amount = g_defbosses.bunny_max_eggs.IntValue;
			if ( secondary == -1 )
			{
				int weapon = player.SpawnWeapon(classname_str, index, level, quality, attribs_str);
				SetEntProp(weapon, Prop_Send, "m_iClip1", egg_amount);
				SetWeaponAmmo(weapon, 0);
			}
			if ( secondary > 0)
			{
				int current_eggs = GetEntProp(secondary, Prop_Send, "m_iClip1");
				int new_eggs = current_eggs + egg_amount;
				SetEntProp(secondary, Prop_Send, "m_iClip1", new_eggs);
			}


			//int weapon = player.SpawnWeapon(classname_str, index, level, quality, attribs_str);
			//SetEntPropEnt(player.index, Prop_Send, "m_hActiveWeapon", weapon);
			//int egg_amount = g_defbosses.bunny_max_eggs.IntValue;
			//SetEntProp(weapon, Prop_Send, "m_iClip1", egg_amount);
			//SetWeaponAmmo(weapon, 0);
		}
	}
	
	ConfigMap rage_sounds = g_defbosses.cfgs[id].GetSection("boss.sounds.rage");
	player.PlayRandVoiceClipCfgMap(rage_sounds, VSH2_VOICE_RAGE);
	player.SetPropFloat("flRAGE", 0.0);
}

public void DefaultBosses_OnJarated(VSH2Player victim, VSH2Player thrower) {
	int id = g_defbosses.GetDefBoss(victim);
	if( !IsDefBoss(id) || g_defbosses.cfgs[id]==null )
		return;
	
	float rage = victim.GetPropFloat("flRAGE");
	victim.SetPropFloat("flRAGE", rage - g_defbosses.jarate_rage.FloatValue);
}

public void DefaultBosses_OnRoundEnd(VSH2Player player, bool boss_win, char message[MAXMESSAGE]) {
	int id = g_defbosses.GetDefBoss(player);
	if( !IsDefBoss(id) || g_defbosses.cfgs[id]==null ) {
		return;
	} else if( boss_win ) {
		ConfigMap win_sounds = g_defbosses.cfgs[id].GetSection("boss.sounds.win");
		player.PlayRandVoiceClipCfgMap(win_sounds, VSH2_VOICE_WIN);
	}
	//HasBossBeenInit = false;		///Ugly Patch.
	//TF2_SetPlayerClass(LocalPlayerIndex, classtype);	///Set the player's class back to what it was prior to becoming hale. (Stange fix applied due to a weird bug where a random players class is being set to something different.)
}

public void DefaultBosses_OnMusic(char song[PLATFORM_MAX_PATH], float& time, VSH2Player player) {

    int id = g_defbosses.GetDefBoss(player);
    if( !IsDefBoss(id) || g_defbosses.cfgs[id]==null ) {
		return;
	}
	
    ConfigMap music_sect = g_defbosses.cfgs[id].GetSection("boss.music");
    if( music_sect==null ) {
		LogToFile("vsh2bosses_default", "id: '%i' | music section is NULL", id);
		return;
	}


    int size = music_sect.Size;
    if( size <= 0 ) {
        return;
    }
    
    static int index;
    index = ShuffleIndex(size, index);
    //int song_len = music_sect.GetKeySize(index);
    music_sect.GetKey(index, song, PLATFORM_MAX_PATH);
    time = music_sect.GetFloatEx(song, 0.0);
    //FindCharInString(song, '\.');
    if ( time == 0.0){
		PrintToServer("MUSIC TIME IS 0, FIX!");
		float songtime;
		int time2 = music_sect.GetFloat(song, songtime);
		PrintToServer("GetFloat returns %f", songtime);
		PrintToServer("GetFloat chars used %i", time2);
		song = "" //Nully the song to prevent earrape
	}
    float songtime;
    int time2 = music_sect.GetFloat(song, songtime);
    PrintToServer("Time GetFloat returns %f", songtime);
    PrintToServer("GetFloat chars used %i", time2);
	/*
	int id = g_defbosses.GetDefBoss(player);
	switch( id ) {
		case -1: {song = "\0"; time = -1.0;}
		case VSH2Boss_Hale: {
			strcopy(song, sizeof(song), HaleTheme),
			time = 324.0;
		}
		case VSH2Boss_Bunny: {
			song = "\0";
			time = -1.0;
		}
		case VSH2Boss_CBS: {
			strcopy(song, sizeof(song), CBSTheme),
			time = 140.0;
		}
		case VSH2Boss_HHHjr: {
			strcopy(song, sizeof(song), HHHTheme);
			time = 90.0;
		}
		case VSH2Boss_Vagineer: {
			strcopy(song, sizeof(song), VagTheme);
			time = 300.0;
		}
	}
	*/
	//LogToFile("vsh2bosses_default", "index: '%s' | time: '%f'", song, time);
}

public void DefaultBosses_OnDeath(VSH2Player player) {
	int id = g_defbosses.GetDefBoss(player);
	if( !IsDefBoss(id) || g_defbosses.cfgs[id]==null )
		return;
	
	ConfigMap lose_sounds = g_defbosses.cfgs[id].GetSection("boss.sounds.death");
	player.PlayRandVoiceClipCfgMap(lose_sounds, VSH2_VOICE_LOSE);
}

public Action DefaultBosses_OnStabbed(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	int id = g_defbosses.GetDefBoss(victim);
	if( !IsDefBoss(id) || g_defbosses.cfgs[id]==null )
		return Plugin_Continue;
	
	ConfigMap stab_sounds = g_defbosses.cfgs[id].GetSection("boss.sounds.backstab");
	victim.PlayRandVoiceClipCfgMap(stab_sounds, VSH2_VOICE_STABBED);
	return Plugin_Continue;
}

public void DefaultBosses_OnLastPlayer(VSH2Player player) {
	int id = g_defbosses.GetDefBoss(player);
	if( !IsDefBoss(id) || g_defbosses.cfgs[id]==null )
		return;
	
	ConfigMap last_sounds = g_defbosses.cfgs[id].GetSection("boss.sounds.lastplayer");
	player.PlayRandVoiceClipCfgMap(last_sounds, VSH2_VOICE_LASTGUY);
}

public Action DefaultBosses_OnVoice(const VSH2Player player, char sample[PLATFORM_MAX_PATH], int& channel, float& volume, int& level, int& pitch, int& flags) {
	int id = g_defbosses.GetDefBoss(player);
	if( !IsDefBoss(id) || g_defbosses.cfgs[id]==null )
		return Plugin_Continue;
	
	switch( id ) {
		case VSH2Boss_Hale: {
			if( !strncmp(sample, "vo", 2, false) ) {
				return Plugin_Handled;
			}
		}
		case VSH2Boss_Vagineer: {
			if( StrContains(sample, "vo/engineer_laughlong01", false) != -1 ) {
				ConfigMap taunt_sounds = g_defbosses.cfgs[id].GetSection("boss.vo.taunt");
				int n = GetRandomInt(0, taunt_sounds.Size-1);
				char taunt_str[PLATFORM_MAX_PATH];
				if( taunt_sounds.GetIntKey(n, taunt_str, PLATFORM_MAX_PATH) > 0 ) {
					strcopy(sample, PLATFORM_MAX_PATH, taunt_str);
				}
				return Plugin_Changed;
			}
			if( !strncmp(sample, "vo", 2, false) ) {
				/// For backstab sound
				if( StrContains(sample, "positivevocalization01", false) != -1 )
					return Plugin_Continue;
				
				if( StrContains(sample, "engineer_moveup", false) != -1 ) {
					ConfigMap moveup_sounds = g_defbosses.cfgs[id].GetSection("boss.vo.moveup");
					int n = GetRandomInt(0, moveup_sounds.Size-1);
					char taunt_str[PLATFORM_MAX_PATH];
					if( moveup_sounds.GetIntKey(n, taunt_str, PLATFORM_MAX_PATH) > 0 ) {
						strcopy(sample, PLATFORM_MAX_PATH, taunt_str);
					}
				} else if( StrContains(sample, "engineer_no", false) != -1 || GetRandomInt(0, 9) > 6 ) {
					strcopy(sample, PLATFORM_MAX_PATH, "vo/engineer_no01.mp3");
				} else {
					strcopy(sample, PLATFORM_MAX_PATH, "vo/engineer_jeers02.mp3");
				}
				return Plugin_Changed;
			}
			return Plugin_Continue;
		}
		case VSH2Boss_HHHjr: {
			if( !strncmp(sample, "vo", 2, false) ) {
				if( GetRandomInt(0, 30) <= 10 ) {
					char HHH_laugh[] = "vo/halloween_boss/knight_laugh";
					Format(sample, PLATFORM_MAX_PATH, "%s0%i.mp3", HHH_laugh, GetRandomInt(1, 4));
					return Plugin_Changed;
				}
				if( StrContains(sample, "halloween_boss") == -1 ) {
					return Plugin_Handled;
				}
			}
		}
		case VSH2Boss_Bunny: {
			/// Do sound things
			if( StrContains(sample, "gibberish", false) == -1
				&& StrContains(sample, "burp", false) == -1
				&& !GetRandomInt(0, 2)
			) {
				ConfigMap demoman_sounds = g_defbosses.cfgs[id].GetSection("boss.vo.gibberish");
				int n = GetRandomInt(0, demoman_sounds.Size-1);
				char taunt_str[PLATFORM_MAX_PATH];
				if( demoman_sounds.GetIntKey(n, taunt_str, PLATFORM_MAX_PATH) > 0 ) {
					strcopy(sample, PLATFORM_MAX_PATH, taunt_str);
				}
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

public void OnEntityCreated(int entity, const char[] classname) {
	if( !strcmp(classname, "tf_projectile_pipe_remote", false) && g_defbosses.cfgs[VSH2Boss_Bunny] != null ) { //Changed from tf_projectile_pipe
		SDKHook(entity, SDKHook_SpawnPost, OnEggBombSpawned);
	}
}

public void OnEggBombSpawned(int entity) {
	int owner = ( IsValidEntity(entity) )? GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") : -1;
	if( IsClientValid(owner) ) {
		VSH2Player boss = VSH2Player(owner);
		if( boss.bIsBoss && g_defbosses.GetDefBoss(boss)==VSH2Boss_Bunny ) {
			//PrintToChatAll("EB Model %s", g_defbosses.egg_model);
			//SetEntityModel(entity, EggModel);
			
			int att = AttachProjectileModel(entity, EggModel);
			SetEntProp(att, Prop_Send, "m_nSkin", 0);
			SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
			SetEntityRenderColor(entity, 255, 255, 255, 0);
			
		}
	}
}


public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if( !IsPlayerAlive(client) )
		return Plugin_Continue;
	
	VSH2Player player = VSH2Player(client);
	int id = g_defbosses.GetDefBoss(player);
	if( !IsDefBoss(id) || g_defbosses.cfgs[id]==null )
		return Plugin_Continue;
	
	switch( id ) {
		case VSH2Boss_Bunny: {
			if( GetPlayerWeaponSlot(client, TFWeaponSlot_Primary)==GetActiveWep(client) ) {
				buttons &= ~IN_ATTACK;
				return Plugin_Changed;
			}
		}
		case VSH2Boss_HHHjr: {
			if( player.GetPropFloat("flCharge") >= 47.0 && (buttons & IN_ATTACK) ) {
				buttons &= ~IN_ATTACK;
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool& result)
{
	if( !g_defbosses.enabled.BoolValue )
		return Plugin_Continue;
	
	VSH2Player player = VSH2Player(client);
	int id = g_defbosses.GetDefBoss(player);
	if( !IsDefBoss(id) || g_defbosses.cfgs[id]==null )
		return Plugin_Continue;
	
	if( id==VSH2Boss_HHHjr ) {
		int climbs = player.GetPropInt("iClimbs");
		if( climbs < g_defbosses.hhh_max_climbs.IntValue && player.ClimbWall(weapon, g_defbosses.hhh_climb_vel.FloatValue, 0.0, false) ) {
			player.SetPropFloat("flWeighDown", 0.0);
		}
	}
	
	if( g_defbosses.no_random_crits.BoolValue ) {
		result = false;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/

stock void TeleToRandomPlayer(VSH2Player boss) {
	int client = boss.index;
	VSH2Player unlucky_fuck = VSH2GameMode.GetRandomFighter();
	if( unlucky_fuck ) {
		int target = unlucky_fuck.index;
		/// Chdata's HHH teleport rework
		//TFClassType tfclass = unlucky_fuck.iTFClass;
		/**
		if( tfclass != TFClass_Scout && tfclass != TFClass_Soldier ) {
			/// Makes HHH clipping go away for player and some projectiles
			SetEntProp(client, Prop_Send, "m_CollisionGroup", 2);
			
			any args[1]; args[0] = boss.userid;
			MakePawnTimer(TeleCollisionReset, 2.0, args, sizeof(args), false);
		}
		**/
		SetEntProp(client, Prop_Send, "m_CollisionGroup", 2);
			
		any args2[1]; args2[0] = boss.userid;
		MakePawnTimer(TeleCollisionReset, 2.0, args2, sizeof(args2), false);
		CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(client, "ghost_appearation", _, false)));
		float pos[3]; GetClientAbsOrigin(target, pos);
		float currtime = GetGameTime();
		SetEntPropFloat(client, Prop_Send, "m_flNextAttack", currtime+2);
		if( GetEntProp(target, Prop_Send, "m_bDucked") ) {
			float collisionvec[3] = {24.0, 24.0, 62.0};
			SetEntPropVector(client, Prop_Send, "m_vecMaxs", collisionvec);
			SetEntProp(client, Prop_Send, "m_bDucked", 1);
			int flags = GetEntityFlags(client);
			SetEntityFlags(client, flags|FL_DUCKING);
			
			any args[2];
			args[0] = boss.userid;
			args[1] = unlucky_fuck.userid;
			MakePawnTimer(StunHHH, 0.2, args, sizeof(args), false);
		} else {
			TF2_StunPlayer(client, 2.0, 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, target);
		}
		
		TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
		SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);
		CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(client, "ghost_appearation")));
		CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(client, "ghost_appearation", _, false)));
		
		/// Chdata's HHH teleport rework
		float vPos[3]; GetEntPropVector(target, Prop_Send, "m_vecOrigin", vPos);
		EmitSoundToClient(client, "misc/halloween/spell_teleport.wav");
		EmitSoundToClient(target, "misc/halloween/spell_teleport.wav");
		
		int msg_len = g_defbosses.cfgs[VSH2Boss_HHHjr].GetSize("teleport msg");
		char[] msg_str = new char[msg_len];
		if( g_defbosses.cfgs[VSH2Boss_HHHjr].Get("teleport msg", msg_str, msg_len) > 0 ) {
			PrintCenterText(target, msg_str);
		} else {
			PrintCenterText(target, "You've been teleported!");
		}
		boss.SetPropFloat("flCharge", g_defbosses.hhh_tele_cooldown.FloatValue);
	}
	
	if( boss.GetPropAny("bSuperCharge") ) {
		boss.SetPropAny("bSuperCharge", false);
	}
}

public void TeleCollisionReset(const int userid) {
	int client = GetClientOfUserId(userid);
	if( !IsClientValid(client) )
		return;
	
	/// Fix HHH's clipping.
	SetEntProp(client, Prop_Send, "m_CollisionGroup", 5);
}

public void StunHHH(const int userid, const int targetid) {
	int client = GetClientOfUserId(userid);
	if( !IsClientValid(client) || !IsPlayerAlive(client) )
		return;
	
	int target = GetClientOfUserId(targetid);
	if( !IsClientValid(target) || !IsPlayerAlive(target) )
		target = 0;
	
	TF2_StunPlayer(client, 2.0, 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, target);
}

public Action RemoveEnt(Handle timer, any entid) {
	int ent = EntRefToEntIndex(entid);
	if( ent > 0 && IsValidEntity(ent) ) {
		AcceptEntityInput(ent, "Kill");
	}
	return Plugin_Continue;
}

stock int AttachParticle(const int ent, const char[] particleType, float offset=0.0, bool battach=true) {
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

stock int AttachProjectileModel(const int entity, const char[] strModel, char[] strAnim = "") {
	if( !IsValidEntity(entity) )
		return -1;
	
	int model = CreateEntityByName("prop_dynamic");
	if( IsValidEntity(model) ) {
		float pos[3], ang[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		GetEntPropVector(entity, Prop_Send, "m_angRotation", ang);
		TeleportEntity(model, pos, ang, NULL_VECTOR);
		DispatchKeyValue(model, "model", strModel);
		DispatchSpawn(model);
		SetVariantString("!activator");
		AcceptEntityInput(model, "SetParent", entity, model, 0);
		if( strAnim[0] != '\0' ) {
			SetVariantString(strAnim);
			AcceptEntityInput(model, "SetDefaultAnimation");
			SetVariantString(strAnim);
			AcceptEntityInput(model, "SetAnimation");
		}
		SetEntPropEnt(model, Prop_Send, "m_hOwnerEntity", entity);
		return model;
	}
	LogError("(AttachProjectileModel): Could not create prop_dynamic");
	return -1;
}

stock bool IsClientValid(int client) {
	return( 0 < client <= MaxClients && IsClientInGame(client) );
}

stock float GetConditionDuration(const int client, const TFCond cond) {
	if( !TF2_IsPlayerInCondition(client, cond) )
		return 0.0;
	
	int m_Shared = FindSendPropInfo("CTFPlayer", "m_Shared");
	Address aCondSource   = view_as< Address >(LoadFromAddress(GetEntityAddress(client) + view_as< Address >(m_Shared + 8), NumberType_Int32));
	Address aCondDuration = view_as< Address >(view_as< int >(aCondSource) + (view_as< int >(cond) * 20) + (2 * 4));
	
	float flDuration = view_as< float >(LoadFromAddress(aCondDuration, NumberType_Int32));
	/**
	const size_t m_Shared    = FindSendPropInfo("CTFPlayer", "m_Shared");
	uint8_t     *client_addr = ( uint8_t* )(GetEntityAddress(client));
	uint8_t     *aCondSource = *( uint8_t** )(client_addr + (m_Shared + 8));
	const float  flDuration  = *( float* )(aCondSource + (cond * 20) + (2 * 4));
	return flDuration;
	 */
	return flDuration;
}

stock void SetConditionDuration(const int client, const TFCond cond, const float duration) {
	if( !TF2_IsPlayerInCondition(client, cond) )
		return;
	
	int m_Shared = FindSendPropInfo("CTFPlayer", "m_Shared");
	Address aCondSource   = view_as< Address >(LoadFromAddress(GetEntityAddress(client) + view_as< Address >(m_Shared + 8), NumberType_Int32));
	Address aCondDuration = view_as< Address >(view_as< int >(aCondSource) + (view_as< int >(cond) * 20) + (2 * 4));
	StoreToAddress(aCondDuration, view_as< int >(duration), NumberType_Int32);
}

stock void SetWeaponAmmo(const int weapon, const int ammo) {
	if( !IsValidEntity(weapon) )
		return;
	
	int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if( !IsClientValid(owner) )
		return;
	
	int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1) * 4;
	int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
	SetEntData(owner, iAmmoTable+iOffset, ammo, 4, true);
}

stock int GetWeaponAmmo(int weapon) {
	if( !IsValidEntity(weapon) )
		return 0;
	
	int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if( owner <= 0 )
		return 0;
	
	int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
	int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
	return GetEntData(owner, iAmmoTable+iOffset, 4);
}

stock void SpawnManyAmmoPacks(const int client, const char[] model, int skin=0, int num=14, float offsz = 30.0) {
	float pos[3], vel[3], ang[3];
	ang[0] = 90.0; ang[1] = 0.0; ang[2] = 0.0;
	GetClientAbsOrigin(client, pos);
	pos[2] += offsz;
	for( int i=0; i<num; i++ ) {
		vel[0] = GetRandomFloat(-400.0, 400.0);
		vel[1] = GetRandomFloat(-400.0, 400.0);
		vel[2] = GetRandomFloat(300.0, 500.0);
		pos[0] += GetRandomFloat(-5.0, 5.0);
		pos[1] += GetRandomFloat(-5.0, 5.0);
		int ent = CreateEntityByName("tf_ammo_pack");
		if( !IsValidEntity(ent) )
			continue;
		
		SetEntityModel(ent, model);
		DispatchKeyValue(ent, "OnPlayerTouch", "!self,Kill,,0,-1"); /// for safety, but it shouldn't act like a normal ammopack
		SetEntProp(ent, Prop_Send, "m_nSkin", skin);
		SetEntProp(ent, Prop_Send, "m_nSolidType", 6);
		SetEntProp(ent, Prop_Send, "m_usSolidFlags", 152);
		SetEntProp(ent, Prop_Send, "m_triggerBloat", 24);
		SetEntProp(ent, Prop_Send, "m_CollisionGroup", 1);
		SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(ent, Prop_Send, "m_iTeamNum", VSH2Team_Red);
		TeleportEntity(ent, pos, ang, vel);
		DispatchSpawn(ent);
		TeleportEntity(ent, pos, ang, vel);
		SetEntProp(ent, Prop_Data, "m_iHealth", 900);
		int offs = GetEntSendPropOffs(ent, "m_vecInitialVelocity", true);
		SetEntData(ent, offs-4, 1, _, true);
	}
}

stock int GetActiveWep(const int client) {
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	return( IsValidEntity(weapon) ) ? weapon : -1;
}