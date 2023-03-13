static bool _RoundEndInfo_OverrideMessage = false;

void InitVSH2Bridge()
{
	char pack[48];
	ff2.m_cvars.m_pack_name.GetString(pack, sizeof(pack));

	ff2_cfgmgr = new FF2BossManager(pack);

	VSH2_Hook(OnCallDownloads,						OnCallDownloadsFF2);
	VSH2_Hook(OnBossMenu,							OnBossMenuFF2);
	VSH2_Hook(OnBossCalcHealth,						OnBossCalcHealthFF2);
	VSH2_Hook(OnBossSelected,						OnBossSelectedFF2);
	VSH2_Hook(OnRedPlayerThink,						OnRedPlayerThinkFF2);
	VSH2_Hook(OnBossThink,							OnBossThinkFF2);
	VSH2_Hook(OnBossSuperJump,						OnBossSuperJumpFF2);
	VSH2_Hook(OnBossWeighDown,						OnBossWeighDownFF2);
	VSH2_Hook(OnBossModelTimer,						OnBossModelTimerFF2);
	VSH2_Hook(OnBossEquipped,						OnBossEquippedFF2);
	VSH2_Hook(OnBossInitialized,					OnBossInitializedFF2);
	VSH2_Hook(OnBossKillBuilding,					OnBossKillBuildingFF2);
	VSH2_Hook(OnBossPlayIntro,						OnBossPlayIntroFF2);
	VSH2_Hook(OnPlayerKilled,						OnPlayerKilledFF2);
	VSH2_Hook(OnPlayerAirblasted,					OnPlayerAirblastedFF2);
	VSH2_Hook(OnBossMedicCall,						OnBossTriggerRageFF2);
	VSH2_Hook(OnBossTaunt,							OnBossTriggerRageFF2);
	VSH2_Hook(OnBossJarated,						OnBossJaratedFF2);
	VSH2_Hook(OnRoundStart,							OnRoundStartFF2);
	VSH2_Hook(OnRoundEndInfo,						OnRoundEndInfoFF2);
	VSH2_Hook(OnMusic,								OnMusicFF2);
	VSH2_Hook(OnBossDeath,							OnBossDeathFF2);
	HookEvent("player_hurt", 						OnPlayerHurtFF2);
	VSH2_Hook(OnBossTakeDamage_OnTriggerHurt,		OnBossTriggerHurtFF2);
	VSH2_Hook(OnBossTakeDamage_OnMarketGardened, 	OnMarketGardenedFF2);
	VSH2_Hook(OnBossTakeDamage_OnStabbed,			OnStabbedFF2);
	VSH2_Hook(OnLastPlayer,							OnLastPlayerFF2);
	VSH2_Hook(OnSoundHook,							OnSoundHookFF2);
	VSH2_Hook(OnScoreTally,							OnScoreTallyFF2);
	VSH2_Hook(OnVariablesReset,						OnVariablesResetFF2);
}

void RemoveVSH2Bridge()
{
	VSH2_Unhook(OnCallDownloads,					OnCallDownloadsFF2);
	VSH2_Unhook(OnBossMenu,							OnBossMenuFF2);
	VSH2_Unhook(OnBossCalcHealth,					OnBossCalcHealthFF2);
	VSH2_Unhook(OnBossSelected,						OnBossSelectedFF2);
	VSH2_Unhook(OnRedPlayerThink,					OnRedPlayerThinkFF2);
	VSH2_Unhook(OnBossThink,						OnBossThinkFF2);
	VSH2_Unhook(OnBossSuperJump,					OnBossSuperJumpFF2);
	VSH2_Unhook(OnBossWeighDown,					OnBossWeighDownFF2);
	VSH2_Unhook(OnBossModelTimer,					OnBossModelTimerFF2);
	VSH2_Unhook(OnBossEquipped,						OnBossEquippedFF2);
	VSH2_Unhook(OnBossInitialized,					OnBossInitializedFF2);
	VSH2_Unhook(OnBossKillBuilding,					OnBossKillBuildingFF2);
	VSH2_Unhook(OnBossPlayIntro,					OnBossPlayIntroFF2);
	VSH2_Unhook(OnPlayerKilled,						OnPlayerKilledFF2);
	VSH2_Unhook(OnPlayerAirblasted,					OnPlayerAirblastedFF2);
	VSH2_Unhook(OnBossMedicCall,					OnBossTriggerRageFF2);
	VSH2_Unhook(OnBossTaunt,						OnBossTriggerRageFF2);
	VSH2_Unhook(OnBossJarated,						OnBossJaratedFF2);
	VSH2_Unhook(OnRoundStart,						OnRoundStartFF2);
	VSH2_Unhook(OnRoundEndInfo,						OnRoundEndInfoFF2);
	VSH2_Unhook(OnMusic,							OnMusicFF2);
	VSH2_Unhook(OnBossDeath,						OnBossDeathFF2);
	UnhookEvent("player_hurt",						OnPlayerHurtFF2);
	VSH2_Unhook(OnBossTakeDamage_OnTriggerHurt,		OnBossTriggerHurtFF2);
	VSH2_Unhook(OnBossTakeDamage_OnMarketGardened, 	OnMarketGardenedFF2);
	VSH2_Unhook(OnBossTakeDamage_OnStabbed,			OnStabbedFF2);
	VSH2_Unhook(OnLastPlayer,						OnLastPlayerFF2);
	VSH2_Unhook(OnSoundHook,						OnSoundHookFF2);
	VSH2_Unhook(OnScoreTally,						OnScoreTallyFF2);
	VSH2_Unhook(OnVariablesReset,					OnVariablesResetFF2);

	ff2_cfgmgr.DeleteAll();
	delete ff2_cfgmgr;
}



///	VSH2 Hooks
Action OnCallDownloadsFF2()
{
	char script_sounds[][] = {
		"Announcer.AM_CapEnabledRandom",
		"Announcer.AM_CapIncite01.mp3",
		"Announcer.AM_CapIncite02.mp3",
		"Announcer.AM_CapIncite03.mp3",
		"Announcer.AM_CapIncite04.mp3",
		"Announcer.RoundEnds5minutes",
		"Announcer.RoundEnds2minutes"
	};

	char basic_sounds[][] = {
		"weapons/barret_arm_zap.wav",
		"player/doubledonk.wav",
		"ambient/lightson.wav",
		"ambient/lightsoff.wav",
	};

	PrecacheScriptList(script_sounds, sizeof(script_sounds));
	PrecacheSoundList(basic_sounds, sizeof(basic_sounds));
	PrepareSound("saxton_hale/9000.wav");

	ProcessOnCallDownload();

	return Plugin_Continue;
}

void OnBossMenuFF2(Menu& menu, const VSH2Player player)
{
	StringMapSnapshot snap = ff2_cfgmgr.Snapshot();
	char boss_name[FF2_MAX_BOSS_NAME_SIZE], id_menu[10];
	FF2Identity cur_identity;
	int num_rounds = VSH2GameMode.GetPropInt("iRoundCount");

	for( int i=snap.Length-1; i>=0; i-- ) {
		snap.GetKey(i, boss_name, sizeof(boss_name));
		if( ff2_cfgmgr.GetIdentity(boss_name, cur_identity) ) {
			ConfigMap cfg = FF2Character(cur_identity.hCfg).InfoSection;
			bool tmp;
			if(
				( !cfg.Get("name", boss_name, sizeof(boss_name)) ) ||
				( cfg.GetBool("blocked", tmp, false) && tmp ) ||
				( cfg.GetBool("nofirst", tmp, false) && tmp && !num_rounds )
			  )
				continue;

			int flag;
			if( cfg.GetInt("permissions", flag, 2) && flag ) {
				if( !CheckCommandAccess(player.index, "", flag) )
					continue;
			}

			IntToString(cur_identity.VSH2ID, id_menu, sizeof(id_menu));
			menu.AddItem(id_menu, boss_name);
		}
	}

	delete snap;
}

void OnBossCalcHealthFF2(const VSH2Player player, int& max_health, const int boss_count, const int red_players)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(player).iBossType, identity) )
		return;

	ConfigMap cfg = FF2Character(identity.hCfg).InfoSection;
	char formula[64];
	if( cfg.Get("health", formula, sizeof(formula)) ) {
		max_health = RoundToFloor(ParseFormula(formula, boss_count + red_players));
	}

	int health_cfg;
	if( cfg.GetInt("max health", health_cfg) && health_cfg > 0 && max_health > health_cfg )
		max_health = health_cfg;

	if( cfg.GetInt("min health", health_cfg) && health_cfg > 0 && health_cfg < max_health )
		max_health = health_cfg;

	///	Support for multilives: https://github.com/01Pollux/FF2-Library/blob/VSH2/addons/sourcemod/scripting/ff2_multilives.sp
	int lives;
	if( !cfg.GetInt("lives", lives) || lives <= 0 )
		lives = 1;
	ToFF2Player(player).iLives = lives;
	ToFF2Player(player).iMaxLives = lives;
}

Action OnBossSelectedFF2(const VSH2Player player)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(player).iBossType, identity) )
		return Plugin_Continue;

	/// player didn't chose a boss yet, disallow him from selecting hidden bosses
	int client = player.index;

	if( player.GetPropInt("iPresetType")==-1 && !player.GetPropAny("bOverridePreset") ) {
		bool is_blocked;
		if( (identity.hCfg.GetBool("character.info.blocked", is_blocked, false) || identity.hCfg.GetBool("character.info.blocked", is_blocked)) && is_blocked ) {
			FF2Identity copy_identity;
			int boss_id = FF2_FindNonHiddenBoss(copy_identity, client);
			if( boss_id!=-1 ) {
				identity = copy_identity;
				player.SetPropInt("iSpecial", copy_identity.VSH2ID);
				player.SetPropInt("iBossType", copy_identity.VSH2ID);
			}
		}
	}
	player.SetPropAny("bOverridePreset", false);

	/// Handle callback
	{
		char name[MAX_BOSS_NAME_SIZE]; name = identity.name;
		Action res = Call_OnBossSelected(ToFF2Player(player), name, false);

		if( res >= Plugin_Changed ) {
			if( ff2_cfgmgr.FindIdentityByName(name, identity) ) {
				player.SetPropInt("iBossType", identity.VSH2ID);
			}
		}
	}

	subplugins.LoadPlugins(identity.abilityList);

	/// Process Set Companion
	{
		ConfigMap companions = identity.hCfg.GetSection("character.info.companion");
		if( companions ) {
			int size = companions.Size;
			if( size ) {
				char companion[FF2_MAX_BOSS_NAME_SIZE];
				FF2Player[] next_players = new FF2Player[MaxClients];
				int count = VSH2GameMode.GetQueue(view_as< VSH2Player >(next_players));
				int allow_count = count - ff2.m_cvars.m_companion_min.IntValue;
				if( allow_count > 0 ) {
					int cur_player = 0;
					for( int i; i<size && cur_player<count && allow_count>0; i++ ) {
						if( companions.GetIntKey(i, companion, sizeof(companion)) && companion[0] ) {
							if( !ff2_cfgmgr.FindIdentityByName(companion, identity) ) {
								continue;
							}

							for( ; cur_player < count && allow_count > 0; ++cur_player ) {
								if( !next_players[cur_player].GetPropAny("bNoCompanion") ) {
									next_players[cur_player].SetPropAny("bOverridePreset", true);
									next_players[cur_player].MakeBossAndSwitch(identity.VSH2ID, true);
									--allow_count;
									break;
								}
							}
						}
					}
				}
			}
		}
	}

	if( IsVoteInProgress() )
		return Plugin_Continue;

	char[] help = new char[512];

	{
		ConfigMap info_sec = FF2Character(identity.hCfg).InfoSection;
		char language[25];
		GetLanguageInfo(GetClientLanguage(client), language, sizeof(language));

		Format(language, sizeof(language), "description.%s", language);
		info_sec.Get(language, help, 512);
	}

	Panel panel = new Panel();

	panel.SetTitle(help);
	panel.DrawItem("Exit");
	panel.Send(client, DummyHintPanel, 10);

	delete panel;

	return Plugin_Changed;
}

void OnRedPlayerThinkFF2(const VSH2Player vsh2player)
{
	LiveSys_DisplayForClient(vsh2player.index);
}

void OnBossThinkFF2(const VSH2Player vsh2player)
{
	FF2Player player = ToFF2Player(vsh2player);
	LiveSys_DisplayForClient(player.index);

	static FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(player).iBossType, identity) )
		return;

	ConfigMap cfg = identity.hCfg;
	ConfigMap info_sec = cfg.GetSection("character.info");

	///	Handle speed think and glow think
	{
		ConfigMap speed_sec = info_sec.GetSection("speed");
		bool custom;
		if( !speed_sec.GetBool("managed", custom, false) || !custom ) {
			float start_speed;
			if( !speed_sec.GetFloat("min", start_speed) )
				start_speed = 350.0;

			float end_speed;
			if( !speed_sec.GetFloat("max", end_speed) )
				end_speed = 100.0;

			player.SpeedThink(start_speed, end_speed);
		}
		player.GlowThink(0.1);
	}

	float flCharge = player.GetPropFloat("flCharge");
	float flRage = player.flRAGE;
	int client = player.index;

	///	Handle super jump
	{
		if( !player.bNoSuperJump ) {
			float max_charge;
			ConfigMap superjump_sec = info_sec.GetSection("Superjump");
			if( !superjump_sec.GetFloat("max charge", max_charge) )
				max_charge = 25.0;

			if( player.SuperJumpThink(2.5, max_charge) ) {
				if( !superjump_sec.GetFloat("reset charge", max_charge) )
					max_charge = -130.0;
				player.SuperJump(flCharge, max_charge);
			}
		}
	}

	///	Handle weighdown
	{
		if( !player.bNoWeighdown ) {
			float cur_time = GetGameTime();
			float curCd = player.GetPropFloat("flWeighdownCd") - cur_time;
			if( curCd <= 0.0 ) {
				int buttons = GetClientButtons(client);
				int flags = GetEntityFlags(client);
				if( flags & FL_ONGROUND )
					player.SetPropFloat("flWeighDown", 0.0);
				else player.SetPropFloat("flWeighDown", cur_time + 0.07);

				if( (buttons & IN_DUCK) && player.GetPropFloat("flWeighDown") >= 0.1 ) {
					float ang[3]; GetClientEyeAngles(client, ang);
					if( ang[0] > 60.0 ) {
						if( !cfg.GetFloat("Weightdown.cooldown", ang[0]) )
							ang[0] = 5.0;

						player.SetPropFloat("flWeighdownCd", cur_time + ang[0]);
						player.WeighDown(0.0);
					}
				}
			} else {
				SetHudTextParams(-1.0, 0.71, 0.15, 255, 0, 0, 255);
				ShowSyncHudText(client, ff2.m_hud[HUD_Weighdown], "Weighdown is not ready\nYou must wait %.1f sec", curCd);
			}
		}
	}

	/// Handle scout's auto rage regeneration
	{
		bool only_scouts = true;
		for( int i = 1; i<=MaxClients; i++ ) {
			if( !IsClientInGame(i) || !IsPlayerAlive(i) || i == client )
				continue;

			if ( TF2_GetPlayerClass(i) != TFClass_Scout ) {
				only_scouts = false;
				break;
			}
		}
		if ( only_scouts )
			player.flRAGE = (flRage += ff2.m_cvars.m_flscout_rage_gen.FloatValue);
	}

	///	Handle hud
	{
		ConfigMap hud_section = info_sec.GetSection("HUD");
		static char buffer[PLATFORM_MAX_PATH];

		char text_color[4]; /// { r, g, b, a }
		float text_offset[2]; // { x, y }
		{
			ConfigMap color_section = hud_section.GetSection("color");
			ConfigMap offset_section = hud_section.GetSection("offset");
			for( int i; i < 4; i++ ) {
				int text_color_val = text_color[i];
				if( !color_section.GetIntKeyInt(i, text_color_val) ) {
					text_color[i] = 255;
				} else {
					text_color[i] = text_color_val;
				}
			}

			if( !offset_section.GetIntKeyFloat(0, text_offset[0]) )
				text_offset[0] = -1.0;
			if( !offset_section.GetIntKeyFloat(1, text_offset[1]) )
				text_offset[1] = 0.78;
		}

		if( !player.bHideHUD ) {
			if( !hud_section.Get("text", buffer, sizeof(buffer)) ) {
				buffer = "Super-Jump: %i%%\n";
			}
			Format(buffer, sizeof(buffer), buffer, player.GetPropInt("bSuperCharge") ? 1000 : RoundFloat(flCharge) * 4);
		}
		else buffer[0] = 0;

		SetHudTextParams(
			text_offset[0],
			text_offset[1],
			0.15,
			text_color[0],
			text_color[1],
			text_color[2],
			text_color[3]
		);

		ShowSyncHudText(
			client,
			ff2.m_hud[HUD_Jump],
				flRage >= 100.0 ?
				"%sCall for medic to activate your \"RAGE\" ability" :
				"%sRage is %.1f percent ready",
			buffer,
			flRage
		);
	}
}


Action OnBossSuperJumpFF2(const VSH2Player vsh2player)
{
	FF2Player player = ToFF2Player(vsh2player);
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(player.iBossType, identity) )
		return Plugin_Continue;

	Call_FF2OnAbility(player, CT_CHARGE);
	identity.soundMap.PlayAbilitySound(vsh2player, identity.hCfg.GetSection("info.Superjump"), CT_CHARGE);
	return Plugin_Continue;
}

void OnBossWeighDownFF2(const VSH2Player vsh2player)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(vsh2player).iBossType, identity) )
		return;

	Call_FF2OnAbility(ToFF2Player(vsh2player), CT_WEIGHDOWN);
	identity.soundMap.PlayAbilitySound(vsh2player, identity.hCfg.GetSection("info.Weighdown"), CT_WEIGHDOWN);
}

void OnBossModelTimerFF2(const VSH2Player player)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(player).iBossType, identity) )
		return;

	int client = player.index;
	char model[PLATFORM_MAX_PATH];
	if( identity.hCfg.Get("character.info.model", model, sizeof(model)) ) {
		SetVariantString(model);
		AcceptEntityInput(client, "SetCustomModel");
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
	}
}

void OnBossEquippedFF2(const VSH2Player player)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(player).iBossType, identity) )
		return;

	FF2Character boss_cfg = FF2Character(identity.hCfg);
	char name[MAX_BOSS_NAME_SIZE]; boss_cfg.Config.Get("info.name", name, sizeof(name));

	player.SetName(name);
	player.RemoveAllItems();

	ConfigMap wepcfg = boss_cfg.WeaponSection;

	int wep_count = wepcfg.Size;
	char attr[64]; int index; int lvl; int qual;
	for( int i; i<wep_count; i++ ) {
		ConfigMap wep = wepcfg.GetIntSection(i);
		if( !wep )
			break;

		if( !wep.GetInt("index", index) )
			continue;
		if( !wep.Get("name", name, sizeof(name)) )
			continue;
		if( !wep.GetInt("level", lvl) )
			lvl = 39;
		if( !wep.GetInt("quality", qual) )
			qual = 5;

		wep.Get("attributes", attr, sizeof(attr));
		int new_weapon = player.SpawnWeapon(name, index, lvl, qual, attr);
		SetEntPropEnt(player.index, Prop_Send, "m_hActiveWeapon", new_weapon);
	}
}

void OnBossInitializedFF2(const VSH2Player vsh2player)
{
	FF2Player player = ToFF2Player(vsh2player);
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(player.iBossType, identity) )
		return;

	ConfigMap cfg = FF2Character(identity.hCfg).InfoSection;
	int cls;
	if( !cfg.GetInt("class", cls) )
		cls = GetRandomInt(1, 8);

	SetEntProp(player.index, Prop_Send, "m_iClass", cls);
	{
		bool tmp;
		player.bNoSuperJump = cfg.GetBool("Superjump.custom", tmp, false) && tmp;
		player.bNoWeighdown = cfg.GetBool("Weightdown.custom", tmp, false) && tmp;
		player.bHideHUD 	= cfg.GetBool("HUD.custom", tmp, false) && tmp;
		player.SetPropAny("bNoHealthPacks", true);
		player.SetPropAny("bNoAmmoPacks", true);
		float val;
		if( !cfg.GetFloat("damage_ratio", val) )
			val = 1.0;
		player.flRageRatio = val;
	}
}

void OnBossKillBuildingFF2(const VSH2Player player, const int building, Event event)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(player).iBossType, identity) )
		return;

	FF2SoundSection sec = identity.soundMap.RandomEntry("kill_buildable");
	if( sec )
		sec.PlaySound(player.index, VSH2_VOICE_ALL);
}

Action OnBossPlayIntroFF2(const VSH2Player player)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(player).iBossType, identity) )
		return Plugin_Continue;

	FF2SoundSection sec = identity.soundMap.RandomEntry("begin");
	if( sec )
		sec.PlaySound(player.index, VSH2_VOICE_INTRO);

	return Plugin_Handled;
}

void OnPlayerKilledFF2(const VSH2Player attacker, const VSH2Player victim, Event event)
{
	if( event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER )
		return;

	FF2Identity identity[2]; bool states[2];
	states[0] = attacker && ff2_cfgmgr.FindIdentity(ToFF2Player(attacker).iBossType, identity[0]);
	states[1] = victim && ff2_cfgmgr.FindIdentity(ToFF2Player(victim).iBossType, identity[1]);
	if( !states[0] && !states[1] )
		return;

	///	Victim is an FF2 boss
	if( states[1] ) {
		FF2Player player = ToFF2Player(victim);
		Call_FF2OnAbility(player, CT_BOSS_KILLED);
	}
	else if( states[0] ) {
		///	Attacker is an FF2 boss
		float curtime = GetGameTime();
		if( curtime <= attacker.GetPropFloat("flKillSpree") )
			attacker.SetPropInt("iKills", attacker.GetPropInt("iKills") + 1);
		else attacker.SetPropInt("iKills", 0);

		///	First play sound_kspree
		if( attacker.GetPropInt("iKills") == 3 && vsh2_gm.iLivingReds != 1 ) {
			FF2SoundSection sec = identity[1].soundMap.RandomEntry("kspree");
			if( sec ) {
				sec.PlaySound(attacker.index, VSH2_VOICE_SPREE);
			}
		} else {
			/// play sounn_hit*
			{
				static const char tf_classes[][] =  { "scout", "sniper", "soldier", "demoman", "medic", "heavy", "pyro", "spy", "engineer" };

				int cls = view_as< int >(victim.iTFClass) - 1;
				char _key[36];
				FormatEx(_key, sizeof(_key), "hit_%s", tf_classes[cls]);

				FF2SoundSection sec;

				if( !GetRandomInt(0, 2) )
					sec = identity[1].soundMap.RandomEntry(_key);

				if( sec ) {
					sec.PlaySound(attacker.index, VSH2_VOICE_SPREE);
				}
				else {
					///	No matching sound_hit_* sound was found, default to sound_hit
					sec = identity[1].soundMap.RandomEntry("hit");
					if( sec ) {
						sec.PlaySound(attacker.index, VSH2_VOICE_SPREE);
					}
				}
			}

			attacker.SetPropFloat("flKillSpree", curtime+5.0);
		}
		Call_FF2OnAbility(ToFF2Player(victim), CT_PLAYER_KILLED);
	}
}

void OnPlayerAirblastedFF2(const VSH2Player airblaster, const VSH2Player airblasted, Event event)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(airblasted).iBossType, identity) )
		return;

	float rage = airblasted.GetPropFloat("flRAGE");
	airblasted.SetPropFloat("flRAGE", rage + ff2.m_cvars.m_flairblast_rage.FloatValue);
}

Action OnBossTriggerRageFF2(const VSH2Player vsh2player)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(vsh2player).iBossType, identity) )
		return Plugin_Continue;

	FF2Player player = ToFF2Player(vsh2player);
	if( player.GetPropAny("flRAGE") < 100.0 )
		return Plugin_Handled;

	Call_FF2OnAbility(player, CT_RAGE);
	if( !player.GetPropAny("bSupressRAGE") ) {
		identity.soundMap.PlayAbilitySound(player, null, CT_RAGE);
		player.SetPropFloat("flRAGE", 0.0);
	}

	return Plugin_Handled;
}

Action OnBossJaratedFF2(const VSH2Player victim, const VSH2Player attacker)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(victim).iBossType, identity) )
		return Plugin_Continue;

	FF2Player player = ToFF2Player(victim);
	float rage = player.flRAGE;

	rage -= ff2.m_cvars.m_fljarate_rage.FloatValue;
	if( rage <= 0.0 )
		rage = 0.0;

	player.flRAGE = rage;
	return Plugin_Changed;
}

void OnRoundStartFF2(const VSH2Player[] bosses, const int boss_count, const VSH2Player[] red_players, const int red_count)
{
	_RoundEndInfo_OverrideMessage = false;
	LiveSys_OnRoundStart(bosses, boss_count);
}

Action OnRoundEndInfoFF2(const VSH2Player player, bool bossBool, char message[MAXMESSAGE])
{
	if( _RoundEndInfo_OverrideMessage ) {
		message[0] = '\0';
		return Plugin_Continue;
	}

	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(player).iBossType, identity) )
		return Plugin_Continue;

	bool soundplayed = false;
	char boss_name[MAX_BOSS_NAME_SIZE];
	float hud_y_pos = 0.2;

	for( int i=MaxClients; i; i-- ) {
		if( !IsClientInGame(i) )
			continue;

		FF2Player cur_boss = FF2Player(i);
		if( !ff2_cfgmgr.FindIdentity(cur_boss.iBossType, identity) )
			continue;

		if( !soundplayed ) {
			if( bossBool ) {
				FF2SoundSection sec = identity.soundMap.RandomEntry("win");
				if( sec ) {
					sec.PlaySound(i, VSH2_VOICE_WIN);
					soundplayed = true;
				}
			} else {
				FF2SoundSection sec = identity.soundMap.RandomEntry("stalemate");
				if( sec ) {
					sec.PlaySound(i, VSH2_VOICE_WIN);
					soundplayed = true;
				}
			}
		}

		if( !LiveSys_OnRoundEndInfo(cur_boss, message) ) {
			cur_boss.GetName(boss_name);

			FormatEx(
				message,
				sizeof(message),
				"%s (%N) had %i (of %i) health left.",
				boss_name,
				cur_boss.index,
				cur_boss.GetPropInt("iHealth"),
				cur_boss.GetPropInt("iMaxHealth")
			);
		}
		_RoundEndInfo_OverrideMessage = true;

		SetHudTextParams(-1.0, hud_y_pos, 10.0, 255, 255, 255, 255);
		for( int j=MaxClients; j; --j ) {
			if( IsClientInGame(j) && !(GetClientButtons(j) & IN_SCORE) ) {
				ShowHudText(j, -1, "%s", message);
				CPrintToChat(j, "{olive}[VSH 2] End of Round{default} %s", message);
			}
		}

		hud_y_pos += 0.03;
	}

	message[0] = 0;
	return Plugin_Continue;
}

Action OnMusicFF2(char song[PLATFORM_MAX_PATH], float& time, const VSH2Player player)
{
	static FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(player).iBossType, identity) )
		return Plugin_Continue;

	Action res = Call_OnMusic(ToFF2Player(player), song, time);
	if( res > Plugin_Changed ) {
		return res;
	}

	/// hmm...
	{
		FF2SoundSection sec;
		if( res>=Plugin_Changed && (sec=FindSoundByPath(identity.soundMap.GetSection("bgm"), song)) ) {
			sec.GetTime(time);
			sec.PrintToAll();
		}
		else {
			if( (sec=identity.soundMap.RandomEntry("bgm")) ) {
				sec.GetPathAndTime(song, sizeof(song), time);
				sec.PrintToAll();
			}
		}
	}

	return Plugin_Handled;
}

void OnBossDeathFF2(const VSH2Player player)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(player).iBossType, identity) )
		return;

	FF2SoundSection sec = identity.soundMap.RandomEntry("death");
	if( sec )
		sec.PlaySound(player.index, VSH2_VOICE_LOSE);
}

Action OnMarketGardenedFF2( VSH2Player victim, int& attacker, int& inflictor,
				   float& damage, int& damagetype, int& weapon,
				   float damageForce[3], float damagePosition[3], int damagecustom )
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(victim).iBossType, identity) )
		return Plugin_Continue;

	Call_FF2OnAbility(ToFF2Player(victim), CT_BOSS_MG);
	return Plugin_Continue;
}

Action OnStabbedFF2( VSH2Player victim, int& attacker, int& inflictor,
			  		 float& damage, int& damagetype, int& weapon,
			    	 float damageForce[3], float damagePosition[3], int damagecustom )
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(victim).iBossType, identity) )
		return Plugin_Continue;

	Action res = Call_OnBossStabbed(ToFF2Player(victim), FF2Player(attacker));
	if( res==Plugin_Stop )
		return Plugin_Changed;
	else if( res==Plugin_Handled )
		damage = 0.0;

	FF2SoundSection sec = identity.soundMap.RandomEntry("stabbed");
	if( sec ) {
		sec.PlaySound(victim.index, VSH2_VOICE_LOSE);
	}

	Call_FF2OnAbility(ToFF2Player(victim), CT_BOSS_STABBED);
	return Plugin_Continue;
}

Action OnSoundHookFF2(const VSH2Player player, char sample[PLATFORM_MAX_PATH], int& channel, float& volume, int& level, int& pitch, int& flags)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(player).iBossType, identity) )
		return Plugin_Continue;

	if( channel==SNDCHAN_VOICE || (channel==SNDCHAN_STATIC && !StrContains(sample, "vo")) ) {
		FF2SoundSection sec = identity.soundMap.RandomEntry("phrase");

		if( sec ) {
			sec.GetPath(sample, sizeof(sample));
			return Plugin_Changed;
		}
		else if( (sec=identity.soundMap.RandomEntry("replace")) ) {
			int max = sec.Config.Size;
			FF2SoundSection[] entries = new FF2SoundSection[max];
			int count;

			char cur_path[PLATFORM_MAX_PATH];
			for( int i = 0; i < max; i++ ) {
				FF2SoundSection cur_entry = view_as<FF2SoundSection>(sec.Config.GetIntSection(i));
				if( !cur_entry )
					continue;

				cur_entry.Config.Get("seek", cur_path, sizeof(cur_path));
				if( !StrContains(cur_path, sample) )
					entries[count++] = cur_entry;
			}

			if( count ) {
				entries[GetRandomInt(0, count - 1)].GetPath(sample, sizeof(sample));
			}
			return Plugin_Changed;
		}

		bool sound_block;
		if( identity.hCfg.GetBool("character.info.mute", sound_block, false) && sound_block ) {
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

void OnLastPlayerFF2(const VSH2Player player)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(player).iBossType, identity) )
		return;

	FF2SoundSection sec = identity.soundMap.RandomEntry("lastman");
	if( sec ) {
		sec.PlaySound(player.index, VSH2_VOICE_LASTGUY);
	}
}

void OnScoreTallyFF2(const VSH2Player player, int& points_earned, int& queue_earned)
{
	ff2.m_queuePoints[player.index] = queue_earned;
	if( !VSH2GameMode.GetPropInt("bQueueChecking") ) {
		RequestFrame(FinishQueueArray);
		VSH2GameMode.SetProp("bQueueChecking", true);
	}
}

void FinishQueueArray()
{
	VSH2GameMode.SetProp("bQueueChecking", false);

	int[] points = new int[MaxClients + 1];
	for( int i=1; i<=MaxClients; i++ )
		points[i] = ff2.m_queuePoints[i];

	Action res = Call_OnSetScore(points);
	if( res == Plugin_Changed ) {
		for( int i=1; i<=MaxClients; i++ ) {
			if( !IsClientInGame(i) )
				continue;

			FF2Player player = FF2Player(i);
			player.SetPropInt("iQueue", points[i] - ff2.m_queuePoints[i] + player.GetPropInt("iQueue"));
		}
	} else if( res != Plugin_Continue ) {
		for( int i=1; i<=MaxClients; i++ ) {
			if( !IsClientInGame(i) )
				continue;

			FF2Player player = FF2Player(i);
			player.SetPropInt("iQueue", player.GetPropInt("iQueue") - ff2.m_queuePoints[i]);
		}
	}

	subplugins.UnloadAllSubPlugins();
}

Action OnPlayerHurtFF2(Event event, const char[] name, bool dontBroadcast)
{
	FF2Identity identity;
	FF2Player player = ToFF2Player(event.GetInt("userid"));
	if( !ff2_cfgmgr.FindIdentity(player.iBossType, identity) ) {
		return Plugin_Continue;
	}

	int damage = event.GetInt("damageamount");
	int cur_lives = player.iLives;
	int cur_health = player.iHealth;
	if( cur_lives > 1 && cur_health <= 0 ) {
		int max_health = player.GetPropInt("iMaxHealth");
		int true_max_health = max_health * cur_lives;
		int delta_health = true_max_health - damage;
		if( delta_health > 0 ) {
			int new_lives = delta_health / max_health;
			if( cur_lives != new_lives ) {
				Action res = Call_OnBossLoseLife(player, cur_lives);
				switch( res ) {
					case Plugin_Continue: {}
					case Plugin_Changed: {
						new_lives = cur_lives;
					}
					default: return res;
				}
				player.iLives = new_lives;

				int new_health = (delta_health % max_health);
				if( !new_health )
					new_health = max_health;
				else new_health += damage;
				player.iHealth = new_health;

				Call_FF2OnAbility(player, CT_LIFE_LOSS);
				switch( new_lives ) {
					case 0: {}
					case 1: {
						char boss_name[MAX_BOSS_NAME_SIZE];
						player.GetName(boss_name);
						PrintToChatAll("%s lost a life! There is 1 more!", boss_name);
						FF2SoundSection sec = identity.soundMap.RandomEntry("last_life");
						if( sec )
							sec.PlaySound(player.index, VSH2_VOICE_LOSE);
					}
					default: {
						char boss_name[MAX_BOSS_NAME_SIZE];
						player.GetName(boss_name);
						PrintToChatAll("%s lost a life! There are %i more!", boss_name, new_lives);
					}
				}
			}
		}
	}

	float rage = damage * player.flRageRatio;
	if( rage > 850.0 )
		rage = 850.0;

	player.GiveRage(RoundToCeil(rage));
	return Plugin_Continue;
}

Action OnBossTriggerHurtFF2(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(victim).iBossType, identity) )
		return Plugin_Continue;

	return Call_OnTakeDamage_OnBossTriggerHurt(victim.index, attacker, damage);
}

void OnVariablesResetFF2(const VSH2Player vsh2player)
{
	FF2Player player = ToFF2Player(vsh2player);

	player.iLives = 0;
	player.iMaxLives = 0;
	player.bNoSuperJump = false;
	player.bNoWeighdown = false;
	player.bHideHUD = false;
	player.flRageRatio = 1.0;

	player.SetPropAny("bNotifySMAC_CVars", false);
	player.SetPropAny("bSupressRAGE", false);
	player.SetPropFloat("flWeighdownCd", 0.0);
	player.SetPropInt("iFlags", 0);

	/// https://github.com/01Pollux/FF2-Library/blob/VSH2/addons/sourcemod/scripting/ff2_nopacks.sp
	player.SetPropAny("bNoHealthPacks", false);
	player.SetPropAny("bNoAmmoPacks", false);

	player.SetPropAny("bOverridePreset", false);
}


int DummyHintPanel(Menu menu, MenuAction action, int param1, int param2)
{
	return 0;
}
