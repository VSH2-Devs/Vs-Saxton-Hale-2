void InitializeForwards() {
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		/// No params, Event.
		g_modsys.SetPrivFwd(i, OnCallDownloads, new PrivateForward( ET_Event ));
		
		/// 1 param, Event.
		g_modsys.SetPrivFwd(i, OnBossSelected,        new PrivateForward( ET_Event, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBossThink,           new PrivateForward( ET_Event, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBossModelTimer,      new PrivateForward( ET_Event, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBossDeath,           new PrivateForward( ET_Event, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBossEquipped,        new PrivateForward( ET_Event, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBossInitialized,     new PrivateForward( ET_Event, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBossPlayIntro,       new PrivateForward( ET_Event, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBossMedicCall,       new PrivateForward( ET_Event, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBossTaunt,           new PrivateForward( ET_Event, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnVariablesReset,      new PrivateForward( ET_Event, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnLastPlayer,          new PrivateForward( ET_Event, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnPrepRedTeam,         new PrivateForward( ET_Event, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnRedPlayerThink,      new PrivateForward( ET_Event, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBossSuperJump,       new PrivateForward( ET_Event, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBossWeighDown,       new PrivateForward( ET_Event, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBossThinkPost,       new PrivateForward( ET_Event, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBossEquippedPost,    new PrivateForward( ET_Event, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnRedPlayerThinkPost,  new PrivateForward( ET_Event, Param_Cell ));
		
		/// 2 params, Event.
		g_modsys.SetPrivFwd(i, OnTouchPlayer,         new PrivateForward( ET_Event, Param_Cell, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnTouchBuilding,       new PrivateForward( ET_Event, Param_Cell, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnMinionInitialized,   new PrivateForward( ET_Event, Param_Cell, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBossJarated,         new PrivateForward( ET_Event, Param_Cell, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnUberDeployed,        new PrivateForward( ET_Event, Param_Cell, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnUberLoop,            new PrivateForward( ET_Event, Param_Cell, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnRPSTaunt,            new PrivateForward( ET_Event, Param_Cell, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBannerDeployed,      new PrivateForward( ET_Event, Param_Cell, Param_Cell ));
		
		/// 3 params, Event.
		g_modsys.SetPrivFwd(i, OnPlayerKilled,        new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnPlayerAirblasted,    new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBossKillBuilding,    new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnPlayerHurt,          new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBossConditionChange, new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBannerEffect,        new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_Cell ));
		
		/// OnTakeDmg copies, Hook.
		g_modsys.SetPrivFwd(i, OnBossTakeDamage,      new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBossDealDamage,      new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBossAirShotProj,     new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBossTakeFallDamage,  new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBossTakeDamage_OnTriggerHurt, new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnBossTakeDamage_OnMantreadsStomp, new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnPlayerTakeFallDamage, new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell ));
		
		for( int x=OnBossDealDamage_OnStomp; x<=OnBossTakeDamage_OnHolidayPunch; x++ ) {
			g_modsys.SetPrivFwd(i, x, new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell ));
		}
		
		/// OnTraceAtk, Hook.
		g_modsys.SetPrivFwd(i, OnTraceAttack,    new PrivateForward( ET_Hook, Param_Cell, Param_Cell, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Cell, Param_Cell ));
		
		/// cell + string, Event.
		g_modsys.SetPrivFwd(i, OnMessageIntro,   new PrivateForward( ET_Event, Param_Cell, Param_String ));
		g_modsys.SetPrivFwd(i, OnBossPickUpItem, new PrivateForward( ET_Event, Param_Cell, Param_String ));
		g_modsys.SetPrivFwd(i, OnRedPlayerHUD,   new PrivateForward( ET_Event, Param_Cell, Param_String ));
		
		/// music, Event.
		g_modsys.SetPrivFwd(i, OnMusic, new PrivateForward( ET_Event, Param_String, Param_FloatByRef, Param_Cell, Param_FloatByRef ));
		
		/// 2 cells, one string, Event.
		g_modsys.SetPrivFwd(i, OnRoundEndInfo,    new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_String ));
		g_modsys.SetPrivFwd(i, OnBossHealthCheck, new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_String ));
		
		/// control point, Event.
		g_modsys.SetPrivFwd(i, OnControlPointCapped, new PrivateForward( ET_Event, Param_String, Param_Cell, Param_Array, Param_Cell ));
		
		/// Boss menu, Ignore.
		g_modsys.SetPrivFwd(i, OnBossMenu,       new PrivateForward( ET_Ignore, Param_CellByRef, Param_Cell ));
		
		/// Score tally, Event.
		g_modsys.SetPrivFwd(i, OnScoreTally,     new PrivateForward( ET_Event, Param_Cell, Param_CellByRef, Param_CellByRef ));
		
		/// OnItemOverride, Hook.
		g_modsys.SetPrivFwd(i, OnItemOverride,   new PrivateForward( ET_Hook, Param_Cell, Param_String, Param_Cell, Param_CellByRef ));
		
		g_modsys.SetPrivFwd(i, OnBossDoRageStun, new PrivateForward( ET_Event, Param_Cell, Param_FloatByRef ));
		g_modsys.SetPrivFwd(i, OnBossGiveRage,   new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_FloatByRef ));
		g_modsys.SetPrivFwd(i, OnUberLoopEnd,    new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_FloatByRef ));
		g_modsys.SetPrivFwd(i, OnBossCalcHealth, new PrivateForward( ET_Single, Param_Cell, Param_CellByRef, Param_Cell, Param_Cell ));
		
		/// SoundHook
		g_modsys.SetPrivFwd(i, OnSoundHook,      new PrivateForward( ET_Hook, Param_Cell, Param_String, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef ));
		
		g_modsys.SetPrivFwd(i, OnRoundStart,     new PrivateForward( ET_Ignore, Param_Array, Param_Cell, Param_Array, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnHelpMenu,       new PrivateForward( ET_Ignore, Param_Cell, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnHelpMenuSelect, new PrivateForward( ET_Ignore, Param_Cell, Param_Cell, Param_Cell ));
		g_modsys.SetPrivFwd(i, OnDrawGameTimer,  new PrivateForward( ET_Event, Param_CellByRef ));
		g_modsys.SetPrivFwd(i, OnPlayerClimb,    new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_FloatByRef, Param_FloatByRef, Param_CellByRef ));
		g_modsys.SetPrivFwd(i, OnRedPlayerCrits, new PrivateForward( ET_Event, Param_Cell, Param_CellByRef ));
		g_modsys.SetPrivFwd(i, OnShowStats,      new PrivateForward( ET_Event, Param_Array ));
	}
}

/// Design Note: pass only enum-struct array, string buffer, and len to all forwards.
Action Call_OnCallDownloads() {
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnCallDownloads);
		Call_StartForward(p);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossSelected(const BaseBoss player) {
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossSelected);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnTouchPlayer(const BaseBoss boss, const BaseBoss otherguy) {
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnTouchPlayer);
		Call_StartForward(p);
		Call_PushCell(boss);
		Call_PushCell(otherguy);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnTouchBuilding(const BaseBoss player, const int buildRef)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnTouchBuilding);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCell(buildRef);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossThink(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossThink);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossModelTimer(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossModelTimer);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossDeath(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossDeath);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossEquipped(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossEquipped);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossInitialized(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossInitialized);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnMinionInitialized(const BaseBoss player, const BaseBoss master)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnMinionInitialized);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCell(master);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossPlayIntro(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossPlayIntro);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossTakeDamage);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossDealDamage(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossDealDamage);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnPlayerKilled(const BaseBoss player, const BaseBoss victim, Event event)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnPlayerKilled);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCell(victim);
		Call_PushCell(event);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnPlayerAirblasted(const BaseBoss player, const BaseBoss victim, Event event)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnPlayerAirblasted);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCell(victim);
		Call_PushCell(event);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnPlayerHurt(const BaseBoss player, const BaseBoss victim, Event event)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnPlayerHurt);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCell(victim);
		Call_PushCell(event);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnTraceAttack(const BaseBoss player, const BaseBoss attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnTraceAttack);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCell(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(ammotype);
		Call_PushCell(hitbox);
		Call_PushCell(hitgroup);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossMedicCall(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossMedicCall);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTaunt(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossTaunt);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossKillBuilding(const BaseBoss player, const int building, Event event)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossKillBuilding);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCell(building);
		Call_PushCell(event);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossJarated(const BaseBoss victim, const BaseBoss attacker)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossJarated);
		Call_StartForward(p);
		Call_PushCell(victim);
		Call_PushCell(attacker);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnMessageIntro(const BaseBoss player, char message[MAXMESSAGE])
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnMessageIntro);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushStringEx(message, MAXMESSAGE, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossPickUpItem(const BaseBoss player, const char item[64])
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossPickUpItem);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushString(item);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnVariablesReset(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnVariablesReset);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnUberDeployed(const BaseBoss medic, const BaseBoss target)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnUberDeployed);
		Call_StartForward(p);
		Call_PushCell(medic);
		Call_PushCell(target);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnUberLoop(const BaseBoss medic, const BaseBoss target)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnUberLoop);
		Call_StartForward(p);
		Call_PushCell(medic);
		Call_PushCell(target);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnMusic(char song[PLATFORM_MAX_PATH], float& time, const BaseBoss player, float& vol)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnMusic);
		Call_StartForward(p);
		Call_PushStringEx(song, PLATFORM_MAX_PATH, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_PushFloatRef(time);
		Call_PushCell(player);
		Call_PushFloatRef(vol);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnRoundEndInfo(const BaseBoss player, bool bosswin, char message[MAXMESSAGE])
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnRoundEndInfo);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCell(bosswin);
		Call_PushStringEx(message, MAXMESSAGE, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnLastPlayer(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnLastPlayer);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossHealthCheck(const BaseBoss player, const bool isBoss, char message[MAXMESSAGE])
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossHealthCheck);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCell(isBoss);
		Call_PushStringEx(message, MAXMESSAGE, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnControlPointCapped(char cappers[MAXPLAYERS+1], const int team, BaseBoss[] bcappers, const int capper_count)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnControlPointCapped);
		Call_StartForward(p);
		Call_PushString(cappers);
		Call_PushCell(team);
		Call_PushArrayEx(bcappers, capper_count, SM_PARAM_COPYBACK);
		Call_PushCell(capper_count);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnPrepRedTeam(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnPrepRedTeam);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnRedPlayerThink(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnRedPlayerThink);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
void Call_OnBossMenu(Menu& menu, const BaseBoss player)
{
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossMenu);
		Call_StartForward(p);
		Call_PushCellRef(menu);
		Call_PushCell(player);
		Call_Finish();
	}
}
Action Call_OnScoreTally(const BaseBoss player, int& points_earned, int& queue_earned)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnScoreTally);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(points_earned);
		Call_PushCellRef(queue_earned);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnItemOverride(const BaseBoss player, const char[] classname, int itemdef, Handle& item)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnItemOverride);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushString(classname);
		Call_PushCell(itemdef);
		Call_PushCellRef(item);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossDealDamage_OnStomp(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossDealDamage_OnStomp);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossDealDamage_OnHitDefBuff(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossDealDamage_OnHitDefBuff);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossDealDamage_OnHitCritMmmph(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossDealDamage_OnHitCritMmmph);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossDealDamage_OnHitMedic(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossDealDamage_OnHitMedic);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossDealDamage_OnHitDeadRinger(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossDealDamage_OnHitDeadRinger);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossDealDamage_OnHitCloakedSpy(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossDealDamage_OnHitCloakedSpy);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossDealDamage_OnHitShield(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossDealDamage_OnHitShield);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}


/// OnBossTakeDamage forwards.
Action Call_OnBossTakeDamage_OnStabbed(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossTakeDamage_OnStabbed);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnTelefragged(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossTakeDamage_OnTelefragged);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnSwordTaunt(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossTakeDamage_OnSwordTaunt);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
/** 
Action Call_OnBossTakeDamage_OnHeavyShotgun(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossTakeDamage_OnHeavyShotgun);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
**/
Action Call_OnBossTakeDamage_OnSniped(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossTakeDamage_OnSniped);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnThirdDegreed(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossTakeDamage_OnThirdDegreed);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnHitSword(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossTakeDamage_OnHitSword);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnHitFanOWar(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossTakeDamage_OnHitFanOWar);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnHitCandyCane(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossTakeDamage_OnHitCandyCane);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnMarketGardened(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossTakeDamage_OnMarketGardened);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnPowerJack(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossTakeDamage_OnPowerJack);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnKatana(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossTakeDamage_OnKatana);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnAmbassadorHeadshot(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossTakeDamage_OnAmbassadorHeadshot);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnDiamondbackManmelterCrit(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossTakeDamage_OnDiamondbackManmelterCrit);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}
Action Call_OnBossTakeDamage_OnHolidayPunch(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossTakeDamage_OnHolidayPunch);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossSuperJump(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossSuperJump);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossDoRageStun(const BaseBoss player, float& distance)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossDoRageStun);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushFloatRef(distance);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossWeighDown(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossWeighDown);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnRPSTaunt(const BaseBoss loser, const BaseBoss winner)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnRPSTaunt);
		Call_StartForward(p);
		Call_PushCell(loser);
		Call_PushCell(winner);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossAirShotProj(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossAirShotProj);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossTakeFallDamage(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossTakeFallDamage);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossGiveRage(const BaseBoss player, const int damage, float& calcd_rage)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossGiveRage);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCell(damage);
		Call_PushFloatRef(calcd_rage);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossCalcHealth(const BaseBoss player, int& max_health, const int boss_count, const int red_players)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossCalcHealth);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(max_health);
		Call_PushCell(boss_count);
		Call_PushCell(red_players);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossTakeDamage_OnTriggerHurt(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossTakeDamage_OnTriggerHurt);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossTakeDamage_OnMantreadsStomp(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossTakeDamage_OnMantreadsStomp);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossThinkPost(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossThinkPost);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossEquippedPost(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossEquippedPost);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnPlayerTakeFallDamage(const BaseBoss player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnPlayerTakeFallDamage);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, 3, SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnSoundHook(const BaseBoss player, char sample[PLATFORM_MAX_PATH], int& channel, float& volume, int& level, int& pitch, int& flags)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnSoundHook);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushStringEx(sample, PLATFORM_MAX_PATH, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_PushCellRef(channel);
		Call_PushFloatRef(volume);
		Call_PushCellRef(level);
		Call_PushCellRef(pitch);
		Call_PushCellRef(flags);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

void Call_OnRoundStart(BaseBoss[] bosses, const int boss_count, BaseBoss[] reds, const int red_count)
{
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnRoundStart);
		Call_StartForward(p);
		Call_PushArrayEx(bosses, boss_count, SM_PARAM_COPYBACK);
		Call_PushCell(boss_count);

		Call_PushArrayEx(reds, red_count, SM_PARAM_COPYBACK);
		Call_PushCell(red_count);
		Call_Finish();
	}
}

void Call_OnHelpMenu(const BaseBoss player, Menu menu)
{
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnHelpMenu);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCell(menu);
		Call_Finish();
	}
}

void Call_OnHelpMenuSelect(const BaseBoss player, Menu menu, const int selection)
{
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnHelpMenuSelect);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCell(menu);
		Call_PushCell(selection);
		Call_Finish();
	}
}

Action Call_OnDrawGameTimer(int& time)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnDrawGameTimer);
		Call_StartForward(p);
		Call_PushCellRef(time);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnPlayerClimb(const BaseBoss player, const int weapon, float& upwardvel, float& health, bool& attackdelay)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnPlayerClimb);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCell(weapon);
		Call_PushFloatRef(upwardvel);
		Call_PushFloatRef(health);
		Call_PushCellRef(attackdelay);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnBossConditionChange(const BaseBoss player, const TFCond cond, const bool removing)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBossConditionChange);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCell(cond);
		Call_PushCell(removing);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

void Call_OnBannerDeployed(const BaseBoss owner, const int buff_type)
{
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		Action act;
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBannerDeployed);
		Call_StartForward(p);
		Call_PushCell(owner);
		Call_PushCell(buff_type);
		Call_Finish(act);
		if( act > Plugin_Continue )
			break;
	}
}

void Call_OnBannerEffect(const BaseBoss player, const BaseBoss owner, const int buff_type)
{
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		Action act;
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnBannerEffect);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCell(owner);
		Call_PushCell(buff_type);
		Call_Finish(act);
		if( act > Plugin_Continue )
			break;
	}
}

void Call_OnUberLoopEnd(const BaseBoss medic, const BaseBoss target, float& reset_charge)
{
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		Action act;
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnUberLoopEnd);
		Call_StartForward(p);
		Call_PushCell(medic);
		Call_PushCell(target);
		Call_PushFloatRef(reset_charge);
		Call_Finish(act);
		if( act > Plugin_Continue )
			break;
	}
}

Action Call_OnRedPlayerThinkPost(const BaseBoss player)
{
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnRedPlayerThinkPost);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnRedPlayerHUD(const BaseBoss player, char playerhud[PLAYER_HUD_SIZE]) {
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnRedPlayerHUD);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushStringEx(playerhud, PLAYER_HUD_SIZE, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnRedPlayerCrits(const BaseBoss player, int &crit_flags) {
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnRedPlayerCrits);
		Call_StartForward(p);
		Call_PushCell(player);
		Call_PushCellRef(crit_flags);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}

Action Call_OnShowStats(BaseBoss players[3]) {
	Action act[2];
	for( int i; i<sizeof(VSH2ModuleSys::m_hForwards); i++ ) {
		PrivateForward p = g_modsys.GetPrivFwdE(i, OnShowStats);
		Call_StartForward(p);
		Call_PushArrayEx(players, 3, 0);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed )
			return act[i];
	}
	return act[0] > act[1] ? act[0] : act[1];
}