#include <sourcemod>
#include <vsh2>

#pragma semicolon		1
#pragma newdecls		required


public Plugin myinfo = {
	name        = "vsh2_block_rage",
	author      = "Assyrian/Nergal",
	description = "plugin for testing vsh2 rage blocking",
	version     = "1.0",
	url         = "http://www.sourcemod.net/"
};


public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		LoadVSH2Hooks();
	}
}

public Action fwdOnBossMedicCall(const VSH2Player player)
{
	PrintToConsole(player.index, "Blocking fwdOnBossMedicCall");
	return Plugin_Stop;
}

public Action fwdOnBossTaunt(const VSH2Player player)
{
	PrintToConsole(player.index, "Blocking fwdOnBossTaunt");
	return Plugin_Stop;
}


public void LoadVSH2Hooks()
{
	if( !VSH2_HookEx(OnBossMedicCall, fwdOnBossMedicCall) )
		LogError("Error Hooking OnBossMedicCall forward for VSH2 Test plugin.");
		
	if( !VSH2_HookEx(OnBossTaunt, fwdOnBossTaunt) )
		LogError("Error Hooking OnBossTaunt forward for VSH2 Test plugin.");
}
