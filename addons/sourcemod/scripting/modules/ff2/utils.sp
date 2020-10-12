#define INVALID_FF2_BOSS_ID -1

#define ToFF2Player(%0)		view_as<FF2Player>(%0)

/// a dynamic hash map, that holds cfg path to aiblities. eg: { { "pl_name##ab_name", "ability1" }, { "pl_name##ab_name", "ability2" }, ... }
methodmap FF2AbilityList < StringMap {
	public FF2AbilityList() {
		return view_as<FF2AbilityList>(new StringMap());
	}
	
	public void Insert(const char[] key, const char[] str) {
		this.SetString(key, str);
	}
	
	public static void GetKeyVal(const char[] key, char[][] pl_ab)
	{
		ExplodeString(key, "##", pl_ab, 2, MAX_SUBPLUGIN_NAME);
	}
}

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
	
	property ConfigMap iCfg {
		public get() {
			return view_as<ConfigMap>(this.GetPropAny("iCfg"));
		}
		public set(ConfigMap cfg) {
			this.SetPropAny("iCfg", cfg);
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
	
	property FF2AbilityList HookedAbilities {
		public get() {
			FF2AbilityList ab;
			return this.SetPropAny("hHookedAbilties", ab) ? ab:null;
		}
		public set(FF2AbilityList hk) {
			this.SetPropAny("hHookedAbilties", hk);
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
	
	public bool RandomSnd(const char[] section_key, char[] file, int maxlen, char[] key = "") {
		ConfigMap section = this.iCfg.GetSection(section_key);
		if( section==null )
			return false;
	
		int sounds;
		int[] match = new int[16];
		int total;
		
		while( ++sounds ) {
			IntToString(sounds, key, 4);
			if( !section.Get(key, file, maxlen) ) {
				sounds--;
				break;
			}
			match[total++] = sounds;
		}
		
		if( !total )
			return false;
		
		IntToString(match[GetRandomInt(0, total - 1)], key, 4);
		return view_as<bool>(section.Get(key, file, maxlen));	
	}
	
	public bool RandomAbilitySnd(const char[] section_key, char[] file, int maxlen, int slot) {
		ConfigMap section = this.iCfg.GetSection(section_key);
		if( section==null )
			return false;
	
		char key[10];
		int sounds;
		int[] match = new int[16];
		int total;
		int found;
		
		while( ++sounds ) {
			IntToString(sounds, key, 4);
			if( !section.Get(key, file, maxlen) ) {
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
		return view_as<bool>(section.Get(key, file, maxlen));	
	}
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

stock ConfigMap GetFF2Config(const int index=0)
{
	/*
	int cfg_index = -1;
	if( is_cfg_index && index > -1 && index < ff2.m_bosscfgs.Length ) {
		cfg_index = index;
	} else if( IsClientValid(index) ) {
		FF2Player player = FF2Player(index);
		if( player.iCfg > -1 && player.iCfg < ff2.m_bosscfgs.Length )
			cfg_index = player.iCfg;
	}
	return( cfg_index != -1 ) ? ff2.m_bosscfgs.Get(cfg_index) : view_as<ConfigMap>(null);
	*/
	return FF2Player(index).iCfg;
}

stock ConfigMap GetMyCharacterCfg(int boss) {
	return GetFF2Config(boss).GetSection("character");
}

stock ConfigMap JumpToAbility(const FF2Player player, const char[] plugin_name, const char[] ability_name)
{
	FF2AbilityList list = player.HookedAbilities;
	
	char actual_key[128];
	FormatEx(actual_key, sizeof(actual_key), "%s##%s", plugin_name, ability_name);
	
	ConfigMap ability = null;
	char pos[24];
	if ( list.GetString(actual_key, pos, sizeof(pos)) ) {
		ability = player.iCfg.GetSection(pos);
	}
	return ability;
}

stock int GetArgNamedI(int boss, const char[] plugin_name, const char[] ability_name, const char[] argument, int defval = 0)
{
	ConfigMap section = JumpToAbility(FF2Player(boss), plugin_name, ability_name);
	if( section==null ) {
		return defval;
	}
	
	int result;
	return section.GetInt(argument, result) ? result:defval;
}

stock float GetArgNamedF(int boss, const char[] plugin_name, const char[] ability_name, const char[] argument, float defval = 0.0)
{
	ConfigMap section = JumpToAbility(FF2Player(boss), plugin_name, ability_name);
	if( section==null ) {
		return defval;
	}
	
	float result;
	return section.GetFloat(argument, result) ? result:defval;
}

stock int GetArgNamedS(int boss, const char[] plugin_name, const char[] ability_name, const char[] argument, char[] result, int &size)
{
	ConfigMap section = JumpToAbility(FF2Player(boss), plugin_name, ability_name);
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

stock int FF2_RegisterFakeBoss(const char[] name)
{
	if(	strlen(name) >= MAX_BOSS_NAME_SIZE - 6 )
		return INVALID_FF2_BOSS_ID;
	char final_name[MAX_BOSS_NAME_SIZE];
	FormatEx(final_name, sizeof(final_name), "%s_FF2", name);
	return VSH2_RegisterPlugin(final_name);
}
