static const char script_sounds[][] = {
	"Announcer.AM_CapEnabledRandom",
	"Announcer.AM_CapIncite01.mp3",
	"Announcer.AM_CapIncite02.mp3",
	"Announcer.AM_CapIncite03.mp3",
	"Announcer.AM_CapIncite04.mp3",
	"Announcer.RoundEnds5minutes",
	"Announcer.RoundEnds2minutes"
};

static const char basic_sounds[][] = {
	"weapons/barret_arm_zap.wav",
	"player/doubledonk.wav",
	"ambient/lightson.wav",
	"ambient/lightsoff.wav",
};

static const char modelT[][] = {
	".mdl",
	".dx80.vtx",
	".dx90.vtx",
	".sw.vtx",
	".vvd",
	".phy"
};

#define CHAR_CFG "characters.cfg"
static char CFG_DIR[28];


public Action OnCallDownloadsFF2()
{
//	FF2_AddToDownloadTable();
	
	PrecacheScriptList(script_sounds, sizeof(script_sounds));
	PrecacheSoundList(basic_sounds, sizeof(basic_sounds));
	PrepareSound("saxton_hale/9000.wav");
	return Plugin_Stop;
}

//TODO
void FF2_FindCharacters()
{
	char path[PLATFORM_MAX_PATH], config[PLATFORM_MAX_PATH];
	
	BuildPath(Path_SM, filepath, PLATFORM_MAX_PATH, "data/freak_fortress_2/%s", CHAR_CFG);

	if( !FileExists(filepath) ) {
		BuildPath(Path_SM, filepath, PLATFORM_MAX_PATH, "configs/freak_fortress_2/%s", CHAR_CFG);
		if(!FileExists(filepath))
		{
			ThrowError("[!!!] Unable to find \"%s\"!", CHAR_CFG);
		}
		FormatEx(CFG_DIR, sizeof(CFG_DIR), "configs/freak_fortress_2");
	} else {
		FormatEx(CFG_DIR, sizeof(CFG_DIR), "data/freak_fortress_2");
	}
	
}
#pragma unused FF2_FindCharacters	///just to stop all of those warnings 

void FF2_LoadCharacter(const char[] character)
{
	static char path[PLATFORM_MAX_PATH]; FormatEx(path, sizeof(path), "%s/%s", CFG_DIR, character);
	static char key_name[PLATFORM_MAX_PATH];
	
	ConfigMap cfg = new ConfigMap(path);
	if( cfg==null ) {
		LogError("[VSH2/FF2] Failed to find \"%s\" character!", character);
		return;
	}
	
	ff2.m_bosscfgs.Push(cfg);
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
	ConfigMap this_char = cfg.GetSection("character");
	
	int i;
	while( i < MAX_SUBPLUGIN_NAME ) {
		FormatEx(key_name, sizeof(key_name), "ability%i.plugin_name", ++i);
		if( !this_char.Get(key_name, path, sizeof(path)))
			break;
		
		BuildPath(Path_SM, key_name, sizeof(key_name), "plugins/freaks/%s.ff2", path);
		if( !FileExists(key_name) ) {
			LogError("[VSH2/FF2] Character \"%s\" missingg \"%s\" subplugin!", character, path);
		} else {
			ff2.m_subplugins.Push(path);
		}
	}
	
	static ConfigMap stacks;
	stacks = this_char.GetSection("download");
	if( stacks!=null ) {
		int size = stacks.Size;
		
		while( size > 0 ) {
			StringToInt(key_name, size--);
			if( this_char.Get(key_name, path, sizeof(path)) == null )
				break;
			
			if( !FileExists(path, true) ) {
				LogError("[VSH2/FF2] Character \"%s\" is missing file \"%s\"!", character, path);
			} else {
				AddFileToDownloadsTable(path);
			}
		}
	}
	
	stacks = this_char.GetSection("mod_download");
	if( stacks!=null ) {
		int size = stacks.Size;
		
		while( size > 0 ) {
			StringToInt(key_name, size--);
			if( this_char.Get(key_name, path, sizeof(path)) == null )
				break;
			
			for( int i; i < sizeof(modelT); i++ ) {
				FormatEx(key_name, PLATFORM_MAX_PATH, "%s%s", path, modelT[i]);
				if( FileExists(key_name, true) ) {
					AddFileToDownloadsTable(key_name);
				}
				else if( StrContains(key_name, ".phy") == -1 ) {
					LogError("[VSH2/FF2] Character \"%s\" is missing file \"%s\"!", character, key_name);
				}
			}
		}
	} else {
		stacks = this_char.GetSection("mat_download");
		if( stacks!=null ) {
			int size = stacks.Size;
			
			while( size > 0 ) {
				StringToInt(key_name, size--);
				if( this_char.Get(key_name, path, sizeof(path)) == null )
					break;
					
				FormatEx(key_name, sizeof(key_name), "%s.vmt", path);
				if( !FileExists(key_name, true) ) {
					LogError("[VSH2/FF2] Character \"%s\" is missing file \"%s\"!", character, key_name);
				} else {
					AddFileToDownloadsTable(key_name);
				}
				
				FormatEx(key_name, sizeof(key_name), "%s.vtf", path);
				if( !FileExists(key_name, true) ) {
					LogError("[VSH2/FF2] Character \"%s\" is missing file \"%s\"!", character, key_name);
				} else {
					AddFileToDownloadsTable(key_name);
				}
			}
		}
	}
	
	
}
#pragma unused FF2_LoadCharacter