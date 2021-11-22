#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <vsh2>
#include <cfgmap>


enum struct SkialData {
	bool      vsh2;
	ConfigMap cfg;
	ConVar    medigun_recharge;
	ConVar    melee_heal_building;
	float     health_boost;
}

enum struct Token {
	char  lexeme[64];
	int   size;
	int   tag;
	float val;
}

enum struct LexState {
	Token tok;
	int   i;
	char  syms[11];
	float values[10];
}


enum {
	TokenInvalid = 0,
	TokenNum     = 1,
	TokenLParen  = 2,
	TokenRParen  = 3,
	TokenLBrack  = 4,
	TokenRBrack  = 5,
	TokenPlus    = 6,
	TokenSub     = 7,
	TokenMul     = 8,
	TokenDiv     = 9,
	TokenPow     = 10,
	TokenVar     = 11,
	LEXEME_SIZE  = 64,
	dot_flag     = 1,
};


public Plugin myinfo = {
	name        = "vsh2addon_mub_vsh",
	author      = "Assyrian/Nergal",
	description = "skial-mub requested vsh2 mods",
	version     = "1.0",
	url         = "http://www.sourcemod.net/"
};


SkialData g_data;

public void OnLibraryAdded(const char[] name)
{
	if( StrEqual(name, "VSH2") ) {
		g_data.vsh2 = true;
		g_data.cfg = new ConfigMap("configs/saxton_hale/skial.cfg");
		g_data.medigun_recharge = FindConVar("vsh2_medigun_reset_amount");
		g_data.health_boost = FindConVar("tf_max_health_boost").FloatValue;
		
		if( !VSH2_HookEx(OnPlayerTakeFallDamage, OnSkialTakeFallDmg) )
			LogError("Error Hooking OnPlayerTakeFallDamage forward for Mub-VSH2 plugin.");
		if( !VSH2_HookEx(OnBannerDeployed, OnSkialBanners) )
			LogError("Error Hooking OnBannerDeployed forward for Mub-VSH2 plugin.");
		if( !VSH2_HookEx(OnBossTakeDamage_OnMarketGardened, OnSkialMG) )
			LogError("Error Hooking OnBossTakeDamage_OnMarketGardened forward for Mub-VSH2 plugin.");
		if( !VSH2_HookEx(OnBossTakeDamage_OnStabbed, OnSkialStab) )
			LogError("Error Hooking OnBossTakeDamage_OnStabbed forward for Mub-VSH2 plugin.");
		if( !VSH2_HookEx(OnBossTakeDamage_OnSniped, OnSkialSniped) )
			LogError("Error Hooking OnBossTakeDamage_OnSniped forward for Mub-VSH2 plugin.");
		if( !VSH2_HookEx(OnRedPlayerThink, OnSkialThink) )
			LogError("Error Hooking OnRedPlayerThink forward for Mub-VSH2 plugin.");
		if( !VSH2_HookEx(OnUberLoopEnd, OnSkialEndUber) )
			LogError("Error Hooking OnUberLoopEnd forward for Mub-VSH2 plugin.");
		if( !VSH2_HookEx(OnBossDealDamage, OnSkialOBDD) )
			LogError("Error Hooking OnBossDealDamage forward for Mub-VSH2 plugin.");
		if( !VSH2_HookEx(OnBossTakeDamage, OnSkialUseCaber) )
			LogError("Error Hooking OnBossTakeDamage forward for Mub-VSH2 plugin.");
		
		g_data.melee_heal_building = CreateConVar("vsh2_mub_vsh_building_amount", "50", "how much health to give to buildings when hit by the homewrecker.", FCVAR_NONE, true, 0.0, true, 99999.0);
		HookEvent("player_builtobject", OnSkialBuiltObj);
	}
}

public void OnLibraryRemoved(const char[] name) {
	g_data.vsh2 = false;
	delete g_data.cfg;
}

public Action OnSkialBuiltObj(Event event, const char[] name, bool dontBroadcast) {
	SDKHook(event.GetInt("index"), SDKHook_OnTakeDamage, OnBuildingTakeDamage);
	return Plugin_Continue;
}

public Action OnBuildingTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if( !g_data.vsh2 || !IsClientValid(attacker) ) {
		return Plugin_Continue;
	} else if( GetEntProp(victim, Prop_Send, "m_iTeamNum")==GetClientTeam(attacker) && GetItemIndex(weapon)==153 ) {
		/// Homewrecker healing!
		int currhp = GetEntProp(victim, Prop_Data, "m_iHealth");
		int maxhp  = GetEntProp(victim, Prop_Data, "m_iMaxHealth");
		if( currhp < maxhp ) {
			int heal_amount = g_data.melee_heal_building.IntValue;
			SetEntProp(victim, Prop_Data, "m_iHealth", (currhp + heal_amount < maxhp) ? currhp + heal_amount : maxhp);
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

public Action OnSkialTakeFallDmg(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	TFClassType tfcls = victim.GetTFClass();
	int client = victim.index;
	float reduce = 0.1;
	switch( tfcls ) {
		case TFClass_DemoMan: {
			int item = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
			if( item <= 0 || !IsValidEntity(item) ) {
				g_data.cfg.GetFloat("skial.demoman falldmg", reduce);
				damage *= reduce;
				return Plugin_Changed;
			}
		}
		case TFClass_Soldier: {
			int item = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
			if( item <= 0 || !IsValidEntity(item) ) {
				g_data.cfg.GetFloat("skial.soldier falldmg", reduce);
				damage *= reduce;
				return Plugin_Changed;
			}
		}
		case TFClass_Sniper: {
			int item = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
			if( item <= 0 || !IsValidEntity(item) ) {
				g_data.cfg.GetFloat("skial.sniper falldmg", reduce);
				damage *= reduce;
				return Plugin_Changed;
			}
		}
		case TFClass_Spy: {
			if( TF2_IsPlayerInCondition(client, TFCond_Cloaked) ) {
				g_data.cfg.GetFloat("skial.spy falldmg", reduce);
				damage *= reduce;
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

public Action OnSkialMG(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	int formula_len = g_data.cfg.GetSize("skial.market garden dmg");
	char[] formula = new char[formula_len];
	if( g_data.cfg.Get("skial.market garden dmg", formula, formula_len) <= 0 )
		return Plugin_Continue;
	
	float values[10];
	values[0] = float(victim.GetPropInt("iMaxHealth"));
	values[1] = float(victim.GetPropInt("iMarketted"));
	values[2] = float(VSH2GameMode.CountBosses(true));
	float res = ParseFormula(formula, values);
	if( res > 0.0 ) {
		damage = res;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action OnSkialStab(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	int formula_len = g_data.cfg.GetSize("skial.backstab dmg");
	char[] formula = new char[formula_len];
	if( g_data.cfg.Get("skial.backstab dmg", formula, formula_len) <= 0 )
		return Plugin_Continue;
	
	float values[10];
	values[0] = float(victim.GetPropInt("iMaxHealth"));
	values[1] = float(victim.GetPropInt("iStabbed"));
	values[2] = float(VSH2GameMode.CountBosses(true));
	float res = ParseFormula(formula, values);
	if( res > 0.0 ) {
		damage = res;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

stock int GetItemIndex(int item) {
	return ( IsValidEntity(item) )? GetEntProp(item, Prop_Send, "m_iItemDefinitionIndex") : -1;
}

stock bool IsClientValid(int client) {
	return( 0 < client && client <= MaxClients && IsClientInGame(client) );
}

public float ParseFormula(const char[] formula, const float vals[10]) {
	LexState ls;
	ls.syms = "abcdefnxyz";
	ls.values = vals;
	GetToken(ls, formula);
	return ParseAddExpr(ls, formula);
}

public float ParseAddExpr(LexState ls, const char[] formula) {
	float val = ParseMulExpr(ls, formula);
	if( ls.tok.tag==TokenPlus ) {
		GetToken(ls, formula);
		float a = ParseAddExpr(ls, formula);
		return val + a;
	} else if( ls.tok.tag==TokenSub ) {
		GetToken(ls, formula);
		float a = ParseAddExpr(ls, formula);
		return val - a;
	}
	return val;
}

public float ParseMulExpr(LexState ls, const char[] formula) {
	float val = ParsePowExpr(ls, formula);
	if( ls.tok.tag==TokenMul ) {
		GetToken(ls, formula);
		float m = ParseMulExpr(ls, formula);
		return val * m;
	} else if( ls.tok.tag==TokenDiv ) {
		GetToken(ls, formula);
		float m = ParseMulExpr(ls, formula);
		return val / m;
	}
	return val;
}

public float ParsePowExpr(LexState ls, const char[] formula) {
	float val = ParseFactor(ls, formula);
	if( ls.tok.tag==TokenPow ) {
		GetToken(ls, formula);
		float e = ParsePowExpr(ls, formula);
		float p = Pow(val, e);
		return p;
	}
	return val;
}

public float ParseFactor(LexState ls, const char[] formula) {
	switch( ls.tok.tag ) {
		case TokenNum: {
			float f = ls.tok.val;
			GetToken(ls, formula);
			return f;
		}
		case TokenVar: {
			GetToken(ls, formula);
			int n = -1;
			for( int i; i<sizeof(ls.values); i++ ) {
				if( ls.tok.lexeme[0]==ls.syms[i] ) {
					n = i;
					break;
				}
			}
			if( n == -1 ) {
				LogError("VSH2/FF2 Formula Parser :: undefined symbol '%s'", ls.tok.lexeme);
				return 0.0;
			}
			return ls.values[n];
		}
		case TokenLParen: {
			GetToken(ls, formula);
			float f = ParseAddExpr(ls, formula);
			if( ls.tok.tag != TokenRParen ) {
				LogError("VSH2/FF2 Formula Parser :: expected ')' bracket but got '%s'", ls.tok.lexeme);
				return 0.0;
			}
			GetToken(ls, formula);
			return f;
		}
		case TokenLBrack: {
			GetToken(ls, formula);
			float f = ParseAddExpr(ls, formula);
			if( ls.tok.tag != TokenRBrack ) {
				LogError("VSH2/FF2 Formula Parser :: expected ']' bracket but got '%s'", ls.tok.lexeme);
				return 0.0;
			}
			GetToken(ls, formula);
			return f;
		}
	}
	return 0.0;
}

public bool LexOctal(LexState ls, const char[] formula) {
	while( formula[ls.i] != 0 && (IsCharNumeric(formula[ls.i])) ) {
		switch( formula[ls.i] ) {
			case '0', '1', '2', '3', '4', '5', '6', '7': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
			}
			default: {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				LogError("VSH2/FF2 Formula Parser :: invalid octal literal: '%s'", ls.tok.lexeme);
				return false;
			}
		}
	}
	return true;
}

public bool LexHex(LexState ls, const char[] formula) {
	while( formula[ls.i] != 0 && (IsCharNumeric(formula[ls.i]) || IsCharAlpha(formula[ls.i])) ) {
		switch( formula[ls.i] ) {
			case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
				'a', 'b', 'c', 'd', 'e', 'f',
				'A', 'B', 'C', 'D', 'E', 'F': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
			}
			default: {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				LogError("VSH2/FF2 Formula Parser :: invalid hex literal: '%s'", ls.tok.lexeme);
				return false;
			}
		}
	}
	return true;
}

public bool LexDec(LexState ls, const char[] formula) {
	int lit_flags = 0;
	while( formula[ls.i] != 0 && (IsCharNumeric(formula[ls.i]) || formula[ls.i]=='.') ) {
		switch( formula[ls.i] ) {
			case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
			}
			case '.': {
				if( lit_flags & dot_flag ) {
					LogError("VSH2/FF2 Formula Parser :: extra dot in decimal literal");
					return false;
				}
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				lit_flags |= dot_flag;
			}
			default: {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				LogError("VSH2/FF2 Formula Parser :: invalid decimal literal: '%s'", ls.tok.lexeme);
				return false;
			}
		}
	}
	return true;
}

public void GetToken(LexState ls, const char[] formula)
{
	int len = strlen(formula);
	Token empty;
	ls.tok = empty;
	while( ls.i<len ) {
		switch( formula[ls.i] ) {
			case ' ', '\t', '\n': {
				ls.i++;
			}
			case '0': { /// possible hex, octal, binary, or float.
				ls.tok.tag = TokenNum;
				ls.i++;
				switch( formula[ls.i] ) {
					case 'o', 'O': {
						/// Octal.
						ls.i++;
						if( LexOctal(ls, formula) ) {
							ls.tok.val = StringToInt(ls.tok.lexeme, 8) + 0.0;
						}
						return;
					}
					case 'x', 'X': {
						/// Hex.
						ls.i++;
						if( LexHex(ls, formula) ) {
							ls.tok.val = StringToInt(ls.tok.lexeme, 16) + 0.0;
						}
						return;
					}
					case '.', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9': {
						/// Decimal/Float.
						if( LexDec(ls, formula) ) {
							ls.tok.val = StringToFloat(ls.tok.lexeme);
						}
						return;
					}
				}
			}
			case '.', '1', '2', '3', '4', '5', '6', '7', '8', '9': {
				ls.tok.tag = TokenNum;
				/// Decimal/Float.
				if( LexDec(ls, formula) ) {
					ls.tok.val = StringToFloat(ls.tok.lexeme);
				}
				return;
			}
			case '(': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				ls.tok.tag = TokenLParen;
				return;
			}
			case ')': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				ls.tok.tag = TokenRParen;
				return;
			}
			case '[': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				ls.tok.tag = TokenLBrack;
				return;
			}
			case ']': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				ls.tok.tag = TokenRBrack;
				return;
			}
			case '+': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				ls.tok.tag = TokenPlus;
				return;
			}
			case '-': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				ls.tok.tag = TokenSub;
				return;
			}
			case '*': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				ls.tok.tag = TokenMul;
				return;
			}
			case '/': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				ls.tok.tag = TokenDiv;
				return;
			}
			case '^': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				ls.tok.tag = TokenPow;
				return;
			}
			case 'a', 'b', 'c', 'd', 'e', 'f', 'n', 'x', 'y', 'z': {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				ls.tok.tag = TokenVar;
				return;
			}
			default: {
				ls.tok.lexeme[ls.tok.size++] = formula[ls.i++];
				LogError("VSH2/FF2 Formula Parser :: invalid formula token '%s'.", ls.tok.lexeme);
				return;
			}
		}
	}
}

public Action OnSkialBanners(const VSH2Player owner, BannerType banner) {
	switch( banner ) {
		case BannerBuff: {
			TF2_AddCondition(owner.index, TFCond_CritOnWin, 10.0);
		}
		case BannerDefBuff: {
			int maxhp = GetEntProp(owner.index, Prop_Data, "m_iMaxHealth");
			int overheal = RoundFloat(FindConVar("tf_max_health_boost").FloatValue * maxhp);
			owner.iHealth = overheal;
		}
	}
	return Plugin_Continue;
}

public Action OnSkialSniped(const VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, const float damageForce[3], const float damagePosition[3], int damagecustom) {
	return Plugin_Changed;
}

public void OnSkialThink(const VSH2Player player) {
	int client = player.index;
	if( player.GetTFClass()==TFClass_Scout && TF2_IsPlayerInCondition(client, TFCond_Bonked) ) {
		TF2_AddCondition(client, TFCond_RuneAgility, 0.2);
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.25);
	}
	
	if( TF2_IsPlayerInCondition(client, TFCond_InHealRadius) ) {
		int maxhp = GetEntProp(client, Prop_Data, "m_iMaxHealth");
		int overheal = RoundFloat(g_data.health_boost * maxhp);
		if( (player.iHealth - maxhp) < (overheal - maxhp) )
			player.iHealth++;
	}
}

public Action OnSkialEndUber(const VSH2Player medic, const VSH2Player target, float& charge) {
	int client = medic.index;
	int vitasaw = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if( vitasaw > MaxClients && IsValidEntity(vitasaw) && GetItemIndex(vitasaw)==173 ) {
		float def_charge = 41.0;
		if( g_data.cfg.GetFloat("skial.vitasaw post uber charge", def_charge) > 0 )
			charge = def_charge / 100.0;
	}
	return Plugin_Continue;
}

public Action OnSkialOBDD(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	if( victim.GetTFClass()==TFClass_DemoMan && IsValidEntity(victim.FindBack({405, 608}, 2)) ) {
		ScaleVector(damageForce, 9.0);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action OnSkialUseCaber(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	if( GetItemIndex(weapon)==307 ) {
		int formula_len = g_data.cfg.GetSize("skial.caber dmg");
		char[] formula = new char[formula_len];
		if( g_data.cfg.Get("skial.caber dmg", formula, formula_len) <= 0 )
			return Plugin_Continue;
		
		float values[10];
		values[0] = float(victim.GetPropInt("iMaxHealth"));
		values[1] = float(victim.iHealth);
		float res = ParseFormula(formula, values);
		if( res > 0.0 ) {
			damage = res;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

/**
 * * 6) Pickaxes: combine
 * 
 * Demoman:
 * * 12) Boots: increased melee knockback
 * * 13) Caber: configurable chunk damage + death on hit
 * 
 * Heavy:
 * * 14) Dalokohs/Fishcake: +50 more HP for 100 more HP total during duration
 */

/**
 * issues:
 * * market gardener & backstab damage glitching out.
 * * Homewrecker doesn't work.
 * * Caber doesn't work.
 */
