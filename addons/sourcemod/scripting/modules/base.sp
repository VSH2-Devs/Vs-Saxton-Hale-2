int
	Health[PLYR],		/* Amount of health given to bosses */
	MaxHealth[PLYR],
	BossType[PLYR],		/* What kind of boss is player? */
	Kills[PLYR],		/* how many players killed by boss or bosses killed by player? */
	ClimbCount[PLYR],	/* self explanatory */
	Hits[PLYR],		/* How many times has the player been hit? */
	Lives[PLYR],		/* Same reason as Hits, Lives should never be under 0. Never heard of -1 lives lol */
	State[PLYR],		/* This is for bosses or players that change "state" for various mechanics */
	AmmoTable[2049],	/* saved max ammo size of the weapon */
	ClipTable[2049],	/* saved max clip size of the weapon */
	Damage[PLYR],		/* self explanatory */
	AirDamage[PLYR],	/* how much damage done by AirStrike soldier, perhaps replace this with static local variable in TakeDamage? */
	SongPick[PLYR],		/* Let bosses customize what Background theme music they want playing. */
	Queue[PLYR],		/* old Queue system but this array is a backup incase cookies haven't cached yet. */
	Stabbed[PLYR],		/* How many times player got backstabbed */
	Marketted[PLYR],	/* How many times player got market gardenned */
	UberTarget[PLYR],	/* userid of the uber'd client */
	PresetBossType[PLYR],	/* If the upcoming boss set their boss from SetBoss command, this array will hold that data */
	OwnerBoss[PLYR],	/* For use on minions, this allows us to get which boss actually created the minion that helps them */
	Difficulty[PLYR]
;

bool
	IsBoss[PLYR],		/* Is the player a boss? */
	IsToSpawnAsBoss[PLYR],	/* Is the player set to become a boss when they spawn? */
	IsMinion[PLYR],		/* Is the player a minion/zombie of a current boss? (Can be set on bosses but please don't, only use on players) */
	UsedUltimate[PLYR],	/* When a boss used a single-use only rage, can be reset, inb4 Overwatch bosses lol */
	InJump[PLYR]		/* when a player is currently in the air as a result of a rocket/sticky jump */
;

float
	fSpeed[PLYR],		/* self explanatory, Boss' movement speed */
	flRightClick[PLYR],	/* Basically the Crouch or Right click ability charge */
	flRage[PLYR],		/* meter for when boss taunts or calls medic */
	fKillSpree[PLYR],	/* When a boss meets a criteria for murdering in a single instance :) */
	WeighDown[PLYR],	/* meter for when boss is looking down while in the air and crouching */
	Glowtime[PLYR],
	LastHit[PLYR],		/* last time the player was hit */
	LastShot[PLYR],		/* last time player shot/fired their weapon */
	flHolstered[PLYR][3]	/* New mechanic for VSH 2, holster reloading for certain classes and weapons */
;

//	Gonna leave these here so we can reduce stack memory for calling boss specific Download function calls
public char snd[FULLPATH]; //How is this even used?
// Moved to stocks.inc
// public char extensions[][] = { ".mdl", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd", ".phy" };
// public char extensionsb[2][5] = { ".vtf", ".vmt" };

#define MAXMESSAGE	4096
public char gameMessage[MAXMESSAGE];	// Just incase...
public char BackgroundSong[FULLPATH];

methodmap BaseFighter	/* Player Interface that Opposing team and Boss team derives from */
/*
Property Organization
Ints
Bools
Floats
Misc properties
Methods
*/
{
	public BaseFighter(const int ind, bool uid=false)
	{
		int player=0;	// If you're using a userid and you know 100% it's valid, then set uid to true
		if (uid and GetClientOfUserId(ind) > 0)
			player = ( ind );
		else if ( IsClientValid(ind) )
			player = GetClientUserId(ind);
		return view_as< BaseFighter >( player );
	}
	///////////////////////////////

	/* [ P R O P E R T I E S ] */

	property int userid {
		public get()				{ return view_as< int >(this); }
	}
	property int index {
		public get()				{ return GetClientOfUserId( view_as< int >(this) ); }
	}
	property int iQueue
	{
		public get()
		{
			int player = this.index;
			if (!player)
				return 0;
			else if (not AreClientCookiesCached(player) or IsFakeClient(player))	// If the coookies aren't cached yet, use array
				return Queue[player];

			char strPoints[10];	// HOW WILL OUR QUEUE SURPRISE OVER 9 DIGITS?
			GetClientCookie(player, PointCookie, strPoints, sizeof(strPoints));
			Queue[player] = StringToInt(strPoints);
			return Queue[ player ];
		}
		public set( const int val )
		{
			int player = this.index;
			if (!player)
				return;
			else if (not AreClientCookiesCached(player) or IsFakeClient(player)) {
				Queue[player] = val;
				return;
			}
			Queue[player] = val;
			char strPoints[10];
			IntToString(Queue[player], strPoints, sizeof(strPoints));
			SetClientCookie(player, PointCookie, strPoints);
		}
	}
	property int iPresetType	// if cookies aren't cached, oh well!
	{
		public get()
		{
			int player = this.index;
			if (!player)
				return -1;
			if (not AreClientCookiesCached(player))
				return PresetBossType[player];
			char setboss[6];
			GetClientCookie(player, BossCookie, setboss, sizeof(setboss));
			PresetBossType[player] = StringToInt(setboss);
			return PresetBossType[player];
		}
		public set( const int val )
		{
			int player = this.index;
			if (!player)
				return;
			else if (not AreClientCookiesCached(player)) {
				PresetBossType[player] = val;
				return;
			}
			PresetBossType[player] = val;
			char setboss[6];
			IntToString(PresetBossType[player], setboss, sizeof(setboss));
			SetClientCookie(player, BossCookie, setboss);
		}
	}
	property int iKills
	{
		public get()				{ return Kills[ this.index ]; }
		public set( const int val )		{ Kills[ this.index ] = val; }
	}
	property int iHits
	{
		public get()
		{
			if (Hits[this.index] < 0)	// No unsigned integers yet, clamp Hits to 0 if under
				Hits[this.index] = 0;
			return Hits[ this.index ];
		}
		public set( const int val )		{ Hits[ this.index ] = val; }
	}
	property int iLives
	{
		public get()
		{
			if (Lives[this.index] < 0)
				Lives[this.index] = 0;
			return Lives[ this.index ];
		}
		public set( const int val )		{ Lives[ this.index ] = val; }
	}
	property int iState
	{
		public get()				{ return State[ this.index ]; }
		public set( const int val )		{ State[ this.index ] = val; }
	}
	property int iDamage
	{
		public get()				{ return Damage[ this.index ]; }
		public set( const int val )		{ Damage[ this.index ] = val; }
	}
	property int iAirDamage
	{
		public get()				{ return AirDamage[ this.index ]; }
		public set( const int val )		{ AirDamage[ this.index ] = val; }
	}
	property int iSongPick
	{
		public get()				{ return SongPick[ this.index ]; }
		public set( const int val )		{ SongPick[ this.index ] = val; }
	}
	property int iHealTarget
	{
		public get() {
			int medigun = GetPlayerWeaponSlot(this.index, TFWeaponSlot_Secondary);
			if (not IsValidEdict(medigun) or not IsValidEntity(medigun))
				return -1;
			char s[32]; GetEdictClassname(medigun, s, sizeof(s));
			if ( not strcmp(s, "tf_weapon_medigun", false) ) {
				if ( GetEntProp(medigun, Prop_Send, "m_bHealing") )
					return GetEntPropEnt( medigun, Prop_Send, "m_hHealingTarget" );
			}
			return -1;
		}
	}
	property int iOwnerBoss
	{
		public get()				{ return GetClientOfUserId(OwnerBoss[ this.index ]); }
		public set( const int val )		{ OwnerBoss[ this.index ] = val; }
	}
	property int iUberTarget	/* please use userid on this; convert to client index if you want but userid is safer */
	{
		public get()				{ return UberTarget[ this.index ]; }
		public set( const int val )		{ UberTarget[ this.index ] = val; }
	}
	property int bGlow
	{
		public get()			{ return GetEntProp(this.index, Prop_Send, "m_bGlowEnabled"); }
		public set( const int val )
		{
			int boolean = ( (val) ? 1 : 0 ) ;
			SetEntProp(this.index, Prop_Send, "m_bGlowEnabled", boolean);
		}
	}

	property bool bNearDispenser
	{
		public get() {
			int medics=0;
			for (int i=MaxClients ; i ; --i) {
				if (!IsValidClient(i))
					continue;
				if (GetHealingTarget(i) is this.index)
					medics++;
			}
			return (GetEntProp(this.index, Prop_Send, "m_nNumHealers") > medics);
		}
	}
	property bool bIsMinion
	{
		public get()				{ return IsMinion[ this.index ]; }
		public set( const bool val )		{ IsMinion[ this.index ] = val; }
	}
	property bool bInJump
	{
		public get()				{ return InJump[ this.index ]; }
		public set( const bool val )		{ InJump[ this.index ] = val; }
	}
	property bool bNoMusic
	{
		public get()
		{
			if (not AreClientCookiesCached(this.index))
				return false;
			char musical[6];
			GetClientCookie(this.index, MusicCookie, musical, sizeof(musical));
			return (StringToInt(musical) == 1);
		}
		public set( const bool val )
		{
			if (not AreClientCookiesCached(this.index))
				return;

			int value;
			if (val)
				value = 1;
			else value = 0;
			char musical[6];
			IntToString(value, musical, sizeof(musical));
			SetClientCookie(this.index, MusicCookie, musical);
		}
	}

	property float flGlowtime
	{
		public get()
		{
			if (Glowtime[ this.index ] < 0.0)
				Glowtime[ this.index ] = 0.0;
			return Glowtime[ this.index ];
		}
		public set( const float val )		{ Glowtime[ this.index ] = val; }
	}
	property float flLastHit
	{
		public get()				{ return LastHit[ this.index ]; }
		public set( const float val )		{ LastHit[ this.index ] = val; }
	}
	property float flLastShot
	{
		public get()				{ return LastShot[ this.index ]; }
		public set( const float val )		{ LastShot[ this.index ] = val; }
	}
	
	public void ConvertToMinion(const float time)
	{
		this.bIsMinion = true;
		SetPawnTimer(_MakePlayerMinion, time, this.userid);
	}
	/**
	 * creates and spawns a weapon to a player, regardless if boss or not
	 *
	 * @param name		entity name of the weapon, example: "tf_weapon_bat"
	 * @param index		the index of the desired weapon
	 * @param level		the level of the weapon
	 * @param qual		the weapon quality of the item
	 * @param att		the nested attribute string, example: "2 ; 2.0" - increases weapon damage by 100% aka 2x.
	 * @return		entity index of the newly created weapon
	 */
	public int SpawnWeapon(char[] name, const int index, const int level, const int qual, char[] att)
	{
		TF2Item hWep = new TF2Item(OVERRIDE_ALL|FORCE_GENERATION);
		if ( !hWep )
			return -1;

		hWep.SetClassname(name);
		hWep.iItemIndex = index;
		hWep.iLevel = level;
		hWep.iQuality = qual;
		char atts[32][32];
		int count = ExplodeString(att, " ; ", atts, 32, 32);
		if (count > 0) {
			hWep.iNumAttribs = count/2;
			int i2=0;
			for (int i=0 ; i<count ; i+=2) {
				hWep.SetAttribute( i2, StringToInt(atts[i]), StringToFloat(atts[i+1]) );
				i2++;
			}
		}
		else hWep.iNumAttribs = 0;

		int entity = hWep.GiveNamedItem(this.index);
		delete hWep;
		EquipPlayerWeapon(this.index, entity);
		return entity;
	}
	/**
	 * gets the max recorded ammo for a certain weapon index
	 *
	 * @param wepslot	the equipment slot of the player
	 * @return		the recorded max ammo of the weapon
	 */
	public int getAmmotable(const int wepslot)
	{
		int weapon = GetPlayerWeaponSlot(this.index, wepslot);
		if (weapon > MaxClients and IsValidEntity(weapon))
			return AmmoTable[weapon];
		return -1;
	}
	
	/**
	 * sets the max recorded ammo for a certain weapon index
	 *
	 * @param wepslot	the equipment slot of the player
	 * @param val		how much the new max ammo should be
	 * @noreturn
	 */
	public void setAmmotable(const int wepslot, const int val)
	{
		int weapon = GetPlayerWeaponSlot(this.index, wepslot);
		if (weapon > MaxClients and IsValidEntity(weapon))
			AmmoTable[weapon] = val;
	}
	/**
	 * gets the max recorded clipsize for a certain weapon index
	 *
	 * @param wepslot	the equipment slot of the player
	 * @return		the recorded clipsize ammo of the weapon
	 */
	public int getCliptable(const int wepslot)
	{
		int weapon = GetPlayerWeaponSlot(this.index, wepslot);
		if (weapon > MaxClients and IsValidEntity(weapon))
			return ClipTable[weapon];
		return -1;
	}
	
	/**
	 * sets the max recorded clipsize for a certain weapon index
	 *
	 * @param wepslot	the equipment slot of the player
	 * @param val		how much the new max clipsize should be
	 * @noreturn
	 */
	public void setCliptable(const int wepslot, const int val)
	{
		int weapon = GetPlayerWeaponSlot(this.index, wepslot);
		if (weapon > MaxClients and IsValidEntity(weapon))
			ClipTable[weapon] = val;
	}
	public int GetWeaponSlotIndex(const int slot)
	{
		int weapon = GetPlayerWeaponSlot(this.index, slot);
		return GetItemIndex(weapon);
	}
	public void SetWepInvis(const int alpha)
	{
		int transparent = alpha;
		int entity;
		for (int i=0; i<5; i++) {
			entity = GetPlayerWeaponSlot(this.index, i); 
			if ( IsValidEdict(entity) and IsValidEntity(entity) )
			{
				if (transparent > 255)
					transparent = 255;
				if (transparent < 0)
					transparent = 0;
				SetEntityRenderMode(entity, RENDER_TRANSCOLOR); 
				SetEntityRenderColor(entity, 150, 150, 150, transparent); 
			}
		}
	}
	public void SetOverlay(const char[] strOverlay)
	{
		int iFlags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
		SetCommandFlags("r_screenoverlay", iFlags);
		ClientCommand(this.index, "r_screenoverlay \"%s\"", strOverlay);
	}
	public void TeleToSpawn(int team = 0)	// Props to Chdata!
	{
		int iEnt = -1;
		float vPos[3], vAng[3];
		ArrayList hArray = new ArrayList();
		while ((iEnt = FindEntityByClassname(iEnt, "info_player_teamspawn")) not_eq -1)
		{
			if (team <= 1)
				hArray.Push(iEnt);
			else {
				if (GetEntProp(iEnt, Prop_Send, "m_iTeamNum") is team)
					hArray.Push(iEnt);
			}
		}
		iEnt = hArray.Get( GetRandomInt(0, hArray.Length-1) );
		delete hArray;

		// Technically you'll never find a map without a spawn point. Not a good map at least.
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
		GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);
		TeleportEntity(this.index, vPos, vAng, nullvec);

		/*if (Special == VSHSpecial_HHH) //reserved for HHH boss
		{
			CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(iEnt, "ghost_appearation", _, false)));
			EmitSoundToAll("misc/halloween/spell_teleport.wav", _, _, SNDLEVEL_GUNFIRE, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, vPos, nullvec, false, 0.0);
		}*/
	}
	public void IncreaseHeadCount()
	{
		if (not TF2_IsPlayerInCondition(this.index, TFCond_DemoBuff))
			TF2_AddCondition(this.index, TFCond_DemoBuff, -1.0);
		int heads = GetEntProp(this.index, Prop_Send, "m_iDecapitations");
		SetEntProp(this.index, Prop_Send, "m_iDecapitations", ++heads);
		int health = GetClientHealth(this.index);
		//health += (decapitations >= 4 ? 10 : 15);
		if ( health < 300 )
			health += 15;
		SetEntProp(this.index, Prop_Data, "m_iHealth", health);
		SetEntProp(this.index, Prop_Send, "m_iHealth", health);
		TF2_AddCondition(this.index, TFCond_SpeedBuffAlly, 0.01);   //recalc their speed
	}
	public void SpawnSmallHealthPack(int ownerteam=0)
	{
		if (not IsValidClient(this.index) or not IsPlayerAlive(this.index))
			return;
		int healthpack = CreateEntityByName("item_healthkit_small");
		if ( IsValidEntity(healthpack) ) {
			float pos[3]; GetClientAbsOrigin(this.index, pos);
			pos[2] += 20.0;
			DispatchKeyValue(healthpack, "OnPlayerTouch", "!self,Kill,,0,-1");  //for safety, though it normally doesn't respawn
			DispatchSpawn(healthpack);
			SetEntProp(healthpack, Prop_Send, "m_iTeamNum", ownerteam, 4);
			SetEntityMoveType(healthpack, MOVETYPE_VPHYSICS);
			float vel[3];
			vel[0] = float(GetRandomInt(-10, 10)), vel[1] = float(GetRandomInt(-10, 10)), vel[2] = 50.0;
			TeleportEntity(healthpack, pos, NULL_VECTOR, vel);
			//CreateTimer(17.0, Timer_RemoveCandycaneHealthPack, EntIndexToEntRef(healthpack), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	public void ForceTeamChange(const int team)
	{
		// Living Spectator Bug:
		// If you force a player onto a team with their tfclass not set, they'll appear as a "living" spectator
		if (TF2_GetPlayerClass(this.index) > TFClass_Unknown) {
			SetEntProp(this.index, Prop_Send, "m_lifeState", 2);
			ChangeClientTeam(this.index, team);
			SetEntProp(this.index, Prop_Send, "m_lifeState", 0);
			TF2_RespawnPlayer(this.index);
		}
	}
	public void ClimbWall(const int weapon, const float upwardvel, const float health, const bool attackdelay)
	//Credit to Mecha the Slag
	{
		if ( GetClientHealth(this.index) <= health )	// Have to baby players so they don't accidentally kill themselves trying to escape
			return;

		int client = this.index;
		char classname[64];
		float vecClientEyePos[3];
		float vecClientEyeAng[3];
		GetClientEyePosition(client, vecClientEyePos);   // Get the position of the player's eyes
		GetClientEyeAngles(client, vecClientEyeAng);	   // Get the angle the player is looking

		//Check for colliding entities
		TR_TraceRayFilter(vecClientEyePos, vecClientEyeAng, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);

		if ( not TR_DidHit(null) )
			return;

		int TRIndex = TR_GetEntityIndex(null);
		GetEdictClassname(TRIndex, classname, sizeof(classname));
		if (not StrEqual(classname, "worldspawn"))
			return;

		float fNormal[3];
		TR_GetPlaneNormal(null, fNormal);
		GetVectorAngles(fNormal, fNormal);

		if (fNormal[0] >= 30.0 && fNormal[0] <= 330.0)
			return;
		if (fNormal[0] <= -30.0)
			return;

		float pos[3]; TR_GetEndPosition(pos);
		float distance = GetVectorDistance(vecClientEyePos, pos);

		if (distance >= 100.0)
			return;

		float fVelocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
		fVelocity[2] = upwardvel;

		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
		SDKHooks_TakeDamage(client, client, client, health, DMG_CLUB, GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));

		if (attackdelay)
			SetPawnTimer(NoAttacking, 0.1, EntIndexToEntRef(weapon));
	}
	public void HelpPanelClass()
	{
		if ( IsVoteInProgress() )
			return ;
		char helpstr[512];
		switch (TF2_GetPlayerClass(this.index))
		{
			case TFClass_Scout:	Format(helpstr, sizeof(helpstr), "Scout:\nThe Crit-a-Cola grants criticals instead of minicrits.\nThe Fan O' War removes 5pct rage on hit.\nPistols gain minicrits.\nCandycane drops a health pack on hit.\nMedics healing you get a speed-buff.\nSun-on-a-Stick puts Boss on fire.\nBackscatter crits whenever it would minicrit.");
			case TFClass_Soldier:	Format(helpstr, sizeof(helpstr), "Soldier:\nThe Battalion's Backup nerfs Boss damage.\nThe Half-Zatoichi heals 35HP on hit + can overheal to +25. Honorbound is removed on hit.\nShotguns minicrit Boss in midair + lower rocketjump damage.\nDirect Hit crits when it would minicrit.\nReserve Shooter has faster weapon switch + damage buff.\nMantreads create greater rocketjumps + negates fall damage.\nRocketJumper replaced with stock Rocket Launcher.");
			case TFClass_Pyro:	Format(helpstr, sizeof(helpstr), "Pyro:\nThe Flare Gun is replaced by the MegaDetonator.\nAirblasting Bosses builds Rage and lengthens the Vagineer's uber.\nThird Degree gains uber for healers on hit.\nBackburner has Chargeable airblast.\nMannmelter crits do extra damage.");
			case TFClass_DemoMan:	Format(helpstr, sizeof(helpstr), "Demoman:\nThe shields block at least one hit from Boss melees.\nUsing shields grants crits on all weapons.\nEyelander/reskins gain heads on hit.\nHalf-Zatoichi heals 35HP on hit and can overheal to +25. Honorbound is removed on hit.\nPersian Persuader gives 2x reserve ammo.\nBoots do stomp damage.\nLoch-n-Load does afterburn on hit.\nGrenade Launcher & Cannon reduces explosive jumping if the weapon is active.\nStickyJumper replaced with Sticky Launcher.\nDecapitator taunt gives 4 heads if Successful.");
			case TFClass_Heavy:	Format(helpstr, sizeof(helpstr), "Heavy:\nNatascha, the KGB, and the Fists of Steel are replaced with the\nRocket Natascha, Gloves of Running, and Fists, respectively.\nThe Gloves of Running are fast but cause you to take more damage.\nThe Holiday Punch will remove any stun on you if you hit Hale while stunned.\nMiniguns get +25% damage boost when being healed by a medic.\nShotguns give damage back as health.\n");
			case TFClass_Engineer:	Format(helpstr, sizeof(helpstr), "Engineer:\nWrenches give an extra +25HP.\nGunslinger gives +55HP\nThe Frontier Justice gains crits only while your sentry is targetting Hale.\nThe Eureka Effect is disabled for now.\nTelefrags kill Bosses in one shot.");
			case TFClass_Medic:	Format(helpstr, sizeof(helpstr), "Medic:\nCharge: Kritz+Uber+Ammo. Charge starts at 40percent.\nCharge lasts for 150 percent after activation.\nSyringe Guns: on hit: +5 to Uber.\nCrossbow: 100 percent crits, +150pct damage, +15 uber on hit.\nUber gives patient infinite ammo until Uber is depleted.\nhaving 90% or higher Uber protects you from one Melee hit from Boss.\nBlutsauger + Overdose are Unlocked + give 1 pct Uber on hit.\nHealing Heavies give them damage boost on Miniguns.");
			case TFClass_Sniper:	Format(helpstr, sizeof(helpstr), "Sniper:\nJarate removes small pct of Boss Rage.\nBack-equipped weapons are replaced with SMG.\nSniper Rifles causes Certain Bosses to glow. Glow time scales with charge.\nAll Sniper melees climb walls, but has slower rate of fire.\nHuntsman carries 2x more ammo.\n");
			case TFClass_Spy:	Format(helpstr, sizeof(helpstr), "Spy:\nBackstab does about 10+ percent of a Boss' max HP.\nCloaknDagger replaced with normal inviswatch.\nAll revolvers minicrit.\nYour Eternal Reward backstabs will disguise you.\nKunai backstabs will get you a health bonus.\nSappers are replaced with NailGun.\nDiamondback gets 2 crits on backstab.\nBig Earner gives full Cloak on backstab.\nAmbassador headshots do extra damage.");
		}
		Panel panel = new Panel();
		panel.SetTitle (helpstr);
		panel.DrawItem( "Exit" );
		panel.Send(this.index, HintPanel, 20);
		delete (panel);
	}
};

methodmap BaseBoss < BaseFighter
/* the methodmap/interface for all bosses to use. Use this if you're making a totally different boss
Property Organization
Ints
Bools
Floats
Methods
*/
{
	public BaseBoss(const int ind, bool uid=false)
	{
		return view_as< BaseBoss >( BaseFighter(ind, uid) );
	}
	///////////////////////////////
	/* [ P R O P E R T I E S ] */

	property int iHealth
	{
		public get()
		{
			if (Health[ this.index ] < 0)
				Health[ this.index ] = 0;
			return Health[ this.index ];
		}
		public set( const int val )		{ Health[ this.index ] = val; }
	}
	property int iMaxHealth
	{
		public get()				{ return MaxHealth[ this.index ]; }
		public set( const int val )		{ MaxHealth[ this.index ] = val; }
	}
	property int iType
	{
		public get()				{ return BossType[ this.index ]; }
		public set( const int val )		{ BossType[ this.index ] = val; }
	}
	property int iClimbs
	{
		public get()				{ return ClimbCount[ this.index ]; }
		public set( const int val )		{ ClimbCount[ this.index ] = val; }
	}
	property int iStabbed
	{
		public get()				{ return Stabbed[ this.index ]; }
		public set( const int val )		{ Stabbed[ this.index ] = val; }
	}
	property int iMarketted
	{
		public get()				{ return Marketted[ this.index ]; }
		public set( const int val )		{ Marketted[ this.index ] = val; }
	}
	property int iDifficulty
	{
		public get()				{ return Difficulty[ this.index ]; }
		public set( const int val )		{ Difficulty[ this.index ] = val; }
	}

	property bool bIsBoss
	{
		public get()				{ return IsBoss[ this.index ]; }
		public set( const bool val )		{ IsBoss[ this.index ] = val; }
	}
	property bool bSetOnSpawn
	{
		public get()				{ return IsToSpawnAsBoss[ this.index ]; }
		public set( const bool val )		{ IsToSpawnAsBoss[ this.index ] = val; }
	}
	property bool bUsedUltimate
	{
		public get()				{ return UsedUltimate[ this.index ]; }
		public set( const bool val )		{ UsedUltimate[ this.index ] = val; }
	}

	property float flSpeed
	{
		public get()				{ return fSpeed[ this.index ]; }
		public set( const float val )		{ fSpeed[ this.index ] = val; }
	}
	property float flCharge
	{
		public get()				{ return flRightClick[ this.index ]; }
		public set( const float val )		{ flRightClick[ this.index ] = val; }
	}
	property float flRAGE
	{
		public get() {		/* Rage should never exceed or "inceed" 0.0 and 100.0 */
			if (flRage[ this.index ] > 100.0)
				flRage[ this.index ] = 100.0;
			else if (flRage[ this.index ] < 0.0)
				flRage[ this.index ] = 0.0;
			return flRage[ this.index ];
		}
		public set( const float val )		{ flRage[ this.index ] = val; }
	}
	property float flKillSpree
	{
		public get()				{ return fKillSpree[ this.index ]; }
		public set( const float val )		{ fKillSpree[ this.index ] = val; }
	}
	property float flWeighDown
	{
		public get()				{ return WeighDown[ this.index ]; }
		public set( const float val )		{ WeighDown[ this.index ] = val; }
	}

	public void ConvertToBoss()
	{
		this.bIsBoss = this.bSetOnSpawn;
		this.flRAGE = 0.0;
		SetPawnTimer(_MakePlayerBoss, 0.1, this.userid);
	}

	public void GiveRage(const int damage)
	{
		this.flRAGE += ( damage/SquareRoot(float(this.iHealth))*4.0 );
	}
	public void MakeBossAndSwitch(const int type, const bool callEvent)
	{
		this.bSetOnSpawn = true;
		this.iType = type;
		if (callEvent)
			ManageOnBossSelected(this);
		this.ConvertToBoss();
		if (GetClientTeam(this.index) is RED)
			this.ForceTeamChange(BLU);
	}
};


public int HintPanel(Menu menu, MenuAction action, int param1, int param2)
{
	if ( not IsValidClient(param1) )
		return;
	return;
}
//	EOF
