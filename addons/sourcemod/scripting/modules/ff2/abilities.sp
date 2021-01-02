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
	int            VSH2ID;
	ConfigMap      hCfg;
	FF2SoundHash   sndHash;
	FF2AbilityList ablist;
	char           szName[48];
	char           szPath[PLATFORM_MAX_PATH];
}

methodmap FF2AbilityList < StringMap {
	public FF2AbilityList() {
		return( view_as< FF2AbilityList >(new StringMap()) );
	}
	
	public void Insert(const char[] key, const char[] str) {
		this.SetString(key, str);
	}
	
	public static void GetKeyVal(const char[] key, char[][] pl_ab)
	{
		ExplodeString(key, "##", pl_ab, 2, FF2_MAX_PLUGIN_NAME);
	}
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
	if( !FileExists(path) ) {
		ThrowError("[!!!] Unable to find \"%s\"!", identity.szName);
	}
	
	strcopy(identity.szPath, sizeof(FF2Identity::szPath), path);
	ConfigMap cfg = new ConfigMap(key_name);
	
	if( !cfg ) {
		LogError("[VSH2/FF2] Failed to find \"%s\" character!", identity.szName);
		return false;
	}
	
	identity.VSH2ID = FF2_RegisterFakeBoss(identity.szName);
	if( identity.VSH2ID == INVALID_FF2_BOSS_ID ) {
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
		
		for( int i = snap.Length - 1; i >= 0 && identity.ablist.Size < FF2_MAX_SUBPLUGINS; i-- ) {
			snap.GetKey(i, key_name, FF2_MAX_ABILITY_KEY);
			if( strncmp(key_name, "ability", 7) )
				continue;
			
			cur_ab = this_char.GetSection(key_name);
			if( !cur_ab || !cur_ab.Get("plugin_name", buffer, FF2_MAX_PLUGIN_NAME) )
				continue;
			
			BuildPath(Path_SM, path, sizeof(path), "plugins/freaks/%s.ff2", buffer);
			if( !FileExists(path) ) {
				LogError("[VSH2/FF2] Character \"%s.cfg\" is missing \"%s\" subplugin!", identity.szName, path);
			} else {
				cur_ab.Get("name", path, FF2_MAX_ABILITY_NAME);
				Format(path, FF2_MAX_LIST_KEY, "%s##%s", buffer, path);
				identity.ablist.Insert(path, key_name);
			}
		}
		delete snap;
	}
	
	ConfigMap stacks;
	
	///	download
	{
		if( (stacks = this_char.GetSection("download")) ) {
			for( int i = stacks.Size - 1; i >= 0; i-- ) {
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
			".dx80.vtx", ".dx90.vtx",
			".sw.vtx",
			".vvd",
			".phy"
		};
	
		if( (stacks = this_char.GetSection("mod_download")) ) {
			for( int i = stacks.Size - 1; i >= 0; i-- ) {
				IntToString(i, key_name, sizeof(key_name));
				if( !stacks.Get(key_name, path, sizeof(path)) )
					continue;
				
				for( int j = 0; j < sizeof(modelT); j++ ) {
					FormatEx(key_name, sizeof(key_name), "%s%s", path, modelT[j]);
					if( FileExists(key_name, true) ) {
						AddFileToDownloadsTable(key_name);
					} else if( StrContains(key_name, ".phy") == -1 ) {
						LogError("[VSH2/FF2] Character \"%s.cfg\" is missing file \"%s\"!", identity.szName, key_name);
					}
				}
			}
		}
		if( (stacks = this_char.GetSection("mat_download")) ) {
			for( int i = stacks.Size - 1; i >= 0; i-- ) {
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
		
		for( int i = snap.Length - 1; i >= 0; i-- ) {
			snap.GetKey(i, _key, sizeof(_key));
			if( !StrContains(_key, "sound") ) {
				_list = this_char.GetSection(_key);
				snd_list = identity.sndHash.GetOrCreateList(_key);
				
				bool bIsBGM = _list.Get("path1", strBuffer, sizeof(strBuffer)) > 0;
				
				for( int j = 1; j <= 15; j++ ) {
					if( bIsBGM ) {
						Format(curSection, sizeof(curSection), "path%i", j);
						if( !_list.Get(curSection, strBuffer, sizeof(strBuffer)) )
							break;
						
						Format(curSection, sizeof(curSection), "time%i", j);
						if( !_list.GetFloat(curSection, time) )
							break;
						
						Format(curSection, sizeof(curSection), "name%i", j);
						if( !_list.Get(curSection, name, sizeof(name)) )
							name = "Unknown Song";
						Format(curSection, sizeof(curSection), "artist%i", j);
						if( !_list.Get(curSection, artist, sizeof(artist)) )
							name = "Unknown Artist";
						
						snd_id.Init(strBuffer, time, name, artist);
						snd_list.PushArray(snd_id, sizeof(FF2SoundIdentity));
					} else {
						IntToString(j, curSection, 2);
						if( !_list.Get(curSection, strBuffer, sizeof(strBuffer)) )
							break;
						
						FormatEx(_key, sizeof(_key), "slot%i", j);
						if( !_list.Get(_key, buffer, sizeof(buffer)) )
							slot_type = view_as< int >(CT_RAGE);
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
methodmap FF2BossManager < StringMap {
	public bool GetIdentity(const char[] name, FF2Identity identity) {
		return( this.GetArray(name, identity, sizeof(FF2Identity)) ? true:false );
	}
	
	public FF2BossManager(const char[] pack_name) {
		/// Parse Boss CFG with pack name
		ConfigMap cfg = ff2.m_charcfg.GetSection(pack_name);
		if( !cfg )
			ThrowError("Failed to find Section for characters.cfg: \"%s\"", pack_name);
		
		StringMap map = new StringMap();
		char key[4], name[48];
		
		/// Iterate through the Pack, copy and verify boss path
		for( int i = cfg.Size - 1; i >= 0; i-- ) {
			IntToString(i, key, sizeof(key));
			if( !cfg.Get(key, name, sizeof(name)) )
				continue;
			
			FF2Identity curIdentity;
			strcopy(curIdentity.szName, sizeof(FF2Identity::szName), name);
			if( FF2_LoadCharacter(curIdentity) ) {
				map.SetArray(name, curIdentity, sizeof(FF2Identity));
			}
		}
		return( view_as< FF2BossManager >(map) );
	}
	
	public void Delete(const char[] name) {
		FF2Identity identity;
		if( this.GetArray(name, identity, sizeof(FF2Identity)) ) {
			RELEASE_IDENTITY(identity);
			this.Remove(name);
		}
	}
	
	public void DeleteAll() {
		StringMapSnapshot snap = this.Snapshot();
		char name[48];
		FF2Identity identity;
		for( int i = snap.Length - 1; i >= 0; i-- ) {
			snap.GetKey(i, name, sizeof(name));
			if( this.GetIdentity(name, identity) ) {
				RELEASE_IDENTITY(identity);
			}
		}
		this.Clear();
		delete snap;
	}
	
	public bool FindIdentity(const int ID, FF2Identity identity) {
		StringMapSnapshot snap = this.Snapshot();
		char name[48];
		bool res;
		for( int i = snap.Length - 1; i >= 0; i-- ) {
			snap.GetKey(i, name, sizeof(name));
			if( this.GetIdentity(name, identity) && identity.VSH2ID == ID ) {
				res = true;
				break;
			}
		}
		delete snap;
		return res;
	}
	
	public bool FindIdentityByCfg(const ConfigMap cfg, FF2Identity identity) {
		StringMapSnapshot snap = this.Snapshot();
		char name[48];
		bool res;
		for( int i = snap.Length - 1; i >= 0; i-- ) {
			snap.GetKey(i, name, sizeof(name));
			if( this.GetIdentity(name, identity) && identity.hCfg == cfg ) {
				res = true;
				break;
			}
		}
		delete snap;
		return res;
	}
	
	public bool FindIdentityByName(const char[] name, FF2Identity identity) {
		StringMapSnapshot snap = this.Snapshot();
		char key_name[48];
		bool res;
		for( int i = snap.Length - 1; i >= 0 && !res; i-- ) {
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