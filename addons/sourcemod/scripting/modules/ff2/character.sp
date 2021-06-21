methodmap FF2AbilityList < StringMap {
	public FF2AbilityList() {
		return( view_as< FF2AbilityList >(new StringMap()) );
	}
	
	public void Insert(const char[] key, const char[] str) {
		this.SetString(key, str);
	}
	
	public static void GetKeyVal(const char[] key, char[][] pl_ab) {
		ExplodeString(key, "##", pl_ab, 2, FF2_MAX_PLUGIN_NAME);
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
 */
enum struct FF2Identity {
	int            VSH2ID;
	ConfigMap      hCfg;
	FF2SoundHash   sndHash;
	FF2AbilityList ablist;
	char           szName[48];
	
	void Release() {
		if( this.sndHash ) {
			this.sndHash.DeleteAll();
			delete this.sndHash;
		}
		DeleteCfg(this.hCfg);
		delete this.ablist;
	}
}

static bool FF2_LoadCharacter(FF2Identity identity, char[] path)
{
	char[] key_name = new char[PLATFORM_MAX_PATH];

	FormatEx(key_name, PLATFORM_MAX_PATH, "configs/freak_fortress_2/%s.cfg", identity.szName);
	BuildPath(Path_SM, path, PLATFORM_MAX_PATH, "%s", key_name);
	if( !FileExists(path) ) {
		LogError("[VSH2/FF2] Unable to find \"%s\"!", identity.szName);
		return false;
	}

	ConfigMap cfg = new ConfigMap(key_name);

	if( !cfg ) {
		LogError("[VSH2/FF2] Failed to find \"%s\" character!", identity.szName);
		return false;
	}
	
	ConfigMap exclude = cfg.GetSection("map_exclude");
	if( exclude ) {
		GetCurrentMap(path, PLATFORM_MAX_PATH);
		for( int i=exclude.Size-1; i>=0; i-- ) {
			if( exclude.GetIntKey(i, key_name, PLATFORM_MAX_PATH) && !StrContains(key_name, path) ) {
				DeleteCfg(cfg);
				return false;
			}
		}
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

	StringMapSnapshot snap = this_char.Snapshot();
	int size_of_snapshot = snap.Length;

	/// ability* || Ability*
	/**
	 *	"Ability: Rage Test" {	///	Can be ability5965841, ability*, as long as the key was unique && less than 64 characters
	 *		"name"			"thing"
	 *		"plugin_name"	"pl_name"	///	"pl_name.smx"
	 *	}
	 */
	{
		for( int i = size_of_snapshot - 1; i >= 0 && identity.ablist.Size < FF2_MAX_SUBPLUGINS; i-- ) {
			snap.GetKey(i, key_name, FF2_MAX_ABILITY_KEY);
			if( strncmp(key_name, "ability", 7, false) )
				continue;

			ConfigMap cur_ab = this_char.GetSection(key_name);
			if( !cur_ab || !cur_ab.Get("plugin_name", buffer, FF2_MAX_PLUGIN_NAME) )
				continue;

			BuildPath(Path_SM, path, PLATFORM_MAX_PATH, "plugins\\freaks\\%s.smx", buffer);
			if( !FileExists(path) ) {
				LogError("[VSH2/FF2] Character \"%s.cfg\" is missing \"%s\" subplugin!", identity.szName, path);
			} else {
				cur_ab.Get("name", path, FF2_MAX_ABILITY_NAME);
				Format(path, FF2_MAX_LIST_KEY, "%s##%s", buffer, path);
				identity.ablist.Insert(path, key_name);
			}
		}
	}

	ConfigMap stacks;

	/**
	 *	"download" {
	 *		"<enum>"		"..."
	 *		"<enum>"		"...."
	 *		"<enum>"		".."
	 *	}
	 */
	{
		if( (stacks = this_char.GetSection("download")) ) {
			for( int i = stacks.Size - 1; i >= 0; i-- ) {
				if( !stacks.GetIntKey(i, path, PLATFORM_MAX_PATH) )
					continue;

				if( !FileExists(path, true) ) {
					LogError("[VSH2/FF2] Character \"%s\" is missing file \"%s\"!", identity.szName, path);
				} else {
					AddFileToDownloadsTable(path);
				}
			}
		}
	}

	/// mat/mod download
	/**
	 *	"mat_download" {	///	"mod_download"
	 *		"<enum>"		"..."
	 *		"<enum>"		"...."
	 *		"<enum>"		".."
	 *	}
	 */
	{
		char model_ext[][] = {
			".mdl",
			".dx80.vtx", ".dx90.vtx",
			".sw.vtx",
			".vvd",
			".phy"
		};

		if( (stacks = this_char.GetSection("mod_download")) ) {
			for( int i = stacks.Size - 1; i >= 0; i-- ) {
				if( !stacks.GetIntKey(i, path, PLATFORM_MAX_PATH) )
					continue;

				for( int j = 0; j < sizeof(model_ext); j++ ) {
					FormatEx(key_name, PLATFORM_MAX_PATH, "%s%s", path, model_ext[j]);
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
				if( !stacks.GetIntKey(i, path, PLATFORM_MAX_PATH) )
					continue;

				FormatEx(key_name, PLATFORM_MAX_PATH, "%s.vmt", path);
				if( !FileExists(key_name, true) ) {
					LogError("[VSH2/FF2] Character \"%s\" is missing file \"%s\"!", identity.szName, key_name);
				} else {
					AddFileToDownloadsTable(key_name);
				}

				FormatEx(key_name, PLATFORM_MAX_PATH, "%s.vtf", path);
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

		ConfigMap _list;
		FF2SoundList snd_list;
		FF2SoundIdentity snd_id;

		char curSection[32], _key[48];

		float time; int slot_type;
		char name[32], artist[32];

		for( int i = size_of_snapshot - 1; i >= 0; i-- ) {
			snap.GetKey(i, _key, sizeof(_key));
			bool is_catch_snd = !strncmp(_key, "catch_", 6);

			if (!strncmp(_key, "sound", 5, false) || is_catch_snd ) {
				_list = this_char.GetSection(_key);
				if( !_list )	///	sound_block_vo or any other ky that contains soun
					continue;

				snd_list = identity.sndHash.GetOrCreateList(_key);

				bool is_bgm_section = _list.Get("path1", key_name, PLATFORM_MAX_PATH) > 0;

				for( int j = 0; j <= 15; j++ ) {
					if( is_bgm_section ) {
						/**	sound* contains pathX & timeX
						 *	FF2SoundIdentity = {
						 *		Path,
						 *		Time,
						 *		Song_Name,
						 *		Atrist_Name
						 *	};
						 *
						 *	"sound_bgm" {
						 *		"pathX"		"..."	///	required
						 *		"timeX"		"..."	///	required
						 *		"nameX"		"..."	///	optional
						 *		"artistX"	"..."	///	optional
						 *	}
						 *
						 */
						Format(curSection, sizeof(curSection), "path%i", j + 1);
						if( !_list.Get(curSection, key_name, PLATFORM_MAX_PATH) )
							break;

						Format(curSection, sizeof(curSection), "time%i", j + 1);
						if( !_list.GetFloat(curSection, time) )
							break;

						Format(curSection, sizeof(curSection), "name%i", j + 1);
						if( !_list.Get(curSection, name, sizeof(name)) )
							name = "Unknown Song";

						Format(curSection, sizeof(curSection), "artist%i", j + 1);
						if( !_list.Get(curSection, artist, sizeof(artist)) )
							name = "Unknown Artist";

						snd_id.Init(key_name, time, name, artist);
						snd_list.PushArray(snd_id, sizeof(FF2SoundIdentity));
					} else {
						if( !_list.GetIntKey(j, key_name, PLATFORM_MAX_PATH) )
							continue;

						/**	catch_* 
						 *	FF2SoundIdentity = {
						 *		Path,
						 *		UNUSED,
						 *		String To Replace || UNUSUED for catch_phrase,
						 *		UNUSED
						 *	};
						 *
						 *	"catch_phrase" {
						 *		"<enum>"	"..."	///	required
						 *		"voX"		"..."	///	required
						 *	}
						 *
						 *	"catch_phrase" {
						 *		"<enum>"		"..."
						 *	}
						 *
						 */
						if( is_catch_snd ) {
							FormatEx(_key, sizeof(_key), "vo%i", j);
							if( !_list.Get(_key, buffer, sizeof(buffer)) )
								buffer[0] = '\0';
						}
						else {
							/** sound*
							 *	FF2SoundIdentity = {
							 * 		Path,
							 *		UNUSED,
							 *		slot'Position'_'FF2CallType_t',
							 *		UNUSED
							 *	}; 
							 *
							 *	"sound_*" {
							 *		"<enum>"		"..."
							 *		"slotX"			"..."	//	only used if section == "sound_ability"
							 *	}
							 */
							FormatEx(_key, sizeof(_key), "slot%i", j);
							if( !_list.GetInt(_key, slot_type, 2) )
								slot_type = view_as< int >(CT_RAGE);

							FormatEx(_key, sizeof(_key), "slot%i_%i", j, slot_type);
						}

						snd_id.Init(key_name, 0.0, _key);
						snd_list.PushArray(snd_id, sizeof(FF2SoundIdentity));
					}
				}
			}
		}
	}
	
	delete snap;
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
		char[] name = new char[PLATFORM_MAX_PATH];

		/// Iterate through the Pack, copy and verify boss path
		for( int i = cfg.Size - 1; i >= 0; i-- ) {
			if( !cfg.GetIntKey(i, name, PLATFORM_MAX_PATH) )
				continue;

			FF2Identity cur_id;
			strcopy(cur_id.szName, sizeof(FF2Identity::szName), name);
			if( FF2_LoadCharacter(cur_id, name) ) {
				map.SetArray(cur_id.szName, cur_id, sizeof(FF2Identity));
			}
		}
		return( view_as< FF2BossManager >(map) );
	}

	public bool Delete(const char[] name) {
		FF2Identity identity;
		if( this.GetArray(name, identity, sizeof(FF2Identity)) ) {
			identity.Release();
			this.Remove(name);
			return true;
		}
		return false;
	}

	public void DeleteAll() {
		StringMapSnapshot snap = this.Snapshot();
		char name[48];
		FF2Identity identity;
		for( int i = snap.Length - 1; i >= 0; i-- ) {
			snap.GetKey(i, name, sizeof(name));
			if( this.GetIdentity(name, identity) ) {
				identity.Release();
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