//defines

//models
#define BunnyModel		"models/player/saxton_hale/easter_demo.mdl"
// #define BunnyModelPrefix	"models/player/saxton_hale/easter_demo"

#define EggModel		"models/player/saxton_hale/w_easteregg.mdl"
// #define EggModelPrefix		"models/player/saxton_hale/w_easteregg"
//#define ReloadEggModel	"models/player/saxton_hale/c_easter_cannonball.mdl"
//#define ReloadEggModelPrefix	"models/player/saxton_hale/c_easter_cannonball"

//materials
static const char BunnyMaterials[][] = {
	"materials/models/player/easter_demo/demoman_head_red.vmt",
	"materials/models/player/easter_demo/easter_body.vmt",
	"materials/models/player/easter_demo/easter_body.vtf",
	"materials/models/player/easter_demo/easter_rabbit.vmt",
	"materials/models/player/easter_demo/easter_rabbit.vtf",
	"materials/models/player/easter_demo/easter_rabbit_normal.vtf",
	"materials/models/player/easter_demo/eyeball_r.vmt"
	// "materials/models/player/easter_demo/demoman_head_blue_invun.vmt", // This is for the new version of easter demo which VSH isn't using
	// "materials/models/player/easter_demo/demoman_head_red_invun.vmt",
	// "materials/models/player/easter_demo/easter_rabbit_blue.vmt",
	// "materials/models/player/easter_demo/easter_rabbit_blue.vtf",
	// "materials/models/player/easter_demo/easter_rabbit_invun.vmt",
	// "materials/models/player/easter_demo/easter_rabbit_invun.vtf",
	// "materials/models/player/easter_demo/easter_rabbit_invun_blue.vmt",
	// "materials/models/player/easter_demo/easter_rabbit_invun_blue.vtf",
	// "materials/models/player/easter_demo/eyeball_invun.vmt"
};

//Easter Bunny voicelines
char BunnyWin[][] = {
	"vo/demoman_gibberish01.mp3",
	"vo/demoman_gibberish12.mp3",
	"vo/demoman_cheers02.mp3",
	"vo/demoman_cheers03.mp3",
	"vo/demoman_cheers06.mp3",
	"vo/demoman_cheers07.mp3",
	"vo/demoman_cheers08.mp3",
	"vo/taunts/demoman_taunts12.mp3"
};

char BunnyJump[][] = {
	"vo/demoman_gibberish07.mp3",
	"vo/demoman_gibberish08.mp3",
	"vo/demoman_laughshort01.mp3",
	"vo/demoman_positivevocalization04.mp3"
};

char BunnyRage[][] = {
	"vo/demoman_positivevocalization03.mp3",
	"vo/demoman_dominationscout05.mp3",
	"vo/demoman_cheers02.mp3"
};

char BunnyFail[][] = {
	"vo/demoman_gibberish04.mp3",
	"vo/demoman_gibberish10.mp3",
	"vo/demoman_jeers03.mp3",
	"vo/demoman_jeers06.mp3",
	"vo/demoman_jeers07.mp3",
	"vo/demoman_jeers08.mp3"
};

char BunnyKill[][] = {
	"vo/demoman_gibberish09.mp3",
	"vo/demoman_cheers02.mp3",
	"vo/demoman_cheers07.mp3",
	"vo/demoman_positivevocalization03.mp3"
};

char BunnySpree[][] = {
	"vo/demoman_gibberish05.mp3",
	"vo/demoman_gibberish06.mp3",
	"vo/demoman_gibberish09.mp3",
	"vo/demoman_gibberish11.mp3",
	"vo/demoman_gibberish13.mp3",
	"vo/demoman_autodejectedtie01.mp3"
};

char BunnyLast[][] = {
	"vo/taunts/demoman_taunts05.mp3",
	"vo/taunts/demoman_taunts04.mp3",
	"vo/demoman_specialcompleted07.mp3"
};

char BunnyPain[][] = {
	"vo/demoman_sf12_badmagic01.mp3",
	"vo/demoman_sf12_badmagic07.mp3",
	"vo/demoman_sf12_badmagic10.mp3"
};

char BunnyStart[][] = {
	"vo/demoman_gibberish03.mp3",
	"vo/demoman_gibberish11.mp3"
};

char BunnyRandomVoice[][] = {
	"vo/demoman_positivevocalization03.mp3",
	"vo/demoman_jeers08.mp3",
	"vo/demoman_gibberish03.mp3",
	"vo/demoman_cheers07.mp3",
	"vo/demoman_sf12_badmagic01.mp3",
	"vo/burp02.mp3",
	"vo/burp03.mp3",
	"vo/burp04.mp3",
	"vo/burp05.mp3",
	"vo/burp06.mp3",
	"vo/burp07.mp3"
};


methodmap CBunny < BaseBoss
{
	public CBunny(const int ind, bool uid=false)
	{
		return view_as<CBunny>( BaseBoss(ind, uid) );
	}

	public void PlaySpawnClip()
	{
		strcopy(snd, PLATFORM_MAX_PATH, BunnyStart[GetRandomInt(0, sizeof(BunnyStart)-1)]);
		EmitSoundToAll(snd);
	}

	public void Think ()
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

		if( ((buttons & IN_DUCK) or (buttons & IN_ATTACK2)) and (this.flCharge >= 0.0) ) {
			if( this.flCharge+2.5 < HALE_JUMPCHARGE )
				this.flCharge += 2.5;
			else this.flCharge = HALE_JUMPCHARGE;
		}
		else if( this.flCharge < 0.0 )
			this.flCharge += 2.5;
		else {
			float EyeAngles[3]; GetClientEyeAngles(this.index, EyeAngles);
			if( this.flCharge > 1.0 and EyeAngles[0] < -5.0 ) {
				float vel[3]; GetEntPropVector(this.index, Prop_Data, "m_vecVelocity", vel);
				vel[2] = 750 + this.flCharge * 13.0;

				SetEntProp(this.index, Prop_Send, "m_bJumping", 1);
				vel[0] *= (1+Sine(this.flCharge * FLOAT_PI / 50));
				vel[1] *= (1+Sine(this.flCharge * FLOAT_PI / 50));
				TeleportEntity(this.index, NULL_VECTOR, NULL_VECTOR, vel);
				this.flCharge = -100.0;
				strcopy(snd, PLATFORM_MAX_PATH, BunnyJump[GetRandomInt(0, sizeof(BunnyJump)-1)]);
				
				EmitSoundToAll(snd, this.index);
				EmitSoundToAll(snd, this.index);
			}
			else this.flCharge = 0.0;
		}
		if( OnlyScoutsLeft(RED) )
			this.flRAGE += 0.5;

		if( flags & FL_ONGROUND )
			this.flWeighDown = 0.0;
		else this.flWeighDown += 0.1;
		
		if( (buttons & IN_DUCK) and this.flWeighDown >= HALE_WEIGHDOWN_TIME ) {
			float ang[3]; GetClientEyeAngles(this.index, ang);
			if( ang[0] > 60.0 ) {
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
		if( jmp > 0.0 )
			jmp *= 4.0;
		if( this.flRAGE >= 100.0 )
			ShowSyncHudText(this.index, hHudText, "Jump: %i | Rage: FULL - Call Medic (default: E) to activate", RoundFloat(jmp));
		else ShowSyncHudText(this.index, hHudText, "Jump: %i | Rage: %0.1f", RoundFloat(jmp), this.flRAGE);
	}
	public void SetModel ()
	{
		SetVariantString(BunnyModel);
		AcceptEntityInput(this.index, "SetCustomModel");
		SetEntProp(this.index, Prop_Send, "m_bUseClassAnimations", 1);
		//SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.25);
	}

	public void Death ()
	{
		strcopy(snd, PLATFORM_MAX_PATH, BunnyFail[GetRandomInt(0, sizeof(BunnyFail)-1)]);
		EmitSoundToAll(snd);
		SpawnManyAmmoPacks(this.index, EggModel, 1);
	}

	public void Equip ()
	{
		this.RemoveAllItems();
		char attribs[128];

		Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 2.77 ; 259 ; 1.0 ; 326 ; 1.3 ; 252 ; 0.6");
		int SaxtonWeapon = this.SpawnWeapon("tf_weapon_bottle", 169, 100, 5, attribs);
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
	}
	public void RageAbility()
	{
		TF2_AddCondition(this.index, view_as<TFCond>(42), 4.0);
		if( !GetEntProp(this.index, Prop_Send, "m_bIsReadyToHighFive")
			and !IsValidEntity(GetEntPropEnt(this.index, Prop_Send, "m_hHighFivePartner")) )
		{
			TF2_RemoveCondition(this.index, TFCond_Taunting);
			this.SetModel(); //MakeModelTimer(null);
		}
		
		TF2_RemoveWeaponSlot(this.index, TFWeaponSlot_Primary);
		int weapon = this.SpawnWeapon("tf_weapon_grenadelauncher", 19, 100, 5, "2 ; 1.25 ; 6 ; 0.1 ; 411 ; 150.0 ; 413 ; 1.0 ; 37 ; 0.0 ; 280 ; 17 ; 477 ; 1.0 ; 467 ; 1.0 ; 181 ; 2.0 ; 252 ; 0.7");
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", weapon);
		SetEntProp(weapon, Prop_Send, "m_iClip1", 50);
		SetWeaponAmmo(weapon, 0);
		
		this.DoGenericStun(VAGRAGEDIST);
		
		strcopy(snd, PLATFORM_MAX_PATH, BunnyRage[GetRandomInt(1, sizeof(BunnyRage)-1)]);
		EmitSoundToAll(snd, this.index); EmitSoundToAll(snd, this.index);
	}

	public void KilledPlayer(const BaseBoss victim, Event event)
	{
		strcopy(snd, PLATFORM_MAX_PATH, BunnyKill[GetRandomInt(0, sizeof(BunnyKill)-1)]);
		EmitSoundToAll(snd, this.index); EmitSoundToAll(snd, this.index);
		SpawnManyAmmoPacks(victim.index, EggModel, 1);
		float curtime = GetGameTime();
		if( curtime <= this.flKillSpree )
			this.iKills++;
		else this.iKills = 0;
		
		if( this.iKills == 3 and GetLivingPlayers(RED) != 1 ) {
			strcopy(snd, PLATFORM_MAX_PATH, BunnySpree[GetRandomInt(0, sizeof(BunnySpree)-1)]);
			EmitSoundToAll(snd, this.index); EmitSoundToAll(snd, this.index);
			this.iKills = 0;
		}
		else this.flKillSpree = curtime+5;
	}
	public void Help()
	{
		if( IsVoteInProgress() )
			return;
		char helpstr[] = "The Easter Bunny:\nI think he wants to give out candy? Maybe?\nSuper Jump: crouch, look up and stand up.\nWeigh-down: in midair, look down and crouch\nRage (Happy Easter, Fools): taunt when Rage Meter is full.\nNearby enemies are stunned.";
		Panel panel = new Panel();
		panel.SetTitle (helpstr);
		panel.DrawItem( "Exit" );
		panel.Send(this.index, HintPanel, 10);
		delete (panel);
	}
	public void LastPlayerSoundClip()
	{
		strcopy(snd, PLATFORM_MAX_PATH, BunnyLast[GetRandomInt(0, sizeof(BunnyLast)-1)]);
		EmitSoundToAll(snd);
	}
};

public CBunny ToCBunny (const BaseBoss guy)
{
	return view_as<CBunny>(guy);
}

public void AddBunnyToDownloads()
{
	// char s[PLATFORM_MAX_PATH];
	
	// int i;
	PrepareModel(BunnyModel);
	PrepareModel(EggModel);

	DownloadMaterialList(BunnyMaterials, sizeof(BunnyMaterials));

	PrepareMaterial("materials/models/props_easteregg/c_easteregg");
	CheckDownload("materials/models/props_easteregg/c_easteregg_gold.vmt");

	PrecacheSoundList(BunnyWin, sizeof(BunnyWin));
	PrecacheSoundList(BunnyJump, sizeof(BunnyJump));
	PrecacheSoundList(BunnyRage, sizeof(BunnyRage));
	PrecacheSoundList(BunnyFail, sizeof(BunnyFail));
	PrecacheSoundList(BunnyKill, sizeof(BunnyKill));
	PrecacheSoundList(BunnySpree, sizeof(BunnySpree));
	PrecacheSoundList(BunnyLast, sizeof(BunnyLast));
	PrecacheSoundList(BunnyPain, sizeof(BunnyPain));
	PrecacheSoundList(BunnyStart, sizeof(BunnyStart));
	PrecacheSoundList(BunnyRandomVoice, sizeof(BunnyRandomVoice));
}

public void AddBunnyToMenu ( Menu& menu )
{
	menu.AddItem("4", "Easter Bunny Demoman");
}

stock void SpawnManyAmmoPacks(const int client, const char[] model, int skin=0, int num=14, float offsz = 30.0)
{
	float pos[3], vel[3], ang[3];
	ang[0] = 90.0;
	ang[1] = 0.0;
	ang[2] = 0.0;
	GetClientAbsOrigin(client, pos);
	pos[2] += offsz;
	for( int i=0 ; i<num ; i++ ) {
		vel[0] = GetRandomFloat(-400.0, 400.0);
		vel[1] = GetRandomFloat(-400.0, 400.0);
		vel[2] = GetRandomFloat(300.0, 500.0);
		pos[0] += GetRandomFloat(-5.0, 5.0);
		pos[1] += GetRandomFloat(-5.0, 5.0);
		int ent = CreateEntityByName("tf_ammo_pack");
		if( !IsValidEntity(ent) )
			continue;
		SetEntityModel(ent, model);
		DispatchKeyValue(ent, "OnPlayerTouch", "!self,Kill,,0,-1"); //for safety, but it shouldn't act like a normal ammopack
		SetEntProp(ent, Prop_Send, "m_nSkin", skin);
		SetEntProp(ent, Prop_Send, "m_nSolidType", 6);
		SetEntProp(ent, Prop_Send, "m_usSolidFlags", 152);
		SetEntProp(ent, Prop_Send, "m_triggerBloat", 24);
		SetEntProp(ent, Prop_Send, "m_CollisionGroup", 1);
		SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(ent, Prop_Send, "m_iTeamNum", 2);
		TeleportEntity(ent, pos, ang, vel);
		DispatchSpawn(ent);
		TeleportEntity(ent, pos, ang, vel);
		SetEntProp(ent, Prop_Data, "m_iHealth", 900);
		int offs = GetEntSendPropOffs(ent, "m_vecInitialVelocity", true);
		SetEntData(ent, offs-4, 1, _, true);
	}
}
public Action Timer_SetEggBomb(Handle timer, any ref)
{
	int entity = EntRefToEntIndex(ref);
	if( FileExists(EggModel) and IsModelPrecached(EggModel) and IsValidEntity(entity) ) {
		int att = AttachProjectileModel(entity, EggModel);
		SetEntProp(att, Prop_Send, "m_nSkin", 0);
		SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
		SetEntityRenderColor(entity, 255, 255, 255, 0);
	}
	return Plugin_Continue;
}
