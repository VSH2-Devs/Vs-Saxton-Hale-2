public Action QueuePanelCmd(int client, int args)
{
	if (not bEnabled.BoolValue)
		return Plugin_Continue;

	if (!client) {
		ReplyToCommand(client, "[VSH 2] You can only use this command ingame.");
		return Plugin_Handled;
	}
	QueuePanel(client);
	return Plugin_Handled;
}

public Action ResetQueue(int client, int args)
{
	if( !bEnabled.BoolValue )
		return Plugin_Continue;
	if( !client ) {
		ReplyToCommand(client, "[VSH 2] You can only use this command ingame.");
		return Plugin_Handled;
	}
	BaseBoss(client).iQueue = 0;
	CPrintToChat(client, "{olive}[VSH 2]{default} Your Queue has been set to 0!");
	return Plugin_Handled;
}

public void QueuePanel(const int client)
{
	Panel panel = new Panel();
	char strBossList[512];
	Format(strBossList, 512, "VSH2 Boss Queue:");
	panel.SetTitle(strBossList);

	BaseBoss Boss = gamemode.GetRandomBoss(false);
	if (Boss) {
		Format(strBossList, sizeof(strBossList), "%N - %i", Boss.index, Boss.iQueue);
		panel.DrawItem(strBossList);
	}
	else panel.DrawItem("None");

	for (int i=0; i<8; ++i) {
		Boss = gamemode.FindNextBoss();	// Using Boss to look at the next boss
		if (Boss) {
			Format(strBossList, 128, "%N - %i", Boss.index, Boss.iQueue);
			panel.DrawItem(strBossList);
			Boss.bSetOnSpawn = true;	// This will have VSHGameMode::FindNextBoss() skip this guy when looping again
		}
		else panel.DrawItem("-");
	}
	
	for (int n=MaxClients ; n ; --n) {	// Ughhh, reset shit...
		if (not IsValidClient(n))
			continue;
		Boss = BaseBoss(n);
		if (not Boss.bIsBoss)
			Boss.bSetOnSpawn = false;
	}

	Format(strBossList, 64, "Your queue points: %i (select to set to 0)", BaseBoss(client).iQueue );
	panel.DrawItem(strBossList);
	panel.Send(client, QueuePanelH, 9001);
	delete (panel);
}
public int QueuePanelH(Menu menu, MenuAction action, int param1, int param2)
{
	if (action is MenuAction_Select and param2 is 10)
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
	delete (panel);
}
public int TurnToZeroPanelH(Menu menu, MenuAction action, int param1, int param2)
{
	if (action is MenuAction_Select and param2 is 1)
	{
		BaseBoss player = BaseBoss(param1);
		if ( player.iQueue ) {
			player.iQueue = 0;
			CPrintToChat(param1, "{olive}[VSH 2]{default} You have reset your queue points to {olive}0{default}");
			BaseBoss nextBoss = gamemode.FindNextBoss(); //int cl = FindNextHaleEx();
			if (nextBoss)
				SkipBossPanelNotify(nextBoss.index);
		}
	}
}
/* FINALLY THE PANEL TRAIN HAS ENDED! */
public int SkipHalePanelH(Menu menu, MenuAction action, int client, int param2)
{
	/*if ( IsValidAdmin(client, "b") )
		SetBossMenu( client, -1 );
	else CommandSetSkill( client, -1 );*/
}
public Action SetNextSpecial(int client, int args)
{
	if (bEnabled.BoolValue) {
		char number[4]; GetCmdArg( 1, number, sizeof(number) );
		int type = StringToInt(number);

		if (type < 0 or type > 255)
			type = -1;

		gamemode.iSpecial = type;
	}
	return Plugin_Handled;
}

public Action ChangeHealthBarColor(int client, int args)
{
	if (bEnabled.BoolValue) {
		char number[4]; GetCmdArg( 1, number, sizeof(number) );
		int type = StringToInt(number);

		gamemode.iHealthBarState = type;
		PrintToChat(client, "iHealthBarState = %i", gamemode.iHealthBarState);
	}
	return Plugin_Handled;
}

public Action Command_GetHPCmd(int client, int args)
{
	if (not bEnabled.BoolValue)
		return Plugin_Continue;
	if (gamemode.iRoundState not_eq StateRunning)
		return Plugin_Handled;
	
	BaseBoss player = BaseBoss(client);
	ManageBossCheckHealth(player);	// in handler.sp
	return Plugin_Handled;
}
public Action CommandBossSelect(int client, int args)
{
	if (not bEnabled.BoolValue)
		return Plugin_Continue;
	if (args < 1) {
		ReplyToCommand(client, "[VSH 2] Usage: boss_select <target>");
		return Plugin_Handled;
	}
	char targetname[32]; GetCmdArg(1, targetname, sizeof(targetname));
	if ( !strcmp(targetname, "@me", false) and IsValidClient(client) ) {
		gamemode.hNextBoss = BaseBoss(client);
		ReplyToCommand(client, "[VSH 2] You've set yourself as the next Boss!");
	}
	else {
		int target = FindTarget(client, targetname);
		if (IsValidClient(target)) {
			gamemode.hNextBoss = BaseBoss(target);
			ReplyToCommand(client, "[VSH 2] %N is set as next Boss!", gamemode.hNextBoss.index);
		}
		else gamemode.hNextBoss = view_as< BaseBoss >(0);
	}
	return Plugin_Handled;
}
public Action SetBossMenu(int client, int args)
{
	if (not bEnabled.BoolValue)
		return Plugin_Continue;

	if ( args )
		ManageSetBossArgs(client);

	else if (!args) {
		Menu bossmenu = new Menu(MenuHandler_PickBosses);
		bossmenu.SetTitle("Set Boss Menu: ");
		bossmenu.AddItem("-1", "None (Random Boss)");
		ManageMenu( bossmenu ); // in handler.sp
		bossmenu.Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}
public int MenuHandler_PickBosses(Menu menu, MenuAction action, int client, int select)
{
	char info1[16]; menu.GetItem(select, info1, sizeof(info1));
	if (action is MenuAction_Select) {
		BaseBoss player = BaseBoss(client);
		player.iPresetType = StringToInt(info1);
	}
	else if (action is MenuAction_End)
		delete menu;
}

public Action MusicTogglePanelCmd(int client, int args)
{
	if (not bEnabled.BoolValue)
		return Plugin_Continue;
	MusicTogglePanel(client);
	return Plugin_Handled;
}
public void MusicTogglePanel(const int client)
{
	if (!bEnabled.BoolValue or !IsValidClient(client))
		return;
	Panel panel = new Panel();
	panel.SetTitle("Turn the VS Saxton Hale Music...");
	panel.DrawItem("On?");
	panel.DrawItem("Off?");
	panel.Send(client, MusicTogglePanelH, 9001);
	delete (panel);
}
public int MusicTogglePanelH(Menu menu, MenuAction action, int param1, int param2)
{
	if (IsValidClient(param1)) {
		if (action == MenuAction_Select) {
			BaseBoss player = BaseBoss(param1);
			if (param2 == 1) {
				player.bNoMusic = false;
				CPrintToChat(param1, "{olive}[VSH 2]{default} You've turned On the VS Saxton Hale Music.");
			} else {
				player.bNoMusic = true;
				CPrintToChat(param1, "{olive}[VSH 2]{default} You've turned Off the VS Saxton Hale Music.\nWhen the music stops, it won't play again.");
			}
		}
	}
}

public Action ForceBossRealtime(int client, int args)
{
	if (not bEnabled.BoolValue)
		return Plugin_Continue;

	if (!client) {
		ReplyToCommand(client, "[VSH 2] You can only use this command ingame.");
		return Plugin_Handled;
	}
	if (args < 2) {
		ReplyToCommand(client, "[VSH 2] Usage: boss_force <target> <boss id>");
		return Plugin_Handled;
	}
	if (gamemode.iRoundState > StateStarting) {
		ReplyToCommand(client, "[VSH 2] You can't force a boss after a round started...");
		return Plugin_Handled;
	}
	
	
	char targetname[32];	GetCmdArg(1, targetname, sizeof(targetname));
	char strBossid[32];	GetCmdArg(2, strBossid, sizeof(strBossid));

	int bosstype = StringToInt(strBossid);
	if (bosstype > MAXBOSS)
		bosstype = MAXBOSS;
	else if (bosstype < 0)
		bosstype = 0;
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	if ( (target_count = ProcessTargetString(
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
	for (int i=0; i<target_count; i++) {
		if ( IsClientInGame(target_list[i]) ) {
			player = BaseBoss(target_list[i]);
			player.MakeBossAndSwitch(bosstype, true);
			CPrintToChat(player.index, "{orange}[VSH 2]{default} an Admin has forced you to be a Boss!");
		}
	}
	ReplyToCommand(client, "[VSH 2] Forced %s as a Boss", target_name);
	return Plugin_Handled;
}

public Action CommandAddPoints(int client, int args)
{
	if ( !bEnabled.BoolValue )
		return Plugin_Continue;

	if (args < 2) {
		ReplyToCommand(client, "[VSH] Usage: hale_addpoints <target> <points>");
		return Plugin_Handled;
	}
	char targetname[32];	GetCmdArg(1, targetname, sizeof(targetname));
	char s2[32];		GetCmdArg(2, s2, sizeof(s2));

	int points = StringToInt(s2);

	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	if ( (target_count = ProcessTargetString(
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
	for (int i=0; i<target_count; i++) {
		if ( IsClientInGame(target_list[i]) )
		{
			player = BaseBoss(target_list[i]);
			player.iQueue += points;
			LogAction(client, target_list[i], "\"%L\" added %d VSH2 queue points to \"%L\"", client, points, target_list[i]);
		}
	}
	ReplyToCommand(client, "[VSH 2] Added %d queue points to %s", points, target_name);
	return Plugin_Handled;
}

public Action HelpPanelCmd(int client, int args)
{
	if (!bEnabled.BoolValue)
		return Plugin_Continue;
	if (!client) {
		ReplyToCommand(client, "[VSH 2] You can only use this command ingame.");
		return Plugin_Handled;
	}
	char strHelp[512];
	Format(strHelp, 512, "Welcome to VS Saxton Hale Mode Version 2!\nOne or more players is selected each round to become a Boss.\nEveryone else must kill them!");
	Panel panel = new Panel();
	panel.SetTitle("What do you want, sir?");
	panel.DrawItem("Show Boss' health (/halehp)");
	panel.DrawItem("Show help about the Mode (/halehelp)");
	panel.DrawItem("Who is the next Hale? (/halenext)");
	panel.DrawItem("Reset Queue Points? (/resetq)");
	panel.Send(client, HelpPanelH, 9001);
	delete panel;
	return Plugin_Handled;
}
public int HelpPanelH(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (gamemode.iRoundState is StateRunning) {
					BaseBoss player = BaseBoss(param1);
					ManageBossCheckHealth(player);
				}
				else CPrintToChat(param1, "{olive}[VSH 2]{default} There's no active boss/bosses...");
			}
			case 2:
			{
				BaseBoss player = BaseBoss(param1);
				if (player.bIsBoss or player.bIsMinion)
					ManageBossHelp(player);
				else player.HelpPanelClass();
			}
			case 3: QueuePanel(param1);
			case 4: {
				BaseBoss(param1).iQueue = 0;
				CPrintToChat(param1, "{olive}[VSH 2]{default} Your Queue has been set to 0!");
			}
			default: return;
		}
	}
}
