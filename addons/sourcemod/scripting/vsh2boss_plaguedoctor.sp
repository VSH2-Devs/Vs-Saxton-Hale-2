#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <vsh2>

#undef REQUIRE_PLUGIN
#tryinclude <tf2attributes>
#define REQUIRE_PLUGIN

#define and    &&
#define or    ||

#define PlagueModel			"models/player/medic.mdl"
// #define PlagueModelPrefix		"models/player/medic"
#define ZombieModel			"models/player/scout.mdl"
// #define ZombieModelPrefix		"models/player/scout"


//voicelines
#define PlagueIntro			"vo/medic_specialcompleted10.mp3"
#define PlagueRage1			"vo/medic_specialcompleted05.mp3"
#define PlagueRage2			"vo/medic_specialcompleted06.mp3"

methodmap CPlague < VSH2Player {
	public CPlague(const int ind, bool uid=false)
	{
		return view_as<CPlague>( VSH2Player(ind, uid) );
	}
	
	property float flCharge {
		public get() {
			float f = this.GetProperty("flCharge");
			return f;
		}
		public set(const float val) {
			this.SetProperty("flCharge", val);
		}
	}
	property float flWeighDown {
		public get() {
			float f = this.GetProperty("flWeighDown");
			return f;
		}
		public set(const float val) {
			this.SetProperty("flWeighDown", val);
		}
	}
	property float flRAGE {
		public get() {
			float f = this.GetProperty("flRAGE");
			return f;
		}
		public set(const float val) {
			this.SetProperty("flRAGE", val);
		}
	}
	
	public void PlaySpawnClip()
	{
		EmitSoundToAll(PlagueIntro);
	}
	
	public void Equip()
	{
		this.RemoveAllItems();
		char attribs[128]; Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 2.25 ; 259 ; 1.0 ; 252 ; 0.75 ; 200 ; 1.0 ; 551 ; 1.0");
		int SaxtonWeapon = this.SpawnWeapon("tf_weapon_shovel", 304, 100, 5, attribs);
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
	}
	public void RageAbility()
	{
		int attribute = 0;
		float value = 0.0; 
		TF2_AddCondition(this.index, TFCond_MegaHeal, 10.0);
		switch( GetRandomInt(0, 2) ) {
			case 0: { attribute = 2; value = 2.0; }		// Extra damage
			case 1: { attribute = 26; value = 100.0; }	// Extra health
			case 2: { attribute = 107; value = 2.0; }	// Extra speed
		}
		VSH2Player minion;
		for( int i=MaxClients ; i ; --i ) {
			if( !IsValidClient(i) or !IsPlayerAlive(i) or GetClientTeam(i) != 3 )
				continue;
			minion = VSH2Player(i);
			bool IsMinion = minion.GetProperty("bIsMinion");
			if( IsMinion ) {
			#if defined _tf2attributes_included
				bool tf2attribs_enabled = VSH2GameMode_GetProperty("bTF2Attribs");
				if( tf2attribs_enabled ) {
					TF2Attrib_SetByDefIndex(i, attribute, value);
					SetPawnTimer(TF2AttribsRemove, 10.0, i);
				}
				else {
					char pdapower[32]; Format(pdapower, sizeof(pdapower), "%i ; %f", attribute, value);
					int wep = minion.SpawnWeapon("tf_weapon_builder", 28, 5, 10, pdapower);
					SetPawnTimer(RemoveWepFromSlot, 10.0, i, GetSlotFromWeapon(i, wep));
				}
			#else
				char pdapower[32]; Format(pdapower, sizeof(pdapower), "%i ; %f", attribute, value);
				int wep = minion.SpawnWeapon("tf_weapon_builder", 28, 5, 10, pdapower);
				SetPawnTimer(RemoveWepFromSlot, 10.0, i, GetSlotFromWeapon(i, wep));
			#endif
			}
		}
		if( GetRandomInt(0, 2) )
			EmitSoundToAll(PlagueRage1);
		else EmitSoundToAll(PlagueRage2);
	}
	public void KilledPlayer(const VSH2Player victim, Event event)
	{
		// GLITCH: suiciding allows boss to become own minion.
		if( this.userid == victim.userid )
			return;
		// PATCH: Hitting spy with active deadringer turns them into Minion...
		else if( event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER )
			return;
		// PATCH: killing spy with teammate disguise kills both spy and the teammate he disguised as...
		else if( TF2_IsPlayerInCondition(victim.index, TFCond_Disguised) )
			TF2_RemovePlayerDisguise(victim.index); //event.SetInt("userid", victim.userid);
		victim.SetProperty("iOwnerBoss", this.userid);
		victim.ConvertToMinion(0.4);
	}
	public void Help()
	{
		if( IsVoteInProgress() )
			return;
		char helpstr[] = "Plague Doctor: Kill enemies and turn them into loyal Zombies!\nSuper Jump: crouch, look up and stand up.\nWeigh-down: in midair, look down and crouch\nRage (Powerup Minions): taunt when Rage is full to give powerups to your Zombies.";
		Panel panel = new Panel();
		panel.SetTitle (helpstr);
		panel.DrawItem( "Exit" );
		panel.Send(this.index, HintPanel, 10);
		delete panel;
	}
};

// plague doctor conversion helper function.
public CPlague ToCPlague(const VSH2Player guy)
{
	return view_as<CPlague>(guy);
}


#if defined _tf2attributes_included
public void TF2AttribsRemove(const int iEntity)
{
	TF2Attrib_RemoveAll(iEntity);
}
#endif
public void RemoveWepFromSlot(const int client, const int wepslot)
{
	TF2_RemoveWeaponSlot(client, wepslot);
}


public Plugin myinfo = {
	name = "VSH2 Plague Doctor Subplugin",
	author = "Nergal/Assyrian",
	description = "",
	version = "1.0",
	url = "sus"
};

int g_iPlagueDocID;

public void OnAllPluginsLoaded()
{
	g_iPlagueDocID = VSH2_RegisterPlugin("plague_doctor");
	LoadVSH2Hooks();
}

public void LoadVSH2Hooks()
{
	if (!VSH2_HookEx(OnCallDownloads, PlagueDoc_OnCallDownloads))
		LogError("Error loading OnCallDownloads forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossMenu, PlagueDoc_OnBossMenu))
		LogError("Error loading OnBossMenu forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossSelected, PlagueDoc_OnBossSelected))
		LogError("Error loading OnBossSelected forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossThink, PlagueDoc_OnBossThink))
		LogError("Error loading OnBossThink forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossModelTimer, PlagueDoc_OnBossModelTimer))
		LogError("Error loading OnBossModelTimer forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossEquipped, PlagueDoc_OnBossEquipped))
		LogError("Error loading OnBossEquipped forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossInitialized, PlagueDoc_OnBossInitialized))
		LogError("Error loading OnBossInitialized forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnMinionInitialized, PlagueDoc_OnMinionInitialized))
		LogError("Error loading OnMinionInitialized forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossPlayIntro, PlagueDoc_OnBossPlayIntro))
		LogError("Error loading OnBossPlayIntro forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossTakeDamage, PlagueDoc_OnBossTakeDamage))
		LogError("Error loading OnBossTakeDamage forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossDealDamage, PlagueDoc_OnBossDealDamage))
		LogError("Error loading OnBossDealDamage forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnPlayerKilled, PlagueDoc_OnPlayerKilled))
		LogError("Error loading OnPlayerKilled forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnPlayerHurt, PlagueDoc_OnPlayerHurt))
		LogError("Error loading OnPlayerHurt forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnPlayerAirblasted, PlagueDoc_OnPlayerAirblasted))
		LogError("Error loading OnPlayerAirblasted forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossMedicCall, PlagueDoc_OnBossMedicCall))
		LogError("Error loading OnBossMedicCall forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossTaunt, PlagueDoc_OnBossMedicCall))
		LogError("Error loading OnBossTaunt forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossJarated, PlagueDoc_OnBossJarated))
		LogError("Error loading OnBossJarated forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnMessageIntro, PlagueDoc_OnMessageIntro))
		LogError("Error loading OnMessageIntro forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnRoundEndInfo, PlagueDoc_OnRoundEndInfo))
		LogError("Error loading OnRoundEndInfo forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossHealthCheck, PlagueDoc_OnBossHealthCheck))
		LogError("Error loading OnBossHealthCheck forwards for Plague Doctor subplugin.");
}
stock bool IsPlagueDoctor(const VSH2Player player) {
	return player.GetProperty("iBossType") == g_iPlagueDocID;
}

public void PlagueDoc_OnCallDownloads()
{
	PrecacheModel(PlagueModel, true);
	PrecacheModel(ZombieModel, true);
	PrecacheSound(PlagueIntro, true);
	PrecacheSound(PlagueRage1, true);
	PrecacheSound(PlagueRage2, true);
}
public void PlagueDoc_OnBossMenu(Menu &menu)
{
	char tostr[10]; IntToString(g_iPlagueDocID, tostr, sizeof(tostr));
	menu.AddItem(tostr, "Plague Doctor (Subplugin Boss)");
}
public void PlagueDoc_OnBossSelected(const VSH2Player player)
{
	if( !IsPlagueDoctor(player) )
		return;
	ToCPlague(player).Help();
}
public void PlagueDoc_OnBossThink(const VSH2Player boss)
{
	int client = boss.index;
	if( !IsPlayerAlive(client) or !IsPlagueDoctor(boss) )
		return;
	
	CPlague player = ToCPlague(boss);
	int buttons = GetClientButtons(client);
	//float currtime = GetGameTime();
	int flags = GetEntityFlags(client);
	
	//int maxhp = GetEntProp(client, Prop_Data, "m_iMaxHealth");
	int health = player.GetProperty("iHealth");
	int maxhealth = player.GetProperty("iMaxHealth");
	float speed = 340.0 + 0.7 * (100-health*100/maxhealth);
	SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", speed);
	
	// glowing code
	float glowtime = player.GetProperty("flGlowtime");
	if( glowtime > 0.0 ) {
		player.SetProperty("bGlow", 1);
		player.SetProperty("flGlowtime", glowtime - 0.1);
	}
	else if( glowtime <= 0.0 )
		player.SetProperty("bGlow", 0);
	
	// superjump code
	if( ((buttons & IN_DUCK) or (buttons & IN_ATTACK2)) and (player.flCharge >= 0.0) ) {
		if( player.flCharge+2.5 < (25*1.0) )
			player.flCharge += 2.5;
		else player.flCharge = 25.0;
	}
	else if( player.flCharge < 0.0 )
		player.flCharge += 2.5;
	else {
		float EyeAngles[3]; GetClientEyeAngles(client, EyeAngles);
		if( player.flCharge > 1.0 and EyeAngles[0] < -5.0 ) {
			float vel[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
			vel[2] = 750 + player.flCharge * 13.0;
			
			SetEntProp(client, Prop_Send, "m_bJumping", 1);
			vel[0] *= (1+Sine(player.flCharge * FLOAT_PI / 50));
			vel[1] *= (1+Sine(player.flCharge * FLOAT_PI / 50));
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
			player.flCharge = -100.0;
			EmitSoundToAll("vo/medic_yes01.mp3", client); EmitSoundToAll("vo/medic_yes01.mp3", client);
		}
		else player.flCharge = 0.0;
	}
	if( OnlyScoutsLeft(2) ) // 2 is RED
		player.flRAGE += 0.5;
	
	// weighdown code
	if( flags & FL_ONGROUND )
		player.flWeighDown = 0.0;
	else player.flWeighDown += 0.1;
	if( (buttons & IN_DUCK) and player.flWeighDown >= 3.0 ) {
		float ang[3]; GetClientEyeAngles(client, ang);
		if( ang[0] > 60.0 ) {
			SetEntityGravity(client, 6.0);
			SetPawnTimer(SetGravityNormal, 1.0, player.userid);
			player.flWeighDown = 0.0;
		}
	}
	// hud code
	SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
	Handle hHudText = VSH2GameMode_GetHUDHandle();
	float jmp = player.flCharge;
	if( jmp > 0.0 )
		jmp *= 4.0;
	if( player.flRAGE >= 100.0 )
		ShowSyncHudText(client, hHudText, "Jump: %i | Rage: FULL - Call Medic (default: E) to activate", RoundFloat(jmp));
	else ShowSyncHudText(client, hHudText, "Jump: %i | Rage: %0.1f", RoundFloat(jmp), player.flRAGE);
}
public void PlagueDoc_OnBossModelTimer(const VSH2Player player)
{
	if( !IsPlagueDoctor(player) )
		return;
	int client = player.index;
	SetVariantString(PlagueModel);
	AcceptEntityInput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
}
public void PlagueDoc_OnBossEquipped(const VSH2Player player)
{
	if( !IsPlagueDoctor(player) )
		return;
	ToCPlague(player).Equip();
}
public void PlagueDoc_OnBossInitialized(const VSH2Player player)
{
	if( !IsPlagueDoctor(player) )
		return;
	SetEntProp(player.index, Prop_Send, "m_iClass", view_as<int>(TFClass_Medic));
}
public void PlagueDoc_OnMinionInitialized(const VSH2Player player)
{
	VSH2Player ownerboss = VSH2Player(player.GetProperty("iOwnerBoss"), true);
	if( !IsPlagueDoctor(ownerboss) )
		return;
	RecruitMinion(player);
}
public void PlagueDoc_OnBossPlayIntro(const VSH2Player player)
{
	if( !IsPlagueDoctor(player) )
		return;
	ToCPlague(player).PlaySpawnClip();
}
public Action PlagueDoc_OnBossTakeDamage(VSH2Player victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if( !IsPlagueDoctor(victim) )
		return Plugin_Continue;
	
	int boss = victim.index;
	float bossrage = victim.GetProperty("flRAGE");
	char trigger[32];
	if( attacker != -1 and GetEdictClassname(attacker, trigger, sizeof(trigger)) and !strcmp(trigger, "trigger_hurt", false) )
	{
		if( damage >= 300.0 )
			victim.TeleToSpawn(3);
	}
	if( attacker <= 0 or attacker > MaxClients )
		return Plugin_Continue;
	
	VSH2Player fighter = VSH2Player(attacker);
	char classname [64], strEntname [32];
	if( IsValidEdict(inflictor) )
		GetEntityClassname(inflictor, strEntname, sizeof(strEntname));
	if( IsValidEdict(weapon) )
		GetEdictClassname(weapon, classname, sizeof(classname));

	int wepindex = GetItemIndex(weapon);
	if( damagecustom == TF_CUSTOM_BACKSTAB or (!strcmp(classname, "tf_weapon_knife", false) and damage > victim.GetProperty("iHealth")) )
	{
		int stabs = victim.GetProperty("iStabbed");
		int maxhealth = victim.GetProperty("iMaxHealth");
		float changedamage = ( (Pow(float(maxhealth)*0.0014, 2.0) + 899.0) - (float(maxhealth)*(float(stabs)/100)) );
		if( stabs < 4 )
			victim.SetProperty("iStabbed", ++stabs);
		damage = changedamage/3; // You can level "damage dealt" with backstabs
		damagetype |= DMG_CRIT;

		EmitSoundToAll("player/spy_shield_break.wav", boss, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
		EmitSoundToAll("player/crit_received3.wav", boss, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
		float curtime = GetGameTime();
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", curtime+2.0);
		SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", curtime+2.0);
		SetEntPropFloat(attacker, Prop_Send, "m_flStealthNextChangeTime", curtime+1.0);
		TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, 1.5);
		TF2_AddCondition(attacker, TFCond_Ubercharged, 2.0);
		int vm = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
		if( vm > MaxClients and IsValidEntity(vm) and TF2_GetPlayerClass(attacker) == TFClass_Spy ) {
			int melee = fighter.GetWeaponSlotIndex(TFWeaponSlot_Melee);
			int anim = 15;
			switch( melee ) {
				case 727: anim = 41;
				case 4, 194, 665, 794, 803, 883, 892, 901, 910: anim = 10;
				case 638: anim = 31;
			}
			SetEntProp(vm, Prop_Send, "m_nSequence", anim);
		}
		PrintCenterText(attacker, "You Tickled The Plague Doctor!");
		PrintCenterText(boss, "You Were Just Tickled!");
		int pistol = fighter.GetWeaponSlotIndex(TFWeaponSlot_Primary);
		if( pistol == 525 ) {	//Diamondback gives 2 crits on backstab
			int iCrits = GetEntProp(attacker, Prop_Send, "m_iRevengeCrits");
			SetEntProp(attacker, Prop_Send, "m_iRevengeCrits", iCrits+2);
		}
		if( wepindex == 356 ) {
			int health = GetClientHealth(attacker)+180;
			if (health > 195)
				health = 400;
			SetEntProp(attacker, Prop_Data, "m_iHealth", health);
			SetEntProp(attacker, Prop_Send, "m_iHealth", health);
		}
		if( wepindex == 461 )	//Big Earner gives full cloak on backstab
			SetEntPropFloat(attacker, Prop_Send, "m_flCloakMeter", 100.0);

		return Plugin_Changed;
	}
	// Detects if boss is damaged by Rock Paper Scissors
	/*if( !damagecustom
		and TF2_IsPlayerInCondition(boss, TFCond_Taunting)
		and TF2_IsPlayerInCondition(attacker, TFCond_Taunting) )
	{
		damage = victim.GetProperty("iHealth")+0.2;
		fighter.SetProperty("iDamage", fighter.GetProperty("iDamage") + RoundFloat(damage));	// If necessary, just cheat by using the arrays.
		return Plugin_Changed;
	}*/
	if( damagecustom == TF_CUSTOM_TELEFRAG ) {
		damage = victim.GetProperty("iHealth")+0.2;
		return Plugin_Changed;
	}
	if( damagecustom == TF_CUSTOM_TAUNT_BARBARIAN_SWING ) {	// Gives 4 heads if successful sword killtaunt!
		for( int xyz=0 ; xyz<4 ; ++xyz )
			fighter.IncreaseHeadCount(); 
	}
	if( StrContains(classname, "tf_weapon_shotgun", false) > -1 && TF2_GetPlayerClass(attacker) == TFClass_Heavy ) { // Heavy Shotguns heal for damage dealt
		int health = GetClientHealth(attacker);
		int newHealth;
		int maxhp = GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
		if( health < RoundFloat(maxhp*1.5) ) {
			newHealth = RoundFloat(damage+health);
			if( damage+health > RoundFloat(maxhp*1.5) )
				newHealth = RoundFloat(maxhp*1.5);
			SetEntityHealth( attacker, newHealth );
		}
	}
	else if( StrContains(classname, "tf_weapon_sniperrifle", false) > -1 and VSH2GameMode_GetProperty("iRoundState") != 2 /* StateEnding */ ) {
		if( wepindex != 230 and wepindex != 526 and wepindex != 752 and wepindex != 30665 ) {
			float bossGlow = victim.GetProperty("flGlowtime");
			float chargelevel = (IsValidEntity(weapon) and weapon > MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
			float time = (bossGlow > 10 ? 1.0 : 2.0);
			time += (bossGlow > 10 ? (bossGlow > 20 ? 1 : 2) : 4)*(chargelevel/100);
			bossGlow += RoundToCeil(time);
			if( bossGlow > 30.0 )
				bossGlow = 30.0;
			victim.SetProperty("flGlowtime", bossGlow);
		}
		if( wepindex == 402 ) {	// bazaar bargain I think
			if( damagecustom == TF_CUSTOM_HEADSHOT )
				fighter.IncreaseHeadCount();
		}
		if( wepindex == 752 ) {
			float chargelevel = (IsValidEntity(weapon) && weapon > MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
			float add = 10 + (chargelevel / 10);
			if( TF2_IsPlayerInCondition(attacker, view_as< TFCond >(46)) )
				add /= 3.0;
			float rage = GetEntPropFloat(attacker, Prop_Send, "m_flRageMeter");
			SetEntPropFloat(attacker, Prop_Send, "m_flRageMeter", (rage + add > 100) ? 100.0 : rage + add);
		}
		if( wepindex == 230 )
			victim.SetProperty("flRAGE", bossrage - (damage * 0.03));
		
		if( !(damagetype & DMG_CRIT) ) {
			bool ministatus = (TF2_IsPlayerInCondition(attacker, TFCond_CritCola) or TF2_IsPlayerInCondition(attacker, TFCond_Buffed) or TF2_IsPlayerInCondition(attacker, TFCond_CritHype));
			
			damage *= (ministatus) ? 2.222222 : 3.0;
			return Plugin_Changed;
		}
	}
	
	if( FindConVar("vsh2_allow_boss_anchor").BoolValue ) {
		int iFlags = GetEntityFlags(boss);
#if defined _tf2attributes_included
		if( VSH2GameMode_GetProperty("bTF2Attribs") ) {
			// If Hale is ducking on the ground, it's harder to knock him back
			if( (iFlags & (FL_ONGROUND|FL_DUCKING)) == (FL_ONGROUND|FL_DUCKING) )
				TF2Attrib_SetByDefIndex(boss, 252, 0.0);
			else TF2Attrib_RemoveByDefIndex(boss, 252);
		}
		else {
			// Does not protect against sentries or FaN, but does against miniguns and rockets
			if( (iFlags & (FL_ONGROUND|FL_DUCKING)) == (FL_ONGROUND|FL_DUCKING) )
				damagetype |= DMG_PREVENT_PHYSICS_FORCE;
		}
#else
		if( (iFlags & (FL_ONGROUND|FL_DUCKING)) == (FL_ONGROUND|FL_DUCKING) )
			damagetype |= DMG_PREVENT_PHYSICS_FORCE;
#endif
	}
	switch( wepindex ) {
		case 593: {	// Third Degree
			int healers[MAXPLAYERS];
			int healercount = 0;
			for( int i=MaxClients ; i ; --i ) {
				if( IsValidClient(i) and IsPlayerAlive(i) and GetHealingTarget(i) == attacker )
				{
					healers[healercount] = i;
					healercount++;
				}
			}
			for( int i=0 ; i<healercount ; i++ ) {
				if( IsValidClient(healers[i]) and IsPlayerAlive(healers[i]) ) {
					int medigun = GetPlayerWeaponSlot(healers[i], TFWeaponSlot_Secondary);
					if( IsValidEntity(medigun) ) {
						char cls[32];
						GetEdictClassname(medigun, cls, sizeof(cls));
						if( !strcmp(cls, "tf_weapon_medigun", false) ) {
							float uber = GetMediCharge(medigun) + (0.1/healercount);
							float max = 1.0;
							if( GetEntProp(medigun, Prop_Send, "m_bChargeRelease") )
								max = 1.5;
							if( uber > max )
								uber = max;
							SetMediCharge(medigun, uber);
						}
					}
				}
			}
		}
		case 132, 266, 482, 1082: fighter.IncreaseHeadCount();
		case 355, 648: victim.SetProperty("flRAGE", bossrage - FindConVar("vsh2_fanowar_rage").FloatValue);
		case 317: fighter.SpawnSmallHealthPack(GetClientTeam(attacker));
		case 416: {	// Chdata's Market Gardener backstab
			bool jumping = fighter.GetProperty("bInJump");
			if( jumping ) {
				int maxhealth = victim.GetProperty("iMaxHealth");
				int markets = victim.GetProperty("iMarketted");
				damage = ( Pow(float(maxhealth), (0.74074))/*512.0*/ - (markets/128*float(maxhealth)) )/3.0;
				//divide by 3 because this is basedamage and lolcrits (0.714286)) + 1024.0)
				damagetype |= DMG_CRIT;
				
				if( markets < 5 )
					victim.SetProperty("iMarketted", ++markets);
				
				PrintCenterText(attacker, "You Market Gardened the Boss!");
				PrintCenterText(boss, "You Were Just Market Gardened!");
				
				EmitSoundToAll("player/doubledonk.wav", boss, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
				SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+2.0);
				return Plugin_Changed;
			}
		}
		case 214: {
			int health = GetClientHealth(attacker);
			int max = GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
			int newhealth = health+25;
			if( health < max+50 ) {
				if( newhealth > max+50 )
					newhealth = max+50;
				SetEntProp(attacker, Prop_Data, "m_iHealth", newhealth);
				SetEntProp(attacker, Prop_Send, "m_iHealth", newhealth);
			}
			if( TF2_IsPlayerInCondition(attacker, TFCond_OnFire) )
				TF2_RemoveCondition(attacker, TFCond_OnFire);
		}
		case 357: {
			SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
			if( GetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy") < 1 )
				SetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
			int health = GetClientHealth(attacker);
			int max = GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
			int newhealth = health+35;
			if( health < max+25 ) {
				if( newhealth > max+25 )
					newhealth = max+25;
				SetEntProp(attacker, Prop_Data, "m_iHealth", newhealth);
				SetEntProp(attacker, Prop_Send, "m_iHealth", newhealth);
			}
		}
		case 61, 1006: {  // Ambassador does 2.5x damage on headshot
			if( damagecustom == TF_CUSTOM_HEADSHOT ) {
				damage *= 2.5;
				return Plugin_Changed;
			}
		}
		/*
		case 16, 203, 751, 1149: {  //SMG does 2.5x damage on headshot
			if( damagecustom == TF_CUSTOM_HEADSHOT ) {
				damage = 27.0;
				return Plugin_Changed;
			}
		}
		*/
		case 525, 595: {
			int iCrits = GetEntProp(attacker, Prop_Send, "m_iRevengeCrits");
			if( iCrits ) {	// If a revenge crit was used, give a damage bonus
				damage = 85.0;
				return Plugin_Changed;
			}
		}
		case 656: {
			SetPawnTimer(StopTickle, FindConVar("vsh2_stop_tickle_time").FloatValue, victim.userid);
			if( TF2_IsPlayerInCondition(attacker, TFCond_Dazed) )
				TF2_RemoveCondition(attacker, TFCond_Dazed);
		}
	}
	return Plugin_Continue;
}
public Action PlagueDoc_OnBossDealDamage(VSH2Player victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if( !IsPlagueDoctor(VSH2Player(attacker)) )
		return Plugin_Continue;
	
	if( damagetype & DMG_CRIT )
		damagetype &= ~DMG_CRIT;
	
	int client = victim.index;
	if( damagecustom == TF_CUSTOM_BOOTS_STOMP ) {
		float flFallVelocity = GetEntPropFloat(inflictor, Prop_Send, "m_flFallVelocity");
		damage = 10.0 * (GetRandomFloat(0.8, 1.2) * (5.0 * (flFallVelocity / 300.0))); //TF2 Fall Damage formula, modified for VSH2
		return Plugin_Changed;
	}
	if( TF2_IsPlayerInCondition(client, TFCond_DefenseBuffed) ) {
		ScaleVector(damageForce, 9.0);
		damage *= 0.3;
		return Plugin_Changed;
	}
	if( TF2_IsPlayerInCondition(client, TFCond_CritMmmph) ) {
		damage *= 0.25;
		return Plugin_Changed;
	}

	int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	char mediclassname[32];
	if( IsValidEdict(medigun)
		and GetEdictClassname(medigun, mediclassname, sizeof(mediclassname))
		and !strcmp(mediclassname, "tf_weapon_medigun", false)
		and !TF2_IsPlayerInCondition(client, TFCond_Ubercharged)
		and weapon == GetPlayerWeaponSlot(attacker, 2)) {
		/*
			If medic has (nearly) full uber, use it as a single-hit shield to prevent medics from dying early.
			Entire team is pretty much screwed if all the medics just die.
		*/
		if( GetMediCharge(medigun) >= 0.90 ) {
			SetMediCharge(medigun, 0.5);
			damage *= 10;
			// Patch: Nov 14, 2017 - removing post-bonk slowdown.
			TF2_AddCondition(client, TFCond_UberchargedOnTakeDamage, 0.1);
			return Plugin_Changed;
		}
	}
	if( TF2_GetPlayerClass(client) == TFClass_Spy ) {  //eggs probably do melee damage to spies, then? That's not ideal, but eh.
		if( GetEntProp(client, Prop_Send, "m_bFeignDeathReady") and !TF2_IsPlayerInCondition(client, TFCond_Cloaked) ) {
			if( damagetype & DMG_CRIT )
				damagetype &= ~DMG_CRIT;
			damage = 85.0;
			return Plugin_Changed;
		}
		if( TF2_IsPlayerInCondition(client, TFCond_Cloaked) or TF2_IsPlayerInCondition(client, TFCond_DeadRingered) ) {
			if( damagetype & DMG_CRIT )
				damagetype &= ~DMG_CRIT;
			damage = 60.0;
			return Plugin_Changed;
		}
	}
	int ent = -1;
	while( (ent = FindEntityByClassname(ent, "tf_wearable_demoshield")) != -1 ) {
		if( GetOwner(ent) == client
			/*and damage >= float(GetClientHealth(client))*/
			and !TF2_IsPlayerInCondition(client, TFCond_Ubercharged)
			and !GetEntProp(ent, Prop_Send, "m_bDisguiseWearable")
			and weapon == GetPlayerWeaponSlot(attacker, 2) )
		{
			victim.SetProperty("iHits", victim.GetProperty("iHits")+1);
			//int HitsRequired = 0;
			//switch (GetItemIndex(ent)) {
			//	case 131, 1144: HitsRequired = 2;	// 2 hits for normal and festive Chargin' Targe
			//	case 406, 1099: HitsRequired = 1;
			//}
			// Patch: Nov 14, 2017 - removing post-bonk slowdown.
			TF2_AddCondition(client, TFCond_PasstimeInterception, 0.1);
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 1.0);
			//if (victim.iHits >= HitsRequired) {
			TF2_RemoveWearable(client, ent);
			EmitSoundToAll("player/spy_shield_break.wav", client, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, true, 0.0);
			//}
			break;
		}
	}
	return Plugin_Continue;
}
public void PlagueDoc_OnPlayerKilled(const VSH2Player attacker, const VSH2Player victim, Event event)
{
	//int deathflags = event.GetInt("death_flags");
	// attacker is plague doctor!
	if( attacker.GetProperty("bIsBoss") and IsPlagueDoctor(attacker) ) {
		ToCPlague(attacker).KilledPlayer(victim, event);
	}
	// attacker is a plague doctor minion!
	else if( attacker.GetProperty("bIsMinion") ) {
		VSH2Player owner = VSH2Player(attacker.GetProperty("iOwnerBoss"), true);
		if( IsPlagueDoctor(owner) )
			ToCPlague(owner).KilledPlayer(victim, event);
	}
	if( victim.GetProperty("bIsMinion") ) {
		// Cap respawning minions by the amount of minions there are. If 10 minions, then respawn him/her in 10 seconds.
		VSH2Player owner = VSH2Player(victim.GetProperty("iOwnerBoss"), true);
		if( IsPlagueDoctor(owner) and IsPlayerAlive(owner.index) ) {
			int minions = VSH2GameMode_CountMinions(false);
			victim.ConvertToMinion(float(minions));
		}
	}
}
public void PlagueDoc_OnPlayerHurt(const VSH2Player attacker, const VSH2Player victim, Event event)
{
	int damage = event.GetInt("damageamount");
	if( !victim.GetProperty("bIsBoss") and victim.GetProperty("bIsMinion") and !attacker.GetProperty("bIsMinion") ) {
		/* Have boss take damage if minions are hurt by players, this prevents bosses from hiding just because they gained minions
		 */
		VSH2Player ownerBoss = VSH2Player(victim.GetProperty("iOwnerBoss"), true);
		if( IsPlagueDoctor(ownerBoss) ) {
			ownerBoss.SetProperty("iHealth", ownerBoss.GetProperty("iHealth")-damage);
			ownerBoss.GiveRage(damage);
		}
		return;
	}
	if( IsPlagueDoctor(victim) and victim.GetProperty("bIsBoss") )
		victim.GiveRage(damage);
}
public void PlagueDoc_OnPlayerAirblasted(const VSH2Player airblaster, const VSH2Player airblasted, Event event)
{
	if( !IsPlagueDoctor(airblasted) )
		return;
	float rage = airblasted.GetProperty("flRAGE");
	airblasted.SetProperty("flRAGE", rage + FindConVar("vsh2_airblast_rage").FloatValue);
}
public void PlagueDoc_OnBossMedicCall(const VSH2Player rager)
{
	if( !IsPlagueDoctor(rager) )
		return;
	float rage = rager.GetProperty("flRAGE");
	if( rage < 100.0 )
		return;
	
	ToCPlague(rager).RageAbility();
	rager.SetProperty("flRAGE", 0.0);
}
public void PlagueDoc_OnBossJarated(const VSH2Player victim, const VSH2Player thrower)
{
	if( !IsPlagueDoctor(victim) )
		return;
	float rage = victim.GetProperty("flRAGE");
	victim.SetProperty("flRAGE", rage - FindConVar("vsh2_jarate_rage").FloatValue);
}
public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool &result)
{
	VSH2Player player = VSH2Player(client);
	if( player.GetProperty("bIsMinion") ) {
		VSH2Player ownerBoss = VSH2Player(player.GetProperty("iOwnerBoss"), true);
		if( IsPlagueDoctor(ownerBoss) )
			player.ClimbWall(weapon, 400.0, 0.0, false);
		
		result = false;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public void PlagueDoc_OnMessageIntro(const VSH2Player player, char message[512])
{
	if( !IsPlagueDoctor(player) )
		return;
	
	int health = player.GetProperty("iHealth");
	Format(message, 512, "%s\n%N has become The Plague Doctor with %i Health", message, player.index, health);
}
public void PlagueDoc_OnRoundEndInfo(const VSH2Player player, bool bossBool, char message[512])
{
	if( !IsPlagueDoctor(player) )
		return;
	int health = player.GetProperty("iHealth");
	int maxhealth = player.GetProperty("iMaxHealth");
	Format(message, 512, "%s\nPlague Doctor (%N) had %i (of %i) health left.", message, player.index, health, maxhealth);
	if( bossBool ) {
		// play Boss Wins sounds here!
	}
	
}
public void PlagueDoc_OnBossHealthCheck(const VSH2Player player, bool bossBool, char message[512])
{
	if( !IsPlagueDoctor(player) )
		return;
	int health = player.GetProperty("iHealth");
	int maxhealth = player.GetProperty("iMaxHealth");
	if( bossBool )
		PrintCenterTextAll("The Plague Doctor showed his current HP: %i of %i", health, maxhealth);
	else Format(message, 512, "%s\nPlague Doctor's current health is: %i of %i", message, health, maxhealth);
}




public void StopTickle(const int userid)
{
	int client = GetClientOfUserId(userid);
	if (!IsValidClient(client) || !IsPlayerAlive(client))
		return;
	if (!GetEntProp(client, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(client, Prop_Send, "m_hHighFivePartner")))
		TF2_RemoveCondition(client, TFCond_Taunting);
}

public void SetGravityNormal(const int userid)
{
	int i = GetClientOfUserId(userid);
	if( IsValidClient(i) )
		SetEntityGravity(i, 1.0);
}

void RecruitMinion(const VSH2Player base)
{
	int client = base.index;
	TF2_SetPlayerClass(client, TFClass_Scout, _, false);
	TF2_RemoveAllWeapons(client);
#if defined _tf2attributes_included
	if( VSH2GameMode_GetProperty("bTF2Attribs") )
		TF2Attrib_RemoveAll(client);
#endif
	int weapon = base.SpawnWeapon("tf_weapon_bat", 572, 100, 5, "6 ; 0.5 ; 57 ; 15.0 ; 26 ; 75.0 ; 49 ; 1.0 ; 68 ; -2.0");
	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
	TF2_AddCondition(client, TFCond_Ubercharged, 3.0);
	SetEntityHealth(client, 200);
	SetVariantString(ZombieModel);
	AcceptEntityInput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
	SetEntProp(client, Prop_Send, "m_nBody", 0);
	SetEntityRenderMode(client, RENDER_TRANSCOLOR);
	SetEntityRenderColor(client, 30, 160, 255, 255);
}


stock bool IsValidClient(const int client, bool nobots=false)
{ 
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
		return false; 
	return IsClientInGame(client); 
}
stock int SetWeaponAmmo(const int weapon, const int ammo)
{
	int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if (owner <= 0)
		return 0;
	if (IsValidEntity(weapon)) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(owner, iAmmoTable+iOffset, ammo, 4, true);
	}
	return 0;
}
stock int GetWeaponAmmo(int weapon)
{
	int owner = GetOwner(weapon);
	if (owner <= 0)
		return 0;
	if (IsValidEntity(weapon)) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		return GetEntData(owner, iAmmoTable+iOffset, 4);
	}
	return 0;
}
stock int GetWeaponClip(const int weapon)
{
	if (IsValidEntity(weapon)) {
		int AmmoClipTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		return GetEntData(weapon, AmmoClipTable);
	}
	return 0;
}
stock int SetWeaponClip(const int weapon, const int ammo)
{
	if (IsValidEntity(weapon)) {
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		SetEntData(weapon, iAmmoTable, ammo, 4, true);
	}
	return 0;
}
stock int GetOwner(const int ent)
{
	if ( IsValidEdict(ent) && IsValidEntity(ent) )
		return GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	return -1;
}
stock int GetSlotFromWeapon(const int iClient, const int iWeapon)
{
	for (int i=0; i<5; i++) {
		if ( iWeapon == GetPlayerWeaponSlot(iClient, i) )
			return i;
	}
	return -1;
}
stock bool OnlyScoutsLeft(const int team)
{
	for (int i=MaxClients ; i ; --i) {
		if ( ! IsValidClient(i) or ! IsPlayerAlive(i) )
			continue;
		if (GetClientTeam(i) == team and TF2_GetPlayerClass(i) != TFClass_Scout)
			return false;
	}
	return true;
}
stock void SetPawnTimer(Function func, float thinktime = 0.1, any param1 = -999, any param2 = -999)
{
	DataPack thinkpack = new DataPack();
	thinkpack.WriteFunction(func);
	thinkpack.WriteCell(param1);
	thinkpack.WriteCell(param2);

	CreateTimer(thinktime, DoThink, thinkpack, TIMER_DATA_HNDL_CLOSE);
}

public Action DoThink(Handle hTimer, DataPack hndl)
{
	hndl.Reset();
	
	Function pFunc = hndl.ReadFunction();
	Call_StartFunction( null, pFunc );
	
	any param1 = hndl.ReadCell();
	if ( param1 != -999 )
		Call_PushCell(param1);
	
	any param2 = hndl.ReadCell();
	if ( param2 != -999 )
		Call_PushCell(param2);
	
	Call_Finish();
	return Plugin_Continue;
}
stock void IncrementHeadCount(const int client, bool addhealth = true, int addheads = 1)
{
	if ( (TF2_GetPlayerClass(client) == TFClass_DemoMan) and  ! TF2_IsPlayerInCondition(client, TFCond_DemoBuff) )
		TF2_AddCondition(client, TFCond_DemoBuff, TFCondDuration_Infinite); //Apply this condition to Demomen to give them their glowing eye effect.
	int decapitations = GetEntProp(client, Prop_Send, "m_iDecapitations");
	SetEntProp(client, Prop_Send, "m_iDecapitations", decapitations + addheads);
	if ( addhealth )
	{
		int health = GetClientHealth(client);
		//health += (decapitations >= 4 ? 10 : 15);
		if ( health + (15 * addheads) <= 300 ) // TODO: Replace this with an overheal calculation (MaxHP * 1.5) OR add a maxhealth arg. 
			health += 15 * addheads;
		else
			health = 300;
		SetEntProp(client, Prop_Data, "m_iHealth", health);
		SetEntProp(client, Prop_Send, "m_iHealth", health);
	}
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);   //recalc their speed
}
stock float GetMediCharge(const int medigun)
{
	if (IsValidEdict(medigun) && IsValidEntity(medigun))
		return GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
	return -1.0;
}
stock void SetMediCharge(const int medigun, const float val)
{
	if (IsValidEdict(medigun) && IsValidEntity(medigun))
		SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", val);
}
stock int GetItemIndex(const int item)
{
	if (IsValidEdict(item) && IsValidEntity(item))
		return GetEntProp(item, Prop_Send, "m_iItemDefinitionIndex");
	return -1;
}
stock int GetHealingTarget(const int client)
{
	int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if (!IsValidEdict(medigun) || !IsValidEntity(medigun))
		return -1;
	
	if( HasEntProp(medigun, Prop_Send, "m_bHealing") ) {
		if( GetEntProp(medigun, Prop_Send, "m_bHealing") )
			return GetEntPropEnt( medigun, Prop_Send, "m_hHealingTarget" );
	}
	return -1;
}
public int HintPanel(Menu menu, MenuAction action, int param1, int param2)
{
	return;
}
