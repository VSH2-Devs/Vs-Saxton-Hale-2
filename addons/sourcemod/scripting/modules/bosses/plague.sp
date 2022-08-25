#define PlagueModel			"models/player/medic.mdl"
#define ZombieModel			"models/player/scout.mdl"


/// voicelines
#define PlagueIntro			"vo/medic_specialcompleted10.mp3"
#define PlagueRage1			"vo/medic_specialcompleted05.mp3"
#define PlagueRage2			"vo/medic_specialcompleted06.mp3"


methodmap CPlague < BaseBoss {
	public CPlague(const int ind, bool uid=false) {
		return view_as<CPlague>( BaseBoss(ind, uid) );
	}
	
	public void PlaySpawnClip() {
		char start_snd[PLATFORM_MAX_PATH];
		strcopy(start_snd, PLATFORM_MAX_PATH, PlagueIntro);
		this.PlayVoiceClip(start_snd, VSH2_VOICE_INTRO);
	}
	
	public void Think() {
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
				this.PlayVoiceClip("vo/medic_yes01.mp3", VSH2_VOICE_ABILITY);
			}
			else this.flCharge = 0.0;
		}
		if( OnlyScoutsLeft(VSH2Team_Red) )
			this.flRAGE += g_vsh2.m_hCvars.ScoutRageGen.FloatValue;
		
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
			ShowSyncHudText(this.index, g_vsh2.m_hHUDs[PlayerHUD], "Jump: %i | Rage: FULL - Call Medic (default: E) to activate", this.bSuperCharge ? 1000 : RoundFloat(jmp));
		else ShowSyncHudText(this.index, g_vsh2.m_hHUDs[PlayerHUD], "Jump: %i | Rage: %0.1f", this.bSuperCharge ? 1000 : RoundFloat(jmp), this.flRAGE);
	}
	public void SetModel() {
		SetVariantString(PlagueModel);
		AcceptEntityInput(this.index, "SetCustomModel");
		SetEntProp(this.index, Prop_Send, "m_bUseClassAnimations", 1);
		//SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.25);
	}
	
	public void Equip() {
		this.SetName("The Plague Doctor");
		this.RemoveAllItems();
		char attribs[128];
		
		Format(attribs, sizeof(attribs), "68; 2.0; 2; 2.5; 259; 1.0; 252; 0.75; 200; 1.0; 551; 1.0");
		int SaxtonWeapon = this.SpawnWeapon("tf_weapon_shovel", 304, 100, 5, attribs);
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
	}
	public void RageAbility()
	{
		int attribute = 0;
		float value = 0.0; 
		TF2_AddCondition(this.index, TFCond_MegaHeal, 10.0);
		switch( GetRandomInt(0, 2) ) {
			case 0: { attribute = 2; value = 2.0; }		/// Extra damage
			case 1: { attribute = 26; value = 100.0; }	/// Extra health
			case 2: { attribute = 107; value = 2.0; }	/// Extra speed
		}
		BaseBoss minion;
		for( int i=MaxClients; i; --i ) {
			if( !IsValidClient(i) || !IsPlayerAlive(i) || GetClientTeam(i) != VSH2Team_Boss )
				continue;
			minion = BaseBoss(i);
			if( minion.bIsMinion ) {
#if defined _tf2attributes_included
				if( g_vsh2.m_hGamemode.bTF2Attribs ) {
					TF2Attrib_SetByDefIndex(i, attribute, value);
					SetPawnTimer(TF2AttribsRemove, 10.0, i);
				}
				else {
					char pdapower[32];
					Format(pdapower, sizeof(pdapower), "%i; %f", attribute, value);
					int wep = minion.SpawnWeapon("tf_weapon_builder", 28, 5, 10, pdapower);
					SetPawnTimer( RemoveWepFromSlot, 10.0, i, GetSlotFromWeapon(i, wep) );
				}
#else
				char pdapower[32];
				Format(pdapower, sizeof(pdapower), "%i; %f", attribute, value);
				int wep = minion.SpawnWeapon("tf_weapon_builder", 28, 5, 10, pdapower);
				SetPawnTimer( RemoveWepFromSlot, 10.0, i, GetSlotFromWeapon(i, wep) );
#endif
			}
		}
	}
	public void KilledPlayer(const BaseBoss victim, Event event) {
		/// GLITCH: suiciding allows boss to become own minion.
		if( this.userid == victim.userid )
			return;
		/// PATCH: Hitting spy with active deadringer turns them into Minion...
		else if( event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER )
			return;
		/// PATCH: killing spy with teammate disguise kills both spy and the teammate he disguised as...
		else if( TF2_IsPlayerInCondition(victim.index, TFCond_Disguised) )
			TF2_RemovePlayerDisguise(victim.index); //event.SetInt("userid", victim.userid);
		victim.iOwnerBoss = this.userid;
		victim.ConvertToMinion(0.4);
	}
	public void RecruitMinion(const BaseBoss base) {
		TF2_SetPlayerClass(base.index, TFClass_Scout, _, false);
		TF2_RemoveAllWeapons(base.index);
#if defined _tf2attributes_included
		if( g_vsh2.m_hGamemode.bTF2Attribs )
			TF2Attrib_RemoveAll(base.index);
#endif
		int weapon = base.SpawnWeapon("tf_weapon_bat", 572, 100, 5, "6; 0.5; 57; 15.0; 26; 75.0; 49; 1.0; 68; -2.0");
		SetEntPropEnt(base.index, Prop_Send, "m_hActiveWeapon", weapon);
		TF2_AddCondition(base.index, TFCond_Ubercharged, 3.0);
		SetEntityHealth(base.index, 200);
		SetVariantString(ZombieModel);
		AcceptEntityInput(base.index, "SetCustomModel");
		SetEntProp(base.index, Prop_Send, "m_bUseClassAnimations", 1);
		SetEntProp(base.index, Prop_Send, "m_nBody", 0);
		SetEntityRenderMode(base.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(base.index, 30, 160, 255, 255);
	}
	public void Help() {
		if( IsVoteInProgress() )
			return;
		char helpstr[] = "Plague Doctor:Kill enemies and turn them into loyal Zombies!\nSuper Jump: crouch, look up and stand up.\nWeigh-down: in midair, look down and crouch\nRage (Powerup Minions): taunt when Rage is full to give powerups to your Zombies.";
		Panel panel = new Panel();
		panel.SetTitle(helpstr);
		panel.DrawItem("Exit");
		panel.Send(this.index, HintPanel, 10);
		delete panel;
	}
};

public CPlague ToCPlague (const BaseBoss guy)
{
	return view_as<CPlague>(guy);
}

public void AddPlagueDocToDownloads()
{
	//char s[PLATFORM_MAX_PATH];
	//int i;
	
	PrecacheModel(PlagueModel, true);
	PrecacheModel(ZombieModel, true);
	
	PrecacheSound(PlagueIntro, true);
	PrecacheSound(PlagueRage1, true);
	PrecacheSound(PlagueRage2, true);
}

public void AddPlagueToMenu(Menu& menu)
{
	//char bossid[5]; IntToString(VSH2Boss_PlagueDoc, bossid, sizeof(bossid));
	//menu.AddItem(bossid, "Plague Doctor");
}

public void TF2AttribsRemove(const int iEntity)
{
#if defined _tf2attributes_included
	TF2Attrib_RemoveAll(iEntity);
#endif
}
public void RemoveWepFromSlot(const int client, const int wepslot)
{
	TF2_RemoveWeaponSlot(client, wepslot);
}
