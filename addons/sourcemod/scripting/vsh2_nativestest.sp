#include <sourcemod>
#include <morecolors>
#include <vsh2>

#pragma semicolon    1
#pragma newdecls     required

methodmap VSH2Derived < VSH2Player {
	public VSH2Derived(const int x, bool userid=false) {
		return view_as< VSH2Derived >(VSH2Player(x, userid));
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
	name        = "vsh2_natives_tester",
	author      = "Assyrian/Nergal",
	description = "plugin for testing vsh2 natives and forwards",
	version     = "1.0",
	url         = "https://github.com/VSH2-Devs/Vs-Saxton-Hale-2"
};


public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		//VSH2_RegisterPlugin("test_plugin_boss");
		RegConsoleCmd("sm_testvsh2natives", CommandInfo, "clever command explanation heer.");
		LoadVSH2Hooks();
	}
}

public Action CommandInfo(int client, int args)
{	PrintToConsole(client, "calling natives command");
	VSH2Player player = VSH2Player(client);
	if( player ) {
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
		
		int max_bosses = VSH2_GetMaxBosses();
		for( int i; i<=max_bosses; i++ ) {
			char boss_name[MAX_BOSS_NAME_SIZE];
			VSH2_GetBossNameByIndex(i, boss_name);
			PrintToConsole(client, "VSH2_GetBossNames :: name[%d]: '%s'", i, boss_name);
		}
	}
	return Plugin_Handled;
}

public void fwdOnDownloadsCalled()
{
	for( int i; i<3; ++i ) {
		PrintToServer("Forward OnDownloadsCalled called");
	}
}
public Action fwdBossSelected(const VSH2Player base)
{
	for( int i=MaxClients; i; --i ) {
		if( IsClientInGame(i) ) {
			PrintToConsole(i, "fwdBossSelected:: ==> %N @ index: %i", base.index, base.index);
		}
	}
	return Plugin_Continue;
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
	PrintToConsole(player.index, "fwdOnBossThink:: ==> player name: %N", player.index);
}

public void fwdOnBossThinkPost(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnBossThinkPost:: ==> player name: %N", player.index);
}

public void fwdOnBossModelTimer(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnBossModelTimer:: ==> player name: %N", player.index);
}

public void fwdOnBossDeath(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnBossDeath:: %N", player.index);
}

public void fwdOnBossEquipped(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnBossEquipped:: %N", player.index);
}

public void fwdOnBossEquippedPost(const VSH2Player player)
{
	PrintToConsole(player.index, "OnBossEquippedPost:: %N", player.index);
}
public void fwdOnBossInitialized(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnBossInitialized:: %N", player.index);
}
public void fwdOnMinionInitialized(const VSH2Player player, const VSH2Player master)
{
	PrintToConsole(player.index, "fwdOnMinionInitialized:: %N, owner boss: %N", player.index, master.index);
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

public Action fwdOnBossTakeDamage_OnStabbed(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnStabbed:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnStabbed:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnTelefragged(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnTelefragged:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnTelefragged:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnSwordTaunt(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnSwordTaunt:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnSwordTaunt:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnHeavyShotgun(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnHeavyShotgun:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnHeavyShotgun:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnSniped(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnSniped:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnSniped:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnThirdDegreed(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnThirdDegreed:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnThirdDegreed:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnHitSword(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnHitSword:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnHitSword:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnHitFanOWar(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnHitFanOWar:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnHitFanOWar:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnHitCandyCane(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnHitCandyCane:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnHitCandyCane:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnMarketGardened(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnMarketGardened:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnMarketGardened:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnPowerJack(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnPowerJack:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnPowerJack:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnKatana(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnKatana:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnKatana:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnAmbassadorHeadshot(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnAmbassadorHeadshot:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnAmbassadorHeadshot:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnDiamondbackManmelterCrit(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnDiamondbackManmelterCrit:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnDiamondbackManmelterCrit:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnHolidayPunch(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnHolidayPunch:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnHolidayPunch:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnTriggerHurt(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnTriggerHurt:: ==> victim name: %N", victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnMantreadsStomp(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnMantreadsStomp:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnMantreadsStomp:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnPlayerTakeFallDamage(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnPlayerTakeFallDamage:: ==> victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnPlayerTakeFallDamage:: ==> victim name: %N", attacker, victim.index);
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

public void fwdOnMessageIntro(const VSH2Player boss, char message[MAXMESSAGE])
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
	PrintToConsole(attacker.index, "fwdOnUberLoop:: ==> Medic name: %N | Target name: %N", victim.index, attacker.index);
	PrintToConsole(victim.index, "fwdOnUberLoop:: ==> Medic name: %N | Target name: %N", victim.index, attacker.index);
}
public void fwdOnMusic(char song[PLATFORM_MAX_PATH], float &time, const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnMusic:: ==> Called");
}
public void fwdOnRoundEndInfo(const VSH2Player player, bool bossBool, char message[MAXMESSAGE])
{
	PrintToConsole(player.index, "fwdOnRoundEndInfo:: %N", player.index);
}
public void fwdOnLastPlayer(const VSH2Player boss)
{
	for( int i=MaxClients; i; --i ) {
		if( IsClientInGame(i) ) {
			PrintToConsole(i, "fwdOnLastPlayer:: ==> Called");
		}
	}
}

public void fwdOnBossHealthCheck(const VSH2Player player, bool bossBool, char message[MAXMESSAGE])
{
	PrintToConsole(player.index, "fwdOnBossHealthCheck:: %N", player.index);
}

public void fwdOnControlPointCapped(char cappers[MAXPLAYERS+1], const int team)
{
	int cappers_len = strlen(cappers);
	for( int i; i<cappers_len; i++ ) {
		int client = cappers[i];
		if( 0 < client <= MaxClients && IsClientInGame(client) ) {
			PrintToConsole(client, "fwdOnControlPointCapped:: capper: %i %N", client, client);
		}
	}
}

public void fwdOnPrepRedTeam(const VSH2Player player) {
	PrintToConsole(player.index, "fwdOnPrepRedTeam:: %N", player.index);
}

public void fwdOnRedPlayerThink(const VSH2Player player) {
	PrintToConsole(player.index, "fwdOnRedPlayerThink:: %N", player.index);
}

public void fwdOnRedPlayerThinkPost(const VSH2Player player) {
	PrintToConsole(player.index, "fwdOnRedPlayerThinkPost:: %N", player.index);
}

public void fwdOnScoreTally(const VSH2Player player, int& points_earned, int& queue_earned) {
	PrintToChatAll("fwdOnScoreTally:: %N: points - %i, queue - %i", player.index, points_earned, queue_earned);
}

public Action fwdOnItemOverride(const VSH2Player player, const char[] classname, int itemdef, TF2Item& item)
{
	PrintToChat(player.index, "%s - %i", classname, itemdef);
	return Plugin_Continue;
}

public void fwdOnBossSuperJump(const VSH2Player player)
{
	PrintToChat(player.index, "OnBossSuperJump:: %N", player.index);
}

public Action fwdOnBossDoRageStun(const VSH2Player player, float& dist)
{
	PrintToChat(player.index, "OnBossDoRageStun:: %N - dist: %f", player.index, dist);
	return Plugin_Continue;
}

public void fwdOnBossWeighDown(const VSH2Player player)
{
	PrintToChat(player.index, "OnBossWeighDown:: %N", player.index);
}

public void fwdOnRPSTaunt(const VSH2Player loser, const VSH2Player winner)
{
	PrintToChatAll("fwdOnRPSTaunt:: winner: %N | loser: %N", winner.index, loser.index);
}

public Action fwdOnBossAirShotProj(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossAirShotProj:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossAirShotProj:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}

public Action fwdOnBossTakeFallDamage(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(victim.index, "fwdOnBossTakeFallDamage:: ==> victim name: %N | damage: %f", victim.index, damage);
	return Plugin_Continue;
}

public void fwdOnBossGiveRage(VSH2Player player, int damage, float& amount)
{
	PrintToConsole(player.index, "fwdOnBossGiveRage:: ==> player name: %N | damage: %i, calculated rage amount: %f", player.index, damage, amount);
}

public void fwdOnBossCalcHealth(VSH2Player player, int& max_health, const int boss_count, const int red_players)
{
	PrintToChat(player.index, "fwdOnBossCalcHealth:: ==> boss name: %N | max health: %i, boss count: %i, players: %i", player.index, max_health, boss_count, red_players);
}
/* /// trust me this works lol.
public void fwdOnSoundHook(const VSH2Player player, char sample[PLATFORM_MAX_PATH], int& channel, float& volume, int& level, int& pitch, int& flags)
{
	PrintToChat(player.index, "fwdOnSoundHook:: ==> boss name: %N | sample: %s, channel: %i, volume: %f, level: %i, pitch: %i, flags: %i", player.index, sample, channel, volume, level, pitch, flags);
}
*/
public void fwdOnRoundStart(const VSH2Player[] bosses, const int boss_count, const VSH2Player[] red_players, const int red_count)
{
	for( int i; i<boss_count; i++ ) {
		PrintToChatAll("fwdOnRoundStart :: boss name: %N", bosses[i].index);
	}
	for( int i; i<red_count; i++ ) {
		PrintToChatAll("fwdOnRoundStart :: red name: %N", red_players[i].index);
	}
}

public void fwdOnHelpMenu(const VSH2Player player, Menu menu)
{
	PrintToConsole(player.index, "fwdOnHelpMenu:: ==> player name: %N", player.index);
	menu.AddItem("-1", "Item from OnHelpMenu. (nativestest)");
}

public void fwdOnHelpMenuSelect(const VSH2Player player, Menu menu, int selection)
{
	PrintToConsole(player.index, "fwdOnHelpMenuSelect:: ==> player name: %N | selection: %i", player.index, selection);
	char info[10];
	char classname[64];
	menu.GetItem(selection, info, sizeof(info), _, classname, sizeof(classname));
}

public void fwdOnDrawGameTimer(int& seconds)
{
	PrintToChatAll("fwdOnDrawGameTimer :: seconds: %d", seconds);
}

public void fwdOnPlayerClimb(const VSH2Player player, const int weapon, float& upwardvel, float& health, bool& attackdelay)
{
	PrintToConsole(player.index, "fwdOnPlayerClimb:: ==> player name: %N | weapon index: %d | upwardvel: %f | health: %f | delay: %i", player.index, weapon, upwardvel, health, attackdelay);
}

public Action fwdOnBannerDeployed(const VSH2Player owner, const BannerType banner)
{
	/// m_bRageDraining, m_flRageMeter
	char banner_name[64];
	switch( banner ) {
		case BannerBuff:     banner_name = "buff banner";
		case BannerDefBuff:  banner_name = "battalion's backup";
		case BannerHealBuff: banner_name = "concheror";
	}
	PrintToChatAll("fwdOnBannerDeployed:: ==> player name: %N | banner type: %s", owner.index, banner_name);
	return Plugin_Continue;
}

public Action fwdOnBannerEffect(const VSH2Player player, const VSH2Player owner, const BannerType banner)
{
	/// m_bRageDraining, m_flRageMeter
	char banner_name[64];
	switch( banner ) {
		case BannerBuff:     banner_name = "buff banner";
		case BannerDefBuff:  banner_name = "battalion's backup";
		case BannerHealBuff: banner_name = "concheror";
	}
	PrintToChatAll("fwdOnBannerEffect:: ==> player name: %N | banner owner: %N | banner type: %s", player.index, owner.index, banner_name);
	return Plugin_Continue;
}

public Action fwdOnUberLoopEnd(const VSH2Player medic, const VSH2Player target, float& charge)
{
	PrintToChatAll("fwdOnUberLoopEnd:: ==> medic name: %N | charge: %f", medic.index, charge);
	return Plugin_Continue;
}

public void fwdOnRedPlayerHUD(const VSH2Player player, char hud[PLAYER_HUD_SIZE]) {
	PrintToConsole(player.index, "fwdOnRedPlayerHUD:: ==> '%s'", hud);
}

public void fwdOnRedPlayerCrits(const VSH2Player player, int& crit_flags) {
	PrintToConsole(player.index, "fwdOnRedPlayerCrits:: ==> crit flags: '%i'", crit_flags);
}

public void fwdOnShowStats(const VSH2Player top_players[3]) {
	for( int i; i<3; i++ ) {
		PrintToChatAll("fwdOnShowStats:: ==> #%i: %N", i, top_players[i].index);
	}
}

public void LoadVSH2Hooks() {
	if( !VSH2_HookEx(OnCallDownloads, fwdOnDownloadsCalled) )
		LogError("Error Hooking OnCallDownloads forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossSelected, fwdBossSelected) )
		LogError("Error Hooking OnBossSelected forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnTouchPlayer, fwdOnTouchPlayer) )
		LogError("Error Hooking OnTouchPlayer forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnTouchBuilding, fwdOnTouchBuilding) )
		LogError("Error Hooking OnTouchBuilding forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossThink, fwdOnBossThink) )
		LogError("Error Hooking OnBossThink forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossModelTimer, fwdOnBossModelTimer) )
		LogError("Error Hooking OnBossModelTimer forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossDeath, fwdOnBossDeath) )
		LogError("Error Hooking OnBossDeath forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossEquipped, fwdOnBossEquipped) )
		LogError("Error Hooking OnBossEquipped forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossInitialized, fwdOnBossInitialized) )
		LogError("Error Hooking OnBossInitialized forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnMinionInitialized, fwdOnMinionInitialized) )
		LogError("Error Hooking OnMinionInitialized forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossPlayIntro, fwdOnBossPlayIntro) )
		LogError("Error Hooking OnBossPlayIntro forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage, fwdOnBossTakeDamage) )
		LogError("Error Hooking OnBossTakeDamage forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossDealDamage, fwdOnBossDealDamage) )
		LogError("Error Hooking OnBossDealDamage forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnPlayerKilled, fwdOnPlayerKilled) )
		LogError("Error Hooking OnPlayerKilled forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnPlayerAirblasted, fwdOnPlayerAirblasted) )
		LogError("Error Hooking OnPlayerAirblasted forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnTraceAttack, fwdOnTraceAttack) )
		LogError("Error Hooking OnTraceAttack forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossMedicCall, fwdOnBossMedicCall) )
		LogError("Error Hooking OnBossMedicCall forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossTaunt, fwdOnBossTaunt) )
		LogError("Error Hooking OnBossTaunt forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossKillBuilding, fwdOnBossKillBuilding) )
		LogError("Error Hooking OnBossKillBuilding forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossJarated, fwdOnBossJarated) )
		LogError("Error Hooking OnBossJarated forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnMessageIntro, fwdOnMessageIntro) )
		LogError("Error Hooking OnMessageIntro forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossPickUpItem, fwdOnBossPickUpItem) )
		LogError("Error Hooking OnBossPickUpItem forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnVariablesReset, fwdOnVariablesReset) )
		LogError("Error Hooking OnVariablesReset forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnUberDeployed, fwdOnUberDeployed) )
		LogError("Error Hooking OnUberDeployed forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnUberLoop, fwdOnUberLoop) )
		LogError("Error Hooking OnUberLoop forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnMusic, fwdOnMusic) )
		LogError("Error Hooking OnMusic forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnRoundEndInfo, fwdOnRoundEndInfo) )
		LogError("Error Hooking OnRoundEndInfo forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnLastPlayer, fwdOnLastPlayer) )
		LogError("Error Hooking OnLastPlayer forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossHealthCheck, fwdOnBossHealthCheck) )
		LogError("Error Hooking OnBossHealthCheck forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnControlPointCapped, fwdOnControlPointCapped) )
		LogError("Error Hooking OnControlPointCapped forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnPrepRedTeam, fwdOnPrepRedTeam) )
		LogError("Error Hooking OnPrepRedTeam forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnRedPlayerThink, fwdOnRedPlayerThink) )
		LogError("Error Hooking OnRedPlayerThink forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnScoreTally, fwdOnScoreTally) )
		LogError("Error Hooking OnScoreTally forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnItemOverride, fwdOnItemOverride) )
		LogError("Error Hooking OnItemOverride forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossDealDamage_OnStomp, fwdOnBossDealDamage_OnStomp) )
		LogError("Error Hooking OnBossDealDamage_OnStomp forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossDealDamage_OnHitDefBuff, fwdOnBossDealDamage_OnHitDefBuff) )
		LogError("Error Hooking OnBossDealDamage_OnHitDefBuff forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossDealDamage_OnHitCritMmmph, fwdOnBossDealDamage_OnHitCritMmmph) )
		LogError("Error Hooking OnBossDealDamage_OnHitCritMmmph forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossDealDamage_OnHitMedic, fwdOnBossDealDamage_OnHitMedic) )
		LogError("Error Hooking OnBossDealDamage_OnHitMedic forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossDealDamage_OnHitDeadRinger, fwdOnBossDealDamage_OnHitDeadRinger) )
		LogError("Error Hooking OnBossDealDamage_OnHitDeadRinger forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossDealDamage_OnHitCloakedSpy, fwdOnBossDealDamage_OnHitCloakedSpy) )
		LogError("Error Hooking OnBossDealDamage_OnHitCloakedSpy forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossDealDamage_OnHitShield, fwdOnBossDealDamage_OnHitShield) )
		LogError("Error Hooking OnBossDealDamage_OnHitShield forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnStabbed, fwdOnBossTakeDamage_OnStabbed) )
		LogError("Error Hooking OnBossTakeDamage_OnStabbed forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnTelefragged, fwdOnBossTakeDamage_OnTelefragged) )
		LogError("Error Hooking OnBossTakeDamage_OnTelefragged forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnSwordTaunt, fwdOnBossTakeDamage_OnSwordTaunt) )
		LogError("Error Hooking OnBossTakeDamage_OnSwordTaunt forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnHeavyShotgun, fwdOnBossTakeDamage_OnHeavyShotgun) )
		LogError("Error Hooking OnBossTakeDamage_OnHeavyShotgun forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnSniped, fwdOnBossTakeDamage_OnSniped) )
		LogError("Error Hooking OnBossTakeDamage_OnSniped forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnThirdDegreed, fwdOnBossTakeDamage_OnThirdDegreed) )
		LogError("Error Hooking OnBossTakeDamage_OnThirdDegreed forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnHitSword, fwdOnBossTakeDamage_OnHitSword) )
		LogError("Error Hooking OnBossTakeDamage_OnHitSword forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnHitFanOWar, fwdOnBossTakeDamage_OnHitFanOWar) )
		LogError("Error Hooking OnBossTakeDamage_OnHitFanOWar forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnHitCandyCane, fwdOnBossTakeDamage_OnHitCandyCane) )
		LogError("Error Hooking OnBossTakeDamage_OnHitCandyCane forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnMarketGardened, fwdOnBossTakeDamage_OnMarketGardened) )
		LogError("Error Hooking OnBossTakeDamage_OnMarketGardened forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnPowerJack, fwdOnBossTakeDamage_OnPowerJack) )
		LogError("Error Hooking OnBossTakeDamage_OnPowerJack forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnKatana, fwdOnBossTakeDamage_OnKatana) )
		LogError("Error Hooking OnBossTakeDamage_OnKatana forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnAmbassadorHeadshot, fwdOnBossTakeDamage_OnAmbassadorHeadshot) )
		LogError("Error Hooking OnBossTakeDamage_OnAmbassadorHeadshot forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnDiamondbackManmelterCrit, fwdOnBossTakeDamage_OnDiamondbackManmelterCrit) )
		LogError("Error Hooking OnBossTakeDamage_OnDiamondbackManmelterCrit forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnHolidayPunch, fwdOnBossTakeDamage_OnHolidayPunch) )
		LogError("Error Hooking OnBossTakeDamage_OnHolidayPunch forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossSuperJump, fwdOnBossSuperJump) )
		LogError("Error Hooking OnBossSuperJump forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossDoRageStun, fwdOnBossDoRageStun) )
		LogError("Error Hooking OnBossDoRageStun forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossWeighDown, fwdOnBossWeighDown) )
		LogError("Error Hooking OnBossWeighDown forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnRPSTaunt, fwdOnRPSTaunt) )
		LogError("Error Hooking OnRPSTaunt forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossAirShotProj, fwdOnBossAirShotProj) )
		LogError("Error Hooking OnBossAirShotProj forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossTakeFallDamage, fwdOnBossTakeFallDamage) )
		LogError("Error Hooking OnBossTakeFallDamage forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossGiveRage, fwdOnBossGiveRage) )
		LogError("Error Hooking OnBossGiveRage forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossCalcHealth, fwdOnBossCalcHealth) )
		LogError("Error Hooking OnBossCalcHealth forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnTriggerHurt, fwdOnBossTakeDamage_OnTriggerHurt) )
		LogError("Error Hooking OnBossTakeDamage_OnTriggerHurt forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnMantreadsStomp, fwdOnBossTakeDamage_OnMantreadsStomp) )
		LogError("Error Hooking OnBossTakeDamage_OnMantreadsStomp forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossThinkPost, fwdOnBossThinkPost) )
		LogError("Error Hooking OnBossThinkPost forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBossEquippedPost, fwdOnBossEquippedPost) )
		LogError("Error Hooking OnBossEquippedPost forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnPlayerTakeFallDamage, fwdOnPlayerTakeFallDamage) )
		LogError("Error Hooking OnPlayerTakeFallDamage forward for VSH2 Test plugin.");
	
	//if( !VSH2_HookEx(OnSoundHook, fwdOnSoundHook) )
	//	LogError("Error Hooking OnSoundHook forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnRoundStart, fwdOnRoundStart) )
		LogError("Error Hooking OnRoundStart forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnHelpMenu, fwdOnHelpMenu) )
		LogError("Error Hooking OnHelpMenu forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnHelpMenuSelect, fwdOnHelpMenuSelect) )
		LogError("Error Hooking OnHelpMenuSelect forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnDrawGameTimer, fwdOnDrawGameTimer) )
		LogError("Error Hooking OnDrawGameTimer forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnPlayerClimb, fwdOnPlayerClimb) )
		LogError("Error Hooking OnPlayerClimb forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBannerDeployed, fwdOnBannerDeployed) )
		LogError("Error Hooking OnBannerDeployed forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnBannerEffect, fwdOnBannerEffect) )
		LogError("Error Hooking OnBannerEffect forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnUberLoopEnd, fwdOnUberLoopEnd) )
		LogError("Error Hooking OnUberLoopEnd forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnRedPlayerThinkPost, fwdOnRedPlayerThinkPost) )
		LogError("Error Hooking OnRedPlayerThinkPost forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnRedPlayerHUD, fwdOnRedPlayerHUD) )
		LogError("Error Hooking OnRedPlayerHUD forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnRedPlayerCrits, fwdOnRedPlayerCrits) )
		LogError("Error Hooking OnRedPlayerCrits forward for VSH2 Test plugin.");
	
	if( !VSH2_HookEx(OnShowStats, fwdOnShowStats) )
		LogError("Error Hooking OnShowStats forward for VSH2 Test plugin.");
}