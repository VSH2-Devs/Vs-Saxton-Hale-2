/// defines
#define CBSModel		"models/player/saxton_hale/cbs_v4.mdl"
// #define CBSModelPrefix		"models/player/saxton_hale/cbs_v4"

/// CBS voicelines
#define CBS0			"vo/sniper_specialweapon08.mp3"
#define CBS1			"vo/taunts/sniper_taunts02.mp3"
#define CBS2			"vo/sniper_award"
#define CBS3			"vo/sniper_battlecry03.mp3"
#define CBS4			"vo/sniper_domination"
#define CBSJump1		"vo/sniper_specialcompleted02.mp3"

#define CBSTheme		"saxton_hale/the_millionaires_holiday.mp3"

#define CBSRAGEDIST		320.0
#define CBS_MAX_ARROWS		9



methodmap CChristian < BaseBoss {
	public CChristian(const int ind, bool uid=false) {
		return view_as<CChristian>( BaseBoss(ind, uid) );
	}
	
	public void PlaySpawnClip() {
		strcopy(snd, PLATFORM_MAX_PATH, CBS0);
		this.PlayVoiceClip(snd, VSH2_VOICE_INTRO);
	}
	
	public void Think()
	{
		if( !IsPlayerAlive(this.index) )
			return;
		
		int buttons = GetClientButtons(this.index);
		int flags = GetEntityFlags(this.index);
		int health = this.iHealth;
		float speed = HALESPEED + 0.7 * (100-health*100/this.iMaxHealth);
		SetEntPropFloat(this.index, Prop_Send, "m_flMaxspeed", speed);
		
		if( this.flGlowtime > 0.0 ) {
			this.bGlow = 1;
			this.flGlowtime -= 0.1;
		}
		else if( this.flGlowtime <= 0.0 )
			this.bGlow = 0;
		
		if( ((buttons & IN_DUCK) || (buttons & IN_ATTACK2)) && (this.flCharge >= 0.0) ) {
			if( this.flCharge+2.5 < HALE_JUMPCHARGE )
				this.flCharge += 2.5;
			else this.flCharge = HALE_JUMPCHARGE;
		}
		else if( this.flCharge < 0.0 )
			this.flCharge += 2.5;
		else {
			float EyeAngles[3]; GetClientEyeAngles(this.index, EyeAngles);
			if( this.flCharge > 1.0 && EyeAngles[0] < -5.0 ) {
				this.SuperJump(this.flCharge, -100.0);
				strcopy(snd, PLATFORM_MAX_PATH, CBSJump1);
				this.PlayVoiceClip(snd, VSH2_VOICE_ABILITY);
			}
			else this.flCharge = 0.0;
		}
		if( OnlyScoutsLeft(VSH2Team_Red) )
			this.flRAGE += cvarVSH2[ScoutRageGen].FloatValue;
		
		if( flags & FL_ONGROUND )
			this.flWeighDown = 0.0;
		else this.flWeighDown += 0.1;
		
		if( (buttons & IN_DUCK) && this.flWeighDown >= HALE_WEIGHDOWN_TIME ) {
			float ang[3]; GetClientEyeAngles(this.index, ang);
			if( ang[0] > 60.0 ) {
				this.WeighDown(0.0);
			}
		}
		SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
		float jmp = this.flCharge;
		if( jmp > 0.0 )
			jmp *= 4.0;
		if( this.flRAGE >= 100.0 )
			ShowSyncHudText(this.index, hHudText, "Jump: %i | Rage: FULL - Call Medic (default: E) to activate", this.bSuperCharge ? 1000 : RoundFloat(jmp));
		else ShowSyncHudText(this.index, hHudText, "Jump: %i | Rage: %0.1f", this.bSuperCharge ? 1000 : RoundFloat(jmp), this.flRAGE);
	}
	public void SetModel() {
		SetVariantString(CBSModel);
		AcceptEntityInput(this.index, "SetCustomModel");
		SetEntProp(this.index, Prop_Send, "m_bUseClassAnimations", 1);
		//SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.25);
	}
	
	public void Death() {
		//EmitSoundToAll(snd, this.index, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC);
	}
	
	public void Equip() {
		this.SetName("The Christian Brutal Sniper");
		this.RemoveAllItems();
		char attribs[128];
		Format(attribs, sizeof(attribs), "68; 2.0; 2; 3.1; 259; 1.0; 252; 0.7");
		int SaxtonWeapon = this.SpawnWeapon("tf_weapon_club", 171, 100, 5, attribs);
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
	}
	public void RageAbility() {
		TF2_AddCondition(this.index, view_as<TFCond>(42), 4.0);
		if( !GetEntProp(this.index, Prop_Send, "m_bIsReadyToHighFive")
			&& !IsValidEntity(GetEntPropEnt(this.index, Prop_Send, "m_hHighFivePartner")) )
		{
			TF2_RemoveCondition(this.index, TFCond_Taunting);
			this.SetModel();
		}
		this.DoGenericStun(CBSRAGEDIST);

		if( GetRandomInt(0, 1) )
			Format(snd, PLATFORM_MAX_PATH, "%s", CBS1);
		else Format(snd, PLATFORM_MAX_PATH, "%s", CBS3);
		this.PlayVoiceClip(snd, VSH2_VOICE_RAGE);
		
		TF2_RemoveWeaponSlot(this.index, TFWeaponSlot_Primary);
		int bow = this.SpawnWeapon("tf_weapon_compound_bow", 1005, 100, 5, "2; 2.1; 6; 0.5; 37; 0.0; 280; 19; 551; 1");
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", bow); /// 266; 1.0 - penetration
		
		int living = GetLivingPlayers(VSH2Team_Red);
		SetWeaponAmmo(bow, ((living >= CBS_MAX_ARROWS) ? CBS_MAX_ARROWS : living));
	}
	
	public void KilledPlayer(const BaseBoss victim, Event event)
	{
		int living = GetLivingPlayers(VSH2Team_Red);
		if( !GetRandomInt(0, 3) && living != 1 ) {
			switch( TF2_GetPlayerClass(victim.index) ) {
				case TFClass_Spy: {
					strcopy(snd, PLATFORM_MAX_PATH, "vo/sniper_dominationspy04.mp3");
					this.PlayVoiceClip(snd, VSH2_VOICE_SPREE);
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
			weapon = this.SpawnWeapon("tf_weapon_club", clubindex, 100, 5, "68; 2.0; 2; 3.1; 259; 1.0; 252; 0.7");
			SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", weapon);
		}

		float curtime = GetGameTime();
		if( curtime <= this.flKillSpree )
			this.iKills++;
		else this.iKills = 0;
		
		if( this.iKills == 3 && living != 1 ) {
			if( !GetRandomInt(0, 3) )
				Format(snd, PLATFORM_MAX_PATH, CBS0);
			else if( !GetRandomInt(0, 3) )
				Format(snd, PLATFORM_MAX_PATH, CBS1);
			else Format(snd, PLATFORM_MAX_PATH, "%s%02i.mp3", CBS2, GetRandomInt(1, 9));
			this.PlayVoiceClip(snd, VSH2_VOICE_SPREE);
			this.iKills = 0;
		}
		else this.flKillSpree = curtime+5;
	}
	public void Help() {
		if( IsVoteInProgress() )
			return;
		char helpstr[] = "Christian Brutal Sniper:\nSuper Jump: crouch, look up and stand up.\nWeigh-down: in midair, look down and crouch\nRage (Huntsman Bow): taunt when Rage is full (9 arrows).\nVery close-by enemies are stunned.";
		Panel panel = new Panel();
		panel.SetTitle(helpstr);
		panel.DrawItem("Exit");
		panel.Send(this.index, HintPanel, 10);
		delete panel;
	}
	public void LastPlayerSoundClip() {
		if( !GetRandomInt(0, 2) )
			Format(snd, PLATFORM_MAX_PATH, "%s", CBS0);
		else Format(snd, PLATFORM_MAX_PATH, "%s%i.mp3", CBS4, GetRandomInt(1, 25));
		this.PlayVoiceClip(snd, VSH2_VOICE_LASTGUY);
	}
};

public CChristian ToCChristian (const BaseBoss guy)
{
	return view_as<CChristian>(guy);
}

public void AddCBSToDownloads()
{
	char s[PLATFORM_MAX_PATH];
	int i;
	
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
	
	for( i=1; i <= 25; i++ ) {
		if( i <= 9 ) {
			Format(s, PLATFORM_MAX_PATH, "%s%02i.mp3", CBS2, i);
			PrecacheSound(s, true);
		}
		Format(s, PLATFORM_MAX_PATH, "%s%02i.mp3", CBS4, i);
		PrecacheSound(s, true);
	}
	PrecacheSound("vo/sniper_dominationspy04.mp3", true);
}

public void AddCBSToMenu(Menu& menu)
{
	menu.AddItem("2", "Christian Brutal Sniper");
}
