public Plugin myinfo = {
	name         = "VSH2 Noboss",
	author       = "Bottiger",
	description  = "Adds the command !noboss to reset queue points every round automatically",
	version      = "1.1",
	url          = "https://www.skial.com"
};

#include <morecolors>
#include <clientprefs>

#undef REQUIRE_PLUGIN
#include <vsh2>
#define REQUIRE_PLUGIN

bool g_vsh2;
Cookie g_noboss_cookie;
ConVar vsh2_enabled;

public void OnPluginStart() {
	g_noboss_cookie = new Cookie("hale_noboss", "Set queue points to 0 every round automatically", CookieAccess_Public);
	RegConsoleCmd("sm_noboss", NoBossCmd);
	RegConsoleCmd("sm_nohale", NoBossCmd);
	RegConsoleCmd("sm_haletoggle", NoBossCmd);
	RegConsoleCmd("sm_ff2toggle", NoBossCmd);
	RegConsoleCmd("sm_bosstoggle", NoBossCmd);
	RegConsoleCmd("sm_vshtoggle", NoBossCmd);
}

public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		g_vsh2 = true;
		vsh2_enabled = FindConVar("vsh2_enabled");
		VSH2_Hook(OnScoreTally, OnScore);
	}
}

public void OnLibraryRemoved(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		g_vsh2 = false;
	}
}

public Action OnScore(const VSH2Player player, int& points_earned, int& queue_earned) {
	char setting[2];
	g_noboss_cookie.Get(player.index, setting, sizeof(setting));
	if(setting[0] == '1') {
		CPrintToChat(player.index, "{olive}[VSH 2]{default} Queue Points set to 0. Type /noboss to toggle.");
		queue_earned = 0;
	}
}

public Action NoBossCmd(int client, int args) {
	if(client == 0) {
		return Plugin_Handled;
	}
	if(!g_vsh2 || !vsh2_enabled.BoolValue) {
		return Plugin_Continue;
	}
	
	char setting[2];
	g_noboss_cookie.Get(client, setting, sizeof(setting));
	if(setting[0] == '1') {
		CPrintToChat(client, "{olive}[VSH 2]{default} Queue point gain enabled.");
		g_noboss_cookie.Set(client, "0");
	} else {
		CPrintToChat(client, "{olive}[VSH 2]{default} Queue points will be set to 0 at the end of each round.");
		SetQueuePoints(client, 0);
		g_noboss_cookie.Set(client, "1");
	}
	return Plugin_Handled;
}

void SetQueuePoints(int client, int value) {
	VSH2Player p = VSH2Player(client);
	p.SetPropInt("iQueue", value);
}
