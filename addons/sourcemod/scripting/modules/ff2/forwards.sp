Action Call_OnBossSelected(FF2Player player, char name[MAX_BOSS_NAME_SIZE], bool force)
{
	Action res;
	Call_StartForward(ff2.m_forwards[FF2OnSpecial]);
	Call_PushCell(player.index);
	Call_PushStringEx(name, sizeof(name), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushCell(force);
	Call_Finish(res);
	return res;
}

Action Call_OnBossLoseLife(FF2Player player)
{
	Action res;

	Call_StartForward(ff2.m_forwards[FF2OnLoseLife]);
	Call_PushCell(player.index);
	int lives = player.iLives;
	Call_PushCellRef(lives);
	int maxlives = player.iMaxLives;
	Call_PushCell(maxlives);
	Call_Finish(res);

	if( res==Plugin_Changed ) {
		if( lives > player.iMaxLives )
			player.iMaxLives = lives;
		player.iLives = lives;
	}

	return res;
}

Action Call_OnMusic(FF2Player player, char song[PLATFORM_MAX_PATH], float& time)
{
	Action res;
	char song_copy[PLATFORM_MAX_PATH]; song_copy = song;
	float time_copy = time;

	Call_StartForward(ff2.m_forwards[FF2OnMusic]);
	Call_PushCell(player.index);
	Call_PushStringEx(song_copy, sizeof(song_copy), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushFloatRef(time_copy);
	Call_Finish(res);

	if( res != Plugin_Continue ) {
		strcopy(song, sizeof(song), song_copy);
		time = time_copy;
	}

	return res;
}

Action Call_OnBossStabbed(FF2Player victim, FF2Player attacker)
{
	Action res;
	Call_StartForward(ff2.m_forwards[FF2OnBackstab]);
	Call_PushCell(victim.index);
	Call_PushCell(attacker.index);
	Call_Finish(res);
	return res;
}

Action Call_OnSetScore(int[] points)
{
	Action res;
	Call_StartForward(ff2.m_forwards[FF2OnQueuePoints]);
	Call_PushArrayEx(points, MAXPLAYERS, SM_PARAM_COPYBACK);
	Call_Finish(res);
	return res;
}

Action Call_OnTakeDamage_OnBossTriggerHurt(int victim, int attacker, float& damage)
{
	Action res;
	Call_StartForward(ff2.m_forwards[FF2OnTriggerHurt]);
	Call_PushCell(victim);
	Call_PushCell(attacker);
	float damage2 = damage;
	Call_PushFloatRef(damage2);
	Call_Finish(res);
	switch( res ) {
		case Plugin_Continue: return res;
		case Plugin_Changed: {
			damage = damage2; return res;
		}
	}
	damage = 0.0;
	return Plugin_Changed;
}