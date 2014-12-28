#include <ccm>

#pragma semicolon 1
#pragma newdecls optional

#define PLUGIN_VERSION		"1.0 BETA"

//bools
bool bIsCustomClass[PLYR];
bool bSetCustomClass[PLYR];
bool bHasLoadout[MAXCLASSES]; //set if custom class has a customizable loadout

//ints
Handle hClassIndex[PLYR];
int iClassIndex[PLYR];

public Plugin myinfo = 
{
	name 			= "Custom Class Maker",
	author 			= "Nergal/Assyrian, props to RSWallen, Friagram, Chdata, Powerlord, and everyone else on AM",
	description 		= "Make your Own Classes!",
	version 		= PLUGIN_VERSION,
	url 			= "hue" //will fill later
}

//cvar handles
Handle bEnabled = INVALID_HANDLE;
Handle AllowBlu = INVALID_HANDLE;
Handle AllowRed = INVALID_HANDLE;
Handle AdminFlagByPass = INVALID_HANDLE;

Handle OnAddToDownloads;

public void OnPluginStart()
{
	SetHandles();
	RegConsoleCmd("sm_ccm", MakeClassMenu);
	RegConsoleCmd("sm_noccm", MakeNotClass); //need more creative commands
	RegConsoleCmd("sm_offccm", MakeNotClass);
	RegConsoleCmd("sm_offclass", MakeNotClass);
	RegAdminCmd("sm_reloadccm", CmdReloadCFG, ADMFLAG_GENERIC);

	bEnabled = CreateConVar("sm_ccm_enabled", "1", "Enable Custom Class Maker plugin", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	AllowBlu = CreateConVar("sm_ccm_blu", "0", "(Dis)Allow Custom Classes to be playable for BLU team", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);

	AllowRed = CreateConVar("sm_ccm_red", "1", "(Dis)Allow Custom Classes to be playable for RED team", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);

	AdminFlagByPass = CreateConVar("sm_ccm_flagbypass", "a", "what flag admins need to bypass the tank class limit", FCVAR_PLUGIN);

	AutoExecConfig(true, "CustomClassMaker");
	HookEvent("player_death", PlayerDeath, EventHookMode_Pre);
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("player_hurt", PlayerHurt, EventHookMode_Pre);
	HookEvent("player_changeclass", ChangeClass);
	HookEvent("player_chargedeployed", ChargeDeployed);
	HookEvent("post_inventory_application", Resupply);
	HookEvent("object_deflected", Deflected, EventHookMode_Pre);
	HookEvent("object_destroyed", Destroyed, EventHookMode_Pre);

	HookEvent("teamplay_round_start", RoundStart);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) continue;
		OnClientPutInServer(i);
	}
}
public void OnClientPutInServer(int client)
{
	bIsCustomClass[client] = false;
	bSetCustomClass[client] = false;
	hClassIndex[client] = INVALID_HANDLE;
	iClassIndex[client] = -1;
}
public void OnClientDisconnect(int client)
{
	bIsCustomClass[client] = false;
	bSetCustomClass[client] = false;
	hClassIndex[client] = INVALID_HANDLE;
	iClassIndex[client] = -1;
}
public Action TF2_OnPlayerTeleport(int client, int teleporter, bool &result)
{
	if (bIsCustomClass[client])
	{
		Function FuncClassTele = GetFunctionByName(hClassIndex[client], "CCM_OnClassTeleport");
		if (FuncClassTele != INVALID_FUNCTION)
		{
			int endresult;
			Call_StartFunction(hClassIndex[client], FuncClassTele);
			Call_PushCell(client);
			Call_PushCell(teleporter);
			Call_PushCellRef(result);
			Call_Finish(endresult);
			return Action:endresult;
		}
		else return Action:0;
	}
	return Action:0;
}
public void OnMapStart()
{
	Call_StartForward(OnAddToDownloads);
	Call_Finish();
}
public Action Resupply(Handle hEvent, const char[] name, bool dontBroadcast)
{
	if (!GetConVarBool(bEnabled)) return Action:0;
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if (client && IsClientInGame(client))
	{
		if (bIsCustomClass[client])
		{
			Function FuncClassResupply = GetFunctionByName(hClassIndex[client], "CCM_OnClassResupply");
			if (FuncClassResupply != INVALID_FUNCTION)
			{
				Call_StartFunction(hClassIndex[client], FuncClassResupply);
				Call_PushCell(client);
				Call_Finish();
			}
			CreateTimer(0.1, TimerEquipClass, GetClientUserId(client));
		}
	}
	return Action:0;
}
public Action PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	if (!GetConVarBool(bEnabled)) return Action:0;
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if ( client && IsClientInGame(client) )
	{
		SetVariantString("");
		AcceptEntityInput(client, "SetCustomModel");
		if ( (!GetConVarBool(AllowBlu) && (GetClientTeam(client) == 3)) || (!GetConVarBool(AllowRed) && (GetClientTeam(client) == 2)) )
		{
			bSetCustomClass[client] = false; //block the blocked teams from being able to become custom classes
		}
		bIsCustomClass[client] = (bSetCustomClass[client] ? true : false); //get class set
		if (bIsCustomClass[client]) MakeClass(GetClientUserId(client));
	}
	return Action:0;
}
public Action MakeClass(int userid) //set class attributes here like Think timers.
{
	int client = GetClientOfUserId(userid);
	if ( client && IsClientInGame(client) )
	{
		CreateTimer(0.2, MakeModelTimer, userid);
		//CreateTimer(0.0, TimerClassThink, userid, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.1, TimerEquipClass, userid);
		CreateTimer(10.0, MakeModelTimer, userid, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

		Function FuncInitTimer = GetFunctionByName(hClassIndex[client], "CCM_OnMakeClass");
		if (FuncInitTimer != INVALID_FUNCTION)
		{
			int result;
			Call_StartFunction(hClassIndex[client], FuncInitTimer);
			Call_PushCell(client);
			Call_Finish(result);
			return Action:result;
		}
	}
	return Action:0;
}
public Action TimerEquipClass(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client) && IsPlayerAlive(client))
	{
		if (!bIsCustomClass[client]) return Action:0;
		TF2_RemoveAllWeapons2(client);

		Function FuncEquip = GetFunctionByName(hClassIndex[client], "CCM_OnClassEquip");
		if (FuncEquip != INVALID_FUNCTION)
		{
			Call_StartFunction(hClassIndex[client], FuncEquip);
			Call_PushCell(client);
			Call_Finish();
		}
	}
	return Action:0;
}
public Action Deflected(Handle event, const char[] name, bool dontBroadcast)
{
	if (!GetConVarBool(bEnabled) || GetEventInt(event, "weaponid")) return Action:0;
	int airblaster = GetClientOfUserId(GetEventInt(event, "userid"));
	int client = GetClientOfUserId(GetEventInt(event, "ownerid"));
	if ( bIsCustomClass[client] )
	{
		Function FuncAirblasted = GetFunctionByName(hClassIndex[client], "CCM_OnClassAirblasted");
		if (FuncAirblasted != INVALID_FUNCTION)
		{
			Call_StartFunction(hClassIndex[client], FuncAirblasted);
			Call_PushCell(client);
			Call_PushCell(airblaster);
			Call_Finish();
		}
	}
	else if ( bIsCustomClass[airblaster] ) 
	{
		Function FuncAirblastee = GetFunctionByName(hClassIndex[airblaster], "CCM_OnClassDoAirblast");
		if (FuncAirblastee != INVALID_FUNCTION)
		{
			Call_StartFunction(hClassIndex[airblaster], FuncAirblastee);
			Call_PushCell(airblaster);
			Call_PushCell(client);
			Call_Finish();
		}
	}
	return Action:0;
}
public Action Destroyed(Handle event, const char[] name, bool dontBroadcast)
{
	if (!GetConVarBool(bEnabled)) return Action:0;
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	int building = GetEventInt(event, "index");
	if ( bIsCustomClass[attacker] )
	{
		Function FuncKillToys = GetFunctionByName(hClassIndex[attacker], "CCM_OnClassKillBuilding");
		if (FuncKillToys != INVALID_FUNCTION)
		{
			Call_StartFunction(hClassIndex[attacker], FuncKillToys);
			Call_PushCell(attacker);
			Call_PushCell(building);
			Call_Finish();
		}
	}
	return Action:0;
}
public Action ChangeClass(Handle event, const char[] name, bool dontBroadcast)
{
	if (!GetConVarBool(bEnabled)) return Action:0;
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client && IsClientInGame(client))
	{
		if ( (!GetConVarBool(AllowBlu) && GetClientTeam(client) == 3) || (!GetConVarBool(AllowRed) && GetClientTeam(client) == 2) )
			return Action:0;

		if (bIsCustomClass[client])
		{
			Function FuncChangeClass = GetFunctionByName(hClassIndex[client], "CCM_OnClassChangeClass");
			if (FuncChangeClass != INVALID_FUNCTION)
			{
				Call_StartFunction(hClassIndex[client], FuncChangeClass);
				Call_PushCell(client);
				Call_Finish();
			}
		}
		else
		{
			if (bSetCustomClass[client]) bIsCustomClass[client] = true;
		}
	}
	return Action:0;
}
public Action PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	if (!GetConVarBool(bEnabled)) return Action:0;
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	int deathflags = GetEventInt(event, "death_flags");

	if (bIsCustomClass[attacker])
	{
		Function FuncClassKill = GetFunctionByName(hClassIndex[attacker], "CCM_OnClassKill");
		if (FuncClassKill != INVALID_FUNCTION)
		{
			Call_StartFunction(hClassIndex[attacker], FuncClassKill);
			Call_PushCell(attacker);
			Call_PushCell(client);
			Call_Finish();
		}
		if (deathflags & (TF_DEATHFLAG_KILLERDOMINATION|TF_DEATHFLAG_ASSISTERDOMINATION))
		{
			Function FuncClassKillDom = GetFunctionByName(hClassIndex[attacker], "CCM_OnClassKillDomination");
			if (FuncClassKillDom != INVALID_FUNCTION)
			{
				Call_StartFunction(hClassIndex[attacker], FuncClassKillDom);
				Call_PushCell(attacker);
				Call_PushCell(client);
				Call_Finish();
			}
		}
		else if ((deathflags & (TF_DEATHFLAG_KILLERREVENGE|TF_DEATHFLAG_ASSISTERREVENGE)))
		{
			Function FuncClassKillRev = GetFunctionByName(hClassIndex[attacker], "CCM_OnClassKillRevenge");
			if (FuncClassKillRev != INVALID_FUNCTION)
			{
				Call_StartFunction(hClassIndex[attacker], FuncClassKillRev);
				Call_PushCell(attacker);
				Call_PushCell(client);
				Call_Finish();
			}
		}
	}
	else if (bIsCustomClass[client])
	{
		Function FuncClassKilled = GetFunctionByName(hClassIndex[client], "CCM_OnClassKilled");
		if (FuncClassKilled != INVALID_FUNCTION)
		{
			Call_StartFunction(hClassIndex[client], FuncClassKilled);
			Call_PushCell(client);
			Call_PushCell(attacker);
			Call_Finish();
		}
	}
	return Action:0;
}
public Action PlayerHurt(Handle event, const char[] name, bool dontBroadcast) //does this even need to be used?
{
	if (!GetConVarBool(bEnabled)) return Action:0;
	//int client = GetClientOfUserId(GetEventInt(event, "userid"));
	//int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	//int damage = GetEventInt(event, "damageamount");
	return Action:0;
}
public Action ChargeDeployed(Handle event, const char[] name, bool dontBroadcast)
{
	if (!GetConVarBool(bEnabled)) return Action:0;
	int medic = GetClientOfUserId(GetEventInt(event, "userid"));
	int ubered = GetClientOfUserId(GetEventInt(event, "targetid"));
	if (bIsCustomClass[ubered])
	{
		Function FuncClassUbered = GetFunctionByName(hClassIndex[ubered], "CCM_OnClassUbered");
		if (FuncClassUbered != INVALID_FUNCTION)
		{
			Call_StartFunction(hClassIndex[ubered], FuncClassUbered);
			Call_PushCell(ubered);
			Call_PushCell(medic);
			Call_Finish();
		}
	}
	else if (bIsCustomClass[medic])
	{
		Function FuncClassDidUber = GetFunctionByName(hClassIndex[medic], "CCM_OnClassDeployUber");
		if (FuncClassDidUber != INVALID_FUNCTION)
		{
			Call_StartFunction(hClassIndex[medic], FuncClassDidUber);
			Call_PushCell(medic);
			Call_PushCell(ubered);
			Call_Finish();
		}
	}
	return Action:0;
}
public Action RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	if (!GetConVarBool(bEnabled)) return Action:0;
	for (int client = 1; client <= MaxClients; client++)
	{
		if ( IsValidClient(client, false) && bIsCustomClass[client] )
		{
			CreateTimer(10.0, TimerEquipClass, GetClientUserId(client));
		}
	}
	return Action:0;
}
public Action MakeModelTimer(Handle hTimer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client <= 0) return Action:4;
	if (client && IsClientInGame(client) && IsPlayerAlive(client))
	{
		if (bIsCustomClass[client])
		{
			Function FuncModelTimer = GetFunctionByName(hClassIndex[client], "CCM_OnModelTimer");
			if (FuncModelTimer != INVALID_FUNCTION)
			{
				int result;
				Call_StartFunction(hClassIndex[client], FuncModelTimer);
				Call_PushCell(client);
				char model[64];
				Call_PushStringEx(model, sizeof(model), 0, SM_PARAM_COPYBACK);
				Call_Finish(result);

				SetVariantString(model);
				AcceptEntityInput(client, "SetCustomModel");
				SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
				return Action:result;
			}
			else LogError("**** CCM Error: Cannot find 'CCM_OnModelTimer' Function ****");
			//SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.25);
		}
		else
		{
			SetVariantString("");
			AcceptEntityInput(client, "SetCustomModel");
			return Action:4;
		}
	}
	return Action:0;
}
public Action MakeClassMenu(int client, int args)
{
	if (GetConVarBool(bEnabled) && IsClientInGame(client))
	{
		char classnameholder[32];
		Menu classpick = Menu(MenuHandler_PickClass);
		//Handle MainMenu = CreateMenu(MenuHandler_Perks);
		classpick.SetTitle("[Custom Class Maker] Choose A Custom Class");
		int count = GetArraySize(hArrayClass);
		for (int i = 0; i < count; i++)
		{
			GetTrieString(GetArrayCell(hArrayClass, i), "ClassName", classnameholder, sizeof(classnameholder));
			classpick.AddItem("pickclass", classnameholder);
		}
		classpick.Display(client, MENU_TIME_FOREVER);
	}
	return Action:0;
}
public int MenuHandler_PickClass(Menu menu, MenuAction action, int client, int selection)
{  
	char blahblah[32];
	menu.GetItem(selection, blahblah, sizeof(blahblah));
	if (action == MenuAction_Select)
        {
		hClassIndex[client] = GetClassSubPlugin(GetArrayCell(hArrayClass, selection));
		char classnameholder[32];
		GetTrieString(GetArrayCell(hArrayClass, selection), "ClassName", classnameholder, sizeof(classnameholder));
		ReplyToCommand(client, "[CCM] You selected %s as your class!", classnameholder);
		iClassIndex[client] = selection;

		Function FuncPickClass = GetFunctionByName(hClassIndex[client], "CCM_OnClassSelected");
		if (FuncPickClass != INVALID_FUNCTION)
		{
			Call_StartFunction(hClassIndex[client], FuncPickClass);
			Call_PushCell(client);
			Call_Finish();
		}
		bSetCustomClass[client] = true;
        }
	else if (action == MenuAction_End) delete menu;	
}
public Action MakeNotClass(int client, int args)
{
	if (GetConVarBool(bEnabled))
	{
		bSetCustomClass[client] = false;
		char classnameholder[32];
		Handle holderhndl = GetArrayCell(hArrayClass, iClassIndex[client]);
		GetTrieString(holderhndl, "ClassName", classnameholder, sizeof(classnameholder));
		ReplyToCommand(client, "You will no longer be the %s class next time you respawn", classnameholder);

		Function FuncOffClass = GetFunctionByName(hClassIndex[client], "CCM_OnClassDeselected");
		if (FuncOffClass != INVALID_FUNCTION)
		{
			Call_StartFunction(hClassIndex[client], FuncOffClass); //get the func off :)
			Call_PushCell(client);
			Call_Finish();
		}
	}
	return Action:0;
}
/*public void ClassInitialize(int userid, int ClassID)
{
	if (!GetConVarBool(bEnabled)) return;
	int client = GetClientOfUserId(userid);
	if ( client <= 0 ) return;
	int iTeam = GetClientTeam(client);
	if ( (!GetConVarBool(AllowBlu) && (iTeam == 3)) || (!GetConVarBool(AllowRed) && (iTeam == 2)) )
	{
		switch (iTeam)
		{
			case 2: ReplyToCommand(client, "RED players are not allowed to play this Class");
			case 3: ReplyToCommand(client, "BLU players are not allowed to play this Class");
		}
		return;
	}
	int ClassLimit, iCount = 0;
	switch (iTeam)
	{
		case 0, 1: ClassLimit = -2;
		case 2: ClassLimit = GetConVarInt(RedLimit);
		case 3: ClassLimit = GetConVarInt(BluLimit);
	}
	if (ClassLimit == -1)
	{
		bSetCustomClass[client] = true;
		ReplyToCommand(client, "You will be the Class the next time you respawn/touch a resupply locker");
		return;
	}
	else if (ClassLimit == 0)
	{
		if (IsImmune(client))
		{
			bSetCustomClass[client] = true;
			ReplyToCommand(client, "You will be the Class the next time you respawn/touch a resupply locker");
		}
		else ReplyToCommand(client, "**** That Custom Class is Blocked for your Team ****");
		return;
	}
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{	
			if ( (GetClientTeam(i) < 2) && bSetCustomClass[i] ) //remove players who played as custom then went spec
				bSetCustomClass[i] = false;
			if ( ( (!GetConVarBool(AllowBlu) && GetClientTeam(i) == 3) || (!GetConVarBool(AllowRed) && GetClientTeam(i) == 2) ) && bSetCustomClass[i] ) //remove players who were forced to switch teams while dead
				bSetCustomClass[i] = false;
			if (GetClientTeam(i) == iTeam && bSetCustomClass[i] && i != client) //get amount of customs on team
				iCount++;
		}
	}
	if (iCount < ClassLimit)
	{
		bSetCustomClass[client] = true;
		ReplyToCommand(client, "You will be the Class the next time you respawn/touch a resupply locker");
	}
	else if (iCount >= ClassLimit)
	{
		if ( IsImmune(client) )
		{
			bSetCustomClass[client] = true;
			ReplyToCommand(client, "You will be the Class the next time you respawn/touch a resupply locker");
		}
		else ReplyToCommand(client, "**** Custom Class Limit is Reached ****");
	}
	return;
} MAKE YOUR OWN DAMN CLASS LIMITS*/
public bool IsImmune(int iClient)
{
	if (!IsValidClient(iClient, false)) return false;
	char sFlags[32];
	GetConVarString(AdminFlagByPass, sFlags, sizeof(sFlags));
	// If flags are specified and client has generic or root flag, client is immune
	return ( !StrEqual(sFlags, "") && GetUserFlagBits(iClient) & (ReadFlagString(sFlags)|ADMFLAG_ROOT) );
}
public Action CmdReloadCFG(int client, int iAction)
{
	ServerCommand("sm_rcon exec sourcemod/CustomClassMaker.cfg");
	ReplyToCommand(client, "**** Reloading CustomClassMaker Config ****");
	return Action:3;
}
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// F O R W A R D S ==============================================================================================
	OnAddToDownloads = CreateGlobalForward("CCM_OnAddToDownloads", ET_Ignore);
	//===========================================================================================================================

	// N A T I V E S ============================================================================================================
	CreateNative("CCM_RegisterClass", Native_RegisterClassSubplugin);
	//===========================================================================================================================

	RegPluginLibrary("ccm");
#if defined _steamtools_included
	MarkNativeAsOptional("Steam_SetGameDescription");
#endif
	return APLRes_Success;
}
public int Native_RegisterClassSubplugin(Handle plugin, int numParams)
{
	char ClassSubPluginName[32];
	GetNativeString(1, ClassSubPluginName, sizeof(ClassSubPluginName));
	CCMError erroar;
	Handle ClassHandle = RegisterClass(plugin, ClassSubPluginName, erroar); //ALL PROPS TO COOKIES.NET AKA COOKIES.IO
	return _:ClassHandle;
}