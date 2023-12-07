public void SkipBossPanelNotify(int client/*, bool newchoice = true*/) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || !IsClientValidExtra(client) || IsFakeClient(client) || IsVoteInProgress() ) {
		return;
	}
	Panel panel = new Panel();
	char temp[MAX_PANEL_MSG];
	Format(temp, sizeof(temp), "[VSH 2] %T", "be_boss_soon_panel_title", client);
	panel.SetTitle(temp);
	Format(temp, sizeof(temp), "%T", "be_boss_soon_panel_text", client);
	panel.DrawItem(temp);
	panel.Send(client, SkipHalePanelH, 30); /// in commands.sp
	delete panel;
}

public Action QueuePanelCmd(int client, int args) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	} else if( !client ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} %t", "Command is in-game only");
		return Plugin_Handled;
	}
	QueuePanel(client);
	return Plugin_Handled;
}

public Action ResetQueue(int client, int args) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	} else if( !client ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} %t", "Command is in-game only");
		return Plugin_Handled;
	}
	BasePlayer(client).iQueue = 0;
	CPrintToChat(client, "{olive}[VSH 2]{default} %t", "queue_set_0");
	return Plugin_Handled;
}


public void QueuePanel(int client) {
	Panel panel = new Panel();
	char strBossList[MAXMESSAGE];
	Format(strBossList, MAXMESSAGE, "%T", "queue_panel_title", client);
	panel.SetTitle(strBossList);
	
	BasePlayer boss = VSHGameMode.GetRandomBoss(false);
	if( boss ) {
		Format(strBossList, sizeof(strBossList), "%N - %i", boss.index, boss.iQueue);
		panel.DrawItem(strBossList);
	} else {
		panel.DrawItem("None");
	}
	
	BasePlayer[] b = new BasePlayer[MaxClients];
	VSHGameMode.GetQueue(b);
	for( int i; i < 8; i++ ) {
		if( b[i] ) {
			Format(strBossList, 128, "%N - %i", b[i].index, b[i].iQueue);
			panel.DrawItem(strBossList);
		} else {
			panel.DrawItem("-");
		}
	}
	
	Format(strBossList, 64, "%T", "queue_panel_set_0", client, BasePlayer(client).iQueue );
	panel.DrawItem(strBossList);
	panel.Send(client, QueuePanelH, 9001);
	delete panel;
}

public int QueuePanelH(Menu menu, MenuAction action, int param1, int param2) {
	if( action==MenuAction_Select && param2==10 ) {
		TurnToZeroPanel(param1);
	}
	return false;
}

public void TurnToZeroPanel(int client) {
	Panel panel = new Panel();
	char strPanel[128];
	//SetGlobalTransTarget(client);
	Format(strPanel, sizeof(strPanel), "%T", "queue_set_0_confirm", client);
	panel.SetTitle(strPanel);
	Format(strPanel, sizeof(strPanel), "%T", "Yes", client);
	panel.DrawItem(strPanel);
	Format(strPanel, sizeof(strPanel), "%T", "No", client);
	panel.DrawItem(strPanel);
	panel.Send(client, TurnToZeroPanelH, 9001);
	delete panel;
}

public int TurnToZeroPanelH(Menu menu, MenuAction action, int param1, int param2) {
	if( action==MenuAction_Select && param2==1 ) {
		BasePlayer player = BasePlayer(param1);
		if( player.iQueue ) {
			player.iQueue = 0;
			CPrintToChat(param1, "{olive}[VSH 2]{default} %t", "queue_points_reset");
			BasePlayer next = VSHGameMode.FindNextBoss();
			if( next ) {
				SkipBossPanelNotify(next.index);
			}
		}
	}
	return 0;
}

/** FINALLY THE PANEL TRAIN HAS ENDED! */
public int SkipHalePanelH(Menu menu, MenuAction action, int client, int param2) {
	/*
	if( IsValidAdmin(client, "b") ) {
		SetBossMenu(client, -1);
	} else {
		CommandSetSkill(client, -1);
	}
	*/
	return 0;
}

public Action SetNextSpecial(int client, int args) {
	if( g_vsh2.m_hCvars.Enabled.BoolValue ) {
		Menu bossmenu = new Menu(MenuHandler_PickBossSpecial);
		char temp[MAX_PANEL_MSG];
		Format(temp, sizeof(temp), "%T", "bossmenu_title", client);
		bossmenu.SetTitle(temp);
		Format(temp, sizeof(temp), "%T", "bossmenu_none", client);
		bossmenu.AddItem("-1", temp);
		ManageMenu(bossmenu, client); /// in handler.sp
		bossmenu.Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}

public int MenuHandler_PickBossSpecial(Menu menu, MenuAction action, int client, int select) {
	char bossname[MAX_BOSS_NAME_SIZE];
	char info1[16]; menu.GetItem(select, info1, sizeof(info1), _, bossname, sizeof(bossname));
	if( action == MenuAction_Select ) {
		g_vshgm.iSpecial = StringToInt(info1);
		CPrintToChat(client, "{olive}[VSH 2]{default} %t", "bossmenu_pick_boss_special", bossname);
	} else if( action == MenuAction_End ) {
		delete menu;
	}
	return 0;
}


public Action ChangeHealthBarColor(int client, int args) {
	if( g_vsh2.m_hCvars.Enabled.BoolValue ) {
		char number[4]; GetCmdArg( 1, number, sizeof(number) );
		int type = StringToInt(number);
		g_vshgm.iHealthBar.iState = type;
		PrintToChat(client, "iHealthBar.iState = %i", g_vshgm.iHealthBar.iState);
	}
	return Plugin_Handled;
}

public Action Command_GetHPCmd(int client, int args) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	} else if( g_vshgm.iRoundState != StateRunning ) {
		return Plugin_Handled;
	}
	BasePlayer player = BasePlayer(client);
	ManageBossCheckHealth(player);    /// in handler.sp
	return Plugin_Handled;
}

public Action CommandBossSelect(int client, int args) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	} else if( args < 1 ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} Usage: boss_select <target>");
		return Plugin_Handled;
	}
	
	char targetname[MAX_NAME_LENGTH]; GetCmdArg(1, targetname, sizeof(targetname));
	if( !strcmp(targetname, "@me", false) && IsClientValidExtra(client) ) {
		g_vshgm.hNextBoss = BasePlayer(client);
		CReplyToCommand(client, "{olive}[VSH 2]{default} %t", "command_boss_select_yourself");
	} else {
		int target = FindTarget(client, targetname);
		if( IsClientValidExtra(target) ) {
			g_vshgm.hNextBoss = BasePlayer(target);
			CReplyToCommand(client, "{olive}[VSH 2]{default} %t", "command_boss_select_someone", g_vshgm.hNextBoss.index);
		} else {
			g_vshgm.hNextBoss = view_as< BasePlayer >(0);
		}
	}
	return Plugin_Handled;
}

public Action SetBossMenu(int client, int args) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	} else if( client==0 ) {
		CReplyToCommand(client, "[VSH 2] %T", "command_boss_select_ingame_only", client);
		return Plugin_Handled;
	}
	Menu bossmenu = new Menu(MenuHandler_PickBosses);
	char temp[MAX_PANEL_MSG], bossname[MAX_BOSS_NAME_SIZE];
	BasePlayer player = BasePlayer(client);
	Format(temp, sizeof(temp), "%T", "bossmenu_none", client);
	bossmenu.AddItem("-1", temp);
	ManageMenu(bossmenu, client); /// in handler.sp
	char info1[16]; bossmenu.GetItem(player.iPresetType+1, info1, sizeof(info1), _, bossname, sizeof(bossname));	//Get menu item base on iPresetType.
	Format(temp, sizeof(temp), "%T", "set_boss_menu_title", client, client);
	bossmenu.SetTitle(temp);
	bossmenu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int MenuHandler_PickBosses(Menu menu, MenuAction action, int client, int select) {
	char bossname[MAX_BOSS_NAME_SIZE];
	char info1[16]; menu.GetItem(select, info1, sizeof(info1), _, bossname, sizeof(bossname));
	if( action==MenuAction_Select ) {
		BasePlayer player = BasePlayer(client);
		player.iPresetType = StringToInt(info1);
		CPrintToChat(client, "{olive}[VSH 2]{default} %t", "bossmenu_pick_boss", bossname);
		ManageBossHelp(player);
	} else if( action==MenuAction_End ) {
		delete menu;
	}
	return 0;
}

public Action MusicTogglePanelCmd(int client, int args) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	}
	MusicTogglePanel(client);
	return Plugin_Handled;
}

public void MusicTogglePanel(int client) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || !IsClientValidExtra(client) ) {
		return;
	}
	Panel panel = new Panel();
	char title[MAX_PANEL_MSG], option[16];
	Format(title, sizeof(title), "%T", "music_panel_title", client);
	panel.SetTitle(title);
	
	Format(option, sizeof(option), "%T?", "music_turn_on", client);
	panel.DrawItem(option);
	Format(option, sizeof(option), "%T?", "music_turn_off", client);
	panel.DrawItem(option);
	panel.Send(client, MusicTogglePanelH, 9001);
	delete panel;
}

public int MusicTogglePanelH(Menu menu, MenuAction action, int param1, int param2) {
	if( IsClientValidExtra(param1) ) {
		if( action == MenuAction_Select ) {
			BasePlayer player = BasePlayer(param1);
			if( param2 == 1 ) {
				player.bNoMusic = false;
				CPrintToChat(param1, "{olive}[VSH 2]{default} %t", "music_on");
			} else {
				player.bNoMusic = true;
				CPrintToChat(param1, "{olive}[VSH 2]{default} %t", "music_off");
				BasePlayer(param1).StopMusic();
			}
		}
	}
	return 0;
}

public Action ForceBossRealtime(int client, int args) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	}
	
	if( !client ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} %t", "Command is in-game only");
		return Plugin_Handled;
	} else if( args < 2 ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} Usage: boss_force <target> <boss id>");
		return Plugin_Handled;
	} else if( g_vshgm.iRoundState > StateStarting ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} %t", "force_cant_after_round_started");
		return Plugin_Handled;
	}
	
	char targetname[MAX_NAME_LENGTH]; GetCmdArg(1, targetname, sizeof(targetname));
	char strBossid[32];               GetCmdArg(2, strBossid, sizeof(strBossid));
	int bosstype = StringToInt(strBossid);
	if( bosstype > g_vshgm.MAXBOSS ) {
		bosstype = g_vshgm.MAXBOSS;
	} else if( bosstype < 0 ) {
		bosstype = GetRandomInt(VSH2Boss_Hale, g_vshgm.MAXBOSS);
	}
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	if( (target_count = ProcessTargetString(
		targetname,
		client,
		target_list,
		MAXPLAYERS,
		0,
		target_name,
		sizeof(target_name),
		tn_is_ml)) <= 0 ) {
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for( int i=0; i < target_count; i++ ) {
		if( !IsClientInGame(target_list[i]) ) {
			continue;
		}
		BasePlayer player = BasePlayer(target_list[i]);
		player.MakeBossAndSwitch(bosstype, true);
		CPrintToChat(player.index, "{olive}[VSH 2]{orange} %t", "force_player_notify");
	}
	CReplyToCommand(client, "{olive}[VSH 2]{default} %t", "force_admin_forced", target_name);
	return Plugin_Handled;
}

public Action CommandAddPoints(int client, int args) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	}
	
	if( args < 2 ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} %t", "addpoints_usage");
		return Plugin_Handled;
	}
	char targetname[MAX_NAME_LENGTH]; GetCmdArg(1, targetname, sizeof(targetname));
	char s2[32];                      GetCmdArg(2, s2, sizeof(s2));
	int points = StringToInt(s2);
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	if( (target_count = ProcessTargetString(
		targetname,
		client,
		target_list,
		MAXPLAYERS,
		0,
		target_name,
		sizeof(target_name),
		tn_is_ml)) <= 0 ) {
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for( int i=0; i < target_count; i++ ) {
		if( IsClientInGame(target_list[i]) ) {
			BasePlayer player = BasePlayer(target_list[i]);
			player.iQueue += points;
			LogAction(client, target_list[i], "\"%L\" added %d VSH2 queue points to \"%L\"", client, points, target_list[i]);
		}
	}
	CReplyToCommand(client, "{olive}[VSH 2]{default} %t", "addpoints_added", points, target_name);
	return Plugin_Handled;
}

public Action CommandSetPoints(int client, int args) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	}
	
	if( args < 2 ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} %t", "setpoints_usage");
		return Plugin_Handled;
	}
	char targetname[MAX_NAME_LENGTH]; GetCmdArg(1, targetname, sizeof(targetname));
	char s2[32]; GetCmdArg(2, s2, sizeof(s2));
	int points = StringToInt(s2);
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	if( (target_count = ProcessTargetString( targetname, client, target_list, MAXPLAYERS, 0, target_name, sizeof(target_name), tn_is_ml)) <= 0 ) {
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for( int i=0; i < target_count; i++ ) {
		if( IsClientInGame(target_list[i]) ) {
			BasePlayer player = BasePlayer(target_list[i]);
			player.iQueue = points;
			LogAction(client, target_list[i], "\"%L\" set %d VSH2 queue points to \"%L\"", client, points, target_list[i]);
		}
	}
	CReplyToCommand(client, "{olive}[VSH 2]{default} %t", "setpoints_added", points, target_name);
	return Plugin_Handled;
}

public Action HelpPanelCmd(int client, int args) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	} else if( !client ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} %t", "Command is in-game only");
		return Plugin_Handled;
	}
	//char strHelp[MAXMESSAGE];
	//Format(strHelp, MAXMESSAGE, "Welcome to VS Saxton Hale Mode Version 2!\nOne or more players is selected each round to become a Boss.\nEveryone else must kill them!");
	Menu help = new Menu(HelpMenuHandler);
	char Text[MAX_PANEL_MSG];
	Format(Text, sizeof(Text), "%T", "helpmenu_title", client);
	help.SetTitle(Text);
	Format(Text, sizeof(Text), "%T", "helpmenu_halehp", client);
	help.AddItem("-1", Text);
	Format(Text, sizeof(Text), "%T", "helpmenu_showclass", client);
	help.AddItem("-1", Text);
	Format(Text, sizeof(Text), "%T", "helpmenu_halenext", client);
	help.AddItem("-1", Text);
	Format(Text, sizeof(Text), "%T", "helpmenu_resetq", client);
	help.AddItem("-1", Text);
	Format(Text, sizeof(Text), "%T", "helpmenu_setboss", client);
	help.AddItem("-1", Text);
	Format(Text, sizeof(Text), "%T", "helpmenu_halemusic", client);
	help.AddItem("-1", Text);
	Format(Text, sizeof(Text), "%T", "helpmenu_halemusic", client);
	help.AddItem("-1", Text);
	Call_OnHelpMenu(BasePlayer(client), help);
	help.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int HelpMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
	if( action==MenuAction_Select ) {
		BasePlayer player = BasePlayer(param1);
		switch( param2+1 ) {
			case 1: {
				if( g_vshgm.iRoundState==StateRunning ) {
					ManageBossCheckHealth(player);
				} else {
					CPrintToChat(param1, "{olive}[VSH 2]{default} %t", "helpmenu_no_active_bosses");
				}
			}
			case 2: {
				if( player.bIsBoss ) {
					ManageBossHelp(player);
				} else if( !player.bIsMinion && GetClientTeam(param1)==VSH2Team_Red ) {
					player.HelpPanelClass();
				}
			}
			case 3:  QueuePanel(param1);
			case 4:  TurnToZeroPanel(param1);
			case 5:  SetBossMenu(param1, -1);
			case 6:  MusicTogglePanelCmd(param1, -1);
			case 7:  BePartnerMenu(param1, -1);
			default: Call_OnHelpMenuSelect(player, menu, param2);
		}
	} else if( action==MenuAction_End ) {
		delete menu;
	}
	return 0;
}

public Action MenuDoClassRush(int client, int args) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	} else if( !client ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} %t", "Command is in-game only");
		return Plugin_Handled;
	}
	
	Menu rush = new Menu(MenuHandler_ClassRush);
	char menu_title[MAX_PANEL_MSG], menu_classname[64];
	Format(menu_title, sizeof(menu_title), "%T", "classrushmenu_title", client);
	rush.SetTitle(menu_title);
	Format(menu_classname, sizeof(menu_classname), "%T", "scout", client);
	rush.AddItem("1", menu_classname);
	Format(menu_classname, sizeof(menu_classname), "%T", "sniper", client);
	rush.AddItem("2", menu_classname);
	Format(menu_classname, sizeof(menu_classname), "%T", "soldier", client);
	rush.AddItem("3", menu_classname);
	Format(menu_classname, sizeof(menu_classname), "%T", "demoman", client);
	rush.AddItem("4", menu_classname);
	Format(menu_classname, sizeof(menu_classname), "%T", "medic", client);
	rush.AddItem("5", menu_classname);
	Format(menu_classname, sizeof(menu_classname), "%T", "heavy", client);
	rush.AddItem("6", menu_classname);
	Format(menu_classname, sizeof(menu_classname), "%T", "pyro", client);
	rush.AddItem("7", menu_classname);
	Format(menu_classname, sizeof(menu_classname), "%T", "spy", client);
	rush.AddItem("8", menu_classname);
	Format(menu_classname, sizeof(menu_classname), "%T", "engineer", client);
	rush.AddItem("9", menu_classname);
	//rush.ExitBackButton = true;
	rush.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int MenuHandler_ClassRush(Menu menu, MenuAction action, int client, int pick) {
	char classname[64];
	char info[10]; menu.GetItem(pick, info, sizeof(info), _, classname, sizeof(classname));
	if( action==MenuAction_Select ) {
		int classtype = StringToInt(info);
		for( int i=1; i<=MaxClients; i++ ) {
			if( !IsClientValidExtra(i) || GetClientTeam(i) != VSH2Team_Red || !IsPlayerAlive(i) ) {
				continue;
			}
			SetEntProp(i, Prop_Send, "m_iClass", classtype);
			TF2_RegeneratePlayer(i);
			SetPawnTimer(PrepPlayers, 0.2, BasePlayer(i));
			CPrintToChat(i, "{olive}[VSH 2]{default} %t", "classrushmenu_force_notify", classname);
		}
		CPrintToChat(client, "{olive}[VSH 2]{default} %t", "classrushmenu_forced", classname);
	} else if( action == MenuAction_End ) {
		delete menu;
	}
	return 0;
}

public Action CmdAbility(int client, int args) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	} else if( !client ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} %t", "Command is in-game only");
		return Plugin_Handled;
	} else if( args < 3 ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} %t", "abilitycmd_usage");
		return Plugin_Handled;
	}
	
	char targetname[MAX_NAME_LENGTH];   GetCmdArg(1, targetname,   sizeof(targetname));
	char ability_name[MAX_NAME_LENGTH]; GetCmdArg(2, ability_name, sizeof(ability_name));
	char option[3];                     GetCmdArg(3, option,       sizeof(option));
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS];
	bool tn_is_ml;
	int target_count = ProcessTargetString(targetname, client, target_list, MAXPLAYERS, 0, target_name, sizeof(target_name), tn_is_ml);
	if( target_count <= 0 ) {
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for( int i; i < target_count; i++ ) {
		if( IsClientInGame(target_list[i]) ) {
			BasePlayer player = BasePlayer(target_list[i]);
			switch( option[0] ) {
				case '+': player.GiveAbility(ability_name);
				case '-': player.RemoveAbility(ability_name);
				case '0': player.RemoveAllAbilities();
			}
		}
	}
	return Plugin_Handled;
}

/*
public Action ResetBossCookie(int client, int args) {
	if( !client ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} %T.", "command_boss_select_ingame_only", client);
		return Plugin_Handled;
	}
	
	BasePlayer player = BasePlayer(client);
	int old_cookie = player.iPresetType;
	player.iPresetType = -1;
	CReplyToCommand(client, "{olive}[VSH 2]{default} %T.", "boss_cookie_reset", client, old_cookie);
	return Plugin_Handled;
}
*/

public Action BePartnerMenu(int client, int args) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue ) {
		return Plugin_Continue;
	}
	BoPartnerTogglePanel(client);
	return Plugin_Handled;
}

public void BoPartnerTogglePanel(int client) {
	if( !g_vsh2.m_hCvars.Enabled.BoolValue || !IsClientValidExtra(client) ) {
		return;
	}
	
	Panel panel = new Panel();
	char title[MAX_PANEL_MSG], option[64];
	Format(title, sizeof(title), "%T", "be_partner_panel_title", client);
	panel.SetTitle(title);
	
	Format(option, sizeof(option), "%T?", "be_partner_turn_on", client);
	panel.DrawItem(option);
	Format(option, sizeof(option), "%T?", "be_partner_turn_off", client);
	panel.DrawItem(option);
	panel.Send(client, BoPartnerTogglePanelH, 9001);
	delete panel;
}

public int BoPartnerTogglePanelH(Menu menu, MenuAction action, int param1, int param2) {
	if( IsClientValidExtra(param1) && action==MenuAction_Select ) {
		BasePlayer player = BasePlayer(param1);
		player.bCanBossPartner = param2==1;
	}
	return 0;
}

public Action CmdReloadCFG(int client, int args) {
	if( g_vsh2.m_hCfg==null ) {
		return Plugin_Handled;
	} else if( g_vsh2.m_hCfg.CfgFileChanged() ) {
		ReloadCfg(g_vsh2.m_hCfg);
	}
	
	if( g_vsh2.m_hCfg==null ) {
		CReplyToCommand(client, "{olive}[VSH 2] ERROR{default} :: %t", "cant_find_vsh2cfg");
	} else {
		CReplyToCommand(client, "{olive}[VSH 2]{default} %t", "vsh2_config_reloaded");
	}
	return Plugin_Handled;
}