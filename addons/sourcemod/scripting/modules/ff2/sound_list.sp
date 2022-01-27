/**
 * FF2SoundIdentity:
 *	Since there will be so many bosses with so many (sound) sections,
 *	allocating a alot of huge buffers of string might not be the best idea.
 *	So instead, this enum struct will only points to the sound section
 *
 *	//"catch_phrase"
 *	"sound_*" {
 * 		"<enum>" {
 *			"path"		"Path/To/Sound"
 * 			"time"		""		//	0.0
 *			"name"		""		//	""
 *			"artist"	""		//	"Unknown artist"
 *			"slot"		""		//	CT_NONE = '0b0'
 *
 *			"internal"
 *			{
 *				//	empty = use default
 *				"channel"	""
 *				"flags"		"10"	//	SND_CHANGEPITCH = 2, as bitflags
 *				"level"		""		//	SNDLEVEL_TRAFFIC = 75
 *
 *				"volume"	""		//	SNDVOL_NORMAL = 1.0
 *				"pitch"		""		//	SNDPITCH_NORMAL = 100
 *			}
 *		}
 * 	}
 *
 *
 */

enum struct FF2SoundIdentity {
	char path[PLATFORM_MAX_PATH];	///	full sound path
	float time;						/// 0.0, or song duration
	char name[32];					///	song name
	char artist[32];				///	song artist name

	int bit_slot;					/// sound slot property

	int channel;					/// sound channel, default to SNDCHAN_VOICE
	int flags;						///	sound flags, default to SND_CHANGEPITCH
	int level;						/// sound level, default to SNDLEVEL_TRAFFIC
	float volume;					/// sound volume, default = SNDVOL_NORMAL
	int pitch;						/// sound pitch, default to SNDPITCH_NORMAL

	bool IsSlotCompatible(FF2CallType_t slot) {
		return (view_as<int>(slot) & this.bit_slot) ? true : false;
	}
}

methodmap FF2SoundSection {
	public FF2SoundSection(ConfigMap section) {
		return view_as<FF2SoundSection>(section);
	}

	property ConfigMap Config {
		public get() { return view_as<ConfigMap>(this); }
	}

	public bool BadSection() {
		return view_as<ConfigMap>(this) == null;
	}

	public void GetPath(char[] path, int path_size) {
		this.Config.Get("path", path, path_size);
	}

	public void GetTime(float& time) {
		this.Config.GetFloat("time", time);
	}

	///	 for fast lookup instead of initializing a whole FF2SoundIdentity
	public void GetPathAndTime(char[] path, int path_size, float& time) {
		this.GetPath(path, path_size);
		this.GetTime(time);
	}

	public bool IsSlotCompatible(FF2CallType_t bit_slot) {
		FF2CallType_t slot;
		if( !this.Config.GetInt("slot", view_as<int>(slot), 2) )
			slot = CT_RAGE;

		return (slot & bit_slot) ? true : false;
	}

	public void FullInfo(FF2SoundIdentity info) {
		ConfigMap cfg = this.Config;

		cfg.Get("path", info.path, sizeof(FF2SoundIdentity::path));
		cfg.GetFloat("time", info.time);
		cfg.Get("name", info.name, sizeof(FF2SoundIdentity::name));
		cfg.Get("artist", info.artist, sizeof(FF2SoundIdentity::artist));
		if( !cfg.GetInt("slot", info.bit_slot, 2) )
			info.bit_slot = view_as<int>(CT_RAGE);

		cfg = cfg.GetSection("internal");
		if( cfg ) {
			if( !cfg.GetInt("channel", info.channel) ) 	info.channel	= SNDCHAN_VOICE;
			if( !cfg.GetInt("flags", info.flags) )	 	info.flags		= SND_CHANGEPITCH;
			if( !cfg.GetInt("level", info.level) )	 	info.level		= SNDLEVEL_TRAFFIC;
			if( !cfg.GetFloat("volume", info.volume) )	info.volume		= SNDVOL_NORMAL;
			if( !cfg.GetInt("pitch", info.pitch) )	 	info.pitch		= SNDPITCH_NORMAL;
		}
	}

	public void PlaySoundSimple(VSH2Player player, int vsh2_flags) {
		char path[PLATFORM_MAX_PATH];
		this.GetPath(path, sizeof(path));
		player.PlayVoiceClip(path, vsh2_flags);
	}

	public void PlaySound(int client, int vsh2_flags) {
		FF2SoundIdentity info;
		this.FullInfo(info);
		float pos[3];
		if( vsh2_flags & VSH2_VOICE_BOSSPOS ) {
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
		}
		else pos = NULL_VECTOR;

		for( int i; i<2; i++ ) {
			EmitSoundToAll(
				info.path,
				(vsh2_flags & VSH2_VOICE_BOSSENT) ? client : SOUND_FROM_PLAYER,
				info.channel ? info.channel : (vsh2_flags & VSH2_VOICE_ALLCHAN) ? SNDCHAN_AUTO : SNDCHAN_ITEM,
				info.level ? info.level : SNDLEVEL_TRAFFIC,
				info.flags ? info.flags : SND_NOFLAGS,
				info.volume ? info.volume : SNDVOL_NORMAL,
				info.pitch ? info.pitch : SNDPITCH_NORMAL,
				client,
				pos
			);
			if( vsh2_flags & VSH2_VOICE_ONCE )
				break;
		}

		if( vsh2_flags & VSH2_VOICE_TOALL ) {
			for( int i=MaxClients; i; --i ) {
				if( IsClientInGame(i) && i != client ) {
					for( int x; x<2; x++ ) {
						EmitSoundToClient(
							i,
							info.path,
							client,
							info.channel ? info.channel : (vsh2_flags & VSH2_VOICE_ALLCHAN) ? SNDCHAN_AUTO : SNDCHAN_ITEM,
							info.level ? info.level : SNDLEVEL_TRAFFIC,
							info.flags ? info.flags : SND_NOFLAGS,
							info.volume ? info.volume : SNDVOL_NORMAL,
							info.pitch ? info.pitch : SNDPITCH_NORMAL,
							client,
							pos
						);
					}
				}
			}
		}
	}

	public void PrintToAll() {
		char name[sizeof(FF2SoundIdentity::name)];
		this.Config.Get("name", name, sizeof(name));

		if( !name[0] )
			return;

		char artist[sizeof(FF2SoundIdentity::artist)];
		this.Config.Get("artist", artist, sizeof(artist));
		for( int i=1;i<MaxClients;i++ ) {
			if( IsClientInGame(i) ) {
				FPrintToChat(i, "Now Playing {blue}%s{default} - {orange}%s{default}", name, artist);
			}
		}
	}
}

/**
 * FF2SoundMap:
 *
 * Key: 	"sound.*"	// "catch.*"
 * Value: 	ConfigMap of a sound section
 */
methodmap FF2SoundMap < StringMap  {
	public FF2SoundMap() {
		return( view_as< FF2SoundMap >(new StringMap()) );
	}

	public ConfigMap GetSection(const char[] name) {
		ConfigMap section;
		this.GetValue(name, section);
		return section;
	}

	public bool SetSection(const char[] name, ConfigMap sec) {
		return this.SetValue(name, sec, false);
	}

	/**
	 * section: extra section for sounds, can be null
	 */
	public void PlayAbilitySound(VSH2Player player, ConfigMap section, FF2CallType_t type) {
		bool play_custom = false;
		char buffer[PLATFORM_MAX_PATH];
		buffer = "ability";

		if( section.GetBool("custom", play_custom, false) && play_custom ) {
			section.Get("sounds", buffer, sizeof(buffer));
		}

		ConfigMap snd_list = this.GetSection(buffer);
		FF2SoundSection sec;
		if( snd_list && RandomAbilitySound(snd_list, type, sec) ) {
			sec.GetPath(buffer, sizeof(buffer));
			sec.PlaySound(player.index, VSH2_VOICE_ABILITY);
		}
	}

	public FF2SoundSection RandomEntry(const char[] name) {
		ConfigMap sec = this.GetSection(name);
		int size = sec ? sec.Size : 0;
		return !size ? FF2SoundSection(null) : FF2SoundSection(sec.GetIntSection(GetRandomInt(0, size-1)));
	}
}

FF2SoundSection FindSoundByPath(ConfigMap snd_section, const char[] target_path)
{
	int size = snd_section.Size;
	char path[PLATFORM_MAX_PATH];
	for( int i; i<size; i++ ) {
		FF2SoundSection sec = FF2SoundSection(snd_section.GetIntSection(i));
		if( !sec )
			continue;

		sec.GetPath(path, sizeof(path));
		if( !strcmp(target_path, path) ) {
			return sec;
		}
	}
	return( FF2SoundSection(null) );
}

bool RandomAbilitySound(ConfigMap sound_section, FF2CallType_t slot, FF2SoundSection& out_snd)
{
	if( !sound_section )
		return( false );

	int size = sound_section.Size;
	if( size > FF2_MAX_RANDOM_SOUNDS )
		size = FF2_MAX_RANDOM_SOUNDS;

	FF2SoundSection[] sounds = new FF2SoundSection[size];
	int count;

	///	first capture all valid sounds
	for( int i=size-1; i>=0; i-- ) {
		FF2SoundSection cur_sound = FF2SoundSection(sound_section.GetIntSection(i));
		if( !cur_sound || !cur_sound.IsSlotCompatible(slot) )
			continue;
		sounds[count++] = cur_sound;
	}

	if( !count )
		return( false );

	out_snd = sounds[GetRandomInt(0, count-1)];
	return( true );
}
