#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <clientprefs>

#include <morecolors>
#include <vsh2>

int RGBA[MAXPLAYERS+1][4];
int damageTracker[MAXPLAYERS+1];
Handle damageHUD;

#define RED     0
#define GREEN   1
#define BLUE    2
#define ALPHA   3

public Plugin myinfo = {
	name = "VSH2 dmg tracker",
	author = "Nergal, all props to Aurora",
	description = "",
	version = "1.0",
	url = "http://uno-gamer.com"
};

Handle haledmg_cookie;

public void OnAllPluginsLoaded()
{
	haledmg_cookie = RegClientCookie("vsh2_haledmg", "cookie to track boss damage settings", CookieAccess_Public);
	RegConsoleCmd("haledmg", Command_damagetracker, "haledmg - Enable/disable the damage tracker.");
	RegConsoleCmd("vsh2dmg", Command_damagetracker, "haledmg - Enable/disable the damage tracker.");
	RegConsoleCmd("ff2dmg", Command_damagetracker, "haledmg - Enable/disable the damage tracker.");
	CreateTimer(180.0, Timer_Advertise);
	damageHUD = CreateHudSynchronizer();
}

public void OnMapStart()
{
	CreateTimer(0.1, Timer_Millisecond, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_Advertise(Handle timer)
{
	CreateTimer(180.0, Timer_Advertise);
	CPrintToChatAll("{olive}[VSH 2]{default} Type \"!haledmg on\" to display the top 3 players! Type \"!haledmg off\" to turn it off again.");
	return Plugin_Handled;
}

public Action Command_damagetracker(int client, int args)
{
	if (client == 0) {
		PrintToServer("[VSH 2] The damage tracker cannot be enabled by Console.");
		return Plugin_Handled;
	}
	if (args == 0) {
		char playersetting[3];
		if (damageTracker[client] == 0) playersetting = "Off";
		if (damageTracker[client] > 0) playersetting = "On";
		CPrintToChat(client, "{olive}[VSH 2]{default} The damage tracker is {olive}%s{default}.\n{olive}[VSH 2]{default} Change it by saying \"!haledmg on [R] [G] [B] [A]\" or \"!haledmg off\"!", playersetting);
		return Plugin_Handled;
	}
	char arg1[64];
	int newval = 3;
	GetCmdArg(1, arg1, sizeof(arg1));
	if (StrEqual(arg1,"off",false))
		damageTracker[client] = 0;
	if (StrEqual(arg1,"on",false))
		damageTracker[client] = 3;
	if (StrEqual(arg1,"0",false))
		damageTracker[client] = 0;
	if (StrEqual(arg1,"of",false))
		damageTracker[client] = 0;
	if (!StrEqual(arg1,"off",false) && !StrEqual(arg1,"on",false) && !StrEqual(arg1,"0",false) && !StrEqual(arg1,"of",false))
	{
		newval = StringToInt(arg1);
		char newsetting[3];
		if (newval > 8)
			newval = 8;
		if (newval != 0)
			damageTracker[client] = newval;
		if (newval != 0 && damageTracker[client] == 0)
			newsetting = "off";
		if (newval != 0 && damageTracker[client] > 0)
			newsetting = "on";
		CPrintToChat(client, "{olive}[VSH 2]{default} The damage tracker is now {lightgreen}%s{default}!", newsetting);
		
		if( AreClientCookiesCached(client) ) {
			SetClientCookie(client, haledmg_cookie, damageTracker[client] ? "1" : "0");
		}
	}
	
	char r[4], g[4], b[4], a[4];
	if(args >= 2) {
		GetCmdArg(2, r, sizeof(r));
		if(!StrEqual(r, "_"))
			RGBA[client][RED] = StringToInt(r);
	}
	
	if(args >= 3) {
		GetCmdArg(3, g, sizeof(g));
		if(!StrEqual(g, "_"))
			RGBA[client][GREEN] = StringToInt(g);
	}
	if(args >= 4) {
		GetCmdArg(4, b, sizeof(b));
		if(!StrEqual(b, "_"))
			RGBA[client][BLUE] = StringToInt(b);
	}
	if(args >= 5) {
		GetCmdArg(5, a, sizeof(a));
		if(!StrEqual(a, "_"))
			RGBA[client][ALPHA] = StringToInt(a);
	}
	return Plugin_Handled;
}

public void OnClientPutInServer(int client)
{
	damageTracker[client] = 0;
	RGBA[client][RED] = 255;
	RGBA[client][GREEN] = 90;
	RGBA[client][BLUE] = 30;
	RGBA[client][ALPHA] = 255;
	
	if( AreClientCookiesCached(client) ) {
		char setting[2]; GetClientCookie(client, haledmg_cookie, setting, sizeof(setting));
		damageTracker[client] = StringToInt(setting);
	}
}

public Action Timer_Millisecond(Handle timer)
{
	if( VSH2GameMode_GetPropInt("iRoundState") != StateRunning )
		return Plugin_Continue;
	
	int i;
	VSH2Player hTop[3];
	VSH2Player(0).SetPropInt("iDamage", 0);
	VSH2Player player;
	for (i=MaxClients; i; --i) {
		if (!IsValidClient(i) || GetClientTeam(i) < VSH2Team_Red)
			continue;
		
		player = VSH2Player(i);
		if (player.GetPropInt("bIsBoss") || player.GetPropInt("iDamage") == 0)
			continue;
		else if (player.GetPropInt("iDamage") >= hTop[0].GetPropInt("iDamage")) {
			hTop[2] = hTop[1];
			hTop[1] = hTop[0];
			hTop[0] = player;
		} else if (player.GetPropInt("iDamage") >= hTop[1].GetPropInt("iDamage")) {
			hTop[2] = hTop[1];
			hTop[1] = player;
		} else if (player.GetPropInt("iDamage") >= hTop[2].GetPropInt("iDamage"))
			hTop[2] = player;
	}
	
	char score1[64], score2[64], score3[64];
	if( hTop[0].index )
		GetClientName(hTop[0].index, score1, sizeof(score1));
	else {
		strcopy(score1, sizeof(score1), "nil");
		hTop[0] = view_as< VSH2Player >(0);
	}
	
	if( hTop[1].index )
		GetClientName(hTop[1].index, score2, sizeof(score2));
	else {
		strcopy(score2, sizeof(score2), "nil");
		hTop[1] = view_as< VSH2Player >(0);
	}
	
	if( hTop[2].index )
		GetClientName(hTop[2].index, score3, sizeof(score3));
	else {
		strcopy(score3, sizeof(score3), "nil");
		hTop[2] = view_as< VSH2Player >(0);
	}
	
	for (i=MaxClients; i; --i) {
		if (!IsValidClient(i))
			continue;
		player = VSH2Player(i);
		if (damageTracker[i] > 0) {
			if (!player.GetPropInt("bIsBoss") && !(GetClientButtons(i) & IN_SCORE)) {
				int dmg1 = hTop[0].GetPropInt("iDamage");
				int dmg2 = hTop[1].GetPropInt("iDamage");
				int dmg3 = hTop[2].GetPropInt("iDamage");
				SetHudTextParams(0.0, 0.0, 0.2, RGBA[i][RED], RGBA[i][GREEN], RGBA[i][BLUE], RGBA[i][ALPHA]);
				ShowSyncHudText(i, damageHUD, "%s - %i\n%s - %i\n%s - %i", score1, dmg1, score2, dmg2, score3, dmg3);
			}
		}
	}
	return Plugin_Continue;
}

stock bool IsValidClient(const int client, bool nobots=false)
{ 
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
		return false; 
	return IsClientInGame(client); 
}
