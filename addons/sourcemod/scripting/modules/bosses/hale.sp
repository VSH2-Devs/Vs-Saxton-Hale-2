/// defines
/// models
// #define HaleModel		"models/player/saxton_hale/saxton_hale.mdl"
// #define HaleModelPrefix		"models/player/saxton_hale/saxton_hale"
#define HaleModel				"models/player/saxton_hale_jungle_inferno/saxton_hale.mdl"

/// materials
static const char HaleMatsV2[][] = {
	/*
	"materials/models/player/saxton_test4/eyeball_l.vmt",
	"materials/models/player/saxton_test4/eyeball_r.vmt",
	"materials/models/player/saxton_test4/halebody.vmt",
	"materials/models/player/saxton_test4/halebody.vtf",
	"materials/models/player/saxton_test4/halebodyexponent.vtf",
	"materials/models/player/saxton_test4/halehead.vmt",
	"materials/models/player/saxton_test4/halehead.vtf",
	"materials/models/player/saxton_test4/haleheadexponent.vtf",
	"materials/models/player/saxton_test4/halenormal.vtf",
	"materials/models/player/saxton_test4/halephongmask.vtf"
	//"materials/models/player/saxton_test4/halegibs.vmt",
	//"materials/models/player/saxton_test4/halegibs.vtf"
	*/

	"materials/models/player/saxton_hale/hale_misc_normal.vtf",
	"materials/models/player/saxton_hale/hale_body_normal.vtf",
	"materials/models/player/saxton_hale/eyeball_l.vmt",
	"materials/models/player/saxton_hale/eyeball_r.vmt",
	"materials/models/player/saxton_hale/hale_egg.vtf",
	"materials/models/player/saxton_hale/hale_egg.vmt",
	"materials/models/player/hwm_saxton_hale/saxton_belt.vmt",
	"materials/models/player/hwm_saxton_hale/saxton_belt_high.vmt",
	"materials/models/player/hwm_saxton_hale/saxton_belt_high.vtf",
	"materials/models/player/hwm_saxton_hale/saxton_belt_high_normal.vtf",
	"materials/models/player/hwm_saxton_hale/saxton_body.vmt",
	"materials/models/player/hwm_saxton_hale/saxton_body.vtf",
	"materials/models/player/hwm_saxton_hale/saxton_body_alt.vmt",
	"materials/models/player/hwm_saxton_hale/saxton_body_exp.vtf",
	"materials/models/player/hwm_saxton_hale/saxton_body_normal.vtf",
	"materials/models/player/hwm_saxton_hale/saxton_body_saxxy.vmt",
	"materials/models/player/hwm_saxton_hale/saxton_body_saxxy.vtf",
	"materials/models/player/hwm_saxton_hale/saxton_hat_color.vmt",
	"materials/models/player/hwm_saxton_hale/saxton_hat_color.vtf",
	"materials/models/player/hwm_saxton_hale/saxton_hat_saxxy.vmt",
	"materials/models/player/hwm_saxton_hale/saxton_hat_saxxy.vtf",
	"materials/models/player/hwm_saxton_hale/tongue_saxxy.vmt",
	"materials/models/player/hwm_saxton_hale/hwm/saxton_head.vmt",
	"materials/models/player/hwm_saxton_hale/hwm/saxton_head.vtf",
	"materials/models/player/hwm_saxton_hale/hwm/saxton_head_exponent.vtf",
	"materials/models/player/hwm_saxton_hale/hwm/saxton_head_normal.vtf",
	"materials/models/player/hwm_saxton_hale/hwm/saxton_head_saxxy.vmt",
	"materials/models/player/hwm_saxton_hale/hwm/saxton_head_saxxy.vtf",
	"materials/models/player/hwm_saxton_hale/hwm/tongue.vmt",
	"materials/models/player/hwm_saxton_hale/hwm/tongue.vtf",
	"materials/models/player/hwm_saxton_hale/shades/eye.vtf",
	"materials/models/player/hwm_saxton_hale/shades/eyeball_l.vmt",
	"materials/models/player/hwm_saxton_hale/shades/eyeball_r.vmt",
	"materials/models/player/hwm_saxton_hale/shades/eyeball_saxxy.vmt",
	"materials/models/player/hwm_saxton_hale/shades/eye-extra.vtf",
	"materials/models/player/hwm_saxton_hale/shades/eye-saxxy.vtf",
	"materials/models/player/hwm_saxton_hale/shades/inv.vmt",
	"materials/models/player/hwm_saxton_hale/shades/null.vtf"
};


/// Saxton Hale voicelines
#define HaleComicArmsFallSound	"saxton_hale/saxton_hale_responce_2.wav"
#define HaleLastB		"vo/announcer_am_lastmanalive"
#define HaleKSpree		"saxton_hale/saxton_hale_responce_3.wav"
#define HaleKSpree2		"saxton_hale/saxton_hale_responce_4.wav"		/// this line is broken and unused
#define HaleRoundStart		"saxton_hale/saxton_hale_responce_start"	/// 1-5
#define HaleJump		"saxton_hale/saxton_hale_responce_jump"			/// 1-2
#define HaleRageSound		"saxton_hale/saxton_hale_responce_rage"		/// 1-4
#define HaleKillMedic		"saxton_hale/saxton_hale_responce_kill_medic.wav"
#define HaleKillSniper1		"saxton_hale/saxton_hale_responce_kill_sniper1.wav"
#define HaleKillSniper2		"saxton_hale/saxton_hale_responce_kill_sniper2.wav"
#define HaleKillSpy1		"saxton_hale/saxton_hale_responce_kill_spy1.wav"
#define HaleKillSpy2		"saxton_hale/saxton_hale_responce_kill_spy2.wav"
#define HaleKillEngie1		"saxton_hale/saxton_hale_responce_kill_eggineer1.wav"
#define HaleKillEngie2		"saxton_hale/saxton_hale_responce_kill_eggineer2.wav"
#define HaleKSpreeNew		"saxton_hale/saxton_hale_responce_spree"  /// 1-5
#define HaleWin			"saxton_hale/saxton_hale_responce_win"		  /// 1-2
#define HaleLastMan		"saxton_hale/saxton_hale_responce_lastman"  /// 1-5
#define HaleFail		"saxton_hale/saxton_hale_responce_fail"			/// 1-3
#define HaleJump132		"saxton_hale/saxton_hale_132_jump_" //1-2
#define HaleStart132		"saxton_hale/saxton_hale_132_start_"   /// 1-5
#define HaleKillDemo132		"saxton_hale/saxton_hale_132_kill_demo.wav"
#define HaleKillEngie132	"saxton_hale/saxton_hale_132_kill_engie_" /// 1-2
#define HaleKillHeavy132	"saxton_hale/saxton_hale_132_kill_heavy.wav"
#define HaleKillScout132	"saxton_hale/saxton_hale_132_kill_scout.wav"
#define HaleKillSpy132		"saxton_hale/saxton_hale_132_kill_spie.wav"
#define HaleKillPyro132		"saxton_hale/saxton_hale_132_kill_w_and_m1.wav"
#define HaleSappinMahSentry132	"saxton_hale/saxton_hale_132_kill_toy.wav"
#define HaleKillKSpree132	"saxton_hale/saxton_hale_132_kspree_"	/// 1-2
#define HaleKillLast132		"saxton_hale/saxton_hale_132_last.wav"
#define HaleStubbed132		"saxton_hale/saxton_hale_132_stub_"  /// 1-4

#define HALESPEED		340.0

#define HALE_JUMPCHARGE		(25*1.0)
#define HALERAGEDIST		800.0
#define HALE_WEIGHDOWN_TIME	3.0


methodmap CHale < BasePlayer {
	public CHale(int ind, bool uid=false) {
		return view_as< CHale >( BasePlayer(ind, uid) );
	}
	
	public void PlaySpawnClip() {
		char start_snd[PLATFORM_MAX_PATH];
		if( !GetRandomInt(0, 1) ) {
			Format(start_snd, PLATFORM_MAX_PATH, "%s%i.wav", HaleRoundStart, GetRandomInt(1, 5));
		} else {
			Format(start_snd, PLATFORM_MAX_PATH, "%s%i.wav", HaleStart132, GetRandomInt(1, 5));
		}
		this.PlayVoiceClip(start_snd, VSH2_VOICE_INTRO);
	}

	public void Think() {
		if( !IsPlayerAlive(this.index) ) {
			return;
		}
		this.SpeedThink(HALESPEED);
		this.GlowThink(0.1);
		if( this.SuperJumpThink(2.5, HALE_JUMPCHARGE) ) {
			this.SuperJump(this.flCharge, -100.0);
			char jump_snd[PLATFORM_MAX_PATH];
			Format(jump_snd, PLATFORM_MAX_PATH, "%s%i.wav", GetRandomInt(0, 1)? HaleJump : HaleJump132, GetRandomInt(1, 2));
			this.PlayVoiceClip(jump_snd, VSH2_VOICE_ABILITY);
		}
		if( this.HasAbility(ABILITY_RAGE) && OnlyScoutsLeft(VSH2Team_Red) ) {
			this.flRAGE += g_vsh2.m_hCvars.ScoutRageGen.FloatValue;
		}
		this.WeighDownThink(HALE_WEIGHDOWN_TIME);
	}
	public void SetModel() {
		SetVariantString(HaleModel);
		AcceptEntityInput(this.index, "SetCustomModel");
		SetEntProp(this.index, Prop_Send, "m_bUseClassAnimations", 1);
		//SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.25);
	}
	
	public void Death() {
		char ded_snd[PLATFORM_MAX_PATH];
		Format(ded_snd, PLATFORM_MAX_PATH, "%s%i.wav", HaleFail, GetRandomInt(1, 3));
		this.PlayVoiceClip(ded_snd, VSH2_VOICE_LOSE);
	}
	
	public void Equip() {
		this.SetName("Saxton Hale");
		this.RemoveAllItems();
		char attribs[128];
		Format(attribs, sizeof(attribs), "68 ; 2.0; 2 ; 3.1; 259 ; 1.0; 252 ; 0.6; 214 ; %d", GetRandomInt(999, 9999));
		int boss_weap = this.SpawnWeapon("tf_weapon_shovel", 5, 100, 5, attribs);
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", boss_weap);
		this.GiveAbility(ABILITY_ESCAPE_PLAN);
		this.GiveAbility(ABILITY_GLOW);
		this.GiveAbility(ABILITY_WEIGHDOWN);
		this.GiveAbility(ABILITY_SUPERJUMP);
		this.GiveAbility(ABILITY_STUN_BUILDS);
		this.GiveAbility(ABILITY_STUN_PLYRS);
		this.GiveAbility(ABILITY_ANCHOR);
		this.GiveAbility(ABILITY_RAGE);
	}
	public void RageAbility() {
		TF2_AddCondition(this.index, TFCond_DefenseBuffNoCritBlock, 4.0);
		if( !GetEntProp(this.index, Prop_Send, "m_bIsReadyToHighFive")
			&& !IsValidEntity(GetEntPropEnt(this.index, Prop_Send, "m_hHighFivePartner")) ) {
			TF2_RemoveCondition(this.index, TFCond_Taunting);
			this.SetModel(); /// should reset Hale's animation
		}
		this.DoGenericStun(HALERAGEDIST);
		char rage_snd[PLATFORM_MAX_PATH];
		Format(rage_snd, PLATFORM_MAX_PATH, "%s%i.wav", HaleRageSound, GetRandomInt(1, 4));
		this.PlayVoiceClip(rage_snd, VSH2_VOICE_RAGE);
	}
	public void KilledPlayer(BasePlayer victim, Event event) {
		if( !GetRandomInt(0, 2) ) {
			char kill_snd[PLATFORM_MAX_PATH];
			switch( victim.iTFClass ) {
				case TFClass_Scout:   strcopy(kill_snd, PLATFORM_MAX_PATH, HaleKillScout132);
				case TFClass_Pyro:    strcopy(kill_snd, PLATFORM_MAX_PATH, HaleKillPyro132);
				case TFClass_DemoMan: strcopy(kill_snd, PLATFORM_MAX_PATH, HaleKillDemo132);
				case TFClass_Heavy:   strcopy(kill_snd, PLATFORM_MAX_PATH, HaleKillHeavy132);
				case TFClass_Medic:   strcopy(kill_snd, PLATFORM_MAX_PATH, HaleKillMedic);
				case TFClass_Sniper:  strcopy(kill_snd, PLATFORM_MAX_PATH, GetRandomInt(0, 1)? HaleKillSniper1 : HaleKillSniper2);
				case TFClass_Spy: {
					switch( GetRandomInt(0, 2) ) {
						case 0: strcopy(kill_snd, PLATFORM_MAX_PATH, HaleKillSpy132);
						case 1: strcopy(kill_snd, PLATFORM_MAX_PATH, HaleKillSpy2);
						case 2: strcopy(kill_snd, PLATFORM_MAX_PATH, HaleKillSpy1);
					}
				}
				case TFClass_Engineer: {
					switch( GetRandomInt(0, 3) ) {
						case 0: strcopy(kill_snd, PLATFORM_MAX_PATH, HaleKillEngie1);
						case 1: strcopy(kill_snd, PLATFORM_MAX_PATH, HaleKillEngie2);
						default: {
							Format(kill_snd, PLATFORM_MAX_PATH, "%s%i.wav", HaleKillEngie132, GetRandomInt(1, 2));
						}
					}
				}
			}
			if( kill_snd[0] != '\0' ) {
				this.PlayVoiceClip(kill_snd, VSH2_VOICE_SPREE);
			}
		}
		
		float curtime = GetGameTime();
		if( curtime <= this.flKillSpree ) {
			this.iKills++;
		} else {
			this.iKills = 0;
		}
		if( this.iKills==3 && GetLivingPlayers(VSH2Team_Red) != 1 ) {
			char spree_snd[PLATFORM_MAX_PATH];
			int randsound = GetRandomInt(0, 7);
			if( !randsound || randsound == 1 ) {
				strcopy(spree_snd, PLATFORM_MAX_PATH, HaleKSpree);
			} else if( randsound < 5 && randsound > 1 ) {
				Format(spree_snd, PLATFORM_MAX_PATH, "%s%i.wav", HaleKSpreeNew, GetRandomInt(1, 5));
			} else {
				Format(spree_snd, PLATFORM_MAX_PATH, "%s%i.wav", HaleKillKSpree132, GetRandomInt(1, 2));
			}
			this.PlayVoiceClip(spree_snd, VSH2_VOICE_SPREE);
			this.iKills = 0;
		} else {
			this.flKillSpree = curtime + 5;
		}
	}
	
	public void Stabbed() {
		char stab_snd[PLATFORM_MAX_PATH];
		Format(stab_snd, PLATFORM_MAX_PATH, "%s%i.wav", HaleStubbed132, GetRandomInt(1, 4));
		this.PlayVoiceClip(stab_snd, VSH2_VOICE_STABBED);
	}
	public void Help() {
		if( IsVoteInProgress() ) {
			return;
		}
		char helpstr[] = "Saxton Hale:\nSuper Jump: crouch, look up and stand up.\nWeigh-down: in midair, look down and crouch\nRage (stun): taunt when the Rage is full to stun nearby enemies.";
		Panel panel = new Panel();
		panel.SetTitle(helpstr);
		char exit_test[64];
		Format(exit_test, 64, "%T", "Exit", this.index);
		panel.DrawItem(exit_test);
		panel.Send(this.index, HintPanel, 10);
		delete panel;
	}
	public void LastPlayerSoundClip() {
		char lastguy_snd[PLATFORM_MAX_PATH];
		switch( GetRandomInt(0, 5) ) {
			case 0:  strcopy(lastguy_snd, PLATFORM_MAX_PATH, HaleComicArmsFallSound);
			case 1:  Format(lastguy_snd, PLATFORM_MAX_PATH, "%s0%i.wav", HaleLastB, GetRandomInt(1, 4));
			case 2:  strcopy(lastguy_snd, PLATFORM_MAX_PATH, HaleKillLast132);
			default: Format(lastguy_snd, PLATFORM_MAX_PATH, "%s%i.wav", HaleLastMan, GetRandomInt(1, 5));
		}
		this.PlayVoiceClip(lastguy_snd, VSH2_VOICE_LASTGUY);
	}
	public void KillToy() {
		if( !GetRandomInt(0, 3) ) {
			this.PlayVoiceClip(HaleSappinMahSentry132, VSH2_VOICE_SPREE);
		}
	}
	public void PlayWinSound() {
		char victory[PLATFORM_MAX_PATH];
		Format(victory, PLATFORM_MAX_PATH, "%s%i.wav", HaleWin, GetRandomInt(1, 2));
		this.PlayVoiceClip(victory, VSH2_VOICE_WIN);
	}
};

public CHale ToCHale(BasePlayer guy) {
	return view_as< CHale >(guy);
}

public void AddHaleToDownloads() {
	char s[PLATFORM_MAX_PATH];
	int i;
	
	PrepareModel(HaleModel);
	DownloadMaterialList(HaleMatsV2, sizeof(HaleMatsV2));
	PrepareSound(HaleComicArmsFallSound);
	PrepareSound(HaleKSpree);
	for( i=1; i <= 4; i++ ) {
		Format(s, PLATFORM_MAX_PATH, "%s0%i.wav", HaleLastB, i);
		PrecacheSound(s, true);
	}
	
	PrepareSound(HaleKillMedic);
	PrepareSound(HaleKillSniper1);
	PrepareSound(HaleKillSniper2);
	PrepareSound(HaleKillSpy1);
	PrepareSound(HaleKillSpy2);
	PrepareSound(HaleKillEngie1);
	PrepareSound(HaleKillEngie2);
	PrepareSound(HaleKillDemo132);
	PrepareSound(HaleKillHeavy132);
	PrepareSound(HaleKillScout132);
	PrepareSound(HaleKillSpy132);
	PrepareSound(HaleKillPyro132);
	PrepareSound(HaleKillDemo132);
	PrepareSound(HaleKillDemo132);
	PrepareSound(HaleKillDemo132);
	PrepareSound(HaleKillDemo132);
	PrepareSound(HaleKillDemo132);
	PrepareSound(HaleSappinMahSentry132);
	PrepareSound(HaleKillLast132);
	
	for( i=1; i <= 5; i++ ) {
		if( i <= 2 ) {
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleJump, i);
			PrepareSound(s);

			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleWin, i);
			PrepareSound(s);

			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleJump132, i);
			PrepareSound(s);

			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleKillEngie132, i);
			PrepareSound(s);

			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleKillKSpree132, i);
			PrepareSound(s);
		}
		if( i <= 3 ) {
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleFail, i);
			PrepareSound(s);
		}

		if( i <= 4 ) {
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleRageSound, i);
			PrepareSound(s);

			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleStubbed132, i);
			PrepareSound(s);
		}

		Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleRoundStart, i);
		PrepareSound(s);

		Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleKSpreeNew, i);
		PrepareSound(s);

		Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleLastMan, i);
		PrepareSound(s);

		Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleStart132, i);
		PrepareSound(s);
	}
}

public void AddHaleToMenu(Menu& menu) {
	char bossid[5]; IntToString(VSH2Boss_Hale, bossid, sizeof(bossid));
	menu.AddItem(bossid, "Saxton Hale");
}

public void EnableSG(int sentry_ref) {
	int i = EntRefToEntIndex(sentry_ref);
	if( !IsValidEntity(i) ) {
		return;
	}
	
	char s[32]; GetEdictClassname(i, s, sizeof(s));
	if( StrEqual(s, "obj_sentrygun") ) {
		SetEntProp(i, Prop_Send, "m_bDisabled", 0);
		int higher = MaxClients+1;
		for( int ent=2048; ent > higher; ent-- ) {
			if( !IsValidEntity(ent) || ent <= 0 ) {
				continue;
			}
			char s2[32]; GetEdictClassname(ent, s2, sizeof(s2));
			if( StrEqual(s2, "info_particle_system") && GetOwner(ent)==i ) {
				AcceptEntityInput(ent, "Kill");
			}
		}
	}
}