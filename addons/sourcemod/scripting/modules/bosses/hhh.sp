#define HHHModel			"models/player/saxton_hale/hhh_jr_mk3.mdl"
// #define HHHModelPrefix			"models/player/saxton_hale/hhh_jr_mk3"

//HHH voicelines
#define HHHLaught			"vo/halloween_boss/knight_laugh"
#define HHHRage				"vo/halloween_boss/knight_attack01.mp3"
#define HHHRage2			"vo/halloween_boss/knight_alert.mp3"
#define HHHAttack			"vo/halloween_boss/knight_attack"
#define HHHPain				"vo/halloween_boss/knight_pain"


#define HHHTheme			"ui/holiday/gamestartup_halloween.mp3"

#define HALEHHH_TELEPORTCHARGETIME	2
#define HALEHHH_TELEPORTCHARGE		(25.0 * HALEHHH_TELEPORTCHARGETIME)


methodmap CHHHJr < BaseBoss
{
	public CHHHJr(const int ind, bool uid = false)
	{
		if (uid)
			return view_as<CHHHJr>( BaseBoss(ind, true) );
		return view_as<CHHHJr>( BaseBoss(ind) );
	}

	public void PlaySpawnClip()
	{
		strcopy(snd, PLATFORM_MAX_PATH, "ui/halloween_boss_summoned_fx.wav");
		EmitSoundToAll(snd);
	}

	public void Think ()
	{
		if ( not IsPlayerAlive(this.index) )
			return;

		int buttons = GetClientButtons(this.index);
		float currtime = GetGameTime();
		int flags = GetEntityFlags(this.index);

		//int maxhp = GetEntProp(this.index, Prop_Data, "m_iMaxHealth");
		int health = this.iHealth;
		float speed = HALESPEED + 0.7 * (100-health*100/this.iMaxHealth);
		SetEntPropFloat(this.index, Prop_Send, "m_flMaxspeed", speed);

		if (this.flGlowtime > 0.0) {
			this.bGlow = 1;
			this.flGlowtime -= 0.1;
		}
		else if (this.flGlowtime <= 0.0)
			this.bGlow = 0;

		if ( ((buttons & IN_DUCK) or (buttons & IN_ATTACK2)) and (this.flCharge >= 0.0) )
		{
			if (this.flCharge+2.5 < HALEHHH_TELEPORTCHARGE)
				this.flCharge += 2.5;
			else this.flCharge = HALEHHH_TELEPORTCHARGE;
		}
		else if (this.flCharge < 0.0)
			this.flCharge += 2.5;
		else {
			float EyeAngles[3]; GetClientEyeAngles(this.index, EyeAngles);
			if ( this.flCharge is HALEHHH_TELEPORTCHARGE and EyeAngles[0] < -5.0 ) {
				int living;
				switch (GetClientTeam(this.index))
				{
					case 2: living = GetLivingPlayers(3);
					case 3: living = GetLivingPlayers(2);
				}
				int target = -1;
				while (living > 0) {
					target = GetRandomInt(1, MaxClients);
					if ( not IsValidClient(target) or not IsPlayerAlive(target) )
						continue;
					if (target is this.index or GetClientTeam(target) is GetClientTeam(this.index))
						continue;
					break;
				}
				if (IsValidClient(target)) {
					// Chdata's HHH teleport rework
					if (TF2_GetPlayerClass(target) not_eq TFClass_Scout and TF2_GetPlayerClass(target) not_eq TFClass_Soldier)
					{
						SetEntProp(this.index, Prop_Send, "m_CollisionGroup", 2); //Makes HHH clipping go away for player and some projectiles
						SetPawnTimer(HHHTeleCollisionReset, 2.0, this.userid);
						//hHHHTeleTimer = CreateTimer(bEnableSuperDuperJump ? 4.0 : 2.0, HHHTeleTimer, Hale, TIMER_FLAG_NO_MAPCHANGE);
					}

					float pos[3]; GetClientAbsOrigin(target, pos);
					SetEntPropFloat(this.index, Prop_Send, "m_flNextAttack", currtime+2);
					if (GetEntProp(target, Prop_Send, "m_bDucked"))
					{
						float collisionvec[3] = {24.0, 24.0, 62.0};
						SetEntPropVector(this.index, Prop_Send, "m_vecMaxs", collisionvec);
						SetEntProp(this.index, Prop_Send, "m_bDucked", 1);
						SetEntityFlags(this.index, flags|FL_DUCKING);
						SetPawnTimer(StunHHH, 0.2, this.userid, GetClientUserId(target));
					}
					else
						TF2_StunPlayer(this.index, 2.0, 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, target);
					TeleportEntity(this.index, pos, NULL_VECTOR, NULL_VECTOR);
					SetEntProp(this.index, Prop_Send, "m_bGlowEnabled", 0);
					CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(this.index, "ghost_appearation")));
					CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(this.index, "ghost_appearation", _, false)));

					// Chdata's HHH teleport rework
					float vPos[3];
					GetEntPropVector(target, Prop_Send, "m_vecOrigin", vPos);

					EmitSoundToClient(this.index, "misc/halloween/spell_teleport.wav");
					EmitSoundToClient(target, "misc/halloween/spell_teleport.wav");
					PrintCenterText(target, "You've been teleported!");

					this.flCharge = -1100.0;
				}
			}
			else this.flCharge = 0.0;
		}
		if (OnlyScoutsLeft(RED))
			this.flRAGE += 0.5;

		if ( flags & FL_ONGROUND ) {
			this.flWeighDown = 0.0;
			this.iClimbs = 0;
		}
		else this.flWeighDown += 0.1;

		if ( (buttons & IN_DUCK) and this.flWeighDown >= 1.0 )
		{
			float ang[3]; GetClientEyeAngles(this.index, ang);
			if ( ang[0] > 60.0 ) {
				SetEntityGravity(this.index, 6.0);
				SetPawnTimer(SetGravityNormal, 1.0, this.userid);
				this.flWeighDown = 0.0;
			}
		}
		SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
		float jmp = this.flCharge;
		if (jmp > 0.0)
			jmp *= 2.0;
		if (this.flRAGE >= 100.0)
			ShowSyncHudText(this.index, hHudText, "Teleport: %i | Climbs: %i | Rage: FULL - Call Medic (default: E) to activate", RoundFloat(jmp), this.iClimbs);
		else ShowSyncHudText(this.index, hHudText, "Teleport: %i | Climbs: %i| Rage: %0.1f", RoundFloat(jmp), this.iClimbs, this.flRAGE);
	}
	public void SetModel ()
	{
		SetVariantString(HHHModel);
		AcceptEntityInput(this.index, "SetCustomModel");
		SetEntProp(this.index, Prop_Send, "m_bUseClassAnimations", 1);
		//SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.25);
	}

	public void Death ()
	{
		Format(snd, PLATFORM_MAX_PATH, "vo/halloween_boss/knight_death0%d.mp3", GetRandomInt(1, 2));
		EmitSoundToAll(snd);
	}

	public void Equip ()
	{
		TF2_RemovePlayerDisguise(this.index);
		int ent = -1;
		while ((ent = FindEntityByClassname(ent, "tf_wearable_demoshield")) not_eq -1)
		{
			if (GetOwner(ent) is this.index) {
				TF2_RemoveWearable(this.index, ent);
				AcceptEntityInput(ent, "Kill");
			}
		}
		ent = -1;
		while ((ent = FindEntityByClassname(ent, "tf_wearable")) not_eq -1)
		{
			if (GetOwner(ent) is this.index) {
				TF2_RemoveWearable(this.index, ent);
				AcceptEntityInput(ent, "Kill");
			}
		}
		ent = -1;
		while ((ent = FindEntityByClassname(ent, "tf_powerup_bottle")) not_eq -1)
		{
			if (GetOwner(ent) is this.index) {
				TF2_RemoveWearable(this.index, ent);
				AcceptEntityInput(ent, "Kill");
			}
		}

		TF2_RemoveAllWeapons(this.index);
		char attribs[128];

		Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 2.86 ; 259 ; 1.0 ; 252 ; 0.7 ; 551 ; 1");
		int SaxtonWeapon = this.SpawnWeapon("tf_weapon_sword", 266, 100, 5, attribs);
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
	}
	public void RageAbility()
	{
		TF2_AddCondition(this.index, view_as<TFCond>(42), 4.0);
		if ( not GetEntProp(this.index, Prop_Send, "m_bIsReadyToHighFive")
			and not IsValidEntity(GetEntPropEnt(this.index, Prop_Send, "m_hHighFivePartner")) )
		{
			TF2_RemoveCondition(this.index, TFCond_Taunting);
			this.SetModel(); //MakeModelTimer(null);
		}
		this.DoGenericStun(HALERAGEDIST);

		strcopy(snd, PLATFORM_MAX_PATH, HHHRage2);
		EmitSoundToAll(snd, this.index); EmitSoundToAll(snd, this.index);
	}

	public void KilledPlayer(const BaseBoss victim, Event event)
	{
		int living = GetLivingPlayers(RED);

		Format(snd, PLATFORM_MAX_PATH, "%s0%i.mp3", HHHAttack, GetRandomInt(1, 4));
		EmitSoundToAll(snd);

		float curtime = GetGameTime();
		if ( curtime <= this.flKillSpree )
			this.iKills++;
		else this.iKills = 0;
		
		if (this.iKills is 3 and living not_eq 1) {
			Format(snd, PLATFORM_MAX_PATH, "%s0%i.mp3", HHHLaught, GetRandomInt(1, 4));
			EmitSoundToAll(snd, this.index); EmitSoundToAll(snd, this.index);
			this.iKills = 0;
		}
		else this.flKillSpree = curtime+5;
	}
	public void Help()
	{
		if ( IsVoteInProgress() )
			return ;
		char helpstr[] = "Horseless Headless Horsemann Jr.:\nTeleporter: crouch, look up and stand up.\nWeigh-down: in midair, look down and crouch\nRage (stun): taunt when Rage is full to stun nearby enemies.";
		Panel panel = new Panel();
		panel.SetTitle (helpstr);
		panel.DrawItem( "Exit" );
		panel.Send(this.index, HintPanel, 10);
		delete (panel);
	}
};

public CHHHJr ToCHHHJr (const BaseBoss guy)
{
	return view_as<CHHHJr>(guy);
}

public void AddHHHToDownloads()
{
	char s[PLATFORM_MAX_PATH];
	
	int i;

	PrepareModel(HHHModel);

	for (i = 1; i <= 4; i++) {
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
}

public void AddHHHToMenu ( Menu& menu )
{
	menu.AddItem("2", "Horseless Headless Horsemann Jr.");
}

public void HHHTeleCollisionReset(const int userid)
{
	int client = GetClientOfUserId(userid);
	SetEntProp(client, Prop_Send, "m_CollisionGroup", 5); //Fix HHH's clipping.
}
public void StunHHH(const int userid, const int targetid)
{
	int client = GetClientOfUserId(userid);
	if (not IsValidClient(client) or not IsPlayerAlive(client))
		return;

	int target = GetClientOfUserId(targetid);
	if ( not IsValidClient(target) or not IsPlayerAlive(target))
		target = 0;
	TF2_StunPlayer(client, 2.0, 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, target);
}
