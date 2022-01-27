#include <morecolors>
#include <tf2_stocks>

#undef REQUIRE_PLUGIN
#include <vsh2>
#define REQUIRE_PLUGIN
#include <sdkhooks>

#define PLUGIN_VERSION "1.0.1"

#include <freak_fortress_2>
#include <cfgmap>

#pragma semicolon        1
#pragma newdecls         required

public Plugin myinfo = {
	name           = "VSH2/FF2 Backwards Compatibility Engine",
	author         = "01Pollux",
	description    = "Forward Old FF2 Plugins to be compatible with VSH2",
	version        = PLUGIN_VERSION,
	url            = "https://github.com/VSH2-Devs/Vs-Saxton-Hale-2"
};

enum struct BossKVData_t
{
	int	VSH2ID;
	KeyValues KV;
}

methodmap BossKVWrapper_t < ArrayList
{
	public BossKVWrapper_t() {
		return view_as<BossKVWrapper_t>(new ArrayList(sizeof(BossKVData_t)));
	}

	public KeyValues FindOrCreate(FF2Player player) {
		BossKVData_t data;
		int boss_id = player.GetPropInt("iBossType");

		for( int i=this.Length-1; i>=0; i-- ) {
			this.GetArray(i, data);
			if( data.VSH2ID==boss_id ) {
				return data.KV;
			}
		}

		char config_path[PLATFORM_MAX_PATH];
		player.GetConfigName(config_path, sizeof(config_path));
		BuildPath(Path_SM, config_path, sizeof(config_path), "configs/freak_fortress_2/%s.cfg", config_path);

		data.VSH2ID = boss_id;
		data.KV = new KeyValues("character");
		data.KV.ImportFromFile(config_path);

		this.PushArray(data);
		return data.KV;
	}

	public void ClearKVs() {
		BossKVData_t data;

		for( int i=this.Length; i>=0; i-- ) {
			this.GetArray(i, data);
			delete data.KV;
		}

		this.Clear();
	}
}
BossKVWrapper_t BossKVWrapper;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("FF2_IsFF2Enabled",				Native_IsEnabled);
	CreateNative("FF2_GetFF2Version",				Native_FF2Version);
	CreateNative("FF2_IsBossVsBoss",				Native_IsVersus);
	CreateNative("FF2_GetForkVersion",				Native_ForkVersion);
	CreateNative("FF2_GetBossUserId",				Native_GetBoss);
	CreateNative("FF2_GetBossIndex",				Native_GetIndex);
	CreateNative("FF2_GetBossTeam",					Native_GetTeam);
	CreateNative("FF2_GetBossSpecial",				Native_GetSpecial);
	CreateNative("FF2_GetBossName",					Native_GetBossName);
	CreateNative("FF2_GetBossHealth",				Native_GetBossHealth);
	CreateNative("FF2_SetBossHealth", 				Native_SetBossHealth);
	CreateNative("FF2_GetBossMaxHealth", 			Native_GetBossMaxHealth);
	CreateNative("FF2_SetBossMaxHealth",			Native_SetBossMaxHealth);
	CreateNative("FF2_GetBossLives", 				Native_GetBossLives);
	CreateNative("FF2_SetBossLives", 				Native_SetBossLives);
	CreateNative("FF2_GetBossMaxLives", 			Native_GetBossMaxLives);
	CreateNative("FF2_SetBossMaxLives", 			Native_SetBossMaxLives);
	CreateNative("FF2_GetBossCharge", 				Native_GetBossCharge);
	CreateNative("FF2_SetBossCharge", 				Native_SetBossCharge);
	CreateNative("FF2_GetBossRageDamage", 			Native_GetBossRageDamage);
	CreateNative("FF2_SetBossRageDamage", 			Native_SetBossRageDamage);
	CreateNative("FF2_GetClientDamage", 			Native_GetDamage);
	CreateNative("FF2_GetRoundState", 				Native_GetRoundState);
	CreateNative("FF2_GetSpecialKV", 				Native_GetSpecialKV);
	CreateNative("FF2_StartMusic", 					Native_StartMusic);
	CreateNative("FF2_StopMusic", 					Native_StopMusic);
	CreateNative("FF2_GetRageDist", 				Native_GetRageDist);
	CreateNative("FF2_HasAbility", 					Native_HasAbility);
	CreateNative("FF2_DoAbility", 					Native_DoAbility);
	CreateNative("FF2_GetAbilityArgument", 			Native_GetAbilityArgument);
	CreateNative("FF2_GetAbilityArgumentFloat", 	Native_GetAbilityArgumentFloat);
	CreateNative("FF2_GetAbilityArgumentString", 	Native_GetAbilityArgumentString);
	CreateNative("FF2_GetArgNamedI", 				Native_GetArgNamedI);
	CreateNative("FF2_GetArgNamedF", 				Native_GetArgNamedF);
	CreateNative("FF2_GetArgNamedS", 				Native_GetArgNamedS);
	CreateNative("FF2_RandomSound", 				Native_RandomSound);
	CreateNative("FF2_GetFF2flags", 				Native_GetFF2flags);
	CreateNative("FF2_SetFF2flags", 				Native_SetFF2flags);
	CreateNative("FF2_GetQueuePoints", 				Native_GetQueuePoints);
	CreateNative("FF2_SetQueuePoints", 				Native_SetQueuePoints);
	CreateNative("FF2_GetClientGlow", 				Native_GetClientGlow);
	CreateNative("FF2_SetClientGlow", 				Native_SetClientGlow);
	CreateNative("FF2_LogError", 					Native_LogError);
	CreateNative("FF2_Debug", 						Native_Debug);
	CreateNative("FF2_GetCheats", 					Native_GetCheats);
	CreateNative("FF2_SetCheats", 					Native_SetCheats);
	CreateNative("FF2_MakeBoss",					Native_MakeBoss);
	CreateNative("FF2_ReportError", 				Native_ReportError);
	return APLRes_Success;
}

public void OnPluginStart()
{
	BossKVWrapper = new BossKVWrapper_t();
}

public void OnLibraryAdded(const char[] name)
{
	if( !strcmp(name, "VSH2") ) {
		VSH2_Hook(OnRoundEndInfo, OnRoundEnd);
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if( !strcmp(name, "VSH2") ) {
		if (BossKVWrapper.Length)
			BossKVWrapper.ClearKVs();
		VSH2_Unhook(OnRoundEndInfo, OnRoundEnd);
	}
}

#if !defined FF2_USING_AUTO_PLUGIN__OLD

enum {
	FF2FLAG_UBERREADY            = (1<<1),  /// Used when medic says "I'm charged!"
	FF2FLAG_ISBUFFED             = (1<<2),  /// Used when soldier uses the Battalion's Backup
	FF2FLAG_CLASSTIMERDISABLED   = (1<<3),  /// Used to prevent clients' timer
	FF2FLAG_HUDDISABLED          = (1<<4),  /// Used to prevent custom hud from clients' timer
	FF2FLAG_BOTRAGE              = (1<<5),  /// Used by bots to use Boss's rage
	FF2FLAG_TALKING              = (1<<6),  /// Used by Bosses with "sound_block_vo" to disable block for some lines
	FF2FLAG_ALLOWSPAWNINBOSSTEAM = (1<<7),  /// Used to allow spawn players in Boss's team
	FF2FLAG_USEBOSSTIMER         = (1<<8),  /// Used to prevent Boss's timer
	FF2FLAG_USINGABILITY         = (1<<9),  /// Used to prevent Boss's hints about abilities buttons
	FF2FLAG_CLASSHELPED          = (1<<10),
	FF2FLAG_HASONGIVED           = (1<<11),
	FF2FLAG_CHANGECVAR           = (1<<12), /// Used to prevent SMAC from kicking bosses who are using certain rages (NYI)
	FF2FLAG_ALLOW_HEALTH_PICKUPS = (1<<13), /// Used to prevent bosses from picking up health
	FF2FLAG_ALLOW_AMMO_PICKUPS   = (1<<14), /// Used to prevent bosses from picking up ammo
	FF2FLAG_ROCKET_JUMPING       = (1<<15), /// Used when a soldier is rocket jumping
	FF2FLAG_ALLOW_BOSS_WEARABLES = (1<<16), /// Used to allow boss having wearables (only for Official FF2)
	FF2FLAGS_SPAWN = ~FF2FLAG_UBERREADY
					& ~FF2FLAG_ISBUFFED
					& ~FF2FLAG_TALKING
					& ~FF2FLAG_ALLOWSPAWNINBOSSTEAM
					& ~FF2FLAG_CHANGECVAR
					& ~FF2FLAG_ROCKET_JUMPING
					& FF2FLAG_USEBOSSTIMER
					& FF2FLAG_USINGABILITY,
};

#endif


stock void OnRoundEnd(const VSH2Player player, bool bossBool, char message[MAXMESSAGE])
{
	if (BossKVWrapper.Length)
		BossKVWrapper.ClearKVs();
}


any Native_IsEnabled(Handle plugin, int numParams)
{
	return FF2_IsFF2Enabled();
}

any Native_FF2Version(Handle plugin, int numParams)
{
	int version[3];
	FF2_GetFF2Version(version);
	SetNativeArray(1, version, sizeof(version));
}

any Native_IsVersus(Handle plugin, int numParams)
{
	return false;
}

any Native_ForkVersion(Handle plugin, int numParams)
{
	int version[3];
	bool ret = FF2_GetForkVersion(version);
	SetNativeArray(1, version, sizeof(version));
	return ret;
}

any Native_GetBoss(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	return FF2_GetBossUserId(boss);
}

any Native_GetIndex(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	return FF2_GetBossIndex(client);
}

any Native_GetTeam(Handle plugin, int numParams)
{
	return FF2_GetBossTeam();
}

any Native_GetSpecial(Handle plugin, int numParams)
{
	int buflen = GetNativeCell(3);
	char[] buf = new char[buflen];

	if( FF2_GetBossSpecial(GetNativeCell(1), buf, buflen, GetNativeCell(4)) ) {
		SetNativeString(2, buf, buflen);
		return true;
	}
	else return false;
}

any Native_GetBossName(Handle plugin, int numParams)
{
	int buflen = GetNativeCell(3);
	char[] buf = new char[buflen];

	if( FF2_GetBossSpecial(GetNativeCell(1), buf, buflen, GetNativeCell(4)) ) {
		SetNativeString(2, buf, buflen);
		return true;
	}
	else return false;
}

any Native_GetBossHealth(Handle plugin, int numParams)
{
	return FF2_GetBossHealth(GetNativeCell(1));
}

any Native_SetBossHealth(Handle plugin, int numParams)
{
	FF2_SetBossHealth(GetNativeCell(1), GetNativeCell(2));
}

any Native_GetBossMaxHealth(Handle plugin, int numParams)
{
	return FF2_GetBossMaxHealth(GetNativeCell(1));
}

any Native_SetBossMaxHealth(Handle plugin, int numParams)
{
	FF2_SetBossMaxHealth(GetNativeCell(1), GetNativeCell(2));
}

any Native_GetBossLives(Handle plugin, int numParams)
{
	return FF2_GetBossLives(GetNativeCell(1));
}

any Native_SetBossLives(Handle plugin, int numParams)
{
	FF2_SetBossLives(GetNativeCell(1), GetNativeCell(2));
}

any Native_GetBossMaxLives(Handle plugin, int numParams)
{
	return FF2_GetBossMaxLives(GetNativeCell(1));
}

any Native_SetBossMaxLives(Handle plugin, int numParams)
{
	FF2_SetBossMaxLives(GetNativeCell(1), GetNativeCell(2));
}

any Native_GetBossCharge(Handle plugin, int numParams)
{
	FF2_GetBossCharge(GetNativeCell(1), GetNativeCell(2));
}

any Native_SetBossCharge(Handle plugin, int numParams)
{
	FF2_SetBossCharge(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3));
}

any Native_GetBossRageDamage(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	return player.GetPropFloat("flRageDamage");
}

any Native_SetBossRageDamage(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	player.SetPropFloat("flRageDamage", GetNativeCell(2));
}

any Native_GetDamage(Handle plugin, int numParams)
{
	return FF2_GetClientDamage(GetNativeCell(1));
}

any Native_GetRoundState(Handle plugin, int numParams)
{
	return FF2_GetRoundState();
}

any Native_GetSpecialKV(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);
	FF2Player player = boss ? FF2Player(boss) : FF2_ZeroBossToFF2Player();
	if( !player.bIsBoss || GetNativeCell(2) )
		return 0;
	else
		return BossKVWrapper.FindOrCreate(player);
}

any Native_StartMusic(Handle plugin, int numParams)
{
	char bgm[PLATFORM_MAX_PATH];
	GetNativeString(2, bgm, sizeof(bgm));
	FF2_StartMusic(GetNativeCell(1), bgm);
}

any Native_StopMusic(Handle plugin, int numParams)
{
	FF2_StopMusic(GetNativeCell(1));
}

any Native_GetRageDist(Handle plugin, int numParams)
{
	char pl_name[FF2_MAX_PLUGIN_NAME];
	char ab_name[FF2_MAX_ABILITY_NAME];
	GetNativeString(2, pl_name, sizeof(pl_name));
	GetNativeString(3, ab_name, sizeof(ab_name));
	return FF2_GetRageDist(GetNativeCell(1), pl_name, ab_name);
}

any Native_HasAbility(Handle plugin, int numParams)
{
	char pl_name[FF2_MAX_PLUGIN_NAME];
	char ab_name[FF2_MAX_ABILITY_NAME];
	GetNativeString(2, pl_name, sizeof(pl_name));
	GetNativeString(3, ab_name, sizeof(ab_name));
	return FF2_HasAbility(GetNativeCell(1), pl_name, ab_name);
}

any Native_DoAbility(Handle plugin, int numParams)
{
	char pl_name[FF2_MAX_PLUGIN_NAME];
	char ab_name[FF2_MAX_ABILITY_NAME];
	GetNativeString(2, pl_name, sizeof(pl_name));
	GetNativeString(3, ab_name, sizeof(ab_name));
	FF2_DoAbility(GetNativeCell(1), pl_name, ab_name, GetNativeCell(4));
}

any Native_GetAbilityArgument(Handle plugin, int numParams)
{
	char pl_name[FF2_MAX_PLUGIN_NAME];
	char ab_name[FF2_MAX_ABILITY_NAME];
	GetNativeString(2, pl_name, sizeof(pl_name));
	GetNativeString(3, ab_name, sizeof(ab_name));
	return FF2_GetAbilityArgument(GetNativeCell(1), pl_name, ab_name, GetNativeCell(4), GetNativeCell(5));
}

any Native_GetAbilityArgumentFloat(Handle plugin, int numParams)
{
	char pl_name[FF2_MAX_PLUGIN_NAME];
	char ab_name[FF2_MAX_ABILITY_NAME];
	GetNativeString(2, pl_name, sizeof(pl_name));
	GetNativeString(3, ab_name, sizeof(ab_name));
	return FF2_GetAbilityArgumentFloat(GetNativeCell(1), pl_name, ab_name, GetNativeCell(4), GetNativeCell(5));
}

any Native_GetAbilityArgumentString(Handle plugin, int numParams)
{
	char pl_name[FF2_MAX_PLUGIN_NAME];
	char ab_name[FF2_MAX_ABILITY_NAME];
	GetNativeString(2, pl_name, sizeof(pl_name));
	GetNativeString(3, ab_name, sizeof(ab_name));

	int buflen = GetNativeCell(6);
	char[] buf = new char[buflen];
	FF2_GetAbilityArgumentString(GetNativeCell(1), pl_name, ab_name, GetNativeCell(4), buf, buflen);
	SetNativeString(5, buf, buflen);
}

any Native_GetArgNamedI(Handle plugin, int numParams)
{
	char pl_name[FF2_MAX_PLUGIN_NAME];
	char ab_name[FF2_MAX_ABILITY_NAME];
	GetNativeString(2, pl_name, sizeof(pl_name));
	GetNativeString(3, ab_name, sizeof(ab_name));

	int keylen;
	GetNativeStringLength(1, keylen); ++keylen;
	char[] key = new char[keylen];
	GetNativeString(4, key, keylen);
	return FF2_GetArgNamedI(GetNativeCell(1), pl_name, ab_name, key, GetNativeCell(5));
}

any Native_GetArgNamedF(Handle plugin, int numParams)
{
	char pl_name[FF2_MAX_PLUGIN_NAME];
	char ab_name[FF2_MAX_ABILITY_NAME];
	GetNativeString(2, pl_name, sizeof(pl_name));
	GetNativeString(3, ab_name, sizeof(ab_name));

	int keylen;
	GetNativeStringLength(1, keylen); ++keylen;
	char[] key = new char[keylen];
	GetNativeString(4, key, keylen);
	return FF2_GetArgNamedF(GetNativeCell(1), pl_name, ab_name, key, GetNativeCell(5));
}

any Native_GetArgNamedS(Handle plugin, int numParams)
{
	char pl_name[FF2_MAX_PLUGIN_NAME];
	char ab_name[FF2_MAX_ABILITY_NAME];
	GetNativeString(2, pl_name, sizeof(pl_name));
	GetNativeString(3, ab_name, sizeof(ab_name));

	int keylen;
	GetNativeStringLength(1, keylen); ++keylen;
	char[] key = new char[keylen];
	GetNativeString(4, key, keylen);

	int buflen = GetNativeCell(6);
	char[] buf = new char[buflen];
	FF2_GetArgNamedS(GetNativeCell(1), pl_name, ab_name, key, buf, buflen);
	SetNativeString(5, buf, buflen);
}

any Native_RandomSound(Handle plugin, int numParams)
{
	int keylen;
	GetNativeStringLength(1, keylen); ++keylen;
	char[] key = new char[keylen];
	GetNativeString(1, key, keylen);

	int buflen = GetNativeCell(3);
	char[] buf = new char[buflen];
	bool ret = FF2_RandomSound(key, buf, buflen, GetNativeCell(4), GetNativeCell(5));
	SetNativeString(2, buf, buflen);

	return ret;
}

any Native_GetFF2flags(Handle plugin, int numParams)
{
	return FF2_GetFF2flags(GetNativeCell(1));
}

any Native_SetFF2flags(Handle plugin, int numParams)
{
	FF2_SetFF2flags(GetNativeCell(1), GetNativeCell(2));
}

any Native_GetQueuePoints(Handle plugin, int numParams)
{
	return FF2_GetQueuePoints(GetNativeCell(1));
}

any Native_SetQueuePoints(Handle plugin, int numParams)
{
	FF2_SetQueuePoints(GetNativeCell(1), GetNativeCell(2));
}

any Native_GetClientGlow(Handle plugin, int numParams)
{
	return FF2_GetClientGlow(GetNativeCell(1));
}

any Native_SetClientGlow(Handle plugin, int numParams)
{
	FF2_SetClientGlow(GetNativeCell(1), GetNativeCell(2));
}

any Native_LogError(Handle plugin, int numParams)
{
	char buffer[PLATFORM_MAX_PATH];
	int error = FormatNativeString(0, 1, 2, sizeof(buffer), _, buffer);
	if (error != SP_ERROR_NONE)
		ThrowNativeError(error, "Failed to format.");
	else FF2GameMode.LogError(buffer);
}

any Native_Debug(Handle plugin, int numParams)
{
	return FF2_Debug();
}

any Native_GetCheats(Handle plugin, int numParams)
{
	return FF2_GetCheats();
}

any Native_SetCheats(Handle plugin, int numParams)
{
	FF2_SetCheats(GetNativeCell(1));
}

any Native_MakeBoss(Handle plugin, int numParams)
{
	int keylen;
	GetNativeStringLength(2, keylen); ++keylen;
	char[] key = new char[keylen];
	GetNativeString(2, key, keylen);

	return FF2_MakeBoss(GetNativeCell(1), key, GetNativeCell(3));
}

any Native_ReportError(Handle plugin, int numParams)
{
	char buffer[PLATFORM_MAX_PATH];
	int error = FormatNativeString(0, 2, 3, sizeof(buffer), _, buffer);
	if (error != SP_ERROR_NONE)
		ThrowNativeError(error, "Failed to format.");
	else FF2GameMode.ReportError(FF2Player(GetNativeCell(1)), buffer);
}

static FF2Player FF2_ZeroBossToFF2Player()
{
	FF2Player[] players = new FF2Player[MaxClients];
	return VSH2GameMode.GetBosses(ToFF2Player(players), false) < 1 ? INVALID_FF2PLAYER : players[0];
}