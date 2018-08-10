#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>
#include <vsh2>

#define PLYRS				MAXPLAYERS+1


public Plugin myinfo = {
	name = "VSH2 bosscap subplugin",
	author = "Nergal/Assyrian",
	description = "",
	version = "1.0",
	url = "sus"
};

public void OnAllPluginsLoaded()
{
	LoadVSH2Hooks();
}

public void LoadVSH2Hooks()
{
	if (!VSH2_HookEx(OnControlPointCapped, BoozOnControlPointCapped))
		LogError("Error loading OnControlPointCapped forwards for VSH2 Booz Capping plugin.");
	
	if (!VSH2_HookEx(OnUberLoop, BoozOnUberLoop))
		LogError("Error loading OnUberLoop forwards for VSH2 Booz Capping plugin.");
}


public void BoozOnControlPointCapped(char cappers[MAXPLAYERS+1], const int team)
{
	int len = strlen(cappers);
	switch( team ) {
		case 2: {
			for( int i=0 ; i<len ; i++ ) {
				TF2_AddCondition(cappers[i], TFCond_DefenseBuffed, 20.0);
				if( GetClientHealth(cappers[i]) < 500 )
					SetEntityHealth(cappers[i], 500);
			}
		}
		case 3: {
			VSH2Player boss;
			for( int i=0 ; i<len ; i++ ) {
				boss = VSH2Player(cappers[i]);
				if( boss.GetProperty("bIsBoss") || boss.GetProperty("bIsMinion") ) {
					TF2_AddCondition(cappers[i], TFCond_Buffed, 20.0);
				}
			}
			for( int n=MaxClients ; n ; n-- ) {
				if( !IsValidClient(n) || !IsPlayerAlive(n) || IsClientObserver(n) || GetClientTeam(n) == 3 )
					continue;
				
				if( GetClientHealth(n) > 50 )
					SetEntityHealth(n, 50);
			}
		}
	}
}

public void BoozOnUberLoop(const VSH2Player medic, const VSH2Player ubertarget)
{
	for( int l=0 ; l<2 ; l++ ) {
		int ent_wep = GetPlayerWeaponSlot(ubertarget.index, l);
		//PrintToConsole(uberer, "ent_wep == %d", ent_wep);
		if( ent_wep <= 0 )
			continue;
		
		int wepindex = ubertarget.GetWeaponSlotIndex(l);
		//PrintToConsole(uberer, "wepindex == %d", wepindex);
		if( wepindex <= 0 )
			continue;
		
		int maxAmmo = ubertarget.GetAmmoTable(l); //Munitions[ubered][l][0];
		//PrintToConsole(uberer, "maxAmmo == %d", maxAmmo);
		if( maxAmmo )
			SetWeaponAmmo(ent_wep, maxAmmo);
		
		if( wepindex==730 || wepindex==1079 || wepindex==305 || wepindex==45 )
			continue;
		
		int maxClip = ubertarget.GetClipTable(l); //Munitions[ubered][l][1];
		//PrintToConsole(uberer, "maxClip == %d", maxClip);
		if( maxClip )
			SetWeaponClip(ent_wep, maxClip);
	}
}

stock bool IsValidClient(const int client, bool nobots=false)
{ 
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
		return false; 
	return IsClientInGame(client); 
}
stock int SetWeaponAmmo(const int weapon, const int ammo)
{
	int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if (owner <= 0)
		return 0;
	if (IsValidEntity(weapon)) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(owner, iAmmoTable+iOffset, ammo, 4, true);
	}
	return 0;
}
stock int GetWeaponAmmo(int weapon)
{
	int owner = GetOwner(weapon);
	if (owner <= 0)
		return 0;
	if (IsValidEntity(weapon)) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		return GetEntData(owner, iAmmoTable+iOffset, 4);
	}
	return 0;
}
stock int GetWeaponClip(const int weapon)
{
	if (IsValidEntity(weapon)) {
		int AmmoClipTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		return GetEntData(weapon, AmmoClipTable);
	}
	return 0;
}
stock int SetWeaponClip(const int weapon, const int ammo)
{
	if (IsValidEntity(weapon)) {
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		SetEntData(weapon, iAmmoTable, ammo, 4, true);
	}
	return 0;
}
stock int GetOwner(const int ent)
{
	if ( IsValidEdict(ent) && IsValidEntity(ent) )
		return GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	return -1;
}
stock int GetSlotFromWeapon(const int iClient, const int iWeapon)
{
	for (int i=0; i<5; i++) {
		if ( iWeapon == GetPlayerWeaponSlot(iClient, i) )
			return i;
	}
	return -1;
}
