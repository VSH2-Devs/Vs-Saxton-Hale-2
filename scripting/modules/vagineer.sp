
//defines
#define VagineerModel		"models/player/saxton_hale/vagineer_v134.mdl"
#define VagineerModelPrefix	"models/player/saxton_hale/vagineer_v134"

//Vagineer voicelines
#define VagineerLastA		"saxton_hale/lolwut_0.wav"
#define VagineerRageSound	"saxton_hale/lolwut_2.wav"
#define VagineerStart		"saxton_hale/lolwut_1.wav"
#define VagineerKSpree		"saxton_hale/lolwut_3.wav"
#define VagineerKSpree2		"saxton_hale/lolwut_4.wav"
#define VagineerHit		"saxton_hale/lolwut_5.wav"
#define VagineerRoundStart	"saxton_hale/vagineer_responce_intro.wav"
#define VagineerJump		"saxton_hale/vagineer_responce_jump_"		//1-2
#define VagineerRageSound2	"saxton_hale/vagineer_responce_rage_"		//1-4
#define VagineerKSpreeNew	"saxton_hale/vagineer_responce_taunt_"		//1-5
#define VagineerFail		"saxton_hale/vagineer_responce_fail_"		//1-2

#define HALESPEED		340.0

#define VAGRAGEDIST		533.333


methodmap CVagineer < BaseBoss
{
	public CVagineer(const int ind, bool uid = false)
	{
		if (uid)
			return view_as<CVagineer>( BaseBoss(ind, true) );
		return view_as<CVagineer>( BaseBoss(ind) );
	}

	public void PlaySpawnClip()
	{
		if (not GetRandomInt(0, 1))
			strcopy(snd, PLATFORM_MAX_PATH, VagineerStart);
		else strcopy(snd, PLATFORM_MAX_PATH, VagineerRoundStart);

		EmitSoundToAll(snd);
	}

	public void Think ()
	{
		if ( not IsPlayerAlive(this.index) )
			return;

		int buttons = GetClientButtons(this.index);
		//float currtime = GetGameTime();
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
			if (this.flCharge+2.5 < HALE_JUMPCHARGE)
				this.flCharge += 2.5;
			else this.flCharge = HALE_JUMPCHARGE;
		}
		else if (this.flCharge < 0.0)
			this.flCharge += 2.5;
		else {
			float EyeAngles[3]; GetClientEyeAngles(this.index, EyeAngles);
			if ( this.flCharge > 1.0 and EyeAngles[0] < -5.0 ) {
				float vel[3]; GetEntPropVector(this.index, Prop_Data, "m_vecVelocity", vel);
				vel[2] = 750 + this.flCharge * 13.0;

				SetEntProp(this.index, Prop_Send, "m_bJumping", 1);
				vel[0] *= (1+Sine(this.flCharge * FLOAT_PI / 50));
				vel[1] *= (1+Sine(this.flCharge * FLOAT_PI / 50));
				TeleportEntity(this.index, NULL_VECTOR, NULL_VECTOR, vel);
				this.flCharge = -100.0;
				Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", VagineerJump, GetRandomInt(1, 2));
				
				EmitSoundToAll(snd, this.index);
				EmitSoundToAll(snd, this.index);
			}
			else this.flCharge = 0.0;
		}
		if (OnlyScoutsLeft(RED))
			this.flRAGE += 0.5;

		if ( flags & FL_ONGROUND )
			this.flWeighDown = 0.0;
		else this.flWeighDown += 0.1;

		if ( (buttons & IN_DUCK) and this.flWeighDown >= 1.0 )
		{
			float ang[3]; GetClientEyeAngles(this.index, ang);
			if ( ang[0] > 60.0 ) {
				//float fVelocity[3];
				//GetEntPropVector(this.index, Prop_Data, "m_vecVelocity", fVelocity);
				//fVelocity[2] = -500.0;
				//TeleportEntity(this.index, NULL_VECTOR, NULL_VECTOR, fVelocity);
				SetEntityGravity(this.index, 6.0);
				SetPawnTimer(SetGravityNormal, 1.0, this.userid);
				this.flWeighDown = 0.0;
			}
		}
		SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
		float jmp = this.flCharge;
		if (jmp > 0.0)
			jmp *= 4.0;
		if (this.flRAGE equals 100.0 or RoundFloat(this.flRAGE) is 100)
			ShowSyncHudText(this.index, hHudText, "Jump: %i | Rage: FULL", RoundFloat(jmp));
		else
			ShowSyncHudText(this.index, hHudText, "Jump: %i | Rage: %i", RoundFloat(jmp), RoundFloat(this.flRAGE));

		if (TF2_IsPlayerInCondition(this.index, TFCond_Ubercharged))
			SetEntProp(this.index, Prop_Data, "m_takedamage", 0);
		else SetEntProp(this.index, Prop_Data, "m_takedamage", 2);
	}
	public void SetModel ()
	{
		SetVariantString(VagineerModel);
		AcceptEntityInput(this.index, "SetCustomModel");
		SetEntProp(this.index, Prop_Send, "m_bUseClassAnimations", 1);
		//SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.25);
	}

	public void Death ()
	{
		Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", VagineerFail, GetRandomInt(1, 2));
		EmitSoundToAll(snd);
	}

	public void Equip ()
	{
		TF2_RemovePlayerDisguise(this.index);
		int ent = -1;
		while ((ent = FindEntityByClassname(ent, "tf_wearable_demoshield")) not_eq -1)
		{
			if (GetOwner(ent) equals this.index) {
				TF2_RemoveWearable(this.index, ent);
				AcceptEntityInput(ent, "Kill");
			}
		}
		ent = -1;
		while ((ent = FindEntityByClassname(ent, "tf_wearable")) not_eq -1)
		{
			if (GetOwner(ent) equals this.index) {
				TF2_RemoveWearable(this.index, ent);
				AcceptEntityInput(ent, "Kill");
			}
		}
		ent = -1;
		while ((ent = FindEntityByClassname(ent, "tf_powerup_bottle")) not_eq -1)
		{
			if (GetOwner(ent) equals this.index) {
				TF2_RemoveWearable(this.index, ent);
				AcceptEntityInput(ent, "Kill");
			}
		}

		TF2_RemoveAllWeapons(this.index);
		char attribs[128];

		Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.1 ; 259 ; 1.0 ; 436 ; 1.0");
		int SaxtonWeapon = this.SpawnWeapon("tf_weapon_wrench", 169, 100, 5, attribs);
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
		TF2_AddCondition(this.index, TFCond_Ubercharged, 10.0);
		int i;
		float pos[3], pos2[3], distance;
		GetEntPropVector(this.index, Prop_Send, "m_vecOrigin", pos);

		for ( i = MaxClients ; i; --i )
		{
			if ( not IsValidClient(i) or not IsPlayerAlive(i) or i equals this.index )
				continue;
			else if (GetClientTeam(i) equals GetClientTeam(this.index))
				continue;

			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if (not TF2_IsPlayerInCondition(i, TFCond_Ubercharged) and distance < VAGRAGEDIST)
			{
				int flags = TF_STUNFLAGS_GHOSTSCARE;
				flags |= TF_STUNFLAG_NOSOUNDOREFFECT;
				CreateTimer(5.0, RemoveEnt, EntIndexToEntRef(AttachParticle(i, "yikes_fx", 75.0)));
				TF2_StunPlayer(i, 5.0, _, flags, this.index);
			}
		}
		i = -1;
		while ((i = FindEntityByClassname(i, "obj_sentrygun")) not_eq -1)
		{
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if (distance < VAGRAGEDIST/2) {
				SetEntProp(i, Prop_Send, "m_bDisabled", 1);
				AttachParticle(i, "yikes_fx", 75.0);
				SetVariantInt(1);
				AcceptEntityInput(i, "RemoveHealth");
				SetPawnTimer(EnableSG, 8.0, EntIndexToEntRef(i)); //CreateTimer(8.0, EnableSG, EntIndexToEntRef(i));
			}
		}
		i = -1;
		while ((i = FindEntityByClassname(i, "obj_dispenser")) not_eq -1)
		{
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if (distance < VAGRAGEDIST) {
				SetVariantInt(1);
				AcceptEntityInput(i, "RemoveHealth");
			}
		}
		i = -1;
		while ((i = FindEntityByClassname(i, "obj_teleporter")) not_eq -1)
		{
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if (distance < VAGRAGEDIST) {
				SetVariantInt(1);
				AcceptEntityInput(i, "RemoveHealth");
			}
		}
		if (GetRandomInt(0, 2))
			strcopy(snd, PLATFORM_MAX_PATH, VagineerRageSound);
		else
			Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", VagineerRageSound2, GetRandomInt(1, 2));
		EmitSoundToAll(snd, this.index); EmitSoundToAll(snd, this.index);
	}

	public void KilledPlayer(const BaseBoss victim, Event event)
	{
		strcopy(snd, PLATFORM_MAX_PATH, VagineerHit);
		EmitSoundToAll(snd, this.index); EmitSoundToAll(snd, this.index);

		float curtime = GetGameTime();
		if ( curtime <= this.flKillSpree )
			this.iKills++;
		else this.iKills = 0;
		
		if (this.iKills equals 3 and GetLivingPlayers(RED) not_eq 1) {
			switch (GetRandomInt(0, 4))
			{
				case 1, 3: strcopy(snd, PLATFORM_MAX_PATH, VagineerKSpree);
				case 2: strcopy(snd, PLATFORM_MAX_PATH, VagineerKSpree2);
				default: Format(snd, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, GetRandomInt(1, 5));
			}
			EmitSoundToAll(snd, this.index); EmitSoundToAll(snd, this.index);
			this.iKills = 0;
		}
		else this.flKillSpree = curtime+5;
	}
	public void Help()
	{
		if ( IsVoteInProgress() )
			return ;
		char helpstr[180];
		Format(helpstr, sizeof(helpstr), "Vagineer:\nSuper Jump: crouch, look up and stand up.\nWeigh-down: in midair, look down and crouch\nRage (Uber): taunt when the Rage Meter is full to stun fairly close-by enemies.");
		Panel panel = new Panel();
		panel.SetTitle (helpstr);
		panel.DrawItem( "Exit" );
		panel.Send(this.index, HintPanel, 10);
		delete (panel);
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
	PrecacheModel(VagineerModel, true);
	for (i = 0; i < sizeof(extensions); i++) {
		Format(s, PLATFORM_MAX_PATH, "%s%s", VagineerModelPrefix, extensions[i]);
		CheckDownload(s);
	}

	PrecacheSound(VagineerLastA, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", VagineerLastA);
	CheckDownload(s);
	PrecacheSound(VagineerStart, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", VagineerStart);
	CheckDownload(s);
	PrecacheSound(VagineerRageSound, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", VagineerRageSound);
	CheckDownload(s);
	PrecacheSound(VagineerKSpree, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", VagineerKSpree);
	CheckDownload(s);
	PrecacheSound(VagineerKSpree2, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", VagineerKSpree2);
	CheckDownload(s);
	PrecacheSound(VagineerHit, true);
	Format(s, PLATFORM_MAX_PATH, "sound/%s", VagineerHit);
	CheckDownload(s);

	for (i = 1; i <= 5; i++) {
		Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerJump, i);
		PrecacheSound(s, true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
		CheckDownload(s);
		
		Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerRageSound2, i);
		PrecacheSound(s, true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
		CheckDownload(s);
		
		Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerFail, i);
		PrecacheSound(s, true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
		CheckDownload(s);

		PrecacheSound(VagineerRoundStart, true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", VagineerRoundStart);
		CheckDownload(s);
		Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, i);
		PrecacheSound(s, true);
		Format(s, PLATFORM_MAX_PATH, "sound/%s", s);
		CheckDownload(s);
	}
	PrecacheSound("vo/engineer_positivevocalization01.mp3", true);
}

public void AddVagToMenu ( Menu& menu )
{
	menu.AddItem("1", "Vagineer");
}
