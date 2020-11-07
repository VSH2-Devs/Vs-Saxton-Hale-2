void InitNatives()
{
	#define CREATE_NATIVE(%0) CreateNative(#%0, Native_%0)
	
	CREATE_NATIVE(FF2_IsFF2Enabled);
	CREATE_NATIVE(FF2_GetFF2Version);
	CREATE_NATIVE(FF2_GetForkVersion);
	
	CREATE_NATIVE(FF2_LogError);
	CREATE_NATIVE(FF2_ReportError);
	
	CREATE_NATIVE(FF2_GetCheats);
	CREATE_NATIVE(FF2_SetCheats);
	
	CREATE_NATIVE(FF2_GetBossCharge);
	CREATE_NATIVE(FF2_SetBossCharge);
	
	CREATE_NATIVE(FF2_GetBossPlayers);
	CREATE_NATIVE(FF2_MakeBoss);
	
	#undef CREATE_NATIVE
	#define CREATE_NATIVE(%0)	CreateNative("FF2Player."...#%0		, Native_FF2Player_%0		)
	#define CREATE_NATIVE_GET(%0)	CreateNative("FF2Player."...#%0...".get", Native_FF2Player_%0_Get	)
	#define CREATE_NATIVE_SET(%0)	CreateNative("FF2Player."...#%0...".set", Native_FF2Player_%0_Set	)
	

	CREATE_NATIVE(FF2Player);
	CREATE_NATIVE(GetArgI);
	CREATE_NATIVE(GetArgF);
	CREATE_NATIVE(GetArgS);
	
	CREATE_NATIVE(GetInt);
	CREATE_NATIVE(GetString);
	CREATE_NATIVE(GetFloat);
	
	CREATE_NATIVE(GetConfigName);
	
	CREATE_NATIVE(HasAbility);
	CREATE_NATIVE(DoAbility);
	CREATE_NATIVE(ForceAbility);
	CREATE_NATIVE(RandomSound);
	CREATE_NATIVE(RageDist);
	
	CREATE_NATIVE_GET(SoundCache);
	CREATE_NATIVE_GET(HookedAbilities);
	CREATE_NATIVE(PlayBGM);
	
	#undef CREATE_NATIVE
	#undef CREATE_NATIVE_GET
	#undef CREATE_NATIVE_SET
}

/* FF2Player methodmaps */
public any Native_FF2Player_FF2Player(Handle plugin, int numParams)
{
	return FF2Player(GetNativeCell(1), GetNativeCell(2));
}

public any Native_FF2Player_GetArgI(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	char pl_name[64], ab_name[64], key_name[32];
	GetNativeString(2, pl_name, sizeof(pl_name));
	GetNativeString(3, ab_name, sizeof(ab_name));
	GetNativeString(4, key_name, sizeof(key_name));
	
	int def = GetNativeCell(5);
	return GetArgNamedI(player, pl_name, ab_name, key_name, def);
}

public any Native_FF2Player_GetArgF(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	char pl_name[64], ab_name[64], key_name[32];
	GetNativeString(2, pl_name, sizeof(pl_name));
	GetNativeString(3, ab_name, sizeof(ab_name));
	GetNativeString(4, key_name, sizeof(key_name));
	
	float def = GetNativeCell(5);
	return GetArgNamedF(player, pl_name, ab_name, key_name, def);
}

public any Native_FF2Player_GetArgS(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	char pl_name[64], ab_name[64], key_name[32];
	GetNativeString(2, pl_name, sizeof(pl_name));
	GetNativeString(3, ab_name, sizeof(ab_name));
	
	GetNativeString(4, key_name, sizeof(key_name));
	
	int maxlen = GetNativeCell(6);
	char[] result = new char[maxlen];
	int written = GetArgNamedS(player, pl_name, ab_name, key_name, result, maxlen);
	
	SetNativeString(5, result, maxlen);
	return written;
}

public any Native_FF2Player_HasAbility(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));
	
	bool result = JumpToAbility(player, plugin_name, ability_name) != null;
	return result;
}

public any Native_FF2Player_DoAbility(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));
	
	int slot = GetNativeCell(4);
	
	Call_StartForward(ff2.m_forwards[FF2OnAbility]);
	Call_PushCell(player);
	Call_PushString(plugin_name);
	Call_PushString(ability_name);
	Call_PushCell(slot);
	Call_Finish();
}

public any Native_FF2Player_ForceAbility(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	FF2CallType_t type = GetNativeCell(4);
	Call_FF2OnAbility(player, type);
}

public any Native_FF2Player_RandomSound(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	
	static FF2Identity identity;
	if ( !ff2_cfgmgr.FindIdentity(player.GetPropInt("iBossType"), identity) )
		return 0;
	
	int size = GetNativeCell(4);
	
	int key_size; GetNativeStringLength(2, key_size); ++key_size;

	char[] key = new char[key_size];
	GetNativeString(2, key, key_size);
	
	bool soundExists;
	
	FF2SoundIdentity snd_id;
	FF2SoundList list = identity.sndHash.GetList(key);
	
	if ( list ) {
		if( !StrContains(key, "sound_ability") ) {
			FF2CallType_t slot = GetNativeCell(5);
			soundExists = RandomAbilitySound(list, slot, snd_id.path, size);
		} 
		else soundExists = list.RandomSound(snd_id);
	}
	
	if ( !soundExists ) return false;
	return SetNativeString(3, snd_id.path, size) == SP_ERROR_NONE;
}

public any Native_FF2Player_RageDist(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	if( !player.Valid )
		return 0.0;
	
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));
	
	ConfigMap cfg = player.iCfg;
	if( !ability_name[0] ) {
		float f;
		return( cfg.GetFloat("ragedist", f) > 0 ) ? f : 0.0;
	}
	
	ConfigMap section = JumpToAbility(player, plugin_name, ability_name);
	float see;
	if ( !section ) return 0.0;
	if( !section.GetFloat("dist", see) && !section.GetFloat("ragedist", see) ) {
		cfg.GetFloat("ragedist", see);
	}
	
	return see;
}

public any Native_FF2Player_GetConfigName(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	
	FF2Identity id;
	if( !ff2_cfgmgr.FindIdentity(player.iBossType, id) )
		return;
	
	SetNativeString(2, id.szName, GetNativeCell(3));
	return;
}

public any Native_FF2Player_GetInt(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	
	char key_name[64]; GetNativeString(2, key_name, sizeof(key_name));
	
	int val;
	if( player.iCfg.GetInt(key_name, val) ) {
		SetNativeCellRef(3, val);
		return true;
	}
	return false;
}

public any Native_FF2Player_GetFloat(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	
	char key_name[64]; GetNativeString(2, key_name, sizeof(key_name));
	
	float val;
	if( player.iCfg.GetFloat(key_name, val) ) {
		SetNativeCellRef(3, val);
		return true;
	}
	return false;
}

public any Native_FF2Player_GetString(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	
	char key_name[64]; GetNativeString(2, key_name, sizeof(key_name));
	
	int len = GetNativeCell(4);
	char[] res = new char[len];
	if( player.iCfg.Get(key_name, res, len) ) {
		return SetNativeString(3, res, len);
	}
	return 0;
}

public any Native_FF2Player_HookedAbilities_Get(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	return player.HookedAbilities;
}

public any Native_FF2Player_SoundCache_Get(Handle plugin, int numParams)
{
	FF2Player player = GetNativeCell(1);
	static FF2Identity identity;
	if ( !ff2_cfgmgr.FindIdentity(player.iBossType, identity) )
		return 0;
	
	return identity.sndHash;
}

public any Native_FF2Player_PlayBGM(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	char bgm[PLATFORM_MAX_PATH]; GetNativeString(2, bgm, sizeof(bgm));
	player.PlayBGM(bgm);
}

/* end FF2Player methodmaps */



/** bool FF2_IsFF2Enabled(); */
public int Native_FF2_IsFF2Enabled(Handle plugin, int numParams)
{
	return ff2.m_cvars.m_enabled.BoolValue;
}

/** bool FF2_GetFF2Version(int[] version=0); */
public int Native_FF2_GetFF2Version(Handle plugin, int numParams)
{
	char version_str[10];
	ff2.m_cvars.m_version.GetString(version_str, sizeof(version_str));
	
	char digit[3][10];
	int version_ints[3];
	if( ExplodeString(version_str, ".", digit, sizeof(digit[]), sizeof(digit[][])) == 3 ) {
		for( int i; i<3; i++ )
			version_ints[i] = StringToInt(digit[i]);
	}
	SetNativeArray(1, version_ints, sizeof(version_ints));
	return 1;
}

/** bool FF2_GetForkVersion(int[] fversion=0); */
public int Native_FF2_GetForkVersion(Handle plugin, int numParams)
{
	int version_ints[3]; SetNativeArray(1, version_ints, sizeof(version_ints));
	return 1;
}

/** void FF2_LogError(const char[] message, any ...); */
public any Native_FF2_LogError(Handle plugin, int numParams)
{
	char buffer[MAX_BUFFER_LENGTH];
	int error = FormatNativeString(0, 1, 2, sizeof(buffer), .fmt_string=buffer);
	if( error != SP_ERROR_NONE ) {
		return ThrowNativeError(error, "Failed to format");
	}
	
	LogError(buffer);
	return 0;
}

/** void FF2_LogError(FF2Player player = INVALID_FF2_PLAYER, const char[] message, any ...); */
public any Native_FF2_ReportError(Handle plugin, int numParams)
{
	FF2Player player = GetNativeCell(1);
	char name[MAX_BOSS_NAME_SIZE] = "Unknown";
	if( player.Valid ) {
		if( player.GetName(name) ) {
			name = "Unknown";
		}
	}
	
	LogError("[FF2] Exception reported: Boss: %i - Name: %s", player, name);
	char actual[PLATFORM_MAX_PATH];
	
	int error;
	if( (error = FormatNativeString(0, 2, 3, sizeof(actual), .out_string=actual)) != SP_ERROR_NONE )
		return ThrowNativeError(error, "Failed to format");
	
	Format(actual, sizeof(actual), "[FF2] %s", actual);
	LogError(actual);
	
	return 0;
}

/** void FF2_SetCheats(bool status); */
public any Native_FF2_SetCheats(Handle plugin, int numParams)
{
	ff2.m_cheats = GetNativeCell(1);
}

/** bool FF2_GetCheats(); */
public any Native_FF2_GetCheats(Handle plugin, int numParams)
{
	return ff2.m_cheats;
}

/** float FF2_GetBossCharge(int boss, int slot); */
public any Native_FF2_GetBossCharge(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	if( !player.Valid )
		return 0.0;
	
	FF2RageType_t slot = GetNativeCell(2);
	return player.GetRageVar(slot);
}

/** void FF2_SetBossCharge(int boss, int slot, float value); */
public any Native_FF2_SetBossCharge(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	if( !player.Valid )
		return 0;
	
	FF2RageType_t slot = GetNativeCell(2);
	float value = GetNativeCell(3);
	player.SetRageVar(slot, value);
	
	return 1;
}

/** int FF2_GetAlivePlayers(); */
public any Native_FF2_GetAlivePlayers(Handle plugin, int numParams)
{
	return vsh2_gm.iLivingReds;
}

/** int FF2_GetBossPlayers(); */
public any Native_FF2_GetBossPlayers(Handle plugin, int numParams)
{
	FF2Player[] bosses = new FF2Player[MaxClients];
	return VSH2GameMode.GetBosses(bosses);
}

/** void FF2_MakeBoss(int client, const char[] boss_name, bool call_event = true); */
public any Native_FF2_MakeBoss(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	if( !player.Valid )
		return false;
	
	char boss_name[48]; GetNativeString(2, boss_name, sizeof(boss_name));
	FF2Identity id;
	if( !ff2_cfgmgr.FindIdentityByName(boss_name, id) )
		return false;
	
	player.MakeBossAndSwitch(id.VSH2ID, GetNativeCell(3));
	
	return true;
}


/** TODO ZZZZZZZZZZZZZZZZZZZZZZZZZZZ */
/*
public any Native_ZZZ(Handle plugin, int numParams)
{
	return 0;
}
*/
