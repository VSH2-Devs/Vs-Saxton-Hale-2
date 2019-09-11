int Munitions[PLYR][2][2];    /// first index obviously player, slot, ammo-0, clip-1

/// Gonna leave these here so we can reduce stack memory for calling boss specific Download function calls
public char snd[FULLPATH]; /// How is this even used?

/// Moved to stocks.inc
// public char extensions[][] = { ".mdl", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd", ".phy" };
// public char extensionsb[2][5] = { ".vtf", ".vmt" };

#define MAXMESSAGE	512
public char gameMessage[MAXMESSAGE];    /// Just incase...
public char BackgroundSong[FULLPATH];


/**
When making new properties, remember to base it off this StringMap AND do NOT forget to initialize it in OnClientPutInServer()
*/
StringMap hPlayerFields[PLYR];

methodmap BaseFighter {	/** Player Interface that Opposing team and Boss team derives from */
/**
 * Property Organization
 * Ints
 * Bools
 * Floats
 * Misc properties
 * Methods
 */
	public BaseFighter(const int ind, bool uid=false) {
		int player=0;	/// If you're using a userid and you know 100% it's valid, then set uid to true
		if( uid && GetClientOfUserId(ind) > 0 )
			player = ( ind );
		else if( IsClientValid(ind) )
			player = GetClientUserId(ind);
		return view_as< BaseFighter >( player );
	}
	///////////////////////////////
	
	/** [ P R O P E R T I E S ] */
	
	property int userid {
		public get() { return view_as< int >(this); }
	}
	property int index {
		public get() { return GetClientOfUserId( view_as< int >(this) ); }
	}
	property int iQueue {
		public get() {
			int player = this.index;
			if( !player )
				return 0;
			else if( !AreClientCookiesCached(player) || IsFakeClient(player) ) {	/// If the coookies aren't cached yet, use array
				int i; hPlayerFields[player].GetValue("iQueue", i);
				return i;
			}
			char strPoints[10];	/// HOW WILL OUR QUEUE SURPASS OVER 9 DIGITS?
			GetClientCookie(player, PointCookie, strPoints, sizeof(strPoints));
			int points = StringToInt(strPoints);
			hPlayerFields[player].SetValue("iQueue", points);
			return points;
		}
		public set( const int val ) {
			int player = this.index;
			if( !player )
				return;
			else if( !AreClientCookiesCached(player) || IsFakeClient(player) ) {
				hPlayerFields[player].SetValue("iQueue", val);
				return;
			}
			hPlayerFields[player].SetValue("iQueue", val);
			char strPoints[10];
			IntToString(val, strPoints, sizeof(strPoints));
			SetClientCookie(player, PointCookie, strPoints);
		}
	}
	property int iPresetType {    /// if cookies aren't cached, oh well!
		public get() {
			int player = this.index;
			if( !player )
				return -1;
			if( !AreClientCookiesCached(player) ) {
				int i; hPlayerFields[player].GetValue("iPresetType", i);
				return i;
			}
			char setboss[6];
			GetClientCookie(player, BossCookie, setboss, sizeof(setboss));
			int bossType = StringToInt(setboss);
			hPlayerFields[player].SetValue("iPresetType", bossType);
			return bossType;
		}
		public set( const int val ) {
			int player = this.index;
			if( !player )
				return;
			else if( !AreClientCookiesCached(player) ) {
				hPlayerFields[player].SetValue("iPresetType", val);
				return;
			}
			hPlayerFields[player].SetValue("iPresetType", val);
			char setboss[6];
			IntToString(val, setboss, sizeof(setboss));
			SetClientCookie(player, BossCookie, setboss);
		}
	}
	property int iKills {
		public get() {
			int i; hPlayerFields[this.index].GetValue("iKills", i);
			return i;
		}
		public set( const int val ) {
			hPlayerFields[this.index].SetValue("iKills", val);
		}
	}
	property int iHits {
		public get() {
			int i; hPlayerFields[this.index].GetValue("iHits", i);
			return i;
		}
		public set( const int val ) {
			hPlayerFields[this.index].SetValue("iHits", ( val>=0 ) ? val : 0);
		}
	}
	property int iLives {
		public get() {
			int i; hPlayerFields[this.index].GetValue("iLives", i);
			return i;
		}
		public set( const int val ) {
			hPlayerFields[this.index].SetValue("iLives", ( val>=0 ) ? val : 0);
		}
	}
	property int iState {
		public get() {
			int i; hPlayerFields[this.index].GetValue("iState", i);
			return i;
		}
		public set( const int val ) {
			hPlayerFields[this.index].SetValue("iState", val);
		}
	}
	property int iDamage {
		public get() {
			int i; hPlayerFields[this.index].GetValue("iDamage", i);
			return i;
		}
		public set( const int val ) {
			hPlayerFields[this.index].SetValue("iDamage", val);
		}
	}
	property int iAirDamage {
		public get() {
			int i; hPlayerFields[this.index].GetValue("iAirDamage", i);
			return i;
		}
		public set( const int val ) {
			hPlayerFields[this.index].SetValue("iAirDamage", val);
		}
	}
	property int iSongPick {
		public get() {
			int i; hPlayerFields[this.index].GetValue("iSongPick", i);
			return i;
		}
		public set( const int val ) {
			hPlayerFields[this.index].SetValue("iSongPick", val);
		}
	}
	property int iOwnerBoss {
		public get() {
			int i; hPlayerFields[this.index].GetValue("iOwnerBoss", i);
			return GetClientOfUserId(i);
		}
		public set( const int val ) {
			hPlayerFields[this.index].SetValue("iOwnerBoss", val);
		}
	}
	property int iUberTarget {    /** please use userid on this; convert to client index if you want but userid is safer */
		public get() {
			int i; hPlayerFields[this.index].GetValue("iUberTarget", i);
			return i;
		}
		public set( const int val ) {
			hPlayerFields[this.index].SetValue("iUberTarget", val);
		}
	}
	property int bGlow {
		public get() {
			int i; hPlayerFields[this.index].GetValue("bGlow", i);
			return i;
		}
		public set( const int val ) {
			hPlayerFields[this.index].SetValue("bGlow", val);
			SetEntProp(this.index, Prop_Send, "m_bGlowEnabled", val);
		}
	}
	property int iShieldDmg {
		public get() {
			int i; hPlayerFields[this.index].GetValue("iShieldDmg", i);
			return i;
		}
		public set( const int val ) {
			hPlayerFields[this.index].SetValue("iShieldDmg", val);
		}
	}
	
	property bool bIsMinion {
		public get() {
			bool i; hPlayerFields[this.index].GetValue("bIsMinion", i);
			return i;
		}
		public set( const bool val ) {
			hPlayerFields[this.index].SetValue("bIsMinion", val);
		}
	}
	property bool bInJump {
		public get() {
			bool i; hPlayerFields[this.index].GetValue("bInJump", i);
			return i;
		}
		public set( const bool val ) {
			hPlayerFields[this.index].SetValue("bInJump", val);
		}
	}
	property bool bNoMusic {
		public get() {
			if( !AreClientCookiesCached(this.index) )
				return false;
			char musical[6];
			GetClientCookie(this.index, MusicCookie, musical, sizeof(musical));
			return( StringToInt(musical) == 1 );
		}
		public set( const bool val ) {
			if( !AreClientCookiesCached(this.index) )
				return;
			char musical[6];
			IntToString(( val ) ? 1 : 0, musical, sizeof(musical));
			SetClientCookie(this.index, MusicCookie, musical);
		}
	}

	property float flGlowtime {
		public get() {
			float i; hPlayerFields[this.index].GetValue("flGlowtime", i);
			if( i<0.0 )
				i = 0.0;
			return i;
		}
		public set( const float val ) {
			hPlayerFields[this.index].SetValue("flGlowtime", val);
		}
	}
	property float flLastHit {
		public get() {
			float i; hPlayerFields[this.index].GetValue("flLastHit", i);
			return i;
		}
		public set( const float val ) {
			hPlayerFields[this.index].SetValue("flLastHit", val);
		}
	}
	property float flLastShot {
		public get() {
			float i; hPlayerFields[this.index].GetValue("flLastShot", i);
			return i;
		}
		public set( const float val ) {
			hPlayerFields[this.index].SetValue("flLastShot", val);
		}
	}
	
	
	public void ConvertToMinion(const float time) {
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
	 * @param att		the nested attribute string, example: "2; 2.0" - increases weapon damage by 100% aka 2x.
	 * @return		entity index of the newly created weapon
	 */
	public int SpawnWeapon(char[] name, const int index, const int level, const int qual, char[] att)
	{
		TF2Item hWep = new TF2Item(OVERRIDE_ALL|FORCE_GENERATION);
		if( !hWep )
			return -1;
		
		hWep.SetClassname(name);
		hWep.iItemIndex = index;
		hWep.iLevel = level;
		hWep.iQuality = qual;
		char atts[32][32];
		int count = ExplodeString(att, "; ", atts, 32, 32);
		
		/// odd numbered attributes result in an error, remove the 1st bit so count will always be even.
		count &= ~1;
		if( count > 0 ) {
			hWep.iNumAttribs = count / 2;
			int i2=0;
			for( int i=0; i<count; i+=2 ) {
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
	public int getAmmotable(const int wepslot) {
		return( wepslot > -1 && wepslot < 2 ) ? Munitions[this.index][wepslot][0] : 0;
	}
	
	/**
	 * sets the max recorded ammo for a certain weapon index
	 *
	 * @param wepslot	the equipment slot of the player
	 * @param val		how much the new max ammo should be
	 * @noreturn
	 */
	public void setAmmotable(const int wepslot, const int val) {
		if( wepslot < 0 || wepslot > 1 )
			return;
		Munitions[this.index][wepslot][0] = val;
	}
	/**
	 * gets the max recorded clipsize for a certain weapon index
	 *
	 * @param wepslot	the equipment slot of the player
	 * @return		the recorded clipsize ammo of the weapon
	 */
	public int getCliptable(const int wepslot) {
		return( wepslot > -1 && wepslot < 2 ) ? Munitions[this.index][wepslot][1] : 0;
	}
	
	/**
	 * sets the max recorded clipsize for a certain weapon index
	 *
	 * @param wepslot	the equipment slot of the player
	 * @param val		how much the new max clipsize should be
	 * @noreturn
	 */
	public void setCliptable(const int wepslot, const int val) {
		if( wepslot < 0 || wepslot > 1 )
			return;
		Munitions[this.index][wepslot][1] = val;
	}
	public int GetWeaponSlotIndex(const int slot) {
		int weapon = GetPlayerWeaponSlot(this.index, slot);
		return GetItemIndex(weapon);
	}
	public void SetWepInvis(const int alpha) {
		int transparent = alpha;
		for( int i=0; i<5; i++ ) {
			int entity = GetPlayerWeaponSlot(this.index, i); 
			if( IsValidEdict(entity) && IsValidEntity(entity) ) {
				if( transparent > 255 )
					transparent = 255;
				if( transparent < 0 )
					transparent = 0;
				SetEntityRenderMode(entity, RENDER_TRANSCOLOR); 
				SetEntityRenderColor(entity, 150, 150, 150, transparent); 
			}
		}
	}
	public void SetOverlay(const char[] strOverlay) {
		int iFlags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
		SetCommandFlags("r_screenoverlay", iFlags);
		ClientCommand(this.index, "r_screenoverlay \"%s\"", strOverlay);
	}
	public void TeleToSpawn(int team = 0)    /// Props to Chdata!
	{
		int iEnt = -1;
		float vPos[3], vAng[3];
		ArrayList hArray = new ArrayList();
		while( (iEnt = FindEntityByClassname(iEnt, "info_player_teamspawn")) != -1 ) {
			if( team <= 1 )
				hArray.Push(iEnt);
			else {
				if( GetEntProp(iEnt, Prop_Send, "m_iTeamNum") == team )
					hArray.Push(iEnt);
			}
		}
		iEnt = hArray.Get( GetRandomInt(0, hArray.Length-1) );
		delete hArray;
		
		/// Technically you'll never find a map without a spawn point. Not a good map at least.
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
		GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);
		TeleportEntity(this.index, vPos, vAng, NULL_VEC);
	}
	public void IncreaseHeadCount() {
		if( !TF2_IsPlayerInCondition(this.index, TFCond_DemoBuff) )
			TF2_AddCondition(this.index, TFCond_DemoBuff, -1.0);
		
		int heads = GetEntProp(this.index, Prop_Send, "m_iDecapitations");
		SetEntProp(this.index, Prop_Send, "m_iDecapitations", ++heads);
		int health = GetClientHealth(this.index);
		//health += (decapitations >= 4 ? 10 : 15);
		if( health < 300 )
			health += 15; /// <-- TODO: cvar this?
		SetEntProp(this.index, Prop_Data, "m_iHealth", health);
		SetEntProp(this.index, Prop_Send, "m_iHealth", health);
		TF2_AddCondition(this.index, TFCond_SpeedBuffAlly, 0.01);   /// recalc their speed
	}
	public void SpawnSmallHealthPack(int ownerteam=0)
	{
		if( !IsValidClient(this.index) || !IsPlayerAlive(this.index) )
			return;
		int healthpack = CreateEntityByName("item_healthkit_small");
		if( IsValidEntity(healthpack) ) {
			float pos[3]; GetClientAbsOrigin(this.index, pos);
			pos[2] += 20.0;
			DispatchKeyValue(healthpack, "OnPlayerTouch", "!self,Kill,,0,-1");  /// for safety, though it normally doesn't respawn
			DispatchSpawn(healthpack);
			SetEntProp(healthpack, Prop_Send, "m_iTeamNum", ownerteam, 4);
			SetEntityMoveType(healthpack, MOVETYPE_VPHYSICS);
			float vel[3];
			vel[0] = float(GetRandomInt(-10, 10)), vel[1] = float(GetRandomInt(-10, 10)), vel[2] = 50.0;
			TeleportEntity(healthpack, pos, NULL_VECTOR, vel);
			//CreateTimer(17.0, Timer_RemoveCandycaneHealthPack, EntIndexToEntRef(healthpack), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	public void ForceTeamChange(const int team) {
		/// Living Spectator Bug:
		/// If you force a player onto a team with their tfclass not set, they'll appear as a "living" spectator
		if( TF2_GetPlayerClass(this.index) > TFClass_Unknown ) {
			SetEntProp(this.index, Prop_Send, "m_lifeState", 2);
			ChangeClientTeam(this.index, team);
			SetEntProp(this.index, Prop_Send, "m_lifeState", 0);
			TF2_RespawnPlayer(this.index);
		}
	}
	public void ClimbWall(const int weapon, const float upwardvel, const float health, const bool attackdelay)
	/// Credit to Mecha the Slag
	{
		/// Have to baby players so they don't accidentally kill themselves trying to escape...
		if( GetClientHealth(this.index) <= health )
			return;
		
		int client = this.index;
		
		float vecClientEyePos[3];
		GetClientEyePosition(client, vecClientEyePos);   /// Get the position of the player's eyes
		
		float vecClientEyeAng[3];
		GetClientEyeAngles(client, vecClientEyeAng);     /// Get the angle the player is looking
		
		/// Check for colliding entities
		TR_TraceRayFilter(vecClientEyePos, vecClientEyeAng, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);
		
		if( !TR_DidHit(null) )
			return;
		
		char classname[64];
		int TRIndex = TR_GetEntityIndex(null);
		GetEdictClassname(TRIndex, classname, sizeof(classname));
		if( !StrEqual(classname, "worldspawn") )
			return;
		
		float fNormal[3];
		TR_GetPlaneNormal(null, fNormal);
		GetVectorAngles(fNormal, fNormal);
		
		if( fNormal[0] >= 30.0 && fNormal[0] <= 330.0 )
			return;
		if( fNormal[0] <= -30.0 )
			return;
		
		float pos[3]; TR_GetEndPosition(pos);
		float distance = GetVectorDistance(vecClientEyePos, pos);
		
		if( distance >= 100.0 )
			return;
		
		float fVelocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
		fVelocity[2] = upwardvel;
		
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
		SDKHooks_TakeDamage(client, client, client, health, DMG_CLUB, GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));
		
		if( attackdelay )
			SetPawnTimer(NoAttacking, 0.1, EntIndexToEntRef(weapon));
	}
	public void HelpPanelClass()
	{
		if( IsVoteInProgress() )
			return;
		char helpstr[512];
		switch( TF2_GetPlayerClass(this.index) ) {
			case TFClass_Scout: Format(helpstr, sizeof(helpstr), "Scout:\nThe Crit-a-Cola grants criticals instead of minicrits.\nThe Fan O' War removes 5pct rage on hit.\nPistols gain minicrits.\nCandycane drops a health pack on hit.\nMedics healing you get a speed-buff.\nSun-on-a-Stick puts Boss on fire.\nBackscatter crits whenever it would minicrit.");
			case TFClass_Soldier: Format(helpstr, sizeof(helpstr), "Soldier:\nThe Battalion's Backup nerfs Boss damage.\nThe Half-Zatoichi heals 35HP on hit + can overheal to +25. Honorbound is removed on hit.\nShotguns minicrit Boss in midair + lower rocketjump damage.\nDirect Hit crits when it would minicrit.\nReserve Shooter has faster weapon switch + damage buff.\nGunboats blocks 75% of rocket jump dmg.\nMantreads create greater rocketjumps + negates fall damage.\nRocketJumper replaced with stock Rocket Launcher.");
			case TFClass_Pyro: Format(helpstr, sizeof(helpstr), "Pyro:\nThe Flare Gun is replaced by the MegaDetonator.\nAirblasting Bosses builds Rage and lengthens the Vagineer's uber.\nThird Degree gains uber for healers on hit.\nBackburner has Chargeable airblast.\nMannmelter crits do extra damage.");
			case TFClass_DemoMan: Format(helpstr, sizeof(helpstr), "Demoman:\nThe shields block at least one hit from Boss melees.\nUsing shields grants crits on all weapons.\nEyelander/reskins gain heads on hit.\nHalf-Zatoichi heals 35HP on hit and can overheal to +25. Honorbound is removed on hit.\nPersian Persuader gives 2x reserve ammo.\nBoots do stomp damage.\nLoch-n-Load does afterburn on hit.\nGrenade Launcher & Cannon reduces explosive jumping if the weapon is active.\nStickyJumper replaced with Sticky Launcher.\nDecapitator taunt gives 4 heads if Successful.");
			case TFClass_Heavy: Format(helpstr, sizeof(helpstr), "Heavy:\nthe KGB, and the Fists of Steel are replaced with the\nGloves of Running, and Fists, respectively.\nThe Gloves of Running are fast but cause you to take more damage.\nThe Holiday Punch will remove any stun on you if you hit Hale while stunned.\nMiniguns get +25% damage boost when being healed by a medic.\nShotguns give damage back as health.\n");
			case TFClass_Engineer: Format(helpstr, sizeof(helpstr), "Engineer:\nWrenches give an extra +25HP.\nGunslinger gives +55HP\nThe Frontier Justice gains crits only while your sentry is targetting Hale.\nThe Eureka Effect is disabled for now.\nTelefrags kill Bosses in one shot.");
			case TFClass_Medic: Format(helpstr, sizeof(helpstr), "Medic:\nCharge: Kritz+Uber+Ammo. Charge starts at 40percent.\nCharge lasts for 150 percent after activation.\nSyringe Guns: on hit: +5 to Uber.\nCrossbow: 100 percent crits, +150pct damage, +15 uber on hit.\nUber gives patient infinite ammo until Uber is depleted.\nhaving 90% or higher Uber protects you from one Melee hit from Boss.\nBlutsauger + Overdose are Unlocked + give 1 pct Uber on hit.\nHealing Heavies give them damage boost on Miniguns.");
			case TFClass_Sniper: Format(helpstr, sizeof(helpstr), "Sniper:\nJarate removes small pct of Boss Rage.\nBack-equipped weapons are replaced with SMG.\nSniper Rifles causes Certain Bosses to glow. Glow time scales with charge.\nAll Sniper melees climb walls, but has slower rate of fire.\nHuntsman carries 2x more ammo.\nBazaar Bargain gains heads on headshot.\n");
			case TFClass_Spy: Format(helpstr, sizeof(helpstr), "Spy:\nBackstab does about 10+ percent of a Boss' max HP.\nCloaknDagger replaced with normal inviswatch.\nAll revolvers minicrit.\nYour Eternal Reward backstabs will disguise you.\nKunai backstabs will get you a health bonus.\nSappers are replaced with NailGun.\nDiamondback gets 2 crits on backstab.\nBig Earner gives full Cloak on backstab.\nAmbassador headshots do extra damage.");
		}
		Panel panel = new Panel();
		panel.SetTitle (helpstr);
		panel.DrawItem( "Exit" );
		panel.Send(this.index, HintPanel, 20);
		delete panel;
	}
	
	public int GetHealTarget() {
		return GetHealingTarget(this.index);
	}
	public bool IsNearDispenser() {
		int client = this.index;
		int medics=0;
		int healers = GetEntProp(client, Prop_Send, "m_nNumHealers");
		if( healers > 0 ) {
			for( int i=MaxClients; i; --i ) {
				if( !IsValidClient(i) )
					continue;
				else if( GetHealingTarget(i) == client )
					medics++;
			}
		}
		return( healers > medics );
	}
	public bool IsInRange(const int target, const float dist, bool pTrace=false) {
		return IsInRange(this.index, target, dist, pTrace);
	}
	public void RemoveBack(int[] indices, const int len) {
		RemovePlayerBack(this.index, indices, len);
	}
	public int FindBack(int[] indices, const int len) {
		return FindPlayerBack(this.index, indices, len);
	}
	public int ShootRocket(bool bCrit=false, float vPosition[3], float vAngles[3], const float flSpeed, const float dmg, const char[] model, bool arc=false) {
		return ShootRocket(this.index, bCrit, vPosition, vAngles, flSpeed, dmg, model, arc);
	}
};

methodmap BaseBoss < BaseFighter
/**
 * the methodmap/interface for all bosses to use. Use this if you're making a totally different boss
 * Property Organization
 * Ints
 * Bools
 * Floats
 * Methods
 */
{
	public BaseBoss(const int ind, bool uid=false) {
		return view_as< BaseBoss >( BaseFighter(ind, uid) );
	}
	
	///////////////////////////////
	/** [ P R O P E R T I E S ] */
	
	property int iHealth {
		public get() {
			int i; hPlayerFields[this.index].GetValue("iHealth", i);
			if( i<0 )
				i = 0;
			return i;
		}
		public set( const int val ) {
			hPlayerFields[this.index].SetValue("iHealth", val);
		}
	}
	property int iMaxHealth {
		public get() {
			int i; hPlayerFields[this.index].GetValue("iMaxHealth", i);
			return i;
		}
		public set( const int val ) {
			hPlayerFields[this.index].SetValue("iMaxHealth", val);
		}
	}
	property int iBossType {
		public get() {
			int i; hPlayerFields[this.index].GetValue("iBossType", i);
			return i;
		}
		public set( const int val ) {
			hPlayerFields[this.index].SetValue("iBossType", val);
		}
	}
	property int iClimbs {
		public get() {
			int i; hPlayerFields[this.index].GetValue("iClimbs", i);
			return i;
		}
		public set( const int val ) {
			hPlayerFields[this.index].SetValue("iClimbs", val);
		}
	}
	property int iStabbed {
		public get() {
			int i; hPlayerFields[this.index].GetValue("iStabbed", i);
			return i;
		}
		public set( const int val ) {
			hPlayerFields[this.index].SetValue("iStabbed", val);
		}
	}
	property int iMarketted {
		public get() {
			int i; hPlayerFields[this.index].GetValue("iMarketted", i);
			return i;
		}
		public set( const int val ) {
			hPlayerFields[this.index].SetValue("iMarketted", val);
		}
	}
	property int iDifficulty {
		public get() {
			int i; hPlayerFields[this.index].GetValue("iDifficulty", i);
			return i;
		}
		public set( const int val ) {
			hPlayerFields[this.index].SetValue("iDifficulty", val);
		}
	}
	
	property bool bIsBoss {
		public get() {
			bool i; hPlayerFields[this.index].GetValue("bIsBoss", i);
			return i;
		}
		public set( const bool val ) {
			hPlayerFields[this.index].SetValue("bIsBoss", val);
		}
	}
	property bool bSetOnSpawn {
		public get() {
			bool i; hPlayerFields[this.index].GetValue("bSetOnSpawn", i);
			return i;
		}
		public set( const bool val ) {
			hPlayerFields[this.index].SetValue("bSetOnSpawn", val);
		}
	}
	property bool bUsedUltimate {
		public get() {
			bool i; hPlayerFields[this.index].GetValue("bUsedUltimate", i);
			return i;
		}
		public set( const bool val ) {
			hPlayerFields[this.index].SetValue("bUsedUltimate", val);
		}
	}
	
	property float flSpeed {
		public get() {
			float i; hPlayerFields[this.index].GetValue("flSpeed", i);
			return i;
		}
		public set( const float val ) {
			hPlayerFields[this.index].SetValue("flSpeed", val);
		}
	}
	property float flCharge {
		public get() {
			float i; hPlayerFields[this.index].GetValue("flCharge", i);
			return i;
		}
		public set( const float val ) {
			hPlayerFields[this.index].SetValue("flCharge", val);
		}
	}
	property float flRAGE {
		public get() { /** Rage should never exceed or "inceed" 0.0 and 100.0 */
			float i; hPlayerFields[this.index].GetValue("flRAGE", i);
			if( i > 100.0 )
				i = 100.0;
			else if( i < 0.0 )
				i = 0.0;
			return i;
		}
		public set( const float val ) {
			hPlayerFields[this.index].SetValue("flRAGE", val);
		}
	}
	property float flKillSpree {
		public get() {
			float i; hPlayerFields[this.index].GetValue("flKillSpree", i);
			return i;
		}
		public set( const float val ) {
			hPlayerFields[this.index].SetValue("flKillSpree", val);
		}
	}
	property float flWeighDown {
		public get() {
			float i; hPlayerFields[this.index].GetValue("flWeighDown", i);
			return i;
		}
		public set( const float val ) {
			hPlayerFields[this.index].SetValue("flWeighDown", val);
		}
	}
	
	public void ConvertToBoss() {
		this.bIsBoss = this.bSetOnSpawn;
		this.flRAGE = 0.0;
		SetPawnTimer(_MakePlayerBoss, 0.1, this.userid);
	}
	
	public void GiveRage(const int damage) {
		this.flRAGE += ( damage/SquareRoot(float(this.iHealth))*4.0 );
	}
	public void MakeBossAndSwitch(const int type, const bool callEvent) {
		this.bSetOnSpawn = true;
		this.iBossType = type;
		if( callEvent )
			ManageOnBossSelected(this);
		this.ConvertToBoss();
		if( GetClientTeam(this.index) == RED )
			this.ForceTeamChange(BLU);
	}
	public void DoGenericStun(const float rageDist)
	{
		int i;
		float pos[3], pos2[3];
		GetEntPropVector(this.index, Prop_Send, "m_vecOrigin", pos);
		for( i=MaxClients; i; --i ) {
			if( !IsValidClient(i) || !IsPlayerAlive(i) || i == this.index || GetClientTeam(i) == GetClientTeam(this.index) )
				continue;
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			float distance = GetVectorDistance(pos, pos2);
			if( !TF2_IsPlayerInCondition(i, TFCond_Ubercharged) && distance < rageDist ) {
				CreateTimer(5.0, RemoveEnt, EntIndexToEntRef(AttachParticle(i, "yikes_fx", 75.0)));
				TF2_StunPlayer(i, 5.0, _, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, this.index);
			}
		}
		i = -1;
		while( (i = FindEntityByClassname(i, "obj_sentrygun")) != -1 ) {
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			float distance = GetVectorDistance(pos, pos2);
			if( distance < rageDist ) {
				SetEntProp(i, Prop_Send, "m_bDisabled", 1);
				AttachParticle(i, "yikes_fx", 75.0);
				SetVariantInt(1);
				AcceptEntityInput(i, "RemoveHealth");
				SetPawnTimer(EnableSG, 8.0, EntIndexToEntRef(i)); //CreateTimer(8.0, EnableSG, EntIndexToEntRef(i));
			}
		}
		i = -1;
		while( (i = FindEntityByClassname(i, "obj_dispenser")) != -1 ) {
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			float distance = GetVectorDistance(pos, pos2);
			if( distance < rageDist ) {
				SetVariantInt(1);
				AcceptEntityInput(i, "RemoveHealth");
			}
		}
		i = -1;
		while( (i = FindEntityByClassname(i, "obj_teleporter")) != -1 ) {
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			float distance = GetVectorDistance(pos, pos2);
			if( distance < rageDist ) {
				SetVariantInt(1);
				AcceptEntityInput(i, "RemoveHealth");
			}
		}
	}
	public void RemoveAllItems() {
		int client = this.index;
		TF2_RemovePlayerDisguise(client);
		
		int ent = -1;
		while( (ent = FindEntityByClassname(ent, "tf_wearabl*")) != -1 ) {
			if( GetOwner(ent) == client ) {
				TF2_RemoveWearable(client, ent);
				AcceptEntityInput(ent, "Kill");
			}
		}
		ent = -1;
		while( (ent = FindEntityByClassname(ent, "tf_powerup_bottle")) != -1 ) {
			if( GetOwner(ent) == client ) {
				TF2_RemoveWearable(client, ent);
				AcceptEntityInput(ent, "Kill");
			}
		}
		TF2_RemoveAllWeapons(client);
	}
};


public int HintPanel(Menu menu, MenuAction action, int param1, int param2) {
	return;
}
