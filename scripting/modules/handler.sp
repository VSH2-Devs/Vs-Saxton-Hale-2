/*
ALL NON-BOSS AND NON-MINION RELATED CODE IS NEAR THE BOTTOM. HAVE FUN CODING!
*/

#include "bosses.sp"

enum /* Bosses */	/* When you add custom Bosses, add to the anonymous enum as the Boss' ID */
{
	Hale = 0,
	Vagineer = 1,
	CBS = 2,
	HHHjr = 3,
	Bunny = 4,
	PlagueDoc = 5,
};

#define MAXBOSS		5	// When adding new bosses, increase the MAXBOSS define for the newest boss id

/*
PLEASE REMEMBER THAT PLAYERS THAT DON'T HAVE THEIR BOSS ID'S SET ARE NOT BOSSES.
THIS PLUGIN HAS BEEN SETUP SO THAT IF YOU BECOME A BOSS, YOU MUST HAVE A VALID BOSS ID

FOR MANAGEMENT FUNCTIONS, DO NOT HAVE THEM DISCRIMINATE WHO IS A BOSS OR NOT, SIMPLY CHECK THE ITYPE TO SEE IF IT REALLY WAS A BOSS PLAYER.
*/


public void GetBossType()	
{
	if (gamemode.hNextBoss and gamemode.hNextBoss.iPresetType > -1) {
		gamemode.iSpecial = gamemode.hNextBoss.iPresetType;
		if ( gamemode.iSpecial > MAXBOSS)
			gamemode.iSpecial = MAXBOSS;
		return;
	}
	BaseBoss boss = gamemode.FindNextBoss();
	if (boss.iPresetType > -1 and gamemode.iSpecial is -1) {
		gamemode.iSpecial = boss.iPresetType;
		if ( gamemode.iSpecial > MAXBOSS)
			gamemode.iSpecial = MAXBOSS;
		return;
	}
	if (gamemode.iSpecial > -1) {	// Clamp the chosen special so we don't error out.
		if ( gamemode.iSpecial > MAXBOSS)
			gamemode.iSpecial = MAXBOSS;
	}
	else gamemode.iSpecial = GetRandomInt(Hale, MAXBOSS);
}

public void ManageDownloads()
{
	PrecacheSound("ui/item_store_add_to_cart.wav", true);
	PrecacheSound("player/doubledonk.wav", true);
	
	PrecacheSound("saxton_hale/9000.wav", true);
	CheckDownload("sound/saxton_hale/9000.wav");
	PrecacheSound("vo/announcer_am_capincite01.mp3", true);
	PrecacheSound("vo/announcer_am_capincite03.mp3", true);
	PrecacheSound("vo/announcer_am_capenabled02.mp3", true);
	
	AddHaleToDownloads	();
	AddVagToDownloads	();
	AddCBSToDownloads	();
	AddHHHToDownloads	();
	AddBunnyToDownloads	();
	AddPlagueDocToDownloads	();
}

public void ManageMenu( Menu& menu )
{
	AddHaleToMenu(menu);
	AddVagToMenu(menu);
	AddCBSToMenu(menu);
	AddHHHToMenu(menu);
	AddBunnyToMenu(menu);
	AddPlagueToMenu(menu);
}

public void ManageConnect(const int client)
{
	
}
public void ManageDisconnect(const int client)
{
	BaseBoss leaver = BaseBoss(client);
	if (leaver.bIsBoss) {
		if (gamemode.iRoundState is StateRunning)
			ForceTeamWin(RED);

		if (gamemode.iRoundState is StateStarting) {
			BaseBoss replace = gamemode.FindNextBoss();
			if (gamemode.hNextBoss) {
				replace = gamemode.hNextBoss;
				gamemode.hNextBoss = SPNULL;
			}
			if ( IsValidClient(replace.index) ) {
				replace.bSetOnSpawn = true;
				replace.iType = leaver.iType;
				ManageOnBossSelected(replace);
				replace.ConvertToBoss();
				if (GetClientTeam(replace.index) != BLU)
					replace.ForceTeamChange(BLU);
				CPrintToChat(replace.index, "{olive}[VSH2]{default} {green}Surprise! You're on NOW!{default}");
			}
		}
		CPrintToChatAll("{olive}[VSH2]{default} {red}A Boss Just Disconnected!{default}");
	} else {
		if (IsValidClient(client)) {
			if ( IsPlayerAlive(client) )
				CheckAlivePlayers();
			if ( client == gamemode.FindNextBoss().index )
				SetPawnTimer(_SkipBossPanel, 1.0);
		}
		if (gamemode.hNextBoss and client == gamemode.hNextBoss.index)
			gamemode.hNextBoss = SPNULL;
	}
}

public void ManageOnBossSelected(const BaseBoss base)	// Don't forget to set custom music here using iSongPick property
{
	switch ( base.iType )
	{
		case -1: {}
		/*case VagineerHale:	// If the randomly selected boss is a multiboss, we set it up here
		{
			base.iType = Hale;
			if (gamemode.iPlaying >= 7)	// If there's 7+ people, allow multiboss Vagineer and Hale combo!
			{
				BaseBoss companion = gamemode.FindNextBoss();
				companion.bSetOnSpawn = true;
				companion.iType = Vagineer;		// make companion as Vagineer while main guy is Hale
				ManageOnBossSelected(companion);	// Calling this so our Help menu attacks our companion ;3
				companion.ConvertToBoss();
				if (GetClientTeam(companion.index) is RED)
					companion.ForceTeamChange(BLU);
			}
		}*/
	}
	if (not GetRandomInt(0, 3))
		ManageBossHelp(base);
}

public void ManageOnTouchPlayer(const BaseBoss base, const BaseBoss victim)
{
	switch ( base.iType )
	{
		case -1: {}
	}
}

public void ManageOnTouchBuilding(const BaseBoss base, const int building)
{
	switch ( base.iType )
	{
		case -1: {}
	}
}

public void ManageBossHelp(const BaseBoss base)
{
	switch ( base.iType )
	{
		case -1: {}
		case Hale:		ToCHale(base).Help();
		case Vagineer:		ToCVagineer(base).Help();
		case CBS:		ToCChristian(base).Help();
		case HHHjr:		ToCHHHJr(base).Help();
		case Bunny:		ToCBunny(base).Help();
		case PlagueDoc:		ToCPlague(base).Help();
	}
}

public void ManageBossThink(const BaseBoss base)
{
	switch ( base.iType )
	{
		case -1: {}
		case Hale:		ToCHale(base).Think();
		case Vagineer:		ToCVagineer(base).Think();
		case CBS:		ToCChristian(base).Think();
		case HHHjr:		ToCHHHJr(base).Think();
		case Bunny:		ToCBunny(base).Think();
		case PlagueDoc:		ToCPlague(base).Think();
	}
}

public void ManageBossModels(const BaseBoss base)
{
	switch ( base.iType )
	{
		case -1: {}
		case Hale:		ToCHale(base).SetModel();
		case Vagineer:		ToCVagineer(base).SetModel();
		case CBS:		ToCChristian(base).SetModel();
		case HHHjr:		ToCHHHJr(base).SetModel();
		case Bunny:		ToCBunny(base).SetModel();
		case PlagueDoc:		ToCPlague(base).SetModel();
	}
}

public void ManageBossDeath(const BaseBoss base)
{
	switch ( base.iType )
	{
		case -1: {}
		case Hale:		ToCHale(base).Death();
		case Vagineer:		ToCVagineer(base).Death();
		case CBS:		ToCChristian(base).Death();
		case HHHjr:		ToCHHHJr(base).Death();
		case Bunny:		ToCBunny(base).Death();
	}
	toggle(gamemode.iHealthBarState);
}

public void ManageBossEquipment(const BaseBoss base)
{
	switch ( base.iType )
	{
		case -1: {}
		case Hale:		ToCHale(base).Equip();
		case Vagineer:		ToCVagineer(base).Equip();
		case CBS:		ToCChristian(base).Equip();
		case HHHjr:		ToCHHHJr(base).Equip();
		case Bunny:		ToCBunny(base).Equip();
		case PlagueDoc:		ToCPlague(base).Equip();
	}
}

public void ManageBossTransition(const BaseBoss base) /* whatever stuff needs initializing should be done here */
{
	switch ( base.iType )
	{
		case -1: {}
		case Hale:
			TF2_SetPlayerClass(base.index, TFClass_Soldier, _, false);
		case Vagineer:
			TF2_SetPlayerClass(base.index, TFClass_Engineer, _, false);
		case CBS:
			TF2_SetPlayerClass(base.index, TFClass_Sniper, _, false);
		case HHHjr, Bunny:
			TF2_SetPlayerClass(base.index, TFClass_DemoMan, _, false);
		case PlagueDoc:
			TF2_SetPlayerClass(base.index, TFClass_Medic, _, false);
	}
	ManageBossModels(base);
	switch ( base.iType )
	{
		case -1: {}
		case HHHjr: ToCHHHJr(base).flCharge = -1000.0;
	}
	if (base.iSongPick is -1) {
		switch ( base.iType )
		{
			case -1: {}
			case Bunny: base.iSongPick = GetRandomInt(0, 1);
			case PlagueDoc: base.iSongPick = GetRandomInt(0, 2);
		}
	}
	ManageBossEquipment(base);
}

public void ManageMinionTransition(const BaseBoss base)
{
	if (!base.bIsMinion)
		return;
	base.ForceTeamChange(BLU); // Force our guy to the dark side lmao

	int ent = -1;
	while ( (ent = FindEntityByClassname(ent, "tf_wearable")) != -1 )
	{
		if (GetOwner(ent) == base.index) {
			int index = GetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex");
			switch (index)
			{
				case 438, 463, 167, 477, 493, 233, 234, 241, 280, 281, 282, 283, 284, 286, 288, 362, 364, 365, 536, 542, 577, 599, 673, 729, 791, 839, 1015, 5607: {}
				default: TF2_RemoveWearable(base.index, ent); //AcceptEntityInput(ent, "kill");
			}
		}
	}
	ent = -1;
	while ( (ent = FindEntityByClassname(ent, "tf_powerup_bottle")) != -1 )
	{
		if (GetOwner(ent) == base.index) {
			int index = GetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex");
			switch (index)
			{
				case 438, 463, 167, 477, 493, 233, 234, 241, 280, 281, 282, 283, 284, 286, 288, 362, 364, 365, 536, 542, 577, 599, 673, 729, 791, 839, 1015, 5607: {}
				default: TF2_RemoveWearable(base.index, ent); //AcceptEntityInput(ent, "kill");
			}
		}
	}
	ent = -1;
	while ( (ent = FindEntityByClassname(ent, "tf_wearable_demoshield")) != -1 )
	{
		if (GetOwner(ent) == base.index)
			TF2_RemoveWearable(base.index, ent);
	}
	switch (BaseBoss(base.iOwnerBoss).iType) {
		case -1: {}
		case PlagueDoc: {
			TF2_SetPlayerClass(base.index, TFClass_Scout, _, false);
			TF2_RemoveAllWeapons(base.index);
#if defined _tf2attributes_included
			TF2Attrib_RemoveAll(base.index);
#endif
			int weapon = base.SpawnWeapon("tf_weapon_bat", 572, 100, 5, "6 ; 0.5 ; 57 ; 15.0 ; 26 ; 75.0 ; 49 ; 1.0 ; 68 ; -2.0");
			SetEntPropEnt(base.index, Prop_Send, "m_hActiveWeapon", weapon);
			TF2_AddCondition(base.index, TFCond_Ubercharged, 3.0);
			SetVariantString(ZombieModel);
			AcceptEntityInput(base.index, "SetCustomModel");
			SetEntProp(base.index, Prop_Send, "m_bUseClassAnimations", 1);
			SetEntProp(base.index, Prop_Send, "m_nBody", 0);
			SetEntityRenderMode(base.index, RENDER_TRANSCOLOR); 
			SetEntityRenderColor(base.index, 30, 160, 255, 255);
		}
	}
}

public void ManagePlayBossIntro(const BaseBoss base)
{
	switch ( base.iType )
	{
		case -1: {}
		case Hale:	ToCHale(base).PlaySpawnClip();
		case Vagineer:	ToCVagineer(base).PlaySpawnClip();
		case CBS:	ToCChristian(base).PlaySpawnClip();
		case HHHjr:	ToCHHHJr(base).PlaySpawnClip();
		case Bunny:	ToCBunny(base).PlaySpawnClip();
		case PlagueDoc:	ToCPlague(base).PlaySpawnClip();
	}
}

public Action ManageOnBossTakeDamage(const BaseBoss victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	switch ( victim.iType )
	{
		case -1: {}
		case Hale, Vagineer, CBS, HHHjr, Bunny, PlagueDoc:
		{
			char classname [64], strEntname [32];
			if ( IsValidEdict(inflictor) )
				GetEntityClassname(inflictor, strEntname, sizeof(strEntname));
			if ( IsValidEdict(weapon) )
				GetEdictClassname(weapon, classname, sizeof(classname));

			int wepindex = GetItemIndex(weapon);
			if ( damagecustom is TF_CUSTOM_BACKSTAB or (not strcmp(classname, "tf_weapon_knife", false) and damage > victim.iHealth) )
			// Bosses shouldn't die from a single backstab
			{
				switch (victim.iType)
				{
					case Hale: Format(snd, FULLPATH, "%s%i.wav", HaleStubbed132, GetRandomInt(1, 4));
					case Vagineer: strcopy(snd, FULLPATH, "vo/engineer_positivevocalization01.mp3");
					case HHHjr: Format(snd, FULLPATH, "vo/halloween_boss/knight_pain0%d.mp3", GetRandomInt(1, 3));
					case Bunny: strcopy(snd, PLATFORM_MAX_PATH, BunnyPain[GetRandomInt(0, sizeof(BunnyPain)-1)]);
				}
				EmitSoundToAll(snd, victim.index); EmitSoundToAll(snd, victim.index);

				float changedamage = ( (Pow(float(victim.iMaxHealth)*0.0014, 2.0) + 899.0) - (float(victim.iMaxHealth)*(float(victim.iStabbed)/100)) );
				if (victim.iStabbed < 4)
					victim.iStabbed++;
				damage = changedamage/3; // You can level "damage dealt" with backstabs
				damagetype |= DMG_CRIT;

				EmitSoundToClient(victim.index, "player/spy_shield_break.wav");
				EmitSoundToClient(attacker, "player/spy_shield_break.wav");
				EmitSoundToClient(victim.index, "player/crit_received3.wav");
				EmitSoundToClient(attacker, "player/crit_received3.wav");
				float curtime = GetGameTime();
				SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", curtime+2.0);
				SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", curtime+2.0);
				SetEntPropFloat(attacker, Prop_Send, "m_flStealthNextChangeTime", curtime+1.0);
				TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, 1.5);
				TF2_AddCondition(attacker, TFCond_Ubercharged, 2.0);
				int vm = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
				if (vm > MaxClients and IsValidEntity(vm) and TF2_GetPlayerClass(attacker) is TFClass_Spy)
				{
					int melee = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Melee);
					int anim = 15;
					switch (melee) {
						case 727: anim = 41;
						case 4, 194, 665, 794, 803, 883, 892, 901, 910: anim = 10;
						case 638: anim = 31;
					}
					SetEntProp(vm, Prop_Send, "m_nSequence", anim);
				}
				PrintCenterText(attacker, "You Tickled The Boss!");
				PrintCenterText(victim.index, "You Were Just Tickled!");
				int pistol = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Primary);
				if (pistol is 525) {	//Diamondback gives 2 crits on backstab
					int iCrits = GetEntProp(attacker, Prop_Send, "m_iRevengeCrits");
					SetEntProp(attacker, Prop_Send, "m_iRevengeCrits", iCrits+2);
				}
				if (wepindex is 356) {
					int health = GetClientHealth(attacker)+180;
					if (health > 195)
						health = 400;
					SetEntProp(attacker, Prop_Data, "m_iHealth", health);
					SetEntProp(attacker, Prop_Send, "m_iHealth", health);
				}
				if (wepindex is 461)	//Big Earner gives full cloak on backstab
					SetEntPropFloat(attacker, Prop_Send, "m_flCloakMeter", 100.0);

				return Plugin_Changed;
			}
			if ( not damagecustom
				and TF2_IsPlayerInCondition(victim.index, TFCond_Taunting)
				and TF2_IsPlayerInCondition(attacker, TFCond_Taunting) )
			{
				damage = victim.iHealth+0.2;
				return Plugin_Changed;
			}
			else if (damagecustom equals TF_CUSTOM_TELEFRAG) {
				damage = victim.iHealth+0.2;
				return Plugin_Changed;
			}
			if (damagecustom is TF_CUSTOM_TAUNT_BARBARIAN_SWING)	// Gives 4 heads if successful sword killtaunt!
			{
				for (int h=0; h<4; ++h)
					IncrementHeadCount(attacker);
			}
			if ( not strcmp(classname, "tf_weapon_shotgun_hwg", false) )
			{
				int health = GetClientHealth(attacker);
				int newHealth;
				int maxhp = GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
				if (health < maxhp) {
					newHealth = RoundFloat(damage+health);
					if (damage+health > maxhp)
						newHealth = maxhp;
					SetEntityHealth( attacker, newHealth );
				}
			}

			switch (wepindex) {
				case 593:	//Third Degree
				{
					int healers[MAXPLAYERS];
					int healercount = 0;
					for (int i=MaxClients ; i ; --i) {
						if (IsClientValid(i) and IsPlayerAlive(i) and GetHealingTarget(i) is attacker)
						{
							healers[healercount] = i;
							healercount++;
						}
					}
					for (int i=0 ; i<healercount ; i++) {
						if (IsValidClient(healers[i]) and IsPlayerAlive(healers[i]))
						{
							int medigun = GetPlayerWeaponSlot(healers[i], TFWeaponSlot_Secondary);
							if (IsValidEntity(medigun)) {
								char cls[32];
								GetEdictClassname(medigun, cls, sizeof(cls));
								if ( not strcmp(cls, "tf_weapon_medigun", false) ) {
									float uber = GetMediCharge(medigun) + (0.1/healercount);
									float max = 1.0;
									if (GetEntProp(medigun, Prop_Send, "m_bChargeRelease"))
										max = 1.5;
									if (uber > max)
										uber = max;
									SetMediCharge(medigun, uber);
								}
							}
						}
					}
				}
				case 14, 201, 230, 402, 526, 664, 752, 792, 801, 851, 881, 890, 899, 908, 957, 966, 1098:
				{
					switch (wepindex)	//cleaner to read than if wepindex == || wepindex == || etc
					{
						case 14, 201, 664, 792, 801, 851, 881, 890, 899, 908, 957, 966:
						{
							if (gamemode.iRoundState not_eq StateEnding) {
								float bossGlow = victim.flGlowtime;
								float chargelevel = (IsValidEntity(weapon) and weapon > MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
								float time = (bossGlow > 10 ? 1.0 : 2.0);
								time += (bossGlow > 10 ? (bossGlow > 20 ? 1 : 2) : 4)*(chargelevel/100);
								bossGlow += RoundToCeil(time);
								if (bossGlow > 30.0)
									bossGlow = 30.0;
								victim.flGlowtime = bossGlow;
							}
						}
					}
					if (wepindex == 752 and gamemode.iRoundState not_eq StateEnding)
					{
						float chargelevel = (IsValidEntity(weapon) && weapon > MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
						float add = 10 + (chargelevel / 10);
						if (TF2_IsPlayerInCondition(attacker, view_as<TFCond>(46)))
							add /= 3;
						float rage = GetEntPropFloat(attacker, Prop_Send, "m_flRageMeter");
						SetEntPropFloat(attacker, Prop_Send, "m_flRageMeter", (rage + add > 100) ? 100.0 : rage + add);
					}
					if ( !(damagetype & DMG_CRIT) ) {
						bool ministatus = (TF2_IsPlayerInCondition(attacker, TFCond_CritCola) or TF2_IsPlayerInCondition(attacker, TFCond_Buffed) or TF2_IsPlayerInCondition(attacker, TFCond_CritHype));

						damage *= (ministatus) ? 2.222222 : 3.0;
						if (wepindex == 230) {
							victim.flRAGE -= (damage/2.0);
						}
						return Plugin_Changed;
					}
					else if (wepindex == 230)
						victim.flRAGE -= (damage*3.0/2.0);
				}
				case 132, 266, 482, 1082: IncrementHeadCount(attacker);
				case 355, 648: victim.flRAGE -= cvarVSH2[FanoWarRage].FloatValue;
				case 317: SpawnSmallHealthPackAt(attacker, GetClientTeam(attacker));
				case 416:	// Chdata's Market Gardener backstab
				{
					if (BaseBoss(attacker).bInJump) {
						//Can't get stuck in HHH in midair and mg him multiple times.
						//if ((GetEntProp(victim.index, Prop_Send, "m_iStunFlags") & TF_STUNFLAGS_GHOSTSCARE | TF_STUNFLAG_NOSOUNDOREFFECT) && Special == HHH) return Plugin_Continue;

						damage = ( Pow(float(victim.iMaxHealth), (0.74074))/*512.0*/ - (victim.iMarketted/128*float(victim.iMaxHealth)) )/3.0;
						//divide by 3 because this is basedamage and lolcrits (0.714286)) + 1024.0)
						damagetype |= DMG_CRIT;

						if (victim.iMarketted < 5)
							victim.iMarketted++;

						PrintCenterText(attacker, "You Market Gardened the Boss!");
						PrintCenterText(victim.index, "You Were Just Market Gardened!");

						EmitSoundToClient(victim.index, "player/doubledonk.wav", _, _, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.6, 100, _, damagePosition, NULL_VECTOR, false, 0.0);
						EmitSoundToClient(attacker, "player/doubledonk.wav", _, _, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.6, 100, _, damagePosition, NULL_VECTOR, false, 0.0);
						SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+2.0);

						return Plugin_Changed;
					}
				}
				case 214:
				{
					int health = GetClientHealth(attacker);
					int max = GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
					int newhealth = health+25;
					if (health < max+50) {
						if (newhealth > max+50)
							newhealth = max+50;
						SetEntProp(attacker, Prop_Data, "m_iHealth", newhealth);
						SetEntProp(attacker, Prop_Send, "m_iHealth", newhealth);
					}
					if (TF2_IsPlayerInCondition(attacker, TFCond_OnFire))
						TF2_RemoveCondition(attacker, TFCond_OnFire);
				}
				case 61, 1006:  //Ambassador does 2.5x damage on headshot
				{
					if (damagecustom equals TF_CUSTOM_HEADSHOT)
					{
						damage *= 2.5;
						return Plugin_Changed;
					}
				}
				/*case 16, 203, 751, 1149:  //SMG does 2.5x damage on headshot
				{
					if (damagecustom equals TF_CUSTOM_HEADSHOT)
					{
						damage = 27.0;
						return Plugin_Changed;
					}
				}*/
				case 525, 595:
				{
					int iCrits = GetEntProp(attacker, Prop_Send, "m_iRevengeCrits");
					if (iCrits) {	//If a revenge crit was used, give a damage bonus
						damage = 85.0;
						return Plugin_Changed;
					}
				}
				case 656:
				{
					SetPawnTimer(_StopTickle, cvarVSH2[StopTickleTime].FloatValue, victim.userid);
					if (TF2_IsPlayerInCondition(attacker, TFCond_Dazed))
						TF2_RemoveCondition(attacker, TFCond_Dazed);
				}
			}
			char trigger[32];
			if (GetEdictClassname(attacker, trigger, sizeof(trigger)) and not strcmp(trigger, "trigger_hurt", false))
			{
				if (damage >= 350.0)
					TeleportToSpawn(victim.index, BLU);
			}
		}
	}
	return Plugin_Continue;
}

public Action ManageOnBossDealDamage(const BaseBoss victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	BaseBoss fighter = BaseBoss(attacker);
	switch ( fighter.iType )
	{
		case -1: {}
		case Hale, Vagineer, CBS, HHHjr, Bunny, PlagueDoc:
		{
			int client = victim.index;
			if (TF2_IsPlayerInCondition(client, TFCond_DefenseBuffed))
			{
				ScaleVector(damageForce, 9.0);
				damage *= 0.3;
				return Plugin_Changed;
			}
			/*if (TF2_IsPlayerInCondition(client, TFCond_DefenseBuffMmmph))
			{
				damage *= 9;
				TF2_AddCondition(client, TFCond_Bonked, 0.1);
				return Plugin_Changed;
			}*/
			if (TF2_IsPlayerInCondition(client, TFCond_CritMmmph))
			{
				damage *= 0.25;
				return Plugin_Changed;
			}

			int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
			char mediclassname[32];
			if (IsValidEdict(medigun)
				and GetEdictClassname(medigun, mediclassname, sizeof(mediclassname))
				and not strcmp(mediclassname, "tf_weapon_medigun", false)
				and not TF2_IsPlayerInCondition(client, TFCond_Ubercharged)
				and weapon is GetPlayerWeaponSlot(attacker, 2)) {
				/*
				If medic has (nearly) full uber, use it as a single-hit shield to prevent medics from dying early.
				Entire team is pretty much screwed if all the medics just die.
				*/
				if (GetMediCharge(medigun) >= 0.90) {
					SetMediCharge(medigun, 0.0);
					damage = 1.0;
					ScaleVector(damageForce, 50.0);
					return Plugin_Changed;
				}
			}
			if (TF2_GetPlayerClass(client) is TFClass_Spy)  //eggs probably do melee damage to spies, then? That's not ideal, but eh.
			{
				if (GetEntProp(client, Prop_Send, "m_bFeignDeathReady") and not TF2_IsPlayerInCondition(client, TFCond_Cloaked))
				{
					if (damagetype & DMG_CRIT)
						damagetype &= ~DMG_CRIT;
					damage = 100.0;
					return Plugin_Changed;
				}
				if (TF2_IsPlayerInCondition(client, TFCond_Cloaked) or TF2_IsPlayerInCondition(client, TFCond_DeadRingered))
				{
					if (damagetype & DMG_CRIT)
						damagetype &= ~DMG_CRIT;
					damage = 100.0;
					return Plugin_Changed;
				}
			}
			int ent = -1;
			while ((ent = FindEntityByClassname(ent, "tf_wearable_demoshield")) != -1)
			{
				if (GetOwner(ent) is client and not GetEntProp(ent, Prop_Send, "m_bDisguiseWearable") and weapon is GetPlayerWeaponSlot(attacker, 2))
				{
					victim.iHits++;
					int HitsRequired = 0;
					int index = GetItemIndex(ent);
					switch (index)
					{
						case 131, 1144: HitsRequired = 2;	// 2 hits for normal and festive Chargin' Targe
						case 406, 1099: HitsRequired = 1;
					}
					TF2_AddCondition(client, TFCond_Bonked, 0.1);
					if (HitsRequired <= victim.iHits) {
						TF2_RemoveWearable(client, ent);
						EmitSoundToClient(client, "player/spy_shield_break.wav", _, _, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.7, 100, _, damagePosition, NULL_VECTOR, false, 0.0);
						EmitSoundToClient(client, "player/spy_shield_break.wav", _, _, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.7, 100, _, damagePosition, NULL_VECTOR, false, 0.0);
						EmitSoundToClient(attacker, "player/spy_shield_break.wav", _, _, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.7, 100, _, damagePosition, NULL_VECTOR, false, 0.0);
						EmitSoundToClient(attacker, "player/spy_shield_break.wav", _, _, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.7, 100, _, damagePosition, NULL_VECTOR, false, 0.0);
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

public void ManageBossKillPlayer(const BaseBoss attacker, const BaseBoss victim, Event event) // To lazy to code this better lol
{
	//int dmgbits = event.GetInt("damagebits");
	if (victim.bIsBoss)	// If victim is a boss, kill him off
		SetPawnTimer(_BossDeath, 0.1, victim.userid);

	if (attacker.bIsBoss) {
		switch ( attacker.iType )
		{
			case -1: {}
			case Hale:
			{
				int deathflags = event.GetInt("death_flags");
				if ( deathflags & TF_DEATHFLAG_DEADRINGER )
					event.SetString("weapon", "fists");
				else ToCHale(attacker).KilledPlayer(victim, event);
			}
			case Vagineer:	ToCVagineer(attacker).KilledPlayer(victim, event);
			case CBS:	ToCChristian(attacker).KilledPlayer(victim, event);
			case HHHjr:	ToCHHHJr(attacker).KilledPlayer(victim, event);
			case Bunny:	ToCBunny(attacker).KilledPlayer(victim, event);
			case PlagueDoc:	ToCPlague(attacker).KilledPlayer(victim, event);
		}
	}
	else if (attacker.bIsMinion) {
		BaseBoss owner = BaseBoss(attacker.iOwnerBoss);
		switch (owner.iType) {
			case -1: {}
			case PlagueDoc: {
				victim.iOwnerBoss = owner.userid;
				victim.ConvertToMinion(0.4);
			}
		}
	}
	if (victim.bIsMinion) {
		// Cap respawning minions by the amount of minions there are. If 10 minions, then respawn him/her in 10 seconds.
		BaseBoss owner = BaseBoss(victim.iOwnerBoss);
		switch (owner.iType) {
			case -1: {}
			case PlagueDoc: {
				int _minions = gamemode.CountMinions(false);
				SetPawnTimer(_MakePlayerMinion, float(_minions), victim.userid);
			}
		}
	}
}
public void ManageHurtPlayer(const BaseBoss attacker, const BaseBoss victim, Event event)
{
	int damage = event.GetInt("damageamount");
	int custom = event.GetInt("custom");
	int weapon = GetEventInt(event, "weaponid");

	if (not victim.bIsBoss and victim.bIsMinion and not attacker.bIsMinion)
	{
		/* Have boss take damage if minions are hurt by players, this prevents bosses from hiding just because they gained minions */
		BaseBoss ownerBoss = BaseBoss(victim.iOwnerBoss);
		ownerBoss.iHealth -= damage;
		ownerBoss.GiveRage(damage);
		return;
	}
	switch ( victim.iType ) {
		case -1: {}
		case Hale, Vagineer, CBS, HHHjr, Bunny, PlagueDoc:
		{
			victim.iHealth -= damage;
			victim.GiveRage(damage);
		}
	}
	if (custom is TF_CUSTOM_TELEFRAG)
		damage = (IsPlayerAlive(attacker.index) ? 9001 : 1);	// Telefrags normally 1-shot the boss but let's cap damage at 9k
	attacker.iDamage += damage;
	if (TF2_GetPlayerClass(attacker.index) is TFClass_Soldier and GetIndexOfWeaponSlot(attacker.index, TFWeaponSlot_Primary) is 1104)
	{
		if (weapon is TF_WEAPON_ROCKETLAUNCHER)
			attacker.iAirDamage += damage;
		int div = cvarVSH2[AirStrikeDamage].IntValue;
		SetEntProp(attacker.index, Prop_Send, "m_iDecapitations", attacker.iAirDamage/div);
	}

	int healers[MAXPLAYERS];
	int healercount = 0;
	for (int i=MaxClients ; i ; --i) {
		if (not IsValidClient(i) or not IsPlayerAlive(i))
			continue;
	
		if (GetHealingTarget(i) is attacker.index)
		{
			healers[healercount] = i;
			healercount++;
		}
	}
	for (int r=0; r<healercount; r++) {	// Medics now count as 3/5 of a backstab, similar to telefrag assists.
		if (not IsValidClient(healers[r]) or not IsPlayerAlive(healers[r]))
			continue;

		if (damage < 10 or UberTarget[healers[r]] is attacker.userid)
			Damage[healers[r]] += damage;
		else Damage[healers[r]] += damage/(healercount+1);
	}
}

public void ManagePlayerAirblast(const BaseBoss airblaster, const BaseBoss airblasted, Event event)
{
	switch ( airblasted.iType )
	{
		case -1: {}
		case Hale, CBS, HHHjr, Bunny, PlagueDoc:	airblasted.flRAGE += cvarVSH2[AirblastRage].FloatValue;
		case Vagineer:
		{
			if ( TF2_IsPlayerInCondition(airblasted.index, TFCond_Ubercharged) )
				TF2_AddCondition(airblasted.index, TFCond_Ubercharged, 2.0);
			else airblasted.flRAGE += cvarVSH2[AirblastRage].FloatValue;
		}
	}
}

public void ManageTraceHit(const BaseBoss victim, const BaseBoss attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
	switch ( victim.iType )
	{
		case Hale: {}
	}
}
public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if ( not bEnabled.BoolValue or not IsPlayerAlive(client) )
		return Plugin_Continue;

	BaseBoss base = BaseBoss(client);
	switch ( base.iType )
	{
		case -1: {}
		case Bunny:
		{
			if (GetPlayerWeaponSlot(client, TFWeaponSlot_Primary) == GetActiveWep(client))
			{
				buttons &= ~IN_ATTACK;
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

public void TF2_OnConditionAdded(int client, TFCond condition)
{
	BaseBoss player = BaseBoss(client);
	if ( not player.bIsBoss )
		return;

	switch (condition)
	{
		case TFCond_Disguised, TFCond_Jarated, TFCond_MarkedForDeath:
			TF2_RemoveCondition(client, condition);
	}
}

public void ManageBossMedicCall(const BaseBoss base)
{
	switch ( base.iType )
	{
		case -1: {}
		case Hale, Vagineer, CBS, HHHjr, Bunny, PlagueDoc:
		{
			if ( base.flRAGE < 100.0 )
				return;
			DoTaunt(base.index, "", 0);
		}
	}
}
public void ManageBossTaunt(const BaseBoss base)
{
	switch ( base.iType )
	{
		case -1: {}
		case Hale:	ToCHale(base).RageAbility();
		case Vagineer:	ToCVagineer(base).RageAbility();
		case CBS:	ToCChristian(base).RageAbility();
		case HHHjr:	ToCHHHJr(base).RageAbility();
		case Bunny:	ToCBunny(base).RageAbility();
		case PlagueDoc:	ToCPlague(base).RageAbility();
	}
}
public void ManageBuildingDestroyed(const BaseBoss base, const int building, const int objecttype)
{
	switch ( base.iType )
	{
		case -1: {}
		case Hale:
		{
			if ( !GetRandomInt(0, 4) ) {
				strcopy(snd, FULLPATH, HaleSappinMahSentry132);
				EmitSoundToAll(snd, base.index);
			}
		}
	}
}
public void ManagePlayerJarated(const BaseBoss attacker, const BaseBoss victim)
{
	switch ( victim.iType )
	{
		case -1: {}
		case Hale, Vagineer, CBS, HHHjr, Bunny, PlagueDoc:
		{
			victim.flRAGE -= cvarVSH2[JarateRage].FloatValue;
		}
	}
}
public Action HookSound(int clients[64], int& numClients, char sample[FULLPATH], int& entity, int& channel, float& volume, int& level, int& pitch, int& flags)
{
	if ( not bEnabled.BoolValue or not IsValidClient(entity) )
		return Plugin_Continue;

	BaseBoss base = BaseBoss(entity);

	switch (base.iType)
	{
		case -1: {}
		case Hale:
		{
			if ( not strncmp(sample, "vo", 2, false) )
				return Plugin_Handled;
		}
		case Vagineer:
		{
			if ( StrContains(sample, "vo/engineer_laughlong01", false) not_eq -1 )
			{
				strcopy(sample, FULLPATH, VagineerKSpree);
				return Plugin_Changed;
			}

			if ( not strncmp(sample, "vo", 2, false) )
			{
				if (StrContains(sample, "positivevocalization01", false) not_eq -1) //For backstab sound
					return Plugin_Continue;
				if (StrContains(sample, "engineer_moveup", false) not_eq -1)
					Format(sample, FULLPATH, "%s%i.wav", VagineerJump, GetRandomInt(1, 2));

				else if (StrContains(sample, "engineer_no", false) not_eq -1 or GetRandomInt(0, 9) > 6)
					strcopy(sample, FULLPATH, "vo/engineer_no01.mp3");

				else strcopy(sample, FULLPATH, "vo/engineer_jeers02.mp3");
				return Plugin_Changed;
			}
			else return Plugin_Continue;
		}
		case HHHjr:
		{
			if ( not strncmp(sample, "vo", 2, false) )
			{
				if ( GetRandomInt(0, 100) <= 10 ) {
					Format(sample, FULLPATH, "%s0%i.mp3", HHHLaught, GetRandomInt(1, 4));
					return Plugin_Changed;
				}
				if (StrContains(sample, "halloween_boss") equals -1)
					return Plugin_Handled;
			}
		}
		case Bunny:
		{
			if ( StrContains(sample, "gibberish", false) == -1
				and StrContains(sample, "burp", false) == -1
				and !GetRandomInt(0, 2) )
			{
				// Do sound things
				strcopy(sample, PLATFORM_MAX_PATH, BunnyRandomVoice[GetRandomInt(0, sizeof(BunnyRandomVoice)-1)]);
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool& result)
{
	if ( not bEnabled.BoolValue )
		return Plugin_Continue;
	
	BaseBoss base = BaseBoss(client);
	switch (base.iType)
	{
		case -1: {}
		case HHHjr:
		{
			if (base.iClimbs < 10) {
				SickleClimbWalls(client, weapon, 500.0, 0.0, false);
				base.flWeighDown = 0.0;
				base.iClimbs++;
			}
		}
	}
	if (base.bIsBoss) {	// Fuck random crits
		if (TF2_IsPlayerCritBuffed(base.index))
			return Plugin_Continue;
		result = false;
		return Plugin_Changed;
	}
	else if (base.bIsMinion) {
		BaseBoss ownerBoss = BaseBoss(base.iOwnerBoss);
		switch (ownerBoss.iType)
		{
			case -1: {}
			case PlagueDoc: base.ClimbWall(weapon, 400.0, 0.0, false);
		}

	}
	if (not base.bIsBoss and not base.bIsMinion) {
		if (TF2_GetPlayerClass(base.index) is TFClass_Sniper and IsWeaponSlotActive(base.index, TFWeaponSlot_Melee))
			base.ClimbWall(weapon, 600.0, 15.0, true);
	}
	return Plugin_Continue;
}

/*
IT SHOULD BE WORTH NOTING THAT ManageMessageIntro IS CALLED AFTER BOSS HEALTH CALCULATION, IT MAY OR MAY NOT BE A GOOD IDEA TO RESET BOSS HEALTH HERE IF NECESSARY. ESPECIALLY IF YOU HAVE A MULTIBOSS THAT REQUIRES UNEQUAL HEALTH DISTRIBUTION.
*/
public void ManageMessageIntro(const BaseBoss base[34])		// I can't believe this works lmaooo
{
	gameMessage[0] = '\0';
	int ent = -1;
	while ( (ent = FindEntityByClassname(ent, "func_door")) not_eq -1 )
	{
		AcceptEntityInput(ent, "Open");
		AcceptEntityInput(ent, "Unlock");
	}
	int i=0;
	for (i=0 ; i<34 ; ++i) {
		if ( !base[i] )
			continue;
		switch ( base[i].iType )
		{
			case -1: {}
			case Hale:	Format(gameMessage, MAXMESSAGE, "%s\n%N has become Saxton Hale with %i Health", gameMessage, base[i].index, base[i].iHealth);
			case Vagineer:	Format(gameMessage, MAXMESSAGE, "%s\n%N has become the Vagineer with %i Health", gameMessage, base[i].index, base[i].iHealth);
			case CBS:	Format(gameMessage, MAXMESSAGE, "%s\n%N has become the Christian Brutal Sniper with %i Health", gameMessage, base[i].index, base[i].iHealth);
			case HHHjr:	Format(gameMessage, MAXMESSAGE, "%s\n%N has become The Horseless Headless Horsemann Jr. with %i Health", gameMessage, base[i].index, base[i].iHealth);
			case Bunny:	Format(gameMessage, MAXMESSAGE, "%s\n%N has become The Easter Bunny with %i Health", gameMessage, base[i].index, base[i].iHealth);
			case PlagueDoc:	Format(gameMessage, MAXMESSAGE, "%s\n%N has become The Plague Doctor with %i Health", gameMessage, base[i].index, base[i].iHealth);
		}
	}
	SetHudTextParams(-1.0, 0.2, 10.0, 255, 255, 255, 255);
	for (i=MaxClients ; i ; --i) {
		if (IsValidClient(i) and not (GetClientButtons(i) & IN_SCORE))
			ShowHudText(i, -1, "%s", gameMessage);
	}
	gamemode.iRoundState = StateRunning;
	SetPawnTimer(_MusicPlay, 2.0);		// in vsh2.sp
}

public void ManageBossPickUpItem(const BaseBoss base, const char item[64])
{
	if (GetIndexOfWeaponSlot(base.index, TFWeaponSlot_Melee) is 404)	// block Persian Persuader
		return;

	switch (base.iType)
	{
		case -1: {}
		case Hale:
		{
			
		}
	}
}

public void ManageResetVariables(const BaseBoss base)
{
	base.bIsBoss = base.bSetOnSpawn = false;
	base.iType = -1;
	base.iStabbed = 0;
	base.iMarketted = 0;
	base.flRAGE = 0.0;
	base.bIsMinion = false;
	base.iDifficulty = 0;
	base.iDamage = 0;
	base.iAirDamage = 0;
	base.iUberTarget = 0;
	base.flCharge = 0.0;
	base.bGlow = 0;
	base.flGlowtime = 0.0;
	base.bUsedUltimate = false;
	base.iOwnerBoss = 0;
	base.iSongPick = -1;
}
public void ManageEntityCreated(const int entity, const char[] classname)
{
	if ( StrContains(classname, "rune") not_eq -1 )	// Special request
		CreateTimer( 0.1, RemoveEnt, EntIndexToEntRef(entity) );
	
	if (gamemode.iRoundState is StateRunning and not strcmp(classname, "tf_projectile_pipe", false))
		SDKHook(entity, SDKHook_SpawnPost, OnEggBombSpawned);
}
public void OnEggBombSpawned(int entity)
{
	int owner = GetOwner(entity);
	BaseBoss boss = BaseBoss(owner);
	if (IsClientValid(owner) and boss.bIsBoss and boss.iType == Bunny)
		CreateTimer(0.0, Timer_SetEggBomb, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
}

public void ManageUberDeploy(const BaseBoss medic, const BaseBoss patient)
{
	int medigun = GetPlayerWeaponSlot(medic.index, TFWeaponSlot_Secondary);
	if ( IsValidEntity(medigun) ) {
		char strMedigun[32]; GetEdictClassname(medigun, strMedigun, sizeof(strMedigun));
		if ( not strcmp(strMedigun, "tf_weapon_medigun", false) )
		{
			SetMediCharge(medigun, 1.51);
			TF2_AddCondition(medic.index, TFCond_CritOnWin, 0.5, medic.index);
			if ( IsValidClient(patient.index) and IsPlayerAlive(patient.index) )
			{
				TF2_AddCondition(patient.index, TFCond_CritOnWin, 0.5, medic.index);
				medic.iUberTarget = patient.userid;
			}
			else medic.iUberTarget = 0;
			CreateTimer(0.1, TimerLazor, EntIndexToEntRef(medigun), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}
public void RoundStartPost()
{
	BaseBoss	boss;
	int		i;	// Count amount of bosses for health calculation!
	for (i=MaxClients ; i ; --i) {
		if ( not IsValidClient(i) or not IsPlayerAlive(i) )
			continue;
		boss = BaseBoss(i);
		if (!boss.bIsBoss) {
			SetEntityMoveType(i, MOVETYPE_WALK);
			if (GetClientTeam(i) not_eq RED and GetClientTeam(i) > int(TFTeam_Spectator))	// For good measure!
				boss.ForceTeamChange(RED);
			SetPawnTimer( PrepPlayers, 0.2, boss.userid );	// in handler.sp
		}
	}
	gamemode.iTotalMaxHealth = 0;
	int bosscount = gamemode.CountBosses(true);

	BaseBoss bosses[34];	// There's no way almost everybody can be an overpowered boss...
	int index = 0;
	for (i=MaxClients ; i ; --i, ++index) {		// Loop again for bosses only
		if (not IsValidClient(i))
			continue;

		boss = BaseBoss(i);
		if (not boss.bIsBoss)
			continue;

		bosses[index] = boss;
		if (not IsPlayerAlive(i))
			TF2_RespawnPlayer(i);
		
		// Automatically divides health based on boss count but this can be changed if necessary
		boss.iMaxHealth = CalcBossHealth(760.8, gamemode.iPlaying, 1.0, 1.0341, 2046.0) / (bosscount);	// In stocks.sp
		if (boss.iMaxHealth < 3000 and bosscount is 1)
			boss.iMaxHealth = 3000;
#if defined _tf2attributes_included
		int maxhp = GetEntProp(boss.index, Prop_Data, "m_iMaxHealth");
		TF2Attrib_RemoveAll(boss.index);
		TF2Attrib_SetByDefIndex( boss.index, 26, float(boss.iMaxHealth-maxhp) );
#endif
		if (GetClientTeam(boss.index) not_eq BLU)
			boss.ForceTeamChange(BLU);
		gamemode.iTotalMaxHealth += boss.iMaxHealth;
		boss.iHealth = boss.iMaxHealth;
	}
	SetPawnTimer(CheckAlivePlayers, 0.2);
	ManageMessageIntro(bosses);
	if ( gamemode.iPlaying > 5 )
		SetControlPoint(false);
}

public void ManageMusic(char song[FULLPATH], float& time)
{
	// UNFORTUNATELY, we have to get a random boss so we can set our music, tragic I know...
	// Remember that you can get a random boss filtered by type as well!
	BaseBoss currBoss = gamemode.GetRandomBoss(false);
	if ( currBoss )
	{
		switch (currBoss.iType) {
			case -1: {song = ""; time = -1.0;}
			case CBS: {
				strcopy(song, sizeof(song), CBSTheme);
				time = 137.0;
			}
			case HHHjr: {
				strcopy(song, sizeof(song), HHHTheme);
				time = 90.0;
			}
		}
	}
}
public void StopBackGroundMusic()	// DESIGN FLAW: 
{
	BaseBoss currBoss = gamemode.GetRandomBoss(false);
	char song[FULLPATH];
	switch (currBoss.iType) {
		case -1: {}
		case CBS: strcopy(song, sizeof(song), CBSTheme);
		case HHHjr: strcopy(song, sizeof(song), HHHTheme);
	}
	for (int i=MaxClients ; i ; --i) {
		if (not IsValidClient(i))
			continue;
		StopSound(i, SNDCHAN_AUTO, song);
	}
}
public void ManageRoundEndBossInfo(const BaseBoss base[34])	// I STILL can't believe this works lmaoooo.
{
	char victory[FULLPATH];
	gameMessage[0] = '\0';
	int i=0;
	for (i=0 ; i<34 ; ++i) {
		if ( !base[i] )
			continue;
		switch ( base[i].iType )
		{
			case Vagineer:
			{
				Format(gameMessage, MAXMESSAGE, "%s\nThe Vagineer (%N) had %i (of %i) health left.", gameMessage, base[i].index, base[i].iHealth, base[i].iMaxHealth);
				Format(victory, FULLPATH, "%s%i.wav", VagineerKSpreeNew, GetRandomInt(1, 5));
				EmitSoundToAll(victory);
			}
			case HHHjr: Format(gameMessage, MAXMESSAGE, "%s\nThe Horseless Headless Horsemann Jr. (%N) had %i (of %i) health left.", gameMessage, base[i].index, base[i].iHealth, base[i].iMaxHealth);
			case CBS: Format(gameMessage, MAXMESSAGE, "%s\nThe Christian Brutal Sniper (%N) had %i (of %i) health left.", gameMessage, base[i].index, base[i].iHealth, base[i].iMaxHealth);
			case Bunny:
			{
				Format(gameMessage, MAXMESSAGE, "%s\nThe Easter Bunny (%N) had %i (of %i) health left.", gameMessage, base[i].index, base[i].iHealth, base[i].iMaxHealth);
				strcopy(victory, FULLPATH, BunnyWin[GetRandomInt(0, sizeof(BunnyWin)-1)]);
				EmitSoundToAll(victory);
			}
			case Hale:
			{
				Format(gameMessage, MAXMESSAGE, "%s\nSaxton Hale (%N) had %i (of %i) health left.", gameMessage, base[i].index, base[i].iHealth, base[i].iMaxHealth);
				Format(victory, FULLPATH, "%s%i.wav", HaleWin, GetRandomInt(1, 2));
				EmitSoundToAll(victory);
			}
			case PlagueDoc: Format(gameMessage, MAXMESSAGE, "%s\nPlague Doctor (%N) had %i (of %i) health left.", gameMessage, base[i].index, base[i].iHealth, base[i].iMaxHealth);
		}
	}
	if (gameMessage[0] not_eq '\0') {
		CPrintToChatAll("{olive}[VSH2]{default} %s", gameMessage);
		SetHudTextParams(-1.0, 0.2, 10.0, 255, 255, 255, 255);
		for (i=MaxClients ; i ; --i) {
			if (IsValidClient(i) and not (GetClientButtons(i) & IN_SCORE))
				ShowHudText(i, -1, "%s", gameMessage);
		}
	}
}
public void ManageLastPlayer()
{
	BaseBoss currBoss = gamemode.GetRandomBoss(false);
	switch (currBoss.iType) {
		case -1: {}
		case Hale:	ToCHale(currBoss).LastPlayerSoundClip();
		case Vagineer:	ToCVagineer(currBoss).LastPlayerSoundClip();
		case CBS:	ToCChristian(currBoss).LastPlayerSoundClip();
		case Bunny:	ToCBunny(currBoss).LastPlayerSoundClip();
	}
}
public void ManageBossCheckHealth(const BaseBoss base)
{
	static int LastBossTotalHealth;
	float currtime = GetGameTime();
	if (base.bIsBoss) {	// If a boss reveals their own health, only show that one boss' health.
		switch (base.iType) {
			case -1: {}
			case Hale:	PrintCenterTextAll("Saxton Hale showed his current HP: %i of %i", base.iHealth, base.iMaxHealth);
			case Vagineer:	PrintCenterTextAll("The Vagineer showed his current HP: %i of %i", base.iHealth, base.iMaxHealth);
			case CBS:	PrintCenterTextAll("The Christian Brutal Sniper showed his current HP: %i of %i", base.iHealth, base.iMaxHealth);
			case HHHjr:	PrintCenterTextAll("The Horseless Headless Horsemann Jr. showed his current HP: %i of %i", base.iHealth, base.iMaxHealth);
			case Bunny:	PrintCenterTextAll("The Easter Bunny showed his current HP: %i of %i", base.iHealth, base.iMaxHealth);
			case PlagueDoc:	PrintCenterTextAll("Plague Doctor showed his current HP: %i of %i", base.iHealth, base.iMaxHealth);
		}
		LastBossTotalHealth = base.iHealth;
		return;
	}
	if (currtime >= gamemode.flHealthTime) {	// If a non-boss is checking health, reveal all Boss' hp
		gamemode.iHealthChecks++;
		BaseBoss boss;
		int totalHealth;
		gameMessage[0] = '\0';
		for (int i=MaxClients ; i ; --i) {
			if ( not IsValidClient(i) or not IsPlayerAlive(i) )	// exclude dead bosses for health check
				continue;
			boss = BaseBoss(i);
			if (not boss.bIsBoss)
				continue;

			switch ( boss.iType )
			{
				case Vagineer:	Format(gameMessage, MAXMESSAGE, "%s\nThe Vagineer's current health is: %i of %i", gameMessage, boss.iHealth, boss.iMaxHealth);
				case HHHjr:	Format(gameMessage, MAXMESSAGE, "%s\nThe Horseless Headless Horsemann Jr's current health is: %i of %i", gameMessage, boss.iHealth, boss.iMaxHealth);
				case CBS:	Format(gameMessage, MAXMESSAGE, "%s\nThe Christian Brutal Sniper's current health is: %i of %i", gameMessage, boss.iHealth, boss.iMaxHealth);
				case Hale:	Format(gameMessage, MAXMESSAGE, "%s\nSaxton Hale's current health is: %i of %i", gameMessage, boss.iHealth, boss.iMaxHealth);
				case Bunny:	Format(gameMessage, MAXMESSAGE, "%s\nThe Easter Bunny's current health is: %i of %i", gameMessage, boss.iHealth, boss.iMaxHealth);
				case PlagueDoc:	Format(gameMessage, MAXMESSAGE, "%s\nPlague Doctor's current health is: %i of %i", gameMessage, boss.iHealth, boss.iMaxHealth);
			}
			totalHealth += boss.iHealth;
		}
		PrintCenterTextAll(gameMessage);
		CPrintToChatAll("{olive}[VSH 2]{default} %s", gameMessage);
		LastBossTotalHealth = totalHealth;
		gamemode.flHealthTime = currtime+(gamemode.iHealthChecks < 3 ? 10.0 : 60.0);
	}
	else CPrintToChat(base.index, "{olive}[VSH 2]{default} You cannot see the Boss HP now (wait %i seconds). Last known total health was %i.", RoundFloat(gamemode.flHealthTime-currtime), LastBossTotalHealth);
}
public void CheckAlivePlayers()
{
	if (gamemode.iRoundState not_eq StateRunning)
		return;

	int living = GetLivingPlayers(RED);
	if (not living)
		ForceTeamWin(BLU);
	else if (living equals 1 and gamemode.GetRandomBoss(true))
	{
		ManageLastPlayer();	// in handler.sp
		//gamemode.bAllowSuperWeaps = true;
		gamemode.iTimeLeft = cvarVSH2[LastPlayerTime].IntValue;
		CreateTimer(1.0, Timer_DrawGame, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
	int Alive = cvarVSH2[AliveToEnable].IntValue;
	if (!cvarVSH2[PointType].BoolValue and living <= Alive and !gamemode.bPointReady)
	{
		PrintHintTextToAll("%i players are left; control point enabled!", living);
		if (living == Alive)
			EmitSoundToAll("vo/announcer_am_capenabled02.mp3");
		else if (living < Alive) {
			Format(snd, FULLPATH, "vo/announcer_am_capincite0%i.mp3", GetRandomInt(0, 1) ? 1 : 3);
			EmitSoundToAll(snd);
		}
		SetControlPoint(true);
		gamemode.bPointReady = true;
	}
}
public void ManageSetBossArgs(const int client)
{
	char targetname[32], bossname[32];
	GetCmdArg(1, targetname, sizeof(targetname));
	GetCmdArg(2, bossname,   sizeof(bossname));

	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	if ( (target_count = ProcessTargetString(
		targetname,
		client,
		target_list,
		MAXPLAYERS,
		0,
		target_name,
		sizeof(target_name),
		tn_is_ml)) <= 0 )
	{
		ReplyToTargetError(client, target_count);
		return;
	}

	int typei;
	if (StrContains(bossname, "hal", false) != -1)
		typei = Hale;
	else if (StrContains(bossname, "vag", false) != -1)
		typei = Vagineer;
	else if (StrContains(bossname, "hhh", false) != -1 or StrContains(bossname, "jr", false) != -1)
		typei = HHHjr;
	else if (StrContains(bossname, "chr", false) != -1 or StrContains(bossname, "cbs", false) != -1)
		typei = CBS;
	
	else if (StrContains(bossname, "bunny", false) != -1 or StrContains(bossname, "east", false) != -1)
		typei = Bunny;
	else if (StrContains(bossname, "plague", false) != -1 or StrContains(bossname, "doc", false) != -1)
		typei = PlagueDoc;

	for (int i=0; i<target_count; i++) {
		if ( not IsClientValid(target_list[i]) )
			continue;

		BaseBoss(target_list[i]).iPresetType = typei;
		ReplyToCommand(target_list[i], "[VSH2] You have set your Boss!");
	}
}
public void _SkipBossPanel()
{
	BaseBoss upnext[3];
	for (int j=0; j<3; ++j)
	{
		upnext[j] = gamemode.FindNextBoss();
		upnext[j].bSetOnSpawn = true;
		if (!j)
			SkipBossPanelNotify(upnext[j].index);
		else CPrintToChat(upnext[j].index, "{olive}[VSH]{default} You are going to be a Boss soon! Type {olive}/halenext{default} to check/reset your queue points.");
	}
}

public void PrepPlayers(const BaseBoss player)
{
	int client = player.index;
	if (not IsValidClient(client)
		or not IsPlayerAlive(client)
		or gamemode.iRoundState is StateEnding
		or player.bIsBoss)
		return ;

#if defined _tf2attributes_included
	TF2Attrib_RemoveAll(client);
#endif
	if (GetClientTeam(client) not_eq RED and GetClientTeam(client) > int(TFTeam_Spectator))
	{
		player.ForceTeamChange(RED);
		TF2_RegeneratePlayer(client); // Added fix by Chdata to correct team colors
	}
	TF2_RegeneratePlayer(client);
	SetEntityHealth(client, GetEntProp(client, Prop_Data, "m_iMaxHealth"));
	if ( not GetRandomInt(0, 3) )
		player.HelpPanelClass();

#if defined _tf2attributes_included
	if (IsValidEntity(FindPlayerBack(client, { 444 }, 1)))    //  Fixes mantreads to have jump height again
        {
            TF2Attrib_SetByDefIndex(client, 58, 1.8);             //  "self dmg push force increased"
        }
#endif
	int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	int index = -1;
	if (weapon > MaxClients and IsValidEdict(weapon))
	{
		index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch (index) {
			case 237:
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon = player.SpawnWeapon("tf_weapon_rocketlauncher", 18, 1, 0, "265 ; 999.0");
				SetWeaponAmmo(weapon, 20);
			}
			case 17, 204:
			{
				if (GetItemQuality(weapon) not_eq 10) {
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					player.SpawnWeapon("tf_weapon_syringegun_medic", 17, 1, 10, "17 ; 0.05 ; 144 ; 1");
				}
			}
		}
	}
	weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if (weapon > MaxClients and IsValidEdict(weapon))
	{
		index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch (index) {
			case 57:	// Razorback
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon = player.SpawnWeapon("tf_weapon_smg", 16, 1, 0, "2 ; 1.0");
			}
			case 265:	// Stickyjumper
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon = player.SpawnWeapon("tf_weapon_pipebomblauncher", 20, 1, 0, "2 ; 1.0");
				SetWeaponAmmo(weapon, 24);
			}
			case 735, 736, 810, 831, 933, 1080, 1102:	// Replace sapper with more useful nail-firing Pistol
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon = player.SpawnWeapon("tf_weapon_handgun_scout_secondary", 23, 5, 10, "280 ; 5 ; 6 ; 0.7 ; 2 ; 0.66 ; 4 ; 4.167 ; 78 ; 8.333 ; 137 ; 6.0");
				SetWeaponAmmo(weapon, 200);
			}
			case 39, 351, 1081:
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon = player.SpawnWeapon("tf_weapon_flaregun", index, 5, 10, "551 ; 1 ; 25 ; 0.5 ; 207 ; 1.33 ; 144 ; 1 ; 58 ; 3.2");
				SetWeaponAmmo(weapon, 20);
			}
			case 740:
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon = player.SpawnWeapon("tf_weapon_flaregun", index, 5, 10, "551 ; 1 ; 25 ; 0.5 ; 207 ; 1.33 ; 416 ; 3 ; 58 ; 2.08 ; 1 ; 0.65");
				SetWeaponAmmo(weapon, 20);
			}
		}
	}
	if ( IsValidEntity (FindPlayerBack(client, { 57 }, 1)) )
	{
		RemovePlayerBack(client, { 57 }, 1);
		weapon = player.SpawnWeapon("tf_weapon_smg", 16, 1, 0, "");
	}
	weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if (weapon > MaxClients and IsValidEdict(weapon))
	{
		index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch (index) {
			case 331:
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
				weapon = player.SpawnWeapon("tf_weapon_fists", 195, 1, 6, "");
			}
			case 357: SetPawnTimer(_NoHonorBound, 1.0, player.userid);
		}
	}
	weapon = GetPlayerWeaponSlot(client, 4);
	if (weapon > MaxClients and IsValidEdict(weapon) and GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") == 60)
	{
		TF2_RemoveWeaponSlot(client, 4);
		weapon = player.SpawnWeapon("tf_weapon_invis", 30, 1, 0, "2 ; 1.0");
	}
	TFClassType equip = TF2_GetPlayerClass(client);
	switch (equip) {
		case TFClass_Medic:
		{
			weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
			int mediquality = GetItemQuality(weapon);
			if (mediquality not_eq 10) {
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon = player.SpawnWeapon("tf_weapon_medigun", 35, 5, 10, "14 ; 0.0 ; 18 ; 0.0 ; 10 ; 1.25 ; 178 ; 0.75");
				//200 ; 1 for area of effect healing, 178 ; 0.75 Faster switch-to, 14 ; 0.0 perm overheal, 11 ; 1.25 Higher overheal
				if (GetMediCharge(weapon) < 0.41)
					SetMediCharge(weapon, 0.41);
			}
		}
	}
#if defined _tf2attributes_included
	if (cvarVSH2[HealthRegenForPlayers].BoolValue)
		TF2Attrib_SetByDefIndex( client, 57, cvarVSH2[HealthRegenAmount].FloatValue );
#endif
}

public Action TF2Items_OnGiveNamedItem(int client, char[] classname, int iItemDefinitionIndex, Handle& hItem)
{
	if (not bEnabled.BoolValue)
		return Plugin_Continue;

	TF2Item hItemOverride = null;
	TF2Item hItemCast = view_as< TF2Item >(hItem);
	switch (iItemDefinitionIndex)
	{
		case 59: // dead ringer
		{
			hItemOverride = PrepareItemHandle(hItemCast, _, _, "35 ; 2.0");
		}
		case 404: //persian persuader
		{
			hItemOverride = PrepareItemHandle(hItemCast, _, _, "76 ; 2.0 ; 78 ; 2.0");
		}
		case 1103: //Backscatter
		{
			hItemOverride = PrepareItemHandle(hItemCast, _, _, "179 ; 1.0");
		}
		case 40, 1146: //backburner
		{
			hItemOverride = PrepareItemHandle(hItemCast, _, _, "165 ; 1.0");
		}
		case 220: //shortstop
		{
			hItemOverride = PrepareItemHandle(hItemCast, _, _, "525 ; 1 ; 526 ; 1.2 ; 533 ; 1.4 ; 534 ; 1.4 ; 328 ; 1 ; 241 ; 1.5 ; 78 ; 1.389 ; 97 ; 0.75", true);
		}
		case 349: //sun on a stick
		{
			hItemOverride = PrepareItemHandle(hItemCast, _, _, "134 ; 13 ; 208 ; 1");
		}
		case 442: //bison
		{
			hItemOverride = PrepareItemHandle(hItemCast, _, _, "97 ; 0.75");
		}
		case 325, 452: //boston basher and 3rune blade
		{
			hItemOverride = PrepareItemHandle(hItemCast, _, _, "204 ; 0 ; 149 ; 5", true);
		}
		case 444: //Mantreads
		{
			hItemOverride = PrepareItemHandle(hItemCast, _, _, "275 ; 1.0");
		}
		case 648: //wrap assassin
		{
			hItemOverride = PrepareItemHandle(hItemCast, _, _, "279 ; 3.0");
		}
		case 224: //Letranger
		{
			hItemOverride = PrepareItemHandle(hItemCast, _, _, "166 ; 15 ; 1 ; 0.8", true);
		}
		case 225, 574: //YER
		{
			hItemOverride = PrepareItemHandle(hItemCast, _, _, "155 ; 1 ; 160 ; 1", true);
		}
		case 232, 401: // Bushwacka + Shahanshah
		{
			hItemOverride = PrepareItemHandle(hItemCast, _, _, "236 ; 1");
		}
		case 226: // The Battalion's Backup
		{
			hItemOverride = PrepareItemHandle(hItemCast, _, _, "252 ; 0.25");
		}
		case 305, 1079: // Medic Xbow
		{
			hItemOverride = PrepareItemHandle(hItemCast, _, _, "17 ; 0.15 ; 2 ; 1.45"); // ; 266 ; 1.0");
		}
		case 56, 1005, 1092: // Huntsman
		{
			hItemOverride = PrepareItemHandle(hItemCast, _, _, "76 ; 2.0");
		}
		case 43, 239, 1084, 1100: //gru
		{
			hItemOverride = PrepareItemHandle(hItemCast, _, iItemDefinitionIndex, "107 ; 1.5 ; 1 ; 0.5 ; 128 ; 1 ; 191 ; -7", true);
		}
		case 415: //reserve shooter
		{
			hItemOverride = PrepareItemHandle(hItemCast, _, _, "179 ; 1 ; 265 ; 999.0 ; 178 ; 0.6 ; 2 ; 1.1 ; 3 ; 0.66", true);
		}
		case 405, 608: // Demo boots have falling stomp damage
		{
			hItemOverride = PrepareItemHandle(hItemCast, _, _, "259 ; 1 ; 252 ; 0.25");
		}
		case 36, 412: // Blutsauger and Overdose
		{
			hItemOverride = PrepareItemHandle(hItemCast, _, _, "17 ; 0.01");
		}
	}
	if (hItemOverride not_eq null) {
		hItem = view_as< Handle >(hItemOverride);
		return Plugin_Changed;
	}

	TFClassType iClass = TF2_GetPlayerClass(client);
	
	if (!strncmp(classname, "tf_weapon_rocketlauncher", 24, false) or !strncmp(classname, "tf_weapon_particle_cannon", 25, false))
	{
		switch (iItemDefinitionIndex)
		{
			case 127: hItemOverride = PrepareItemHandle(hItemCast, _, _, "265 ; 999.0 ; 179 ; 1.0");
			case 414: hItemOverride = PrepareItemHandle(hItemCast, _, _, "265 ; 999.0 ; 99 ; 1.25");
			case 1104: hItemOverride = PrepareItemHandle(hItemCast, _, _, "76 ; 1.25 ; 265 ; 999.0");
			//case 730: hItemOverride = PrepareItemHandle(hItemCast, _, _, "394 ; 0.2 ; 241 ; 1.3 ; 3 ; 0.75 ; 411 ; 5 ; 6 ; 0.1 ; 642 ; 1 ; 413 ; 1", true);
			default: hItemOverride = PrepareItemHandle(hItemCast, _, _, "265 ; 999.0");
		}
	}
	if (!strncmp(classname, "tf_weapon_grenadelauncher", 25, false) or !strncmp(classname, "tf_weapon_cannon", 16, false))
	{
		switch (iItemDefinitionIndex)
		{
			// loch n load
			case 308: hItemOverride = PrepareItemHandle(hItemCast, _, _, "265 ; 999 ; 208 ; 1.0");
			default: hItemOverride = PrepareItemHandle(hItemCast, _, _, "265 ; 999.0 ; 128 ; 1 ; 135 ; 0.5");
		}
	}
	if (!strncmp(classname, "tf_weapon_sword", 15, false))
	{
		hItemOverride = PrepareItemHandle(hItemCast, _, _, "178 ; 0.8");
	}
	if (!strncmp(classname, "tf_weapon_shotgun", 17, false) or !strncmp(classname, "tf_weapon_sentry_revenge", 24, false))
	{
		switch ( iClass )
		{
			case TFClass_Soldier:
				hItemOverride = PrepareItemHandle(hItemCast, _, _, "135 ; 0.6 ; 265 ; 999.0");
			default:
				hItemOverride = PrepareItemHandle(hItemCast, _, _, "265 ; 999.0");
		}
	}
	if (!strncmp(classname, "tf_weapon_wrench", 16, false) or !strncmp(classname, "tf_weapon_robot_arm", 19, false))
	{
		if (iItemDefinitionIndex is 142)
			hItemOverride = PrepareItemHandle(hItemCast, _, _, "26 ; 55");
		else hItemOverride = PrepareItemHandle(hItemCast, _, _, "26 ; 25");
	}
	if ( !strncmp(classname, "tf_weapon_minigun", 17, false) )
	{
		switch ( iItemDefinitionIndex )
		{
			case 41:	// Natascha
				hItemOverride = PrepareItemHandle(hItemCast, _, _, "87 ; 0.75 ; 280 ; 2 ; 642 ; 1 ; 2 ; 3.0 ; 411 ; 4 ; 181 ; 2.0 ; 233 ; 1.25", true); //26 ; 50.0
			default:
				hItemOverride = PrepareItemHandle(hItemCast, _, _, "233 ; 1.25");
		}
	}
	if (hItemOverride != null) {
		hItem = view_as< Handle >(hItemOverride);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public void ManageFighterThink(const BaseBoss fighter)
{
	if (GetClientTeam(fighter.index) not_eq RED)
		return;

	int i = fighter.index;
	char wepclassname[32];
	int buttons = GetClientButtons(i);

	SetHudTextParams(-1.0, 0.88, 0.35, 90, 255, 90, 255, 0, 0.35, 0.0, 0.1);
	if (not IsPlayerAlive(i)) {
		int obstarget = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
		if ( IsValidClient(obstarget) and GetClientTeam(obstarget) not_eq 3 and obstarget not_eq i)
		{
			if (not (buttons & IN_SCORE))
				ShowSyncHudText(i, rageHUD, "Damage: %d - %N's Damage: %d", fighter.iDamage, obstarget, BaseBoss(obstarget).iDamage);
		}
		else {
			if (not (buttons & IN_SCORE))
				ShowSyncHudText(i, rageHUD, "Damage: %d", fighter.iDamage);
		}
		return;
	}
	if (not (buttons & IN_SCORE))
		ShowSyncHudText(i, rageHUD, "Damage: %d", fighter.iDamage);

	if (HasEntProp(i, Prop_Send, "m_iKillStreak")) {
		int killstreaker = fighter.iDamage/1000;
		if ( killstreaker and GetEntProp(i, Prop_Send, "m_iKillStreak") >= 0 )
			SetEntProp(i, Prop_Send, "m_iKillStreak", killstreaker);
	}
	TFClassType tf2class = TF2_GetPlayerClass(i);
	int weapon = GetActiveWep(i);
	if (weapon <= MaxClients or not IsValidEntity(weapon) or not GetEdictClassname(weapon, wepclassname, sizeof(wepclassname)))
		strcopy(wepclassname, sizeof(wepclassname), "");
	bool validwep = ( not strncmp(wepclassname, "tf_wea", 6, false) );
	int index = GetItemIndex(weapon);

	switch (tf2class) {
		// Chdata's Deadringer Notifier
		case TFClass_Spy:
		{
			if (GetClientCloakIndex(i) is 59)
			{
				int drstatus = TF2_IsPlayerInCondition(i, TFCond_Cloaked) ? 2 : GetEntProp(i, Prop_Send, "m_bFeignDeathReady") ? 1 : 0;
				char s[32];
				switch (drstatus) {
					case 1:
					{
						SetHudTextParams(-1.0, 0.83, 0.35, 90, 255, 90, 255, 0, 0.0, 0.0, 0.0);
						Format(s, sizeof(s), "Status: Feign-Death Ready");
					}
					case 2:
					{
						SetHudTextParams(-1.0, 0.83, 0.35, 255, 64, 64, 255, 0, 0.0, 0.0, 0.0);
						Format(s, sizeof(s), "Status: Dead-Ringered");
					}
					default:
					{
						SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.0, 0.0, 0.0);
						Format(s, sizeof(s), "Status: Inactive");
					}
				}
				if (!(buttons & IN_SCORE))
					ShowSyncHudText(i, jumpHUD, "%s", s);
			}
		}
		case TFClass_Medic:
		{
			int medigun = GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary);
			char mediclassname[32];
			if (IsValidEdict(medigun) and GetEdictClassname(medigun, mediclassname, sizeof(mediclassname)) and !strcmp(mediclassname, "tf_weapon_medigun", false) )
			{
				SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);
				int charge = RoundToFloor(GetMediCharge(medigun)*100);
				if (not (buttons & IN_SCORE))
					ShowSyncHudText(i, jumpHUD, "Ubercharge: %i", charge);
			}

			if (weapon is GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary))
			{
				int healtarget = GetHealingTarget(i);
				if (IsValidClient(healtarget) and TF2_GetPlayerClass(healtarget) is TFClass_Scout)
					TF2_AddCondition(i, TFCond_SpeedBuffAlly, 0.2);
			}
			if (medigun is -1)
				return;
			//float oober = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
			//if ( GetHealingTarget(i) == -1 && TF2_IsPlayerInCondition(i, TFCond_Ubercharged) && oober <= 0)
			//	TF2_RemoveCondition(i, TFCond_Ubercharged);
		}
		case TFClass_Soldier:
		{
			if ( GetIndexOfWeaponSlot(i, TFWeaponSlot_Primary) is 1104 )
			{
				SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);
				if (!(buttons & IN_SCORE))
					ShowSyncHudText(i, jumpHUD, "Air Strike Damage: %i", AirDamage[i]);
			}
		}
	}
	int living = GetLivingPlayers(RED);
	if ( living is 1 and not TF2_IsPlayerInCondition(i, TFCond_Cloaked) )
	{
		TF2_AddCondition(i, TFCond_CritOnWin, 0.2);
		int primary = GetPlayerWeaponSlot(i, TFWeaponSlot_Primary);
		if (tf2class is TFClass_Engineer and weapon is primary and StrEqual(wepclassname, "tf_weapon_sentry_revenge", false))
			SetEntProp(i, Prop_Send, "m_iRevengeCrits", 3);
		TF2_AddCondition(i, TFCond_Buffed, 0.2);
		return;
	}

	else if (living is 2 and not TF2_IsPlayerInCondition(i, TFCond_Cloaked))
		TF2_AddCondition(i, TFCond_Buffed, 0.2);

							/* THIS section really needs cleaning! */
	TFCond cond = TFCond_CritOnWin;
	if (TF2_IsPlayerInCondition(i, TFCond_CritCola) and (tf2class is TFClass_Scout or tf2class is TFClass_Heavy))
	{
		TF2_AddCondition(i, cond, 0.2);
		return;
	}

	bool addthecrit = false;
	bool addmini = false;
	for (int u=MaxClients ; u ; --u) {
		if (IsValidClient(u) and IsPlayerAlive(i) and GetHealingTarget(u) == i)
		{
			addmini = true;
			break;
		}
	}
	if (validwep and weapon is GetPlayerWeaponSlot(i, TFWeaponSlot_Melee))
	{
		//slightly longer check but makes sure that any weapon that can backstab will not crit (e.g. Saxxy)
		if ( strcmp(wepclassname, "tf_weapon_knife", false) and index not_eq 416 )
			addthecrit = true;
	}
	switch (index)
	{
		case 305, 1079, 1081, 56, 16, 203,
                     1149, 15001, 15022, 15032, 15037, 15058, // SMG
                     58, 1083, 1105, 1100, 1005, 1092, 812, 833, 997, 39, 351, 740, 588, 595, 751: //Critlist
		{
			int flindex = GetIndexOfWeaponSlot(i, TFWeaponSlot_Primary);
			// No crits if using phlog
			if (TF2_GetPlayerClass(i) is TFClass_Pyro and flindex is 594)
				addthecrit = false;
			else addthecrit = true;
		}
		case 22, 23, 160, 209, 294, 449, 773,          // Scout pistol minicrits - Engie crits
                     15013, 15018, 15035, 15041, 15046, 15056: // Gunmettle
		{
			if (tf2class not_eq TFClass_Spy) 
				addthecrit = true;
			if (tf2class is TFClass_Scout and cond is TFCond_CritOnKill)
				cond = TFCond_Buffed;
		}
		case 656:
		{
			addthecrit = true;
			cond = TFCond_Buffed;
		}
		default: {}
	}
	if (index is 16 and addthecrit and IsValidEntity(FindPlayerBack(i, { 642 }, 1)))
		addthecrit = false;

	if ( tf2class is TFClass_DemoMan and not IsValidEntity(GetPlayerWeaponSlot(i, TFWeaponSlot_Secondary)) )
	{
		addthecrit = true;
		/*if (not gamemode.bDemomanShieldCrits and GetActiveWep(i) not_eq GetPlayerWeaponSlot(i, TFWeaponSlot_Melee))
		{
			cond = TFCond_Buffed;
		}*/
	}

	if (addthecrit) {
		TF2_AddCondition(i, cond, 0.2);
		if (addmini and cond not_eq TFCond_Buffed)
			TF2_AddCondition(i, TFCond_Buffed, 0.2);
	}
	if (tf2class is TFClass_Spy and validwep and weapon is GetPlayerWeaponSlot(i, TFWeaponSlot_Primary))
	{
		if (not TF2_IsPlayerCritBuffed(i)
			and not TF2_IsPlayerInCondition(i, TFCond_Buffed)
			and not TF2_IsPlayerInCondition(i, TFCond_Cloaked)
			and not TF2_IsPlayerInCondition(i, TFCond_Disguised)
			and not GetEntProp(i, Prop_Send, "m_bFeignDeathReady"))
		{
			TF2_AddCondition(i, TFCond_CritCola, 0.2);
		}
	}
	if (tf2class is TFClass_Engineer
		and weapon is GetPlayerWeaponSlot(i, TFWeaponSlot_Primary)
		and StrEqual(wepclassname, "tf_weapon_sentry_revenge", false))
	{
		int sentry = FindSentry(i);
		if (IsValidEntity(sentry)) {
			int enemy = GetEntPropEnt(sentry, Prop_Send, "m_hEnemy");
			if (enemy and GetClientTeam(enemy) is 3) {	// Trying to target minions as well
				SetEntProp(i, Prop_Send, "m_iRevengeCrits", 3);
				TF2_AddCondition(i, TFCond_Kritzkrieged, 0.2);
			}
			else {
				if (GetEntProp(i, Prop_Send, "m_iRevengeCrits"))
					SetEntProp(i, Prop_Send, "m_iRevengeCrits", 0);
				else if (TF2_IsPlayerInCondition(i, TFCond_Kritzkrieged) and not TF2_IsPlayerInCondition(i, TFCond_Healing))
					TF2_RemoveCondition(i, TFCond_Kritzkrieged);
			}
		}
	}
}