
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