#define INVALID_FF2_BOSS_ID -1
#define INVALID_FF2PLAYER	view_as<FF2Player>(-1)

#define ToFF2Player(%0)			view_as<FF2Player>(%0)
#define ClientToBossIndex(%0) 	view_as<int>(%0)

#define IsClientValid(%1)    ( 0 < (%1) && (%1) <= MaxClients && IsClientInGame((%1)) )

/// a dynamic hash map, that holds cfg path to aiblities. eg: { { "pl_name##ab_name", "ability1" }, { "pl_name##ab_name", "ability2" }, ... }
methodmap FF2AbilityList < StringMap {
	public FF2AbilityList() {
		return view_as<FF2AbilityList>(new StringMap());
	}
	
	public void Insert(const char[] key, const char[] str) {
		this.SetString(key, str);
	}
	
	public static void GetKeyVal(const char[] key, char[][] pl_ab)
	{
		ExplodeString(key, "##", pl_ab, 2, MAX_SUBPLUGIN_NAME);
	}
}

methodmap FF2Player < VSH2Player {
	property bool Valid {
		public get() { return this != INVALID_FF2PLAYER; }
	}	
	public FF2Player(const int index, bool userid = false) {
		if( !index ) {
			return ZeroBossToFF2Player();
		}
		return view_as< FF2Player >(VSH2Player(index, userid));
	}
	
	property int iMaxLives {
		public get() {
			return this.GetPropInt("iMaxLives");
		}
		public set(int val) {
			this.SetPropInt("iMaxLives", val);
		}
	}
	
	property int iRageDmg {
		public get() {
			return this.GetPropInt("iRageDmg");
		}
		public set(int val) {
			this.SetPropInt("iRageDmg", val);
		}
	}
	
	property ConfigMap iCfg {
		public get() {
			return view_as<ConfigMap>(this.GetPropAny("iCfg"));
		}
		public set(ConfigMap cfg) {
			this.SetPropAny("iCfg", cfg);
		}
	}
	
	property int iShieldId {
		public get() {
			return this.GetPropInt("iShieldId");
		}
		public set(int val) {
			this.SetPropInt("iShieldId", val);
		}
	}
	
	property float iShieldHP {
		public get() {
			return this.GetPropFloat("iShieldHP");
		}
		public set(float val) {
			this.SetPropFloat("iShieldHP", val);
		}
	}
	
	property int iFlags {
		public get() {
			return this.GetPropInt("iFlags");
		}
		public set(int flag) {
			this.SetPropInt("iFlags", flag);
		}
	}
	
	property FF2AbilityList HookedAbilities {
		public get() {
			FF2AbilityList ab;
			return this.SetPropAny("hHookedAbilties", ab) ? ab:null;
		}
		public set(FF2AbilityList hk) {
			this.SetPropAny("hHookedAbilties", hk);
		}
	}
	
	public any GetRageInfo(m_iRageInfo Info) {
		switch( Info ) {
			case iRageMode: {
				return this.GetPropInt("iRageMode");
			}
			case iRageMin: {
				return this.GetPropFloat("iRageMin");
			}
			case iRageMax: {
				return this.GetPropInt("iRageMax");
			}
			default: {
				return 0;
			}
		}
	}
	
	public bool SetRageInfo(m_iRageInfo Info, any val) {
		switch( Info ) {
			case iRageMode: {
				return this.SetPropInt("iRageMode", val);
			}
			case iRageMin: {
				return this.SetPropFloat("iRageMin", val);
			}
			case iRageMax: {
				return this.SetPropFloat("iRageMax", val);
			}
			default: {
				return false;
			}
		}
	}
	
	public void PlayBGM(const char[] music) {
		this.PlayMusic(vsh2cvars.m_flmusicvol.FloatValue, music);
	}
	
	public void SetTimedOverlay(const char[] path, float time=0.0) {
		this.SetOverlay(path);
		if( time )
			CreateTimer(time, Timer_RemoveOverlay, GetClientSerial(this.index), TIMER_FLAG_NO_MAPCHANGE);
	}
}


/// dynamic array that holds sounds for key.
methodmap FF2SoundList < ArrayList
{
	property bool Empty {
		public get() {
			return this.Length == 0;
		}
	}
	
	public FF2SoundList()
	{
		return view_as<FF2SoundList>(new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH)));
	}
	
	public void At(int idx, char[] buffer, int maxlen)
	{
		this.GetString(idx, buffer, maxlen);
	}
	
	public bool RandomString(char[] buffer, int maxlen)
	{
		if(!this.Empty) {
			int rand = GetRandomInt(0, this.Length - 1);
			this.GetString(rand, buffer, maxlen);
			return true;
		}
		return false;
	}
}

/// a hash map that holds keys to sound list.
methodmap FF2SoundHash < StringMap 
{
	public FF2SoundHash()
	{
		return view_as<FF2SoundHash>(new StringMap());
	}
	
	public FF2SoundList GetOrCreateList(const char[] key)
	{
		FF2SoundList list;
		if(this.GetValue(key, list) && list) {
			return list;
		}
		
		list = new FF2SoundList();
		this.SetValue(key, list);
		return list;
	}
	
	public FF2SoundList GetAssertedList(const char[] key)
	{
		FF2SoundList list;
		if(this.GetValue(key, list) && list) {
			return list;
		}
		
		return null;
	}
	
	public void Delete(const char[] key)
	{
		FF2SoundList list;
		if(this.GetValue(key, list)) {
			delete list;
		}
		this.Remove(key);
	}
	
	public void DeleteAll()
	{
		StringMapSnapshot snap = this.Snapshot();
		
		char name[48];
		FF2SoundList list;
		
		for ( int i = snap.Length - 1; i >= 0; i-- ) {
			snap.GetKey(i, name, sizeof(name));
			if(this.GetValue(name, list)) {
				delete list;
			}
		}
		
		this.Clear();
		delete snap;
	}
}

enum struct FF2Identity
{
	int 			VSH2ID;
	ConfigMap 		hCfg;
	FF2SoundHash 	sndHash;
	FF2AbilityList 	ablist;
	char 			szName[48];
	char 			szPath[PLATFORM_MAX_PATH];
}


#define RELEASE_IDENTITY(%0) \
		identity.sndHash.DeleteAll(); \
		delete identity.sndHash; \
		DeleteCfg(identity.hCfg); \
		delete identity.ablist

static bool FF2_LoadCharacter(FF2Identity identity)
{
	///Precache HERE!
	char path[PLATFORM_MAX_PATH], key_name[PLATFORM_MAX_PATH];
	
	FormatEx(key_name, sizeof(key_name), "configs/freak_fortress_2/%s.cfg", identity.szName);
	BuildPath(Path_SM, path, sizeof(path), "%s", key_name);
	
	if(!FileExists(path)) {
		ThrowError("[!!!] Unable to find \"%s\"!", identity.szName);
	}
	
	strcopy(identity.szPath, sizeof(FF2Identity::szPath), path);
	ConfigMap cfg = new ConfigMap(key_name);
	
	if( !cfg) {
		LogError("[VSH2/FF2] Failed to find \"%s\" character!", identity.szName);
		return false;
	}
	
	/*
	TODO
	if(KvJumpToKey(BossKV[Specials], "map_exclude"))
	{
		char item[6];
		static char buffer[34];
		for(int size=1; ; size++)
		{
			FormatEx(item, sizeof(item), "map%d", size);
			KvGetString(BossKV[Specials], item, buffer, sizeof(buffer));
			if(!buffer[0])
				break;

			if(!StrContains(currentmap, buffer))
			{
				MapBlocked[Specials] = true;
				break;
			}
		}
	}
	*/
	
	char buffer[64];
	
	ConfigMap this_char = cfg.GetSection("character");
	identity.ablist = new FF2AbilityList();
	
	{
		ConfigMap cur_ab;
		int i;
		while( ++i < MAX_ABILITIES_PL ) {
			FormatEx(key_name, sizeof(key_name), "ability%i", i);
			
			cur_ab = this_char.GetSection(key_name);
			
			if( !cur_ab || !cur_ab.Get("plugin_name", buffer, sizeof(buffer)) )
				break;
			
			BuildPath(Path_SM, path, sizeof(path), "plugins/freaks/%s.ff2", buffer);
			if( !FileExists(path) ) {
				LogError("[VSH2/FF2] Character \"%s.cfg\" is missing \"%s\" subplugin!", identity.szName, path);
			} 
			else {
				cur_ab.Get("name", path, sizeof(path));
				Format(path, sizeof(path), "%s##%s", buffer, path);
				identity.ablist.Insert(path, key_name);
			}
		}
	}
	
	ConfigMap stacks = this_char.GetSection("download");
	if( stacks ) {
		StringMapSnapshot snap = stacks.Snapshot();
		int size = snap.Length;
		delete snap;
		
		while( size > 0 ) {
			IntToString(size--, key_name, 4);
			if( !this_char.Get(key_name, path, sizeof(path)) )
				break;
			
			if( !FileExists(path, true) ) {
				LogError("[VSH2/FF2] Character \"%s\" is missing file \"%s\"!", identity.szName, path);
			} else {
				AddFileToDownloadsTable(path);
			}
		}
	}
	
	static const char modelT[][] = {
		".mdl",
		".dx80.vtx",
		".dx90.vtx",
		".sw.vtx",
		".vvd",
		".phy"
	};
	
	stacks = this_char.GetSection("mod_download");
	if( stacks ) {
		StringMapSnapshot snap = stacks.Snapshot();
		int size = snap.Length;
		delete snap;
		
		while( size > 0 ) {
			IntToString(size--, key_name, 4);
			if( !stacks.Get(key_name, path, sizeof(path)) )
				break;
			
			for( int i = 0; i < sizeof(modelT); i++ ) {
				FormatEx(key_name, PLATFORM_MAX_PATH, "%s%s", path, modelT[i]);
				if( FileExists(key_name, true) ) {
					AddFileToDownloadsTable(key_name);
				}
				else if( StrContains(key_name, ".phy") == -1 ) {
					LogError("[VSH2/FF2] Character \"%s\" is missing file \"%s\"!", identity.szName, key_name);
				}
			}
		}
	} 
	else {
		stacks = this_char.GetSection("mat_download");
		if( stacks ) {
			StringMapSnapshot snap = stacks.Snapshot();
			int size = snap.Length;
			delete snap;
			
			while( size > 0 ) {
				IntToString(size--, key_name, 4);
				if( stacks.Get(key_name, path, sizeof(path)) )
					break;
					
				FormatEx(key_name, sizeof(key_name), "%s.vmt", path);
				if( !FileExists(key_name, true) ) {
					LogError("[VSH2/FF2] Character \"%s\" is missing file \"%s\"!", identity.szName, key_name);
				} else {
					AddFileToDownloadsTable(key_name);
				}
				
				FormatEx(key_name, sizeof(key_name), "%s.vtf", path);
				if( !FileExists(key_name, true) ) {
					LogError("[VSH2/FF2] Character \"%s\" is missing file \"%s\"!", identity.szName, key_name);
				} else {
					AddFileToDownloadsTable(key_name);
				}
			}
		}
	}
	
	/// Prepare Sound list
	{
		identity.sndHash = new FF2SoundHash();
		StringMapSnapshot snap = this_char.Snapshot();
		ConfigMap snd_list;
		FF2SoundList list;
		
		char curSection[32], snd_key[32];
		char strBuffer[PLATFORM_MAX_PATH];
		
		for(int i = snap.Length - 1; i >= 0; i--) {
			snap.GetKey(i, snd_key, sizeof(snd_key));
			
			if(!StrContains(snd_key, "sound")) {
				snd_list = this_char.GetSection(snd_key);
				list = identity.sndHash.GetOrCreateList(snd_key);
				
				for (int j = 1; j < 15; j++) {
					IntToString(j, curSection, 4);
					if(snd_list.Get(curSection, strBuffer, sizeof(strBuffer))) {
						list.PushString(strBuffer);
						PrepareSound(strBuffer);
					}
					else break;
				}
			}
		}
		
		delete snap;
	}
	
	identity.VSH2ID = FF2_RegisterFakeBoss(identity.szName);
	identity.hCfg = this_char;
	
	if ( identity.VSH2ID == INVALID_FF2_BOSS_ID ) {
		RELEASE_IDENTITY(identity);
		return false;
	}
	
	return true;
}


/// a hash map that holds boss' identities
methodmap FF2BossManager < StringMap
{
	public bool GetIdentity(const char[] name, FF2Identity identity)
	{
		return this.GetArray(name, identity, sizeof(FF2Identity)) ? true:false;
	}
	
	public FF2BossManager(const char[] pack_name)
	{
		StringMap map = new StringMap();
		
		/// Parse Boss CFG with pack name
		ConfigMap cfg = ff2.m_charcfg.GetSection(pack_name);
		
		if( !cfg ) ThrowError("Failed to find Section for characters.cfg: \"%s\"", pack_name);
		
		StringMapSnapshot snap = cfg.Snapshot();
		
		char key[4], name[48];
		FF2Identity curIdentity;
		
		/// Iter through the Pack, copy and verify boss path
		for ( int i = snap.Length - 1; i >= 0; i-- ) {
			snap.GetKey(i, key, sizeof(key));
			cfg.Get(key, name, sizeof(name));
			strcopy(curIdentity.szName, sizeof(FF2Identity::szName), name);
			if ( FF2_LoadCharacter(curIdentity) ) {
				map.SetArray(name, curIdentity, sizeof(FF2Identity));
			}
		}
		
		delete snap;
		return view_as<FF2BossManager>(map);
	}
	
	public void Delete(const char[] name)
	{
		FF2Identity identity;
		if(this.GetArray(name, identity, sizeof(FF2Identity))) {
			
			RELEASE_IDENTITY(identity);
			
			this.Remove(name);
		}
	}
	
	public void DeleteAll()
	{
		StringMapSnapshot snap = this.Snapshot();
		char name[48];
		FF2Identity identity;
		
		for ( int i = snap.Length - 1; i >= 0; i-- ) {
			snap.GetKey(i, name, sizeof(name));
			if(this.GetIdentity(name, identity)) {
				RELEASE_IDENTITY(identity);
			}
		}
		
		this.Clear();
		delete snap;
	}
	
	public bool FindIdentity(const int ID, FF2Identity identity)
	{
		StringMapSnapshot snap = this.Snapshot();
		char name[48];
		bool res;
		
		for ( int i = snap.Length - 1; i >= 0; i-- ) {
			snap.GetKey(i, name, sizeof(name));
			if(this.GetIdentity(name, identity) && identity.VSH2ID == ID) {
				res = true;
				break;
			}
		}
		
		delete snap;
		return res;
	}
	
	public bool FindIdentityByCfg(const ConfigMap cfg, FF2Identity identity)
	{
		StringMapSnapshot snap = this.Snapshot();
		char name[48];
		bool res;
		
		for ( int i = snap.Length - 1; i >= 0; i-- ) {
			snap.GetKey(i, name, sizeof(name));
			if(this.GetIdentity(name, identity) && identity.hCfg == cfg) {
				res = true;
				break;
			}
		}
		
		delete snap;
		return res;
	}
	
	public bool FindIdentityByName(const char[] name, FF2Identity identity)
	{
		StringMapSnapshot snap = this.Snapshot();
		char key_name[48];
		bool res;
		
		for ( int i = snap.Length - 1; i >= 0 && !res; i-- ) {
			snap.GetKey(i, key_name, sizeof(key_name));
			if(this.GetIdentity(key_name, identity) && !strcmp(name, identity.szName)) {
				res = true;
			}
		}
		
		delete snap;
		return res;
	}
}
FF2BossManager ff2_cfgmgr;



/*
stock int ClientToBossIndex(FF2Player client)
{
	FF2Player[] players = new FF2Player[MaxClients];
	int amount_of_bosses = VSH2GameMode.GetBosses(players, false);
	if( amount_of_bosses > 0 ) {
		for( int i; i<amount_of_bosses; i++ ) {
			if( players[i].index==client ) {
				if( i==0 )
					return 0;
				else return players[i].index;
			}
		}
	}
	return -1;
}
*/



stock FF2Player ZeroBossToFF2Player()
{
	FF2Player[] players = new FF2Player[MaxClients];
	if( VSH2GameMode.GetBosses(players, false) < 1 )
		return INVALID_FF2PLAYER;
	
	return players[0];
}

/*
stock ConfigMap GetFF2Config(const int index=0)
{
	int cfg_index = -1;
	if( is_cfg_index && index > -1 && index < ff2.m_bosscfgs.Length ) {
		cfg_index = index;
	} else if( IsClientValid(index) ) {
		FF2Player player = FF2Player(index);
		if( player.iCfg > -1 && player.iCfg < ff2.m_bosscfgs.Length )
			cfg_index = player.iCfg;
	}
	return( cfg_index != -1 ) ? ff2.m_bosscfgs.Get(cfg_index) : view_as<ConfigMap>(null);
}
*/

stock ConfigMap JumpToAbility(const FF2Player player, const char[] plugin_name, const char[] ability_name)
{
	FF2AbilityList list = player.HookedAbilities;
	
	char actual_key[128];
	FormatEx(actual_key, sizeof(actual_key), "%s##%s", plugin_name, ability_name);
	
	ConfigMap ability = null;
	char pos[24];
	if ( list.GetString(actual_key, pos, sizeof(pos)) ) {
		ability = player.iCfg.GetSection(pos);
	}
	return ability;
}

stock int GetArgNamedI(int boss, const char[] plugin_name, const char[] ability_name, const char[] argument, int defval = 0)
{
	ConfigMap section = JumpToAbility(FF2Player(boss), plugin_name, ability_name);
	if( section==null ) {
		return defval;
	}
	
	int result;
	return section.GetInt(argument, result) ? result:defval;
}

stock float GetArgNamedF(int boss, const char[] plugin_name, const char[] ability_name, const char[] argument, float defval = 0.0)
{
	ConfigMap section = JumpToAbility(FF2Player(boss), plugin_name, ability_name);
	if( section==null ) {
		return defval;
	}
	
	float result;
	return section.GetFloat(argument, result) ? result:defval;
}

stock int GetArgNamedS(int boss, const char[] plugin_name, const char[] ability_name, const char[] argument, char[] result, int &size)
{
	ConfigMap section = JumpToAbility(FF2Player(boss), plugin_name, ability_name);
	if( section==null ) {
		return 0;
	}
	return section.Get(argument, result, size);
}

stock void FPrintToChat(int client, const char[] message, any ...)
{
	SetGlobalTransTarget(client);
	char buffer[192];
	VFormat(buffer, sizeof(buffer), message, 3);
	CPrintToChat(client, "{olive}[VSH2/FF2]{default} %s",  buffer);
}

//TODO
/*
enum ChargeType_t {
	RAGE = 0,
	JUMP,
	WDOWN,
	DEMO,
}
*/
stock float FF2_GetCustomCharge(const FF2Player player, int slot)
{
	char ability_key[64];
	Format(ability_key, sizeof(ability_key), "ability%i.name", slot);
	ConfigMap config = player.iCfg;
	int len = config.GetSize(ability_key);
	char[] ability_name = new char[len];
	if( config.Get(ability_key, ability_name, len) ) {
		if( StrContains(ability_name, "weighdown", false) != -1 ) {
			return player.GetPropFloat("flWeighDown");
		} else if( StrContains(ability_name, "bravejump", false) != -1 ) {
			return player.GetPropFloat("flCharge");
		} else {
			char new_ability[64];
			Format(new_ability, sizeof(ability_key), "flCharge%i", slot);
			return player.GetPropFloat(new_ability);
		}
	}
	return 0.0;
}

stock bool FF2_SetCustomCharge(const FF2Player player, int slot, float value)
{
	char ability_key[64];
	Format(ability_key, sizeof(ability_key), "ability%i.name", slot);
	ConfigMap config = player.iCfg;
	int len = config.GetSize(ability_key);
	char[] ability_name = new char[len];
	if( config.Get(ability_key, ability_name, len) ) {
		if( StrContains(ability_name, "weighdown", false) != -1 ) {
			return player.SetPropFloat("flWeighDown", value);
		} else if( StrContains(ability_name, "bravejump", false) != -1 ) {
			return player.SetPropFloat("flCharge", value);
		} else {
			char new_ability[64];
			Format(new_ability, sizeof(ability_key), "flCharge%i", slot);
			return player.SetPropFloat(new_ability, value);
		}
	}
	return false;
}

stock int FF2_RegisterFakeBoss(const char[] name)
{
	if(	strlen(name) >= MAX_BOSS_NAME_SIZE - 6 )
		return INVALID_FF2_BOSS_ID;
	char final_name[MAX_BOSS_NAME_SIZE];
	FormatEx(final_name, sizeof(final_name), "%s_FF2", name);
	return VSH2_RegisterPlugin(final_name);
}

