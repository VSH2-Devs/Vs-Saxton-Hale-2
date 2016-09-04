int
	state,			/* Sets the round state of the gamemode */
	BossSpecial = -1,	/* preset the next boss type */
	HealthBar = -1,		/* obviously handles the boss healthbar */
	TotalMaxHealth,
	TimeLeft,		/* How many minutes to countdown! */
	RoundCount,		/* number of rounds played */
	HealthChecks
;

float
	HealthTime,		/* for health check time */
	MusicTime
;
bool
	PointReady
;

BaseBoss preselected;		/* The next player chosen as boss */

#if defined _steamtools_included
bool steamtools;
#endif

//Handle
//	hMusicTimer		/* bool for music timer */
//;

enum /* VSH2 Round States */
{
	StateDisabled = -1,
	StateStarting = 0,
	StateRunning = 1,
	StateEnding = 2,
};

/*enum
{
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
};*/

methodmap VSHGameMode		/* all game mode oriented code should be handled HERE ONLY */
{
	public VSHGameMode()
	{
		preselected = SPNULL;
	}

	property int iRoundState
	{
		public get()			{ return state; }
		public set(const int val)	{ state = val; }
	}
	property int iSpecial
	{
		public get()			{ return BossSpecial; }
		public set(const int val)	{ BossSpecial = val; }
	}
	property int iPlaying
	{
		public get()
		{
			int playing = 0;
			for (int i=MaxClients ; i ; --i) {
				if (not IsClientInGame(i) or not IsPlayerAlive(i))
					continue;
				if (BaseBoss(i).bIsBoss)
					continue;
				playing++;
			}
			return playing;
		}
	}
	property int iHealthBar
	{
		public get()			{ return HealthBar; }
		public set(const int val)	{ HealthBar = val; }
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
			if (clamped>255)
				clamped = 255;
			else if (clamped<0)
				clamped = 0;
			SetEntProp(this.iHealthBar, Prop_Send, "m_iBossHealthPercentageByte", clamped);
		}
	}
	property int iTotalMaxHealth
	{
		public get()			{ return TotalMaxHealth; }
		public set(const int val)	{ TotalMaxHealth = val; }
	}
	property int iTimeLeft
	{
		public get()			{ return TimeLeft; }
		public set(const int val)	{ TimeLeft = val; }
	}
	property int iRoundCount
	{
		public get()			{ return RoundCount; }
		public set(const int val)	{ RoundCount = val; }
	}
	property int iHealthChecks
	{
		public get()			{ return HealthChecks; }
		public set(const int val)	{ HealthChecks = val; }
	}
	
#if defined _steamtools_included
	property bool bSteam
	{
		public get()			{ return steamtools; }
		public set(const bool val)	{ steamtools = val; }
	}
#endif
	property bool bPointReady
	{
		public get()			{ return PointReady; }
		public set(const bool val)	{ PointReady = val; }
	}

	property float flHealthTime
	{
		public get()			{ return HealthTime; }
		public set(const float val)	{ HealthTime = val; }
	}
	property float flMusicTime
	{
		public get()			{ return MusicTime; }
		public set(const float val)	{ MusicTime = val; }
	}

	property BaseBoss hNextBoss
	{
		public get()
		{
			if (!preselected.userid or !IsClientValid(preselected.index))
				return SPNULL;
			return preselected;
		}
		public set(const BaseBoss val)	{ preselected = val; }
	}
	/*property Handle hMusic
	{
		public get()			{ return hMusicTimer; }
		public set(const Handle val)	{ hMusicTimer = val; }
	}*/

	public BaseBoss GetRandomBoss(const bool balive)
	{
		BaseBoss boss;
		for (int i=MaxClients ; i ; --i) {
			if (not IsValidClient(i) )
				continue;
			if (balive and not IsPlayerAlive(i))
				continue;
			boss = BaseBoss(i);
			if (not boss.bIsBoss)
				continue;
			else return boss;
		}
		return SPNULL;
	}
	public BaseBoss GetBossByType(const bool balive, const int type)
	{
		BaseBoss boss;
		for (int i=MaxClients ; i ; --i) {
			if (not IsValidClient(i) )
				continue;
			if (balive and not IsPlayerAlive(i))
				continue;
			boss = BaseBoss(i);
			if (not boss.bIsBoss)
				continue;
			if (boss.iType is type)
				return boss;
		}
		return SPNULL;
	}
	public void CheckArena(const bool type)
	{
		if (type)
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
		for (int i=MaxClients ; i ; --i) {
			if ( not IsValidClient(i) or GetClientTeam(i) <= int(TFTeam_Spectator) )
				continue;

			boss = BaseBoss(i);
			if (boss.iQueue >= points and not boss.bSetOnSpawn) {
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
		for (int i=MaxClients ; i ; --i) {
			if (not IsValidClient(i) )
				continue;
			if (balive and not IsPlayerAlive(i))
				continue;
			boss = BaseBoss(i);
			if (not boss.bIsMinion)
				continue;
			++count;
		}
		return (count);
	}
	public int CountBosses(const bool balive)
	{
		BaseBoss boss;
		int count=0;
		for (int i=MaxClients ; i ; --i) {
			if (not IsValidClient(i) )
				continue;
			if (balive and not IsPlayerAlive(i))
				continue;
			boss = BaseBoss(i);
			if (not boss.bIsBoss)
				continue;
			++count;
		}
		return (count);
	}
	public int GetTotalBossHealth()
	{
		BaseBoss boss;
		int count=0;
		for (int i=MaxClients ; i ; --i) {
			if (not IsValidClient(i) )
				continue;

			boss = BaseBoss(i);
			if (not boss.bIsBoss)
				continue;
			count += boss.iHealth;
		}
		return (count);
	}
	public void SearchForItemPacks()
	{
		bool foundAmmo, foundHealth;
		int ent = -1, count = 0;
		float pos[3];
		while ( (ent = FindEntityByClassname(ent, "item_ammopack_full")) != -1 )
		{
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
		while ((ent = FindEntityByClassname(ent, "item_ammopack_medium")) != -1)
		{
			//SetEntProp(ent, Prop_Send, "m_iTeamNum", manager.bMainEnable ? manager.iRedTeam : 0, 4);
			GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
			AcceptEntityInput(ent, "Kill");

			DataPack vecPack = new DataPack();
			vecPack.WriteFloat(pos[0]);
			vecPack.WriteFloat(pos[1]);
			vecPack.WriteFloat(pos[2]);
			CreateTimer(0.2, SetSmallAmmoPack, vecPack, TIMER_DATA_HNDL_CLOSE);
			count++;
			if (!foundAmmo)
				foundAmmo = (count > 4);
		}
		ent = -1;
		count = 0;
		while ((ent = FindEntityByClassname(ent, "item_ammopack_small")) != -1)
		{
			count = 0;
			count++;
			if (!foundAmmo)
				foundAmmo = (count > 4);
		}
		ent = -1;
		count = 0;
		while ( (ent = FindEntityByClassname(ent, "item_healthkit_small")) != -1 )
		{
			SetEntProp(ent, Prop_Send, "m_iTeamNum", bEnabled.BoolValue ? 2 : 0, 4);
			count++;
			if (!foundHealth)
				foundHealth = (count > 4); //true;
		}
		ent = -1;
		count = 0;
		while ( (ent = FindEntityByClassname(ent, "item_healthkit_medium")) != -1 )
		{
			SetEntProp(ent, Prop_Send, "m_iTeamNum", bEnabled.BoolValue ? 2 : 0, 4);
			count++;
			if (!foundHealth)
				foundHealth = (count > 2);//true;
		}
		ent = -1;
		count = 0;
		while ( (ent = FindEntityByClassname(ent, "item_healthkit_large")) != -1 )
		{
			SetEntProp(ent, Prop_Send, "m_iTeamNum", bEnabled.BoolValue ? 2 : 0, 4);
			count++;
			if (!foundHealth)
				foundHealth = (count > 2); //true;
		}
		if (!foundAmmo)
			SpawnRandomAmmo();
		if (!foundHealth)
			SpawnRandomHealth();
	}
	public void UpdateBossHealth()
	{
		BaseBoss boss;
		int totalHealth, bosscount;
		for (int i=MaxClients; i ; --i) {
			if (not IsValidClient(i))	// don't count dead bosses
				{continue;}
			boss = BaseBoss(i);
			if (not boss.bIsBoss)
				{continue;}
			bosscount++;
			totalHealth += boss.iHealth;
			if (not IsPlayerAlive(i))
				totalHealth -= boss.iHealth;
		}
		if (bosscount)
			this.iHealthBarPercent = RoundToCeil( float(totalHealth)/float(this.iTotalMaxHealth)*255.0 );
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
