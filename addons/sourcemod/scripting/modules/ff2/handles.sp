stock void ActivateAbilitySlot(int boss, int slot, bool buttonmodeactive=true)
{
	ConfigMap character = GetMyCharacterCfg(boss);
	if( character==null )
		return;
	
	int i;
	char[] key = new char[64]; 
	char lives[MAX_SUBPLUGIN_NAME][3];
	ConfigMap ability;
	while( i < MAX_SUBPLUGIN_NAME ) {
		FormatEx(key, 64, "ability%i", ++i);
		ability = character.GetSection(key);
		if( ability==null )
			break;
		
		int _var;
		if( !ability.GetInt("slot", _var) && !_var)
			ability.GetInt("arg0", _var);
		
		if( _var != slot )
			continue;
		
		_var = buttonmodeactive && ability.GetInt("buttonmode", _var) ? _var : 0;
		static char ability_name[64], plugin_name[64];
		
		if( !ability.Get("life", key, 64) ) {
			ability.Get("name", ability_name, sizeof(ability_name));
			ability.Get("plugin_name", plugin_name, sizeof(plugin_name));
			if( !UseAbility(plugin_name, ability_name, boss, slot) ) 
				break;
		}
		else {
			int count = ExplodeString(key, " ", lives, sizeof(lives[]), sizeof(lives[][]));
			FF2Player player = FF2Player(boss);
			int iLives = player.GetPropInt("iLives");
			while( --count >= 0 ) {
				if( StringToInt(lives[count])==iLives ) {
					ability.Get("name", ability_name, sizeof(ability_name));
					ability.Get("plugin_name", plugin_name, sizeof(plugin_name));
					if( !UseAbility(plugin_name, ability_name, boss, slot) ) 
						return;
					break;
				}
			}
		}
	}
}

stock bool RandomSound(const char[] sound, char[] file, int size, int boss=0)
{
	ConfigMap cfg = GetMyCharacterCfg(boss);
	if( boss < 0 || cfg==null )
		return false;
	
	ConfigMap section = cfg.GetSection(sound);
	if( section==null )
		return false;
	
	char path[PLATFORM_MAX_PATH];
	char key[36];
	
	int sounds = section.Size;
	if( !sounds )
		return false;
	
	int rand = GetRandomInt(1, sounds);
	
	FormatEx(key, sizeof(key), "%i_overlay", rand);
	section.Get(key, path, sizeof(path));
	if( path[0] ) {
		FF2Player player = FF2Player(boss);
		TFTeam iteam = TF2_GetClientTeam(player.index);
		
		FormatEx(key, sizeof(key), "%i_overlay_time", rand);
		float time; section.GetFloat(key, time);
		
		for( int i=1; i<=MaxClients; i++ ) {
			if( IsValidClient(i) && TF2_GetClientTeam(i) != iteam ) {
				player.SetTimedOverlay(path, time);
			}
		}
	}
	
	FormatEx(key, sizeof(key), "%imusic", rand);
	section.Get(key, path, sizeof(path));
	if( path[0] ) {
		float time;	section.GetFloat(key, time);
		static char name[64], artist[64];
		
		IntToString(rand, key, sizeof(key));
		section.Get(key, path, sizeof(path));
		
		FormatEx(key, sizeof(key), "%iname", rand);
		section.Get(key, name, sizeof(name));
		
		FormatEx(key, sizeof(key), "%iartist", rand);
		section.Get(key, artist, sizeof(artist));
		
		for( int i=1; i<=MaxClients; i++ ) {
			if( i && IsValidClient(i) ) {
				PlayBGM(i, path, time, name, artist);
			}
		}
		return false;
	}
	
	IntToString(rand, key, sizeof(key));
	return view_as< bool >(section.Get(key, file, size));
}

stock bool RandomSoundAbility(const char[] sound, char[] file, int length, int boss=0, int slot=0)
{
	ConfigMap character = GetMyCharacterCfg(boss);
	if( boss < 0 || character==null )
		return false;
	
	ConfigMap section = character.GetSection(sound);
	if( section==null )
		return false;

	char key[10];
	int sounds;
	int[] match = new int[16];
	int total;
	int found;
	
	while( ++sounds ) {
		IntToString(sounds, key, 4);
		if( !section.Get(key, file, length) ) {
			sounds--;
			break;
		}
		
		FormatEx(key, sizeof(key), "slot%i", sounds);
		if( section.GetInt(key, found) && found == slot ) {
			match[total++] = sounds;
		}
	}
	
	if( !total )
		return false;
	
	IntToString(match[GetRandomInt(0, total - 1)], key, 4);
	return view_as<bool>(section.Get(key, file, length));
}

stock bool UseAbility(const char[] plugin_name, const char[] ability_name, int boss=0, int slot, int buttonMode)
{
	Call_StartForward(ff2.m_forwards[FF2OnPreAbility]);
	Call_PushCell(boss);
	Call_PushString(plugin_name);
	Call_PushString(ability_name);
	Call_PushCell(slot);
	bool enabled = true;
	Call_PushCellRef(enabled);
	Call_Finish();
	
	if( !enabled )
		return false;
	
	Action action = Plugin_Continue;
	Call_StartForward(ff2.m_forwards[FF2OnAbility]);
	Call_PushCell(boss);
	Call_PushString(plugin_name);
	Call_PushString(ability_name);
	
	FF2Player player = FF2Player(boss);
	
	switch( slot ) {
		case 0: {
			player.iFlags &=~ (1<<5);
			Call_PushCell(3);
			Call_Finish(action);
			
			if( player.GetPropInt("bUsedUltimate") ) {
				if( player.GetRageInfo(iRageMode) == 1 ) {
					float charge = FF2_GetCustomCharge(boss, slot) - player.GetRageInfo(iRageMin);
					if( charge <= 0 )
						charge = 0.0;
					FF2_SetCustomCharge(boss, slot, charge);
				} else if( !player.GetRageInfo(iRageMode) ) {
					FF2_SetCustomCharge(boss, slot, 0.0);
				}
			}
		}
		case 1, 2, 3: {
			SetHudTextParams(-1.0, 0.88, 0.15, 255, 255, 255, 255);
			int button;
			switch( buttonMode ) {
				case 1: button = IN_DUCK|IN_ATTACK2;
				case 2: button = IN_RELOAD;
				case 3: button = IN_ATTACK3;
				case 4: button = IN_DUCK;
				case 5: button = IN_SCORE;
				default: button = IN_ATTACK2;
			}
			
			int client = player.index;
			float charge = FF2_GetCustomCharge(boss, slot);
			if( GetClientButtons(client) & button ) {
				if( charge >= 0.0 ) {
					Call_PushCell(2);
					Call_Finish(action);
					float add;
					
					if( GetArgNamedI(boss, plugin_name, ability_name, "slot", -2) != -2 ) {
						add = 100.0*0.2/GetArgNamedF(boss, plugin_name, ability_name, "charge time", 1.5);
					} else {
						add = 100.0*0.2/GetArgNamedF(boss, plugin_name, ability_name, "arg1", 1.5);
					}
					charge += add;
					if( charge > 100.0 )
						charge = 100.0;
					FF2_SetCustomCharge(boss, slot, charge);
				} else {
					Call_PushCell(1);
					Call_Finish(action);
					FF2_SetCustomCharge(boss, slot, charge + 0.2);
				}
			} else if( charge > 0.3 ) {
				float vecAng[3];
				GetClientEyeAngles(client, vecAng);
				if( vecAng[0] < -5.0 ) {
					///VSH2Player::SuperJumpThink?
					///TODO
					Call_PushCell(3);
					Call_Finish(action);
					DataPack data;
					CreateDataTimer(0.1, Timer_UseBossCharge, data);
					data.WriteCell(boss);
					data.WriteCell(slot);
					if( GetArgNamedI(boss, plugin_name, ability_name, "slot", -2) != -2 ) {
						data.WriteFloat(-1.0*GetArgNamedF(boss, plugin_name, ability_name, "cooldown", 5.0));
					} else {
						data.WriteFloat(-1.0*GetArgNamedF(boss, plugin_name, ability_name, "arg2", 5.0));
					}
				} else {
					Call_PushCell(0);
					Call_Finish(action);
					FF2_SetCustomCharge(boss, slot, 0.0);
				}
			} else if( charge >= 0.0 ) {
				Call_PushCell(0);
				Call_Finish(action);
			} else {
				Call_PushCell(1);
				Call_Finish(action);
				FF2_SetCustomCharge(boss, slot, charge + 0.2);
			}
		}
		default: {
			Call_PushCell(3);
			Call_Finish(action);
		}
	}
	
	return true;
}

public Action Timer_RemoveOverlay(Handle Timer, any iSerial)
{
	int client = GetClientFromSerial(iSerial);
	if( !client || !IsPlayerAlive(client) )
		return Plugin_Continue;
	
	int flags = GetCommandFlags("r_screenoverlay");
	SetCommandFlags("r_screenoverlay", flags & ~FCVAR_CHEAT);
	ClientCommand(client, "r_screenoverlay off");
	SetCommandFlags("r_screenoverlay", flags);
	return Plugin_Continue;
}

stock void PlayBGM(int client, char[] music, float time, char[] name="", char[] artist="")
{
	static char nFile[64]; FormatEx(nFile, sizeof(nFile), "sound/%s", music);
	if( !FileExists(nFile, true) ) {
		ConfigMap character = GetMyCharacterCfg(0);
		if( character==null ) {
			LogError("[VSH2/FF2] Invalid Boss Config with a missing BGM file: \"%s\"!!", music);
		} else {
			character.Get("name", nFile, sizeof(nFile));
			LogError("[VSH2/FF2] Character: \"%s\" is missing BGM file:\"%s\"!", music);
		}
		return;
	}
	
	FF2Player player = FF2Player(client);
	player.StopMusic();
	player.PlayBGM(music);
	
	FPrintToChat(client, "Now Playing: {blue}%s{default} - {orange}%s{default}", !artist[0] ? "Unknown Song":artist, !name[0] ? "Unknown Artist":name);
}

public Action Timer_UseBossCharge(Handle Timer, DataPack data)
{
	data.Reset();
	int boss = data.ReadCell();
	int slot = data.ReadCell();
	float cd = data.ReadFloat();
	FF2_SetCustomCharge(boss, slot, cd);
}