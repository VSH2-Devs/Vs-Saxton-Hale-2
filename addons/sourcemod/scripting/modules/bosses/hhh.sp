#define HHHModel			"models/player/saxton_hale/hhh_jr_mk3.mdl"

/// HHH voicelines
#define HHHLaught			"vo/halloween_boss/knight_laugh"
#define HHHRage				"vo/halloween_boss/knight_attack01.mp3"
#define HHHRage2			"vo/halloween_boss/knight_alert.mp3"
#define HHHAttack			"vo/halloween_boss/knight_attack"
#define HHHPain				"vo/halloween_boss/knight_pain"

#define HHHTheme			"ui/holiday/gamestartup_halloween.mp3"

#define HALEHHH_TELEPORTCHARGETIME     2
#define HALEHHH_TELEPORTCHARGE         (25.0 * HALEHHH_TELEPORTCHARGETIME)


methodmap CHHHJr < BasePlayer {
	public CHHHJr(int ind, bool uid=false) {
		return view_as< CHHHJr >( BasePlayer(ind, uid) );
	}

	public void PlaySpawnClip() {
		char start_snd[PLATFORM_MAX_PATH];
		strcopy(start_snd, PLATFORM_MAX_PATH, "ui/halloween_boss_summoned_fx.wav");
		this.PlayVoiceClip(start_snd, VSH2_VOICE_INTRO);
	}

	public void Think() {
		int client = this.index;
		if( !IsPlayerAlive(client) ) {
			return;
		}
		this.SpeedThink(HALESPEED);
		this.GlowThink(0.1);
		
		float curr_charge  = this.flCharge;
		bool super_charged = this.bSuperCharge;
		float angle_eyes[3]; GetClientEyeAngles(client, angle_eyes);
		if( this.ChargedAbilityThink(2.5, curr_charge, HALEHHH_TELEPORTCHARGE, HALEHHH_TELEPORTCHARGE, IN_DUCK|IN_ATTACK2, angle_eyes[0] < -5.0, super_charged) ) {
			this.TeleToRandomPlayer(g_vsh2.m_hCvars.HHHTeleCooldown.FloatValue, true);
		}
		this.flCharge = curr_charge;
		
		if( this.HasAbility(ABILITY_RAGE) && OnlyScoutsLeft(VSH2Team_Red) ) {
			this.flRAGE += g_vsh2.m_hCvars.ScoutRageGen.FloatValue;
		}
		
		this.WeighDownThink(1.0);
		int flags = GetEntityFlags(client);
		if( flags & FL_ONGROUND ) {
			this.iClimbs = 0;
		}
	}
	public void SetModel() {
		SetVariantString(HHHModel);
		AcceptEntityInput(this.index, "SetCustomModel");
		SetEntProp(this.index, Prop_Send, "m_bUseClassAnimations", 1);
		//SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.25);
	}

	public void Death() {
		char ded_snd[PLATFORM_MAX_PATH];
		Format(ded_snd, PLATFORM_MAX_PATH, "vo/halloween_boss/knight_death0%d.mp3", GetRandomInt(1, 2));
		this.PlayVoiceClip(ded_snd, VSH2_VOICE_LOSE);
	}

	public void Equip() {
		this.SetName("The Horseless Headless Horsemann Jr.");
		this.RemoveAllItems();
		char attribs[128];
		
		Format(attribs, sizeof(attribs), "68; 2.0; 2; 3.1; 259; 1.0; 252; 0.6; 551; 1");
		int boss_weap = this.SpawnWeapon("tf_weapon_sword", 266, 100, 5, attribs);
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", boss_weap);
		this.flCharge = g_vsh2.m_hCvars.HHHTeleCooldown.FloatValue * 0.9091;
		this.GiveAbility(ABILITY_ESCAPE_PLAN);
		this.GiveAbility(ABILITY_GLOW);
		this.GiveAbility(ABILITY_WEIGHDOWN);
		this.GiveAbility(ABILITY_CLIMB_WALLS);
		this.GiveAbility(ABILITY_TELEPORT);
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
		this.DoGenericStun(HALERAGEDIST);
		this.PlayVoiceClip(HHHRage2, VSH2_VOICE_RAGE);
	}

	public void KilledPlayer(BasePlayer victim, Event event) {
		int living = GetLivingPlayers(VSH2Team_Red);
		if( victim.index != this.index ) {
			char kill_snd[PLATFORM_MAX_PATH];
			Format(kill_snd, PLATFORM_MAX_PATH, "%s0%i.mp3", HHHAttack, GetRandomInt(1, 4));
			this.PlayVoiceClip(kill_snd, VSH2_VOICE_SPREE);
		}
		
		float curtime = GetGameTime();
		if( curtime <= this.flKillSpree ) {
			this.iKills++;
		} else {
			this.iKills = 0;
		}
		
		if( this.iKills == 3 && living != 1 ) {
			char spree_snd[PLATFORM_MAX_PATH];
			Format(spree_snd, PLATFORM_MAX_PATH, "%s0%i.mp3", HHHLaught, GetRandomInt(1, 4));
			this.PlayVoiceClip(spree_snd, VSH2_VOICE_SPREE);
			this.iKills = 0;
		}
		else this.flKillSpree = curtime+5;
	}

	public void Stabbed() {
		char stab_snd[PLATFORM_MAX_PATH];
		Format(stab_snd, PLATFORM_MAX_PATH, "vo/halloween_boss/knight_pain0%d.mp3", GetRandomInt(1, 3));
		this.PlayVoiceClip(stab_snd, VSH2_VOICE_STABBED);
	}

	public void Help() {
		if( IsVoteInProgress() )
			return;
		char helpstr[] = "Horseless Headless Horsemann Jr.:\nTeleporter: crouch, look up and stand up.\nWeigh-down: in midair, look down and crouch\nRage (stun): taunt when Rage is full to stun nearby enemies.";
		Panel panel = new Panel();
		panel.SetTitle(helpstr);
		char exit_test[64];
		Format(exit_test, 64, "%T", "Exit", this.index);
		panel.DrawItem(exit_test);
		panel.Send(this.index, HintPanel, 10);
		delete panel;
	}
};

public CHHHJr ToCHHHJr (BasePlayer guy) {
	return view_as< CHHHJr >(guy);
}

public void AddHHHToDownloads() {
	PrepareModel(HHHModel);
	for( int i=1; i <= 4; i++ ) {
		char s[PLATFORM_MAX_PATH];
		Format(s, PLATFORM_MAX_PATH, "%s0%i.mp3", HHHLaught, i);
		PrecacheSound(s, true);
		Format(s, PLATFORM_MAX_PATH, "%s0%i.mp3", HHHAttack, i);
		PrecacheSound(s, true);
		Format(s, PLATFORM_MAX_PATH, "%s0%i.mp3", HHHPain, i);
		PrecacheSound(s, true);
	}
	PrecacheSound(HHHRage, true);
	PrecacheSound(HHHRage2, true);
	PrecacheSound(HHHTheme, true);
	PrecacheSound("ui/halloween_boss_summoned_fx.wav", true);
	PrecacheSound("ui/halloween_boss_defeated_fx.wav", true);
	PrecacheSound("vo/halloween_boss/knight_pain01.mp3", true);
	PrecacheSound("vo/halloween_boss/knight_pain02.mp3", true);
	PrecacheSound("vo/halloween_boss/knight_pain03.mp3", true);
	PrecacheSound("vo/halloween_boss/knight_death01.mp3", true);
	PrecacheSound("vo/halloween_boss/knight_death02.mp3", true);
	PrecacheSound("misc/halloween/spell_teleport.wav", true);
}

public void AddHHHToMenu(Menu& menu) {
	char bossid[5]; IntToString(VSH2Boss_HHHjr, bossid, sizeof(bossid));
	menu.AddItem(bossid, "Horseless Headless Horsemann Jr.");
}