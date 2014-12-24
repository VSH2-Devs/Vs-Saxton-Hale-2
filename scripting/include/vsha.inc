#if defined _vsha_included
 #endinput
#endif
#define _vsha_included

#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>
#include <sdktools_gamerules>
//#include <nextmap>
#include <tf2items>
//#include <clientprefs>
#include <morecolors>
#include <adt>
#include <tf2attributes>

//#pragma semicolon			1
#pragma newdecls			optional

#define MaxEntities			2048
#define PLYR				MAXPLAYERS+1
#define PLUGIN_VERSION			"1.0"
#define PATH				64
#define PATHX				PLATFORM_MAX_PATH
#define NULLHANDLE			INVALID_HANDLE //easier to copypaste

/*
methodmap CBoss //soon my pet, soon...
{
	property int UserID
	{
		public get() {
			if (IsValidClient(_:this)) return GetClientUserId(_:this);
		}
	}
	property int Index
	{
		public get() { return GetClientOfUserId(this.UserID); }
	}
	property int Health
	{
		public get() { return iBossHealth[this.Index]; }
		public set(int val) { iBossHealth[this.Index] = val; }
	}
	property int MaxHealth
	{
		public get() { return iBossMaxHealth[this.Index]; }
		public set(int val) { iBossMaxHealth[this.Index] = val; }
	}
	property int Difficulty
	{
		public get() { return iDifficulty[this.Index]; }
		public set(int val) { iDifficulty[this.Index] = val; }
	}
	property float MoveSpeed
	{
		public get() { return flMoveSpeed[this.Index]; }
		public set(float val) { flMoveSpeed[this.Index] = val; }
	}
	property float Rage
	{
		public get() { return flRage[this.Index]; }
		public set(float val) { flRage[this.Index] = val; }
	}
	property float RageDistance
	{
		public get() { return flRageDist[this.Index]; }
		public set(float val) { flRageDist[this.Index] = val; }
	}
}
*/

enum VSHAError
{
	Error_None,				// All-Clear :>
	Error_InvalidName,			// Invalid name for Boss
	Error_AlreadyExists,			// Boss Already Exists....
	Error_SubpluginAlreadyRegistered,	// The plugin registering a game mode already has a game mode registered
}

Handle hArrayBossSubplugins = NULLHANDLE;	// List <Subplugin>
Handle hTrieBossSubplugins = NULLHANDLE;	// Map <Boss Name, Subplugin Handle>


stock void IntMain()
{
	hArrayBossSubplugins = CreateArray();
	hTrieBossSubplugins = CreateTrie();
}

//=================================================== [ S T O C K S ] ========================================================

//============= [ D E F A U L T  A B I L I T I E S ] ===================
stock void SuperJump(int client, float charge, float JumpAngle)
{
	float ang[3];
	GetClientEyeAngles(client, ang);
        if ( ang[0] <= JumpAngle) // JumpAngle = -45.0
	{
		float vel[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
		vel[2] = 750 + charge * 13.0;
		SetEntProp(client, Prop_Send, "m_bJumping", 1);
		vel[0] *= (1+Sine(charge * FLOAT_PI / 50));
		vel[1] *= (1+Sine(charge * FLOAT_PI / 50));
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
		charge = -120;
	}
}
stock void Weighdown(int client, float weighdowntime, float AngleForWayDown)
{
	if ( weighdowntime >= 1.0 && /*(GetClientButtons(bossplayer) & IN_DUCK)*/ (GetEntityGravity(client) != 6.0) )
	{
		float ang[3];
		GetClientEyeAngles(client, ang);
		if ( ang[0] >= AngleForWayDown ) //AngleForWayDown = 60.0
		{
			float fVelocity[3];
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
			fVelocity[2] = -1000.0;
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
			SetEntityGravity(client, 6.0);
			CreateTimer(2.0, TimerGravityCat, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			weighdowntime = 0.0;
		}
	}
}
public Action TimerGravityCat(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (IsValidClient(client)) SetEntityGravity(client, 1.0);
	return Plugin_Continue;
}
stock void StunSentry(int client, float dist, float duration = 6.0)
{
	float bossPosition[3], sentryPosition[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", bossPosition);
	int sentry;
	while ( (sentry = FindEntityByClassname2(sentry, "obj_sentrygun")) != -1 )
	{
		GetEntPropVector(sentry, Prop_Send, "m_vecOrigin", sentryPosition);
		if ( GetVectorDistance(bossPosition, sentryPosition) <= dist )
		{
			SetEntProp(sentry, Prop_Send, "m_bDisabled", 1);
			CreateTimer( duration, RemoveEnt, EntIndexToEntRef(AttachParticle(sentry, "yikes_fx", 75.0)) );
			CreateTimer( duration, TimerEnableSentry, EntIndexToEntRef(sentry) );
		}
	}
}
public Action TimerEnableSentry(Handle hTimer, any sentryid)
{
	int i = EntRefToEntIndex(sentryid);
	if (CheckRoundState() == 1 && IsValidEdict(i) && i > MaxClients)
	{
		char s[64];
		GetEdictClassname(i, s, 64);
		if (StrEqual(s, "obj_sentrygun")) GetEntProp(i, Prop_Send, "m_bDisabled", 0);
	}
	return Plugin_Continue;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
stock bool IsVSHMap() //just use arena maps as vsh/ff2 maps
{
	if (FindEntityByClassname(-1, "tf_logic_arena") != -1) return true;
	return false;
}
public Action RemoveEnt(Handle timer, any entid)
{
	int ent = EntRefToEntIndex(entid);
	if (ent > 0 && IsValidEntity(ent)) AcceptEntityInput(ent, "Kill");
	return Plugin_Continue;
}
stock int AttachParticle(int ent, char[] particleType, float offset = 0.0, bool battach = true)
{
	int particle = CreateEntityByName("info_particle_system");
	char tName[128];
	float pos[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	pos[2] += offset;
	TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
	Format(tName, sizeof(tName), "target%i", ent);
	DispatchKeyValue(ent, "targetname", tName);
	DispatchKeyValue(particle, "targetname", "tf2particle");
	DispatchKeyValue(particle, "parentname", tName);
	DispatchKeyValue(particle, "effect_name", particleType);
	DispatchSpawn(particle);
	SetVariantString(tName);
	if (battach)
	{
		AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		SetEntPropEnt(particle, Prop_Send, "m_hOwnerEntity", ent);
	}
	ActivateEntity(particle);
	AcceptEntityInput(particle, "start");
	return particle;
}
stock int FindNextBoss(bool[] array) //why force specs to Boss? They're prob AFK...
{
	int inBoss = -1, tBossPoints = -99999;
	for (int i = 1; i <= MaxClients; i++)
	{
		if ( IsValidClient(i) && GetClientTeam(i) > _:TFTeam_Spectator )
		{
			int points = GetClientQueuePoints(i);
			if (points >= tBossPoints && !array[i])
			{
				inBoss = i;
				tBossPoints = points;
			}
		}
	}
	return inBoss;
}
stock void SetControlPoint(bool enable)
{
	int controlPoint = MaxClients+1;
	while ( (controlPoint = FindEntityByClassname2(controlPoint, "team_control_point")) != -1 )
	{
		if ( IsValidEdict(controlPoint) && IsValidEntity(controlPoint) )
		{
			AcceptEntityInput(controlPoint, (enable ? "ShowModel" : "HideModel"));
			SetVariantInt(enable ? 0 : 1);
			AcceptEntityInput(controlPoint, "SetLocked");
		}
	}
}
stock int CheckRoundState()
{
	switch ( GameRules_GetRoundState() )
	{
		case RoundState_Init, RoundState_Pregame: return -1;
		case RoundState_StartGame, RoundState_Preround: return 0;
		case RoundState_RoundRunning, RoundState_Stalemate: return 1;
		default: return 2;
	}
	return -1;
}
stock void ForceTeamWin(int team)
{
	int entity = FindEntityByClassname2(-1, "team_control_point_master");
	if (entity == -1)
	{
		entity = CreateEntityByName("team_control_point_master");
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "Enable");
	}
	SetVariantInt(team);
	AcceptEntityInput(entity, "SetWinner");
}
stock int FindEntityByClassname2(int startEnt, const char[] classname)
{
	/* If startEnt isn't valid shifting it back to the nearest valid one */
	while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}
stock int GetItemIndex(int item)
{
	if (IsValidEdict(item) && IsValidEntity(item)) return GetEntProp(item, Prop_Send, "m_iItemDefinitionIndex");
	return -1;
}
stock int GetItemQuality(int item)
{
	if (IsValidEdict(item) && IsValidEntity(item)) return GetEntProp(item, Prop_Send, "m_iEntityQuality");
	return -1;
}
stock int GetIndexOfWeaponSlot(int client, int slot)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	return (IsValidEdict(weapon) && IsValidEntity(weapon)) ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1;
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
	for (int i = 0; i <= 5; i++)
	{
		TF2_RemoveWeaponSlot2(client, i);
	}
}
stock void RemovePlayerBack(int client, int[] indices, int len)
{
	if (len <= 0) return;
	int edict = MaxClients+1;
	while ((edict = FindEntityByClassname2(edict, "tf_wearable")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearable"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++)
				{
					if (idx == indices[i]) TF2_RemoveWearable(client, edict);
				}
			}
		}
	}
	edict = MaxClients+1;
	while ((edict = FindEntityByClassname2(edict, "tf_powerup_bottle")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFPowerupBottle"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++)
				{
					if (idx == indices[i]) TF2_RemoveWearable(client, edict);
				}
			}
		}
	}
}
stock int FindPlayerBack(int client, int[] indices, int len)
{
	if (len <= 0) return -1;
	int edict = MaxClients+1;
	while ((edict = FindEntityByClassname2(edict, "tf_wearable")) != -1)
	{
		char netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearable"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (int i = 0; i < len; i++)
				{
					if (idx == indices[i]) return edict;
				}
			}
		}
	}
	edict = MaxClients+1;
	while ((edict = FindEntityByClassname2(edict, "tf_powerup_bottle")) != -1)
	{
		decl String:netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFPowerupBottle"))
		{
			int idx = GetItemIndex(edict);
			if (GetOwner(edict) == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (new i = 0; i < len; i++)
				{
					if (idx == indices[i]) return edict;
				}
			}
		}
	}
	return -1;
}
stock float GetMediCharge(int medigun)
{
	if (IsValidEdict(medigun) && IsValidEntity(medigun)) return GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
	return -1.0;
}
stock void SetMediCharge(int medigun, float val)
{
	if (IsValidEdict(medigun) && IsValidEntity(medigun)) SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", val);
}
stock Handle PrepareItemHandle(Handle hdlItem, char[] name = "", int index = -1, const char[] att = "", bool dontpreserve = false)
{
	Handle hWeapon;
	int addattribs = 0;

	char weaponAttribsArray[32][32];
	int attribCount = ExplodeString(att, " ; ", weaponAttribsArray, 32, 32);

	int flags = OVERRIDE_ATTRIBUTES;
	if (!dontpreserve) flags |= PRESERVE_ATTRIBUTES;
	if (hWeapon == NULLHANDLE) hWeapon = TF2Items_CreateItem(flags);
	else TF2Items_SetFlags(hWeapon, flags);
	//  new Handle:hWeapon = TF2Items_CreateItem(flags);    //NULLHANDLE;
	if (hdlItem != NULLHANDLE)
	{
		addattribs = TF2Items_GetNumAttributes(hdlItem);
		if (addattribs > 0)
		{
			for (int i = 0; i < 2 * addattribs; i += 2)
			{
				bool dontAdd = false;
				int attribIndex = TF2Items_GetAttributeId(hdlItem, i);
				for (int z = 0; z < attribCount+i; z += 2)
				{
					if (StringToInt(weaponAttribsArray[z]) == attribIndex)
					{
						dontAdd = true;
						break;
					}
				}
				if (!dontAdd)
				{
					IntToString(attribIndex, weaponAttribsArray[i+attribCount], 32);
					FloatToString(TF2Items_GetAttributeValue(hdlItem, i), weaponAttribsArray[i+1+attribCount], 32);
				}
			}
			attribCount += 2 * addattribs;
		}
		delete hdlItem; //probably returns false but whatever
	}

	if (name[0] != '\0')
	{
		flags |= OVERRIDE_CLASSNAME;
		TF2Items_SetClassname(hWeapon, name);
	}
	if (index != -1)
	{
		flags |= OVERRIDE_ITEM_DEF;
		TF2Items_SetItemIndex(hWeapon, index);
	}
	if (attribCount > 1)
	{
		TF2Items_SetNumAttributes(hWeapon, (attribCount/2));
		int i2 = 0;
		for (int i = 0; i < attribCount && i < 32; i += 2)
		{
			TF2Items_SetAttribute(hWeapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
			i2++;
		}
	}
	else TF2Items_SetNumAttributes(hWeapon, 0);
	TF2Items_SetFlags(hWeapon, flags);
	return hWeapon;
}
stock int SpawnWeapon(int client, char[] name, int index, int level, int qual, char[] att)
{
	Handle hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon == NULLHANDLE) return -1;
	TF2Items_SetClassname(hWeapon, name);
	TF2Items_SetItemIndex(hWeapon, index);
	TF2Items_SetLevel(hWeapon, level);
	TF2Items_SetQuality(hWeapon, qual);
	char atts[32][32];
	int count = ExplodeString(att, " ; ", atts, 32, 32);
	if (count > 1)
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
	delete hWeapon;
	EquipPlayerWeapon(client, entity);
	return entity;
}
stock int GetClientCloakIndex(int client)
{
	if (!IsValidClient(client)) return -1;
	int wep = GetPlayerWeaponSlot(client, 4);
	if (!IsValidEntity(wep)) return -1;
	char classname[32];
	GetEntityClassname(wep, classname, sizeof(classname));
	if ( strncmp(classname, "tf_wea", 6, false) != 0 ) return -1;
	return GetEntProp(wep, Prop_Send, "m_iItemDefinitionIndex");
}
stock int GetHealingTarget(int client)
{
	char s[32];
	int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if ( !IsValidEdict(medigun) || !IsValidEntity(medigun) ) return -1;
	GetEdictClassname(medigun, s, sizeof(s));
	if (!strcmp(s, "tf_weapon_medigun", false))
	{
		if (GetEntProp(medigun, Prop_Send, "m_bHealing")) return GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
	}
	return -1;
}
stock bool IsNearSpencer(int client) 
{ 
	int medics = 0, healers = GetEntProp(client, Prop_Send, "m_nNumHealers"); 
	if (healers > 0) 
	{ 
		for (int i = 1; i <= MaxClients; i++) 
		{ 
			if (IsValidClient(i) && IsPlayerAlive(i) && GetHealingTarget(i) == client) medics++; 
		}
	}
	return (healers > medics) ? true : false; 
} 

stock int FindSentry(int client)
{
	int i = -1;
	while ((i = FindEntityByClassname2(i, "obj_sentrygun")) != -1)
	{
		if (GetEntPropEnt(i, Prop_Send, "m_hBuilder") == client) return i;
	}
	return -1;
}
stock void IncrementHeadCount(int client)
{
	if (!TF2_IsPlayerInCondition(client, TFCond_DemoBuff)) TF2_AddCondition(client, TFCond_DemoBuff, -1.0);
	int decapitations = GetEntProp(client, Prop_Send, "m_iDecapitations");
	SetEntProp(client, Prop_Send, "m_iDecapitations", decapitations+1);
	int health = GetClientHealth(client);
	if (health < 300) health += 15;
	SetEntProp(client, Prop_Data, "m_iHealth", health);
	SetEntProp(client, Prop_Send, "m_iHealth", health);
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);   //recalc their speed
}
stock void SpawnSmallHealthPackAt(int client, int ownerteam = 0)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client)) return;
	int healthpack = CreateEntityByName("item_healthkit_small");
	float pos[3];
	GetClientAbsOrigin(client, pos);
	pos[2] += 20.0;
	if (IsValidEntity(healthpack))
	{
		DispatchKeyValue(healthpack, "OnPlayerTouch", "!self,Kill,,0,-1");  //for safety, though it normally doesn't respawn
		DispatchSpawn(healthpack);
		SetEntProp(healthpack, Prop_Send, "m_iTeamNum", ownerteam, 4);
		SetEntityMoveType(healthpack, MOVETYPE_VPHYSICS);
		float vel[3];
		vel[0] = float(GetRandomInt(-10, 10)), vel[1] = float(GetRandomInt(-10, 10)), vel[2] = 50.0;
		TeleportEntity(healthpack, pos, NULL_VECTOR, vel);
	}
}
stock void StopMusic(int client, char[] music)
{
	if ( IsValidClient(client) ) StopSound(client, SNDCHAN_AUTO, music);
}
stock bool IsValidClient(int client, bool replaycheck = true)
{
	if (client <= 0 || client > MaxClients) return false;
	if (!IsClientInGame(client)) return false;
	if (GetEntProp(client, Prop_Send, "m_bIsCoaching")) return false;
	if (replaycheck) if (IsClientSourceTV(client) || IsClientReplay(client)) return false;
	return true;
}
stock int FindTeleOwner(int client)
{
	int teleporter = GetEntPropEnt(client, Prop_Send, "m_hGroundEntity");
	char classname[32];
	if (IsValidEntity(teleporter) && GetEdictClassname(teleporter, classname, sizeof(classname)) && !strcmp(classname, "obj_teleporter", false))
	{
		int owner = GetEntPropEnt(teleporter, Prop_Send, "m_hBuilder");
		if (IsValidClient(owner, false)) return owner;
	}
	return -1;
}
stock int GetOwner(int ent)
{
	if (IsValidEdict(ent) && IsValidEntity(ent)) return GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	return -1;
}
stock void SetClientGlow(int client, float time1, float clampfl = -1.0)
{
	if (IsValidClient(client))
	{
		flGlowTimer[client] += time1;
		if (clampfl >= 0) flGlowTimer[client] = clampfl;
		if (flGlowTimer[client] <= 0.0)
		{
			flGlowTimer[client] = 0.0;
			SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);
		}
		else SetEntProp(client, Prop_Send, "m_bGlowEnabled", 1);
	}
}
stock void ClearTimer(Handle Timer)
{
	if (Timer != NULLHANDLE)
	{
		CloseHandle(Timer);
		Timer = NULLHANDLE;
	}
	return;
}
stock void ForceTeamChange(int client, int iTeam)
{
	SetEntProp(client, Prop_Send, "m_lifeState", 2);
	ChangeClientTeam(client, iTeam);
	SetEntProp(client, Prop_Send, "m_lifeState", 0);
	TF2_RespawnPlayer(client);
}
stock int GetTeamPlayerCount(int team)
{
	int count = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && GetClientTeam(i) == team) count++;
	}
	return count;
}
stock int GetWeaponAmmo(int weapon)
{
	int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if (owner <= 0) return 0;
	if (IsValidEntity(weapon))
	{
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		return GetEntData(owner, iAmmoTable+iOffset, 4);
	}
	return 0;
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
stock void SetWeaponAmmo(int weapon, int ammo)
{
	int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if (owner == -1) return;
	if (IsValidEntity(weapon))
	{
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(owner, iAmmoTable+iOffset, ammo, 4, true);
	}
	return;
}
stock void SetWeaponClip(int weapon, int ammo)
{
	if (IsValidEntity(weapon))
	{
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		SetEntData(weapon, iAmmoTable, ammo, 4, true);
	}
	return;
}
stock int GetMaxAmmo(int client, int slot)
{
	if (!IsValidClient(client)) return 0;
	int weapon = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(weapon))
	{
		switch (slot)
		{
			case TFWeaponSlot_Primary: return GetEntData(client, FindDataMapOffs(client, "m_iAmmo")+4);
			case TFWeaponSlot_Secondary: return GetEntData(client, FindDataMapOffs(client, "m_iAmmo")+8);
			case TFWeaponSlot_Melee: return GetEntData(client, FindDataMapOffs(client, "m_iAmmo")+12);
		}
	}
	return 0;
}
stock bool TF2_IsPlayerCritBuffed(int client)
{
    return (TF2_IsPlayerInCondition(client, TFCond_Kritzkrieged)
            || TF2_IsPlayerInCondition(client, TFCond_HalloweenCritCandy)
            || TF2_IsPlayerInCondition(client, TFCond:34)
            || TF2_IsPlayerInCondition(client, TFCond:35)
            || TF2_IsPlayerInCondition(client, TFCond_CritOnFirstBlood)
            || TF2_IsPlayerInCondition(client, TFCond_CritOnWin)
            || TF2_IsPlayerInCondition(client, TFCond_CritOnFlagCapture)
            || TF2_IsPlayerInCondition(client, TFCond_CritOnKill)
            || TF2_IsPlayerInCondition(client, TFCond_CritMmmph)
            );
}
stock void SetArenaCapEnableTime(float time)
{
	int ent = -1;
	char strTime[32];
	FloatToString(time, strTime, sizeof(strTime));
	if ((ent = FindEntityByClassname2(-1, "tf_logic_arena")) != -1) DispatchKeyValue(ent, "CapEnableDelay", strTime);
}
stock void TeleportToSpawn(int iClient, int iTeam = 0)
{
	int iEnt = -1;
	float vPos[3];
	float vAng[3];
	Handle hArray = CreateArray();
	while ((iEnt = FindEntityByClassname2(iEnt, "info_player_teamspawn")) != -1)
	{
		if (iTeam <= 1) PushArrayCell(hArray, iEnt); // Not RED (2) nor BLu (3)
		else
		{
			int iSpawnTeam = GetEntProp(iEnt, Prop_Send, "m_iTeamNum");
			if (iSpawnTeam == iTeam) PushArrayCell(hArray, iEnt);
		}
	}
	iEnt = GetArrayCell(hArray, GetRandomInt(0, GetArraySize(hArray) - 1));
	CloseHandle(hArray);

	//Technically you'll never find a map without a spawn point. Not a good map at least.
	GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
	GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);
	TeleportEntity(iClient, vPos, vAng, NULL_VECTOR);

	/*if (Special == VSHSpecial_HHH) //reserved for HHH subplugin boss
	{
		CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(iEnt, "ghost_appearation", _, false)));
		EmitSoundToAll("misc/halloween/spell_teleport.wav", _, _, SNDLEVEL_GUNFIRE, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, vPos, NULL_VECTOR, false, 0.0);
	}*/
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
stock Handle FindBossBySubPlugin(Handle plugin)
{
	int count = GetArraySize(hArrayBossSubplugins);
	for (int i = 0; i < count; i++)
	{
		Handle bossub = GetArrayCell(hArrayBossSubplugins, i);
		if (GetBossSubPlugin(bossub) == plugin) return bossub;
	}
	return NULLHANDLE;
}
stock Handle GetBossSubPlugin(Handle hndl)
{
	Handle plugin;
	if (GetTrieValue(hndl, "Subplugin", plugin)) return plugin;
	// Shouldn't actually get here, but we keep it just incase
	return NULLHANDLE;
}
stock Handle FindBossName(const char[] name)
{
	Handle GotBossName;
	if (GetTrieValueCaseInsensitive(hTrieBossSubplugins, name, GotBossName)) return GotBossName;
	return NULLHANDLE;
}
stock Handle RegisterBoss(Handle pluginhndl, const char[] name, VSHAError error)
{
	if (!ValidateName(name))
	{
		LogError("**** RegisterBoss - Invalid Name ****");
		error = Error_InvalidName;
		return NULLHANDLE;
	}
	if (FindBossBySubPlugin(pluginhndl) != NULLHANDLE)
	{
		LogError("**** RegisterBoss - Boss Subplugin Already Registered ****");
		error = Error_SubpluginAlreadyRegistered;
		return NULLHANDLE;
	}
	if (FindBossName(name) != NULLHANDLE)
	{
		LogError("**** RegisterBoss - Boss Name Already Exists ****");
		error = Error_AlreadyExists;
		return NULLHANDLE;
	}
	// Create the trie to hold the data about the boss
	Handle BossSubplug = CreateTrie();
	SetTrieValue(BossSubplug, "Subplugin", pluginhndl);
	SetTrieString(BossSubplug, "BossName", name);

	// Then push it to the global array and trie
	// Don't forget to convert the string to lower cases!
	PushArrayCell(hArrayBossSubplugins, BossSubplug);
	SetTrieValueCaseInsensitive(hTrieBossSubplugins, name, BossSubplug);

	error = Error_None;
	return pluginhndl;
}
//=================================================================================================================================

//=================================================== [ N A T I V E ] =========================================================

native int VSHA_RegisterBoss(char[] BossName); //EVERY BOSS NEEDS THIS, PREFERABLY USE IN ONPLUGINSTART OK?

native int VSHA_GetBossUserID(int client); //gets boss' userid
native int VSHA_SetBossUserID(int client, int userid);

native int VSHA_GetDifficulty(int client); /* this is to modify bosses based on what difficulty level the player wants his boss to be, doesn't do anything by itself but this API should help with it. */
native int VSHA_SetDifficulty(int client, int difficultylevel);

native int VSHA_GetLives(int client); /* gets the player's lives, you can get/set lives for both players and bosses */
native int VSHA_SetLives(int client, int lives);

native int VSHA_GetPresetBoss(int client); //this gets the preset boss special ID, similar to VSH Special or FF2 Get special
native int VSHA_SetPresetBoss(int client, int presetboss);

native int VSHA_GetBossHealth(int client);
native int VSHA_SetBossHealth(int client, int health);

native int VSHA_GetBossMaxHealth(int client);
native int VSHA_SetBossMaxHealth(int client, int maxhealth);

native int VSHA_GetBossPlayerKills(int client); //how many players a boss killed in the entire round
native int VSHA_SetBossPlayerKills(int client, int kills);

native int VSHA_GetBossKillstreak(int client); //how many people boss killed in a certain amount of time
native int VSHA_SetBossKillstreak(int client, int killspree);

native int VSHA_GetPlayerBossKills(int client); //how many times a player has killed a boss in entire map time
native int VSHA_SetPlayerBossKills(int client, int bosseskilled);

native int VSHA_GetDamage(int client); //this can also get the boss' damage.
native int VSHA_SetDamage(int client, int dmg);

native int VSHA_GetBossMarkets(int client); /* how many times a boss was market-gardened. THIS DOES NOT AUTO INCREMENT IN CORE PLUGIN. If you want your boss to take Market-Garden Backstab-like damage, you should use this. */
native int VSHA_SetBossMarkets(int client, int markets);

native int VSHA_GetBossStabs(int client); //how many times a boss was backstabbed
native int VSHA_SetBossStabs(int client, int stabs);

native int VSHA_GetMaxWepAmmo(int wepentity);
native int VSHA_SetMaxWepAmmo(int wepentity, int maxammo);

native int VSHA_GetMaxWepClip(int wepentity);
native int VSHA_SetMaxWepClip(int wepentity, int maxclip);

native int VSHA_GetPresetBossPlayer(); //Get when or which player will be forced as the next boss
native int VSHA_SetPresetBossPlayer(int client);

native int VSHA_GetAliveRedPlayers();
native int VSHA_GetAliveBluPlayers();

native float VSHA_GetBossRage(int client); /* gets the charge of the hardcoded, built-in rage charge. You can create multiple rage charges or make the default one charge up from different things than just taking damage. */
native int VSHA_SetBossRage(int client, float rage);

native float VSHA_GetGlowTimer(int client); //used to set glow timers on players, use in boss subplugins plz
native int VSHA_SetGlowTimer(int client, float glowtime);

native bool VSHA_IsBossPlayer(int client); //is client a boss?
native bool VSHA_IsPlayerInJump(int client); //did player rocket/sticky jump?
native bool VSHA_CanBossTaunt(int client); //is boss taunt cooldown over?

native int VSHA_GetSingleBoss(); /* gets the next player in queue list and sets that player as a boss, conveniently sets boss-player's userid as well! :>. This function native returns the player's index for reference */

native int VSHA_PickBossSpecial(int client); /* picks the special for the player. everytime this is used, it calls the forward "VSHA_OnBossSelected" so be wary of that. */

/* Used to get/set minions/zombies for bosses. When using these natives, you need to set the minion bool to true on a player before respawning them as a minion. When a player is spawned as a minion, the forward "VSHA_OnPrepBoss" is called on the minion, so don't forget to specify what minions and bosses each get. Please note that Minions do not get their own HUDs so you need to create one for them in the forward "VSHA_BossPreThink" */
native bool VSHA_IsMinion(int client);
native int VSHA_SetMinion(int client, bool set);

/*
Initial is the health that is autogiven to the boss, playing is how many players are playing, exponent is how much power is added to the calculation, and additional is how much additional health given to the final calculation. All of it is auto rounded to int and automatically divided according to the number of bosses :)

For better knowledge on how it works, here's the entire function, everything is in float for a bit better precision.

stock int HealthCalc(float initial, float playing, float subtract, float exponent, float additional)
{
	return RoundToCeil( Pow((((initial/CountBosses())+playing)*(playing-subtract)), exponent)+additional );
}
*/
native int VSHA_CalcBossHealth(float initial, float playing, float subtract, float exponent, float additional);

native int VSHA_CountScoutsLeft(); /* counts how many scouts are left */ 

//=================================================================================================================================

//=================================================== [ F O R W A R D S ] =========================================================

forward void VSHA_AddToDownloads(); /* called during OnMapStart(); NOTICE: THIS IS A GLOBAL FORWARD */

forward void VSHA_OnPlayerKilled(int attacker, int client); //when a boss kills a player

forward void VSHA_OnKillingSpree(int attacker, int client); /* when boss has killed certain amount of players in a certain amount of time, conveniently gets the killed player who triggered this forward */

forward void VSHA_OnBossKilled(int client, int attacker); /* when a boss is killed, conveniently gets the player who killed the boss too, give the lucky sob a medal :3 */

forward void VSHA_OnBossWin(); // self explanatory lol

forward void VSHA_OnBossKillBuilding(int attacker, int building); // also self explanatory

forward void VSHA_OnBossAirblasted(int client, int airblaster); /* when boss is airblasted, client is the airblasted boss */

forward void VSHA_OnBossSelected(int client); //when a boss is selected, the client is the player that is assigned the boss

forward void VSHA_OnBossIntroTalk(); //play boss intro response sound clip in this forward

forward void VSHA_OnBossSetHP(int client); //self explanatory, when boss has their hp set and client is the individual boss

forward void VSHA_OnLastSurvivor(int target); //target = lucky survivor

forward void VSHA_OnBossTimer(int client); //called every 0.2 seconds on each boss, health is set automatically though

forward void VSHA_OnPrepBoss(int client); /* called during MakeBoss timer; in this forward, the boss is disarmed and stripped of all equipment. Equip them or whatever in this forward*/

forward void VSHA_OnMusic(char[] BossTheme, float time); //sets the boss theme music

forward void VSHA_OnModelTimer(int client, char[] modelpath); //YOU NEED THIS TIMER FOR EVERY BOSS OR ELSE PLUGIN WILL BITCH @ U

forward void VSHA_BossPreThink(int client); /* runs on PreThink aka runs every frame. When unused, this defaults to a default boss HUD. When this forward is used, it overrides EVERYTHING in PreThink for the Boss, so you HAVE to make a custom HUD if you want to use this forward or else your boss won't have a HUD. */

forward void VSHA_OnBossRage(int client); //when boss does taunt or medic call rage

forward void VSHA_OnBossConditionAdded(int client); //when condition like jarate is added

forward void VSHA_OnUberTimer(int medic, int target); //called every 0.4 seconds

forward Action VSHA_OnBossDealDmg(int victim, int &attacker, int &weapon, int &inflictor, float &damage); //when a boss player deals dmg

forward Action VSHA_OnBossTeleFragd(int victim, int &attacker, float &damage); //boss got telefragged

forward Action VSHA_OnBossTakeDmg(int victim, int &attacker, int &weapon, int &inflictor, float &damage); //boss took dmg

forward Action VSHA_OnBossStabbed(int victim, int &attacker, int &weapon, float &damage); //boss got backstabbed

//=================================================================================================================================

public SharedPlugin:__pl_VSHA = 
{
	name = "vsha",
	file = "vsha.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_VSHA_SetNTVOptional()
{
	MarkNativeAsOptional("VSHA_RegisterBoss");

	MarkNativeAsOptional("VSHA_GetBossUserID");
	MarkNativeAsOptional("VSHA_SetBossUserID");

	MarkNativeAsOptional("VSHA_GetDifficulty");
	MarkNativeAsOptional("VSHA_SetDifficulty");

	MarkNativeAsOptional("VSHA_GetLives");
	MarkNativeAsOptional("VSHA_SetLives");

	MarkNativeAsOptional("VSHA_GetPresetBoss");
	MarkNativeAsOptional("VSHA_SetPresetBoss");

	MarkNativeAsOptional("VSHA_GetBossHealth");
	MarkNativeAsOptional("VSHA_SetBossHealth");

	MarkNativeAsOptional("VSHA_GetBossMaxHealth");
	MarkNativeAsOptional("VSHA_SetBossMaxHealth");

	MarkNativeAsOptional("VSHA_GetBossPlayerKills");
	MarkNativeAsOptional("VSHA_SetBossPlayerKills");

	MarkNativeAsOptional("VSHA_GetBossKillstreak");
	MarkNativeAsOptional("VSHA_SetBossKillstreak");

	MarkNativeAsOptional("VSHA_GetPlayerBossKills");
	MarkNativeAsOptional("VSHA_SetPlayerBossKills");

	MarkNativeAsOptional("VSHA_GetDamage");
	MarkNativeAsOptional("VSHA_SetDamage");

	MarkNativeAsOptional("VSHA_GetBossMarkets");
	MarkNativeAsOptional("VSHA_SetBossMarkets");

	MarkNativeAsOptional("VSHA_GetBossStabs");
	MarkNativeAsOptional("VSHA_SetBossStabs");

	MarkNativeAsOptional("VSHA_GetMaxWepAmmo");
	MarkNativeAsOptional("VSHA_SetMaxWepAmmo");

	MarkNativeAsOptional("VSHA_GetMaxWepClip");
	MarkNativeAsOptional("VSHA_SetMaxWepClip");

	MarkNativeAsOptional("VSHA_GetPresetBossPlayer");
	MarkNativeAsOptional("VSHA_SetPresetBossPlayer");

	MarkNativeAsOptional("VSHA_GetAliveRedPlayers");
	MarkNativeAsOptional("VSHA_GetAliveBluPlayers");

	MarkNativeAsOptional("VSHA_GetBossRage");
	MarkNativeAsOptional("VSHA_SetBossRage");

	MarkNativeAsOptional("VSHA_GetGlowTimer");
	MarkNativeAsOptional("VSHA_SetGlowTimer");

	MarkNativeAsOptional("VSHA_IsBossPlayer");
	MarkNativeAsOptional("VSHA_IsPlayerInJump");
	MarkNativeAsOptional("VSHA_CanBossTaunt");

	MarkNativeAsOptional("VSHA_GetSingleBoss");
	MarkNativeAsOptional("VSHA_PickBossSpecial");

	MarkNativeAsOptional("VSHA_IsMinion");
	MarkNativeAsOptional("VSHA_SetMinion");

	MarkNativeAsOptional("VSHA_CalcBossHealth");

	MarkNativeAsOptional("VSHA_CountScoutsLeft");
}
#endif
