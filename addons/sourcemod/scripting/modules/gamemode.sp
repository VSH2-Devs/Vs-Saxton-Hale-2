enum {	/* VSH2 Round States */
	StateDisabled = -1,
	StateStarting = 0,
	StateRunning = 1,
	StateEnding = 2,
};

/*
enum {
	Skill_Normal = 0,
	Skill_AllCrits,
	Skill_RuneKing,
	Skill_RuneHaste,
	Skill_RuneKnockout,
	Skill_RunePrecision,
	Skill_RuneAgility,
	Skill_RuneStrength,
	Skill_GnG,
	Skill_MiniCrits
};

public int AllowedDifficulties[] = {
	Skill_AllCrits,
	Skill_RuneKing,
	Skill_RuneHaste,
	Skill_RuneKnockout,
	Skill_RunePrecision,
	Skill_RuneAgility,
	Skill_RuneStrength,
	Skill_MiniCrits
};
*/

StringMap hGameModeFields ;

methodmap VSHGameMode /* < StringMap */		/* all game mode oriented code should be handled HERE ONLY */
{
	public VSHGameMode()
	{
		hGameModeFields = new StringMap();
	}
	property int iRoundState
	{
		public get()			//{ return state; }
		{
			int i; hGameModeFields.GetValue("iRoundState", i);
			return i;
		}
		public set(const int val)	//{ state = val; }
		{
			hGameModeFields.SetValue("iRoundState", val);
		}
	}
	property int iSpecial
	{
		public get()			//{ return BossSpecial; }
		{
			int i; hGameModeFields.GetValue("iSpecial", i);
			return i;
		}
		public set(const int val)	//{ BossSpecial = val; }
		{
			hGameModeFields.SetValue("iSpecial", val);
		}
	}
	property int iPlaying
	{
		public get()
		{
			int playing = 0;
			for( int i=MaxClients ; i ; --i ) {
				if( !IsClientInGame(i) )
					continue;
				else if( !IsPlayerAlive(i) )
					continue;
				if( BaseBoss(i).bIsBoss )
					continue;
				++playing;
			}
			return playing;
		}
	}
	property int iHealthBar
	{
		public get()			//{ return HealthBar; }
		{
			int i; hGameModeFields.GetValue("iHealthBar", i);
			return i;
		}
		public set(const int val)	//{ HealthBar = val; }
		{
			hGameModeFields.SetValue("iHealthBar", val);
		}
	}
	property int iHealthBarState
	{
		public get()			{ return GetEntProp(this.iHealthBar, Prop_Send, "m_iBossState"); }
		public set(const int val)	{ SetEntProp(this.iHealthBar, Prop_Send, "m_iBossState", val); }
	}
	property int iHealthBarPercent
	{
		public get()			{ return GetEntProp(this.iHealthBar, Prop_Send, "m_iBossHealthPercentageByte"); }
		public set(const int val)
		{
			int clamped = val;
			if( clamped>255 )
				clamped = 255;
			else if( clamped<0 )
				clamped = 0;
			SetEntProp(this.iHealthBar, Prop_Send, "m_iBossHealthPercentageByte", clamped);
		}
	}
	property int iTotalMaxHealth
	{
		public get()			//{ return TotalMaxHealth; }
		{
			int i; hGameModeFields.GetValue("iTotalMaxHealth", i);
			return i;
		}
		public set(const int val)	//{ TotalMaxHealth = val; }
		{
			hGameModeFields.SetValue("iTotalMaxHealth", val);
		}
	}
	property int iTimeLeft
	{
		public get()			//{ return TimeLeft; }
		{
			int i; hGameModeFields.GetValue("iTimeLeft", i);
			return i;
		}
		public set(const int val)	//{ TimeLeft = val; }
		{
			hGameModeFields.SetValue("iTimeLeft", val);
		}
	}
	property int iRoundCount
	{
		public get()			//{ return RoundCount; }
		{
			int i; hGameModeFields.GetValue("iRoundCount", i);
			return i;
		}
		public set(const int val)	//{ RoundCount = val; }
		{
			hGameModeFields.SetValue("iRoundCount", val);
		}
	}
	property int iHealthChecks
	{
		public get()			//{ return HealthChecks; }
		{
			int i; hGameModeFields.GetValue("iHealthChecks", i);
			return i;
		}
		public set(const int val)	//{ HealthChecks = val; }
		{
			hGameModeFields.SetValue("iHealthChecks", val);
		}
	}
	property int iCaptures
	{
		public get()			//{ return NumCaps; }
		{
			int i; hGameModeFields.GetValue("iCaptures", i);
			return i;
		}
		public set(const int val)	//{ NumCaps = val; }
		{
			hGameModeFields.SetValue("iCaptures", val);
		}
	}
	
#if defined _steamtools_included
	property bool bSteam
	{
		public get()			//{ return steamtools; }
		{
			bool i; hGameModeFields.GetValue("bSteam", i);
			return i;
		}
		public set(const bool val)	//{ steamtools = val; }
		{
			hGameModeFields.SetValue("bSteam", val);
		}
	}
#endif
#if defined _tf2attributes_included
	property bool bTF2Attribs
	{
		public get()
		{
			bool i; hGameModeFields.GetValue("bTF2Attribs", i);
			return i;
		}
		public set(const bool val)
		{
			hGameModeFields.SetValue("bTF2Attribs", val);
		}
	}
#endif
	property bool bPointReady
	{
		public get()			//{ return PointReady; }
		{
			bool i; hGameModeFields.GetValue("bPointReady", i);
			return i;
		}
		public set(const bool val)	//{ PointReady = val; }
		{
			hGameModeFields.SetValue("bPointReady", val);
		}
	}
	property bool bMedieval
	{
		public get()			//{ return Medieval; }
		{
			bool i; hGameModeFields.GetValue("bMedieval", i);
			return i;
		}
		public set(const bool val)	//{ Medieval = val; }
		{
			hGameModeFields.SetValue("bMedieval", val);
		}
	}

	property float flHealthTime
	{
		public get()			//{ return HealthTime; }
		{
			float i; hGameModeFields.GetValue("flHealthTime", i);
			return i;
		}
		public set(const float val)	//{ HealthTime = val; }
		{
			hGameModeFields.SetValue("flHealthTime", val);
		}
	}
	property float flMusicTime
	{
		public get()			//{ return MusicTime; }
		{
			float i; hGameModeFields.GetValue("flMusicTime", i);
			return i;
		}
		public set(const float val)	//{ MusicTime = val; }
		{
			hGameModeFields.SetValue("flMusicTime", val);
		}
	}

	property BaseBoss hNextBoss
	{
		public get()
		/*{
			if( !preselected.userid or !IsClientValid(preselected.index) )
				return view_as< BaseBoss >(0);
			return preselected;
		}*/
		{
			BaseBoss i; hGameModeFields.GetValue("hNextBoss", i);
			if( !i or !i.index )
				return view_as< BaseBoss >(0);
			return i;
		}
		public set(const BaseBoss val)	//{ preselected = val; }
		{
			hGameModeFields.SetValue("hNextBoss", val);
		}
	}
	/*
	property Handle hMusic
	{
		public get()			{ return hMusicTimer; }
		public set(const Handle val)	{ hMusicTimer = val; }
	}
	*/
	
	public void Init()	// When adding a new property, make sure you initialize it to a default 
	{
		this.iRoundState = 0;
		this.iSpecial = -1;
		this.iHealthBar = 0;
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
		this.flHealthTime = 0.0;
		this.flMusicTime = 0.0;
		this.hNextBoss = view_as< BaseBoss >(0);
	}

	public BaseBoss GetRandomBoss(const bool balive)
	{
		int count;
		BaseBoss boss;
		BaseBoss[] bosses = new BaseBoss[MaxClients];
		for( int i=MaxClients ; i ; --i ) {
			if( !IsValidClient(i) )
				continue;
			else if( balive and !IsPlayerAlive(i) )
				continue;
			boss = BaseBoss(i);
			if( !boss.bIsBoss )
				continue;
			bosses[count++] = boss;
		}
		return (!count ? view_as< BaseBoss >(0) : bosses[GetRandomInt(0, count-1)]);
	}
	public BaseBoss GetBossByType(const bool balive, const int type)
	{
		BaseBoss boss;
		for( int i=MaxClients ; i ; --i ) {
			if( !IsValidClient(i) )
				continue;
			else if( balive and !IsPlayerAlive(i) )
				continue;
			boss = BaseBoss(i);
			if( !boss.bIsBoss )
				continue;
			if( boss.iType==type )
				return boss;
		}
		return view_as< BaseBoss >(0);
	}
	public void CheckArena(const bool type)
	{
		if( type )
			SetArenaCapEnableTime( float(45+cvarVSH2[PointDelay].IntValue*(this.iPlaying-1)) );
		else {
			SetArenaCapEnableTime(0.0);
			SetControlPoint(false);
		}
	}
	public BaseBoss FindNextBoss()
	{
		BaseBoss tBoss;
		int points = -999;
		BaseBoss boss;
		for( int i=MaxClients ; i ; --i ) {
			if( !IsValidClient(i) )
				continue;
			else if( GetClientTeam(i) <= int(TFTeam_Spectator) )
				continue;
			boss = BaseBoss(i);
			if( boss.iQueue >= points and !boss.bSetOnSpawn ) {
				tBoss = boss;
				points = boss.iQueue;
			}
		}
		return tBoss;
	}
	public int CountMinions(const bool balive)
	{
		BaseBoss boss;
		int count=0;
		for( int i=MaxClients ; i ; --i ) {
			if( !IsValidClient(i) )
				continue;
			else if( balive and !IsPlayerAlive(i) )
				continue;
			boss = BaseBoss(i);
			if( !boss.bIsMinion )
				continue;
			++count;
		}
		return( count );
	}
	public int CountBosses(const bool balive)
	{
		BaseBoss boss;
		int count=0;
		for( int i=MaxClients ; i ; --i ) {
			if( !IsValidClient(i) )
				continue;
			else if( balive and !IsPlayerAlive(i) )
				continue;
			boss = BaseBoss(i);
			if( !boss.bIsBoss )
				continue;
			++count;
		}
		return( count );
	}
	public int GetTotalBossHealth()
	{
		BaseBoss boss;
		int count=0;
		for( int i=MaxClients ; i ; --i ) {
			if( !IsValidClient(i) )
				continue;

			boss = BaseBoss(i);
			if( !boss.bIsBoss )
				continue;
			count += boss.iHealth;
		}
		return( count );
	}
	public void SearchForItemPacks()
	{
		bool foundAmmo, foundHealth;
		int ent = -1, count = 0;
		float pos[3];
		while( (ent = FindEntityByClassname(ent, "item_ammopack_full")) != -1 ) {
			GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
			AcceptEntityInput(ent, "Kill");

			DataPack vecPack = new DataPack();
			vecPack.WriteFloat(pos[0]);
			vecPack.WriteFloat(pos[1]);
			vecPack.WriteFloat(pos[2]);
			CreateTimer(0.2, SetSmallAmmoPack, vecPack, TIMER_DATA_HNDL_CLOSE);
			count++;
			foundAmmo = (count > 4);
		}
		ent = -1;
		count = 0;
		while( (ent = FindEntityByClassname(ent, "item_ammopack_medium")) != -1 ) {
			//SetEntProp(ent, Prop_Send, "m_iTeamNum", manager.bMainEnable ? manager.iRedTeam : 0, 4);
			GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
			AcceptEntityInput(ent, "Kill");

			DataPack vecPack = new DataPack();
			vecPack.WriteFloat(pos[0]);
			vecPack.WriteFloat(pos[1]);
			vecPack.WriteFloat(pos[2]);
			CreateTimer(0.2, SetSmallAmmoPack, vecPack, TIMER_DATA_HNDL_CLOSE);
			count++;
			if( !foundAmmo )
				foundAmmo = (count > 4);
		}
		ent = -1;
		count = 0;
		while( (ent = FindEntityByClassname(ent, "item_ammopack_small")) != -1 ) {
			count = 0;
			count++;
			if( !foundAmmo )
				foundAmmo = (count > 4);
		}
		ent = -1;
		count = 0;
		while( (ent = FindEntityByClassname(ent, "item_healthkit_small")) != -1 ) {
			SetEntProp(ent, Prop_Send, "m_iTeamNum", bEnabled.BoolValue ? 2 : 0, 4);
			count++;
			if( !foundHealth )
				foundHealth = (count > 4); //true;
		}
		ent = -1;
		count = 0;
		while( (ent = FindEntityByClassname(ent, "item_healthkit_medium")) != -1 ) {
			SetEntProp(ent, Prop_Send, "m_iTeamNum", bEnabled.BoolValue ? 2 : 0, 4);
			count++;
			if (!foundHealth)
				foundHealth = (count > 2);//true;
		}
		ent = -1;
		count = 0;
		while( (ent = FindEntityByClassname(ent, "item_healthkit_large")) != -1 ) {
			SetEntProp(ent, Prop_Send, "m_iTeamNum", bEnabled.BoolValue ? 2 : 0, 4);
			count++;
			if( !foundHealth )
				foundHealth = (count > 2); //true;
		}
		if( !foundAmmo )
			SpawnRandomAmmo();
		if( !foundHealth )
			SpawnRandomHealth();
	}
	public void UpdateBossHealth()
	{
		BaseBoss boss;
		int totalHealth, bosscount;
		for( int i=MaxClients; i ; --i ) {
			if( !IsValidClient(i) )	// don't count dead bosses
				continue;
			boss = BaseBoss(i);
			if( !boss.bIsBoss )
				continue;
			bosscount++;
			totalHealth += boss.iHealth;
			if( !IsPlayerAlive(i) )
				totalHealth -= boss.iHealth;
		}
		if( bosscount )
			this.iHealthBarPercent = RoundToCeil( float(totalHealth)/float(this.iTotalMaxHealth)*255.0 );
	}
	public void GetBossType()
	{
		if( this.hNextBoss and this.hNextBoss.iPresetType > -1 ) {
			this.iSpecial = this.hNextBoss.iPresetType;
			if( this.iSpecial > MAXBOSS )
				this.iSpecial = MAXBOSS;
			return;
		}
		BaseBoss boss = this.FindNextBoss();
		if( boss.iPresetType > -1 and this.iSpecial == -1 ) {
			this.iSpecial = boss.iPresetType;
			boss.iPresetType = -1;
			if( this.iSpecial > MAXBOSS )
				this.iSpecial = MAXBOSS;
			return;
		}
		if( this.iSpecial > -1 ) {	// Clamp the chosen special so we don't error out.
			if( this.iSpecial > MAXBOSS )
				this.iSpecial = MAXBOSS;
		}
		else this.iSpecial = GetRandomInt(Hale, MAXBOSS);
	}
};

public Action SetSmallAmmoPack(Handle timer, DataPack pack)
{
	pack.Reset();

	float vecPos[3];
	vecPos[0] = pack.ReadFloat();
	vecPos[1] = pack.ReadFloat();
	vecPos[2] = pack.ReadFloat();

	int ammopacker = CreateEntityByName("item_ammopack_small");
	TeleportEntity(ammopacker, vecPos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(ammopacker);
	//SetEntProp(ammopacker, Prop_Send, "m_iTeamNum", manager.bMainEnable ? manager.iRedTeam : 0, 4);
	return Plugin_Continue;
}
