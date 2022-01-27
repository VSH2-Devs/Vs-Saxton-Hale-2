/**
 * Subplugins struct
 *
 * name = Plugin Name
 * hndl = Plugin Handle
 */
enum struct FF2SubPlugin {
	char name[FF2_MAX_PLUGIN_NAME];
	Handle hndl;
	bool loading;
}

methodmap FF2PluginList < ArrayList {
	public FF2PluginList() {
		return( view_as< FF2PluginList >(new ArrayList(sizeof(FF2SubPlugin))) );
	}

	public void GetInfo(int index, FF2SubPlugin infos) {
		this.GetArray(index, infos, sizeof(FF2SubPlugin));
	}

	public void SetInfo(int index, FF2SubPlugin infos) {
		this.SetArray(index, infos, sizeof(FF2SubPlugin));
	}

	public bool TryLoadSubPlugin(const char[] name) {
		if( !ValidateName(name) ) {
			LogError("[VSH2/FF2] Invalid Plugin Name: \"%s\"", name);
			return false;
		}

		FF2SubPlugin infos;
		int i;
		int size = this.Length;
		// find plugin if it already exists
		for( ; i < size; i++ ) {
			this.GetInfo(i, infos);
			if( strcmp(infos.name, name) )
				continue;

			if( infos.loading )
				return false;

			Handle iter = GetPluginIterator();
			for( Handle pl=ReadPlugin(iter); MorePlugins(iter); pl=ReadPlugin(iter) ) {
				if( pl==infos.hndl ) {
					delete iter;
					return true;
				}
			}

			delete iter;

			infos.loading = true;
			this.SetInfo(i, infos);
			CreateTimer(0.1, _ScheduleAddSubplugin, i, TIMER_FLAG_NO_MAPCHANGE);
			return true;
		}

		if( size>=FF2_MAX_SUBPLUGINS )
			return false;

		ServerCommand("sm plugins load \"freaks\\%s.smx\"", name);

		infos.loading = true;
		strcopy(infos.name, sizeof(FF2SubPlugin::name), name);
		this.PushArray(infos, sizeof(FF2SubPlugin));
		CreateTimer(0.1, _ScheduleAddSubplugin, i, TIMER_FLAG_NO_MAPCHANGE);

		return true;
	}

	public int LoadPluginsEx(FF2AbilityList query_abilities, int remaining_size) {
		char plugin_name[FF2_MAX_PLUGIN_NAME];
		int required_size = query_abilities.Length;
		int size_left = remaining_size - required_size;
		if (size_left < required_size)
			required_size = size_left;

		int num_of_plugins;
		for( int i; i<required_size; i++ ) {
			FF2Ability ability = query_abilities.Get(i);
			ability.GetPlugin(plugin_name);
			if( this.TryLoadSubPlugin(plugin_name) )
				num_of_plugins++;
		}
		return num_of_plugins;
	}

	public void LoadPlugins(FF2AbilityList query_abilities) {
		this.LoadPluginsEx(query_abilities, FF2_MAX_SUBPLUGINS - ff2.m_plugins.Length);
	}

	public void FindAndErase(const char[] name) {
		FF2SubPlugin infos;
		for( int i=this.Length-1; i>=0; i-- ) {
			this.GetInfo(i, infos);
			if( !strcmp(infos.name, name) ) {
				this.Erase(i);
				break;
			}
		}
	}

	public void UnloadAllSubPlugins() {
		FF2SubPlugin info;
		for( int i=this.Length-1; i>=0; i-- ) {
			this.GetInfo(i, info);
			InsertServerCommand("sm plugins unload \"freaks\\%s.smx\"", info.name);
		}
		this.Clear();
		ServerExecute();
	}

	/// renames all subplugins ending in "ff2" with "smx" to comply with new plugin loading rule.
	public static void FixSubPlugins() {
		char plugin_directory_path[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, plugin_directory_path, PLATFORM_MAX_PATH, "plugins/freaks");

		DirectoryListing plugin_directory = OpenDirectory(plugin_directory_path);

		/// return early if there is no directory to read from.
		if( plugin_directory==INVALID_HANDLE ) {
			return;
		}

		FileType file_type;
		char plugin_buffer[PLATFORM_MAX_PATH];
		char renamed_plugin_buffer[PLATFORM_MAX_PATH];
		while( plugin_directory.GetNext(plugin_buffer, PLATFORM_MAX_PATH, file_type) ) {
			if( file_type != FileType_File ) {
				continue;
			}

			/// make sure the file ends with ".ff2"
			int extension_index = FindCharInString(plugin_buffer, '.', true);
			if( extension_index == -1 || extension_index > FF2_MAX_PLUGIN_NAME - 1 || plugin_buffer[extension_index+1] != 'f'|| plugin_buffer[extension_index+2] != 'f' || plugin_buffer[extension_index+3] != '2' || plugin_buffer[extension_index+4] != 0 ) {
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

		delete plugin_directory;
	}

	/// unloads all plugins with extension '.smx' in 'freaks' folder
	public static void ForceUnloadAllSubPlugins() {
		char path[PLATFORM_MAX_PATH], filename[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, path, PLATFORM_MAX_PATH, "plugins/freaks");

		FileType filetype;
		DirectoryListing pl_directory = OpenDirectory(path);
		while( pl_directory.GetNext(filename, sizeof(filename), filetype) ) {
			if( filetype==FileType_File && StrContains(filename, ".smx", false)!=-1 ) {
				InsertServerCommand("sm plugins unload freaks/%s", filename);
			}
		}

		delete pl_directory;
		ServerExecute();
	}
}


static Handle _FindPlugin(const char[] name)
{
	char pl_name[PLATFORM_MAX_PATH];
	FormatEx(pl_name, sizeof(pl_name), "freaks\\%s.smx", name);
	Handle pl = FindPluginByFile(pl_name);
	if( !pl || GetPluginStatus(pl)!=Plugin_Running ) {
		LogError("[VSH2/FF2] Failed to load plugin: %s", pl_name);
		return null;
	}

	return pl;
}

static Action _ScheduleAddSubplugin(Handle timer, int pos)
{
	if( !ff2.m_vsh2 )
		return Plugin_Continue;

	FF2SubPlugin info; ff2.m_plugins.GetInfo(pos, info);
	info.hndl = _FindPlugin(info.name);
	info.loading = false;
	ff2.m_plugins.SetInfo(pos, info);

	return Plugin_Continue;
}
