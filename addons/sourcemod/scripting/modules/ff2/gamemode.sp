#include "modules/ff2/subplugins.sp"

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
		FF2PluginList.ForceUnloadAllSubPlugins();
		FF2PluginList.FixSubPlugins();
	}

	public static void LateLoadSubplugins() {
		if( FF2GameMode.GetPropAny("iRoundState") == StateRunning ) {
			FF2Player[] bosses = new FF2Player[MaxClients];

			int count = VSH2GameMode.GetBosses(ToFF2Player(bosses), false);
			int size_left = FF2_MAX_SUBPLUGINS - ff2.m_plugins.Length;

			FF2Player player;
			for( int i; i < count && size_left>0; i++ ) {
				player = bosses[i];
				FF2AbilityList list = player.HookedAbilities;
				if( list ) {
					size_left -= ff2.m_plugins.LoadPluginsEx(list, size_left);
				}
			}
		}
	}

	public static void RemoveSubPlugins(bool do_delete=false) {
		if( !do_delete && ff2.m_plugins ) {
			ff2.m_plugins.UnloadAllSubPlugins();
		}
		else if( ff2.m_plugins ) {
			FF2PluginList.ForceUnloadAllSubPlugins();
			delete ff2.m_plugins;
		}
	}

	public static void RemoveCfgMgr() {
		if( ff2_cfgmgr ) {
			ff2_cfgmgr.DeleteAll();
		}
		delete ff2_cfgmgr;
	}
}