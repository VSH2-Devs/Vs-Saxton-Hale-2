#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <vsh2>

#undef REQUIRE_PLUGIN
#tryinclude <tf2attributes>
#define REQUIRE_PLUGIN

#define PlagueModel    "models/player/medic.mdl"
#define ZombieModel    "models/player/scout.mdl"

/// voicelines
#define PlagueIntro    "vo/medic_specialcompleted10.mp3"
#define PlagueRage1    "vo/medic_specialcompleted05.mp3"
#define PlagueRage2    "vo/medic_specialcompleted06.mp3"


methodmap CPlague < VSH2Player {
	public CPlague(const int ind, bool uid=false) {
		return view_as<CPlague>( VSH2Player(ind, uid) );
	}
	
	property float flCharge {
		public get() {
			return this.GetPropFloat("flCharge");
		}
		public set(const float val) {
			this.SetPropFloat("flCharge", val);
		}
	}
	property float flWeighDown {
		public get() {
			return this.GetPropFloat("flWeighDown");
		}
		public set(const float val) {
			this.SetPropFloat("flWeighDown", val);
		}
	}
	property float flRAGE {
		public get() {
			return this.GetPropFloat("flRAGE");
		}
		public set(const float val) {
			this.SetPropFloat("flRAGE", val);
		}
	}
	
	public void PlaySpawnClip() {
		this.PlayVoiceClip(PlagueIntro, VSH2_VOICE_INTRO);
	}
	
	public void Equip() {
		this.SetName("The Plague Doctor");
		this.RemoveAllItems();
		char attribs[128]; Format(attribs, sizeof(attribs), "68; 2.0; 2; 2.3; 259; 1.0; 252; 0.75; 200; 1.0; 551; 1.0");
		int SaxtonWeapon = this.SpawnWeapon("tf_weapon_shovel", 304, 100, 5, attribs);
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
	}
	public void RageAbility()
	{
		int attribute = 0;
		float value = 0.0; 
		TF2_AddCondition(this.index, TFCond_MegaHeal, 10.0);
		switch( GetRandomInt(0, 2) ) {
			case 0: { attribute = 2; value = 2.0; }	 /// Extra damage
			case 1: { attribute = 26; value = 100.0; }	/// Extra health
			case 2: { attribute = 107; value = 2.0; }	/// Extra speed
		}
		VSH2Player minion;
		for( int i=MaxClients; i; --i ) {
			if( !IsValidClient(i) || !IsPlayerAlive(i) || GetClientTeam(i) != VSH2Team_Boss )
				continue;
			minion = VSH2Player(i);
			bool IsMinion = minion.GetPropAny("bIsMinion");
			/// PATCH: only boost OUR minions, nobody elses...
			if( IsMinion && minion.hOwnerBoss == this ) {
			#if defined _tf2attributes_included
				bool tf2attribs_enabled = VSH2GameMode_GetPropAny("bTF2Attribs");
				if( tf2attribs_enabled ) {
					TF2Attrib_SetByDefIndex(i, attribute, value);
					SetPawnTimer(TF2AttribsRemove, 10.0, i);
				} else {
					char pdapower[32]; Format(pdapower, sizeof(pdapower), "%i; %f", attribute, value);
					int wep = minion.SpawnWeapon("tf_weapon_builder", 28, 5, 10, pdapower);
					SetPawnTimer(RemoveWepFromSlot, 10.0, i, GetSlotFromWeapon(i, wep));
				}
			#else
				char pdapower[32]; Format(pdapower, sizeof(pdapower), "%i; %f", attribute, value);
				int wep = minion.SpawnWeapon("tf_weapon_builder", 28, 5, 10, pdapower);
				SetPawnTimer(RemoveWepFromSlot, 10.0, i, GetSlotFromWeapon(i, wep));
			#endif
			}
		}
		if( GetRandomInt(0, 2) )
			this.PlayVoiceClip(PlagueRage1, VSH2_VOICE_RAGE);
		else this.PlayVoiceClip(PlagueRage2, VSH2_VOICE_RAGE);
	}
	public void KilledPlayer(const VSH2Player victim, Event event) {
		/// GLITCH: suiciding allows boss to become own minion.
		if( this.userid == victim.userid )
			return;
		/// PATCH: Hitting spy with active deadringer turns them into Minion...
		else if( event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER )
			return;
		/// PATCH: killing spy with teammate disguise kills both spy and the teammate he disguised as...
		else if( TF2_IsPlayerInCondition(victim.index, TFCond_Disguised) )
			TF2_RemovePlayerDisguise(victim.index); //event.SetInt("userid", victim.userid);
		victim.hOwnerBoss = this;
		victim.ConvertToMinion(0.4);
	}
	public void Help() {
		if( IsVoteInProgress() )
			return;
		char helpstr[] = "Plague Doctor: Kill enemies and turn them into loyal Zombies!\nSuper Jump: crouch, look up and stand up.\nWeigh-down: in midair, look down and crouch\nRage (Powerup Minions): taunt when Rage is full to give powerups to your Zombies.";
		Panel panel = new Panel();
		panel.SetTitle(helpstr);
		panel.DrawItem("Exit");
		panel.Send(this.index, HintPanel, 10);
		delete panel;
	}
};

/// plague doctor conversion helper function.
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

ConVar
	g_vsh2_scout_rage_gen,
	g_vsh2_airblast_rage,
	g_vsh2_jarate_rage
;

public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		g_vsh2_scout_rage_gen = FindConVar("vsh2_scout_rage_gen");
		g_vsh2_airblast_rage = FindConVar("vsh2_airblast_rage");
		g_vsh2_jarate_rage = FindConVar("vsh2_jarate_rage");
		g_iPlagueDocID = VSH2_RegisterPlugin("plague_doctor");
		LoadVSH2Hooks();
	}
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
	
	if (!VSH2_HookEx(OnRoundEndInfo, PlagueDoc_OnRoundEndInfo))
		LogError("Error loading OnRoundEndInfo forwards for Plague Doctor subplugin.");
}
stock bool IsPlagueDoctor(const VSH2Player player) {
	return player.GetPropInt("iBossType") == g_iPlagueDocID;
}

public void PlagueDoc_OnCallDownloads()
{
	PrecacheModel(PlagueModel, true);
	PrecacheModel(ZombieModel, true);
	
	char sounds_list[][] = {
		PlagueIntro, PlagueRage1, PlagueRage2
	};
	PrecacheSoundList(sounds_list, sizeof(sounds_list));
}
public void PlagueDoc_OnBossMenu(Menu &menu)
{
	char tostr[10]; IntToString(g_iPlagueDocID, tostr, sizeof(tostr));
	menu.AddItem(tostr, "Plague Doctor (Custom Boss)");
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
	if( !IsPlayerAlive(client) || !IsPlagueDoctor(boss) )
		return;
	
	CPlague player = ToCPlague(boss);
	
	VSH2_SpeedThink(boss, 340.0);
	VSH2_GlowThink(boss, 0.1);
	if( VSH2_SuperJumpThink(boss, 2.5, 25.0) ) {
		player.SuperJump(player.flCharge, -100.0);
		player.PlayVoiceClip("vo/medic_yes01.mp3", VSH2_VOICE_ABILITY);
	}
	
	if( OnlyScoutsLeft(VSH2Team_Red) )
		player.flRAGE += g_vsh2_scout_rage_gen.FloatValue;
	
	VSH2_WeighDownThink(boss, 3.0, 1.0);
	
	/// hud code
	SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
	Handle hHudText = VSH2GameMode_GetHUDHandle();
	float jmp = player.flCharge;
	if( jmp > 0.0 )
		jmp *= 4.0;
	if( player.flRAGE >= 100.0 )
		ShowSyncHudText(client, hHudText, "Jump: %i | Rage: FULL - Call Medic (default: E) to activate", player.GetPropInt("bSuperCharge") ? 1000 : RoundFloat(jmp));
	else ShowSyncHudText(client, hHudText, "Jump: %i | Rage: %0.1f", player.GetPropInt("bSuperCharge") ? 1000 : RoundFloat(jmp), player.flRAGE);
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
public void PlagueDoc_OnMinionInitialized(const VSH2Player player, const VSH2Player master)
{
	if( !IsPlagueDoctor(master) )
		return;
	RecruitMinion(player);
}
public void PlagueDoc_OnBossPlayIntro(const VSH2Player player)
{
	if( !IsPlagueDoctor(player) )
		return;
	ToCPlague(player).PlaySpawnClip();
}

public void PlagueDoc_OnPlayerKilled(const VSH2Player attacker, const VSH2Player victim, Event event)
{
	//int deathflags = event.GetInt("death_flags");
	/// attacker is plague doctor!
	if( attacker.GetPropInt("bIsBoss") && IsPlagueDoctor(attacker) ) {
		ToCPlague(attacker).KilledPlayer(victim, event);
	}
	/// attacker is a plague doctor minion!
	else if( attacker.GetPropInt("bIsMinion") ) {
		VSH2Player owner = attacker.hOwnerBoss;
		if( IsPlagueDoctor(owner) )
			ToCPlague(owner).KilledPlayer(victim, event);
	}
	if( victim.GetPropInt("bIsMinion") ) {
		/// Cap respawning minions by the amount of minions there are * 1.5.
		/// If 10 minions, then respawn them in 15 seconds.
		VSH2Player owner = victim.hOwnerBoss;
		if( IsPlagueDoctor(owner) && IsPlayerAlive(owner.index) ) {
			int minions = VSH2GameMode_CountMinions(false);
			victim.ConvertToMinion(minions * 1.5);
		}
	}
}
public void PlagueDoc_OnPlayerHurt(const VSH2Player attacker, const VSH2Player victim, Event event)
{
	int damage = event.GetInt("damageamount");
	if( !victim.GetPropInt("bIsBoss") && victim.GetPropInt("bIsMinion") && !attacker.GetPropInt("bIsMinion") ) {
		/** Have boss take damage if minions are hurt by players, this prevents bosses from hiding just because they gained minions.
		 */
		VSH2Player ownerBoss = victim.hOwnerBoss;
		if( IsPlagueDoctor(ownerBoss) ) {
			ownerBoss.SetPropInt("iHealth", GetClientHealth(ownerBoss.index)-damage);
			ownerBoss.GiveRage(damage);
		}
		return;
	}
	if( IsPlagueDoctor(victim) && victim.GetPropInt("bIsBoss") )
		victim.GiveRage(damage);
}
public void PlagueDoc_OnPlayerAirblasted(const VSH2Player airblaster, const VSH2Player airblasted, Event event)
{
	if( !IsPlagueDoctor(airblasted) )
		return;
	float rage = airblasted.GetPropFloat("flRAGE");
	airblasted.SetPropFloat("flRAGE", rage + g_vsh2_airblast_rage.FloatValue);
}
public void PlagueDoc_OnBossMedicCall(const VSH2Player rager)
{
	if( !IsPlagueDoctor(rager) )
		return;
	
	float rage = rager.GetPropFloat("flRAGE");
	if( rage < 100.0 )
		return;
	
	ToCPlague(rager).RageAbility();
	rager.SetPropFloat("flRAGE", 0.0);
}
public void PlagueDoc_OnBossJarated(const VSH2Player victim, const VSH2Player thrower)
{
	if( !IsPlagueDoctor(victim) )
		return;
	float rage = victim.GetPropFloat("flRAGE");
	victim.SetPropFloat("flRAGE", rage - g_vsh2_jarate_rage.FloatValue);
}
public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool &result)
{
	VSH2Player player = VSH2Player(client);
	if( player.GetPropInt("bIsMinion") ) {
		VSH2Player ownerBoss = player.hOwnerBoss;
		if( IsPlagueDoctor(ownerBoss) )
			player.ClimbWall(weapon, 400.0, 0.0, false);
		
		result = false;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public void PlagueDoc_OnRoundEndInfo(const VSH2Player player, bool bossBool, char message[MAXMESSAGE])
{
	if( !IsPlagueDoctor(player) )
		return;
	
	if( bossBool ) {
		/// play Boss Wins sounds here!
	}
}


void RecruitMinion(const VSH2Player base)
{
	int client = base.index;
	TF2_SetPlayerClass(client, TFClass_Scout, _, false);
	base.RemoveAllItems();
#if defined _tf2attributes_included
	if( VSH2GameMode_GetPropInt("bTF2Attribs") )
		TF2Attrib_RemoveAll(client);
#endif
	int weapon = base.SpawnWeapon("tf_weapon_bat", 572, 100, 5, "6; 0.5; 57; 15.0; 26; 75.0; 49; 1.0; 68; -2.0");
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
stock int GetSlotFromWeapon(const int iClient, const int iWeapon)
{
	for (int i=0; i<5; i++) {
		if( iWeapon == GetPlayerWeaponSlot(iClient, i) )
			return i;
	}
	return -1;
}
stock bool OnlyScoutsLeft(const int team)
{
	for (int i=MaxClients; i; --i) {
		if( !IsValidClient(i) || !IsPlayerAlive(i) )
			continue;
		if (GetClientTeam(i) == team && TF2_GetPlayerClass(i) != TFClass_Scout)
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
	if( param1 != -999 )
		Call_PushCell(param1);
	
	any param2 = hndl.ReadCell();
	if( param2 != -999 )
		Call_PushCell(param2);
	
	Call_Finish();
	return Plugin_Continue;
}



public int HintPanel(Menu menu, MenuAction action, int param1, int param2)
{
	return;
}
