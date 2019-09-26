
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
#define VagineerHit		"saxton_hale/lolwut_5.wav"
#define VagineerRoundStart	"saxton_hale/vagineer_responce_intro.wav"
#define VagineerJump		"saxton_hale/vagineer_responce_jump_"		/// 1-2
#define VagineerRageSound2	"saxton_hale/vagineer_responce_rage_"		/// 1-4
#define VagineerKSpreeNew	"saxton_hale/vagineer_responce_taunt_"		/// 1-5
#define VagineerFail		"saxton_hale/vagineer_responce_fail_"		/// 1-2

#define VAGRAGEDIST		533.333


methodmap CVagineer < BaseBoss
{
	public CVagineer(const int ind, bool uid=false)
	{
		return view_as<CVagineer>( BaseBoss(ind, uid) );
	}

	public void PlaySpawnClip()
	{
		if( !GetRandomInt(0, 1) )
			strcopy(snd, PLATFORM_MAX_PATH, VagineerStart);
		else strcopy(snd, PLATFORM_MAX_PATH, VagineerRoundStart);

		EmitSoundToAll(snd);
	}

	public void Think()
	{
		if( !IsPlayerAlive(this.index) )
			return;

		int buttons = GetClientButtons(this.index);
		//float currtime = GetGameTime();
		int flags = GetEntityFlags(this.index);

		//int maxhp = GetEntProp(this.index, Prop_Data, "m_iMaxHealth");
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
				Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", VagineerJump, GetRandomInt(1, 2));
				
				EmitSoundToAll(snd, this.index, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC);
				EmitSoundToAll(snd, this.index, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC);
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
		
		if( TF2_IsPlayerInCondition(this.index, TFCond_Ubercharged) )
			SetEntProp(this.index, Prop_Data, "m_takedamage", 0);
		else SetEntProp(this.index, Prop_Data, "m_takedamage", 2);
	}
	public void SetModel()
	{
		SetVariantString(VagineerModel);
		AcceptEntityInput(this.index, "SetCustomModel");
		SetEntProp(this.index, Prop_Send, "m_bUseClassAnimations", 1);
		//SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.25);
	}

	public void Death()
	{
		Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", VagineerFail, GetRandomInt(1, 2));
		EmitSoundToAll(snd);
	}

	public void Equip()
	{
		this.SetName("The Vagineer");
		this.RemoveAllItems();
		char attribs[128];
		
		Format(attribs, sizeof(attribs), "68; 2.0; 2; 3.1; 259; 1.0; 436; 1.0; 252; 0.7");
		int SaxtonWeapon = this.SpawnWeapon("tf_weapon_wrench", 169, 100, 5, attribs);
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
	}
	public void RageAbility()
	{
		TF2_AddCondition(this.index, view_as<TFCond>(42), 4.0);
		if( !GetEntProp(this.index, Prop_Send, "m_bIsReadyToHighFive")
			&& !IsValidEntity(GetEntPropEnt(this.index, Prop_Send, "m_hHighFivePartner")) )
		{
			TF2_RemoveCondition(this.index, TFCond_Taunting);
			this.SetModel(); 
		}
		TF2_AddCondition(this.index, TFCond_Ubercharged, 10.0);
		this.DoGenericStun(VAGRAGEDIST);
		if( GetRandomInt(0, 2) )
			strcopy(snd, PLATFORM_MAX_PATH, VagineerRageSound);
		else
			Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", VagineerRageSound2, GetRandomInt(1, 2));
		EmitSoundToAll(snd, this.index, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC); EmitSoundToAll(snd, this.index, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC);
	}

	public void KilledPlayer(const BaseBoss victim, Event event)
	{
		strcopy(snd, PLATFORM_MAX_PATH, VagineerHit);
		EmitSoundToAll(snd, this.index, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC); EmitSoundToAll(snd, this.index, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC);
		
		float curtime = GetGameTime();
		if( curtime <= this.flKillSpree )
			this.iKills++;
		else this.iKills = 0;
		
		if( this.iKills == 3 && GetLivingPlayers(VSH2Team_Red) != 1 ) {
			switch( GetRandomInt(0, 4) ) {
				case 1, 3: strcopy(snd, PLATFORM_MAX_PATH, VagineerKSpree);
				case 2: strcopy(snd, PLATFORM_MAX_PATH, VagineerKSpree2);
				default: Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, GetRandomInt(1, 5));
			}
			EmitSoundToAll(snd, this.index, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC); EmitSoundToAll(snd, this.index, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC);
			this.iKills = 0;
		}
		else this.flKillSpree = curtime+5;
	}
	
	public void Stabbed() {
		EmitSoundToAll("vo/engineer_positivevocalization01.mp3", this.index, _, SNDLEVEL_TRAFFIC);
		EmitSoundToAll("vo/engineer_positivevocalization01.mp3", this.index, _, SNDLEVEL_TRAFFIC);
	}
	
	public void Help()
	{
		if( IsVoteInProgress() )
			return;
		char helpstr[] = "Vagineer:\nSuper Jump: crouch, look up and stand up.\nWeigh-down: in midair, look down and crouch\nRage (Uber): taunt when the Rage Meter is full to stun fairly close-by enemies.";
		Panel panel = new Panel();
		panel.SetTitle(helpstr);
		panel.DrawItem("Exit");
		panel.Send(this.index, HintPanel, 10);
		delete panel;
	}
	public void LastPlayerSoundClip()
	{
		strcopy(snd, PLATFORM_MAX_PATH, VagineerLastA);
		EmitSoundToAll(snd);
	}
};

public CVagineer ToCVagineer (const BaseBoss guy)
{
	return view_as<CVagineer>(guy);
}

public void AddVagToDownloads()
{
	char s[PLATFORM_MAX_PATH];
	int i;
	
	PrepareModel(VagineerModel);
	
	PrepareSound(VagineerLastA);
	PrepareSound(VagineerStart);
	PrepareSound(VagineerRageSound);
	PrepareSound(VagineerKSpree);
	PrepareSound(VagineerKSpree2);
	PrepareSound(VagineerHit);
	PrepareSound(VagineerRoundStart);
	
	for( i=1; i <= 5; i++ ) {
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

public void AddVagToMenu(Menu& menu)
{
	menu.AddItem("1", "Vagineer");
}
