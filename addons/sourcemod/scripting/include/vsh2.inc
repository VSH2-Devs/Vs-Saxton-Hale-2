#if defined _vsh2_included
	#endinput
#endif
#define _vsh2_included

#include <tf2items_stocks>
#include <cfgmap>


#define MAXMESSAGE            512
#define MAX_PANEL_MSG         512
#define MAX_BOSS_NAME_SIZE    64

enum { /** VSH2 Round States */
	StateDisabled = -1,
	StateStarting = 0,
	StateRunning = 1,
	StateEnding = 2,
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
	VSH2_VOICE_BOSSENT = 1, /// use boss as entity to emit from.
	VSH2_VOICE_BOSSPOS = 2, /// use boss position for sound origin.
	VSH2_VOICE_TOALL = 4,   /// sound replay to each individual player.
	VSH2_VOICE_ALLCHAN = 8, /// if sound replay should use auto sound channel.
	VSH2_VOICE_ONCE = 16    /// play a clip once to all. (does not cancel out 'VSH2_VOICE_TOALL')
};

#define VSH2_VOICE_ALL     (VSH2_VOICE_BOSSENT|VSH2_VOICE_BOSSPOS|VSH2_VOICE_TOALL|VSH2_VOICE_ALLCHAN|VSH2_VOICE_ONCE)

/// For when boss does something like a superjump, etc.
#define VSH2_VOICE_ABILITY (VSH2_VOICE_BOSSENT|VSH2_VOICE_BOSSPOS|VSH2_VOICE_TOALL)

/// For when boss does something like rage or special ability.
#define VSH2_VOICE_RAGE    (VSH2_VOICE_BOSSENT|VSH2_VOICE_BOSSPOS|VSH2_VOICE_TOALL|VSH2_VOICE_ALLCHAN)

/// For when boss gets stabbed or goes on a killing spree.
#define VSH2_VOICE_SPREE   (0)
#define VSH2_VOICE_STABBED VSH2_VOICE_SPREE

/// For when boss loses, wins, or introduces themselves like the mentlegen they are.
#define VSH2_VOICE_WIN     (VSH2_VOICE_ONCE|VSH2_VOICE_ALLCHAN)
#define VSH2_VOICE_LOSE    VSH2_VOICE_WIN
#define VSH2_VOICE_INTRO   VSH2_VOICE_WIN

/// For when there's only one target left!
#define VSH2_VOICE_LASTGUY (VSH2_VOICE_BOSSPOS)


methodmap VSH2Player {
	/** [ C O N S T R U C T O R ]
	 * Constructs an instance of the BaseBoss internal methodmap
	 * @param index			index (or the userid) of a player
	 * @param userid		if using userid instead of player index, set this param to true
	 * @return			a player instance of the VSH2Player methodmap
	 */
	public native VSH2Player(const int index, bool userid=false);
	
	
	/** **** **** [ P R O P E R T I E S ] **** **** **/
	/**
	 * gets the userid of the vsh2 player instance
	 * @return			the bare player userid integer
	 */
	property int userid {
		public native get();
	}
	
	/**
	 * gets the index of the vsh2 player instance
	 * @return			the bare player index integer
	 */
	property int index {
		public native get();
	}
	
	/**
	 * sets the property of the internal VSH2 methodmap
	 * NOTE: You can use this to create new properties which GetProperty can access!
	 * @param prop_name		name of property you want to access data from.
	 * @param item			reference to use of the variable to overwrite with data from the property.
	 * @return		value as "any".
	 */
	#pragma deprecated Use GetPropInt, GetPropFloat, or GetPropAny instead.
	public native any GetProperty(const char prop_name[64]);
	
	/**
	 * sets the property of the internal VSH2 methodmap
	 * NOTE: You can use this to create new properties which GetProperty can access!
	 * @param prop_name		name of the property you want to override data from (works like StringMap).
	 * @param value			data you want the property to hold.
	 * @noreturn
	 */
	#pragma deprecated Use SetPropInt, SetPropFloat, or SetPropAny instead.
	public native void SetProperty(const char prop_name[64], any value);
	
	public native int GetPropInt(const char prop_name[64]);
	public native float GetPropFloat(const char prop_name[64]);
	public native any GetPropAny(const char prop_name[64]);
	
	public native bool SetPropInt(const char prop_name[64], int value);
	public native bool SetPropFloat(const char prop_name[64], float value);
	public native bool SetPropAny(const char prop_name[64], any value);
	
	/** AVAILABLE PROPERTIES
	 * int iQueue
	 * int iPresetType
	 * int iLives
	 * int iState
	 * int iDamage
	 * int iAirDamage
	 * int iSongPick
	 * int iClimbs
	
	* use 'hOwnerBoss' instead of this.
	 * int iOwnerBoss
	
	** please use userid on this; convert to client index if you want but userid is safer **
	* Use 'hUberTarget' property instead this
	 * int iUberTarget
	 * bool bIsMinion
	 * bool bInJump
	 * float flGlowtime
	 * float flLastHit
	 * float flLastShot
	
	** ALL PROPERTIES AFTER THIS COMMENT ONLY ACCOUNT FOR BOSSES BUT CAN STILL APPLY ON NON-BOSSES AND MINIONS **
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
	
	public native void ConvertToMinion(const float spawntime);
	public native int SpawnWeapon(char[] name, const int index, const int level, const int qual, char[] att);
	public native int GetWeaponSlotIndex(const int slot);
	public native void SetWepInvis(const int alpha);
	public native void SetOverlay(const char[] strOverlay);
	public native bool TeleToSpawn(int team=0);
	public native void IncreaseHeadCount();
	public native void SpawnSmallHealthPack(int ownerteam=0);
	public native void ForceTeamChange(const int team);
	public native bool ClimbWall(const int weapon, const float upwardVel, const float health, const bool attackdelay);
	public native void HelpPanelClass();
	public native int GetAmmoTable(const int wepslot);
	public native void SetAmmoTable(const int wepslot, const int amount);
	public native int GetClipTable(const int wepslot);
	public native void SetClipTable(const int wepslot, const int amount);
	
	public native int GetHealTarget();
	public VSH2Player GetHealPatient() {
		return VSH2Player(this.GetHealTarget());
	}
	
	public native bool IsNearDispenser();
	public native bool IsInRange(const int target, const float dist, bool pTrace=false);
	public bool IsPlayerInRange(VSH2Player target, const float dist, bool pTrace=false) {
		return this.IsInRange(target.index, dist, pTrace);
	}
	
	public int GetPlayersInRange(VSH2Player[] players, const float dist, bool trace=false) {
		int count;
		VSH2Player player;
		for( int i=MaxClients; i; --i ) {
			if( i <= 0 || i > MaxClients || !IsClientInGame(i) || !IsPlayerAlive(i) )
				continue;
			
			player = VSH2Player(i);
			if( player==this )
				continue;
			else if( this.IsInRange(i, dist, trace) )
				players[count++] = player;
		}
		return count;
	}
	
	public native void RemoveBack(int[] indices, const int len);
	public native int FindBack(int[] indices, const int len);
	public native int ShootRocket(bool bCrit=false, float vPosition[3], float vAngles[3], const float flSpeed, const float dmg, const char[] model, bool arc=false);
	public native void Heal(const int health, bool on_hud=false);
	
	/// Boss oriented methods
	public native void ConvertToBoss();
	public native void GiveRage(const int damage);
	public native void MakeBossAndSwitch(const int type, const bool callEvent);
	public native void DoGenericStun(const float rageDist);
	public native void StunPlayers(float rage_dist, float stun_time=5.0);
	public native void StunBuildings(float rage_dist, float sentry_stun_time=8.0);
	public native void RemoveAllItems(bool weps=true);
	
	public native bool GetName(char buffer[MAX_BOSS_NAME_SIZE]);
	public native bool SetName(const char name[MAX_BOSS_NAME_SIZE]);
	
	public native void SuperJump(const float power, const float reset);
	public native void WeighDown(const float reset);
	
	/** use the VSH2_VOICE_* flags above^^^. */
	public native void PlayVoiceClip(const char[] voiceclip, const int flags);
	
	public native void PlayMusic(const float vol=100.0, const char[] override="");
	public native void StopMusic();
	
	public void SpeedThink(const float iota, const float minspeed=100.0) {
		VSH2_SpeedThink(this, iota, minspeed);
	}
	public void GlowThink(const float decrease) {
		VSH2_GlowThink(this, decrease);
	}
	public bool SuperJumpThink(const float charging, const float jumpcharge) {
		return VSH2_SuperJumpThink(this, charging, jumpcharge);
	}
	public void WeighDownThink(const float weighdown_time, const float incr) {
		VSH2_WeighDownThink(this, weighdown_time, incr);
	}
};


/** Common Boss Think Mechanics
 * Made these because of how common these boss mechanics are used within VSH and FF2.
 * 
 * SpeedThink -> health-based speed where the less health the boss has, the faster they move.
 * GlowThink -> handles how long the boss will be visible through walls aka glowing.
 * SuperJumpThink -> handles superjump charging
 * WeighDownThink -> handles weighdown charging
 */

stock void VSH2_SpeedThink(VSH2Player boss, const float iota, const float minspeed=100.0) {
	float speed = iota + 0.7 * (100 - boss.iHealth * 100 / boss.GetPropInt("iMaxHealth"));
	SetEntPropFloat(boss.index, Prop_Send, "m_flMaxspeed", (speed < minspeed) ? minspeed : speed);
}

stock void VSH2_GlowThink(VSH2Player boss, const float decrease) {
	float glowtime = boss.GetPropFloat("flGlowtime");
	if( glowtime > 0.0 ) {
		SetEntProp(boss.index, Prop_Send, "m_bGlowEnabled", 1);
		boss.SetPropFloat("flGlowtime", glowtime - decrease);
	} else if( glowtime <= 0.0 )
		SetEntProp(boss.index, Prop_Send, "m_bGlowEnabled", 0);
}

stock bool VSH2_SuperJumpThink(VSH2Player boss, const float charging, const float jumpcharge) {
	int player = boss.index;
	int buttons = GetClientButtons(player);
	float charge = boss.GetPropFloat("flCharge");
	if( ((buttons & IN_DUCK) || (buttons & IN_ATTACK2)) && (charge >= 0.0) ) {
		if( charge + charging < jumpcharge )
			boss.SetPropFloat("flCharge", charge + charging);
		else boss.SetPropFloat("flCharge", jumpcharge);
	} else if( charge < 0.0 )
		boss.SetPropFloat("flCharge", charge + charging);
	else {
		float EyeAngles[3]; GetClientEyeAngles(player, EyeAngles);
		if( charge > 1.0 && EyeAngles[0] < -5.0 ) {
			return true;
		}
		else boss.SetPropFloat("flCharge", 0.0);
	}
	return false;
}

stock void VSH2_WeighDownThink(VSH2Player boss, const float weighdown_time, const float incr) {
	int player = boss.index;
	int buttons = GetClientButtons(player);
	int flags = GetEntityFlags(player);
	if( flags & FL_ONGROUND )
		boss.SetPropFloat("flWeighDown", 0.0);
	else boss.SetPropFloat("flWeighDown", boss.GetPropFloat("flWeighDown") + incr);
	
	if( (buttons & IN_DUCK) && boss.GetPropFloat("flWeighDown") >= weighdown_time ) {
		float ang[3]; GetClientEyeAngles(player, ang);
		if( ang[0] > 60.0 )
			boss.WeighDown(0.0);
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


enum { /// VSH2HookType
	OnCallDownloads=0,
	OnBossSelected,
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
	MaxVSH2Forwards
};

/**
 * IF YOU'RE USING THE HOOKING SYSTEM FOR A CUSTOM BOSS,
 * YOU HAVE TO REGISTER YOUR PLUGIN WITH VSH2 BECAUSE YOU NEED THE BOSS' INDEX TRACKED.
 */

typeset VSH2HookCB {
	/**
	 * OnBossSelected
	 * BossThink
	 * BossModelTimer
	 * BossDeath
	 * BossEquipped
	 * BossEquippedPost -> Action has no effect on this forward.
	 * BossInitialized
	 * BossPlayIntro
	 * BossMedicCall
	 * BossTaunt
	 * VariablesReset
	 * PrepRedTeam
	 * RedPlayerThink
	 * LastPlayer - Player is a random boss in this case.
	 * BossSuperJump
	 * BossWeighDown
	 * BossThinkPost -> Action has no effect on this forward.
	 */
	function Action (const VSH2Player player);
	function void (const VSH2Player player);
	
	/**
	 * TouchPlayer - victim is boss, attacker is other player.
	 * BossJarated
	 * UberDeployed - Victim is medic, Attacker (Check if valid) is uber target
	 * UberLoop - Victim is medic, Attacker (Check if valid) is uber target
	 * RPSTaunt - victim is loser, attacker is winner.
	 * MinionInitialized - victim is minion, attacker is the owner/master boss.
	 */
	function Action (const VSH2Player victim, const VSH2Player attacker);
	function void (const VSH2Player victim, const VSH2Player attacker);
	
	/// OnTouchBuilding
	function Action (const VSH2Player attacker, const int BuildingRef);
	function void (const VSH2Player attacker, const int BuildingRef);
	
	/// OnBossKillBuilding
	function Action (const VSH2Player attacker, const int building, Event event);
	function void (const VSH2Player attacker, const int building, Event event);
	
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
	function Action (const VSH2Player player, const VSH2Player victim, Event event);
	function void (const VSH2Player player, const VSH2Player victim, Event event);
	
	/// OnTraceAttack
	function Action (const VSH2Player victim, const VSH2Player attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup);
	function void (const VSH2Player victim, const VSH2Player attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup);
	
	/// OnMessageIntro
	function Action (const VSH2Player player, char message[MAXMESSAGE]);
	function void (const VSH2Player player, char message[MAXMESSAGE]);
	
	/**
	 * BossHealthCheck - bossBool determines if command user was the boss
	 * RoundEndInfo - bossBool determines if boss won the round
	 */
	function Action (const VSH2Player player, bool bossBool, char message[MAXMESSAGE]);
	function void (const VSH2Player player, bool bossBool, char message[MAXMESSAGE]);
	
	/// OnMusic
	function Action (char song[PLATFORM_MAX_PATH], float& time, const VSH2Player player);
	function void (char song[PLATFORM_MAX_PATH], float& time, const VSH2Player player);
	
	/// OnControlPointCapped
	function Action (char cappers[MAXPLAYERS+1], const int team);
	function void (char cappers[MAXPLAYERS+1], const int team);
	
	/// OnCallDownloads
	function Action ();
	function void ();
	
	/// OnBossPickUpItem -> player may or may not actually be a boss in this forward.
	function Action (const VSH2Player player, const char item[64]);
	function void (const VSH2Player player, const char item[64]);
	
	/// OnBossMenu
	function void (Menu& menu);
	function void (Menu& menu, const VSH2Player player);
	
	/// OnScoreTally
	function Action (const VSH2Player player, int& points_earned, int& queue_earned);
	function void (const VSH2Player player, int& points_earned, int& queue_earned);
	
	/// OnItemOverride
	function Action (const VSH2Player player, const char[] classname, int itemdef, Handle& item);
	function void (const VSH2Player player, const char[] classname, int itemdef, Handle& item);
	function Action (const VSH2Player player, const char[] classname, int itemdef, TF2Item& item);
	function void (const VSH2Player player, const char[] classname, int itemdef, TF2Item& item);
	
	/// OnBossDoRageStun
	function Action (const VSH2Player player, float& distance);
	function void (const VSH2Player player, float& distance);
	
	/// OnBossGiveRage
	function Action (const VSH2Player player, const int damage, float& calcd_rage);
	function void (const VSH2Player player, const int damage, float& calcd_rage);
	
	/// OnBossCalcHealth
	/**
	 * Exercise caution using this, multiple plugins could call and modify 'max_health'.
	 * It's preferred that you use/modify the 'iMaxHealth' property instead.
	 */
	function Action (const VSH2Player player, int& max_health, const int boss_count, const int red_players);
	function void (const VSH2Player player, int& max_health, const int boss_count, const int red_players);
	
	/// OnSoundHook
	function Action (const VSH2Player player, char sample[PLATFORM_MAX_PATH], int& channel, float& volume, int& level, int& pitch, int& flags);
	function void (const VSH2Player player, char sample[PLATFORM_MAX_PATH], int& channel, float& volume, int& level, int& pitch, int& flags);
	
	/// OnRoundStart
	function void (const VSH2Player[] bosses, const int boss_count, const VSH2Player[] red_players, const int red_count);
	
	/// OnHelpMenu
	function void (const VSH2Player player, Menu menu);
	
	/// OnHelpMenuSelect
	function void (const VSH2Player player, Menu menu, int selection);
	
	/// OnDrawGameTimer
	function Action (int& seconds);
	function void (int& seconds);
};

/// Use hooktype enum on these.
native void VSH2_Hook(const int callbacktype, VSH2HookCB callback);
native bool VSH2_HookEx(const int callbacktype, VSH2HookCB callback);

native void VSH2_Unhook(const int callbacktype, VSH2HookCB callback);
native bool VSH2_UnhookEx(const int callbacktype, VSH2HookCB callback);

native int VSH2_GetMaxBosses();
native int VSH2_GetRandomBossType(int[] boss_filter, int filter_size=0);

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
 * Stops the VSH2 background music at will.
 * @param reset_time: resets the music time so that 'OnMusic' hook can be called again.
 * @noreturn
 */
native void VSH2_StopMusic(bool reset_time=true);


/**
 * Game Mode Oriented stuff.
 */

methodmap VSHHealthBar {
	public VSHHealthBar() {
		int healthbar = FindEntityByClassname(-1, "monster_resource");
		if( healthbar == -1 ) {
			healthbar = CreateEntityByName("monster_resource");
			if( healthbar != -1 )
				DispatchSpawn(healthbar);
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
			int clamped = val;
			if( clamped>255 )
				clamped = 255;
			else if( clamped<0 )
				clamped = 0;
			SetEntProp(this.entity, Prop_Send, "m_iBossHealthPercentageByte", clamped);
		}
	}
	
	public void SetHealthPercent(int total_health, int total_max_health) {
		this.iPercent = RoundFloat(float(total_health) / float(total_max_health) * 255);
	}
};

native any VSH2GameMode_GetProperty(const char prop_name[64]);
native void VSH2GameMode_SetProperty(const char prop_name[64], any value);

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

/**
 * Available Properties:
 * int iRoundState
 * int iSpecial
 * int iTotalMaxHealth
 * int iTimeLeft
 * int iRoundCount
 * int iHealthChecks
 * int iCaptures
 * bool bSteam
 * bool bTF2Attribs
 * bool bPointReady
 * bool bMedieval
 * bool bDoors
 * bool bTeleToSpawn
 * float flHealthTime
 * float flMusicTime
 * VSH2Player hNextBoss
 */


native VSH2Player VSH2GameMode_FindNextBoss();
native VSH2Player VSH2GameMode_GetRandomBoss(const bool IsAlive);
native VSH2Player VSH2GameMode_GetBossByType(const bool IsAlive, const int BossType);

native int VSH2GameMode_CountMinions(const bool IsAlive);
native int VSH2GameMode_CountBosses(const bool IsAlive);
native int VSH2GameMode_GetTotalBossHealth();
native int VSH2GameMode_GetTotalRedPlayers();
native int VSH2GameMode_GetBosses(VSH2Player[] bosses, bool balive=true);
native int VSH2GameMode_GetFighters(VSH2Player[] redplayers, bool balive=true);
native int VSH2GameMode_GetMinions(VSH2Player[] minions, bool balive=true);
native int VSH2GameMode_GetBossesByType(VSH2Player[] bosses, const int type, bool balive=true);

/// has the `players` array sorted by DESCENDING order (first index is highest queue).
native int VSH2GameMode_GetQueue(VSH2Player[] players);

native void VSH2GameMode_SearchForItemPacks();
native void VSH2GameMode_UpdateBossHealth();
native void VSH2GameMode_GetBossType();

native Handle VSH2GameMode_GetHUDHandle();

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
	
	public static void SetProp(const char prop_name[64], any value) {
		VSH2GameMode_SetProperty(prop_name, value);
	}
	
	property VSHHealthBar hHealthBar {
		public get() {
			return VSH2GameMode.GetPropAny("iHealthBar");
		}
	}
	
	public static VSH2Player GetRandomBoss(const bool is_alive) {
		return VSH2GameMode_GetRandomBoss(is_alive);
	}
	public static VSH2Player GetBossByType(const bool is_alive, const int boss_type) {
		return VSH2GameMode_GetBossByType(is_alive, boss_type);
	}
	
	public static int CountMinions(const bool is_alive) {
		return VSH2GameMode_CountMinions(is_alive);
	}
	public static int CountBosses(const bool is_alive) {
		return VSH2GameMode_CountBosses(is_alive);
	}
	public static int GetBosses(VSH2Player[] bosses, bool balive=true) {
		return VSH2GameMode_GetBosses(bosses, balive);
	}
	public static int GetFighters(VSH2Player[] redplayers, bool balive=true) {
		return VSH2GameMode_GetFighters(redplayers, balive);
	}
	public static int GetMinions(VSH2Player[] minions, bool balive=true) {
		return VSH2GameMode_GetMinions(minions, balive);
	}
	public static int GetBossesByType(VSH2Player[] bosses, const int type, bool balive=true) {
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
};


/**
 * VSH2 Misc. Useful stocks.
 */
stock void CheckDownload(const char[] file)
{
	if( FileExists(file, true) )
		AddFileToDownloadsTable(file);
}

stock void PrepareSound(const char[] sound_path)
{
	PrecacheSound(sound_path, true);
	char s[PLATFORM_MAX_PATH];
	Format(s, sizeof(s), "sound/%s", sound_path);
	CheckDownload(s);
}

stock void DownloadSoundList(const char[][] file_list, int size)
{
	for( int i; i<size; i++ )
		PrepareSound(file_list[i]);
}

stock void PrecacheSoundList(const char[][] file_list, int size)
{
	for( int i; i<size; i++ )
		PrecacheSound(file_list[i], true);
}

stock void PrecacheScriptList(const char[][] file_list, int size)
{
	for( int i; i<size; i++ )
		PrecacheScriptSound(file_list[i]);
}

/// For single custom materials, omit file extensions as it prepares VMT + VTF
stock void PrepareMaterial(const char[] matpath)
{
	char s[PLATFORM_MAX_PATH];
	Format(s, sizeof(s), "%s%s", matpath, ".vtf");
	CheckDownload(s);
	Format(s, sizeof(s), "%s%s", matpath, ".vmt");
	CheckDownload(s);
}

stock void DownloadMaterialList(const char[][] file_list, int size)
{
	char s[PLATFORM_MAX_PATH];
	for( int i; i<size; i++ ) {
		strcopy(s, sizeof(s), file_list[i]);
		CheckDownload(s);
	}
}

/// For custom models, do NOT omit .MDL extension
stock int PrepareModel(const char[] model_path, bool model_only=false)
{
	char extensions[][] = { ".mdl", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd", ".phy" };
	char model_base[PLATFORM_MAX_PATH];
	char path[PLATFORM_MAX_PATH];
	
	strcopy(model_base, sizeof(model_base), model_path);
	SplitString(model_base, ".mdl", model_base, sizeof(model_base)); /// Kind of redundant, but eh.
	if( !model_only ) {
		for( int i; i<sizeof(extensions); i++ ) {
			Format(path, PLATFORM_MAX_PATH, "%s%s", model_base, extensions[i]);
			CheckDownload(path);
		}
	}
	else CheckDownload(model_path);
	return PrecacheModel(model_path, true);
}

/// Contributed by ScaleFace
stock bool IsStockSound(char sample[PLATFORM_MAX_PATH])
{
	char exclusions[][] = {
		"_pain","_medic","_battlecry","_pain","_auto","_activatecharge","_jeers","_cheers","_help",
		"_incoming","_goodjob","_head","_fight","_cloaked","_melee","_move","_positive","_negative","_need",
		"_nice","_thanks", "_yes","_no","_go","_sentry"
	};
	
	for( int i; i<sizeof(exclusions); i++ )
		if( StrContains(sample, exclusions[i], false) != -1 )
			return true;
	
	return false;
}

stock bool IsVoiceLine(char sample[PLATFORM_MAX_PATH])
{
	return !strncmp(sample, "vo", 2, false);
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
public void __pl_vsh2_SetNTVOptional()
{
	MarkNativeAsOptional("VSH2_RegisterPlugin");
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
	
	MarkNativeAsOptional("VSH2_Hook");
	MarkNativeAsOptional("VSH2_HookEx");
	MarkNativeAsOptional("VSH2_Unhook");
	MarkNativeAsOptional("VSH2_UnhookEx");
	MarkNativeAsOptional("VSH2_GetMaxBosses");
	MarkNativeAsOptional("VSH2_GetRandomBossType");
	MarkNativeAsOptional("VSH2_GetBossIDs");
	MarkNativeAsOptional("VSH2_GetBossID");
	MarkNativeAsOptional("VSH2_StopMusic");
	
	MarkNativeAsOptional("VSH2GameMode_GetProperty");
	MarkNativeAsOptional("VSH2GameMode_SetProperty");
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