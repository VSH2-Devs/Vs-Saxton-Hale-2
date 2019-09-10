#if defined _vsh2_included
	#endinput
#endif
#define _vsh2_included


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
	 * @return		
	 */
	public native any GetProperty(const char prop_name[64]);
	
	/**
	 * sets the property of the internal VSH2 methodmap
	 * NOTE: You can use this to create new properties which GetProperty can access!
	 * @param prop_name		name of the property you want to override data from (works like StringMap).
	 * @param value			data you want the property to hold.
	 * @noreturn
	 */
	public native void SetProperty(const char prop_name[64], any value);
	
	/** AVAILABLE PROPERTIES
	property int iQueue
	property int iPresetType
	property int iLives
	property int iState
	property int iDamage
	property int iAirDamage
	property int iSongPick
	property int iOwnerBoss
	property int iUberTarget	/// please use userid on this; convert to client index if you want but userid is safer
	property int bGlow	 /// use like a bool
	property bool bIsMinion
	property bool bInJump
	property float flGlowtime
	property float flLastHit
	property float flLastShot
	
	/// ALL PROPERTIES AFTER THIS COMMENT ONLY ACCOUNT FOR BOSSES BUT CAN STILL APPLY ON NON-BOSSES AND MINIONS ///
	property int iHealth
	property int iMaxHealth
	property int iType
	property int iClimbs
	property int iStabbed
	property int iMarketted
	property int iDifficulty
	property bool bUsedUltimate	/// Not an overwatch reference lol; purpose is for a use-once ability but you can reset it
	property float flSpeed   /// if you boss needs a set amount of speed, use this obviously
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
	public native void TeleToSpawn(int team=0);
	public native void IncreaseHeadCount();
	public native void SpawnSmallHealthPack(int ownerteam=0);
	public native void ForceTeamChange(const int team);
	public native void ClimbWall(const int weapon, const float upwardVel, const float health, const bool attackdelay);
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
	
	/// Boss oriented natives
	public native void ConvertToBoss();
	public native void GiveRage(const int damage);
	public native void MakeBossAndSwitch(const int type, const bool callEvent);
	public native void DoGenericStun(const float rageDist);
	public native void RemoveAllItems();
};


/**
 * Registers a plugin to be able to use VSH2's forwards
 * NOTE: The purpose of this native is to register boss subplugins, you don't need to register plugins to use forwards, simply hook what forward you need.
 * @param plugin_name			module name you want your calling plugin to be identified under
 * @return				integer of the plugin array index
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
	//OnHookSound,
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
	OnRedPlayerThink
};

/**
	IF YOU'RE USING THE HOOKING SYSTEM FOR A BOSS, YOU HAVE TO REGISTER YOUR PLUGIN WITH VSH2 BECAUSE YOU NEED THE MODULE INDEX TRACKED
*/

typeset VSH2HookCB {
	/**
		OnBossSelected
		OnBossThink
		OnBossModelTimer
		OnBossDeath
		OnBossEquipped
		OnBossInitialized
		OnMinionInitialized
		OnBossPlayIntro
		OnBossMedicCall
		OnBossTaunt
		OnVariablesReset
		OnPrepRedTeam
		OnRedPlayerThink
		OnLastPlayer - Player is a random boss in this case.
	*/
	function void (const VSH2Player Player);
	
	/**
		OnTouchPlayer - victim is boss, attacker is other player.
		OnBossJarated
		OnUberDeployed, OnUberLoop - Victim is medic, Attacker is uber target
	*/
	function void (const VSH2Player Victim, const VSH2Player Attacker);
	
	/// OnTouchBuilding
	function void (const VSH2Player Attacker, const int BuildingRef);
	
	/// OnBossKillBuilding
	function void (const VSH2Player Attacker, const int building, Event event);
	
	/// OnBossTakeDamage , OnBossDealDamage
	function Action (VSH2Player Victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom);
	
	/**
		OnPlayerKilled
		OnPlayerAirblasted - player is the airblaster
		OnPlayerHurt
	*/
	function void (const VSH2Player Player, const VSH2Player Victim, Event event);
	
	/// OnTraceAttack
	function void (const VSH2Player Victim, const VSH2Player attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup);
	
	/// OnMessageIntro
	function void (const VSH2Player Player, char message[512]);
	
	/**
		OnBossHealthCheck - bossBool determines if command user was the boss
		OnRoundEndInfo - bossBool determines if boss won the round
	*/
	function void (const VSH2Player Player, bool bossBool, char message[512]);
	
	/// OnMusic
	function void (char song[PLATFORM_MAX_PATH], float& time, const VSH2Player Player);
	
	/// OnControlPointCapped
	function void (char cappers[MAXPLAYERS+1], const int team);
	
	/// OnCallDownloads
	function void ();
	
	/// OnBossPickUpItem
	function void (const VSH2Player Player, const char item[64]);
	
	/// OnBossMenu
	function void (Menu& menu);
};

/// Use hooktype enum on these.
native void VSH2_Hook(const int callbacktype, VSH2HookCB callback);
native bool VSH2_HookEx(const int callbacktype, VSH2HookCB callback);

native void VSH2_Unhook(const int callbacktype, VSH2HookCB callback);
native bool VSH2_UnhookEx(const int callbacktype, VSH2HookCB callback);


native any VSH2GameMode_GetProperty(const char prop_name[64]);
native void VSH2GameMode_SetProperty(const char prop_name[64], any value);

/**	Available properties
property int iRoundState
property int iSpecial
property int iTotalMaxHealth
property int iTimeLeft
property int iRoundCount
property int iHealthChecks
property int iCaptures
property bool bSteam		- Only useable if SteamTools is enabled and used.
property bool bTF2Attribs	- Only useable if TF2Attributes is enabled and used
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
native void VSH2GameMode_SearchForItemPacks();
native void VSH2GameMode_UpdateBossHealth();
native void VSH2GameMode_GetBossType();
native int VSH2GameMode_GetTotalRedPlayers();
native Handle VSH2GameMode_GetHUDHandle();


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
public __pl_vsh2_SetNTVOptional()
{
	MarkNativeAsOptional("VSH2_RegisterPlugin");
	MarkNativeAsOptional("VSH2Player.VSH2Player");
	
	MarkNativeAsOptional("VSH2Player.userid.get");
	MarkNativeAsOptional("VSH2Player.index.get");
	
	MarkNativeAsOptional("VSH2Player.GetProperty");
	MarkNativeAsOptional("VSH2Player.SetProperty");
	
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
	
	MarkNativeAsOptional("VSH2_Hook");
	MarkNativeAsOptional("VSH2_HookEx");
	MarkNativeAsOptional("VSH2_Unhook");
	MarkNativeAsOptional("VSH2_UnhookEx");
	
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
}
#endif
