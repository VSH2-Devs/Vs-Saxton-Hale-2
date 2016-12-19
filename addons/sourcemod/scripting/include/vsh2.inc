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

	property int m_iQueue
	{
		public native get();
		public native set( const int queue );
	}
	property int m_iPresetType
	{
		public native get();
		public native set( const int bosstype );
	}
	property int m_iKills
	{
		public native get();
		public native set( const int kills )
	}
	property int m_iHits
	{
		public native get();
		public native set( const int hits );
	}
	property int m_iLives
	{
		public native get();
		public native set( const int lives );
	}
	property int m_iState
	{
		public native get();
		public native set( const int boss_state );
	}
	property int m_iDamage
	{
		public native get();
		public native set( const int damage );
	}
	property int m_iAirDamage
	{
		public native get();
		public native set( const int airstrike_damage );
	}
	property int m_iSongPick
	{
		public native get();
		public native set( const int song_index );
	}
	property int m_iHealTarget	/* returns -1 is there's no valid player */
	{
		public native get();
	}
	property int m_iOwnerBoss
	{
		public native get();
		public native set( const int boss_userid );
	}
	property int m_iUberTarget	/* please use userid on this; convert to client index if you want but userid is safer */
	{
		public native get();
		public native set( const int userid );
	}
	property int m_iGlow		/* use like a bool */
	{
		public native get();
		public native set( const int isGlow );
	}
	property bool m_bNearDispenser
	{
		public native get();
	}
	property bool m_bIsMinion
	{
		public native get();
		public native set( const bool is_minion );
	}
	property bool m_bInJump
	{
		public native get();
		public native set( const bool is_jumping );
	}

	property float m_flGlowtime
	{
		public native get();
		public native set( const float glowtime );
	}
	property float m_flLastHit
	{
		public native get();
		public native set( const float lasthit_time );
	}
	property float m_flLastShot
	{
		public native get();
		public native set( const float last_time_player_shot_something );
	}
	
	/* 	ALL PROPERTIES AFTER THIS COMMENT ONLY ACCOUNT FOR BOSSES BUT CAN STILL APPLY ON NON-BOSSES AND MINIONS 	 */
	property int m_iHealth
	{
		public native get();
		public native set( const int new_health );
	}
	property int m_iMaxHealth
	{
		public native get();
		public native set( const int new_maxhealth );
	}
	property int m_iType
	{
		public native get();
		public native set( const int boss_id );
	}
	property int m_iClimbs
	{
		public native get();
		public native set( const int climb_amount );
	}
	property int m_iStabbed
	{
		public native get();
		public native set( const int amount_of_times_stabbed );
	}
	property int m_iMarketted
	{
		public native get();
		public native set( const int amount_of_times_market_gardened );
	}
	property int m_iDifficulty
	{
		public native get();
		public native set( const int difficulty_setting );
	}

	property bool m_bIsBoss
	{
		public native get();
		public native set( const bool is_boss );
	}
	property bool m_bSetOnSpawn
	{
		public native get();
		public native set( const bool is_set_to_be_boss );
	}
	property bool m_bUsedUltimate	/* Not an overwatch reference lol; purpose is for a use-once ability but you can reset it */
	{
		public native get();
		public native set( const bool used_rare_ability );
	}

	property float m_flSpeed	/* if you boss needs a set amount of speed, use this obviously */
	{
		public native get();
		public native set( const float boss_speed );
	}
	property float m_flCharge
	{
		public native get();
		public native set( const float ability_charge );
	}
	property float m_flRAGE
	{
		public native get();
		public native set( const float hulk_smash_percent );
	}
	property float m_flKillSpree
	{
		public native get();
		public native set( const float time_boss_has_to_kill_alot );
	}
	property float m_flWeighDown
	{
		public native get();
		public native set( const float weight_percentage_charge );
	}
};


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
	MarkNativeAsOptional("VSH2Player.VSH2Player");
	MarkNativeAsOptional("VSH2Player.userid.get");
	MarkNativeAsOptional("VSH2Player.index.get");
	
	MarkNativeAsOptional("VSH2Player.m_iQueue.get");
	MarkNativeAsOptional("VSH2Player.m_iQueue.set");
	
	MarkNativeAsOptional("VSH2Player.m_iPresetType.get");
	MarkNativeAsOptional("VSH2Player.m_iPresetType.set");
	
	MarkNativeAsOptional("VSH2Player.m_iKills.get");
	MarkNativeAsOptional("VSH2Player.m_iKills.set");
	
	MarkNativeAsOptional("VSH2Player.m_iHits.get");
	MarkNativeAsOptional("VSH2Player.m_iHits.set");
	
	MarkNativeAsOptional("VSH2Player.m_iLives.get");
	MarkNativeAsOptional("VSH2Player.m_iLives.set");
	
	MarkNativeAsOptional("VSH2Player.m_iState.get");
	MarkNativeAsOptional("VSH2Player.m_iState.set");
	
	MarkNativeAsOptional("VSH2Player.m_iDamage.get");
	MarkNativeAsOptional("VSH2Player.m_iDamage.set");
	
	MarkNativeAsOptional("VSH2Player.m_iAirDamage.get");
	MarkNativeAsOptional("VSH2Player.m_iAirDamage.set");
	
	MarkNativeAsOptional("VSH2Player.m_iSongPick.get");
	MarkNativeAsOptional("VSH2Player.m_iSongPick.set");
	
	MarkNativeAsOptional("VSH2Player.m_iHealTarget.get");
	
	MarkNativeAsOptional("VSH2Player.m_iOwnerBoss.get");
	MarkNativeAsOptional("VSH2Player.m_iOwnerBoss.set");
	
	MarkNativeAsOptional("VSH2Player.m_iUberTarget.get");
	MarkNativeAsOptional("VSH2Player.m_iUberTarget.set");
	
	MarkNativeAsOptional("VSH2Player.m_iGlow.get");
	MarkNativeAsOptional("VSH2Player.m_iGlow.set");
	
	MarkNativeAsOptional("VSH2Player.m_bNearDispenser.get");
	
	MarkNativeAsOptional("VSH2Player.m_bIsMinion.get");
	MarkNativeAsOptional("VSH2Player.m_bIsMinion.set");
	
	MarkNativeAsOptional("VSH2Player.m_bInJump.get");
	MarkNativeAsOptional("VSH2Player.m_bInJump.set");
	
	MarkNativeAsOptional("VSH2Player.m_flGlowtime.get");
	MarkNativeAsOptional("VSH2Player.m_flGlowtime.set");
	
	MarkNativeAsOptional("VSH2Player.m_flLastHit.get");
	MarkNativeAsOptional("VSH2Player.m_flLastHit.set");
	
	MarkNativeAsOptional("VSH2Player.m_flLastShot.get");
	MarkNativeAsOptional("VSH2Player.m_flLastShot.set");
	
	MarkNativeAsOptional("VSH2Player.m_iHealth.get");
	MarkNativeAsOptional("VSH2Player.m_iHealth.set");
	
	MarkNativeAsOptional("VSH2Player.m_iMaxHealth.get");
	MarkNativeAsOptional("VSH2Player.m_iMaxHealth.set");
	
	MarkNativeAsOptional("VSH2Player.m_iType.get");
	MarkNativeAsOptional("VSH2Player.m_iType.set");
	
	MarkNativeAsOptional("VSH2Player.m_iClimbs.get");
	MarkNativeAsOptional("VSH2Player.m_iClimbs.set");
	
	MarkNativeAsOptional("VSH2Player.m_iStabbed.get");
	MarkNativeAsOptional("VSH2Player.m_iStabbed.set");
	
	MarkNativeAsOptional("VSH2Player.m_iMarketted.get");
	MarkNativeAsOptional("VSH2Player.m_iMarketted.set");
	
	MarkNativeAsOptional("VSH2Player.m_iDifficulty.get");
	MarkNativeAsOptional("VSH2Player.m_iDifficulty.set");
	
	MarkNativeAsOptional("VSH2Player.m_bIsBoss.get");
	MarkNativeAsOptional("VSH2Player.m_bIsBoss.set");
	
	MarkNativeAsOptional("VSH2Player.m_bSetOnSpawn.get");
	MarkNativeAsOptional("VSH2Player.m_bSetOnSpawn.set");
	
	MarkNativeAsOptional("VSH2Player.m_bUsedUltimate.get");
	MarkNativeAsOptional("VSH2Player.m_bUsedUltimate.set");
	
	MarkNativeAsOptional("VSH2Player.m_flSpeed.get");
	MarkNativeAsOptional("VSH2Player.m_flSpeed.set");
	
	MarkNativeAsOptional("VSH2Player.m_flCharge.get");
	MarkNativeAsOptional("VSH2Player.m_flCharge.set");
	
	MarkNativeAsOptional("VSH2Player.m_flRAGE.get");
	MarkNativeAsOptional("VSH2Player.m_flRAGE.set");
	
	MarkNativeAsOptional("VSH2Player.m_flKillSpree.get");
	MarkNativeAsOptional("VSH2Player.m_flKillSpree.set");
	
	MarkNativeAsOptional("VSH2Player.m_flWeighDown.get");
	MarkNativeAsOptional("VSH2Player.m_flWeighDown.set");
}
#endif
