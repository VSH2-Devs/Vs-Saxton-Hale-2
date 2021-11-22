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
	bool bEnabled;
	
	Color_t color;
	Vector2D_t pos;
	float pad;
	
	int num_bosses;
	FF2Player boss;
	
	void ParseFromConfig(FF2Player player)
	{
        float pos;
        ConfigMap cfg = player.BossConfig.Config.GetSection(CFG_TO_LIVESYS_SECTION);

        /// X Position
        {
            if (!cfg.GetFloat("position.x", pos))
                pos = -1.0;
            this.pos.x = pos;
        }
        /// Y Position
        {
            if (!cfg.GetFloat("position.y", pos))
                pos = 0.174;
            this.pos.y = pos;
        }
		
		/// Y pad
        {
            if (!cfg.GetFloat("position.pad", pos))
                pos = 0.03;
            this.pad = pos;
        }
		
		/// RGBA color
        {
            char clr[8];
            cfg.GetString("color", clr, sizeof(clr));
            Parse_RGBA(clr, this.color);
        }

        this.boss = player;
	}
}

static int BossesWithLives;
static bool DisplayHudOnce;

static LivesSys_t LivesSys[MAXPLAYERS];


void LiveSys_OnRoundStart(const VSH2Player[] bosses, const int boss_count)
{
    FF2Player player;
    for (int i = 0; i < boss_count && BossesWithLives < sizeof(LivesSys); i++)
    {
		player = ToFF2Player(bosses[i]);
		if (player.GetPropInt("iMaxLives") <= 1)
			continue;

		LivesSys[BossesWithLives++].ParseFromConfig(player);
	}
}

void LiveSys_OnRoundEndInfo(const VSH2Player player, char message[MAXMESSAGE])
{
    if (BossesWithLives && DisplayHudOnce && player.GetPropInt("iMaxLives") > 1)
	{
		char name[MAX_BOSS_NAME_SIZE];
		player.GetName(name);
		
		FormatEx(
            message, 
            MAXMESSAGE,
            "%s (%N) had %i (of %i) health left, %i (of %i) lives left.", 
			name, 
			player.index, 
			player.GetPropInt("iHealth"), 
			player.GetPropInt("iMaxHealth"),
			player.GetPropInt("iLives"),
			player.GetPropInt("iMaxLives")
        );
		
		if (DisplayHudOnce) 
		{
			DisplayHudOnce = false;
			CreateTimer(0.2, Timer_ResetLiveSys);
		}
	}
}

void LiveSys_DisplayForClient(int client)
{
    if (!BossesWithLives || VSH2GameMode.GetPropInt("iRoundState") != StateRunning)
    	return;
	
    DisplayLivesNum(client);
}


Action Timer_ResetLiveSys(Handle timer)
{
	BossesWithLives = 0;
	DisplayHudOnce = true;
}


static void DisplayLivesNum(int client)
{
    float nest_y_pos = 2.0;
    static char name[MAX_BOSS_NAME_SIZE]; 
	
    for (int i = 0; i < BossesWithLives; i++)
	{
		FF2Player curBoss = LivesSys[i].boss;
		if (!curBoss.index)
			continue;
			
		int curLives = curBoss.GetPropInt("iLives");
		
		if (curLives <= 1)
			continue;
        
		curBoss.GetName(name);

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
    for (int i; i < 4; i++)
    {
        c[2] = str[extra_offset + i * 2] & 0xFF;
        c[3] = str[extra_offset + i * 2 + 1] & 0xFF;
        color[i] = StringToInt(c, 16);
    }
}