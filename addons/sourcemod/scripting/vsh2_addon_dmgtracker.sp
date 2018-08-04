#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <morecolors>
#include <vsh2>

int RGBA[MAXPLAYERS+1][4];
int damageTracker[MAXPLAYERS+1];
Handle damageHUD;

#define RED	0
#define GREEN	1
#define BLUE	2
#define ALPHA	3

public Plugin myinfo = {
	name = "VSH2 dmg tracker",
	author = "Nergal, all props to Aurora",
	description = "",
	version = "1.0",
	url = "http://uno-gamer.com"
};

public void OnPluginStart()
{
	RegConsoleCmd("haledmg", Command_damagetracker, "haledmg - Enable/disable the damage tracker.");
	RegConsoleCmd("vsh2dmg", Command_damagetracker, "haledmg - Enable/disable the damage tracker.");
	RegConsoleCmd("ff2dmg", Command_damagetracker, "haledmg - Enable/disable the damage tracker.");
	CreateTimer(0.1, Timer_Millisecond);
	CreateTimer(180.0, Timer_Advertise);
	damageHUD = CreateHudSynchronizer();
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
	damageTracker[client] = 1;
	RGBA[client][RED] = 255;
	RGBA[client][GREEN] = 90;
	RGBA[client][BLUE] = 30;
	RGBA[client][ALPHA] = 255;
}

public Action Timer_Millisecond(Handle timer)
{
	CreateTimer(0.1, Timer_Millisecond);
	int i;

	VSH2Player hTop[3];
	
	VSH2Player(0).SetProperty("iDamage", 0);
	VSH2Player player;
	for (i=MaxClients ; i ; --i) {
		if (!IsValidClient(i))
			continue;
		
		player = VSH2Player(i);
		if (player.GetProperty("bIsBoss"))
			continue;
		
		if (player.GetProperty("iDamage") >= hTop[0].GetProperty("iDamage")) {
			hTop[2] = hTop[1];
			hTop[1] = hTop[0];
			hTop[0] = VSH2Player(i);
		}
		else if (player.GetProperty("iDamage") >= hTop[1].GetProperty("iDamage")) {
			hTop[2] = hTop[1];
			hTop[1] = VSH2Player(i);
		}
		else if (player.GetProperty("iDamage") >= hTop[2].GetProperty("iDamage"))
			hTop[2] = VSH2Player(i);
	}
	
	char first[64], second[64], third[64];
	for (int z=MaxClients ; z ; --z) {
		if (!IsValidClient(z))
			continue;
		player = VSH2Player(i);
		if (damageTracker[z] > 0) {
			if (!player.GetProperty("bIsBoss") && !(GetClientButtons(z) & IN_SCORE)) {
				SetHudTextParams(0.0, 0.0, 0.2, RGBA[z][RED], RGBA[z][GREEN], RGBA[z][BLUE], RGBA[z][ALPHA]);
				if(IsValidClient(hTop[0].index))
					Format(first, sizeof(first), "[1] %N - %d\n", hTop[0].index, hTop[0].GetProperty("iDamage"));
				else Format(first, sizeof(first), "[1] N/A - 0\n");
				if(IsValidClient(hTop[1].index))
					Format(second, sizeof(second), "[2] %N - %d\n", hTop[1].index, hTop[1].GetProperty("iDamage"));
				else Format(second, sizeof(second), "[2] N/A - 0\n");
				if(IsValidClient(hTop[2].index))
					Format(third, sizeof(third), "[3] %N - %d\n", hTop[2].index, hTop[2].GetProperty("iDamage"));
				else Format(third, sizeof(third), "[3] N/A - 0\n");
				ShowSyncHudText(z, damageHUD, "%s%s%s", first, second, third);
			}
		}
	}
	return Plugin_Handled;
}

stock bool IsValidClient(const int client, bool nobots=false)
{ 
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
		return false; 
	return IsClientInGame(client); 
}  
