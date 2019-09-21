#include <morecolors>
#include <clientprefs>

#undef REQUIRE_PLUGIN
#include <vsh2>
#define REQUIRE_PLUGIN

#pragma semicolon        1
#pragma newdecls         required

public Plugin myinfo = {
	name           = "VSH2 Noboss",
	author         = "Bottiger",
	description    = "Adds the command !noboss to reset queue points every round automatically",
	version        = "1.0",
	url            = "https://www.skial.com"
};

Handle g_noboss_cookie;

public void OnAllPluginsLoaded() 
{
	g_noboss_cookie = RegClientCookie("hale_noboss", "Set queue points to 0 every round automatically", CookieAccess_Public);
	RegConsoleCmd("sm_noboss", NoBossCmd);
	RegConsoleCmd("sm_nohale", NoBossCmd);
	VSH2_Hook(OnScoreTally, OnScore);
}

public void OnScore(const VSH2Player player, int& points_earned, int& queue_earned)
{
	int i = player.index;
	char setting[2]; GetClientCookie(i, g_noboss_cookie, setting, sizeof(setting));
	if( setting[0]=='1' ) {
		CPrintToChat(i, "{olive}[VSH 2]{default} Points set to 0. Type /noboss to toggle.");
		points_earned = 0;
		queue_earned = 0;
	}
}

public Action NoBossCmd(int client, int args)
{
	if( !client )
		return Plugin_Handled;
	
	char setting[2]; GetClientCookie(client, g_noboss_cookie, setting, sizeof(setting));
	if( setting[0] == '1' ) {
		CPrintToChat(client, "{olive}[VSH 2]{default} Queue point gain enabled.");
		SetClientCookie(client, g_noboss_cookie, "0");
	} else {
		CPrintToChat(client, "{olive}[VSH 2]{default} Queue points will be set to 0 at the end of each round.");
		SetQueuePoints(client, 0);
		SetClientCookie(client, g_noboss_cookie, "1");
	}
	return Plugin_Handled;
}

void SetQueuePoints(int client, int value)
{
	VSH2Player p = VSH2Player(client);
	p.SetPropInt("iQueue", value);
}
