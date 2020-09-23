methodmap FF2Player < VSH2Player {
	public FF2Player(const int index, bool userid=false) {
		return view_as< FF2Player >(VSH2Player(index, userid));
	}
	
	property int iMaxLives {
		public get() {
			return this.GetPropInt("iMaxLives");
		}
		public set(int val) {
			this.SetPropInt("iMaxLives", val);
		}
	}
	
	property int iRageDmg {
		public get() {
			return this.GetPropInt("iRageDmg");
		}
		public set(int val) {
			this.SetPropInt("iRageDmg", val);
		}
	}
	
	property int iCfg {
		public get() {
			return this.GetPropInt("iCfg");
		}
		public set(int val) {
			this.SetPropInt("iCfg", val);
		}
	}
	
	property int iShieldId {
		public get() {
			return this.GetPropInt("iShieldId");
		}
		public set(int val) {
			this.SetPropInt("iShieldId", val);
		}
	}
	
	property float iShieldHP {
		public get() {
			return this.GetPropFloat("iShieldHP");
		}
		public set(float val) {
			this.SetPropFloat("iShieldHP", val);
		}
	}
	
	property int iFlags {
		public get() {
			return this.GetPropInt("iFlags");
		}
		public set(int flag) {
			this.SetPropInt("iFlags", flag);
		}
	}
	
	public any GetRageInfo(m_iRageInfo Info) {
		switch( Info ) {
			case iRageMode: {
				return this.GetPropInt("iRageMode");
			}
			case iRageMin: {
				return this.GetPropFloat("iRageMin");
			}
			case iRageMax: {
				return this.GetPropInt("iRageMax");
			}
			default: {
				return 0;
			}
		}
	}
	
	public bool SetRageInfo(m_iRageInfo Info, any val) {
		switch( Info ) {
			case iRageMode: {
				return this.SetPropInt("iRageMode", val);
			}
			case iRageMin: {
				return this.SetPropFloat("iRageMin", val);
			}
			case iRageMax: {
				return this.SetPropFloat("iRageMax", val);
			}
			default: {
				return false;
			}
		}
	}
	
	public void PlayBGM(const char[] music) {
		this.PlayMusic(vsh2cvars.m_flmusicvol.FloatValue, music);
	}
	
	public void SetTimedOverlay(const char[] path, float time=0.0) {
		this.SetOverlay(path);
		if( time )
			CreateTimer(time, Timer_RemoveOverlay, GetClientSerial(this.index), TIMER_FLAG_NO_MAPCHANGE);
	}
}

stock FF2Player ToFF2Player(VSH2Player p)
{
	return view_as< FF2Player >(p);
}

stock int ClientToBossIndex(int client)
{
	FF2Player[] players = new FF2Player[MaxClients];
	int amount_of_bosses = VSH2GameMode.GetBosses(players, false);
	if( amount_of_bosses > 0 ) {
		for( int i; i<amount_of_bosses; i++ ) {
			if( players[i].index==client ) {
				if( i==0 )
					return 0;
				else return players[i].index;
			}
		}
	}
	return -1;
}

stock bool ZeroBossToFF2Player(FF2Player& player)
{
	FF2Player[] players = new FF2Player[MaxClients];
	if( VSH2GameMode.GetBosses(players, false) < 1 )
		return false;
	
	player = players[0];
	return true;
}

stock ConfigMap GetFF2Config(const int index=0, const bool is_cfg_index=false)
{
	int cfg_index = -1;
	if( is_cfg_index && index > -1 && index < ff2.m_bosscfgs.Length ) {
		cfg_index = index;
	} else if( IsClientValid(index) ) {
		FF2Player player = FF2Player(index);
		if( player.iCfg > -1 && player.iCfg < ff2.m_bosscfgs.Length )
			cfg_index = player.iCfg;
	}
	return( cfg_index != -1 ) ? ff2.m_bosscfgs.Get(cfg_index) : view_as<ConfigMap>(null);
}

stock ConfigMap GetMyCharacterCfg(int boss) {
	return GetFF2Config(boss).GetSection("character");
}

stock ConfigMap JumpToAbility(const ConfigMap section, const char[] plugin_name, const char[] ability_name)
{
	int i;
	char[] key = new char[64];
	char key_name[64];
	while( i < MAX_SUBPLUGIN_NAME ) {
		FormatEx(key, 64, "ability%i.name", ++i);
		if( !section.Get(key, key_name, sizeof(key_name)) )
			break;
		else if( strcmp(key_name, ability_name) )
			continue;
		
		ReplaceString(key, 64, ".name", ".plugin_name");
		if( !section.Get(key, key_name, sizeof(key_name)) )
			break;
		else if( strcmp(key_name, plugin_name) )
			continue;
		
		FormatEx(key, 64, "ability%i", i);
		return section.GetSection(key);
	}
	return null;
}


stock int GetArgNamedI(int boss, const char[] plugin_name, const char[] ability_name, const char[] argument, int defval = 0)
{
	ConfigMap section = JumpToAbility(GetMyCharacterCfg(boss), plugin_name, ability_name);
	if( section==null ) {
		return defval;
	}
	
	int result;
	return section.GetInt(argument, result) ? result:defval;
}

stock float GetArgNamedF(int boss, const char[] plugin_name, const char[] ability_name, const char[] argument, float defval = 0.0)
{
	ConfigMap section = JumpToAbility(GetMyCharacterCfg(boss), plugin_name, ability_name);
	if( section==null ) {
		return defval;
	}
	
	float result;
	return section.GetFloat(argument, result) ? result:defval;
}

stock int GetArgNamedS(int boss, const char[] plugin_name, const char[] ability_name, const char[] argument, char[] result, int &size)
{
	ConfigMap section = JumpToAbility(GetMyCharacterCfg(boss), plugin_name, ability_name);
	if( section==null ) {
		return 0;
	}
	return section.Get(argument, result, size);
}

stock void FPrintToChat(int client, const char[] message, any ...)
{
	SetGlobalTransTarget(client);
	char buffer[192];
	VFormat(buffer, sizeof(buffer), message, 3);
	CPrintToChat(client, "{olive}[VSH2/FF2]{default} %s",  buffer);
}

stock float FF2_GetCustomCharge(int boss=0, int slot)
{
	FF2Player player = FF2Player(boss);
	char ability_key[64];
	Format(ability_key, sizeof(ability_key), "character.ability%i.name", slot);
	ConfigMap config = GetFF2Config(boss);
	int len = config.GetSize(ability_key);
	char[] ability_name = new char[len];
	if( config.Get(ability_key, ability_name, len) ) {
		if( StrContains(ability_name, "weighdown", false) != -1 ) {
			return player.GetPropFloat("flWeighDown");
		} else if( StrContains(ability_name, "bravejump", false) != -1 ) {
			return player.GetPropFloat("flCharge");
		} else {
			char new_ability[64];
			Format(new_ability, sizeof(ability_key), "flCharge%i", slot);
			return player.GetPropFloat(new_ability);
		}
	}
	return 0.0;
}

stock bool FF2_SetCustomCharge(int boss=0, int slot, float value)
{
	FF2Player player = FF2Player(boss);
	char ability_key[64];
	Format(ability_key, sizeof(ability_key), "character.ability%i.name", slot);
	ConfigMap config = GetFF2Config(boss);
	int len = config.GetSize(ability_key);
	char[] ability_name = new char[len];
	if( config.Get(ability_key, ability_name, len) ) {
		if( StrContains(ability_name, "weighdown", false) != -1 ) {
			return player.SetPropFloat("flWeighDown", value);
		} else if( StrContains(ability_name, "bravejump", false) != -1 ) {
			return player.SetPropFloat("flCharge", value);
		} else {
			char new_ability[64];
			Format(new_ability, sizeof(ability_key), "flCharge%i", slot);
			return player.SetPropFloat(new_ability, value);
		}
	}
	return false;
}