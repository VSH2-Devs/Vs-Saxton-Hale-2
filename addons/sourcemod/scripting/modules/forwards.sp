void InitializeForwards() {
	for( int i; i < sizeof(g_hForwards); i++ ) {
		g_hForwards[i][OnCallDownloads] = new PrivateForward( ET_Event );
		g_hForwards[i][OnBossSelected] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnBossHelp] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnTouchPlayer] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
		g_hForwards[i][OnTouchBuilding] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
		g_hForwards[i][OnBossThink] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnBossModelTimer] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnBossDeath] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnBossEquipped] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnBossInitialized] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnMinionInitialized] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
		g_hForwards[i][OnBossPlayIntro] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnBossTakeDamage] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossDealDamage] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnPlayerKilled] = new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_Cell );
		g_hForwards[i][OnPlayerAirblasted] = new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_Cell );
		g_hForwards[i][OnTraceAttack] = new PrivateForward( ET_Hook, Param_Cell, Param_Cell, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Cell, Param_Cell );
		g_hForwards[i][OnBossMedicCall] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnBossTaunt] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnBossKillBuilding] = new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_Cell );
		g_hForwards[i][OnBossJarated] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
		g_hForwards[i][OnMessageIntro] = new PrivateForward( ET_Event, Param_Cell, Param_String );
		g_hForwards[i][OnBossPickUpItem] = new PrivateForward( ET_Event, Param_Cell, Param_String );
		g_hForwards[i][OnVariablesReset] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnUberDeployed] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
		g_hForwards[i][OnUberLoop] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
		g_hForwards[i][OnMusic] = new PrivateForward( ET_Event, Param_String, Param_FloatByRef, Param_Cell, Param_FloatByRef );
		g_hForwards[i][OnRoundEndInfo] = new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_String );
		g_hForwards[i][OnLastPlayer] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
		g_hForwards[i][OnBossHealthCheck] = new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_String );
		g_hForwards[i][OnControlPointCapped] = new PrivateForward( ET_Event, Param_String, Param_Cell, Param_Array, Param_Cell );
		g_hForwards[i][OnPrepRedTeam] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnRedPlayerThink] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnPlayerHurt] = new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_Cell );
		g_hForwards[i][OnBossMenu] = new PrivateForward( ET_Ignore, Param_CellByRef, Param_Cell );
		g_hForwards[i][OnScoreTally] = new PrivateForward( ET_Event, Param_Cell, Param_CellByRef, Param_CellByRef );
		g_hForwards[i][OnItemOverride] = new PrivateForward( ET_Hook, Param_Cell, Param_String, Param_Cell, Param_CellByRef );
		
		/// OnBossDealDamage Specific Forwards.
		g_hForwards[i][OnBossDealDamage_OnStomp] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossDealDamage_OnHitDefBuff] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossDealDamage_OnHitCritMmmph] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossDealDamage_OnHitMedic] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossDealDamage_OnHitDeadRinger] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossDealDamage_OnHitCloakedSpy] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossDealDamage_OnHitShield] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		
		/// OnBossTakeDamage Specific Forwards
		g_hForwards[i][OnBossTakeDamage_OnStabbed] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnTelefragged] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnSwordTaunt] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnHeavyShotgun] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnSniped] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnThirdDegreed] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnHitSword] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnHitFanOWar] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnHitCandyCane] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnMarketGardened] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnPowerJack] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnKatana] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnAmbassadorHeadshot] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnDiamondbackManmelterCrit] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnHolidayPunch] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		
		g_hForwards[i][OnBossSuperJump] = new PrivateForward( ET_Event, Param_Cell );
		g_hForwards[i][OnBossDoRageStun] = new PrivateForward( ET_Event, Param_Cell, Param_FloatByRef );
		g_hForwards[i][OnBossWeighDown] = new PrivateForward( ET_Event, Param_Cell );
		
		g_hForwards[i][OnRPSTaunt] = new PrivateForward( ET_Event, Param_Cell, Param_Cell );
		g_hForwards[i][OnBossAirShotProj] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeFallDamage] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossGiveRage] = new PrivateForward( ET_Event, Param_Cell, Param_Cell, Param_FloatByRef );
		g_hForwards[i][OnBossCalcHealth] = new PrivateForward( ET_Single, Param_Cell, Param_CellByRef, Param_Cell, Param_Cell );
		
		g_hForwards[i][OnBossTakeDamage_OnTriggerHurt] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossTakeDamage_OnMantreadsStomp] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		g_hForwards[i][OnBossThinkPost] = new PrivateForward( ET_Hook, Param_Cell );
		g_hForwards[i][OnBossEquippedPost] = new PrivateForward( ET_Hook, Param_Cell );
		g_hForwards[i][OnPlayerTakeFallDamage] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell );
		
		g_hForwards[i][OnSoundHook] = new PrivateForward( ET_Event, Param_Cell, Param_String, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef );
		g_hForwards[i][OnRoundStart] = new PrivateForward( ET_Ignore, Param_Array, Param_Cell, Param_Array, Param_Cell );
		g_hForwards[i][OnHelpMenu] = new PrivateForward( ET_Ignore, Param_Cell, Param_Cell );
		g_hForwards[i][OnHelpMenuSelect] = new PrivateForward( ET_Ignore, Param_Cell, Param_Cell, Param_Cell );
		g_hForwards[i][OnDrawGameTimer] = new PrivateForward( ET_Hook, Param_CellByRef );
		g_hForwards[i][OnPlayerClimb] = new PrivateForward( ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef, Param_FloatByRef, Param_CellByRef );
		g_hForwards[i][OnBossConditionChange] = new PrivateForward( ET_Hook, Param_Cell, Param_Cell, Param_Cell, Param_CellByRef );
		g_hForwards[i][OnBannerDeployed] = new PrivateForward( ET_Hook, Param_Cell, Param_Cell );
		g_hForwards[i][OnBannerEffect] = new PrivateForward( ET_Hook, Param_Cell, Param_Cell, Param_Cell );
		g_hForwards[i][OnUberLoopEnd] = new PrivateForward( ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef );
		g_hForwards[i][OnRedPlayerThinkPost] = new PrivateForward( ET_Hook, Param_Cell );
		g_hForwards[i][OnRedPlayerHUD] = new PrivateForward( ET_Hook, Param_Cell, Param_String );
		g_hForwards[i][OnRedPlayerCrits] = new PrivateForward( ET_Hook, Param_Cell, Param_CellByRef );
		g_hForwards[i][OnShowStats] = new PrivateForward( ET_Hook, Param_Array );
		g_hForwards[i][OnPreAbility] = new PrivateForward( ET_Hook, Param_Cell, Param_String, Param_Array, Param_Cell, Param_Cell );
		g_hForwards[i][OnPostAbility] = new PrivateForward( ET_Ignore, Param_Cell, Param_String, Param_Array, Param_Cell, Param_Cell );
		g_hForwards[i][OnBossHUD] = new PrivateForward( ET_Ignore, Param_Cell, Param_String );
		g_hForwards[i][OnTeamsSeparate] = new PrivateForward( ET_Event );
		g_hForwards[i][OnMapObsPrep] = new PrivateForward( ET_Event, Param_String );
	}
}

Action Call_OnCallDownloads() {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnCallDownloads]);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnBossSelected(BasePlayer player) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossSelected]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnBossHelp(BasePlayer player) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossHelp]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnTouchPlayer(BasePlayer boss, BasePlayer otherguy) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnTouchPlayer]);
		Call_PushCell(boss);
		Call_PushCell(otherguy);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnTouchBuilding(BasePlayer player, int buildRef) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnTouchBuilding]);
		Call_PushCell(player);
		Call_PushCell(buildRef);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnBossThink(BasePlayer player) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossThink]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnBossModelTimer(BasePlayer player) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossModelTimer]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnBossDeath(BasePlayer player) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossDeath]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnBossEquipped(BasePlayer player) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossEquipped]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnBossInitialized(BasePlayer player) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossInitialized]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnMinionInitialized(BasePlayer player, BasePlayer master) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnMinionInitialized]);
		Call_PushCell(player);
		Call_PushCell(master);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnBossPlayIntro(BasePlayer player) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossPlayIntro]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnTakeDamageGeneric(int fwd_id, BasePlayer player, int& attacker, int& inflictor, float& damage, int& dmgType, int& weapon, float dmgForce[3], float dmgPos[3], int dmgCustom) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][fwd_id]);
		Call_PushCell(player);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(dmgType);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(dmgForce, 3, SM_PARAM_COPYBACK);
		Call_PushArrayEx(dmgPos,   3, SM_PARAM_COPYBACK);
		Call_PushCell(dmgCustom);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnBossTakeDamage(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossTakeDamage, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnBossDealDamage(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossDealDamage, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnPlayerKilled(BasePlayer player, BasePlayer victim, Event event) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnPlayerKilled]);
		Call_PushCell(player);
		Call_PushCell(victim);
		Call_PushCell(event);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
	
}
Action Call_OnPlayerAirblasted(BasePlayer player, BasePlayer victim, Event event) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnPlayerAirblasted]);
		Call_PushCell(player);
		Call_PushCell(victim);
		Call_PushCell(event);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnPlayerHurt(BasePlayer player, BasePlayer victim, Event event) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnPlayerHurt]);
		Call_PushCell(player);
		Call_PushCell(victim);
		Call_PushCell(event);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnTraceAttack(BasePlayer player, BasePlayer attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnTraceAttack]);
		Call_PushCell(player);
		Call_PushCell(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(ammotype);
		Call_PushCell(hitbox);
		Call_PushCell(hitgroup);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnBossMedicCall(BasePlayer player) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossMedicCall]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnBossTaunt(BasePlayer player) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossTaunt]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnBossKillBuilding(BasePlayer player, int building, Event event) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossKillBuilding]);
		Call_PushCell(player);
		Call_PushCell(building);
		Call_PushCell(event);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnBossJarated(BasePlayer victim, BasePlayer attacker) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossJarated]);
		Call_PushCell(victim);
		Call_PushCell(attacker);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnMessageIntro(BasePlayer player, char message[MAXMESSAGE]) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnMessageIntro]);
		Call_PushCell(player);
		Call_PushStringEx(message, MAXMESSAGE, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnBossPickUpItem(BasePlayer player, const char item[64]) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossPickUpItem]);
		Call_PushCell(player);
		Call_PushString(item);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnVariablesReset(BasePlayer player) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnVariablesReset]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnUberDeployed(BasePlayer medic, BasePlayer target) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnUberDeployed]);
		Call_PushCell(medic);
		Call_PushCell(target);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnUberLoop(BasePlayer medic, BasePlayer target) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnUberLoop]);
		Call_PushCell(medic);
		Call_PushCell(target);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnMusic(char song[PLATFORM_MAX_PATH], float& time, BasePlayer player, float& vol) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnMusic]);
		Call_PushStringEx(song, PLATFORM_MAX_PATH, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_PushFloatRef(time);
		Call_PushCell(player);
		Call_PushFloatRef(vol);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnRoundEndInfo(BasePlayer player, bool bosswin, char message[MAXMESSAGE]) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnRoundEndInfo]);
		Call_PushCell(player);
		Call_PushCell(bosswin);
		Call_PushStringEx(message, MAXMESSAGE, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnLastPlayer(BasePlayer player, BasePlayer last_guy) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnLastPlayer]);
		Call_PushCell(player);
		Call_PushCell(last_guy);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnBossHealthCheck(BasePlayer player, bool isBoss, char message[MAXMESSAGE]) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossHealthCheck]);
		Call_PushCell(player);
		Call_PushCell(isBoss);
		Call_PushStringEx(message, MAXMESSAGE, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnControlPointCapped(char cappers[MAXPLAYERS+1], int team, BasePlayer[] bcappers, int capper_count) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnControlPointCapped]);
		Call_PushString(cappers);
		Call_PushCell(team);
		Call_PushArrayEx(bcappers, capper_count, SM_PARAM_COPYBACK);
		Call_PushCell(capper_count);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnPrepRedTeam(BasePlayer player) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnPrepRedTeam]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnRedPlayerThink(BasePlayer player) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnRedPlayerThink]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
void Call_OnBossMenu(Menu& menu, BasePlayer player) {
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossMenu]);
		Call_PushCellRef(menu);
		Call_PushCell(player);
		Call_Finish();
	}
}
Action Call_OnScoreTally(BasePlayer player, int& points_earned, int& queue_earned) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnScoreTally]);
		Call_PushCell(player);
		Call_PushCellRef(points_earned);
		Call_PushCellRef(queue_earned);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnItemOverride(BasePlayer player, const char[] classname, int itemdef, Handle& item) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnItemOverride]);
		Call_PushCell(player);
		Call_PushString(classname);
		Call_PushCell(itemdef);
		Call_PushCellRef(item);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnBossDealDamage_OnStomp(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossDealDamage_OnStomp, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnBossDealDamage_OnHitDefBuff(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossDealDamage_OnHitDefBuff, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnBossDealDamage_OnHitCritMmmph(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossDealDamage_OnHitCritMmmph, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnBossDealDamage_OnHitMedic(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossDealDamage_OnHitMedic, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnBossDealDamage_OnHitDeadRinger(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossDealDamage_OnHitDeadRinger, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnBossDealDamage_OnHitCloakedSpy(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossDealDamage_OnHitCloakedSpy, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnBossDealDamage_OnHitShield(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossDealDamage_OnHitShield, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}


/// OnBossTakeDamage forwards.
Action Call_OnBossTakeDamage_OnStabbed(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossTakeDamage_OnStabbed, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnBossTakeDamage_OnTelefragged(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossTakeDamage_OnTelefragged, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnBossTakeDamage_OnSwordTaunt(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossTakeDamage_OnSwordTaunt, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnBossTakeDamage_OnHeavyShotgun(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossTakeDamage_OnHeavyShotgun, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnBossTakeDamage_OnSniped(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossTakeDamage_OnSniped, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnBossTakeDamage_OnThirdDegreed(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossTakeDamage_OnThirdDegreed, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnBossTakeDamage_OnHitSword(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossTakeDamage_OnHitSword, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnBossTakeDamage_OnHitFanOWar(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossTakeDamage_OnHitFanOWar, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnBossTakeDamage_OnHitCandyCane(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossTakeDamage_OnHitCandyCane, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnBossTakeDamage_OnMarketGardened(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossTakeDamage_OnMarketGardened, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnBossTakeDamage_OnPowerJack(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossTakeDamage_OnPowerJack, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnBossTakeDamage_OnKatana(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossTakeDamage_OnKatana, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnBossTakeDamage_OnAmbassadorHeadshot(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossTakeDamage_OnAmbassadorHeadshot, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnBossTakeDamage_OnDiamondbackManmelterCrit(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossTakeDamage_OnDiamondbackManmelterCrit, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}
Action Call_OnBossTakeDamage_OnHolidayPunch(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossTakeDamage_OnHolidayPunch, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}

Action Call_OnBossSuperJump(BasePlayer player) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossSuperJump]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnBossDoRageStun(BasePlayer player, float& distance) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossDoRageStun]);
		Call_PushCell(player);
		Call_PushFloatRef(distance);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnBossWeighDown(BasePlayer player) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossWeighDown]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnRPSTaunt(BasePlayer loser, BasePlayer winner) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnRPSTaunt]);
		Call_PushCell(loser);
		Call_PushCell(winner);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnBossAirShotProj(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossAirShotProj, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}

Action Call_OnBossTakeFallDamage(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossTakeFallDamage, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}

Action Call_OnBossGiveRage(BasePlayer player, int damage, float& calcd_rage) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossGiveRage]);
		Call_PushCell(player);
		Call_PushCell(damage);
		Call_PushFloatRef(calcd_rage);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnBossCalcHealth(BasePlayer player, int& max_health, int boss_count, int red_players) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossCalcHealth]);
		Call_PushCell(player);
		Call_PushCellRef(max_health);
		Call_PushCell(boss_count);
		Call_PushCell(red_players);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnBossTakeDamage_OnTriggerHurt(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossTakeDamage_OnTriggerHurt, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}

Action Call_OnBossTakeDamage_OnMantreadsStomp(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnBossTakeDamage_OnMantreadsStomp, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}

Action Call_OnBossThinkPost(BasePlayer player) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossThinkPost]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnBossEquippedPost(BasePlayer player) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossEquippedPost]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnPlayerTakeFallDamage(BasePlayer player, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	return Call_OnTakeDamageGeneric(OnPlayerTakeFallDamage, player, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}

Action Call_OnSoundHook(BasePlayer player, char sample[PLATFORM_MAX_PATH], int& channel, float& volume, int& level, int& pitch, int& flags) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnSoundHook]);
		Call_PushCell(player);
		Call_PushStringEx(sample, PLATFORM_MAX_PATH, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_PushCellRef(channel);
		Call_PushFloatRef(volume);
		Call_PushCellRef(level);
		Call_PushCellRef(pitch);
		Call_PushCellRef(flags);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

void Call_OnRoundStart(BasePlayer[] bosses, int boss_count, BasePlayer[] reds, int red_count) {
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnRoundStart]);
		Call_PushArrayEx(bosses, boss_count, SM_PARAM_COPYBACK);
		Call_PushCell(boss_count);
		Call_PushArrayEx(reds, red_count, SM_PARAM_COPYBACK);
		Call_PushCell(red_count);
		Call_Finish();
	}
}

void Call_OnHelpMenu(BasePlayer player, Menu menu) {
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnHelpMenu]);
		Call_PushCell(player);
		Call_PushCell(menu);
		Call_Finish();
	}
}

void Call_OnHelpMenuSelect(BasePlayer player, Menu menu, int selection) {
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnHelpMenuSelect]);
		Call_PushCell(player);
		Call_PushCell(menu);
		Call_PushCell(selection);
		Call_Finish();
	}
}

Action Call_OnDrawGameTimer(int& time) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnDrawGameTimer]);
		Call_PushCellRef(time);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnPlayerClimb(BasePlayer player, int weapon, float& upwardvel, float& health, bool& attackdelay) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnPlayerClimb]);
		Call_PushCell(player);
		Call_PushCell(weapon);
		Call_PushFloatRef(upwardvel);
		Call_PushFloatRef(health);
		Call_PushCellRef(attackdelay);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnBossConditionChange(BasePlayer player, TFCond cond, bool removing, bool& remove) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossConditionChange]);
		Call_PushCell(player);
		Call_PushCell(cond);
		Call_PushCell(removing);
		Call_PushCellRef(remove);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

void Call_OnBannerDeployed(BasePlayer owner, int buff_type) {
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Action act;
		Call_StartForward(g_hForwards[i][OnBannerDeployed]);
		Call_PushCell(owner);
		Call_PushCell(buff_type);
		Call_Finish(act);
		if( act > Plugin_Continue ) {
			break;
		}
	}
}

void Call_OnBannerEffect(BasePlayer player, BasePlayer owner, int buff_type) {
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Action act;
		Call_StartForward(g_hForwards[i][OnBannerEffect]);
		Call_PushCell(player);
		Call_PushCell(owner);
		Call_PushCell(buff_type);
		Call_Finish(act);
		if( act > Plugin_Continue ) {
			break;
		}
	}
}

void Call_OnUberLoopEnd(BasePlayer medic, BasePlayer target, float& reset_charge) {
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Action act;
		Call_StartForward(g_hForwards[i][OnUberLoopEnd]);
		Call_PushCell(medic);
		Call_PushCell(target);
		Call_PushFloatRef(reset_charge);
		Call_Finish(act);
		if( act > Plugin_Continue ) {
			break;
		}
	}
}

Action Call_OnRedPlayerThinkPost(BasePlayer player) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnRedPlayerThinkPost]);
		Call_PushCell(player);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnRedPlayerHUD(BasePlayer player, char hud_text[PLAYER_HUD_SIZE]) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnRedPlayerHUD]);
		Call_PushCell(player);
		Call_PushStringEx(hud_text, PLAYER_HUD_SIZE, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}
Action Call_OnBossHUD(BasePlayer player, char hud_text[PLAYER_HUD_SIZE]) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnBossHUD]);
		Call_PushCell(player);
		Call_PushStringEx(hud_text, sizeof(hud_text), SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnRedPlayerCrits(BasePlayer player, int &crit_flags) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnRedPlayerCrits]);
		Call_PushCell(player);
		Call_PushCellRef(crit_flags);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnShowStats(BasePlayer players[3]) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnShowStats]);
		Call_PushArrayEx(players, 3, 0);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnTeamsSeparate() {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnTeamsSeparate]);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}

Action Call_OnMapObsPrep(const char[] entity_name) {
	Action act[2];
	for( int i; i < sizeof(g_hForwards); i++ ) {
		Call_StartForward(g_hForwards[i][OnMapObsPrep]);
		Call_PushString(entity_name);
		Call_Finish(act[i]);
		if( act[i] > Plugin_Changed ) {
			return act[i];
		}
	}
	return act[0] > act[1]? act[0] : act[1];
}