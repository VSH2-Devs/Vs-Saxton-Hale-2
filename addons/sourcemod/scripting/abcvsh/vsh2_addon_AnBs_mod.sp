#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <vsh2>
#include <tf2attributes>
#include <morecolors>

#define PLYRS    MAXPLAYERS+1


/**
 * Gameplay Loop: Give a reason to play and a reason to KEEP playing...
 * RED doesn't feel challenging enough.
 * 
 * ideas:
 * Reset max cap amounts back to default.
 * Remove capping buffs, replace with making enemies glow.
 * 
 */

/// SetEntProp(weapon, Prop_Send, "m_bValidatedAttachedEntity", 1);

enum /** difficulty flags */ {
	DIFF_FLAG_25PC_LESS_HP    = 1,
	DIFF_FLAG_HALF_HP         = 2,
	DIFF_FLAG_NO_RAGE         = 4,
	DIFF_FLAG_DEGEN_HEALTH    = 8,
	DIFF_FLAG_NO_WGHDWN       = 16,
	DIFF_FLAG_ALL_SUPERWEPS   = 32,
};

enum struct DeathQueue {
	VSH2Player dead[34];
	
	bool Add(VSH2Player p) {
		for( int i; i<sizeof(DeathQueue::dead); i++ ) {
			if( !this.dead[i] ) {
				this.dead[i] = p;
				return true;
			}
		}
		return false;
	}
	
	bool Remove(VSH2Player p) {
		for( int i; i<sizeof(DeathQueue::dead); i++ ) {
			if( this.dead[i]==p ) {
				this.dead[i] = view_as< VSH2Player >(0);
				return true;
			}
		}
		return false;
	}
	
	void ShiftUp() {
		for( int n=1, j; n<sizeof(DeathQueue::dead); n++ )
			this.dead[j++] = this.dead[n];
	}
	
	void CleanUp() {
		for( int i; i<sizeof(DeathQueue::dead); i++ )
			this.dead[i] = view_as< VSH2Player >(0);
	}
	
	VSH2Player GetNext() {
		VSH2Player p = this.dead[0];
		this.ShiftUp();
		return p;
	}
	
	bool Has(VSH2Player p) {
		for( int i; i<sizeof(DeathQueue::dead); i++ )
			if( this.dead[i]==p )
				return true;
		return false;
	}
}

DeathQueue g_death_queue;


enum struct AnBPlayer {
	bool m_bAllowSuperWeps;
	bool m_bPlayAirShotSong;
	ConVar m_hFriendlyFire;
	/*
	int m_iFourthWep[PLYRS];
	
	bool EquipFourthWep(VSH2Player player) {
		int i = player.index;
		int wep = EntRefToEntIndex(this.m_iFourthWep[i]);
		PrintToConsole(i, "m_iFourthWep = %i, wep = %i", this.m_iFourthWep[i], wep);
		if( wep > MaxClients && IsValidEntity(wep) ) {
			SetEntPropEnt(i, Prop_Send, "m_hActiveWeapon", wep);
			return true;
		}
		return false;
	}
	*/
}

AnBPlayer g_ab_data;

char saxton_songs_str[][] = {
	"saxton_hale/hale_theme1.mp3", /// JMA Saxton Hale Mix
	"saxton_hale/hale_theme2.mp3" /// Men at Work - Land Down Under
};
float saxton_songs_time[] = { 171.0, 221.0 };

char vagineer_songs_str[][] = {
	"saxton_hale/erectin_a_river.mp3",
	"saxton_hale/devil_went_down_to_georgia.mp3",
	"saxton_hale/big_iron.mp3"
};
float vagineer_songs_time[] = { 227.0, 213.0, 236.0 };

char cbs_songs_str[][] = {
	"saxton_hale/numbah_one_snoipah.mp3", /// Mastgrr - Sniper remix Number One TF2
	"saxton_hale/spy_vs_spy.mp3" /// Combustible Edison - Spy vs. Spy
};
float cbs_songs_time[] = { 227.0, 140.0 };

char hhh_songs_str[][] = {
	"saxton_hale/glover_frankenstein_boss.mp3"
};
float hhh_songs_time[] = { 211.0 };

char bunny_songs_str[][] = {
	"saxton_hale/electric_avenue.mp3",
	"saxton_hale/go_daddy_o.mp3"
};
float bunny_songs_time[] = { 221.0, 192.0 };

char plague_songs_str[][] = {
	"plaguedoc/theme1.mp3"
};
float plague_songs_time[] = {
	138.0
};



public Plugin myinfo = {
	name = "VSH2 Buzz Mods addon",
	author = "Nergal/Assyrian",
	description = "",
	version = "1.0",
	url = "sus"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_vsh2_givesuperwep", AdminGiveSuperWeaps, ADMFLAG_VOTE);
	RegConsoleCmd("sm_vsh2_difficulty", SetDifficulty);
	RegConsoleCmd("sm_setdifficulty", SetDifficulty);
	RegConsoleCmd("sm_difficulty", SetDifficulty);
	g_ab_data.m_hFriendlyFire = FindConVar("mp_friendlyfire");
	
	RegConsoleCmd("sm_rules", CommandRules, "A&B's VSH rules.");
	RegConsoleCmd("sm_rulez", CommandRules, "A&B's VSH rules.");
	RegConsoleCmd("sm_darulez", CommandRules, "A&B's VSH rules");
	RegConsoleCmd("sm_commands", CommandsList, "Useful commands for A&B's VSH");
}

public void OnMapStart()
{
	CreateTimer(180.0, ConnectionMessage, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action ConnectionMessage(Handle timer)
{
	CPrintToChatAll("{olive}[A&B's Custom VSH]{default} Type {axis}!rules{default} or {axis}!commands{default} for helpful stuff.");
}


public Action CommandRules(int client, int args)
{
	if( client <= 0 ) {
		ReplyToCommand(client, "[ACVSH Rules] You have to be ingame to use this command.");
		return Plugin_Handled;
	} else if( IsVoteInProgress() )
		return Plugin_Handled;
	
	Menu roolz = new Menu(MenuHandler_Rules);
	roolz.SetTitle("Rules of A&B's Custom Saxton Hale:");
	roolz.AddItem("0", "No cheating or exploiting.");
	roolz.AddItem("1", "Do not drag the round.");
	roolz.AddItem("2", "No phonespam, low quality micspam, or earrape.");
	roolz.AddItem("3", "You can't use voicechat if your voice sounds very young.");
	roolz.AddItem("4", "If a Boss killed you (in)directly, you can't ask for a respawn.");
	roolz.AddItem("5", "No camping if you're not an Engie, Stickybomb Demoman, or Heavy.");
	roolz.AddItem("6", "No advertising for other servers or posting web links in chat.");
	roolz.AddItem("7", "Don't be a jerk or smartasss, just have fun.");
	roolz.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int MenuHandler_Rules(Menu menu, MenuAction action, int client, int item)
{
	if( client<=0 )
		delete menu;
	
	//char info[32]; GetMenuItem(menu, pick, info, sizeof(info));
	char rule_str[][] = {
		"No using third party cheating tools such as LMAOBox.\nno Exploiting counts for both game, map areas, and server plugins. If the Boss cannot get you in a certain map area, it's exploiting.",
		"Self-explanatory, don't make the round go longer than it has to. You can be friendly with players but gotta keep the round going so dead people can play again.",
		"phonespam is playing music straight into your mic instead of using tools or hardware.\nEar rape is any kind of annoying sound that is very annoyingly repetitive or too loud. If the sound is louder than game sounds, it's considered ear rape.",
		"if your voice sounds very young like a kid (women excluded), you're not allowed to use voice chat.",
		"If a Boss directly killed you with their damage or their damage caused you to somehow die, you cannot ask for a respawn. Suiciding counts as well.",
		"Only Defensive classes can camp. If you're a demoknight, even with a grenade launcher, you can't camp; only Sticky Demomen can camp.\nEngineers, even Gunslinger engies, and Heavies can camp. Medics can camp but must be actively healing.",
		"No posting IP address or links to other server communities; this rule includes Discord invites, even if it's an invite for the Assyrian's VSH server group.",
		"Self Explanatory, shit-talking is part of gamer culture but keep it cool. Be edgy in moderation. Don't threaten or provoke people."
	};
	
	if( action==MenuAction_Select ) {
		Panel panel = new Panel();
		panel.SetTitle(rule_str[item]);
		panel.DrawItem("Exit");
		panel.Send(client, HintPanel, 50);
		delete panel;
	} else if( action == MenuAction_End )
		delete menu;
}

public int HintPanel(Menu menu, MenuAction action, int param1, int param2) {
	return;
}


public Action CommandsList(int client, int args)
{
	if( client <= 0 ) {
		ReplyToCommand(client, "[ACVSH Rules] You have to be ingame to use this command.");
		return Plugin_Handled;
	} else if( IsVoteInProgress() )
		return Plugin_Handled;
	
	Menu menu = new Menu(HintPanel);
	menu.SetTitle("Useful Commands for A&B's Custom Saxton Hale:");
	menu.AddItem("", "!vsh2vm <number between 0 and 255> (makes your weapons transparent.)");
	menu.AddItem("", "!noboss (resets your queue points to 0 every end of round.)");
	menu.AddItem("", "!halenext (check to see who the next hale is.)");
	menu.AddItem("", "!setboss (sets your chosen boss.)");
	menu.AddItem("", "!halehelp (help about the mode.)");
	menu.AddItem("", "!resetq (resets your queue points.)");
	menu.AddItem("", "!halehp (check the total boss health.)");
	menu.AddItem("", "!pong, !tetris, !snake (menu games.)");
	menu.AddItem("", "+nade1, +nade2 (using grenades, press once to cook, again to throw.)");
	menu.AddItem("", "!haledmg on (turn on the haledmg counter.)");
	menu.AddItem("", "!difficulty, !vsh2_difficulty (sets your boss difficulty [can only be done when you become the boss].)");
	menu.AddItem("", "!donorlite_timeleft (Checks how much donor time you have left.)");
	menu.AddItem("", "!perks (player customized powerups!)");
	//menu.AddItem("Nzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz");
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}



public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		LoadVSH2Hooks();
	}
}

public void LoadVSH2Hooks()
{
	if( !VSH2_HookEx(OnCallDownloads, BoozDownloads) )
		LogError("Error loading OnCallDownloads forwards for A&B's VSH2 Plugin.");
	
	if( !VSH2_HookEx(OnControlPointCapped, BoozOnControlPointCapped) )
		LogError("Error loading OnControlPointCapped forwards for A&B's VSH2 Plugin.");
	
	if( !VSH2_HookEx(OnUberLoop, BoozOnUberLoop) )
		LogError("Error loading OnUberLoop forwards for A&B's VSH2 Plugin.");
		
	if( !VSH2_HookEx(OnItemOverride, BoozOnItemOverride) )
		LogError("Error Hooking OnItemOverride forward for A&B's VSH2 plugin.");
		
	if( !VSH2_HookEx(OnPrepRedTeam, BoozOnPrepRed) )
		LogError("Error Hooking OnPrepRedTeam forward for A&B's VSH2 plugin.");
		
	if( !VSH2_HookEx(OnVariablesReset, BoozResetShit) )
		LogError("Error Hooking OnVariablesReset forward for A&B's VSH2 plugin.");
		
	if( !VSH2_HookEx(OnLastPlayer, BoozOnDoWonderWaffe) )
		LogError("Error Hooking OnLastPlayer forward for A&B's VSH2 plugin.");
		
	if( !VSH2_HookEx(OnRoundEndInfo, BoozOnRoundEnd) )
		LogError("Error Hooking OnRoundEndInfo forward for A&B's VSH2 plugin.");
		
	if( !VSH2_HookEx(OnMusic, BoozMusic) )
		LogError("Error Hooking OnRoundEndInfo forward for A&B's VSH2 plugin.");
		
	if( !VSH2_HookEx(OnBossCalcHealth, BoozOnModHealth) )
		LogError("Error Hooking OnBossCalcHealth forward for A&B's VSH2 plugin.");
		
	if( !VSH2_HookEx(OnBossThinkPost, BoozOnBossThinkPost) )
		LogError("Error Hooking OnBossThinkPost forward for A&B's VSH2 plugin.");
		
	if( !VSH2_HookEx(OnMessageIntro, BoozOnMessageIntro) )
		LogError("Error Hooking OnMessageIntro forward for A&B's VSH2 plugin.");
		
	if( !VSH2_HookEx(OnBossAirShotProj, BoozOnBossAirShotProj) )
		LogError("Error Hooking OnBossAirShotProj forward for A&B's VSH2 plugin.");
		
	if( !VSH2_HookEx(OnRPSTaunt, BoozRPS) )
		LogError("Error Hooking OnBossAirShotProj forward for A&B's VSH2 plugin.");
		
	if( !VSH2_HookEx(OnPlayerKilled, BoozPlayerKilled) )
		LogError("Error Hooking OnPlayerKilled forward for A&B's VSH2 plugin.");
		
	if( !VSH2_HookEx(OnRedPlayerThink, BoozOnRedPlayerThink) )
		LogError("Error Hooking OnRedPlayerThink forward for A&B's VSH2 plugin.");
}


public void OnClientPutInServer(int client)
{
	//g_ab_data.m_iFourthWep[client] = -1;
}

public void BoozDownloads()
{
	DownloadSoundList(saxton_songs_str, sizeof(saxton_songs_str));
	DownloadSoundList(vagineer_songs_str, sizeof(vagineer_songs_str));
	DownloadSoundList(cbs_songs_str, sizeof(cbs_songs_str));
	DownloadSoundList(hhh_songs_str, sizeof(hhh_songs_str));
	DownloadSoundList(bunny_songs_str, sizeof(bunny_songs_str));
	DownloadSoundList(plague_songs_str, sizeof(plague_songs_str));
	PrepareSound("acvsh/airshot.wav");
}


public void BoozOnControlPointCapped(char cappers[MAXPLAYERS+1], const int team)
{
	int len = strlen(cappers);
	switch( team ) {
		case VSH2Team_Red: {
			VSH2Player[] bosses = new VSH2Player[MaxClients];
			int num_bosses = VSH2GameMode_GetBosses(bosses);
			for( int i; i<num_bosses; i++ )
				bosses[i].SetPropFloat("flGlowtime", 15.0);
			/*
			int pwrup = GetRandomInt(0, 1);
			for( int i; i<len; i++ ) {
				int client = cappers[i];
				VSH2Player player = VSH2Player(client);
			}
			
			VSH2Player[] reds = new VSH2Player[MaxClients];
			int red_count = VSH2GameMode_GetFighters(reds, false);
			int respawn = red_count / 8;
			if( respawn <= 0 )
				respawn = 1;
			
			/// Respawn some players.
			while( respawn-- ) {
				VSH2Player ded = g_death_queue.GetNext();
				if( !ded || IsPlayerAlive(ded.index) )
					continue;
				TF2_RespawnPlayer(ded.index);
			}
			*/
		}
		case VSH2Team_Boss: {
			VSH2Player[] reds = new VSH2Player[MaxClients];
			int num_reds = VSH2GameMode_GetFighters(reds);
			for( int i; i<num_reds; i++ )
				reds[i].SetPropFloat("flGlowtime", 15.0);
			
			//VSH2GameMode_GetPropInt("iCaptures")
			/*
			for( int i=0; i<len; i++ ) {
				int client = cappers[i];
				boss = VSH2Player(client);
				
			}
			*/
		}
	}
}

public void BoozOnUberLoop(const VSH2Player medic, const VSH2Player ubertarget)
{
	if( !ubertarget )
		return;
	
	for( int i; i<2; i++ ) {
		int ent_wep = GetPlayerWeaponSlot(ubertarget.index, i);
		//PrintToConsole(uberer, "ent_wep == %d", ent_wep);
		if( ent_wep <= 0 || !IsValidEntity(ent_wep) )
			continue;
		
		int wepindex = ubertarget.GetWeaponSlotIndex(i);
		//PrintToConsole(uberer, "wepindex == %d", wepindex);
		if( wepindex <= 0 )
			continue;
		
		int maxAmmo = ubertarget.GetAmmoTable(i);
		//PrintToConsole(medic.index, "maxAmmo[%i] == %d", i, maxAmmo);
		if( maxAmmo > 0 )
			SetWeaponAmmo(ent_wep, maxAmmo);
		
		if( wepindex==730 || wepindex==1079 || wepindex==305 || wepindex==45 )
			continue;
		
		int maxClip = ubertarget.GetClipTable(i);
		//PrintToConsole(medic.index, "maxClip[%i] == %d", i, maxClip);
		if( maxClip > 0 )
			SetWeaponClip(ent_wep, maxClip);
	}
}

public Action BoozOnItemOverride(const VSH2Player player, const char[] classname, int itemdef, TF2Item& hItem)
{
	int client = player.index;
	TF2Item hItemOverride = null;
	
	switch( itemdef ) {
		/// Fortified Compound.
		//case 1092: hItemOverride = TF2Item_PrepareItemHandle(null, _, _, "1 ; 0.1 ; 76 ; 3.0 ; 6 ; 0.2 ; 41 ; 4.0");
		/// soda popper
		case 448: hItemOverride = TF2Item_PrepareItemHandle(null, _, _, "4 ; 2.0");
		/// Righteous Bison
		//case 442: hItemOverride = TF2Item_PrepareItemHandle(null, _, _, "97 ; 0.5 ; 6 ; 0.75");
		/// HHH's Axe
		case 266: hItemOverride = TF2Item_PrepareItemHandle(null, _, _, "134 ; 37 ; 251 ; 1.0");
		/// Natascha
		case 41: hItemOverride = TF2Item_PrepareItemHandle(null, _, _, "87 ; 0.75 ; 280 ; 2 ; 642 ; 1 ; 2 ; 3.0 ; 411 ; 4 ; 181 ; 2.0 ; 128 ; 1 ; 26 ; 50.0", true);
		/// Huo Long Heater
		case 811, 832: hItemOverride = TF2Item_PrepareItemHandle(null, _, _, "87 ; 0.75 ; 430 ; 30 ; 431 ; 1", true);
		/// boston basher & 3rune blade
		case 325, 452: hItemOverride = TF2Item_PrepareItemHandle(null, _, _, "204 ; 0 ; 149 ; 5", true);
		/// Beggar's Bazooka
		case 730: hItemOverride = TF2Item_PrepareItemHandle(null, _, _, "394 ; 0.3 ; 241 ; 1.3 ; 3 ; 0.75 ; 411 ; 5 ; 6 ; 0.1 ; 642 ; 1", true);
	}
	/*
	if( !strncmp(classname, "tf_weapon_shotgun", 17, false) || !strncmp(classname, "tf_weapon_sentry_revenge", 24, false) ) {
		switch( TF2_GetPlayerClass(client) ) {
			case TFClass_Soldier: hItemOverride = TF2Item_PrepareItemHandle(null, _, _, "6 ; 0.75 ; 97 ; 0.5 ; 78 ; 1.125 ; 135; 0.6; 114; 1.0");
			case TFClass_Engineer: hItemOverride = TF2Item_PrepareItemHandle(null, _, _, "6 ; 0.75 ; 97 ; 0.5 ; 76 ; 1.125 ; 114; 1.0");
			default: hItemOverride = TF2Item_PrepareItemHandle(null, _, _, "6 ; 0.75 ; 97 ; 0.5 ; 78 ; 1.125 ; 114; 1.0");
		}
	} else if( !strncmp(classname, "tf_weapon_scattergun", 20, false) || !strncmp(classname, "tf_weapon_pep_brawler_blaster", 29, false) ) {
		switch( itemdef ) {
			case 45, 1078: hItemOverride = TF2Item_PrepareItemHandle(null, _, _, "76 ; 1.125");
			case 772: hItemOverride = TF2Item_PrepareItemHandle(null, _, _, "6 ; 0.75; 97 ; 0.5; 76 ; 1.125; 412 ; 1.33; 106; 0.3; 4; 1.33; 45; 0.6; 114; 1.0", true);
			case 1103: hItemOverride = TF2Item_PrepareItemHandle(null, _, _, "6 ; 0.75 ; 97 ; 0.5 ; 76 ; 1.125 ; 179 ; 1.0");
			default: hItemOverride = TF2Item_PrepareItemHandle(null, _, _, "6 ; 0.75 ; 97 ; 0.5 ; 76 ; 1.125");
		}
	} else if( StrEqual(classname, "tf_wearable", false) && itemdef > 642 ) {
		hItemOverride = TF2Item_PrepareItemHandle(null, _, _, "26 ; 15");
	}*/
	
	if( hItemOverride != null ) {
		if( hItem != null )
			delete hItem;
		hItem = hItemOverride;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public void BoozOnPrepRed(const VSH2Player player)
{
	int client = player.index;
	TFClassType tfclass = TF2_GetPlayerClass(client);
	switch( tfclass ) {
		case TFClass_Scout: {
			int weapon = GetPlayerWeaponSlot(player.index, TFWeaponSlot_Melee);
			if( weapon > MaxClients && IsValidEntity(weapon) ) {
				if( VSH2GameMode_GetPropAny("bTF2Attribs") )
					TF2Attrib_SetByDefIndex(weapon, 6, 0.75);
			}
		}
		/*
		case TFClass_DemoMan: {
			int weapon = player.SpawnWeapon("tf_weapon_shotgun_primary", 9, 100, 10, "4 ; 1.33 ; 45 ; 0.6 ; 106 ; 0.4 ; 6 ; 0.8 ; 97 ; 0.4 ; 76 ; 1.5625 ; 114; 1.0");
			g_ab_data.m_iFourthWep[client] = EntIndexToEntRef(weapon);
			PrintToConsole(client, "Demo shotgun: weapon: %i, ent ref: %i", weapon, g_ab_data.m_iFourthWep[client]);
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
		}
		case TFClass_Pyro: {
			int weapon = player.SpawnWeapon("tf_weapon_shotgun_pyro", 12, 100, 10, "4 ; 0.167 ; 45 ; 0.6 ; 106 ; 0.3 ; 6 ; 0.8 ; 97 ; 0.25 ; 78 ; 2.5 ; 114; 1.0");
			g_ab_data.m_iFourthWep[client] = EntIndexToEntRef(weapon);
			PrintToConsole(client, "Pyro shotgun: weapon: %i, ent ref: %i", weapon, g_ab_data.m_iFourthWep[client]);
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
		}
		*/
	}
	PrintHintText(client, "[A&B's Custom VSH] Type !rules or !commands for helpful stuff.");
}

public void BoozOnRoundEnd(const VSH2Player player, bool bossBool, char message[MAXMESSAGE])
{
	g_ab_data.m_bAllowSuperWeps = false;
	if( g_ab_data.m_hFriendlyFire != null )
		g_ab_data.m_hFriendlyFire.BoolValue = true;
	
	g_death_queue.CleanUp();
	/*
	int ent = -1;
	while( (ent = FindEntityByClassname(ent, "trigger_capture_area")) != -1 ) {
		SetVariantInt(10);
		AcceptEntityInput(ent, "SetWinner");
	}*/
}

public void BoozMusic(char song[PLATFORM_MAX_PATH], float& time, const VSH2Player player)
{
	int bossid = player.GetPropInt("iBossType");
	switch( bossid ) {
		case VSH2Boss_Hale: {
			int index = GetRandomInt(0, sizeof(saxton_songs_str)-1);
			strcopy(song, sizeof(song), saxton_songs_str[index]);
			time = saxton_songs_time[index];
		}
		case VSH2Boss_Vagineer: {
			int index = GetRandomInt(0, sizeof(vagineer_songs_str)-1);
			strcopy(song, sizeof(song), vagineer_songs_str[index]);
			time = vagineer_songs_time[index];
		}
		case VSH2Boss_CBS: {
			if( GetRandomInt(0, 1) )
				return;
			
			int index = GetRandomInt(0, sizeof(cbs_songs_str)-1);
			strcopy(song, sizeof(song), cbs_songs_str[index]);
			time = cbs_songs_time[index];
		}
		case VSH2Boss_HHHjr: {
			if( GetRandomInt(0, 1) )
				return;
			
			int index = GetRandomInt(0, sizeof(hhh_songs_str)-1);
			strcopy(song, sizeof(song), hhh_songs_str[index]);
			time = hhh_songs_time[index];
		}
		case VSH2Boss_Bunny: {
			int index = GetRandomInt(0, sizeof(bunny_songs_str)-1);
			strcopy(song, sizeof(song), bunny_songs_str[index]);
			time = bunny_songs_time[index];
		}
		default: {
			StringMap boss_map = VSH2_GetBossIDs(true);
			int i;
			if( boss_map.GetValue("plague_doctor", i) && bossid==i ) {
				int index = GetRandomInt(0, sizeof(plague_songs_str)-1);
				strcopy(song, sizeof(song), plague_songs_str[index]);
				time = plague_songs_time[index];
			}
			delete boss_map;
		}
	}
}

public void BoozOnDoWonderWaffe(const VSH2Player player)
{
	g_ab_data.m_bAllowSuperWeps = true;
	VSH2Player[] bosses = new VSH2Player[MaxClients];
	int count = VSH2GameMode_GetBosses(bosses);
	int total_health, total_max_health;
	for( int i; i<count; i++ ) {
		total_health += GetClientHealth(bosses[i].index);
		total_max_health += bosses[i].GetPropInt("iMaxHealth");
	}
	
	float perc = float(total_health) / float(total_max_health);
	if( perc >= 0.5 && total_health > 5000 ) {
		VSH2Player[] reds = new VSH2Player[MaxClients];
		VSH2GameMode_GetFighters(reds);
		if( reds[0].GetPropInt("iDamage") >= 1000 )
			PickSuperWeapon(reds[0].index, -1);
	}
}

public Action PickSuperWeapon(client, args)
{
	if( IsValidClient(client) && IsPlayerAlive(client) && GetClientTeam(client) != VSH2Team_Boss ) {
		Menu superwep = new Menu(MenuHandler_SuperWeapz);
		superwep.SetTitle("**** QUICK: DO YOU WANT SuperWeaponz? ****");
		superwep.AddItem("yes", "**** YES ****");
		superwep.AddItem("no", "**** NO ****");
		//superwep.AddItem("", "");
		superwep.Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Continue;
}

public int MenuHandler_SuperWeapz(Menu menu, MenuAction action, int client, int pick)
{
	char info[32]; menu.GetItem(pick, info, sizeof(info));
	if( action == MenuAction_Select ) {
		if( !g_ab_data.m_bAllowSuperWeps )
			pick = 2;
		switch( pick ) {
			case 0: {
				GiveSuperWeap(VSH2Player(client));
				g_ab_data.m_bAllowSuperWeps = false;
			}
			default: g_ab_data.m_bAllowSuperWeps = false;
		}
	} else if( action == MenuAction_End )
		delete menu;
}

void GiveSuperWeap(VSH2Player player)
{
	char health_attribs[64];
	int client = player.index;
	int trollhealth = ( 20 * (VSH2GameMode_GetTotalBossHealth() / 1000) );
	switch( TF2_GetPlayerClass(client) ) {
		case TFClass_Scout: {
			Format(health_attribs, sizeof(health_attribs), "2 ; 3.0 ; 6 ; 0.75 ; 26 ; %i", trollhealth);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			player.SpawnWeapon("tf_weapon_scattergun", 200, 100, 10, "542 ; 1 ; 2022 ; 1 ; 2027 ; 1 ; 2 ; 3.0 ; 6 ; 0.75 ; 97 ; 0.5 ; 76 ; 1.875");
			player.SpawnWeapon("tf_weapon_pistol_scout", 160, 100, 10, "2 ; 3.0 ; 97 ; 0.5 ; 78 ; 2.0");
			player.SpawnWeapon("tf_weapon_bat", 1071, 100, 10, health_attribs);
		}
		case TFClass_Soldier: {
			Format(health_attribs, sizeof(health_attribs), "2 ; 3.0 ; 26 ; %i", trollhealth);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			player.SpawnWeapon("tf_weapon_rocketlauncher", 228, 100, 10, "542 ; 1 ; 2022 ; 1 ; 2027 ; 1 ; 2 ; 3.0 ; 76 ; 2.0");
			player.SpawnWeapon("tf_weapon_shotgun_soldier", 10, 100, 10, "2 ; 3.0 ; 6 ; 0.75 ; 97 ; 0.5 ; 78 ; 1.875");
			player.SpawnWeapon("tf_weapon_shovel", 1071, 100, 10, health_attribs);
		}
		case TFClass_Pyro: {
			Format(health_attribs, sizeof(health_attribs), "542 ; 1 ; 2022 ; 1 ; 2027 ; 1 ; 2 ; 3.0 ; 26 ; %i", trollhealth);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			player.SpawnWeapon("tf_weapon_flamethrower", 208, 100, 10, "542 ; 1 ; 2022 ; 1 ; 2027 ; 1 ; 2 ; 3.0 ; 76 ; 2.0");
			player.SpawnWeapon("tf_weapon_shotgun_pyro", 12, 100, 10, "2 ; 3.0 ; 6 ; 0.75 ; 97 ; 0.5 ; 78 ; 1.875 ; 208 ; 1");
			player.SpawnWeapon("tf_weapon_fireaxe", 38, 100, 10, health_attribs);
		}
		case TFClass_DemoMan: {
			Format(health_attribs, sizeof(health_attribs), "542 ; 1 ; 2022 ; 1 ; 2027 ; 1 ; 2 ; 3.0 ; 26 ; %i", trollhealth);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			player.SpawnWeapon("tf_weapon_grenadelauncher", 206, 100, 10, "542 ; 1 ; 2022 ; 1 ; 2027 ; 1 ; 2 ; 3.0 ; 76 ; 2.0");
			player.SpawnWeapon("tf_weapon_pipebomblauncher", 207, 100, 10, "542 ; 1 ; 2022 ; 1 ; 2027 ; 1 ; 2 ; 3.0 ; 6 ; 0.75 ; 78 ; 1.5");
			player.SpawnWeapon("tf_weapon_sword", 132, 100, 10, health_attribs);
		}
		case TFClass_Heavy: {
			Format(health_attribs, sizeof(health_attribs), "2 ; 3.0 ; 26 ; %i", trollhealth);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			player.SpawnWeapon("tf_weapon_minigun", 202, 100, 10, "542 ; 1 ; 2022 ; 1 ; 2027 ; 1 ; 2 ; 3.0 ; 76 ; 2.0 ; 87 ; 0.5");
			player.SpawnWeapon("tf_weapon_shotgun_hwg", 11, 100, 10, "2 ; 3.0 ; 6 ; 0.75 ; 97 ; 0.5 ; 78 ; 1.875");
			player.SpawnWeapon("tf_weapon_fists", 1071, 100, 10, health_attribs);
		}
		case TFClass_Engineer: {
			Format(health_attribs, sizeof(health_attribs), "113 ; 50 ; 2043 ; 4.0 ; 2 ; 3.0 ; 26 ; %i", trollhealth);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			player.SpawnWeapon("tf_weapon_sentry_revenge", 141, 100, 10, "542 ; 1 ; 2022 ; 1 ; 2027 ; 1 ; 6 ; 0.75 ; 97 ; 0.5 ; 2 ; 3.0 ; 76 ; 2.0");
			player.SpawnWeapon("tf_weapon_pistol", 773, 100, 10, "2 ; 3.0");
			player.SpawnWeapon("tf_weapon_wrench", 1071, 100, 10, health_attribs);
		}
		case TFClass_Medic: {
			Format(health_attribs, sizeof(health_attribs), "17 ; 0.25 ; 2 ; 3.0 ; 26 ; %i", trollhealth);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			player.SpawnWeapon("tf_weapon_syringegun_medic", 36, 100, 10, "542 ; 1 ; 2022 ; 1 ; 2027 ; 1 ; 2 ; 3.0 ; 76 ; 2.0 ; 17 ; 0.10");
			player.SpawnWeapon("tf_weapon_medigun", 211, 100, 10, "542 ; 1 ; 2022 ; 1 ; 2027 ; 1");
			player.SpawnWeapon("tf_weapon_bonesaw", 1071, 100, 10, health_attribs);
		}
		case TFClass_Sniper: {
			Format(health_attribs, sizeof(health_attribs), "2 ; 3.0 ; 26 ; %i", trollhealth);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			player.SpawnWeapon("tf_weapon_sniperrifle", 201, 100, 10, "542 ; 1 ; 2022 ; 1 ; 2027 ; 1 ; 2 ; 3.0 ; 76 ; 2.0 ; 390 ; 3.0");
			player.SpawnWeapon("tf_weapon_smg", 203, 100, 10, "542 ; 1 ; 2022 ; 1 ; 2027 ; 1 ; 2 ; 3.0");
			player.SpawnWeapon("tf_weapon_club", 1071, 100, 10, health_attribs);
		}
		case TFClass_Spy: {
			Format(health_attribs, sizeof(health_attribs), "542 ; 1 ; 2022 ; 1 ; 2027 ; 1 ; 2 ; 2.0 ; 26 ; %i", trollhealth);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
			player.SpawnWeapon("tf_weapon_revolver", 61, 100, 10, "542 ; 1 ; 2022 ; 1 ; 2027 ; 1 ; 51 ; 1.0 ; 5 ; 1.2 ; 2 ; 3.0 ; 76 ; 2.0");
			player.SpawnWeapon("tf_weapon_knife", 194, 100, 10, health_attribs);
		}
	}
	int maxhp = GetEntProp(client, Prop_Data, "m_iMaxHealth");
	SetAmmo(client, 0, 9999);
	SetAmmo(client, 1, 9999);
	SetEntityHealth(client, trollhealth+maxhp);
}

public void BoozResetShit(const VSH2Player player)
{
	if( g_ab_data.m_hFriendlyFire != null )
		g_ab_data.m_hFriendlyFire.BoolValue = false;
	g_ab_data.m_bPlayAirShotSong = true;
}

public Action BoozOnBossAirShotProj(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if( victim.index==attacker )
		return Plugin_Continue;
	
	char inflictor_name[32];
	if( IsValidEntity(inflictor) )
		GetEntityClassname(inflictor, inflictor_name, sizeof(inflictor_name));
	
	//char wepname[64];
	//if( IsValidEntity(weapon) )
	//	GetEdictClassname(weapon, wepname, sizeof(wepname));
	
	if( StrEqual(inflictor_name, "tf_projectile_rocket") || StrEqual(inflictor_name, "tf_projectile_pipe") ) {
		VSH2Player pro = VSH2Player(attacker);
		if( IsValidEntity(weapon) ) {
			int maxClip = pro.GetClipTable(GetSlotFromWeapon(attacker, weapon));
			if( maxClip > 0 )
				SetWeaponClip(weapon, maxClip);
		}
		if( g_ab_data.m_bPlayAirShotSong ) {
			EmitSoundToAll("acvsh/airshot.wav");
			g_ab_data.m_bPlayAirShotSong = false;
			CreateTimer(80.0, TimerResetAirshot, _, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return Plugin_Continue;
}

public Action TimerResetAirshot(Handle timer)
{
	g_ab_data.m_bPlayAirShotSong = true;
	return Plugin_Continue;
}

public void BoozRPS(const VSH2Player victim, const VSH2Player attacker)
{
	if( victim.GetPropAny("bIsBoss") )
		SetPawnTimer(DoRPSDamage, 2.0, victim, attacker);
}

public void DoRPSDamage(const VSH2Player victim, const VSH2Player attacker)
{
	if( !IsValidClient(victim.index) || !IsValidClient(attacker.index) )
		return;
	SDKHooks_TakeDamage(victim.index, attacker.index, attacker.index, victim.iHealth+0.0, DMG_DIRECT);
}

public void BoozPlayerKilled(const VSH2Player player, const VSH2Player victim, Event event)
{
	if( victim.GetPropAny("bIsBoss") || victim.GetPropAny("bIsMinion") )
		return;
	g_death_queue.Add(victim);
}

public void BoozOnRedPlayerThink(const VSH2Player player)
{
	VSH2_GlowThink(player, 0.1);
}

public Action AdminGiveSuperWeaps(int client, int args)
{
	if( args < 1 ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} Usage: /vsh2_givesuperwep <target>");
		return Plugin_Handled;
	}
	char szTargetname[64]; GetCmdArg(1, szTargetname, sizeof(szTargetname));
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS+1], target_count;
	bool tn_is_ml;
	if( (target_count = ProcessTargetString(szTargetname, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0 ) {
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for( int i; i<target_count; i++ ) {
		if( IsValidClient(target_list[i]) && IsPlayerAlive(target_list[i]) ) {
			GiveSuperWeap(VSH2Player(target_list[i]));
			CPrintToChat(target_list[i], "{olive}[VSH 2]{orange} an Admin gave you super weps!");
		}
	}
	return Plugin_Handled;
}


public Action SetDifficulty(int client, int args)
{
	if( client <= 0 ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} You can only use this command ingame.");
		return Plugin_Handled;
	}
	
	VSH2Player player = VSH2Player(client);
	Menu difficulty = new Menu(MenuHandler_DoDifficulties);
	difficulty.SetTitle("Choose your VSH2 Boss Difficulty Settings:");
	int curr_difficulty = player.GetPropInt("iDifficulty");
	char
		tostr[10],
		settingstr[100]
	;
	
	IntToString(DIFF_FLAG_25PC_LESS_HP, tostr, sizeof(tostr));
	Format(settingstr, sizeof(settingstr), "25% Less Boss Health %s", curr_difficulty & DIFF_FLAG_25PC_LESS_HP ? "(Enabled)" : "(Disabled)");
	difficulty.AddItem(tostr, settingstr);
	
	IntToString(DIFF_FLAG_HALF_HP, tostr, sizeof(tostr));
	Format(settingstr, sizeof(settingstr), "Halved Boss Health %s", curr_difficulty & DIFF_FLAG_HALF_HP ? "(Enabled)" : "(Disabled)");
	difficulty.AddItem(tostr, settingstr);
	
	IntToString(DIFF_FLAG_NO_RAGE, tostr, sizeof(tostr));
	Format(settingstr, sizeof(settingstr), "No Rage Generation %s", curr_difficulty & DIFF_FLAG_NO_RAGE ? "(Enabled)" : "(Disabled)");
	difficulty.AddItem(tostr, settingstr);
	
	IntToString(DIFF_FLAG_DEGEN_HEALTH, tostr, sizeof(tostr));
	Format(settingstr, sizeof(settingstr), "Health Degeneration %s", curr_difficulty & DIFF_FLAG_DEGEN_HEALTH ? "(Enabled)" : "(Disabled)");
	difficulty.AddItem(tostr, settingstr);
	
	IntToString(DIFF_FLAG_NO_WGHDWN, tostr, sizeof(tostr));
	Format(settingstr, sizeof(settingstr), "No Weighdown %s", curr_difficulty & DIFF_FLAG_NO_WGHDWN ? "(Enabled)" : "(Disabled)");
	difficulty.AddItem(tostr, settingstr);
	
	IntToString(DIFF_FLAG_ALL_SUPERWEPS, tostr, sizeof(tostr));
	Format(settingstr, sizeof(settingstr), "All Super Weapons %s [Disabled for Multibosses]", curr_difficulty & DIFF_FLAG_ALL_SUPERWEPS ? "(Enabled)" : "(Disabled)");
	difficulty.AddItem(tostr, settingstr);
	
	difficulty.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int MenuHandler_DoDifficulties(Menu menu, MenuAction action, int client, int pick)
{
	char info[32]; menu.GetItem(pick, info, sizeof(info));
	if( action == MenuAction_Select ) {
		int difficulty_flag = StringToInt(info);
		VSH2Player player = VSH2Player(client);
		int curr_difficulty = player.GetPropInt("iDifficulty");
		player.SetPropInt("iDifficulty", curr_difficulty ^ difficulty_flag);
		SetDifficulty(client, -1);
	} else if( action == MenuAction_End )
		delete menu;
}


/*
public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	VSH2Player player = VSH2Player(client);
	if( player && (buttons & IN_ATTACK3) )
		g_ab_data.EquipFourthWep(player);
	
	return Plugin_Continue;
}
*/

public void BoozOnModHealth(const VSH2Player player, int& max_health, const int boss_count, const int red_players)
{
	max_health = CalcBossHealth(800.0, red_players, 1.0, 1.035, 2046.0) / boss_count;
	int diff_flags = player.GetPropInt("iDifficulty");
	switch( diff_flags & (DIFF_FLAG_25PC_LESS_HP|DIFF_FLAG_HALF_HP) ) {
		case DIFF_FLAG_25PC_LESS_HP|DIFF_FLAG_HALF_HP:
			max_health = RoundFloat( max_health * 0.25 );
		case DIFF_FLAG_25PC_LESS_HP:
			max_health = RoundFloat( max_health * 0.75 );
		case DIFF_FLAG_HALF_HP:
			max_health = RoundFloat( max_health * 0.5 );
	}
}

public void BoozOnBossThinkPost(VSH2Player player)
{
	int client = player.index;
	if( !IsPlayerAlive(client) )
		return;
	
	int diff_flags = player.GetPropInt("iDifficulty");
	if( diff_flags & DIFF_FLAG_NO_RAGE )
		player.SetPropFloat("flRAGE", 0.0);
	
	if( diff_flags & DIFF_FLAG_DEGEN_HEALTH ) {
		if( player.iHealth > 300 )
			player.iHealth -= 1;
	}
	
	if( diff_flags & DIFF_FLAG_NO_WGHDWN )
		player.SetPropFloat("flWeighDown", 0.0);
}

public void BoozOnMessageIntro(const VSH2Player player, char message[MAXMESSAGE])
{
	int boss_count = VSH2GameMode_CountBosses(true);
	if( boss_count==1 ) {
		if( player.GetPropInt("iDifficulty") & DIFF_FLAG_ALL_SUPERWEPS ) {
			g_ab_data.m_bAllowSuperWeps = false;
			VSH2Player[] reds = new VSH2Player[MaxClients];
			int red_count = VSH2GameMode_GetFighters(reds);
			for( int i; i<red_count; i++ )
				GiveSuperWeap(reds[i]);
		}
	}
}

public void OnEntityCreated(int ent, const char[] classname)
{
	if( !IsValidEntity(ent) )
		return;
	else if( StrContains(classname, "tf_wea") != -1 ) {
		if( HasEntProp(ent, Prop_Send, "m_bValidatedAttachedEntity") )
			SetEntProp(ent, Prop_Send, "m_bValidatedAttachedEntity", 1);
	}
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
	if( IsValidEntity(weapon) ) {
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
