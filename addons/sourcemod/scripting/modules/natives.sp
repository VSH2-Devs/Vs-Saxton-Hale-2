public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("VSH2_RegisterPlugin",             Native_RegisterBoss);
	CreateNative("VSH2_Hook",                       Native_Hook);
	CreateNative("VSH2_HookEx",                     Native_HookEx);
	
	CreateNative("VSH2_Unhook",                     Native_Unhook);
	CreateNative("VSH2_UnhookEx",                   Native_UnhookEx);
	CreateNative("VSH2_GetRandomBossType",          Native_GetRandomBossType);
	CreateNative("VSH2_GetBossIDs",                 Native_GetBossIDs);
	CreateNative("VSH2_GetBossID",                  Native_GetBossID);
	CreateNative("VSH2_GetBossNameByIndex",         Native_GetBossNameByIndex);
	CreateNative("VSH2_StopMusic",                  Native_StopMusic);
	CreateNative("VSH2_GetConfigMap",               Native_GetMainConfig);
	
	CreateNative("VSH2Player.VSH2Player",           Native_VSH2Instance);
	
	CreateNative("VSH2Player.userid.get",           Native_VSH2GetUserid);
	CreateNative("VSH2Player.index.get",            Native_VSH2GetIndex);
	
	CreateNative("VSH2Player.GetProperty",          Native_VSH2_getProperty);
	CreateNative("VSH2Player.SetProperty",          Native_VSH2_setProperty);
	
	/// type safe versions of VSH2Player::GetProperty & VSH2Player::SetProperty.
	CreateNative("VSH2Player.GetPropInt",           Native_VSH2_getIntProp);
	CreateNative("VSH2Player.GetPropFloat",         Native_VSH2_getFloatProp);
	CreateNative("VSH2Player.GetPropAny",           Native_VSH2_getProperty);
	
	CreateNative("VSH2Player.SetPropInt",           Native_VSH2_setIntProp);
	CreateNative("VSH2Player.SetPropFloat",         Native_VSH2_setFloatProp);
	CreateNative("VSH2Player.SetPropAny",           Native_VSH2_setProp);
	
	/// VSH2 Fighter Methods
	CreateNative("VSH2Player.ConvertToMinion",      Native_VSH2_ConvertToMinion);
	CreateNative("VSH2Player.SpawnWeapon",          Native_VSH2_SpawnWep);
	CreateNative("VSH2Player.GetWeaponSlotIndex",   Native_VSH2_GetWeaponSlotIndex);
	CreateNative("VSH2Player.SetWepInvis",          Native_VSH2_SetWepInvis);
	CreateNative("VSH2Player.SetOverlay",           Native_VSH2_SetOverlay);
	CreateNative("VSH2Player.TeleToSpawn",          Native_VSH2_TeleToSpawn);
	CreateNative("VSH2Player.IncreaseHeadCount",    Native_VSH2_IncreaseHeadCount);
	CreateNative("VSH2Player.SpawnSmallHealthPack", Native_VSH2_SpawnSmallHealthPack);
	CreateNative("VSH2Player.ForceTeamChange",      Native_VSH2_ForceTeamChange);
	CreateNative("VSH2Player.ClimbWall",            Native_VSH2_ClimbWall);
	CreateNative("VSH2Player.HelpPanelClass",       Native_VSH2_HelpPanelClass);
	CreateNative("VSH2Player.GetAmmoTable",         Native_VSH2_GetAmmoTable);
	CreateNative("VSH2Player.SetAmmoTable",         Native_VSH2_SetAmmoTable);
	CreateNative("VSH2Player.GetClipTable",         Native_VSH2_GetClipTable);
	CreateNative("VSH2Player.SetClipTable",         Native_VSH2_SetClipTable);
	CreateNative("VSH2Player.GetHealTarget",        Native_VSH2_GetHealTarget);
	CreateNative("VSH2Player.IsNearDispenser",      Native_VSH2_IsNearDispenser);
	CreateNative("VSH2Player.IsInRange",            Native_VSH2_IsInRange);
	CreateNative("VSH2Player.RemoveBack",           Native_VSH2_RemoveBack);
	CreateNative("VSH2Player.FindBack",             Native_VSH2_FindBack);
	CreateNative("VSH2Player.ShootRocket",          Native_VSH2_ShootRocket);
	CreateNative("VSH2Player.Heal",                 Native_VSH2_Heal);
	CreateNative("VSH2Player.AddTempAttrib",        Native_VSH2_AddTempAttrib);
	
	/// VSH2 Boss Methods
	CreateNative("VSH2Player.ConvertToBoss",        Native_VSH2_ConvertToBoss);
	CreateNative("VSH2Player.GiveRage",             Native_VSH2_GiveRage);
	CreateNative("VSH2Player.MakeBossAndSwitch",    Native_VSH2_MakeBossAndSwitch);
	CreateNative("VSH2Player.DoGenericStun",        Native_VSH2_DoGenericStun);
	CreateNative("VSH2Player.StunPlayers",          Native_VSH2_StunPlayers);
	CreateNative("VSH2Player.StunBuildings",        Native_VSH2_StunBuildings);
	CreateNative("VSH2Player.RemoveAllItems",       Native_VSH2_RemoveAllItems);
	CreateNative("VSH2Player.GetName",              Native_VSH2_GetName);
	CreateNative("VSH2Player.SetName",              Native_VSH2_SetName);
	CreateNative("VSH2Player.SuperJump",            Native_VSH2_SuperJump);
	CreateNative("VSH2Player.WeighDown",            Native_VSH2_WeighDown);
	CreateNative("VSH2Player.PlayVoiceClip",        Native_VSH2_PlayVoiceClip);
	CreateNative("VSH2Player.PlayMusic",            Native_VSH2_PlayMusic);
	CreateNative("VSH2Player.StopMusic",            Native_VSH2_StopMusic);
	
	/// VSH2 Game Mode Managers Methods
	CreateNative("VSH2GameMode_GetProperty",        Native_VSH2GameMode_GetProperty);
	CreateNative("VSH2GameMode_SetProperty",        Native_VSH2GameMode_SetProperty);
	
	CreateNative("VSH2GameMode_FindNextBoss",       Native_VSH2GameMode_FindNextBoss);
	CreateNative("VSH2GameMode_GetRandomBoss",      Native_VSH2GameMode_GetRandomBoss);
	CreateNative("VSH2GameMode_GetBossByType",      Native_VSH2GameMode_GetBossByType);
	CreateNative("VSH2GameMode_CountMinions",       Native_VSH2GameMode_CountMinions);
	CreateNative("VSH2GameMode_CountBosses",        Native_VSH2GameMode_CountBosses);
	CreateNative("VSH2GameMode_GetTotalBossHealth", Native_VSH2GameMode_GetTotalBossHealth);
	CreateNative("VSH2GameMode_SearchForItemPacks", Native_VSH2GameMode_SearchForItemPacks);
	CreateNative("VSH2GameMode_UpdateBossHealth",   Native_VSH2GameMode_UpdateBossHealth);
	CreateNative("VSH2GameMode_GetBossType",        Native_VSH2GameMode_GetBossType);
	CreateNative("VSH2GameMode_GetTotalRedPlayers", Native_VSH2GameMode_GetTotalRedPlayers);
	CreateNative("VSH2GameMode_GetHUDHandle",       Native_VSH2GameMode_GetHUDHandle);
	CreateNative("VSH2GameMode_GetBosses",          Native_VSH2GameMode_GetBosses);
	CreateNative("VSH2GameMode_IsVSHMap",           Native_VSH2GameMode_IsVSHMap);
	CreateNative("VSH2GameMode_GetFighters",        Native_VSH2GameMode_GetFighters);
	CreateNative("VSH2GameMode_GetMinions",         Native_VSH2GameMode_GetMinions);
	CreateNative("VSH2GameMode_GetQueue",           Native_VSH2GameMode_GetQueue);
	CreateNative("VSH2GameMode_GetBossesByType",    Native_VSH2GameMode_GetBossesByType);
	
	CreateNative("VSH2_GetMaxBosses",               Native_VSH2_GetMaxBosses);
#if defined _steamtools_included
	MarkNativeAsOptional("Steam_SetGameDescription");
#endif
	
#if defined _tf2attributes_included
	MarkNativeAsOptional("TF2Attrib_SetByDefIndex");
	MarkNativeAsOptional("TF2Attrib_RemoveByDefIndex");
#endif
	RegPluginLibrary("VSH2");
	return APLRes_Success;
}

public int Native_RegisterBoss(Handle plugin, int numParams)
{
	char module_name[MAX_BOSS_NAME_SIZE]; GetNativeString(1, module_name, sizeof(module_name));
	bool red_only = GetNativeCell(2);
	/// ALL PROPS TO COOKIES.NET AKA COOKIES.IO
	return RegisterBoss(plugin, module_name, red_only);
}

public any Native_VSH2Instance(Handle plugin, int numParams)
{
	BaseBoss player = BaseBoss(GetNativeCell(1), GetNativeCell(2));
	return player;
}

public int Native_VSH2GetUserid(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.userid;
}
public int Native_VSH2GetIndex(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.index;
}

public any Native_VSH2_getProperty(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	if( StrEqual(prop_name, "iHealth") ) {
		return player.iHealth;
	} else if( StrEqual(prop_name, "iQueue") ) {
		return player.iQueue;
	} else if( StrEqual(prop_name, "bIsBoss") || StrEqual(prop_name, "bSetOnSpawn") ) {
		return player.iBossType >= 0;
	}
	any item;
	if( !g_vsh2.m_hPlayerFields[player.index].GetValue(prop_name, item) ) {
		LogError("VSH2 VSH2Player.GetPropAny :: missing prop '%s'", prop_name);
	}
	return item;
}
public int Native_VSH2_setProperty(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	any item = GetNativeCell(3);
	if( StrEqual(prop_name, "iHealth") ) {
		player.iHealth = view_as< int >(item);
	} else if( StrEqual(prop_name, "iQueue") ) {
		player.iQueue = view_as< int >(item);
	}
	else g_vsh2.m_hPlayerFields[player.index].SetValue(prop_name, item);
	return 0;
}

public int Native_VSH2_getIntProp(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	if( StrEqual(prop_name, "iHealth") ) {
		return player.iHealth;
	} else if( StrEqual(prop_name, "iQueue") ) {
		return player.iQueue;
	} else if( StrEqual(prop_name, "bIsBoss") || StrEqual(prop_name, "bSetOnSpawn") ) {
		return player.iBossType >= 0;
	}
	int item;
	if( !g_vsh2.m_hPlayerFields[player.index].GetValue(prop_name, item) ) {
		LogError("VSH2 VSH2Player.GetIntProp :: missing prop '%s'", prop_name);
	}
	return item;
}
public int Native_VSH2_setIntProp(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	int item = GetNativeCell(3);
	if( StrEqual(prop_name, "iHealth") ) {
		player.iHealth = item;
		return true;
	} else if( StrEqual(prop_name, "iQueue") ) {
		player.iQueue = item;
		return true;
	} else if( StrEqual(prop_name, "bIsBoss") || StrEqual(prop_name, "bSetOnSpawn") ) {
		return false;
	}
	return g_vsh2.m_hPlayerFields[player.index].SetValue(prop_name, item);
}

public any Native_VSH2_getFloatProp(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	float item;
	if( !g_vsh2.m_hPlayerFields[player.index].GetValue(prop_name, item) ) {
		LogError("VSH2 VSH2Player.GetFloatProp :: missing prop '%s'", prop_name);
	}
	return item;
}
public int Native_VSH2_setFloatProp(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	float item = GetNativeCell(3);
	return g_vsh2.m_hPlayerFields[player.index].SetValue(prop_name, item);
}

public int Native_VSH2_setProp(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char prop_name[64]; GetNativeString(2, prop_name, 64);
	any item = GetNativeCell(3);
	if( StrEqual(prop_name, "iHealth") ) {
		SetEntityHealth(player.index, view_as< int >(item));
		return true;
	} else if( StrEqual(prop_name, "iQueue") ) {
		player.iQueue = view_as< int >(item);
		return true;
	} else if( StrEqual(prop_name, "bIsBoss") || StrEqual(prop_name, "bSetOnSpawn") ) {
		return false;
	}
	return g_vsh2.m_hPlayerFields[player.index].SetValue(prop_name, item);
}

public int Native_Hook(Handle plugin, int numParams)
{
	bool is_boss_module = g_modsys.IsPluginABoss(plugin);
	int vsh2Hook = GetNativeCell(1);
	Function func = GetNativeFunction(2);
	PrivateForward pw = g_modsys.GetPrivFwd(is_boss_module, vsh2Hook);
	if( pw != null )
		pw.AddFunction(plugin, func);
	return 0;
}

public int Native_HookEx(Handle plugin, int numParams)
{
	bool is_boss_module = g_modsys.IsPluginABoss(plugin);
	int vsh2Hook = GetNativeCell(1);
	Function func = GetNativeFunction(2);
	PrivateForward pw = g_modsys.GetPrivFwd(is_boss_module, vsh2Hook);
	if( pw != null )
		return pw.AddFunction(plugin, func);
	return false;
}

public int Native_Unhook(Handle plugin, int numParams)
{
	bool is_boss_module = g_modsys.IsPluginABoss(plugin);
	int vsh2Hook = GetNativeCell(1);
	Function func = GetNativeFunction(2);
	PrivateForward pw = g_modsys.GetPrivFwd(is_boss_module, vsh2Hook);
	if( pw != null )
		pw.RemoveFunction(plugin, func);
	return false;
}
public int Native_UnhookEx(Handle plugin, int numParams)
{
	bool is_boss_module = g_modsys.IsPluginABoss(plugin);
	int vsh2Hook = GetNativeCell(1);
	Function func = GetNativeFunction(2);
	PrivateForward pw = g_modsys.GetPrivFwd(is_boss_module, vsh2Hook);
	if( pw != null )
		return pw.RemoveFunction(plugin, func);
	return false;
}

public int Native_GetRandomBossType(Handle plugin, int numParams)
{
	bool multibosses = GetNativeCell(3);
	bool redonly = GetNativeCell(4);
	return VSHGameMode.GetRandomBossType(multibosses, redonly);
}

public any Native_GetBossIDs(Handle plugin, int numParams)
{
	//bool registered_only = GetNativeCell(1);
	StringMap boss_map = null;
	
	int max = g_modsys.m_hBossesRegistered.Length;
	if( max <= 0 )
		return boss_map;
	
	boss_map = new StringMap();
	for( int i; i<max; i++ ) {
		BossModule boss_plugin;
		g_modsys.m_hBossesRegistered.GetArray(i, boss_plugin, sizeof(boss_plugin));
		boss_map.SetValue(boss_plugin.name, i);
	}
	return boss_map;
}

public int Native_GetBossID(Handle plugin, int numParams)
{
	char bossname[MAX_BOSS_NAME_SIZE]; GetNativeString(1, bossname, MAX_BOSS_NAME_SIZE);
	for( int i; i<g_modsys.m_hBossesRegistered.Length; i++ ) {
		BossModule module;
		g_modsys.m_hBossesRegistered.GetArray(i, module, sizeof(module));
		if( !strcmp(module.name, bossname) )
			return i;
	}
	
	/// -1 == boss not found
	return -1;
}

public int Native_GetBossNameByIndex(Handle plugin, int numParams)
{
	int index = GetNativeCell(1);
	int max = g_modsys.m_hBossesRegistered.Length;
	if( index < 0 || index >= max ) {
		return 0;
	}
	
	BossModule module;
	if( g_modsys.m_hBossesRegistered.GetArray(index, module, sizeof(module)) < sizeof(module) ) {
		return 0;
	}
	SetNativeString(2, module.name, sizeof(BossModule::name));
	return 1;
}

public int Native_StopMusic(Handle plugin, int numParams)
{
	bool reset_time = GetNativeCell(1);
	StopBackGroundMusic();
	if( reset_time ) {
		if( g_vsh2.m_hCvars.PlayerMusic.BoolValue ) {
			for( int i=MaxClients; i; --i ) {
				if( !IsClientValid(i) ) {
					continue;
				}
				BaseBoss player = BaseBoss(i);
				player.flMusicTime = -1.0;
			}
		} else {
			g_vsh2.m_hGamemode.flMusicTime = -1.0;
		}
	}
	return 0;
}

public any Native_GetMainConfig(Handle plugin, int numParams)
{
	return g_vsh2.m_hCfg;
}

public int Native_VSH2_ConvertToMinion(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	float spawntime = GetNativeCell(2);
	player.ConvertToMinion(spawntime);
	return true;
}

public int Native_VSH2_SpawnWep(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char classname[64]; GetNativeString(2, classname, 64);
	int itemindex = GetNativeCell(3);
	int level = GetNativeCell(4);
	int quality = GetNativeCell(5);
	char attributes[128]; GetNativeString(6, attributes, 128);
	return player.SpawnWeapon(classname, itemindex, level, quality, attributes);
}

public int Native_VSH2_GetWeaponSlotIndex(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int slot = GetNativeCell(2);
	return player.GetWeaponSlotIndex(slot);
}

public int Native_VSH2_SetWepInvis(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int alpha = GetNativeCell(2);
	player.SetWepInvis(alpha);
	return 0;
}

public int Native_VSH2_SetOverlay(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char overlay[256]; GetNativeString(2, overlay, 256);
	player.SetOverlay(overlay);
	return 0;
}

public int Native_VSH2_TeleToSpawn(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int team = GetNativeCell(2);
	
	return player.TeleToSpawn(team);
}

public int Native_VSH2_IncreaseHeadCount(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	bool addhealth = GetNativeCell(2);
	int head_count = GetNativeCell(3);
	player.IncreaseHeadCount(addhealth, head_count);
	return 0;
}

public int Native_VSH2_SpawnSmallHealthPack(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int team = GetNativeCell(2);
	player.SpawnSmallHealthPack(team);
	return 0;
}

public int Native_VSH2_ForceTeamChange(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int team = GetNativeCell(2);
	player.ForceTeamChange(team);
	return 0;
}

public any Native_VSH2_ClimbWall(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int wep = GetNativeCell(2);
	float spawntime = GetNativeCell(3);
	float healthdmg = GetNativeCell(4);
	bool attackdelay = GetNativeCell(5);
	return player.ClimbWall(wep, spawntime, healthdmg, attackdelay);
}

public int Native_VSH2_HelpPanelClass(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.HelpPanelClass();
	return 0;
}

public int Native_VSH2_GetAmmoTable(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int slot = GetNativeCell(2);
	return player.getAmmotable(slot);
}

public int Native_VSH2_SetAmmoTable(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.setAmmotable(GetNativeCell(2), GetNativeCell(3));
	return 0;
}

public int Native_VSH2_GetClipTable(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int slot = GetNativeCell(2);
	return player.getCliptable(slot);
}

public int Native_VSH2_SetClipTable(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.setCliptable(GetNativeCell(2), GetNativeCell(3));
	return 0;
}

public int Native_VSH2_GetHealTarget(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.GetHealTarget();
}

public int Native_VSH2_IsNearDispenser(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	return player.IsNearDispenser();
}

public any Native_VSH2_IsInRange(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	float distance = GetNativeCell(3);
	return player.IsInRange(GetNativeCell(2), distance, GetNativeCell(4));
}

public int Native_VSH2_RemoveBack(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int length = GetNativeCell(3);
	int[] data = new int[length];
	GetNativeArray(2, data, length);
	player.RemoveBack(data, length);
	return 0;
}

public int Native_VSH2_FindBack(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int length = GetNativeCell(3);
	int[] data = new int[length];
	GetNativeArray(2, data, length);
	return player.FindBack(data, length);
}

public int Native_VSH2_ShootRocket(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	bool crit = GetNativeCell(2);
	float vpos[3]; GetNativeArray(3, vpos, 3);
	float vang[3]; GetNativeArray(4, vang, 3);
	float speed = GetNativeCell(5);
	float dmg = GetNativeCell(6);
	char modelname[PLATFORM_MAX_PATH]; GetNativeString(7, modelname, PLATFORM_MAX_PATH);
	bool arc = GetNativeCell(8);
	return player.ShootRocket(crit, vpos, vang, speed, dmg, modelname, arc);
}

public int Native_VSH2_Heal(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int health = GetNativeCell(2);
	bool hud = GetNativeCell(3);
	bool hp_override = GetNativeCell(4);
	int overheal_limit = GetNativeCell(5);
	player.Heal(health, hud, hp_override, overheal_limit);
	return 0;
}

public any Native_VSH2_AddTempAttrib(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int attrib = GetNativeCell(2);
	float val = GetNativeCell(3);
	float dur = GetNativeCell(4);
	return player.AddTempAttrib(attrib, val, dur);
}


public int Native_VSH2_ConvertToBoss(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.ConvertToBoss();
	return 0;
}

public int Native_VSH2_GiveRage(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int dmg = GetNativeCell(2);
	player.GiveRage(dmg);
	return 0;
}

public int Native_VSH2_MakeBossAndSwitch(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	int bossid = GetNativeCell(2);
	bool run_event = GetNativeCell(2);
	bool friendly = GetNativeCell(3);
	player.MakeBossAndSwitch(bossid, run_event, friendly);
	return 0;
}

public int Native_VSH2_DoGenericStun(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	float rage_radius = GetNativeCell(2);
	player.DoGenericStun(rage_radius);
	return 0;
}

public int Native_VSH2_StunPlayers(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	float rage_radius = GetNativeCell(2);
	float stun_time = GetNativeCell(3);
	player.StunPlayers(rage_radius, stun_time);
	return 0;
}

public int Native_VSH2_StunBuildings(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	float rage_radius = GetNativeCell(2);
	float sentry_stun_time = GetNativeCell(3);
	player.StunBuildings(rage_radius, sentry_stun_time);
	return 1;
}



public int Native_VSH2_RemoveAllItems(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	bool weps = numParams <= 1 ? true : GetNativeCell(2);
	player.RemoveAllItems(weps);
	return 1;
}

public any Native_VSH2_GetName(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char name[MAX_BOSS_NAME_SIZE];
	bool res = player.GetName(name);
	SetNativeString(2, name, sizeof(name), true);
	return res;
}

public any Native_VSH2_SetName(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char name[MAX_BOSS_NAME_SIZE];
	GetNativeString(2, name, sizeof(name));
	return player.SetName(name);
}

public int Native_VSH2_SuperJump(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	float power = GetNativeCell(2);
	float reset = GetNativeCell(3);
	player.SuperJump(power, reset);
	return 0;
}

public int Native_VSH2_WeighDown(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	float reset = GetNativeCell(2);
	player.WeighDown(reset);
	return 0;
}

public int Native_VSH2_PlayVoiceClip(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	char sound[PLATFORM_MAX_PATH]; GetNativeString(2, sound, sizeof(sound));
	int flags = GetNativeCell(3);
	player.PlayVoiceClip(sound, flags);
	return 0;
}

public int Native_VSH2_PlayMusic(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	float vol = GetNativeCell(2);
	player.PlayMusic(vol);
	return 0;
}

public int Native_VSH2_StopMusic(Handle plugin, int numParams)
{
	BaseBoss player = GetNativeCell(1);
	player.StopMusic();
	return 0;
}


public int Native_VSH2GameMode_GetProperty(Handle plugin, int numParams)
{
	char prop_name[64]; GetNativeString(1, prop_name, sizeof(prop_name));
	any item;
	if( g_vsh2.m_hGamemode.GetValue(prop_name, item) ) {
		return item;
	}
	return 0;
}
public int Native_VSH2GameMode_SetProperty(Handle plugin, int numParams)
{
	char prop_name[64]; GetNativeString(1, prop_name, sizeof(prop_name));
	any item = GetNativeCell(2);
	g_vsh2.m_hGamemode.SetValue(prop_name, item);
	return 0;
}
public any Native_VSH2GameMode_GetRandomBoss(Handle plugin, int numParams)
{
	bool alive = GetNativeCell(1);
	return VSHGameMode.GetRandomBoss(alive);
}
public any Native_VSH2GameMode_GetBossByType(Handle plugin, int numParams)
{
	bool alive = GetNativeCell(1);
	int bossid = GetNativeCell(2);
	return VSHGameMode.GetBossByType(alive, bossid);
}
public any Native_VSH2GameMode_FindNextBoss(Handle plugin, int numParams)
{
	return VSHGameMode.FindNextBoss();
}
public int Native_VSH2GameMode_CountMinions(Handle plugin, int numParams)
{
	bool alive = GetNativeCell(1);
	BaseBoss owner = GetNativeCell(2);
	return VSHGameMode.CountMinions(alive, owner);
}
public int Native_VSH2GameMode_CountBosses(Handle plugin, int numParams)
{
	bool alive = GetNativeCell(1);
	return VSHGameMode.CountBosses(alive);
}
public int Native_VSH2GameMode_GetTotalBossHealth(Handle plugin, int numParams)
{
	return VSHGameMode.GetTotalBossHealth();
}
public int Native_VSH2GameMode_SearchForItemPacks(Handle plugin, int numParams)
{
	VSHGameMode.SearchForItemPacks();
	return 1;
}
public int Native_VSH2GameMode_UpdateBossHealth(Handle plugin, int numParams)
{
	g_vsh2.m_hGamemode.UpdateBossHealth();
	return 1;
}
public int Native_VSH2GameMode_GetBossType(Handle plugin, int numParams)
{
	g_vsh2.m_hGamemode.GetBossType();
	return 1;
}

public int Native_VSH2GameMode_GetTotalRedPlayers(Handle plugin, int numParams)
{
	return GetLivingPlayers(VSH2Team_Red);
}

public any Native_VSH2GameMode_GetHUDHandle(Handle plugin, int numParams)
{
	int hud_type = GetNativeCell(1);
	hud_type = IntClamp(hud_type, HealthHUD, PlayerHUD);
	return g_vsh2.m_hHUDs[hud_type];
}

public int Native_VSH2GameMode_GetBosses(Handle plugin, int numParams)
{
	BaseBoss[] bosses = new BaseBoss[MaxClients];
	bool balive = GetNativeCell(2);
	int numbosses = VSHGameMode.GetBosses(bosses, balive);
	SetNativeArray(1, bosses, MaxClients);
	return numbosses;
}

public int Native_VSH2GameMode_IsVSHMap(Handle plugin, int numParams)
{
	return VSHGameMode.IsVSHMap();
}

public int Native_VSH2_GetMaxBosses(Handle plugin, int numParams)
{
	return g_vsh2.m_hGamemode.MAXBOSS;
}

public int Native_VSH2GameMode_GetFighters(Handle plugin, int numParams)
{
	BaseBoss[] reds = new BaseBoss[MaxClients];
	bool balive = GetNativeCell(2);
	int numreds = VSHGameMode.GetFighters(reds, balive);
	SetNativeArray(1, reds, MaxClients);
	return numreds;
}

public int Native_VSH2GameMode_GetMinions(Handle plugin, int numParams)
{
	BaseBoss[] minions = new BaseBoss[MaxClients];
	bool balive = GetNativeCell(2);
	BaseBoss owner = GetNativeCell(3);
	int numminions = VSHGameMode.GetMinions(minions, balive, owner);
	SetNativeArray(1, minions, MaxClients);
	return numminions;
}

public int Native_VSH2GameMode_GetQueue(Handle plugin, int numParams)
{
	BaseBoss[] players = new BaseBoss[MaxClients];
	int n = VSHGameMode.GetQueue(players);
	SetNativeArray(1, players, MaxClients);
	return n;
}

public int Native_VSH2GameMode_GetBossesByType(Handle plugin, int numParams)
{
	BaseBoss[] bosses = new BaseBoss[MaxClients];
	int type = GetNativeCell(2);
	bool alive = GetNativeCell(3);
	int n = VSHGameMode.GetBossesByType(bosses, type, alive);
	SetNativeArray(1, bosses, MaxClients);
	return n;
}