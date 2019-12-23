public Plugin myinfo = {
	name         = "VSH2 Transparent Weapons",
	author       = "Assyrian/Nergal",
	description  = "Allows players to make their weapons transparent.",
	version      = "1.0",
	url          = "https://github.com/VSH2-Devs/Vs-Saxton-Hale-2"
};

#include <morecolors>
#include <clientprefs>

#undef REQUIRE_PLUGIN
#include <vsh2>
#define REQUIRE_PLUGIN

bool g_vsh2;
int g_invis_setting[35];

public void OnPluginStart() {
	RegConsoleCmd("sm_inviswep", MakeWeapInvis);
	RegConsoleCmd("sm_vsh2vm", MakeWeapInvis);
	RegConsoleCmd("sm_pro", MakeWeapInvis);
	
	RegAdminCmd("sm_adpro", AdminMakeWeapInvis, ADMFLAG_GENERIC);
	RegAdminCmd("sm_adinviswep", AdminMakeWeapInvis, ADMFLAG_GENERIC);
	RegAdminCmd("sm_advsh2vm", AdminMakeWeapInvis, ADMFLAG_GENERIC);
	
	for( int i; i<sizeof(g_invis_setting); i++ )
		g_invis_setting[i] = 255;
}

public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		g_vsh2 = true;
		VSH2_Hook(OnRedPlayerThink, OnRedThink);
		VSH2_Hook(OnBossThinkPost, OnRedThink);
	}
}

public void OnLibraryRemoved(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		g_vsh2 = false;
		VSH2_Unhook(OnRedPlayerThink, OnRedThink);
		VSH2_Unhook(OnBossThinkPost, OnRedThink);
	}
}

public void OnRedThink(const VSH2Player player) {
	player.SetWepInvis(g_invis_setting[player.index]);
}

public Action MakeWeapInvis(int client, int args) {
	if( !g_vsh2 ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} VSH2 is not running!");
		return Plugin_Handled;
	} else if( !client ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} You can only use this command ingame.");
		return Plugin_Handled;
	} else if( args < 1 ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} Usage: /pro <0-255>");
		return Plugin_Handled;
	}
	char number[8]; GetCmdArg(1, number, sizeof(number));
	int maxalpha = StringToInt(number);
	VSH2Player(client).SetWepInvis(maxalpha);
	g_invis_setting[client] = maxalpha;
	CPrintToChat(client, "{olive}[VSH 2]{default} your weapon transparency has been set to %i.", maxalpha);
	return Plugin_Handled;
}

public Action AdminMakeWeapInvis(int client, int args)
{
	if( !g_vsh2 ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} VSH2 is not running!");
		return Plugin_Handled;
	} else if( args < 2 ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} Usage: /adpro <target(s)> <0-255>");
		return Plugin_Handled;
	}
	char szTargetname[64]; GetCmdArg(1, szTargetname, sizeof(szTargetname));
	char szNum[8]; GetCmdArg(2, szNum, sizeof(szNum));
	int maxalpha = StringToInt(szNum);
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS+1], target_count;
	bool tn_is_ml;
	if( (target_count = ProcessTargetString(szTargetname, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0 ) {
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for( int i; i<target_count; i++ ) {
		if( IsValidClient(target_list[i]) && IsPlayerAlive(target_list[i]) ) {
			VSH2Player(target_list[i]).SetWepInvis(maxalpha);
			CPrintToChat(target_list[i], "{olive}[VSH 2]{orange}an Admin made your weapon transparent!");
		}
	}
	return Plugin_Handled;
}

stock bool IsValidClient(const int client, bool replaycheck=true)
{
	if( client <= 0 || client > MaxClients || !IsClientInGame(client) )
		return false;
	else if( GetEntProp(client, Prop_Send, "m_bIsCoaching") )
		return false;
	else if( replaycheck && (IsClientSourceTV(client) || IsClientReplay(client)) )
		return false;
	return true;
}
