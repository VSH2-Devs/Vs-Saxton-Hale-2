enum struct AmmoData {
	int ammo[2];
	int clip[2];

	int GetAmmo(int wepslot) {
		return( IsIntInBounds(wepslot, 1, 0) ) ? this.ammo[wepslot] : 0;
	}
	int GetClip(int wepslot) {
		return( IsIntInBounds(wepslot, 1, 0) ) ? this.clip[wepslot] : 0;
	}

	void SetAmmo(int wepslot, int val) {
		if( !IsIntInBounds(wepslot, 1, 0) )
			return;
		this.ammo[wepslot] = val;
	}
	void SetClip(int wepslot, int val) {
		if( !IsIntInBounds(wepslot, 1, 0) )
			return;
		this.clip[wepslot] = val;
	}
}

AmmoData g_munitions[PLYR];


/** Player Interface that Opposing team and Boss team derives from */
methodmap BaseFighter {
/**
 * Property Organization
 * Ints
 * Bools
 * Floats
 * Misc properties
 * Methods
 */
	/// If you're using a userid and you know 100% it's valid, then set uid to true
	public BaseFighter(const int ind, bool uid=false) {
		int player;
		if( uid && GetClientOfUserId(ind) > 0 ) {
			player = ind;
		} else if( IsClientValid(ind) ) {
			player = GetClientUserId(ind);
		}
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
			if( !player ) {
				return 0;
			} else if( !AreClientCookiesCached(player) || IsFakeClient(player) ) {
				/// If the coookies aren't cached yet, use map.
				int i; g_vsh2.m_hPlayerFields[player].GetValue("iQueue", i);
				return i;
			}
			char strPoints[10]; /// HOW WILL OUR QUEUE SURPASS OVER 9 DIGITS?
			g_vsh2.m_hCookies[Points].Get(player, strPoints, sizeof(strPoints));
			int points = StringToInt(strPoints);
			g_vsh2.m_hPlayerFields[player].SetValue("iQueue", points);
			return points;
		}
		public set( const int val ) {
			int player = this.index;
			if( !player ) {
				return;
			} else if( !AreClientCookiesCached(player) || IsFakeClient(player) ) {
				g_vsh2.m_hPlayerFields[player].SetValue("iQueue", val);
				return;
			}
			g_vsh2.m_hPlayerFields[player].SetValue("iQueue", val);
			char strPoints[10];
			IntToString(val, strPoints, sizeof(strPoints));
			g_vsh2.m_hCookies[Points].Set(player, strPoints);
		}
	}
	property int iPresetType {    /// if cookies aren't cached, oh well!
		public get() {
			int player = this.index;
			if( !player ) {
				return -1;
			} else if( !AreClientCookiesCached(player) ) {
				int i; g_vsh2.m_hPlayerFields[player].GetValue("iPresetType", i);
				return i;
			}
			char setboss[6];
			g_vsh2.m_hCookies[BossOpt].Get(player, setboss, sizeof(setboss));
			int bossType = (setboss[0] != '\0') ? StringToInt(setboss) : -1; /// fallback to -1 aka random/unset on empty-string
			g_vsh2.m_hPlayerFields[player].SetValue("iPresetType", bossType);
			return bossType;
		}
		public set( const int val ) {
			int player = this.index;
			if( !player ) {
				return;
			} else if( !AreClientCookiesCached(player) ) {
				g_vsh2.m_hPlayerFields[player].SetValue("iPresetType", val);
				return;
			}
			g_vsh2.m_hPlayerFields[player].SetValue("iPresetType", val);
			char setboss[6];
			IntToString(val, setboss, sizeof(setboss));
			g_vsh2.m_hCookies[BossOpt].Set(player, setboss);
		}
	}
	property int iKills {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iKills", i);
			return i;
		}
		public set( const int val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iKills", val);
		}
	}
	property int iHits {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iHits", i);
			return i;
		}
		public set( const int val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iHits", ( val>=0 ) ? val : 0);
		}
	}
	property int iLives {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iLives", i);
			return i;
		}
		public set( const int val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iLives", ( val>=0 ) ? val : 0);
		}
	}
	property int iState {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iState", i);
			return i;
		}
		public set( const int val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iState", val);
		}
	}
	property int iDamage {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iDamage", i);
			return i;
		}
		public set( const int val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iDamage", val);
		}
	}
	property int iAirDamage {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iAirDamage", i);
			return i;
		}
		public set( const int val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iAirDamage", val);
		}
	}
	property int iSongPick {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iSongPick", i);
			return i;
		}
		public set( const int val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iSongPick", val);
		}
	}
	property int iOwnerBoss {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iOwnerBoss", i);
			return i;
		}
		public set( const int val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iOwnerBoss", val);
		}
	}

	/** please use userid on this; convert to client index if you want but userid is safer */
	property int iUberTarget {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iUberTarget", i);
			return i;
		}
		public set( const int val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iUberTarget", val);
		}
	}
	property int iShieldDmg {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iShieldDmg", i);
			return i;
		}
		public set( const int val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iShieldDmg", val);
		}
	}
	property int iClimbs {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iClimbs", i);
			return i;
		}
		public set( const int val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iClimbs", val);
		}
	}
	property TFClassType iTFClass {
		public get() {
			return TF2_GetPlayerClass(this.index);
		}
	}

	property bool bIsMinion {
		public get() {
			bool i; g_vsh2.m_hPlayerFields[this.index].GetValue("bIsMinion", i);
			return i;
		}
		public set( const bool val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("bIsMinion", val);
		}
	}
	property bool bInJump {
		public get() {
			bool i; g_vsh2.m_hPlayerFields[this.index].GetValue("bInJump", i);
			return i;
		}
		public set( const bool val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("bInJump", val);
		}
	}
	property bool bNoMusic {
		public get() {
			if( !AreClientCookiesCached(this.index) ) {
				return false;
			}
			char musical[6];
			g_vsh2.m_hCookies[MusicOpt].Get(this.index, musical, sizeof(musical));
			return( StringToInt(musical) == 1 );
		}
		public set( const bool val ) {
			if( !AreClientCookiesCached(this.index) ) {
				return;
			}
			char musical[6];
			IntToString(( val ) ? 1 : 0, musical, sizeof(musical));
			g_vsh2.m_hCookies[MusicOpt].Set(this.index, musical);
		}
	}

	property float flGlowtime {
		public get() {
			float i; g_vsh2.m_hPlayerFields[this.index].GetValue("flGlowtime", i);
			if( i<0.0 ) {
				i = 0.0;
				g_vsh2.m_hPlayerFields[this.index].SetValue("flGlowtime", 0.0);
			}
			return i;
		}
		public set( const float val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("flGlowtime", val);
		}
	}
	property float flLastHit {
		public get() {
			float i; g_vsh2.m_hPlayerFields[this.index].GetValue("flLastHit", i);
			return i;
		}
		public set( const float val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("flLastHit", val);
		}
	}
	property float flLastShot {
		public get() {
			float i; g_vsh2.m_hPlayerFields[this.index].GetValue("flLastShot", i);
			return i;
		}
		public set( const float val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("flLastShot", val);
		}
	}
	property float flMusicTime {
		public get() {
			float i; g_vsh2.m_hPlayerFields[this.index].GetValue("flMusicTime", i);
			return i;
		}
		public set( const float val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("flMusicTime", val);
		}
	}

	public void ConvertToMinion(const float time) {
		this.bIsMinion = true;
		SetPawnTimer(_MakePlayerMinion, time, this.userid);
	}
	/**
	 * creates and spawns a weapon to a player, regardless if boss or not
	 *
	 * @param name      entity name of the weapon, example: "tf_weapon_bat"
	 * @param index     the index of the desired weapon
	 * @param level     the level of the weapon
	 * @param qual      the weapon quality of the item
	 * @param att       the nested attribute string, example: "2; 2.0" - increases weapon damage by 100% aka 2x.
	 * @return          entity index of the newly created weapon
	 */
	public int SpawnWeapon(char[] name, const int index, const int level, const int qual, char[] att)
	{
		TF2Item hWep = new TF2Item(OVERRIDE_ALL|FORCE_GENERATION);
		if( !hWep ) {
			return -1;
		}
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
			for( int i, att_index; i<count; i+=2, att_index++ ) {
				hWep.SetAttribute(att_index, StringToInt(atts[i]), StringToFloat(atts[i+1]));
			}
		} else {
			hWep.iNumAttribs = 0;
		}

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
		return g_munitions[this.index].GetAmmo(wepslot);
	}

	/**
	 * sets the max recorded ammo for a certain weapon index
	 *
	 * @param wepslot	the equipment slot of the player
	 * @param val		how much the new max ammo should be
	 * @noreturn
	 */
	public void setAmmotable(const int wepslot, const int val) {
		g_munitions[this.index].SetAmmo(wepslot, val);
	}
	/**
	 * gets the max recorded clipsize for a certain weapon index
	 *
	 * @param wepslot	the equipment slot of the player
	 * @return		the recorded clipsize ammo of the weapon
	 */
	public int getCliptable(const int wepslot) {
		return g_munitions[this.index].GetClip(wepslot);
	}

	/**
	 * sets the max recorded clipsize for a certain weapon index
	 *
	 * @param wepslot	the equipment slot of the player
	 * @param val		how much the new max clipsize should be
	 * @noreturn
	 */
	public void setCliptable(const int wepslot, const int val) {
		g_munitions[this.index].SetClip(wepslot, val);
	}
	public int GetWeaponSlotIndex(const int slot) {
		int weapon = GetPlayerWeaponSlot(this.index, slot);
		return GetItemIndex(weapon);
	}
	public void SetWepInvis(const int alpha) {
		int transparent = alpha;
		for( int i; i<5; i++ ) {
			int entity = GetPlayerWeaponSlot(this.index, i);
			if( IsValidEntity(entity) ) {
				transparent = IntClamp(transparent, 100, 0);
				SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
				SetEntityRenderColor(entity, 150, 150, 150, RoundFloat((transparent / 100.0) * 255));
			}
		}
	}
	public void SetOverlay(const char[] strOverlay) {
		int iFlags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
		SetCommandFlags("r_screenoverlay", iFlags);
		ClientCommand(this.index, "r_screenoverlay \"%s\"", strOverlay);
	}

	/// Props to Chdata!
	public bool TeleToSpawn(int team=0)
	{
		int spawn = -1;
		float pos[3], mins[3], maxs[3];
		int spawn_len;
		int[] spawns = new int[MaxClients+1];
		while( (spawn = FindEntityByClassname(spawn, "info_player_teamspawn")) != -1 ) {
			if( spawn_len >= MaxClients+1 )
				break;
			
			/// skip disabled spawns.
			if( GetEntProp(spawn, Prop_Data, "m_bDisabled") )
				continue;

			/// now check if the spawn is blocked by something that might get our player stuck.
			GetEntPropVector(spawn, Prop_Send, "m_vecOrigin", pos);
			GetClientMaxs(this.index, maxs);
			GetClientMins(this.index, mins);
			if( !CanFitHere(pos, mins, maxs) )
				continue;

			/// if the client is a boss, allow them to use ANY valid spawn!
			int is_boss; g_vsh2.m_hPlayerFields[this.index].GetValue("iBossType", is_boss);
			if( team <= 1 || is_boss > -1 ) {
				spawns[spawn_len++] = spawn;
			} else {
				int spawn_team = GetEntProp(spawn, Prop_Data, "m_iTeamNum");
				if( spawn_team==team ) {
					spawns[spawn_len++] = spawn;
				}
			}
		}

		/// Technically you'll never find a map without a spawn point. Not a good map at least.
		if( spawn_len<=0 )
			return false;

		spawn = spawns[GetRandomInt(0, spawn_len - 1)];
		GetEntPropVector(spawn, Prop_Send, "m_vecOrigin",   pos);
		float ang[3]; GetEntPropVector(spawn, Prop_Send, "m_angRotation", ang);
		TeleportEntity(this.index, pos, ang, NULL_VECTOR);
		return true;
	}

	public void IncreaseHeadCount(bool addhealth=true, int head_count=1) {
		int client = this.index;
		/// Apply this condition to Demomen to give them their glowing eye effect.
		if( (this.iTFClass == TFClass_DemoMan) && !TF2_IsPlayerInCondition(client, TFCond_DemoBuff) ) {
			TF2_AddCondition(client, TFCond_DemoBuff, TFCondDuration_Infinite);
		}
		int decapitations = GetEntProp(client, Prop_Send, "m_iDecapitations");
		SetEntProp(client, Prop_Send, "m_iDecapitations", decapitations + head_count);
		if( addhealth && GetClientHealth(client) < g_vsh2.m_hCvars.MaxDemoKnightOverheal.IntValue ) {
			HealPlayer(client, g_vsh2.m_hCvars.SwordHeadHPAdd.IntValue * head_count, true, true, g_vsh2.m_hCvars.MaxDemoKnightOverheal.IntValue);
		}
		/// recalc their speed
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);
	}
	public void SpawnSmallHealthPack(int ownerteam=0) {
		if( !IsValidClient(this.index) || !IsPlayerAlive(this.index) )
			return;

		int healthpack = CreateEntityByName("item_healthkit_small");
		if( IsValidEntity(healthpack) ) {
			float pos[3]; GetClientAbsOrigin(this.index, pos);
			pos[2] += 20.0;
			/// for safety, though it normally doesn't respawn
			DispatchKeyValue(healthpack, "OnPlayerTouch", "!self,Kill,,0,-1");
			DispatchSpawn(healthpack);
			SetEntProp(healthpack, Prop_Send, "m_iTeamNum", ownerteam, 4);
			SetEntityMoveType(healthpack, MOVETYPE_VPHYSICS);
			float vel[3];
			vel[0] = float(GetRandomInt(-10, 10)), vel[1] = float(GetRandomInt(-10, 10)), vel[2] = 50.0;
			TeleportEntity(healthpack, pos, NULL_VECTOR, vel);
		}
	}
	public void ForceTeamChange(const int team) {
		/// Living Spectator Bug:
		/// If you force a player onto a team with their tfclass not set, they'll appear as a "living" spectator
		if( this.iTFClass > TFClass_Unknown ) {
			SetEntProp(this.index, Prop_Send, "m_lifeState", 2);
			ChangeClientTeam(this.index, team);
			SetEntProp(this.index, Prop_Send, "m_lifeState", 0);
			TF2_RespawnPlayer(this.index);
		}
	}
	public bool ClimbWall(const int weapon, const float upwardvel, float health, bool attackdelay)
	{ /// Credit to Mecha the Slag
		int client = this.index;
		float vecClientEyePos[3];
		GetClientEyePosition(client, vecClientEyePos);   /// Get the position of the player's eyes

		float vecClientEyeAng[3];
		GetClientEyeAngles(client, vecClientEyeAng);     /// Get the angle the player is looking

		/// Check for colliding entities
		TR_TraceRayFilter(vecClientEyePos, vecClientEyeAng, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);
		if( !TR_DidHit(null) )
			return false;

		char classname[64];
		int TRIndex = TR_GetEntityIndex(null);
		GetEdictClassname(TRIndex, classname, sizeof(classname));
		if( !(StrEqual(classname, "worldspawn") || !strncmp(classname, "prop_", 5)) )
			return false;

		float fNormal[3];
		TR_GetPlaneNormal(null, fNormal);
		GetVectorAngles(fNormal, fNormal);

		if( fNormal[0] >= 30.0 && fNormal[0] <= 330.0 )
			return false;
		if( fNormal[0] <= -30.0 )
			return false;

		float pos[3]; TR_GetEndPosition(pos);
		float distance = GetVectorDistance(vecClientEyePos, pos);
		if( distance >= 100.0 )
			return false;

		float fVelocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
		fVelocity[2] = upwardvel;

		if( Call_OnPlayerClimb(view_as< BaseBoss >(this), weapon, fVelocity[2], health, attackdelay) > Plugin_Changed ) {
			return false;
		} else if( GetClientHealth(this.index) <= health ) {
			/// Also, Have to baby players so they don't accidentally kill themselves trying to escape...
			return false;
		}

		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
		SDKHooks_TakeDamage(client, client, client, health, DMG_CLUB, 0); /// Inflictor is 0 to prevent Shiv self-bleed
		this.iClimbs++;

		if( attackdelay )
			RequestFrame(NoAttacking, EntIndexToEntRef(weapon));
		return true;
	}

	public void HelpPanelClass() {
		if( IsVoteInProgress() )
			return;

		static char class_help[][] = {
			"help.unknown",
			"help.scout",
			"help.sniper",
			"help.soldier",
			"help.demo",
			"help.medic",
			"help.heavy",
			"help.pyro",
			"help.spy",
			"help.engie"
		};

		Panel panel = new Panel();
		TFClassType tfclass = this.iTFClass;
		int len = g_vsh2.m_hCfg.GetSize(class_help[tfclass]);
		char[] helpstr = new char[len];
		g_vsh2.m_hCfg.Get(class_help[tfclass], helpstr, len);
		panel.SetTitle(helpstr);
		char ExitText[64];
		Format(ExitText, 64, "%T", "Exit", this.index);
		panel.DrawItem(ExitText);
		panel.Send(this.index, HintPanel, 20);
		delete panel;
	}

	public int GetHealTarget() {
		return GetHealingTarget(this.index);
	}
	public bool IsNearDispenser() {
		return IsNearSpencer(this.index);
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
	public void Heal(const int health, bool on_hud=false, bool overridehp=false, int overheal_limit=0) {
		HealPlayer(this.index, health, on_hud, overridehp, overheal_limit);
	}

	public bool SetMusic(const char song[PLATFORM_MAX_PATH]) {
		return g_vsh2.m_hPlayerFields[this.index].SetString("strMusic", song);
	}

	public bool GetMusic(char buffer[PLATFORM_MAX_PATH]) {
		return g_vsh2.m_hPlayerFields[this.index].GetString("strMusic", buffer, sizeof(buffer));
	}

	public void PlayMusic(const float vol, const char[] override = "") {
		if( this.bNoMusic )
			return;

		if( g_vsh2.m_hCvars.PlayerMusic.BoolValue ) {
			char song[PLATFORM_MAX_PATH]; this.GetMusic(song);
			if( override[0] != 0 ) {
				strcopy(song, sizeof(song), override);
				this.SetMusic(song);
			}
			EmitSoundToClient(this.index, song, _, _, SNDLEVEL_NORMAL, SND_NOFLAGS, vol, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		} else {
			if( override[0] != 0 ) {
				strcopy(g_vsh2.m_strCurrSong, sizeof(g_vsh2.m_strCurrSong), override);
			}
			EmitSoundToClient(this.index, g_vsh2.m_strCurrSong, _, _, SNDLEVEL_NORMAL, SND_NOFLAGS, vol, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		}
	}

	public void StopMusic() {
		if( g_vsh2.m_hCvars.PlayerMusic.BoolValue ) {
			char song[PLATFORM_MAX_PATH]; this.GetMusic(song);
			StopSound(this.index, SNDCHAN_AUTO, song);
		} else {
			StopSound(this.index, SNDCHAN_AUTO, g_vsh2.m_strCurrSong);
		}
	}

	public bool AddTempAttrib(const int attrib, const float val, const float dur=-1.0) {
		bool res;
#if defined _tf2attributes_included
		bool tf2attribs; view_as< StringMap >(g_vshgm).GetValue("bTF2Attribs", tf2attribs);
		if( tf2attribs ) {
			res = TF2Attrib_SetByDefIndex(this.index, attrib, val);
			if( res && dur > -1.0 ) {
				SetPawnTimer(TF2AttribsRemove, dur, this.userid, attrib);
			}
		}
#endif
		return res;
	}
};

methodmap BaseBoss < BaseFighter {
/**
 * the methodmap/interface for all bosses to use. Use this if you're making a totally different boss
 * Property Organization
 * Ints
 * Bools
 * Floats
 * Methods
 */
	public BaseBoss(const int ind, bool uid=false) {
		return view_as< BaseBoss >( BaseFighter(ind, uid) );
	}

	///////////////////////////////
	/** [ P R O P E R T I E S ] */

	property int iHealth {
		public get() {
			return GetClientHealth(this.index);
		}
		public set( const int val ) {
			SetEntityHealth(this.index, val);
		}
	}
	property int iMaxHealth {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iMaxHealth", i);
			return i;
		}
		public set( const int val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iMaxHealth", val);
		}
	}
	property int iBossType {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iBossType", i);
			return i;
		}
		public set( const int val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iBossType", val);
		}
	}
	property int iStabbed {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iStabbed", i);
			return i;
		}
		public set( const int val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iStabbed", val);
		}
	}
	property int iMarketted {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iMarketted", i);
			return i;
		}
		public set( const int val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iMarketted", val);
		}
	}
	property int iDifficulty {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iDifficulty", i);
			return i;
		}
		public set( const int val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iDifficulty", val);
		}
	}

	property bool bIsBoss {
		public get() {
			return this.iBossType >= 0;
		}
	}
	property bool bUsedUltimate {
		public get() {
			bool i; g_vsh2.m_hPlayerFields[this.index].GetValue("bUsedUltimate", i);
			return i;
		}
		public set( const bool val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("bUsedUltimate", val);
		}
	}
	property bool bSuperCharge {
		public get() {
			bool i; g_vsh2.m_hPlayerFields[this.index].GetValue("bSuperCharge", i);
			return i;
		}
		public set( const bool val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("bSuperCharge", val);
		}
	}

	property float flSpeed {
		public get() {
			float i; g_vsh2.m_hPlayerFields[this.index].GetValue("flSpeed", i);
			return i;
		}
		public set( const float val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("flSpeed", val);
		}
	}
	property float flCharge {
		public get() {
			float i; g_vsh2.m_hPlayerFields[this.index].GetValue("flCharge", i);
			return i;
		}
		public set( const float val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("flCharge", val);
		}
	}
	property float flRAGE {
		public get() { /** Rage should never go under 0.0 */
			float i; g_vsh2.m_hPlayerFields[this.index].GetValue("flRAGE", i);
			if( i < 0.0 ) {
				i = 0.0;
				g_vsh2.m_hPlayerFields[this.index].SetValue("flRAGE", i);
			}
			return i;
		}
		public set( const float val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("flRAGE", val);
		}
	}
	property float flKillSpree {
		public get() {
			float i; g_vsh2.m_hPlayerFields[this.index].GetValue("flKillSpree", i);
			return i;
		}
		public set( const float val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("flKillSpree", val);
		}
	}
	property float flWeighDown {
		public get() {
			float i; g_vsh2.m_hPlayerFields[this.index].GetValue("flWeighDown", i);
			return i;
		}
		public set( const float val ) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("flWeighDown", val);
		}
	}

	public void ConvertToBoss() {
		this.flRAGE = 0.0;
		SetPawnTimer(_MakePlayerBoss, 0.1, this.userid);
	}

	public void GiveRage(const int damage) {
		/// Patch Oct 26, 2019.
		/// Killing boss throws negative value exception for sqrt.
		float health = ( (this.iHealth <= 0) ? 1 : this.iHealth ) + 0.0;
		float rage_amount = damage / SquareRoot(health) * 1.76;
		Action act = Call_OnBossGiveRage(this, damage, rage_amount);
		if( act > Plugin_Changed )
			return;
		this.flRAGE += rage_amount;
	}

	public void MakeBossAndSwitch(const int type, const bool run_event, const bool friendly=false) {
		this.iBossType = type;
		if( run_event )
			ManageOnBossSelected(this);

		this.ConvertToBoss();
		if( !friendly && GetClientTeam(this.index)==VSH2Team_Red )
			this.ForceTeamChange(VSH2Team_Boss);
	}

	public void StunPlayers(float rage_dist, float stun_time=5.0)
	{
		float boss_pos[3], player_pos[3];
		GetEntPropVector(this.index, Prop_Send, "m_vecOrigin", boss_pos);
		for( int i=MaxClients; i; --i ) {
			if( !IsValidClient(i) || !IsPlayerAlive(i) || i==this.index || GetClientTeam(i)==GetClientTeam(this.index) ) {
				continue;
			}
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", player_pos);
			float distance = GetVectorDistance(boss_pos, player_pos);
			if( !TF2_IsPlayerInCondition(i, TFCond_Ubercharged) && distance < rage_dist ) {
				CreateTimer(stun_time, RemoveEnt, EntIndexToEntRef(AttachParticle(i, "yikes_fx", 75.0)));
				TF2_StunPlayer(i, stun_time, _, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, this.index);
			}
		}
	}

	public void StunBuildings(float rage_dist, float sentry_stun_time=8.0)
	{
		float boss_pos[3], building_pos[3];
		GetEntPropVector(this.index, Prop_Send, "m_vecOrigin", boss_pos);
		int i = -1;
		while( (i = FindEntityByClassname(i, "obj_sentrygun")) != -1 ) {
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", building_pos);
			if( GetVectorDistance(boss_pos, building_pos) < rage_dist ) {
				SetEntProp(i, Prop_Send, "m_bDisabled", 1);
				AttachParticle(i, "yikes_fx", 75.0);
				SetVariantInt(1);
				AcceptEntityInput(i, "RemoveHealth");
				SetPawnTimer(EnableSG, sentry_stun_time, EntIndexToEntRef(i));
			}
		}
		i = -1;
		while( (i = FindEntityByClassname(i, "obj_dispenser")) != -1 ) {
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", building_pos);
			if( GetVectorDistance(boss_pos, building_pos) < rage_dist ) {
				SetVariantInt(1);
				AcceptEntityInput(i, "RemoveHealth");
			}
		}
		i = -1;
		while( (i = FindEntityByClassname(i, "obj_teleporter")) != -1 ) {
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", building_pos);
			if( GetVectorDistance(boss_pos, building_pos) < rage_dist ) {
				SetVariantInt(1);
				AcceptEntityInput(i, "RemoveHealth");
			}
		}
	}

	public void DoGenericStun(float rage_dist)
	{
		Action act = Call_OnBossDoRageStun(this, rage_dist);
		if( act > Plugin_Changed )
			return;

		this.StunPlayers(rage_dist);
		this.StunBuildings(rage_dist);
	}

	public void RemoveAllItems(bool weps=true) {
		int client = this.index;
		TF2_RemovePlayerDisguise(client);

		int ent = -1;
		while( (ent = FindEntityByClassname(ent, "tf_wearabl*")) != -1 ) {
			if( GetOwner(ent)==client ) {
				TF2_RemoveWearable(client, ent);
				AcceptEntityInput(ent, "Kill");
			}
		}
		ent = -1;
		while( (ent = FindEntityByClassname(ent, "tf_powerup_bottle")) != -1 ) {
			if( GetOwner(ent)==client ) {
				TF2_RemoveWearable(client, ent);
				AcceptEntityInput(ent, "Kill");
			}
		}
		if( weps ) {
			TF2_RemoveAllWeapons(client);
		}
	}

	public bool GetName(char buffer[MAX_BOSS_NAME_SIZE]) {
		return g_vsh2.m_hPlayerFields[this.index].GetString("strName", buffer, sizeof(buffer));
	}
	public bool SetName(const char name[MAX_BOSS_NAME_SIZE]) {
		return g_vsh2.m_hPlayerFields[this.index].SetString("strName", name);
	}

	public void SuperJump(const float power, const float reset) {
		Action act = Call_OnBossSuperJump(this);
		if( act > Plugin_Changed ) {
			return;
		}

		int client = this.index;
		float vel[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
		vel[2] = 750 + power * 13.0;
		if( this.bSuperCharge ) {
			vel[2] += 2000.0;
			this.bSuperCharge = false;
		}
		SetEntProp(client, Prop_Send, "m_bJumping", 1);
		vel[0] *= (1+Sine(power * FLOAT_PI / 50));
		vel[1] *= (1+Sine(power * FLOAT_PI / 50));
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
		this.flCharge = reset;
	}

	public void WeighDown(const float reset) {
		Action act = Call_OnBossWeighDown(this);
		if( act > Plugin_Changed ) {
			return;
		}
		int client = this.index;
		float fVelocity[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
		fVelocity[2] = -1000.0;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
		SetEntityGravity(client, 6.0);
		SetPawnTimer(SetGravityNormal, 1.0, this);
		this.flWeighDown = reset;
	}

	public void PlayVoiceClip(const char[] vclip, const int flags) {
		int client = this.index;
		float pos[3];
		if( flags & VSH2_VOICE_BOSSPOS ) {
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
		}
		EmitSoundToAll(vclip, (flags & VSH2_VOICE_BOSSENT) ? client : SOUND_FROM_PLAYER, (flags & VSH2_VOICE_ALLCHAN) ? SNDCHAN_AUTO : SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, (flags & VSH2_VOICE_BOSSPOS) ? pos : NULL_VECTOR, NULL_VECTOR, true, 0.0);

		if( !(flags & VSH2_VOICE_ONCE) ) {
			EmitSoundToAll(vclip, (flags & VSH2_VOICE_BOSSENT) ? client : SOUND_FROM_PLAYER, (flags & VSH2_VOICE_ALLCHAN) ? SNDCHAN_AUTO : SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, (flags & VSH2_VOICE_BOSSPOS) ? pos : NULL_VECTOR, NULL_VECTOR, true, 0.0);
		}

		if( flags & VSH2_VOICE_TOALL ) {
			for( int i=MaxClients; i; --i ) {
				if( IsClientInGame(i) && i != client ) {
					for( int x; x<2; x++ ) {
						EmitSoundToClient(i, vclip, client, (flags & VSH2_VOICE_ALLCHAN) ? SNDCHAN_AUTO : SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, (flags & VSH2_VOICE_BOSSPOS) ? pos : NULL_VECTOR, NULL_VECTOR, true, 0.0);
					}
				}
			}
		}
	}

	public void SpeedThink(const float iota, const float minspeed=100.0) {
		float speed = iota + 0.7 * (100 - this.iHealth * 100 / this.iMaxHealth);
		SetEntPropFloat(this.index, Prop_Send, "m_flMaxspeed", (speed < minspeed) ? minspeed : speed);
	}
	public void GlowThink(const float decrease) {
		if( this.flGlowtime > 0.0 ) {
			SetEntProp(this.index, Prop_Send, "m_bGlowEnabled", 1);
			this.flGlowtime -= decrease;
		} else if( this.flGlowtime <= 0.0 ) {
			SetEntProp(this.index, Prop_Send, "m_bGlowEnabled", 0);
		}
	}
	public bool SuperJumpThink(const float charging, const float jumpcharge) {
		int buttons = GetClientButtons(this.index);
		if( ((buttons & IN_DUCK) || (buttons & IN_ATTACK2)) && (this.flCharge >= 0.0) ) {
			if( this.flCharge+charging < jumpcharge ) {
				this.flCharge += charging;
			} else {
				this.flCharge = jumpcharge;
			}
		} else if( this.flCharge < 0.0 ) {
			this.flCharge += charging;
		} else {
			float EyeAngles[3]; GetClientEyeAngles(this.index, EyeAngles);
			if( this.flCharge > 1.0 && EyeAngles[0] < -5.0 ) {
				return true;
			} else {
				this.flCharge = 0.0;
			}
		}
		return false;
	}
	public void WeighDownThink(const float weighdown_time) {
		int client  = this.index;
		int buttons = GetClientButtons(client);
		int flags   = GetEntityFlags(client);
		if( flags & FL_ONGROUND ) {
			this.flWeighDown = 0.0;
		} else {
			this.flWeighDown += 0.1;
		}

		if( (buttons & IN_DUCK) && this.flWeighDown >= weighdown_time ) {
			float ang[3]; GetClientEyeAngles(client, ang);
			if( ang[0] > 60.0 ) {
				this.WeighDown(0.0);
			}
		}
	}
};


public int HintPanel(Menu menu, MenuAction action, int param1, int param2) {
	return 0;
}

public void SetGravityNormal(const BaseBoss b)
{
	int i = b.index;
	if( IsClientValid(i) ) {
		SetEntityGravity(i, 1.0);
	}
}

public void TF2AttribsRemoveAll(const int ent)
{
#if defined _tf2attributes_included
	TF2Attrib_RemoveAll(ent);
#endif
}

public void TF2AttribsRemove(const int userid, const int attrib)
{
#if defined _tf2attributes_included
	TF2Attrib_RemoveByDefIndex(GetClientOfUserId(userid), attrib);
#endif
}
