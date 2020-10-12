
/// dynamic array that holds sounds for key.
methodmap FF2SoundList < ArrayList
{
	property bool Empty {
		public get() {
			return this.Length == 0;
		}
	}
	
	public FF2SoundList()
	{
		return view_as<FF2SoundList>(new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH)));
	}
	
	public void At(int idx, char[] buffer, int maxlen)
	{
		this.GetString(idx, buffer, maxlen);
	}
	
	public bool RandomString(char[] buffer, int maxlen)
	{
		if(!this.Empty) {
			int rand = GetRandomInt(0, this.Length - 1);
			this.GetString(rand, buffer, maxlen);
			return true;
		}
		return false;
	}
}

/// a hash map that holds keys to sound list.
methodmap FF2SoundHash < StringMap 
{
	public FF2SoundHash()
	{
		return view_as<FF2SoundHash>(new StringMap());
	}
	
	public FF2SoundList GetOrCreateList(const char[] key)
	{
		FF2SoundList list;
		if(this.GetValue(key, list) && list) {
			return list;
		}
		
		list = new FF2SoundList();
		this.SetValue(key, list);
		return list;
	}
	
	public FF2SoundList GetAssertedList(const char[] key)
	{
		FF2SoundList list;
		if(this.GetValue(key, list) && list) {
			return list;
		}
		
		ThrowError("Failed to get list!");
		return null;
	}
	
	public void Delete(const char[] key)
	{
		FF2SoundList list;
		if(this.GetValue(key, list)) {
			delete list;
		}
		this.Remove(key);
	}
	
	public void DeleteAll()
	{
		StringMapSnapshot snap = this.Snapshot();
		
		char name[48];
		FF2SoundList list;
		
		for ( int i = snap.Length - 1; i >= 0; i-- ) {
			snap.GetKey(i, name, sizeof(name));
			if(this.GetValue(name, list)) {
				delete list;
			}
		}
		
		this.Clear();
		delete snap;
	}
}

enum struct FF2Identity
{
	int 			VSH2ID;
	ConfigMap 		hCfg;
	FF2SoundHash 	sndHash;
	FF2AbilityList 	ablist;
	char 			szName[48];
	char 			szPath[PLATFORM_MAX_PATH];
}


static const char script_sounds[][] = {
	"Announcer.AM_CapEnabledRandom",
	"Announcer.AM_CapIncite01.mp3",
	"Announcer.AM_CapIncite02.mp3",
	"Announcer.AM_CapIncite03.mp3",
	"Announcer.AM_CapIncite04.mp3",
	"Announcer.RoundEnds5minutes",
	"Announcer.RoundEnds2minutes"
};

static const char basic_sounds[][] = {
	"weapons/barret_arm_zap.wav",
	"player/doubledonk.wav",
	"ambient/lightson.wav",
	"ambient/lightsoff.wav",
};

#define RELEASE_IDENTITY(%0) \
		identity.sndHash.DeleteAll(); \
		delete identity.sndHash; \
		delete identity.hCfg; \
		delete identity.ablist

static bool FF2_LoadCharacter(FF2Identity identity)
{
	///Precache HERE!
	char path[PLATFORM_MAX_PATH], key_name[PLATFORM_MAX_PATH];
	
	FormatEx(key_name, sizeof(key_name), "configs/freak_fortress_2/%s.cfg", identity.szName);
	BuildPath(Path_SM, path, sizeof(path), "%s", key_name);
	
	if(!FileExists(path)) {
		ThrowError("[!!!] Unable to find \"%s\"!", identity.szName);
	}
	
	strcopy(identity.szPath, sizeof(FF2Identity::szPath), path);
	ConfigMap cfg = new ConfigMap(key_name);
	
	if( !cfg) {
		LogError("[VSH2/FF2] Failed to find \"%s\" character!", identity.szName);
		return false;
	}
	
	/*
	TODO
	if(KvJumpToKey(BossKV[Specials], "map_exclude"))
	{
		char item[6];
		static char buffer[34];
		for(int size=1; ; size++)
		{
			FormatEx(item, sizeof(item), "map%d", size);
			KvGetString(BossKV[Specials], item, buffer, sizeof(buffer));
			if(!buffer[0])
				break;

			if(!StrContains(currentmap, buffer))
			{
				MapBlocked[Specials] = true;
				break;
			}
		}
	}
	*/
	
	char buffer[64];
	
	ConfigMap this_char = cfg.GetSection("character");
	identity.ablist = new FF2AbilityList();
	
	{
		ConfigMap cur_ab;
		int i;
		while( ++i < MAX_ABILITIES_PL ) {
			FormatEx(key_name, sizeof(key_name), "ability%i", i);
			
			cur_ab = this_char.GetSection(key_name);
			
			if( !cur_ab || !cur_ab.Get("plugin_name", buffer, sizeof(buffer)) )
				break;
			
			BuildPath(Path_SM, path, sizeof(path), "plugins/freaks/%s.ff2", buffer);
			if( !FileExists(path) ) {
				LogError("[VSH2/FF2] Character \"%s.cfg\" is missing \"%s\" subplugin!", identity.szName, path);
			} 
			else {
				cur_ab.Get("name", path, sizeof(path));
				Format(path, sizeof(path), "%s##%s", buffer, path);
				identity.ablist.Insert(path, key_name);
			}
		}
	}
	
	ConfigMap stacks = this_char.GetSection("download");
	if( stacks ) {
		StringMapSnapshot snap = stacks.Snapshot();
		int size = snap.Length;
		delete snap;
		
		while( size > 0 ) {
			IntToString(size--, key_name, 4);
			if( !this_char.Get(key_name, path, sizeof(path)) )
				break;
			
			if( !FileExists(path, true) ) {
				LogError("[VSH2/FF2] Character \"%s\" is missing file \"%s\"!", identity.szName, path);
			} else {
				AddFileToDownloadsTable(path);
			}
		}
	}
	
	static const char modelT[][] = {
		".mdl",
		".dx80.vtx",
		".dx90.vtx",
		".sw.vtx",
		".vvd",
		".phy"
	};
	
	stacks = this_char.GetSection("mod_download");
	if( stacks ) {
		StringMapSnapshot snap = stacks.Snapshot();
		int size = snap.Length;
		delete snap;
		
		while( size > 0 ) {
			IntToString(size--, key_name, 4);
			if( !stacks.Get(key_name, path, sizeof(path)) )
				break;
			
			for( int i = 0; i < sizeof(modelT); i++ ) {
				FormatEx(key_name, PLATFORM_MAX_PATH, "%s%s", path, modelT[i]);
				if( FileExists(key_name, true) ) {
					AddFileToDownloadsTable(key_name);
				}
				else if( StrContains(key_name, ".phy") == -1 ) {
					LogError("[VSH2/FF2] Character \"%s\" is missing file \"%s\"!", identity.szName, key_name);
				}
			}
		}
	} 
	else {
		stacks = this_char.GetSection("mat_download");
		if( stacks ) {
			StringMapSnapshot snap = stacks.Snapshot();
			int size = snap.Length;
			delete snap;
			
			while( size > 0 ) {
				IntToString(size--, key_name, 4);
				if( stacks.Get(key_name, path, sizeof(path)) )
					break;
					
				FormatEx(key_name, sizeof(key_name), "%s.vmt", path);
				if( !FileExists(key_name, true) ) {
					LogError("[VSH2/FF2] Character \"%s\" is missing file \"%s\"!", identity.szName, key_name);
				} else {
					AddFileToDownloadsTable(key_name);
				}
				
				FormatEx(key_name, sizeof(key_name), "%s.vtf", path);
				if( !FileExists(key_name, true) ) {
					LogError("[VSH2/FF2] Character \"%s\" is missing file \"%s\"!", identity.szName, key_name);
				} else {
					AddFileToDownloadsTable(key_name);
				}
			}
		}
	}
	
	/// Prepare Sound list
	{
		identity.sndHash = new FF2SoundHash();
		StringMapSnapshot snap = this_char.Snapshot();
		ConfigMap snd_list;
		FF2SoundList list;
		
		char curSection[32];
		char strBuffer[PLATFORM_MAX_PATH];
		
		for(int i = snap.Length - 1; i >= 0; i--) {
			snap.GetKey(i, curSection, sizeof(curSection));
			
			if(!StrContains(curSection, "sound")) {
				snd_list = this_char.GetSection(curSection);
				list = identity.sndHash.GetOrCreateList(curSection);
				
				int j;
				while (++j && j <= 15) {
					IntToString(j, curSection, 4);
					if(snd_list.Get(curSection, strBuffer, sizeof(strBuffer))) {
						list.PushString(strBuffer);
					}
					else break;
				}
				
			}
		}
		
		delete snap;
	}
	
	identity.VSH2ID = FF2_RegisterFakeBoss(identity.szName);
	identity.hCfg = cfg;
	
	if ( identity.VSH2ID == INVALID_FF2_BOSS_ID ) {
		RELEASE_IDENTITY(identity);
		return false;
	}
	
	return true;
}


/// a hash map that holds boss' identities
methodmap FF2BossManager < StringMap
{
	public bool GetIdentity(const char[] name, FF2Identity identity)
	{
		return this.GetArray(name, identity, sizeof(FF2Identity)) ? true:false;
	}
	
	public FF2BossManager(const char[] pack_name)
	{
		StringMap map = new StringMap();
		
		/// Parse Boss CFG with pack name
		ConfigMap cfg = ff2.m_charcfg.GetSection(pack_name);
		
		if( !cfg ) ThrowError("Failed to find Section for characters.cfg: \"%s\"", pack_name);
		
		StringMapSnapshot snap = cfg.Snapshot();
		
		char key[4], name[48];
		FF2Identity curIdentity;
		
		/// Iter through the Pack, copy and verify boss path
		for ( int i = snap.Length - 1; i >= 0; i-- ) {
			snap.GetKey(i, key, sizeof(key));
			cfg.Get(key, name, sizeof(name));
			strcopy(curIdentity.szName, sizeof(FF2Identity::szName), name);
			if ( FF2_LoadCharacter(curIdentity) ) {
				map.SetArray(name, curIdentity, sizeof(FF2Identity));
			}
		}
		
		delete snap;
		return view_as<FF2BossManager>(map);
	}
	
	public void Delete(const char[] name)
	{
		FF2Identity identity;
		if(this.GetArray(name, identity, sizeof(FF2Identity))) {
			
			RELEASE_IDENTITY(identity);
			
			this.Remove(name);
		}
	}
	
	public void DeleteAll()
	{
		StringMapSnapshot snap = this.Snapshot();
		char name[48];
		FF2Identity identity;
		
		for ( int i = snap.Length - 1; i >= 0; i-- ) {
			snap.GetKey(i, name, sizeof(name));
			if(this.GetIdentity(name, identity)) {
				RELEASE_IDENTITY(identity);
			}
		}
		
		this.Clear();
		delete snap;
	}
	
	public bool FindIdentity(const int ID, FF2Identity identity)
	{
		StringMapSnapshot snap = this.Snapshot();
		char name[48];
		bool res;
		
		for ( int i = snap.Length - 1; i >= 0; i-- ) {
			snap.GetKey(i, name, sizeof(name));
			if(this.GetIdentity(name, identity) && identity.VSH2ID == ID) {
				res = true;
				break;
			}
		}
		
		delete snap;
		return res;
	}
	
	public bool FindIdentityByCfg(const ConfigMap cfg, FF2Identity identity)
	{
		StringMapSnapshot snap = this.Snapshot();
		char name[48];
		bool res;
		
		for ( int i = snap.Length - 1; i >= 0; i-- ) {
			snap.GetKey(i, name, sizeof(name));
			if(this.GetIdentity(name, identity) && identity.hCfg == cfg) {
				res = true;
				break;
			}
		}
		
		delete snap;
		return res;
	}
	
	public bool FindIdentityByName(const char[] name, FF2Identity identity)
	{
		StringMapSnapshot snap = this.Snapshot();
		char key_name[48];
		bool res;
		
		for ( int i = snap.Length - 1; i >= 0 && !res; i-- ) {
			snap.GetKey(i, key_name, sizeof(key_name));
			if(this.GetIdentity(key_name, identity) && !strcmp(name, identity.szName)) {
				res = true;
			}
		}
		
		delete snap;
		return res;
	}
}
FF2BossManager ff2_cfgmgr;

void InitVSH2Bridge()
{
	ff2_cfgmgr = new FF2BossManager("Freak Fortress 2");
	
	VSH2_Hook(OnCallDownloads, OnCallDownloadsFF2);
	
	VSH2_Hook(OnBossMenu, OnBossMenuFF2);
	
	VSH2_Hook(OnBossSelected, OnBossSelectedFF2);
	
	VSH2_Hook(OnBossThink, OnBossThinkFF2);
	
	VSH2_Hook(OnBossModelTimer, OnBossModelTimerFF2);
	
	VSH2_Hook(OnBossEquipped, OnBossEquippedFF2);
	
	VSH2_Hook(OnBossInitialized, OnBossInitializedFF2);
	
	VSH2_Hook(OnBossPlayIntro, OnBossPlayIntroFF2);
	
	VSH2_Hook(OnPlayerKilled, OnPlayerKilledFF2);
	
	VSH2_Hook(OnPlayerHurt, OnPlayerHurtFF2);

	VSH2_Hook(OnPlayerAirblasted, OnPlayerAirblastedFF2);
	
	VSH2_Hook(OnBossMedicCall, OnBossMedicCallFF2);
	
	VSH2_Hook(OnBossTaunt, OnBossMedicCallFF2);
	
	VSH2_Hook(OnBossJarated, OnBossJaratedFF2);
	
	VSH2_Hook(OnRoundStart, PostRoundStartFF2);
		
	VSH2_Hook(OnRoundEndInfo, OnRoundEndInfoFF2);
	
	VSH2_Hook(OnMusic, OnMusicFF2);
	
	VSH2_Hook(OnBossDeath, OnBossDeathFF2);
	
	VSH2_Hook(OnBossTakeDamage_OnStabbed, OnStabbedFF2);
	
	VSH2_Hook(OnLastPlayer, OnLastPlayerFF2);
	
	VSH2_Hook(OnSoundHook, OnSoundHookFF2);
	
	VSH2_Hook(OnScoreTally, OnScoreTallyFF2);
	
	VSH2_Hook(OnBossDealDamage_OnHitShield, OnHurtShieldFF2);
}

void RemoveVSH2Bridge()
{
	VSH2_Unhook(OnCallDownloads, OnCallDownloadsFF2);
	
	VSH2_Unhook(OnBossMenu, OnBossMenuFF2);
	
	VSH2_Unhook(OnBossSelected, OnBossSelectedFF2);
	
	VSH2_Unhook(OnBossThink, OnBossThinkFF2);
	
	VSH2_Unhook(OnBossModelTimer, OnBossModelTimerFF2);
	
	VSH2_Unhook(OnBossEquipped, OnBossEquippedFF2);
	
	VSH2_Unhook(OnBossInitialized, OnBossInitializedFF2);
	
	VSH2_Unhook(OnBossPlayIntro, OnBossPlayIntroFF2);
	
	VSH2_Unhook(OnPlayerKilled, OnPlayerKilledFF2);
	
	VSH2_Unhook(OnPlayerHurt, OnPlayerHurtFF2);

	VSH2_Unhook(OnPlayerAirblasted, OnPlayerAirblastedFF2);
	
	VSH2_Unhook(OnBossMedicCall, OnBossMedicCallFF2);
	
	VSH2_Unhook(OnBossTaunt, OnBossMedicCallFF2);
	
	VSH2_Unhook(OnBossJarated, OnBossJaratedFF2);
	
	VSH2_Unhook(OnRoundStart, PostRoundStartFF2);
		
	VSH2_Unhook(OnRoundEndInfo, OnRoundEndInfoFF2);
	
	VSH2_Unhook(OnMusic, OnMusicFF2);
	
	VSH2_Unhook(OnBossDeath, OnBossDeathFF2);
	
	VSH2_Unhook(OnBossTakeDamage_OnStabbed, OnStabbedFF2);
	
	VSH2_Unhook(OnLastPlayer, OnLastPlayerFF2);
	
	VSH2_Unhook(OnSoundHook, OnSoundHookFF2);
	
	VSH2_Unhook(OnScoreTally, OnScoreTallyFF2);
	
	VSH2_Unhook(OnBossDealDamage_OnHitShield, OnHurtShieldFF2);
	
	ff2_cfgmgr.DeleteAll();
	delete ff2_cfgmgr;
}



///	VSH2 Hooks
public Action OnCallDownloadsFF2()
{
	PrecacheScriptList(script_sounds, sizeof(script_sounds));
	PrecacheSoundList(basic_sounds, sizeof(basic_sounds));
	PrepareSound("saxton_hale/9000.wav");
	
	return Plugin_Stop;
}

public void OnBossMenuFF2(Menu& menu, const VSH2Player player)
{
	char id_menu[10]; 
	
	StringMapSnapshot snap = ff2_cfgmgr.Snapshot();
	char char_name[48];
		
	for ( int i = snap.Length - 1; i >= 0; i-- ) {
		snap.GetKey(i, char_name, sizeof(char_name));
		FF2Identity curIdentity;
		if(ff2_cfgmgr.GetIdentity(char_name, curIdentity)) {
			IntToString(curIdentity.VSH2ID, id_menu, sizeof(id_menu));
			curIdentity.hCfg.Get("name", char_name, sizeof(char_name));
			
			menu.AddItem(id_menu, char_name);
		}
	}
	
	delete snap;
}

public Action OnBossSelectedFF2(const VSH2Player player)
{
	if(IsVoteInProgress())
		return Plugin_Continue;
	
	int boss = player.GetPropInt("iBossType");
	
	static FF2Identity identity;
	if(!ff2_cfgmgr.FindIdentity(boss, identity))
		return Plugin_Continue;
		
	/// Handle callback
	{
		Action act;
		Call_StartForward(ff2.m_forwards[FF2OnSpecial]);
		Call_PushCellRef(boss);
		char name[MAX_BOSS_NAME_SIZE]; player.GetName(name);
		Call_PushStringEx(name, sizeof(name), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
		Call_PushCell(true); /// True if the boss is the primary boss
		Call_Finish(act);
		if( act == Plugin_Changed )
		{
			/*
			if(FF2BossManager.FindEntityByName(name, identity))
			{
				player.SetPropInt("iBossType", identity.VSH2ID);
			}
			*/
		}		
	}
	
	
	/// TODO: description_*{ en, ru, ko, ... }
	static char help[128] = ""; identity.hCfg.Get("description_en", help, sizeof(help));
	Panel panel = new Panel();
	
	panel.SetTitle(help);
	panel.DrawItem("Exit");
	panel.Send(player.index, HintPanel, 10);
	
	delete panel;
	
	return Plugin_Changed;
}

public void OnBossThinkFF2(const VSH2Player player)
{
	static FF2Identity identity;
	if(!ff2_cfgmgr.FindIdentity(player.GetPropInt("iBossType"), identity))
		return;
		
	ConfigMap cfg = identity.hCfg;
	
	if( !cfg ) return;
	
	float flStart; if( !cfg.GetFloat("minspeed", flStart) ) flStart = 100.0;
	float flEnd; cfg.GetFloat("maxspeed", flEnd);
	
	player.SpeedThink(flStart);
	player.GlowThink(0.1);
}

public void OnBossModelTimerFF2(const VSH2Player player)
{
	static FF2Identity identity;
	if(!ff2_cfgmgr.FindIdentity(player.GetPropInt("iBossType"), identity))
		return;
	
	int client = player.index;
	char model[PLATFORM_MAX_PATH];
	if( view_as<FF2Player>(player).iCfg.Get("model", model, sizeof(model)) ) {
		SetVariantString(model);
		AcceptEntityInput(client, "SetCustomModel");
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
	}
}

public void OnBossEquippedFF2(const VSH2Player player)
{
	static FF2Identity identity;
	if(!ff2_cfgmgr.FindIdentity(player.GetPropInt("iBossType"), identity))
		return;
	
	ConfigMap cfg = view_as<FF2Player>(player).iCfg;
	char name[MAX_BOSS_NAME_SIZE]; cfg.Get("name", name, sizeof(name));
	
	player.SetName(name);
	player.RemoveAllItems();
	
	ConfigMap wepcfg;
	
	char attr[64]; int index; int lvl; int qual;
	
	for(int i = 1; i < 4; i++) {
		FormatEx(name, sizeof(name), "weapon%i", i);
		wepcfg = cfg.GetSection(name);
		if ( !wepcfg ) break;
		
		if ( !wepcfg.GetInt("index", index) ) 			continue;
		if ( !wepcfg.Get("name", attr, sizeof(attr)) ) 	continue;
		if ( !wepcfg.GetInt("level", lvl) ) 			lvl = 39;
		if ( !wepcfg.GetInt("quality", qual) ) 			qual = 5;
		
		wepcfg.Get("attributes", attr, sizeof(attr));
		
		int new_weapon = player.SpawnWeapon(name, index, lvl, qual, attr);
		
		SetEntPropEnt(player.index, Prop_Send, "m_hActiveWeapon", new_weapon);
	}
}

public void OnBossInitializedFF2(const VSH2Player player)
{
	static FF2Identity identity;
	if ( !ff2_cfgmgr.FindIdentity(player.GetPropInt("iBossType"), identity) )
		return;
	TFClassType cls;
	if ( !ToFF2Player(player).iCfg.GetInt("class", view_as<int>(cls)) )
		cls = view_as<TFClassType>(GetRandomInt(1, 8));
	
	SetEntProp(player.index, Prop_Send, "m_iClass", cls);
}


public void OnBossPlayIntroFF2(const VSH2Player player)
{
	static FF2Identity identity;
	if ( !ff2_cfgmgr.FindIdentity(player.GetPropInt("iBossType"), identity) )
		return;
	
	FF2SoundList list = identity.sndHash.GetAssertedList("sound_begin");
	if ( !list ) return;
	
	char intro[PLATFORM_MAX_PATH];
	if( list.RandomString(intro, sizeof(intro)) )
		player.PlayVoiceClip(intro, VSH2_VOICE_INTRO);
}

public void OnPlayerKilledFF2(const VSH2Player attacker, const VSH2Player victim, Event event)
{
	if( event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER )
		return;
	
	static FF2Identity identity[2]; bool bState[2];
	bState[0] = ff2_cfgmgr.FindIdentity(attacker.GetPropInt("iBossType"), identity[0]);
	bState[1] = ff2_cfgmgr.FindIdentity(victim.GetPropInt("iBossType"), identity[1]);
	if(!bState[0] && bState[1])
		return;
	
	///	Victim is the boss
	if( bState[1] ) {
		Action act;
		Call_StartForward(ff2.m_forwards[FF2OnLoseLife]);
		int boss = ClientToBossIndex(victim.index);
		Call_PushCell(boss);
		int lives = victim.GetPropInt("iLives");
		Call_PushCellRef(lives);
		int maxlives = ToFF2Player(victim).iMaxLives;
		Call_PushCell(maxlives);
		Call_Finish(act);
		if( act==Plugin_Changed ) {
			if( lives > ToFF2Player(victim).iMaxLives )
				ToFF2Player(victim).iMaxLives = lives;
			victim.SetPropInt("iLives", lives);
		}
	}
	///	Attacker is the boss
	else if( bState[0] ) {
		
		static char snd[PLATFORM_MAX_PATH];
		
		float curtime = GetGameTime();
		if( curtime <= attacker.GetPropFloat("flKillSpree") )
			attacker.SetPropInt("iKills", attacker.GetPropInt("iKills") + 1);
		else attacker.SetPropInt("iKills", 0);
		
		if( attacker.GetPropInt("iKills") == 3 && vsh2_gm.iLivingReds != 1 ) {
			FF2SoundList list = identity[1].sndHash.GetAssertedList("sound_kspree");
			if( list && list.RandomString(snd, sizeof(snd)) ) {
				attacker.PlayVoiceClip(snd, VSH2_VOICE_SPREE);
			}
		}
		else attacker.SetPropFloat("flKillSpree", curtime+5.0);
	}
	
	///	FF2_OnAlivePlayersChanged
	{
		Call_StartForward(ff2.m_forwards[FF2OnAlive]);
		
		FF2Player[] array = new FF2Player[MaxClients];
		Call_PushCell(VSH2GameMode.GetFighters(array, true));
		
		int bosses = VSH2GameMode.GetBosses(array, true);
		Call_PushCell(bosses + VSH2GameMode.GetMinions(array, true));
		
		Call_Finish();
	}
}

public void OnPlayerHurtFF2(const VSH2Player attacker, const VSH2Player victim, Event event)
{
	static FF2Identity identity;
	if ( !ff2_cfgmgr.FindIdentity(victim.GetPropInt("iBossType"), identity) )
		return;
	
	int damage = event.GetInt("damageamount");
	victim.GiveRage(damage);
}

public void OnPlayerAirblastedFF2(const VSH2Player airblaster, const VSH2Player airblasted, Event event)
{
	static FF2Identity identity;
	if ( !ff2_cfgmgr.FindIdentity(airblasted.GetPropInt("iBossType"), identity) )
		return;
	float rage = airblasted.GetPropFloat("flRAGE");
	airblasted.SetPropFloat("flRAGE", rage + vsh2cvars.m_flairblast.FloatValue);
}


public Action OnBossMedicCallFF2(const VSH2Player player)
{
	static FF2Identity identity;
	if ( !ff2_cfgmgr.FindIdentity(player.GetPropInt("iBossType"), identity) )
		return;
	
	static char curKey[64];
	static char pl_ab[2][MAX_SUBPLUGIN_NAME];
	
#define FOR_EACH_CALLBACK \
		static FF2AbilityList list; list = ToFF2Player(player).HookedAbilities; \
		StringMapSnapshot snap = list.Snapshot(); \
		for (int i = 0; i < snap.Length; i++)
		
	FOR_EACH_CALLBACK {
		
		snap.GetKey(i, curKey, sizeof(curKey));
		
		FF2AbilityList.GetKeyVal(curKey, pl_ab);
		
		int boss = ClientToBossIndex(player.index);
		Call_StartForward(ff2.m_forwards[FF2OnPreAbility]);
		Call_PushCell(boss);
		Call_PushString(pl_ab[0]);
		Call_PushString(pl_ab[1]);
		Call_PushCell(0);
		bool enabled = true;
		Call_PushCellRef(enabled);
		Call_Finish();
		
		if(!enabled) {
			continue;
		}
		
		Action act;
		Call_StartForward(ff2.m_forwards[FF2OnAbility]);
		Call_PushCell(boss);
		Call_PushString(pl_ab[0]);
		Call_PushString(pl_ab[1]);
//		Call_PushCell(3);
		Call_PushCell(0);		///  TODO: later replace it
		Call_Finish(act);
	
	}
	
	delete snap;
	
	#undef FOR_EACH_CALLBACK
}

public Action OnBossJaratedFF2(const VSH2Player victim, const VSH2Player attacker)
{
	static FF2Identity identity;
	if ( !ff2_cfgmgr.FindIdentity(victim.GetPropInt("iBossType"), identity) )
		return Plugin_Continue;
	
	Action act;
	Call_StartForward(ff2.m_forwards[FF2OnBossJarated]);
	int boss = ClientToBossIndex(victim.index);
	Call_PushCell(boss);
	Call_PushCell(attacker.index);
	float rage = victim.GetPropFloat("flRAGE");
	Call_PushFloatRef(rage);
	Call_Finish(act);
	if( act==Plugin_Stop )
		return Plugin_Changed;
	
	rage -= vsh2cvars.m_fljarate.FloatValue;
	if( rage <= 0.0 )
		rage = 0.0;
	
	victim.SetPropFloat("flRAGE", rage);
	return Plugin_Changed;
}

public void PostRoundStartFF2(const VSH2Player[] bosses, const int boss_count, const VSH2Player[] red_players, const int red_count)
{
	FF2Identity identity;
	FF2Player curPlayer;
	
	for (int i = 0; i < boss_count; i++ ) {
		curPlayer = ToFF2Player(bosses[i]);
		if( ff2_cfgmgr.FindIdentity(curPlayer.GetPropInt("iBossType"), identity) ) {
			curPlayer.iCfg = identity.hCfg;
			curPlayer.HookedAbilities = identity.ablist;
		}
	}
	
	Call_StartForward(ff2.m_forwards[FF2PostRoundStart]);
	Call_PushArray(bosses, boss_count);
	Call_PushCell(boss_count);
	Call_PushArray(red_players, red_count);
	Call_PushCell(red_count);
	Call_Finish();
}

public void OnRoundEndInfoFF2(const VSH2Player player, bool bossBool, char message[MAXMESSAGE])
{
	static FF2Identity identity;
	if ( !ff2_cfgmgr.FindIdentity(player.GetPropInt("iBossType"), identity) )
		return;
	
	char snd[PLATFORM_MAX_PATH];
	if(bossBool) {
		FF2SoundList list = identity.sndHash.GetAssertedList("sound_win");
		if ( list.RandomString(snd, sizeof(snd)) )
			player.PlayVoiceClip(snd, VSH2_VOICE_WIN);
	}
	else {
		FF2SoundList list = identity.sndHash.GetAssertedList("sound_stalemate");
		if ( list.RandomString(snd, sizeof(snd)) )
			player.PlayVoiceClip(snd, VSH2_VOICE_WIN);
	}
	
	ToFF2Player(player).iCfg = null;
	ToFF2Player(player).HookedAbilities = null;
}


public Action OnMusicFF2(char song[PLATFORM_MAX_PATH], float& time, const VSH2Player player)
{
	Action act = Plugin_Continue;
	Call_StartForward(ff2.m_forwards[FF2OnMusic2]);
	char song2[PLATFORM_MAX_PATH]; strcopy(song2, sizeof(song2), song);
	Call_PushStringEx(song, sizeof(song), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	float time2 = time;
	Call_PushFloatRef(time2);
	Call_PushStringEx("Unknown Song", 64, SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushStringEx("Unknown Artist", 64, SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish(act);
	if( act != Plugin_Continue ) {
		strcopy(song, sizeof(song), song2);
		time = time2;
		return act;
	}

	Call_StartForward(ff2.m_forwards[FF2OnMusic]);
	strcopy(song2, sizeof(song2), song);
	Call_PushStringEx(song, sizeof(song), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	time2 = time;
	Call_PushFloatRef(time2);
	Call_Finish(act);
	if( act != Plugin_Continue ) {
		strcopy(song, sizeof(song), song2);
		time = time2;
		return act;
	}
	
	FF2Player rand = ToFF2Player(VSH2GameMode_GetRandomBoss(false));
	if( !rand )
		return Plugin_Continue;
	
	
	/// hmm...
	{
		char res[4];
		static FF2Identity identity;
		if ( ff2_cfgmgr.FindIdentityByCfg(rand.iCfg, identity) ) {
			
			FF2SoundList list = identity.sndHash.GetAssertedList("sound_bgm");
			if ( list ) {
				int idx = GetRandomInt(0, list.Length - 1);
				
				IntToString(idx, res, sizeof(res));
				list.At(idx, song, sizeof(song));
				
				rand.iCfg.GetFloat(res, time);
			}
			
		}
		
	}
	return Plugin_Continue;
}


public void OnBossDeathFF2(const VSH2Player player)
{
	static FF2Identity identity;
	if ( !ff2_cfgmgr.FindIdentity(player.GetPropInt("iBossType"), identity) )
		return;
	
	char rand[PLATFORM_MAX_PATH];
	if(RandomSoundFromList(ToFF2Player(player), "sound_death", rand, sizeof(rand)))
		player.PlayVoiceClip(rand, VSH2_VOICE_LOSE);
}

public Action OnStabbedFF2(VSH2Player victim, int& attacker, int& inflictor, 
							float& damage, int& damagetype, int& weapon,
							float damageForce[3], float damagePosition[3], int damagecustom)
{
	static FF2Identity identity;
	if ( !ff2_cfgmgr.FindIdentity(victim.GetPropInt("iBossType"), identity) )
		return Plugin_Continue;
	
	Action act;
	Call_StartForward(ff2.m_forwards[FF2OnBackstab]);
	int client = victim.index;
	int boss = ClientToBossIndex(client);
	Call_PushCell(boss);
	Call_PushCell(client);
	Call_PushCell(attacker);
	Call_Finish(act);
	if( act==Plugin_Stop )
		return Plugin_Changed;
	else if( act==Plugin_Handled )
		damage = 0.0;
		
	char rand[PLATFORM_MAX_PATH];
	if(RandomSoundFromList(ToFF2Player(victim), "sound_stabbed", rand, sizeof(rand)))
		victim.PlayVoiceClip(rand, VSH2_VOICE_LOSE);
	
	return Plugin_Continue;
}

public Action OnSoundHookFF2(const VSH2Player player, char sample[PLATFORM_MAX_PATH], int& channel, float& volume, int& level, int& pitch, int& flags)
{
//	
//	if ( RandomSoundFromListStriStr(ToFF2Player(player), "sound_replace", sample, sizeof(sample)) ) {
//		return Plugin_Handled;
//	} 
///	TODO
	return Plugin_Continue;
}

public void OnLastPlayerFF2(const VSH2Player player)
{
	static FF2Identity identity;
	if ( !ff2_cfgmgr.FindIdentity(player.GetPropInt("iBossType"), identity) )
		return;
	
	FF2SoundList list = identity.sndHash.GetAssertedList("sound_lastman");
	if ( !list ) return;
	
	char rnd[PLATFORM_MAX_PATH];
	list.RandomString(rnd, sizeof(rnd));
	
	player.PlayVoiceClip(rnd, VSH2_VOICE_LASTGUY);
}

public void OnScoreTallyFF2(const VSH2Player player, int& points_earned, int& queue_earned)
{
	ff2.m_queuePoints[player.index] = queue_earned;
	if( !ff2.m_queueChecking ) {
		RequestFrame(FinishQueueArray);
		ff2.m_queueChecking = true;
	}
}

public void FinishQueueArray()
{
	ff2.m_queueChecking = false;
	
	Call_StartForward(ff2.m_forwards[FF2OnQueuePoints]);
	int[] points = new int[MaxClients];
	for ( int i=1; i<=MaxClients; i++ )
		points[i] = ff2.m_queuePoints[i];
	
	Action action;
	Call_PushArrayEx(points, MaxClients+1, SM_PARAM_COPYBACK);
	Call_Finish(action);
	if ( action == Plugin_Changed ) {
		for( int i=1; i<=MaxClients; i++ ) {
			if( !IsClientInGame(i) )
				continue;
			
			FF2Player player = FF2Player(i);
			player.SetPropInt("iQueue", points[i] - ff2.m_queuePoints[i] + player.GetPropInt("iQueue"));
		}
	} else if ( action != Plugin_Continue ) {
		for( int i=1; i<=MaxClients; i++ ) { 
			if( !IsClientInGame(i) )
				continue;
			
			FF2Player player = FF2Player(i);
			player.SetPropInt("iQueue", player.GetPropInt("iQueue") - ff2.m_queuePoints[i]);
		}
	}
}

public Action OnHurtShieldFF2(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action act;
	Call_StartForward(ff2.m_forwards[FF2OnHurtShield]);
	Call_PushCell(victim.index);
	int shield = TF2_GetWearable(victim.index, TFWeaponSlot_Secondary);
	Call_PushCellRef(shield);
	int boss = ClientToBossIndex(attacker);
	Call_PushCell(boss);
	Call_PushCell(attacker);
	float damage2 = damage;
	Call_PushCellRef(damage2);
	Call_Finish(act);
	if( act==Plugin_Stop )
		return Plugin_Changed;
	else if( act!=Plugin_Continue )
		damage = damage2;
	
	return Plugin_Continue;
}


stock bool RandomSoundFromList(FF2Player player, const char[] section_key, char[] file, int maxlen)
{
	static FF2Identity identity;
	if ( !ff2_cfgmgr.FindIdentityByCfg(player.iCfg, identity) ) return false;
	
	FF2SoundList list = identity.sndHash.GetAssertedList(section_key);
	if ( !list ) return false; 
	
	return list.RandomString(file, maxlen);
}

public int HintPanel(Menu menu, MenuAction action, int param1, int param2)
{
	return;
}
