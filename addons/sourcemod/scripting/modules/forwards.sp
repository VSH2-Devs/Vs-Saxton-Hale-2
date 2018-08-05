methodmap PrivateForward < Handle	//very useful ^^
{
	public PrivateForward( const Handle forw )
	{
		if( forw != null )
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
	g_hForwards[OnBossTakeDamage] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossDealDamage] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnPlayerKilled] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	g_hForwards[OnPlayerAirblasted] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	g_hForwards[OnTraceAttack] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Cell, Param_Cell) );
	g_hForwards[OnBossMedicCall] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnBossTaunt] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnBossKillBuilding] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	g_hForwards[OnBossJarated] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_Cell) );
	//g_hForwards[OnHookSound] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnMessageIntro] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_String) );
	g_hForwards[OnBossPickUpItem] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_String) );
	g_hForwards[OnVariablesReset] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnUberDeployed] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_Cell) );
	g_hForwards[OnUberLoop] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_Cell) );
	g_hForwards[OnMusic] = new PrivateForward( CreateForward(ET_Ignore, Param_String, Param_FloatByRef) );
	g_hForwards[OnRoundEndInfo] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_String) );
	g_hForwards[OnLastPlayer] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnBossHealthCheck] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_String) );
	g_hForwards[OnControlPointCapped] = new PrivateForward( CreateForward(ET_Ignore, Param_String, Param_Cell) );
	g_hForwards[OnPrepRedTeam] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnRedPlayerThink] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell) );
	g_hForwards[OnPlayerHurt] = new PrivateForward( CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell) );
	g_hForwards[OnBossMenu] = new PrivateForward( CreateForward(ET_Ignore, Param_CellByRef) );
}

void Call_OnCallDownloads()
{
	g_hForwards[OnCallDownloads].Start();
	Call_Finish();
}
void Call_OnBossSelected(const BaseBoss player)
{
	g_hForwards[OnBossSelected].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnTouchPlayer(const BaseBoss player, const BaseBoss otherguy)
{
	g_hForwards[OnTouchPlayer].Start();
	Call_PushCell(otherguy);
	Call_PushCell(player);
	Call_Finish();
}

void Call_OnTouchBuilding(const BaseBoss player, const int buildRef)
{
	g_hForwards[OnTouchBuilding].Start();
	Call_PushCell(player);
	Call_PushCell(buildRef);
	Call_Finish();
}

void Call_OnBossThink(const BaseBoss player)
{
	g_hForwards[OnBossThink].Start();
	Call_PushCell(player);
	Call_Finish();
}

void Call_OnBossModelTimer(const BaseBoss player)
{
	g_hForwards[OnBossModelTimer].Start();
	Call_PushCell(player);
	Call_Finish();
}

void Call_OnBossDeath(const BaseBoss player)
{
	g_hForwards[OnBossDeath].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossEquipped(const BaseBoss player)
{
	g_hForwards[OnBossEquipped].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossInitialized(const BaseBoss player)
{
	g_hForwards[OnBossInitialized].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnMinionInitialized(const BaseBoss player)
{
	g_hForwards[OnMinionInitialized].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossPlayIntro(const BaseBoss player)
{
	g_hForwards[OnBossPlayIntro].Start();
	Call_PushCell(player);
	Call_Finish();
}
Action Call_OnBossTakeDamage(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result = Plugin_Continue;
	g_hForwards[OnBossTakeDamage].Start();
	Call_PushCell(player);
	Call_PushCellRef(attacker);
	Call_PushCellRef(inflictor);
	Call_PushFloatRef(damage);
	Call_PushCellRef(damagetype);
	Call_PushCellRef(weapon);
	Call_PushArray(damageForce,3);
	Call_PushArray(damagePosition,3);
	Call_PushCell(damagecustom);
	Call_Finish(result);
	return result;
}
Action Call_OnBossDealDamage(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result = Plugin_Continue;
	g_hForwards[OnBossDealDamage].Start();
	Call_PushCell(player);
	Call_PushCellRef(attacker);
	Call_PushCellRef(inflictor);
	Call_PushFloatRef(damage);
	Call_PushCellRef(damagetype);
	Call_PushCellRef(weapon);
	Call_PushArray(damageForce,3);
	Call_PushArray(damagePosition,3);
	Call_PushCell(damagecustom);
	Call_Finish(result);
	return result;
}
void Call_OnPlayerKilled(const BaseBoss player, const BaseBoss victim, Event event)
{
	g_hForwards[OnPlayerKilled].Start();
	Call_PushCell(player);
	Call_PushCell(victim);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnPlayerAirblasted(const BaseBoss player, const BaseBoss victim, Event event)
{
	g_hForwards[OnPlayerAirblasted].Start();
	Call_PushCell(player);
	Call_PushCell(victim);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnPlayerHurt(const BaseBoss player, const BaseBoss victim, Event event)
{
	g_hForwards[OnPlayerHurt].Start();
	Call_PushCell(player);
	Call_PushCell(victim);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnTraceAttack(const BaseBoss player, const BaseBoss attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
	g_hForwards[OnTraceAttack].Start();
	Call_PushCell(player);
	Call_PushCell(attacker);
	Call_PushCellRef(inflictor);
	Call_PushFloatRef(damage);
	Call_PushCellRef(damagetype);
	Call_PushCellRef(ammotype);
	Call_PushCell(hitbox);
	Call_PushCell(hitgroup);
	Call_Finish();
}
void Call_OnBossMedicCall(const BaseBoss player)
{
	g_hForwards[OnBossMedicCall].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossTaunt(const BaseBoss player)
{
	g_hForwards[OnBossTaunt].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossKillBuilding(const BaseBoss player, const int building, Event event)
{
	g_hForwards[OnBossKillBuilding].Start();
	Call_PushCell(player);
	Call_PushCell(building);
	Call_PushCell(event);
	Call_Finish();
}
void Call_OnBossJarated(const BaseBoss player, const BaseBoss attacker)
{
	g_hForwards[OnBossJarated].Start();
	Call_PushCell(player);
	Call_PushCell(attacker);
	Call_Finish();
}
/*void Call_OnHookSound(const BaseBoss player)
{
	g_hForwards[OnHookSound].Start();
	Call_PushCell(player);
	Call_Finish();
}*/
void Call_OnMessageIntro(const BaseBoss player, char message[MAXMESSAGE])
{
	g_hForwards[OnMessageIntro].Start();
	Call_PushCell(player);
	Call_PushStringEx(message, MAXMESSAGE, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish();
}
void Call_OnBossPickUpItem(const BaseBoss player, const char item[64])
{
	g_hForwards[OnBossPickUpItem].Start();
	Call_PushCell(player);
	//Call_PushArray(item, 64);
	Call_PushString(item);
	Call_Finish();
}
void Call_OnVariablesReset(const BaseBoss player)
{
	g_hForwards[OnVariablesReset].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnUberDeployed(const BaseBoss medic, const BaseBoss target)
{
	g_hForwards[OnUberDeployed].Start();
	Call_PushCell(medic);
	Call_PushCell(target);
	Call_Finish();
}
void Call_OnUberLoop(const BaseBoss medic, const BaseBoss target)
{
	g_hForwards[OnUberLoop].Start();
	Call_PushCell(medic);
	Call_PushCell(target);
	Call_Finish();
}
void Call_OnMusic(char song[PLATFORM_MAX_PATH], float& time)
{
	g_hForwards[OnMusic].Start();
	Call_PushStringEx(song, PLATFORM_MAX_PATH, 0, SM_PARAM_COPYBACK);
	Call_PushFloatRef(time);
	Call_Finish();
}
void Call_OnRoundEndInfo(const BaseBoss player, bool bosswin, char message[MAXMESSAGE])
{
	g_hForwards[OnRoundEndInfo].Start();
	Call_PushCell(player);
	Call_PushCell(bosswin);
	Call_PushStringEx(message, MAXMESSAGE, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish();
}
void Call_OnLastPlayer(const BaseBoss player)
{
	g_hForwards[OnLastPlayer].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossHealthCheck(const BaseBoss player, const bool isBoss, char message[MAXMESSAGE])
{
	g_hForwards[OnBossHealthCheck].Start();
	Call_PushCell(player);
	Call_PushCell(isBoss);
	Call_PushStringEx(message, MAXMESSAGE, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish();
}
void Call_OnControlPointCapped(char cappers[MAXPLAYERS+1], const int team)
{
	g_hForwards[OnControlPointCapped].Start();
	Call_PushString(cappers);
	Call_PushCell(team);
	Call_Finish();
}
void Call_OnPrepRedTeam(const BaseBoss player)
{
	g_hForwards[OnPrepRedTeam].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnRedPlayerThink(const BaseBoss player)
{
	g_hForwards[OnRedPlayerThink].Start();
	Call_PushCell(player);
	Call_Finish();
}
void Call_OnBossMenu(Menu& menu)
{
	g_hForwards[OnBossMenu].Start();
	Call_PushCellRef(menu);
	Call_Finish();
}
