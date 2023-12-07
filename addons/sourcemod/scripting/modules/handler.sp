/**
 * ALL NON-BOSS AND NON-MINION RELATED CODE IS AT THE BOTTOM. HAVE FUN CODING!
 */

#include "bosses.sp"

/**
	PLEASE REMEMBER THAT PLAYERS THAT DON'T HAVE THEIR BOSS ID'S SET ARE NOT ACTUAL BOSSES.
	THIS PLUGIN HAS BEEN SETUP SO THAT IF YOU BECOME A BOSS, YOU MUST HAVE A VALID BOSS ID.

	FOR MANAGEMENT FUNCTIONS, DO NOT HAVE THEM DISCRIMINATE WHO IS A BOSS OR NOT, SIMPLY CHECK 'iBossType' TO SEE IF IT REALLY WAS A BOSS PLAYER.
*/


public void ManageDownloads() {
	Action act = Call_OnCallDownloads();    /// in forwards.sp
	if( act==Plugin_Stop ) {
		return;
	}
	
	char download_keys[][] = {
		"downloads.sounds",
		"downloads.models",
		"downloads.materials"
	};
	
	for( int i; i < sizeof(download_keys); i++ ) {
		ConfigMap download_map = g_vsh2.m_hCfg.GetSection(download_keys[i]);
		PrepareAssetsFromCfgMap(download_map, i);
	}
	
	char basic_sounds[][] = {
		"ui/item_store_add_to_cart.wav",
		"player/doubledonk.wav",
		"vo/announcer_am_capincite01.mp3",
		"vo/announcer_am_capincite03.mp3",
		"vo/announcer_am_capenabled02.mp3",
		"vo/announcer_ends_60sec.mp3",
		"vo/announcer_ends_30sec.mp3",
		"vo/announcer_ends_10sec.mp3",
		"vo/announcer_ends_1sec.mp3",
		"vo/announcer_ends_2sec.mp3",
		"vo/announcer_ends_3sec.mp3",
		"vo/announcer_ends_4sec.mp3",
		"vo/announcer_ends_5sec.mp3",
		"items/pumpkin_pickup.wav"
	};
	PrecacheSoundList(basic_sounds, sizeof(basic_sounds));
	//PrepareSound("saxton_hale/9000.wav");
	
	//AddHaleToDownloads   ();
	//AddVagToDownloads    ();
	//AddCBSToDownloads    ();
	//AddHHHToDownloads    ();
	//AddBunnyToDownloads  ();
}

public void ManageMenu(Menu& menu, int client) {
	for( int i = VSH2Boss_Hale; i < MaxDefaultVSH2Bosses; i++ ) {
		if( g_vsh2.m_hBossCfgs[i] != null ) {
			char bossid[5]; IntToString(i, bossid, sizeof(bossid));
			char boss_name[45];
			switch( i ) {
				case VSH2Boss_Hale:     boss_name = "hale_menu_name";
				case VSH2Boss_Bunny:    boss_name = "bunny_menu_name";
				case VSH2Boss_CBS:      boss_name = "cbs_menu_name";
				case VSH2Boss_HHHjr:    boss_name = "hhh_menu_name";
				case VSH2Boss_Vagineer: boss_name = "vagineer_menu_name";
			}
			char menu_name[100];
			Format(menu_name, sizeof(menu_name), "%T", boss_name, client);
			menu.AddItem(bossid, menu_name);
		}
	}
	Call_OnBossMenu(menu, BasePlayer(client));
}

public void ManageDisconnect(int client) {
	BasePlayer leaver = BasePlayer(client);
	if( leaver.index && leaver.bIsBoss ) {
		if( g_vshgm.iRoundState >= StateRunning ) {
			/// Arena mode flips out when no one is on the other team
			BasePlayer[] bosses = new BasePlayer[MaxClients];
			int numbosses = VSHGameMode.GetBosses(bosses, false);
			if( numbosses-1 > 0 ) { /// Exclude leaver, this is why CountBosses() can't be used
				for( int i=0; i < numbosses; i++ ) {
					if( bosses[i]==leaver || (IsClientValid(bosses[i].index) && IsPlayerAlive(bosses[i].index)) ) {
						continue;
					}
					BasePlayer next = VSHGameMode.FindNextBoss();
					if( g_vshgm.hNextBoss ) {
						next = g_vshgm.hNextBoss;
						g_vshgm.hNextBoss = view_as< BasePlayer >(0);
					}
					if( IsClientValidExtra(next.index) ) {
						next.bIsMinion = true; /// Dumb hack, prevents spawn hook from forcing them back to red
						next.ForceTeamChange(VSH2Team_Boss);
					}
					if( g_vshgm.iRoundState==StateRunning ) {
						g_vshgm.iRoundResult = RoundResBossDisc;
						ForceTeamWin(VSH2Team_Red);
					}
					break;
				}
			} else { /// No bosses left
				BasePlayer next = VSHGameMode.FindNextBoss();
				if( g_vshgm.hNextBoss ) {
					next = g_vshgm.hNextBoss;
					g_vshgm.hNextBoss = view_as< BasePlayer >(0);
				}
				if( IsClientValidExtra(next.index) ) {
					next.bIsMinion = true;
					next.ForceTeamChange(VSH2Team_Boss);
				}
				if( g_vshgm.iRoundState==StateRunning ) {
					g_vshgm.iRoundResult = RoundResBossDisc;
					ForceTeamWin(VSH2Team_Red);
				}
			}
		} else if( g_vshgm.iRoundState==StateStarting ) {
			BasePlayer replace = VSHGameMode.FindNextBoss();
			if( g_vshgm.hNextBoss ) {
				replace = g_vshgm.hNextBoss;
				g_vshgm.hNextBoss = view_as< BasePlayer >(0);
			}
			if( IsClientValidExtra(replace.index) ) {
				replace.MakeBossAndSwitch(replace.iPresetType == -1? leaver.iBossType : replace.iPresetType, true);
				CPrintToChat(replace.index, "{olive}[VSH 2]{green} %t", "start_boss_replacer");
			}
		}
		CPrintToChatAll("{olive}[VSH 2]{red} %t", "start_boss_disconnected");
	} else {
		RequestFrame(CheckAlivePlayers, 0);
		if( client==VSHGameMode.FindNextBoss().index ) {
			SetPawnTimer(_SkipBossPanel, 1.0);
		}
		if( leaver.userid==g_vshgm.hNextBoss.userid ) {
			g_vshgm.hNextBoss = view_as< BasePlayer >(0);
		}
	}
}

public void ManageOnBossSelected(BasePlayer base) {
	SetPawnTimer(_SkipBossPanel, 4.0);
	Action act = Call_OnBossSelected(base);
	if( act > Plugin_Changed ) {
		return;
	}
	
	ManageBossHelp(base);
	
	/// random multibosses code.
	int playing = GetLivingPlayers(VSH2Team_Red);
	int max_random_bosses = g_vsh2.m_hCvars.MaxRandomMultiBosses.IntValue;
	if( !g_vsh2.m_hCvars.AllowRandomMultiBosses.BoolValue || playing < 10 || GetRandomInt(0, 3) > 0 || VSHGameMode.CountBosses(false) >= max_random_bosses ) {
		return;
	}
	
	int extra_bosses = GetRandomInt(1, playing / 12);
	if( extra_bosses > max_random_bosses ) {
		extra_bosses = max_random_bosses;
	}
	
	BasePlayer[] players = new BasePlayer[MaxClients];
	int num_players = VSHGameMode.GetQueue(players);
	int curr_player = 0, curr_extra_boss = 0;
	while( curr_extra_boss < extra_bosses && curr_player < num_players ) {
		BasePlayer partner = players[curr_player];
		/// Check for boss here (again) for redundancy.
		if( partner.bIsMinion || partner.bIsBoss || !partner.bCanBossPartner ) {
			curr_player++;
			continue;
		}
		
		int preset_boss_type = partner.iPresetType;
		if( preset_boss_type == -1 ) {
			preset_boss_type = GetRandomInt(VSH2Boss_Hale, g_vshgm.MAXBOSS);
		}
		partner.MakeBossAndSwitch(preset_boss_type, false);
		curr_extra_boss++;
		curr_player++;
	}
}

public Action ManageOnTouchPlayer(BasePlayer base, BasePlayer victim) {
	return Call_OnTouchPlayer(base, victim);
}

public Action ManageOnTouchBuilding(BasePlayer base, int building) {
	return Call_OnTouchBuilding(base, EntIndexToEntRef(building));
}

public void ManageBossHelp(BasePlayer base) {
	if( VSH2Boss_Hale <= base.iBossType < MaxDefaultVSH2Bosses ) {
		if( IsVoteInProgress() ) {
			return;
		}
		char helpstr[256];
		char boss_panel[64];
		switch( base.iBossType ) {
		case -1: {}
			case VSH2Boss_Hale:     boss_panel = "hale_panel";
			case VSH2Boss_Vagineer: boss_panel = "vagineer_panel";
			case VSH2Boss_CBS:      boss_panel = "cbs_panel";
			case VSH2Boss_HHHjr:    boss_panel = "hhh_panel";
			case VSH2Boss_Bunny:    boss_panel = "bunny_panel";
		}
		
		Format(helpstr, sizeof(helpstr), "%T", boss_panel, base.index);
		
		Panel panel = new Panel();
		panel.SetTitle(helpstr);
		char exit_test[64];
		Format(exit_test, sizeof(exit_test), "%T", "Exit", base.index);
		panel.DrawItem(exit_test);
		panel.Send(base.index, HintPanel, 10);
		delete panel;
	}
	Call_OnBossHelp(base);
}


stock void AddSpacer(char hud_text[PLAYER_HUD_SIZE]) {
	Format(hud_text, sizeof(hud_text), "%s | ", hud_text);
}
public bool SetUpHUDForAbilities(BasePlayer player, char hud_text[PLAYER_HUD_SIZE]) {
	bool written = false;
	if( player.HasAbility(ABILITY_SUPERJUMP) ) {
		float charge = player.flCharge;
		Format(hud_text, sizeof(hud_text), "%s%t", hud_text, "superjump_hud_text", player.bSuperCharge? 1000 : RoundFloat(charge) * 4);
		written = true;
	}
	if( player.HasAbility(ABILITY_POWER_UBER) && TF2_IsPlayerInCondition(player.index, TFCond_Ubercharged) ) {
		if( written ) {
			AddSpacer(hud_text);
		}
		float dur = GetConditionDuration(player.index, TFCond_Ubercharged);
		Format(hud_text, sizeof(hud_text), "%s%t", hud_text, "uber_hud_text", dur);
		written = true;
	}
	if( player.HasAbility(ABILITY_TELEPORT) ) {
		if( written ) {
			AddSpacer(hud_text);
		}
		float charge = player.flCharge;
		Format(hud_text, sizeof(hud_text), "%t", "teleport_hud_text", player.bSuperCharge? 1000 : RoundFloat(charge) * 2);
		written = true;
	}
	if( player.HasAbility(ABILITY_RAGE) ) {
		if( written ) {
			AddSpacer(hud_text);
		}
		Format(hud_text, sizeof(hud_text), "%s%t: %t", hud_text, "rage_hud_text", player.flRAGE >= 100.0? "rage_hud_text_full" : "rage_hud_text_percent", player.flRAGE);
		written = true;
	}
	return written;
}

public void ManageBossHUD(BasePlayer player) {
	int client = player.index;
	if( !IsPlayerAlive(client) ) {
		return;
	}
	char hud_text[PLAYER_HUD_SIZE];
	bool written = SetUpHUDForAbilities(player, hud_text);
	
	/// special boss HUD texts that can't really be genericized.
	switch( player.iBossType ) {
		case VSH2Boss_CBS: {
			int bow = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
			if( bow != -1 ) {
				int arrows_left = GetWeaponAmmo(bow);
				if( written ) {
					AddSpacer(hud_text);
				}
				Format(hud_text, sizeof(hud_text), "%s%t", hud_text, "cbs_arrow_hud_text", arrows_left);
			}
		}
		case VSH2Boss_HHHjr: {
			if( player.HasAbility(ABILITY_CLIMB_WALLS) ) {
				if( written ) {
					AddSpacer(hud_text);
				}
				int max_climbs = g_vsh2.m_hCvars.HHHMaxClimbs.IntValue;
				Format(hud_text, sizeof(hud_text), "%s%t", hud_text, "hhh_climb_hud_text", player.iClimbs, max_climbs);
			}
		}
	}
	
	if( Call_OnBossHUD(player, hud_text) > Plugin_Changed ) {
		return;
	}
	
	/// TODO: cvar/configs for HUD data.
	SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
	ShowSyncHudText(player.index, g_vsh2.m_hHUDs[PlayerHUD], "%s", hud_text);
}

public void ManageBossModels(BasePlayer base) {
	if( Call_OnBossModelTimer(base) > Plugin_Changed ) {
		return;
	}
	/// TODO: phase this out.
	ConfigMap cfg = g_vsh2.GetPlayerCfg(base);
	ConfigMap models_sect = cfg.GetSection("models");
	int client = base.index;
	int model_str_len = models_sect.GetSize("0");
	char[] model_str = new char[model_str_len + 1];
	models_sect.GetIntKey(0, model_str, model_str_len);
	
	SetVariantString(model_str);
	AcceptEntityInput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
}

public void ManageBossDeath(BasePlayer base) {
	if( Call_OnBossDeath(base) > Plugin_Changed ) {
		return;
	}
	ConfigMap cfg = g_vsh2.GetPlayerCfg(base);
	base.PlayRandVoiceClipFromCfg(cfg.GetSection("sounds.lose"), VSH2_VOICE_LOSE);
	
	if( base.HasAbility(ABILITY_EXPLODE_AMMO) ) {
		ConfigMap ability_section = cfg.GetSection("abilities." ... ABILITY_EXPLODE_AMMO);
		int model_len = ability_section.GetIntKeySize(0);
		if( model_len > 1 ) {
			char[] model = new char[model_len + 1];
			ability_section.GetIntKey(0, model, model_len);
			SpawnManyAmmoPacks(base.index, model, 1);
		}
	}
	g_vshgm.iHealthBar.iState ^= 1;
}

public void ManageBossEquipment(BasePlayer base) {
	if( Call_OnBossEquipped(base) > Plugin_Changed ) {
		return;
	}
	
	ConfigMap cfg = g_vsh2.GetPlayerCfg(base);
	if( cfg==null ) {
		return;
	}
	
	char boss_name[MAX_BOSS_NAME_SIZE];
	if( VSH2Boss_Hale <= base.iBossType < MaxDefaultVSH2Bosses ) {
		char name_translation[30];
		switch( base.iBossType ) {
			case VSH2Boss_Hale:
				name_translation = "hale_name";
			case VSH2Boss_CBS:
				name_translation = "cbs_name";
			case VSH2Boss_Bunny:
				name_translation = "bunny_name";
			case VSH2Boss_HHHjr:
				name_translation = "hhh_name";
			case VSH2Boss_Vagineer:
				name_translation = "vagineer_name";
		}
		Format(boss_name, sizeof(boss_name), "%T", name_translation, base.index);
		base.SetName(boss_name);
	} else {
		cfg.Get("boss.name", boss_name, sizeof(boss_name));
		base.SetName(boss_name);
	}
	
	ConfigMap weapons_sect = cfg.GetSection("weapons");
	if( weapons_sect==null ) {
		return;
	}
	
	base.RemoveAllItems();
	int num_weaps = weapons_sect.Size;
	for( int i; i < num_weaps; i++ ) {
		ConfigMap weapon_sect = weapons_sect.GetIntKeySection(i);
		if( weapon_sect==null ) {
			continue;
		}
		
		int classname_len = weapon_sect.GetSize("classname");
		char[] wep_classname = new char[classname_len + 1];
		weapon_sect.Get("classname", wep_classname, classname_len);
		
		int index;     weapon_sect.GetInt("index",   index);
		int level;     weapon_sect.GetInt("level",   level);
		int quality;   weapon_sect.GetInt("quality", quality);
		int ammo = -1; weapon_sect.GetInt("ammo",    ammo);
		int clip = -1; weapon_sect.GetInt("clip",    clip);
		
		int attribs_len = weapon_sect.GetSize("attributes");
		char[] attribs = new char[attribs_len + 1];
		weapon_sect.Get("attributes", attribs, attribs_len);
		
		int boss_weap = base.SpawnWeapon(wep_classname, index, level, quality, attribs);
		SetEntPropEnt(base.index, Prop_Send, "m_hActiveWeapon", boss_weap);
		
		if( ammo > -1 ) {
			SetWeaponAmmo(boss_weap, ammo);
		}
		if( clip > -1 ) {
			SetWeaponClip(boss_weap, clip);
		}
	}
	
	ConfigMap abilities_sect = cfg.GetSection("abilities");
	int num_abilities = abilities_sect.Size;
	for( int i; i < num_abilities; i++ ) {
		int key_len = abilities_sect.GetKeySize(i);
		char[] key = new char[key_len + 1];
		abilities_sect.GetKey(i, key, key_len);
		base.GiveAbility(key);
	}
	Call_OnBossEquippedPost(base);
}

/** whatever stuff needs initializing should be done here */
public void ManageBossTransition(BasePlayer base) {
#if defined _tf2attributes_included
	if( g_vshgm.bTF2Attribs ) {
		TF2Attrib_RemoveAll(base.index);
	}
#endif
	switch( base.iBossType ) {
		case VSH2Boss_Hale:                  TF2_SetPlayerClass(base.index, TFClass_Soldier,  _, false);
		case VSH2Boss_Vagineer:              TF2_SetPlayerClass(base.index, TFClass_Engineer, _, false);
		case VSH2Boss_CBS:                   TF2_SetPlayerClass(base.index, TFClass_Sniper,   _, false);
		case VSH2Boss_HHHjr, VSH2Boss_Bunny: TF2_SetPlayerClass(base.index, TFClass_DemoMan,  _, false);
	}
	ManageBossModels(base);
	/// Patch: Aug 18, 2018 - patching bad first person animations on custom boss models.
	Call_OnBossInitialized(base);
	ManageBossEquipment(base);
}

public void ManageMinionTransition(BasePlayer base) {
	if( !base.bIsMinion ) {
		return;
	}
	base.ForceTeamChange(VSH2Team_Boss); /// Force our guy to the dark side lmao
	base.RemoveAllItems(false);
	BasePlayer master = BasePlayer(base.iOwnerBoss, true);
	Call_OnMinionInitialized(base, master);
}

public void ManagePlayBossIntro(BasePlayer base) {
	if( Call_OnBossPlayIntro(base) > Plugin_Changed ) {
		return;
	}
	int boss_type = base.iBossType;
	if( VSH2Boss_Hale <= boss_type < MaxDefaultVSH2Bosses ) {
		ConfigMap cfg = g_vsh2.m_hBossCfgs[boss_type];
		if( cfg==null ) {
			return;
		}
		
		ConfigMap intros = cfg.GetSection("sounds.intros");
		base.PlayRandVoiceClipFromCfg(intros, VSH2_VOICE_INTRO);
	}
}

public Action ManageOnBossTakeDamage(BasePlayer victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	switch( victim.iBossType ) {
		case -1: {}
		default: {
			int bFallDamage = (damagetype & DMG_FALL);
			char trigger[32];
			if( attacker > MaxClients
			&& GetEdictClassname(attacker, trigger, sizeof(trigger))
			&& !strcmp(trigger, "trigger_hurt", false) ) {
				Action act = Call_OnBossTakeDamage_OnTriggerHurt(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
				if( act > Plugin_Changed ) {
					return Plugin_Continue;
				}
				if( g_vshgm.bTeleToSpawn || damage >= victim.iHealth ) {
					victim.TeleToSpawn(VSH2Team_Boss);
				} else if( damage >= g_vsh2.m_hCvars.TriggerHurtThreshold.FloatValue ) {
					/*
					if( victim.HasAbility(ABILITY_TELEPORT) ) {
						ConfigMap ability = g_vsh2.GetPlayerCfg(victim).GetSection("abilities").GetSection(ABILITY_TELEPORT);
						victim.flCharge = ability.GetIntKeyFloatEx(1, 50.0);
					} else {
					*/
					victim.bSuperCharge = true;
					//}
				}
				if( damage > g_vsh2.m_hCvars.MaxTriggerHurtDmg.FloatValue ) {
					if( act != Plugin_Changed ) {
						damage = g_vsh2.m_hCvars.MaxTriggerHurtDmg.FloatValue;
					}
					return Plugin_Changed;
				}
			} else if( attacker <= 0 && bFallDamage ) {
				if( Call_OnBossTakeFallDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
					damage = (victim.iHealth > 100)? 1.0 : 30.0;
				}
				return Plugin_Changed;
			}
			
			if( attacker <= 0 || attacker > MaxClients ) {
				return Plugin_Continue;
			}
			
			BasePlayer hitter = BasePlayer(attacker);
			victim.iHits++;
			victim.flLastHit = GetGameTime();
			char classname[64], inflictor_name[32];
			if( IsValidEntity(inflictor) ) {
				GetEntityClassname(inflictor, inflictor_name, sizeof(inflictor_name));
			}
			if( IsValidEntity(weapon) ) {
				GetEdictClassname(weapon, classname, sizeof(classname));
			}
			
			/// Bosses shouldn't die from a single backstab
			int wepindex = GetItemIndex(weapon);
			if( damagecustom == TF_CUSTOM_BACKSTAB || (!strcmp(classname, "tf_weapon_knife", false) && damage > victim.iHealth) ) {
				float max_hp       = float(victim.iMaxHealth);
				float power        = Pow(max_hp * 0.0014, 2.0);
				float percentage   = max_hp * (float(victim.iStabbed) / 100);
				float changedamage = (power + 899.0) - percentage;
				
				/// TODO: cvar for stab amount.
				if( victim.iStabbed < 4 ) {
					victim.iStabbed++;
				}
				/// You can level "damage dealt" with backstabs
				damage = changedamage / 3;
				damagetype |= DMG_CRIT;
				EmitSoundToAll("player/spy_shield_break.wav", victim.index, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
				EmitSoundToAll("player/crit_received3.wav", victim.index, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
				
				float curtime = GetGameTime();
				/// TODO: cvars for post-stab cooldowns.
				SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", curtime+2.0);
				SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", curtime+2.0);
				SetEntPropFloat(attacker, Prop_Send, "m_flStealthNextChangeTime", curtime+2.0);
				int vm = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
				if( IsValidEntity(vm) && hitter.iTFClass==TFClass_Spy ) {
					int melee = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Melee);
					int anim = 15;
					switch( melee ) {
						case 727: anim = 41;
						case 4, 194, 665, 794, 803, 883, 892, 901, 910: anim = 10;
						case 638: anim = 31;
					}
					SetEntProp(vm, Prop_Send, "m_nSequence", anim);
				}
				char boss_name[MAX_BOSS_NAME_SIZE]; victim.GetName(boss_name);
				PrintCenterText(attacker, "%t", "player_backstab", boss_name);
				PrintCenterText(victim.index, "%t", "boss_got_backstabbed");
				
				int pistol = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Primary);
				if( pistol == 525 ) {
					/// Diamondback gains 2 crits on backstab.
					int iCrits = GetEntProp(attacker, Prop_Send, "m_iRevengeCrits");
					/// TODO: cvar for how many crits are gained.
					SetEntProp(attacker, Prop_Send, "m_iRevengeCrits", iCrits+2);
				}
				
				/// connivers kunai
				if( wepindex==356 ) {
					int health = hitter.iHealth + g_vsh2.m_hCvars.KunaiHealthAdd.IntValue;
					if( health > g_vsh2.m_hCvars.KunaiHealthGuard.IntValue ) {
						health = g_vsh2.m_hCvars.KunaiHealthLimit.IntValue;
					}
					SetEntProp(attacker, Prop_Data, "m_iHealth", health);
					SetEntProp(attacker, Prop_Send, "m_iHealth", health);
				} else if( wepindex==461 ) {
					/// Big Earner gives full cloak on backstab
					SetEntPropFloat(attacker, Prop_Send, "m_flCloakMeter", 100.0);
				}
				ConfigMap cfg = g_vsh2.GetPlayerCfg(victim);
				ConfigMap stabbed_sounds = cfg.GetSection("sounds.backstab");
				victim.PlayRandVoiceClipFromCfg(stabbed_sounds, VSH2_VOICE_STABBED);
				
				if( Call_OnBossTakeDamage_OnStabbed(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) > Plugin_Changed ) {
					return Plugin_Changed;
				}
				return Plugin_Changed;
			}
			if( damagecustom==TF_CUSTOM_BOOTS_STOMP ) {
				ConfigMap cfg = g_vsh2.GetPlayerCfg(victim);
				ConfigMap stomped_sounds = cfg.GetSection("sounds.stomped");
				victim.PlayRandVoiceClipFromCfg(stomped_sounds, VSH2_VOICE_STABBED);
				if( Call_OnBossTakeDamage_OnMantreadsStomp(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
					int flag = g_vsh2.m_hCvars.BootStompLogic.IntValue;
					float boot_dmg = g_vsh2.m_hCvars.BootStompDamage.FloatValue;
					switch( flag ) {
						case 0: damage =  boot_dmg;
						case 1: damage *= boot_dmg;
						case 2: damage += boot_dmg;
					}
				}
				return Plugin_Changed;
			}
			if( damagecustom==TF_CUSTOM_TELEFRAG ) {
				ConfigMap cfg = g_vsh2.GetPlayerCfg(victim);
				ConfigMap telefrag_sounds = cfg.GetSection("sounds.telefragged");
				victim.PlayRandVoiceClipFromCfg(telefrag_sounds, VSH2_VOICE_STABBED);
				if( Call_OnBossTakeDamage_OnTelefragged(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
					damage = victim.iHealth+0.2;
					int flag = g_vsh2.m_hCvars.TeleFragLogic.IntValue;
					float telefrag_dmg = g_vsh2.m_hCvars.TeleFragDamage.FloatValue;
					switch( flag ) {
						case 0: damage =  telefrag_dmg;
						case 1: damage *= telefrag_dmg;
						case 2: damage += telefrag_dmg;
						case 3: damage =  victim.iHealth + 0.2;
						case 4: damage =  victim.iHealth * telefrag_dmg;
						case 5: damage =  victim.iHealth + telefrag_dmg;
					}
				}
				int teleowner = FindTeleOwner(attacker);
				if( teleowner != -1 && teleowner != attacker ) {
					BasePlayer builder = BasePlayer(teleowner);
					builder.iDamage += RoundFloat(damage) / 2;
				}
				return Plugin_Changed;
			}
			if( victim.HasAbility(ABILITY_ANCHOR) || g_vsh2.m_hCvars.Anchoring.BoolValue ) {
				int iFlags = GetEntityFlags(victim.index);
				int crouch_walk = (FL_ONGROUND|FL_DUCKING);
#if defined _tf2attributes_included
				if( g_vshgm.bTF2Attribs ) {
					/// If Hale is ducking on the ground, it's harder to knock him back
					if( (iFlags & crouch_walk)==crouch_walk ) {
						TF2Attrib_SetByDefIndex(victim.index, 252, 0.0);
					} else {
						TF2Attrib_RemoveByDefIndex(victim.index, 252);
					}
				} else {
					/// Does not protect against sentries or FaN, but does against miniguns and rockets
					if( (iFlags & crouch_walk)==crouch_walk ) {
						damagetype |= DMG_PREVENT_PHYSICS_FORCE;
					}
				}
#else
				if( (iFlags & crouch_walk)==crouch_walk ) {
					damagetype |= DMG_PREVENT_PHYSICS_FORCE;
				}
#endif
				ConfigMap cfg = g_vsh2.GetPlayerCfg(victim);
				ConfigMap ability = cfg.GetSection("abilities." ... ABILITY_ANCHOR);
				victim.PlayRandVoiceClipFromCfg(ability.GetSection("sounds"), VSH2_VOICE_ABILITY);
			}
			
			/// Gives 4 heads if successful sword killtaunt!
			if( damagecustom==TF_CUSTOM_TAUNT_BARBARIAN_SWING ) {
				hitter.IncreaseHeadCount(_, 4);
				if( Call_OnBossTakeDamage_OnSwordTaunt(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) == Plugin_Changed ) {
					return Plugin_Changed;
				}
			}
			
			/// Heavy Shotguns heal for damage dealt
			if( StrContains(classname, "tf_weapon_shotgun", false) > -1 && hitter.iTFClass==TFClass_Heavy ) {
				return Call_OnBossTakeDamage_OnHeavyShotgun(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
			} else if( StrContains(classname, "tf_weapon_sniperrifle", false) > -1 && g_vshgm.iRoundState != StateEnding ) {
				if( wepindex != 230 && wepindex != 526 && wepindex != 752 && wepindex != 30665 ) {
					float bossGlow = victim.flGlowtime;
					float chargelevel = (IsValidEntity(weapon)? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
					
					/// TODO: add cvars for all this.
					float time = (bossGlow > 10? 1.0 : 2.0);
					time += (bossGlow > 10? (bossGlow > 20? 1 : 2) : 4) * (chargelevel / 100);
					bossGlow += RoundToCeil(time);
					float max_time_cap = g_vsh2.m_hCvars.MaxBossGlowTime.FloatValue;
					if( bossGlow > max_time_cap ) {
						bossGlow = max_time_cap;
					}
					victim.flGlowtime = bossGlow;
				}
				/// bazaar bargain I think
				if( wepindex==402 && damagecustom==TF_CUSTOM_HEADSHOT ) {
					hitter.IncreaseHeadCount(false);
				}
				if( wepindex==752 ) {
					float chargelevel = (IsValidEntity(weapon)? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
					float add = 10 + (chargelevel / 10);
					if( TF2_IsPlayerInCondition(attacker, view_as< TFCond >(46)) ) {
						add /= 3.0;
					}
					float rage = GetEntPropFloat(attacker, Prop_Send, "m_flRageMeter");
					SetEntPropFloat(attacker, Prop_Send, "m_flRageMeter", (rage + add > 100)? 100.0 : rage + add);
				}

				if( wepindex==230 ) {
					victim.flRAGE -= (damage * g_vsh2.m_hCvars.SydneySleeperRageRemove.FloatValue);
				}

				if( !(damagetype & DMG_CRIT) ) {
					bool ministatus = (TF2_IsPlayerInCondition(attacker, TFCond_CritCola) || TF2_IsPlayerInCondition(attacker, TFCond_Buffed) || TF2_IsPlayerInCondition(attacker, TFCond_CritHype));
					if( Call_OnBossTakeDamage_OnSniped(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
						/// TODO: add cvar for this.
						damage *= (ministatus)? 2.222222 : 3.0;
						return Plugin_Changed;
					}
					return Plugin_Changed;
				}
			}
			switch( wepindex ) {
				/// Third Degree
				case 593: {
					int medics;
					int numhealers = GetEntProp(attacker, Prop_Send, "m_nNumHealers");
					for( int i; i < numhealers; i++ ) {
						/// Dispensers > MaxClients
						if( 0 < GetHealerByIndex(attacker, i) <= MaxClients ) {
							medics++;
						}
					}
					for( int i; i < numhealers; i++ ) {
						int healer;
						if( 0 < (healer = GetHealerByIndex(attacker, i)) <= MaxClients ) {
							int medigun = GetPlayerWeaponSlot(healer, TFWeaponSlot_Secondary);
							if( IsValidEntity(medigun) ) {
								char cls[32]; GetEdictClassname(medigun, cls, sizeof(cls));
								if( !strcmp(cls, "tf_weapon_medigun", false) ) {
									float gain = g_vsh2.m_hCvars.ThirdDegreeUberGain.FloatValue;
									float uber = GetMediGunCharge(medigun) + (gain / medics);
									float max = 1.0;
									if( GetEntProp(medigun, Prop_Send, "m_bChargeRelease") ) {
										max = g_vsh2.m_hCvars.UberDeployChargeAmnt.FloatValue;
									}
									if( uber > max ) {
										uber = max;
									}
									SetMediCharge(medigun, uber);
								}
							}
						}
					}
					if( Call_OnBossTakeDamage_OnThirdDegreed(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) == Plugin_Changed ) {
						return Plugin_Changed;
					}
				}
				/*
				case 14, 201, 230, 402, 526, 664, 752, 792, 801, 851, 881, 890, 899, 908, 957, 966, 1098: {
					switch( wepindex ) {	/// cleaner to read than if wepindex == || wepindex == || etc.
						case 14, 201, 664, 792, 801, 851, 881, 890, 899, 908, 957, 966: {	/// sniper rifles
							if( g_vshgm.iRoundState != StateEnding ) {
								float bossGlow = victim.flGlowtime;
								float chargelevel = (IsValidEntity(weapon)? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
								float time = (bossGlow > 10? 1.0 : 2.0);
								time += (bossGlow > 10? (bossGlow > 20? 1 : 2) : 4)*(chargelevel/100);
								bossGlow += RoundToCeil(time);
								if( bossGlow > 30.0 )
									bossGlow = 30.0;
								victim.flGlowtime = bossGlow;
							}
						}
					}
					if( wepindex == 402 ) {	/// bazaar bargain I think
						if( damagecustom == TF_CUSTOM_HEADSHOT )
							hitter.IncreaseHeadCount(false);
					}
					if( wepindex == 752 && g_vshgm.iRoundState != StateEnding ) {
						float chargelevel = (IsValidEntity(weapon)? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
						float add = 10 + (chargelevel 0/ 10);
						if( TF2_IsPlayerInCondition(attacker, view_as< TFCond >(46)) )
							add /= 3;
						float rage = GetEntPropFloat(attacker, Prop_Send, "m_flRageMeter");
						SetEntPropFloat(attacker, Prop_Send, "m_flRageMeter", (rage + add > 100)? 100.0 : rage + add);
					}
					if( !(damagetype & DMG_CRIT) ) {
						bool ministatus = (TF2_IsPlayerInCondition(attacker, TFCond_CritCola) || TF2_IsPlayerInCondition(attacker, TFCond_Buffed) || TF2_IsPlayerInCondition(attacker, TFCond_CritHype));
						damage *= (ministatus)? 2.222222 : 3.0;
						if( wepindex==230 ) {
							victim.flRAGE -= (damage * 0.035);
						}
						return Plugin_Changed;
					} else if( wepindex==230 ) {
						victim.flRAGE -= (damage * 0.035);
					}
				}
				*/
				/// Swords
				case 132, 266, 482, 1082: {
					if( Call_OnBossTakeDamage_OnHitSword(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) == Plugin_Changed ) {
						return Plugin_Changed;
					}
					hitter.IncreaseHeadCount();
				}
				/// Fan O War
				case 355: {
					if( Call_OnBossTakeDamage_OnHitFanOWar(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) == Plugin_Changed ) {
						return Plugin_Changed;
					}
					victim.flRAGE -= g_vsh2.m_hCvars.FanoWarRage.FloatValue;
				}
				/// Candy Cane
				case 317: {
					if( Call_OnBossTakeDamage_OnHitCandyCane(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) == Plugin_Changed ) {
						return Plugin_Changed;
					}
					hitter.SpawnSmallHealthPack(GetClientTeam(attacker));
				}
				/// Chdata's Market Gardener backstab
				case 416: {
					if( hitter.bInJump ) {
						float max_hp = float(victim.iMaxHealth);
						float power = Pow(max_hp, 0.74074);
						float percentage = victim.iMarketted / 128 * max_hp;
						damage = (power - percentage) / 3.0;
						
						damage *= VSHGameMode.CountBosses(true);
						/// divide by 3 because this is basedamage and lolcrits (0.714286)) + 1024.0)
						damagetype |= DMG_CRIT;
						
						if( victim.iMarketted < 5 ) {
							victim.iMarketted++;
						}
						char name[MAX_BOSS_NAME_SIZE]; victim.GetName(name);
						PrintCenterText(attacker, "%t", "player_market_garden", name);
						PrintCenterText(victim.index, "%t", "boss_got_market_gardened");
						EmitSoundToAll("player/doubledonk.wav", victim.index, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
						SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+2.0);
						ConfigMap cfg = g_vsh2.GetPlayerCfg(victim);
						ConfigMap market_garden_sounds = cfg.GetSection("sounds.marketed");
						victim.PlayRandVoiceClipFromCfg(market_garden_sounds, VSH2_VOICE_STABBED);
						if( Call_OnBossTakeDamage_OnMarketGardened(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
							return Plugin_Changed;
						}
						return Plugin_Changed;
					}
				}
				/// PowerJackass
				case 214: {
					int max = GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
					hitter.Heal(g_vsh2.m_hCvars.PowerJackHealth.IntValue, true, true, max + g_vsh2.m_hCvars.PowerJackMaxOverheal.IntValue);
					if( TF2_IsPlayerInCondition(attacker, TFCond_OnFire) ) {
						TF2_RemoveCondition(attacker, TFCond_OnFire);
					}
					if( Call_OnBossTakeDamage_OnPowerJack(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) == Plugin_Changed ) {
						return Plugin_Changed;
					}
				}
				/// Katana
				case 357: {
					SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
					if( GetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy") < 1 ) {
						SetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
					}
					int max = GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
					hitter.Heal(g_vsh2.m_hCvars.KatanaHealth.IntValue, true, true, max + g_vsh2.m_hCvars.KatanaMaxOverheal.IntValue);
					if( TF2_IsPlayerInCondition(attacker, TFCond_OnFire) ) {
						TF2_RemoveCondition(attacker, TFCond_OnFire);
					}
					//int weap = GetPlayerWeaponSlot(victim.index, TFWeaponSlot_Melee);
					//int index = GetItemIndex(weap);
					//int active = GetEntPropEnt(victim.index, Prop_Send, "m_hActiveWeapon");
					if( Call_OnBossTakeDamage_OnKatana(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) == Plugin_Changed ) {
						return Plugin_Changed;
					}
					/*
					if( index == 357 && active == weap ) {
						damage = 195.0 / 3.0;
						return Plugin_Changed;
					}
					*/
				}
				/// Ambassador + Festive ver.
				case 61, 1006: {  /// Ambassador does 2.5x damage on headshot
					if( damagecustom == TF_CUSTOM_HEADSHOT ) {
						if( Call_OnBossTakeDamage_OnAmbassadorHeadshot(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
							damage *= g_vsh2.m_hCvars.SpyHeadMult.FloatValue;
						}
						return Plugin_Changed;
					}
				}
				/*
				case 16, 203, 751, 1149: {  /// SMG does 2.5x damage on headshot
					if( damagecustom == TF_CUSTOM_HEADSHOT ) {
						damage = 27.0;
						return Plugin_Changed;
					}
				}
				*/
				/// Diamondback & Manmelter
				case 525, 595: {
					/// If a revenge crit was used, give a damage bonus
					int iCrits = GetEntProp(attacker, Prop_Send, "m_iRevengeCrits");
					if( iCrits ) {
						if( Call_OnBossTakeDamage_OnDiamondbackManmelterCrit(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
							damage = g_vsh2.m_hCvars.DiamondMelterBaseDmg.FloatValue;
						}
						return Plugin_Changed;
					}
				}
				/// Tickle Hoovy Fists.
				case 656: {
					SetPawnTimer(_StopTickle, g_vsh2.m_hCvars.StopTickleTime.FloatValue, victim.userid);
					if( TF2_IsPlayerInCondition(attacker, TFCond_Dazed) ) {
						TF2_RemoveCondition(attacker, TFCond_Dazed);
					}
					if( Call_OnBossTakeDamage_OnHolidayPunch(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) == Plugin_Changed ) {
						return Plugin_Changed;
					}
				}
			}
			
			/// Patch Nov 1, 2019: being in water fires air shot hook.
			int boss_flags = GetEntityFlags(victim.index);
			int grounded = boss_flags & FL_ONGROUND;
			int swimming = boss_flags & FL_INWATER;
			if( !grounded && !swimming && !StrContains(inflictor_name, "tf_projectile_", false) ) {
				static float ray_angle[] = { 90.0, 0.0, 0.0 };
				TR_TraceRayFilter(damagePosition, ray_angle, MASK_PLAYERSOLID_BRUSHONLY, RayType_Infinite, TraceRayIgnoreEnts);
				if( TR_DidHit() ) {
					float end_pos[3]; TR_GetEndPosition(end_pos);
					float air_shot_dist = g_vsh2.m_hCvars.AirShotDist.FloatValue;
					if( GetVectorDistance(damagePosition, end_pos, true) >= air_shot_dist*air_shot_dist ) {
						if( Call_OnBossAirShotProj(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) ) {
							return Plugin_Changed;
						}
					}
				}
			}
			/// everything else covered here.
			return Call_OnBossTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		}
	}
	return Plugin_Continue;
}

public Action ManageOnBossDealDamage(BasePlayer victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	BasePlayer fighter = BasePlayer(attacker);
	switch( fighter.iBossType ) {
		case -1: {}
		default: {
			victim.iHits++;
			victim.flLastHit = GetGameTime();
			
			int client = victim.index;
			if( damagecustom == TF_CUSTOM_BOOTS_STOMP ) {
				if( Call_OnBossDealDamage_OnStomp(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
					float flFallVelocity = GetEntPropFloat(inflictor, Prop_Send, "m_flFallVelocity");
					/// TF2 Fall Damage formula, modified for VSH2
					damage = 10.0 * (GetRandomFloat(0.8, 1.2) * (5.0 * (flFallVelocity / 300.0)));
				}
				return Plugin_Changed;
			}
			if( TF2_IsPlayerInCondition(client, TFCond_DefenseBuffed) ) {
				if( Call_OnBossDealDamage_OnHitDefBuff(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
					ScaleVector(damageForce, 9.0);
					damage *= g_vsh2.m_hCvars.OnHitBattalions.FloatValue;
				}
				return Plugin_Changed;
			}
			/*
			if( TF2_IsPlayerInCondition(client, TFCond_DefenseBuffMmmph) ) {
				damage *= 9;
				/// Patch: Nov 14, 2017 - removing post-bonk slowdown.
				TF2_AddCondition(client, TFCond_UberchargedOnTakeDamage, 0.1);
				return Plugin_Changed;
			}
			*/
			if( TF2_IsPlayerInCondition(client, TFCond_CritMmmph) ) {
				if( Call_OnBossDealDamage_OnHitCritMmmph(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
					damage *= g_vsh2.m_hCvars.OnHitPhlogTaunt.FloatValue;
					return Plugin_Changed;
				}
				return Plugin_Changed;
			}
			
			int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
			char mediclassname[32];
			if( IsValidEntity(medigun)
				&& GetEdictClassname(medigun, mediclassname, sizeof(mediclassname))
				&& !strcmp(mediclassname, "tf_weapon_medigun", false)
				&& !TF2_IsPlayerInCondition(client, TFCond_Ubercharged)
				&& weapon == GetPlayerWeaponSlot(attacker, TFWeaponSlot_Melee)) {
				/**
				 * If medic has (nearly) full uber, use it as a single-hit shield to prevent medics from dying early.
				 * Entire team is pretty much screwed if all the medics just die.
				 */
				if( Call_OnBossDealDamage_OnHitMedic(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
					/// TODO: add cvar for medic uber shield percentage needed.
					/// TODO IMPORTANT: Make Ubershield an ability
					if( g_vsh2.m_hCvars.MedicUberShield.BoolValue && GetMediGunCharge(medigun) >= 0.90 ) {
						SetMediCharge(medigun, 0.1);
						ScaleVector(damageForce, 9.0);
						damage *= 0.1;
						/// Patch: Nov 14, 2017 - removing post-bonk slowdown.
						//TF2_AddCondition(client, TFCond_UberchargedOnTakeDamage, 0.1);
						EmitSoundToAll("player/spy_shield_break.wav", client, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
						TF2_AddCondition(client, TFCond_SpeedBuffAlly, 5.0);
						return Plugin_Changed;
					}
				}
				return Plugin_Changed;
			}
			
			/// eggs probably do melee damage to spies, then? That's not ideal, but eh.
			if( victim.iTFClass == TFClass_Spy ) {
				if( GetEntProp(client, Prop_Send, "m_bFeignDeathReady") || TF2_IsPlayerInCondition(client, TFCond_Cloaked) ) {
					if( GetClientCloakIndex(client)==59 ) {
						if( Call_OnBossDealDamage_OnHitDeadRinger(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
							if( damagetype & DMG_CRIT ) {
								damagetype &= ~DMG_CRIT;
							}
							if( damagetype & (DMG_CLUB|DMG_SLASH) ) {
								damage = g_vsh2.m_hCvars.DeadRingerDamage.FloatValue / FindConVar("tf_feign_death_damage_scale").FloatValue;
							}
							return Plugin_Changed;
						}
						return Plugin_Changed;
					} else {
						if( Call_OnBossDealDamage_OnHitCloakedSpy(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
							if( damagetype & DMG_CRIT ) {
								damagetype &= ~DMG_CRIT;
							}
							if( damagetype & (DMG_CLUB|DMG_SLASH) ) {
								damage = g_vsh2.m_hCvars.CloakDamage.FloatValue / FindConVar("tf_stealth_damage_reduction").FloatValue;
							}
							return Plugin_Changed;
						}
						return Plugin_Changed;
					}
				}
			}
			
			int ent = GetShield(client, "tf_wearable_demo");
			if( ent != -1 && !TF2_IsPlayerInCondition(client, TFCond_Ubercharged)
				&& (weapon==GetPlayerWeaponSlot(attacker, TFWeaponSlot_Melee) || damage >= victim.iHealth+0.0) ) {
				/// FIXME: crit damage is calculated after this and can kill regardless of shield!
				if( Call_OnBossDealDamage_OnHitShield(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
					/// Patch: Nov 14, 2017 - removing post-bonk slowdown.
					TF2_AddCondition(client, TFCond_PasstimeInterception, 0.1);
					TF2_AddCondition(client, TFCond_SpeedBuffAlly, 1.0);
					TF2_RemoveWearable(client, ent);
					EmitSoundToAll("player/spy_shield_break.wav", client, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
					return Plugin_Continue;
				}
				return Plugin_Changed;
			}
			
			ent = GetShield(client, "tf_wearable_razor");
			if( ent != -1 && !TF2_IsPlayerInCondition(client, TFCond_Ubercharged)
				&& (weapon==GetPlayerWeaponSlot(attacker, TFWeaponSlot_Melee) || damage >= victim.iHealth+0.0) ) {
				if( Call_OnBossDealDamage_OnHitShield(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom) != Plugin_Changed ) {
					/// Patch: Nov 14, 2017 - removing post-bonk slowdown.
					TF2_AddCondition(client, TFCond_PasstimeInterception, 0.1);
					TF2_AddCondition(client, TFCond_SpeedBuffAlly, 1.0);
					TF2_RemoveWearable(client, ent);
					EmitSoundToAll("player/spy_shield_break.wav", client, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
					return Plugin_Continue;
				}
				return Plugin_Changed;
			}
			return Call_OnBossDealDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		}
	}
	return Plugin_Continue;
}

#if defined _goomba_included_
public Action ManageOnGoombaStomp(int attacker, int client, float& damageMultiplier, float& damageAdd, float& JumpPower) {
	BasePlayer boss = BasePlayer(client);
	/// Players Stomping the Boss
	if( boss.bIsBoss ) {
		switch( boss.iBossType ) {
			/// Ignore if not boss at all.
			case -1: {}
			/// Default behaviour for Goomba Stompoing the Boss
			default: {
				/// Prevent goomba stomp for mantreads/demo boots if being able to is disabled.
				if( IsValidEntity(FindPlayerBack(attacker, { 444, 405, 608 }, 3)) && !g_vsh2.m_hCvars.CanMantreadsGoomba.BoolValue ) {
					return Plugin_Handled;
				}
				damageAdd = float(g_vsh2.m_hCvars.GoombaDamageAdd.IntValue);
				damageMultiplier = g_vsh2.m_hCvars.GoombaLifeMultiplier.FloatValue;
				JumpPower = g_vsh2.m_hCvars.GoombaReboundPower.FloatValue;
				//PrintToChatAll("%N Just Goomba stomped %N(The Boss)!", attacker, client);
				CPrintToChatAllEx(attacker, "%t", "goomba_stomp", attacker, client);
				return Plugin_Changed;
			}
		}
		return Plugin_Continue;
	}
	
	boss = BasePlayer(attacker);
	/// The Boss(es) Stomping a player
	if( boss.bIsBoss ) {
		switch( boss.iBossType ) {
			/// Ignore if not boss at all.
			case -1: {}
			/// Default behaviour for the Boss Goomba Stomping other players.
			default: {
				/// Block the Boss from Goomba Stomping if disabled.
				if( !g_vsh2.m_hCvars.CanBossGoomba.BoolValue ) {
					return Plugin_Handled;
				}
				/// If the demo had a shield to break
				if( RemoveDemoShield(client) || RemoveRazorBack(client) ) {
					EmitSoundToAll("player/spy_shield_break.wav", client, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
					/// Patch: Nov 14, 2017 - removing post-bonk slowdown.
					TF2_AddCondition(client, TFCond_PasstimeInterception, 0.1);
					TF2_AddCondition(client, TFCond_SpeedBuffAlly, 1.0);
					damageAdd = 0.0;
					damageMultiplier = 0.0;
					//JumpPower = 0.0;
					return Plugin_Changed;
				}
				//PrintToChatAll("%N(The Boss) just got stomped by %N!", client, attacker);
			}
		}
		return Plugin_Continue;
	}
	return Plugin_Continue;
}
#endif

public void ManageBossKillPlayer(BasePlayer attacker, BasePlayer victim, Event event) {
	if( Call_OnPlayerKilled(attacker, victim, event) > Plugin_Changed ) {
		return;
	}
	//int dmgbits = event.GetInt("damagebits");
	int deathflags = event.GetInt("death_flags");
	
	/// If victim is a boss, kill him off
	if( victim.bIsBoss ) {
		RequestFrame(_BossDeath, victim.userid);
		//SetPawnTimer(_BossDeath, 0.1, victim.userid);
		attacker.iBossKills++;
	}
	if( attacker.bIsBoss ) {
		switch( attacker.iBossType ) {
			case VSH2Boss_Hale: {
				int melee = GetPlayerWeaponSlot(attacker.index, TFWeaponSlot_Melee);
				char melee_classname[64];
				if( GetEdictClassname(melee, melee_classname, sizeof(melee_classname)) && StrEqual(melee_classname, "tf_weapon_shovel") ) {
					event.SetString("weapon", "fists");
				}
			}
		}
		
		ConfigMap cfg = g_vsh2.GetPlayerCfg(attacker);
		int living_mercs = GetLivingPlayers(VSH2Team_Red);
		
		if( attacker.HasAbility(ABILITY_EXPLODE_AMMO) ) {
			ConfigMap ability = cfg.GetSection("abilities." ... ABILITY_EXPLODE_AMMO);
			int model_len = ability.GetIntKeySize(0);
			if( model_len > 1 ) {
				char[] model = new char[model_len + 1];
				ability.GetIntKey(0, model, model_len);
				SpawnManyAmmoPacks(victim.index, model, 1);
			}
			attacker.PlayRandVoiceClipFromCfg(ability.GetSection("sounds"), VSH2_VOICE_ABILITY);
		}
		
		/// for a sound on every kill.
		if( victim.index != attacker.index ) {
			bool played_random_sound = false;
			ConfigMap kill_sounds = cfg.GetSection("sounds.kill");
			ConfigMap all_or_rand = kill_sounds.GetSection("0");
			if( all_or_rand != null ) {
				ConfigMap random_sounds_sect = all_or_rand.GetSection("random");
				if( random_sounds_sect != null ) {
					/// allow a function for this?
					float rand_chance   = random_sounds_sect.CalcMath("math", VSH2MathVarsKillSounds, event);
					float needed_chance = random_sounds_sect.GetFloatEx("needed", -1.0);
					if( needed_chance >= rand_chance ) {
						ConfigMap random_sounds = random_sounds_sect.GetSection("sounds");
						attacker.PlayRandVoiceClipFromCfg(random_sounds, VSH2_VOICE_SPREE);
						played_random_sound = true;
					}
				} else {
					/// always section is optional.
					ConfigMap always_sounds = all_or_rand.GetSection("always");
					attacker.PlayRandVoiceClipFromCfg(always_sounds, VSH2_VOICE_SPREE);
				}
			}
			
			if( !played_random_sound ) {
				ConfigMap class_kill_snds_sect = kill_sounds.GetIntKeySection(view_as< int >(victim.iTFClass));
				attacker.PlayRandVoiceClipFromCfg(class_kill_snds_sect, VSH2_VOICE_SPREE);
			}
		}
		
		/// for a sound on killing spree.
		float currtime = GetGameTime();
		if( currtime <= attacker.flKillSpree ) {
			attacker.iKills++;
		} else {
			attacker.iKills = 0;
		}
		
		/// TODO: add cvars/config for killing spree amounts.
		if( attacker.iKills >= 3 && living_mercs > 1 ) {
			ConfigMap spree_sounds = cfg.GetSection("sounds.spree");
			attacker.PlayRandVoiceClipFromCfg(spree_sounds, VSH2_VOICE_SPREE);
			attacker.iKills = 0;
		} else {
			attacker.flKillSpree = currtime + 5.0;
		}
	}
}
public void VSH2MathVarsKillSounds(const char[] var_name, int var_name_len, float &f, any data) {
	Event event = data;
	BasePlayer victim  = BasePlayer( event.GetInt("userid"),   true );
	BasePlayer fighter = BasePlayer( event.GetInt("attacker"), true );
	
	int idx = 0;
	enum { UseVictim=1, UseAttacker, UseGameMode };
	int usage;
	if( StrStarts(var_name, "victim", false) ) {
		idx += strlen("victim");
		usage = UseVictim;
	} else if( StrStarts(var_name, "attacker", false) ) {
		idx += strlen("attacker");
		usage = UseAttacker;
	} else if( StrStarts(var_name, "gm", false) ) {
		idx += 2;
		usage = UseGameMode;
	}
	
	if( var_name[idx]=='_' ) {
		idx++;
	}
	
	any a;
	if(
		(usage==UseVictim   && victim.Props.GetValue(var_name[idx], a))
	 || (usage==UseAttacker && fighter.Props.GetValue(var_name[idx], a))
	 || (usage==UseGameMode && g_vshgm.GetValue(var_name[idx], a))
	) {
		if( var_name[idx]=='i' || var_name[idx]=='I' ) {
			f = float(view_as< int >(a));
			return;
		} else if( var_name[idx]=='f' || var_name[idx]=='F' ) {
			f = a;
			return;
		}
	}
	LogMessage("[VSH2] Math Parser Kill Sounds :: Warning **** Failed to find '%s' ****", var_name);
}

public void ManageHurtPlayer(BasePlayer attacker, BasePlayer victim, Event event) {
	if( Call_OnPlayerHurt(attacker, victim, event) > Plugin_Changed ) {
		return;
	}
	
	int damage = event.GetInt("damageamount");
	int custom = event.GetInt("custom");
	int weapon = event.GetInt("weaponid");
	if( victim.HasAbility(ABILITY_RAGE) ) {
		victim.GiveRage(damage);
	}
	
	/// Minions shouldn't have their damage tracked.
	if( attacker.bIsMinion ) {
		return;
	}
	
	/// Telefrags normally 1-shot the boss but let's cap damage at 9k
	if( custom==TF_CUSTOM_TELEFRAG ) {
		/// TODO: add cvar for max given damage for telefrags.
		damage = IsPlayerAlive(attacker.index)? 9001 : 1;
	}
	/// block off bosses from doing the rest of things but track their damage.
	attacker.iDamage += damage;
	if( attacker.bIsBoss ) {
		return;
	}
	
	if( !GetEntProp(attacker.index, Prop_Send, "m_bShieldEquipped")
		&& GetPlayerWeaponSlot(attacker.index, TFWeaponSlot_Secondary) <= 0
		&& attacker.iTFClass == TFClass_DemoMan ) {
		int iReqDmg = g_vsh2.m_hCvars.ShieldRegenDmgReq.IntValue;
		if( iReqDmg > 0 ) {
			attacker.iShieldDmg += damage;
			if( attacker.iShieldDmg >= iReqDmg ) {
				/// TODO: figure out a better way to regenerate shield.
				/// FIXME: replace with `CBasePlayer::EquipWearable`.
				/// save data so we can get our shield back.
				/// save health, heads, and weapon data.
				int client = attacker.index;
				int health = GetClientHealth(client);
				int heads;
				if( HasEntProp(client, Prop_Send, "m_iDecapitations") ) {
					heads = GetEntProp(client, Prop_Send, "m_iDecapitations");
				}
				int primammo = GetAmmo(client, TFWeaponSlot_Primary);
				int primclip = GetClip(client, TFWeaponSlot_Primary);
				TF2_RegeneratePlayer(client);
				SetEntityHealth(client, health);
				/// PATCH Sept 22, 2019: Demos that lost shield but changed loadouts during round retaining their heads...
				if( HasEntProp(client, Prop_Send, "m_iDecapitations") && heads > 0 ) {
					SetEntProp(client, Prop_Send, "m_iDecapitations", GetEntProp(client, Prop_Send, "m_bShieldEquipped")? heads : 0);
				}
				SetAmmo(client, TFWeaponSlot_Primary, primammo);
				SetClip(client, TFWeaponSlot_Primary, primclip);
				attacker.iShieldDmg = 0;
			}
		}
	}
	
	/// Compatibility patch for Randomizer
	if( GetIndexOfWeaponSlot(attacker.index, TFWeaponSlot_Primary) == 1104 ) {
		if( weapon==TF_WEAPON_ROCKETLAUNCHER ) {
			attacker.iAirDamage += damage;
		}
		int div = g_vsh2.m_hCvars.AirStrikeDamage.IntValue;
		SetEntProp(attacker.index, Prop_Send, "m_iDecapitations", attacker.iAirDamage / div);
	} else if( attacker.iTFClass==TFClass_Heavy && weapon==TF_WEAPON_SHOTGUN_HWG ) {
		/// Heavy Shotgun healing.
		int health = GetClientHealth(attacker.index);
		int maxhp = GetEntProp(attacker.index, Prop_Data, "m_iMaxHealth");
		int heavy_overheal = RoundFloat(FindConVar("tf_max_health_boost").FloatValue * maxhp);
		int health_from_dmg = (( health < maxhp )? (maxhp - health) : (heavy_overheal - health)) % damage;
		if( health_from_dmg==0 ) {
			health_from_dmg = damage >> view_as< int >(health > maxhp);
		}
		HealPlayer(attacker.index, health_from_dmg, true);
	}
	
	/// Medics now count as 3/5 of a backstab, similar to telefrag assists.
	int healers = GetEntProp(attacker.index, Prop_Send, "m_nNumHealers");
	int healercount;
	for( int i; i < healers; i++ ) {
		if( 0 < GetHealerByIndex(attacker.index, i) <= MaxClients ) {
			healercount++;
		}
	}
	
	for( int i; i < healers; i++ ) {
		BasePlayer medic = BasePlayer(GetHealerByIndex(attacker.index, i));
		if( 0 < medic.index <= MaxClients ) {
			if( damage < 10 || medic.iUberTarget==attacker.userid ) {
				medic.iDamage += damage;
			} else {
				medic.iDamage += damage / (healercount + 1);
			}
		}
	}
}

public void ManagePlayerAirblast(BasePlayer airblaster, BasePlayer airblasted, Event event) {
	if( Call_OnPlayerAirblasted(airblaster, airblasted, event) > Plugin_Changed ) {
		return;
	}
	
	int victim = airblasted.index;
	if( airblasted.HasAbility(ABILITY_POWER_UBER) && TF2_IsPlayerInCondition(victim, TFCond_Ubercharged) ) {
		float dur       = GetConditionDuration(victim, TFCond_Ubercharged);
		float max_dur   = g_vsh2.m_hCvars.VagineerUberTime.FloatValue;
		float increase  = g_vsh2.m_hCvars.VagineerUberAirBlast.FloatValue;
		float extra_dur = dur + increase;
		SetConditionDuration(victim, TFCond_Ubercharged, (extra_dur < max_dur)? extra_dur : max_dur);
		return;
	}
	if( airblasted.HasAbility(ABILITY_RAGE)
		&& (!airblasted.HasAbility(ABILITY_POWER_UBER) || !TF2_IsPlayerInCondition(victim, TFCond_Ubercharged)) ) {
		airblasted.flRAGE += g_vsh2.m_hCvars.AirblastRage.FloatValue;
	}
}

public Action ManageTraceHit(BasePlayer victim, BasePlayer attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup) {
	return Call_OnTraceAttack(victim, attacker, inflictor, damage, damagetype, ammotype, hitbox, hitgroup);
}
public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || !IsPlayerAlive(client) ) {
		return Plugin_Continue;
	}
	
	BasePlayer base = BasePlayer(client);
	if( base.HasAbility(ABILITY_AUTO_FIRE) && GetPlayerWeaponSlot(client, TFWeaponSlot_Primary)==GetActiveWep(client) ) {
		buttons &= ~IN_ATTACK;
		return Plugin_Changed;
	}
	
	switch( base.iBossType ) {
		case VSH2Boss_HHHjr: {
			if( base.flCharge >= 47.0 && (buttons & IN_ATTACK) ) {
				buttons &= ~IN_ATTACK;
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

public void TF2_OnConditionAdded(int client, TFCond condition) {
	BasePlayer player = BasePlayer(client);
	if( !player.bIsBoss ) {
		return;
	}
	
	bool remove;
	switch( condition ) {
		case TFCond_Disguised, TFCond_Jarated, TFCond_MarkedForDeath: {
			remove = true;
		}
	}
	
	bool removing = remove;
	if( Call_OnBossConditionChange(player, condition, removing, remove) <= Plugin_Changed && remove ) {
		TF2_RemoveCondition(client, condition);
	}
}

public void ManageBossMedicCall(BasePlayer base) {
	if( Call_OnBossMedicCall(base) > Plugin_Changed ) {
		return;
	}
	
	if( !base.HasAbility(ABILITY_RAGE) || base.flRAGE < 100.0 ) {
		return;
	}
	DoTaunt(base.index, "", 0);
	base.flRAGE = 0.0;
}
public void ManageBossTaunt(BasePlayer base) {
	if( Call_OnBossTaunt(base) > Plugin_Changed || !base.HasAbility(ABILITY_RAGE) ) {
		return;
	}
	
	int client    = base.index;
	int boss_type = base.iBossType;
	ConfigMap cfg = g_vsh2.GetPlayerCfg(base);
	if( VSH2Boss_Hale <= boss_type < MaxDefaultVSH2Bosses ) {
		TF2_AddCondition(client, TFCond_DefenseBuffNoCritBlock, 4.0);
		if( !GetEntProp(client, Prop_Send, "m_bIsReadyToHighFive")
		&& !IsValidEntity(GetEntPropEnt(client, Prop_Send, "m_hHighFivePartner")) ) {
			TF2_RemoveCondition(client, TFCond_Taunting);
			ManageBossModels(base);
		}
	}
	
	if( base.HasAbility(ABILITY_STUN_BUILDS) ) {
		ConfigMap ability_section = cfg.GetSection("abilities." ... ABILITY_STUN_BUILDS);
		float dist = ability_section.GetIntKeyFloatEx(0, 800.0);
		float time = ability_section.GetIntKeyFloatEx(1, 5.0);
		base.StunBuildings(dist, time);
	}
	if( base.HasAbility(ABILITY_STUN_PLYRS) ) {
		ConfigMap ability_section = cfg.GetSection("abilities." ... ABILITY_STUN_PLYRS);
		float dist = ability_section.GetIntKeyFloatEx(0, 800.0);
		float time = ability_section.GetIntKeyFloatEx(1, 5.0);
		base.StunPlayers(dist, time);
	}
	
	if( base.HasAbility(ABILITY_POWER_UBER) ) {
		ConfigMap ability_section = cfg.GetSection("abilities." ... ABILITY_POWER_UBER);
		float time = ability_section.GetIntKeyFloatEx(0, g_vsh2.m_hCvars.VagineerUberTime.FloatValue);
		TF2_AddCondition(client, TFCond_Ubercharged, time);
	}
	
	if( base.HasAbility(ABILITY_GET_WEP) ) {
		/*
		int bow = base.SpawnWeapon("tf_weapon_compound_bow", 1005, 100, 5, "2 ; 2.1; 6 ; 0.5; 37 ; 0.0; 280 ; 19; 551 ; 1");
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", bow); /// 266; 1.0 - penetration
		int living = GetLivingPlayers(VSH2Team_Red);
		SetWeaponAmmo(bow, ((living >= CBS_MAX_ARROWS)? CBS_MAX_ARROWS : living));
		*/
		ConfigMap ability_section = cfg.GetSection("abilities." ... ABILITY_GET_WEP);
		if( ability_section==null ) {
			return;
		}
		
		int num_weaps = ability_section.Size;
		for( int i; i < num_weaps && i <= TFWeaponSlot_Item2; i++ ) {
			ConfigMap weapon_sect = ability_section.GetIntKeySection(i);
			if( weapon_sect==null ) {
				continue;
			}
			
			int classname_len = weapon_sect.GetSize("classname");
			char[] wep_classname = new char[classname_len + 1];
			weapon_sect.Get("classname", wep_classname, classname_len);
			
			int index   = weapon_sect.GetIntEx("index",   -1);
			int level   = weapon_sect.GetIntEx("level",   -1);
			int quality = weapon_sect.GetIntEx("quality", -1);
			int ammo    = weapon_sect.GetIntEx("ammo",    -1);
			int clip    = weapon_sect.GetIntEx("clip",    -1);
			
			int attribs_len = weapon_sect.GetSize("attributes");
			char[] attribs = new char[attribs_len + 1];
			weapon_sect.Get("attributes", attribs, attribs_len);
			
			TF2_RemoveWeaponSlot(client, i);
			int boss_weap = base.SpawnWeapon(wep_classname, index, level, quality, attribs);
			SetEntPropEnt(base.index, Prop_Send, "m_hActiveWeapon", boss_weap);
			bool use_living_as_ammo = weapon_sect.GetBoolEx("use living for ammo", false);
			if( use_living_as_ammo ) {
				int living = GetLivingPlayers(VSH2Team_Red);
				int limit  = weapon_sect.GetIntEx("ammo limit for living", 0);
				SetWeaponAmmo(boss_weap, living >= limit? limit : living);
			} else {
				if( ammo > -1 ) {
					SetWeaponAmmo(boss_weap, ammo);
				}
				if( clip > -1 ) {
					SetWeaponClip(boss_weap, clip);
				}
			}
		}
	}
	
	ConfigMap ability_sounds_section = cfg.GetSection("abilities." ... ABILITY_RAGE ... ".sounds");
	base.PlayRandVoiceClipFromCfg(ability_sounds_section, VSH2_VOICE_RAGE);
	base.flRAGE = 0.0;
}

public void ManageBuildingDestroyed(BasePlayer base, int building, int objecttype, Event event) {
	if( Call_OnBossKillBuilding(base, building, event) > Plugin_Changed ) {
		return;
	}
	
	ConfigMap cfg = g_vsh2.GetPlayerCfg(base);
	ConfigMap kill_building_sounds = cfg.GetSection("sounds.kill building");
	base.PlayRandVoiceClipFromCfg(kill_building_sounds, VSH2_VOICE_SPREE);
	switch( base.iBossType ) {
		case VSH2Boss_Hale: {
			int melee = GetPlayerWeaponSlot(base.index, TFWeaponSlot_Melee);
			char melee_classname[64];
			if( GetEdictClassname(melee, melee_classname, sizeof(melee_classname)) && StrEqual(melee_classname, "tf_weapon_shovel") ) {
				event.SetString("weapon", "fists");
			}
		}
	}
}

public void ManagePlayerJarated(BasePlayer attacker, BasePlayer victim) {
	if( Call_OnBossJarated(victim, attacker) > Plugin_Changed || !victim.HasAbility(ABILITY_RAGE) ) {
		return;
	}
	victim.flRAGE -= g_vsh2.m_hCvars.JarateRage.FloatValue;
}

public Action HookSound(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || !IsClientValidExtra(entity) ) {
		return Plugin_Continue;
	}
	
	BasePlayer base = BasePlayer(entity);
	Action act = Call_OnSoundHook(base, sample, channel, volume, level, pitch, flags);
	if( act != Plugin_Continue ) {
		return act;
	}
	
	//int client = base.index;
	//int boss_type = base.iBossType;
	ConfigMap cfg = g_vsh2.GetPlayerCfg(base);
	ConfigMap vo_sounds = cfg.GetSection("sounds.vo");
	if( vo_sounds==null ) {
		return Plugin_Continue;
	}
	
	ConfigMap contains_sect = vo_sounds.GetSection("contains");
	if( contains_sect != null ) {
		int sect_size = contains_sect.Size;
		for( int i; i < sect_size; i++ ) {
			int key_len = contains_sect.GetKeySize(i);
			char[] key = new char[key_len + 1];
			contains_sect.GetKey(i, key, key_len);
			if( StrContains(sample, key, false) != -1 ) {
				switch( contains_sect.GetKeyValType(key) ) {
					case KeyValType_Value: {
						int sound_replace_len = contains_sect.GetSize(key);
						if( sound_replace_len <= 1 ) {
							return Plugin_Handled;
						}
						char[] replacement_sound = new char[sound_replace_len + 1];
						contains_sect.Get(key, replacement_sound, sound_replace_len);
						strcopy(sample, sizeof(sample), replacement_sound);
						return Plugin_Changed;
					}
					case KeyValType_Section: {
						ConfigMap sect = contains_sect.GetSection(key);
						if( sect==null || sect.Size <= 0 ) {
							return Plugin_Handled;
						}
						int selected = GetRandomInt(0, sect.Size-1);
						int sound_replace_len = sect.GetIntKeySize(selected);
						if( sound_replace_len <= 1 ) {
							return Plugin_Handled;
						}
						char[] replacement_sound = new char[sound_replace_len + 1];
						contains_sect.GetIntKey(selected, replacement_sound, sound_replace_len);
						strcopy(sample, sizeof(sample), replacement_sound);
						return Plugin_Changed;
					}
				}
			}
		}
	}
	
	ConfigMap prefix_sect = vo_sounds.GetSection("prefix");
	if( prefix_sect != null ) {
		int sect_size = prefix_sect.Size;
		for( int i; i < sect_size; i++ ) {
			int key_len = prefix_sect.GetKeySize(i);
			char[] key = new char[key_len + 1];
			prefix_sect.GetKey(i, key, key_len);
			if( !strncmp(sample, key, key_len, false) ) {
				switch( prefix_sect.GetKeyValType(key) ) {
					case KeyValType_Value: {
						int sound_replace_len = prefix_sect.GetSize(key);
						if( sound_replace_len <= 1 ) {
							return Plugin_Handled;
						}
						char[] replacement_sound = new char[sound_replace_len + 1];
						prefix_sect.Get(key, replacement_sound, sound_replace_len);
						strcopy(sample, sizeof(sample), replacement_sound);
						return Plugin_Changed;
					}
					case KeyValType_Section: {
						/// Allow for multiple sounds by allowing the sound to be a section.
						ConfigMap sect = prefix_sect.GetSection(key);
						if( sect==null || sect.Size <= 0 ) {
							return Plugin_Handled;
						}
						int selected = GetRandomInt(0, sect.Size-1);
						int sound_replace_len = sect.GetIntKeySize(selected);
						if( sound_replace_len <= 1 ) {
							return Plugin_Handled;
						}
						char[] replacement_sound = new char[sound_replace_len + 1];
						prefix_sect.GetIntKey(selected, replacement_sound, sound_replace_len);
						strcopy(sample, sizeof(sample), replacement_sound);
						return Plugin_Changed;
					}
				}
			}
		}
	}
	
	/*
	switch( base.iBossType ) {
		case -1: {}
		case VSH2Boss_Hale: {
			if( !strncmp(sample, "vo", 2, false) ) {
				return Plugin_Handled;
			}
		}
		case VSH2Boss_Vagineer: {
			if( StrContains(sample, "vo/engineer_laughlong01", false) != -1 ) {
				strcopy(sample, sizeof(sample), VagineerKSpree);
				return Plugin_Changed;
			} else if( !strncmp(sample, "vo", 2, false) ) {
				if( StrContains(sample, "positivevocalization01", false) != -1 ) {
					/// For backstab sound
					return Plugin_Continue;
				}
				if( StrContains(sample, "engineer_moveup", false) != -1 ) {
					Format(sample, sizeof(sample), "%s%i.wav", VagineerJump, GetRandomInt(1, 2));
				} else if( StrContains(sample, "engineer_no", false) != -1 || GetRandomInt(0, 9) > 6 ) {
					strcopy(sample, sizeof(sample), "vo/engineer_no01.mp3");
				} else {
					strcopy(sample, sizeof(sample), "vo/engineer_jeers02.mp3");
				}
				return Plugin_Changed;
			} else {
				return Plugin_Continue;
			}
		}
		case VSH2Boss_HHHjr: {
			if( !strncmp(sample, "vo", 2, false) ) {
				if( GetRandomInt(0, 30) <= 10 ) {
					Format(sample, sizeof(sample), "%s0%i.mp3", HHHLaught, GetRandomInt(1, 4));
					return Plugin_Changed;
				}
				if( StrContains(sample, "halloween_boss") == -1 ) {
					return Plugin_Handled;
				}
			}
		}
		case VSH2Boss_Bunny: {
			if( StrContains(sample, "gibberish", false) == -1 && StrContains(sample, "burp", false) == -1
				&& !GetRandomInt(0, 3) ) {
				/// Do sound things
				strcopy(sample, sizeof(sample), BunnyRandomVoice[GetRandomInt(0, sizeof(BunnyRandomVoice)-1)]);
				return Plugin_Changed;
			}
		}
	}
	*/
	return Plugin_Continue;
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool& result) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	}
	
	BasePlayer base = BasePlayer(client);
	if( IsWeaponSlotActive(client, TFWeaponSlot_Melee) && base.HasAbility(ABILITY_CLIMB_WALLS) ) {
		ConfigMap cfg = g_vsh2.GetPlayerCfg(base);
		ConfigMap climb_sect = cfg.GetSection("abilities." ... ABILITY_CLIMB_WALLS);
		int climb_limit = climb_sect.GetIntKeyIntEx(0, g_vsh2.m_hCvars.HHHMaxClimbs.IntValue);
		if( base.iClimbs < climb_limit ) {
			int boss_type = base.iBossType;
			float climb_vel;
			if( boss_type >= VSH2Boss_Hale ) {
				climb_vel = climb_sect.GetIntKeyFloatEx(1, g_vsh2.m_hCvars.HHHClimbVelocity.FloatValue);
			} else {
				climb_vel = climb_sect.GetIntKeyFloatEx(1, g_vsh2.m_hCvars.SniperClimbVelocity.FloatValue);
			}
			float climb_dmg = climb_sect.GetIntKeyFloatEx(2, (boss_type == -1)? g_vsh2.m_hCvars.SniperClimbDmg.FloatValue : 0.0);
			bool wep_cooldown = climb_sect.GetIntKeyBoolEx(3, true);
			
			base.ClimbWall(weapon, climb_vel, climb_dmg, wep_cooldown);
			if( base.HasAbility(ABILITY_WEIGHDOWN) ) {
				base.flWeighDown = 0.0;
			}
		}
	}
	/// Fuck random crits
	if( TF2_IsPlayerCritBuffed(client) ) {
		return Plugin_Continue;
	}
	if( base.bIsBoss ) {
		result = false;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public void ManageMessageIntro(BasePlayer[] bosses, int len) {
	if( g_vshgm.bDoors ) {
		int ent = -1;
		while( (ent = FindEntityByClassname(ent, "func_door")) != -1 ) {
			AcceptEntityInput(ent, "Open");
			AcceptEntityInput(ent, "Unlock");
		}
	}
	
	char intro_msg[MAXMESSAGE];
	for( int i=0; i < len; i++ ) {
		BasePlayer base = bosses[i];
		if( !base ) {
			continue;
		}
		char name[MAX_BOSS_NAME_SIZE], boss_msg[MAXMESSAGE];
		base.GetName(name);
		Format(boss_msg, sizeof boss_msg, "%T", "become_boss", i, base.index, name, base.iHealth);
		if( Call_OnMessageIntro(base, boss_msg) > Plugin_Changed ) {
			continue;
		}
		StrCat(intro_msg, MAXMESSAGE, boss_msg);
		StrCat(intro_msg, MAXMESSAGE, "\n");
	}
	SetHudTextParams(-1.0, 0.2, 10.0, 255, 255, 255, 255);
	for( int i=1; i<=MaxClients; i++ ) {
		if( !IsClientInGame(i) ) {
			continue;
		}
		ShowHudText(i, -1, "%s", intro_msg);
	}
	g_vshgm.iRoundState = StateRunning;
}

public void ManageBossPickUpItem(BasePlayer base, const char item[64]) {
	/// block Persian Persuader
	//if( GetIndexOfWeaponSlot(base.index, TFWeaponSlot_Melee) == 404 )
	//	return;
	Call_OnBossPickUpItem(base, item);
}

public void ManageResetVariables(BasePlayer base) {
	if( Call_OnVariablesReset(base) > Plugin_Changed ) {
		return;
	}
	base.iBossType     = -1;
	base.iStabbed      = 0;
	base.iMarketted    = 0;
	base.flRAGE        = 0.0;
	base.bIsMinion     = false;
	base.iDamage       = 0;
	base.iAirDamage    = 0;
	base.iUberTarget   = 0;
	base.flCharge      = 0.0;
	base.flGlowtime    = 0.0;
	base.bUsedUltimate = false;
	base.iOwnerBoss    = 0;
	base.iSongPick     = -1;
	SetEntityRenderColor(base.index, 255, 255, 255, 255);
	base.flLastShot    = 0.0;
	base.flLastHit     = 0.0;
	base.iState        = -1;
	base.iHits         = 0;
	base.iLives        = (g_vshgm.bMedieval || g_vsh2.m_hCvars.ForceLives.BoolValue)? g_vsh2.m_hCvars.MedievalLives.IntValue : 0;
	base.iMaxLives     = (g_vshgm.bMedieval || g_vsh2.m_hCvars.ForceLives.BoolValue)? g_vsh2.m_hCvars.MedievalLives.IntValue : 0;
	base.iMaxHealth    = 0;
	base.iShieldDmg    = 0;
	base.iClimbs       = 0;
	base.bSuperCharge  = false;
	base.bInJump       = false; /// PATCH: rocket jumping at end of round then respawning keeps this on true with perma-crit market gardener.
	base.RemoveAllAbilities();
}

public void ManageEntityCreated(int entity, const char[] classname) {
	if( StrContains(classname, "rune") != -1 ) {
		CreateTimer(0.1, RemoveEnt, EntIndexToEntRef(entity));
	} else if( StrEqual(classname, "tf_dropped_weapon") && !g_vsh2.m_hCvars.DroppedWeapons.BoolValue ) {
		/// Remove dropped weapons to avoid bad things
		AcceptEntityInput(entity, "kill");
	} else if( !strcmp(classname, "tf_projectile_cleaver", false) ) {
		SDKHook(entity, SDKHook_SpawnPost, OnCleaverSpawned);
	} else if( g_vshgm.iRoundState==StateRunning ) {
		if( !strcmp(classname, "tf_projectile_pipe", false) ) {
			SDKHook(entity, SDKHook_SpawnPost, OnEggBombSpawned);
		} else if( !strcmp(classname, "item_healthkit_medium", false) || !strcmp(classname, "item_healthkit_small", false) ) {
			int team = GetEntProp(entity, Prop_Send, "m_iTeamNum");
			if( team != VSH2Team_Red ) {
				SetEntProp(entity, Prop_Send, "m_iTeamNum", VSH2Team_Red, 4);
			}
		}
	}
}

public void OnEggBombSpawned(int entity) {
	int owner = GetOwner(entity);
	if( !IsClientValid(owner) ) {
		return;
	}
	
	BasePlayer boss = BasePlayer(owner);
	if( !boss.HasAbility(ABILITY_AUTO_FIRE) ) {
		return;
	}
	CreateTimer(0.0, Timer_SetEggBomb, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_SetEggBomb(Handle timer, any ref) {
	int entity = EntRefToEntIndex(ref);
	if( IsValidEntity(entity) ) {
		BasePlayer owner = BasePlayer(GetOwner(entity));
		ConfigMap cfg = g_vsh2.GetPlayerCfg(owner);
		ConfigMap spew_bombs_sect = cfg.GetSection("abilities." ... ABILITY_AUTO_FIRE);
		int model_str_len = spew_bombs_sect.GetIntKeySize(0);
		char[] model_str = new char[model_str_len + 1];
		spew_bombs_sect.GetIntKey(0, model_str, model_str_len);
		if( FileExists(model_str, true) && IsModelPrecached(model_str) ) {
			int att = AttachProjectileModel(entity, model_str);
			SetEntProp(att, Prop_Send, "m_nSkin", 0);
			SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
			SetEntityRenderColor(entity, 255, 255, 255, 0);
		}
	}
	return Plugin_Continue;
}

public void OnCleaverSpawned(int entity) {
	int client = GetThrower(entity);
	if( !IsClientValid(client) || TF2_GetPlayerClass(client) != TFClass_Spy ) {
		return;
	}
	/// TODO: use a cvar/cfg.
	char kunai_model[] = "models/weapons/c_models/c_shogun_kunai/c_shogun_kunai.mdl";
	PrecacheModel(kunai_model, true);
	SetEntityModel(entity, kunai_model);
	SetEntityGravity(entity, 10.0);
}

public void ManageUberDeploy(BasePlayer medic, BasePlayer patient) {
	int medic_client = medic.index;
	int medigun = GetPlayerWeaponSlot(medic_client, TFWeaponSlot_Secondary);
	if( !IsValidEntity(medigun) ) {
		return;
	}
	
	/// TODO IMPORTANT: Make the extended uber+kritz as an ability?
	char strMedigun[32]; GetEdictClassname(medigun, strMedigun, sizeof(strMedigun));
	if( !strcmp(strMedigun, "tf_weapon_medigun", false) ) {
		if( Call_OnUberDeployed(medic, patient) > Plugin_Changed ) {
			return;
		}
		SetMediCharge(medigun, g_vsh2.m_hCvars.UberDeployChargeAmnt.FloatValue);
		TF2_AddCondition(medic_client, TFCond_CritOnWin, 0.5, medic_client);
		
		int patient_client = patient.index;
		if( IsClientValid(patient_client) && IsPlayerAlive(patient_client) ) {
			TF2_AddCondition(patient_client, TFCond_CritOnWin, 0.5, medic_client);
			medic.iUberTarget = patient.userid;
		} else {
			medic.iUberTarget = 0;
		}
		CreateTimer(0.1, TimerUberLoop, EntIndexToEntRef(medigun), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void ManageMusic(char song[PLATFORM_MAX_PATH], float& time, float& vol) {
	/// UNFORTUNATELY, we have to get a random boss so we can set our music, tragic I know...
	/// Remember that you can get a random boss filtered by type as well!
	BasePlayer currBoss = VSHGameMode.GetRandomBoss(true);
	if( Call_OnMusic(song, time, currBoss, vol) > Plugin_Changed ) {
		return;
	}
	
	if( currBoss && song[0]=='\0' ) {
		time = -1.0;
		ConfigMap cfg = g_vsh2.GetPlayerCfg(currBoss);
		ConfigMap song_list = cfg.GetSection("sounds.music");
		if( song_list==null ) {
			return;
		}
		
		int num_songs = song_list.Size;
		if( num_songs <= 0 ) {
			return;
		}
		static int selection;
		selection = ShuffleIndex(num_songs, selection);
		song_list.GetKey(selection, song, sizeof(song));
		time = song_list.GetFloatEx(song, -1.0);
	}
}

public void StopBackGroundMusic() {
	if( g_vsh2.m_strCurrSong[0] != 0 ) {
		for( int i=1; i<=MaxClients; i++ ) {
			if( !IsClientValid(i) ) {
				continue;
			}
			BasePlayer(i).StopMusic();
		}
	}
}

public void ManageRoundEndBossInfo(BasePlayer[] bosses, int len, bool bossWon) {
	char round_end_msg[MAXMESSAGE];
	for( int i; i < len; i++ ) {
		BasePlayer base = bosses[i];
		if( !base ) {
			continue;
		}
		char name[MAX_BOSS_NAME_SIZE], boss_msg[MAXMESSAGE];
		base.GetName(name);
		Format(boss_msg, sizeof boss_msg, "%T", "health_left", i, name, base.index, base.iHealth, base.iMaxHealth);
		if( Call_OnRoundEndInfo(base, bossWon, boss_msg) > Plugin_Changed ) {
			continue;
		}
		StrCat(round_end_msg, MAXMESSAGE, boss_msg);
		StrCat(round_end_msg, MAXMESSAGE, "\n");
		if( bossWon ) {
			ConfigMap cfg = g_vsh2.GetPlayerCfg(base);
			ConfigMap win_sounds = cfg.GetSection("sounds.win");
			base.PlayRandVoiceClipFromCfg(win_sounds, VSH2_VOICE_WIN);
		}
		base.iDifficulty = 0;
	}
	if( round_end_msg[0] != '\0' ) {
		CPrintToChatAll("%T", "end_of_round", LANG_SERVER, round_end_msg);
		SetHudTextParams(-1.0, 0.2, 10.0, 255, 255, 255, 255);
		for( int i=1; i<=MaxClients; i++ ) {
			if( !IsClientValid(i) || (GetClientButtons(i) & IN_SCORE) ) {
				continue;
			}
			ShowHudText(i, -1, "%s", round_end_msg);
		}
	}
	
	/// If the config files were changed during the gameplay,
	/// allow them to be reloaded after.
	if( g_vsh2.m_hCfg.CfgFileChanged() ) {
		ReloadCfg(g_vsh2.m_hCfg);
	}
	for( int i; i < MaxDefaultVSH2Bosses; i++ ) {
		if( g_vsh2.m_hBossCfgs[i] != null && g_vsh2.m_hBossCfgs[i].CfgFileChanged() ) {
			ReloadCfg(g_vsh2.m_hBossCfgs[i]);
		}
	}
	for( int i; i < len; i++ ) {
		BasePlayer base = bosses[i];
		if( !base ) {
			continue;
		}
		
		ConfigMap cfg = base.hConfig;
		if( cfg != null && cfg.CfgFileChanged() ) {
			ReloadCfg(cfg);
			base.hConfig = cfg;
		}
	}
}

public void ManageLastPlayer() {
	BasePlayer currBoss = VSHGameMode.GetRandomBoss(true);
	BasePlayer[] reds = new BasePlayer[MaxClients];
	VSHGameMode.GetFighters(reds, true);
	if( Call_OnLastPlayer(currBoss, reds[0]) > Plugin_Changed ) {
		return;
	}
	
	ConfigMap cfg = g_vsh2.GetPlayerCfg(currBoss);
	ConfigMap last_guy = cfg.GetSection("sounds.last guy");
	currBoss.PlayRandVoiceClipFromCfg(last_guy, VSH2_VOICE_LASTGUY);
}

public void ManageBossCheckHealth(BasePlayer base) {
	static int LastBossTotalHealth;
	float currtime = GetGameTime();
	/// If a boss reveals their own health, only show that one boss' health.
	if( base.bIsBoss && IsPlayerAlive(base.index) ) {
		char health_check[MAXMESSAGE];
		if( Call_OnBossHealthCheck(base, true, health_check) > Plugin_Changed ) {
			return;
		}
		char name[MAX_BOSS_NAME_SIZE];
		base.GetName(name);
		PrintCenterTextAll("%t", "show_current_hp", name, base.iHealth, base.iMaxHealth);
		LastBossTotalHealth = base.iHealth;
	} else if( currtime >= g_vshgm.flHealthTime ) {
		/// If a non-boss is checking health, reveal all Boss' hp
		g_vshgm.iHealthChecks++;
		int totalHealth;
		char health_check[MAXMESSAGE];
		for( int i=1; i<=MaxClients; i++ ) {
			/// exclude dead bosses for health check
			if( !IsClientValidExtra(i) || !IsPlayerAlive(i) ) {
				continue;
			}
			
			BasePlayer boss = BasePlayer(i);
			if( !boss.bIsBoss ) {
				continue;
			}
			
			char name[MAX_BOSS_NAME_SIZE], boss_msg[MAXMESSAGE];
			boss.GetName(name);
			Format(boss_msg, sizeof boss_msg, "%T", "current_health", i, name, boss.iHealth, boss.iMaxHealth);
			if( Call_OnBossHealthCheck(boss, false, boss_msg) > Plugin_Changed ) {
				continue;
			}
			StrCat(health_check, MAXMESSAGE, boss_msg);
			StrCat(health_check, MAXMESSAGE, "\n");
			totalHealth += boss.iHealth;
		}
		PrintCenterTextAll(health_check);
		CPrintToChatAll("{olive}[VSH 2] {axis}%T", "boss_health_check", LANG_SERVER, health_check);
		LastBossTotalHealth = totalHealth;
		/// TODO: put cvars here?
		g_vshgm.flHealthTime = currtime + ((g_vshgm.iHealthChecks < 3)? 10.0 : 60.0);
	} else {
		CPrintToChat(base.index, "{olive}[VSH 2]{default} %t", "cannot_see_hp_now", RoundFloat(g_vshgm.flHealthTime-currtime), LastBossTotalHealth);
	}
}

public void CheckAlivePlayers(any nil) {
	if( g_vshgm.iRoundState != StateRunning ) {
		return;
	}
	
	int living = GetLivingPlayers(VSH2Team_Red);
	if( !living ) {
		g_vshgm.iRoundResult = RoundResBossWin;
		/// Put vsh2 event here `OnRedAllDead`?
		ForceTeamWin(VSH2Team_Boss);
	} else if( living==1 && VSHGameMode.CountBosses(true) > 0 && g_vshgm.iTimeLeft <= 0 ) {
		ManageLastPlayer(); /// in handler.sp
		g_vshgm.iTimeLeft = g_vsh2.m_hCvars.LastPlayerTime.IntValue;
		
		/// maybe some day...
		/*
		int round_timer = FindEntityByClassname(-1, "team_round_timer");
		if( round_timer <= 0 ) {
			round_timer = CreateEntityByName("team_round_timer");
		}
		
		if( IsValidEntity(round_timer) ) {
			SetVariantInt(g_vsh2.m_hCvars.LastPlayerTime.IntValue);
			//DispatchKeyValue(round_timer, "targetname", TIMER_NAME);
			//DispatchKeyValue(round_timer, "setup_length", setupLength);
			//DispatchKeyValue(round_timer, "setup_length", "30");
			DispatchKeyValue(round_timer, "reset_time", "1");
			DispatchKeyValue(round_timer, "auto_countdown", "1");
			char time[5];
			IntToString(g_vsh2.m_hCvars.LastPlayerTime.IntValue, time, sizeof(time));
			DispatchKeyValue(round_timer, "timer_length", time);
			DispatchSpawn(round_timer);
		}
		*/
		CreateTimer(1.0, Timer_DrawGame, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
	
	int enable_alive = g_vsh2.m_hCvars.AliveToEnable.IntValue;
	if( !g_vsh2.m_hCvars.PointType.BoolValue && living <= enable_alive && !g_vshgm.bPointReady ) {
		PrintHintTextToAll("%i players are left; control point enabled!", living);
		/// TODO: use main cfg for the countdown sounds?
		if( living==enable_alive ) {
			EmitSoundToAll("vo/announcer_am_capenabled02.mp3");
		} else if( living < enable_alive ) {
			char cap_incite_snd[][] = {
				"vo/announcer_am_capincite01.mp3",
				"vo/announcer_am_capincite03.mp3"
			};
			EmitSoundToAll(cap_incite_snd[GetRandomInt(0, 1)]);
		}
		SetControlPoint(true);
		g_vshgm.bPointReady = true;
	}
}

public void ManageOnBossCap(char sCappers[MAXPLAYERS+1], int capping_team, BasePlayer[] cappers, int capper_count) {
	Call_OnControlPointCapped(sCappers, capping_team, cappers, capper_count);
}

public void _SkipBossPanel() {
	BasePlayer[] upnext = new BasePlayer[MaxClients];
	VSHGameMode.GetQueue(upnext);
	/// TODO: cvar for who is up next to become the boss.
	for( int j; j < 3; j++ ) {
		if( !upnext[j] ) {
			continue;
		}
		/// If up next to become a boss.
		int player = upnext[j].index;
		if( !j ) {
			SkipBossPanelNotify(player);
		} else if( !IsFakeClient(player) ) {
			CPrintToChat(player, "{olive}[VSH 2]{default} %t", "be_boss_soon");
		}
	}
}

public void PrepPlayers(BasePlayer player) {
	int client = player.index;
	if( g_vshgm.iRoundState==StateEnding || !IsClientValidExtra(client) || !IsPlayerAlive(client) || player.bIsBoss ) {
		return;
	}
#if defined _tf2attributes_included
	if( g_vshgm.bTF2Attribs )
		TF2Attrib_RemoveAll(client);
#endif
	if( Call_OnPrepRedTeam(player) > Plugin_Changed ) {
		return;
	}
	/// Added fix by Chdata to correct team colors
	int player_team = GetClientTeam(client);
	if( player_team > VSH2Team_Spectator && player_team != VSH2Team_Red ) {
		player.ForceTeamChange(VSH2Team_Red);
		TF2_RegeneratePlayer(client);
	}
	TF2_RegeneratePlayer(client);
	SetEntityHealth(client, GetEntProp(client, Prop_Data, "m_iMaxHealth"));
	if( !GetRandomInt(0, 1) ) {
		player.HelpPanelClass();
	}
#if defined _tf2attributes_included
	/// Fixes mantreads to have jump height again
	if( g_vshgm.bTF2Attribs ) {
		/// Patch: Equipping mantreads then equipping gunboats allows you to keep the push force increase.
		TF2Attrib_RemoveByDefIndex(client, 58);
		int mantreads_entity = FindPlayerBack(client, { 444 }, 1);
		if( IsValidEntity(mantreads_entity) ) {
			/// "self dmg push force increased"
			TF2Attrib_SetByDefIndex(client, 58, 1.8);
		}
	}
#endif
	ConfigMap replacer = g_vsh2.m_hCfg.GetSection("weapon overrides.replace");
	if( replacer != null ) {
		int entries = replacer.Size;
		for( int i; i < entries; i++ ) {
			ConfigMap entry_sect = replacer.GetIntKeySection(i);
			if( entry_sect != null ) {
				int classes_len = entry_sect.GetSize("classes");
				char[] classes = new char[classes_len];
				entry_sect.Get("classes", classes, classes_len);
				/// First we check if a class requirement is set.
				if( classes[0] != '0' ) {
					char class_strs[10][10];
					int class_count = ExplodeString(classes, ", ", class_strs, 10, 10);
					bool correct_class;
					TFClassType tfclass = player.iTFClass;
					for( int n; n < class_count; n++ ) {
						TFClassType class_type = view_as< TFClassType >(StringToInt(class_strs[n]));
						if( tfclass==class_type ) {
							correct_class = true;
							break;
						}
					}
					if( !correct_class ) {
						continue;
					}
				}
				int indices_len = entry_sect.GetSize("indices");
				char[] indices = new char[indices_len];
				entry_sect.Get("indices", indices, indices_len);
				char index_strs[20][10];
				int index_count = ExplodeString(indices, ", ", index_strs, 20, 10);
				int[] indexes = new int[index_count];
				for( int n; n < index_count; n++ ) {
					indexes[n] = StringToInt(index_strs[n]);
				}
				/// O(n^2)...
				for( int slot=TFWeaponSlot_Primary; slot <= TFWeaponSlot_Item2; slot++ ) {
					int weapon = GetPlayerWeaponSlot(client, slot);
					int index  = GetItemIndex(weapon);
					for( int n; n < index_count; n++ ) {
						if( index==indexes[n] ) {
							int classname_len = entry_sect.GetSize("classname");
							char[] wep_classname = new char[classname_len];
							entry_sect.Get("classname", wep_classname, classname_len);
							int desired_index, desired_level, desired_quality, desired_ammo;
							entry_sect.GetInt("index", desired_index);
							entry_sect.GetInt("level", desired_level);
							entry_sect.GetInt("quality", desired_quality);
							
							int attribs_len = entry_sect.GetSize("attribs");
							char[] attribs  = new char[attribs_len];
							entry_sect.Get("attribs", attribs, attribs_len);
							entry_sect.GetInt("ammo", desired_ammo);
							TF2_RemoveWeaponSlot(client, slot);
							if( desired_index == -1 ) {
								desired_index = index;
							}
							
							weapon = player.SpawnWeapon(wep_classname, desired_index, desired_level, desired_quality, attribs);
							if( desired_ammo > 0 ) {
								SetWeaponAmmo(weapon, desired_ammo);
							}
						}
					}
				}
			}
		}
	}
	
	/// TODO IMPORTANT: rework mediguns to have more variety instead of making them all into one kind.
	/// perhaps make these as player abilities?
	TFClassType tfclass = player.iTFClass;
	switch( tfclass ) {
		case TFClass_Medic: {
			int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
			/// 200; 1 for area of effect healing, 178; 0.75 Faster switch-to, 14; 0.0 perm overheal, 11; 1.25 Higher overheal
			float start_uber = g_vsh2.m_hCvars.StartUberChargeAmnt.FloatValue;
			if( GetMediGunCharge(weapon) != start_uber ) {
				SetMediCharge(weapon, start_uber);
			}
		}
	}
#if defined _tf2attributes_included
	if( g_vshgm.bTF2Attribs && g_vsh2.m_hCvars.HealthRegenForPlayers.BoolValue ) {
		int max_health = GetEntProp(client, Prop_Data, "m_iMaxHealth");
		TF2Attrib_SetByDefIndex(client, 57, max_health * 0.02 + g_vsh2.m_hCvars.HealthRegenAmount.FloatValue);
	}
#endif
}

public Action TF2Items_OnGiveNamedItem(int client, char[] classname, int iItemDefinitionIndex, Handle &hItem) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	}
	BasePlayer player = BasePlayer(client);
	TF2Item hItemOverride = null;
	TF2Item hItemCast = view_as< TF2Item >(hItem);
	char override_keys[][] = {
		"weapon overrides.preserve",
		"weapon overrides.override"
	};
	
	for( int i; i < sizeof(override_keys); i++ ) {
		bool second = i==1;
		ConfigMap override_map = g_vsh2.m_hCfg.GetSection(override_keys[i]);
		if( override_map != null ) {
			char itemdef_path[15]; IntToString(iItemDefinitionIndex, itemdef_path, sizeof itemdef_path);
			KeyValType kvt = override_map.GetKeyValType(itemdef_path);
			switch( kvt ) {
				case KeyValType_Value: {
					int attribs_len = override_map.GetSize(itemdef_path);
					if( attribs_len > 0 ) {
						char[] attribs = new char[attribs_len];
						override_map.Get(itemdef_path, attribs, attribs_len);
						hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, attribs, second);
					}
				}
				case KeyValType_Section: {
					/// check if the player's class number exists in the section.
					/// otherwise, check for 0 as the all-class number.
					ConfigMap index_sect = override_map.GetSection(itemdef_path);
					int class_type = view_as< int >(player.iTFClass);
					int attribs_len = index_sect.GetIntKeySize(class_type);
					if( attribs_len > 0 ) {
						char[] attribs = new char[attribs_len];
						index_sect.GetIntKey(class_type, attribs, attribs_len);
						hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, attribs, second);
					} else if( (attribs_len = index_sect.GetIntKeySize(0)) > 0 ) {
						char[] attribs = new char[attribs_len];
						index_sect.GetIntKey(0, attribs, attribs_len);
						hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, attribs, second);
					}
				}
			}
		}
	}
	
	if( hItemOverride != null ) {
		Action act = Call_OnItemOverride(player, classname, iItemDefinitionIndex, view_as< Handle >(hItemOverride));
		if( act > Plugin_Changed ) {
			return Plugin_Continue;
		}
		hItem = view_as< Handle >(hItemOverride);
		return Plugin_Changed;
	}
	
	char classname_keys[][] = {
		"weapon overrides.classname preserve",
		"weapon overrides.classname override"
	};
	
	for( int i; i < sizeof(classname_keys); i++ ) {
		bool second = i==1;
		ConfigMap override_map = g_vsh2.m_hCfg.GetSection(classname_keys[i]);
		if( override_map != null ) {
			KeyValType kvt = override_map.GetKeyValType(classname);
			switch( kvt ) {
				case KeyValType_Value: {
					int attribs_len = override_map.GetSize(classname);
					if( attribs_len > 0 ) {
						char[] attribs = new char[attribs_len];
						override_map.Get(classname, attribs, attribs_len);
						hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, attribs, second);
					}
				}
				case KeyValType_Section: {
					ConfigMap clsname_sect = override_map.GetSection(classname);
					int class_type = view_as< int >(player.iTFClass);
					int attribs_len = clsname_sect.GetIntKeySize(class_type);
					if( attribs_len > 0 ) {
						char[] attribs = new char[attribs_len];
						clsname_sect.GetIntKey(class_type, attribs, attribs_len);
						hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, attribs, second);
					} else if( (attribs_len = clsname_sect.GetIntKeySize(0)) > 0 ) {
						char[] attribs = new char[attribs_len];
						clsname_sect.GetIntKey(0, attribs, attribs_len);
						hItemOverride = TF2Item_PrepareItemHandle(hItemCast, _, _, attribs, second);
					}
				}
			}
		}
	}
	
	if( hItemOverride != null ) {
		Action act = Call_OnItemOverride(player, classname, iItemDefinitionIndex, view_as< Handle >(hItemOverride));
		if( act > Plugin_Changed ) {
			return Plugin_Continue;
		}
		hItem = view_as< Handle >(hItemOverride);
		return Plugin_Changed;
	}
	return Call_OnItemOverride(player, classname, iItemDefinitionIndex, hItem);
}

public void ManageFighterCrits(BasePlayer fighter) {
	int i = fighter.index;
	TFClassType tfclass = fighter.iTFClass;
	char wepclassname[64];
	int weapon = GetActiveWep(i);
	bool validwep = (weapon != -1 && IsValidEntity(weapon));
	if( validwep ) {
		GetEdictClassname(weapon, wepclassname, sizeof(wepclassname));
	}
	
	if( !TF2_IsPlayerInCondition(i, TFCond_Cloaked) ) {
		switch( GetLivingPlayers(VSH2Team_Red) ) {
			case 1: {
				TF2_AddCondition(i, TFCond_CritOnWin, 0.2);
				TF2_AddCondition(i, TFCond_Buffed,    0.2);
				int primary = GetPlayerWeaponSlot(i, TFWeaponSlot_Primary);
				if( tfclass==TFClass_Engineer && weapon==primary && StrEqual(wepclassname, "tf_weapon_sentry_revenge", false) ) {
					SetEntProp(i, Prop_Send, "m_iRevengeCrits", 3);
				}
				return;
			}
			case 2: {
				TF2_AddCondition(i, TFCond_Buffed, 0.2);
			}
		}
	}
	
	
	/// Crit Flags logic.
	/// the event OnRedPlayerCrits is called only once but specific depending on certain cases.
	int crit_flags = 0;
	if( TF2_IsPlayerInCondition(i, TFCond_CritCola) && (tfclass==TFClass_Scout || tfclass==TFClass_Heavy) ) {
		crit_flags = CRITFLAG_FULL;
		Action act = Call_OnRedPlayerCrits(fighter, crit_flags);
		if( act <= Plugin_Changed ) {
			TF2_AddCondition(i, TFCond_CritOnWin, 0.2);
		}
		return;
	}
	
	int healers = GetEntProp(i, Prop_Send, "m_nNumHealers");
	for( int u; u < healers; u++ ) {
		if( 0 < GetHealerByIndex(i, u) <= MaxClients ) {
			crit_flags |= CRITFLAG_STACK;
			break;
		}
	}
	
	if( validwep ) {
		switch( GetSlotFromWeapon(i, weapon) ) {
			case TFWeaponSlot_Melee: {
				/// slightly longer check but makes sure that any weapon that can backstab will not crit (e.g. Saxxy)
				crit_flags |= view_as< int >(!!strcmp(wepclassname, "tf_weapon_knife", false)) << 1;
			}
			case TFWeaponSlot_Primary: {
				bool is_wep_class = (
					StrStarts(wepclassname, "tf_weapon_compound_bow") /// Sniper bows
					|| StrStarts(wepclassname, "tf_weapon_crossbow") /// Medic crossbows
					|| StrEqual(wepclassname,  "tf_weapon_shotgun_building_rescue") /// Engineer Rescue Ranger
					|| StrEqual(wepclassname,  "tf_weapon_drg_pomson") /// Engie Laser Shotty.
				);
				crit_flags |= view_as< int >(is_wep_class) << 1;
			}
			case TFWeaponSlot_Secondary: {
				if( StrStarts(wepclassname, "tf_weapon_pistol") /// Engineer/Scout pistols
					|| StrStarts(wepclassname, "tf_weapon_handgun_scout_secondary") /// Scout pistols
					|| StrStarts(wepclassname, "tf_weapon_flaregun")  /// Flare guns
					|| StrStarts(wepclassname, "tf_weapon_smg") /// Sniper SMGs minus Cleaner's Carbine
				) {
					int PrimaryIndex = GetIndexOfWeaponSlot(i, TFWeaponSlot_Primary);
					/// No crits if using Phlogistinator or Cozy Camper
					if( (tfclass==TFClass_Pyro && PrimaryIndex==594) || IsValidEntity(FindPlayerBack(i, { 642 }, 1)) ) {
						crit_flags &= ~CRITFLAG_FULL;
					} else {
						crit_flags |= CRITFLAG_FULL;
					}
					if( tfclass==TFClass_Scout ) {
						crit_flags = CRITFLAG_MINI;
					}
				}
				/// Jarate/Milk + Flying Guillotine
				crit_flags |= view_as< int >((StrStarts(wepclassname, "tf_weapon_jar") || StrEqual(wepclassname, "tf_weapon_cleaver"))) << 1;
			}
		}
	}
	
	/// Specific weapon crit list
	switch( GetItemIndex(weapon) ) {
		/// Holiday Punch, Short Circuit
		case 656, 528: {
			crit_flags = CRITFLAG_MINI;
		}
		/// Market Gardener
		case 416: {
			crit_flags = 0;
		}
	}
	
	/// Demo Man shield crits code.
	if( tfclass==TFClass_DemoMan && !IsValidEntity(GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary))
		&& GetSlotFromWeapon(i, weapon) != TFWeaponSlot_Melee
	) {
		switch( g_vsh2.m_hCvars.DemoShieldCrits.IntValue ) {
			case 0: {
				crit_flags = 0;
			}
			case 1: {
				crit_flags = CRITFLAG_MINI;
			}
			case 2: {
				crit_flags = CRITFLAG_FULL;
			}
			case 3: {
				float shield_meter = GetEntPropFloat(i, Prop_Send, "m_flChargeMeter");
				if( shield_meter==100.0 ) {
					crit_flags = CRITFLAG_FULL;
				} else if( 35.0 < shield_meter < 100.0 ) {
					crit_flags = CRITFLAG_MINI;
				} else {
					crit_flags = 0;
				}
				crit_flags *= GetEntProp(i, Prop_Send, "m_bShieldEquipped");
			}
		}
	}
	
	/// overheal cond does nothing.
	Action act = Call_OnRedPlayerCrits(fighter, crit_flags);
	if( act > Plugin_Changed ) {
		return;
	}
	
	if( crit_flags & CRITFLAG_MINI ) {
		TF2_AddCondition(i, TFCond_Buffed, 0.2);
	}
	if( crit_flags & CRITFLAG_FULL ) {
		if( crit_flags & CRITFLAG_STACK ) {
			TF2_AddCondition(i, TFCond_Buffed, 0.2);
		}
		TF2_AddCondition(i, TFCond_CritOnWin, 0.2);
	}
	
	switch( tfclass ) {
		case TFClass_Spy: {
			/// If Spies are cloaked or disguised, make sure they're not showing crit FX.
			if( validwep && weapon == GetPlayerWeaponSlot(i, TFWeaponSlot_Primary) ) {
				if( !TF2_IsPlayerCritBuffed(i)
					&& !TF2_IsPlayerInCondition(i, TFCond_Buffed)
					&& !TF2_IsPlayerInCondition(i, TFCond_Cloaked)
					&& !TF2_IsPlayerInCondition(i, TFCond_Disguised)
					&& !GetEntProp(i, Prop_Send, "m_bFeignDeathReady")
				) {
					TF2_AddCondition(i, TFCond_CritCola, 0.2);
				}
			}
		}
		case TFClass_Engineer: {
			/// Frontier Justice revenge-crits code.
			if( weapon==GetPlayerWeaponSlot(i, TFWeaponSlot_Primary) && StrEqual(wepclassname, "tf_weapon_sentry_revenge", false) ) {
				int sentry = FindSentry(i);
				if( IsValidEntity(sentry) ) {
					/// Trying to target minions as well
					int enemy = GetEntPropEnt(sentry, Prop_Send, "m_hEnemy");
					if( enemy > 0 && GetClientTeam(enemy)==VSH2Team_Boss ) {
						/// TODO: Add cvar for Engie's given revenge crits.
						SetEntProp(i, Prop_Send, "m_iRevengeCrits", 3);
						TF2_AddCondition(i, TFCond_Kritzkrieged, 0.2);
					} else {
						if( HasEntProp(i, Prop_Send, "m_iRevengeCrits") ) {
							SetEntProp(i, Prop_Send, "m_iRevengeCrits", 0);
						} else if( TF2_IsPlayerInCondition(i, TFCond_Kritzkrieged) && !TF2_IsPlayerInCondition(i, TFCond_Healing) ) {
							TF2_RemoveCondition(i, TFCond_Kritzkrieged);
						}
					}
				}
			}
		}
	}
}

public void ManageFighterHUD(BasePlayer fighter) {
	int i = fighter.index;
	
	/// HUD code
	char HUDText[PLAYER_HUD_SIZE];
	Format(HUDText, sizeof(HUDText), "%T", "hud_damage", i, fighter.iDamage);
	if( !IsPlayerAlive(i) ) {
		int obstarget = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
		if( IsClientValidExtra(obstarget) && GetClientTeam(obstarget) != VSH2Team_Boss && obstarget != i ) {
			BasePlayer observ = BasePlayer(obstarget);
			Format(HUDText, sizeof(HUDText), "%T", "hud_others_damage", i, HUDText, obstarget, observ.iDamage);
		}
	} else if( g_vshgm.bMedieval || g_vsh2.m_hCvars.ForceLives.BoolValue ) {
		Format(HUDText, sizeof(HUDText), "%T", "hud_lives", i, HUDText, fighter.iLives);
	}
	
	TFClassType tfclass = fighter.iTFClass;
	char wepclassname[64];
	int weapon = GetActiveWep(i);
	bool validwep = weapon != -1 && IsValidEntity(weapon);
	if( validwep ) {
		GetEdictClassname(weapon, wepclassname, sizeof(wepclassname));
	}
	switch( tfclass ) {
		/// Chdata's Deadringer Notifier
		case TFClass_Spy: {
			if( GetClientCloakIndex(i)==59 ) {
				char status_str[32];
				switch( GetDeadRingerStatus(i) ) {
					case 1:  Format(status_str, sizeof(status_str), "%T", "dead_ringer_ready",    i);
					case 2:  Format(status_str, sizeof(status_str), "%T", "dead_ringer_active",   i);
					default: Format(status_str, sizeof(status_str), "%T", "dead_ringer_inactive", i);
				}
				Format(HUDText, sizeof(HUDText), "%s\n%s", HUDText, status_str);
			}
			int spy_secondary = GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary);
			if( IsValidEntity(spy_secondary) ) {
				Format(HUDText, sizeof(HUDText), "%T", GetWeaponAmmo(spy_secondary)? "kunai_ready" : "kunai_none", i, HUDText);
			}
		}
		case TFClass_Medic: {
			int medigun = GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary);
			if( IsValidEntity(medigun) ) {
				char mediclassname[32]; GetEdictClassname(medigun, mediclassname, sizeof(mediclassname));
				if( !strcmp(mediclassname, "tf_weapon_medigun", false) ) {
					float charge_level = GetMediGunCharge(medigun);
					int charge = RoundToFloor(charge_level * 100);
					Format(HUDText, sizeof(HUDText), "%s\nUbercharge: %i%%", HUDText, charge);
					
					/// Fixes Ubercharges ending prematurely on Medics.
					if( GetEntProp(medigun, Prop_Send, "m_bChargeRelease") && charge_level > 0.0 && GetActiveWep(i)==medigun ) {
						TF2_AddCondition(i, TFCond_Ubercharged, 1.0);
					}
				}
			}
		}
		case TFClass_Soldier: {
			if( GetIndexOfWeaponSlot(i, TFWeaponSlot_Primary)==1104 ) {
				Format(HUDText, sizeof(HUDText), "%s\n%T", HUDText, "air_strike_damage", i, fighter.iAirDamage);
			}
		}
		case TFClass_DemoMan: {
			int shield = GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary);
			if( shield <= 0 ) {
				int has_shield = GetEntProp(i, Prop_Send, "m_bShieldEquipped");
				Format(HUDText, sizeof(HUDText), "%s\n%T", HUDText, has_shield? "shield_active" : "shield_gone", i);
			}
		}
	}
	
	Format(HUDText, sizeof(HUDText), "%s\n", HUDText);
	SetUpHUDForAbilities(fighter, HUDText);
	if( Call_OnRedPlayerHUD(fighter, HUDText) > Plugin_Changed ) {
		return;
	}
	
	if( !(GetClientButtons(i) & IN_SCORE) ) {
		SetHudTextParams(-1.0, 0.88, 0.35, 90, 255, 90, 255, 0, 0.35, 0.0, 0.1);
		ShowSyncHudText(i, g_vsh2.m_hHUDs[PlayerHUD], HUDText);
	}
}

/// too many temp funcs just to call as a timer. No wonder sourcepawn needs lambda funcs...
public void _RespawnPlayer(int userid) {
	if( g_vshgm.iRoundState==StateRunning ) {
		TF2_RespawnPlayer(GetClientOfUserId(userid));
	}
}

/**
 * `pl_` prefix for player   properties, if available.
 * `gm_` prefix for gamemode properties.
 */
public void VSH2MathVars(const char[] var_name, int var_name_len, float &f, any data) {
	BasePlayer p = data;
	int idx = 0;
	enum { UsePlayer=1, UseGameMode };
	int usage;
	if( StrStarts(var_name, "pl", false) ) {
		idx += 2;
		usage = UsePlayer;
	} else if( StrStarts(var_name, "gm", false) ) {
		idx += 2;
		usage = UseGameMode;
	}
	
	if( var_name[idx]=='_' ) {
		idx++;
	}
	
	any a;
	if(
		(usage==UsePlayer   && p.Props.GetValue(var_name[idx], a))
	 || (usage==UseGameMode && g_vshgm.GetValue(var_name[idx], a))
	) {
		if( var_name[idx]=='i' || var_name[idx]=='I' ) {
			f = float(view_as< int >(a));
			return;
		} else if( var_name[idx]=='f' || var_name[idx]=='F' ) {
			f = a;
			return;
		}
	}
	LogMessage("[VSH2] Math Parser :: Warning **** Failed to find '%s' ****", var_name);
}