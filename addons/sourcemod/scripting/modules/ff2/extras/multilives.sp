#define CFG_TO_LIVESYS_SECTION "info.lives_sys"

enum struct Vector2D_t
{
	float x;
	float y;
}

enum struct Color_t
{
	char r;
	char g;
	char b;
	char a;
}

enum struct LivesSys_t
{
	Color_t color;
	Vector2D_t pos;
	float pad;

	int num_bosses;
	FF2Player boss;

	void ParseFromConfig(FF2Player player, ConfigMap cfg)
	{
		float pos;

		/// X Position
		{
			if( !cfg.GetFloat("position.x", pos) )
				pos = -1.0;
			this.pos.x = pos;
		}
		/// Y Position
		{
			if( !cfg.GetFloat("position.y", pos) )
				pos = 0.174;
			this.pos.y = pos;
		}

		/// Y pad
		{
			if( !cfg.GetFloat("position.pad", pos) )
				pos = 0.03;
			this.pad = pos;
		}

		/// RGBA color
		{
			char clr[8];
			if( cfg.Get("color", clr, sizeof(clr)) )
				Parse_RGBA(clr, this.color);
			else {
				this.color.r = this.color.g = this.color.b = this.color.a = 0xFF;
			}

		}

		this.boss = player;
	}
}

static int BossesWithLives;
static LivesSys_t LivesSys[MAXPLAYERS];


void LiveSys_OnRoundStart(const VSH2Player[] bosses, const int boss_count)
{
	FF2Identity identity;
	for (int i = 0; i < boss_count && BossesWithLives < sizeof(LivesSys); i++)
	{
		FF2Player player = ToFF2Player(bosses[i]);
		if( !ff2_cfgmgr.FindIdentity(player.iBossType, identity) )
			return;
		if( player.GetPropInt("iMaxLives") <= 1 )
			continue;

		LivesSys[BossesWithLives++].ParseFromConfig(player, identity.hCfg.GetSection(FF2_CHARACTER_KEY ... "." ... CFG_TO_LIVESYS_SECTION));
	}
}

bool LiveSys_OnRoundEndInfo(const VSH2Player player, char message[MAXMESSAGE])
{
	BossesWithLives = 0;
	if (player.GetPropInt("iMaxLives") > 1)
	{
		char name[MAX_BOSS_NAME_SIZE];
		player.GetName(name);

		FormatEx(
			message, 
			sizeof(message),
			"%s (%N) had %i (of %i) health left, %i (of %i) lives left.",
			name, 
			player.index, 
			player.GetPropInt("iHealth"), 
			player.GetPropInt("iMaxHealth"),
			player.GetPropInt("iLives"),
			player.GetPropInt("iMaxLives")
		);

		return true;
	}
	return false;
}

void LiveSys_DisplayForClient(int client)
{
	if( !BossesWithLives || VSH2GameMode.GetPropInt("iRoundState") != StateRunning )
		return;

	DisplayLivesNum(client);
}


static void DisplayLivesNum(int client)
{
	float nest_y_pos = 2.0;
	static char name[MAX_BOSS_NAME_SIZE]; 

	for( int i = 0; i < BossesWithLives; i++ ) {
		FF2Player curBoss = LivesSys[i].boss;
		if( !curBoss.index )
			continue;

		int curLives = curBoss.GetPropInt("iLives");
		if( curLives <= 1 )
			continue;

		if (nest_y_pos == 2.0)
			nest_y_pos = LivesSys[i].pos.y;

		SetHudTextParams(
			LivesSys[i].pos.x, 
			nest_y_pos,
			0.15, 
			LivesSys[i].color.r,
			LivesSys[i].color.g,
			LivesSys[i].color.b,
			LivesSys[i].color.a
		);

		curBoss.GetName(name);
		ShowHudText(
			client,
			-1,
			"%s: (%i / %i) lives left",
			name,
			curLives,
			curBoss.GetPropInt("iMaxLives")
		);

		nest_y_pos += LivesSys[i].pad;
	}
}


static void Parse_RGBA(const char[] str, any color[4])
{
	int extra_offset = str[0] == '0' && str[1] == 'x' ? 2:0;
	char c[5];	c[0] = '0'; c[1] = 'x';
	for( int i; i < 4; i++ ) {
		c[2] = str[extra_offset + i * 2] & 0xFF;
		c[3] = str[extra_offset + i * 2 + 1] & 0xFF;
		color[i] = StringToInt(c, 16);
	}
}