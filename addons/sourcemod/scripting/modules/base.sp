enum struct AmmoData {
	int ammo[2];
	int clip[2];
	
	int GetAmmo(int wepslot) {
		return( IsIntInBounds(wepslot, 1, 0) )? this.ammo[wepslot] : 0;
	}
	int GetClip(int wepslot) {
		return( IsIntInBounds(wepslot, 1, 0) )? this.clip[wepslot] : 0;
	}
	
	void SetAmmo(int wepslot, int val) {
		if( !IsIntInBounds(wepslot, 1, 0) ) {
			return;
		}
		this.ammo[wepslot] = val;
	}
	void SetClip(int wepslot, int val) {
		if( !IsIntInBounds(wepslot, 1, 0) ) {
			return;
		}
		this.clip[wepslot] = val;
	}
}

AmmoData g_munitions[PLYR];


/** Player Interface that Opposing team and Boss team derives from */
methodmap BasePlayer {
/**
 * Property Organization
 * Ints
 * Bools
 * Floats
 * Misc properties
 * Methods
 */
	/// If you're using a userid and you know 100% it's valid, then set uid to true
	public BasePlayer(int ind, bool uid=false) {
		int player;
		if( uid && GetClientOfUserId(ind) > 0 ) {
			player = ind;
		} else if( IsClientValid(ind) ) {
			player = GetClientUserId(ind);
		}
		return view_as< BasePlayer >( player );
	}
	///////////////////////////////

	/** [ P R O P E R T I E S ] */

	property int userid {
		public get() { return view_as< int >(this); }
	}
	property int index {
		public get() { return GetClientOfUserId( view_as< int >(this) ); }
	}
	property StringMap Props {
		public get() { return g_vsh2.m_hPlayerFields[this.index]; }
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
		public set(int val) {
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
			int bossType = (setboss[0] != '\0')? StringToInt(setboss) : -1; /// fallback to -1 aka random/unset on empty-string
			g_vsh2.m_hPlayerFields[player].SetValue("iPresetType", bossType);
			return bossType;
		}
		public set(int val) {
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
		public set(int val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iKills", val);
		}
	}
	property int iHits {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iHits", i);
			return i;
		}
		public set(int val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iHits", ( val>=0 )? val : 0);
		}
	}
	property int iLives {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iLives", i);
			return i;
		}
		public set(int val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iLives", ( val>=0 )? val : 0);
		}
	}
	property int iMaxLives {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iMaxLives", i);
			return i;
		}
		public set(int val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iMaxLives", ( val>=0 )? val : 0);
		}
	}
	property int iState {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iState", i);
			return i;
		}
		public set(int val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iState", val);
		}
	}
	property int iDamage {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iDamage", i);
			return i;
		}
		public set(int val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iDamage", val);
		}
	}
	property int iAirDamage {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iAirDamage", i);
			return i;
		}
		public set(int val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iAirDamage", val);
		}
	}
	property int iSongPick {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iSongPick", i);
			return i;
		}
		public set(int val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iSongPick", val);
		}
	}
	property int iOwnerBoss {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iOwnerBoss", i);
			return i;
		}
		public set(int val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iOwnerBoss", val);
		}
	}

	/** please use userid on this; convert to client index if you want but userid is safer */
	property int iUberTarget {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iUberTarget", i);
			return i;
		}
		public set(int val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iUberTarget", val);
		}
	}
	property int iShieldDmg {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iShieldDmg", i);
			return i;
		}
		public set(int val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iShieldDmg", val);
		}
	}
	property int iClimbs {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iClimbs", i);
			return i;
		}
		public set(int val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iClimbs", val);
		}
	}
	property int iHealth {
		public get() {
			return GetClientHealth(this.index);
		}
		public set(int val) {
			SetEntityHealth(this.index, val);
		}
	}
	property int iMaxHealth {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iMaxHealth", i);
			if( !i ) {
				i = GetEntProp(this.index, Prop_Data, "m_iMaxHealth");
			}
			return i;
		}
		public set(int val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iMaxHealth", val);
		}
	}
	property int iBossType {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iBossType", i);
			return i;
		}
		public set(int val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iBossType", val);
		}
	}
	property int iStabbed {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iStabbed", i);
			return i;
		}
		public set(int val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iStabbed", val);
		}
	}
	property int iMarketted {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iMarketted", i);
			return i;
		}
		public set(int val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iMarketted", val);
		}
	}
	property int iDifficulty {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iDifficulty", i);
			return i;
		}
		public set(int val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iDifficulty", val);
		}
	}
	property TFClassType iTFClass {
		public get() {
			return TF2_GetPlayerClass(this.index);
		}
	}
	property int iBossWins {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iBossWins", i);
			return i;
		}
		public set(int val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iBossWins", val);
		}
	}
	property int iBossLosses {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iBossLosses", i);
			return i;
		}
		public set(int val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iBossLosses", val);
		}
	}
	property int iBossKills {
		public get() {
			int i; g_vsh2.m_hPlayerFields[this.index].GetValue("iBossKills", i);
			return i;
		}
		public set(int val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("iBossKills", val);
		}
	}
	
	property bool bIsMinion {
		public get() {
			bool i; g_vsh2.m_hPlayerFields[this.index].GetValue("bIsMinion", i);
			return i;
		}
		public set(bool val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("bIsMinion", val);
		}
	}
	property bool bInJump {
		public get() {
			bool i; g_vsh2.m_hPlayerFields[this.index].GetValue("bInJump", i);
			return i;
		}
		public set(bool val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("bInJump", val);
		}
	}
	property bool bNoMusic {
		public get() {
			if( !AreClientCookiesCached(this.index) ) {
				return false;
			}
			char setting[6];
			g_vsh2.m_hCookies[MusicOpt].Get(this.index, setting, sizeof(setting));
			return( setting[0]=='1' );
		}
		public set(bool val) {
			if( !AreClientCookiesCached(this.index) ) {
				return;
			}
			char setting[6];
			setting = ( val )? "1" : "0";
			g_vsh2.m_hCookies[MusicOpt].Set(this.index, setting);
		}
	}
	property bool bCanBossPartner {
		public get() {
			int player = this.index;
			if( !AreClientCookiesCached(player) ) {
				bool i; g_vsh2.m_hPlayerFields[player].GetValue("bCanBossPartner", i);
				return i;
			}
			char setting[6];
			g_vsh2.m_hCookies[BossPartnerOpt].Get(player, setting, sizeof(setting));
			bool partner_enabled = setting[0]=='1';
			g_vsh2.m_hPlayerFields[player].SetValue("bCanBossPartner", partner_enabled);
			return partner_enabled;
		}
		public set(bool val) {
			int player = this.index;
			if( AreClientCookiesCached(player) ) {
				char setting[10];
				setting = ( val )? "1" : "0";
				g_vsh2.m_hCookies[BossPartnerOpt].Set(player, setting);
			}
			g_vsh2.m_hPlayerFields[player].SetValue("bCanBossPartner", val);
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
		public set(bool val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("bUsedUltimate", val);
		}
	}
	property bool bSuperCharge {
		public get() {
			bool i; g_vsh2.m_hPlayerFields[this.index].GetValue("bSuperCharge", i);
			return i;
		}
		public set(bool val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("bSuperCharge", val);
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
		public set(float val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("flGlowtime", val);
		}
	}
	property float flLastHit {
		public get() {
			float i; g_vsh2.m_hPlayerFields[this.index].GetValue("flLastHit", i);
			return i;
		}
		public set(float val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("flLastHit", val);
		}
	}
	property float flLastShot {
		public get() {
			float i; g_vsh2.m_hPlayerFields[this.index].GetValue("flLastShot", i);
			return i;
		}
		public set(float val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("flLastShot", val);
		}
	}
	property float flMusicTime {
		public get() {
			float i; g_vsh2.m_hPlayerFields[this.index].GetValue("flMusicTime", i);
			return i;
		}
		public set(float val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("flMusicTime", val);
		}
	}
	property float flSpeed {
		public get() {
			float i; g_vsh2.m_hPlayerFields[this.index].GetValue("flSpeed", i);
			return i;
		}
		public set(float val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("flSpeed", val);
		}
	}
	property float flCharge {
		public get() {
			float i; g_vsh2.m_hPlayerFields[this.index].GetValue("flCharge", i);
			return i;
		}
		public set(float val) {
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
		public set(float val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("flRAGE", val);
		}
	}
	property float flKillSpree {
		public get() {
			float i; g_vsh2.m_hPlayerFields[this.index].GetValue("flKillSpree", i);
			return i;
		}
		public set(float val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("flKillSpree", val);
		}
	}
	property float flWeighDown {
		public get() {
			float i; g_vsh2.m_hPlayerFields[this.index].GetValue("flWeighDown", i);
			return i;
		}
		public set(float val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("flWeighDown", val);
		}
	}
	property float flTimeAlive {
		public get() {
			float i; g_vsh2.m_hPlayerFields[this.index].GetValue("flTimeAlive", i);
			return i;
		}
		public set(float val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("flTimeAlive", val);
		}
	}
	property ConfigMap hConfig {
		public get() {
			ConfigMap i; g_vsh2.m_hPlayerFields[this.index].GetValue("hConfig", i);
			return i;
		}
		public set(ConfigMap val) {
			g_vsh2.m_hPlayerFields[this.index].SetValue("hConfig", val);
		}
	}
	
	public bool GiveAbility(const char[] name) {
		int ability_bits[COMPONENT_LEN];
		if( !g_vsh2.m_hPlayerFields[this.index].GetArray("arriAbilityBits", ability_bits, sizeof(ability_bits)) ) {
			LogError("[VSH 2] GiveAbility :: ERROR :: **** unable to retrieve ability bits from player '%N'. ****", this.index);
			return false;
		}
		
		int bit_idx = -1;
		if( !g_modsys.m_hAbilityBitIdxs.GetValue(name, bit_idx) || bit_idx < 0 ) {
			LogError("[VSH 2] GiveAbility :: ERROR :: **** ability '%s' does not exist. ****", name);
			return false;
		}
		BitVec_Set(ability_bits, bit_idx);
		return g_vsh2.m_hPlayerFields[this.index].SetArray("arriAbilityBits", ability_bits, sizeof(ability_bits));
	}
	public bool RemoveAbility(const char[] name) {
		int ability_bits[COMPONENT_LEN];
		if( !g_vsh2.m_hPlayerFields[this.index].GetArray("arriAbilityBits", ability_bits, sizeof(ability_bits)) ) {
			LogError("[VSH 2] RemoveAbility :: ERROR :: **** unable to retrieve ability bits from player '%N'. ****", this.index);
			return false;
		}
		
		int bit_idx = -1;
		if( !g_modsys.m_hAbilityBitIdxs.GetValue(name, bit_idx) || bit_idx < 0 ) {
			LogError("[VSH 2] RemoveAbility :: ERROR :: **** ability '%s' does not exist. ****", name);
			return false;
		}
		BitVec_Clear(ability_bits, bit_idx);
		return g_vsh2.m_hPlayerFields[this.index].SetArray("arriAbilityBits", ability_bits, sizeof(ability_bits));
	}
	public bool RemoveAllAbilities() {
		int ability_bits[COMPONENT_LEN];
		return g_vsh2.m_hPlayerFields[this.index].SetArray("arriAbilityBits", ability_bits, sizeof(ability_bits));
	}
	
	public bool HasAbility(const char[] name) {
		int ability_bits[COMPONENT_LEN];
		if( !g_vsh2.m_hPlayerFields[this.index].GetArray("arriAbilityBits", ability_bits, sizeof(ability_bits)) ) {
			LogError("[VSH 2] HasAbility :: Error **** unable to retrieve ability bits. ****");
			return false;
		}
		
		/// cannot let `bit_idx` start at 0
		/// 0 is a valid bit index aka 1st bit aka LSB.
		int bit_idx = -1;
		if( !g_modsys.m_hAbilityBitIdxs.GetValue(name, bit_idx) || bit_idx < 0 ) {
			LogError("[VSH 2] HasAbility :: Error **** ability '%s' does not exist. ****", name);
			return false;
		}
		return BitVec_Has(ability_bits, bit_idx);
	}
	
	public Action RunPreAbility(const char[] ability_name, any[] args, int arg_len) {
		Action act[2];
		for( int i; i < sizeof(g_hForwards); i++ ) {
			Call_StartForward(g_hForwards[i][OnPreAbility]);
			Call_PushCell(this);
			Call_PushString(ability_name);
			Call_PushArrayEx(args, arg_len, SM_PARAM_COPYBACK);
			Call_PushCell(arg_len);
			Call_Finish(act[i]);
			if( act[i] > Plugin_Changed ) {
				break;
			}
		}
		return act[0] > act[1]? act[0] : act[1];
	}
	public void RunPostAbility(const char[] ability_name, const any[] args, int arg_len, bool was_changed) {
		for( int i; i < sizeof(g_hForwards); i++ ) {
			Call_StartForward(g_hForwards[i][OnPostAbility]);
			Call_PushCell(this);
			Call_PushString(ability_name);
			Call_PushArray(args, arg_len);
			Call_PushCell(arg_len);
			Call_PushCell(was_changed);
			Call_Finish();
		}
	}
	
	
	public void ConvertToMinion(float time) {
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
	public int SpawnWeapon(char[] name, int index, int level, int qual, char[] att) {
		TF2Item hWep = new TF2Item(OVERRIDE_ALL|FORCE_GENERATION);
		if( !hWep ) {
			return -1;
		}
		hWep.SetClassname(name);
		hWep.iItemIndex = index;
		hWep.iLevel = level;
		hWep.iQuality = qual;
		char atts[32][32];
		int count = ExplodeString(att, ";", atts, 32, 32);
		
		/// odd numbered attributes result in an error, remove the 1st bit so count will always be even.
		count &= ~1;
		if( count > 0 ) {
			hWep.iNumAttribs = count / 2;
			for( int i, att_index; i < count; i += 2, att_index++ ) {
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
	public int getAmmotable(int wepslot) {
		return g_munitions[this.index].GetAmmo(wepslot);
	}
	
	/**
	 * sets the max recorded ammo for a certain weapon index
	 *
	 * @param wepslot	the equipment slot of the player
	 * @param val		how much the new max ammo should be
	 * @noreturn
	 */
	public void setAmmotable(int wepslot, int val) {
		g_munitions[this.index].SetAmmo(wepslot, val);
	}
	/**
	 * gets the max recorded clipsize for a certain weapon index
	 *
	 * @param wepslot	the equipment slot of the player
	 * @return		the recorded clipsize ammo of the weapon
	 */
	public int getCliptable(int wepslot) {
		return g_munitions[this.index].GetClip(wepslot);
	}
	
	/**
	 * sets the max recorded clipsize for a certain weapon index
	 *
	 * @param wepslot	the equipment slot of the player
	 * @param val		how much the new max clipsize should be
	 * @noreturn
	 */
	public void setCliptable(int wepslot, int val) {
		g_munitions[this.index].SetClip(wepslot, val);
	}
	public int GetWeaponSlotIndex(int slot) {
		int weapon = GetPlayerWeaponSlot(this.index, slot);
		return GetItemIndex(weapon);
	}
	public void SetWepInvis(int alpha) {
		int transparent = alpha;
		for( int i; i < 5; i++ ) {
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
	public bool TeleToSpawn(int team=0) {
		int spawn = -1;
		float pos[3], mins[3], maxs[3];
		int spawn_len;
		int[] spawns = new int[MaxClients+1];
		while( (spawn = FindEntityByClassname(spawn, "info_player_teamspawn")) != -1 ) {
			if( spawn_len >= MaxClients+1 )
				break;
			
			/// skip disabled spawns.
			if( GetEntProp(spawn, Prop_Data, "m_bDisabled") ) {
				continue;
			}
			
			/// now check if the spawn is blocked by something that might get our player stuck.
			GetEntPropVector(spawn, Prop_Send, "m_vecOrigin", pos);
			GetClientMaxs(this.index, maxs);
			GetClientMins(this.index, mins);
			if( !CanFitHere(pos, mins, maxs) ) {
				continue;
			}
			
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
		if( spawn_len <= 0 ) {
			return false;
		}
		
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
		if( !IsClientValidExtra(this.index) || !IsPlayerAlive(this.index) || !this.HasAbility(ABILITY_SPAWN_HEALTH) ) {
			return;
		}
		
		int healthpack = CreateEntityByName("item_healthkit_small");
		if( !IsValidEntity(healthpack) ) {
			return;
		}
		
		float pos[3]; GetClientAbsOrigin(this.index, pos);
		pos[2] += 20.0;
		/// for safety, though it normally doesn't respawn
		DispatchKeyValue(healthpack, "OnPlayerTouch", "!self,Kill,,0,-1");
		DispatchSpawn(healthpack);
		SetEntProp(healthpack, Prop_Send, "m_iTeamNum", ownerteam, 4);
		SetEntityMoveType(healthpack, MOVETYPE_VPHYSICS);
		float vel[3];
		vel[0] = float(GetRandomInt(-10, 10));
		vel[1] = float(GetRandomInt(-10, 10));
		vel[2] = 50.0;
		TeleportEntity(healthpack, pos, NULL_VECTOR, vel);
	}
	public void ForceTeamChange(int team) {
		/// Living Spectator Bug:
		/// If you force a player onto a team with their tfclass not set, they'll appear as a "living" spectator
		if( this.iTFClass > TFClass_Unknown ) {
			SetEntProp(this.index, Prop_Send, "m_lifeState", 2);
			ChangeClientTeam(this.index, team);
			SetEntProp(this.index, Prop_Send, "m_lifeState", 0);
			TF2_RespawnPlayer(this.index);
		}
	}
	
	/// Credit to Mecha the Slag
	public bool ClimbWall(int weapon, float upwardvel, float health, bool attackdelay) {
		if( GetClientHealth(this.index) <= health ) {
			return false;
		}
		int client = this.index;
		float vecClientEyePos[3];
		GetClientEyePosition(client, vecClientEyePos);   /// Get the position of the player's eyes
		
		float vecClientEyeAng[3];
		GetClientEyeAngles(client, vecClientEyeAng);     /// Get the angle the player is looking
		
		/// Check for colliding entities
		TR_TraceRayFilter(vecClientEyePos, vecClientEyeAng, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);
		if( !TR_DidHit() ) {
			return false;
		}
		
		char classname[64];
		int TRIndex = TR_GetEntityIndex(null);
		GetEdictClassname(TRIndex, classname, sizeof(classname));
		if( !(StrEqual(classname, "worldspawn") || !strncmp(classname, "prop_", 5)) ) {
			return false;
		}
		
		float fNormal[3]; TR_GetPlaneNormal(null, fNormal);
		GetVectorAngles(fNormal, fNormal);
		if( fNormal[0] >= 30.0 && fNormal[0] <= 330.0 ) {
			return false;
		}
		if( fNormal[0] <= -30.0 ) {
			return false;
		}
		
		float pos[3]; TR_GetEndPosition(pos);
		float distance = GetVectorDistance(vecClientEyePos, pos, true);
		if( distance >= 100.0*100.0 ) {
			return false;
		}
		
		float fVelocity[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
		fVelocity[2] = upwardvel;
		if( Call_OnPlayerClimb(this, weapon, fVelocity[2], health, attackdelay) > Plugin_Changed ) {
			return false;
		}
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
		SDKHooks_TakeDamage(client, client, client, health, DMG_CLUB, 0); /// Inflictor is 0 to prevent Shiv self-bleed
		this.iClimbs++;
		
		if( attackdelay ) {
			RequestFrame(NoAttacking, EntIndexToEntRef(weapon));
		}
		return true;
	}
	
	public void HelpPanelClass() {
		if( IsVoteInProgress() ) {
			return;
		}
		
		char class_help[][] = {
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
		char exit_test[64];
		Format(exit_test, 64, "%T", "Exit", this.index);
		panel.DrawItem(exit_test);
		panel.Send(this.index, HintPanel, 20);
		delete panel;
	}
	
	public int GetHealTarget() {
		return GetHealingTarget(this.index);
	}
	public bool IsNearDispenser() {
		return IsNearSpencer(this.index);
	}
	public bool IsInRange(int target, float dist, bool trace=false) {
		return IsInRange(this.index, target, dist, trace);
	}
	public void RemoveBack(int[] indices, int len) {
		RemovePlayerBack(this.index, indices, len);
	}
	public int FindBack(int[] indices, int len) {
		return FindPlayerBack(this.index, indices, len);
	}
	public int ShootRocket(bool bCrit=false, float vPosition[3], float vAngles[3], float flSpeed, float dmg, const char[] model, bool arc=false) {
		return ShootRocket(this.index, bCrit, vPosition, vAngles, flSpeed, dmg, model, arc);
	}
	public void Heal(int health, bool on_hud=false, bool overridehp=false, int overheal_limit=0) {
		HealPlayer(this.index, health, on_hud, overridehp, overheal_limit);
	}
	
	public bool SetMusic(const char song[PLATFORM_MAX_PATH]) {
		return g_vsh2.m_hPlayerFields[this.index].SetString("strMusic", song);
	}
	public bool GetMusic(char buffer[PLATFORM_MAX_PATH]) {
		return g_vsh2.m_hPlayerFields[this.index].GetString("strMusic", buffer, sizeof(buffer));
	}
	
	public void PlayMusic(float vol, const char[] override = "") {
		if( this.bNoMusic ) {
			return;
		}
		
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
	
	public bool AddTempAttrib(int attrib, float val, float dur=-1.0) {
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
	
	public void ConvertToBoss() {
		this.flRAGE = 0.0;
		SetPawnTimer(_MakePlayerBoss, 0.1, this.userid);
	}
	
	public void GiveRage(int damage) {
		if( !this.HasAbility(ABILITY_RAGE) ) {
			return;
		}
		/// Patch Oct 26, 2019.
		/// Killing boss throws negative value exception for sqrt.
		float health = ( this.iHealth <= 0? 1 : this.iHealth ) + 0.0;
		float rage_amount = damage / SquareRoot(health) * 1.76;
		if( Call_OnBossGiveRage(this, damage, rage_amount) > Plugin_Changed ) {
			return;
		}
		this.flRAGE += rage_amount;
	}
	
	public void MakeBossAndSwitch(int type, bool run_event, bool friendly=false) {
		this.iBossType = type;
		if( run_event ) {
			ManageOnBossSelected(this);
		}
		
		this.ConvertToBoss();
		if( !friendly && GetClientTeam(this.index)==VSH2Team_Red ) {
			this.ForceTeamChange(VSH2Team_Boss);
		}
	}
	
	public void StunPlayers(float rage_dist, float stun_time=5.0) {
		if( !this.HasAbility(ABILITY_STUN_PLYRS) ) {
			return;
		}
		float boss_pos[3], player_pos[3];
		GetEntPropVector(this.index, Prop_Send, "m_vecOrigin", boss_pos);
		float rage_dist_pow2 = rage_dist*rage_dist;
		for( int i=1; i<=MaxClients; i++ ) {
			if( !IsClientValidExtra(i) || !IsPlayerAlive(i) || i==this.index || GetClientTeam(i)==GetClientTeam(this.index) ) {
				continue;
			}
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", player_pos);
			float distance = GetVectorDistance(boss_pos, player_pos, true);
			if( !TF2_IsPlayerInCondition(i, TFCond_Ubercharged) && distance < rage_dist_pow2 ) {
				CreateTimer(stun_time, RemoveEnt, EntIndexToEntRef(AttachParticle(i, "yikes_fx", 75.0)));
				TF2_StunPlayer(i, stun_time, _, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, this.index);
			}
		}
	}
	
	public void StunBuildings(float rage_dist, float sentry_stun_time=8.0) {
		if( !this.HasAbility(ABILITY_STUN_BUILDS) ) {
			return;
		}
		
		float boss_pos[3], building_pos[3];
		GetEntPropVector(this.index, Prop_Send, "m_vecOrigin", boss_pos);
		float rage_dist_pow2 = rage_dist*rage_dist;
		int i = -1;
		while( (i = FindEntityByClassname(i, "obj_sentrygun")) != -1 ) {
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", building_pos);
			if( GetVectorDistance(boss_pos, building_pos, true) < rage_dist_pow2 ) {
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
			if( GetVectorDistance(boss_pos, building_pos) < rage_dist_pow2 ) {
				SetVariantInt(1);
				AcceptEntityInput(i, "RemoveHealth");
			}
		}
		i = -1;
		while( (i = FindEntityByClassname(i, "obj_teleporter")) != -1 ) {
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", building_pos);
			if( GetVectorDistance(boss_pos, building_pos) < rage_dist_pow2 ) {
				SetVariantInt(1);
				AcceptEntityInput(i, "RemoveHealth");
			}
		}
	}
	
	public void DoGenericStun(float rage_dist) {
		Action act = Call_OnBossDoRageStun(this, rage_dist);
		if( act > Plugin_Changed ) {
			return;
		}
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
	
	public void SuperJump(float power, float reset) {
		if( Call_OnBossSuperJump(this) > Plugin_Changed ) {
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
	
	public void WeighDown(float reset) {
		if( Call_OnBossWeighDown(this) > Plugin_Changed ) {
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
	
	public void PlayVoiceClip(const char[] vclip, int flags) {
		int client = this.index;
		float pos[3];
		if( flags & VSH2_VOICE_BOSSPOS ) {
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
		}
		EmitSoundToAll(vclip, (flags & VSH2_VOICE_BOSSENT)? client : SOUND_FROM_PLAYER, (flags & VSH2_VOICE_ALLCHAN)? SNDCHAN_AUTO : SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, (flags & VSH2_VOICE_BOSSPOS)? pos : NULL_VECTOR, NULL_VECTOR, true, 0.0);
		
		if( !(flags & VSH2_VOICE_ONCE) ) {
			EmitSoundToAll(vclip, (flags & VSH2_VOICE_BOSSENT)? client : SOUND_FROM_PLAYER, (flags & VSH2_VOICE_ALLCHAN)? SNDCHAN_AUTO : SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, (flags & VSH2_VOICE_BOSSPOS)? pos : NULL_VECTOR, NULL_VECTOR, true, 0.0);
		}
		if( flags & VSH2_VOICE_TOALL ) {
			for( int i=1; i<=MaxClients; i++ ) {
				if( !IsClientInGame(i) || i==client ) {
					continue;
				}
				for( int x; x < 2; x++ ) {
					EmitSoundToClient(i, vclip, client, (flags & VSH2_VOICE_ALLCHAN)? SNDCHAN_AUTO : SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, (flags & VSH2_VOICE_BOSSPOS)? pos : NULL_VECTOR, NULL_VECTOR, true, 0.0);
				}
			}
		}
	}
	
	public void SpeedThink(float iota, float minspeed=100.0) {
		float speed = iota + 0.7 * (100 - this.iHealth * 100 / this.iMaxHealth);
		SetEntPropFloat(this.index, Prop_Send, "m_flMaxspeed", (speed < minspeed)? minspeed : speed);
	}
	public void GlowThink(float decrease) {
		if( this.flGlowtime > 0.0 ) {
			SetEntProp(this.index, Prop_Send, "m_bGlowEnabled", 1);
			this.flGlowtime -= decrease;
		} else {
			SetEntProp(this.index, Prop_Send, "m_bGlowEnabled", 0);
		}
	}
	
	public bool ChargedAbilityThink(float charge_rate, float &charge, float max_charge, float min_charge, int req_buttons, bool cond, bool &super_charged=false) {
		if( charge < 0.0 ) {
			charge += charge_rate;
			return false;
		}
		
		int client  = this.index;
		int buttons = GetClientButtons(client);
		if( buttons & req_buttons ) {
			charge += charge_rate;
			if( charge > max_charge ) {
				charge = max_charge;
			}
		} else {
			if( (super_charged || charge >= min_charge) && cond ) {
				if( super_charged ) {
					super_charged = false;
				}
				return true;
			}
			charge = 0.0;
		}
		return false;
	}
	
	public bool SuperJumpThink(float charging, float jumpcharge) {
		float charge = this.flCharge;
		float minimum_charge = 1.0;
		float angle_eyes[3]; GetClientEyeAngles(this.index, angle_eyes);
		bool res = this.ChargedAbilityThink(charging, charge, jumpcharge, minimum_charge, IN_DUCK|IN_ATTACK2, angle_eyes[0] < -5.0);
		this.flCharge = charge;
		return res;
	}
	public void WeighDownThink(float weighdown_time, float min_angle=60.0) {
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
			if( ang[0] > min_angle ) {
				this.WeighDown(0.0);
			}
		}
	}
	
	public void TeleToRandomPlayer(float charge_reset, bool supercharge_reset) {
		int client     = this.index;
		int target     = GetRandomClient(_, VSH2Team_Red);
		float currtime = GetGameTime();
		int flags      = GetEntityFlags(client);
		if( target != -1 ) {
			BasePlayer t = BasePlayer(target);
			/// Chdata's HHH teleport rework
			if( t.iTFClass != TFClass_Scout && t.iTFClass != TFClass_Soldier ) {
				/// Makes HHH clipping go away for player and some projectiles
				SetEntProp(client, Prop_Send, "m_CollisionGroup", 2);
				SetPawnTimer(HHHTeleCollisionReset, 2.0, this.userid);
			}
			CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(client, "ghost_appearation", _, false)));
			float pos[3]; GetClientAbsOrigin(target, pos);
			SetEntPropFloat(client, Prop_Send, "m_flNextAttack", currtime+2);
			if( GetEntProp(target, Prop_Send, "m_bDucked") ) {
				float collisionvec[3] = {24.0, 24.0, 62.0};
				SetEntPropVector(client, Prop_Send, "m_vecMaxs", collisionvec);
				SetEntProp(client, Prop_Send, "m_bDucked", 1);
				SetEntityFlags(client, flags|FL_DUCKING);
				SetPawnTimer(StunHHH, 0.2, this.userid, GetClientUserId(target));
			} else {
				TF2_StunPlayer(client, 2.0, 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, target);
			}
			TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
			SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);
			CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(client, "ghost_appearation")));
			CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(client, "ghost_appearation", _, false)));
			
			/// Chdata's HHH teleport rework
			float vPos[3]; GetEntPropVector(target, Prop_Send, "m_vecOrigin", vPos);
			EmitSoundToClient(client, "misc/halloween/spell_teleport.wav");
			EmitSoundToClient(target, "misc/halloween/spell_teleport.wav");
			PrintCenterText(target, "You've been teleported!");
			this.flCharge = charge_reset;
		}
		if( supercharge_reset && this.bSuperCharge ) {
			this.bSuperCharge = false;
		}
	}
	
	public void PlayRandVoiceClipFromCfg(ConfigMap sect, int voice_flags) {
		if( sect==null || sect.Size <= 0 ) {
			return;
		}
		int sound_idx = GetRandomInt(0, sect.Size - 1);
		int sound_len = sect.GetIntKeySize(sound_idx);
		char[] sound_str = new char[sound_len];
		if( sect.GetIntKey(sound_idx, sound_str, sound_len) > 0 ) {
			this.PlayVoiceClip(sound_str, voice_flags);
		}
	}
};


public int HintPanel(Menu menu, MenuAction action, int param1, int param2) {
	return 0;
}

public void SetGravityNormal(BasePlayer player) {
	int client = player.index;
	if( IsClientValid(client) ) {
		SetEntityGravity(client, 1.0);
	}
}

public void TF2AttribsRemoveAll(int ent) {
#if defined _tf2attributes_included
	TF2Attrib_RemoveAll(ent);
#endif
}

public void TF2AttribsRemove(int userid, int attrib) {
#if defined _tf2attributes_included
	TF2Attrib_RemoveByDefIndex(GetClientOfUserId(userid), attrib);
#endif
}

public void HHHTeleCollisionReset(BasePlayer player) {
	SetEntProp(player.index, Prop_Send, "m_CollisionGroup", 5); /// Fix HHH's clipping.
}
public void StunHHH(int userid, int targetid) {
	int client = GetClientOfUserId(userid);
	int target = GetClientOfUserId(targetid);
	if( !IsClientValid(client) || !IsClientValid(target)
	 || !IsPlayerAlive(client) || !IsPlayerAlive(target) ) {
		return;
	}
	TF2_StunPlayer(client, 2.0, 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, target);
}

public void EnableSG(int sentry_ref) {
	int i = EntRefToEntIndex(sentry_ref);
	if( !IsValidEntity(i) ) {
		return;
	}
	
	char s[32]; GetEdictClassname(i, s, sizeof(s));
	if( StrEqual(s, "obj_sentrygun") ) {
		SetEntProp(i, Prop_Send, "m_bDisabled", 0);
		for( int ent=2048; ent > (MaxClients+1); ent-- ) {
			if( !IsValidEntity(ent) || ent <= 0 ) {
				continue;
			}
			char s2[32]; GetEdictClassname(ent, s2, sizeof(s2));
			if( StrEqual(s2, "info_particle_system") && GetOwner(ent)==i ) {
				AcceptEntityInput(ent, "Kill");
			}
		}
	}
}