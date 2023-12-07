
/// defines
/*
#define VagineerModel		"models/player/saxton_hale/vagineer_v134.mdl"
#define VagineerModelPrefix	"models/player/saxton_hale/vagineer_v134"
*/

#define VagineerModel		"models/player/saxton_hale/vagineer_v150.mdl"
// #define VagineerModelPrefix	"models/player/saxton_hale/vagineer_v150"


/// Vagineer voicelines
#define VagineerLastA		"saxton_hale/lolwut_0.wav"
#define VagineerRageSound	"saxton_hale/lolwut_2.wav"
#define VagineerStart		"saxton_hale/lolwut_1.wav"
#define VagineerKSpree		"saxton_hale/lolwut_3.wav"
#define VagineerKSpree2		"saxton_hale/lolwut_4.wav"
#define VagineerHit			"saxton_hale/lolwut_5.wav"
#define VagineerRoundStart	"saxton_hale/vagineer_responce_intro.wav"
#define VagineerJump		"saxton_hale/vagineer_responce_jump_"		/// 1-2
#define VagineerRageSound2	"saxton_hale/vagineer_responce_rage_"		/// 1-4
#define VagineerKSpreeNew	"saxton_hale/vagineer_responce_taunt_"		/// 1-5
#define VagineerFail		"saxton_hale/vagineer_responce_fail_"		/// 1-2

#define VAGRAGEDIST     533.333


methodmap CVagineer < BasePlayer {
	public CVagineer(int ind, bool uid=false) {
		return view_as< CVagineer >( BasePlayer(ind, uid) );
	}

	public void PlaySpawnClip() {
		char start_snd[PLATFORM_MAX_PATH];
		if( !GetRandomInt(0, 1) ) {
			strcopy(start_snd, PLATFORM_MAX_PATH, VagineerStart);
		} else {
			strcopy(start_snd, PLATFORM_MAX_PATH, VagineerRoundStart);
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
			char gottam_snd[PLATFORM_MAX_PATH];
			Format(gottam_snd, PLATFORM_MAX_PATH, "%s%i.wav", VagineerJump, GetRandomInt(1, 2));
			this.PlayVoiceClip(gottam_snd, VSH2_VOICE_ABILITY);
		}
		if( this.HasAbility(ABILITY_RAGE) && OnlyScoutsLeft(VSH2Team_Red) ) {
			this.flRAGE += g_vsh2.m_hCvars.ScoutRageGen.FloatValue;
		}
		this.WeighDownThink(HALE_WEIGHDOWN_TIME);
	}
	
	public void SetModel() {
		SetVariantString(VagineerModel);
		AcceptEntityInput(this.index, "SetCustomModel");
		SetEntProp(this.index, Prop_Send, "m_bUseClassAnimations", 1);
		//SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.25);
	}
	
	public void Death() {
		char ded_snd[PLATFORM_MAX_PATH];
		Format(ded_snd, PLATFORM_MAX_PATH, "%s%i.wav", VagineerFail, GetRandomInt(1, 2));
		this.PlayVoiceClip(ded_snd, VSH2_VOICE_LOSE);
	}
	
	public void Equip() {
		this.SetName("The Vagineer");
		this.RemoveAllItems();
		char attribs[128]; Format(attribs, sizeof(attribs), "68; 2.0; 2; 3.1; 259; 1.0; 436; 1.0");
		int boss_weap = this.SpawnWeapon("tf_weapon_wrench", 169, 100, 5, attribs);
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", boss_weap);
		this.GiveAbility(ABILITY_ESCAPE_PLAN);
		this.GiveAbility(ABILITY_GLOW);
		this.GiveAbility(ABILITY_WEIGHDOWN);
		this.GiveAbility(ABILITY_SUPERJUMP);
		this.GiveAbility(ABILITY_POWER_UBER);
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
		TF2_AddCondition(this.index, TFCond_Ubercharged, g_vsh2.m_hCvars.VagineerUberTime.FloatValue);
		this.DoGenericStun(VAGRAGEDIST);
		char rage_snd[PLATFORM_MAX_PATH];
		if( GetRandomInt(0, 2) ) {
			strcopy(rage_snd, PLATFORM_MAX_PATH, VagineerRageSound);
		} else {
			Format(rage_snd, PLATFORM_MAX_PATH, "%s%i.wav", VagineerRageSound2, GetRandomInt(1, 2));
		}
		this.PlayVoiceClip(rage_snd, VSH2_VOICE_RAGE);
	}
	
	public void KilledPlayer(BasePlayer victim, Event event) {
		char wrench_hit_snd[PLATFORM_MAX_PATH];
		strcopy(wrench_hit_snd, PLATFORM_MAX_PATH, VagineerHit);
		this.PlayVoiceClip(wrench_hit_snd, VSH2_VOICE_SPREE);
		float curtime = GetGameTime();
		if( curtime <= this.flKillSpree ) {
			this.iKills++;
		} else {
			this.iKills = 0;
		}
		
		if( this.iKills == 3 && GetLivingPlayers(VSH2Team_Red) != 1 ) {
			char spree_snd[PLATFORM_MAX_PATH];
			switch( GetRandomInt(0, 4) ) {
				case 1, 3: strcopy(spree_snd, PLATFORM_MAX_PATH, VagineerKSpree);
				case 2: strcopy(spree_snd, PLATFORM_MAX_PATH, VagineerKSpree2);
				default: Format(spree_snd, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, GetRandomInt(1, 5));
			}
			this.PlayVoiceClip(spree_snd, VSH2_VOICE_SPREE);
			this.iKills = 0;
		} else {
			this.flKillSpree = curtime+5;
		}
	}
	
	public void Stabbed() {
		this.PlayVoiceClip("vo/engineer_positivevocalization01.mp3", VSH2_VOICE_STABBED);
	}
	
	public void Help() {
		if( IsVoteInProgress() ) {
			return;
		}
		
		char helpstr[] = "Vagineer:\nSuper Jump: crouch, look up and stand up.\nWeigh-down: in midair, look down and crouch\nRage (Uber): taunt when the Rage Meter is full to stun fairly close-by enemies.";
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
		strcopy(lastguy_snd, PLATFORM_MAX_PATH, VagineerLastA);
		this.PlayVoiceClip(lastguy_snd, VSH2_VOICE_LASTGUY);
	}
	public void PlayWinSound() {
		char victory[PLATFORM_MAX_PATH];
		Format(victory, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, GetRandomInt(1, 5));
		this.PlayVoiceClip(victory, VSH2_VOICE_WIN);
	}
};

public CVagineer ToCVagineer(BasePlayer guy) {
	return view_as< CVagineer >(guy);
}

public void AddVagToDownloads() {
	PrepareModel(VagineerModel);
	PrepareSound(VagineerLastA);
	PrepareSound(VagineerStart);
	PrepareSound(VagineerRageSound);
	PrepareSound(VagineerKSpree);
	PrepareSound(VagineerKSpree2);
	PrepareSound(VagineerHit);
	PrepareSound(VagineerRoundStart);
	for( int i=1; i <= 5; i++ ) {
		char s[PLATFORM_MAX_PATH];
		if( i <= 2 ) {
			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerJump, i);
			PrepareSound(s);

			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerRageSound2, i);
			PrepareSound(s);

			Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerFail, i);
			PrepareSound(s);
		}
		Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, i);
		PrepareSound(s);
	}
	PrecacheSound("vo/engineer_positivevocalization01.mp3", true);
}

public void AddVagToMenu(Menu& menu) {
	char bossid[5]; IntToString(VSH2Boss_Vagineer, bossid, sizeof(bossid));
	menu.AddItem(bossid, "Vagineer");
}
