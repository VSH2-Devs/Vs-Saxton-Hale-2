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
			return this.GetPropInt("iNewProperty");
		}
		public set(const int i) {
			this.SetPropInt("iNewProperty", i);
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

/** YOU NEED TO USE OnAllPluginsLoaded() TO REGISTER PLUGINS BECAUSE WE NEED TO MAKE SURE THE VSH2 PLUGIN LOADS FIRST */
//int ThisPluginIndex;
public void OnAllPluginsLoaded()
{
	//VSH2_RegisterPlugin("test_plugin_boss");
	RegConsoleCmd("sm_testvsh2natives", CommandInfo, "clever command explanation heer.");
	LoadVSH2Hooks();
}

public Action CommandInfo(int client, int args)
{	PrintToConsole(client, "calling natives command");
	VSH2Player player = VSH2Player(client);
	if (player) {
		PrintToConsole(client, "VSH2Player methodmap Constructor is working");
		PrintToConsole(client, "player.index = %d | player.userid = %d", player.index, player.userid);
		int damage = player.GetPropInt("iDamage");
		PrintToConsole(client, "players damage is %d", damage);
		
		player.SetPropInt("iState", 999);
		int boss_status = player.GetPropInt("iState");
		PrintToConsole(client, "players state is %d", boss_status);
		VSH2Derived deriver = VSH2Derived(client);
		PrintToConsole(client, "made derived");
		deriver.iNewProperty = 643;
		PrintToConsole(client, "made new property and initialized it to %d", deriver.iNewProperty);
		deriver.SetPropInt("iState", 3245);
		boss_status = deriver.GetPropInt("iState");
		PrintToConsole(client, "testing inheritance and boss status is %d", boss_status);
	}
	return Plugin_Handled;
}

public void fwdOnDownloadsCalled()
{
	for (int i=0; i < 5; ++i)
		PrintToServer("Forward OnDownloadsCalled called");
}
public void fwdBossSelected(const VSH2Player base)
{
	for (int i=MaxClients; i; --i)
		if( IsClientInGame(i) )
			PrintToConsole(i, "fwdBossSelected:: ==> %N @ index: %i", base.index, base.index);
}

public void fwdOnTouchPlayer(const VSH2Player victim, const VSH2Player attacker)
{
	PrintToConsole(attacker.index, "fwdOnTouchPlayer:: ==> attacker name: %N | victim name: %N", attacker.index, victim.index);
	PrintToConsole(victim.index, "fwdOnTouchPlayer:: ==> attacker name: %N | victim name: %N", attacker.index, victim.index);
}

public void fwdOnTouchBuilding(const VSH2Player attacker, const int building)
{
	PrintToConsole(attacker.index, "fwdOnTouchBuilding:: ==> attacker name: %N | Building Reference %i", attacker.index, building);
}

public void fwdOnBossThink(const VSH2Player player)
{
	player.SetPropInt("iHealth", player.GetPropInt("iHealth") + 1);
}
public void fwdOnBossModelTimer(const VSH2Player player)
{
	player.SetPropFloat("flRAGE", player.GetPropFloat("flRAGE") + 1.0);
}

public void fwdOnBossDeath(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnBossDeath:: %N", player.index);
}

public void fwdOnBossEquipped(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnBossEquipped:: %N", player.index);
}
public void fwdOnBossInitialized(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnBossInitialized:: %N", player.index);
}
public void fwdOnMinionInitialized(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnMinionInitialized:: %N", player.index);
}
public void fwdOnBossPlayIntro(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnBossPlayIntro:: %N", player.index);
}

public Action fwdOnBossTakeDamage(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}

public Action fwdOnBossDealDamage(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossDealDamage:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossDealDamage:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}

public Action fwdOnBossDealDamage_OnStomp(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossDealDamage_OnStomp:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossDealDamage_OnStomp:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}

public Action fwdOnBossDealDamage_OnHitDefBuff(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossDealDamage_OnHitDefBuff:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossDealDamage_OnHitDefBuff:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}

public Action fwdOnBossDealDamage_OnHitCritMmmph(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossDealDamage_OnHitCritMmmph:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossDealDamage_OnHitCritMmmph:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}

public Action fwdOnBossDealDamage_OnHitMedic(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossDealDamage_OnHitMedic:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossDealDamage_OnHitMedic:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}

public Action fwdOnBossDealDamage_OnHitDeadRinger(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossDealDamage_OnHitDeadRinger:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossDealDamage_OnHitDeadRinger:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}

public Action fwdOnBossDealDamage_OnHitCloakedSpy(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossDealDamage_OnHitCloakedSpy:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossDealDamage_OnHitCloakedSpy:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}

public Action fwdOnBossDealDamage_OnHitShield(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossDealDamage_OnHitShield:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossDealDamage_OnHitShield:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}

public void fwdOnPlayerKilled(const VSH2Player player, const VSH2Player victim, Event event)
{
	PrintToConsole(player.index, "fwdOnPlayerKilled:: ==> attacker name: %N | victim name: %N", player.index, victim.index);
	PrintToConsole(victim.index, "fwdOnPlayerKilled:: ==> attacker name: %N | victim name: %N", player.index, victim.index);
}

public void fwdOnPlayerAirblasted(const VSH2Player player, const VSH2Player victim, Event event)
{
	PrintToConsole(player.index, "fwdOnPlayerAirblasted:: ==> attacker name: %N | victim name: %N", player.index, victim.index);
	PrintToConsole(victim.index, "fwdOnPlayerAirblasted:: ==> attacker name: %N | victim name: %N", player.index, victim.index);
}

public void fwdOnTraceAttack(const VSH2Player player, const VSH2Player attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
	PrintToConsole(player.index, "fwdOnTraceAttack:: ==> attacker name: %N | victim name: %N", attacker.index, player.index);
	PrintToConsole(attacker.index, "fwdOnTraceAttack:: ==> attacker name: %N | victim name: %N", attacker.index, player.index);
}

public void fwdOnBossMedicCall(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnBossMedicCall:: %N", player.index);
}

public void fwdOnBossTaunt(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnBossTaunt:: %N", player.index);
}

public void fwdOnBossKillBuilding(const VSH2Player attacker, const int building, Event event)
{
	PrintToConsole(attacker.index, "fwdOnBossKillBuilding:: %N | build -> %i", attacker.index, building);
}

public void fwdOnBossJarated(const VSH2Player victim, const VSH2Player attacker)
{
	PrintToConsole(attacker.index, "fwdOnBossJarated:: ==> attacker name: %N | victim name: %N", attacker.index, victim.index);
	PrintToConsole(victim.index, "fwdOnBossJarated:: ==> attacker name: %N | victim name: %N", attacker.index, victim.index);
}

public void fwdOnMessageIntro(const VSH2Player boss, char message[512])
{
	PrintToConsole(boss.index, "fwdOnMessageIntro:: %N", boss.index);
}

public void fwdOnBossPickUpItem(const VSH2Player player, const char item[64])
{
	PrintToConsole(player.index, "fwdOnBossPickUpItem:: %N ==> item is %s", player.index, item);
}

public void fwdOnVariablesReset(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnVariablesReset:: %N", player.index);
}
public void fwdOnUberDeployed(const VSH2Player victim, const VSH2Player attacker)
{
	PrintToConsole(attacker.index, "fwdOnUberDeployed:: ==> Medic name: %N | Target name: %N", attacker.index, victim.index);
	PrintToConsole(victim.index, "fwdOnUberDeployed:: ==> Medic name: %N | Target name: %N", attacker.index, victim.index);
}
public void fwdOnUberLoop(const VSH2Player victim, const VSH2Player attacker)
{
	PrintToConsole(attacker.index, "fwdOnUberLoop:: ==> Medic name: %N | Target name: %N", attacker.index, victim.index);
	PrintToConsole(victim.index, "fwdOnUberLoop:: ==> Medic name: %N | Target name: %N", attacker.index, victim.index);
}
public void fwdOnMusic(char song[PLATFORM_MAX_PATH], float &time, const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnMusic:: ==> Called");
}
public void fwdOnRoundEndInfo(const VSH2Player player, bool bossBool, char message[512])
{
	PrintToConsole(player.index, "fwdOnRoundEndInfo:: %N", player.index);
}
public void fwdOnLastPlayer(const VSH2Player boss)
{
	for (int i=MaxClients; i; --i)
		if( IsClientInGame(i) )
			PrintToConsole(i, "fwdOnLastPlayer:: ==> Called");
}

public void fwdOnBossHealthCheck(const VSH2Player player, bool bossBool, char message[512])
{
	PrintToConsole(player.index, "fwdOnBossHealthCheck:: %N", player.index);
}

public void fwdOnControlPointCapped(char cappers[MAXPLAYERS+1], const int team)
{
	PrintToConsole(cappers[0], "fwdOnControlPointCapped:: %N", cappers[0]);
}

public void fwdOnPrepRedTeam(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnPrepRedTeam:: %N", player.index);
}

public void fwdOnRedPlayerThink(const VSH2Player player)
{
	player.SetPropInt("iDamage", player.GetPropInt("iDamage") + 1);
}

public void fwdOnScoreTally(const VSH2Player player, int& points_earned, int& queue_earned)
{
	PrintToChatAll("fwdOnScoreTally:: %N: points - %i, queue - %i", player.index, points_earned, queue_earned);
}

public void fwdOnItemOverride(const VSH2Player player, const char[] classname, int itemdef, Handle& item)
{
	PrintToChat(player.index, "%s - %i", classname, itemdef);
}


public void LoadVSH2Hooks()
{
	if (!VSH2_HookEx(OnCallDownloads, fwdOnDownloadsCalled))
		LogError("Error loading OnCallDownloads forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossSelected, fwdBossSelected))
		LogError("Error loading OnBossSelected forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnTouchPlayer, fwdOnTouchPlayer))
		LogError("Error loading OnTouchPlayer forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnTouchBuilding, fwdOnTouchBuilding))
		LogError("Error loading OnTouchBuilding forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossThink, fwdOnBossThink))
		LogError("Error loading OnBossThink forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossModelTimer, fwdOnBossModelTimer))
		LogError("Error loading OnBossModelTimer forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossDeath, fwdOnBossDeath))
		LogError("Error loading OnBossDeath forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossEquipped, fwdOnBossEquipped))
		LogError("Error loading OnBossEquipped forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossInitialized, fwdOnBossInitialized))
		LogError("Error loading OnBossInitialized forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnMinionInitialized, fwdOnMinionInitialized))
		LogError("Error loading OnMinionInitialized forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossPlayIntro, fwdOnBossPlayIntro))
		LogError("Error loading OnBossPlayIntro forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossTakeDamage, fwdOnBossTakeDamage))
		LogError("Error loading OnBossTakeDamage forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossDealDamage, fwdOnBossDealDamage))
		LogError("Error loading OnBossDealDamage forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnPlayerKilled, fwdOnPlayerKilled))
		LogError("Error loading OnBossSelected forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnPlayerAirblasted, fwdOnPlayerAirblasted))
		LogError("Error loading OnPlayerAirblasted forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnTraceAttack, fwdOnTraceAttack))
		LogError("Error loading OnTraceAttack forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossMedicCall, fwdOnBossMedicCall))
		LogError("Error loading OnBossMedicCall forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossTaunt, fwdOnBossTaunt))
		LogError("Error loading OnBossTaunt forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossKillBuilding, fwdOnBossKillBuilding))
		LogError("Error loading OnBossKillBuilding forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossJarated, fwdOnBossJarated))
		LogError("Error loading OnBossJarated forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnMessageIntro, fwdOnMessageIntro))
		LogError("Error loading OnMessageIntro forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossPickUpItem, fwdOnBossPickUpItem))
		LogError("Error loading OnBossPickUpItem forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnVariablesReset, fwdOnVariablesReset))
		LogError("Error loading OnVariablesReset forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnUberDeployed, fwdOnUberDeployed))
		LogError("Error loading OnUberDeployed forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnUberLoop, fwdOnUberLoop))
		LogError("Error loading OnUberLoop forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnMusic, fwdOnMusic))
		LogError("Error loading OnMusic forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnRoundEndInfo, fwdOnRoundEndInfo))
		LogError("Error loading OnRoundEndInfo forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnLastPlayer, fwdOnLastPlayer))
		LogError("Error loading OnLastPlayer forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossHealthCheck, fwdOnBossHealthCheck))
		LogError("Error loading OnBossHealthCheck forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnControlPointCapped, fwdOnControlPointCapped))
		LogError("Error loading OnControlPointCapped forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnPrepRedTeam, fwdOnPrepRedTeam))
		LogError("Error loading OnPrepRedTeam forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnRedPlayerThink, fwdOnRedPlayerThink))
		LogError("Error loading OnRedPlayerThink forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnScoreTally, fwdOnScoreTally))
		LogError("Error loading OnScoreTally forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnItemOverride, fwdOnItemOverride))
		LogError("Error loading OnItemOverride forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossDealDamage_OnStomp, fwdOnBossDealDamage_OnStomp))
		LogError("Error loading OnBossDealDamage_OnStomp forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossDealDamage_OnHitDefBuff, fwdOnBossDealDamage_OnHitDefBuff))
		LogError("Error loading OnBossDealDamage_OnHitDefBuff forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossDealDamage_OnHitCritMmmph, fwdOnBossDealDamage_OnHitCritMmmph))
		LogError("Error loading OnBossDealDamage_OnHitCritMmmph forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossDealDamage_OnHitMedic, fwdOnBossDealDamage_OnHitMedic))
		LogError("Error loading OnBossDealDamage_OnHitMedic forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossDealDamage_OnHitDeadRinger, fwdOnBossDealDamage_OnHitDeadRinger))
		LogError("Error loading OnBossDealDamage_OnHitDeadRinger forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossDealDamage_OnHitCloakedSpy, fwdOnBossDealDamage_OnHitCloakedSpy))
		LogError("Error loading OnBossDealDamage_OnHitCloakedSpy forwards for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossDealDamage_OnHitShield, fwdOnBossDealDamage_OnHitShield))
		LogError("Error loading OnBossDealDamage_OnHitShield forwards for VSH2 Test plugin.");
}
