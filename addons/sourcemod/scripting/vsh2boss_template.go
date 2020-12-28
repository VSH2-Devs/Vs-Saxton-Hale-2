package main

import (
	"sourcemod"
	"sdktools"
	"sdkhooks"
	"tf2_stocks"
	"vsh2"
	"cfgmap"
)

const (
	TemplateModel = "models/templatefolder/templateboss.mdl"
	
	/// Voicelines
	TemplateIntro = [...]string{
		"template_snd/start1.mp3",
		"template_snd/start2.mp3",
	}
	TemplateJump = [...]string{
		"template_snd/jump1.mp3",
		"template_snd/jump2.mp3",
	}
	TemplateStab = [...]string{
		"template_snd/stab1.mp3",
		"template_snd/stab2.mp3",
	}
	TemplateDeath = [...]string{
		"template_snd/death1.mp3",
		"template_snd/death2.mp3",
	}
	TemplateLast = [...]string{
		"template_snd/lastguy1.mp3",
		"template_snd/lastguy2.mp3",
	}
	TemplateRage = [...]string{
		"template_snd/rage1.mp3",
		"template_snd/rage2.mp3",
	}
	TemplateKill = [...]string{
		"template_snd/kill1.mp3",
		"template_snd/kill2.mp3",
	}
	TemplateSpree = [...]string{
		"template_snd/spree1.mp3",
		"template_snd/spree2.mp3",
	}
	TemplateWin = [...]string{
		"template_snd/win1.mp3",
		"template_snd/win2.mp3",
	}
	TemplateThemes = [...]string{
		"template_snd/theme1.mp3",
		"template_snd/theme2.mp3",
	}
	TemplateThemesTime = [...]float{
		60.0,
		60.0,
	}
)

type VSH2CVars struct {
	scout_rage_gen, airblast_rage, jarate_rage ConVar
}

var (
	myinfo = Plugin{
		name:        "VSH2 Template Boss Module",
		author:      "Nergal/Assyrian",
		description: "",
		version:     "1.0",
		url:         "sus",
	}
	g_iTemplateID int
	g_vsh2_cvars VSH2CVars
	vsh2_gm VSH2GameMode
	template_boss_cfg ConfigMap
)


func OnLibraryAdded(name string) {
	if StrEqual(name, "VSH2") {
		g_vsh2_cvars.scout_rage_gen = FindConVar("vsh2_scout_rage_gen")
		g_vsh2_cvars.airblast_rage = FindConVar("vsh2_airblast_rage")
		g_vsh2_cvars.jarate_rage = FindConVar("vsh2_jarate_rage")
		g_iTemplateID = VSH2_RegisterPlugin("template_boss")
		__sp__(`template_boss_cfg = new ConfigMap("path/to/template_boss/config.cfg");`)
		LoadVSH2Hooks()
	}
}

func LoadVSH2Hooks() {
	if !VSH2_HookEx(OnCallDownloads, Template_OnCallDownloads) {
		LogError("Error loading OnCallDownloads forwards for Template subplugin.")
	}
	
	if !VSH2_HookEx(OnBossMenu, func(menu *Menu) {
		var tostr [10]char
		IntToString(g_iTemplateID, tostr, len(tostr));
		
		/// ConfigMap can be used to store the boss name.
		name_len := template_boss_cfg.GetSize("boss_name")
		name := make([]char, name_len)
		template_boss_cfg.Get("boss_name", name, name_len)
		menu.AddItem(tostr, name);
	}) {
		LogError("Error loading OnBossMenu forwards for Template subplugin.")
	}
	
	if !VSH2_HookEx(OnBossSelected, Template_OnBossSelected) {
		LogError("Error loading OnBossSelected forwards for Template subplugin.")
	}
	
	if !VSH2_HookEx(OnBossThink, Template_OnBossThink) {
		LogError("Error loading OnBossThink forwards for Template subplugin.")
	}
	
	if !VSH2_HookEx(OnBossModelTimer, func(player VSH2Player) {
		if !IsTemplate(player) {
			return
		}
		client := player.index;
		SetVariantString(TemplateModel)
		AcceptEntityInput(client, "SetCustomModel")
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1)
	}) {
		LogError("Error loading OnBossModelTimer forwards for Template subplugin.")
	}
	
	if !VSH2_HookEx(OnBossEquipped, Template_OnBossEquipped) {
		LogError("Error loading OnBossEquipped forwards for Template subplugin.")
	}
	
	if !VSH2_HookEx(OnBossInitialized, func(player VSH2Player) {
		if !IsTemplate(player) {
			return
		}
		__sp__(`SetEntProp(player.index, Prop_Send, "m_iClass", view_as< int >(TFClass_Soldier));`)
	}) {
		LogError("Error loading OnBossInitialized forwards for Template subplugin.")
	}
	
	if !VSH2_HookEx(OnBossPlayIntro, func(player VSH2Player) {
		if !IsTemplate(player) {
			return
		}
		player.PlayVoiceClip(TemplateIntro[GetRandomInt(0, len(TemplateIntro)-1)], VSH2_VOICE_INTRO);
	}) {
		LogError("Error loading OnBossPlayIntro forwards for Template subplugin.")
	}
	
	if !VSH2_HookEx(OnPlayerKilled, Template_OnPlayerKilled) {
		LogError("Error loading OnPlayerKilled forwards for Template subplugin.")
	}
	
	if !VSH2_HookEx(OnPlayerHurt, func(attacker, victim VSH2Player, event Event) {
		damage := event.GetInt("damageamount")
		if IsTemplate(victim) && victim.GetPropInt("bIsBoss") > 0 {
			victim.GiveRage(damage)
		}
	}) {
		LogError("Error loading OnPlayerHurt forwards for Template subplugin.")
	}
	
	if !VSH2_HookEx(OnPlayerAirblasted, func(airblaster, airblasted VSH2Player, event Event) {
		if !IsTemplate(airblasted) {
			return
		}
		rage := airblasted.GetPropFloat("flRAGE")
		airblasted.SetPropFloat("flRAGE", rage + g_vsh2_cvars.airblast_rage.FloatValue)
	}) {
		LogError("Error loading OnPlayerAirblasted forwards for Template subplugin.")
	}
	
	if !VSH2_HookEx(OnBossMedicCall, Template_OnBossMedicCall) {
		LogError("Error loading OnBossMedicCall forwards for Template subplugin.")
	}
	
	if !VSH2_HookEx(OnBossTaunt, Template_OnBossMedicCall) {
		LogError("Error loading OnBossTaunt forwards for Template subplugin.")
	}
	
	if !VSH2_HookEx(OnBossJarated, func(victim, thrower VSH2Player) {
		if !IsTemplate(victim) {
			return
		}
		rage := victim.GetPropFloat("flRAGE")
		victim.SetPropFloat("flRAGE", rage - g_vsh2_cvars.jarate_rage.FloatValue)
	}) {
		LogError("Error loading OnBossJarated forwards for Template subplugin.")
	}
	
	if !VSH2_HookEx(OnRoundEndInfo, func(player VSH2Player, boss_win bool, message [MAXMESSAGE]char) {
		if !IsTemplate(player) {
			return
		} else if boss_win {
			player.PlayVoiceClip(TemplateWin[GetRandomInt(0, len(TemplateWin)-1)], VSH2_VOICE_WIN)
		}
	}) {
		LogError("Error loading OnRoundEndInfo forwards for Template subplugin.")
	}
	
	if !VSH2_HookEx(OnMusic, func(song *PathStr, time *float, player VSH2Player) {
		if !IsTemplate(player) {
			return
		}
		theme := GetRandomInt(0, len(TemplateThemes)-1)
		Format(song, len(song), "%s", TemplateThemes[theme])
		*time = TemplateThemesTime[theme]
	}) {
		LogError("Error loading OnBossDealDamage forwards for Template subplugin.")
	}
	
	if !VSH2_HookEx(OnBossDeath, func(player VSH2Player) {
		if !IsTemplate(player) {
			return
		}
		player.PlayVoiceClip(TemplateDeath[GetRandomInt(0, len(TemplateDeath)-1)], VSH2_VOICE_LOSE)
	}) {
		LogError("Error loading OnBossDeath forwards for Template subplugin.")
	}
	
	if !VSH2_HookEx(OnBossTakeDamage_OnStabbed, func(victim VSH2Player, attacker, inflictor *int, damage *float, damagetype, weapon *int, damageForce, damagePosition *Vec3, damagecustom int) Action {
		if IsTemplate(victim) {
			victim.PlayVoiceClip(TemplateStab[GetRandomInt(0, len(TemplateStab)-1)], VSH2_VOICE_STABBED)
		}
		return Plugin_Continue
	}) {
		LogError("Error loading OnBossTakeDamage_OnStabbed forwards for Template subplugin.")
	}
	
	if !VSH2_HookEx(OnLastPlayer, func(player VSH2Player) {
		if !IsTemplate(player) {
			return
		}
		player.PlayVoiceClip(TemplateLast[GetRandomInt(0, len(TemplateLast)-1)], VSH2_VOICE_LASTGUY)
	}) {
		LogError("Error loading OnLastPlayer forwards for Template subplugin.")
	}
	
	if !VSH2_HookEx(OnSoundHook, func(player VSH2Player, sample PathStr, channel *int, volume *float, level, pitch, flags *int) Action {
		if !IsTemplate(player) {
			return Plugin_Continue
		} else if IsVoiceLine(sample) {
			/// this code: returning Plugin_Handled blocks the sound, a voiceline in this case.
			return Plugin_Handled
		}
		return Plugin_Continue
	}) {
		LogError("Error loading OnSoundHook forwards for Template subplugin.")
	}
}



func IsTemplate(player VSH2Player) bool {
	return player.GetPropInt("iBossType") == g_iTemplateID
}


func Template_OnCallDownloads() {
	PrepareModel(TemplateModel)
	DownloadSoundList(TemplateIntro, len(TemplateIntro))
	DownloadSoundList(TemplateJump, len(TemplateJump))
	DownloadSoundList(TemplateStab, len(TemplateStab))
	DownloadSoundList(TemplateDeath, len(TemplateDeath))
	DownloadSoundList(TemplateLast, len(TemplateLast))
	DownloadSoundList(TemplateRage, len(TemplateRage))
	DownloadSoundList(TemplateKill, len(TemplateKill))
	DownloadSoundList(TemplateSpree, len(TemplateSpree))
	DownloadSoundList(TemplateWin, len(TemplateWin))
	DownloadSoundList(TemplateThemes, len(TemplateThemes))
	
	PrepareMaterial("materials/models/template_snd/skin_red")
	PrepareMaterial("materials/models/template_snd/skin_blu")
	PrepareMaterial("materials/models/template_snd/normals")
	
	/// ConfigMap used for asset downloading.
	dl_keys := [...]string{
		"sounds",
		"models",
		"materials",
	}
	assets := template_boss_cfg.GetSection("assets")
	for i := range dl_keys {
		dl_section := assets.GetSection(dl_keys[i])
		if dl_section != nil {
			for n:=0; n < dl_section.Size; n++ {
				var index [10]char
				Format(index, len(index), "%i", n)
				path_len := dl_section.GetSize(index)
				file := make([]char, path_len)
				if dl_section.Get(index, file, path_len) > 0 {
					switch i {
						case 0:
							PrepareSound(file)
						case 1:
							PrepareModel(file)
						case 2:
							PrepareMaterial(file)
					}
				}
			}
		}
	}
}


func Template_OnBossSelected(player VSH2Player) {
	if !IsTemplate(player) {
		return
	}
	
	player.SetPropInt("iCustomProp", 0);
	player.SetPropFloat("flCustomProp", 0.0);
	player.SetPropAny("hCustomProp", player);
	
	/// ConfigMap is also useful for automating custom prop creation.
	custom_props := template_boss_cfg.GetSection("custom_props");
	for i:=0; i<custom_props.Size; i++ {
		var (
			index [10]char
			prop  PropName
		)
		IntToString(i, index, len(index))
		prop_len := template_boss_cfg.GetSize(index)
		prop_name := make([]char, prop_len)
		template_boss_cfg.Get(index, prop_name, prop_len)
		strcopy(prop, len(prop), prop_name)
		player.SetPropInt(prop, 0)
	}
	
	var panel Panel
	__sp__(`panel = new Panel();`)
	
	panel_len := template_boss_cfg.GetSize("panel_msg")
	panel_info := make([]char, panel_len)
	template_boss_cfg.Get("panel_msg", panel_info, panel_len)
	panel.SetTitle(panel_info)
	panel.DrawItem("Exit")
	panel.Send(player.index, func(menu Menu, action MenuAction, param1, param2 int) int {
		return 0;
	}, 999)
	__sp__(`delete panel;`)
}

func Template_OnBossThink(player VSH2Player) {
	client := player.index
	if !IsPlayerAlive(client) || !IsTemplate(player) {
		return
	}
	
	player.SpeedThink(340.0)
	player.GlowThink(0.1)
	if player.SuperJumpThink(2.5, 25.0) {
		player.PlayVoiceClip(TemplateJump[GetRandomInt(0, len(TemplateJump)-1)], VSH2_VOICE_ABILITY)
		player.SuperJump(player.GetPropFloat("flCharge"), -100.0)
	}
	
	if OnlyScoutsLeft(VSH2Team_Red) {
		player.SetPropFloat("flRAGE", player.GetPropFloat("flRAGE") + g_vsh2_cvars.scout_rage_gen.FloatValue)
	}
	
	player.WeighDownThink(2.0, 0.1)
	
	/// hud code
	SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255)
	hud, jmp, rage := vsh2_gm.hHUD, player.GetPropFloat("flCharge"), player.GetPropFloat("flRAGE")
	if rage >= 100.0 {
		if player.GetPropInt("bSuperCharge") > 0 {
			ShowSyncHudText(client, hud, "Jump: %i%% | Rage: FULL - Call Medic (default: E) to activate", 1000)
		} else {
			ShowSyncHudText(client, hud, "Jump: %i%% | Rage: FULL - Call Medic (default: E) to activate", RoundFloat(jmp) * 4)
		}
	} else {
		if player.GetPropInt("bSuperCharge") > 0 {
			ShowSyncHudText(client, hud, "Jump: %i%% | Rage: %0.1f", 1000, rage)
		} else {
			ShowSyncHudText(client, hud, "Jump: %i%% | Rage: %0.1f", RoundFloat(jmp) * 4, rage)
		}
	}
}

func Template_OnBossEquipped(player VSH2Player) {
	if !IsTemplate(player) {
		return
	}
	
	boss_name_len := template_boss_cfg.GetSize("boss_name")
	boss_name := make([]char, boss_name_len)
	template_boss_cfg.Get("boss_name", boss_name, boss_name_len)
	
	var name BossName
	strcopy(name, len(name), boss_name)
	player.SetName(name)
	
	player.RemoveAllItems()
	attribs_len := template_boss_cfg.GetSize("melee_attribs")
	attribs := make([]char, attribs_len)
	template_boss_cfg.Get("melee_attribs", attribs, attribs_len)
	
	//char attribs[128]; Format(attribs, len(attribs), "68; 2.0; 2; 3.1; 259; 1.0; 252; 0.6; 214; %d", GetRandomInt(999, 9999))
	wep := player.SpawnWeapon("tf_weapon_shovel", 5, 100, 5, attribs)
	SetEntPropEnt(player.index, Prop_Send, "m_hActiveWeapon", wep)
}

func Template_OnPlayerKilled(attacker, victim VSH2Player, event Event) {
	if !IsTemplate(attacker) {
		return
	}
	curtime := GetGameTime()
	if curtime <= attacker.GetPropFloat("flKillSpree") {
		attacker.SetPropInt("iKills", attacker.GetPropInt("iKills") + 1)
	} else {
		attacker.SetPropInt("iKills", 0)
	}
	attacker.PlayVoiceClip(TemplateKill[GetRandomInt(0, len(TemplateKill)-1)], VSH2_VOICE_SPREE)
	
	if attacker.GetPropInt("iKills") == 3 && vsh2_gm.iLivingReds != 1 {
		attacker.PlayVoiceClip(TemplateSpree[GetRandomInt(0, len(TemplateSpree)-1)], VSH2_VOICE_SPREE)
		attacker.SetPropInt("iKills", 0)
	} else {
		attacker.SetPropFloat("flKillSpree", curtime+5.0)
	}
}

func Template_OnBossMedicCall(player VSH2Player) {
	if !IsTemplate(player) || player.GetPropFloat("flRAGE") < 100.0 {
		return
	}
	
	/// use ConfigMap to set how large the rage radius is!
	radius := 800.0 /// in case of failure, default value!
	template_boss_cfg.GetFloat("rage_dist", &radius)
	
	player.DoGenericStun(radius)
	players := make([]VSH2Player, MaxClients)
	in_range := player.GetPlayersInRange(&players, radius)
	for i:=0; i<in_range; i++ {
		if players[i].GetPropAny("bIsBoss") || players[i].GetPropAny("bIsMinion") {
			continue
		}
		/// do a distance based thing here.
	}
	player.PlayVoiceClip(TemplateRage[GetRandomInt(0, len(TemplateRage)-1)], VSH2_VOICE_RAGE)
	player.SetPropFloat("flRAGE", 0.0)
}

/// Stocks =============================================
func IsValidClient(client Entity) bool {
	if client <= 0 || client > MaxClients || !IsClientConnected(client) || IsFakeClient(client) {
		return false
	}
	return IsClientInGame(client)
}

func GetSlotFromWeapon(client, wep Entity) int {
	for i:=0; i<5; i++ {
		if wep == GetPlayerWeaponSlot(client, i) {
			return i
		}
	}
	return -1;
}

func OnlyScoutsLeft(team int) bool {
	for i:=MaxClients; i > 0; i-- {
		if !IsValidClient(i) || !IsPlayerAlive(i) {
			continue
		} else if GetClientTeam(i) == team && TF2_GetPlayerClass(i) != TFClass_Scout {
			return false
		}
	}
	return true
}

func MakePawnTimer(fn Function, thinktime float, args []any, argc int) {
	var timer_data DataPack
	__sp__(`timer_data = new DataPack();`)
	timer_data.WriteFunction(fn)
	timer_data.WriteCell(argc)
	for i:=0; i<argc; i++ {
		timer_data.WriteCell(args[i])
	}
	
	CreateTimer(thinktime, func(timer Handle, data any) Action {
		var dp DataPack = data
		dp.Reset()
		
		fn := dp.ReadFunction()
		Call_StartFunction(nil, fn)
		
		var argc int = dp.ReadCell()
		for i:=0; i<argc; i++ {
			Call_PushCell(dp.ReadCell())
		}
		Call_Finish()
		return Plugin_Continue
	}, timer_data, TIMER_DATA_HNDL_CLOSE)
}

func SetWeaponClip(weapon, ammo int) {
	if IsValidEntity(weapon) {
		iAmmoTable := FindSendPropInfo("CTFWeaponBase", "m_iClip1", nil, nil, nil)
		SetEntData(weapon, iAmmoTable, ammo, 4, true)
	}
}