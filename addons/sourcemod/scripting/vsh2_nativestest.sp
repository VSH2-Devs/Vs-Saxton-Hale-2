#include <sourcemod>
#include <morecolors>
#include <vsh2>

#pragma semicolon		1
#pragma newdecls		required

methodmap VSH2Derived < VSH2Player
{
	public VSH2Derived (const int x, bool userid=false)
	{
		return view_as< VSH2Derived >( VSH2Player(x, userid) );
	}
	
	property int iNewProperty {
		public get() {
			return this.GetProperty("iNewProperty");
		}
		public set(const int i) {
			this.SetProperty("iNewProperty", i);
		}
	}
};

public Plugin myinfo = {
	name = "vsh2_natives_tester",
	author = "Assyrian/Nergal",
	description = "plugin for testing vsh2 natives and forwards",
	version = "1.0",
	url = "http://www.sourcemod.net/"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_testvsh2_natives", CommandInfo, "clever command explanation heer.");
}

/* YOU NEED TO USE OnAllPluginsLoaded() BECAUSE WE NEED TO MAKE SURE THE VSH2 PLUGIN LOADS FIRST */

public void OnAllPluginsLoaded()
{
	if (!VSH2_HookEx(OnCallDownloads, OnDownloadsCalled))
		LogError("Error loading OnCallDownloads forwards for VSH2 Test plugin.");
	if (!VSH2_HookEx(OnBossSelected, BossSelected))
		LogError("Error loading OnCallDownloads forwards for VSH2 Test plugin.");
}

public void OnDownloadsCalled()
{
	for (int i=0 ; i < 20 ; i += 5) {
		PrintToServer("Forward OnDownloadsCalled called");
	}
}
public void BossSelected(const VSH2Player base)
{
	for (int i=0 ; i < 20 ; i += 5) {
		PrintToServer("Forward BossSelected called");
	}
}

public Action CommandInfo(int client, int args)
{	PrintToConsole(client, "calling natives command");
	VSH2Player player = VSH2Player(client);
	if (player) {
		PrintToConsole(client, "VSH2Player methodmap Constructor is working");
		PrintToConsole(client, "player.index = %d | player.userid = %d", player.index, player.userid);
		int damage = player.GetProperty("iDamage");
		PrintToConsole(client, "players damage is %d", damage);
		
		player.SetProperty("iState", 999);
		int boss_status = player.GetProperty("iState");
		PrintToConsole(client, "players state is %d", boss_status);
		VSH2Derived deriver = VSH2Derived(client);
		PrintToConsole(client, "made derived");
		deriver.iNewProperty = 643;
		PrintToConsole(client, "made new property and initialized it to %d", deriver.iNewProperty);
		deriver.SetProperty("iState", 3245);
		boss_status = deriver.GetProperty("iState");
		PrintToConsole(client, "testing inheritance and boss status is %d", boss_status);
	}
	return Plugin_Handled;
}
