#define INVALID_FF2_BOSS_ID      -1
#define INVALID_FF2PLAYER        view_as< FF2Player >(-1)

#define ToFF2Player(%0)          view_as< FF2Player >(%0)
#define ClientToBossIndex(%0)    view_as< int >(%0)

#define IsClientValid(%1)        ( 0 < (%1) && (%1) <= MaxClients && IsClientInGame((%1)) )

#define	PATH_TO_CHAR_CFG    "data/freak_fortress_2/characters.cfg"


enum FF2CallType_t {
	CT_NONE          = 0b000000000, /// Inactive, default to CT_RAGE
	CT_LIFE_LOSS     = 0b000000001,
	CT_RAGE          = 0b000000010,
	CT_CHARGE        = 0b000000100,
	CT_UNUSED_DEMO   = 0b000001000, /// UNUSED
	CT_WEIGHDOWN     = 0b000010000,
	CT_PLAYER_KILLED = 0b000100000,
	CT_BOSS_KILLED   = 0b001000000,
	CT_BOSS_STABBED  = 0b010000000,
	CT_BOSS_MG       = 0b100000000,
};

enum FF2RageType_t {
	RT_RAGE = 0,
	RT_WEIGHDOWN,
	RT_CHARGE
};

enum { FF2_MAX_SUBPLUGINS = 16 };

enum {
	FF2_MAX_PLUGIN_NAME  = 64,   /// sizeof plugin_name
	FF2_MAX_ABILITY_NAME = 64,   /// sizeof ability_name
	FF2_MAX_ABILITY_KEY  = 64,   /// sizeof "ability*" key
};

enum { FF2_MAX_LIST_KEY = FF2_MAX_PLUGIN_NAME + FF2_MAX_ABILITY_NAME + 2 };		/// sizeof key in FF2AbilityList

#include "sound_list.sp"
#include "character.sp"
#include "player.sp"

stock FF2Player ZeroBossToFF2Player()
{
	FF2Player[] players = new FF2Player[MaxClients];
	if( VSH2GameMode.GetBosses(players, false) < 1 )
		return( INVALID_FF2PLAYER );
	
	return( players[0] );
}

stock ConfigMap JumpToAbility(const FF2Player player, const char[] plugin_name, const char[] ability_name)
{
	FF2AbilityList list = player.HookedAbilities;
	
	static char actual_key[FF2_MAX_LIST_KEY];
	FormatEx(actual_key, sizeof(actual_key), "%s##%s", plugin_name, ability_name);
	
	ConfigMap ability = null;
	char pos[64];
	
	if( list && list.GetString(actual_key, pos, sizeof(pos)) ) {
		ability = player.iCfg.GetSection(pos);
	}
	
	return( ability );
}

stock int GetArgNamedB(FF2Player player, const char[] plugin_name, const char[] ability_name, const char[] argument, bool defval = false)
{
	ConfigMap section = JumpToAbility(player, plugin_name, ability_name);
	if( section==null ) {
		return( defval );
	}
	
	bool result;
	return( section.GetBool(argument, result) ? result:defval );
}

stock int GetArgNamedI(FF2Player player, const char[] plugin_name, const char[] ability_name, const char[] argument, int defval = 0)
{
	ConfigMap section = JumpToAbility(player, plugin_name, ability_name);
	if( section==null ) {
		return( defval );
	}
	
	int result;
	return( section.GetInt(argument, result) ? result:defval );
}

stock float GetArgNamedF(FF2Player player, const char[] plugin_name, const char[] ability_name, const char[] argument, float defval = 0.0)
{
	ConfigMap section = JumpToAbility(player, plugin_name, ability_name);
	if( section==null ) {
		return( defval );
	}
	
	float result;
	return( section.GetFloat(argument, result) ? result:defval );
}

stock int GetArgNamedS(FF2Player player, const char[] plugin_name, const char[] ability_name, const char[] argument, char[] result, int size)
{
	ConfigMap section = JumpToAbility(player, plugin_name, ability_name);
	if( section==null ) {
		return 0;
	}
	return( section.Get(argument, result, size) );
}

stock void FPrintToChat(int client, const char[] message, any ...)
{
	SetGlobalTransTarget(client);
	char buffer[192];
	VFormat(buffer, sizeof(buffer), message, 3);
	CPrintToChat(client, "{olive}[VSH2/FF2]{default} %s",  buffer);
}

stock int FF2_RegisterFakeBoss(const char[] name)
{
	if( strlen(name) >= MAX_BOSS_NAME_SIZE - 6 )
		return( INVALID_FF2_BOSS_ID );
	char final_name[MAX_BOSS_NAME_SIZE];
	FormatEx(final_name, sizeof(final_name), "%s_FF2", name);
	
	int id;
	if( (id = VSH2_GetBossID(final_name)) != INVALID_FF2_BOSS_ID ) {
		return( id );
	}
	
	return( VSH2_RegisterPlugin(final_name) );
}