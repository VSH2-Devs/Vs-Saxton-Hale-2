#if defined _vsh2_included
	#endinput
#endif
#define _vsh2_included


methodmap VSH2Player	
{
	/** [ C O N S T R U C T O R ]
	 * Constructs an instance of the BaseBoss internal methodmap
	 * @param index			index (or the userid) of a player
	 * @param userid		if using userid instead of player index, set this param to true
	 * @return			a player instance of the VSH2Player methodmap
	*/
	public native VSH2Player(const int index, bool userid=false);

	/* **** **** [ P R O P E R T I E S ] **** **** */
	
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
	
	public native bool GetProperty(const char prop_name[64], any& item);
	public native void SetProperty(const char prop_name[64], any value);

	/*		AVAILABLE PROPS
	property int iQueue
	{
		public native get();
		public native set( const int queue );
	}
	property int iPresetType
	{
		public native get();
		public native set( const int bosstype );
	}
	property int iKills
	{
		public native get();
		public native set( const int kills )
	}
	property int iHits
	{
		public native get();
		public native set( const int hits );
	}
	property int iLives
	{
		public native get();
		public native set( const int lives );
	}
	property int iState
	{
		public native get();
		public native set( const int boss_state );
	}
	property int iDamage
	{
		public native get();
		public native set( const int damage );
	}
	property int iAirDamage
	{
		public native get();
		public native set( const int airstrike_damage );
	}
	property int iSongPick
	{
		public native get();
		public native set( const int song_index );
	}
	property int iHealTarget	// returns -1 is there's no valid player
	{
		public native get();
	}
	property int iOwnerBoss
	{
		public native get();
		public native set( const int boss_userid );
	}
	property int iUberTarget	// please use userid on this; convert to client index if you want but userid is safer
	{
		public native get();
		public native set( const int userid );
	}
	property int bGlow		// use like a bool
	{
		public native get();
		public native set( const int isGlow );
	}
	property bool bNearDispenser
	{
		public native get();
	}
	property bool bIsMinion
	{
		public native get();
		public native set( const bool is_minion );
	}
	property bool bInJump
	{
		public native get();
		public native set( const bool is_jumping );
	}

	property float flGlowtime
	{
		public native get();
		public native set( const float glowtime );
	}
	property float flLastHit
	{
		public native get();
		public native set( const float lasthit_time );
	}
	property float flLastShot
	{
		public native get();
		public native set( const float last_time_player_shot_something );
	}
	
	// 	ALL PROPERTIES AFTER THIS COMMENT ONLY ACCOUNT FOR BOSSES BUT CAN STILL APPLY ON NON-BOSSES AND MINIONS
	property int iHealth
	{
		public native get();
		public native set( const int new_health );
	}
	property int iMaxHealth
	{
		public native get();
		public native set( const int new_maxhealth );
	}
	property int iType
	{
		public native get();
		public native set( const int boss_id );
	}
	property int iClimbs
	{
		public native get();
		public native set( const int climb_amount );
	}
	property int iStabbed
	{
		public native get();
		public native set( const int amount_of_times_stabbed );
	}
	property int iMarketted
	{
		public native get();
		public native set( const int amount_of_times_market_gardened );
	}
	property int iDifficulty
	{
		public native get();
		public native set( const int difficulty_setting );
	}

	property bool bIsBoss
	{
		public native get();
		public native set( const bool is_boss );
	}
	property bool bSetOnSpawn
	{
		public native get();
		public native set( const bool is_set_to_be_boss );
	}
	property bool bUsedUltimate	// Not an overwatch reference lol; purpose is for a use-once ability but you can reset it
	{
		public native get();
		public native set( const bool used_rare_ability );
	}

	property float flSpeed	// if you boss needs a set amount of speed, use this obviously
	{
		public native get();
		public native set( const float boss_speed );
	}
	property float flCharge
	{
		public native get();
		public native set( const float ability_charge );
	}
	property float flRAGE
	{
		public native get();
		public native set( const float hulk_smash_percent );
	}
	property float flKillSpree
	{
		public native get();
		public native set( const float time_boss_has_to_kill_alot );
	}
	property float flWeighDown
	{
		public native get();
		public native set( const float weight_percentage_charge );
	}
	*/
	
	//public native void ConvertToMinion(const float respawn_time);
};

native int VSH2_RegisterPlugin(const char plugin_name[64]);


public SharedPlugin __pl_vsh2 = {
	name = "vsh2",
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
	/*
	MarkNativeAsOptional("VSH2Player.iQueue.get");
	MarkNativeAsOptional("VSH2Player.iQueue.set");
	
	MarkNativeAsOptional("VSH2Player.iPresetType.get");
	MarkNativeAsOptional("VSH2Player.iPresetType.set");
	
	MarkNativeAsOptional("VSH2Player.iKills.get");
	MarkNativeAsOptional("VSH2Player.iKills.set");
	
	MarkNativeAsOptional("VSH2Player.iHits.get");
	MarkNativeAsOptional("VSH2Player.iHits.set");
	
	MarkNativeAsOptional("VSH2Player.iLives.get");
	MarkNativeAsOptional("VSH2Player.iLives.set");
	
	MarkNativeAsOptional("VSH2Player.iState.get");
	MarkNativeAsOptional("VSH2Player.iState.set");
	
	MarkNativeAsOptional("VSH2Player.iDamage.get");
	MarkNativeAsOptional("VSH2Player.iDamage.set");
	
	MarkNativeAsOptional("VSH2Player.iAirDamage.get");
	MarkNativeAsOptional("VSH2Player.iAirDamage.set");
	
	MarkNativeAsOptional("VSH2Player.iSongPick.get");
	MarkNativeAsOptional("VSH2Player.iSongPick.set");
	
	MarkNativeAsOptional("VSH2Player.iHealTarget.get");
	
	MarkNativeAsOptional("VSH2Player.iOwnerBoss.get");
	MarkNativeAsOptional("VSH2Player.iOwnerBoss.set");
	
	MarkNativeAsOptional("VSH2Player.iUberTarget.get");
	MarkNativeAsOptional("VSH2Player.iUberTarget.set");
	
	MarkNativeAsOptional("VSH2Player.iGlow.get");
	MarkNativeAsOptional("VSH2Player.iGlow.set");
	
	MarkNativeAsOptional("VSH2Player.bNearDispenser.get");
	
	MarkNativeAsOptional("VSH2Player.bIsMinion.get");
	MarkNativeAsOptional("VSH2Player.bIsMinion.set");
	
	MarkNativeAsOptional("VSH2Player.bInJump.get");
	MarkNativeAsOptional("VSH2Player.bInJump.set");
	
	MarkNativeAsOptional("VSH2Player.flGlowtime.get");
	MarkNativeAsOptional("VSH2Player.flGlowtime.set");
	
	MarkNativeAsOptional("VSH2Player.flLastHit.get");
	MarkNativeAsOptional("VSH2Player.flLastHit.set");
	
	MarkNativeAsOptional("VSH2Player.flLastShot.get");
	MarkNativeAsOptional("VSH2Player.flLastShot.set");
	
	MarkNativeAsOptional("VSH2Player.iHealth.get");
	MarkNativeAsOptional("VSH2Player.iHealth.set");
	
	MarkNativeAsOptional("VSH2Player.iMaxHealth.get");
	MarkNativeAsOptional("VSH2Player.iMaxHealth.set");
	
	MarkNativeAsOptional("VSH2Player.iType.get");
	MarkNativeAsOptional("VSH2Player.iType.set");
	
	MarkNativeAsOptional("VSH2Player.iClimbs.get");
	MarkNativeAsOptional("VSH2Player.iClimbs.set");
	
	MarkNativeAsOptional("VSH2Player.iStabbed.get");
	MarkNativeAsOptional("VSH2Player.iStabbed.set");
	
	MarkNativeAsOptional("VSH2Player.iMarketted.get");
	MarkNativeAsOptional("VSH2Player.iMarketted.set");
	
	MarkNativeAsOptional("VSH2Player.iDifficulty.get");
	MarkNativeAsOptional("VSH2Player.iDifficulty.set");
	
	MarkNativeAsOptional("VSH2Player.bIsBoss.get");
	MarkNativeAsOptional("VSH2Player.bIsBoss.set");
	
	MarkNativeAsOptional("VSH2Player.bSetOnSpawn.get");
	MarkNativeAsOptional("VSH2Player.bSetOnSpawn.set");
	
	MarkNativeAsOptional("VSH2Player.bUsedUltimate.get");
	MarkNativeAsOptional("VSH2Player.bUsedUltimate.set");
	
	MarkNativeAsOptional("VSH2Player.flSpeed.get");
	MarkNativeAsOptional("VSH2Player.flSpeed.set");
	
	MarkNativeAsOptional("VSH2Player.flCharge.get");
	MarkNativeAsOptional("VSH2Player.flCharge.set");
	
	MarkNativeAsOptional("VSH2Player.flRAGE.get");
	MarkNativeAsOptional("VSH2Player.flRAGE.set");
	
	MarkNativeAsOptional("VSH2Player.flKillSpree.get");
	MarkNativeAsOptional("VSH2Player.flKillSpree.set");
	
	MarkNativeAsOptional("VSH2Player.flWeighDown.get");
	MarkNativeAsOptional("VSH2Player.flWeighDown.set");
	*/
}
#endif
