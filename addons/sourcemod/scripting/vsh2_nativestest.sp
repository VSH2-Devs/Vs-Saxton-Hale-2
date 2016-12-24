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
	RegConsoleCmd("sm_testvsh2natives", CommandInfo, "clever command explanation heer.");
	LoadVSH2Hooks();
}

/* YOU NEED TO USE OnAllPluginsLoaded() TO REGISTER PLUGINS BECAUSE WE NEED TO MAKE SURE THE VSH2 PLUGIN LOADS FIRST */

//int ThisPluginIndex;
public void OnAllPluginsLoaded()
{
	/*
	ThisPluginIndex = VSH2_RegisterPlugin("test_plugin_boss");
	*/
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

public void fwdOnDownloadsCalled()
{
	for (int i=0 ; i < 5 ; ++i)
		PrintToServer("Forward OnDownloadsCalled called");
}
public void fwdBossSelected(const VSH2Player base)
{
	for (int i=MaxClients ; i ; --i)
		if ( IsClientInGame(i) )
			PrintToConsole(i, "fwdBossSelected:: ==> %N @ index: %i", base.index, base.index);
}

public void fwdOnTouchPlayer(const VSH2Player Victim, const VSH2Player Attacker)
{
	PrintToConsole(Attacker.index, "fwdOnTouchPlayer:: ==> Attacker name: %N | Victim name: %N", Attacker.index, Victim.index);
	PrintToConsole(Victim.index, "fwdOnTouchPlayer:: ==> Attacker name: %N | Victim name: %N", Attacker.index, Victim.index);
}

public void fwdOnTouchBuilding(const VSH2Player Attacker, const int BuildingRef)
{
	PrintToConsole(Attacker.index, "fwdOnTouchBuilding:: ==> Attacker name: %N | Building Reference %i", Attacker.index, BuildingRef);
}

public void fwdOnBossThink(const VSH2Player Player)
{
	int health = Player.GetProperty("iHealth");
	Player.SetProperty("iHealth", ++health);
}
public void fwdOnBossModelTimer(const VSH2Player Player)
{
	float rage = Player.GetProperty("flRAGE");
	Player.SetProperty("flRAGE", rage+1.0);
}

public void fwdOnBossDeath(const VSH2Player Player)
{
	PrintToConsole(Player.index, "fwdOnBossDeath:: %N", Player.index);
}

public void fwdOnBossEquipped(const VSH2Player Player)
{
	PrintToConsole(Player.index, "fwdOnBossEquipped:: %N", Player.index);
}
public void fwdOnBossInitialized(const VSH2Player Player)
{
	PrintToConsole(Player.index, "fwdOnBossInitialized:: %N", Player.index);
}
public void fwdOnMinionInitialized(const VSH2Player Player)
{
	PrintToConsole(Player.index, "fwdOnMinionInitialized:: %N", Player.index);
}
public void fwdOnBossPlayIntro(const VSH2Player Player)
{
	PrintToConsole(Player.index, "fwdOnBossPlayIntro:: %N", Player.index);
}

public Action fwdOnBossTakeDamage(VSH2Player Victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage:: ==> Attacker name: %N | Victim name: %N", attacker, Victim.index);
	PrintToConsole(Victim.index, "fwdOnBossTakeDamage:: ==> Attacker name: %N | Victim name: %N", attacker, Victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossDealDamage(VSH2Player Victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossDealDamage:: ==> Attacker name: %N | Victim name: %N", attacker, Victim.index);
	PrintToConsole(Victim.index, "fwdOnBossDealDamage:: ==> Attacker name: %N | Victim name: %N", attacker, Victim.index);
	return Plugin_Continue;
}

public void fwdOnPlayerKilled(const VSH2Player player, const VSH2Player victim, Event event)
{
	PrintToConsole(player.index, "fwdOnPlayerKilled:: ==> Attacker name: %N | Victim name: %N", player.index, victim.index);
	PrintToConsole(victim.index, "fwdOnPlayerKilled:: ==> Attacker name: %N | Victim name: %N", player.index, victim.index);
}

public void fwdOnPlayerAirblasted(const VSH2Player player, const VSH2Player victim, Event event)
{
	PrintToConsole(player.index, "fwdOnPlayerAirblasted:: ==> Attacker name: %N | Victim name: %N", player.index, victim.index);
	PrintToConsole(victim.index, "fwdOnPlayerAirblasted:: ==> Attacker name: %N | Victim name: %N", player.index, victim.index);
}

public void fwdOnTraceAttack(const VSH2Player player, const VSH2Player attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
	PrintToConsole(player.index, "fwdOnTraceAttack:: ==> Attacker name: %N | Victim name: %N", attacker.index, player.index);
	PrintToConsole(attacker.index, "fwdOnTraceAttack:: ==> Attacker name: %N | Victim name: %N", attacker.index, player.index);
}

public void fwdOnBossMedicCall(const VSH2Player Player)
{
	PrintToConsole(Player.index, "fwdOnBossMedicCall:: %N", Player.index);
}

public void fwdOnBossTaunt(const VSH2Player Player)
{
	PrintToConsole(Player.index, "fwdOnBossTaunt:: %N", Player.index);
}

public void fwdOnBossKillBuilding(const VSH2Player Attacker, const int building, Event event)
{
	PrintToConsole(Attacker.index, "fwdOnBossKillBuilding:: %N | build -> %i", Attacker.index, building);
}

public void fwdOnBossJarated(const VSH2Player Victim, const VSH2Player Attacker)
{
	PrintToConsole(Attacker.index, "fwdOnBossJarated:: ==> Attacker name: %N | Victim name: %N", Attacker.index, Victim.index);
	PrintToConsole(Victim.index, "fwdOnBossJarated:: ==> Attacker name: %N | Victim name: %N", Attacker.index, Victim.index);
}

public void fwdOnMessageIntro(ArrayList bossArray)
{
	int bosses = bossArray.Length;
	VSH2Player boss;
	for (int i=0 ; i<bosses ; ++i) {
		boss = bossArray.Get(i);
		PrintToConsole(boss.index, "fwdOnMessageIntro:: %N", boss.index);
	}
}

public void fwdOnBossPickUpItem(const VSH2Player Player, const char item[64])
{
	PrintToConsole(Player.index, "fwdOnBossPickUpItem:: %N ==> item is %s", Player.index, item);
}

public void fwdOnVariablesReset(const VSH2Player Player)
{
	PrintToConsole(Player.index, "fwdOnVariablesReset:: %N", Player.index);
}
public void fwdOnUberDeployed(const VSH2Player Victim, const VSH2Player Attacker)
{
	PrintToConsole(Attacker.index, "fwdOnUberDeployed:: ==> Medic name: %N | Target name: %N", Attacker.index, Victim.index);
	PrintToConsole(Victim.index, "fwdOnUberDeployed:: ==> Medic name: %N | Target name: %N", Attacker.index, Victim.index);
}
public void fwdOnUberLoop(const VSH2Player Victim, const VSH2Player Attacker)
{
	PrintToConsole(Attacker.index, "fwdOnUberLoop:: ==> Medic name: %N | Target name: %N", Attacker.index, Victim.index);
	PrintToConsole(Victim.index, "fwdOnUberLoop:: ==> Medic name: %N | Target name: %N", Attacker.index, Victim.index);
}
public void fwdOnMusic(char song[PLATFORM_MAX_PATH], float& time)
{
	for (int i=MaxClients ; i ; --i)
		if ( IsClientInGame(i) )
			PrintToConsole(i, "fwdOnMusic:: ==> Called");
}
public void fwdOnRoundEndInfo(ArrayList bossArray, bool bosswin)
{
	int bosses = bossArray.Length;
	VSH2Player boss;
	for (int i=0 ; i<bosses ; ++i) {
		boss = bossArray.Get(i);
		PrintToConsole(boss.index, "fwdOnRoundEndInfo:: %N", boss.index);
	}
}
public void fwdOnLastPlayer()
{
	for (int i=MaxClients ; i ; --i)
		if ( IsClientInGame(i) )
			PrintToConsole(i, "fwdOnLastPlayer:: ==> Called");
}

public void fwdOnBossHealthCheck(const VSH2Player Player)
{
	PrintToConsole(Player.index, "fwdOnBossHealthCheck:: %N", Player.index);
}

public void fwdOnControlPointCapped(char cappers[MAXPLAYERS+1], const int team)
{
	PrintToConsole(cappers[0], "fwdOnControlPointCapped:: %N", cappers[0]);
}

public void fwdOnPrepRedTeam(const VSH2Player Player)
{
	PrintToConsole(Player.index, "fwdOnPrepRedTeam:: %N", Player.index);
}

public void fwdOnRedPlayerThink(const VSH2Player Player)
{
	int health = Player.GetProperty("iDamage");
	Player.SetProperty("iDamage", ++health);
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
}
