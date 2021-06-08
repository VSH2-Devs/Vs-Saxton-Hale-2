
methodmap FF2GameMode < VSH2GameMode {
	public static void HookToVSH2() {
		InitVSH2Bridge();
	}
	
	public static void UnhookFromVSH2() {
		RemoveVSH2Bridge();
	}
	
	public static void LoadFF2() {
		ff2.m_charcfg = new ConfigMap(PATH_TO_CHAR_CFG);
		ff2.m_hud[HUD_Jump] = vsh2_gm.hHUD;
		if ( !ff2.m_hud[HUD_Weighdown] ) {
			ff2.m_hud[HUD_Weighdown] = CreateHudSynchronizer();
		}
		
		FF2GameMode.HookToVSH2();
		
		for( int i=MaxClients; i > 0; i-- ) {
			if( IsClientInGame(i) ) {
				OnClientPutInServer(i);
			}
		}
		
		ff2.m_plugins = new FF2PluginList();
	}
	

	/// renames all subplugins ending in "ff2" with "smx" to comply with new plugin loading rule.
	public static void PrepareSubplugins() {
		char plugin_directory_path[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, plugin_directory_path, PLATFORM_MAX_PATH, "plugins/freaks");

		Handle plugin_directory = OpenDirectory(plugin_directory_path);

		/// return early if there is no directory to read from.
		if( plugin_directory == INVALID_HANDLE ) {
			return;
		}

		FileType file_type;
		char plugin_buffer[PLATFORM_MAX_PATH];
		char renamed_plugin_buffer[PLATFORM_MAX_PATH];
		while(ReadDirEntry(plugin_directory, plugin_buffer, PLATFORM_MAX_PATH, file_type))
		{
			if( file_type != FileType_File ) {
				continue;
			}

			/// make sure the file ends with ".ff2"
			int extension_index = FindCharInString(plugin_buffer, '.', true);
			if( extension_index == -1 || extension_index + 3 > PLATFORM_MAX_PATH || plugin_buffer[extension_index+1] != 'f'|| plugin_buffer[extension_index+2] != 'f' || plugin_buffer[extension_index+3] != '2' ) {
				continue;
			}

			strcopy(renamed_plugin_buffer, PLATFORM_MAX_PATH, plugin_buffer);
			plugin_buffer[extension_index+1] = 's';
			plugin_buffer[extension_index+2] = 'm';
			plugin_buffer[extension_index+3] = 'x';

			/// put the paths in the buffers
			Format(plugin_buffer, PLATFORM_MAX_PATH, "%s/%s", plugin_directory_path, plugin_buffer);
			Format(renamed_plugin_buffer, PLATFORM_MAX_PATH, "%s/%s", plugin_directory_path, renamed_plugin_buffer);

			/// remove existing file with colliding name and rename the subplugin file
			DeleteFile(renamed_plugin_buffer);
			RenameFile(renamed_plugin_buffer, plugin_buffer);
		}
	}

	public static void LateLoadSubplugins() {
		if( FF2GameMode.GetPropAny("iRoundState") == StateRunning ) {
			FF2Player[] bosses = new FF2Player[MaxClients];
			int count = VSH2GameMode.GetBosses(ToFF2Player(bosses), false);
	
			FF2Player player;
			for( int i; i < count && !ff2.m_plugins.IsFull; i++ ) {
				player = bosses[i];
				FF2AbilityList list = player.HookedAbilities;
				if( list ) {
					ff2.m_plugins.LoadPlugins(list);
				}
			}
		}
	}
	
	public static void RemoveSubplugins(bool do_delete=false) {
		if( ff2.m_plugins != null ) {
			ff2.m_plugins.UnloadAllSubPlugins();
		}
		if( do_delete ) {
			delete ff2.m_plugins;
		}
	}
	
	public static void RemoveCfgMgr() {
		if( ff2_cfgmgr != null ) {
			ff2_cfgmgr.DeleteAll();
		}
		delete ff2_cfgmgr;
	}
}