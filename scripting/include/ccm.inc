#if defined _ccm_included
 #endinput
#endif
#define _ccm_included

#define PLYR			MAXPLAYERS+1 //easier to highlight and copypaste over
#define MAXCLASSES		250 //who's gonna think up over 250 custom classes anyways? Let alone GETTING to 250 lol

#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>
#include <tf2items>
#include <adt>

#pragma semicolon 1
#pragma newdecls optional

//=================================================== [ V A R I A B L E S ] ========================================================

Handle hArrayClass = INVALID_HANDLE;	// List <Subplugin>
Handle hTrieClass = INVALID_HANDLE;	// Map <Boss Name, Subplugin Handle>

stock void SetHandles()
{
	hArrayClass = CreateArray();
	hTrieClass = CreateTrie();
}

enum CCMError
{
	Error_None,				// All-Clear :>
	Error_InvalidName,			// Invalid name for Class
	Error_AlreadyExists,			// Class Already Exists....
	Error_SubpluginAlreadyRegistered,	// The plugin registering a Class already has a Class registered
}
//=================================================================================================================================



//=================================================== [ N A T I V E S ] ==========================================================

native int CCM_RegisterClass(char[] NameOfClass); //use this in EVERY class subplugin, ok?
 
//=================================================================================================================================

//=================================================== [ F O R W A R D S ] =========================================================

forward Action CCM_OnModelTimer(int client, char ClassModel[64]); /*called every 2 seconds. YOU NEED THIS FORWARD, IF NOT THEN PLUGIN WILL BITCH AT YOU.*/
forward Action CCM_OnClassTeleport(int client, int teleporter, bool &result); //obviously when player teleports as a custom class

forward Action CCM_OnMakeClass(int client); /*called when a player becomes a custom class*/

forward void CCM_AddToDownloads(); //called during OnMapStart()

forward void CCM_OnClassResupply(int client); /*called when a player resupply as a custom class*/

forward void CCM_OnClassEquip(int client); /*called when a player is equipped as custom class*/

forward void CCM_OnClassAirblasted(int client, int airblaster); /*called when a custom class player is airblasted*/

forward void CCM_OnClassDoAirblast(int airblaster, int client); /*called when a custom class player airblasts a player*/

forward void CCM_OnClassKillBuilding(int attacker, int building); /*called when a custom class player destroys buildings*/

forward void CCM_OnClassChangeClass(int client); /*called when a custom class player changes class*/

forward void CCM_OnClassKill(int attacker, int client); /*called when a custom class player kills someone*/

forward void CCM_OnClassKillDomination(int attacker, int client); /*called when a custom class player dominates someone*/

forward void CCM_OnClassKillRevenge(int attacker, int client); /*called when a custom class player gets revenge*/

forward void CCM_OnClassKilled(int client, int attacker); /*called when a custom class player is killed*/

forward void CCM_OnClassUbered(int ubered, int medic); /*called when a custom class player is ubered*/

forward void CCM_OnClassDeployUber(int medic, int ubered); /*called when a custom class player deploys uber*/

forward void CCM_OnClassSelected(int client); /*called when a player selects a custom class*/

forward void CCM_OnClassDeselected(int client); /*called when a player gets off their custom class*/

//=================================================================================================================================

//=================================================== [ S T O C K S ] =========================================================
stock int SetWeaponAmmo(int weapon, int ammo)
{
	int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if (owner <= 0) return 0;
	if (IsValidEntity(weapon))
	{
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(owner, iAmmoTable+iOffset, ammo, 4, true);
	}
	return 0;
}
public Action RemoveEnt(Handle timer, any entid)
{
	int ent = EntRefToEntIndex(entid);
	if (ent > 0 && IsValidEntity(ent)) AcceptEntityInput(ent, "Kill");
	return Action:0;
}
stock int GetWeaponClip(int weapon)
{
	if (IsValidEntity(weapon))
	{
		int AmmoClipTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		return GetEntData(weapon, AmmoClipTable);
	}
	return 0;
}
stock int SetWeaponClip(int weapon, int ammo)
{
	if (IsValidEntity(weapon))
	{
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		SetEntData(weapon, iAmmoTable, ammo, 4, true);
	}
	return 0;
}
stock int FindEntityByClassname2(int startEnt, const char[] classname)
{
	/* If startEnt isn't valid shifting it back to the nearest valid one */
	while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}
stock int SpawnWeapon(int client, char[] name, int index, int level, int qual, char[] att)
{
	Handle hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon == INVALID_HANDLE) return -1;
	TF2Items_SetClassname(hWeapon, name);
	TF2Items_SetItemIndex(hWeapon, index);
	TF2Items_SetLevel(hWeapon, level);
	TF2Items_SetQuality(hWeapon, qual);
	char atts[32][32];
	int count = ExplodeString(att, " ; ", atts, 32, 32);
	if (count > 0)
	{
		TF2Items_SetNumAttributes(hWeapon, count/2);
		int i2 = 0;
		for (int i = 0; i < count; i += 2)
		{
			TF2Items_SetAttribute(hWeapon, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
			i2++;
		}
	}
	else TF2Items_SetNumAttributes(hWeapon, 0);

	int entity = TF2Items_GiveNamedItem(client, hWeapon);
	CloseHandle(hWeapon);
	EquipPlayerWeapon(client, entity);
	return entity;
}
stock void SetWeaponInvis(int client, int alpha)
{
	for (int i = 0; i < 5; i++)
	{
		char wepclassname[32];
		int entity = GetPlayerWeaponSlot(client, i); 
		if (entity != -1 && StrContains(wepclassname, "tf_weapon", false))
		{ 
			SetEntityRenderMode(entity, RENDER_TRANSCOLOR); 
			SetEntityRenderColor(entity, 255, 255, 255, alpha); 
		} 
	}
}
stock void SetClientOverlay(int client, char[] strOverlay)
{
	int iFlags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
	SetCommandFlags("r_screenoverlay", iFlags);
	if (IsValidClient(client)) ClientCommand(client, "r_screenoverlay \"%s\"", strOverlay);
}
stock bool IsValidClient(int client, bool replaycheck = true)
{
	if (client <= 0 || client > MaxClients) return false;
	if (!IsClientInGame(client)) return false;
	if (GetEntProp(client, Prop_Send, "m_bIsCoaching")) return false;
	if (replaycheck) if (IsClientSourceTV(client) || IsClientReplay(client)) return false;
	return true;
}
stock void TF2_RemoveWeaponSlot2(int client, int slot)
{
	int ew, weaponIndex;
	while ((weaponIndex = GetPlayerWeaponSlot(client, slot)) != -1)
	{ 
		ew = GetEntPropEnt(weaponIndex, Prop_Send, "m_hExtraWearable");
		if (IsValidEntity(ew)) TF2_RemoveWearable(client, ew);
		ew = GetEntPropEnt(weaponIndex, Prop_Send, "m_hExtraWearableViewModel");
		if (IsValidEntity(ew)) TF2_RemoveWearable(client, ew);
		RemovePlayerItem(client, weaponIndex);
		AcceptEntityInput(weaponIndex, "Kill");
	} 
}
stock void TF2_RemoveAllWeapons2(int client)
{
	for (int i = 0; i < 6; i++)
	{
		TF2_RemoveWeaponSlot2(client, i);
	}
}
stock Handle RegisterClass(Handle pluginhndl, const char[] name, CCMError error)
{
	if (!ValidateName(name))
	{
		LogError("**** RegisterClass - Invalid Name For Class ****");
		error = Error_InvalidName;
		return INVALID_HANDLE;
	}
	if (FindClassBySubPlugin(pluginhndl) != INVALID_HANDLE)
	{
		LogError("**** RegisterClass - Class Already Registered ****");
		error = Error_SubpluginAlreadyRegistered;
		return INVALID_HANDLE;
	}
	if (FindClassName(name) != INVALID_HANDLE)
	{
		LogError("**** RegisterClass - Class Already Exists ****");
		error = Error_AlreadyExists;
		return INVALID_HANDLE;
	}
	// Create the trie to hold the data about the class
	Handle ClassSubplug = CreateTrie();
	SetTrieValue(ClassSubplug, "Subplugin", pluginhndl);
	SetTrieString(ClassSubplug, "ClassName", name);

	// Then push it to the global array and trie
	// Don't forget to convert the string to lower cases!
	PushArrayCell(hArrayClass, ClassSubplug);
	SetTrieValueCaseInsensitive(hTrieClass, name, ClassSubplug);

	error = Error_None;
	return pluginhndl;
}
stock bool ValidateName(const char[] name)
{
	int length = strlen(name);
	for (int i = 0; i < length; i++)
	{
		int holder = name[i];
		// Invalid name, names may only contains numbers, underscores and normal letters
		if (!(IsCharAlpha(holder) || IsCharNumeric(holder) || holder == '_')) return false;
	}
	// A name is, of course, only valid if it's 1 or more chars long, though longer is recommended
	return (length > 0);
}
stock Handle FindClassBySubPlugin(Handle plugin)
{
	int count = GetArraySize(hArrayClass);
	for (int i = 0; i < count; i++)
	{
		Handle classplugin = GetArrayCell(hArrayClass, i);
		if (GetClassSubPlugin(classplugin) == plugin) return classplugin;
	}
	return INVALID_HANDLE;
}
stock Handle FindClassName(const char[] name)
{
	Handle GotClassName;
	if (GetTrieValueCaseInsensitive(hTrieClass, name, GotClassName)) return GotClassName;
	return INVALID_HANDLE;
}
stock void StringToLower(const char[] input, char[] output, int size)
{
	for (int i = 0; i < size; i++)
	{
		if (IsCharUpper(input[i])) output[i] = CharToLower(input[i]);
		else output[i] = input[i];
	}
}
stock bool GetTrieValueCaseInsensitive(Handle trie, const char[] key, any &value)
{
	int length = strlen(key)+1;
	char[] trieKey = new char[length]; //you've got to be fucking me.
	StringToLower(key, trieKey, length);
	return GetTrieValue(trie, trieKey, value);
}
stock bool SetTrieValueCaseInsensitive(Handle trie, const char[] key, any value)
{
	int length = strlen(key)+1;
	char[] trieKey = new char[length];
	StringToLower(key, trieKey, length);
	return SetTrieValue(trie, trieKey, value);
}
stock Handle GetClassSubPlugin(Handle hndl)
{
	Handle plugin;
	if (GetTrieValue(hndl, "Subplugin", plugin)) return plugin;
	// Shouldn't actually get here, but we keep it just incase
	return INVALID_HANDLE;
}
//=================================================================================================================================

public SharedPlugin:__pl_CCM = 
{
	name = "ccm",
	file = "ccm.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_CCM_SetNTVOptional()
{
	MarkNativeAsOptional("CCM_RegisterClass");
}
#endif