public Action QueuePanelCmd(int client, int args)
{
	if( !g_vsh2.m_hCvars[Enabled].BoolValue )
		return Plugin_Continue;
	else if( !client ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} You can only use this command ingame.");
		return Plugin_Handled;
	}
	QueuePanel(client);
	return Plugin_Handled;
}

public Action ResetQueue(int client, int args)
{
	if( !g_vsh2.m_hCvars[Enabled].BoolValue )
		return Plugin_Continue;
	else if( !client ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} You can only use this command ingame.");
		return Plugin_Handled;
	}
	BaseBoss(client).iQueue = 0;
	CPrintToChat(client, "{olive}[VSH 2]{default} Your Queue has been set to 0!");
	return Plugin_Handled;
}


public void QueuePanel(const int client)
{
	Panel panel = new Panel();
	char strBossList[MAXMESSAGE];
	Format(strBossList, MAXMESSAGE, "VSH2 Boss Queue:");
	panel.SetTitle(strBossList);
	
	BaseBoss Boss = gamemode.GetRandomBoss(false);
	if( Boss ) {
		Format(strBossList, sizeof(strBossList), "%N - %i", Boss.index, Boss.iQueue);
		panel.DrawItem(strBossList);
	}
	else panel.DrawItem("None");
	
	for( int i=0; i<8; ++i ) {
		Boss = gamemode.FindNextBoss();	/// Using Boss to look at the next boss
		if( Boss ) {
			Format(strBossList, 128, "%N - %i", Boss.index, Boss.iQueue);
			panel.DrawItem(strBossList);
			
			/// This will have VSHGameMode::FindNextBoss() skip this guy when looping again
			Boss.bSetOnSpawn = true;
		}
		else panel.DrawItem("-");
	}
	
	/// Ughhh, reset shit...
	for( int n=MaxClients; n; --n ) {
		if( !IsValidClient(n) )
			continue;
		Boss = BaseBoss(n);
		if( !Boss.bIsBoss )
			Boss.bSetOnSpawn = false;
	}
	
	Format(strBossList, 64, "Your queue points: %i (select to set to 0)", BaseBoss(client).iQueue );
	panel.DrawItem(strBossList);
	panel.Send(client, QueuePanelH, 9001);
	delete panel;
}
public int QueuePanelH(Menu menu, MenuAction action, int param1, int param2)
{
	if( action==MenuAction_Select && param2==10 )
		TurnToZeroPanel(param1);
	return false;
}
public void TurnToZeroPanel(const int client)
{
	Panel panel = new Panel();
	char strPanel[128];
	//SetGlobalTransTarget(client);
	Format(strPanel, 128, "Are you sure you want to set your queue points to 0?");
	panel.SetTitle(strPanel);
	Format(strPanel, 128, "YES");
	panel.DrawItem(strPanel);
	Format(strPanel, 128, "NO");
	panel.DrawItem(strPanel);
	panel.Send(client, TurnToZeroPanelH, 9001);
	delete panel;
}
public int TurnToZeroPanelH(Menu menu, MenuAction action, int param1, int param2)
{
	if( action==MenuAction_Select && param2==1 ) {
		BaseBoss player = BaseBoss(param1);
		if( player.iQueue ) {
			player.iQueue = 0;
			CPrintToChat(param1, "{olive}[VSH 2]{default} You have reset your queue points to {olive}0{default}");
			BaseBoss nextBoss = gamemode.FindNextBoss(); //int cl = FindNextHaleEx();
			if( nextBoss )
				SkipBossPanelNotify(nextBoss.index);
		}
	}
}

/** FINALLY THE PANEL TRAIN HAS ENDED! */
public int SkipHalePanelH(Menu menu, MenuAction action, int client, int param2)
{
	/*
	if( IsValidAdmin(client, "b") )
		SetBossMenu(client, -1);
	else CommandSetSkill(client, -1);
	*/
}

public Action SetNextSpecial(int client, int args)
{
	if( g_vsh2.m_hCvars[Enabled].BoolValue ) {
		Menu bossmenu = new Menu(MenuHandler_PickBossSpecial);
		bossmenu.SetTitle("Set Next Boss Type Menu: ");
		bossmenu.AddItem("-1", "None (Random Boss)");
		ManageMenu(bossmenu); /// in handler.sp
		bossmenu.Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}

public int MenuHandler_PickBossSpecial(Menu menu, MenuAction action, int client, int select)
{
	char bossname[MAX_BOSS_NAME_SIZE];
	char info1[16]; menu.GetItem(select, info1, sizeof(info1), _, bossname, sizeof(bossname));
	if( action == MenuAction_Select ) {
		gamemode.iSpecial = StringToInt(info1);
		CPrintToChat(client, "{olive}[VSH 2]{default} Next Boss will be {olive}%s{default}!", bossname);
	}
	else if( action == MenuAction_End )
		delete menu;
}


public Action ChangeHealthBarColor(int client, int args)
{
	if( g_vsh2.m_hCvars[Enabled].BoolValue ) {
		char number[4]; GetCmdArg( 1, number, sizeof(number) );
		int type = StringToInt(number);
		gamemode.iHealthBarState = type;
		PrintToChat(client, "iHealthBarState = %i", gamemode.iHealthBarState);
	}
	return Plugin_Handled;
}

public Action Command_GetHPCmd(int client, int args)
{
	if( !g_vsh2.m_hCvars[Enabled].BoolValue )
		return Plugin_Continue;
	else if( gamemode.iRoundState != StateRunning )
		return Plugin_Handled;
	
	BaseBoss player = BaseBoss(client);
	ManageBossCheckHealth(player);    /// in handler.sp
	return Plugin_Handled;
}
public Action CommandBossSelect(int client, int args)
{
	if( !g_vsh2.m_hCvars[Enabled].BoolValue )
		return Plugin_Continue;
	else if( args < 1 ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} Usage: boss_select <target>");
		return Plugin_Handled;
	}
	char targetname[32]; GetCmdArg(1, targetname, sizeof(targetname));
	if( !strcmp(targetname, "@me", false) && IsValidClient(client) ) {
		gamemode.hNextBoss = BaseBoss(client);
		CReplyToCommand(client, "{olive}[VSH 2]{default} You've set yourself as the next Boss!");
	} else {
		int target = FindTarget(client, targetname);
		if( IsValidClient(target) ) {
			gamemode.hNextBoss = BaseBoss(target);
			CReplyToCommand(client, "{olive}[VSH 2]{default} %N is set as next Boss!", gamemode.hNextBoss.index);
		}
		else gamemode.hNextBoss = view_as< BaseBoss >(0);
	}
	return Plugin_Handled;
}
public Action SetBossMenu(int client, int args)
{
	if( !g_vsh2.m_hCvars[Enabled].BoolValue )
		return Plugin_Continue;
	
	Menu bossmenu = new Menu(MenuHandler_PickBosses);
	bossmenu.SetTitle("Set Boss Menu: ");
	bossmenu.AddItem("-1", "None (Random Boss)");
	ManageMenu(bossmenu); /// in handler.sp
	bossmenu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int MenuHandler_PickBosses(Menu menu, MenuAction action, int client, int select)
{
	char bossname[MAX_BOSS_NAME_SIZE];
	char info1[16]; menu.GetItem(select, info1, sizeof(info1), _, bossname, sizeof(bossname));
	if( action == MenuAction_Select ) {
		BaseBoss player = BaseBoss(client);
		player.iPresetType = StringToInt(info1);
		CPrintToChat(client, "{olive}[VSH 2]{default} Your boss is set to {olive}%s{default}!", bossname);
	} else if( action == MenuAction_End )
		delete menu;
}

public Action MusicTogglePanelCmd(int client, int args)
{
	if( !g_vsh2.m_hCvars[Enabled].BoolValue )
		return Plugin_Continue;
	MusicTogglePanel(client);
	return Plugin_Handled;
}
public void MusicTogglePanel(const int client)
{
	if( !g_vsh2.m_hCvars[Enabled].BoolValue || !IsValidClient(client) )
		return;
	Panel panel = new Panel();
	panel.SetTitle("Turn the VS Saxton Hale 2 Music...");
	panel.DrawItem("On?");
	panel.DrawItem("Off?");
	panel.Send(client, MusicTogglePanelH, 9001);
	delete panel;
}
public int MusicTogglePanelH(Menu menu, MenuAction action, int param1, int param2)
{
	if( IsValidClient(param1) ) {
		if( action == MenuAction_Select ) {
			BaseBoss player = BaseBoss(param1);
			if( param2 == 1 ) {
				player.bNoMusic = false;
				CPrintToChat(param1, "{olive}[VSH 2]{default} You've turned On the VS Saxton Hale 2 Music.");
			} else {
				player.bNoMusic = true;
				CPrintToChat(param1, "{olive}[VSH 2]{default} You've turned Off the VS Saxton Hale 2 Music.");
				BaseBoss(param1).StopMusic();
			}
		}
	}
}

public Action ForceBossRealtime(int client, int args)
{
	if( !g_vsh2.m_hCvars[Enabled].BoolValue )
		return Plugin_Continue;
	
	if( !client ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} You can only use this command ingame.");
		return Plugin_Handled;
	} else if( args < 2 ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} Usage: boss_force <target> <boss id>");
		return Plugin_Handled;
	} else if( gamemode.iRoundState > StateStarting ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} You can't force a boss after a round started...");
		return Plugin_Handled;
	}
	
	char targetname[32]; GetCmdArg(1, targetname, sizeof(targetname));
	char strBossid[32]; GetCmdArg(2, strBossid, sizeof(strBossid));
	
	int bosstype = StringToInt(strBossid);
	if( bosstype > MAXBOSS )
		bosstype = MAXBOSS;
	else if( bosstype < 0 )
		bosstype = GetRandomInt(VSH2Boss_Hale, MAXBOSS);
	
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
		tn_is_ml)) <= 0 )
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	BaseBoss player;
	for( int i=0; i<target_count; i++ ) {
		if( IsClientInGame(target_list[i]) ) {
			player = BaseBoss(target_list[i]);
			player.MakeBossAndSwitch(bosstype, true);
			CPrintToChat(player.index, "{olive}[VSH 2]{orange} an Admin has forced you to be a Boss!");
		}
	}
	CReplyToCommand(client, "{olive}[VSH 2]{default} Forced %s as a Boss", target_name);
	return Plugin_Handled;
}

public Action CommandAddPoints(int client, int args)
{
	if( !g_vsh2.m_hCvars[Enabled].BoolValue )
		return Plugin_Continue;
	
	if( args < 2 ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} Usage: hale_addpoints <target> <points>");
		return Plugin_Handled;
	}
	char targetname[32];	GetCmdArg(1, targetname, sizeof(targetname));
	char s2[32];		GetCmdArg(2, s2, sizeof(s2));
	
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
		tn_is_ml)) <= 0 )
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	BaseBoss player;
	for( int i=0; i<target_count; i++ ) {
		if( IsClientInGame(target_list[i]) ) {
			player = BaseBoss(target_list[i]);
			player.iQueue += points;
			LogAction(client, target_list[i], "\"%L\" added %d VSH2 queue points to \"%L\"", client, points, target_list[i]);
		}
	}
	CReplyToCommand(client, "{olive}[VSH 2]{default} Added %d queue points to %s", points, target_name);
	return Plugin_Handled;
}

public Action CommandSetPoints(int client, int args)
{
	if( !g_vsh2.m_hCvars[Enabled].BoolValue )
		return Plugin_Continue;
	
	if( args < 2 ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} Usage: hale_setpoints <target> <points>");
		return Plugin_Handled;
	}
	char targetname[32]; GetCmdArg(1, targetname, sizeof(targetname));
	char s2[32]; GetCmdArg(2, s2, sizeof(s2));
	int points = StringToInt(s2);
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if( (target_count = ProcessTargetString( targetname, client, target_list, MAXPLAYERS, 0, target_name, sizeof(target_name), tn_is_ml)) <= 0 ) {
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	BaseBoss player;
	for( int i=0; i<target_count; i++ ) {
		if( IsClientInGame(target_list[i]) ) {
			player = BaseBoss(target_list[i]);
			player.iQueue = points;
			LogAction(client, target_list[i], "\"%L\" set %d VSH2 queue points to \"%L\"", client, points, target_list[i]);
		}
	}
	CReplyToCommand(client, "{olive}[VSH 2]{default} Added %d queue points to %s", points, target_name);
	return Plugin_Handled;
}

public Action HelpPanelCmd(int client, int args)
{
	if( !g_vsh2.m_hCvars[Enabled].BoolValue )
		return Plugin_Continue;
	else if( !client ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} You can only use this command ingame.");
		return Plugin_Handled;
	}
	//char strHelp[MAXMESSAGE];
	//Format(strHelp, MAXMESSAGE, "Welcome to VS Saxton Hale Mode Version 2!\nOne or more players is selected each round to become a Boss.\nEveryone else must kill them!");
	Panel panel = new Panel();
	panel.SetTitle("What do you want, sir?");
	panel.DrawItem("Show Boss health. (/halehp)");
	panel.DrawItem("Show help about my class.");
	panel.DrawItem("Who is the next Boss? (/halenext)");
	panel.DrawItem("Reset my Queue Points. (/resetq)");
	panel.DrawItem("Set My Preferred Boss. (/setboss)");
	panel.DrawItem("Turn Off/On the Background Music. (/halemusic)");
	panel.Send(client, HelpPanelH, 9001);
	delete panel;
	return Plugin_Handled;
}
public int HelpPanelH(Menu menu, MenuAction action, int param1, int param2)
{
	if( action == MenuAction_Select ) {
		switch( param2 ) {
			case 1: {
				if( gamemode.iRoundState == StateRunning ) {
					BaseBoss player = BaseBoss(param1);
					ManageBossCheckHealth(player);
				}
				else CPrintToChat(param1, "{olive}[VSH 2]{default} There are no active bosses...");
			}
			case 2: {
				BaseBoss player = BaseBoss(param1);
				if( player.bIsBoss )
					ManageBossHelp(player);
				else if( !player.bIsMinion && GetClientTeam(param1)==VSH2Team_Red )
					player.HelpPanelClass();
			}
			case 3: QueuePanel(param1);
			case 4: TurnToZeroPanel(param1);
			case 5: SetBossMenu(param1, -1);
			case 6: MusicTogglePanelCmd(param1, -1);
		}
	}
}

public Action MenuDoClassRush(int client, int args)
{
	if( !g_vsh2.m_hCvars[Enabled].BoolValue )
		return Plugin_Continue;
	else if( !client ) {
		CReplyToCommand(client, "{olive}[VSH 2]{default} You can only use this command ingame.");
		return Plugin_Handled;
	}
	
	Menu rush = new Menu(MenuHandler_ClassRush);
	rush.SetTitle("VSH2 Class Rush Menu");
	rush.AddItem("1", "**** Scout ****");
	rush.AddItem("2", "**** Sniper ****");
	rush.AddItem("3", "**** Soldier ****");
	rush.AddItem("4", "**** Demoman ****");
	rush.AddItem("5", "**** Medic ****");
	rush.AddItem("6", "**** Heavy ****");
	rush.AddItem("7", "**** Pyro ****");
	rush.AddItem("8", "**** Spy ****");
	rush.AddItem("9", "**** Engineer ****");
	//rush.ExitBackButton = true;
	rush.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int MenuHandler_ClassRush(Menu menu, MenuAction action, int client, int pick)
{
	char classname[64];
	char info[10]; menu.GetItem(pick, info, sizeof(info), _, classname, sizeof(classname));
	if( action == MenuAction_Select ) {
		int classtype = StringToInt(info);
		for( int i=MaxClients; i; --i ) {
			if( !IsValidClient(i) || GetClientTeam(i) != VSH2Team_Red || !IsPlayerAlive(i) )
				continue;
			SetEntProp(i, Prop_Send, "m_iClass", classtype);
			TF2_RegeneratePlayer(i);
			SetPawnTimer(PrepPlayers, 0.2, BaseBoss(i));
			CPrintToChat(i, "{olive}[VSH 2]{default} You've been forced to {orange}%s{default}.", classname);
		}
		CPrintToChat(client, "{olive}[VSH 2]{default} Forced everybody to {orange}%s{default}.", classname);
	}
	else if( action == MenuAction_End )
		delete menu;
}
