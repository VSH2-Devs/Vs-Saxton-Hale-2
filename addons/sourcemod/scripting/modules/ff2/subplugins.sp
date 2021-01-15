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

	property bool IsFull {
		public get() { return( this.Length >= FF2_MAX_SUBPLUGINS ); }
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
		for( ; i < this.Length; i++ ) {
			this.GetInfo(i, infos);
			if( strcmp(infos.name, name) )
				continue;

			if( infos.loading )
				return true;

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

		if( this.IsFull )
			return false;

		ServerCommand("sm plugins load \"freaks\\%s.ff2\"", name);

		infos.loading = true;
		strcopy(infos.name, sizeof(FF2SubPlugin::name), name);
		this.PushArray(infos, sizeof(FF2SubPlugin));
		CreateTimer(0.1, _ScheduleAddSubplugin, i, TIMER_FLAG_NO_MAPCHANGE);

		return true;
	}

	public void LoadPlugins(FF2AbilityList query_abilities) {
		char pl_ab_key[FF2_MAX_LIST_KEY];
		char plugin_name[FF2_MAX_PLUGIN_NAME];

		StringMapSnapshot snap = query_abilities.Snapshot();
		for( int i; i < snap.Length && !this.IsFull; i++ ) {
			snap.GetKey(i, pl_ab_key, sizeof(pl_ab_key));
			SplitString(pl_ab_key, "##", plugin_name, sizeof(plugin_name));
			this.TryLoadSubPlugin(plugin_name);
		}
		delete snap;
	}

	public void FindAndErase(const char[] name) {
		FF2SubPlugin infos;
		for( int i; i < this.Length; i++ ) {
			this.GetInfo(i, infos);
			if( !strcmp(infos.name, name) ) {
				this.Erase(i);
				break;
			}
		}
	}

	public void UnloadAllSubPlugins() {
		FF2SubPlugin info;
		for( int i; i < this.Length; i++ ) {
			this.GetInfo(i, info);
			ServerCommand("sm plugins unload \"freaks\\%s.ff2\"", info.name);
		}
		this.Clear();
	}
}


static Handle _FindPlugin(const char[] name)
{
	char pl_name[PLATFORM_MAX_PATH];
	FormatEx(pl_name, sizeof(pl_name), "freaks\\%s.ff2", name);
	Handle pl = FindPluginByFile(pl_name);
	if( !pl || GetPluginStatus(pl)!=Plugin_Running )
	{
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
