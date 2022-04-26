void ProcessOnCallDownload()
{
	///	Precache Sounds
	{
		StringMapSnapshot snap = ff2_cfgmgr.Snapshot();

		FF2Identity identity;
		char _key[FF2_MAX_BOSS_NAME_SIZE];
		char path[PLATFORM_MAX_PATH];

		for( int i = snap.Length - 1; i >= 0; i-- ) {
			snap.GetKey(i, _key, sizeof(_key));
			ff2_cfgmgr.GetIdentity(_key, identity);

			/// Precache SoundList
			{
				StringMapSnapshot sound_snap = identity.soundMap.Snapshot();
				for( int j = sound_snap.Length - 1; j >= 0; j-- ) {
					sound_snap.GetKey(j, path, sizeof(path));
					ConfigMap section = identity.soundMap.GetSection(path);

					for( int k=section.Size-1; k>=0; k-- ) {
						FF2SoundSection cur_sec = FF2SoundSection(section.GetIntSection(k));
						if( !cur_sec )
							continue;

						cur_sec.GetPath(path, sizeof(path));
						if( path[0] ) {
							PrecacheSound(path, true);
						}
					}
				}
				delete sound_snap;
			}

			/// Precache Models
			FF2Character cfg = FF2Character(identity.hCfg);
			bool new_api = identity.isNewAPI;

			ConfigMap precache_section = cfg.Config.GetSection(new_api ? "downloads.precache" : "mod_precache");
			if( !precache_section ) precache_section = cfg.Config.GetSection(new_api ? "downloads.models" : "mod_download");
			int extra = new_api ? 0 : 1;	///	offset and start at 1 instead of 0

			if( precache_section ) {
				for( int j=precache_section.Size-1; j>=0; j-- ) {
					if( precache_section.GetIntKey(j + extra, path, sizeof(path)) && path[0] ) {
						PrecacheModel(path, true);
					}
				}
			}

			///Retry Downloads.
			FF2Character_ProcessDownloads(cfg, new_api, identity.name);
		}
		delete snap;
	}
}

void Call_FF2OnAbility(const FF2Player player, FF2CallType_t call_type)
{
	FF2AbilityList list = player.HookedAbilities;
	if( !list )
		return;

	static char pl_name[FF2_MAX_PLUGIN_NAME], ab_name[FF2_MAX_ABILITY_NAME];
	int size = list.Length;
	int boss_index = player.index;

	for( int i; i<size; i++ ) {
		FF2Ability cur = list.Get(i);

		if( !cur.ContainsBitSlot(call_type) )
			continue;

		cur.GetPluginAndAbility(pl_name, ab_name);

		Call_StartForward(ff2.m_forwards[FF2OnPreAbility]);
		Call_PushCell(boss_index);
		Call_PushString(pl_name);
		Call_PushString(ab_name);
		Call_PushCell(call_type);
		bool enabled = true;
		Call_PushCellRef(enabled);
		Call_Finish();

		if( !enabled ) {
			continue;
		}

		Call_StartForward(ff2.m_forwards[FF2OnAbility]);
		Call_PushCell(boss_index);
		Call_PushString(pl_name);
		Call_PushString(ab_name);
		Call_PushCell(call_type);
		Call_Finish();
	}
}
