void InitNatives()
{
	/// Natives For FF2GameMode
	#define CREATE_NATIVE(%0)    CreateNative("FF2GameMode."...#%0   , Native_FF2GameMode_%0)

	CREATE_NATIVE(IsOn);
	CREATE_NATIVE(PluginVersion);
	CREATE_NATIVE(ForkVersion);

	CREATE_NATIVE(Cheats);

	CREATE_NATIVE(QueryBoss);

	CREATE_NATIVE(LoadAbility);
	CREATE_NATIVE(SubPlugins);
	CREATE_NATIVE(Validate);
	CREATE_NATIVE(RegisterPlugin);

	/// Natives For FF2Player
	#undef CREATE_NATIVE
	#define CREATE_NATIVE(%0)        CreateNative("FF2Player."...#%0,          Native_FF2Player_%0    )
	#define CREATE_NATIVE_GET(%0)    CreateNative("FF2Player."...#%0...".get", Native_FF2Player_%0_Get)


	CREATE_NATIVE(FF2Player);
	CREATE_NATIVE(GetArgB);
	CREATE_NATIVE(GetArgI);
	CREATE_NATIVE(GetArgF);
	CREATE_NATIVE(GetArgS);

	CREATE_NATIVE(GetInt);
	CREATE_NATIVE(GetFloat);
	CREATE_NATIVE(GetString);
	CREATE_NATIVE(GetSection);

	CREATE_NATIVE(GetConfigName);

	CREATE_NATIVE(HasAbility);
	CREATE_NATIVE(DoAbility);
	CREATE_NATIVE(ForceAbility);

	CREATE_NATIVE(RandomSound);
	CREATE_NATIVE(RageDist);

	CREATE_NATIVE(PlayBGM);

	#undef CREATE_NATIVE
	#undef CREATE_NATIVE_GET
}

/** FF2Player methodmaps */
any Native_FF2Player_FF2Player(Handle plugin, int numParams)
{
	return( FF2Player(GetNativeCell(1), GetNativeCell(2)) );
}

any Native_FF2Player_GetArgB(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	char pl_name[64], ab_name[64], key_name[32];
	GetNativeString(2, pl_name, sizeof(pl_name));
	GetNativeString(3, ab_name, sizeof(ab_name));
	GetNativeString(4, key_name, sizeof(key_name));

	bool def = GetNativeCell(5);
	return( GetArgNamedB(player, pl_name, ab_name, key_name, def) );
}

any Native_FF2Player_GetArgI(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	char pl_name[64], ab_name[64], key_name[32];
	GetNativeString(2, pl_name, sizeof(pl_name));
	GetNativeString(3, ab_name, sizeof(ab_name));
	GetNativeString(4, key_name, sizeof(key_name));

	int def = GetNativeCell(5);
	return( GetArgNamedI(player, pl_name, ab_name, key_name, def) );
}

any Native_FF2Player_GetArgF(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	char pl_name[64], ab_name[64], key_name[32];
	GetNativeString(2, pl_name, sizeof(pl_name));
	GetNativeString(3, ab_name, sizeof(ab_name));
	GetNativeString(4, key_name, sizeof(key_name));

	float def = GetNativeCell(5);
	return( GetArgNamedF(player, pl_name, ab_name, key_name, def) );
}

any Native_FF2Player_GetArgS(Handle plugin, int numParams)
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
	return( written );
}

any Native_FF2Player_HasAbility(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));

	bool result = JumpToAbility(player, plugin_name, ability_name) != null;
	return( result );
}

any Native_FF2Player_DoAbility(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));

	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));

	FF2CallType_t slot = GetNativeCell(4);

	Call_StartForward(ff2.m_forwards[FF2OnAbility]);
	Call_PushCell(player.index);
	Call_PushString(plugin_name);
	Call_PushString(ability_name);
	Call_PushCell(slot);
	Call_Finish();
}

any Native_FF2Player_ForceAbility(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	FF2CallType_t type = GetNativeCell(2);
	Call_FF2OnAbility(player, type);
}

any Native_FF2Player_RandomSound(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));

	FF2Identity identity;
	if( !ff2_cfgmgr.FindIdentity(player.GetPropInt("iBossType"), identity) ) {
		return 0;
	}

	int key_size; GetNativeStringLength(2, key_size); ++key_size;

	char[] key = new char[key_size];
	GetNativeString(2, key, key_size);

	FF2SoundSection sec;

	if( !StrContains(key, "ability") ) {
		FF2CallType_t slot = GetNativeCell(4);
		RandomAbilitySound(identity.soundMap.GetSection(key), slot, sec);
	} else {
		sec = identity.soundMap.RandomEntry(key);
	}

	if( !sec )
		return false;

	FF2SoundIdentity snd_info;
	sec.FullInfo(snd_info);
	return( SetNativeArray(3, snd_info, sizeof(snd_info)) == SP_ERROR_NONE );
}

any Native_FF2Player_RageDist(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	if( !player.Valid )
		return 0.0;

	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));

	if( !ability_name[0] ) {
		float f;
		return( player.BossConfig.Config.GetFloat("info.ragedist", f) > 0 ) ? f : 0.0;
	}

	ConfigMap section = JumpToAbility(player, plugin_name, ability_name);
	float see;
	if( !section )
		return 0.0;

	if( !section.GetFloat("dist", see) && !section.GetFloat("ragedist", see) ) {
		player.BossConfig.Config.GetFloat("info.ragedist", see);
	}

	return( see );
}

any Native_FF2Player_GetConfigName(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));

	FF2Identity id;
	if( !ff2_cfgmgr.FindIdentity(player.iBossType, id) )
		return 0;

	return( SetNativeString(2, id.name, GetNativeCell(3)) == SP_ERROR_NONE );
}

any Native_FF2Player_GetInt(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));

	char key_name[64]; GetNativeString(2, key_name, sizeof(key_name));

	int val;
	if( player.BossConfig.Config.GetInt(key_name, val) ) {
		SetNativeCellRef(3, val);
		return true;
	}
	return false;
}

any Native_FF2Player_GetFloat(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));

	char key_name[64]; GetNativeString(2, key_name, sizeof(key_name));

	float val;
	if( player.BossConfig.Config.GetFloat(key_name, val) ) {
		SetNativeCellRef(3, val);
		return true;
	}
	return false;
}

any Native_FF2Player_GetString(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));

	char key_name[64]; GetNativeString(2, key_name, sizeof(key_name));

	int len = GetNativeCell(4);
	char[] res = new char[len];
	if( player.BossConfig.Config.Get(key_name, res, len) ) {
		return SetNativeString(3, res, len)==SP_ERROR_NONE;
	}
	return 0;
}

any Native_FF2Player_GetSection(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));

	char key_name[64]; GetNativeString(2, key_name, sizeof(key_name));

	ConfigMap sec = player.BossConfig.Config.GetSection(key_name);
	return sec.Clone(plugin);
}

any Native_FF2Player_PlayBGM(Handle plugin, int numParams)
{
	FF2Player player = ToFF2Player(GetNativeCell(1));
	char bgm[PLATFORM_MAX_PATH]; GetNativeString(2, bgm, sizeof(bgm));
	player.PlayBGM(bgm);
}

/** End of FF2Player methodmaps */



/** FF2GameMode methodmaps */
int Native_FF2GameMode_IsOn(Handle plugin, int numParams)
{
	return( ff2.m_vsh2 );
}

int Native_FF2GameMode_PluginVersion(Handle plugin, int numParams)
{
	char version_str[10];
	ff2.m_cvars.m_version.GetString(version_str, sizeof(version_str));

	char digit[3][10];
	int version_ints[3];
	if( ExplodeString(version_str, ".", digit, sizeof(digit[]), sizeof(digit[][])) == 3 ) {
		for( int i; i<3; i++ )
			version_ints[i] = StringToInt(digit[i]);
	}
	return SetNativeArray(1, version_ints, sizeof(version_ints)) == SP_ERROR_NONE;
}

int Native_FF2GameMode_ForkVersion(Handle plugin, int numParams)
{
	char version[3][4];
	int output[3];

	if( ExplodeString(PLUGIN_VERSION, ".", version, sizeof(version), sizeof(version[])) == 3 ) {
		for( int i; i<3; i++ )
			output[i] = StringToInt(version[i]);
	}

	SetNativeArray(1, output, sizeof(output));

	int end = strlen(version[2]);
	return version[2][end - 1] == 'b';
}

any Native_FF2GameMode_Cheats(Handle plugin, int numParams)
{
	if( GetNativeCell(1) ) {
		ff2.m_cheats = GetNativeCell(2) != 0;
	}

	return ff2.m_cheats;
}

enum struct FF2Identity_Q {
	int				VSH2ID;
	ConfigMap		hCfg;
	StringMap		soundMap;
	ArrayList		abilityList;
	char			name[FF2_MAX_BOSS_NAME_SIZE];

	bool			isNewAPI;
	bool			isFound;
}

enum FF2GameModeQ_t {
	/// Fill the FF2Identity::hCfg struct
	FF2GAMEMODEQ_CONFIGMAP 	= 1 << 0,
	/// Fill the FF2Identity::soundMap
	FF2GAMEMODEQ_SOUNDMAP 	= 1 << 1,
	/// Fill the FF2Identity::abilityList
	FF2GAMEMODEQ_ABILITIES 	= 1 << 2,
	
	/// if it was set, and 'FF2GAMEMODEQ_BY_NAME' was set, fill the FF2Identity::VSH2ID else vise-versa
	FF2GAMEMODEQ_COPY_OTHER	= 1 << 3,
	/// if it was set, search the boss by FF2Identity::name, else search by FF2Identity::VSH2ID
	FF2GAMEMODEQ_BY_NAME	= 1 << 4,
}

any Native_FF2GameMode_QueryBoss(Handle plugin, int numParams)
{
	FF2Identity_Q out;
	FF2Identity tmp;
	GetNativeArray(1, out, sizeof(FF2Identity_Q));
	FF2GameModeQ_t flags = GetNativeCell(2);

	if( flags & FF2GAMEMODEQ_BY_NAME ) {
		if( !(out.isFound = ff2_cfgmgr.FindIdentityByName(out.name, tmp)) ) {
			return 0;
		}
		if( flags & FF2GAMEMODEQ_COPY_OTHER )
			out.VSH2ID = tmp.VSH2ID;
	}
	else {
		if( !(out.isFound = ff2_cfgmgr.FindIdentity(out.VSH2ID, tmp)) ) {
			return 0;
		}

		if( flags & FF2GAMEMODEQ_COPY_OTHER )
			strcopy(out.name, sizeof(FF2Identity_Q::name), tmp.name);
	}

	if( flags & FF2GAMEMODEQ_CONFIGMAP ) {
		out.hCfg = tmp.hCfg.Clone(plugin);
	}
	if( flags & FF2GAMEMODEQ_ABILITIES ) {
		out.abilityList = new ArrayList();
		for( int i=tmp.abilityList.Length-1; i>=0; i-- ) {
			out.abilityList.Push(view_as<ConfigMap>(tmp.abilityList.Get(i)).Clone(plugin));
		}
	}
	if( flags & FF2GAMEMODEQ_SOUNDMAP ) {
		out.soundMap = new StringMap();
		StringMapSnapshot snap = tmp.soundMap.Snapshot();
		
		for( int i=snap.Length-1; i>=0; i-- ) {
			int len = snap.KeyBufferSize(i);
			char[] key = new char[len];
			snap.GetKey(i, key, len);

			ConfigMap section;
			tmp.soundMap.GetValue(key, section);
			out.soundMap.SetValue(key, section.Clone(plugin));
		}
		delete snap;
	}
	out.isNewAPI = tmp.isNewAPI;

	SetNativeArray(1, out, sizeof(FF2Identity_Q));
	return 0;
}

any Native_FF2GameMode_LoadAbility(Handle plugins, int numParams)
{
	char pl_name[FF2_MAX_PLUGIN_NAME];
	GetNativeString(1, pl_name, sizeof(pl_name));

	return ff2.m_plugins.TryLoadSubPlugin(pl_name);
}

any Native_FF2GameMode_SubPlugins(Handle plugins, int numParams)
{
	FF2PluginList list = ff2.m_plugins;
	if( !list.Length )
		return 0;

	StringMap map = new StringMap();
	FF2SubPlugin info;
	for( int i; i < list.Length; i++ ) {
		list.GetInfo(i, info);
		map.SetValue(info.name, info.hndl);
	}

	return map;
}

any Native_FF2GameMode_Validate(Handle plugins, int numParams)
{
	FF2Identity id;
	return ff2_cfgmgr.FindIdentity(ToFF2Player(GetNativeCell(1)).iBossType, id);
}

any Native_FF2GameMode_RegisterPlugin(Handle plugins, int numParams)
{
	char cfg_name[PLATFORM_MAX_PATH];
	GetNativeString(1, cfg_name, sizeof(cfg_name));
	FF2Identity id;
	strcopy(id.name, sizeof(FF2Identity::name), cfg_name);
	if( FF2_LoadCharacter(id, cfg_name) ) {
		ff2_cfgmgr.SetArray(cfg_name, id, sizeof(FF2Identity));
		return id.VSH2ID;
	}
	else return INVALID_FF2_BOSS_ID;
}

/** End of FF2GameMode methodmaps */


/*
public any Native_ZZZ(Handle plugin, int numParams)
{
	return 0;
}
*/