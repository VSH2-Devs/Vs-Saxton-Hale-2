
void InitConVars()
{
	/// ConVars subplugins depend on
	CreateConVar("ff2_oldjump", "1", "Use old Saxton Hale jump equations", _, true, 0.0, true, 1.0);
	CreateConVar("ff2_base_jumper_stun", "0", "Whether or not the Base Jumper should be disabled when a player gets stunned", _, true, 0.0, true, 1.0);
	CreateConVar("ff2_solo_shame", "0", "Always insult the boss for solo raging", _, true, 0.0, true, 1.0);
	
	ff2.m_cvars.m_version 		= FindConVar("vsh2_version");
	ff2.m_cvars.m_fljarate 		= FindConVar("vsh2_jarate_rage");
	ff2.m_cvars.m_flairblast 	= FindConVar("vsh2_airblast_rage");
	ff2.m_cvars.m_flmusicvol 	= FindConVar("vsh2_music_volume");
	ff2.m_cvars.m_nextmap 		= FindConVar("sm_nextmap");
	
	if( !ff2.m_cvars.m_companion_min )
		ff2.m_cvars.m_companion_min	= CreateConVar("ff2_companion_min", "4", "Minimum players required to enable duos", FCVAR_NOTIFY, .hasMin = true, .min = 1.0, .hasMax = true, .max = 34.0);
	if( !ff2.m_cvars.m_pack_name )
		ff2.m_cvars.m_pack_name 	= CreateConVar("ff2_current", "Freak Fortress 2", "Freak Fortress 2 current boss pack name", FCVAR_NOTIFY);
	if( !ff2.m_cvars.m_pack_limit )
		ff2.m_cvars.m_pack_limit	= CreateConVar("ff2_pack_limit", "16", "Minimum players required to enable duos", FCVAR_NOTIFY, .hasMin = true, .min = 2.0);
	if( !ff2.m_cvars.m_pack_scramble )
		ff2.m_cvars.m_pack_scramble	= CreateConVar("ff2_pack_scramble", "1", "Minimum players required to enable duos", FCVAR_NOTIFY);
	
	ff2.m_cvars.m_nextmap.AddChangeHook(_OnNextMap);
	
	RegAdminCmd("sm_ff2_load_plugin", Load_Plugin, ADMFLAG_RCON, "Load/Reload a FF2 SubPlugin");
	RegAdminCmd("sm_ff2_unload_plugin", Unload_Plugin, ADMFLAG_RCON, "Unload FF2 SubPlugin");
}


void _OnNextMap(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if( IsVSHMap(newValue) )
		CreateTimer(0.1, Timer_DisplayCharPack, .flags = TIMER_FLAG_NO_MAPCHANGE);
}


Action Timer_DisplayCharPack(Handle timer)
{
	if( VSH2GameMode.GetPropAny("bPackSelected") )
		return Plugin_Continue;
		
	if( IsVoteInProgress() ) {
		CreateTimer(5.0, Timer_DisplayCharPack, .flags = TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Continue;
	}
	
	ConfigMap packs = ff2.m_charcfg;
	if( packs.Size < 2 )
		return Plugin_Continue;
	
	StringMapSnapshot snap = packs.Snapshot();
	
	char pack[64], _item[4];
	ArrayList list = new ArrayList(sizeof(pack));
	
	int i;
	for( ; i < snap.Length; i++ ) {
		snap.GetKey(i, pack, sizeof(pack));
		list.PushString(pack);
	}
	
	delete snap;
	
	if( ff2.m_cvars.m_pack_scramble.BoolValue )
		list.Sort(Sort_Random, Sort_String);
	
	Menu menu = new Menu(Handle_PackSelect, MENU_ACTIONS_ALL);
	menu.SetTitle("Please vote for the boss pack for the next map.");
	
	int pack_limit = ff2.m_cvars.m_pack_limit.IntValue, list_limit = list.Length;
	for( i = 0; i < list_limit && i < pack_limit; i++ ) {
		list.GetString(i, pack, sizeof(pack));
		IntToString(i, _item, sizeof(_item));
		menu.AddItem(_item, pack);
	}
	
	menu.ExitButton = false;
	ConVar voteDuration = FindConVar("sm_mapvote_voteduration");
	menu.DisplayVoteToAll(voteDuration ? voteDuration.IntValue : 20);
	return Plugin_Continue;
}

int Handle_PackSelect(Menu menu,  MenuAction action, int param1, int param2)
{
	switch( action ) {
		case MenuAction_End: delete menu;
		case MenuAction_VoteEnd: {
			char nextMap[32], packName[48];
			menu.GetItem(param1, nextMap, sizeof(nextMap), .dispBuf = packName, .dispBufLen = sizeof(packName));
			
			ff2.m_cvars.m_pack_name.SetString(packName);
			ff2.m_cvars.m_nextmap.GetString(nextMap, sizeof(nextMap));
			CPrintToChatAll("{olive}[VSH 2]{default} The next FF2 Pack for %s will be %s.", nextMap, packName);
			
			VSH2GameMode.SetProp("bPackSelected", true);
		}
	}
}

static bool IsVSHMap(const char[] nextmap)
{
	if( !ff2.m_vsh2 )
		return false;
	
	char config[PLATFORM_MAX_PATH];
	if( FileExists("bNextMapToFF2") || FileExists("bNextMapToHale") )
		return true;
	
	BuildPath(Path_SM, config, PLATFORM_MAX_PATH, "configs/freak_fortress_2/maps.cfg");
	if( !FileExists(config) ) {
		BuildPath(Path_SM, config, PLATFORM_MAX_PATH, "configs/saxton_hale/saxton_hale_maps.cfg");
		if( !FileExists(config) ) {
			LogError("[VSH 2] ERROR: **** Unable to find VSH/FF2 Compatible Map Configs, Disabling VSH 2 ****");
			return false;
		}
	}
	
	File file = OpenFile(config, "r");
	if( !file ) {
		LogError("[VSH 2] **** Error Reading Maps from %s Config, Disabling VSH 2 ****", config);
		return false;
	}
	
	int tries;
	while( file.ReadLine(config, sizeof(config)) && tries < 100 ) {
		++tries;
		if( tries == 100 ) {
			LogError("[VSH 2] **** Breaking Loop Looking For a Map, Disabling VSH 2 ****");
			return false;
		}
			
		Format(config, strlen(config)-1, config);
		if( !strncmp(config, "//", 2, false) )
			continue;
		
		if( StrContains(nextmap, config, false) != -1 || StrContains(config, "all", false) != -1 ) {
			file.Close();
			return true;
		}
	}
	delete file;
	return false;
}


static Action Load_Plugin(int client, int argc)
{
	char pl_name[FF2_MAX_PLUGIN_NAME];
	char path[PLATFORM_MAX_PATH];
	GetCmdArgString(pl_name, sizeof(pl_name));
	
	BuildPath(Path_SM, path, sizeof(path), "plugins\\freaks\\%s.ff2", pl_name);
	if( !FileExists(path) ) {
		ReplyToCommand(client, "[VSH2/FF2] Plugin: \"%s\" doesn't exists", pl_name);
		return Plugin_Handled;
	}
	
	if( !ff2.m_plugins.TryLoadSubPlugin(pl_name) ) {
		ReplyToCommand(client, "[VSH2/FF2] Failed to reload SubPlugin: \"%s\"", pl_name);
	}
	else ReplyToCommand(client, "[VSH2/FF2] Plugin: \"%s\" Loaded successfully", pl_name);
	
	return Plugin_Handled;
}

static Action Unload_Plugin(int client, int argc)
{
	char pl_name[FF2_MAX_PLUGIN_NAME];
	
	GetCmdArgString(pl_name, sizeof(pl_name));
	ff2.m_plugins.FindAndErase(pl_name);
	
	ServerCommand("sm plugins unload \"freaks\\%s.ff2\"", pl_name);
	return Plugin_Handled;
}