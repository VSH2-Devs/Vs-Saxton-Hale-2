#define INVALID_FF2_BOSS_ID -1
#define INVALID_FF2PLAYER	view_as<FF2Player>(-1)

#define ToFF2Player(%0)			view_as<FF2Player>(%0)
#define ClientToBossIndex(%0) 	view_as<int>(%0)

#define IsClientValid(%1)    ( 0 < (%1) && (%1) <= MaxClients && IsClientInGame((%1)) )


enum FF2CallType_t
{
	CT_NONE		= 0b000000000,	// 	Inactive, default to CT_RAGE
	CT_LIFE_LOSS 	= 0b000000001,	
	CT_RAGE		= 0b000000010,
	CT_CHARGE	= 0b000000100,
	CT_UNUSED_DEMO 	= 0b000001000,	//	UNUSED
	CT_WEIGHDOWN	= 0b000010000,	
	CT_PLAYER_KILLED= 0b000100000,
	CT_BOSS_KILLED	= 0b001000000,
	CT_BOSS_STABBED	= 0b010000000,
	CT_BOSS_MG		= 0b100000000,
};

enum FF2RageType_t
{
	RT_RAGE = 0,
	RT_WEIGHDOWN,
	RT_CHARGE
};


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
		public get() { return this != INVALID_FF2PLAYER && this.index; }
	}
	
	public FF2Player(const int index, bool userid = false) {
		if( !index ) {
			return ZeroBossToFF2Player();
		}
		return view_as< FF2Player >(VSH2Player(index, userid));
	}
	
	property ConfigMap iCfg {
		public get() { 
			return GetFF2Config(this);
		}
	}
	
	property int iBossType {
		public get() { return this.GetPropInt("iBossType"); }
	}
	
	property float flRAGE {
		public get() {
			return this.GetPropFloat("flRAGE");
		}
		public set(const float val) {
			this.SetPropFloat("flRAGE", val);
		}
	}
	
	property int iLives {
		public get() {
			return this.GetPropInt("iLives");
		}
		public set(const int val) {
			this.SetPropInt("iLives", val);
		}
	}
	
	property int iMaxLives {
		public get() {
			return this.GetPropInt("iMaxLives");
		}
		public set(const int val) {
			this.SetPropInt("iMaxLives", val);
		}
	}
	
	property FF2AbilityList HookedAbilities {
		public get() {
			return GetFF2AbilityList(this);
		}
	}
	
	property bool bNoSuperJump {
		public get() { 
			return this.GetPropAny("bNoSuperJump");
		}
		public set(bool state) {
			this.SetPropAny("bNoSuperJump", state);
		}
	}
	
	property bool bNoWeighdown {
		public get() { 
			return this.GetPropAny("bNoWeighdown");
		}
		public set(bool state) {
			this.SetPropAny("bNoWeighdown", state);
		}
	}
	
	property bool bHideHUD {
		public get() { 
			return this.GetPropAny("bHideHUD");
		}
		public set(bool state) {
			this.SetPropAny("bHideHUD", state);
		}
	}
	
	public float GetRageVar(FF2RageType_t type) {
		switch( type ) {
			case RT_RAGE: 		return this.GetPropFloat("flRAGE");
			case RT_CHARGE: 	return this.GetPropFloat("flCharge");
			case RT_WEIGHDOWN: 	return this.GetPropFloat("flWeighDown");
			default: {
				static char key[64]; FormatEx(key, sizeof(key), "flCharge%i", type);
				return this.GetPropFloat(key);
			}
		}
	}
	
	public void SetRageVar(FF2RageType_t type, float val) {
		switch( type ) {
			case RT_RAGE: 		this.SetPropFloat("flRAGE", val);
			case RT_CHARGE: 	this.SetPropFloat("flCharge", val);
			case RT_WEIGHDOWN: 	this.SetPropFloat("flWeighDown", val);
			default: {
				static char key[64]; FormatEx(key, sizeof(key), "flCharge%i", type);
				this.SetPropFloat(key, val);
			}
		}
	}
	
	public void PlayBGM(const char[] music) {
		this.PlayMusic(ff2.m_cvars.m_flmusicvol.FloatValue, music);
	}
}

/**
 * FF2SoundIdentity:
 *
 * path = full song path name
 * name = > "slot*_*": <key position>_<value>
 * 		  > "song name"
 * artist = empty or contains artist's name
 * time = 0.0, or song duration
 */
enum struct FF2SoundIdentity  {
	char path[PLATFORM_MAX_PATH];
	char name[32];
	char artist[32];
	float time;
	
	void Init(const char[] path, float time, const char[] name = "Unknown Song", const char[] artist = "Unknown artist") {
		strcopy(this.path, sizeof(FF2SoundIdentity::path), path);
		strcopy(this.name, sizeof(FF2SoundIdentity::name), name);
		strcopy(this.artist, sizeof(FF2SoundIdentity::artist), artist);
		this.time = time;
	}
}

/**
 * FF2SoundList:
 *
 * Dynamic array of FF2SoundIdentity
 */
methodmap FF2SoundList < ArrayList
{
	property bool Empty {
		public get() {
			return this.Length == 0;
		}
	}
	
	public FF2SoundList()
	{
		return view_as<FF2SoundList>(new ArrayList(sizeof(FF2SoundIdentity)));
	}
	
	public bool At(int idx, FF2SoundIdentity snd_id)
	{
		return this.GetArray(idx, snd_id, sizeof(FF2SoundIdentity)) != 0;
	}
	
	public bool RandomSound(FF2SoundIdentity snd_id)
	{
		if(!this.Empty) {
			int rand = GetRandomInt(0, this.Length - 1);
			return this.At(rand, snd_id);
		}
		return false;
	}
	
	public bool Seek(const char[] path_name, FF2SoundIdentity snd_id)
	{
		if(!this.Empty) {
			for( int i = 0; i < this.Length; i++ ) {
				this.At(i, snd_id);
				if( !strcmp(path_name, snd_id.path) )
					return true;
			}
		}
		return false;
	}
}

/**
 * FF2SoundHash:
 *
 * Key: 	"sound_*"
 * Value: 	FF2SoundList
 */
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
	
	public FF2SoundList GetList(const char[] key)
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

/**
 * Boss identity struct
 *
 * VSH2ID = iBossType
 * sndHash = map of precached sounds to use instead of iterating through ConfigMap.Snapshot()
 * ablist = list of encoded abilities to use instead of iterating rought Snapshot, eg:
 *								[{ "plugin_name##ability_name", "ability*" }, { "plugin_name##ability_name", "ability**" }, ...)
 * szName = boss config name in character.cfg
 * szPath = pull path name
 */
enum struct FF2Identity {
	int 			VSH2ID;
	ConfigMap 		hCfg;
	FF2SoundHash 	sndHash;
	FF2AbilityList 	ablist;
	char 			szName[48];
	char 			szPath[PLATFORM_MAX_PATH];
}


#define RELEASE_IDENTITY(%0) \
		%0.sndHash.DeleteAll(); \
		delete %0.sndHash; \
		DeleteCfg(%0.hCfg); \
		delete %0.ablist


static bool FF2_LoadCharacter(FF2Identity identity)
{
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
	
	identity.VSH2ID = FF2_RegisterFakeBoss(identity.szName);
	if ( identity.VSH2ID == INVALID_FF2_BOSS_ID ) {
		DeleteCfg(cfg);
		return false;
	}
	
	char buffer[64];
	
	identity.hCfg = cfg;
	ConfigMap this_char = cfg.GetSection("character");
	identity.ablist = new FF2AbilityList();
	
	/// abilities*
	{
		ConfigMap cur_ab;
		
		StringMapSnapshot snap = this_char.Snapshot();
		
		for (int i = snap.Length - 1; i >= 0; i--) {
			snap.GetKey(i, key_name, sizeof(key_name));
			if ( strncmp(key_name, "ability", 7) )
				continue;
			
			cur_ab = this_char.GetSection(key_name);
			if ( !cur_ab || !cur_ab.Get("plugin_name", buffer, sizeof(buffer)) )
				continue;
			
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
		
		delete snap;
	}
	
	ConfigMap stacks;
	
	///	download
	{
		if( (stacks = this_char.GetSection("download")) ) {
			for (int i = stacks.Size - 1; i >= 0; i-- ) {
				IntToString(i, key_name, sizeof(key_name));
				if( !stacks.Get(key_name, path, sizeof(path)) )
					continue;
				
				if( !FileExists(path, true) ) {
					LogError("[VSH2/FF2] Character \"%s\" is missing file \"%s\"!", key_name, i, identity.szName, path); 
				} else {
					AddFileToDownloadsTable(path);
				}
			}
		}
	}
	
	
	/// mat/mod download
	{
		static const char modelT[][] = {
			".mdl",
			".dx80.vtx", 	".dx90.vtx",
			".sw.vtx",
			".vvd", 
			".phy"
		};
	
		if( (stacks = this_char.GetSection("mod_download")) ) {
			for (int i = stacks.Size - 1; i >= 0; i--) {
				IntToString(i, key_name, sizeof(key_name));
				if( !stacks.Get(key_name, path, sizeof(path)) )
					continue;
				
				for( int j = 0; j < sizeof(modelT); j++ ) {
					FormatEx(key_name, sizeof(key_name), "%s%s", path, modelT[j]);
					if( FileExists(key_name, true) ) {
						AddFileToDownloadsTable(key_name);
					}
					else if( StrContains(key_name, ".phy") == -1 ) {
						LogError("[VSH2/FF2] Character \"%s.cfg\" is missing file \"%s\"!", identity.szName, key_name);
					}
				}
			}
		} 
		if( (stacks = this_char.GetSection("mat_download")) ){
			for (int i = stacks.Size - 1; i >= 0; i--) {
				IntToString(i, key_name, sizeof(key_name));
				if( !stacks.Get(key_name, path, sizeof(path)) )
					continue;
				
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
		
		ConfigMap _list;
		FF2SoundList snd_list;
		FF2SoundIdentity snd_id;
		
		char curSection[32], _key[32];
		
		char strBuffer[PLATFORM_MAX_PATH];
		float time; int slot_type;
		char name[32], artist[32];
		
		for(int i = snap.Length - 1; i >= 0; i--) {
			snap.GetKey(i, _key, sizeof(_key));
			
			if(!StrContains(_key, "sound")) {
				_list = this_char.GetSection(_key);
				snd_list = identity.sndHash.GetOrCreateList(_key);
				
				bool bIsBGM = _list.Get("path1", strBuffer, sizeof(strBuffer)) > 0;
				
				for (int j = 1; j <= 15; j++) {
					if(bIsBGM) {
						Format(curSection, sizeof(curSection), "path%i", j); 
						if(!_list.Get(curSection, strBuffer, sizeof(strBuffer)))
					 		break;
					 	
						Format(curSection, sizeof(curSection), "time%i", j); 
					 	if(!_list.GetFloat(curSection, time))
					 		break;
					 	
						Format(curSection, sizeof(curSection), "name%i", j); 
					 	if ( !_list.Get(curSection, name, sizeof(name)) ) name = "Unknown Song";
						Format(curSection, sizeof(curSection), "artist%i", j); 
					 	if ( !_list.Get(curSection, artist, sizeof(artist)) ) name = "Unknown Artist";
					 	
						
						snd_id.Init(strBuffer, time, name, artist);
					 	snd_list.PushArray(snd_id, sizeof(FF2SoundIdentity));
					 	
					}
					else {
						IntToString(j, curSection, 2);
						 	
					 	if ( !_list.Get(curSection, strBuffer, sizeof(strBuffer)) )
					 		break;
					 	
					 	FormatEx(_key, sizeof(_key), "slot%i", j);
					 	if ( !_list.Get(_key, buffer, sizeof(buffer)) )
				 			slot_type = view_as<int>(CT_RAGE);
					 	else slot_type = StringToInt(buffer, 2);
						
					 	FormatEx(_key, sizeof(_key), "slot%i_%i", j, slot_type);
						
						snd_id.Init(strBuffer, 0.0, _key);
						snd_list.PushArray(snd_id, sizeof(FF2SoundIdentity));
					}
					
				}
			}
		}
		
		delete snap;
	}	
	return true;
}

/**
 * a hash map that holds boss' identities
 */
methodmap FF2BossManager < StringMap
{
	public bool GetIdentity(const char[] name, FF2Identity identity)
	{
		return this.GetArray(name, identity, sizeof(FF2Identity)) ? true:false;
	}
	
	public FF2BossManager(const char[] pack_name)
	{
		/// Parse Boss CFG with pack name
		ConfigMap cfg = ff2.m_charcfg.GetSection(pack_name);
		
		if( !cfg ) ThrowError("Failed to find Section for characters.cfg: \"%s\"", pack_name);
		
		StringMap map = new StringMap();
		
		char key[4], name[48];
		
		/// Iterate through the Pack, copy and verify boss path
		for ( int i = cfg.Size - 1; i >= 0; i-- ) {
			IntToString(i, key, sizeof(key));
			if( !cfg.Get(key, name, sizeof(name)) )
				continue;
			
			FF2Identity curIdentity;
			strcopy(curIdentity.szName, sizeof(FF2Identity::szName), name);
			
			if ( FF2_LoadCharacter(curIdentity) ) {
				map.SetArray(name, curIdentity, sizeof(FF2Identity));
			}
		}
		
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
			if( this.GetIdentity(name, identity) && identity.VSH2ID == ID ) {
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
			if( this.GetIdentity(name, identity) && identity.hCfg == cfg ) {
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
			if( this.GetIdentity(key_name, identity) && !strcmp(name, identity.szName) ) {
				res = true;
			}
		}
		
		delete snap;
		return res;
	}
}
FF2BossManager ff2_cfgmgr;


stock FF2Player ZeroBossToFF2Player()
{
	FF2Player[] players = new FF2Player[MaxClients];
	if( VSH2GameMode.GetBosses(players, false) < 1 )
		return INVALID_FF2PLAYER;
	
	return players[0];
}

stock ConfigMap JumpToAbility(const FF2Player player, const char[] plugin_name, const char[] ability_name)
{
	FF2AbilityList list = player.HookedAbilities;
	
	static char actual_key[128];
	FormatEx(actual_key, sizeof(actual_key), "%s##%s", plugin_name, ability_name);
	
	ConfigMap ability = null;
	static char pos[64];
	
	if ( list && list.GetString(actual_key, pos, sizeof(pos)) ) {
		ability = player.iCfg.GetSection(pos);
	}
	
	return ability;
}

stock int GetArgNamedI(FF2Player player, const char[] plugin_name, const char[] ability_name, const char[] argument, int defval = 0)
{
	ConfigMap section = JumpToAbility(player, plugin_name, ability_name);
	if( section==null ) {
		return defval;
	}
	
	int result;
	return section.GetInt(argument, result) ? result:defval;
}

stock float GetArgNamedF(FF2Player player, const char[] plugin_name, const char[] ability_name, const char[] argument, float defval = 0.0)
{
	ConfigMap section = JumpToAbility(player, plugin_name, ability_name);
	if( section==null ) {
		return defval;
	}
	
	float result;
	return section.GetFloat(argument, result) ? result:defval;
}

stock int GetArgNamedS(FF2Player player, const char[] plugin_name, const char[] ability_name, const char[] argument, char[] result, int size)
{
	ConfigMap section = JumpToAbility(player, plugin_name, ability_name);
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

stock int FF2_RegisterFakeBoss(const char[] name)
{
	if(	strlen(name) >= MAX_BOSS_NAME_SIZE - 6 )
		return INVALID_FF2_BOSS_ID;
	char final_name[MAX_BOSS_NAME_SIZE];
	FormatEx(final_name, sizeof(final_name), "%s_FF2", name);
	
	int id;
	if( (id = VSH2_GetBossID(final_name)) != INVALID_FF2_BOSS_ID ) {
		return id;
	}
	
	return VSH2_RegisterPlugin(final_name);
}


static ConfigMap GetFF2Config(FF2Player player)
{
	static FF2Identity id;
	return ( ff2_cfgmgr.FindIdentity(player.iBossType, id) ? id.hCfg.GetSection("character"):null );
}

static FF2AbilityList GetFF2AbilityList(FF2Player player)
{
	static FF2Identity id;
	return ( ff2_cfgmgr.FindIdentity(player.iBossType, id) ? id.ablist:null );
}
