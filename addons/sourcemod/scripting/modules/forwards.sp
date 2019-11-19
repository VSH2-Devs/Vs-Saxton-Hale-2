void InitializeForwards()
{
	g_vsh2.m_hForwards[OnCallDownloads] = new PrivateForward( ET_Event );
	g_vsh2.m_hForwards[OnBossSelected] = new PrivateForward( ET_Event, Param_Cell );
	g_vsh2.m_hForwards[OnTouchPlayer] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
	g_vsh2.m_hForwards[OnTouchBuilding] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
	g_vsh2.m_hForwards[OnBossThink] = new PrivateForward( ET_Event, Param_Cell );
	g_vsh2.m_hForwards[OnBossModelTimer] = new PrivateForward( ET_Event, Param_Cell );
	g_vsh2.m_hForwards[OnBossDeath] = new PrivateForward( ET_Event, Param_Cell );
	g_vsh2.m_hForwards[OnBossEquipped] = new PrivateForward( ET_Event, Param_Cell );
	g_vsh2.m_hForwards[OnBossInitialized] = new PrivateForward( ET_Event, Param_Cell );
	g_vsh2.m_hForwards[OnMinionInitialized] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
	g_vsh2.m_hForwards[OnBossPlayIntro] = new PrivateForward( ET_Event, Param_Cell );
	g_vsh2.m_hForwards[OnBossTakeDamage] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossDealDamage] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnPlayerKilled] = new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_Cell );
	g_vsh2.m_hForwards[OnPlayerAirblasted] = new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_Cell );
	g_vsh2.m_hForwards[OnTraceAttack] = new PrivateForward( ET_Hook, Param_Cell, Param_Cell, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Cell, Param_Cell );
	g_vsh2.m_hForwards[OnBossMedicCall] = new PrivateForward( ET_Event, Param_Cell );
	g_vsh2.m_hForwards[OnBossTaunt] = new PrivateForward( ET_Event, Param_Cell );
	g_vsh2.m_hForwards[OnBossKillBuilding] = new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_Cell );
	g_vsh2.m_hForwards[OnBossJarated] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
	g_vsh2.m_hForwards[OnMessageIntro] = new PrivateForward( ET_Event, Param_Cell, Param_String );
	g_vsh2.m_hForwards[OnBossPickUpItem] = new PrivateForward( ET_Event, Param_Cell, Param_String );
	g_vsh2.m_hForwards[OnVariablesReset] = new PrivateForward( ET_Event, Param_Cell );
	g_vsh2.m_hForwards[OnUberDeployed] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
	g_vsh2.m_hForwards[OnUberLoop] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
	g_vsh2.m_hForwards[OnMusic] = new PrivateForward( ET_Event, Param_String, Param_FloatByRef, Param_Cell );
	g_vsh2.m_hForwards[OnRoundEndInfo] = new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_String );
	g_vsh2.m_hForwards[OnLastPlayer] = new PrivateForward( ET_Event, Param_Cell );
	g_vsh2.m_hForwards[OnBossHealthCheck] = new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_String );
	g_vsh2.m_hForwards[OnControlPointCapped] = new PrivateForward( ET_Event, Param_String, Param_Cell );
	g_vsh2.m_hForwards[OnPrepRedTeam] = new PrivateForward( ET_Event, Param_Cell );
	g_vsh2.m_hForwards[OnRedPlayerThink] = new PrivateForward( ET_Event, Param_Cell );
	g_vsh2.m_hForwards[OnPlayerHurt] = new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_Cell );
	g_vsh2.m_hForwards[OnBossMenu] = new PrivateForward( ET_Ignore, Param_CellByRef );
	g_vsh2.m_hForwards[OnScoreTally] = new PrivateForward( ET_Event, Param_Cell, Param_CellByRef, Param_CellByRef );
	g_vsh2.m_hForwards[OnItemOverride] = new PrivateForward( ET_Hook, Param_Cell, Param_String, Param_Cell, Param_CellByRef );
	
	/// OnBossDealDamage Specific Forwards.
	g_vsh2.m_hForwards[OnBossDealDamage_OnStomp] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossDealDamage_OnHitDefBuff] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossDealDamage_OnHitCritMmmph] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossDealDamage_OnHitMedic] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossDealDamage_OnHitDeadRinger] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossDealDamage_OnHitCloakedSpy] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossDealDamage_OnHitShield] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	
	/// OnBossTakeDamage Specific Forwards
	g_vsh2.m_hForwards[OnBossTakeDamage_OnStabbed] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossTakeDamage_OnTelefragged] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossTakeDamage_OnSwordTaunt] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossTakeDamage_OnHeavyShotgun] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossTakeDamage_OnSniped] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossTakeDamage_OnThirdDegreed] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossTakeDamage_OnHitSword] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossTakeDamage_OnHitFanOWar] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossTakeDamage_OnHitCandyCane] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossTakeDamage_OnMarketGardened] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossTakeDamage_OnPowerJack] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossTakeDamage_OnKatana] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossTakeDamage_OnAmbassadorHeadshot] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossTakeDamage_OnDiamondbackManmelterCrit] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossTakeDamage_OnHolidayPunch] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	
	g_vsh2.m_hForwards[OnBossSuperJump] = new PrivateForward( ET_Event, Param_Cell );
	g_vsh2.m_hForwards[OnBossDoRageStun] = new PrivateForward( ET_Event, Param_Cell, Param_FloatByRef );
	g_vsh2.m_hForwards[OnBossWeighDown] = new PrivateForward( ET_Event, Param_Cell );
	
	g_vsh2.m_hForwards[OnRPSTaunt] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
	g_vsh2.m_hForwards[OnBossAirShotProj] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossTakeFallDamage] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossGiveRage] = new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_FloatByRef );
	g_vsh2.m_hForwards[OnBossCalcHealth] = new PrivateForward( ET_Event, Param_Cell, Param_CellByRef, Param_Cell, Param_Cell );
	
	g_vsh2.m_hForwards[OnBossTakeDamage_OnTriggerHurt] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossTakeDamage_OnMantreadsStomp] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
	g_vsh2.m_hForwards[OnBossThinkPost] = new PrivateForward( ET_Hook, Param_Cell );
	g_vsh2.m_hForwards[OnBossEquippedPost] = new PrivateForward( ET_Hook, Param_Cell );
	g_vsh2.m_hForwards[OnPlayerTakeFallDamage] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
}

Action Call_OnCallDownloads()
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnCallDownloads]);
	Call_Finish(act);
	return act;
}
Action Call_OnBossSelected(const BaseBoss player)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnBossSelected]);
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnTouchPlayer(const BaseBoss boss, const BaseBoss otherguy)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnTouchPlayer]);
	Call_PushCell(boss);
	Call_PushCell(otherguy);
	Call_Finish(act);
	return act;
}

Action Call_OnTouchBuilding(const BaseBoss player, const int buildRef)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnTouchBuilding]);
	Call_PushCell(player);
	Call_PushCell(buildRef);
	Call_Finish(act);
	return act;
}

Action Call_OnBossThink(const BaseBoss player)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnBossThink]);
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}

Action Call_OnBossModelTimer(const BaseBoss player)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnBossModelTimer]);
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}

Action Call_OnBossDeath(const BaseBoss player)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnBossDeath]);
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnBossEquipped(const BaseBoss player)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnBossEquipped]);
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnBossInitialized(const BaseBoss player)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnBossInitialized]);
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnMinionInitialized(const BaseBoss player, const BaseBoss master)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnMinionInitialized]);
	Call_PushCell(player);
	Call_PushCell(master);
	Call_Finish(act);
	return act;
}
Action Call_OnBossPlayIntro(const BaseBoss player)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnBossPlayIntro]);
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnBossTakeDamage(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	Call_StartForward(g_vsh2.m_hForwards[OnBossTakeDamage]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossDealDamage]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnPlayerKilled]);
	Call_PushCell(player);
	Call_PushCell(victim);
	Call_PushCell(event);
	Call_Finish(act);
	return act;
}
Action Call_OnPlayerAirblasted(const BaseBoss player, const BaseBoss victim, Event event)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnPlayerAirblasted]);
	Call_PushCell(player);
	Call_PushCell(victim);
	Call_PushCell(event);
	Call_Finish(act);
	return act;
}
Action Call_OnPlayerHurt(const BaseBoss player, const BaseBoss victim, Event event)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnPlayerHurt]);
	Call_PushCell(player);
	Call_PushCell(victim);
	Call_PushCell(event);
	Call_Finish(act);
	return act;
}
Action Call_OnTraceAttack(const BaseBoss player, const BaseBoss attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnTraceAttack]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossMedicCall]);
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnBossTaunt(const BaseBoss player)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnBossTaunt]);
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnBossKillBuilding(const BaseBoss player, const int building, Event event)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnBossKillBuilding]);
	Call_PushCell(player);
	Call_PushCell(building);
	Call_PushCell(event);
	Call_Finish(act);
	return act;
}
Action Call_OnBossJarated(const BaseBoss player, const BaseBoss attacker)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnBossJarated]);
	Call_PushCell(player);
	Call_PushCell(attacker);
	Call_Finish(act);
	return act;
}

Action Call_OnMessageIntro(const BaseBoss player, char message[MAXMESSAGE])
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnMessageIntro]);
	Call_PushCell(player);
	Call_PushStringEx(message, MAXMESSAGE, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish(act);
	return act;
}
Action Call_OnBossPickUpItem(const BaseBoss player, const char item[64])
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnBossPickUpItem]);
	Call_PushCell(player);
	Call_PushString(item);
	Call_Finish(act);
	return act;
}
Action Call_OnVariablesReset(const BaseBoss player)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnVariablesReset]);
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnUberDeployed(const BaseBoss medic, const BaseBoss target)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnUberDeployed]);
	Call_PushCell(medic);
	Call_PushCell(target);
	Call_Finish(act);
	return act;
}
Action Call_OnUberLoop(const BaseBoss medic, const BaseBoss target)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnUberLoop]);
	Call_PushCell(medic);
	Call_PushCell(target);
	Call_Finish(act);
	return act;
}
Action Call_OnMusic(char song[PLATFORM_MAX_PATH], float& time, const BaseBoss player)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnMusic]);
	Call_PushStringEx(song, PLATFORM_MAX_PATH, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushFloatRef(time);
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnRoundEndInfo(const BaseBoss player, bool bosswin, char message[MAXMESSAGE])
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnRoundEndInfo]);
	Call_PushCell(player);
	Call_PushCell(bosswin);
	Call_PushStringEx(message, MAXMESSAGE, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish(act);
	return act;
}
Action Call_OnLastPlayer(const BaseBoss player)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnLastPlayer]);
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnBossHealthCheck(const BaseBoss player, const bool isBoss, char message[MAXMESSAGE])
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnBossHealthCheck]);
	Call_PushCell(player);
	Call_PushCell(isBoss);
	Call_PushStringEx(message, MAXMESSAGE, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish(act);
	return act;
}
Action Call_OnControlPointCapped(char cappers[MAXPLAYERS+1], const int team)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnControlPointCapped]);
	Call_PushString(cappers);
	Call_PushCell(team);
	Call_Finish(act);
	return act;
}
Action Call_OnPrepRedTeam(const BaseBoss player)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnPrepRedTeam]);
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
Action Call_OnRedPlayerThink(const BaseBoss player)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnRedPlayerThink]);
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}
void Call_OnBossMenu(Menu& menu)
{
	Call_StartForward(g_vsh2.m_hForwards[OnBossMenu]);
	Call_PushCellRef(menu);
	Call_Finish();
}
Action Call_OnScoreTally(const BaseBoss player, int& points_earned, int& queue_earned)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnScoreTally]);
	Call_PushCell(player);
	Call_PushCellRef(points_earned);
	Call_PushCellRef(queue_earned);
	Call_Finish(act);
	return act;
}
Action Call_OnItemOverride(const BaseBoss player, const char[] classname, int itemdef, Handle& item)
{
	Action result;
	Call_StartForward(g_vsh2.m_hForwards[OnItemOverride]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossDealDamage_OnStomp]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossDealDamage_OnHitDefBuff]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossDealDamage_OnHitCritMmmph]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossDealDamage_OnHitMedic]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossDealDamage_OnHitDeadRinger]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossDealDamage_OnHitCloakedSpy]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossDealDamage_OnHitShield]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossTakeDamage_OnStabbed]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossTakeDamage_OnTelefragged]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossTakeDamage_OnSwordTaunt]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossTakeDamage_OnHeavyShotgun]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossTakeDamage_OnSniped]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossTakeDamage_OnThirdDegreed]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossTakeDamage_OnHitSword]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossTakeDamage_OnHitFanOWar]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossTakeDamage_OnHitCandyCane]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossTakeDamage_OnMarketGardened]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossTakeDamage_OnPowerJack]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossTakeDamage_OnKatana]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossTakeDamage_OnAmbassadorHeadshot]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossTakeDamage_OnDiamondbackManmelterCrit]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossTakeDamage_OnHolidayPunch]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossSuperJump]);
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}

Action Call_OnBossDoRageStun(const BaseBoss player, float& distance)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnBossDoRageStun]);
	Call_PushCell(player);
	Call_PushFloatRef(distance);
	Call_Finish(act);
	return act;
}

Action Call_OnBossWeighDown(const BaseBoss player)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnBossWeighDown]);
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}

Action Call_OnRPSTaunt(const BaseBoss loser, const BaseBoss winner)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnRPSTaunt]);
	Call_PushCell(loser);
	Call_PushCell(winner);
	Call_Finish(act);
	return act;
}

Action Call_OnBossAirShotProj(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	Call_StartForward(g_vsh2.m_hForwards[OnBossAirShotProj]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossTakeFallDamage]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossGiveRage]);
	Call_PushCell(player);
	Call_PushCell(damage);
	Call_PushFloatRef(calcd_rage);
	Call_Finish(act);
	return act;
}

Action Call_OnBossCalcHealth(const BaseBoss player, int& max_health, const int boss_count, const int red_players)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnBossCalcHealth]);
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
	Call_StartForward(g_vsh2.m_hForwards[OnBossTakeDamage_OnTriggerHurt]);
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

Action Call_OnBossTakeDamage_OnMantreadsStomp(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	Call_StartForward(g_vsh2.m_hForwards[OnBossTakeDamage_OnMantreadsStomp]);
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

Action Call_OnBossThinkPost(const BaseBoss player)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnBossThinkPost]);
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}

Action Call_OnBossEquippedPost(const BaseBoss player)
{
	Action act;
	Call_StartForward(g_vsh2.m_hForwards[OnBossEquippedPost]);
	Call_PushCell(player);
	Call_Finish(act);
	return act;
}


Action Call_OnPlayerTakeFallDamage(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action result;
	Call_StartForward(g_vsh2.m_hForwards[OnPlayerTakeFallDamage]);
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
