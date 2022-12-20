// MOAR COLORS
// By Dr. McKay
// Inspired by: https://forums.alliedmods.net/showthread.php?t=96831

#if defined _colors_included
 #endinput
#endif
#define _colors_included

#include <regex>

#define MORE_COLORS_VERSION		"1.9.1"
#define MAX_MESSAGE_LENGTH		256
#define MAX_BUFFER_LENGTH		(MAX_MESSAGE_LENGTH * 4)

#define COLOR_RED				0xFF4040
#define COLOR_BLUE				0x99CCFF
#define COLOR_GRAY				0xCCCCCC
#define COLOR_GREEN				0x3EFF3E

#define GAME_DODS				0

bool CSkipList[MAXPLAYERS+1];
StringMap CMap;
int CTeamColors[][] = {{0xCCCCCC, 0x4D7942, 0xFF4040}}; // Multi-dimensional array for games that don't support SayText2. First index is the game index (as defined by the GAME_ defines), second index is team. 0 = spectator, 1 = team1, 2 = team2

/**
 * Prints a message to a specific client in the chat area.
 * Supports color tags.
 *
 * @param client		Client index.
 * @param message		Message (formatting rules).
 * @noreturn
 *
 * On error/Errors:		If the client is not connected an error will be thrown.
 */
stock void CPrintToChat(int client, const char[] message, any ...) {
	CCheckMap();
	if(client <= 0 || client > MaxClients) {
		ThrowError("Invalid client index %i", client);
	}
	if(!IsClientInGame(client)) {
		ThrowError("Client %i is not in game", client);
	}
	char buffer[MAX_BUFFER_LENGTH], buffer2[MAX_BUFFER_LENGTH];
	SetGlobalTransTarget(client);
	Format(buffer, sizeof(buffer), "\x01%s", message);
	VFormat(buffer2, sizeof(buffer2), buffer, 3);
	CReplaceColorCodes(buffer2);
	CSendMessage(client, buffer2);
}

/**
 * Prints a message to all clients in the chat area.
 * Supports color tags.
 *
 * @param client		Client index.
 * @param message		Message (formatting rules).
 * @noreturn
 */
stock void CPrintToChatAll(const char[] message, any ...) {
	CCheckMap();
	char buffer[MAX_BUFFER_LENGTH], buffer2[MAX_BUFFER_LENGTH];
	for(int i = 1; i <= MaxClients; i++) {
		if(!IsClientInGame(i) || CSkipList[i]) {
			CSkipList[i] = false;
			continue;
		}
		SetGlobalTransTarget(i);
		Format(buffer, sizeof(buffer), "\x01%s", message);
		VFormat(buffer2, sizeof(buffer2), buffer, 2);
		CReplaceColorCodes(buffer2);
		CSendMessage(i, buffer2);
	}
}

/**
 * Prints a message to a specific client in the chat area.
 * Supports color tags and teamcolor tag.
 *
 * @param client		Client index.
 * @param author		Author index whose color will be used for teamcolor tag.
 * @param message		Message (formatting rules).
 * @noreturn
 *
 * On error/Errors:		If the client or author are not connected an error will be thrown
 */
stock void CPrintToChatEx(int client, int author, const char[] message, any ...) {
	CCheckMap();
	if(client <= 0 || client > MaxClients) {
		ThrowError("Invalid client index %i", client);
	}
	if(!IsClientInGame(client)) {
		ThrowError("Client %i is not in game", client);
	}
	if(author <= 0 || author > MaxClients) {
		ThrowError("Invalid client index %i", author);
	}
	if(!IsClientInGame(author)) {
		ThrowError("Client %i is not in game", author);
	}
	char buffer[MAX_BUFFER_LENGTH], buffer2[MAX_BUFFER_LENGTH];
	SetGlobalTransTarget(client);
	Format(buffer, sizeof(buffer), "\x01%s", message);
	VFormat(buffer2, sizeof(buffer2), buffer, 4);
	CReplaceColorCodes(buffer2, author);
	CSendMessage(client, buffer2, author);
}

/**
 * Prints a message to all clients in the chat area.
 * Supports color tags and teamcolor tag.
 *
 * @param author	  Author index whose color will be used for teamcolor tag.
 * @param message   Message (formatting rules).
 * @noreturn
 *
 * On error/Errors:   If the author is not connected an error will be thrown.
 */
stock void CPrintToChatAllEx(int author, const char[] message, any ...) {
	CCheckMap();
	if(author <= 0 || author > MaxClients) {
		ThrowError("Invalid client index %i", author);
	}
	if(!IsClientInGame(author)) {
		ThrowError("Client %i is not in game", author);
	}
	char buffer[MAX_BUFFER_LENGTH], buffer2[MAX_BUFFER_LENGTH];
	for(int i = 1; i <= MaxClients; i++) {
		if(!IsClientInGame(i) || CSkipList[i]) {
			CSkipList[i] = false;
			continue;
		}
		SetGlobalTransTarget(i);
		Format(buffer, sizeof(buffer), "\x01%s", message);
		VFormat(buffer2, sizeof(buffer2), buffer, 3);
		CReplaceColorCodes(buffer2, author);
		CSendMessage(i, buffer2, author);
	}
}

/**
 * Sends a SayText2 usermessage
 *
 * @param client	Client to send usermessage to
 * @param message	Message to send
 * @noreturn
 */
stock void CSendMessage(int client, const char[] message, int author=0) {
	if(author == 0) {
		author = client;
	}
	char buffer[MAX_MESSAGE_LENGTH], game[16];
	GetGameFolderName(game, sizeof(game));
	strcopy(buffer, sizeof(buffer), message);
	UserMsg index = GetUserMessageId("SayText2");
	if(index == INVALID_MESSAGE_ID) {
		if(StrEqual(game, "dod")) {
			int team = GetClientTeam(author);
			if(team == 0) {
				ReplaceString(buffer, sizeof(buffer), "\x03", "\x04", false); // Unassigned gets green
			} else {
				char temp[16];
				Format(temp, sizeof(temp), "\x07%06X", CTeamColors[GAME_DODS][team - 1]);
				ReplaceString(buffer, sizeof(buffer), "\x03", temp, false);
			}
		}
		PrintToChat(client, "%s", buffer);
		return;
	}
	Handle buf = StartMessageOne("SayText2", client, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS);
	if(GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf) {
		PbSetInt(buf, "ent_idx", author);
		PbSetBool(buf, "chat", true);
		PbSetString(buf, "msg_name", buffer);
		PbAddString(buf, "params", "");
		PbAddString(buf, "params", "");
		PbAddString(buf, "params", "");
		PbAddString(buf, "params", "");
	} else {
		BfWriteByte(buf, author); // Message author
		BfWriteByte(buf, true); // Chat message
		BfWriteString(buf, buffer); // Message text
	}
	EndMessage();
}

/**
 * This function should only be used right in front of
 * CPrintToChatAll or CPrintToChatAllEx. It causes those functions
 * to skip the specified client when printing the message.
 * After printing the message, the client will no longer be skipped.
 *
 * @param client   Client index
 * @noreturn
 */
stock void CSkipNextClient(int client) {
	if(client <= 0 || client > MaxClients) {
		ThrowError("Invalid client index %i", client);
	}
	CSkipList[client] = true;
}

/**
 * Checks if the colors trie is initialized and initializes it if it's not (used internally)
 *
 * @return			No return
 */
stock void CCheckMap() {
	if(CMap == null) {
		CMap = InitColorMap();
	}
}

/**
 * Replaces color tags in a string with color codes (used internally by CPrintToChat, CPrintToChatAll, CPrintToChatEx, and CPrintToChatAllEx
 *
 * @param buffer		String.
 * @param author		Optional client index to use for {teamcolor} tags, or 0 for none
 * @param removeTags	Optional boolean value to determine whether we're replacing tags with colors, or just removing tags, used by CRemoveTags
 * @param maxlen		Optional value for max buffer length, used by CRemoveTags
 * @noreturn
 *
 * On error/Errors:		If the client index passed for author is invalid or not in game.
 */
stock void CReplaceColorCodes(char[] buffer, int author=0, bool removeTags=false, int maxlen=MAX_BUFFER_LENGTH) {
	CCheckMap();
	if(!removeTags) {
		ReplaceString(buffer, maxlen, "{default}", "\x01", false);
	} else {
		ReplaceString(buffer, maxlen, "{default}", "", false);
		ReplaceString(buffer, maxlen, "{teamcolor}", "", false);
	}
	if(author != 0 && !removeTags) {
		if(author < 0 || author > MaxClients) {
			ThrowError("Invalid client index %i", author);
		}
		if(!IsClientInGame(author)) {
			ThrowError("Client %i is not in game", author);
		}
		ReplaceString(buffer, maxlen, "{teamcolor}", "\x03", false);
	}
	int cursor = 0;
	int value;
	char tag[32], buff[32];
	char[] output = new char[maxlen];
	//char output[maxlen];
	strcopy(output, maxlen, buffer);
	// Since the string's size is going to be changing, output will hold the replaced string and we'll search buffer

	Regex regex = new Regex("{[a-zA-Z0-9]+}");
	for(int i = 0; i < 1000; i++) { // The RegEx extension is quite flaky, so we have to loop here :/. This loop is supposed to be infinite and broken by return, but conditions have been added to be safe.
		if(regex.Match(buffer[cursor]) < 1) {
			CloseHandle(regex);
			strcopy(buffer, maxlen, output);
			return;
		}
		regex.GetSubString(0, tag, sizeof(tag));
		CStrToLower(tag);
		cursor = StrContains(buffer[cursor], tag, false) + cursor + 1;
		strcopy(buff, sizeof(buff), tag);
		ReplaceString(buff, sizeof(buff), "{", "");
		ReplaceString(buff, sizeof(buff), "}", "");

		if(!CMap.GetValue(buff, value)) {
			continue;
		}

		if(removeTags) {
			ReplaceString(output, maxlen, tag, "", false);
		} else {
			Format(buff, sizeof(buff), "\x07%06X", value);
			ReplaceString(output, maxlen, tag, buff, false);
		}
	}
	LogError("[MORE COLORS] Infinite loop broken.");
}

/**
 * Gets a part of a string
 *
 * @param input			String to get the part from
 * @param output		Buffer to write to
 * @param maxlen		Max length of output buffer
 * @param start			Position to start at
 * @param numChars		Number of characters to return, or 0 for the end of the string
 * @noreturn
 */
stock void CSubString(const char[] input, char[] output, int maxlen, int start, int numChars=0) {
	int i = 0;
	for(;;) {
		if(i == maxlen - 1 || i >= numChars || input[start + i] == '\0') {
			output[i] = '\0';
			return;
		}
		output[i] = input[start + i];
		i++;
	}
}

/**
 * Converts a string to lowercase
 *
 * @param buffer		String to convert
 * @noreturn
 */
stock void CStrToLower(char[] buffer) {
	int len = strlen(buffer);
	for(int i = 0; i < len; i++) {
		buffer[i] = CharToLower(buffer[i]);
	}
}

/**
 * Adds a color to the colors trie
 *
 * @param name			Color name, without braces
 * @param color			Hexadecimal representation of the color (0xRRGGBB)
 * @return				True if color was added successfully, false if a color already exists with that name
 */
stock bool CAddColor(const char[] name, int color) {
	CCheckMap();
	int value;
	if(CMap.GetValue(name, value)) {
		return false;
	}
	char newName[64];
	strcopy(newName, sizeof(newName), name);
	CStrToLower(newName);
	CMap.SetValue(newName, color);
	return true;
}

/**
 * Removes color tags from a message
 *
 * @param message		Message to remove tags from
 * @param maxlen		Maximum buffer length
 * @noreturn
 */
stock void CRemoveTags(char[] message, int maxlen) {
	CReplaceColorCodes(message, 0, true, maxlen);
}

/**
 * Replies to a command with colors
 *
 * @param client		Client to reply to
 * @param message		Message (formatting rules)
 * @noreturn
 */
stock void CReplyToCommand(int client, const char[] message, any ...) {
	char buffer[MAX_BUFFER_LENGTH];
	SetGlobalTransTarget(client);
	VFormat(buffer, sizeof(buffer), message, 3);
	if(GetCmdReplySource() == SM_REPLY_TO_CONSOLE) {
		CRemoveTags(buffer, sizeof(buffer));
		PrintToConsole(client, "%s", buffer);
	} else {
		CPrintToChat(client, "%s", buffer);
	}
}

/**
 * Replies to a command with colors
 *
 * @param client		Client to reply to
 * @param author		Client to use for {teamcolor}
 * @param message		Message (formatting rules)
 * @noreturn
 */
stock void CReplyToCommandEx(int client, int author, const char[] message, any ...) {
	char buffer[MAX_BUFFER_LENGTH];
	SetGlobalTransTarget(client);
	VFormat(buffer, sizeof(buffer), message, 4);
	if(GetCmdReplySource() == SM_REPLY_TO_CONSOLE) {
		CRemoveTags(buffer, sizeof(buffer));
		PrintToConsole(client, "%s", buffer);
	} else {
		CPrintToChatEx(client, author, "%s", buffer);
	}
}

/**
 * Shows admin activity with colors
 *
 * @param client		Client performing an action
 * @param message		Message (formatting rules)
 * @noreturn
 */
stock void CShowActivity(int client, const char[] message, any ...) {
	CCheckMap();
	if(client < 0 || client > MaxClients) {
		ThrowError("Invalid client index %d", client);
	}
	if(client != 0 && !IsClientInGame(client)) {
		ThrowError("Client %d is not in game", client);
	}
	char buffer[MAX_BUFFER_LENGTH], buffer2[MAX_BUFFER_LENGTH];
	Format(buffer, sizeof(buffer), "\x01%s", message);
	VFormat(buffer2, sizeof(buffer2), buffer, 3);
	CReplaceColorCodes(buffer2);
	ShowActivity(client, "%s", buffer2);
}

/**
 * Shows admin activity with colors
 *
 * @param client		Client performing an action
 * @param tag			Tag to prepend to the message (color tags supported)
 * @param message		Message (formatting rules)
 * @noreturn
 */
stock void CShowActivityEx(int client, const char[] tag, const char[] message, any ...) {
	CCheckMap();
	if(client < 0 || client > MaxClients) {
		ThrowError("Invalid client index %d", client);
	}
	if(client != 0 && !IsClientInGame(client)) {
		ThrowError("Client %d is not in game", client);
	}
	char buffer[MAX_BUFFER_LENGTH], buffer2[MAX_BUFFER_LENGTH];
	Format(buffer, sizeof(buffer), "\x01%s", message);
	VFormat(buffer2, sizeof(buffer2), buffer, 4);
	CReplaceColorCodes(buffer2);
	strcopy(buffer, sizeof(buffer), tag);
	CReplaceColorCodes(buffer);
	ShowActivityEx(client, tag, "%s", buffer2);
}

/**
 * Shows admin activity with colors
 *
 * @param client		Client performing an action
 * @param tag			Tag to prepend to the message (color tags supported)
 * @param message		Message (formatting rules)
 * @noreturn
 */
stock void CShowActivity2(int client, const char[] tag, const char[] message, any ...) {
	CCheckMap();
	if(client < 0 || client > MaxClients) {
		ThrowError("Invalid client index %d", client);
	}
	if(client != 0 && !IsClientInGame(client)) {
		ThrowError("Client %d is not in game", client);
	}
	char buffer[MAX_BUFFER_LENGTH], buffer2[MAX_BUFFER_LENGTH];
	Format(buffer, sizeof(buffer), "\x01%s", message);
	VFormat(buffer2, sizeof(buffer2), buffer, 4);
	CReplaceColorCodes(buffer2);
	strcopy(buffer, sizeof(buffer), tag);
	CReplaceColorCodes(buffer);
	ShowActivity2(client, buffer, "%s", buffer2);
}

/**
 * Determines whether a color name exists
 *
 * @param color			The color name to check
 * @return				True if the color exists, false otherwise
 */
stock bool CColorExists(const char[] color) {
	CCheckMap();
	int temp;
	return CMap.GetValue(color, temp);
}

/**
 * Returns the hexadecimal representation of a client's team color (will NOT initialize the trie)
 *
 * @param client		Client to get the team color for
 * @return				Client's team color in hexadecimal, or green if unknown
 * On error/Errors:		If the client index passed is invalid or not in game.
 */
stock int CGetTeamColor(int client) {
	if(client <= 0 || client > MaxClients) {
		ThrowError("Invalid client index %i", client);
	}
	if(!IsClientInGame(client)) {
		ThrowError("Client %i is not in game", client);
	}
	int value;
	switch(GetClientTeam(client)) {
		case 1: {
			value = COLOR_GRAY;
		}
		case 2: {
			value = COLOR_RED;
		}
		case 3: {
			value = COLOR_BLUE;
		}
		default: {
			value = COLOR_GREEN;
		}
	}
	return value;
}

stock StringMap InitColorMap() {
	StringMap hMap = new StringMap();
	hMap.SetValue("aliceblue", 0xF0F8FF);
	hMap.SetValue("allies", 0x4D7942); // same as Allies team in DoD:S
	hMap.SetValue("ancient", 0xEB4B4B); // same as Ancient item rarity in Dota 2
	hMap.SetValue("antiquewhite", 0xFAEBD7);
	hMap.SetValue("aqua", 0x00FFFF);
	hMap.SetValue("aquamarine", 0x7FFFD4);
	hMap.SetValue("arcana", 0xADE55C); // same as Arcana item rarity in Dota 2
	hMap.SetValue("axis", 0xFF4040); // same as Axis team in DoD:S
	hMap.SetValue("azure", 0x007FFF);
	hMap.SetValue("beige", 0xF5F5DC);
	hMap.SetValue("bisque", 0xFFE4C4);
	hMap.SetValue("black", 0x000000);
	hMap.SetValue("blanchedalmond", 0xFFEBCD);
	hMap.SetValue("blue", 0x99CCFF); // same as BLU/Counter-Terrorist team color
	hMap.SetValue("blueviolet", 0x8A2BE2);
	hMap.SetValue("brown", 0xA52A2A);
	hMap.SetValue("burlywood", 0xDEB887);
	hMap.SetValue("cadetblue", 0x5F9EA0);
	hMap.SetValue("chartreuse", 0x7FFF00);
	hMap.SetValue("chocolate", 0xD2691E);
	hMap.SetValue("collectors", 0xAA0000); // same as Collector's item quality in TF2
	hMap.SetValue("common", 0xB0C3D9); // same as Common item rarity in Dota 2
	hMap.SetValue("community", 0x70B04A); // same as Community item quality in TF2
	hMap.SetValue("coral", 0xFF7F50);
	hMap.SetValue("cornflowerblue", 0x6495ED);
	hMap.SetValue("cornsilk", 0xFFF8DC);
	hMap.SetValue("corrupted", 0xA32C2E); // same as Corrupted item quality in Dota 2
	hMap.SetValue("crimson", 0xDC143C);
	hMap.SetValue("cyan", 0x00FFFF);
	hMap.SetValue("darkblue", 0x00008B);
	hMap.SetValue("darkcyan", 0x008B8B);
	hMap.SetValue("darkgoldenrod", 0xB8860B);
	hMap.SetValue("darkgray", 0xA9A9A9);
	hMap.SetValue("darkgrey", 0xA9A9A9);
	hMap.SetValue("darkgreen", 0x006400);
	hMap.SetValue("darkkhaki", 0xBDB76B);
	hMap.SetValue("darkmagenta", 0x8B008B);
	hMap.SetValue("darkolivegreen", 0x556B2F);
	hMap.SetValue("darkorange", 0xFF8C00);
	hMap.SetValue("darkorchid", 0x9932CC);
	hMap.SetValue("darkred", 0x8B0000);
	hMap.SetValue("darksalmon", 0xE9967A);
	hMap.SetValue("darkseagreen", 0x8FBC8F);
	hMap.SetValue("darkslateblue", 0x483D8B);
	hMap.SetValue("darkslategray", 0x2F4F4F);
	hMap.SetValue("darkslategrey", 0x2F4F4F);
	hMap.SetValue("darkturquoise", 0x00CED1);
	hMap.SetValue("darkviolet", 0x9400D3);
	hMap.SetValue("deeppink", 0xFF1493);
	hMap.SetValue("deepskyblue", 0x00BFFF);
	hMap.SetValue("dimgray", 0x696969);
	hMap.SetValue("dimgrey", 0x696969);
	hMap.SetValue("dodgerblue", 0x1E90FF);
	hMap.SetValue("exalted", 0xCCCCCD); // same as Exalted item quality in Dota 2
	hMap.SetValue("firebrick", 0xB22222);
	hMap.SetValue("floralwhite", 0xFFFAF0);
	hMap.SetValue("forestgreen", 0x228B22);
	hMap.SetValue("frozen", 0x4983B3); // same as Frozen item quality in Dota 2
	hMap.SetValue("fuchsia", 0xFF00FF);
	hMap.SetValue("fullblue", 0x0000FF);
	hMap.SetValue("fullred", 0xFF0000);
	hMap.SetValue("gainsboro", 0xDCDCDC);
	hMap.SetValue("genuine", 0x4D7455); // same as Genuine item quality in TF2
	hMap.SetValue("ghostwhite", 0xF8F8FF);
	hMap.SetValue("gold", 0xFFD700);
	hMap.SetValue("goldenrod", 0xDAA520);
	hMap.SetValue("gray", 0xCCCCCC); // same as spectator team color
	hMap.SetValue("grey", 0xCCCCCC);
	hMap.SetValue("green", 0x3EFF3E);
	hMap.SetValue("greenyellow", 0xADFF2F);
	hMap.SetValue("haunted", 0x38F3AB); // same as Haunted item quality in TF2
	hMap.SetValue("honeydew", 0xF0FFF0);
	hMap.SetValue("hotpink", 0xFF69B4);
	hMap.SetValue("immortal", 0xE4AE33); // same as Immortal item rarity in Dota 2
	hMap.SetValue("indianred", 0xCD5C5C);
	hMap.SetValue("indigo", 0x4B0082);
	hMap.SetValue("ivory", 0xFFFFF0);
	hMap.SetValue("khaki", 0xF0E68C);
	hMap.SetValue("lavender", 0xE6E6FA);
	hMap.SetValue("lavenderblush", 0xFFF0F5);
	hMap.SetValue("lawngreen", 0x7CFC00);
	hMap.SetValue("legendary", 0xD32CE6); // same as Legendary item rarity in Dota 2
	hMap.SetValue("lemonchiffon", 0xFFFACD);
	hMap.SetValue("lightblue", 0xADD8E6);
	hMap.SetValue("lightcoral", 0xF08080);
	hMap.SetValue("lightcyan", 0xE0FFFF);
	hMap.SetValue("lightgoldenrodyellow", 0xFAFAD2);
	hMap.SetValue("lightgray", 0xD3D3D3);
	hMap.SetValue("lightgrey", 0xD3D3D3);
	hMap.SetValue("lightgreen", 0x99FF99);
	hMap.SetValue("lightpink", 0xFFB6C1);
	hMap.SetValue("lightsalmon", 0xFFA07A);
	hMap.SetValue("lightseagreen", 0x20B2AA);
	hMap.SetValue("lightskyblue", 0x87CEFA);
	hMap.SetValue("lightslategray", 0x778899);
	hMap.SetValue("lightslategrey", 0x778899);
	hMap.SetValue("lightsteelblue", 0xB0C4DE);
	hMap.SetValue("lightyellow", 0xFFFFE0);
	hMap.SetValue("lime", 0x00FF00);
	hMap.SetValue("limegreen", 0x32CD32);
	hMap.SetValue("linen", 0xFAF0E6);
	hMap.SetValue("magenta", 0xFF00FF);
	hMap.SetValue("maroon", 0x800000);
	hMap.SetValue("mediumaquamarine", 0x66CDAA);
	hMap.SetValue("mediumblue", 0x0000CD);
	hMap.SetValue("mediumorchid", 0xBA55D3);
	hMap.SetValue("mediumpurple", 0x9370D8);
	hMap.SetValue("mediumseagreen", 0x3CB371);
	hMap.SetValue("mediumslateblue", 0x7B68EE);
	hMap.SetValue("mediumspringgreen", 0x00FA9A);
	hMap.SetValue("mediumturquoise", 0x48D1CC);
	hMap.SetValue("mediumvioletred", 0xC71585);
	hMap.SetValue("midnightblue", 0x191970);
	hMap.SetValue("mintcream", 0xF5FFFA);
	hMap.SetValue("mistyrose", 0xFFE4E1);
	hMap.SetValue("moccasin", 0xFFE4B5);
	hMap.SetValue("mythical", 0x8847FF); // same as Mythical item rarity in Dota 2
	hMap.SetValue("navajowhite", 0xFFDEAD);
	hMap.SetValue("navy", 0x000080);
	hMap.SetValue("normal", 0xB2B2B2); // same as Normal item quality in TF2
	hMap.SetValue("oldlace", 0xFDF5E6);
	hMap.SetValue("olive", 0x9EC34F);
	hMap.SetValue("olivedrab", 0x6B8E23);
	hMap.SetValue("orange", 0xFFA500);
	hMap.SetValue("orangered", 0xFF4500);
	hMap.SetValue("orchid", 0xDA70D6);
	hMap.SetValue("palegoldenrod", 0xEEE8AA);
	hMap.SetValue("palegreen", 0x98FB98);
	hMap.SetValue("paleturquoise", 0xAFEEEE);
	hMap.SetValue("palevioletred", 0xD87093);
	hMap.SetValue("papayawhip", 0xFFEFD5);
	hMap.SetValue("peachpuff", 0xFFDAB9);
	hMap.SetValue("peru", 0xCD853F);
	hMap.SetValue("pink", 0xFFC0CB);
	hMap.SetValue("plum", 0xDDA0DD);
	hMap.SetValue("powderblue", 0xB0E0E6);
	hMap.SetValue("purple", 0x800080);
	hMap.SetValue("rare", 0x4B69FF); // same as Rare item rarity in Dota 2
	hMap.SetValue("red", 0xFF4040); // same as RED/Terrorist team color
	hMap.SetValue("rosybrown", 0xBC8F8F);
	hMap.SetValue("royalblue", 0x4169E1);
	hMap.SetValue("saddlebrown", 0x8B4513);
	hMap.SetValue("salmon", 0xFA8072);
	hMap.SetValue("sandybrown", 0xF4A460);
	hMap.SetValue("seagreen", 0x2E8B57);
	hMap.SetValue("seashell", 0xFFF5EE);
	hMap.SetValue("selfmade", 0x70B04A); // same as Self-Made item quality in TF2
	hMap.SetValue("sienna", 0xA0522D);
	hMap.SetValue("silver", 0xC0C0C0);
	hMap.SetValue("skyblue", 0x87CEEB);
	hMap.SetValue("slateblue", 0x6A5ACD);
	hMap.SetValue("slategray", 0x708090);
	hMap.SetValue("slategrey", 0x708090);
	hMap.SetValue("snow", 0xFFFAFA);
	hMap.SetValue("springgreen", 0x00FF7F);
	hMap.SetValue("steelblue", 0x4682B4);
	hMap.SetValue("strange", 0xCF6A32); // same as Strange item quality in TF2
	hMap.SetValue("tan", 0xD2B48C);
	hMap.SetValue("teal", 0x008080);
	hMap.SetValue("thistle", 0xD8BFD8);
	hMap.SetValue("tomato", 0xFF6347);
	hMap.SetValue("turquoise", 0x40E0D0);
	hMap.SetValue("uncommon", 0xB0C3D9); // same as Uncommon item rarity in Dota 2
	hMap.SetValue("unique", 0xFFD700); // same as Unique item quality in TF2
	hMap.SetValue("unusual", 0x8650AC); // same as Unusual item quality in TF2
	hMap.SetValue("valve", 0xA50F79); // same as Valve item quality in TF2
	hMap.SetValue("vintage", 0x476291); // same as Vintage item quality in TF2
	hMap.SetValue("violet", 0xEE82EE);
	hMap.SetValue("wheat", 0xF5DEB3);
	hMap.SetValue("white", 0xFFFFFF);
	hMap.SetValue("whitesmoke", 0xF5F5F5);
	hMap.SetValue("yellow", 0xFFFF00);
	hMap.SetValue("yellowgreen", 0x9ACD32);
	return hMap;
}
