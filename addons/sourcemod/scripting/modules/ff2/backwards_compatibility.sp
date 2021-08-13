/*
#define PROFILE_SECTION \
	Profiler pf = new Profiler(); \
	pf.Start()
	
#define STOP_PROFILER \
	pf.Stop(); \
	float time = pf.Time; \
	PrintToServer("%.12f", time)
*/

static ConfigMap ConfigMap_NewSection(ConfigMap parent, const char[] name)
{
	PackVal val;
	StringMap sm = new StringMap();
	
	val.tag = KeyValType_Section;
	val.data = new DataPack();
	val.data.WriteCell(sm);
	val.size = sizeof(StringMap);
	
	parent.SetArray(name, val, sizeof(val));
	return view_as<ConfigMap>(sm);
}

/// Insert a packval to the ConfigMap, if the key doesn't exists, create its new (sub)section(s)
static ConfigMap _EnsureSectionExists(ConfigMap section, const char[] key, PackVal pack, int enumeration = 0, KeyValType type = KeyValType_Value)
{
	int i; /// used for `key`.
	char final_section[PLATFORM_MAX_PATH];
	ParseTargetPath(key, final_section, sizeof(final_section));
		
	bool skip_call = false;	///	don't care StringMap::GetArray during the next iterations
	ConfigMap itermap = section;
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
					ConfigMap final_cfg = ConfigMap_NewSection(itermap, curr_section);
					char int_key[10];
					if( type==KeyValType_Section ) {
						for( int j; j<enumeration; j++ ) {
							IntToString(j, int_key, sizeof(int_key));
							PackVal sec;
							
							sec.data = new DataPack();
							sec.size = sizeof(StringMap);
							sec.data.WriteCell(new StringMap());
							sec.tag = KeyValType_Section;
							
							final_cfg.SetArray(int_key, sec, sizeof(sec));
						}
					}
					itermap = final_cfg;
				}
				else {
					StringMap retsm = itermap;
					if( type==KeyValType_Section ) {
						retsm = new StringMap();

						pack.tag = KeyValType_Section;
						pack.data = new DataPack();
						pack.data.WriteCell(retsm);
						pack.size = sizeof(StringMap);
					}
					
					itermap.SetArray(curr_section, pack, sizeof(pack));
					itermap = view_as<ConfigMap>(retsm);
				}
			}
			return itermap;
		}
		bool result = skip_call || itermap.GetArray(curr_section, val, sizeof(val));
		if( !result ) {
			itermap = ConfigMap_NewSection(itermap, curr_section);
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

static void _InsertNewSectionToConfigMap(ConfigMap cfg, const char[] old_key, const char[] new_key, int enumeration = 0, KeyValType type = KeyValType_Null)
{
	PackVal datapack;
	if( cfg.GetVal(old_key, datapack) ) {
		datapack.data = view_as<DataPack>(CloneHandle(datapack.data));
		_EnsureSectionExists(cfg, new_key, datapack, enumeration, type);
	}
}

static ConfigMap _ReserveNewSectionForConfigMap(const ConfigMap cfg, const char[] new_key, int enumeration = 0, KeyValType type = KeyValType_Section)
{
	PackVal datapack;
	return _EnsureSectionExists(cfg, new_key, datapack, enumeration, type);
}


#define FF2_RESOLVE_FUNC(%0)	static stock void FF2Resolve_%0(ArrayList delete_list, const ConfigMap cfg, char[] key, int len)

static bool FF2Resolve_GenericInfo(ArrayList delete_list, const ConfigMap cfg, char[] key, bool[] skip_imports, int skips)
{
	char generic_info_keys[][][] = {
		///{ old section,		new section,		enumeration for <enum> }
		{ "name", 				"info.name",		'0' },	///	0
		{ "model", 				"info.model",		'0' },	///	1
		
		{ "class", 				"info.class",		'0' },	///	2
		{ "lives",				"info.lives",		'0' },	///	3
		
		{ "health_formula",		"info.health",		'0' },	///	4
		{ "ragedist",			"info.ragedist",	'0' },	///	4
		
		{ "nofirst",			"info.nofirst",		'0' },	///	5
		{ "permission",			"info.permission",	'0' },	///	6
		{ "blocked",			"info.blocked",		'0' },	///	7
		
		{ "speed",				"info.speed.min",	'0' },	///	8
		{ "minspeed",			"info.speed.min",	'0' },	///	9
		{ "maxspeed",			"info.speed.max",	'0' },	///	10
		
		{ "companion",			"info.companion",	'1' },	/// 11
		
		{ "sound_block_vo",		"info.mute",		'0' },	/// 12
		{ "version",			"info.version",		'0' },	/// 13
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
	
			_InsertNewSectionToConfigMap(
				cfg,
				generic_info_keys[j][0],
				generic_info_keys[j][1],
				generic_info_keys[j][2][0]-'0',
				KeyValType_Value
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
		_InsertNewSectionToConfigMap(
			cfg,
			key,
			new_key,
			0,
			KeyValType_Value
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
	char[] tmp_key = new char[36];

	FormatEx(tmp_key, 24, "weapons.%i", num);

	ConfigMap to_move_to = _ReserveNewSectionForConfigMap(cfg, tmp_key, 0);
	ConfigMap to_move_from = cfg.GetSection(key);
	StringMapSnapshot sub_snap = to_move_from.Snapshot();

	///	Move sections from "weapon%i" to "weapons.%i"
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

	for(int j; j<sub_size; j++ ) {
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

	ConfigMap sound_section = cfg.GetSection(key);
	int sections_count;

	///	find all highest section index
	StringMapSnapshot snap = sound_section.Snapshot();
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
		_ReserveNewSectionForConfigMap(
			cfg,
			final_outkey, 
			sections_count, 
			KeyValType_Section
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
			
			if( sound_section.GetArray(rkey, pack, sizeof(pack)) ) {
				cur_final.SetArray("path", pack, sizeof(pack));
				pack.data = null;
				pack.tag = KeyValType_Null;
				pack.size = 0;
				sound_section.SetArray(rkey, pack, sizeof(pack));
			}
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
				if( sound_section.GetArray(rkey, pack, sizeof(pack)) ) {
					cur_final.SetArray(keys[j], pack, sizeof(pack));
					pack.data = null;
					pack.tag = KeyValType_Null;
					pack.size = 0;
					sound_section.SetArray(rkey, pack, sizeof(pack));
				}
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
				if( sound_section.GetArray(rkey, pack, sizeof(pack)) ) {
					if( j ) {
						char tmp[16];
						pack.data.Reset();
						pack.data.ReadString(tmp, sizeof(tmp));
						
						int ftmp = view_as<int>(FF2_OldNumToBitSlot(StringToInt(tmp)));
						IntToString(ftmp, tmp, sizeof(tmp));
						FormatEx(tmp, sizeof(tmp), "%b", ftmp);

						pack.data.Reset();
						pack.data.WriteString(tmp);
					}
					cur_final.SetArray(set_keys[j], pack, sizeof(pack));
					pack.data = null;
					pack.tag = KeyValType_Null;
					pack.size = 0;
					sound_section.SetArray(rkey, pack, sizeof(pack));
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
				if( sound_section.GetArray(rkey, pack, sizeof(pack)) ) {
					cur_final.SetArray(set_keys[j], pack, sizeof(pack));
					pack.data = null;
					pack.tag = KeyValType_Null;
					pack.size = 0;
					sound_section.SetArray(rkey, pack, sizeof(pack));
				}
			}
		}
		}
	}
}


#undef FF2_RESOLVE_FUNC
#define FF2_RESOLVE_FUNC(%0)	FF2Resolve_%0(delete_list, cfg, key, len)
///	Instead of checking for literary each time if we should use info section or anything new, why not reparse the config to the new format
/// Note: some keys will be discared and ignored unless you have "using.VSH2/FF2 new API" key set to true
/// TODO: don't process all in one frame, try creating multiple frames each time until it ends
void FF2_ResolveBackwardCompatibility(ConfigMap cfg)
{
	StringMapSnapshot snap = cfg.Snapshot();
	int snap_size = snap.Length;

	ArrayList delete_list = new ArrayList(ByteCountToCells(64));

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
			cfg.DeleteSection(key);
		}
	}

	delete delete_list;
	delete snap;
}

#undef FF2_RESOLVE_FUNC