/*
#define PROFILE_SECTION \
	Profiler pf = new Profiler(); \
	pf.Start()

#define STOP_PROFILER \
	pf.Stop(); \
	float time = pf.Time; \
	PrintToServer("%.12f", time)
*/

methodmap ConfigMapAllocator {
	public ConfigMapAllocator(ConfigMap cfg) {
		return view_as< ConfigMapAllocator >( cfg );
	}

	property ConfigMap Config {
		public get() { return view_as< ConfigMap >( this );}
	}

	public ConfigMap NewSection(const char[] name) {
		PackVal val;
		StringMap sm = new StringMap();

		val.tag = KeyValType_Section;
		val.data = new DataPack();
		val.data.WriteCell(sm);
		val.size = sizeof(StringMap);

		this.Config.SetArray(name, val, sizeof(val));
		return view_as<ConfigMap>(sm);
	}

	public void NewValue(const char[] name, const char[] value, int size) {
		PackVal val;

		val.tag = KeyValType_Value;
		val.data = new DataPack();
		val.data.WriteString(value);
		val.size = size;

		this.Config.SetArray(name, val, sizeof(val));
	}

	/// Insert a packval to the ConfigMap, if the key doesn't exists, create its new (sub)section(s)
	///	if enumeration is greater than 0
	/// 	if KeyValType_Section or (KeyValType_Value and enumeration greater than 1)
	///			packval must be null
	///	else 
	///		if KeyValType_Section
	///			packval must be null
	public ConfigMap EnsureSectionExists(const char[] key, PackVal pack, int enumeration = 0, KeyValType type = KeyValType_Value) {
		int i; /// used for `key`.
		char final_section[PLATFORM_MAX_PATH];
		ParseTargetPath(key, final_section, sizeof(final_section));

		bool skip_call = false;	///	don't care and skip StringMap::GetArray during the next iterations
		ConfigMap itermap = this.Config;
		while( itermap != null ) {
			int n;
			char curr_section[PLATFORM_MAX_PATH];
			/// Patch: allow keys to use dot without interfering with dot path.
			while( key[i] != 0 ) {
				if( key[i]=='\\' && key[i+1] != 0 && key[i+1]=='.' ) {
					i++;
					if( n<PLATFORM_MAX_PATH ) {
						curr_section[n++] = key[i++];
					}
				} else if( key[i]=='.' ) {
					i++;
					break;
				} else {
					if( n<PLATFORM_MAX_PATH ) {
						curr_section[n++] = key[i++];
					}
				}
			}

			PackVal val;
			if( StrEqual(curr_section, final_section) ) {
				/// this is a new section
				if( skip_call || !itermap.GetArray(curr_section, val, sizeof(val)) ) {
					/// an enumerated section
					if( enumeration > 0 ) {
						ConfigMapAllocator final_cfg = ConfigMapAllocator(ConfigMapAllocator(itermap).NewSection(curr_section));
						char int_key[10];

						switch( type ) {
						case KeyValType_Section: {
							for( int j; j<enumeration; j++ ) {
								IntToString(j, int_key, sizeof(int_key));
								final_cfg.NewSection(int_key);
							}
						}
						case KeyValType_Value: {
							if( enumeration>1 ) {
								for( int j; j<enumeration; j++ ) {
									IntToString(j, int_key, sizeof(int_key));
									final_cfg.NewValue(int_key, "", 0);
								}
							}
							else {
								int size = pack.size;
								char[] str = new char[size];
								pack.data.Reset();
								pack.data.ReadString(str, size);
								final_cfg.Config.SetArray("0", pack, sizeof(pack));
								//final_cfg.NewValue("0", str, size);
							}
						}
						default: { }
						}

						itermap = final_cfg.Config;
					}
					else {
						/// a key-value
						StringMap retsm = itermap;
						switch( type ) {
						case KeyValType_Section: {
							if( pack.data )
								delete pack.data;

							retsm = new StringMap();

							pack.tag = KeyValType_Section;
							pack.data = new DataPack();
							pack.data.WriteCell(retsm);
							pack.size = sizeof(StringMap);
						}
						case KeyValType_Value: {
							/// Section was moved
							if( !pack.data ) {
								pack.tag = KeyValType_Value;
								pack.data = new DataPack();
								pack.data.WriteString("");
								pack.size = 0;
							}
						}
						default: { }
						}

						itermap.SetArray(curr_section, pack, sizeof(pack));
						itermap = view_as<ConfigMap>(retsm);
					}
				}
				return itermap;
			}
			if( skip_call || !itermap.GetArray(curr_section, val, sizeof(val)) ) {
				itermap = ConfigMapAllocator(itermap).NewSection(curr_section);
				skip_call = true;
			} else if( val.tag==KeyValType_Section ) {
				val.data.Reset();
				itermap = val.data.ReadCell();
			}
			///	we don't care about value, its the end of parsing
			else break;
		}
		return null;
	}

	public ConfigMap ReserveNewSection(const char[] new_key, int enumeration = 0) {
		PackVal empty;
		return this.EnsureSectionExists(new_key, empty, enumeration, KeyValType_Section);
	}

	public void ReserveNewValues(const char[] new_key, int enumeration = 0) {
		PackVal empty;
		this.EnsureSectionExists(new_key, empty, enumeration, KeyValType_Value);
	}

	public void CloneToSection(const char[] old_key, const char[] new_key, int enumeration = 0) {
		PackVal datapack;
		if( this.Config.GetVal(old_key, datapack) ) {
			datapack.data = view_as<DataPack>(CloneHandle(datapack.data));
			this.EnsureSectionExists(new_key, datapack, enumeration, KeyValType_Value);
		}
	}

	public void MoveToSection(const char[] cur_key, ConfigMap target, const char[] new_key) {
		PackVal pack;
		if( this.Config.GetArray(cur_key, pack, sizeof(pack)) ) {
			target.SetArray(new_key, pack, sizeof(pack));
			pack.data = null;
			pack.tag = KeyValType_Null;
			pack.size = 0;
			this.Config.SetArray(cur_key, pack, sizeof(pack));
		}
	}
}

#define KeyValType_MovedSection view_as<KeyValType>(KeyValType_Value + 1)

#define FF2_RESOLVE_FUNC(%0)	static stock void FF2Resolve_%0(ArrayList delete_list, const ConfigMapAllocator cfg, char[] key, int len)

static bool FF2Resolve_GenericInfo(ArrayList delete_list, const ConfigMapAllocator cfg, char[] key, bool[] skip_imports, int skips)
{
	char generic_info_keys[][][] = {
		///{ old section,		new section,		enumeration for <enum> }
		{ "name", 				"info.name",		"0" },	///	0
		{ "model", 				"info.model",		"0" },	///	1

		{ "class", 				"info.class",		"0" },	///	2
		{ "lives",				"info.lives",		"0" },	///	3

		{ "health_formula",		"info.health",		"0" },	///	4
		{ "ragedist",			"info.ragedist",	"0" },	///	4

		{ "nofirst",			"info.nofirst",		"0" },	///	5
		{ "permission",			"info.permission",	"0" },	///	6
		{ "blocked",			"info.blocked",		"0" },	///	7

		{ "speed",				"info.speed.min",	"0" },	///	8
		{ "minspeed",			"info.speed.min",	"0" },	///	9
		{ "maxspeed",			"info.speed.max",	"0" },	///	10

		{ "companion",			"info.companion",	"0" },	/// 11

		{ "sound_block_vo",		"info.mute",		"0" },	/// 12
		{ "version",			"info.version",		"0" },	/// 13
	};
	const int size_of_skips = sizeof(generic_info_keys);

	///	generic_info_keys section
	/// import some required keys to the info section
	if( skips!=size_of_skips ) {
		for( int j; j<size_of_skips; j++ ) {
			if( skip_imports[j] )
				continue;
			if( strcmp(generic_info_keys[j][0], key) )
				continue;

			delete_list.PushString(generic_info_keys[j][0]);
			if( j==9||j==8 ) skip_imports[9] = skip_imports[8] = true;
				else skip_imports[j] = true;
			skips++;

			cfg.CloneToSection(
				generic_info_keys[j][0],		///	old_key
				generic_info_keys[j][1],		///	new_key
				generic_info_keys[j][2][0]-'0'	///	enumeration
			);
			return true;
		}
	}

	return false;
}

FF2_RESOLVE_FUNC(Description)
{
	int pos = FindCharInString(key, '_', true);
	if( pos!=-1 ) {
		delete_list.PushString(key);
		char[] new_key = new char[len+5];	///	sizeof("info.") + len

		FormatEx(new_key, len, "%s", key);
		new_key[pos] = '\0';
		Format(new_key, len+5, "info.%s.%s", new_key, new_key[pos+1]);
		cfg.CloneToSection(
			key,
			new_key,
			0
		);
	}
}

FF2_RESOLVE_FUNC(WeaponSection)
{
	int num;
	/// bad key, "weapon" instead of "weapon<enum>"
	if (!StringToIntEx(key[6], num) )
		return;

	delete_list.PushString(key);
	char tmp_key[36];

	FormatEx(tmp_key, 24, "weapons.%i", num - 1);

	ConfigMap to_move_to = cfg.ReserveNewSection(tmp_key);
	ConfigMap to_move_from = cfg.Config.GetSection(key);
	StringMapSnapshot sub_snap = to_move_from.Snapshot();

	///	Move sections from "weapon%i" to "weapons.(%i-1)"
	int sub_size = sub_snap.Length;
	char[][] keys = new char[sub_size][36];
	PackVal pack;

	for( int j; j<sub_size; j++ ) {
		sub_snap.GetKey(j, keys[j], 36);
		to_move_from.GetArray(keys[j], pack, sizeof(pack));
		/// Subsections not supported
		if( pack.tag==KeyValType_Value ) {
			to_move_to.SetArray(keys[j], pack, sizeof(pack));
		}
		else keys[j][0] = '\0';
	}

	pack.data = null;
	pack.size = 0;
	pack.tag = KeyValType_Null;

	for( int j; j<sub_size; j++ ) {
		if( keys[j][0] ) {
			to_move_from.SetArray(keys[j], pack, sizeof(pack));
		}
	}

	delete sub_snap;
}

enum SoundSectionType {
	SST_GENERIC,
	SST_BGM,
	SST_ABILITY,
	SST_REPLACE
};

///	Splits and set sounds section with character '_'
///	eg: from 'sound_bgm' to 'sounds.bgm.<enum>'
///	each sound is enumerated with '<enum>' keyword from 'ConfigMap'
///
///	check out 'vsh2ff2_sample.cfg' for more keys and better examples
FF2_RESOLVE_FUNC(SoundSection)
{
	delete_list.PushString(key);
	SoundSectionType section_type = 
		!strcmp(key[4], "d_bgm") ? SST_BGM :
		!strcmp(key[4], "d_ability") ? SST_ABILITY :
		!strcmp(key[4], "h_replace") ? SST_REPLACE :
		SST_GENERIC;

	ConfigMapAllocator sound_section = ConfigMapAllocator(cfg.Config.GetSection(key));
	int sections_count;

	///	find all highest section index
	StringMapSnapshot snap = sound_section.Config.Snapshot();
	int snap_size = snap.Length;
	for( int i=snap_size-1; i>=0; i-- ) {
		char intkey[12];
		snap.GetKey(i, intkey, sizeof(intkey));
		int tmp = section_type == SST_BGM ? StringToInt(intkey[4]) : StringToInt(intkey);
		if( tmp > sections_count )
			sections_count = tmp;
	}

	delete snap;

	if( !sections_count ) {
		return;
	}

	char[] final_outkey = new char[len + 7];
	FormatEx(final_outkey, len + 7, "sounds.%s", key[6]);

	ConfigMap final_section =
		cfg.ReserveNewSection(
			final_outkey, 
			sections_count
		);

	PackVal pack;
	for( int i; i<sections_count; i++ ) {
		char fkey[4];
		IntToString(i, fkey, sizeof(fkey));
		ConfigMap cur_final = final_section.GetSection(fkey);

		switch( section_type ) {
		case SST_GENERIC: {
			char rkey[4];
			IntToString(i+1, rkey, sizeof(rkey));

			sound_section.MoveToSection(rkey, cur_final, "path");
		}
		case SST_BGM: {
			char keys[][] = {
				"path",
				"time",
				"name",
				"artist"
			};
			char rkey[8];

			for( int j; j<sizeof(keys); j++ ) {
				FormatEx(rkey, sizeof(rkey), "%s%i", keys[j], i+1);
				sound_section.MoveToSection(rkey, cur_final, keys[j]);
			}
		}
		case SST_ABILITY: {
			char fetch_keys[][] = {
				"",
				"slot",
			};
			char set_keys[][] = {
				"path",
				"slot",
			};
			char rkey[8];

			for( int j; j<sizeof(set_keys); j++ ) {
				FormatEx(rkey, sizeof(rkey), "%s%i", fetch_keys[j], i+1);
				if( sound_section.Config.GetArray(rkey, pack, sizeof(pack)) ) {
					if( j ) {
						char tmp[32];
						pack.data.Reset();
						pack.data.ReadString(tmp, sizeof(tmp));

						pack.size = FormatEx(tmp, sizeof(tmp), "%b", FF2_OldNumToBitSlot(StringToInt(tmp))) + 1;

						pack.data.Reset();
						pack.data.WriteString(tmp);
					}
					cur_final.SetArray(set_keys[j], pack, sizeof(pack));
					pack.data = null;
					pack.tag = KeyValType_Null;
					pack.size = 0;
					sound_section.Config.SetArray(rkey, pack, sizeof(pack));
				}
			}
		}
		case SST_REPLACE: {
			char keys[][] = {
				"",
				"vo",
			};
			char set_keys[][] = {
				"seek",
				"path",
			};
			char rkey[8];

			for( int j; j<sizeof(keys); j++ ) {
				FormatEx(rkey, sizeof(rkey), "%s%i", keys[j], i+1);
				sound_section.MoveToSection(rkey, cur_final, set_keys[j]);
			}
		}
		}
	}
}


#undef FF2_RESOLVE_FUNC
#define FF2_RESOLVE_FUNC(%0)	FF2Resolve_%0(delete_list, cfg, key, len)
///	Instead of checking for literary each time if we should use info section or anything new, why not reparse the config to the new format
/// Note: some keys will be discared and ignored unless you have "using.VSH2/FF2 new API" key set to true
void FF2_ResolveBackwardCompatibility(ConfigMap charcfg)
{
	StringMapSnapshot snap = charcfg.Snapshot();
	int snap_size = snap.Length;

	ArrayList delete_list = new ArrayList(ByteCountToCells(64));
	ConfigMapAllocator cfg = ConfigMapAllocator(charcfg);

	/// resolve info section
	{
		bool skip_imports[14];
		int skips;

		for( int i; i<snap_size; i++ ) {
			int len = snap.KeyBufferSize(i);
			char[] key = new char[len];
			snap.GetKey(i, key, len);

			if( FF2Resolve_GenericInfo(delete_list, cfg, key, skip_imports, skips) )
				continue;

			///
			/// resolve description
			///	from "description_<lang>" to
			///
			///	"description" {
			///		"en"	"..."
			///		"jp"	"..."
			///		"ru"	"..."
			///	}
			///
			if( !strncmp(key, "description", 11) ) {
				FF2_RESOLVE_FUNC(Description);
			}

			///
			/// resolve weapon section
			///	from "weapon<enum>" to
			///
			///	"weapons" {
			///		"<enum>" {
			///			"..."
			///		}
			///	}
			///
			/// Note: we will only copy and truncate the useful sections
			else if( !strncmp(key, "weapon", 5) ) {
				FF2_RESOLVE_FUNC(WeaponSection);
			}

			///
			///	resolve sounds
			else if( (!strncmp(key, "sound_", 6) && strcmp(key[6], "block_vo")) || !strncmp(key, "catch_", 6) ) {
				FF2_RESOLVE_FUNC(SoundSection);
			}

			/// ignoring 'downloads' section since it's a one time get
		}

		char key[64];
		for ( int j; j<delete_list.Length; j++ ) {
			delete_list.GetString(j, key, sizeof(key));
			charcfg.DeleteSection(key);
		}
	}

	delete delete_list;
	delete snap;
}

#undef FF2_RESOLVE_FUNC