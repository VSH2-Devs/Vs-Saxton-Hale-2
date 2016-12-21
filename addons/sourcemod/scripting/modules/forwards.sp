methodmap PrivateForward < Handle	//very useful ^^
{
	public PrivateForward( const Handle forw )
	{
		if (forw != null)
			return view_as<PrivateForward>( forw );
		return null;
	}
	property int FuncCount {
		public get()	{ return GetForwardFunctionCount(this); }
	}
	public bool Add(Handle plugin, Function func)
	{
		return AddToForward(this, plugin, func);
	}
	public bool Remove(Handle plugin, Function func)
	{
		return RemoveFromForward(this, plugin, func);
	}
	public int RemoveAll(Handle plugin)
	{
		return RemoveAllFromForward(this, plugin);
	}
	public void Start()
	{
		Call_StartForward(this);
	}
};

PrivateForward
	g_hForwards[OnRedPlayerThink+1]
;

void InitializeForwards()
{
	g_hForwards[OnCallDownloads] = new PrivateForward( CreateForward(ET_Ignore) );
	g_hForwards[OnBossSelected] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnTouchPlayer] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_Cell) );
	g_hForwards[OnTouchBuilding] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_Cell) );
	g_hForwards[OnBossThink] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnBossModelTimer] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnBossDeath] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnBossEquipped] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnBossInitialized] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnMinionInitialized] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnBossPlayIntro] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnBossTakeDamage] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnBossDealDamage] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnPlayerKilled] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnPlayerAirblasted] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnBossMedicCall] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnBossTaunt] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnBossKillBuilding] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnBossJarated] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnHookSound] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnMessageIntro] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnBossPickUpItem] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnVariablesReset] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnUberDeployed] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnMusic] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnRoundEndInfo] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnLastPlayer] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnBossHealthCheck] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnControlPointCapped] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnPrepRedTeam] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnRedPlayerThink] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
}

void Call_OnCallDownloads()
{
	g_hForwards[OnCallDownloads].Start();
	Call_Finish();
}
void Call_OnBossSelected(const int player)
{
	g_hForwards[OnBossSelected].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnTouchPlayer(const int player, const int otherguy)
{
	g_hForwards[OnTouchPlayer].Start();
	Call_PushCell(player);
	Call_PushCell(otherguy);
	Call_Finish();
}

void Call_OnTouchBuilding(const int player, const int buildRef)
{
	g_hForwards[OnTouchBuilding].Start();
	Call_PushCell(player);
	Call_PushCell(buildRef);
	Call_Finish();
}

void Call_OnBossThink(const int player)
{
	g_hForwards[OnBossThink].Start();
	Call_PushCell(player);
	Call_Finish();
}

void Call_OnBossModelTimer(const int player)
{
	g_hForwards[OnBossModelTimer].Start();
	Call_PushCell(player);
	Call_Finish();
}

void Call_OnBossDeath(const int player)
{
	g_hForwards[OnBossDeath].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossEquipped(const int player)
{
	g_hForwards[OnBossEquipped].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossInitialized(const int player)
{
	g_hForwards[OnBossInitialized].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnMinionInitialized(const int player)
{
	g_hForwards[OnMinionInitialized].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossPlayIntro(const int player)
{
	g_hForwards[OnBossPlayIntro].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossTakeDamage(const int player)
{
	g_hForwards[OnBossTakeDamage].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossDealDamage(const int player)
{
	g_hForwards[OnBossDealDamage].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnPlayerKilled(const int player)
{
	g_hForwards[OnPlayerKilled].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnPlayerAirblasted(const int player)
{
	g_hForwards[OnPlayerAirblasted].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossMedicCall(const int player)
{
	g_hForwards[OnBossMedicCall].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossTaunt(const int player)
{
	g_hForwards[OnBossTaunt].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossKillBuilding(const int player)
{
	g_hForwards[OnBossKillBuilding].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossJarated(const int player)
{
	g_hForwards[OnBossJarated].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnHookSound(const int player)
{
	g_hForwards[OnHookSound].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnMessageIntro(const int player)
{
	g_hForwards[OnMessageIntro].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossPickUpItem(const int player)
{
	g_hForwards[OnBossPickUpItem].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnVariablesReset(const int player)
{
	g_hForwards[OnVariablesReset].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnUberDeployed(const int player)
{
	g_hForwards[OnUberDeployed].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnMusic(const int player)
{
	g_hForwards[OnMusic].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnRoundEndInfo(const int player)
{
	g_hForwards[OnRoundEndInfo].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnLastPlayer(const int player)
{
	g_hForwards[OnLastPlayer].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossHealthCheck(const int player)
{
	g_hForwards[OnBossHealthCheck].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnControlPointCapped(const int player)
{
	g_hForwards[OnControlPointCapped].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnPrepRedTeam(const int player)
{
	g_hForwards[OnPrepRedTeam].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnRedPlayerThink(const int player)
{
	g_hForwards[OnRedPlayerThink].Start();
	Call_PushCell(player);
	Call_Finish();
}
