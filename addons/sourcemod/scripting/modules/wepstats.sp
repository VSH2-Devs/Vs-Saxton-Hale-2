Menu
	hWepMenus[9][4]
;


///ALL CREDITS TO SCAG FOR MOST OF THIS CODE. 
#define MENUPARAMS 		Menu menu, MenuAction action, int client, int select

public void BuildWepMenus()
{
	int i, u;
	char buffer[64], id[5];
	for (i = 0; i < 9; ++i)
	{
		IntToString(i, id, sizeof(id));
		for (u = 0; u < 4; ++u)
		{
			hWepMenus[i][u] = new Menu(StatHandler);

			TF2_GetClassName(view_as< TFClassType >(i+1), buffer, sizeof(buffer), true);
			hWepMenus[i][u].AddItem(id, buffer, ITEMDRAW_IGNORE);
			Format(buffer, sizeof(buffer), "VSH2 Weapon Stats | %s", buffer);

			hWepMenus[i][u].SetTitle(buffer);
			hWepMenus[i][u].ExitBackButton = true;
		}
	}
	//Scout
	hWepMenus[0][0].AddItem("13", "Scattergun");
	hWepMenus[0][0].AddItem("45", "Force-a-Nature");
	hWepMenus[0][0].AddItem("220", "Shortstop");
	hWepMenus[0][0].AddItem("448", "Soda Popper");
	hWepMenus[0][0].AddItem("772", "BFB");
	hWepMenus[0][0].AddItem("1103", "Back Scatter");

	//Secondaries
	hWepMenus[0][1].AddItem("23", "Pistol");
	hWepMenus[0][1].AddItem("46", "Bonk! Atomic Punch");
	hWepMenus[0][1].AddItem("163", "Crit-a-Cola");
	hWepMenus[0][1].AddItem("449", "Winger");
	hWepMenus[0][1].AddItem("773", "PBPP");
	hWepMenus[0][1].AddItem("812", "Flying Guillotine");
	hWepMenus[0][1].AddItem("222", "Mad Milk");

	//Melee
	hWepMenus[0][2].AddItem("0", "Bat");
	hWepMenus[0][2].AddItem("44", "Sandman");
	hWepMenus[0][2].AddItem("221", "Holy Mackerel");
	hWepMenus[0][2].AddItem("317", "Candy Cane");
	hWepMenus[0][2].AddItem("325", "Boston Basher");
	hWepMenus[0][2].AddItem("349", "SOAS");
	hWepMenus[0][2].AddItem("355", "Fan O' War");
	hWepMenus[0][2].AddItem("450", "Atomizer");
	hWepMenus[0][2].AddItem("452", "Three-Rune Blade");
	hWepMenus[0][2].AddItem("648", "Wrap Assassin");

	//Sniper
	hWepMenus[1][0].AddItem("14", "Sniper Rifle");
	hWepMenus[1][0].AddItem("56", "Huntsman");
	hWepMenus[1][0].AddItem("230", "Sydney Sleeper");
	hWepMenus[1][0].AddItem("526", "Machina");
	hWepMenus[1][0].AddItem("402", "Bazaar Bargain");
	hWepMenus[1][0].AddItem("752", "Hitman's Heatmaker");
	hWepMenus[1][0].AddItem("1098", "Classic");
	hWepMenus[1][1].AddItem("16", "SMG");
	hWepMenus[1][1].AddItem("57", "Razorback");
	hWepMenus[1][1].AddItem("58", "Jarate");
	hWepMenus[1][1].AddItem("231", "DDS");
	hWepMenus[1][1].AddItem("642", "Cozy Camper");
	hWepMenus[1][1].AddItem("751", "Cleaner's Carbine");
	hWepMenus[1][2].AddItem("3", "Kukri");
	hWepMenus[1][2].AddItem("232", "Bushwacka");
	hWepMenus[1][2].AddItem("171", "Tribalman's Shiv");
	hWepMenus[1][2].AddItem("401", "Shahanshah");

	//Soldier
	hWepMenus[2][0].AddItem("18", "Rocket Launcher");
	hWepMenus[2][0].AddItem("127", "Direct Hit");
	hWepMenus[2][0].AddItem("228", "Black Box");
	hWepMenus[2][0].AddItem("237", "Rocket Jumper");
	hWepMenus[2][0].AddItem("414", "Liberty Launcher");
	hWepMenus[2][0].AddItem("441", "Cow Mangler");
	hWepMenus[2][0].AddItem("730", "Beggar's Bazooka");
	hWepMenus[2][0].AddItem("1104", "Air Strike");
	hWepMenus[2][1].AddItem("10", "Shotgun");
	hWepMenus[2][1].AddItem("129", "Buff Banner");
	hWepMenus[2][1].AddItem("133", "Gunboats");
	hWepMenus[2][1].AddItem("226", "Battalion's Backup");
	hWepMenus[2][1].AddItem("354", "Concheror");
	hWepMenus[2][1].AddItem("415", "Reserve Shooter");
	hWepMenus[2][1].AddItem("442", "Righteous Bison");
	hWepMenus[2][1].AddItem("444", "Mantreads");
	hWepMenus[2][1].AddItem("1101", "B.A.S.E. Jumper");
	hWepMenus[2][1].AddItem("1153", "Panic Attack");
	hWepMenus[2][2].AddItem("6", "Shovel");
	hWepMenus[2][2].AddItem("128", "Equalizer");
	hWepMenus[2][2].AddItem("154", "Pain Train");
	hWepMenus[2][2].AddItem("357", "Half-Zatoichi");
	hWepMenus[2][2].AddItem("416", "Market Gardener");
	hWepMenus[2][2].AddItem("447", "Disciplinary Action");
	hWepMenus[2][2].AddItem("775", "Escape Plan");

	//Demoman
	hWepMenus[3][0].AddItem("19", "Grenade Launcher");
	hWepMenus[3][0].AddItem("308", "Loch-n-Load");
	hWepMenus[3][0].AddItem("405", "Boots");
	hWepMenus[3][0].AddItem("996", "Loose Cannon");
	hWepMenus[3][0].AddItem("1101", "B.A.S.E. Jumper");
	hWepMenus[3][0].AddItem("1151", "Iron Bomber");
	hWepMenus[3][1].AddItem("20", "Stickybomb Launcher");
	hWepMenus[3][1].AddItem("130", "Scottish Resistance");
	hWepMenus[3][1].AddItem("131", "Chargin' Targe");
	hWepMenus[3][1].AddItem("265", "Sticky Jumper");
	hWepMenus[3][1].AddItem("406", "Splendid Screen");
	hWepMenus[3][1].AddItem("1099", "Tide Turner");
	hWepMenus[3][1].AddItem("1150", "Quickiebomb Launcher");
	hWepMenus[3][2].AddItem("154", "Pain Train");
	hWepMenus[3][2].AddItem("132", "Eyelander");
	hWepMenus[3][2].AddItem("307", "Ullapool Caber");
	hWepMenus[3][2].AddItem("327", "Claidheamh Mor");
	hWepMenus[3][2].AddItem("404", "Persian Persuader");
	hWepMenus[3][2].AddItem("609", "Scottish Handshake");
	hWepMenus[3][2].AddItem("172", "Scotsman's Skullcutter");

	//Medic
	hWepMenus[4][0].AddItem("17", "Syringe Gun");
	hWepMenus[4][0].AddItem("36", "Blutsauger");
	hWepMenus[4][0].AddItem("305", "Crusader's Crossbow");
	hWepMenus[4][0].AddItem("412", "Overdose");
	hWepMenus[4][1].AddItem("29", "Medigun");
	hWepMenus[4][1].AddItem("35", "Kritzkrieg");
	hWepMenus[4][1].AddItem("411", "Quick-Fix");
	hWepMenus[4][1].AddItem("998", "Vaccinator");
	hWepMenus[4][2].AddItem("8", "Bonesaw");
	hWepMenus[4][2].AddItem("37", "Ubersaw");
	hWepMenus[4][2].AddItem("173", "Vita-Saw");
	hWepMenus[4][2].AddItem("304", "Amputator");
	hWepMenus[4][2].AddItem("413", "Solemn Vow");
	
	//Heavy
	hWepMenus[5][0].AddItem("15", "Minigun");
	hWepMenus[5][0].AddItem("41", "Natascha");
	hWepMenus[5][0].AddItem("312", "Brass Beast");
	hWepMenus[5][0].AddItem("424", "Tomislav");
	hWepMenus[5][0].AddItem("811", "Huo-Long Heater");
	hWepMenus[5][1].AddItem("10", "Shotgun");
	hWepMenus[5][1].AddItem("42", "Sandvich");
	hWepMenus[5][1].AddItem("159", "Dalokohs Bar");
	hWepMenus[5][1].AddItem("311", "Buffalo Steak Sandvich");
	hWepMenus[5][1].AddItem("433", "Fishcake");
	hWepMenus[5][1].AddItem("425", "Family Business");
	hWepMenus[5][1].AddItem("1153", "Panic Attack");
	hWepMenus[5][1].AddItem("1190", "Second Banana");
	hWepMenus[5][2].AddItem("5", "Fists");
	hWepMenus[5][2].AddItem("43", "KGB");
	hWepMenus[5][2].AddItem("239", "GRU");
	hWepMenus[5][2].AddItem("310", "Warrior's Spirit");
	hWepMenus[5][2].AddItem("331", "Fists of Steel");
	hWepMenus[5][2].AddItem("426", "Eviction Notice");
	hWepMenus[5][2].AddItem("656", "Holiday Punch");

	//Pyro
	hWepMenus[6][0].AddItem("21", "Flamethrower");
	hWepMenus[6][0].AddItem("40", "Backburner");
	hWepMenus[6][0].AddItem("594", "Phlogistinator");
	hWepMenus[6][0].AddItem("1178", "Dragon's Fury");
	hWepMenus[6][1].AddItem("12", "Shotgun");
	hWepMenus[6][1].AddItem("39", "Flare Gun");
	hWepMenus[6][1].AddItem("351", "Detonator");
	hWepMenus[6][1].AddItem("415", "Reserve Shooter");
	hWepMenus[6][1].AddItem("595", "Manmelter");
	hWepMenus[6][1].AddItem("1153", "Panic Attack");
	hWepMenus[6][1].AddItem("1179", "Thermal Thruster");
	hWepMenus[6][1].AddItem("1180", "Gas Passer");
	hWepMenus[6][2].AddItem("2", "Fire Axe");
	hWepMenus[6][2].AddItem("153", "Homewrecker");
	hWepMenus[6][2].AddItem("326", "Back Scratcher");
	hWepMenus[6][2].AddItem("348", "Sharpened Volcano Fragment");
	hWepMenus[6][2].AddItem("457", "Postal Pummeler");
	hWepMenus[6][2].AddItem("593", "Third Degree");
	hWepMenus[6][2].AddItem("813", "Neon Annihilator");
	hWepMenus[6][2].AddItem("1181", "Hot Hand");

	//Spy
	hWepMenus[7][0].AddItem("24", "Revolver");
	hWepMenus[7][0].AddItem("61", "Ambassador");
	hWepMenus[7][0].AddItem("224", "Letranger");
	hWepMenus[7][0].AddItem("460", "Enforcer");
	hWepMenus[7][0].AddItem("525", "Diamondback");
	hWepMenus[7][1].AddItem("735", "Sapper");
	hWepMenus[7][1].AddItem("810", "Red-Tape Recorder");
	hWepMenus[7][2].AddItem("4", "Knife");
	hWepMenus[7][2].AddItem("356", "Conniver's Kunai");
	hWepMenus[7][2].AddItem("225", "YER");
	hWepMenus[7][2].AddItem("461", "Big Earner");
	hWepMenus[7][2].AddItem("649", "Spy-Cicle");
	//Spy-Watches
	hWepMenus[7][3].AddItem("30", "Invis Watch");
	hWepMenus[7][3].AddItem("59", "Dead Ringer");
	hWepMenus[7][3].AddItem("60", "Cloak and Dagger");

	//Engineer
	hWepMenus[8][0].AddItem("9", "Shotgun");
	hWepMenus[8][0].AddItem("141", "Frontier Justice");
	hWepMenus[8][0].AddItem("527", "Widowmaker");
	hWepMenus[8][0].AddItem("588", "Pomson");
	hWepMenus[8][0].AddItem("997", "Rescue Ranger");
	hWepMenus[8][0].AddItem("1153", "Panic Attack");

	hWepMenus[8][1].AddItem("22", "Pistol");
	hWepMenus[8][1].AddItem("140", "Wrangler");
	hWepMenus[8][1].AddItem("528", "Short Circuit");

	hWepMenus[8][2].AddItem("7", "Wrench");
	hWepMenus[8][2].AddItem("142", "Gunslinger");
	hWepMenus[8][2].AddItem("155", "Southern Hospitality");
	hWepMenus[8][2].AddItem("329", "Jag");
	hWepMenus[8][2].AddItem("589", "Eureka Effect");
	hWepMenus[8][2].AddItem("169", "Fake Golden Wrench");
}

public void WepStatsMenu_Root(int client)
{
	Menu menu = new Menu(WepMenu_Root);
	menu.SetTitle("VSH2 Weapon Stats");
	menu.AddItem("1", "Scout");
	menu.AddItem("2", "Sniper");
	menu.AddItem("3", "Soldier");
	menu.AddItem("4", "Demoman");
	menu.AddItem("5", "Medic");
	menu.AddItem("6", "Heavy");
	menu.AddItem("7", "Pyro");
	menu.AddItem("8", "Spy");
	menu.AddItem("9", "Engineer");
 	menu.Display(client, 0);
}

public int WepMenu_Root(Menu menu, MenuAction action, int client, int select)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char id[4];
			char item[32]; menu.GetItem(select, id, 4, _, item, sizeof(item));
			WepStatsMenu_Slot(client, id, item);
		}
		case MenuAction_End:delete menu;
	}
	return 0;
}

public void WepStatsMenu_Slot(int client, const char[] id, const char[] name)
{
	Menu menu = new Menu(WepMenu_Slot);
	char buffer[64];
	FormatEx(buffer, sizeof(buffer), "VSH2 Weapon Stats | %s", name);
	menu.SetTitle(buffer);
	menu.AddItem("-1", id, ITEMDRAW_IGNORE);
	menu.AddItem("0", "Primary");
	menu.AddItem("1", "Secondary");
	menu.AddItem("2", "Melee");
	if (strcmp(buffer, "Spy", false))
		menu.AddItem("3", "Cloak");
	//menu.AddItem("3", "Class Bonuses");
	menu.ExitBackButton = true;

	menu.Display(client, 0);
}

public int WepMenu_Slot(MENUPARAMS)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char id[4]; menu.GetItem(0, "", 0, _, id, sizeof(id));
			char id2[4]; menu.GetItem(select, id2, sizeof(id2));
//			PrintToChatAll("%s %s", id, id2);
			hWepMenus[StringToInt(id)-1][StringToInt(id2)].Display(client, 0);
		}
		case MenuAction_Cancel:
		{
			if (select == MenuCancel_ExitBack)
				WepStatsMenu_Root(client);
		}
		case MenuAction_End:delete menu;
	}
	return 0;
}

public int StatHandler(MENUPARAMS)
{
	switch (action)
	{
		case MenuAction_Select:
		{
//			char name[32];
			char id[4]; menu.GetItem(0, id, sizeof(id));//, _, name, sizeof(name));
			char item[16], itemname[32]; menu.GetItem(select, item, sizeof(item), _, itemname, sizeof(itemname));
			char buffer[256];
			GetWeaponStatCfg(StringToInt(item), buffer, sizeof(buffer), StringToInt(id));
			if (!strcmp(itemname, buffer, false))
				FormatEx(buffer, sizeof(buffer), "%s: Default stats.", itemname);
			else if (buffer[0] == '\0')
				FormatEx(buffer, sizeof(buffer), "{red}ERROR{default}: No stats found for {olive}%s{default}.", itemname);

			CPrintToChat(client, "{olive}[VSH 2]{default} %s", buffer);
			menu.DisplayAt(client, select - select % 8, 0);
		}
		case MenuAction_Cancel:
		{
			if (select == MenuCancel_ExitBack)
			{
				char name[32];
				char id[4]; menu.GetItem(0, id, sizeof(id), _, name, sizeof(name));
				IntToString(StringToInt(id)+1, id, sizeof(id));
				WepStatsMenu_Slot(client, id, name);
			}
		}
	}
	return 1;
}


///Replaced Scags case based implementation with a config to make it easier to update and control. 
stock void GetWeaponStatCfg(int idx, char[] buffer, int maxlen, int class)
{
	buffer[0] = '\0';
	if (idx == -1)
		return;
	if (idx == 20230211){
		if (class == 0){  //Scout
			int note_len = g_vsh2.m_hCfg.GetSize("weplist.scout.classnote");
			char[] note = new char[note_len];
			if( g_vsh2.m_hCfg.Get("weplist.scout.classnote", note, note_len) > 0 ) {
				strcopy(buffer, maxlen, note);
			}
		}
		if (class == 1){	//Sniper
			int note_len = g_vsh2.m_hCfg.GetSize("weplist.sniper.classnote");
			char[] note = new char[note_len];
			if( g_vsh2.m_hCfg.Get("weplist.sniper.classnote", note, note_len) > 0 ) {
				strcopy(buffer, maxlen, note);
			}
		}
		if (class == 2){	//Soldier
			int note_len = g_vsh2.m_hCfg.GetSize("weplist.soldier.classnote");
			char[] note = new char[note_len];
			if( g_vsh2.m_hCfg.Get("weplist.soldier.classnote", note, note_len) > 0 ) {
				strcopy(buffer, maxlen, note);
			}
		}
		if (class == 3){	//Demoman
			int note_len = g_vsh2.m_hCfg.GetSize("weplist.scout.classnote");
			char[] note = new char[note_len];
			if( g_vsh2.m_hCfg.Get("weplist.demoman.classnote", note, note_len) > 0 ) {
				strcopy(buffer, maxlen, note);
			}
		}
		if (class == 4){	//Medic
			int note_len = g_vsh2.m_hCfg.GetSize("weplist.scout.classnote");
			char[] note = new char[note_len];
			if( g_vsh2.m_hCfg.Get("weplist.medic.classnote", note, note_len) > 0 ) {
				strcopy(buffer, maxlen, note);
			}
		}
		if (class == 5){	//Heavy
			int note_len = g_vsh2.m_hCfg.GetSize("weplist.scout.classnote");
			char[] note = new char[note_len];
			if( g_vsh2.m_hCfg.Get("weplist.heavy.classnote", note, note_len) > 0 ) {
				strcopy(buffer, maxlen, note);
			}
		}
		if (class == 6){	//Pyro
			int note_len = g_vsh2.m_hCfg.GetSize("weplist.scout.classnote");
			char[] note = new char[note_len];
			if( g_vsh2.m_hCfg.Get("weplist.pyro.classnote", note, note_len) > 0 ) {
				strcopy(buffer, maxlen, note);
			}
		}
		if (class == 7){	//Spy
			int note_len = g_vsh2.m_hCfg.GetSize("weplist.scout.classnote");
			char[] note = new char[note_len];
			if( g_vsh2.m_hCfg.Get("weplist.spy.classnote", note, note_len) > 0 ) {
				strcopy(buffer, maxlen, note);
			}
		}
		if (class == 8){	//Engie
			int note_len = g_vsh2.m_hCfg.GetSize("weplist.scout.classnote");
			char[] note = new char[note_len];
			if( g_vsh2.m_hCfg.Get("weplist.engineer.classnote", note, note_len) > 0 ) {
				strcopy(buffer, maxlen, note);
			}
		}
	}

	switch(class){
		case 0:
			switch(idx){
				//Scout
				//Primary
				case 200, 669, 799, 808, 888, 897, 906, 915, 964, 973, 15002, 15015, 15021, 15029, 15036, 15053, 15065, 15069, 15106, 15107, 15108, 15131, 15151, 15157:
					idx = 13;
				case 1078:
					idx = 45; 
				//Secondary
				case 209, 160, 294, 15013, 15018, 15035, 15041, 15046, 15056, 15060, 15061, 15100, 15101, 15102, 15126, 15148, 30666:
					idx = 23;
				case 1121:
					idx = 222;
				case 833:
					idx = 812;
				case 1145:
					idx = 46;
				//Melee
				case 190, 264, 423, 474, 660, 880, 939, 954, 1013, 1071, 1123, 1127, 30667, 30758:
					idx = 0;
				case 572, 999:
					idx = 221;
				case 452:
					idx = 325;
			}
		case 1:
			switch(idx){
				//Sniper
				//Primary
				case 201, 664, 792, 801, 851, 881, 890, 899, 908, 957, 966, 15000, 15007, 15019, 15023, 15033, 15059, 15070, 15071, 15072, 15111, 15112, 15135, 15136, 15154:
					idx = 14;
				case 30665:
					idx = 526;
				case 1005, 1092:
					idx = 56;
				
				//Secondary
				case 203, 1149, 15001, 15022, 15032, 15037, 15058, 15076, 15110, 15134, 15153:
					idx = 16;
				case 1083, 1105:
					idx = 58;

				//Melee
				case 193, 264, 423, 474, 880, 939, 954, 1013, 1071, 1123, 1127, 30758:
					idx = 3;
			}
		case 2:
			switch(idx){
				//Soldier
				//Primary
				case 205, 513, 658, 800, 809, 889, 898, 907, 916, 965, 974, 15006, 15014, 15028, 15043, 15052, 15057, 15081, 15104, 15105, 15129, 15130, 15150:
					idx = 18;
				case 1085:
					idx = 228;
				
				//Secondary
				case 199, 1141, 15003, 15016, 15044, 15047, 15085, 15109, 15132, 15133, 15152:
					idx = 10;
				case 1001:
					idx = 129;

				//Melee
				case 196, 264, 423, 474, 880, 939, 954, 1013, 1071, 1123, 1127, 30758:
					idx = 6;
			}
		case 3:
			switch(idx){
				//Demoman
				//Primary
				case 206, 1007, 15077, 15079, 15091, 15116, 15117, 15142, 15158:
					idx = 19;

				//Secondary
				case 207, 661, 797, 806, 886, 895, 904, 913, 962, 971, 15009, 15012, 15024, 15038, 15045, 15048, 15082, 15083, 15084, 15113, 15137, 15138, 15155:
					idx = 20;
				
				//Melee
				case 191, 264, 423, 474, 880, 939, 954, 1013, 1071, 1123, 1127, 30758:
					idx = 1;
				case 266, 1082, 482:
					idx = 132;
			}
		case 4:
			switch(idx){
				//Medic
				//Primary
				case 204: 
					idx = 17;
				case 1079:
					idx = 305;

				//Secondary
				case 211, 663, 796, 805, 885, 894, 903, 912, 961, 970, 15008, 15010, 15025, 15039, 15050, 15078, 15097, 15121, 15122, 15123, 15145, 15146:
					idx = 29;
				
				//Melee
				case 198, 264, 423, 474, 880, 939, 954, 1013, 1071, 1123, 1127, 1143, 30758:
					idx = 8;
				case 1003:
					idx = 37;
			}
		case 5:
			switch(idx){
				//Heavy
				//Primary
				case 202, 298, 654, 793, 802, 850, 882, 891, 900, 909, 958, 967, 15004, 15020, 15026, 15031, 15040, 15055, 15086, 15087, 15088, 15098, 15099, 15123, 15124, 15125, 15147:
					idx = 15;
				case 832:
					idx = 811;

				//Secondary
				case 199, 1141, 15003, 15016, 15044, 15047, 15085, 15109, 15132, 15133, 15152:
					idx = 11;
				case 433, 1190:
					idx = 159;
				case 863, 1002:
					idx = 42;

				//Melee
				case 195, 264, 423, 474, 880, 939, 954, 1013, 1071, 1123, 1127, 30758:
					idx = 5;
				case 587:
					idx = 43;
				case 1084, 1100:
					idx = 239;
			}
		case 6:
			switch(idx){
				//Pyro
				//Primary
				case 208, 659, 741, 798, 807, 887, 896, 905, 914, 963, 972, 15005, 15017, 15030, 15034, 15049, 15054, 15066, 15067, 15068, 15089, 15090, 15115, 15141, 30474:
					idx = 21;
				case 1146:
					idx = 40;

				//Secondary
				case 199, 1141, 15003, 15016, 15044, 15047, 15085, 15109, 15132, 15133, 15152:
					idx = 12;
				case 1081:
					idx = 39;
				

				//Melee
				case 192, 264, 423, 474, 739, 880, 939, 954, 1013, 1071, 1123, 1127, 30758:
					idx = 2;
				case 457, 1000:
					idx = 38; 
				case 466:
					idx = 153;
				case 834:
					idx = 813; 
			}
		case 7:
			switch(idx){
				//Spy
				//Primary
				case 210, 161, 1142, 15011, 15027, 15042, 15051, 15063, 15064, 15103, 15128, 15127, 15149:
					idx = 24;
				case 1006:
					idx = 61;

				//Secondary
				case 736, 933, 1080, 1102:
					idx = 735;
				case 831:
					idx = 810;

				//Melee
				case 194, 423, 638, 665, 727, 794, 803, 883, 892, 901, 910, 959, 968, 1071, 15062, 15094, 15095, 15096, 15118, 15119, 15143, 15144, 30758:
					idx = 4;
				case 574:
					idx = 225;

				//Watches
				case 212, 297, 947:
					idx = 30;
			}
		case 8:
			switch(idx){
				//Engie
				//Primary
				case 199, 1141, 15003, 15016, 15044, 15047, 15085, 15109, 15132, 15133, 15152:
					idx = 9;
				case 1004:
					idx = 141;
				//Secondary
				case 209, 160, 294, 15013, 15018, 15035, 15041, 15046, 15056, 15060, 15061, 15100, 15101, 15102, 15126, 15148, 30666:
					idx = 22;
				case 1086, 30668:
					idx = 140;
				

				//Melee
				case 197, 169, 423, 662, 795, 804, 884, 893, 902, 911, 969, 1071, 1123, 15073, 15074, 15075, 15139, 15140, 15114, 15156, 30758:
					idx = 7;
			}
	}
	//Remap reskins to their stock counterpart.
	char itemid[64];
	IntToString(idx, itemid, sizeof(itemid));
	if (class == 0){  //Scout
		char cfgmapindex[][] = {
			"weplist.scout.primary",
			"weplist.scout.secondary",
			"weplist.scout.melee"
		};
		for( int i; i<sizeof(cfgmapindex); i++ ) {
			ConfigMap ClassMap = g_vsh2.m_hCfg.GetSection(cfgmapindex[i]);
			if( ClassMap != null ) {
				int value_size = ClassMap.GetSize(itemid);
				char[] stat = new char[value_size];
				if( ClassMap.Get(itemid, stat, value_size) ) {
					strcopy(buffer, maxlen, stat);
				}
			}
		}
	}
	if (class == 1){	//Sniper
		char cfgmapindex[][] = {
			"weplist.sniper.primary",
			"weplist.sniper.secondary",
			"weplist.sniper.melee"
		};
		for( int i; i<sizeof(cfgmapindex); i++ ) {
			ConfigMap ClassMap = g_vsh2.m_hCfg.GetSection(cfgmapindex[i]);
			if( ClassMap != null ) {
				int value_size = ClassMap.GetSize(itemid);
				char[] stat = new char[value_size];
				if( ClassMap.Get(itemid, stat, value_size) ) {
					strcopy(buffer, maxlen, stat);
				}
			}
		}
	}
	if (class == 2){	//Soldier
		char cfgmapindex[][] = {
			"weplist.soldier.primary",
			"weplist.soldier.secondary",
			"weplist.soldier.melee"
		};
		for( int i; i<sizeof(cfgmapindex); i++ ) {
			ConfigMap ClassMap = g_vsh2.m_hCfg.GetSection(cfgmapindex[i]);
			if( ClassMap != null ) {
				int value_size = ClassMap.GetSize(itemid);
				char[] stat = new char[value_size];
				if( ClassMap.Get(itemid, stat, value_size) ) {
					strcopy(buffer, maxlen, stat);
				}
			}
		}
	}
	if (class == 3){	//Demoman
		char cfgmapindex[][] = {
			"weplist.demoman.primary",
			"weplist.demoman.secondary",
			"weplist.demoman.melee"
		};
		for( int i; i<sizeof(cfgmapindex); i++ ) {
			ConfigMap ClassMap = g_vsh2.m_hCfg.GetSection(cfgmapindex[i]);
			if( ClassMap != null ) {
				int value_size = ClassMap.GetSize(itemid);
				char[] stat = new char[value_size];
				if( ClassMap.Get(itemid, stat, value_size) ) {
					strcopy(buffer, maxlen, stat);
				}
			}
		}
	}
	if (class == 4){	//Medic
		char cfgmapindex[][] = {
			"weplist.medic.primary",
			"weplist.medic.secondary",
			"weplist.medic.melee"
		};
		for( int i; i<sizeof(cfgmapindex); i++ ) {
			ConfigMap ClassMap = g_vsh2.m_hCfg.GetSection(cfgmapindex[i]);
			if( ClassMap != null ) {
				int value_size = ClassMap.GetSize(itemid);
				char[] stat = new char[value_size];
				if( ClassMap.Get(itemid, stat, value_size) ) {
					strcopy(buffer, maxlen, stat);
				}
			}
		}
	}
	if (class == 5){	//Heavy
		char cfgmapindex[][] = {
			"weplist.heavy.primary",
			"weplist.heavy.secondary",
			"weplist.heavy.melee"
		};
		for( int i; i<sizeof(cfgmapindex); i++ ) {
			ConfigMap ClassMap = g_vsh2.m_hCfg.GetSection(cfgmapindex[i]);
			if( ClassMap != null ) {
				int value_size = ClassMap.GetSize(itemid);
				char[] stat = new char[value_size];
				if( ClassMap.Get(itemid, stat, value_size) ) {
					strcopy(buffer, maxlen, stat);
				}
			}
		}
	}
	if (class == 6){	//Pyro
		char cfgmapindex[][] = {
			"weplist.pyro.primary",
			"weplist.pyro.secondary",
			"weplist.pyro.melee"
		};
		for( int i; i<sizeof(cfgmapindex); i++ ) {
			ConfigMap ClassMap = g_vsh2.m_hCfg.GetSection(cfgmapindex[i]);
			if( ClassMap != null ) {
				int value_size = ClassMap.GetSize(itemid);
				char[] stat = new char[value_size];
				if( ClassMap.Get(itemid, stat, value_size) ) {
					strcopy(buffer, maxlen, stat);
				}
			}
		}
	}
	if (class == 7){	//Spy
		char cfgmapindex[][] = {
			"weplist.spy.primary",
			"weplist.spy.secondary",
			"weplist.spy.melee",
			"weplist.spy.watches"
		};
		for( int i; i<sizeof(cfgmapindex); i++ ) {
			ConfigMap ClassMap = g_vsh2.m_hCfg.GetSection(cfgmapindex[i]);
			if( ClassMap != null ) {
				int value_size = ClassMap.GetSize(itemid);
				char[] stat = new char[value_size];
				if( ClassMap.Get(itemid, stat, value_size) ) {
					strcopy(buffer, maxlen, stat);
				}
			}
		}
	}
	if (class == 8){	//Engie
		char cfgmapindex[][] = {
			"weplist.engineer.primary",
			"weplist.engineer.secondary",
			"weplist.engineer.melee"
		};
		for( int i; i<sizeof(cfgmapindex); i++ ) {
			ConfigMap ClassMap = g_vsh2.m_hCfg.GetSection(cfgmapindex[i]);
			if( ClassMap != null ) {
				int value_size = ClassMap.GetSize(itemid);
				char[] stat = new char[value_size];
				if( ClassMap.Get(itemid, stat, value_size) ) {
					strcopy(buffer, maxlen, stat);
				}
			}
		}
	}
}