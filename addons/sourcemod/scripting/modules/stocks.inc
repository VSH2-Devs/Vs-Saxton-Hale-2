stock int GetHealingTarget(int client) {
	int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if( !IsValidEntity(medigun) ) {
		return -1;
	} else if( HasEntProp(medigun, Prop_Send, "m_bHealing") && GetEntProp(medigun, Prop_Send, "m_bHealing") ) {
		return GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
	}
	return -1;
}

public Action RemoveEnt(Handle timer, any entid) {
	int ent = EntRefToEntIndex(entid);
	if( ent > 0 && IsValidEntity(ent) ) {
		AcceptEntityInput(ent, "Kill");
	}
	return Plugin_Continue;
}

stock int GetActiveWep(int client) {
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	return( IsValidEntity(weapon) )? weapon : -1;
}

stock float GetMediGunCharge(int medigun) {
	return( IsValidEntity(medigun) )? GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel") : -1.0;
}

stock void SetMediCharge(int medigun, float val) {
	if( !IsValidEntity(medigun) ) {
		return;
	}
	SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", val);
}

stock bool IsNearSpencer(int client) {
	int healers = GetEntProp(client, Prop_Send, "m_nNumHealers");
	int medics;
	if( healers > 0 ) {
		for( int i=1; i<=MaxClients; i++ ) {
			if( IsClientValidExtra(i) && GetHealingTarget(i) == client ) {
				medics++;
			}
		}
	}
	return (healers > medics);
}

stock bool IsHealedByMedic(int client) {
	int numhealers = GetEntProp(client, Prop_Send, "m_nNumHealers");
	for( int i=0; i < numhealers; i++ ) {
		if( 0 < GetHealerByIndex(client, i) <= MaxClients ) {
			return true;
		}
	}
	return false;
}

stock bool IsNearDispencer(int client) {
	int numhealers = GetEntProp(client, Prop_Send, "m_nNumHealers");
	for( int i = 0; i < numhealers; i++ ) {
		if( IsDispenserHeal(client, i) ) {
			return true;
		}
	}
	return false;
}

stock bool IsDispenserHeal(int client, int index) {
	static int m_aHealers;
	if( !m_aHealers ) {
		m_aHealers = FindSendPropInfo("CTFPlayer", "m_nNumHealers") + 12;
	}
	Address m_Shared = GetEntityAddress(client) + view_as<Address>(m_aHealers);
	Address aHealers = view_as<Address>(LoadFromAddress(m_Shared, NumberType_Int32));
	return !!LoadFromAddress(aHealers + view_as<Address>(index * 0x24 + 20), NumberType_Int8);
}

public bool TraceRayDontHitSelf(int entity, int mask, any data) {
	return( entity != data );
}
public bool TraceRayIgnoreEnts(int entity, int mask, any data) {
	return entity==0;
}
stock void ForceTeamWin(int team) {
	int entity = FindEntityByClassname(-1, "team_control_point_master");
	if( entity <= 0 ) {
		entity = CreateEntityByName("team_control_point_master");
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "Enable");
	}
	SetVariantInt(team);
	AcceptEntityInput(entity, "SetWinner");
}
stock int GetItemIndex(int item) {
	return( IsValidEntity(item) )? GetEntProp(item, Prop_Send, "m_iItemDefinitionIndex") : -1;
}
stock int GetItemQuality(int item) {
	return( IsValidEntity(item) )? GetEntProp(item, Prop_Send, "m_iEntityQuality") : -1;
}
stock int GetIndexOfWeaponSlot(int client, int slot) {
	int weapon = GetPlayerWeaponSlot(client, slot);
	return GetItemIndex(weapon);
}
stock bool IsInRange(int entity, int target, float dist, bool trace=false) {
	float entity_pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", entity_pos);
	float target_pos[3]; GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", target_pos);
	bool within_range = GetVectorDistance(entity_pos, target_pos, true) <= dist*dist;
	if( within_range && trace ) {
		TR_TraceRayFilter(entity_pos, target_pos, MASK_SHOT, RayType_EndPoint, TraceRayDontHitSelf, entity);
		return TR_GetFraction() > 0.98;
	}
	return within_range;
}
stock int AttachParticle(int ent, const char[] particleType, float offset = 0.0, bool battach = true) {
	int particle = CreateEntityByName("info_particle_system");
	char tName[32];
	float pos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	pos[2] += offset;
	TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
	Format(tName, sizeof(tName), "target%i", ent);
	DispatchKeyValue(ent, "targetname", tName);
	DispatchKeyValue(particle, "targetname", "tf2particle");
	DispatchKeyValue(particle, "parentname", tName);
	DispatchKeyValue(particle, "effect_name", particleType);
	DispatchSpawn(particle);
	SetVariantString(tName);
	if( battach ) {
		AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		SetEntPropEnt(particle, Prop_Send, "m_hOwnerEntity", ent);
	}
	ActivateEntity(particle);
	AcceptEntityInput(particle, "start");
	CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(particle));
	return particle;
}
stock void CreateParticles(char[] particlename, float Pos[3] = NULL_VECTOR, float time) {
	int particle = CreateEntityByName("info_particle_system");
	if( IsValidEntity(particle) ) {
		DispatchKeyValue(particle, "effect_name", particlename);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		TeleportEntity(particle, Pos, NULL_VECTOR, NULL_VECTOR);
		CreateTimer(time, RemoveEnt, EntIndexToEntRef(particle));
	}
	else LogError("CreateParticles: **** Couldn't Create 'info_particle_system Entity' ****");
}
stock void SetWeaponInvis(int client, int alpha) {
	int transparent = alpha;
	for( int i; i < 5; i++ ) {
		int entity = GetPlayerWeaponSlot(client, i);
		if( IsValidEntity(entity) ) {
			transparent = IntClamp(transparent, 255, 0);
			SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
			SetEntityRenderColor(entity, 150, 150, 150, transparent);
		}
	}
}
stock void SetWeaponAmmo(int weapon, int ammo) {
	int owner = GetOwner(weapon);
	if( owner <= 0 ) {
		return;
	}
	int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
	int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
	SetEntData(owner, iAmmoTable+iOffset, ammo, 4, true);
}
stock int GetWeaponAmmo(int weapon) {
	int owner = GetOwner(weapon);
	if( owner <= 0 ) {
		return 0;
	}
	int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
	int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
	return GetEntData(owner, iAmmoTable+iOffset, 4);
}
stock int GetWeaponClip(int weapon) {
	if( !IsValidEntity(weapon) ) {
		return 0;
	}
	int AmmoClipTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
	return GetEntData(weapon, AmmoClipTable);
}
stock void SetWeaponClip(int weapon, int ammo) {
	if( !IsValidEntity(weapon) ) {
		return;
	}
	int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
	SetEntData(weapon, iAmmoTable, ammo, 4, true);
}
stock int ShootRocket(int client, bool bCrit=false, const float vPosition[3], const float vAngles[3], float flSpeed, float dmg, const char[] model, bool arc=false) {
	int iTeam = GetClientTeam(client);
	int iProjectile = CreateEntityByName("tf_projectile_rocket");
	if( !IsValidEntity(iProjectile) ) {
		return 0;
	}
	
	float vVelocity[3]; GetAngleVectors(vAngles, vVelocity, NULL_VECTOR, NULL_VECTOR);
	if( !arc ) {
		NormalizeVector(vVelocity, vVelocity);
	} else {
		vVelocity[2] -= 0.025;
	}
	
	ScaleVector(vVelocity, flSpeed);
	SetEntPropEnt(iProjectile, Prop_Send, "m_hOwnerEntity", client);
	SetEntProp(iProjectile,    Prop_Send, "m_bCritical", (bCrit? 1 : 0));
	SetEntProp(iProjectile,    Prop_Send, "m_iTeamNum", iTeam, 1);
	SetEntProp(iProjectile,    Prop_Send, "m_nSkin", (iTeam-2));
	
	SetVariantInt(iTeam);
	AcceptEntityInput(iProjectile, "TeamNum", -1, -1, 0);
	SetVariantInt(iTeam);
	AcceptEntityInput(iProjectile, "SetTeam", -1, -1, 0);
	SetEntDataFloat(iProjectile, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, dmg, true);
	
	TeleportEntity(iProjectile, vPosition, vAngles, vVelocity);
	DispatchSpawn(iProjectile);
	if( arc ) {
		SetEntityMoveType(iProjectile, MOVETYPE_FLYGRAVITY);
	}
	if( model[0] != '\0' ) {
		SetEntityModel(iProjectile, model);
	}
	return iProjectile;
}

stock void SetClientOverlay(int client, const char[] overlay) {
	int cmd_flags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
	SetCommandFlags("r_screenoverlay", cmd_flags);
	ClientCommand(client, "r_screenoverlay \"%s\"", overlay);
}

stock bool IsClientValid(int client) {
	return( 0 < client <= MaxClients && IsClientInGame(client) );
}

stock bool IsClientValidExtra(int client, bool replaycheck=true) {
	if( !IsClientValid(client) || GetEntProp(client, Prop_Send, "m_bIsCoaching") ) {
		return false;
	} else if( replaycheck && (IsClientSourceTV(client) || IsClientReplay(client)) ) {
		return false;
	} else if( TF2_GetPlayerClass(client)==TFClass_Unknown ) {
		return false;
	}
	return true;
}
stock int GetOwner(int ent) {
	return( IsValidEntity(ent) )? GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") : -1;
}
stock int GetBuilder(int ent) {
	return( IsValidEntity(ent) )? GetEntPropEnt(ent, Prop_Send, "m_hBuilder") : -1;
}
stock int GetGroundEntity(int client) {
	return( IsClientValidExtra(client) )? GetEntPropEnt(client, Prop_Send, "m_hGroundEntity") : -1;
}
stock int FindTeleOwner(int client) {
	int teleporter = GetGroundEntity(client);
	char classname[64];
	if( IsValidEntity(teleporter) && GetEdictClassname(teleporter, classname, sizeof(classname)) && !strcmp(classname, "obj_teleporter", false) ) {
		int owner = GetBuilder(teleporter);
		if( IsClientValid(owner) ) {
			return owner;
		}
	}
	return -1;
}

/// Props to Chdata!
stock void TeleportToSpawn(int client, int team=0) {
	int spawn = -1;
	ArrayList spawns = new ArrayList();
	while( (spawn = FindEntityByClassname(spawn, "info_player_teamspawn")) != -1 ) {
		if( GetEntProp(spawn, Prop_Data, "m_bDisabled") ) {
			continue; /// skip disabled spawns.
		} else if( team <= 1 || GetEntProp(spawn, Prop_Send, "m_iTeamNum")==team ) {
			spawns.Push(spawn);
		}
	}
	spawn = spawns.Get(GetRandomInt(0, spawns.Length - 1));
	delete spawns;
	
	/// Technically you'll never find a map without a spawn point. Not a good map at least.
	float vPos[3]; GetEntPropVector(spawn, Prop_Send, "m_vecOrigin",   vPos);
	float vAng[3]; GetEntPropVector(spawn, Prop_Send, "m_angRotation", vAng);
	TeleportEntity(spawn, vPos, vAng, NULL_VECTOR);
}

stock void DoExplosion(int owner, int damage, int radius, float pos[3]) {
	int explode = CreateEntityByName("env_explosion");
	if( !IsValidEntity(explode) ) {
		return;
	}
	
	DispatchKeyValue(explode, "targetname", "exploder");
	DispatchKeyValue(explode, "spawnflags", "4");
	DispatchKeyValue(explode, "rendermode", "5");
	
	SetEntPropEnt(explode, Prop_Data, "m_hOwnerEntity", owner);
	SetEntProp(explode, Prop_Data, "m_iMagnitude", damage);
	SetEntProp(explode, Prop_Data, "m_iRadiusOverride", radius);
	
	int team = GetClientTeam(owner);
	SetVariantInt(team); AcceptEntityInput(explode, "TeamNum");
	SetVariantInt(team); AcceptEntityInput(explode, "SetTeam");
	
	TeleportEntity(explode, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(explode);
	ActivateEntity(explode);
	AcceptEntityInput(explode, "Explode");
	AcceptEntityInput(explode, "Kill");
}

stock bool OnlyScoutsLeft(int team) {
	for( int i=1; i<=MaxClients; i++ ) {
		if( !IsClientValidExtra(i) || !IsPlayerAlive(i) ) {
			continue;
		} else if( GetClientTeam(i) == team && TF2_GetPlayerClass(i) != TFClass_Scout ) {
			return false;
		}
	}
	return true;
}
stock int GetLivingPlayers(int team) {
	int living = 0;
	for( int i=1; i<=MaxClients; i++ ) {
		if( IsClientValidExtra(i) && IsPlayerAlive(i) && GetClientTeam(i)==team ) {
			living++;
		}
	}
	return living;
}

stock void IncrementHeadCount(int client, bool addhealth=true, int addheads=1, int heal_amount=15) {
	/// Apply this condition to Demomen to give them their glowing eye effect.
	if( TF2_GetPlayerClass(client)==TFClass_DemoMan && !TF2_IsPlayerInCondition(client, TFCond_DemoBuff) ) {
		TF2_AddCondition(client, TFCond_DemoBuff, TFCondDuration_Infinite);
	}
	int decapitations = GetEntProp(client, Prop_Send, "m_iDecapitations");
	SetEntProp(client, Prop_Send, "m_iDecapitations", decapitations + addheads);
	if( addhealth ) {
		HealPlayer(client, heal_amount * addheads, true);
	}
	/// recalc their speed
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);
}
stock void SpawnSmallHealthPackAt(int client, int ownerteam=0) {
	if( !IsClientValidExtra(client) || !IsPlayerAlive(client) ) {
		return;
	}
	
	int healthpack = CreateEntityByName("item_healthkit_small");
	if( IsValidEntity(healthpack) ) {
		float pos[3]; GetClientAbsOrigin(client, pos);
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
}

/// Credit to Mecha the Slag
public void SickleClimbWalls(int client, int weapon, float upwardvel, float health, bool attackdelay) {
	if( !IsClientValidExtra(client) || (GetClientHealth(client) <= health) ) {
		return;
	}
	
	/// Get the position of the player's eyes
	float vecClientEyePos[3]; GetClientEyePosition(client, vecClientEyePos);
	
	/// Get the angle the player is looking
	float vecClientEyeAng[3]; GetClientEyeAngles(client, vecClientEyeAng);
	
	/// Check for colliding entities
	TR_TraceRayFilter(vecClientEyePos, vecClientEyeAng, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);
	if( !TR_DidHit() ) {
		return;
	}
	
	int traced_entity = TR_GetEntityIndex(null);
	char classname[64]; GetEdictClassname(traced_entity, classname, sizeof(classname));
	if( !StrEqual(classname, "worldspawn") ) {
		return;
	}
	
	float fNormal[3]; TR_GetPlaneNormal(null, fNormal);
	GetVectorAngles(fNormal, fNormal);
	
	if( (fNormal[0] >= 30.0 && fNormal[0] <= 330.0) || fNormal[0] <= -30.0 ) {
		return;
	}
	
	float pos[3]; TR_GetEndPosition(pos);
	float distance = GetVectorDistance(vecClientEyePos, pos, true);
	if( distance >= 100.0*100.0 ) {
		return;
	}
	
	float fVelocity[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
	fVelocity[2] = upwardvel;
	
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
	SDKHooks_TakeDamage(client, client, client, health, DMG_CLUB, GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));
	
	if( attackdelay ) {
		RequestFrame(NoAttacking, EntIndexToEntRef(weapon));
	}
}
public void NoAttacking(any wepref) {
	int weapon = EntRefToEntIndex(wepref);
	SetNextAttack(weapon, 1.56);
}
stock void SetNextAttack(int weapon, float duration = 0.0) {
	if( weapon <= MaxClients || !IsValidEntity(weapon) ) {
		return;
	}
	float next_time = GetGameTime() + duration;
	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack",   next_time);
	SetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack", next_time);
}
stock void ResetPlayer(int client) {
	TF2_RegeneratePlayer(client);
	SetEntityHealth( client, GetEntProp(client, Prop_Data, "m_iMaxHealth") );
	SetEntProp( client, Prop_Send, "m_iHealth", GetEntProp(client, Prop_Data, "m_iMaxHealth") );
}


/**
 * Wrapper function for easily setting up non-repeating timers
 *
 * @param func			Function pointer to call desired function when time elapses
 * @param thinktime		time in seconds when timer function will be called
 * @param param1		1st param for the call back function
 * @param param2		2nd param for the call back function
 *
 * @noreturn
 */

/**
If you need to use this and your function uses 3 parameters, modify it if necessary.
BUG/GLITCH: For some strange reason, SetPawnTimer doesn't work when u attempt to callback stock functions, interesting...
*/
stock void SetPawnTimer(Function func, float thinktime = 0.1, any param1 = -999, any param2 = -999) {
	DataPack thinkpack = new DataPack();
	thinkpack.WriteFunction(func);
	thinkpack.WriteCell(param1);
	thinkpack.WriteCell(param2);
	CreateTimer(thinktime, DoThink, thinkpack, TIMER_DATA_HNDL_CLOSE);
}

public Action DoThink(Handle t, DataPack pack) {
	pack.Reset();
	Function fn = pack.ReadFunction();
	Call_StartFunction(null, fn);
	
	any param = pack.ReadCell();
	if( param != -999 ) {
		Call_PushCell(param);
	}
	param = pack.ReadCell();
	if( param != -999 ) {
		Call_PushCell(param);
	}
	Call_Finish();
	return Plugin_Continue;
}

stock void ForceClientTeamChange(int client, int iTeam) {
	SetEntProp(client, Prop_Send, "m_lifeState", 2);
	ChangeClientTeam(client, iTeam);
	SetEntProp(client, Prop_Send, "m_lifeState", 0);
	TF2_RespawnPlayer(client);
}

stock float CalcBossHealth(float initial, int playing, float subtract, float exponent, float additional) {
	float initial_hp  = initial + playing;
	float player_iota = playing - subtract;
	float boss_hp     = Pow(initial_hp * player_iota, exponent);
	return boss_hp + additional;
}

stock void SetArenaCapEnableTime(float time) {
	int ent = -1;
	char time_str[32]; FloatToString(time, time_str, sizeof(time_str));
	if( (ent = FindEntityByClassname(-1, "tf_logic_arena")) != -1 ) {
		DispatchKeyValue(ent, "CapEnableDelay", time_str);
	}
}

stock void SetClientGlow(int client, float time1, float clampfl=0.0, float &glowtimer) {
	if( !IsClientValidExtra(client) ) {
		return;
	}
	glowtimer += time1;
	if( clampfl > 0.0 ) {
		glowtimer = clampfl;
	}
	
	SetEntProp(client, Prop_Send, "m_bGlowEnabled", glowtimer <= 0.0);
	if( glowtimer <= 0.0 ) {
		glowtimer = 0.0;
	}
}

stock void SetControlPoint(bool enable) {
	int CPm = -1;
	while( (CPm = FindEntityByClassname(CPm, "team_control_point")) != -1 ) {
		if( IsValidEntity(CPm) ) {
			AcceptEntityInput(CPm, (enable? "ShowModel" : "HideModel"));
			SetVariantInt(enable? 0 : 1);
			AcceptEntityInput(CPm, "SetLocked");
		}
	}
}

public void EnableCap(bool open_doors) {
	SetControlPoint(true);
	if( open_doors ) {
		int ent = -1;
		while( (ent = FindEntityByClassname(ent, "func_door")) != -1 ) {
			AcceptEntityInput(ent, "Open");
			AcceptEntityInput(ent, "Unlock");
		}
	}
}

stock bool CanFitHere(float origin[3], const float mins[3], const float maxs[3]) {
	for( int i; i < 200; i++ ) {
		TR_TraceHull(origin, origin, mins, maxs, MASK_PLAYERSOLID);
		if( TR_GetFraction() > 0.98 ) {
			return true;
		}
		origin[2] += 0.5;
	}
	return false;
}

stock int SpawnRandomPickups(int maxlimit, int minlimit, int chance, bool team_only, int team=VSH2Team_Red, const char[] item_name) {
	int spawn_entity = MaxClients+1;
	int spawned;
	while( (spawn_entity = FindEntityByClassname(spawn_entity, "info_player_teamspawn")) != -1 ) {
		if( spawned >= minlimit && GetRandomInt(0, chance) > 0 ) {
			continue;
		}
		if( spawned >= maxlimit ) {
			break;
		}
		
		/// Technically you'll never find a map without a spawn point.
		float vPos[3]; GetEntPropVector(spawn_entity, Prop_Send, "m_vecOrigin",   vPos);
		float vAng[3]; GetEntPropVector(spawn_entity, Prop_Send, "m_angRotation", vAng);
		int pickup = CreateEntityByName(item_name);
		TeleportEntity(pickup, vPos, vAng, NULL_VECTOR);
		DispatchSpawn(pickup);
		SetEntProp(pickup, Prop_Send, "m_iTeamNum", team_only? team : VSH2Team_Neutral, 4);
		spawned++;
	}
	return spawned;
}
stock int GetTeamPlayerCount(int team) {
	int count = 0;
	for( int i=1; i<=MaxClients; i++ ) {
		if( !IsClientValidExtra(i) || GetClientTeam(i)!=team ) {
			continue;
		}
		count++;
	}
	return count;
}
stock void GetTeamCounts(int[] teams) {
	for( int i=1; i<=MaxClients; i++ ) {
		if( !IsClientValidExtra(i) ) {
			continue;
		}
		teams[GetClientTeam(i)]++;
	}
}
stock int GetClientCloakIndex(int client) {
	if( !IsClientValidExtra(client) ) {
		return -1;
	}
	
	int wep = GetPlayerWeaponSlot(client, TFWeaponSlot_Building);
	if( !IsValidEntity(wep) ) {
		return -1;
	}
	
	//char classname[32]; GetEntityClassname(wep, classname, sizeof(classname));
	//if( !strncmp(classname, "tf_wea", 6, false) ) {
	return GetItemIndex(wep);
	//}
	//return -1;
}
stock int GetSlotFromWeapon(int iClient, int iWeapon) {
	for( int i; i < 5; i++ ) {
		if( iWeapon==GetPlayerWeaponSlot(iClient, i) ) {
			return i;
		}
	}
	return -1;
}
stock bool RemoveDemoShield(int iClient) {
	int numwearables = TF2_GetNumWearables(iClient);
	for( int i; i < numwearables; i++ ) {
		int wearable = TF2_GetWearable(iClient, i);
		if( wearable && !GetEntProp(wearable, Prop_Send, "m_bDisguiseWearable") ) {
			char cls[32];
			if( GetEntityClassname(wearable, cls, sizeof(cls)), !strncmp(cls, "tf_wearable_demo", 16, false) ) {
				TF2_RemoveWearable(iClient, wearable);
				return true; /// Returns true if Shield was removed...
			}
		}
	}
	return false; /// ...and returns False if one wasn't found.
}

stock bool RemoveRazorBack(int iClient) {
	int numwearables = TF2_GetNumWearables(iClient);
	for( int i; i < numwearables; i++ ) {
		int wearable = TF2_GetWearable(iClient, i);
		if( wearable && !GetEntProp(wearable, Prop_Send, "m_bDisguiseWearable") ) {
			char cls[32];
			if( GetEntityClassname(wearable, cls, sizeof(cls)), !strncmp(cls, "tf_wearable_razo", 16, false) ) {
				TF2_RemoveWearable(iClient, wearable);
				return true; /// Returns true if Shield was removed...
			}
		}
	}
	return false; /// ...and returns False if one wasn't found.
}

stock int GetShield(int client, const char[] wearable_name) {
	int numwearables = TF2_GetNumWearables(client);
	int name_len = strlen(wearable_name);
	for( int i; i < numwearables; i++ ) {
		int wearable = TF2_GetWearable(client, i);
		if( wearable > MaxClients && HasEntProp(wearable, Prop_Send, "m_bDisguiseWearable") && !GetEntProp(wearable, Prop_Send, "m_bDisguiseWearable") ) {
			char cls[64];
			if( GetEntityClassname(wearable, cls, sizeof(cls)), !strncmp(cls, wearable_name, name_len, false) ) {
				return wearable;
			}
		}
	}
	return -1;
}

stock void RemovePlayerBack(int client, const int[] indices, int len) {
	if( len <= 0 ) {
		return;
	}
	int numwearables = TF2_GetNumWearables(client);
	for( int i; i < numwearables; i++ ) {
		int wearable = TF2_GetWearable(client, i);
		if( wearable && !GetEntProp(wearable, Prop_Send, "m_bDisguiseWearable") ) {
			int idx = GetItemIndex(wearable);
			for( int u; u < len; u++ ) {
				if( idx==indices[u] ) {
					TF2_RemoveWearable(client, wearable);
					break;
				}
			}
		}
	}
}
stock int FindPlayerBack(int client, const int[] indices, int len) {
	if( len <= 0 ) {
		return -1;
	}
	int numwearables = TF2_GetNumWearables(client);
	for( int i; i < numwearables; i++ ) {
		int wearable = TF2_GetWearable(client, i);
		if( wearable && !GetEntProp(wearable, Prop_Send, "m_bDisguiseWearable") ) {
			int idx = GetItemIndex(wearable);
			for( int u; u < len; u++ ) {
				if( idx==indices[u] ) {
					return wearable;
				}
			}
		}
	}
	return -1;
}
stock bool PlayerHasItem(int client, int item_def) {
	if( !IsClientValid(client) ) {
		return false;
	}
	
	for( int i; i < 5; i++ ) {
		int entity = GetPlayerWeaponSlot(client, i);
		if( GetItemIndex(entity)==item_def ) {
			return true;
		}
	}
	
	int numwearables = TF2_GetNumWearables(client);
	for( int i; i < numwearables; i++ ) {
		int wearable = TF2_GetWearable(client, i);
		if( IsValidEntity(wearable) && !GetEntProp(wearable, Prop_Send, "m_bDisguiseWearable") ) {
			if( GetItemIndex(wearable)==item_def ) {
				return true;
			}
		}
	}
	return false;
}

stock int FindSentry(int client) {
	int i = -1;
	while( (i = FindEntityByClassname(i, "obj_sentrygun")) != -1 ) {
		if( GetEntPropEnt(i, Prop_Send, "m_hBuilder") == client ) {
			return i;
		}
	}
	return -1;
}

stock bool TF2_IsPlayerCritBuffed(int client) {
	return( TF2_IsPlayerInCondition(client, TFCond_Kritzkrieged)
			|| TF2_IsPlayerInCondition(client, TFCond_HalloweenCritCandy)
			|| TF2_IsPlayerInCondition(client, view_as< TFCond >(34))
			|| TF2_IsPlayerInCondition(client, view_as< TFCond >(35))
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnFirstBlood)
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnWin)
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnFlagCapture)
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnKill)
			|| TF2_IsPlayerInCondition(client, TFCond_CritMmmph)
			);
}

stock void OverNineThousand() {
	EmitSoundToAll("saxton_hale/9000.wav");
	EmitSoundToAll("saxton_hale/9000.wav");
}

public void _NoHonorBound(int userid) {
	int client = GetClientOfUserId(userid);
	if( IsClientValidExtra(client) && IsPlayerAlive(client) ) {
		int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		int index = GetItemIndex(weapon);
		int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		char classname[32];
		if( IsValidEntity(active) ) {
			GetEdictClassname(active, classname, sizeof(classname));
		}
		if( index == 357 && active == weapon && !strcmp(classname, "tf_weapon_katana", false) ) {
			SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
			if( GetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy") < 1 ) {
				SetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
			}
		}
	}
}
stock int GetMaxAmmo(int client, int slot) {
	if( !IsClientValidExtra(client) ) {
		return 0;
	}
	
	int weapon = GetPlayerWeaponSlot(client, slot);
	if( IsValidEntity(weapon) ) {
		switch( slot ) {
			case TFWeaponSlot_Primary: return GetEntData(client, FindDataMapInfo(client, "m_iAmmo")+4);
			case TFWeaponSlot_Secondary: return GetEntData(client, FindDataMapInfo(client, "m_iAmmo")+8);
			case TFWeaponSlot_Melee: return GetEntData(client, FindDataMapInfo(client, "m_iAmmo")+12);
		}
	}
	return 0;
}
stock bool IsWeaponSlotActive(int client, int slot) {
	return GetPlayerWeaponSlot(client, slot) == GetActiveWep(client);
}
public void _StopTickle(int userid) {
	int client = GetClientOfUserId(userid);
	if( !IsClientValidExtra(client) || !IsPlayerAlive(client) )
		return;

	if( !GetEntProp(client, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(client, Prop_Send, "m_hHighFivePartner")) )
		TF2_RemoveCondition(client, TFCond_Taunting);
}
stock bool MapHasMusic(bool forceRecalc=false) {
	static bool hasMusic;
	static bool found = false;
	if( forceRecalc ) {
		found = false;
		hasMusic = false;
	}
	if( !found ) {
		int i = -1;
		char name[64];
		while( (i = FindEntityByClassname(i, "info_target")) != -1 ) {
			GetEntPropString(i, Prop_Data, "m_iName", name, sizeof(name));
			if( !strcmp(name, "hale_no_music", false) ) {
				hasMusic = true;
			}
		}
		found = true;
	}
	return hasMusic;
}
stock bool IsValidAdmin(int client, const char[] flags) {
	if( !IsClientInGame(client) ) {
		return false;
	}
	int ibFlags = ReadFlagString(flags);
	if( !StrEqual(flags, "") ) {
		if( (GetUserFlagBits(client) & ibFlags)==ibFlags ) {
			return true;
		}
	}
	if( GetUserFlagBits(client) & ADMFLAG_ROOT ) {
		return true;
	}
	return false;
}
stock int AttachProjectileModel(int entity, const char[] strModel, const char[] strAnim = "") {
	if( !IsValidEntity(entity) ) {
		return -1;
	}
	
	int model = CreateEntityByName("prop_dynamic");
	if( !IsValidEntity(model) ) {
		LogError("(AttachProjectileModel): Could not create prop_dynamic");
		return -1;
	}
	
	float pos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin",   pos);
	float ang[3]; GetEntPropVector(entity, Prop_Send, "m_angRotation", ang);
	TeleportEntity(model, pos, ang, NULL_VECTOR);
	DispatchKeyValue(model, "model", strModel);
	DispatchSpawn(model);
	SetVariantString("!activator");
	AcceptEntityInput(model, "SetParent", entity, model, 0);
	if( strAnim[0] != '\0' ) {
		SetVariantString(strAnim);
		AcceptEntityInput(model, "SetDefaultAnimation");
		SetVariantString(strAnim);
		AcceptEntityInput(model, "SetAnimation");
	}
	SetEntPropEnt(model, Prop_Send, "m_hOwnerEntity", entity);
	return model;
}

stock bool GetRandomBool() {
	return view_as< bool >( GetRandomInt(0, 1) );
}
stock int GetRandomIntEven(int min, int max) {
	return GetRandomInt(min, max) * 2;
}
stock int GetRandomIntOdd(int min, int max) {
	return GetRandomIntEven(min, max) + 1;
}

stock void SetAmmo(int client, int slot, int ammo) {
	int weapon = GetPlayerWeaponSlot(client, slot);
	if( !IsValidEntity(weapon) ) {
		return;
	}
	int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
	int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
	SetEntData(client, iAmmoTable+iOffset, ammo, 4, true);
}
stock void SetClip(int client, int slot, int ammo) {
	int weapon = GetPlayerWeaponSlot(client, slot);
	if( !IsValidEntity(weapon) ) {
		return;
	}
	int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
	SetEntData(weapon, iAmmoTable, ammo, 4, true);
}
stock int GetAmmo(int client, int slot) {
	if( !IsClientValidExtra(client) ) {
		return 0;
	}
	
	int weapon = GetPlayerWeaponSlot(client, slot);
	if( !IsValidEntity(weapon) ) {
		return 0;
	}
	
	int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
	int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
	return GetEntData(client, iAmmoTable+iOffset);
}

stock int GetClip(int client, int slot) {
	int weapon = GetPlayerWeaponSlot(client, slot);
	if( !IsValidEntity(weapon) ) {
		return 0;
	}
	int AmmoClipTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
	return GetEntData(weapon, AmmoClipTable);
}

stock void _SetCapOwner(int iCapTeam, bool open_doors, float flEnableTime = 30.0) {
	int i = -1;
	int cap_master = FindEntityByClassname(-1, "team_control_point_master");
	while( (i = FindEntityByClassname(i, "team_control_point")) != -1 ) {
		/// Adapted from Arena:Respawn
		if( IsValidEntity(i) ) {
			SetVariantInt(iCapTeam);
			/// Must have team_control_point_master as the activator, less it will just ignore the Input
			AcceptEntityInput(i, "SetOwner", -1, cap_master);
			SetVariantInt(1);
			AcceptEntityInput(i, "SetLocked");
			SetPawnTimer(EnableCap, flEnableTime, open_doors);
		}
	}
}
stock bool StrStarts(const char[] szStr, const char[] szSubStr, bool bCaseSensitive = true) {
	return !StrContains(szStr, szSubStr, bCaseSensitive);
}
stock bool ValidateName(const char[] name) {
	int length = strlen(name);
	for( int i; i < length; i++ ) {
		int holder = name[i];
		/// Invalid name, names may only contains numbers, underscores, and normal letters.
		if( !(IsCharAlpha(holder) || IsCharNumeric(holder) || holder=='_') ) {
			return false;
		}
	}
	/// A name is, of course, only valid if it's 1 or more chars long, though longer is recommended
	return length > 0;
}

/// Thx Pelipoika
stock int GetHealerByIndex(int client, int index) {
	int m_aHealers   = FindSendPropInfo("CTFPlayer", "m_nNumHealers") + 12;
	Address m_Shared = GetEntityAddress(client) + view_as< Address >(m_aHealers);
	Address aHealers = view_as< Address >(LoadFromAddress(m_Shared, NumberType_Int32));
	return (LoadFromAddress(aHealers + view_as< Address >(index * 0x24), NumberType_Int32) & 0xFFF);
}

stock float GetConditionDuration(int client, TFCond cond) {
	if( !TF2_IsPlayerInCondition(client, cond) ) {
		return 0.0;
	}
	
	int m_Shared = FindSendPropInfo("CTFPlayer", "m_Shared");
	Address aCondSource   = view_as< Address >(LoadFromAddress(GetEntityAddress(client) + view_as< Address >(m_Shared + 8), NumberType_Int32));
	Address aCondDuration = view_as< Address >(view_as< int >(aCondSource) + (view_as< int >(cond) * 20) + (2 * 4));
	
	float flDuration = view_as< float >(LoadFromAddress(aCondDuration, NumberType_Int32));
	return flDuration;
}

stock void SetConditionDuration(int client, TFCond cond, float duration) {
	if( !TF2_IsPlayerInCondition(client, cond) ) {
		return;
	}
	
	int m_Shared = FindSendPropInfo("CTFPlayer", "m_Shared");
	Address aCondSource   = view_as< Address >(LoadFromAddress(GetEntityAddress(client) + view_as< Address >(m_Shared + 8), NumberType_Int32));
	Address aCondDuration = view_as< Address >(view_as< int >(aCondSource) + (view_as< int >(cond) * 20) + (2 * 4));
	StoreToAddress(aCondDuration, view_as< int >(duration), NumberType_Int32);
}

enum {
	TF_AMMO_DUMMY = 0,    /// Dummy index to make the CAmmoDef indices correct for the other ammo types.
	TF_AMMO_PRIMARY,
	TF_AMMO_SECONDARY,
	TF_AMMO_METAL,
	TF_AMMO_GRENADES1,
	TF_AMMO_GRENADES2,
	TF_AMMO_COUNT
};
stock void SetAmmoPackData(int pack, int type, int val) {
	int offset = ((type * 4) + (FindDataMapInfo(pack, "m_vOriginalSpawnAngles") + 20));
	SetEntData(pack, offset, val, _, true);
}
stock void PrepareSoundDir(bool valve = false, char[] dir = "sound") {
	DirectoryListing l = OpenDirectory(dir, valve);
	char buffer[PLATFORM_MAX_PATH];
	FileType type;
	int len;
	l.GetNext(buffer, sizeof(buffer));
	
	while( l.GetNext(buffer, sizeof(buffer), type) ) {
		if( buffer[0] == '\0' || !strcmp(buffer, ".", false) || !strcmp(buffer, "..", false) ) {
			continue;
		}
		
		if( type==FileType_Directory ) {
			Format(buffer, PLATFORM_MAX_PATH, "%s/%s", dir, buffer);
			PrepareSoundDir(valve, buffer);
		} else if( type==FileType_File ) {
			/// .mp3, .wav, etc
			if( (len = strlen(buffer)) < 5 ) {
				continue;
			}
			
			/// Don't think TF2 supports .ogg but w/e
			if( StrContains(buffer[len-4], ".mp3") == -1 && StrContains(buffer[len-4], ".wav") == -1 && StrContains(buffer[len-4], ".ogg") == -1 ) {
				continue;
			}
			
			Format(buffer, sizeof(buffer), "%s/%s", dir, buffer);
			AddFileToDownloadsTable(buffer);
			
			/// Offsets 'sound/'
			PrecacheSound(buffer[6]);
		}
	}
	delete l;
}
stock void PrepareModelDir(bool valve=false, const char[] dir="models") {
	DirectoryListing l = OpenDirectory(dir, valve);
	char buffer[PLATFORM_MAX_PATH];
	FileType type;
	l.GetNext(buffer, sizeof(buffer));
	while( l.GetNext(buffer, sizeof(buffer), type) ) {
		if( buffer[0] == '\0' || !strcmp(buffer, ".", false) || !strcmp(buffer, "..", false) ) {
			continue;
		}
		
		if( type==FileType_Directory ) {
			Format(buffer, PLATFORM_MAX_PATH, "%s/%s", dir, buffer);
			PrepareModelDir(valve, buffer);
		} else if( type==FileType_File ) {
			if( strlen(buffer) < 5 ) {
				continue;
			}
			
			if( StrContains(buffer, ".dx80.vtx") == -1 && StrContains(buffer, ".dx90.vtx") == -1 && StrContains(buffer, ".mdl") == -1
			 && StrContains(buffer, ".phy") == -1 && StrContains(buffer, ".sw.vtx") == -1 && StrContains(buffer, ".vvd") == -1 ) {
				continue;
			}
			Format(buffer, sizeof(buffer), "%s/%s", dir, buffer);
			AddFileToDownloadsTable(buffer);
			if( StrContains(buffer, ".mdl", false) != -1 && !IsModelPrecached(buffer) ) {
				PrecacheModel(buffer);
			}
		}
	}
	delete l;
}
stock void PrepareMaterialDir(bool valve = false, char[] dir = "materials") {
	DirectoryListing l = OpenDirectory(dir, valve);
	char buffer[PLATFORM_MAX_PATH];
	FileType type;
	l.GetNext(buffer, sizeof(buffer));
	
	while( l.GetNext(buffer, sizeof(buffer), type) ) {
		if( buffer[0] == '\0' || !strcmp(buffer, ".", false) || !strcmp(buffer, "..", false) ) {
			continue;
		}
		
		if( type==FileType_Directory ) {
			Format(buffer, PLATFORM_MAX_PATH, "%s/%s", dir, buffer);
			PrepareMaterialDir(valve, buffer);
		} else if( type==FileType_File ) {
			if( strlen(buffer) < 5 ) {
				continue;
			} else if( StrContains(buffer, ".vmt") == -1 && StrContains(buffer, ".vtf") == -1 ) {
				continue;
			}
			Format(buffer, sizeof(buffer), "%s/%s", dir, buffer);
			AddFileToDownloadsTable(buffer);
		}
	}
	delete l;
}
stock char[] TF2_GetPlayerClassname(int client, bool capitalize=false) {
	char s[16];
	switch( TF2_GetPlayerClass(client) ) {
		case TFClass_Scout:    s = "scout";
		case TFClass_Soldier:  s = "soldier";
		case TFClass_Pyro:     s = "pyro";
		case TFClass_DemoMan:  s = "demoman";
		case TFClass_Medic:    s = "medic";
		case TFClass_Heavy:    s = "heavy";
		case TFClass_Spy:      s = "spy";
		case TFClass_Engineer: s = "engineer";
	}
	
	if( capitalize ) {
		s[0] = CharToUpper(s[0]);
	}
	return s;
}
stock int FindMatchingTeleporter(int tele) {
	if( !HasEntProp(tele, Prop_Send, "m_bMatchBuilding") ) {
		return 0;
	}
	int offset = FindSendPropInfo("CObjectTeleporter", "m_bMatchBuilding")+4;
	return GetEntDataEnt2(tele, offset);
}
stock bool TF2_IsKillable(int entity) {
	if( 0 < entity <= MaxClients ) {
		if(TF2_IsPlayerInCondition(entity, TFCond_Ubercharged)
		|| TF2_IsPlayerInCondition(entity, TFCond_UberchargedHidden)
		|| TF2_IsPlayerInCondition(entity, TFCond_UberchargedCanteen)
		|| TF2_IsPlayerInCondition(entity, TFCond_Bonked)
		|| TF2_IsPlayerInCondition(entity, TFCond_PasstimeInterception)) {
			return false;
		}
	}
	if( GetEntProp(entity, Prop_Data, "m_takedamage") != 2 ) {
		return false;
	}
	return true;
}

stock void SetMetal(int client, int amount) {
	int iMetalTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
	SetEntData(client, iMetalTable + (4*3), amount, 4, true);
}

stock void SetActiveWep(int client, int wep) {
	if( !IsValidEntity(wep) ) {
		return;
	}
	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", wep);
}

stock int GetRandomClient(bool balive=true, int team=0) {
	int[] players = new int[MaxClients];
	int count;
	for( int i=1; i<=MaxClients; i++ ) {
		if( !IsClientValidExtra(i) || (balive && !IsPlayerAlive(i)) ) {
			continue;
		} else if( team && GetClientTeam(i) != team ) {
			continue;
		}
		players[count++] = i;
	}
	return !count? -1 : players[GetRandomInt(0, count-1)];
}

stock int GetThrower(int ent) {
	return IsValidEntity(ent)? GetEntPropEnt(ent, Prop_Send, "m_hThrower") : -1;
}

stock void HealPlayer(int client, int health, bool on_hud=false, bool overridehp=false, int overheal_limit=0) {
	int hp    = GetEntProp(client, Prop_Data, "m_iHealth");
	int maxhp = GetEntProp(client, Prop_Data, "m_iMaxHealth");
	int diff  = health;
	
	int max_overheal = RoundFloat(FindConVar("tf_max_health_boost").FloatValue * maxhp);
	if( !overridehp && diff > max_overheal - hp ) {
		diff = max_overheal - hp;
	}
	if( overridehp && overheal_limit > 0 ) {
		if( diff > overheal_limit - hp ) {
			diff = overheal_limit - hp;
		}
	}
	
	if( diff > 0 ) {
		SetEntityHealth(client, hp + diff);
		if( on_hud ) {
			Event event = CreateEvent("player_healonhit");
			if( event != null ) {
				event.SetInt("amount", diff);
				event.SetInt("entindex", client);
				event.FireToClient(client);
				event.Cancel();
			}
		}
	}
}

stock int TF2_GetNumWearables(int client) {
	/// 3552 linux
	/// 3532 windows
	int offset = FindSendPropInfo("CTFPlayer", "m_flMaxspeed") - 20 + 12;
	return GetEntData(client, offset);
}

stock int TF2_GetWearable(int client, int wearableidx) {
	/// 3540 linux
	/// 3520 windows
	int offset = FindSendPropInfo("CTFPlayer", "m_flMaxspeed") - 20;
	Address client_offs = GetEntityAddress(client) + view_as< Address >(offset);
	Address m_hMyWearables = view_as< Address >( LoadFromAddress(client_offs, NumberType_Int32) );
	return LoadFromAddress(m_hMyWearables + view_as< Address >(4 * wearableidx), NumberType_Int32) & 0xFFF;
}

stock int GetDeadRingerStatus(int client) {
	if( TF2_IsPlayerInCondition(client, TFCond_Cloaked) ) {
		return 2;
	}
	return GetEntProp(client, Prop_Send, "m_bFeignDeathReady")? 1 : 0;
}
stock void SpawnManyAmmoPacks(int client, const char[] model, int skin=0, int num=14, float offsz=30.0, int team=VSH2Team_Red) {
	float pos[3], vel[3], ang[3];
	ang[0] = 90.0;
	ang[1] = 0.0;
	ang[2] = 0.0;
	GetClientAbsOrigin(client, pos);
	pos[2] += offsz;
	for( int i=0; i < num; i++ ) {
		vel[0]  = GetRandomFloat(-400.0, 400.0);
		vel[1]  = GetRandomFloat(-400.0, 400.0);
		vel[2]  = GetRandomFloat(300.0, 500.0);
		pos[0] += GetRandomFloat(-5.0, 5.0);
		pos[1] += GetRandomFloat(-5.0, 5.0);
		
		int ent = CreateEntityByName("tf_ammo_pack");
		if( !IsValidEntity(ent) ) {
			continue;
		}
		
		SetEntityModel(ent, model);
		DispatchKeyValue(ent, "OnPlayerTouch", "!self,Kill,,0,-1"); /// for safety, but it shouldn't act like a normal ammopack
		SetEntProp(ent, Prop_Send, "m_nSkin", skin);
		SetEntProp(ent, Prop_Send, "m_nSolidType", 6);
		SetEntProp(ent, Prop_Send, "m_usSolidFlags", 152);
		SetEntProp(ent, Prop_Send, "m_triggerBloat", 24);
		SetEntProp(ent, Prop_Send, "m_CollisionGroup", 1);
		SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(ent, Prop_Send, "m_iTeamNum", team);
		TeleportEntity(ent, pos, ang, vel);
		DispatchSpawn(ent);
		TeleportEntity(ent, pos, ang, vel);
		SetEntProp(ent, Prop_Data, "m_iHealth", 900);
		int offs = GetEntSendPropOffs(ent, "m_vecInitialVelocity", true);
		SetEntData(ent, offs-4, 1, _, true);
	}
}

stock void SecondsToTime(int time, char strTime[10]) {
	int minutes = time / 60;
	if( minutes > 9 ) {
		IntToString(minutes, strTime, 6);
	} else {
		Format(strTime, sizeof(strTime), "0%i", minutes);
	}
	int seconds_part = time % 60;
	Format(strTime, sizeof(strTime), ( seconds_part > 9 )? "%s:%i" : "%s:0%i", strTime, seconds_part);
}


stock bool IsValidPlugin(Handle plugin) {
	PluginIterator iter = new PluginIterator();
	bool res = false;
	while( iter.Next() && !res ) {
		res = iter.Plugin==plugin;
	}
	delete iter;
	return res;
}

stock bool UpdatePluginHandle(Handle &plugin, const char[] name) {
	PluginIterator iter = new PluginIterator();
	bool res = false;
	while( iter.Next() && !res ) {
		Handle pl = iter.Plugin;
		if( plugin==pl ) {
			/// plugin is valid, no need to update.
			res = true;
			break;
		}
		
		char pl_name[PLATFORM_MAX_PATH];
		GetPluginFilename(pl, pl_name, sizeof(pl_name));
		if( !StrEqual(name, pl_name) ) {
			/// not the same.
			continue;
		}
		plugin = pl;
		res = true;
	}
	delete iter;
	return res;
}