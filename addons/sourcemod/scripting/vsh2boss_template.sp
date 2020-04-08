#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <vsh2>

#undef REQUIRE_PLUGIN
#tryinclude <tf2attributes>
#define REQUIRE_PLUGIN


#define TemplateModel    "models/templatefolder/templateboss.mdl"

/// voicelines
char TemplateIntro[][] = {
	"template_snd/start1.mp3",
	"template_snd/start2.mp3"
};

char TemplateJump[][] = {
	"template_snd/jump1.mp3",
	"template_snd/jump2.mp3"
};

char TemplateStab[][] = {
	"template_snd/stab1.mp3",
	"template_snd/stab2.mp3"
};

char TemplateDeath[][] = {
	"template_snd/death1.mp3",
	"template_snd/death2.mp3"
};

char TemplateLast[][] = {
	"template_snd/lastguy1.mp3",
	"template_snd/lastguy2.mp3"
};

char TemplateRage[][] = {
	"template_snd/rage1.mp3",
	"template_snd/rage2.mp3"
};

char TemplateKill[][] = {
	"template_snd/kill1.mp3",
	"template_snd/kill2.mp3"
};

char TemplateSpree[][] = {
	"template_snd/spree1.mp3",
	"template_snd/spree2.mp3"
};

char TemplateWin[][] = {
	"template_snd/win1.mp3",
	"template_snd/win2.mp3"
};

char TemplateThemes[][] = {
	"template_snd/theme1.mp3",
	"template_snd/theme2.mp3"
};

float TemplateThemesTime[] = {
	60.0,
	60.0
};


public Plugin myinfo = {
	name = "VSH2 Template Boss Module",
	author = "Nergal/Assyrian",
	description = "",
	version = "1.0",
	url = "sus"
};

int g_iTemplateID;

enum struct VSH2CVars {
	ConVar scout_rage_gen;
	ConVar airblast_rage;
	ConVar jarate_rage;
}

VSH2CVars g_vsh2_cvars;


public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		g_vsh2_cvars.scout_rage_gen = FindConVar("vsh2_scout_rage_gen");
		g_vsh2_cvars.airblast_rage = FindConVar("vsh2_airblast_rage");
		g_vsh2_cvars.jarate_rage = FindConVar("vsh2_jarate_rage");
		g_iTemplateID = VSH2_RegisterPlugin("template_boss");
		LoadVSH2Hooks();
	}
}

public void LoadVSH2Hooks()
{
	if( !VSH2_HookEx(OnCallDownloads, Template_OnCallDownloads) )
		LogError("Error loading OnCallDownloads forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossMenu, Template_OnBossMenu) )
		LogError("Error loading OnBossMenu forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossSelected, Template_OnBossSelected) )
		LogError("Error loading OnBossSelected forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossThink, Template_OnBossThink) )
		LogError("Error loading OnBossThink forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossModelTimer, Template_OnBossModelTimer) )
		LogError("Error loading OnBossModelTimer forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossEquipped, Template_OnBossEquipped) )
		LogError("Error loading OnBossEquipped forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossInitialized, Template_OnBossInitialized) )
		LogError("Error loading OnBossInitialized forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossPlayIntro, Template_OnBossPlayIntro) )
		LogError("Error loading OnBossPlayIntro forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnPlayerKilled, Template_OnPlayerKilled) )
		LogError("Error loading OnPlayerKilled forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnPlayerHurt, Template_OnPlayerHurt) )
		LogError("Error loading OnPlayerHurt forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnPlayerAirblasted, Template_OnPlayerAirblasted) )
		LogError("Error loading OnPlayerAirblasted forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossMedicCall, Template_OnBossMedicCall) )
		LogError("Error loading OnBossMedicCall forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossTaunt, Template_OnBossMedicCall) )
		LogError("Error loading OnBossTaunt forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossJarated, Template_OnBossJarated) )
		LogError("Error loading OnBossJarated forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnRoundEndInfo, Template_OnRoundEndInfo) )
		LogError("Error loading OnRoundEndInfo forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnMusic, Template_Music) )
		LogError("Error loading OnBossDealDamage forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossDeath, Template_OnBossDeath) )
		LogError("Error loading OnBossDeath forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnBossTakeDamage_OnStabbed, Template_OnStabbed) )
		LogError("Error loading OnBossTakeDamage_OnStabbed forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnLastPlayer, Template_OnLastPlayer) )
		LogError("Error loading OnLastPlayer forwards for Template subplugin.");
	
	if( !VSH2_HookEx(OnSoundHook, Template_OnSoundHook) )
		LogError("Error loading OnSoundHook forwards for Template subplugin.");
}



stock bool IsTemplate(const VSH2Player player) {
	return player.GetPropInt("iBossType") == g_iTemplateID;
}


public void Template_OnCallDownloads()
{
	PrepareModel(TemplateModel);
	DownloadSoundList(TemplateIntro, sizeof(TemplateIntro));
	DownloadSoundList(TemplateJump, sizeof(TemplateJump));
	DownloadSoundList(TemplateStab, sizeof(TemplateStab));
	DownloadSoundList(TemplateDeath, sizeof(TemplateDeath));
	DownloadSoundList(TemplateLast, sizeof(TemplateLast));
	DownloadSoundList(TemplateRage, sizeof(TemplateRage));
	DownloadSoundList(TemplateKill, sizeof(TemplateKill));
	DownloadSoundList(TemplateSpree, sizeof(TemplateSpree));
	DownloadSoundList(TemplateWin, sizeof(TemplateWin));
	DownloadSoundList(TemplateThemes, sizeof(TemplateThemes));
	
	PrepareMaterial("materials/models/template_snd/skin_red");
	PrepareMaterial("materials/models/template_snd/skin_blu");
	PrepareMaterial("materials/models/template_snd/normals");
}

public void Template_OnBossMenu(Menu &menu)
{
	char tostr[10]; IntToString(g_iTemplateID, tostr, sizeof(tostr));
	menu.AddItem(tostr, "Template");
}

public void Template_OnBossSelected(const VSH2Player player)
{
	if( !IsTemplate(player) )
		return;
	
	player.SetPropInt("iCustomProp", 0);
	player.SetPropFloat("flCustomProp", 0.0);
	player.SetPropAny("hCustomProp", player);
	
	Panel panel = new Panel();
	panel.SetTitle("Template:\nInfo Message 1.\nInfo Message 2.\nInfo Message 3.");
	panel.DrawItem("Exit");
	panel.Send(player.index, HintPanel, 50);
	delete panel;
}

public void Template_OnBossThink(const VSH2Player player)
{
	int client = player.index;
	if( !IsPlayerAlive(client) || !IsTemplate(player) )
		return;
	
	player.SpeedThink(340.0);
	player.GlowThink(0.1);
	if( player.SuperJumpThink(2.5, 25.0) ) {
		player.PlayVoiceClip(TemplateJump[GetRandomInt(0, sizeof(TemplateJump)-1)], VSH2_VOICE_ABILITY);
		player.SuperJump(player.GetPropFloat("flCharge"), -100.0);
	}
	
	if( OnlyScoutsLeft(VSH2Team_Red) )
		player.SetPropFloat("flRAGE", player.GetPropFloat("flRAGE") + g_vsh2_cvars.scout_rage_gen.FloatValue);
	
	player.WeighDownThink(2.0, 0.1);
	
	/// hud code
	SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
	Handle hud = VSH2GameMode_GetHUDHandle();
	float jmp = player.GetPropFloat("flCharge");
	float rage = player.GetPropFloat("flRAGE");
	if( rage >= 100.0 )
		ShowSyncHudText(client, hud, "Jump: %i%% | Rage: FULL - Call Medic (default: E) to activate", player.GetPropInt("bSuperCharge") ? 1000 : RoundFloat(jmp) * 4);
	else ShowSyncHudText(client, hud, "Jump: %i%% | Rage: %0.1f", player.GetPropInt("bSuperCharge") ? 1000 : RoundFloat(jmp) * 4, rage);
}

public void Template_OnBossModelTimer(const VSH2Player player)
{
	if( !IsTemplate(player) )
		return;
	int client = player.index;
	SetVariantString(TemplateModel);
	AcceptEntityInput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
}

public void Template_OnBossEquipped(const VSH2Player player)
{
	if( !IsTemplate(player) )
		return;
	
	player.SetName("Template");
	player.RemoveAllItems();
	char attribs[128]; Format(attribs, sizeof(attribs), "68; 2.0; 2; 3.1; 259; 1.0; 252; 0.6; 214; %d", GetRandomInt(999, 9999));
	int wep = player.SpawnWeapon("tf_weapon_shovel", 5, 100, 5, attribs);
	SetEntPropEnt(player.index, Prop_Send, "m_hActiveWeapon", wep);
}

public void Template_OnBossInitialized(const VSH2Player player)
{
	if( !IsTemplate(player) )
		return;
	SetEntProp(player.index, Prop_Send, "m_iClass", view_as<int>(TFClass_Soldier));
}

public void Template_OnBossPlayIntro(const VSH2Player player)
{
	if( !IsTemplate(player) )
		return;
	player.PlayVoiceClip(TemplateIntro[GetRandomInt(0, sizeof(TemplateIntro)-1)], VSH2_VOICE_INTRO);
}

public void Template_OnPlayerKilled(const VSH2Player attacker, const VSH2Player victim, Event event)
{
	if( !IsTemplate(attacker) )
		return;
	
	float curtime = GetGameTime();
	if( curtime <= attacker.GetPropFloat("flKillSpree") )
		attacker.SetPropInt("iKills", attacker.GetPropInt("iKills") + 1);
	else attacker.SetPropInt("iKills", 0);
	attacker.PlayVoiceClip(TemplateKill[GetRandomInt(0, sizeof(TemplateKill)-1)], VSH2_VOICE_SPREE);
	
	if( attacker.GetPropInt("iKills") == 3 && VSH2GameMode_GetTotalRedPlayers() != 1 ) {
		attacker.PlayVoiceClip(TemplateSpree[GetRandomInt(0, sizeof(TemplateSpree)-1)], VSH2_VOICE_SPREE);
		attacker.SetPropInt("iKills", 0);
	}
	else attacker.SetPropFloat("flKillSpree", curtime+5.0);
}

public void Template_OnPlayerHurt(const VSH2Player attacker, const VSH2Player victim, Event event)
{
	int damage = event.GetInt("damageamount");
	if( IsTemplate(victim) && victim.GetPropInt("bIsBoss") )
		victim.GiveRage(damage);
}
public void Template_OnPlayerAirblasted(const VSH2Player airblaster, const VSH2Player airblasted, Event event)
{
	if( !IsTemplate(airblasted) )
		return;
	float rage = airblasted.GetPropFloat("flRAGE");
	airblasted.SetPropFloat("flRAGE", rage + g_vsh2_cvars.airblast_rage.FloatValue);
}
public void Template_OnBossMedicCall(const VSH2Player player)
{
	if( !IsTemplate(player) || player.GetPropFloat("flRAGE") < 100.0 )
		return;
	
	player.DoGenericStun(800.0);
	VSH2Player[] players = new VSH2Player[MaxClients];
	int in_range = player.GetPlayersInRange(players, 800.0);
	for( int i; i<in_range; i++ ) {
		if( players[i].GetPropAny("bIsBoss") || players[i].GetPropAny("bIsMinion") )
			continue;
		/// do a distance based thing here.
	}
	player.PlayVoiceClip(TemplateRage[GetRandomInt(0, sizeof(TemplateRage)-1)], VSH2_VOICE_RAGE);
	player.SetPropFloat("flRAGE", 0.0);
}

public void Template_OnBossJarated(const VSH2Player victim, const VSH2Player thrower)
{
	if( !IsTemplate(victim) )
		return;
	float rage = victim.GetPropFloat("flRAGE");
	victim.SetPropFloat("flRAGE", rage - g_vsh2_cvars.jarate_rage.FloatValue);
}


public void Template_OnRoundEndInfo(const VSH2Player player, bool bossBool, char message[MAXMESSAGE])
{
	if( !IsTemplate(player) )
		return;
	else if( bossBool )
		player.PlayVoiceClip(TemplateWin[GetRandomInt(0, sizeof(TemplateWin)-1)], VSH2_VOICE_WIN);
}


public void Template_Music(char song[PLATFORM_MAX_PATH], float &time, const VSH2Player player)
{
	if( !IsTemplate(player) )
		return;
	
	int theme = GetRandomInt(0, sizeof(TemplateThemes)-1);
	Format(song, sizeof(song), "%s", TemplateThemes[theme]);
	time = TemplateThemesTime[theme];
}

public void Template_OnBossDeath(const VSH2Player player)
{
	if( !IsTemplate(player) )
		return;
	
	player.PlayVoiceClip(TemplateDeath[GetRandomInt(0, sizeof(TemplateDeath)-1)], VSH2_VOICE_LOSE);
}

public Action Template_OnStabbed(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if( !IsTemplate(victim) )
		return Plugin_Continue;
	
	victim.PlayVoiceClip(TemplateStab[GetRandomInt(0, sizeof(TemplateStab)-1)], VSH2_VOICE_STABBED);
	return Plugin_Continue;
}

public void Template_OnLastPlayer(const VSH2Player player)
{
	if( !IsTemplate(player) )
		return;
	player.PlayVoiceClip(TemplateLast[GetRandomInt(0, sizeof(TemplateLast)-1)], VSH2_VOICE_LASTGUY);
}

public Action Template_OnSoundHook(const VSH2Player player, char sample[PLATFORM_MAX_PATH], int& channel, float& volume, int& level, int& pitch, int& flags)
{
	if( !IsTemplate(player) )
		return Plugin_Continue;
	else if( IsVoiceLine(sample) )    /// this code: returning Plugin_Handled blocks the sound, a voiceline in this case.
		return Plugin_Handled;
	
	return Plugin_Continue;
}

/// Stocks =============================================
stock bool IsValidClient(const int client, bool nobots=false)
{ 
	if( client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)) )
		return false; 
	return IsClientInGame(client); 
}

stock int GetSlotFromWeapon(const int iClient, const int iWeapon)
{
	for( int i; i<5; i++ )
		if( iWeapon == GetPlayerWeaponSlot(iClient, i) )
			return i;
	
	return -1;
}

stock bool OnlyScoutsLeft(const int team)
{
	for( int i=MaxClients; i; --i ) {
		if( !IsValidClient(i) || !IsPlayerAlive(i) )
			continue;
		else if( GetClientTeam(i) == team && TF2_GetPlayerClass(i) != TFClass_Scout )
			return false;
	}
	return true;
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
	Call_StartFunction(null, pFunc);
	
	any param1 = hndl.ReadCell();
	if( param1 != -999 )
		Call_PushCell(param1);
	
	any param2 = hndl.ReadCell();
	if( param2 != -999 )
		Call_PushCell(param2);
	
	Call_Finish();
	return Plugin_Continue;
}
stock int SetWeaponClip(const int weapon, const int ammo)
{
	if( IsValidEntity(weapon) ) {
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		SetEntData(weapon, iAmmoTable, ammo, 4, true);
	}
	return 0;
}


public int HintPanel(Menu menu, MenuAction action, int param1, int param2)
{
	return;
}
