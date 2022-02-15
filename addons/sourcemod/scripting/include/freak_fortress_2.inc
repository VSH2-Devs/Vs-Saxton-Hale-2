#include <sdktools>
#include <morecolors>
#tryinclude <tf2items>

#if defined _VSH2_FF2
	#endinput
#endif
#define _VSH2_FF2

#include <vsh2>

#if !defined FF2_USING_AUTO_PLUGIN__OLD

enum FF2CallType_t {
	CT_NONE          = 0b000000000, /// Inactive, default to CT_RAGE
	CT_LIFE_LOSS     = 0b000000001,
	CT_RAGE          = 0b000000010,
	CT_CHARGE        = 0b000000100,
	CT_UNUSED_DEMO   = 0b000001000, /// UNUSED
	CT_INACTIVE		 = CT_UNUSED_DEMO,
	CT_WEIGHDOWN     = 0b000010000,
	CT_PLAYER_KILLED = 0b000100000,
	CT_BOSS_KILLED   = 0b001000000,
	CT_BOSS_STABBED  = 0b010000000,
	CT_BOSS_MG       = 0b100000000,
};

enum FF2RageType_t {
	RT_RAGE = 0,
	RT_WEIGHDOWN,
	RT_CHARGE
};

#else

#define FF2CallType_t   int
#define FF2RageType_t	int

enum {
	CT_NONE          = 0b000000000, /// Inactive, default to CT_RAGE
	CT_LIFE_LOSS     = 0b000000001,
	CT_RAGE          = 0b000000010,
	CT_CHARGE        = 0b000000100,
	CT_UNUSED_DEMO   = 0b000001000, /// UNUSED
	CT_INACTIVE		 = CT_UNUSED_DEMO,
	CT_WEIGHDOWN     = 0b000010000,
	CT_PLAYER_KILLED = 0b000100000,
	CT_BOSS_KILLED   = 0b001000000,
	CT_BOSS_STABBED  = 0b010000000,
	CT_BOSS_MG       = 0b100000000,
};

enum {
	RT_RAGE = 0,
	RT_WEIGHDOWN,
	RT_CHARGE
};

enum {
	FF2FLAG_UBERREADY            = (1<<1),  /// Used when medic says "I'm charged!"
	FF2FLAG_ISBUFFED             = (1<<2),  /// Used when soldier uses the Battalion's Backup
	FF2FLAG_CLASSTIMERDISABLED   = (1<<3),  /// Used to prevent clients' timer
	FF2FLAG_HUDDISABLED          = (1<<4),  /// Used to prevent custom hud from clients' timer
	FF2FLAG_BOTRAGE              = (1<<5),  /// Used by bots to use Boss's rage
	FF2FLAG_TALKING              = (1<<6),  /// Used by Bosses with "sound_block_vo" to disable block for some lines
	FF2FLAG_ALLOWSPAWNINBOSSTEAM = (1<<7),  /// Used to allow spawn players in Boss's team
	FF2FLAG_USEBOSSTIMER         = (1<<8),  /// Used to prevent Boss's timer
	FF2FLAG_USINGABILITY         = (1<<9),  /// Used to prevent Boss's hints about abilities buttons
	FF2FLAG_CLASSHELPED          = (1<<10),
	FF2FLAG_HASONGIVED           = (1<<11),
	FF2FLAG_CHANGECVAR           = (1<<12), /// Used to prevent SMAC from kicking bosses who are using certain rages (NYI)
	FF2FLAG_ALLOW_HEALTH_PICKUPS = (1<<13), /// Used to prevent bosses from picking up health
	FF2FLAG_ALLOW_AMMO_PICKUPS   = (1<<14), /// Used to prevent bosses from picking up ammo
	FF2FLAG_ROCKET_JUMPING       = (1<<15), /// Used when a soldier is rocket jumping
	FF2FLAG_ALLOW_BOSS_WEARABLES = (1<<16), /// Used to allow boss having wearables (only for Official FF2)
	FF2FLAGS_SPAWN = ~FF2FLAG_UBERREADY
					& ~FF2FLAG_ISBUFFED
					& ~FF2FLAG_TALKING
					& ~FF2FLAG_ALLOWSPAWNINBOSSTEAM
					& ~FF2FLAG_CHANGECVAR
					& ~FF2FLAG_ROCKET_JUMPING
					& FF2FLAG_USEBOSSTIMER
					& FF2FLAG_USINGABILITY,
};


#endif

#define INVALID_FF2PLAYER    ToFF2Player(0)
#define ToFF2Player(%0)      view_as< FF2Player >(%0)
#define FF2_PREFIX           "{olive}[FF2]{default} "

enum {
	FF2_MAX_PLUGIN_NAME  = 64,   /// sizeof plugin_name
	FF2_MAX_ABILITY_NAME = 64,   /// sizeof ability_name
	FF2_MAX_ABILITY_KEY  = 64,   /// sizeof "ability*" key
};

enum { FF2_MAX_LIST_KEY = FF2_MAX_PLUGIN_NAME + FF2_MAX_ABILITY_NAME + 2 };		/// sizeof key in FF2AbilityList
enum { INVALID_FF2_BOSS_ID = -1 };	//Invalid VSH2 iBossType


enum struct FF2SoundIdentity {
	char path[PLATFORM_MAX_PATH];	///	full sound path
	float time;						/// 0.0, or song duration
	char name[32];					///	song name
	char artist[32];				///	song artist name

	int bit_slot;					/// sound slot property

	int channel;					/// sound channel, default to SNDCHAN_VOICE
	int flags;						///	sound flags, default to SND_CHANGEPITCH
	int level;						/// sound level, default to SNDLEVEL_TRAFFIC
	float volume;					/// sound volume, default = SNDVOL_NORMAL
	int pitch;						/// sound pitch, default to SNDPITCH_NORMAL

	bool IsSlotCompatible(FF2CallType_t slot) {
		return view_as<int>(slot) & this.bit_slot ? true : false;
	}
}

/**
 * Boss identity struct
 *
 * VSH2ID = iBossType
 * soundMap = map of precached sounds to use instead of iterating through ConfigMap.Snapshot()
 * abilityList = list of 'ConfigMap' that points to the ability section
 * name = boss config name in character.cfg
 */
enum struct FF2Identity {
	int				VSH2ID;
	ConfigMap		hCfg;
	StringMap		soundMap;
	ArrayList		abilityList;
	char			name[MAX_BOSS_NAME_SIZE];

	bool			isNewAPI;
	bool			isFound;

	void Release() {
		this.ReleaseSoundMap();
		this.ReleaseAbilityList();
		DeleteCfg(this.hCfg);
	}

	void ReleaseSoundMap() {
		if( !this.soundMap )
			return;
		StringMapSnapshot snap = this.soundMap.Snapshot();

		for( int i=this.soundMap.Size-1; i>=0; i-- ) {
			int len = snap.KeyBufferSize(i);
			char[] key = new char[len];
			snap.GetKey(i, key, len);

			ConfigMap cfg;
			this.soundMap.GetValue(key, cfg);
			DeleteCfg(cfg);
		}

		delete snap;
		delete this.soundMap;
	}

	void ReleaseAbilityList() {
		if( !this.abilityList )
			return;
		for( int i=this.abilityList.Length-1; i>=0; i-- ) {
			any cfg = this.abilityList.Get(i);
			DeleteCfg(view_as<ConfigMap>(cfg));
		}
		delete this.abilityList;
	}
}


/**
 * Some new properties:
 *
 * iLives
 * iMaxLives
 * bNoSuperJump
 * bNoWeighdown
 * bHideHUD
 * bSupressRAGE
 * bNotifySMAC_CVars
 * bNoCompanion
 * flWeighdownCd
 * iFlags
 */
methodmap FF2Player < VSH2Player {
	/** [ C O N S T R U C T O R ]
	 *
	 * Constructs an instance of the BaseBoss internal methodmap
	 *
	 * @param index			index (or the userid) of a player
	 * @param userid		if using userid instead of player index, set this param to true
	 *
	 * @return				a player instance of the FF2Player methodmap
	 */
	public native FF2Player(const int index, const bool userid = false);

	property bool Valid {
		public get() {
			return this != INVALID_FF2PLAYER && this.index > 0;
		}
	}

	property bool bIsBoss {
		public get() {
			return this.GetPropAny("bIsBoss");
		}
	}

	/**
	 * Retrieve an integer from boss config
	 *
	 * @param key_name		key name
	 *
	 * @return				true if key exists, false otherwise
	 */
	public native bool GetInt(const char[] key_name, int& res);

	/**
	 * Retrieve a float value from boss config
	 *
	 * @param key_name		key name
	 *
	 * @return				true if key exists, false otherwise
	 */
	public native bool GetFloat(const char[] key_name, float& res);

	/**
	 * Retrieve a string from boss config
	 *
	 * @param key_name		key name
	 * @param res			output buffer
	 * @param maxlen		size of output
	 *
	 * @return			true on sucess, false otherwise
	 */
	public native bool GetString(const char[] key_name, char[] res, int maxlen);

	/**
	 * Retrieve a ConfigMap section from boss config
	 *
	 * @param key_name		key name
	 *
	 * @return			a valid ConfigMap handle on success, null otherwis
	 * @note			the handle MUST be deleted with 'DeleteCfg()'
	 */
	public native ConfigMap GetSection(const char[] key_name);

	/**
	 * Gets the charge meter value of the Boss
	 *
	 * @param type		check FF2RageType_t enum value
	 *
	 * @return			charge meter value
	 */
	public float GetRageVar(FF2RageType_t type) {
		switch( type ) {
			case RT_RAGE: 		return this.GetPropFloat("flRAGE");
			case RT_CHARGE: 	return this.GetPropFloat("flCharge");
			case RT_WEIGHDOWN: 	return this.GetPropFloat("flWeighDown");
			default: {
				char key[64]; Format(key, sizeof(key), "flCharge%i", type);
				return this.GetPropFloat(key);
			}
		}
	}

	/**
	 * Sets the charge meter value of the Boss
	 *
	 * @param type		check FF2RageType_t enum value
	 * @param value		value to set
	 */
	public float SetRageVar(FF2RageType_t type, float val) {
		switch( type ) {
			case RT_RAGE: 		this.SetPropFloat("flRAGE", val);
			case RT_CHARGE: 	this.SetPropFloat("flCharge", val);
			case RT_WEIGHDOWN: 	this.SetPropFloat("flWeighDown", val);
			default: {
				char key[64]; Format(key, sizeof(key), "flCharge%i", type);
				this.SetPropFloat(key, val);
			}
		}
	}

	/**
	 * Gets boss' name in characters.cfg
	 *
	 * @param path			output buffer
	 * @param maxlen		size of output
	 */
	public native void GetConfigName(char[] path, int maxlen);

	/**
	 * Retrieve a boolean from boss ability
	 *
	 * @param pl_name		"plugin_name" instance
	 * @param ab_name		ability "name" instance
	 * @param key_name		key to extract
	 * @param defVal		default value if no matching key was found
	 *
	 * @return				the value stored in ability
	 */
	public native bool GetArgB(const char[] pl_name, const char[] ab_name, const char[] key_name, bool defVal = false);

	/**
	 * Retrieve an integer from boss ability
	 *
	 * @param pl_name		"plugin_name" instance
	 * @param ab_name		ability "name" instance
	 * @param key_name		key to extract
	 * @param defVal		default value if no matching key was found
	 *
	 * @return				the value stored in ability
	 */
	public native int GetArgI(const char[] pl_name, const char[] ab_name, const char[] key_name, int defVal = 0);

	/**
	 * Retrieve a float value from boss ability
	 *
	 * @param pl_name		"plugin_name" instance
	 * @param ab_name		ability "name" instance
	 * @param key_name		key to extract
	 * @param defVal		default value if no matching key was found
	 *
	 * @return				the value stored in ability
	 */
	public native float GetArgF(const char[] pl_name, const char[] ab_name, const char[] key_name, float defVal = 0.0);

	/**
	 * Retrieve a string from boss ability
	 *
	 * @param pl_name		"plugin_name" instance
	 * @param ab_name		ability "name" instance
	 * @param key_name		key to extract
	 * @param buffer		buffer to store the value
	 * @param maxlen		size of buffer
	 *
	 * @return				number of bytes written
	 */
	public native int GetArgS(const char[] pl_name, const char[] ab_name, const char[] key_name, char[] buffer, int maxlen);

	/**
	 * Checks if a boss has this ability
	 *
	 * @param pl_name		"plugin_name" instance
	 * @param ab_name		ability "name" instance
	 *
	 * @return				true on success, false otherwise
	 */
	public native bool HasAbility(const char[] pl_name, const char[] ab_name);

	/**
	 * Gets an ability's rage distance
	 *
	 * @param pl_name		"plugin_name" instance
	 * @param ab_name		ability "name" instance
	 *
	 * @return		Ability's rage distance
	 */
	public native float RageDist(const char[] pl_name = "", const char[] ab_name = "");

	/**
	 * Starts the Boss's music for the specified client
	 *
	 * @param path	path for music to play
	 */
	public native void PlayBGM(const char path[PLATFORM_MAX_PATH]);

	/**
	 * Forces boss to use an ability
	 *
	 * @param pluginName	Name of plugin with this ability
	 * @param abilityName 	Name of ability
	 * @param slot			check FF2CallType enums
	 *
	 * @note				this will NOT remove/reduce boss charge
	 */
	public native void DoAbility(const char[] pl_name, const char[] ab_name, FF2CallType_t slot);

	/**
	 * Forces boss to use every ability with
	 *
	 * @param slot		check FF2CallType enums
	 *
	 * @note				this will NOT remove/reduce boss charge
	 */
	public native void ForceAbility(FF2CallType_t slot);

	/**
	 * Starts a random Boss sound from its config file
	 *
	 * @param keyvalue		Name of sound container
	 * @param buffer		FF2SoundIdentity Buffer for results
	 * @param slot 			Only for "sound_ability" - slot of ability
	 *
	 * @return		True if sound has been found, false otherwise
	 */
	public native bool RandomSound(const char[] key_name, any[] snd_info, FF2CallType_t slot=view_as< FF2CallType_t >(2));
}


enum FF2GameModeQ_t {
	/// Fill the FF2Identity::hCfg struct
	FF2GAMEMODEQ_CONFIGMAP 	= 1 << 0,
	/// Fill the FF2Identity::soundMap
	FF2GAMEMODEQ_SOUNDMAP 	= 1 << 1,
	/// Fill the FF2Identity::abilityList
	FF2GAMEMODEQ_ABILITIES 	= 1 << 2,

	/// if it was set, and 'FF2GAMEMODEQ_BY_NAME' was set, fill the FF2Identity::VSH2ID else vise-versa
	FF2GAMEMODEQ_COPY_OTHER	= 1 << 3,
	/// if it was set, search the boss by FF2Identity::name, else search by FF2Identity::VSH2ID
	FF2GAMEMODEQ_BY_NAME	= 1 << 4,
}


/**
 * bPackSelected
 */
methodmap FF2GameMode < VSH2GameMode
{
	public FF2GameMode() { return view_as< FF2GameMode >(0); }

	public static native bool IsOn();

	public static native void PluginVersion(int ver[3]);

	public static native void ForkVersion(int fver[3]);

	public static void LogError(const char[] message, any ...) {
		char buffer[MAX_BUFFER_LENGTH];
		VFormat(buffer, sizeof(buffer), message, 2);
		LogError(buffer);
	}

	public static void ReportError(FF2Player player = INVALID_FF2PLAYER, const char[] message, any ...) {
		char name[MAX_BOSS_NAME_SIZE] = "Unknown";
		if( player.Valid ) {
			if( !player.GetName(name) )
				name = "Unknown";
		}

		char buffer[PLATFORM_MAX_PATH];
		VFormat(buffer, sizeof(buffer), message, 3);

		LogError("[VSH2/FF2] Exception reported: Boss: %i - Name: %s", player, name);
		LogError("[VSH2/FF2] %s", buffer);
	}

	public static native bool Cheats(bool change = false, bool stat = false);

	/**
	* Get boss information by 'FF2GameModeQ_t'
	* identity is enum struct of type 'FF2Identity'
	*/
	public static native void QueryBoss(any[] identity, FF2GameModeQ_t qinfo);

	public static native bool LoadAbility(const char[] plugin_name);

	public static native StringMap SubPlugins();

	property bool FF2IsOn {
		public get() { return LibraryExists("VSH2") && FF2GameMode.IsOn(); }
	}

	property int RoundState {
		public get() { return VSH2GameMode.GetPropInt("iRoundState"); }
	}

	/**
	 * Check if player is a FF2 boss
	 */
	public static native bool Validate(const VSH2Player player);

	/**
	 * Register a boss as an FF2's boss instead of VSH2
	 *
	 * An external FF2 boss is required to have a freak_fortress_2 config file, but it can also use it's own config similar to how vsh2 does it
	 * To obtain an freak_fortress_2 config, use FF2GameMode.QueryBoss() function
	 * Registering will allow automatically manage boss' hooks
	 */
	public static native int RegisterPlugin(const VSH2Player player);
}


/** Stocks for backward compatibility */
/** All of them are redundant and provides overhead, you should not use them if you're making a subplugin for VSH2-FF2 */

/**
 * Is Freak Fortress 2 enabled?
 *
 * @return		False if FF2 is disabled, true otherwise
 */
stock bool FF2_IsFF2Enabled()
{
	FF2GameMode gm;
	return gm.FF2IsOn;
}

/**
 * Gets the version of FF2 running on the server
 *
 * @param version	An array of size 3 that will contain the major, minor, and stable version numbers respectively
 */
stock void FF2_GetFF2Version(int version[3])
{
	if( FF2GameMode.IsOn() )
		FF2GameMode.PluginVersion(version);
}

/**
 * Gets the version of the FF2 fork running on the server
 *
 * @note		Official FF2 versions always return 0 for version numbers
 *
 * @param version	An array of size 3 that will contain the major, minor, and stable version numbers respectively
 *
 * @return		true if the plugin is running on beta version, false otherwise
 */
stock bool FF2_GetForkVersion(int version[3])
{
	return FF2GameMode.IsOn() && FF2GameMode.ForkVersion(version);
}

/**
 * Gets current round state
 *
 * @return		0 - in setup
 *			1 - round is in progress (due to a bug in arena mode, stalemate will also return 1)
 *			2 - someone wins
 */
stock int FF2_GetRoundState()
{
	return FF2GameMode.IsOn() && VSH2GameMode.GetPropInt("iRoundState");
}

static FF2Player FF2_ZeroBossToFF2Player()
{
	FF2Player[] players = new FF2Player[MaxClients];
	return VSH2GameMode.GetBosses(ToFF2Player(players), false) < 1 ? INVALID_FF2PLAYER : players[0];
}

/**
 * Gets UserID of current Boss
 * Redundant, use FF2Player if compiling for VSH2
 *
 * @param boss		Boss's index
 *
 * @return		Userid of boss (-1 if Boss does not exist)
 */
stock int FF2_GetBossUserId(int boss=0)
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	return ( player && player.bIsBoss ) ? player.userid:-1;
}

/**
 * Gets the boss index of a client
 * Redundant, use FF2Player if compiling for VSH2
 *
 * @param client	The client used to search for the boss index
 *
 * @return		Boss index of that client.  If client is not boss, returns -1
 */
stock int FF2_GetBossIndex(int client)
{
	FF2Player player = FF2Player(client);
	return ( player && player.Valid ) && player.bIsBoss ? client:-1;
}

/**
 * Gets current team of Boss
 *
 * @return		boss' team index
 */
stock int FF2_GetBossTeam()
{
	return VSH2Team_Boss;
}

/**
 * Gets the character name of the Boss
 *
 * @param boss	 		Boss's index
 * @param buffer		Buffer for boss' character name
 * @param bufferLength		Length of buffer string
 * @param bossMeaning			0 - "boss" parameter means index of current Boss
 *					1 - "boss" parameter means number of Boss in characters.cfg
 *
 * @return			True if boss exists, false if not
 */
stock bool FF2_GetBossSpecial(int boss=0, char[] buffer, int bufferLength, int bossMeaning=0)
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	if( !player.Valid || !player.bIsBoss )
		return false;

	if( bossMeaning ) {
		player.GetConfigName(buffer, bufferLength);
	}
	else {
		char name[MAX_BOSS_NAME_SIZE];
		player.GetName(name);
		strcopy(buffer, bufferLength, name);
	}
	return true;
}

/**
 * Gets the current health value of the Boss
 *
 * @param boss		Boss's index
 *
 * @return		Current health of the Boss
 */
stock int FF2_GetBossHealth(int boss=0)
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	return ( player && player.bIsBoss ) ? player.GetPropInt("iHealth"):0;
}

/**
 * Sets the health of the Boss
 *
 * @param boss		Boss's index
 * @param health	New health value
 */
stock void FF2_SetBossHealth(int boss, int health)
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	if( player && player.bIsBoss ) {
		player.SetPropInt("iHealth", health);
	}
}

/**
 * Gets the max health of the Boss
 *
 * @param boss		Boss's index
 *
 * @error		Invalid boss index
 *
 * @return		Max health of the Boss
 */
stock int FF2_GetBossMaxHealth(int boss=0)
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	return ( player && player.bIsBoss ) ? player.GetPropInt("iMaxHealth"):0;
}

/**
 * Sets the max health of the Boss
 *
 * @param boss		Boss's index
 * @param health	New max health value
 */
stock void FF2_SetBossMaxHealth(int boss, int health)
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	if( player && player.bIsBoss ) {
		player.SetPropInt("iMaxHealth", health);
	}
}

/**
 * Gets the current number of lives of the Boss
 *
 * @param boss		Boss's index
 *
 * @return 		Number of lives the boss has remaining
 */
stock int FF2_GetBossLives(int boss)
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	return ( player && player.bIsBoss ) ? player.GetPropInt("iLives"):0;
}

/**
 * Sets the current number of lives of the Boss
 *
 * @param boss		Boss's index
 * @param lives		New number of lives
 */
stock void FF2_SetBossLives(int boss, int lives)
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	if( player && player.bIsBoss ) {
		player.SetPropInt("iLives", lives);
	}
}

/**
 * Gets the max number of lives of the Boss
 *
 * @param boss		Boss's index
 *
 * @return		Max number of lives of the Boss
 */
stock int FF2_GetBossMaxLives(int boss)
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	return ( player && player.bIsBoss ) ? player.GetPropInt("iMaxLives"):0;
}

/**
 * Sets the max number of lives of the Boss
 *
 * @param boss		Boss's index
 * @param lives		New max number of lives
 */
stock void FF2_SetBossMaxLives(int boss, int lives)
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	if( player && player.bIsBoss ) {
		player.SetPropInt("iMaxLives", lives);
	}
}

/**
 * Gets the charge meter value of the Boss
 *
 * @param type		check FF2RageType_t enum value
 *
 * @return			charge meter value
 */
stock float FF2_GetBossCharge(int boss, int slot)
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	return ( player && player.bIsBoss ) ? player.GetRageVar(view_as<FF2RageType_t>(slot)):0.0;
}

/**
 * Sets the charge meter value of the Boss
 *
 * @param type		check FF2RageType_t enum value
 * @param value		value to se
 */
stock void FF2_SetBossCharge(int boss, int slot, float value)
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	if( player && player.bIsBoss ) {
		player.SetRageVar(view_as<FF2RageType_t>(slot), value);
	}
}

/**
 * Gets damage dealt by this client
 *
 * @param client 	Client's index
 *
 * @return		Damage dealt
 */
stock int FF2_GetClientDamage(int client)
{
	FF2Player player = FF2Player(client);
	return player ? player.GetPropInt("iDamage"):0;
}

/**
 * Gets damage dealt by this client
 *
 * @param client 	Client's index
 */
stock void FF2_SetClientDamage(int client, int damage)
{
	FF2Player player = FF2Player(client);
	if( player ) {
		player.SetPropInt("iDamage", damage);
	}
}

/**
 * Gets an ability's rage distance
 *
 * @param boss		Boss's index
 * @param pluginName	Name of plugin with this ability
 * @param abilityName	Name of ability (use an empty string if you want get boss's global "ragedist" value)
 *
 * @return		Ability's rage distance
 */
stock float FF2_GetRageDist(int boss=0, const char[] pluginName="", const char[] abilityName="")
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	return ( player && player.bIsBoss ) ? player.RageDist(pluginName, abilityName):0.0;
}

/**
 * Finds if a Boss has a certain ability
 *
 * @param boss		Boss's index
 * @param pluginName	Name of plugin with this ability
 * @param abilityName 	Name of ability
 *
 * @error		Invalid boss index
 *
 * @return		True if the boss has this ability, false if it doesn't
 */
stock bool FF2_HasAbility(int boss, const char[] pluginName, const char[] abilityName)
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	return ( player && player.bIsBoss ) ? player.HasAbility(pluginName, abilityName):false;
}

/**
	 * Forces boss to use an ability
	 *
	 * @param boss		Boss's index
	 * @param pluginName	Name of plugin with this ability
	 * @param abilityName Name of ability
	 * @param slot		check FF2CallType enums
	 *
	 * @note				this will NOT remove/reduce boss charge
	 */
stock void FF2_DoAbility(int boss, const char[] pluginName, const char[] abilityName, int slot)
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	if( player && player.bIsBoss ) {
		player.DoAbility(pluginName, abilityName, view_as< FF2CallType_t >(slot));
	}
}

/**
 * Gets the integer value of an ability argument
 *
 * @param boss		Boss's index
 * @param pluginName	Name of plugin with this ability
 * @param abilityName 	Name of ability
 * @param argument 	Number of argument
 * @param defValue 	Returns if argument is not defined
 *
 * @return		Value of argument
 */
stock int FF2_GetAbilityArgument(int boss, const char[] plugin_name, const char[] ability_name, int argument, int defValue=0)
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	if( player && player.bIsBoss ) {
		char arg_[8];
		FormatEx(arg_, sizeof(arg_), "arg%i", argument);
		return player.GetArgI(plugin_name, ability_name, arg_, defValue);
	}
	else return defValue;
}

/**
 * Gets the float value of an ability argument
 *
 * @param boss		Boss's index
 * @param pluginName	Name of plugin with this ability
 * @param abilityName 	Name of ability
 * @param argument 	Number of argument
 * @param defValue 	Returns if argument is not defined
 *
 * @error		Invalid boss index
 *
 * @return		Value of argument
 */
stock float FF2_GetAbilityArgumentFloat(int boss, const char[] plugin_name, const char[] ability_name, int argument, float defValue=0.0)
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	if( player && player.bIsBoss ) {
		char arg_[8];
		FormatEx(arg_, sizeof(arg_), "arg%i", argument);
		return player.GetArgF(plugin_name, ability_name, arg_, defValue);
	}
	else return defValue;
}

/**
 * Gets the string value of an ability argument
 *
 * @param boss		Boss's index
 * @param pluginName	Name of plugin with this ability
 * @param abilityName 	Name of ability
 * @param argument 	Number of argument
 * @param buffer 	Buffer for value of argument
 * @param bufferLength	Length of buffer string
 *
 * @error		Invalid boss index
 */
stock void FF2_GetAbilityArgumentString(int boss, const char[] pluginName, const char[] abilityName, int argument, char[] buffer, int bufferLength)
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	if( player && player.bIsBoss ) {
		char arg_[8];
		FormatEx(arg_, sizeof(arg_), "arg%i", argument);
		player.GetArgS(pluginName, abilityName, arg_, buffer, bufferLength);
	}
}

/**
 * Gets the integer value of a named ability argument
 *
 * @param boss		Boss's index
 * @param pluginName	Name of plugin with this ability
 * @param abilityName 	Name of ability
 * @param argument 	Argument name
 * @param defValue 	Returns if argument is not defined
 *
 * @error		Invalid boss index
 *
 * @return		Value of argument
 */
stock int FF2_GetArgNamedI(int boss, const char[] pluginName, const char[] abilityName, const char[] argument, int defValue=0)
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	if( player && player.bIsBoss ) {
		return player.GetArgI(pluginName, abilityName, argument, defValue);
	}
	else return defValue;
}

/**
 * Gets the float value of a named ability argument
 *
 * @param boss		Boss's index
 * @param pluginName	Name of plugin with this ability
 * @param abilityName 	Name of ability
 * @param argument 	Argument name
 * @param defValue 	Returns if argument is not defined
 *
 * @error		Invalid boss index
 *
 * @return		Value of argument
 */
stock float FF2_GetArgNamedF(int boss, const char[] pluginName, const char[] abilityName, const char[] argument, float defValue=0.0)
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	if( player && player.bIsBoss ) {
		return player.GetArgF(pluginName, abilityName, argument, defValue);
	}
	else return defValue;
}

/**
 * Gets the string value of a named ability argument
 *
 * @param boss		Boss's index
 * @param pluginName	Name of plugin with this ability
 * @param abilityName 	Name of ability
 * @param argument 	Argument name
 * @param buffer 	Buffer for value of argument
 * @param bufferLength	Length of buffer string
 */
stock void FF2_GetArgNamedS(int boss, const char[] pluginName, const char[] abilityName, const char[] argument, char[] buffer, int bufferLength)
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	if( player && player.bIsBoss ) {
		player.GetArgS(pluginName, abilityName, argument, buffer, bufferLength);
	}
}

/**
 * Starts a random Boss sound from its config file
 *
 * @param keyvalue		Name of sound container
 * @param buffer		Buffer for result sound path
 * @param bufferLength	Length of buffer
 * @param boss			Boss's index
 * @param slot 			Only for "sound_ability" - slot of ability
 *
 * @return		True if sound has been found, false otherwise
 */
stock bool FF2_RandomSound(const char[] keyvalue, char[] buffer, int bufferLength, int boss=0, int slot=0)
{
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	if( !(player && player.bIsBoss) ) {
		return false;
	}
	FF2SoundIdentity info;
	int first_underscore = FindCharInString(keyvalue, '_') + 1;
	if( !player.RandomSound(keyvalue[first_underscore], info, FF2_OldNumToBitSlot(slot)) ) {
		return false;
	}
	return strcopy(buffer, bufferLength, info.path) > 0;
}

/**
 * Starts the Boss's music for the specified clients
 *
 * @param client	Client's index (0 for all clients)
 * @param bgm		music path
 */
stock void FF2_StartMusic(int client = 0, const char bgm[PLATFORM_MAX_PATH] = "")
{
	if( !client ) {
		for( int i = 1; i <= MaxClients; i++ ) {
			if( IsClientInGame(i) ) {
				FF2Player(i).PlayBGM(bgm);
			}
		}
	}
	else {
		FF2Player player = FF2Player(client);
		if( player.Valid ) {
			player.PlayBGM(bgm);
		}
	}
}

/**
 * Stops the Boss's music for the specified clients
 *
 * @param client	Client's index (0 for all clients)
 */
stock void FF2_StopMusic(int client=0)
{
	if( !client ) {
		for( int i = 1; i <= MaxClients; i++ ) {
			if( IsClientInGame(i) ) {
				FF2Player(i).StopMusic();
			}
		}
	}
	else {
		FF2Player player = FF2Player(client);
		if( player.index ) {
			player.StopMusic();
		}
	}
}

/**
 * Gets a Boss's KV handle
 *
 * @return 		null
 */
#pragma deprecated Use FF2Player methodmaps
stock Handle FF2_GetSpecialKV(int boss, int specialIndex=0)
{
	return null;
}

/**
 * Gets a client's flags for FF2
 *
 * @param client	Client's index
 *
 * @return		Client's FF2 flags
 */
stock int FF2_GetFF2flags(int client)
{
#if defined FF2_USING_AUTO_PLUGIN__OLD
	#warning Using this function might have undesired behaviours, such as some flags might not be set. Use FF2Player.GetProp[Int, Float, Any] instead.
#endif

	FF2Player player = FF2Player(client);
	if( !player.Valid ) {
		return 0;
	}
	int flags = player.GetPropInt("iFlags");

	/// The most commonly used flags:
	/// https://github.com/VSH2-Devs/Vs-Saxton-Hale-2/blob/develop/addons/sourcemod/scripting/modules/ff2/vsh2_bridge.sp#L276
	if (player.GetPropInt("bHideHUD"))
		flags |= (1<<4) /* FF2FLAG_HUDDISABLED */;
	else
		flags &= ~(1<<4) /* FF2FLAG_HUDDISABLED */;

	/// https://github.com/VSH2-Devs/Vs-Saxton-Hale-2/wiki/VSH-2-Internal-API-Reference#general-boss-and-player-api-modulesbasesp
	if (player.GetPropInt("bIsMinion"))
		flags |= (1<<7) /* FF2FLAG_ALLOWSPAWNINBOSSTEAM */;
	else
		flags &= ~(1<<7) /* FF2FLAG_ALLOWSPAWNINBOSSTEAM */;

	/// https://github.com/VSH2-Devs/Vs-Saxton-Hale-2/blob/develop/addons/sourcemod/scripting/freak_fortress_2.sp#L164
	if (player.GetPropInt("bNotifySMAC_CVars"))
		flags |= (1<<12) /* FF2FLAG_CHANGECVAR */;
	else
		flags &= ~(1<<12) /* FF2FLAG_CHANGECVAR */;

	/// requires https://github.com/01Pollux/FF2-Library/blob/VSH2/addons/sourcemod/scripting/ff2_nopacks.sp
	if (player.GetPropInt("bNoHealthPacks"))
		flags &= ~(1<<13) /* FF2FLAG_ALLOW_HEALTH_PICKUPS */;
	else
		flags |= (1<<13) /* FF2FLAG_ALLOW_HEALTH_PICKUPS */;

	/// requires https://github.com/01Pollux/FF2-Library/blob/VSH2/addons/sourcemod/scripting/ff2_nopacks.sp
	if (player.GetPropInt("bNoAmmoPacks"))
		flags &= ~(1<<14) /* FF2FLAG_ALLOW_AMMO_PICKUPS */;
	else
		flags |= (1<<14) /* FF2FLAG_ALLOW_AMMO_PICKUPS */;

	return flags;
}

/**
 * Sets a client's flags for FF2
 *
 * @param client	Client's index
 * @param flags		New flag values
 */
stock void FF2_SetFF2flags(int client, int flags)
{
#if defined FF2_USING_AUTO_PLUGIN__OLD
	#warning Using this function might have undesired behaviours, such as some flags might not be set. Use FF2Player.GetProp[Int, Float, Any] instead.
#endif

	FF2Player player = FF2Player(client);
	if( !player.Valid ) {
		return;
	}

	/// The most commonly used flags:
	/// https://github.com/VSH2-Devs/Vs-Saxton-Hale-2/blob/develop/addons/sourcemod/scripting/modules/ff2/vsh2_bridge.sp#L276
	player.SetPropInt("bHideHUD", (flags & (1<<4) /* FF2FLAG_HUDDISABLED */) ? 1 : 0);

	/// https://github.com/VSH2-Devs/Vs-Saxton-Hale-2/wiki/VSH-2-Internal-API-Reference#general-boss-and-player-api-modulesbasesp
	player.SetPropInt("bIsMinion", (flags & (1<<7) /* FF2FLAG_ALLOWSPAWNINBOSSTEAM */) ? 1 : 0);

	/// https://github.com/VSH2-Devs/Vs-Saxton-Hale-2/blob/develop/addons/sourcemod/scripting/freak_fortress_2.sp#L164
	player.SetPropInt("bNotifySMAC_CVars", (flags & (1<<12) /* FF2FLAG_CHANGECVAR */) ? 1 : 0);

	/// requires https://github.com/01Pollux/FF2-Library/blob/VSH2/addons/sourcemod/scripting/ff2_nopacks.sp
	player.SetPropInt("bNoHealthPacks", (flags & (1<<13) /* FF2FLAG_ALLOW_HEALTH_PICKUPS */) ? 0 : 1);

	/// requires https://github.com/01Pollux/FF2-Library/blob/VSH2/addons/sourcemod/scripting/ff2_nopacks.sp
	player.SetPropInt("bNoAmmoPacks", (flags & (1<<14) /* FF2FLAG_ALLOW_AMMO_PICKUPS */) ? 0 : 1);

	player.SetPropInt("iFlags", flags);
}

/**
 * Gets a client's queue points
 *
 * @param client	Client's index
 *
 * @error		Invalid client index
 *
 * @return		Client's queue points, -999 if client is not valid
 */
stock int FF2_GetQueuePoints(int client)
{
	FF2Player player = ToFF2Player(client);
	return player.Valid ? player.GetPropInt("iQueue"):-999;
}

/**
 * Sets a client's queue points
 *
 * @param client	Client's index
 * @param value		New value of client's queue points
 *
 * @error		Invalid client index
 */
stock void FF2_SetQueuePoints(int client, int value)
{
	FF2Player player = FF2Player(client);
	if( player.Valid ) {
		player.SetPropInt("iQueue", value);
	}
}

/**
 * Gets a client's glow timer
 *
 * @param client	Client's index
 *
 * @return			Glow time
 */
stock float FF2_GetClientGlow(int client)
{
	FF2Player player = FF2Player(client);
	if( !player.Valid )
		return -1.0;

	if( !GetEntProp(player.index, Prop_Send, "m_bGlowEnabled") )
		return -1.0;

	return (player.GetPropFloat("flGlowtime"));
}

/**
 * Sets a client's glow timer
 *
 * @param client	Client's index
 * @param time1		Number of seconds to add to the glow timer (can be negative)
 * @param time2		New value of glow timer
 */
stock void FF2_SetClientGlow(int client, float time1, float time2=-1.0)
{
	FF2Player player = FF2Player(client);
	if( !player.Valid )
		return;

	if( time2 > 0.0 )
		player.SetPropFloat("flGlowtime", time2);
	else {
		player.SetPropFloat("flGlowtime", player.GetPropFloat("flGlowtime") + time1);
	}
}

/**
 * Reports an error to FF2's error log
 *
 * @param message	Message to error log
 */
stock void FF2_LogError(const char[] message, any ...)
{
	int len = PLATFORM_MAX_PATH + strlen(message);
	char[] err = new char[len];
	VFormat(err, len, message, 2);
	FF2GameMode.LogError(err);
}

/**
 * Reports an error to FF2's error log with boss name
 *
 * @param boss		Boss index
 * @param message	Message to error log
 *
 * @error 			failed to format
 */
stock void FF2_ReportError(const FF2Player boss = INVALID_FF2PLAYER, const char[] message, any ...)
{
	int len = PLATFORM_MAX_PATH + strlen(message);
	char[] str = new char[len];
	VFormat(str, len, message, 2);
	FF2GameMode.ReportError(boss, str);
}

/**
 * Returns whether or not debug is enabled
 *
 * @return		True if enabled, false otherwise
 */
stock bool FF2_Debug()
{
#if defined DEBUG || defined _DEBUG
	return true;
#else
	return false;
#endif
}

/**
 * Sets the cheat status to turn off logging and statistics
 *
 * @param status	Disable statistics if true
 */
stock void FF2_SetCheats(bool status=true)
{
	FF2GameMode.Cheats(status);
}

/**
 * Returns whether or not FF2 cheat commands was in the round
 *
 * @return		True if used, false otherwise
 */
stock bool FF2_GetCheats()
{
	return FF2GameMode.Cheats();
}

/**
 * Sets the boss selection of a client
 *
 * @param client	Client's index
 * @param boss		Boss's name ("name" key)
 * @param access	Allow the client to play that boss regardless of permission
 *
 * @return		True if the client normally was sucessfully set to the boss, false otherwise
 */
stock bool FF2_MakeBoss(int client, const char[] boss_name, bool call_event = true)
{
	FF2Player player = FF2Player(client);
	if( !player.Valid ) {
		return false;
	}

	FF2Identity id;
	strcopy(id.name, sizeof(FF2Identity::name), boss_name);
	FF2GameMode.QueryBoss(id, FF2GAMEMODEQ_COPY_OTHER | FF2GAMEMODEQ_BY_NAME);
	if( id.VSH2ID==INVALID_FF2_BOSS_ID )
		return false;

	player.MakeBossAndSwitch(id.VSH2ID, call_event);
	return true;
}

/**
 * Called when before a Boss uses an ability (see FF2CallType_t)
 *
 * @note		Use FF2_PreAbility with enabled=false ONLY to prevent FF2_OnAbility!
 *
 * @param boss			Boss/client's index
 * @param pluginName	Name of plugin with this ability
 * @param abilityName 	Name of ability
 * @param calltype		reason for the call
 * @param enabled		enabled = false to prevent the ability from being called
 */
forward void FF2_PreAbility(int boss, const char[] pluginName, const char[] abilityName, FF2CallType_t calltype, bool &enabled);

/**
 * Called when a Boss uses an ability (see FF2CallType_t)
 *
 * @param boss	 		Boss/client's index
 * @param pluginName	Name of plugin with this ability
 * @param abilityName 	Name of ability
 * @param calltype		reason for the call
 */
forward void FF2_OnAbility(int boss, const char[] pluginName, const char[] abilityName, FF2CallType_t calltype);

/**
 * Called when a Boss gets hurt by environmental damage
 *
 * @param boss			Boss/client's index
 * @param triggerHurt	Entity index of "trigger_hurt"
 * @param damage 		Damage by "trigger_hurt".  Cutomizable.
 *
 * @return		Plugin_Stop will prevent forward, Plugin_Changed will change damage.
 */
forward Action FF2_OnTriggerHurt(int boss, int triggerHurt, float &damage);

/**
 * Called when a Boss's music begins
 *
 * @param boss		Boss/client's index
 * @param path 		Path to music sound file
 * @param time		Length of music
 *
 * @return		Plugin_Stop will prevent music, Plugin_Changed will change it.
 */
forward Action FF2_OnMusic(int boss, char[] path, float& time);


/**
 * Called when FF2 picks a character for a Boss
 *
 * @param boss			Boss/client's index
 * @param character   	Character index
 * @param characterName	Character name
 * @param preset		True if the boss was set using a command such as ff2_special
 *
 * @return		You can NOT use Plugin_Stop to prevent this, but you can change characterName and use Plugin_Changed to change the boss.  If you want to change 'character', then make 'characterName' null.
 */
forward Action FF2_OnBossSelected(int boss, char[] characterName, bool preset);

/**
 * Called when FF2 adds queue points
 *
 * @param add_points	Array that contains each player's queue points
 *
 * @return		Plugin_Stop will prevent this, Plugin_Changed will change it.
 */
forward Action FF2_OnAddQueuePoints(int add_points[MAXPLAYERS + 1]);

/**
 * Called when a Boss loses a life
 *
 * @param boss		Boss's index
 * @param lives		Number of lives left
 * @param maxLives	Max number of lives
 *
 * @return		Plugin_Stop or Plugin_Handled to prevent damage that would remove a life, Plugin_Changed if you want to change the number of lives left.
 */
forward Action FF2_OnLoseLife(int boss, int& lives, int maxLives);

/**
 * Called when a boss is backstabbed
 *
 * @param boss		Boss/client's index
 * @param attacker	Attacker's client index
 * @param damage	Damage dealt (includes crit bonus)
 *
 * @return		Plugin_Changed to adjust the damage dealt, Plugin_Handled to prevent damage being dealt but continue sounds, stuns, etc, Plugin_Stop to prevent the backstab all together
 */
forward Action FF2_OnBackStabbed(int boss, int attacker);

/**
 * Gives ammo to a weapon
 *
 * @param client	Client's index
 * @param weapon	Weapon
 * @param ammo		Ammo (set to -1 for clipless weapons, then set the actual ammo using clip)
 * @param clip		Clip
 *
 * @error		Invalid client index or client not in game
 */
stock void FF2_SetAmmo(int client, int weapon, int ammo=-1, int clip=-1)
{
	if( IsValidEntity(weapon) ) {
		if( clip > -1 )
			SetEntProp(weapon, Prop_Data, "m_iClip1", clip);

		int ammoType = (ammo>-1 ? GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType") : -1);
		if( ammoType != -1 )
			SetEntProp(client, Prop_Data, "m_iAmmo", ammo, _, ammoType);
	}
}

/**
 * Sends a synced HUD message according to FF2's rules
 * Will only send if the client hasn't disabled their HUD and isn't checking the scoreboard
 *
 * Uses the same params and return values as ShowSyncHudText
 */
stock void FF2_ShowSyncHudText(int client, Handle sync, const char[] buffer, any ...)
{
	FF2Player player = FF2Player(client);
	if( player.Valid && !player.GetPropInt("bHideHUD") && !(GetClientButtons(client) & IN_SCORE) ) {
		char message[256];
		VFormat(message, sizeof(message), buffer, 4);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, sync, message);
	}
}

/**
 * Sends a HUD message according to FF2's rules
 * Will only send if the client hasn't disabled their HUD and isn't checking the scoreboard
 *
 * Uses the same params and return values as ShowHudText
 */
stock void FF2_ShowHudText(int client, int channel, const char[] buffer, any ...)
{
	if( player.Valid && !player.GetPropInt("bHideHUD") && !(GetClientButtons(client) & IN_SCORE) ) {
		char message[256];
		VFormat(message, sizeof(message), buffer, 4);
		SetGlobalTransTarget(client);
		ShowHudText(client, channel, message);
	}
}

/**
 * Used to consolidate debug messages
 *
 * @param buffer	Debug string to display
 * @param ...		Formatting rules
 */
stock void FF2Dbg(const char[] buffer, any ...)
{
	if( FF2_Debug() ) {
		char message[192];
		VFormat(message, sizeof(message), buffer, 2);
		CPrintToChatAll("{olive}[FF2 {darkorange}DEBUG{olive}]{default} %s", message);
		PrintToServer("[VSH2/FF2 DEBUG] %s", message);
	}
}


/**
 * Prints a color message with FF2's prefix
 *
 * Uses the same params and return values as CPrintToChat, CPrintToChatAll, and CReplyToCommand
 */
stock void FPrintToChat(int client, const char[] message, any ...)
{
	SetGlobalTransTarget(client);
	char buffer[192];
	VFormat(buffer, sizeof(buffer), message, 3);
	CPrintToChat(client, FF2_PREFIX ... "%s", buffer);
}

stock void FPrintToChatAll(const char[] message, any ...)
{
	char buffer[192];
	VFormat(buffer, sizeof(buffer), message, 2);
	CPrintToChatAll(FF2_PREFIX ... "%s", buffer);
}

stock void FReplyToCommand(int client, const char[] message, any ...)
{
	SetGlobalTransTarget(client);
	char buffer[192];
	VFormat(buffer, sizeof(buffer), message, 3);
	if( !client ) {
		CRemoveTags(buffer, sizeof(buffer));
		PrintToServer("[VSH2/FF2] %s", buffer);
	}
	else if( GetCmdReplySource() == SM_REPLY_TO_CONSOLE ) {
		CRemoveTags(buffer, sizeof(buffer));
		PrintToConsole(client, "[VSH2/FF2] %s", buffer);
	}
	else {
		CPrintToChat(client, FF2_PREFIX ... "%s", buffer);
	}
}

///	https://github.com/01Pollux/FF2ConfigToVSH2/blob/main/ff2_config_to_vsh2.sp#L385
stock FF2CallType_t FF2_OldNumToBitSlot(int slot)
{
	/**
	 * -2 - Invalid slot(internally used by FF2 for detecting missing "arg0" argument). Don't use!
	 * -1 - When Boss loses a life (if he has over 1)
     * 0 - Rage
     * 1 - Used by charging brave Jump. Fired every 0.2s
     * 2 - Demopan's charge of targe, projectiles etc.
     * 3 - Weighdown
     * 4 - Killed player (not used for sounds)
     * 5 - Boss killed (not used for sounds)
     * 6 - Boss backstabbed (not used for sounds)
     * 7 - Boss market gardened (not used for sounds)
     */
	switch (slot)
	{
 	case -2, 2: {
	// 2, -2 should never be used unless you're calling with FF2Player.ForceAbility
	return CT_UNUSED_DEMO;
	}
	case -1: return CT_LIFE_LOSS;
	case 1: return CT_CHARGE;
	case 0: return CT_RAGE;

//	case 3, 4, 5, 6, 7:
	default: {
		return view_as<FF2CallType_t>(1 << (1 + slot));
	}
	}
}


/**
 * Used to spawn a weapon
 *
 * @param client	Client index
 * @param name		Classname of the weapon
 * @param index		Definition index of the weapon
 * @param level		Level of the weapon
 * @param qual		Quality of the weapon
 * @param att		String, containing the attributes in the following format: attr ; val ; attr ; val ; ...
 * @param visible	Weapon will be visible?
 *
 * @error		Invalid item index, level, quality, client index, or client not in game
 *
 * @return		Entity index of the weapon, -1 on failure
 */
stock int FF2_SpawnWeapon(int client, char[] name, int index, int level, int qual, char[] att, bool visible=true)
{
	FF2Player player = FF2Player(client);
	return player.Valid ? player.SpawnWeapon(name, index, level, qual, att) : -1;
}

stock int FF2_GetBossPlayers()
{
	FF2Player[] bosses = new FF2Player[MaxClients];
	return FF2GameMode.GetBosses(bosses);
}



public SharedPlugin __pl_FF2 =
{
	name = "freak_fortress_2",
	file = "freak_fortress_2.smx",
	#if defined REQUIRE_PLUGIN
		required = 1,
	#else
		required = 0,
	#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_FF2_SetNTVOptional()
{
	#define MARK_OPTIONAL(%0) 		MarkNativeAsOptional("FF2Player."...#%0)
	#define MARK_OPTIONAL_GET(%0) 	MarkNativeAsOptional("FF2Player."...#%0...".get")


	MARK_OPTIONAL(FF2Player);
	MARK_OPTIONAL(GetInt);
	MARK_OPTIONAL(GetFloat);
	MARK_OPTIONAL(GetString);
	MARK_OPTIONAL(GetSection);
	MARK_OPTIONAL(GetArgB);
	MARK_OPTIONAL(GetArgI);
	MARK_OPTIONAL(GetArgF);
	MARK_OPTIONAL(GetArgS);

	MARK_OPTIONAL(HasAbility);
	MARK_OPTIONAL(DoAbility);
	MARK_OPTIONAL(ForceAbility);
	MARK_OPTIONAL(RandomSound);
	MARK_OPTIONAL(RageDist);
	MARK_OPTIONAL(GetConfigName);

	MARK_OPTIONAL(PlayBGM);

	#undef MARK_OPTIONAL
	#undef MARK_OPTIONAL_GET

	#define MARK_OPTIONAL(%0) 		MarkNativeAsOptional("FF2GameMode."...#%0)


	CREATE_NATIVE(IsOn);
	CREATE_NATIVE(PluginVersion);
	CREATE_NATIVE(ForkVersion);

	CREATE_NATIVE(Cheats);
	CREATE_NATIVE(QueryBoss);

	CREATE_NATIVE(LoadAbility);
	CREATE_NATIVE(SubPlugins);
	CREATE_NATIVE(Validate);


	#undef MARK_OPTIONAL
	#undef MARK_OPTIONAL_GET
}
#endif



#if defined FF2_USING_AUTO_PLUGIN || defined FF2_USING_AUTO_PLUGIN__OLD
char this_plugin_name[64];

static void GetThisPluginName()
{
	char pluginName[80];
	GetPluginFilename(INVALID_HANDLE, pluginName, sizeof(pluginName));

	/// make sure the file ends with ".smx"
	int extension_index = FindCharInString(pluginName, '.', true);
	if( extension_index == -1 ||
		extension_index + 3 >= sizeof(pluginName) ||
		pluginName[extension_index+1] != 's'||
		pluginName[extension_index+2] != 'm' ||
		pluginName[extension_index+3] != 'x' 
	  ) {
		return;
	}

	pluginName[extension_index] = 0;

	int forwardSlash = -1;
	int backwardSlash = -1;
	int finalPluginName = -1;

	for ( ;; ) {
		forwardSlash = StrContains(pluginName[finalPluginName+1], "/");
		backwardSlash = StrContains(pluginName[finalPluginName+1], "\\");
		if( (backwardSlash<forwardSlash && backwardSlash!=-1) || forwardSlash==-1 ) {
			if( backwardSlash == -1 )
				break;

			finalPluginName = backwardSlash;
		}
		else if( (forwardSlash<backwardSlash && forwardSlash!=-1) || backwardSlash==-1 ) {
			if(forwardSlash == -1)
				break;

			finalPluginName = forwardSlash;
		}
	}

	strcopy(this_plugin_name, sizeof(this_plugin_name), pluginName[finalPluginName+1]);
}


public void OnPluginStart()
{
	GetThisPluginName();
	FF2GameMode gm;
	if( gm.FF2IsOn )
		OnPluginStart2();
}

#if defined FF2_USING_AUTO_PLUGIN
// void FF2_OnAbility2(const FF2Player, const char[], const char[], FF2CallType_t);
public void FF2_OnAbility(int boss, const char[] pluginName, const char[] abilityName, FF2CallType_t calltype)
{
	if( !strcmp(pluginName, this_plugin_name) ) {
		FF2_OnAbility2(FF2Player(boss), abilityName, calltype);
	}
}
#else
// void FF2_OnAbility2(int, const char[], const char[], int);
public void FF2_OnAbility(int boss, const char[] pluginName, const char[] abilityName, FF2CallType_t calltype)
{
	if( !strcmp(pluginName, this_plugin_name) ) {
		FF2_OnAbility2(boss, pluginName, abilityName, view_as< int >(calltype));
	}
}
#endif // FF2_USING_AUTO_PLUGIN

#endif // FF2_USING_AUTO_PLUGIN || FF2_USING_AUTO_PLUGIN__OLD

#file "Freak Fortress 2 Include"