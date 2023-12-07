/// defines
/// models
#define BunnyModel		"models/player/saxton_hale/easter_demo.mdl"
// #define BunnyModelPrefix	"models/player/saxton_hale/easter_demo"

#define EggModel		"models/player/saxton_hale/w_easteregg.mdl"
// #define EggModelPrefix		"models/player/saxton_hale/w_easteregg"
//#define ReloadEggModel	"models/player/saxton_hale/c_easter_cannonball.mdl"
//#define ReloadEggModelPrefix	"models/player/saxton_hale/c_easter_cannonball"

/// materials
static const char BunnyMaterials[][] = {
	"materials/models/player/easter_demo/demoman_head_red.vmt",
	"materials/models/player/easter_demo/easter_body.vmt",
	"materials/models/player/easter_demo/easter_body.vtf",
	"materials/models/player/easter_demo/easter_rabbit.vmt",
	"materials/models/player/easter_demo/easter_rabbit.vtf",
	"materials/models/player/easter_demo/easter_rabbit_normal.vtf",
	"materials/models/player/easter_demo/eyeball_r.vmt"
	// "materials/models/player/easter_demo/demoman_head_blue_invun.vmt", /// This is for the new version of easter demo which VSH isn't using
	// "materials/models/player/easter_demo/demoman_head_red_invun.vmt",
	// "materials/models/player/easter_demo/easter_rabbit_blue.vmt",
	// "materials/models/player/easter_demo/easter_rabbit_blue.vtf",
	// "materials/models/player/easter_demo/easter_rabbit_invun.vmt",
	// "materials/models/player/easter_demo/easter_rabbit_invun.vtf",
	// "materials/models/player/easter_demo/easter_rabbit_invun_blue.vmt",
	// "materials/models/player/easter_demo/easter_rabbit_invun_blue.vtf",
	// "materials/models/player/easter_demo/eyeball_invun.vmt"
};

/// Easter Bunny voicelines
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


methodmap CBunny < BasePlayer {
	public CBunny(int ind, bool uid=false) {
		return view_as< CBunny >( BasePlayer(ind, uid) );
	}
	
	public void PlaySpawnClip() {
		char spawn_snd[PLATFORM_MAX_PATH];
		strcopy(spawn_snd, PLATFORM_MAX_PATH, BunnyStart[GetRandomInt(0, sizeof(BunnyStart)-1)]);
		this.PlayVoiceClip(spawn_snd, VSH2_VOICE_INTRO);
	}
	
	public void Think() {
		if( !IsPlayerAlive(this.index) ) {
			return;
		}
		
		this.SpeedThink(HALESPEED);
		this.GlowThink(0.1);
		if( this.SuperJumpThink(2.5, HALE_JUMPCHARGE) ) {
			this.SuperJump(this.flCharge, -100.0);
			char jump_snd[PLATFORM_MAX_PATH];
			strcopy(jump_snd, PLATFORM_MAX_PATH, BunnyJump[GetRandomInt(0, sizeof(BunnyJump)-1)]);
			this.PlayVoiceClip(jump_snd, VSH2_VOICE_ABILITY);
		}
		if( this.HasAbility(ABILITY_RAGE) && OnlyScoutsLeft(VSH2Team_Red) ) {
			this.flRAGE += g_vsh2.m_hCvars.ScoutRageGen.FloatValue;
		}
		this.WeighDownThink(HALE_WEIGHDOWN_TIME);
	}
	public void SetModel() {
		SetVariantString(BunnyModel);
		AcceptEntityInput(this.index, "SetCustomModel");
		SetEntProp(this.index, Prop_Send, "m_bUseClassAnimations", 1);
		//SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.25);
	}
	
	public void Death() {
		char death_snd[PLATFORM_MAX_PATH];
		strcopy(death_snd, PLATFORM_MAX_PATH, BunnyFail[GetRandomInt(0, sizeof(BunnyFail)-1)]);
		this.PlayVoiceClip(death_snd, VSH2_VOICE_LOSE);
		SpawnManyAmmoPacks(this.index, EggModel, 1);
	}
	
	public void Equip() {
		this.SetName("The Easter Bunny");
		this.RemoveAllItems();
		char attribs[128];
		Format(attribs, sizeof(attribs), "68 ; 2.0; 2 ; 3.0; 259 ; 1.0; 326 ; 1.3; 252 ; 0.6");
		int boss_weap = this.SpawnWeapon("tf_weapon_bottle", 609, 100, 5, attribs);
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", boss_weap);
		
		this.GiveAbility(ABILITY_ESCAPE_PLAN);
		this.GiveAbility(ABILITY_GLOW);
		this.GiveAbility(ABILITY_WEIGHDOWN);
		this.GiveAbility(ABILITY_SUPERJUMP);
		this.GiveAbility(ABILITY_AUTO_FIRE);
		this.GiveAbility(ABILITY_STUN_PLYRS);
		this.GiveAbility(ABILITY_STUN_BUILDS);
		this.GiveAbility(ABILITY_ANCHOR);
		this.GiveAbility(ABILITY_RAGE);
		this.GiveAbility(ABILITY_EXPLODE_AMMO);
	}
	public void RageAbility() {
		TF2_AddCondition(this.index, TFCond_DefenseBuffNoCritBlock, 4.0);
		if( !GetEntProp(this.index, Prop_Send, "m_bIsReadyToHighFive")
			&& !IsValidEntity(GetEntPropEnt(this.index, Prop_Send, "m_hHighFivePartner")) ) {
			TF2_RemoveCondition(this.index, TFCond_Taunting);
			this.SetModel();
		}
		this.DoGenericStun(VAGRAGEDIST);
		
		char rage_snd[PLATFORM_MAX_PATH];
		strcopy(rage_snd, PLATFORM_MAX_PATH, BunnyRage[GetRandomInt(1, sizeof(BunnyRage)-1)]);
		this.PlayVoiceClip(rage_snd, VSH2_VOICE_RAGE);
	}
	
	public void KilledPlayer(BasePlayer victim, Event event) {
		if( GetRandomInt(0, 3) ) {
			char kill_snd[PLATFORM_MAX_PATH];
			strcopy(kill_snd, PLATFORM_MAX_PATH, BunnyKill[GetRandomInt(0, sizeof(BunnyKill)-1)]);
			this.PlayVoiceClip(kill_snd, VSH2_VOICE_SPREE);
		}
		SpawnManyAmmoPacks(victim.index, EggModel, 1);
		
		float curtime = GetGameTime();
		if( curtime <= this.flKillSpree ) {
			this.iKills++;
		} else {
			this.iKills = 0;
		}
		
		if( this.iKills == 3 && GetLivingPlayers(VSH2Team_Red) != 1 ) {
			char spree_snd[PLATFORM_MAX_PATH];
			strcopy(spree_snd, PLATFORM_MAX_PATH, BunnySpree[GetRandomInt(0, sizeof(BunnySpree)-1)]);
			this.PlayVoiceClip(spree_snd, VSH2_VOICE_SPREE);
			this.iKills = 0;
		} else {
			/// TODO: add cvars/config for killing spree amounts. 
			this.flKillSpree = curtime+5;
		}
	}
	
	public void Stabbed() {
		char stab_snd[PLATFORM_MAX_PATH];
		strcopy(stab_snd, PLATFORM_MAX_PATH, BunnyPain[GetRandomInt(0, sizeof(BunnyPain)-1)]);
		this.PlayVoiceClip(stab_snd, VSH2_VOICE_STABBED);
	}
	
	public void Help() {
		if( IsVoteInProgress() ) {
			return;
		}
		char helpstr[] = "The Easter Bunny:\nI think he wants to give out candy? Maybe?\nSuper Jump: crouch, look up and stand up.\nWeigh-down: in midair, look down and crouch\nRage (Happy Easter, Fools): taunt when Rage Meter is full.\nNearby enemies are stunned.";
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
		strcopy(lastguy_snd, PLATFORM_MAX_PATH, BunnyLast[GetRandomInt(0, sizeof(BunnyLast)-1)]);
		this.PlayVoiceClip(lastguy_snd, VSH2_VOICE_LASTGUY);
	}
	public void PlayWinSound() {
		char victory[PLATFORM_MAX_PATH];
		strcopy(victory, PLATFORM_MAX_PATH, BunnyWin[GetRandomInt(0, sizeof(BunnyWin)-1)]);
		this.PlayVoiceClip(victory, VSH2_VOICE_WIN);
	}
};

public CBunny ToCBunny (BasePlayer guy) {
	return view_as< CBunny >(guy);
}

public void AddBunnyToDownloads() {
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

public void AddBunnyToMenu(Menu& menu) {
	char bossid[5]; IntToString(VSH2Boss_Bunny, bossid, sizeof(bossid));
	menu.AddItem(bossid, "Easter Bunny Demoman");
}

stock void SpawnManyAmmoPacks(int client, const char[] model, int skin=0, int num=14, float offsz = 30.0) {
	float pos[3], vel[3], ang[3];
	ang[0] = 90.0;
	ang[1] = 0.0;
	ang[2] = 0.0;
	GetClientAbsOrigin(client, pos);
	pos[2] += offsz;
	for( int i=0; i < num; i++ ) {
		vel[0] = GetRandomFloat(-400.0, 400.0);
		vel[1] = GetRandomFloat(-400.0, 400.0);
		vel[2] = GetRandomFloat(300.0, 500.0);
		pos[0] += GetRandomFloat(-5.0, 5.0);
		pos[1] += GetRandomFloat(-5.0, 5.0);
		
		int ent = CreateEntityByName("tf_ammo_pack");
		if( !IsValidEntity(ent) ) {
			continue;
		}
		
		SetEntityModel(ent, model);
		DispatchKeyValue(ent, "OnPlayerTouch", "!self,Kill,,0,-1"); /// for safety, but it shouldn't act like a normal ammopack
		SetEntProp(ent, Prop_Send, "m_nSkin", skin);
		SetEntProp(ent, Prop_Send, "m_nSolidType", 6);
		SetEntProp(ent, Prop_Send, "m_usSolidFlags", 152);
		SetEntProp(ent, Prop_Send, "m_triggerBloat", 24);
		SetEntProp(ent, Prop_Send, "m_CollisionGroup", 1);
		SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(ent, Prop_Send, "m_iTeamNum", VSH2Team_Red);
		TeleportEntity(ent, pos, ang, vel);
		DispatchSpawn(ent);
		TeleportEntity(ent, pos, ang, vel);
		SetEntProp(ent, Prop_Data, "m_iHealth", 900);
		int offs = GetEntSendPropOffs(ent, "m_vecInitialVelocity", true);
		SetEntData(ent, offs-4, 1, _, true);
	}
}

public Action Timer_SetEggBomb(Handle timer, any ref) {
	int entity = EntRefToEntIndex(ref);
	if( FileExists(EggModel, true) && IsModelPrecached(EggModel) && IsValidEntity(entity) ) {
		int att = AttachProjectileModel(entity, EggModel);
		SetEntProp(att, Prop_Send, "m_nSkin", 0);
		SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
		SetEntityRenderColor(entity, 255, 255, 255, 0);
	}
	return Plugin_Continue;
}
