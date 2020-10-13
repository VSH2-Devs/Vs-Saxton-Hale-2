void InitNatives()
{
	CreateNative("FF2_IsFF2Enabled", Native_FF2_IsFF2Enabled);
	CreateNative("FF2_GetFF2Version", Native_FF2_GetFF2Version);
	
}

/** bool FF2_IsFF2Enabled(); */
public int Native_FF2_IsFF2Enabled(Handle plugin, int numParams)
{
	return vsh2cvars.m_enabled.BoolValue;
}

/** bool FF2_GetFF2Version(int[] version=0); */
public int Native_FF2_GetFF2Version(Handle plugin, int numParams)
{
	char version_str[10];
	vsh2cvars.m_version.GetString(version_str, sizeof(version_str));
	
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

/** int FF2_GetRoundState(); */
public int Native_FF2_GetRoundState(Handle plugin, int numParams)
{
	return VSH2GameMode.GetPropInt("iRoundState");
}

/** int FF2_GetBossUserId(int boss=0); */
public int Native_FF2_GetBossUserId(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	return player.Valid ? player.userid:-1;
}

/** int FF2_GetBossIndex(int client); */
public any Native_FF2_GetBossIndex(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	return player;
}

/** int FF2_GetBossTeam(); */
public int Native_FF2_GetBossTeam(Handle plugin, int numParams)
{
	return VSH2Team_Boss;
}

/** bool FF2_GetBossSpecial(int boss=0, char[] buffer, int bufferLength, int bossMeaning=0); */
public int Native_FF2_GetBossSpecial(Handle plugin, int numParams)
{
	int
		index = GetNativeCell(1),
		buflen = GetNativeCell(3),
		meaning = GetNativeCell(4)
	;
	
	FF2Player player = FF2Player(index);
	if ( !player.Valid || !player.GetPropAny("bIsBoss") ) {
		return false;
	}
	
	char[] name = new char[buflen];
	
	if ( !meaning ) {
		ConfigMap cfg = player.iCfg;
		if( cfg ) {
			if( cfg.Get("name", name, buflen) ) {
				SetNativeString(2, name, buflen);
				return true;
			}
		}
		
		return false;
	} else {
		/// TODO
		return false;
	}
}

/** int FF2_GetBossHealth(int boss=0); */
public int Native_FF2_GetBossHealth(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	return player.Valid && player.GetPropAny("bIsBoss") ? player.iHealth : 0;
}

/** bool FF2_SetBossHealth(int boss, int health); */
public any Native_FF2_SetBossHealth(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	int new_health = GetNativeCell(2);
	return player.Valid && player.GetPropAny("bIsBoss") ? player.SetPropInt("iHealth", new_health):false;
}

/** int FF2_GetBossMaxHealth(int boss=0); */
public int Native_FF2_GetBossMaxHealth(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	return player.Valid && player.GetPropAny("bIsBoss") ? player.GetPropInt("iMaxHealth"):0;
}

/** void FF2_SetBossMaxHealth(int boss, int health); */
public any Native_FF2_SetBossMaxHealth(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	int new_maxhealth = GetNativeCell(2);
	return player.Valid && player.GetPropAny("bIsBoss") ? player.SetPropInt("iMaxHealth", new_maxhealth) : false;
}

/** int FF2_GetBossLives(int boss); */
public any Native_FF2_GetBossLives(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	return player.Valid && player.GetPropAny("bIsBoss") ? player.GetPropInt("iLives") : 0;
}

/** void FF2_SetBossLives(int boss, int lives); */
public any Native_FF2_SetBossLives(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	int lives = GetNativeCell(2);
	player.SetPropInt("iLives", lives);
}

/** int FF2_GetBossMaxLives(int boss); */
public any Native_FF2_GetBossMaxLives(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	return player.Valid && player.GetPropAny("bIsBoss") ? player.GetPropInt("iMaxLives") : 0;
}

/** void FF2_SetBossMaxLives(int boss, int lives); */
public any Native_FF2_SetBossMaxLives(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	int lives = GetNativeCell(2);
	player.SetPropInt("iMaxLives", lives);
}

/** bool FF2_SetQueuePoints(int client, int value); */
public any Native_FF2_SetQueuePoints(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	if ( !player.Valid ) {
		return false;
	}
	int q = GetNativeCell(2);
	return player.SetPropInt("iQueue", q);
}

/** int FF2_GetQueuePoints(int client); */
public any Native_FF2_GetQueuePoints(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	if ( !player.Valid ) {
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid FF2Player index");
	}
	return player.GetPropInt("iQueue");
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

/** bool FF2_Debug(); */
public any Native_FF2_Debug(Handle plugin, int numParams)
{
	return 1; /// Batfoxkid: Not sure what you want to do here, this mainly just tells the plugin when to print out Debug messages
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

///	TODO
/** float FF2_GetBossCharge(int boss, int slot); */
public any Native_FF2_GetBossCharge(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	if( !player.Valid )
		return 0.0;
	
	int slot = GetNativeCell(2);
	switch( slot ) {
		case 0: { /// Rage
			return player.GetPropFloat("flRAGE");
		}
		default: {
			return FF2_GetCustomCharge(player, slot);
		}
	}
}

///	TODO
/** void FF2_SetBossCharge(int boss, int slot, float value); */
public any Native_FF2_SetBossCharge(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	if( !player.Valid )
		return 0.0;
	
	int slot = GetNativeCell(2);
	float value = GetNativeCell(3);
	switch( slot ) {
		case 0: { /// Rage
			return player.SetPropFloat("flRAGE", value);
		}
		default: {
			return FF2_SetCustomCharge(player, slot, value);
		}
	}
}

/** int FF2_GetBossRageDamage(int boss); */
public int Native_FF2_GetBossRageDamage(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	return player.Valid ? player.iRageDmg:0;
}

/** void FF2_SetBossRageDamage(int boss, int damage); */
public any Native_FF2_SetBossRageDamage(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	if (!player.Valid )
		return false;
	int damage = GetNativeCell(2);
	player.iRageDmg = damage;
	return true;
}

/** int FF2_GetClientDamage(int client); */
public int Native_FF2_GetClientDamage(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	return player.Valid ? player.GetPropInt("iDamage"):0;
}

/** void FF2_SetClientDamage(int client, int val); */
public int Native_FF2_SetClientDamage(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	return player.Valid ? player.SetPropInt("iDamage", GetNativeCell(2)):false;
}

/** float FF2_GetRageDist(int boss=0, const char[] pluginName="", const char[] abilityName=""); */
public any Native_FF2_GetRageDist(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	if( !player.Valid )
		return 0.0;
	
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));
	
	if( ability_name[0]==0 ) {
		float f;
		/// GetFloat + GetInt return number of characters used in conversion.
		return( player.iCfg.GetFloat("ragedist", f) > 0 ) ? f : 0.0;
	}
	
	ConfigMap section = JumpToAbility(player, plugin_name, ability_name);
	float see;
	if( !section.GetFloat("dist", see) ) {
		section.GetFloat("ragedist", see);
	}
	
	return see;
}

/** bool FF2_HasAbility(int boss, const char[] pluginName, const char[] abilityName); */
public any Native_FF2_HasAbility(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	if( !player.Valid )
		return false;
	
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));
	
	bool result = JumpToAbility(player, plugin_name, ability_name) != null;
	
	return result;
}

/** bool FF2_DoAbility(int boss, const char[] pluginName, const char[] abilityName, int slot, int buttonMode=0); */
public any Native_FF2_DoAbility(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	if( !player.Valid )
		return ThrowNativeError(SP_ERROR_NATIVE, "[VSH2/FF2] Invalid boss index (%d) for FF2_DoAbility()!", player);
	
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));
	
//	int slot = GetNativeCell(4);
//	int button = GetNativeCell(5);
	///TODO	
//	Call_FF2OnAbility(player, plugin_name, ability_name, boss, slot, button);

	return 0;
}

/** int FF2_GetAbilityArgument(int boss, const char[] pluginName, const char[] abilityName, int argument, int defValue=0); */
public int Native_FF2_GetAbilityArgument(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));
	char argument[8]; int key = GetNativeCell(4); FormatEx(argument, sizeof(argument), "arg%i", key);
	
	int defval = GetNativeCell(5);
	
	return GetArgNamedI(boss, plugin_name, ability_name, argument, defval);
}

/** float FF2_GetAbilityArgumentFloat(int boss, const char[] plugin_name, const char[] ability_name, int argument, float defValue=0.0); */
public any Native_FF2_GetAbilityArgumentFloat(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));
	char argument[8]; int key = GetNativeCell(4); FormatEx(argument, sizeof(argument), "arg%i", key);
	
	float defval = GetNativeCell(5);
	
	return GetArgNamedF(boss, plugin_name, ability_name, argument, defval);
}

/** void FF2_GetAbilityArgumentString(int boss, const char[] pluginName, const char[] abilityName, int argument, char[] buffer, int bufferLength); */
public any Native_FF2_GetAbilityArgumentString(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));
	char argument[8]; int key = GetNativeCell(4); FormatEx(argument, sizeof(argument), "arg%i", key);
	int length; length = GetNativeCell(6);
	char[] result = new char[length];
	
	int res = GetArgNamedS(boss, plugin_name, ability_name, argument, result, length);
	if ( res )
		SetNativeString(5, result, length);
	
	return res;
}

/** int FF2_GetArgNamedI(int boss, const char[] pluginName, const char[] abilityName, const char[] argument, int defValue=0); */
public int Native_FF2_GetArgNamedI(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));
	char argument[32]; GetNativeString(4, argument, sizeof(argument));
	
	int defval = GetNativeCell(5);
	
	return GetArgNamedI(boss, plugin_name, ability_name, argument, defval);
}

/** float FF2_GetArgNamedF(int boss, const char[] plugin_name, const char[] ability_name, const char[] argument, float defValue=0.0); */
public any Native_FF2_GetArgNamedF(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));
	char argument[32]; GetNativeString(4, argument, sizeof(argument));
	
	float defval = GetNativeCell(5);
	
	return GetArgNamedF(boss, plugin_name, ability_name, argument, defval);
}

/** void FF2_GetArgNamedS(int boss, const char[] pluginName, const char[] abilityName, const char[] argument, char[] buffer, int bufferLength); */
public any Native_FF2_GetArgNamedS(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	
	char plugin_name[64]; GetNativeString(2, plugin_name, sizeof(plugin_name));
	char ability_name[64]; GetNativeString(3, ability_name, sizeof(ability_name));
	char argument[32]; GetNativeString(4, argument, sizeof(argument));
	int length; length = GetNativeCell(6);
	char[] result = new char[length];
	
	int res = GetArgNamedS(boss, plugin_name, ability_name, argument, result, length);
	if ( res )
		SetNativeString(5, result, length);
	
	return res;
}

/** bool FF2_RandomSound(const char[] keyvalue, char[] buffer, int bufferLength, int boss=0); */ /* int slot=0*/
public any Native_FF2_RandomSound(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(4));
	if( !player.Valid )
		return ThrowNativeError(SP_ERROR_NATIVE, "[VSH2/FF2] Invalid boss index (%d) for FF2_DoAbility()!", player);
	
//	int slot = GetNativeCell(5);
	int size = GetNativeCell(3) + 1;
	char[] sound = new char[size];
	
	int key_size; GetNativeStringLength(1, key_size); ++key_size;

	char[] key = new char[key_size];
	GetNativeString(1, key, key_size);

	static FF2Identity identity;
	if ( !ff2_cfgmgr.FindIdentity(player.GetPropInt("iBossType"), identity) )
		return 0;
	
	bool soundExists;
	FF2SoundList list = identity.sndHash.GetAssertedList(key);
	if ( list ) {
		soundExists = list.RandomString(sound, size);
	}
	if ( !soundExists ) return false;
	return SetNativeString(2, sound, size) == SP_ERROR_NONE;
}

/** void FF2_StartMusic(int client=0); */
public any Native_FF2_StartMusic(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	if( !player.Valid )
		return 0;
	player.PlayMusic(vsh2cvars.m_flmusicvol.FloatValue);
	return 0;
}

/** void FF2_StopMusic(int client=0); */
public any Native_FF2_StopMusic(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	if( !player.Valid )
		return 0;
	player.StopMusic();
	return 0;
}

/** Handle FF2_GetBossKV(int boss=0); */
public any Native_FF2_GetBossKV(Handle plugin, int numParams)
{
	/// Return null KV for now.
	return 0;
}

/** Handle FF2_GetSpecialKV(int boss, int specialIndex=0); */
public any Native_FF2_GetSpecialKV(Handle plugin, int numParams)
{
	/// Return null KV for now.
	return 0;
}

/** int FF2_GetFF2flags(int client); */
public int Native_FF2_GetFF2flags(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	if( !player.Valid )
		return 0;
	
	return player.iFlags;
}

/** void FF2_SetFF2flags(int client, int flags); */
public any Native_FF2_SetFF2flags(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	if( !player.Valid )
		return 0;
	
	int flags = GetNativeCell(2);
	return player.iFlags = flags;
}

/** float FF2_GetClientGlow(int client); */
public any Native_FF2_GetClientGlow(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	if( !player.Valid )
		return 0.0;
	
	if(!GetEntProp(player.index, Prop_Send, "m_bGlowEnabled"))
		return 0.0;
	
	return (player.GetPropFloat("flGlowtime"));
}

/** void FF2_SetClientGlow(int client, float time1, float time2=-1.0); */
public any Native_FF2_SetClientGlow(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	if( !player.Valid )
		return 0;
	
	float time1 = GetNativeCell(2);
	float time2 = GetNativeCell(3);
	float glowt = player.GetPropFloat("flGlowtime");
	player.SetPropFloat("flGlowtime", glowt + time1);
	
	if( time2 > 0.0 )
		player.SetPropFloat("flGlowtime", time2);
	
	return 0;
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

/** float FF2_GetClientShield(int client); */
public any Native_FF2_GetClientShieldHealth(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	if( !player.Valid )
		return 0;
	
	return (player.iShieldId == -1) ? -1:RoundFloat(player.iShieldHP);
}

/** void FF2_SetClientShield(int client, int entity=0, float health=0.0, float reduction=-1.0); */
public any Native_FF2_SetClientShield(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	if( !player.Valid )
		return false;
	
	int shield = GetNativeCell(2);
	if( !IsValidEntity(shield) )
		return false;
		
	float health = GetNativeCell(3);
	
	player.iShieldId = ( GetOwner(shield)!=player.index || shield==0 ) ? player.iShieldId : EntIndexToEntRef(shield);
	player.iShieldHP = health;
	
	return true;
}

/** bool FF2_RemoveClientShield(int client); */
public any Native_FF2_RemoveClientShield(Handle plugin, int numParams)
{
	FF2Player player = FF2Player(GetNativeCell(1));
	if( !player.Valid )
		return 0;
	
	player.iShieldHP = 0.0;
	
	int shield = TF2_GetWearable(player.index, TFWeaponSlot_Secondary);
	if( shield == -1 || player.iShieldId == -1 )
		return false;
	
	TF2_RemoveWearable(player.index, shield);
	player.iShieldId = -1;
	
	return true;
}

/** TODO void FF2_MakeBoss(int client, int boss, int special=-1, bool rival=false); */
public any Native_FF2_MakeBoss(Handle plugin, int numParams)
{
	return 0;
}

/** TODO bool FF2_SelectBoss(int client, const char[] boss, bool access=true); */
public any Native_FF2_SelectBoss(Handle plugin, int numParams)
{
	return 0;
}

/** ConfigMap FF2_GetSpecialConfig(int boss=0, bool meaning=false); */
public any Native_FF2_GetSpecialConfig(Handle plugin, int numParams)
{
//	TODO
//	int index = GetNativeCell(1);
//	bool meaning = GetNativeCell(2);
//	return GetFF2Config(index);
}

/** TODO ZZZZZZZZZZZZZZZZZZZZZZZZZZZ */
/*
public any Native_ZZZ(Handle plugin, int numParams)
{
	return 0;
}
*/
