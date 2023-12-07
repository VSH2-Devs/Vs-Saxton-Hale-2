#if defined _vsh2_included
	#endinput
#endif
#define _vsh2_included

#include <tf2_stocks>
#include <tf2items_stocks>
#include <cfgmap>
#include <ecs_helper>


enum {
	MAXMESSAGE         = 512,
	MAX_PANEL_MSG      = 512,
	PLAYER_HUD_SIZE    = 512,
	MAX_BOSS_NAME_SIZE = 64,
	PLAYER_NAME_SIZE   = 64,
};


enum { /** VSH2 Round States */
	StateDisabled = -1,
	StateStarting = 0,
	StateRunning  = 1,
	StateEnding   = 2,
};

enum { /** VSH2 Teams */
	VSH2Team_Unassigned=0,
	VSH2Team_Neutral=0,
	VSH2Team_Spectator,
	VSH2Team_Red,
	VSH2Team_Boss
};

enum { /** VSH2 Default Bosses */
	VSH2Boss_Hale,
	VSH2Boss_Vagineer,
	VSH2Boss_CBS,
	VSH2Boss_HHHjr,
	VSH2Boss_Bunny,
	MaxDefaultVSH2Bosses,
};


enum { /** Voice Clip Flags */
	VSH2_VOICE_BOSSENT = 1,  /// use boss as entity to emit from.
	VSH2_VOICE_BOSSPOS = 2,  /// use boss position for sound origin.
	VSH2_VOICE_TOALL   = 4,  /// sound replay to each individual player.
	VSH2_VOICE_ALLCHAN = 8,  /// if sound replay should use auto sound channel.
	VSH2_VOICE_ONCE    = 16, /// play a clip once to all. (does not cancel out 'VSH2_VOICE_TOALL')
};

enum {
	VSH2_VOICE_ALL     = VSH2_VOICE_BOSSENT|VSH2_VOICE_BOSSPOS|VSH2_VOICE_TOALL|VSH2_VOICE_ALLCHAN|VSH2_VOICE_ONCE,
	
	/// For when boss does something like a superjump, etc.
	VSH2_VOICE_ABILITY = VSH2_VOICE_BOSSENT|VSH2_VOICE_BOSSPOS|VSH2_VOICE_TOALL,
	
	/// For when boss does something like rage or special ability.
	VSH2_VOICE_RAGE    = VSH2_VOICE_BOSSENT|VSH2_VOICE_BOSSPOS|VSH2_VOICE_TOALL|VSH2_VOICE_ALLCHAN,
	
	/// For when boss gets stabbed or goes on a killing spree.
	VSH2_VOICE_SPREE   = 0,
	VSH2_VOICE_STABBED = 0,
	
	/// For when boss loses, wins, or introduces themselves like the mentlegen they are.
	VSH2_VOICE_WIN     = VSH2_VOICE_ONCE|VSH2_VOICE_ALLCHAN,
	VSH2_VOICE_LOSE    = VSH2_VOICE_ONCE|VSH2_VOICE_ALLCHAN,
	VSH2_VOICE_INTRO   = VSH2_VOICE_ONCE|VSH2_VOICE_ALLCHAN,
	
	/// For when there's only one target left!
	VSH2_VOICE_LASTGUY = VSH2_VOICE_BOSSPOS,
};


enum { /** HUDs */
	PlayerHUD,
	TimeLeftHUD,
	HealthHUD,
	MaxVSH2HUDs
};


enum BannerType {
	BannerBuff     = 1,
	BannerDefBuff,
	BannerHealBuff
};

enum /** Critflags */ {
	CRITFLAG_MINI  = 1 << 0, /// minicrits.
	CRITFLAG_FULL  = 1 << 1, /// full crits.
	CRITFLAG_STACK = 1 << 2, /// when healed by med, adds minicrits when full crits (for the fx).
};

enum { /** VSH2 Resource Types */
	ResourceSound,
	ResourceModel,
	ResourceMaterial,
	MaxResourceTypes
};

/// WHY did the round end?
enum { /** VSH2RoundResult */
	RoundResInvalid,  /// round didn't even end yet.
	RoundResBossWin,  /// boss successfully killed ALL players.
	RoundResBossDied, /// last/only boss died.
	RoundResBossDisc, /// last/only boss disconnected.
	RoundResTimer,    /// timer ran out.
	RoundResCap,      /// control point was captured.
};

enum { /** Builtin Abilities */
	Ability_Rage,                  /// taking damage increases a rage meter.
	Ability_MeleeClimbWalls,       /// hitting a wall with melee makes you climb it.
	Ability_MakeHealthKitOnHit,    /// hit something, health spawns
	Ability_SuperJump,             /// superjump mechanic.
	Ability_Weighdown,             /// weighdown mechanic.
	Ability_GlowOnDmg,             /// player is outlined when hurt [by specific things].
	Ability_EscapePlanEffect,      /// move faster as health gets lower.
	Ability_StunRagePlayers,       /// saxton hale stun rage on players.
	Ability_StunRageBuildings,     /// saxton hale stun rage on buildings.
	Ability_TeleToRandomPlayer,    /// HHH right-click/duck teleport.
	Ability_EggBombs,              /// Easter Bunny egg rage.
	Ability_PowerUber,             /// Vagineer-like Uber (uber + no knockback)
	Ability_Anchor,                /// crouch walking takes no knock-back.
	MaxDefaultAblities,
	
	MAX_ABILITIES = COMPONENT_BIT_LEN,
};

/// Builtin Abilities string name.
/// Please arrange these by sets of five.
#define ABILITY_RAGE            "rage"              /// taking damage increases a rage meter.
#define ABILITY_CLIMB_WALLS     "melee_climb_walls" /// hitting a wall with melee makes you climb it.
#define ABILITY_SPAWN_HEALTH    "spawn_health"      /// hit something, health spawns
#define ABILITY_SUPERJUMP       "superjump"         /// superjump mechanic.
#define ABILITY_WEIGHDOWN       "weighdown"         /// weighdown mechanic.

#define ABILITY_GLOW            "glow"              /// player is outlined when hurt [by specific things].
#define ABILITY_ESCAPE_PLAN     "escape_plan"       /// move faster as health gets lower.
#define ABILITY_STUN_PLYRS      "stun_players"      /// saxton hale stun rage on players.
#define ABILITY_STUN_BUILDS     "stun_building"     /// saxton hale stun rage on buildings.
#define ABILITY_TELEPORT        "teleport"          /// HHH right-click/duck teleport.

#define ABILITY_AUTO_FIRE       "auto_fire"         /// Easter Bunny egg rage.
#define ABILITY_POWER_UBER      "power_uber"        /// Vagineer-like Uber. (uber + no knockback)
#define ABILITY_ANCHOR          "anchor"            /// crouch walking takes no knock-back.
#define ABILITY_GET_WEP         "get_weapon"        /// CBS-style rage where you just gain a weapon.
#define ABILITY_EXPLODE_AMMO    "explode_ammo"      /// Easter Bunny ammo eggs burst on kill/death.


methodmap VSH2Player {
	/** [ C O N S T R U C T O R ]
	 * Constructs an instance of the BasePlayer internal methodmap
	 * @param index - index (or the userid) of a player
	 * @param userid - if using userid instead of player index, set this param to true
	 * @return    a player instance of the VSH2Player methodmap
	 */
	public native VSH2Player(int index, bool userid=false);
	
	
	/** **** **** [ P R O P E R T I E S ] **** **** **/
	/**
	 * gets the userid of the vsh2 player instance
	 * @return    the bare player userid integer
	 */
	property int userid {
		public native get();
	}
	
	/**
	 * gets the index of the vsh2 player instance
	 * @return    the bare player index integer
	 */
	property int index {
		public native get();
	}
	
	/**
	 * sets the property of the internal VSH2 methodmap
	 * NOTE: You can use this to create new properties which GetProperty can access!
	 * @param prop_name - name of property you want to access data from.
	 * @param item - reference to use of the variable to overwrite with data from the property.
	 * @return    value as "any".
	 */
	#pragma deprecated Use GetPropInt, GetPropFloat, or GetPropAny instead.
	public native any GetProperty(const char prop_name[64]);
	
	/**
	 * sets the property of the internal VSH2 methodmap
	 * NOTE: You can use this to create new properties which GetProperty can access!
	 * @param prop_name - name of the property you want to override data from (works like StringMap).
	 * @param value - data you want the property to hold.
	 * @noreturn
	 */
	#pragma deprecated Use SetPropInt, SetPropFloat, or SetPropAny instead.
	public native void  SetProperty(const char prop_name[64], any value);
	
	public native int   GetPropInt(const char prop_name[64]);
	public native float GetPropFloat(const char prop_name[64]);
	public native any   GetPropAny(const char prop_name[64]);
	
	public native bool  SetPropInt(const char prop_name[64], int value);
	public native bool  SetPropFloat(const char prop_name[64], float value);
	public native bool  SetPropAny(const char prop_name[64], any value);
	
	public native bool  HasProp(const char prop_name[64]);
	
	/** AVAILABLE PROPERTIES
	 * int iQueue
	 * int iPresetType
	 * int iLives
	 * int iState
	 * int iDamage
	 * int iAirDamage
	 * int iSongPick
	 * int iClimbs
	 * int iOwnerBoss  **** Use 'hOwnerBoss'  property instead of this. ****
	 * int iUberTarget **** Use 'hUberTarget' property instead of this. ****
	 * bool bIsMinion
	 * bool bInJump
	 * float flGlowtime
	 * float flLastHit
	 * float flLastShot
	 * 
	 * ALL PROPERTIES AFTER THIS COMMENT ONLY ACCOUNT FOR BOSSES BUT CAN STILL APPLY TO NON-BOSSES AND MINIONS **
	 * int iHealth
	 * int iMaxHealth
	 * int iBossType
	 * int iStabbed
	 * int iMarketted
	 * int iDifficulty
	 * bool bUsedUltimate
	 * bool bIsBoss
	 * bool bSuperCharge
	 * float flSpeed
	 * float flCharge
	 * float flRAGE
	 * float flKillSpree
	 * float flWeighDown
	 * float flMusicTime
	 * ConfigMap hConfig
	 */
	
	property int iHealth {
		public get() {
			return GetClientHealth(this.index);
		}
		public set(int val) {
			SetEntityHealth(this.index, val);
		}
	}
	
	property VSH2Player hOwnerBoss {
		public get() {
			return VSH2Player(this.GetPropInt("iOwnerBoss"), true);
		}
		public set(VSH2Player val) {
			this.SetPropInt("iOwnerBoss", val.userid);
		}
	}
	
	property VSH2Player hUberTarget {
		public get() {
			return VSH2Player(this.GetPropInt("iUberTarget"), true);
		}
		public set(VSH2Player val) {
			this.SetPropInt("iUberTarget", val.userid);
		}
	}
	property bool bIsMinion {
		public get() {
			return this.GetPropAny("bIsMinion");
		}
	}
	
	public native void ConvertToMinion(float spawntime);
	public native int  SpawnWeapon(const char[] name, int index, int level, int qual, const char[] att);
	public native int  GetWeaponSlotIndex(int slot);
	public native void SetWepInvis(int alpha);
	public        int  GetSlotIdxFromWep(int wep) {
		int client = this.index;
		for( int i = TFWeaponSlot_Primary; i <= TFWeaponSlot_Item2; i++ ) {
			if( wep==GetPlayerWeaponSlot(client, i) ) {
				return i;
			}
		}
		return -1;
	}
	
	public native void SetOverlay(const char[] strOverlay);
	public native bool TeleToSpawn(int team=0);
	public native void IncreaseHeadCount(bool addhealth=true, int head_count=1);
	public native void SpawnSmallHealthPack(int ownerteam=0);
	public native void ForceTeamChange(int team);
	public native bool ClimbWall(int weapon, float upwardVel, float health, bool attackdelay);
	public native void HelpPanelClass();
	public native int  GetAmmoTable(int wepslot);
	public native void SetAmmoTable(int wepslot, int amount);
	public native int  GetClipTable(int wepslot);
	public native void SetClipTable(int wepslot, int amount);
	
	public native int  GetHealTarget();
	public VSH2Player  GetHealPatient() {
		return VSH2Player(this.GetHealTarget());
	}
	
	property VSH2Player hHealTarget {
		public get() {
			return this.GetHealPatient();
		}
	}
	
	public native bool IsNearDispenser();
	public native bool IsInRange(int target, float dist, bool pTrace=false);
	public bool        IsPlayerInRange(VSH2Player target, float dist, bool pTrace=false) {
		return this.IsInRange(target.index, dist, pTrace);
	}
	
	public int GetPlayersInRange(VSH2Player[/** MaxClients */] players, float dist, bool trace=false) {
		int count;
		for( int i=1; i<=MaxClients; i++ ) {
			if( !(0 < i <= MaxClients) || !IsClientInGame(i) || !IsPlayerAlive(i) ) {
				continue;
			}
			VSH2Player player = VSH2Player(i);
			if( player==this ) {
				continue;
			} else if( this.IsInRange(i, dist, trace) ) {
				players[count++] = player;
			}
		}
		return count;
	}
	
	public native void RemoveBack(const int[] indices, int len);
	
	public native int  FindBack(const int[] indices, int len);
	
	public native int  ShootRocket(bool bCrit=false, const float vPosition[3], const float vAngles[3], float flSpeed, float dmg, const char[] model, bool arc=false);
	
	public native void Heal(int health, bool on_hud=false, bool overridehp=false, int overheal_limit=0);
	
	#pragma deprecated Use iTFClass property instead.
	public TFClassType GetTFClass() {
		return TF2_GetPlayerClass(this.index);
	}
	
	/// why didn't I make it a property in the first place?
	property TFClassType iTFClass {
		public get() {
			return TF2_GetPlayerClass(this.index);
		}
	}
	
	public native bool AddTempAttrib(int attrib, float val, float dur=(-1.0));
	
	/// Ability stuff.
	/// works on bosses and non-bosses alike.
	public native bool GiveAbility(const char[] name);
	public native bool RemoveAbility(const char[] name);
	public native bool HasAbility(const char[] name);
	public native bool RemoveAllAbilities();
	
	/**
	 * For ability-making devs to allow addons and boss modules to intercept ability data.
	 * 
	 * @param ability_name - name of the ability about to be run.
	 * @param args         - ability arguments in an ArrayList.
	 * @return             - Action, Plugin_Changed result will set 'was_changed' to true for 'RunPostAbility'.
	 */
	public native Action RunPreAbility(const char[] ability_name, any[] args, int len);
	public native void   RunPostAbility(const char[] ability_name, const any[] args, int len, bool was_changed);
	
	
	/// Boss oriented methods & properties.
	property bool bIsBoss {
		public get() {
			return this.GetPropAny("bIsBoss");
		}
	}
	public native void ConvertToBoss();
	public native void GiveRage(int damage);
	public native void MakeBossAndSwitch(int type, bool run_event);
	public native void DoGenericStun(float rageDist);
	public native void StunPlayers(float rage_dist, float stun_time=5.0);
	public native void StunBuildings(float rage_dist, float sentry_stun_time=8.0);
	public native void RemoveAllItems(bool weps=true);
	
	public native bool GetName(char buffer[MAX_BOSS_NAME_SIZE]);
	public native bool SetName(const char name[MAX_BOSS_NAME_SIZE]);
	
	public native void SuperJump(float power, float reset);
	public native void WeighDown(float reset);
	
	/** use the VSH2_VOICE_* flags above^^^. */
	public native void PlayVoiceClip(const char[] voiceclip, int flags);
	
	public native void PlayMusic(float vol=100.0, const char[] override="");
	public native void StopMusic();
	
	public void SpeedThink(float iota, float minspeed=100.0) {
		VSH2_SpeedThink(this, iota, minspeed);
	}
	public void GlowThink(float decrease) {
		VSH2_GlowThink(this, decrease);
	}
	public bool SuperJumpThink(float charging, float jumpcharge, int buttons = (IN_ATTACK2|IN_DUCK)) {
		return VSH2_SuperJumpThink(this, charging, jumpcharge, buttons);
	}
	public void WeighDownThink(float weighdown_time, float incr, int buttons = IN_DUCK) {
		VSH2_WeighDownThink(this, weighdown_time, incr, buttons);
	}
	
	public void PlayRandVoiceClipCfgMap(ConfigMap sect, int voice_flags) {
		if( sect==null ) {
			return;
		}
		static int curr_sound_idx;
		curr_sound_idx = ShuffleIndex(sect.Size, curr_sound_idx);
		int sound_len = sect.GetIntKeySize(curr_sound_idx);
		char[] sound_str = new char[sound_len];
		if( sect.GetIntKey(curr_sound_idx, sound_str, sound_len) > 0 ) {
			this.PlayVoiceClip(sound_str, voice_flags);
		}
	}
	
	public native bool ChargedThink(float charge_rate, float &charge, float max_charge, float min_charge, int req_buttons, bool cond, bool &super_charged=false);
	
	/// HHH Jr teleport.
	public native void TeleToRandomPlayer(float charge_reset, bool supercharge_reset);
};


/** Common Boss Think Mechanics
 * Made these because of how common these boss mechanics are used within VSH and FF2.
 *
 * SpeedThink -> health-based speed where the less health the boss has, the faster they move.
 * GlowThink -> handles how long the boss will be visible through walls aka glowing.
 * SuperJumpThink -> handles superjump charging
 * WeighDownThink -> handles weighdown charging
 */

stock void VSH2_SpeedThink(VSH2Player boss, float iota, float minspeed=100.0) {
	if( !boss.HasAbility(ABILITY_ESCAPE_PLAN) ) {
		return;
	}
	float speed = iota + 0.7 * (100 - boss.iHealth * 100 / boss.GetPropInt("iMaxHealth"));
	SetEntPropFloat(boss.index, Prop_Send, "m_flMaxspeed", (speed < minspeed)? minspeed : speed);
}

stock void VSH2_GlowThink(VSH2Player boss, float decrease) {
	if( !boss.HasAbility(ABILITY_GLOW) ) {
		return;
	}
	float glowtime = boss.GetPropFloat("flGlowtime");
	if( glowtime > 0.0 ) {
		SetEntProp(boss.index, Prop_Send, "m_bGlowEnabled", 1);
		boss.SetPropFloat("flGlowtime", glowtime - decrease);
	} else if( glowtime <= 0.0 ) {
		SetEntProp(boss.index, Prop_Send, "m_bGlowEnabled", 0);
	}
}

stock bool VSH2_SuperJumpThink(VSH2Player boss, float charging, float jumpcharge, int button=(IN_ATTACK2|IN_DUCK)) {
	if( !boss.HasAbility(ABILITY_SUPERJUMP) ) {
		return false;
	}
	int player   = boss.index;
	int buttons  = GetClientButtons(player);
	float charge = boss.GetPropFloat("flCharge");
	if( (buttons & button) && charge >= 0.0 ) {
		if( charge + charging < jumpcharge ) {
			boss.SetPropFloat("flCharge", charge + charging);
		} else {
			boss.SetPropFloat("flCharge", jumpcharge);
		}
	} else if( charge < 0.0 ) {
		boss.SetPropFloat("flCharge", charge + charging);
	} else {
		float EyeAngles[3]; GetClientEyeAngles(player, EyeAngles);
		if( charge > 1.0 && EyeAngles[0] < -5.0 ) {
			return true;
		} else {
			boss.SetPropFloat("flCharge", 0.0);
		}
	}
	return false;
}

stock void VSH2_WeighDownThink(VSH2Player boss, float weighdown_time, float incr, int button=IN_DUCK) {
	if( !boss.HasAbility(ABILITY_WEIGHDOWN) ) {
		return;
	}
	int player  = boss.index;
	int buttons = GetClientButtons(player);
	int flags   = GetEntityFlags(player);
	if( flags & FL_ONGROUND ) {
		boss.SetPropFloat("flWeighDown", 0.0);
	} else {
		boss.SetPropFloat("flWeighDown", boss.GetPropFloat("flWeighDown") + incr);
	}
	if( (buttons & button) && boss.GetPropFloat("flWeighDown") >= weighdown_time ) {
		float ang[3]; GetClientEyeAngles(player, ang);
		if( ang[0] > 60.0 ) {
			boss.WeighDown(0.0);
		}
	}
}


/**
 * Registers a boss module/subplugin.
 * NOTE: The purpose of this native is to register boss modules/subplugins, you don't need to register add-on plugins to use forwards, simply hook what forward(s) you need.
 * 
 * @param     plugin_name -> module name you want your calling plugin to be identified under
 * @return    integer of the plugin array index, -1 if error.
 */
native int VSH2_RegisterPlugin(const char plugin_name[64]);

/**
 * Returns the single, internal hash map that is intended to be shared with addons and boss modules.
 * NOTE: **** DO NOT DELETE THE STRINGMAP GIVEN FROM THIS NATIVE. ****
 * 
 * @return    shareable hashmap.
 */
native StringMap VSH2_GetSharedMap();


/**
 * Registers an ability which is defines as any passive or active mechanic
 * that a player, minion and/or boss is allowed to use such as Wall-Climbing Melee.
 *
 * @param     ability_name -> Name of the ability, some are already preregistered.
 * @return    true if successful, false otherwise.
 */
native bool VSH2_RegisterAbility(const char[] ability_name);


enum { /// VSH2HookType
	OnCallDownloads=0,
	OnBossSelected,
	OnBossHelp,
	OnTouchPlayer,
	OnTouchBuilding,
	OnBossThink,
	OnBossModelTimer,
	OnBossDeath,
	OnBossEquipped,
	OnBossInitialized,
	OnMinionInitialized,
	OnBossPlayIntro,
	OnBossTakeDamage,
	OnBossDealDamage,
	OnPlayerKilled,
	OnPlayerAirblasted,
	OnTraceAttack,
	OnBossMedicCall,
	OnBossTaunt,
	OnBossKillBuilding,
	OnBossJarated,
	OnMessageIntro,
	OnBossPickUpItem,
	OnVariablesReset,
	OnUberDeployed,
	OnUberLoop,
	OnMusic,
	OnRoundEndInfo,
	OnLastPlayer,
	OnBossHealthCheck,
	OnControlPointCapped,
	OnBossMenu,
	OnPrepRedTeam,
	OnPlayerHurt,
	OnScoreTally,
	OnItemOverride,
	OnBossDealDamage_OnStomp,
	OnBossDealDamage_OnHitDefBuff,
	OnBossDealDamage_OnHitCritMmmph,
	OnBossDealDamage_OnHitMedic,
	OnBossDealDamage_OnHitDeadRinger,
	OnBossDealDamage_OnHitCloakedSpy,
	OnBossDealDamage_OnHitShield,
	
	OnBossTakeDamage_OnStabbed,
	OnBossTakeDamage_OnTelefragged,
	OnBossTakeDamage_OnSwordTaunt,
	OnBossTakeDamage_OnHeavyShotgun,
	OnBossTakeDamage_OnSniped,
	OnBossTakeDamage_OnThirdDegreed,
	OnBossTakeDamage_OnHitSword,
	OnBossTakeDamage_OnHitFanOWar,
	OnBossTakeDamage_OnHitCandyCane,
	OnBossTakeDamage_OnMarketGardened,
	OnBossTakeDamage_OnPowerJack,
	OnBossTakeDamage_OnKatana,
	OnBossTakeDamage_OnAmbassadorHeadshot,
	OnBossTakeDamage_OnDiamondbackManmelterCrit,
	OnBossTakeDamage_OnHolidayPunch,
	
	OnBossSuperJump,
	OnBossDoRageStun,
	OnBossWeighDown,
	OnRPSTaunt,
	OnBossAirShotProj,
	OnBossTakeFallDamage,
	OnBossGiveRage,
	OnBossCalcHealth,
	OnBossTakeDamage_OnTriggerHurt,
	OnBossTakeDamage_OnMantreadsStomp,
	OnBossThinkPost,
	OnRedPlayerThink,
	OnBossEquippedPost,
	OnPlayerTakeFallDamage,
	OnSoundHook,
	OnRoundStart,
	OnHelpMenu,
	OnHelpMenuSelect,
	OnDrawGameTimer,
	OnPlayerClimb,
	OnBossConditionChange,
	OnBannerDeployed,
	OnBannerEffect,
	OnUberLoopEnd,
	OnRedPlayerThinkPost,
	OnRedPlayerHUD,
	OnRedPlayerCrits,
	OnShowStats,
	OnPreAbility,
	OnPostAbility,
	OnBossHUD,
	OnTeamsSeparate,
	OnMapObsPrep,
	MaxVSH2Forwards
};


/**
 * IF YOU'RE USING THE HOOKING SYSTEM FOR A CUSTOM BOSS,
 * YOU HAVE TO REGISTER YOUR PLUGIN WITH VSH2 BECAUSE YOU NEED THE BOSS' INDEX TRACKED.
 */

typeset VSH2HookCB {
	/**
	 * OnBossSelected
	 * OnBossHelp -> Action has no effect on this forward.
	 * OnBossThink
	 * OnBossModelTimer
	 * OnBossDeath
	 * OnBossEquipped
	 * OnBossEquippedPost -> Action has no effect on this forward.
	 * OnBossInitialized
	 * OnBossPlayIntro
	 * OnBossMedicCall
	 * OnBossTaunt
	 * OnVariablesReset
	 * OnPrepRedTeam
	 * OnRedPlayerThink
	 * OnLastPlayer - 'player' is a boss.
	 * OnBossSuperJump
	 * OnBossWeighDown
	 * OnBossThinkPost -> Action has no effect on this forward.
	 * OnRedPlayerThinkPost -> Action has no effect on this forward.
	 */
	function Action (VSH2Player player);
	function void   (VSH2Player player);
	
	/**
	 * OnTouchPlayer - victim is boss, attacker is other player.
	 * OnBossJarated
	 * OnUberDeployed - Victim is medic, Attacker (Check if valid) is uber target
	 * OnUberLoop - Victim is medic, Attacker (Check if valid) is uber target
	 * OnRPSTaunt - victim is loser, attacker is winner.
	 * OnMinionInitialized - victim is minion, attacker is the owner/master boss.
	 * OnLastPlayer - "victim" is a boss, "attacker" is the last fighter/player.
	 */
	function Action (VSH2Player victim, VSH2Player attacker);
	function void   (VSH2Player victim, VSH2Player attacker);
	
	/// OnTouchBuilding
	function Action (VSH2Player attacker, int BuildingRef);
	function void   (VSH2Player attacker, int BuildingRef);
	
	/// OnBossKillBuilding
	function Action (VSH2Player attacker, int building, Event event);
	function void   (VSH2Player attacker, int building, Event event);
	
	/** Boss Specific OnTakeDamage hooks
	 * OnBossTakeDamage -> use if your boss requires completely custom take damage code.
	 * OnBossDealDamage -> use if your boss requires completely custom deal damage code.
	 * OnBossDealDamage_OnStomp -> when boss mantread-stomps a player.
	 * OnBossDealDamage_OnHitDefBuff -> hit's players buffed with Battalion's Backup banner.
	 * OnBossDealDamage_OnHitCritMmmph -> hitting someone under phlog buff.
	 * OnBossDealDamage_OnHitMedic -> hitting a medic.
	 * OnBossDealDamage_OnHitDeadRinger -> hitting a spy that has Dead Ringer.
	 * OnBossDealDamage_OnHitCloakedSpy -> hitting a spy that is cloaked.
	 * OnBossDealDamage_OnHitShield -> hitting a player equipped with demoknight shield or razorback.
	 * 
	 * OnBossTakeDamage_OnStabbed -> boss got backstabbed!
	 * OnBossTakeDamage_OnTelefragged -> boss got telefragged
	 * OnBossTakeDamage_OnSwordTaunt -> boss got hit by a demo sword swing taunt.
	 * OnBossTakeDamage_OnHeavyShotgun -> boss got shot by a heavy weapons guy's shotgun.
	 * OnBossTakeDamage_OnSniped -> Boss is shot with a sniper rifle.
	 * OnBossTakeDamage_OnThirdDegreed -> Boss is hit with third degree pyro melee.
	 * OnBossTakeDamage_OnHitSword -> Boss is hit with demo sword that accrues heads.
	 * OnBossTakeDamage_OnHitFanOWar -> boss is hit with scout Fan O' War.
	 * OnBossTakeDamage_OnHitCandyCane -> boss is hit with scout Candy Cane.
	 * OnBossTakeDamage_OnMarketGardened -> boss is hit with market garden in midair.
	 * OnBossTakeDamage_OnPowerJack -> boss is hit with power jack.
	 * OnBossTakeDamage_OnKatana -> boss is hit with katana.
	 * OnBossTakeDamage_OnAmbassadorHeadshot -> boss is headshotted with ambassador spy pistol.
	 * OnBossTakeDamage_OnDiamondbackManmelterCrit -> boss is hit with a crit from manmelter or diamondback.
	 * OnBossTakeDamage_OnHolidayPunch -> boss is hit with the Holiday Punch HWG melee.
	 * OnBossAirShotProj -> when a boss was airshotted by a projectile.
	 * OnBossTakeFallDamage
	 * OnBossTakeDamage_OnTriggerHurt
	 * OnBossTakeDamage_OnMantreadsStomp
	 * OnPlayerTakeFallDamage -> when a red takes fall dmg.
	 */
	function Action (VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom);
	
	/**
	 * PlayerKilled
	 * PlayerAirblasted - player is the airblaster
	 * PlayerHurt
	 */
	function Action (VSH2Player player, VSH2Player victim, Event event);
	function void   (VSH2Player player, VSH2Player victim, Event event);
	
	/// OnTraceAttack
	function Action (VSH2Player victim, VSH2Player attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup);
	function void   (VSH2Player victim, VSH2Player attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup);
	
	/// OnMessageIntro
	function Action (VSH2Player player, char message[MAXMESSAGE]);
	function void   (VSH2Player player, char message[MAXMESSAGE]);
	
	/**
	 * BossHealthCheck - bossBool determines if command user was the boss
	 * RoundEndInfo - bossBool determines if boss won the round
	 */
	function Action (VSH2Player player, bool bossBool, char message[MAXMESSAGE]);
	function void   (VSH2Player player, bool bossBool, char message[MAXMESSAGE]);
	
	/// OnMusic
	function Action (char song[PLATFORM_MAX_PATH], float& time, VSH2Player player);
	function void   (char song[PLATFORM_MAX_PATH], float& time, VSH2Player player);
	function Action (char song[PLATFORM_MAX_PATH], float& time, VSH2Player player, float& volume);
	function void   (char song[PLATFORM_MAX_PATH], float& time, VSH2Player player, float& volume);
	
	/// OnControlPointCapped
	function Action (char cappers[MAXPLAYERS+1], int team);
	function void   (char cappers[MAXPLAYERS+1], int team);
	/// Use these VVVVVVVVV forward signatures instead for 'OnControlPointCapped'.
	function Action (char cappers[MAXPLAYERS+1], int team, VSH2Player[] pcappers, int capper_count);
	function void   (char cappers[MAXPLAYERS+1], int team, VSH2Player[] pcappers, int capper_count);
	
	/// OnCallDownloads
	/// OnTeamsSeparate
	function Action ();
	function void   ();
	
	/// OnBossPickUpItem -> player may or may not actually be a boss in this forward.
	function Action (VSH2Player player, const char item[64]);
	function void   (VSH2Player player, const char item[64]);
	
	/// OnBossMenu
	function void   (Menu& menu);
	function void   (Menu& menu, VSH2Player player);
	
	/// OnScoreTally
	function Action (VSH2Player player, int& points_earned, int& queue_earned);
	function void   (VSH2Player player, int& points_earned, int& queue_earned);
	
	/// OnItemOverride
	function Action (VSH2Player player, const char[] classname, int itemdef, Handle& item);
	function void   (VSH2Player player, const char[] classname, int itemdef, Handle& item);
	function Action (VSH2Player player, const char[] classname, int itemdef, TF2Item& item);
	function void   (VSH2Player player, const char[] classname, int itemdef, TF2Item& item);
	
	/// OnBossDoRageStun
	function Action (VSH2Player player, float& distance);
	function void   (VSH2Player player, float& distance);
	
	/// OnBossGiveRage
	function Action (VSH2Player player, int damage, float& calcd_rage);
	function void   (VSH2Player player, int damage, float& calcd_rage);
	
	/// OnBossCalcHealth
	/// It's preferred that you use/modify the 'iMaxHealth' property instead.
	function Action (VSH2Player player, int& max_health, int boss_count, int red_players);
	function void   (VSH2Player player, int& max_health, int boss_count, int red_players);
	
	/// OnSoundHook
	function Action (VSH2Player player, char sample[PLATFORM_MAX_PATH], int& channel, float& volume, int& level, int& pitch, int& flags);
	function void   (VSH2Player player, char sample[PLATFORM_MAX_PATH], int& channel, float& volume, int& level, int& pitch, int& flags);
	
	/// OnRoundStart
	function void   (VSH2Player[] bosses, int boss_count, VSH2Player[] red_players, int red_count);
	
	/// OnHelpMenu
	function void   (VSH2Player player, Menu menu);
	
	/// OnHelpMenuSelect
	function void   (VSH2Player player, Menu menu, int selection);
	
	/// OnDrawGameTimer
	function Action (int& seconds);
	function void   (int& seconds);
	
	/// OnPlayerClimb
	function Action (VSH2Player player, int weapon, float& upwardvel, float& health, bool& attackdelay);
	function void   (VSH2Player player, int weapon, float& upwardvel, float& health, bool& attackdelay);
	
	/// OnBossConditionChange
	function Action (VSH2Player player, TFCond cond, bool removing);
	function Action (VSH2Player player, TFCond cond, bool removing, bool& remove);
	
	/// OnBannerDeployed
	/// 'owner' is the owner of the banner.
	/// Returning other than `Plugin_Continue` has no effect
	/// except preventing boss modules from getting this event.
	function Action (VSH2Player owner, BannerType banner);
	
	/// OnBannerEffect
	/// 'owner' is the owner of the banner.
	/// 'player' is buffed by the banner.
	/// Returning other than `Plugin_Continue` has no effect
	/// except preventing boss modules from getting this event.
	function Action (VSH2Player player, VSH2Player owner, BannerType banner);
	
	/// OnUberLoopEnd
	/// target can be invalid so be careful.
	function Action (VSH2Player medic, VSH2Player target, float& reset_charge);
	
	/// OnRedPlayerHUD
	/// OnBossHUD
	function Action (VSH2Player player, char hud_text[PLAYER_HUD_SIZE]);
	function void   (VSH2Player player, char hud_text[PLAYER_HUD_SIZE]);
	
	/// OnRedPlayerCrits
	function Action (VSH2Player player, int& crit_flags);
	function void   (VSH2Player player, int& crit_flags);
	
	/// OnShowStats
	function Action (VSH2Player top_players[3]);
	function void   (VSH2Player top_players[3]);
	
	/// OnPreAbility
	function Action (VSH2Player player, const char[] ability_name, any[] args, int len);
	
	/// OnPostAbility
	function void   (VSH2Player player, const char[] ability_name, any[] args, int len, bool was_changed);
	
	/// OnMapObsPrep
	function Action (const char[] map_obj_name);
	function void   (const char[] map_obj_name);
};

/// Use hooktype enum on these.
native void VSH2_Hook(int callbacktype, VSH2HookCB callback);
native bool VSH2_HookEx(int callbacktype, VSH2HookCB callback);

native void VSH2_Unhook(int callbacktype, VSH2HookCB callback);
native bool VSH2_UnhookEx(int callbacktype, VSH2HookCB callback);

native int  VSH2_GetMaxBosses();
native int  VSH2_GetRandomBossType(int[] boss_filter, int filter_size=0);

/**
 * Gets the ID and (short) names of all bosses.
 * @param registered_only: gets only the boss modules.
 * @return                 StringMap of all bosses, null if empty or error.
 * @note     Don't forget to delete the StringMap when you're done with it.
 */
native StringMap VSH2_GetBossIDs(bool registered_only=false);

/**
 * Returns the ID of a specific bossname, useful for example finding IDs of companions bosses at runtime.
 * @param boss_name: short name of the boss you want to find
 * @return           boss ID as an integer
 * @note             returns -1 if boss was not found
 */
native int VSH2_GetBossID(const char boss_name[MAX_BOSS_NAME_SIZE]);

/**
 * @param index:       self-explanatory.
 * @param name_buffer: buffer to store the boss name.
 * @return             boss ID as an integer
 * @note               returns false if name buffer was written to, true if otherwise.
 */
native bool VSH2_GetBossNameByIndex(int index, char name_buffer[MAX_BOSS_NAME_SIZE]);

/**
 * Stops the VSH2 background music at will.
 * @param reset_time: resets the music time so that 'OnMusic' hook can be called again.
 * @noreturn
 */
native void VSH2_StopMusic(bool reset_time=true);

/**
 * returns the internal ConfigMap instance read from 'vsh2.cfg'.
 * @noparam
 * @return          internal config map used by VSH2.
 * @note            the handle MUST be freed with DeleteCfg
 */
native ConfigMap VSH2_GetConfigMap();


/**
 * Game Mode Oriented stuff.
 */

methodmap VSHHealthBar {
	public VSHHealthBar() {
		int healthbar = FindEntityByClassname(-1, "monster_resource");
		if( healthbar == -1 ) {
			healthbar = CreateEntityByName("monster_resource");
			if( healthbar != -1 ) {
				DispatchSpawn(healthbar);
			}
		}
		return view_as< VSHHealthBar >(healthbar);
	}
	
	property int entity {
		public get() {
			return view_as< int >(this);
		}
	}
	
	property int iState {
		public get() {
			return GetEntProp(this.entity, Prop_Send, "m_iBossState");
		}
		public set(int val) {
			SetEntProp(this.entity, Prop_Send, "m_iBossState", val);
		}
	}
	property int iPercent {
		public get() {
			return GetEntProp(this.entity, Prop_Send, "m_iBossHealthPercentageByte");
		}
		public set(int val) {
			SetEntProp(this.entity, Prop_Send, "m_iBossHealthPercentageByte", IntClamp(val, 255, 0));
		}
	}

	public void SetHealthPercent(int total_health, int total_max_health) {
		this.iPercent = RoundFloat(float(total_health) / float(total_max_health) * 255);
	}
};


native any  VSH2GameMode_GetProperty(const char prop_name[64]);
native void VSH2GameMode_SetProperty(const char prop_name[64], any value);
native bool VSH2GameMode_HasProperty(const char prop_name[64]);

/**
 * Available Properties:
 * int iRoundState
 * int iSpecial
 * int iPrevSpecial
 * int iTotalMaxHealth
 * int iTimeLeft
 * int iRoundCount
 * int iHealthChecks
 * int iCaptures
 *
 * bool bSteam
 * bool bTF2Attribs
 * bool bPointReady
 * bool bMedieval
 * bool bDoors
 * bool bTeleToSpawn
 *
 * float flHealthTime
 * float flMusicTime
 *
 * VSH2Player hNextBoss
 */

stock int VSH2GameMode_GetPropInt(const char prop_name[64]) {
	return VSH2GameMode_GetProperty(prop_name);
}

stock float VSH2GameMode_GetPropFloat(const char prop_name[64]) {
	float f = VSH2GameMode_GetProperty(prop_name);
	return f;
}

stock any VSH2GameMode_GetPropAny(const char prop_name[64]) {
	return VSH2GameMode_GetProperty(prop_name);
}

stock void VSH2GameMode_SetPropInt(const char prop_name[64], int value) {
	VSH2GameMode_SetProperty(prop_name, value);
}

stock void VSH2GameMode_SetPropFloat(const char prop_name[64], float value) {
	VSH2GameMode_SetProperty(prop_name, value);
}

stock void VSH2GameMode_SetPropAny(const char prop_name[64], any value) {
	VSH2GameMode_SetProperty(prop_name, value);
}


native VSH2Player VSH2GameMode_FindNextBoss();
native VSH2Player VSH2GameMode_GetRandomBoss(bool IsAlive);
native VSH2Player VSH2GameMode_GetBossByType(bool IsAlive, int BossType);

native int VSH2GameMode_CountMinions(bool IsAlive, VSH2Player ownerboss=view_as< VSH2Player >(0));
native int VSH2GameMode_CountBosses(bool IsAlive);
native int VSH2GameMode_GetTotalBossHealth();
native int VSH2GameMode_GetTotalRedPlayers();
native int VSH2GameMode_GetBosses(VSH2Player[] bosses, bool balive=true);
native int VSH2GameMode_GetFighters(VSH2Player[] redplayers, bool balive=true);
native int VSH2GameMode_GetMinions(VSH2Player[] minions, bool balive=true, VSH2Player ownerboss=view_as< VSH2Player >(0));
native int VSH2GameMode_GetBossesByType(VSH2Player[] bosses, int type, bool balive=true);

/// has the `players` array sorted by DESCENDING order (first index is highest queue).
native int VSH2GameMode_GetQueue(VSH2Player[] players);

native void VSH2GameMode_SearchForItemPacks();
native void VSH2GameMode_UpdateBossHealth();
native void VSH2GameMode_GetBossType();

native Handle VSH2GameMode_GetHUDHandle(int HUDType=PlayerHUD);

native bool VSH2GameMode_IsVSHMap();


methodmap VSH2GameMode {
	public VSH2GameMode() { return view_as< VSH2GameMode >(0); }
	
	property VSH2Player hNextBoss {
		public get() {
			return VSH2GameMode_FindNextBoss();
		}
	}
	
	property int iTotalBossHealth {
		public get() {
			return VSH2GameMode_GetTotalBossHealth();
		}
	}
	property int iLivingReds {
		public get() {
			return VSH2GameMode_GetTotalRedPlayers();
		}
	}
	
	property Handle hHUD {
		public get() {
			return VSH2GameMode_GetHUDHandle();
		}
	}
	
	public static int GetPropInt(const char prop_name[64]) {
		return VSH2GameMode_GetProperty(prop_name);
	}
	public static any GetPropAny(const char prop_name[64]) {
		return VSH2GameMode_GetProperty(prop_name);
	}
	public static float GetPropFloat(const char prop_name[64]) {
		float f = VSH2GameMode_GetProperty(prop_name);
		return f;
	}
	
	public static void SetPropInt(const char prop_name[64], int value) {
		VSH2GameMode_SetProperty(prop_name, value);
	}
	public static void SetPropAny(const char prop_name[64], any value) {
		VSH2GameMode_SetProperty(prop_name, value);
	}
	public static void SetPropFloat(const char prop_name[64], float value) {
		VSH2GameMode_SetProperty(prop_name, value);
	}
	
	public static bool HasProp(const char prop_name[64]) {
		return VSH2GameMode_HasProperty(prop_name);
	}
	
	property VSHHealthBar hHealthBar {
		public get() {
			return VSH2GameMode.GetPropAny("iHealthBar");
		}
	}
	
	public static VSH2Player GetRandomBoss(bool is_alive) {
		return VSH2GameMode_GetRandomBoss(is_alive);
	}
	public static VSH2Player GetBossByType(bool is_alive, int boss_type) {
		return VSH2GameMode_GetBossByType(is_alive, boss_type);
	}
	
	public static int CountMinions(bool is_alive, VSH2Player ownerboss=view_as< VSH2Player >(0)) {
		return VSH2GameMode_CountMinions(is_alive, ownerboss);
	}
	public static int CountBosses(bool is_alive) {
		return VSH2GameMode_CountBosses(is_alive);
	}
	public static int GetBosses(VSH2Player[] bosses, bool balive=true) {
		return VSH2GameMode_GetBosses(bosses, balive);
	}
	public static int GetFighters(VSH2Player[] redplayers, bool balive=true) {
		return VSH2GameMode_GetFighters(redplayers, balive);
	}
	public static int GetMinions(VSH2Player[] minions, bool balive=true, VSH2Player ownerboss=view_as< VSH2Player >(0)) {
		return VSH2GameMode_GetMinions(minions, balive, ownerboss);
	}
	public static int GetBossesByType(VSH2Player[] bosses, int type, bool balive=true) {
		return VSH2GameMode_GetBossesByType(bosses, type, balive);
	}
	public static int GetQueue(VSH2Player[] players) {
		return VSH2GameMode_GetQueue(players);
	}
	
	public static void SearchForItemPacks() {
		VSH2GameMode_SearchForItemPacks();
	}
	public static void UpdateBossHealth() {
		VSH2GameMode_UpdateBossHealth();
	}
	public static void SelectBossType() {
		VSH2GameMode_GetBossType();
	}
	public static bool IsVSHMap() {
		return VSH2GameMode_IsVSHMap();
	}
	
	public static bool AreScoutsLeft() {
		VSH2Player[] players = new VSH2Player[MaxClients];
		int reds = VSH2GameMode.GetFighters(players);
		/// make sure friendly bosses and minions are excluded.
		for( int i; i < reds; i++ ) {
			if( players[i].bIsBoss || players[i].GetPropInt("bIsMinion") || players[i].iTFClass != TFClass_Scout ) {
				return false;
			}
		}
		return true;
	}
	public static VSH2Player GetRandomFighter(bool friendly_bosses=true, bool is_alive=true) {
		VSH2Player[] players = new VSH2Player[MaxClients];
		int count;
		for( int i=1; i <= MaxClients; i++ ) {
			if( !IsClientInGame(i) || GetClientTeam(i) != VSH2Team_Red || (is_alive && !IsPlayerAlive(i)) ) {
				continue;
			}
			
			VSH2Player p = VSH2Player(i);
			if( !friendly_bosses && p.bIsBoss ) {
				continue;
			}
			players[count++] = p;
		}
		return( !count )? VSH2Player(0) : players[GetRandomInt(0, count-1)];
	}
	public static int GetRandomBossType(bool multibosses=false, bool red_only=false) {
		int boss_filter[1];
		return VSH2_GetRandomBossType(boss_filter, sizeof(boss_filter) /*, multibosses, red_only*/);
	}
};


/**
 * VSH2 Misc. Useful stocks.
 */
stock bool CheckDownload(const char[] file) {
	if( FileExists(file, true) ) {
		AddFileToDownloadsTable(file);
		return true;
	}
	LogError("CheckDownload :: File not found: '%s'", file);
	return false;
}

stock void PrepareSound(const char[] sound_path) {
	PrecacheSound(sound_path, true);
	char s[PLATFORM_MAX_PATH];
	Format(s, sizeof(s), "sound/%s", sound_path);
	CheckDownload(s);
}

stock void DownloadSoundList(const char[][] file_list, int size) {
	for( int i; i < size; i++ ) {
		PrepareSound(file_list[i]);
	}
}

stock void PrecacheSoundList(const char[][] file_list, int size) {
	for( int i; i < size; i++ ) {
		PrecacheSound(file_list[i], true);
	}
}

stock void PrecacheScriptList(const char[][] file_list, int size) {
	for( int i; i < size; i++ ) {
		PrecacheScriptSound(file_list[i]);
	}
}

/// For single custom materials, omit file extensions as it prepares VMT + VTF
stock void PrepareMaterial(const char[] matpath) {
	char s[PLATFORM_MAX_PATH];
	Format(s, sizeof(s), "%s%s", matpath, ".vtf");
	CheckDownload(s);
	Format(s, sizeof(s), "%s%s", matpath, ".vmt");
	CheckDownload(s);
}

stock void DownloadMaterialList(const char[][] file_list, int size) {
	char s[PLATFORM_MAX_PATH];
	for( int i; i < size; i++ ) {
		strcopy(s, sizeof(s), file_list[i]);
		CheckDownload(s);
	}
}

/// For custom models, do NOT omit .MDL extension
stock int PrepareModel(const char[] model_path, bool model_only=false) {
	char extensions[][] = { ".mdl", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd", ".phy" };
	char model_base[PLATFORM_MAX_PATH];
	char path[PLATFORM_MAX_PATH];

	strcopy(model_base, sizeof(model_base), model_path);
	SplitString(model_base, ".mdl", model_base, sizeof(model_base)); /// Kind of redundant, but eh.
	if( !model_only ) {
		for( int i; i < sizeof(extensions); i++ ) {
			Format(path, PLATFORM_MAX_PATH, "%s%s", model_base, extensions[i]);
			CheckDownload(path);
		}
	} else {
		CheckDownload(model_path);
	}
	return PrecacheModel(model_path, true);
}

/// Contributed by ScaleFace
stock bool IsStockSound(const char sample[PLATFORM_MAX_PATH]) {
	char exclusions[][] = {
		"_pain","_medic","_battlecry","_pain","_auto","_activatecharge","_jeers","_cheers","_help",
		"_incoming","_goodjob","_head","_fight","_cloaked","_melee","_move","_positive","_negative","_need",
		"_nice","_thanks", "_yes","_no","_go","_sentry"
	};
	for( int i; i < sizeof(exclusions); i++ ) {
		if( StrContains(sample, exclusions[i], false) != -1 ) {
			return true;
		}
	}
	return false;
}

stock bool IsVoiceLine(const char sample[PLATFORM_MAX_PATH]) {
	return !strncmp(sample, "vo", 2, false);
}

stock int ShuffleIndex(int size, int curr_index) {
	if( size < 2 ) {
		return 0;
	}
	int t = size - 1;
	curr_index = IntClamp(curr_index, t, 0);
	int new_index = GetRandomInt(0, t);
	while( new_index==curr_index ) {
		new_index = GetRandomInt(0, t);
	}
	return new_index;
}

/**
 * `int` can go from 2147483647 to -2147483648
 * which is 10 characters + 1 for unary minus.
 */
stock bool KeyToStr(any key, char buffer[12]) {
	return IntToString(key, buffer, sizeof(buffer)) != 0;
}

/**
 * Credit: Asher 'Asherkin' Baker
 * Packs a key, as an integer, into a null-terminated string buffer.
 */
enum { CELL_KEY_SIZE=6 };
stock void PackItem(any key, char buffer[CELL_KEY_SIZE]) {
	int k = key;
	buffer[0] = ((k >> (7 * 4)) & 0x7F) | 0x80;
	buffer[1] = ((k >> (7 * 3)) & 0x7F) | 0x80;
	buffer[2] = ((k >> (7 * 2)) & 0x7F) | 0x80;
	buffer[3] = ((k >> (7 * 1)) & 0x7F) | 0x80;
	buffer[4] = ((k >> (7 * 0)) & 0x7F) | 0x80;
	buffer[5] = 0x00;
}
stock char[] PackCellToStr(any key) {
	char pack[CELL_KEY_SIZE]; PackItem(key, pack);
	return pack;
}


stock void MakePawnTimer(Function func, float thinktime=0.1, const any[] args, int len, bool as_array=false) {
	DataPack thinkpack = new DataPack();
	thinkpack.WriteFunction(func);
	thinkpack.WriteCell(len);
	thinkpack.WriteCell(as_array);
	for( int i; i < len; i++ ) {
		thinkpack.WriteCell(args[i]);
	}
	CreateTimer(thinktime, RunPawnFunc, thinkpack, TIMER_DATA_HNDL_CLOSE);
}

public Action RunPawnFunc(Handle t, DataPack pack) {
	pack.Reset();
	Function fn = pack.ReadFunction();
	Call_StartFunction(null, fn);

	int len = pack.ReadCell();
	bool as_array = pack.ReadCell();
	if( as_array ) {
		any[] parms = new any[len];
		for( int i; i < len; i++ ) {
			parms[i] = pack.ReadCell();
		}
		Call_PushArray(parms, len);
	} else {
		for( int i; i < len; i++ ) {
			Call_PushCell(pack.ReadCell());
		}
	}
	Call_Finish();
	return Plugin_Continue;
}

/// useful for cooldowns.
/// Static Time, saves the current `GetGameTime`.
enum struct StaticTime {
	float t;
	void Update() {
		this.t = GetGameTime();
	}
	float Curr() {
		return this.t;
	}
	float Elapsed() {
		return GetGameTime() - this.t;
	}
	bool WithinTime(float delay_time) {
		return (GetGameTime() - this.t) <= delay_time;
	}
}

/// Forward Time, saves the current `GetGameTime` + delta value.
enum struct FwdTime {
	float t;
	void Update(float delta=1.0) {
		this.t = GetGameTime() + delta;
	}
	float Curr() {
		return this.t;
	}
	float Elapsed() {
		return this.t - GetGameTime();
	}
	bool WithinTime() {
		return GetGameTime() <= this.t;
	}
}


/// useful for cooldowns & stuff that happens in a certain period of time.
stock bool IsPastSavedTime(float last_time) {
	return( last_time > GetGameTime() );
}
stock bool IsWithinGoalTime(float goal_time) {
	return( GetGameTime() <= goal_time );
}
stock void UpdateSavedTime(float& last_time, float delta=1.0) {
	last_time = GetGameTime() + delta;
}

stock bool IsIntInBounds(int val, int max, int min) {
	return ((val - min) * (max - val)) >= 0;
}
stock int IntClamp(int val, int max, int min) {
	return (val < min)? min : (val > max)? max : val;
}


/**
 * Helper for preparing resources that are defined from a ConfigMap.
 *
 * @param sect:       ConfigMap of the section for the materials.
 * @param resrc_type: enum value marking what type of resource we're preparing.
 * @noreturn
 *
 * @note
 * the structure of the section must use "<enum>" keys.
 * example:
 * "sound section" {
 *     "<enum>"   "sound1.mp3"
 *     ...
 *     "<enum>"   "soundN.mp3"
 * }
 * "material section" {
 *     "<enum>"   "skinRed"
 *     ...
 *     "<enum>"   "skinBlu"
 * }
 */
stock void PrepareAssetsFromCfgMap(ConfigMap sect, int resrc_type) {
	if( sect==null ) {
		return;
	}
	
	int size = sect.Size;
	for( int i; i < size; i++ ) {
		int len = sect.GetIntKeySize(i);
		char[] str = new char[len];
		if( sect.GetIntKey(i, str, len) > 0 ) {
			switch( resrc_type ) {
				case ResourceSound:    PrepareSound(str);
				case ResourceModel:    PrepareModel(str);
				case ResourceMaterial: PrepareMaterial(str);
			}
		}
	}
}


public SharedPlugin __pl_vsh2 = {
	name = "VSH2",
	file = "vsh2.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_vsh2_SetNTVOptional() {
	MarkNativeAsOptional("VSH2_RegisterPlugin");
	MarkNativeAsOptional("VSH2_GetSharedMap");
	MarkNativeAsOptional("VSH2Player.VSH2Player");
	
	MarkNativeAsOptional("VSH2Player.userid.get");
	MarkNativeAsOptional("VSH2Player.index.get");
	
	MarkNativeAsOptional("VSH2Player.GetProperty");
	MarkNativeAsOptional("VSH2Player.SetProperty");
	
	MarkNativeAsOptional("VSH2Player.GetPropInt");
	MarkNativeAsOptional("VSH2Player.GetPropFloat");
	MarkNativeAsOptional("VSH2Player.GetPropAny");
	
	MarkNativeAsOptional("VSH2Player.SetPropInt");
	MarkNativeAsOptional("VSH2Player.SetPropFloat");
	MarkNativeAsOptional("VSH2Player.SetPropAny");
	MarkNativeAsOptional("VSH2Player.HasProp");
	
	MarkNativeAsOptional("VSH2Player.ConvertToMinion");
	MarkNativeAsOptional("VSH2Player.SpawnWeapon");
	MarkNativeAsOptional("VSH2Player.GetWeaponSlotIndex");
	MarkNativeAsOptional("VSH2Player.SetWepInvis");
	MarkNativeAsOptional("VSH2Player.SetOverlay");
	MarkNativeAsOptional("VSH2Player.TeleToSpawn");
	MarkNativeAsOptional("VSH2Player.IncreaseHeadCount");
	MarkNativeAsOptional("VSH2Player.SpawnSmallHealthPack");
	MarkNativeAsOptional("VSH2Player.ForceTeamChange");
	MarkNativeAsOptional("VSH2Player.ClimbWall");
	MarkNativeAsOptional("VSH2Player.HelpPanelClass");
	MarkNativeAsOptional("VSH2Player.GetAmmoTable");
	MarkNativeAsOptional("VSH2Player.SetAmmoTable");
	MarkNativeAsOptional("VSH2Player.GetClipTable");
	MarkNativeAsOptional("VSH2Player.SetClipTable");
	
	MarkNativeAsOptional("VSH2Player.GetHealTarget");
	MarkNativeAsOptional("VSH2Player.IsNearDispenser");
	MarkNativeAsOptional("VSH2Player.IsInRange");
	MarkNativeAsOptional("VSH2Player.RemoveBack");
	MarkNativeAsOptional("VSH2Player.FindBack");
	MarkNativeAsOptional("VSH2Player.ShootRocket");
	MarkNativeAsOptional("VSH2Player.Heal");
	MarkNativeAsOptional("VSH2Player.AddTempAttrib");
	
	MarkNativeAsOptional("VSH2Player.GiveAbility");
	MarkNativeAsOptional("VSH2Player.RemoveAbility");
	MarkNativeAsOptional("VSH2Player.HasAbility");
	MarkNativeAsOptional("VSH2Player.RemoveAllAbilities");
	MarkNativeAsOptional("VSH2Player.RunPreAbility");
	MarkNativeAsOptional("VSH2Player.RunPostAbility");
	
	MarkNativeAsOptional("VSH2Player.ConvertToBoss");
	MarkNativeAsOptional("VSH2Player.GiveRage");
	MarkNativeAsOptional("VSH2Player.MakeBossAndSwitch");
	MarkNativeAsOptional("VSH2Player.DoGenericStun");
	MarkNativeAsOptional("VSH2Player.StunPlayers");
	MarkNativeAsOptional("VSH2Player.StunBuildings");
	MarkNativeAsOptional("VSH2Player.RemoveAllItems");
	
	MarkNativeAsOptional("VSH2Player.GetName");
	MarkNativeAsOptional("VSH2Player.SetName");
	
	MarkNativeAsOptional("VSH2Player.SuperJump");
	MarkNativeAsOptional("VSH2Player.WeighDown");
	MarkNativeAsOptional("VSH2Player.PlayVoiceClip");
	MarkNativeAsOptional("VSH2Player.PlayMusic");
	MarkNativeAsOptional("VSH2Player.StopMusic");
	
	MarkNativeAsOptional("VSH2Player.TeleToRandomPlayer");
	MarkNativeAsOptional("VSH2Player.ChargedThink");
	
	
	MarkNativeAsOptional("VSH2_Hook");
	MarkNativeAsOptional("VSH2_HookEx");
	MarkNativeAsOptional("VSH2_Unhook");
	MarkNativeAsOptional("VSH2_UnhookEx");
	MarkNativeAsOptional("VSH2_GetMaxBosses");
	MarkNativeAsOptional("VSH2_GetRandomBossType");
	MarkNativeAsOptional("VSH2_GetBossIDs");
	MarkNativeAsOptional("VSH2_GetBossID");
	MarkNativeAsOptional("VSH2_GetBossNameByIndex");
	MarkNativeAsOptional("VSH2_StopMusic");
	MarkNativeAsOptional("VSH2_GetConfigMap");
	
	MarkNativeAsOptional("VSH2GameMode_GetProperty");
	MarkNativeAsOptional("VSH2GameMode_SetProperty");
	MarkNativeAsOptional("VSH2GameMode_HasProperty");
	MarkNativeAsOptional("VSH2GameMode_FindNextBoss");
	MarkNativeAsOptional("VSH2GameMode_GetRandomBoss");
	MarkNativeAsOptional("VSH2GameMode_GetBossByType");
	MarkNativeAsOptional("VSH2GameMode_CountMinions");
	MarkNativeAsOptional("VSH2GameMode_CountBosses");
	MarkNativeAsOptional("VSH2GameMode_GetTotalBossHealth");
	MarkNativeAsOptional("VSH2GameMode_SearchForItemPacks");
	MarkNativeAsOptional("VSH2GameMode_UpdateBossHealth");
	MarkNativeAsOptional("VSH2GameMode_GetBossType");
	MarkNativeAsOptional("VSH2GameMode_GetTotalRedPlayers");
	MarkNativeAsOptional("VSH2GameMode_GetHUDHandle");
	MarkNativeAsOptional("VSH2GameMode_GetBosses");
	MarkNativeAsOptional("VSH2GameMode_IsVSHMap");
	MarkNativeAsOptional("VSH2GameMode_GetFighters");
	MarkNativeAsOptional("VSH2GameMode_GetMinions");
	MarkNativeAsOptional("VSH2GameMode_GetQueue");
	MarkNativeAsOptional("VSH2GameMode_GetBossesByType");
}
#endif