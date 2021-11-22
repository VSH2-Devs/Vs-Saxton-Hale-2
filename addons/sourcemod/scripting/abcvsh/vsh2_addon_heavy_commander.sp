#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <vsh2>
#include <tf2attributes>
#include <morecolors>

#define PLYRS    MAXPLAYERS+1


enum {
	CarePackage_HealthSmall,
	CarePackage_HealthMed,
	CarePackage_HealthBig,
	CarePackage_AmmoSmall,
	CarePackage_AmmoMed,
	CarePackage_AmmoBig,
}

enum struct Commander {
	int currency;
	
	void DropCarePackage(int client) {
		float origin[3];
		if( GetClientSightEnd(client, origin) ) {
			int care_package = CreateEntityByName("item_powerup_rune");
			if( IsValidEntity(care_package) ) {
				origin[2] += 20.0;
				DispatchKeyValue(care_package, "OnPlayerTouch", "!self,Kill,,0,-1");
				DispatchSpawn(care_package);
				SetEntityRenderMode(care_package, RENDER_TRANSCOLOR);
				SetEntityRenderColor(care_package, 150, 150, 150, 150);
				SetEntProp(care_package, Prop_Data, "m_iTeamNum", VSH2Team_Neutral, 4);
				SetEntPropEnt(care_package, Prop_Send, "m_hOwnerEntity", client);
				TeleportEntity(care_package, origin, NULL_VECTOR, NULL_VECTOR);
				SetPawnTimer(EnableCarePackage, 4.0, EntIndexToEntRef(care_package));
				SDKHook(care_package, SDKHook_Touch, OnTouchCarePack);
				
				int owner = GetOwner(care_package);
				PrintToConsole(client, "owner = %i", owner);
			}
		}
	}
}

public void EnableCarePackage(int entref) {
	int ent = EntRefToEntIndex(entref);
	if( ent <= 0 || !IsValidEntity(ent) )
		return;
	
	SetEntityRenderMode(ent, RENDER_TRANSCOLOR);
	SetEntityRenderColor(ent, 255, 255, 255, 255);
	SetEntProp(ent, Prop_Data, "m_iTeamNum", VSH2Team_Red, 4);
}

public Action OnTouchCarePack(int entity, int other) {
	int care_package_team = GetEntProp(entity, Prop_Send, "m_iTeamNum");
	if( care_package_team != VSH2Team_Red )
		return Plugin_Stop;
	
	return Plugin_Continue;
}




public Plugin myinfo = {
	name = "VSH2 Heavy Commander addon",
	author = "Nergal/Assyrian",
	description = "",
	version = "1.0",
	url = "sus"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_vsh2_dropcarepack", AdminDropCarePackage, ADMFLAG_VOTE);
}


public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		LoadVSH2Hooks();
	}
}

public void LoadVSH2Hooks()
{
	if( !VSH2_HookEx(OnCallDownloads, HeavyCommanderDownloads) )
		LogError("Error loading OnCallDownloads forwards for Heavy Commander Addon.");
}


public void OnClientPutInServer(int client)
{
	
}

public void HeavyCommanderDownloads()
{
	
}


public Action AdminDropCarePackage(int client, int args)
{
	Commander c;
	c.DropCarePackage(client);
	return Plugin_Handled;
}


stock bool IsValidClient(const int client, bool nobots=false)
{ 
	if( client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)) )
		return false; 
	return IsClientInGame(client); 
}
stock int SetWeaponAmmo(const int weapon, const int ammo)
{
	int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if( owner <= 0 )
		return 0;
	if( IsValidEntity(weapon) ) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(owner, iAmmoTable+iOffset, ammo, 4, true);
	}
	return 0;
}
stock int GetWeaponAmmo(int weapon)
{
	int owner = GetOwner(weapon);
	if( owner <= 0 )
		return 0;
	if( IsValidEntity(weapon) ) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		return GetEntData(owner, iAmmoTable+iOffset, 4);
	}
	return 0;
}
stock int GetWeaponClip(const int weapon)
{
	if( IsValidEntity(weapon) ) {
		int AmmoClipTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		return GetEntData(weapon, AmmoClipTable);
	}
	return 0;
}
stock int SetWeaponClip(const int weapon, const int ammo)
{
	if( IsValidEntity(weapon) ) {
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		SetEntData(weapon, iAmmoTable, ammo, 4, true);
	}
	return 0;
}
stock int GetOwner(const int ent)
{
	if( IsValidEdict(ent) && IsValidEntity(ent) )
		return GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	return -1;
}
stock int GetSlotFromWeapon(const int iClient, const int iWeapon)
{
	for( int i=0; i<5; i++ )
		if( iWeapon == GetPlayerWeaponSlot(iClient, i) )
			return i;
	return -1;
}
stock void SetAmmo(const int client, const int slot, const int ammo)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(weapon)) {
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(client, iAmmoTable+iOffset, ammo, 4, true);
	}
}
stock int CalcBossHealth(const float initial, const int playing, const float subtract, const float exponent, const float additional)
{
	return RoundFloat( Pow((((initial)+playing)*(playing-subtract)), exponent)+additional );
}

stock void SetPawnTimer(Function func, float thinktime = 0.1, any param1 = -999, any param2 = -999)
{
	DataPack thinkpack = new DataPack();
	thinkpack.WriteFunction(func);
	thinkpack.WriteCell(param1);
	thinkpack.WriteCell(param2);
	CreateTimer(thinktime, DoThink, thinkpack, TIMER_DATA_HNDL_CLOSE);
}
public Action DoThink(Handle hTimer, DataPack hndl)
{
	hndl.Reset();
	
	Function pFunc = hndl.ReadFunction();
	Call_StartFunction( null, pFunc );
	
	any param1 = hndl.ReadCell();
	if( param1 != -999 )
		Call_PushCell(param1);
	
	any param2 = hndl.ReadCell();
	if( param2 != -999 )
		Call_PushCell(param2);
	
	Call_Finish();
	return Plugin_Continue;
}

stock int FilterPlayers(const int client, const bool alive) {
	int bitstring;
	for( int i=MaxClients; i; i-- ) {
		if( !IsValidClient(i) )
			continue;
		else if( alive && !IsPlayerAlive(i) )
			continue;
		bitstring |= 1 << i;
	}
	return bitstring;
}

stock bool GetClientSightEnd(int client, float flResult[3])
{
	float vAngles[3], vOrigin[3];
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	// get endpoint for annote
	TR_TraceRayFilter(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	bool hit = TR_DidHit();
	if( hit ) {
		float vStart[3]; TR_GetEndPosition(vStart);
		if( TR_PointOutsideWorld(vStart) )
			return false;
		GetVectorDistance(vOrigin, vStart, false);
		float Distance = -35.0;
		float vAngVec[3];
		GetAngleVectors(vAngles, vAngVec, NULL_VECTOR, NULL_VECTOR);
		flResult[0] = vStart[0] + (vAngVec[0]*Distance);
		flResult[1] = vStart[1] + (vAngVec[1]*Distance);
		flResult[2] = vStart[2] + (vAngVec[2]*Distance);
	}
	return hit;
}
public bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
	return (entity > MaxClients || !entity);
}

public Action RemoveEnt(Handle timer, any entid)
{
	int ent = EntRefToEntIndex(entid);
	if( ent > 0 && IsValidEntity(ent) )
		AcceptEntityInput(ent, "Kill");
	return Plugin_Continue;
}
