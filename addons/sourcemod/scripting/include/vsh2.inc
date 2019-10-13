#if defined _vsh2_included
	#endinput
#endif
#define _vsh2_included


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

enum /** VSH2 Default Bosses */ {
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
	#pragma deprecated Use GetPropInt, GetPropFloat, or GetAnyProp instead.
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
	property int iQueue
	property int iPresetType
	property int iLives
	property int iState
	property int iDamage
	property int iAirDamage
	property int iSongPick
	property int iOwnerBoss
	
	** please use userid on this; convert to client index if you want but userid is safer **
	property int iUberTarget
	
	** use like a bool **
	property int bGlow
	
	property bool bIsMinion
	property bool bInJump
	property float flGlowtime
	property float flLastHit
	property float flLastShot
	
	** ALL PROPERTIES AFTER THIS COMMENT ONLY ACCOUNT FOR BOSSES BUT CAN STILL APPLY ON NON-BOSSES AND MINIONS **
	property int iHealth
	property int iMaxHealth
	property int iBossType
	property int iClimbs
	property int iStabbed
	property int iMarketted
	property int iDifficulty
	property bool bUsedUltimate
	property float flSpeed
	property float flCharge
	property float flRAGE
	property float flKillSpree
	property float flWeighDown
	*/
	
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
	public native bool IsNearDispenser();
	public native bool IsInRange(const int target, const float dist, bool pTrace=false);
	public native void RemoveBack(int[] indices, const int len);
	public native int FindBack(int[] indices, const int len);
	public native int ShootRocket(bool bCrit=false, float vPosition[3], float vAngles[3], const float flSpeed, const float dmg, const char[] model, bool arc=false);
	
	/// Boss oriented methods ///
	public native void ConvertToBoss();
	public native void GiveRage(const int damage);
	public native void MakeBossAndSwitch(const int type, const bool callEvent);
	public native void DoGenericStun(const float rageDist);
	public native void RemoveAllItems();
	
	public native bool GetName(const char buffer[MAX_BOSS_NAME_SIZE]);
	public native bool SetName(const char name[MAX_BOSS_NAME_SIZE]);
	
	public native void SuperJump(const float power, const float reset);
	public native void WeighDown(const float reset);
	
	/** use the VSH2_VOICE_* flags above^^^. */
	public native void PlayVoiceClip(const char[] voiceclip, const int flags);
};


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
	OnRedPlayerThink
};

/**
	IF YOU'RE USING THE HOOKING SYSTEM FOR A CUSTOM BOSS, YOU HAVE TO REGISTER YOUR PLUGIN WITH VSH2 BECAUSE YOU NEED THE MODULE INDEX TRACKED
*/

typeset VSH2HookCB {
	/**
		OnBossSelected
		OnBossThink
		OnBossModelTimer
		OnBossDeath
		OnBossEquipped
		OnBossInitialized
		OnBossPlayIntro
		OnBossMedicCall
		OnBossTaunt
		OnVariablesReset
		OnPrepRedTeam
		OnRedPlayerThink
		OnLastPlayer - Player is a random boss in this case.
		OnBossSuperJump
		OnBossWeighDown
	*/
	function Action (const VSH2Player player);
	function void (const VSH2Player player);
	
	/**
		OnTouchPlayer - victim is boss, attacker is other player.
		OnBossJarated
		OnUberDeployed - Victim is medic, Attacker (Check if valid) is uber target
		OnUberLoop - Victim is medic, Attacker (Check if valid) is uber target
		OnRPSTaunt - victim is loser, attacker is winner.
		OnMinionInitialized - victim is minion, attacker is the owner/master boss.
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
	 */
	function Action (VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom);
	
	/**
		OnPlayerKilled
		OnPlayerAirblasted - player is the airblaster
		OnPlayerHurt
	*/
	function Action (const VSH2Player player, const VSH2Player victim, Event event);
	function void (const VSH2Player player, const VSH2Player victim, Event event);
	
	/// OnTraceAttack
	function Action (const VSH2Player victim, const VSH2Player attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup);
	function void (const VSH2Player victim, const VSH2Player attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup);
	
	/// OnMessageIntro
	function Action (const VSH2Player player, char message[512]);
	function void (const VSH2Player player, char message[512]);
	
	/**
		OnBossHealthCheck - bossBool determines if command user was the boss
		OnRoundEndInfo - bossBool determines if boss won the round
	*/
	function Action (const VSH2Player player, bool bossBool, char message[512]);
	function void (const VSH2Player player, bool bossBool, char message[512]);
	
	/// OnMusic
	function Action (char song[PLATFORM_MAX_PATH], float& time, const VSH2Player player);
	function void (char song[PLATFORM_MAX_PATH], float& time, const VSH2Player player);
	
	/// OnControlPointCapped
	function Action (char cappers[MAXPLAYERS+1], const int team);
	function void (char cappers[MAXPLAYERS+1], const int team);
	
	/// OnCallDownloads
	function Action ();
	function void ();
	
	/// OnBossPickUpItem
	function Action (const VSH2Player player, const char item[64]);
	function void (const VSH2Player player, const char item[64]);
	
	/// OnBossMenu
	function void (Menu& menu);
	
	/// OnScoreTally
	function Action (const VSH2Player player, int& points_earned, int& queue_earned);
	function void (const VSH2Player player, int& points_earned, int& queue_earned);
	
	/// OnItemOverride
	function Action (const VSH2Player player, const char[] classname, int itemdef, Handle& item);
	function void (const VSH2Player player, const char[] classname, int itemdef, Handle& item);
	
	/// OnBossDoRageStun
	function Action (const VSH2Player player, float& distance);
	function void (const VSH2Player player, float& distance);
	
	/// OnBossGiveRage
	function Action (const VSH2Player player, const int damage, float& calcd_rage);
	function void (const VSH2Player player, const int damage, float& calcd_rage);
	
	/// OnBossCalcHealth
	function Action (const VSH2Player player, int& max_health, const int boss_count, const int red_players);
	function void (const VSH2Player player, int& max_health, const int boss_count, const int red_players);
};

/// Use hooktype enum on these.
native void VSH2_Hook(const int callbacktype, VSH2HookCB callback);
native bool VSH2_HookEx(const int callbacktype, VSH2HookCB callback);

native void VSH2_Unhook(const int callbacktype, VSH2HookCB callback);
native bool VSH2_UnhookEx(const int callbacktype, VSH2HookCB callback);

native int VSH2_GetMaxBosses();
native int VSH2_GetRandomBossType(int[] boss_filter, int filter_size=0);


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

/**	Available Properties:
property int iRoundState
property int iSpecial
property int iTotalMaxHealth
property int iTimeLeft
property int iRoundCount
property int iHealthChecks
property int iCaptures

** Only useable if SteamTools is enabled and used.
property bool bSteam

** Only useable if TF2Attributes is enabled and used.
property bool bTF2Attribs

property bool bPointReady
property bool bMedieval
property float flHealthTime
property float flMusicTime
property VSH2Player hNextBoss
*/

native VSH2Player VSH2GameMode_FindNextBoss();
native VSH2Player VSH2GameMode_GetRandomBoss(const bool IsAlive);
native VSH2Player VSH2GameMode_GetBossByType(const bool IsAlive, const int BossType);

native int VSH2GameMode_CountMinions(const bool IsAlive);
native int VSH2GameMode_CountBosses(const bool IsAlive);
native int VSH2GameMode_GetTotalBossHealth();
native int VSH2GameMode_GetTotalRedPlayers();
native int VSH2GameMode_GetBosses(VSH2Player[] bosses, bool balive);

native void VSH2GameMode_SearchForItemPacks();
native void VSH2GameMode_UpdateBossHealth();
native void VSH2GameMode_GetBossType();

native Handle VSH2GameMode_GetHUDHandle();

native bool VSH2GameMode_IsVSHMap();


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
	
	MarkNativeAsOptional("VSH2Player.ConvertToBoss");
	MarkNativeAsOptional("VSH2Player.GiveRage");
	MarkNativeAsOptional("VSH2Player.MakeBossAndSwitch");
	MarkNativeAsOptional("VSH2Player.DoGenericStun");
	MarkNativeAsOptional("VSH2Player.RemoveAllItems");
	
	MarkNativeAsOptional("VSH2Player.GetName");
	MarkNativeAsOptional("VSH2Player.SetName");
	
	MarkNativeAsOptional("VSH2Player.SuperJump");
	MarkNativeAsOptional("VSH2Player.WeighDown");
	MarkNativeAsOptional("VSH2Player.PlayVoiceClip");
	
	MarkNativeAsOptional("VSH2_Hook");
	MarkNativeAsOptional("VSH2_HookEx");
	MarkNativeAsOptional("VSH2_Unhook");
	MarkNativeAsOptional("VSH2_UnhookEx");
	MarkNativeAsOptional("VSH2_GetMaxBosses");
	MarkNativeAsOptional("VSH2_GetRandomBossType");
	
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
}
#endif
