void InitVSH2Bridge()
{
	char pack[48];
	ff2.m_cvars.m_pack_name.GetString(pack, sizeof(pack));
	
	ff2_cfgmgr = new FF2BossManager(pack);
	
	VSH2_Hook(OnCallDownloads,						OnCallDownloadsFF2);
	VSH2_Hook(OnBossMenu,							OnBossMenuFF2);
	VSH2_Hook(OnBossCalcHealth,						OnBossCalcHealthFF2);
	VSH2_Hook(OnBossSelected,						OnBossSelectedFF2);
	VSH2_Hook(OnBossThink,							OnBossThinkFF2);
	VSH2_Hook(OnBossSuperJump,						OnBossSuperJumpFF2);
	VSH2_Hook(OnBossWeighDown,						OnBossWeighDownFF2);
	VSH2_Hook(OnBossModelTimer,						OnBossModelTimerFF2);
	VSH2_Hook(OnBossEquipped,						OnBossEquippedFF2);
	VSH2_Hook(OnBossInitialized,					OnBossInitializedFF2);
	VSH2_Hook(OnBossKillBuilding,					OnBossKillBuildingFF2);
	VSH2_Hook(OnBossPlayIntro,						OnBossPlayIntroFF2);
	VSH2_Hook(OnPlayerKilled,						OnPlayerKilledFF2);
	VSH2_Hook(OnPlayerHurt,							OnPlayerHurtFF2);
	VSH2_Hook(OnPlayerAirblasted,					OnPlayerAirblastedFF2);
	VSH2_Hook(OnBossMedicCall,						OnBossTriggerRageFF2);
	VSH2_Hook(OnBossTaunt,							OnBossTriggerRageFF2);
	VSH2_Hook(OnBossJarated,						OnBossJaratedFF2);
	VSH2_Hook(OnRoundEndInfo,						OnRoundEndInfoFF2);
	VSH2_Hook(OnMusic,								OnMusicFF2);
	VSH2_Hook(OnBossDeath,							OnBossDeathFF2);
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
	VSH2_Unhook(OnBossThink,						OnBossThinkFF2);
	VSH2_Unhook(OnBossSuperJump,					OnBossSuperJumpFF2);
	VSH2_Unhook(OnBossWeighDown,					OnBossWeighDownFF2);
	VSH2_Unhook(OnBossModelTimer,					OnBossModelTimerFF2);
	VSH2_Unhook(OnBossEquipped,						OnBossEquippedFF2);
	VSH2_Unhook(OnBossInitialized,					OnBossInitializedFF2);
	VSH2_Unhook(OnBossKillBuilding,					OnBossKillBuildingFF2);
	VSH2_Unhook(OnBossPlayIntro,					OnBossPlayIntroFF2);
	VSH2_Unhook(OnPlayerKilled,						OnPlayerKilledFF2);
	VSH2_Unhook(OnPlayerHurt,						OnPlayerHurtFF2);
	VSH2_Unhook(OnPlayerAirblasted,					OnPlayerAirblastedFF2);
	VSH2_Unhook(OnBossMedicCall,					OnBossTriggerRageFF2);
	VSH2_Unhook(OnBossTaunt,						OnBossTriggerRageFF2);
	VSH2_Unhook(OnBossJarated,						OnBossJaratedFF2);
	VSH2_Unhook(OnRoundEndInfo,						OnRoundEndInfoFF2);
	VSH2_Unhook(OnMusic,							OnMusicFF2);
	VSH2_Unhook(OnBossDeath,						OnBossDeathFF2);
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
	char id_menu[10];

	StringMapSnapshot snap = ff2_cfgmgr.Snapshot();
	char char_name[48];

	int num_rounds = VSH2GameMode.GetPropInt("iRoundCount");
	ConfigMap cfg;
	bool tmp;
	int flag;

	for( int i = snap.Length - 1; i >= 0; i-- ) {
		snap.GetKey(i, char_name, sizeof(char_name));
		FF2Identity curIdentity;
		if( ff2_cfgmgr.GetIdentity(char_name, curIdentity) ) {
			cfg = curIdentity.hCfg.GetSection("character");
			if( !cfg.Get("name", char_name, sizeof(char_name)) || (cfg.GetBool("blocked", tmp) && tmp) )
				continue;

			if( cfg.GetBool("nofirst", tmp) && tmp && !num_rounds )
				continue;

			if( cfg.GetInt("permissions", flag, 2) && flag )
				if( !CheckCommandAccess(player.index, "", flag) )
					continue;

			IntToString(curIdentity.VSH2ID, id_menu, sizeof(id_menu));
			menu.AddItem(id_menu, char_name);
		}
	}
	delete snap;
}

void OnBossCalcHealthFF2(const VSH2Player player, int& max_health, const int boss_count, const int red_players)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(player).iBossType, identity) )
		return;

	ConfigMap cfg = ToFF2Player(player).iCfg;
	char formula[64];
	if( cfg.Get("health_formula", formula, sizeof(formula)) ) {
		max_health = RoundToFloor(ParseFormula(formula, boss_count + red_players));
	}

	int lives;
	///	Support for multilives: https://github.com/01Pollux/FF2-Library/blob/VSH2/addons/sourcemod/scripting/ff2_multilives.sp
	if( cfg.GetInt("lives", lives) && lives > 1 ) {
		ToFF2Player(player).iLives = lives;
		ToFF2Player(player).iMaxLives = lives;
	}
}

Action OnBossSelectedFF2(const VSH2Player player)
{
	if( IsVoteInProgress() )
		return Plugin_Continue;

	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(player).iBossType, identity) )
		return Plugin_Continue;
	
	/// Handle callback
	{
		char name[MAX_BOSS_NAME_SIZE]; name = identity.szName;
		Action res = Call_OnBossSelected(ToFF2Player(player), name, false);

		if( res >= Plugin_Changed ) {
			if( ff2_cfgmgr.FindIdentityByName(name, identity) ) {
				player.SetPropInt("iBossType", identity.VSH2ID);
			}
		}		
	}

	ff2.m_plugins.LoadPlugins(identity.ablist);
	char[] help = new char[512];
	{
		char language[25];
		GetLanguageInfo(GetClientLanguage(player.index), language, sizeof(language));
		Format(language, sizeof(language), "character.description_%s", language);
		if( !identity.hCfg.Get(language, help, 512) )
			return Plugin_Changed;
	}

	Panel panel = new Panel();

	panel.SetTitle(help);
	panel.DrawItem("Exit");
	panel.Send(player.index, DummyHintPanel, 10);

	delete panel;

	return Plugin_Changed;
}

void OnBossThinkFF2(const VSH2Player vsh2player)
{
	FF2Player player = ToFF2Player(vsh2player);

	static FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(player).iBossType, identity) )
		return;

	///	Handle speed think
	{
		float flstart;
		if( !player.iCfg.GetFloat("speed", flstart) && !player.iCfg.GetFloat("maxspeed", flstart) )
			flstart = 350.0;

		float flmin;
		if( !player.iCfg.GetFloat("minspeed", flmin) )
			flmin = 100.0;

		player.SpeedThink(flstart, flmin);
		player.GlowThink(0.1);
	}

	float flCharge = player.GetPropFloat("flCharge");
	float flRage = player.GetPropFloat("flRAGE");
	int client = player.index;
	ConfigMap cfg = player.iCfg;
	static char buffer[PLATFORM_MAX_PATH];

	///	Handle super jump
	if( !player.bNoSuperJump ) {
		float flmin;
		if( !cfg.GetFloat("min super jump", flmin) )
			flmin = 25.0;

		if( player.SuperJumpThink(2.5, flmin) ) {
			if( !cfg.GetFloat("super jump reset", flmin) )
				flmin = -130.0;
			player.SuperJump(flCharge, flmin);

			FF2SoundList snd_list = identity.sndHash.GetList("sound_ability");
			if( RandomAbilitySound(snd_list, CT_CHARGE, buffer, sizeof(buffer)) ) {
				player.PlayVoiceClip(buffer, VSH2_VOICE_ABILITY);
			}
		}
	}

	///	Handle weighdown
	{
		if( !player.bNoWeighdown ) {
			float curCd = player.GetPropFloat("flWeighdownCd") - GetGameTime();
			if( curCd <= 0.0 ) {
				int buttons = GetClientButtons(client);
				int flags = GetEntityFlags(client);
				if( flags & FL_ONGROUND )
					player.SetPropFloat("flWeighDown", 0.0);
				else player.SetPropFloat("flWeighDown", GetGameTime() + 0.07);

				if( (buttons & IN_DUCK) && player.GetPropFloat("flWeighDown") >= 0.1 ) {
					float ang[3]; GetClientEyeAngles(client, ang);
					if( ang[0] > 60.0 ) {
						if( !cfg.GetFloat("weighdown cooldown", ang[0]) )
							ang[0] = 5.0;

						player.SetPropFloat("flWeighdownCd", GetGameTime() + ang[0]);
						player.WeighDown(0.0);
					}
				}
			} else {
				SetHudTextParams(-1.0, 0.85, 0.15, 255, 0, 0, 255);
				ShowSyncHudText(client, ff2.m_hud[HUD_Weighdown], "Weighdown is not ready\nYou must wait %.1f sec", curCd);
			}
		}
	}

	buffer[0] = '\0';

	if( !player.bHideHUD )
		Format(buffer, sizeof(buffer), "Super-Jump: %i%%\n", player.GetPropInt("bSuperCharge") ? 1000 : RoundFloat(flCharge) * 4);

	SetHudTextParams(-1.0, 0.77, 0.15, 255, 255, 255, 255);

	if( flRage >= 100.0 ) {
		Format(buffer, sizeof(buffer), "%sCall for medic to activate your \"RAGE\" ability", buffer);
	} else {
		Format(buffer, sizeof(buffer), "%sRage is %.1f percent ready", buffer, flRage);
	}

	ShowSyncHudText(client, ff2.m_hud[HUD_Jump], "%s", buffer);
}

Action OnBossSuperJumpFF2(const VSH2Player vsh2player)
{
	FF2Player player = ToFF2Player(vsh2player);
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(player.iBossType, identity) )
		return Plugin_Continue;

	Call_FF2OnAbility(player, CT_CHARGE);
	return Plugin_Continue;
}

void OnBossWeighDownFF2(const VSH2Player vsh2player)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(vsh2player).iBossType, identity) )
		return;
	
	Call_FF2OnAbility(ToFF2Player(vsh2player), CT_WEIGHDOWN);
}

void OnBossModelTimerFF2(const VSH2Player player)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(player).iBossType, identity) )
		return;

	int client = player.index;
	char model[PLATFORM_MAX_PATH];
	if( ToFF2Player(player).iCfg.Get("model", model, sizeof(model)) ) {
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

	ConfigMap cfg = ToFF2Player(player).iCfg;
	char name[MAX_BOSS_NAME_SIZE]; cfg.Get("name", name, sizeof(name));

	player.SetName(name);
	player.RemoveAllItems();

	ConfigMap wepcfg;

	char attr[64]; int index; int lvl; int qual;
	for( int i = 1; i < 4; i++ ) {
		FormatEx(name, sizeof(name), "weapon%i", i);
		wepcfg = cfg.GetSection(name);
		if( !wepcfg )
			break;

		if( !wepcfg.GetInt("index", index) )
			continue;
		if( !wepcfg.Get("name", name, sizeof(name)) )
			continue;
		if( !wepcfg.GetInt("level", lvl) )
			lvl = 39;
		if( !wepcfg.GetInt("quality", qual) )
			qual = 5;

		wepcfg.Get("attributes", attr, sizeof(attr));
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

	ConfigMap cfg = player.iCfg;
	int cls;
	if( !cfg.GetInt("class", cls) )
		cls = GetRandomInt(1, 8);

	SetEntProp(player.index, Prop_Send, "m_iClass", cls);
	{
		bool tmp;
		player.bNoSuperJump = cfg.GetBool("No Superjump", tmp) && tmp;
		player.bNoWeighdown = cfg.GetBool("No Weighdown", tmp) && tmp;
		player.bHideHUD 	= cfg.GetBool("No HUD", tmp) && tmp;
	}

	/// Process Set Companion
	{
		char companion[48];
		if( !cfg.Get("companion", companion, sizeof(companion)) || !companion[0] ) {
			return;
		}

		if( !ff2_cfgmgr.FindIdentityByName(companion, identity) ) {
			return;
		}

		FF2Player[] next_players = new FF2Player[MaxClients];
		int count = VSH2GameMode.GetQueue(view_as< VSH2Player >(next_players));
		int limit = ff2.m_cvars.m_companion_min.IntValue;
		for( int i = 1; i < count && i <= limit; i++ ) {
			if( !next_players[i].GetPropAny("bNoCompanion") ) {
				next_players[i].MakeBossAndSwitch(identity.VSH2ID, true);
				break;
			}
		}
	}
}

void OnBossKillBuildingFF2(const VSH2Player player, const int building, Event event)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(player).iBossType, identity) )
		return;

	FF2SoundList list = identity.sndHash.GetList("sound_kill_buildable");
	FF2SoundIdentity snd_id;
	if( list && list.RandomSound(snd_id) )
		player.PlayVoiceClip(snd_id.path, VSH2_VOICE_ALL);
}

Action OnBossPlayIntroFF2(const VSH2Player player)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(player).iBossType, identity) )
		return Plugin_Continue;

	FF2SoundList list = identity.sndHash.GetList("sound_begin");
	FF2SoundIdentity snd_id;
	
	if( list && list.RandomSound(snd_id) )
		player.PlayVoiceClip(snd_id.path, VSH2_VOICE_INTRO);

	return Plugin_Handled;
}

void OnPlayerKilledFF2(const VSH2Player attacker, const VSH2Player victim, Event event)
{
	if( event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER )
		return;

	FF2Identity identity[2]; bool states[2];
	states[0] = ff2_cfgmgr.FindIdentity(ToFF2Player(attacker).iBossType, identity[0]);
	states[1] = ff2_cfgmgr.FindIdentity(ToFF2Player(victim).iBossType, identity[1]);
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
			FF2SoundList list = identity[1].sndHash.GetList("sound_kspree");
			FF2SoundIdentity snd_id;
			if( list && list.RandomSound(snd_id) ) {
				attacker.PlayVoiceClip(snd_id.path, VSH2_VOICE_SPREE);
			}
		} else {
			/// play sounn_hit*
			{
				FF2SoundIdentity snd_id;
				static const char tf_classes[] =  { "scout", "sniper", "soldier", "demoman", "medic", "heavy", "pyro", "spy", "engineer" };

				int cls = view_as< int >(victim.iTFClass) - 1;
				char _key[36];
				FormatEx(_key, sizeof(_key), "sound_hit_%s", tf_classes[cls]);

				FF2SoundList list;

				if( !GetRandomInt(0, 2) )
					list = identity[1].sndHash.GetList(_key);

				if( list && list.RandomSound(snd_id) ) {
					attacker.PlayVoiceClip(snd_id.path, VSH2_VOICE_SPREE);
				}
				else {
					///	No matching sound_hit_* sound was found, default to sound_hit
					list = identity[1].sndHash.GetList("sound_hit");
					if( list && list.RandomSound(snd_id) ) {
						attacker.PlayVoiceClip(snd_id.path, VSH2_VOICE_SPREE);
					}
				}
			}
			
			attacker.SetPropFloat("flKillSpree", curtime+5.0);
		}
		Call_FF2OnAbility(ToFF2Player(victim), CT_PLAYER_KILLED);
	}
}

void OnPlayerHurtFF2(const VSH2Player attacker, const VSH2Player victim, Event event)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(victim).iBossType, identity) )
		return;

	int damage = event.GetInt("damageamount");
	victim.GiveRage(damage);

	FF2Player player = ToFF2Player(victim);
	int curHealth = player.iHealth;
	if( player.iLives <= 1 || damage < curHealth )
		return;

	Action res = Call_OnBossLoseLife(player);
	if( res <= Plugin_Changed ) {
		if( player.iLives > 1 ) {
			player.iHealth = player.GetPropInt("iMaxHealth") + curHealth - damage;
			Call_FF2OnAbility(player, CT_LIFE_LOSS);
			player.iLives--;
		}
	}
}

void OnPlayerAirblastedFF2(const VSH2Player airblaster, const VSH2Player airblasted, Event event)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(airblasted).iBossType, identity) )
		return;

	float rage = airblasted.GetPropFloat("flRAGE");
	airblasted.SetPropFloat("flRAGE", rage + ff2.m_cvars.m_flairblast.FloatValue);
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
	if( !player.GetPropAny("bSupressRAGE") )
		player.SetPropFloat("flRAGE", 0.0);
	
	return Plugin_Handled;
}

Action OnBossJaratedFF2(const VSH2Player victim, const VSH2Player attacker)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(victim).iBossType, identity) )
		return Plugin_Continue;

	FF2Player player = ToFF2Player(victim);
	float rage = player.flRAGE;
	Action res = Call_OnBossJarated(ToFF2Player(victim), ToFF2Player(attacker), rage);
	if( res==Plugin_Stop )
		return Plugin_Changed;

	rage -= ff2.m_cvars.m_fljarate.FloatValue;
	if( rage <= 0.0 )
		rage = 0.0;

	player.flRAGE = rage;
	return Plugin_Changed;
}

void OnRoundEndInfoFF2(const VSH2Player player, bool bossBool, char message[MAXMESSAGE])
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(player).iBossType, identity) )
		return;

	FF2SoundIdentity snd_id;
	if( bossBool ) {
		FF2SoundList list = identity.sndHash.GetList("sound_win");
		if( list && list.RandomSound(snd_id) )
			player.PlayVoiceClip(snd_id.path, VSH2_VOICE_WIN);
	} else {
		FF2SoundList list = identity.sndHash.GetList("sound_stalemate");
		if( list && list.RandomSound(snd_id) )
			player.PlayVoiceClip(snd_id.path, VSH2_VOICE_WIN);
	}
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
		FF2SoundIdentity snd_id;
		FF2SoundList list = identity.sndHash.GetList("sound_bgm");
		if( list ) {
			if( res == Plugin_Changed && list.Seek(song, snd_id) && snd_id.time > 0.0 ) {
				strcopy(song, sizeof(song), snd_id.path);
				time = snd_id.time;
			} else if( list.RandomSound(snd_id) && snd_id.time > 0.0 ) {
				strcopy(song, sizeof(song), snd_id.path);
				time = snd_id.time;
				snd_id.PrintToAll();
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

	FF2SoundList list = identity.sndHash.GetList("sound_death");
	FF2SoundIdentity snd_id;
	if( list && list.RandomSound(snd_id) )
		player.PlayVoiceClip(snd_id.path, VSH2_VOICE_LOSE);
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

	FF2SoundIdentity snd_id;
	FF2SoundList list = identity.sndHash.GetList("sound_stabbed");
	if( list && list.RandomSound(snd_id) ) {
		victim.PlayVoiceClip(snd_id.path, VSH2_VOICE_LOSE);
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
		FF2SoundList list = identity.sndHash.GetList("catch_phrase");
		static FF2SoundIdentity snd_id;

		if( list && list.RandomSound(snd_id) )
			strcopy(sample, sizeof(sample), snd_id.path);
		else {
			list = identity.sndHash.GetList("catch_replace");
			if( list ) {
				int max = list.Length;
				int[] entries = new int[max];
				int count;

				for( int i = 0; i < max; i++ ) {
					if( list.At(i, snd_id) && !StrContains(snd_id.path, sample) )
						entries[count++] = i;
				}

				if( count ) {
					int pos = GetRandomInt(0, count - 1);
					if( list.At(entries[pos], snd_id) ) {
						strcopy(sample, sizeof(sample), snd_id.path);
					}
				}
			}
		}

		bool sound_block;
		if( identity.hCfg.GetBool("character.sound_block_vo", sound_block) && sound_block ) {
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

	FF2SoundList list = identity.sndHash.GetList("sound_lastman");
	FF2SoundIdentity snd_id;
	if( list && list.RandomSound(snd_id) ) {
		player.PlayVoiceClip(snd_id.path, VSH2_VOICE_LASTGUY);
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

	int[] points = new int[MaxClients];
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
	
	ff2.m_plugins.UnloadAllSubPlugins();
}

Action OnBossTriggerHurtFF2(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(ToFF2Player(victim).iBossType, identity) )
		return Plugin_Continue;
	return Call_OnTakeDamage_OnBossTriggerHurt(victim.userid, attacker, damage);
}

void OnVariablesResetFF2(const VSH2Player vsh2player)
{
	FF2Player player = ToFF2Player(vsh2player);
	
	player.SetPropAny("bNotifySMAC_CVars", false);
	
	player.iMaxLives = 0;
	player.bNoSuperJump = false;
	player.bNoWeighdown = false;
	player.bHideHUD = false;
	player.SetPropAny("bSupressRAGE", false);
}


int DummyHintPanel(Menu menu, MenuAction action, int param1, int param2)
{
	return;
}