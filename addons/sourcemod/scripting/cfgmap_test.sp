#include <sourcemod>
#include <sdktools>
#include <cfgmap>

#pragma semicolon 1


static bool TestCase_GetSection_PredCallback(const char[] name, ConfigMap cursection) {
	int id;
	bool boolv;
	cursection.GetInt("id", id);
	PrintToServer("incoming %s - %i", name, id);
	return cursection.GetBool("boolv", boolv, false) && boolv;
}
	
methodmap TestCase {
	public static void GetKeyVals(ConfigMap sec) {
		/**
		 * 22 - 39
		 * count 3 == offcount 3
		 * offke[0] = 0, ke[offke[0]] = index
		 * offke[1] = 0, ke[offke[1]] = index
		 * offke[2] = 6, ke[offke[2]] = name
		 * count 3 == vacount 3
		 * offke[0] = 0, ke[offke[0]] = 450
		 * offke[1] = 4, ke[offke[1]] = tf_weapon_bat
		 * offke[2] = 18, ke[offke[2]] = 15 ; 0 ; 178 ; 0.001
		 */
		int keys, vals;
		int count = sec.GetCombinedKeyValLens(keys, vals);
		PrintToServer("%i - %i", keys, vals);
		
		{
			char[] ke = new char[keys];
			int[] offke = new int[count];
			int offcount = sec.GetKeys(ke, offke);
			
			PrintToServer("count %i == offcount %i", count, offcount);
			for( int i; i < count; i++ ) {
				PrintToServer("offke[%i] = %i, ke[offke[%i]] = %s", i, offke[i], i, ke[offke[i]]);
			}
		}
		{
			char[] va = new char[vals];
			int[] offva = new int[count];
			int vacount = sec.GetVals(va, offva);
			
			PrintToServer("count %i == vacount %i", count, vacount);
			for( int i; i < count; i++ ) {
				PrintToServer("offva[%i] = %i, va[offke[%i]] = %s", i, offva[i], i, va[offva[i]]);
			}
		}
	}
	
	/**
	 * "sounds" {
	 *	"enums" {
	 *		"<enum>" {
	 *			"id"	"<IOTA>"
	 *			"boolv"	"true"
	 *		}
	 *		"<enum>" {
	 *			"id"	"<IOTA>"
	 *			"boolv"	"false"
	 *		}
	 *		"<enum>" {
	 *			"id"	"<IOTA>"
	 *			"boolv"	"true"
	 *		}
	 *		"<enum>" {
	 *			"id"	"<IOTA>"
	 *			"boolv"	"true"
	 *		}
	 *	}
	 *	
	 *	"any" {
	 *		"a" {
	 *			"id"	"1010"
	 *		}
	 *		"b" {
	 *			"id"	"15"
	 *		}
	 *		"c" {
	 *			"id"	"85"
	 *		}
	 *		"d" {
	 *			"id"	"31"
	 *		}
	 *	}
	 * }
	 */
	
	public static void GetSections_Any(ConfigMap sec) {
		/**
		 * count 4 == scount 4
		 * subs[0].id = 15
		 * subs[1].id = 31
		 * subs[2].id = 1010
		 * subs[3].id = 85
		 */
		ConfigMap anysec = sec.GetSection("any");
		int count = anysec.Size;
		ConfigMap[] subs = new ConfigMap[count];
		int scount = anysec.GetSections(subs);
		PrintToServer("count %i == scount %i", count, scount);
		for( int i; i<scount; i++ ) {
			int id = -1;
			subs[i].GetInt("id", id);
			PrintToServer("subs[%i].id = %i", i, id);
		}
	}
	
	public static void GetSections_Pred(ConfigMap sec) {
		/**
		 * incoming 0 - 0
		 * incoming 2 - 2
		 * incoming 1 - 1
		 * incoming 3 - 3
		 * count 4 / scount 3
		 * subs[0].id = 0
		 * subs[1].id = 2
		 * subs[2].id = 3
		*/
		ConfigMap anysec = sec.GetSection("enums");
		int count = anysec.Size;
		ConfigMap[] subs = new ConfigMap[count];
		int scount = anysec.GetSections(subs, TestCase_GetSection_PredCallback);
		PrintToServer("count %i / scount %i", count, scount);
		for( int i; i<scount; i++ ) {
			int id = -1;
			subs[i].GetInt("id", id);
			PrintToServer("subs[%i].id = %i", i, id);
		}
	}
	
	/**
	 * "array_test" {
	 * 	"ints" "a['1', '3', '7', '9']"
	 * //"ints" {
	 * //		"<enum>"	"1"
	 * //	"<enum>"	"12"
	 * 		"<enum>"	"123"
	 * 		"<enum>"	"1234"
	 * 			
	 * 		}
	 * 	
	 * 	"floats" "a['0.1','3.0','7.6','9.5']"
	 * 	
	 * 	//"strings1" "a[ 'aaa', 'bbb',
	 * 	//	'xxx',
	 * 	//	'ddd'
	 * 	//]"
	 * 	
	 * 	//"strings2" "a[ 'aaa', 'bbb',
	 * 	//	'xxx',
	 * 	//	'ddd']"
	 * 	//
	 *
	 * 	//"strings3" "a[
	 *	//	'aaa',
	 *	//	'bbb',
	 * 	//	'xxx',
	 * 	//	'ddd'
	 *	//]"
	 * 	//
	 * 	
	 * 	"strings" "a[ 'aaa', 'bbb', 'xxx', 'ddd' ]"
	 * 	
	 * 	"bad" "a[
	 * 		'true',
	 * 		'5.0',
	 * 		'6.0',
	 * 		'what'
	 * 	]"
	 * }
	 */
	public static void GetTypes(ConfigMap sec) {
		
		PrintToServer("Ints:");
		{
			int size = sec.GetSectionSize("ints");
			int[] ints = new int[size];
			bool res = sec.GetInts("ints", ints, size);
			PrintToServer("%i - %i", res, size);
			for( int i; i < size; i++ ) {
				PrintToServer("ints[%i] = %i", i, ints[i]);
			}
		}
		PrintToServer("Floats:");
		{
			int size = sec.GetSectionSize("floats");
			float[] floats = new float[size];
			bool res = sec.GetFloats("floats", floats, size);
			PrintToServer("%i - %i", res, size);
			for( int i; i < size; i++ ) {
				PrintToServer("floats[%i] = %f", i, floats[i]);
			}
		}
		PrintToServer("Strings:");
		{
			TestCase.GetKeyVals(sec.GetSection("strings"));
		}
	}
	
	/**
	 * "include_test" {
	 * 	"A" {
	 * 		"OUT" {
	 * 			"Hello"	 "World"
	 * 		}
	 * 	}
	 * }
	 */
	public static void GetInclude(ConfigMap sec) {
		char world[8];
		sec.Get("OUT.Hello", world, sizeof(world));
		PrintToServer("world = %s", world);
	}
	
	public static void ReMap(ConfigMap sec, const char[] fname) {
		sec.ExportToFile("character", fname);
	}
}

public void OnPluginStart()
{
	ConfigMap cfg = new ConfigMap("configs/freak_fortress_2/test_cfg.cfg");
	
//	TestCase.GetKeyVals(cfg.GetSection("character.weapon1"));
//	TestCase.GetSections_Any(cfg.GetSection("character.sounds"));
//	TestCase.GetSections_Pred(cfg.GetSection("character.sounds"));
//	TestCase.GetTypes(cfg.GetSection("character.array_test"));
//	TestCase.GetInclude(cfg.GetSection("character.include_test.A"));
//	char path[PLATFORM_MAX_PATH]; BuildPath(Path_SM, path, sizeof(path), "configs/freak_fortress_2/test_cfg2.cfg");
//	TestCase.ReMap(cfg.GetSection("character"), path);
	
	DeleteCfg(cfg);
}

