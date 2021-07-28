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


methodmap CHHHJr < BaseBoss {
	public CHHHJr(const int ind, bool uid=false) {
		return view_as< CHHHJr >( BaseBoss(ind, uid) );
	}
	
	public void PlaySpawnClip() {
		char start_snd[PLATFORM_MAX_PATH];
		strcopy(start_snd, PLATFORM_MAX_PATH, "ui/halloween_boss_summoned_fx.wav");
		this.PlayVoiceClip(start_snd, VSH2_VOICE_INTRO);
	}
	
	public void Think()
	{
		if( !IsPlayerAlive(this.index) )
			return;
		
		int buttons = GetClientButtons(this.index);
		float currtime = GetGameTime();
		int flags = GetEntityFlags(this.index);
		
		this.SpeedThink(HALESPEED);
		this.GlowThink(0.1);
		
		if( ((buttons & IN_DUCK) || (buttons & IN_ATTACK2)) && (this.flCharge >= 0.0) ) {
			if( this.flCharge+2.5 < HALEHHH_TELEPORTCHARGE )
				this.flCharge += 2.5;
			else this.flCharge = HALEHHH_TELEPORTCHARGE;
		} else if( this.flCharge < 0.0 )
			this.flCharge += 2.5;
		else {
			float EyeAngles[3]; GetClientEyeAngles(this.index, EyeAngles);
			if( (this.flCharge == HALEHHH_TELEPORTCHARGE || this.bSuperCharge) && EyeAngles[0] < -5.0 ) {
				int target = -1;
				/*int living;
				switch( GetClientTeam(this.index) ) {
					case 2: living = GetLivingPlayers(VSH2Team_Boss);
					case 3: living = GetLivingPlayers(VSH2Team_Red);
				}
				while( living > 0 ) {
					target = GetRandomInt(1, MaxClients);
					if( !IsValidClient(target) || !IsPlayerAlive(target) || target == this.index || GetClientTeam(target) == GetClientTeam(this.index) )
						continue;
					break;
				}*/
				target = GetRandomClient(_, VSH2Team_Red);
				if( target != -1 ) {
					BaseBoss t = BaseBoss(target);
					/// Chdata's HHH teleport rework
					if( t.iTFClass != TFClass_Scout && t.iTFClass != TFClass_Soldier ) {
						/// Makes HHH clipping go away for player and some projectiles
						SetEntProp(this.index, Prop_Send, "m_CollisionGroup", 2);
						SetPawnTimer(HHHTeleCollisionReset, 2.0, this.userid);
					}
					
					CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(this.index, "ghost_appearation", _, false)));
					float pos[3]; GetClientAbsOrigin(target, pos);
					SetEntPropFloat(this.index, Prop_Send, "m_flNextAttack", currtime+2);
					if( GetEntProp(target, Prop_Send, "m_bDucked") ) {
						float collisionvec[3] = {24.0, 24.0, 62.0};
						SetEntPropVector(this.index, Prop_Send, "m_vecMaxs", collisionvec);
						SetEntProp(this.index, Prop_Send, "m_bDucked", 1);
						SetEntityFlags(this.index, flags|FL_DUCKING);
						SetPawnTimer(StunHHH, 0.2, this.userid, GetClientUserId(target));
					}
					else TF2_StunPlayer(this.index, 2.0, 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, target);
					
					TeleportEntity(this.index, pos, NULL_VECTOR, NULL_VECTOR);
					SetEntProp(this.index, Prop_Send, "m_bGlowEnabled", 0);
					CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(this.index, "ghost_appearation")));
					CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(this.index, "ghost_appearation", _, false)));
					
					/// Chdata's HHH teleport rework
					float vPos[3];
					GetEntPropVector(target, Prop_Send, "m_vecOrigin", vPos);
					
					EmitSoundToClient(this.index, "misc/halloween/spell_teleport.wav");
					EmitSoundToClient(target, "misc/halloween/spell_teleport.wav");
					PrintCenterText(target, "You've been teleported!");
					
					this.flCharge = g_vsh2.m_hCvars.HHHTeleCooldown.FloatValue;
				}
				if( this.bSuperCharge )
					this.bSuperCharge = false;
			}
			else this.flCharge = 0.0;
		}
		
		if( OnlyScoutsLeft(VSH2Team_Red) )
			this.flRAGE += g_vsh2.m_hCvars.ScoutRageGen.FloatValue;
		
		if( flags & FL_ONGROUND ) {
			this.flWeighDown = 0.0;
			this.iClimbs = 0;
		}
		else this.flWeighDown += 0.1;
		
		if( (buttons & IN_DUCK) && this.flWeighDown >= 1.0 ) {
			float ang[3]; GetClientEyeAngles(this.index, ang);
			if( ang[0] > 60.0 ) {
				this.WeighDown(0.0);
			}
		}
		SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
		float jmp = this.flCharge;
		int max_climbs = g_vsh2.m_hCvars.HHHMaxClimbs.IntValue;
		if( this.flRAGE >= 100.0 )
			ShowSyncHudText(this.index, g_vsh2.m_hHUDs[PlayerHUD], "Teleport: %i%% | Climbs: %i / %i | Rage: FULL - Call Medic (default: E) to activate", this.bSuperCharge ? 1000 : RoundFloat(jmp) * 2, this.iClimbs, max_climbs);
		else ShowSyncHudText(this.index, g_vsh2.m_hHUDs[PlayerHUD], "Teleport: %i%% | Climbs: %i / %i | Rage: %0.1f", this.bSuperCharge ? 1000 : RoundFloat(jmp) * 2, this.iClimbs, max_climbs, this.flRAGE);
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
		int SaxtonWeapon = this.SpawnWeapon("tf_weapon_sword", 266, 100, 5, attribs);
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
		this.flCharge = g_vsh2.m_hCvars.HHHTeleCooldown.FloatValue * 0.9091;
	}
	public void RageAbility()
	{
		TF2_AddCondition(this.index, view_as< TFCond >(42), 4.0);
		if( !GetEntProp(this.index, Prop_Send, "m_bIsReadyToHighFive")
			&& !IsValidEntity(GetEntPropEnt(this.index, Prop_Send, "m_hHighFivePartner")) )
		{
			TF2_RemoveCondition(this.index, TFCond_Taunting);
			this.SetModel();
		}
		this.DoGenericStun(HALERAGEDIST);
		this.PlayVoiceClip(HHHRage2, VSH2_VOICE_RAGE);
	}
	
	public void KilledPlayer(const BaseBoss victim, Event event) {
		int living = GetLivingPlayers(VSH2Team_Red);
		if( victim.index != this.index ) {
			char kill_snd[PLATFORM_MAX_PATH];
			Format(kill_snd, PLATFORM_MAX_PATH, "%s0%i.mp3", HHHAttack, GetRandomInt(1, 4));
			this.PlayVoiceClip(kill_snd, VSH2_VOICE_SPREE);
		}
		float curtime = GetGameTime();
		if( curtime <= this.flKillSpree )
			this.iKills++;
		else this.iKills = 0;
		
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
	
	public void Help()
	{
		if( IsVoteInProgress() )
			return;
		char helpstr[] = "Horseless Headless Horsemann Jr.:\nTeleporter: crouch, look up and stand up.\nWeigh-down: in midair, look down and crouch\nRage (stun): taunt when Rage is full to stun nearby enemies.";
		Panel panel = new Panel();
		panel.SetTitle(helpstr);
		panel.DrawItem("Exit");
		panel.Send(this.index, HintPanel, 10);
		delete panel;
	}
};

public CHHHJr ToCHHHJr (const BaseBoss guy)
{
	return view_as< CHHHJr >(guy);
}

public void AddHHHToDownloads()
{
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

public void AddHHHToMenu(Menu& menu)
{
	char bossid[5]; IntToString(VSH2Boss_HHHjr, bossid, sizeof(bossid));
	menu.AddItem(bossid, "Horseless Headless Horsemann Jr.");
}

public void HHHTeleCollisionReset(const int userid)
{
	int client = GetClientOfUserId(userid);
	SetEntProp(client, Prop_Send, "m_CollisionGroup", 5); /// Fix HHH's clipping.
}
public void StunHHH(const int userid, const int targetid)
{
	int client = GetClientOfUserId(userid);
	if( !IsValidClient(client) || !IsPlayerAlive(client) )
		return;
	
	int target = GetClientOfUserId(targetid);
	if( !IsValidClient(target) || !IsPlayerAlive(target) )
		target = 0;
	TF2_StunPlayer(client, 2.0, 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, target);
}