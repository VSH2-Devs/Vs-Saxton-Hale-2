/// all game mode oriented code should be handled HERE ONLY.
methodmap VSHGameMode < StringMap {
	public VSHGameMode() {
		return view_as< VSHGameMode >(new StringMap());
	}
	property int iRoundState {
		public get() {
			int i; this.GetValue("iRoundState", i);
			return i;
		}
		public set(const int val) {
			this.SetValue("iRoundState", val);
		}
	}
	property int iSpecial {
		public get() {
			int i; this.GetValue("iSpecial", i);
			return i;
		}
		public set(const int val) {
			this.SetValue("iSpecial", val);
		}
	}
	property int iPrevSpecial {
		public get() {
			int i; this.GetValue("iPrevSpecial", i);
			return i;
		}
		public set(const int val) {
			this.SetValue("iPrevSpecial", val);
		}
	}
	property VSHHealthBar iHealthBar { /// in vsh2.inc
		public get() {
			VSHHealthBar i; this.GetValue("iHealthBar", i);
			return i;
		}
		public set(const VSHHealthBar val) {
			this.SetValue("iHealthBar", val);
		}
	}
	property int iTotalMaxHealth {
		public get() {
			int i; this.GetValue("iTotalMaxHealth", i);
			return i;
		}
		public set(const int val) {
			this.SetValue("iTotalMaxHealth", val);
		}
	}
	property int iTimeLeft {
		public get() {
			int i; this.GetValue("iTimeLeft", i);
			return i;
		}
		public set(const int val) {
			this.SetValue("iTimeLeft", val);
		}
	}
	property int iRoundCount {
		public get() {
			int i; this.GetValue("iRoundCount", i);
			return i;
		}
		public set(const int val) {
			this.SetValue("iRoundCount", val);
		}
	}
	property int iHealthChecks {
		public get() {
			int i; this.GetValue("iHealthChecks", i);
			return i;
		}
		public set(const int val) {
			this.SetValue("iHealthChecks", val);
		}
	}
	property int iCaptures {
		public get() {
			int i; this.GetValue("iCaptures", i);
			return i;
		}
		public set(const int val) {
			this.SetValue("iCaptures", val);
		}
	}
	
	property bool bSteam {
		public get() {
			bool i; this.GetValue("bSteam", i);
			return i;
		}
		public set(const bool val) {
			this.SetValue("bSteam", val);
		}
	}
	property bool bTF2Attribs {
		public get() {
			bool i; this.GetValue("bTF2Attribs", i);
			return i;
		}
		public set(const bool val) {
			this.SetValue("bTF2Attribs", val);
		}
	}
	property bool bPointReady {
		public get() {
			bool i; this.GetValue("bPointReady", i);
			return i;
		}
		public set(const bool val) {
			this.SetValue("bPointReady", val);
		}
	}
	property bool bMedieval {
		public get() {
			bool i; this.GetValue("bMedieval", i);
			return i;
		}
		public set(const bool val) {
			this.SetValue("bMedieval", val);
		}
	}
	property bool bDoors {
		public get() {
			bool i; this.GetValue("bDoors", i);
			return i;
		}
		public set(const bool val) {
			this.SetValue("bDoors", val);
		}
	}
	property bool bTeleToSpawn {
		public get() {
			bool i; this.GetValue("bTeleToSpawn", i);
			return i;
		}
		public set(const bool val) {
			this.SetValue("bTeleToSpawn", val);
		}
	}
	
	property float flHealthTime {
		public get() {
			float i; this.GetValue("flHealthTime", i);
			return i;
		}
		public set(const float val) {
			this.SetValue("flHealthTime", val);
		}
	}
	property float flMusicTime {
		public get() {
			float i; this.GetValue("flMusicTime", i);
			return i;
		}
		public set(const float val) {
			this.SetValue("flMusicTime", val);
		}
	}
	
	property float flRoundStartTime {
		public get() {
			float i; this.GetValue("flRoundStartTime", i);
			return i;
		}
		public set(const float val) {
			this.SetValue("flRoundStartTime", val);
		}
	}
	
	property BaseBoss hNextBoss {
		public get() {
			BaseBoss i; this.GetValue("hNextBoss", i);
			if( i && !i.index ) {
				this.SetValue("hNextBoss", 0);
				i = view_as< BaseBoss >(0);
			}
			return i;
		}
		public set(const BaseBoss val) {
			this.SetValue("hNextBoss", val);
		}
	}
	
	/// When adding a new property, make sure you initialize it to a default
	public void Init() {
		this.iRoundState = 0;
		this.iSpecial = -1;
		this.iPrevSpecial = -1;
		this.iHealthBar = view_as< VSHHealthBar >(0);
		this.iTotalMaxHealth = 0;
		this.iTimeLeft = 0;
		this.iRoundCount = 0;
		this.iHealthChecks = 0;
		this.iCaptures = 0;
#if defined _steamtools_included
		this.bSteam = false;
#endif
		this.bPointReady = false;
		this.bMedieval = false;
		this.bDoors = false;
		this.bTeleToSpawn = false;
		this.flHealthTime = 0.0;
		this.flMusicTime = 0.0;
		this.flRoundStartTime = 0.0;
		this.hNextBoss = view_as< BaseBoss >(0);
	}
	
	public static BaseBoss GetRandomBoss(const bool balive) {
		int count;
		BaseBoss[] bosses = new BaseBoss[MaxClients];
		for( int i=MaxClients; i; --i ) {
			if( !IsValidClient(i) || (balive && !IsPlayerAlive(i)) )
				continue;
			BaseBoss boss = BaseBoss(i);
			if( !boss.bIsBoss )
				continue;
			bosses[count++] = boss;
		}
		return (!count ? view_as< BaseBoss >(0) : bosses[GetRandomInt(0, count-1)]);
	}
	
	public static BaseBoss GetBossByType(const bool balive, const int type) {
		for( int i=MaxClients; i; --i ) {
			if( !IsValidClient(i) || (balive && !IsPlayerAlive(i)) )
				continue;
			BaseBoss boss = BaseBoss(i);
			if( !boss.bIsBoss )
				continue;
			else if( boss.iBossType==type )
				return boss;
		}
		return view_as< BaseBoss >(0);
	}
	public static void CheckArena(const bool type) {
		if( type ) {
			SetArenaCapEnableTime( float(45+g_vsh2.m_hCvars.PointDelay.IntValue*(GetLivingPlayers(VSH2Team_Red)-1)) );
		} else {
			SetArenaCapEnableTime(0.0);
			SetControlPoint(false);
		}
	}
	
	public static int GetQueue(BaseBoss[] players) {
		int k;
		for( int i=MaxClients; i; --i ) {
			if( !IsValidClient(i) || GetClientTeam(i) <= VSH2Team_Spectator )
				continue;
			
			BaseBoss boss = BaseBoss(i);
			if( boss.bIsBoss ) {
				continue;
			}
			players[k++] = boss;
		}
		
		for( int i; i<k; i++ ) {
			for( int n; n<k; n++ ) {
				if( players[n].iQueue < players[i].iQueue ) {
					BaseBoss t = players[i];
					players[i] = players[n];
					players[n] = t;
				}
			}
		}
		return k;
	}
	
	public static BaseBoss FindNextBoss() {
		BaseBoss[] players = new BaseBoss[MaxClients];
		VSHGameMode.GetQueue(players);
		return players[0];
	}
	
	public static int CountMinions(const bool balive, BaseBoss owner=view_as< BaseBoss >(0)) {
		int count=0;
		for( int i=MaxClients; i; --i ) {
			if( !IsValidClient(i) || (balive && !IsPlayerAlive(i)) )
				continue;
			BaseBoss minion = BaseBoss(i);
			if( !minion.bIsMinion ) {
				continue;
			} else if( !owner || owner.userid==minion.iOwnerBoss ) {
				++count;
			}
		}
		return count;
	}
	public static int CountBosses(const bool balive) {
		int count=0;
		for( int i=MaxClients; i; --i ) {
			if( !IsValidClient(i) || (balive && !IsPlayerAlive(i)) )
				continue;
			BaseBoss boss = BaseBoss(i);
			if( !boss.bIsBoss )
				continue;
			++count;
		}
		return count;
	}
	public static int GetTotalBossHealth() {
		int count=0;
		for( int i=MaxClients; i; --i ) {
			if( !IsValidClient(i) )
				continue;
			
			BaseBoss boss = BaseBoss(i);
			if( !boss.bIsBoss )
				continue;
			count += boss.iHealth;
		}
		return count;
	}
	public static void ReplaceAmmoPack(int ent, int setting) {
		float pos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
		AcceptEntityInput(ent, "Kill");
		
		DataPack vecPack = new DataPack();
		vecPack.WriteFloat(pos[0]);
		vecPack.WriteFloat(pos[1]);
		vecPack.WriteFloat(pos[2]);
		vecPack.WriteCell(setting);
		CreateTimer(0.2, SetAmmoPack, vecPack, TIMER_DATA_HNDL_CLOSE);
	}
	public static void SearchForItemPacks()
	{
		int ammo_pack_setting = g_vsh2.m_hCvars.ChangeAmmoPacks.IntValue;
		if( ammo_pack_setting > 0 ) {
			int ent = -1;
			while( (ent = FindEntityByClassname(ent, "item_ammopack_*")) != -1 ) {
				VSHGameMode.ReplaceAmmoPack(ent, ammo_pack_setting);
			}
		}
		
		bool foundAmmo, foundHealth;
		int ent = -1, count = 0;
		while( (ent = FindEntityByClassname(ent, "item_healthkit_small")) != -1 ) {
			SetEntProp(ent, Prop_Send, "m_iTeamNum", g_vsh2.m_hCvars.Enabled.BoolValue ? VSH2Team_Red : VSH2Team_Neutral, 4);
			count++;
			if( !foundHealth )
				foundHealth = (count > 9);
		}
		ent = -1;
		count = 0;
		while( (ent = FindEntityByClassname(ent, "item_healthkit_medium")) != -1 ) {
			SetEntProp(ent, Prop_Send, "m_iTeamNum", g_vsh2.m_hCvars.Enabled.BoolValue ? VSH2Team_Red : VSH2Team_Neutral, 4);
			count++;
			if( !foundHealth )
				foundHealth = (count > 6);
		}
		ent = -1;
		count = 0;
		while( (ent = FindEntityByClassname(ent, "item_healthkit_full")) != -1 ) {
			SetEntProp(ent, Prop_Send, "m_iTeamNum", g_vsh2.m_hCvars.Enabled.BoolValue ? VSH2Team_Red : VSH2Team_Neutral, 4);
			count++;
			if( !foundHealth )
				foundHealth = (count > 3);
		}
		
		if( !foundAmmo ) {
			SpawnRandomAmmo(
				g_vsh2.m_hCvars.AmmoKitLimitMax.IntValue,
				g_vsh2.m_hCvars.AmmoKitLimitMin.IntValue,
				g_vsh2.m_hCvars.Enabled
			);
		}
		if( !foundHealth ) {
			SpawnRandomHealth(
				g_vsh2.m_hCvars.HealthKitLimitMax.IntValue,
				g_vsh2.m_hCvars.HealthKitLimitMin.IntValue,
				g_vsh2.m_hCvars.Enabled
			);
		}
	}
	public void UpdateBossHealth() {
		int totalHealth, bosscount;
		for( int i=MaxClients; i; --i ) {
			/// don't count dead bosses
			if( !IsValidClient(i) || !IsPlayerAlive(i) ) {
				continue;
			}
			
			BaseBoss boss = BaseBoss(i);
			if( !boss.bIsBoss ) {
				continue;
			}
			bosscount++;
			totalHealth += boss.iHealth;
		}
		if( bosscount > 0 ) {
			this.iHealthBar.SetHealthPercent(totalHealth, this.iTotalMaxHealth);
		}
	}
	public void GetBossType()
	{
		if( this.hNextBoss && this.hNextBoss.iPresetType > -1 ) {
			this.iSpecial = this.hNextBoss.iPresetType;
			if( this.iSpecial > MAXBOSS ) {
				this.iSpecial = MAXBOSS;
			}
			return;
		}
		
		BaseBoss boss = VSHGameMode.FindNextBoss();
		if( boss.iPresetType > -1 && this.iSpecial == -1 ) {
			this.iSpecial = boss.iPresetType;
			if( this.iSpecial > MAXBOSS ) {
				this.iSpecial = MAXBOSS;
			}
			return;
		}
		if( this.iSpecial > -1 ) {    /// Clamp the chosen special so we don't error out.
			if( this.iSpecial > MAXBOSS ) {
				this.iSpecial = MAXBOSS;
			}
		} else {
			this.iSpecial = GetRandomInt(VSH2Boss_Hale, MAXBOSS);
		}
	}
	/// just use arena maps as vsh/ff2 maps
	public static bool IsVSHMap()
	{
		char config[PLATFORM_MAX_PATH], currentmap[99];
		GetCurrentMap(currentmap, sizeof(currentmap));
		if( FileExists("bNextMapToFF2") || FileExists("bNextMapToHale") )
			return true;
		
		BuildPath(Path_SM, config, PLATFORM_MAX_PATH, "configs/freak_fortress_2/maps.cfg");
		if( !FileExists(config) ) {
			BuildPath(Path_SM, config, PLATFORM_MAX_PATH, "configs/saxton_hale/saxton_hale_maps.cfg");
			if( !FileExists(config) ) {
				LogError("[VSH 2] ERROR: **** Unable to find VSH/FF2 Compatible Map Configs, Disabling VSH 2 ****");
				return false;
			}
		}
		
		File file = OpenFile(config, "r");
		if( !file ) {
			LogError("[VSH 2] **** Error Reading Maps from %s Config, Disabling VSH 2 ****", config);
			return false;
		}
		
		int tries;
		while( file.ReadLine(config, sizeof(config)) && tries < 100 ) {
			++tries;
			if( tries == 100 ) {
				LogError("[VSH 2] **** Breaking Loop Looking For a Map, Disabling VSH 2 ****");
				return false;
			}
			
			Format(config, strlen(config)-1, config);
			if( !strncmp(config, "//", 2, false) )
				continue;
			
			if( StrContains(currentmap, config, false) != -1 || StrContains(config, "all", false) != -1 ) {
				file.Close();
				return true;
			}
		}
		delete file;
		return false;
		
		/// do not remove this plz.
		//if( FindEntityByClassname(-1, "tf_logic_arena") != -1 )
		//	return true;
		//return false;
	}
	
	public void CheckDoors()
	{
		char config[PLATFORM_MAX_PATH], currentmap[99];
		char lolcano[] = "vsh_lolcano_pb1";
		GetCurrentMap(currentmap, sizeof(currentmap));
		this.bDoors = false;
		BuildPath(Path_SM, config, PLATFORM_MAX_PATH, "configs/saxton_hale/saxton_hale_doors.cfg");
		if( !FileExists(config) ) {
			if( !strncmp(currentmap, lolcano, sizeof(lolcano), false) )
				this.bDoors = true;
			return;
		}
		
		File file = OpenFile(config, "r");
		if( !file ) {
			if( !strncmp(currentmap, lolcano, sizeof(lolcano), false) )
				this.bDoors = true;
			return;
		}
		while( !file.EndOfFile() && file.ReadLine(config, sizeof(config)) ) {
			Format(config, strlen(config)-1, config);
			if( !strncmp(config, "//", 2, false) )
				continue;
			else if( StrContains(currentmap, config, false) != -1 || !StrContains(config, "all", false) ) {
				delete file;
				this.bDoors = true;
				return;
			}
		}
		delete file;
	}
	
	public void CheckTeleToSpawn()
	{
		char config[PLATFORM_MAX_PATH], currentmap[99];
		GetCurrentMap(currentmap, sizeof(currentmap));
		this.bTeleToSpawn = false;
		
		BuildPath(Path_SM, config, PLATFORM_MAX_PATH, "configs/saxton_hale/saxton_spawn_teleport.cfg");
		if( !FileExists(config) )
			return;
		
		File file = OpenFile(config, "r");
		if( !file )
			return;
		
		while( !file.EndOfFile() && file.ReadLine(config, sizeof(config)) ) {
			Format(config, strlen(config) - 1, config);
			if( !strncmp(config, "//", 2, false) ) {
				continue;
			} else if( StrContains(currentmap, config, false) != -1 || !StrContains(config, "all", false) ) {
				this.bTeleToSpawn = true;
				delete file;
				return;
			}
		}
		delete file;
	}
	
	public static int GetBosses(BaseBoss[] bossarray, const bool balive) {
		int count;
		for( int i=MaxClients; i; --i ) {
			if( !IsClientInGame(i) )
				continue;
			else if( balive && !IsPlayerAlive(i) )
				continue;
			
			BaseBoss boss = BaseBoss(i);
			if( boss.bIsBoss )
				bossarray[count++] = boss;
		}
		return count;
	}
	public static int GetBossesByType(BaseBoss[] bossarray, const int type, const bool balive=true) {
		int count;
		for( int i=MaxClients; i; --i ) {
			if( !IsClientInGame(i) )
				continue;
			else if( balive && !IsPlayerAlive(i) )
				continue;
			
			BaseBoss boss = BaseBoss(i);
			if( boss.bIsBoss && boss.iBossType==type )
				bossarray[count++] = boss;
		}
		return count;
	}
	public static int GetFighters(BaseBoss[] redarray, const bool balive) {
		int count;
		for( int i=MaxClients; i; --i ) {
			if( !IsClientInGame(i) || GetClientTeam(i) <= VSH2Team_Spectator )
				continue;
			else if( balive && !IsPlayerAlive(i) )
				continue;
			
			BaseBoss red = BaseBoss(i);
			if( !red.bIsBoss && !red.bIsMinion )
				redarray[count++] = red;
		}
		return count;
	}
	public static int GetFightersByClass(BaseBoss[] redarray, TFClassType tfclass, const bool balive) {
		int count;
		for( int i=MaxClients; i; --i ) {
			if( !IsClientInGame(i) || GetClientTeam(i) <= VSH2Team_Spectator ) {
				continue;
			} else if( balive && !IsPlayerAlive(i) ) {
				continue;
			}
			BaseBoss red = BaseBoss(i);
			if( !red.bIsBoss && !red.bIsMinion && red.iTFClass==tfclass ) {
				redarray[count++] = red;
			}
		}
		return count;
	}
	public static int GetMinions(BaseBoss[] marray, const bool balive, BaseBoss owner=view_as< BaseBoss >(0)) {
		int count;
		for( int i=MaxClients; i; --i ) {
			if( !IsClientInGame(i) ) {
				continue;
			} else if( balive && !IsPlayerAlive(i) ) {
				continue;
			}
			BaseBoss minion = BaseBoss(i);
			if( minion.bIsMinion && (!owner || owner.userid==minion.iOwnerBoss) ) {
				marray[count++] = minion;
			}
		}
		return count;
	}
	
	public static int CalcBossMaxHP(int red_players, int boss_count) {
		/// In stocks.sp
		int max_health = CalcBossHealth(760.8, red_players, 1.0, 1.0341, 2046.0) / (boss_count);
		if( max_health < 3000 && boss_count==1 ) {
			max_health = 3000;
		} else if( max_health > 3000 && boss_count > 1 ) {
			/// Putting in multiboss Handicap from complaints of fighting multiple bosses being too overpowered since teamwork itself is overpowered :)
			max_health -= g_vsh2.m_hCvars.MultiBossHandicap.IntValue;
		}
		return max_health;
	}
};

public Action SetAmmoPack(Handle timer, DataPack pack) {
	pack.Reset();
	float vecPos[3];
	vecPos[0] = pack.ReadFloat();
	vecPos[1] = pack.ReadFloat();
	vecPos[2] = pack.ReadFloat();
	int setting = pack.ReadCell();
	
	char ammopack_names[][] = {
		"item_ammopack_small",
		"item_ammopack_medium",
		"item_ammopack_large"
	};
	
	int ammopack_ent = -1;
	switch( setting ) {
		case 1: ammopack_ent = CreateEntityByName(ammopack_names[setting-1]);
		case 2: ammopack_ent = CreateEntityByName(ammopack_names[setting-1]);
		case 3: ammopack_ent = CreateEntityByName(ammopack_names[setting-1]);
		default: ammopack_ent = CreateEntityByName(ammopack_names[GetRandomInt(0, sizeof(ammopack_names)-1)]);
	}
	TeleportEntity(ammopack_ent, vecPos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(ammopack_ent);
	//SetEntProp(ammopack_ent, Prop_Send, "m_iTeamNum", manager.bMainEnable ? manager.iRedTeam : 0, 4);
	return Plugin_Continue;
}