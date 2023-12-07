/// defines
#define CBSModel		"models/player/saxton_hale/cbs_v4.mdl"
// #define CBSModelPrefix		"models/player/saxton_hale/cbs_v4"

/// Christian Brutal Sniper voicelines
#define CBS0			"vo/sniper_specialweapon08.mp3"
#define CBS1			"vo/taunts/sniper_taunts02.mp3"
#define CBS2			"vo/sniper_award"
#define CBS3			"vo/sniper_battlecry03.mp3"
#define CBS4			"vo/sniper_domination"
#define CBSJump1		"vo/sniper_specialcompleted02.mp3"

#define CBSTheme		"saxton_hale/the_millionaires_holiday.mp3"

#define CBSRAGEDIST		320.0
#define CBS_MAX_ARROWS		9



methodmap CChristian < BasePlayer {
	public CChristian(int ind, bool uid=false) {
		return view_as< CChristian >( BasePlayer(ind, uid) );
	}
	
	public void PlaySpawnClip() {
		this.PlayVoiceClip(CBS0, VSH2_VOICE_INTRO);
	}
	
	public void Think() {
		if( !IsPlayerAlive(this.index) ) {
			return;
		}
		this.SpeedThink(HALESPEED);
		this.GlowThink(0.1);
		if( this.SuperJumpThink(2.5, HALE_JUMPCHARGE) ) {
			this.SuperJump(this.flCharge, -100.0);
			this.PlayVoiceClip(CBSJump1, VSH2_VOICE_ABILITY);
		}
		if( this.HasAbility(ABILITY_RAGE) && OnlyScoutsLeft(VSH2Team_Red) ) {
			this.flRAGE += g_vsh2.m_hCvars.ScoutRageGen.FloatValue;
		}
		this.WeighDownThink(HALE_WEIGHDOWN_TIME);
	}
	public void SetModel() {
		SetVariantString(CBSModel);
		AcceptEntityInput(this.index, "SetCustomModel");
		SetEntProp(this.index, Prop_Send, "m_bUseClassAnimations", 1);
		//SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.25);
	}
	
	public void Death() {
		// char ded_snd[PLATFORM_MAX_PATH];
		//EmitSoundToAll(snd, this.index, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC);
	}
	
	public void Equip() {
		this.SetName("The Christian Brutal Sniper");
		this.RemoveAllItems();
		char attribs[128];
		Format(attribs, sizeof(attribs), "68; 2.0; 2; 3.1; 259; 1.0");
		int boss_weap = this.SpawnWeapon("tf_weapon_club", 171, 100, 5, attribs);
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", boss_weap);
		
		this.GiveAbility(ABILITY_ESCAPE_PLAN);
		this.GiveAbility(ABILITY_GLOW);
		this.GiveAbility(ABILITY_WEIGHDOWN);
		this.GiveAbility(ABILITY_SUPERJUMP);
		this.GiveAbility(ABILITY_STUN_PLYRS);
		this.GiveAbility(ABILITY_STUN_BUILDS);
		this.GiveAbility(ABILITY_ANCHOR);
		this.GiveAbility(ABILITY_RAGE);
	}
	public void RageAbility() {
		TF2_AddCondition(this.index, TFCond_DefenseBuffNoCritBlock, 4.0);
		if( !GetEntProp(this.index, Prop_Send, "m_bIsReadyToHighFive")
			&& !IsValidEntity(GetEntPropEnt(this.index, Prop_Send, "m_hHighFivePartner")) ) {
			TF2_RemoveCondition(this.index, TFCond_Taunting);
			this.SetModel();
		}
		this.DoGenericStun(CBSRAGEDIST);
		this.PlayVoiceClip(GetRandomInt(0, 1)? CBS1 : CBS3, VSH2_VOICE_RAGE);
		
		TF2_RemoveWeaponSlot(this.index, TFWeaponSlot_Primary);
		int bow = this.SpawnWeapon("tf_weapon_compound_bow", 1005, 100, 5, "2 ; 2.1; 6 ; 0.5; 37 ; 0.0; 280 ; 19; 551 ; 1");
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", bow); /// 266; 1.0 - penetration
		int living = GetLivingPlayers(VSH2Team_Red);
		SetWeaponAmmo(bow, ((living >= CBS_MAX_ARROWS)? CBS_MAX_ARROWS : living));
	}
	
	public void KilledPlayer(BasePlayer victim, Event event) {
		int living = GetLivingPlayers(VSH2Team_Red);
		if( !GetRandomInt(0, 3) && living != 1 ) {
			switch( victim.iTFClass ) {
				case TFClass_Spy: {
					this.PlayVoiceClip("vo/sniper_dominationspy04.mp3", VSH2_VOICE_SPREE);
				}
			}
		}
		int weapon = GetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon");
		if( weapon == GetPlayerWeaponSlot(this.index, TFWeaponSlot_Melee) ) {
			TF2_RemoveWeaponSlot(this.index, TFWeaponSlot_Melee);
			int clubindex;
			switch( GetRandomInt(0, 6) ) {
				case 0: clubindex = 171;
				case 1: clubindex = 3;
				case 2: clubindex = 232;
				case 3: clubindex = 401;
				case 4: clubindex = 264;
				case 5: clubindex = 423;
				case 6: clubindex = 474;
			}
			weapon = this.SpawnWeapon("tf_weapon_club", clubindex, 100, 5, "68; 2.0; 2; 3.1; 259; 1.0");
			SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", weapon);
		}
		
		float curtime = GetGameTime();
		if( curtime <= this.flKillSpree ) {
			this.iKills++;
		} else {
			this.iKills = 0;
		}
		if( this.iKills==3 && living != 1 ) {
			char spree_snd[PLATFORM_MAX_PATH];
			if( !GetRandomInt(0, 3) ) {
				Format(spree_snd, PLATFORM_MAX_PATH, CBS0);
			} else if( !GetRandomInt(0, 3) ) {
				Format(spree_snd, PLATFORM_MAX_PATH, CBS1);
			} else {
				Format(spree_snd, PLATFORM_MAX_PATH, "%s%02i.mp3", CBS2, GetRandomInt(1, 9));
			}
			this.PlayVoiceClip(spree_snd, VSH2_VOICE_SPREE);
			this.iKills = 0;
		} else {
			this.flKillSpree = curtime+5;
		}
	}
	public void Help() {
		if( IsVoteInProgress() ) {
			return;
		}
		char helpstr[] = "Christian Brutal Sniper:\nSuper Jump: crouch, look up and stand up.\nWeigh-down: in midair, look down and crouch\nRage (Huntsman Bow): taunt when Rage is full (9 arrows).\nVery close-by enemies are stunned.";
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
		if( !GetRandomInt(0, 2) ) {
			Format(lastguy_snd, PLATFORM_MAX_PATH, "%s", CBS0);
		} else {
			Format(lastguy_snd, PLATFORM_MAX_PATH, "%s%i.mp3", CBS4, GetRandomInt(1, 25));
		}
		this.PlayVoiceClip(lastguy_snd, VSH2_VOICE_LASTGUY);
	}
};

public CChristian ToCChristian (BasePlayer guy) {
	return view_as< CChristian >(guy);
}

public void AddCBSToDownloads() {
	PrepareModel(CBSModel);
	PrepareMaterial("materials/models/player/saxton_hale/sniper_red");
	PrepareMaterial("materials/models/player/saxton_hale/sniper_lens");
	PrepareMaterial("materials/models/player/saxton_hale/sniper_head");
	PrepareMaterial("materials/models/player/saxton_hale/sniper_head_red");

	PrecacheSound(CBS0, true);
	PrecacheSound(CBS1, true);
	PrecacheSound(CBS3, true);
	PrecacheSound(CBSJump1, true);
	PrepareSound(CBSTheme);

	for( int i=1; i <= 25; i++ ) {
		char s[PLATFORM_MAX_PATH];
		if( i <= 9 ) {
			Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", CBS2, i);
			PrecacheSound(s, true);
		}
		Format(s, PLATFORM_MAX_PATH, "%s%i.mp3", CBS4, i);
		PrecacheSound(s, true);
	}
	PrecacheSound("vo/sniper_dominationspy04.mp3", true);
}

public void AddCBSToMenu(Menu& menu) {
	char bossid[5]; IntToString(VSH2Boss_CBS, bossid, sizeof(bossid));
	menu.AddItem(bossid, "Christian Brutal Sniper");
}
