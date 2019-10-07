/// very useful ^^
methodmap PrivateForward < Handle {
	public PrivateForward( const Handle forw ) {
		if( forw != null )
			return view_as<PrivateForward>( forw );
		return null;
	}
	property int FuncCount {
		public get() {
			return GetForwardFunctionCount(this);
		}
	}
	public bool Add(Handle plugin, Function func) {
		return AddToForward(this, plugin, func);
	}
	public bool Remove(Handle plugin, Function func) {
		return RemoveFromForward(this, plugin, func);
	}
	public int RemoveAll(Handle plugin) {
		return RemoveAllFromForward(this, plugin);
	}
	public void Start() {
		Call_StartForward(this);
	}
};

PrivateForward
	g_hForwards[OnRedPlayerThink+1]
;

void InitializeForwards()
{
	g_hForwards[OnCallDownloads] = new PrivateForward( CreateForward(ET_Event) );
	g_hForwards[OnBossSelected] = new PrivateForward( CreateForward(ET_Event, Param_Cell) );
	g_hForwards[OnTouchPlayer] = new PrivateForward( CreateForward(ET_Event, Param_Cell, Param_Cell) );
	g_hForwards[OnTouchBuilding] = new PrivateForward( CreateForward(ET_Event, Param_Cell, Param_Cell) );
	g_hForwards[OnBossThink] = new PrivateForward( CreateForward(ET_Event, Param_Cell) );
	g_hForwards[OnBossModelTimer] = new PrivateForward( CreateForward(ET_Event, Param_Cell) );
	g_hForwards[OnBossDeath] = new PrivateForward( CreateForward(ET_Event, Param_Cell) );
	g_hForwards[OnBossEquipped] = new PrivateForward( CreateForward(ET_Event, Param_Cell) );
	g_hForwards[OnBossInitialized] = new PrivateForward( CreateForward(ET_Event, Param_Cell) );
	g_hForwards[OnMinionInitialized] = new PrivateForward( CreateForward(ET_Event, Param_Cell, Param_Cell) );
	g_hForwards[OnBossPlayIntro] = new PrivateForward( CreateForward(ET_Event, Param_Cell) );
	g_hForwards[OnBossTakeDamage] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossDealDamage] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnPlayerKilled] = new PrivateForward( CreateForward(ET_Event, Param_Cell, Param_Cell, Param_Cell) );
	g_hForwards[OnPlayerAirblasted] = new PrivateForward( CreateForward(ET_Event, Param_Cell, Param_Cell, Param_Cell) );
	g_hForwards[OnTraceAttack] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Cell, Param_Cell) );
	g_hForwards[OnBossMedicCall] = new PrivateForward( CreateForward(ET_Event, Param_Cell) );
	g_hForwards[OnBossTaunt] = new PrivateForward( CreateForward(ET_Event, Param_Cell) );
	g_hForwards[OnBossKillBuilding] = new PrivateForward( CreateForward(ET_Event, Param_Cell, Param_Cell, Param_Cell) );
	g_hForwards[OnBossJarated] = new PrivateForward( CreateForward(ET_Event, Param_Cell, Param_Cell) );
	g_hForwards[OnMessageIntro] = new PrivateForward( CreateForward(ET_Event, Param_Cell, Param_String) );
	g_hForwards[OnBossPickUpItem] = new PrivateForward( CreateForward(ET_Event, Param_Cell, Param_String) );
	g_hForwards[OnVariablesReset] = new PrivateForward( CreateForward(ET_Event, Param_Cell) );
	g_hForwards[OnUberDeployed] = new PrivateForward( CreateForward(ET_Event, Param_Cell, Param_Cell) );
	g_hForwards[OnUberLoop] = new PrivateForward( CreateForward(ET_Event, Param_Cell, Param_Cell) );
	g_hForwards[OnMusic] = new PrivateForward( CreateForward(ET_Event, Param_String, Param_FloatByRef, Param_Cell) );
	g_hForwards[OnRoundEndInfo] = new PrivateForward( CreateForward(ET_Event, Param_Cell, Param_Cell, Param_String) );
	g_hForwards[OnLastPlayer] = new PrivateForward( CreateForward(ET_Event, Param_Cell) );
	g_hForwards[OnBossHealthCheck] = new PrivateForward( CreateForward(ET_Event, Param_Cell, Param_Cell, Param_String) );
	g_hForwards[OnControlPointCapped] = new PrivateForward( CreateForward(ET_Event, Param_String, Param_Cell) );
	g_hForwards[OnPrepRedTeam] = new PrivateForward( CreateForward(ET_Event, Param_Cell) );
	g_hForwards[OnRedPlayerThink] = new PrivateForward( CreateForward(ET_Event, Param_Cell) );
	g_hForwards[OnPlayerHurt] = new PrivateForward( CreateForward(ET_Event, Param_Cell, Param_Cell, Param_Cell) );
	g_hForwards[OnBossMenu] = new PrivateForward( CreateForward(ET_Ignore, Param_CellByRef) );
	g_hForwards[OnScoreTally] = new PrivateForward( CreateForward(ET_Event, Param_Cell, Param_CellByRef, Param_CellByRef) );
	g_hForwards[OnItemOverride] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_String, Param_Cell, Param_CellByRef) );
	
	/// OnBossDealDamage Specific Forwards.
	g_hForwards[OnBossDealDamage_OnStomp] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossDealDamage_OnHitDefBuff] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossDealDamage_OnHitCritMmmph] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossDealDamage_OnHitMedic] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossDealDamage_OnHitDeadRinger] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossDealDamage_OnHitCloakedSpy] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossDealDamage_OnHitShield] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	
	/// OnBossTakeDamage Specific Forwards
	g_hForwards[OnBossTakeDamage_OnStabbed] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossTakeDamage_OnTelefragged] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossTakeDamage_OnSwordTaunt] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossTakeDamage_OnHeavyShotgun] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossTakeDamage_OnSniped] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossTakeDamage_OnThirdDegreed] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossTakeDamage_OnHitSword] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossTakeDamage_OnHitFanOWar] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossTakeDamage_OnHitCandyCane] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossTakeDamage_OnMarketGardened] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossTakeDamage_OnPowerJack] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossTakeDamage_OnKatana] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossTakeDamage_OnAmbassadorHeadshot] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossTakeDamage_OnDiamondbackManmelterCrit] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossTakeDamage_OnHolidayPunch] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	
	g_hForwards[OnBossSuperJump] = new PrivateForward( CreateForward(ET_Event, Param_Cell));
	g_hForwards[OnBossDoRageStun] = new PrivateForward( CreateForward(ET_Event, Param_Cell, Param_FloatByRef));
	g_hForwards[OnBossWeighDown] = new PrivateForward( CreateForward(ET_Event, Param_Cell));
	
	g_hForwards[OnRPSTaunt] = new PrivateForward( CreateForward(ET_Event, Param_Cell, Param_Cell));
	g_hForwards[OnBossAirShotProj] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossTakeFallDamage] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
	g_hForwards[OnBossGiveRage] = new PrivateForward( CreateForward(ET_Event, Param_Cell, Param_Cell, Param_FloatByRef));
	g_hForwards[OnBossCalcHealth] = new PrivateForward( CreateForward(ET_Event, Param_Cell, Param_CellByRef, Param_Cell, Param_Cell));
	
	g_hForwards[OnBossTakeDamage_OnTriggerHurt] = new PrivateForward( CreateForward(ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell));
}

Action Call_OnCallDownloads()
{
	Action act;
	g_hForwards[OnCallDownloads].Start();
	Call_Finish(act);
	return act;
}
Action Call_OnBossSelected(const BaseBoss player)
{
	Action act;
	g_hForwards[OnBossSelected].Start();
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnTouchPlayer(const BaseBoss player, const BaseBoss otherguy)
{
	Action act;
	g_hForwards[OnTouchPlayer].Start();
	Call_PushCell(otherguy);
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}

Action Call_OnTouchBuilding(const BaseBoss player, const int buildRef)
{
	Action act;
	g_hForwards[OnTouchBuilding].Start();
	Call_PushCell(player);
	Call_PushCell(buildRef);
	Call_Finish(act);
	return act;
}

Action Call_OnBossThink(const BaseBoss player)
{
	Action act;
	g_hForwards[OnBossThink].Start();
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}

Action Call_OnBossModelTimer(const BaseBoss player)
{
	Action act;
	g_hForwards[OnBossModelTimer].Start();
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}

Action Call_OnBossDeath(const BaseBoss player)
{
	Action act;
	g_hForwards[OnBossDeath].Start();
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnBossEquipped(const BaseBoss player)
{
	Action act;
	g_hForwards[OnBossEquipped].Start();
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnBossInitialized(const BaseBoss player)
{
	Action act;
	g_hForwards[OnBossInitialized].Start();
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnMinionInitialized(const BaseBoss player, const BaseBoss master)
{
	Action act;
	g_hForwards[OnMinionInitialized].Start();
	Call_PushCell(player);
	Call_PushCell(master);
	Call_Finish(act);
	return act;
}
Action Call_OnBossPlayIntro(const BaseBoss player)
{
	Action act;
	g_hForwards[OnBossPlayIntro].Start();
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnBossTakeDamage(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
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
	Action result;
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
Action Call_OnPlayerKilled(const BaseBoss player, const BaseBoss victim, Event event)
{
	Action act;
	g_hForwards[OnPlayerKilled].Start();
	Call_PushCell(player);
	Call_PushCell(victim);
	Call_PushCell(event);
	Call_Finish(act);
	return act;
}
Action Call_OnPlayerAirblasted(const BaseBoss player, const BaseBoss victim, Event event)
{
	Action act;
	g_hForwards[OnPlayerAirblasted].Start();
	Call_PushCell(player);
	Call_PushCell(victim);
	Call_PushCell(event);
	Call_Finish(act);
	return act;
}
Action Call_OnPlayerHurt(const BaseBoss player, const BaseBoss victim, Event event)
{
	Action act;
	g_hForwards[OnPlayerHurt].Start();
	Call_PushCell(player);
	Call_PushCell(victim);
	Call_PushCell(event);
	Call_Finish(act);
	return act;
}
Action Call_OnTraceAttack(const BaseBoss player, const BaseBoss attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
	Action act;
	g_hForwards[OnTraceAttack].Start();
	Call_PushCell(player);
	Call_PushCell(attacker);
	Call_PushCellRef(inflictor);
	Call_PushFloatRef(damage);
	Call_PushCellRef(damagetype);
	Call_PushCellRef(ammotype);
	Call_PushCell(hitbox);
	Call_PushCell(hitgroup);
	Call_Finish(act);
	return act;
}
Action Call_OnBossMedicCall(const BaseBoss player)
{
	Action act;
	g_hForwards[OnBossMedicCall].Start();
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnBossTaunt(const BaseBoss player)
{
	Action act;
	g_hForwards[OnBossTaunt].Start();
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnBossKillBuilding(const BaseBoss player, const int building, Event event)
{
	Action act;
	g_hForwards[OnBossKillBuilding].Start();
	Call_PushCell(player);
	Call_PushCell(building);
	Call_PushCell(event);
	Call_Finish(act);
	return act;
}
Action Call_OnBossJarated(const BaseBoss player, const BaseBoss attacker)
{
	Action act;
	g_hForwards[OnBossJarated].Start();
	Call_PushCell(player);
	Call_PushCell(attacker);
	Call_Finish(act);
	return act;
}

Action Call_OnMessageIntro(const BaseBoss player, char message[MAXMESSAGE])
{
	Action act;
	g_hForwards[OnMessageIntro].Start();
	Call_PushCell(player);
	Call_PushStringEx(message, MAXMESSAGE, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish(act);
	return act;
}
Action Call_OnBossPickUpItem(const BaseBoss player, const char item[64])
{
	Action act;
	g_hForwards[OnBossPickUpItem].Start();
	Call_PushCell(player);
	Call_PushString(item);
	Call_Finish(act);
	return act;
}
Action Call_OnVariablesReset(const BaseBoss player)
{
	Action act;
	g_hForwards[OnVariablesReset].Start();
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnUberDeployed(const BaseBoss medic, const BaseBoss target)
{
	Action act;
	g_hForwards[OnUberDeployed].Start();
	Call_PushCell(medic);
	Call_PushCell(target);
	Call_Finish(act);
	return act;
}
Action Call_OnUberLoop(const BaseBoss medic, const BaseBoss target)
{
	Action act;
	g_hForwards[OnUberLoop].Start();
	Call_PushCell(medic);
	Call_PushCell(target);
	Call_Finish(act);
	return act;
}
Action Call_OnMusic(char song[PLATFORM_MAX_PATH], float& time, const BaseBoss player)
{
	Action act;
	g_hForwards[OnMusic].Start();
	Call_PushStringEx(song, PLATFORM_MAX_PATH, 0, SM_PARAM_COPYBACK);
	Call_PushFloatRef(time);
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnRoundEndInfo(const BaseBoss player, bool bosswin, char message[MAXMESSAGE])
{
	Action act;
	g_hForwards[OnRoundEndInfo].Start();
	Call_PushCell(player);
	Call_PushCell(bosswin);
	Call_PushStringEx(message, MAXMESSAGE, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish(act);
	return act;
}
Action Call_OnLastPlayer(const BaseBoss player)
{
	Action act;
	g_hForwards[OnLastPlayer].Start();
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnBossHealthCheck(const BaseBoss player, const bool isBoss, char message[MAXMESSAGE])
{
	Action act;
	g_hForwards[OnBossHealthCheck].Start();
	Call_PushCell(player);
	Call_PushCell(isBoss);
	Call_PushStringEx(message, MAXMESSAGE, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish(act);
	return act;
}
Action Call_OnControlPointCapped(char cappers[MAXPLAYERS+1], const int team)
{
	Action act;
	g_hForwards[OnControlPointCapped].Start();
	Call_PushString(cappers);
	Call_PushCell(team);
	Call_Finish(act);
	return act;
}
Action Call_OnPrepRedTeam(const BaseBoss player)
{
	Action act;
	g_hForwards[OnPrepRedTeam].Start();
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnRedPlayerThink(const BaseBoss player)
{
	Action act;
	g_hForwards[OnRedPlayerThink].Start();
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
void Call_OnBossMenu(Menu& menu)
{
	g_hForwards[OnBossMenu].Start();
	Call_PushCellRef(menu);
	Call_Finish();
}
Action Call_OnScoreTally(const BaseBoss player, int& points_earned, int& queue_earned)
{
	Action act;
	g_hForwards[OnScoreTally].Start();
	Call_PushCell(player);
	Call_PushCellRef(points_earned);
	Call_PushCellRef(queue_earned);
	Call_Finish(act);
	return act;
}
Action Call_OnItemOverride(const BaseBoss player, const char[] classname, int itemdef, Handle& item)
{
	Action result;
	g_hForwards[OnItemOverride].Start();
	Call_PushCell(player);
	Call_PushString(classname);
	Call_PushCell(itemdef);
	Call_PushCellRef(item);
	Call_Finish(result);
	return result;
}
Action Call_OnBossDealDamage_OnStomp(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossDealDamage_OnStomp].Start();
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
Action Call_OnBossDealDamage_OnHitDefBuff(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossDealDamage_OnHitDefBuff].Start();
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
Action Call_OnBossDealDamage_OnHitCritMmmph(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossDealDamage_OnHitCritMmmph].Start();
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
Action Call_OnBossDealDamage_OnHitMedic(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossDealDamage_OnHitMedic].Start();
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
Action Call_OnBossDealDamage_OnHitDeadRinger(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossDealDamage_OnHitDeadRinger].Start();
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
Action Call_OnBossDealDamage_OnHitCloakedSpy(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossDealDamage_OnHitCloakedSpy].Start();
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
Action Call_OnBossDealDamage_OnHitShield(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossDealDamage_OnHitShield].Start();
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


/// OnBossTakeDamage forwards.
Action Call_OnBossTakeDamage_OnStabbed(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossTakeDamage_OnStabbed].Start();
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
Action Call_OnBossTakeDamage_OnTelefragged(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossTakeDamage_OnTelefragged].Start();
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
Action Call_OnBossTakeDamage_OnSwordTaunt(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossTakeDamage_OnSwordTaunt].Start();
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
Action Call_OnBossTakeDamage_OnHeavyShotgun(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossTakeDamage_OnHeavyShotgun].Start();
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
Action Call_OnBossTakeDamage_OnSniped(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossTakeDamage_OnSniped].Start();
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
Action Call_OnBossTakeDamage_OnThirdDegreed(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossTakeDamage_OnThirdDegreed].Start();
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
Action Call_OnBossTakeDamage_OnHitSword(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossTakeDamage_OnHitSword].Start();
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
Action Call_OnBossTakeDamage_OnHitFanOWar(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossTakeDamage_OnHitFanOWar].Start();
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
Action Call_OnBossTakeDamage_OnHitCandyCane(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossTakeDamage_OnHitCandyCane].Start();
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
Action Call_OnBossTakeDamage_OnMarketGardened(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossTakeDamage_OnMarketGardened].Start();
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
Action Call_OnBossTakeDamage_OnPowerJack(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossTakeDamage_OnPowerJack].Start();
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
Action Call_OnBossTakeDamage_OnKatana(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossTakeDamage_OnKatana].Start();
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
Action Call_OnBossTakeDamage_OnAmbassadorHeadshot(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossTakeDamage_OnAmbassadorHeadshot].Start();
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
Action Call_OnBossTakeDamage_OnDiamondbackManmelterCrit(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossTakeDamage_OnDiamondbackManmelterCrit].Start();
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
Action Call_OnBossTakeDamage_OnHolidayPunch(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossTakeDamage_OnHolidayPunch].Start();
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

Action Call_OnBossSuperJump(const BaseBoss player)
{
	Action act;
	g_hForwards[OnBossSuperJump].Start();
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}

Action Call_OnBossDoRageStun(const BaseBoss player, float& distance)
{
	Action act;
	g_hForwards[OnBossDoRageStun].Start();
	Call_PushCell(player);
	Call_PushFloatRef(distance);
	Call_Finish(act);
	return act;
}

Action Call_OnBossWeighDown(const BaseBoss player)
{
	Action act;
	g_hForwards[OnBossWeighDown].Start();
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}

Action Call_OnRPSTaunt(const BaseBoss loser, const BaseBoss winner)
{
	Action act;
	g_hForwards[OnRPSTaunt].Start();
	Call_PushCell(loser);
	Call_PushCell(winner);
	Call_Finish(act);
	return act;
}

Action Call_OnBossAirShotProj(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossAirShotProj].Start();
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

Action Call_OnBossTakeFallDamage(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossTakeFallDamage].Start();
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

Action Call_OnBossGiveRage(const BaseBoss player, const int damage, float& calcd_rage)
{
	Action act;
	g_hForwards[OnBossGiveRage].Start();
	Call_PushCell(player);
	Call_PushCell(damage);
	Call_PushFloatRef(calcd_rage);
	Call_Finish(act);
	return act;
}

Action Call_OnBossCalcHealth(const BaseBoss player, int& max_health, const int boss_count, const int red_players)
{
	Action act;
	g_hForwards[OnBossCalcHealth].Start();
	Call_PushCell(player);
	Call_PushCellRef(max_health);
	Call_PushCell(boss_count);
	Call_PushCell(red_players);
	Call_Finish(act);
	return act;
}

Action Call_OnBossTakeDamage_OnTriggerHurt(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	g_hForwards[OnBossTakeDamage_OnTriggerHurt].Start();
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
