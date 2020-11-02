#include <sdktools>
#include <morecolors>
#tryinclude <tf2items>

#if defined _VSH2_FF2
 #endinput
#endif
#define _VSH2_FF2

#include <vsh2>


enum FF2CallType_t
{
	CT_NONE		= 0b000000000,	// 	Inactive, default to CT_RAGE
	CT_LIFE_LOSS 	= 0b000000001,
	CT_RAGE		= 0b000000010,
	CT_CHARGE	= 0b000000100,
	CT_UNUSED_DEMO 	= 0b000001000,	//	UNUSED
	CT_WEIGHDOWN	= 0b000010000,
	CT_PLAYER_KILLED= 0b000100000,
	CT_BOSS_KILLED	= 0b001000000,
	CT_BOSS_STABBED	= 0b010000000,
	CT_BOSS_MG	= 0b100000000,
};

enum FF2RageType_t
{
	RT_RAGE = 0,
	RT_WEIGHDOWN,
	RT_CHARGE
};

#if defined FF2_USING_AUTO_PLUGIN__OLD

enum {
	FF2FLAG_UBERREADY 		= (1<<1),		//Used when medic says "I'm charged!"				
	FF2FLAG_ISBUFFED 		= (1<<2),		//Used when soldier uses the Battalion's Backup	
	FF2FLAG_CLASSTIMERDISABLED 	= (1<<3),		//Used to prevent clients' timer		
	FF2FLAG_HUDDISABLED 		= (1<<4),		//Used to prevent custom hud from clients' timer	
	FF2FLAG_BOTRAGE 		= (1<<5),		//Used by bots to use Boss's rage
	FF2FLAG_TALKING 		= (1<<6),		//Used by Bosses with "sound_block_vo" to disable block for some lines			
	FF2FLAG_ALLOWSPAWNINBOSSTEAM	= (1<<7),		//Used to allow spawn players in Boss's team			
	FF2FLAG_USEBOSSTIMER 		= (1<<8),		//Used to prevent Boss's timer		
	FF2FLAG_USINGABILITY 		= (1<<9),		//Used to prevent Boss's hints about abilities buttons	
	FF2FLAG_CLASSHELPED 		= (1<<10),					
	FF2FLAG_HASONGIVED 		= (1<<11),					
	FF2FLAG_CHANGECVAR		= (1<<12),		//Used to prevent SMAC from kicking bosses who are using certain rages (NYI)		
	FF2FLAG_ALLOW_HEALTH_PICKUPS	= (1<<13),		//Used to prevent bosses from picking up health
	FF2FLAG_ALLOW_AMMO_PICKUPS	= (1<<14),		//Used to prevent bosses from picking up ammo		
	FF2FLAG_ROCKET_JUMPING		= (1<<15),		//Used when a soldier is rocket jumping
	FF2FLAG_ALLOW_BOSS_WEARABLES	= (1<<16),		//Used to allow boss having wearables (only for Official FF2)
	FF2FLAGS_SPAWN 			= ~FF2FLAG_UBERREADY 
					& ~FF2FLAG_ISBUFFED 
					& ~FF2FLAG_TALKING 
					& ~FF2FLAG_ALLOWSPAWNINBOSSTEAM 
					& ~FF2FLAG_CHANGECVAR 
					& ~FF2FLAG_ROCKET_JUMPING 
					& FF2FLAG_USEBOSSTIMER 
					& FF2FLAG_USINGABILITY,					
}

#endif

#define INVALID_FF2PLAYER ToFF2Player(-1)
#define ToFF2Player(%0)	view_as<FF2Player>(%0)
#define FF2_PREFIX		"{olive}[FF2]{default} "

/** 
 * Some new properties:
 *
 * iLives
 * iMaxLives
 * bNoSuperJump
 * bHideHUD
 * bNotifySMAC_CVars
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
	
	/**
	 * list of abilities the current boss has
	 *
	 * @return				{ { "plugin_name##ability_name", "ability key" }, ... }
	 */
	property StringMap HookedAbilities {
		public native get();
	}
	
	property bool Valid {
		public get() { return this != INVALID_FF2PLAYER && this.index; }
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
	 * @return				number of bytes written, 0 if key doesn't exists
	 */
	public native int GetString(const char[] key_name, char[] res, int maxlen);
	
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
	 *
	 * @noreturn
	 */
	public native void PlayBGM(const char path[PLATFORM_MAX_PATH]);
	
	/**
	 * Forces boss to use an ability
	 *
	 * @param boss		Boss's index
	 * @param pluginName	Name of plugin with this ability
	 * @param abilityName Name of ability
	 * @param slot		check FF2CallType enums
	 *
	 * @note				this will NOT remove/reduce boss charge
	 * @noreturn
	 */
	public native void DoAbility(const char[] pl_name, const char[] ab_name, FF2CallType_t slot);
	
	/**
	 * Starts a random Boss sound from its config file
	 *
	 * @param keyvalue		Name of sound container
	 * @param buffer		Buffer for result sound path
	 * @param bufferLength	Length of buffer
	 * @param boss			Boss's index
	 *
	 * @return		True if sound has been found, false otherwise
	 */
	public native bool RandomSound(const char[] key_name, char[] buffer, int maxlen);
}


/**
 * Is Freak Fortress enabled?
 *
 * @return		False if FF2 is disabled
 *			True if FF2 is enabled
 */
native bool FF2_IsFF2Enabled();


methodmap FF2GameMode < VSH2GameMode
{
	public FF2GameMode() { return view_as< FF2GameMode >(0); }
	
	property bool FF2IsOn {
		public get() { return FF2_IsFF2Enabled(); }
	}
	
	property int RoundState {
		public get() { return VSH2GameMode.GetPropInt("iRoundState"); }
	}
	
	public static bool Validate(const VSH2Player player) {
		return ToFF2Player(player).HookedAbilities != null;
	}
}


/**
 * Gets the version of FF2 running on the server
 *
 * @param version	An array of size 3 that will contain the major, minor, and stable version numbers respectively
 *
 * @return		
 */
native bool FF2_GetFF2Version(int[] version=0);

/**
 * Gets the version of the FF2 fork running on the server
 *
 * @note		Official FF2 versions always return 0 for version numbers
 *
 * @param version	An array of size 3 that will contain the major, minor, and stable version numbers respectively
 *
 * @return		
 */
native bool FF2_GetForkVersion(int[] fversion=0);

/**
 * Gets current round state
 *
 * @return		0 - in setup
 *			1 - round is in progress (due to a bug in arena mode, stalemate will also return 1)
 *			2 - someone wins
 */
stock int FF2_GetRoundState()
{
	return VSH2GameMode.GetPropInt("iRoundState");
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
	FF2Player player = FF2Player(boss, true);
	return player.GetPropInt("bIsBoss") ? player.userid:-1;
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
	return player.GetPropInt("bIsBoss") ? player.userid:-1;
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
native bool FF2_GetBossSpecial(int boss=0, char[] buffer, int bufferLength, int bossMeaning=0);

/**
 * Gets the current health value of the Boss
 *
 * @param boss		Boss's index
 *
 * @return		Current health of the Boss
 */
stock int FF2_GetBossHealth(int boss=0)
{
	FF2Player player = ToFF2Player(boss);
	return player.GetPropInt("bIsBoss") ? player.GetPropInt("iHealth"):0;
}

/**
 * Sets the health of the Boss
 *
 * @param boss		Boss's index
 * @param health	New health value
 *
 * @noreturn
 */
stock void FF2_SetBossHealth(int boss, int health)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	if( player.SetPropInt("bIsBoss") ) {
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
	FF2Player player = ToFF2Player(boss);
	return player.GetPropInt("bIsBoss") ? player.GetPropInt("iMaxHealth"):0;
}

/**
 * Sets the max health of the Boss
 *
 * @param boss		Boss's index
 * @param health	New max health value
 *
 * @noreturn
 */
stock void FF2_SetBossMaxHealth(int boss, int health)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	if( player.SetPropInt("bIsBoss") ) {
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
	FF2Player player = ToFF2Player(GetNativeCell(1));
	if( player.SetPropInt("bIsBoss") ) {
		player.SetPropInt("iLives", health);
	}
}

/**
 * Sets the current number of lives of the Boss
 *
 * @param boss		Boss's index
 * @param lives		New number of lives
 *
 * @noreturn
 */
stock void FF2_SetBossLives(int boss, int lives)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	if( player.SetPropInt("bIsBoss") ) {
		player.SetPropInt("iLives", health);
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
	FF2Player player = ToFF2Player(GetNativeCell(1));
	if( player.GetPropInt("bIsBoss") ) {
		return player.GetPropInt("iMaxLives");
	}
	return 0;
}

/**
 * Sets the max number of lives of the Boss
 *
 * @param boss		Boss's index
 * @param lives		New max number of lives
 *
 * @noreturn
 */
stock void FF2_SetBossMaxLives(int boss, int lives)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	if( player.SetPropInt("bIsBoss") ) {
		player.SetPropInt("iMaxLives", lives);
	}
}

/**
 * Gets the charge meter value of the Boss
 *
 * @param boss		Boss's index
 * @param slot		Slot of charge meter
 *				0 - rage
 *				1 - as usual, used for brave jump or teleport
 *				2 - other charged abilities
 *
 * @return		Charge value of the Boss
 */
native float FF2_GetBossCharge(int boss, int slot);

/**
 * Sets the charge meter value of the Boss
 *
 * @param boss		Boss's index
 * @param slot		Slot of charge meter
 *				0 	- rage
 *				1 	- as usual, used for brave jump or teleport
 *				... - other charged abilities
 * @param value		New value of charge
 *
 * @noreturn
 */
native void FF2_SetBossCharge(int boss, int slot, float value);

/**
 * Gets damage dealt by this client
 *
 * @param client 	Client's index
 *
 * @return		Damage dealt
 */
stock int FF2_GetClientDamage(int client)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	return player.GetPropInt("iDamage");
}

/**
 * Gets damage dealt by this client
 *
 * @param client 	Client's index
 *
 * @noreturn
 */
stock void FF2_SetClientDamage(int client, int damage)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	player.SetPropInt("iDamage", damage);
}

/**
 * Gets an ability's rage distance
 *
 * @param boss		Boss's index
 * @param pluginName	Name of plugin with this ability
 * @param abilityName	Name of ability (use null string if you want get boss's global "ragedist" value)
 *
 * @return		Ability's rage distance
 */
stock float FF2_GetRageDist(int boss=0, const char[] pluginName="", const char[] abilityName="")
{
	return FF2Player(boss).RageDist(pluginName, abilityName);
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
	return FF2Player(boss).HasAbility(pluginName, abilityName);
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
	 * @noreturn
	 */
stock void FF2_DoAbility(int boss, const char[] pluginName, const char[] abilityName, int slot)
{
	FF2Player(boss).DoAbility(pluginName, abilityName, view_as<FF2CallType_t>(slot));
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
stock int FF2_GetAbilityArgument(int boss, const char[] pluginName, const char[] abilityName, int argument, int defValue=0)
{
	FF2Player player = FF2Player(boss);
	static char arg_[8];
	FormatEx(arg_, sizeof(arg_), "arg%i", argument);
	return player.GetArgI(pluginName, abilityName, arg_, defValue);
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
	FF2Player player = FF2Player(boss);
	static char arg_[8];
	FormatEx(arg_, sizeof(arg_), "arg%i", argument);
	return player.GetArgF(plugin_name, ability_name, arg_, defValue);
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
 *
 * @noreturn
 */
stock void FF2_GetAbilityArgumentString(int boss, const char[] pluginName, const char[] abilityName, int argument, char[] buffer, int bufferLength)
{
	FF2Player player = FF2Player(boss);
	static char arg_[8];
	FormatEx(arg_, sizeof(arg_), "arg%i", argument);
	player.GetArgS(pluginName, abilityName, arg_, buffer, bufferLength);
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
	FF2Player player = FF2Player(boss);
	return player.GetArgS(pluginName, abilityName, argument, defValue);
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
stock float FF2_GetArgNamedF(int boss, const char[] plugin_name, const char[] ability_name, const char[] argument, float defValue=0.0)
{
	FF2Player player = FF2Player(boss);
	return player.GetArgS(pluginName, abilityName, argument, defValue);
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
 *
 * @noreturn
 */
stock void FF2_GetArgNamedS(int boss, const char[] pluginName, const char[] abilityName, const char[] argument, char[] buffer, int bufferLength)
{
	FF2Player player = FF2Player(boss);
	player.GetArgS(pluginName, abilityName, argument, buffer, bufferLength);
}

/**
 * Starts a random Boss sound from its config file
 *
 * @param keyvalue		Name of sound container
 * @param buffer		Buffer for result sound path
 * @param bufferLength	Length of buffer
 * @param boss			Boss's index
 * @unused slot 		Only for "sound_ability" - slot of ability
 *
 * @return		True if sound has been found, false otherwise
 */
stock bool FF2_RandomSound(const char[] keyvalue, char[] buffer, int bufferLength, int boss=0, int slot=0)
{
	return FF2Player(boss).RandomSound(keyvalue, buffer, bufferLength);
}

/**
 * Starts the Boss's music for the specified clients
 *
 * @param client	Client's index (0 for all clients)
 * @param bgm		music path
 *
 * @noreturn
 */
stock void FF2_StartMusic(int client = 0, const char[] bgm = "")
{
	if( !client ) {
		for( int i = 1; i <= MaxClients; i++ ) {
			if(IsClientInGame(i)) {
				FF2Player(i).PlayBGM(bgm);
			}
		}
	}
	else {
		FF2Player player = FF2Player(client);
		if( player.index ) {
			player.PlayBGM(bgm);
		}
	}
}

/**
 * Stops the Boss's music for the specified clients
 *
 * @param client	Client's index (0 for all clients)
 *
 * @noreturn
 */
stock void FF2_StopMusic(int client=0)
{
	if( !client ) {
		for( int i = 1; i <= MaxClients; i++ ) {
			if(IsClientInGame(i)) {
				FF2Player(i).StopMusic(; )
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
	#warning this doesn't return what you think it does, use FF2Player.GetProp[Int, Float, Any] instead. 
#endif
	FF2Player player = FF2Player(client);
	return player.GetPropInt("iFlags");
}

/**
 * Sets a client's flags for FF2
 *
 * @param client	Client's index
 * @param flags		New flag values
 *
 * @noreturn
 */
stock void FF2_SetFF2flags(int client, int flags)
{
#if defined FF2_USING_AUTO_PLUGIN__OLD
	#warning this doesn't return what you think it does, use FF2Player.SetProp[Int, Float, Any] instead.
#endif
	FF2Player player = FF2Player(client);
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
	FF2Player player = ToFF2Player(GetNativeCell(1));
	return player.Valid ? player.GetPropInt("iQueue"):-999;
}

/**
 * Sets a client's queue points
 *
 * @param client	Client's index
 * @param value		New value of client's queue points
 *
 * @error		Invalid client index
 *
 * @noreturn
 */
stock void FF2_SetQueuePoints(int client, int value)
{
	FF2Player player = FF2Player(client);
	if ( player.Valid ) {
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
 *
 * @noreturn
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
 *
 * @noreturn
 */
native void FF2_LogError(const char[] message, any ...);

/**
 * Reports an error to FF2's error log with boss name
 *
 * @param boss		Boss index
 * @param message	Message to error log
 *
 * @noreturn
 * @error 			failed to format
 */
native void FF2_ReportError(const FF2Player boss = INVALID_FF2PLAYER, const char[] message, any ...);

/**
 * Returns whether or not debug is enabled
 *
 * @return		True if enabled, false otherwise
 */
stock bool FF2_Debug()
{
#if defined DEBUG
	return true;
#else 
	return false;
#endif
}

/**
 * Sets the cheat status to turn off logging and statistics
 *
 * @param status	Disable statistics if true
 *
 * @noreturn
 */
native void FF2_SetCheats(bool status=true);

/**
 * Returns whether or not FF2 cheat commands was in the round
 *
 * @return		True if used, false otherwise
 */
native bool FF2_GetCheats();

/**
 * Sets the boss selection of a client
 *
 * @param client	Client's index
 * @param boss		Boss's name ("name" key)
 * @param access	Allow the client to play that boss regardless of permission
 *
 * @return		True if the client normally has access to this boss, false otherwise
 */
native bool FF2_MakeBoss(int client, const char[] boss_name, bool call_event = true);

/**
 * Called when before a Boss uses an ability (see FF2CallType_t)
 *
 * @note		Use FF2_PreAbility with enabled=false ONLY to prevent FF2_OnAbility!
 *
 * @param boss	 		Boss's index
 * @param pluginName	Name of plugin with this ability
 * @param abilityName 	Name of ability
 * @param calltype		reason for the call
 * @param enabled		reason for the call
 *
 * @noreturn
 */
forward void FF2_PreAbility(const FF2Player player, const char[] pluginName, const char[] abilityName, FF2CallType_t calltype, bool &enabled);

/**
 * Called when a Boss uses an ability (see FF2CallType_t)
 *
 * @param boss	 		Boss's index
 * @param pluginName	Name of plugin with this ability
 * @param abilityName 	Name of ability
 * @param calltype		reason for the call
 *
 * @noreturn
 */
forward void FF2_OnAbility(const FF2Player player, const char[] pluginName, const char[] abilityName, FF2CallType_t calltype);

/**
 * Called when a Boss gets hurt by environmental damage
 *
 * @param boss	 	Boss's index
 * @param triggerHurt	Entity index of "trigger_hurt"
 * @param damage 	Damage by "trigger_hurt".  Cutomizable.
 *
 * @return		Plugin_Stop will prevent forward, Plugin_Changed will change damage.
 */
forward Action FF2_OnTriggerHurt(int boss, int triggerHurt, float &damage);

/**
 * Called when a Boss's music begins
 *
 * @param path 		Path to music sound file
 * @param time		Length of music
 *
 * @return		Plugin_Stop will prevent music, Plugin_Changed will change it.
 */
forward Action FF2_OnMusic(char[] path, float &time);

/**
 * Called when a Boss's music begins with name and artist
 *
 * @param path 		Path to music sound file
 * @param time		Length of music
 * @param name 		The music name
 * @param artist 	The music artist
 *
 * @return		Plugin_Stop will prevent music, Plugin_Changed will change it.
 */
forward Action FF2_OnMusic2(char[] path, float &time, char[] name, char[] artist);

/**
 * Called when FF2 picks a character for a Boss
 *
 * @param boss		Boss index
 * @param character   	Character index
 * @param characterName	Character name
 * @param preset	True if the boss was set using a command such as ff2_special
 *
 * @return		You can NOT use Plugin_Stop to prevent this, but you can change characterName and use Plugin_Changed to change the boss.  If you want to change 'character', then make 'characterName' null.
 */
forward Action FF2_OnBossSelected(FF2Player player, char[] characterName, bool preset);

/**
 * Called when FF2 adds queue points
 *
 * @param add_points	Array that contains each player's queue points
 *
 * @return		Plugin_Stop will prevent this, Plugin_Changed will change it.
 */
forward Action FF2_OnAddQueuePoints(int add_points[MAXPLAYERS+1]);

/**
 * Called when a Boss loses a life
 *
 * @param boss		Boss's index
 * @param lives		Number of lives left
 * @param maxLives	Max number of lives
 *
 * @return		Plugin_Stop or Plugin_Handled to prevent damage that would remove a life, Plugin_Changed if you want to change the number of lives left.
 */
forward Action FF2_OnLoseLife(int boss, int &lives, int maxLives);

/**
 * Called when the number of alive players changes.  Note that this will never be 0 as FF2 does not re-calculate the number of players once the round ends.
 *
 * @param players	Number of alive players left on the non-boss team
 * @param bosses	Number of alive players left on the boss team (this includes minions as well)
 *
 * @noreturn
 */
//forward void FF2_OnAlivePlayersChanged(int players, int bosses);

/**
 * Called when a boss is backstabbed
 *
 * @param boss		Boss's index
 * @param client	Boss's client index
 * @param attacker	Attacker's client index
 * @param damage	Damage dealt (includes crit bonus)
 *
 * @return		Plugin_Changed to adjust the damage dealt, Plugin_Handled to prevent damage being dealt but continue sounds, stuns, etc, Plugin_Stop to prevent the backstab all together
 */
forward Action FF2_OnBackStabbed(int boss, int client, int attacker);

/**
 * Gives ammo to a weapon
 *
 * @param client	Client's index
 * @param weapon	Weapon
 * @param ammo		Ammo (set to -1 for clipless weapons, then set the actual ammo using clip)
 * @param clip		Clip
 *
 * @error		Invalid client index or client not in game
 *
 * @noreturn
 */
stock void FF2_SetAmmo(int client, int weapon, int ammo=-1, int clip=-1)
{
	if(IsValidEntity(weapon))
	{
		if(clip > -1)
			SetEntProp(weapon, Prop_Data, "m_iClip1", clip);

		int ammoType = (ammo>-1 ? GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType") : -1);
		if(ammoType != -1)
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
	if( !player.GetPropInt("bHideHUD") && !(GetClientButtons(client) & IN_SCORE) ) {
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
	if( !player.GetPropInt("bHideHUD") && !(GetClientButtons(client) & IN_SCORE) ) {
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
 *
 * @noreturn
 */
stock void FF2Dbg(const char[] buffer, any ...)
{
	if( FF2_Debug() ) {
		char message[192];
		VFormat(message, sizeof(message), buffer, 2);
		CPrintToChatAll("{olive}[FF2 {darkorange}DEBUG{olive}]{default} %s", message);
		PrintToServer("[FF2 DEBUG] %s", message);
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
	if(!client)
	{
		CRemoveTags(buffer, sizeof(buffer));
		PrintToServer("[FF2] %s", buffer);
	}
	else if(GetCmdReplySource() == SM_REPLY_TO_CONSOLE)
	{
		CRemoveTags(buffer, sizeof(buffer));
		PrintToConsole(client, "[FF2] %s", buffer);
	}
	else
	{
		CPrintToChat(client, FF2_PREFIX ... "%s", buffer);
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
stock int FF2_SpawnWeapon(int client, char[] name, int index, int level, int qual, const char[] att, bool visible=true)
{
	FF2Player player = FF2Player(client);
	return player.SpawnWeapon(name, index, level, qual, att);
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
	#define MARK_OPTIONAL(%0) 		MarkNativeAsOptional(#%0)
	#define MARK_OPTIONAL_M(%0) 	MarkNativeAsOptional("FF2Player."...#%0)
	#define MARK_OPTIONAL_MGET(%0) 	MarkNativeAsOptional("FF2Player."...#%0...".get")
	#define MARK_OPTIONAL_MSET(%0) 	MarkNativeAsOptional("FF2Player."...#%0...".set")
	
	MARK_OPTIONAL(FF2_IsFF2Enabled);
	MARK_OPTIONAL(FF2_GetFF2Version);
	MARK_OPTIONAL(FF2_GetForkVersion);
	
	MARK_OPTIONAL(FF2_GetBossSpecial);
	
	MARK_OPTIONAL(FF2_LogError);
	MARK_OPTIONAL(FF2_Debug);
	
	MARK_OPTIONAL(FF2_GetCheats);
	MARK_OPTIONAL(FF2_SetCheats);
	
	MARK_OPTIONAL(FF2_GetBossCharge);
	MARK_OPTIONAL(FF2_SetBossCharge);
	
	MARK_OPTIONAL(FF2_GetBossPlayers);
	MARK_OPTIONAL(FF2_MakeBoss);

	MARK_OPTIONAL_M(FF2Player);
	MARK_OPTIONAL_M(GetInt);
	MARK_OPTIONAL_M(GetFloat);
	MARK_OPTIONAL_M(GetString);
	MARK_OPTIONAL_M(GetArgI);
	MARK_OPTIONAL_M(GetArgF);
	MARK_OPTIONAL_M(GetArgS);
	
	MARK_OPTIONAL_M(HasAbility);
	MARK_OPTIONAL_M(DoAbility);
	MARK_OPTIONAL_M(RandomSound);
	MARK_OPTIONAL_M(RageDist);
	
	MARK_OPTIONAL_MGET(HookedAbilities);
	MARK_OPTIONAL_M(PlayBGM);
	
	#undef MARK_OPTIONAL
	#undef MARK_OPTIONAL_MGET
	#undef MARK_OPTIONAL_MSET
}
#endif



#if defined FF2_USING_AUTO_PLUGIN || defined FF2_USING_AUTO_PLUGIN__OLD
char this_plugin_name[64];

static void GetThisPluginName()
{
	char pluginName[80];
	GetPluginFilename(INVALID_HANDLE, pluginName, sizeof(pluginName));
	ReplaceString(pluginName, sizeof(pluginName), ".ff2", "", false);
	int forwardSlash = -1;
	int backwardSlash = -1;
	int finalPluginName = -1;
	for(;;)
	{
		forwardSlash = StrContains(pluginName[finalPluginName+1], "/");
		backwardSlash = StrContains(pluginName[finalPluginName+1], "\\");
		if((backwardSlash<forwardSlash && backwardSlash!=-1) || forwardSlash==-1)
		{
			if(backwardSlash == -1)
				break;

			finalPluginName = backwardSlash;
		}
		else if((forwardSlash<backwardSlash && forwardSlash!=-1) || backwardSlash==-1)
		{
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
	OnPluginStart2();
}

#if defined FF2_USING_AUTO_PLUGIN
public void FF2_OnAbility(const FF2Player player, const char[] pluginName, const char[] abilityName, FF2CallType_t calltype)
{
	if( !strcmp(pluginName, this_plugin_name) ) {
		FF2_OnAbility2(player, abilityName, calltype);
	}
}

#else 

public void FF2_OnAbility(const FF2Player player, const char[] pluginName, const char[] abilityName, FF2CallType_t calltype)
{
	if( !strcmp(pluginName, this_plugin_name) ) {
		FF2_OnAbility2(player.userid, pluginName, abilityName, view_as<int>(calltype));
	}
}

#endif
#endif

#file "Freak Fortress 2 Include"
