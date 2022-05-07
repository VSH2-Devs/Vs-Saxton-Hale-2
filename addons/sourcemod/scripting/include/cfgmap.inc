/**
 * cfgmap.inc
 *
 * Copyright [2020] Nergal the Ashurian
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE ANDNONINFRINGEMENT.
 *
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#if defined _cfgmap_included
	#endinput
#endif
#define _cfgmap_included

#include <adt_array>
#include <adt_trie>
#include <adt_stack>
#include <textparse>
#include <datapack>


enum KeyValType {
	KeyValType_Null,     /// nil
	KeyValType_Section,  /// StringMap : char[*][*]
	KeyValType_Value,    /// char[*]
};

enum struct PackVal {
	DataPack   data;
	int        size;
	KeyValType tag;
}

enum { SEC_SCOPE_SIZE=512 };
enum struct KeyValState {
	SMCParser  parser;
	
	/// Stack to store old StringMap tops to pop back later.
	ArrayStack cfgstack;
	
	/// store old (sub)section names.
	ArrayStack secstack;
	
	/// store old (sub)section enum values.
	ArrayStack enum_stack;
	
	/// the current StringMap instance we're working with.
	StringMap  top;
	
	char       curr_section[PLATFORM_MAX_PATH];
	
	int        enumer_global; /// for keeping track of <ENUM> value.
	int        enumer_local;  /// for keeping track of <enum> value.
	int        iota_global;   /// for keeping track of <IOTA> value.
	int        iota_local;    /// for keeping track of <iota> value.
}

static KeyValState g_kvstate;


methodmap ConfigMap < StringMap {
	public ConfigMap(const char[] filename) {
		char path[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, path, sizeof(path), filename);
		
		g_kvstate.cfgstack = new ArrayStack();
		g_kvstate.enum_stack = new ArrayStack();
		g_kvstate.secstack = new ArrayStack(PLATFORM_MAX_PATH);
		g_kvstate.top = new StringMap();
		g_kvstate.enumer_global = g_kvstate.iota_global = 0;
		g_kvstate.enumer_local = g_kvstate.iota_local = 0;
		
		g_kvstate.parser = new SMCParser();
		g_kvstate.parser.OnEnterSection = ConfigMap_OnNewSection;
		g_kvstate.parser.OnKeyValue = ConfigMap_OnKeyValue;
		g_kvstate.parser.OnLeaveSection = ConfigMap_OnEndSection;
		g_kvstate.parser.OnRawLine = ConfigMap_OnCurrentLine;
		
		SMCError err = g_kvstate.parser.ParseFile(path);
		//PrintCfg(view_as< ConfigMap >(g_kvstate.top));
		if( err != SMCError_Okay ) {
			char buffer[64];
			if( g_kvstate.parser.GetErrorString(err, buffer, sizeof(buffer)) ) {
				LogError("ConfigMap Err (%s) :: **** %s ****", path, buffer);
			} else {
				LogError("ConfigMap Err (%s) :: **** Unknown Fatal Parse Error ****", path);
			}
			
			if( g_kvstate.top != null ) {
				DeleteCfg(view_as< ConfigMap >(g_kvstate.top));
			}
		}
		delete g_kvstate.parser;
		delete g_kvstate.cfgstack;
		delete g_kvstate.secstack;
		delete g_kvstate.enum_stack;
		
		StringMap cfg = g_kvstate.top;
		if( g_kvstate.top != null ) {
			g_kvstate.top = null;
		}
		return view_as< ConfigMap >(cfg);
	}
	
	public bool GetVal(const char[] key, PackVal valbuf)
	{
		if( this==null ) {
			return false;
		}
		
		/// first check if we're getting a singular value OR we iterate through a sectional path.
		int dot = FindCharInString(key, '.');
		/// Patch: dot and escaped dot glitching out the hashmap hashing...
		if( dot == -1 || (dot > 0 && key[dot-1]=='\\') ) {
			PackVal val;
			bool result = this.GetArray(key, val, sizeof(val));
			if( result && val.tag != KeyValType_Null ) {
				valbuf = val;
				return true;
			}
			return false;
		}
		
		/// ok, not a singular value, iterate to the specific linkmap section then.
		/// parse the target key first.
		int i; /// used for `key`.
		char target_section[PLATFORM_MAX_PATH];
		ParseTargetPath(key, target_section, sizeof(target_section));
		
		ConfigMap itermap = this;
		while( itermap != null ) {
			int n;
			char curr_section[PLATFORM_MAX_PATH];
			/// Patch: allow keys to use dot without interfering with dot path.
			while( key[i] != 0 ) {
				if( key[i]=='\\' && key[i+1] != 0 && key[i+1]=='.' ) {
					i++;
					if( n<PLATFORM_MAX_PATH ) {
						curr_section[n++] = key[i++];
					}
				} else if( key[i]=='.' ) {
					i++;
					break;
				} else {
					if( n<PLATFORM_MAX_PATH ) {
						curr_section[n++] = key[i++];
					}
				}
			}
			PackVal val;
			bool result = itermap.GetArray(curr_section, val, sizeof(val));
			if( !result ) {
				break;
			} else if( StrEqual(curr_section, target_section) ) {
				valbuf = val;
				return true;
			} else if( val.tag==KeyValType_Section ) {
				val.data.Reset();
				itermap = val.data.ReadCell();
			}
		}
		return false;
	}
	
	public bool SetVal(const char[] key, const char[] val_str = "", int val_size = 0) {
		if( this==null ) {
			return false;
		}

		/// if "do_erase" is set true, "SetVal" will behave as "RemoveVal", iterate and recursively delete the elements.
		bool do_erase = val_size < 0;
		/// first check if we're getting a singular value OR we iterate through a sectional path.
		int dot = FindCharInString(key, '.');
		/// Patch: dot and escaped dot glitching out the hashmap hashing...
		if( dot == -1 || (dot > 0 && key[dot-1]=='\\') ) {
			PackVal val;
			bool result = this.GetArray(key, val, sizeof(val));
			KeyValType tag = val.tag;
			
			if( result && tag != KeyValType_Null ) {
				if( do_erase ) {
					if( val.tag==KeyValType_Section ) {
						val.data.Reset();
						ConfigMap cfg = val.data.ReadCell();
						DeleteCfg(cfg);
					}
					delete val.data;
					this.Remove(key);
				} else if( tag==KeyValType_Value ) {
					val.data.Reset();
					val.data.WriteString(val_str);
					val.size = val_size;
					this.SetArray(key, val, sizeof(val));
				}
				return true;
			}
			return false;
		}

		/// ok, not a singular value, iterate to the specific linkmap section then.
		/// parse the target key first.
		int i; /// used for `key`.
		char target_section[PLATFORM_MAX_PATH];
		ParseTargetPath(key, target_section, sizeof(target_section));
		
		ConfigMap itermap = this;
		while( itermap != null ) {
			int n;
			char curr_section[PLATFORM_MAX_PATH];
			/// Patch: allow keys to use dot without interfering with dot path.
			while( key[i] != 0 ) {
				if( key[i]=='\\' && key[i+1] != 0 && key[i+1]=='.' ) {
					i++;
					if( n<PLATFORM_MAX_PATH ) {
						curr_section[n++] = key[i++];
					}
				} else if( key[i]=='.' ) {
					i++;
					break;
				} else {
					if( n<PLATFORM_MAX_PATH ) {
						curr_section[n++] = key[i++];
					}
				}
			}
			PackVal val;
			bool result = itermap.GetArray(curr_section, val, sizeof(val));
			if( !result ) {
				break;
			} else if( StrEqual(curr_section, target_section) ) {
				if( !do_erase ) {
					val.data.Reset();
					val.data.WriteString(val_str);
					val.size = val_size;
					itermap.SetArray(curr_section, val, sizeof(val));
				} else {
					if( val.tag==KeyValType_Section ) {
						val.data.Reset();
						ConfigMap cfg = val.data.ReadCell();
						DeleteCfg(cfg);
					}

					delete val.data;
					itermap.Remove(curr_section);
				}
				return true;
			} else if( val.tag==KeyValType_Section ) {
				val.data.Reset();
				itermap = val.data.ReadCell();
			}
		}
		return false;
	}
	
	/**
	 *
	 * name:      GetSize
	 * @param     key_path : key path to the data you need.
	 * @return    size of the string value.
	 * @note      to directly access subsections, use a '.' like "root.section.key"
	 *            for keys that have a dot in their name, use '\\.'
	 */
	public int GetSize(const char[] key_path) {
		if( this==null ) {
			return 0;
		}
		PackVal val;
		bool result = this.GetVal(key_path, val);
		return( result && val.tag==KeyValType_Value ) ? val.size : 0;
	}
	
	/**
	 *
	 * name:      Get
	 * @param     key_path : key path to the data you need.
	 * @param     buffer : buffer to store the string value.
	 * @param     buf_size : size of the buffer.
	 * @return    Number of chars used, 0 if error.
	 * @note      to directly access subsections, use a '.' like "root.section.key"
	 *            for keys that have a dot in their name, use '\\.'
	 */
	public int Get(const char[] key_path, char[] buffer, int buf_size) {
		if( this==null || buf_size<=0 ) {
			return 0;
		}
		PackVal val;
		bool result = this.GetVal(key_path, val);
		if( result && val.tag==KeyValType_Value ) {
			val.data.Reset();
			char[] src_buf = new char[val.size];
			val.data.ReadString(src_buf, val.size);
			return strcopy(buffer, buf_size, src_buf);
		}
		return 0;
	}
	
	/**
	 * 
	 * name:      Set
	 * @param     key_path : key path to the data you need.
	 * @param     str : new string to set.
	 * @return    true on success, false if the key doesn't exists.
	 * @note      to directly access subsections, use a '.' like "root.section.key"
	 *            for keys that have a dot in their name, use '\\.'
	 */
	public bool Set(const char[] key_path, const char[] str) {
		if( this==null ) {
			return false;
		}
		return this.SetVal(key_path, str, strlen(str) + 1);
	}
	
	/**
	 *
	 * name:      GetSection
	 * @param     key_path : key path to the data you need.
	 * @return    ConfigMap subsection if successful, null otherwise.
	 * @note      to directly access subsections, use a '.' like "root.section1.section2"
	 *            for keys that have a dot in their name, use '\\.'
	 */
	public ConfigMap GetSection(const char[] key_path) {
		if( this==null ) {
			return null;
		}
		PackVal val;
		bool result = this.GetVal(key_path, val);
		if( result && val.tag==KeyValType_Section ) {
			val.data.Reset();
			ConfigMap section = val.data.ReadCell();
			return section;
		}
		return null;
	}

	/**
	 *
	 * name:      GetKeyValType
	 * @param     key_path : key path to the data you need.
	 * @return    either Section or String type if successful, Null otherwise.
	 * @note      to directly access subsections, use a '.' like "root.section1.section2"
	 *            for keys that have a dot in their name, use '\\.'
	 */
	public KeyValType GetKeyValType(const char[] key_path) {
		if( this==null ) {
			return KeyValType_Null;
		}
		PackVal val;
		return( this.GetVal(key_path, val) ) ? val.tag : KeyValType_Null;
	}
	
	/**
	 *
	 * name:      GetInt
	 * @param     key_path : key path to the data you need.
	 * @param     val : int reference to store data.
	 * @param     base : numeric base to do the conversion with.
	 * @return    Number of chars used, 0 if error.
	 * @note      to directly access subsections, use a '.' like "root.section1.section2"
	 *            for keys that have a dot in their name, use '\\.'
	 */
	public int GetInt(const char[] key_path, int& i, int base=10) {
		if( this==null ) {
			return 0;
		}
		PackVal val;
		bool result = this.GetVal(key_path, val);
		if( result && val.tag==KeyValType_Value ) {
			val.data.Reset();
			char[] strval = new char[val.size];
			val.data.ReadString(strval, val.size);
			return StringToIntEx(strval, i, base);
		}
		return 0;
	}
	
	/**
	 * 
	 * name:      SetInt
	 * @param     key_path : key path to the data you need.
	 * @param     val : integer value to set data to.
	 * @return    true on success, false if the key doesn't exists.
	 * @note      to directly access subsections, use a '.' like "root.section1.section2"
	 *            for keys that have a dot in their name, use '\\.'
	 */
	public bool SetInt(const char[] key_path, int i, const char[] fmt="%i") {
		if( this==null ) {
			return false;
		}
		char val_str[15];
		int size = Format(val_str, sizeof(val_str), fmt, i);
		return this.SetVal(key_path, val_str, size);
	}
	
	/**
	 *
	 * name:      GetFloat
	 * @param     key_path : key path to the data you need.
	 * @param     val : float reference to store data.
	 * @return    Number of chars used, 0 if error.
	 * @note      to directly access subsections, use a '.' like "root.section1.section2"
	 *            for keys that have a dot in their name, use '\\.'
	 */
	public int GetFloat(const char[] key_path, float& f) {
		if( this==null ) {
			return 0;
		}
		PackVal val;
		bool result = this.GetVal(key_path, val);
		if( result && val.tag==KeyValType_Value ) {
			val.data.Reset();
			char[] strval = new char[val.size];
			val.data.ReadString(strval, val.size);
			return StringToFloatEx(strval, f);
		}
		return 0;
	}
	
	/**
	 * 
	 * name:      SetFloat
	 * @param     key_path : key path to the data you need.
	 * @param     val : float value to set data to.
	 * @return    true on success, false if the key doesn't exists.
	 * @note      to directly access subsections, use a '.' like "root.section1.section2"
	 *            for keys that have a dot in their name, use '\\.'
	 */
	public bool SetFloat(const char[] key_path, float f) {
		if( this==null ) {
			return false;
		}
		char val_str[15];
		int size = FloatToString(f, val_str, sizeof(val_str)) + 1;
		return this.SetVal(key_path, val_str, size);
	}

	/**
	 *
	 * name:      GetBool
	 * @param     key_path : key path to the data you need.
	 * @param     b : bool reference to store data.
	 * @param     simple : option to simplistically check string value as boolean or not.
	 * @return    Number of chars used, 0 if error.
	 * @note      to directly access subsections, use a '.' like "root.section1.section2"
	 *            for keys that have a dot in their name, use '\\.'
	 */
	public int GetBool(const char[] key_path, bool& b, bool simple=true) {
		if( this==null ) {
			return 0;
		}
		PackVal val;
		bool result = this.GetVal(key_path, val);
		if( result && val.tag==KeyValType_Value ) {
			val.data.Reset();
			char[] strval = new char[val.size];
			val.data.ReadString(strval, val.size);
			if( simple ) {
				b = StringToInt(strval) != 0;
			} else {
				if( !strcmp(strval, "true", false) || !strcmp(strval, "1", false) ) {
					b = true;
				} else if( !strcmp(strval, "false", false) || !strcmp(strval, "0", false) ) {
					b = false;
				} else {
					return 0;
				}
			}
			return val.size - 1;
		}
		return 0;
	}
	
	/**
	 * 
	 * name:      ExportToFile
	 * @param     sec_name : new section name.
	 * @param     path : path to store ConfigMap infos.
	 * @return    true on sucess, false otherwise.
	 */
	public bool ExportToFile(const char[] sec_name, const char[] path) {
		if( this==null ) {
			return false;
		}
		
		File file = OpenFile(path, "wt");
		if( file==null ) {
			return false;
		}
		bool res = ConfigMapToFile(this, sec_name, file);
		delete file;
		return res;
	}

	/**
	 * 
	 * name:      Clone
	 * @param     new_owner_pl : new plugin owner.
	 * @return    true on sucess, false otherwise.
	 */
	public ConfigMap Clone(Handle new_owner_pl) {
		if( this==null || new_owner_pl==null ) {
			return null;
		}
		
		ConfigMap map = view_as< ConfigMap >(new StringMap());
		if( !CloneConfigMap(this, map, new_owner_pl) ) {
			DeleteCfg(map);
		}
		return map;
	}
	
	/**
	 * 
	 * name:      DeleteSection
	 * @param     key_path : section path name to erase.
	 * @return    true on if section was successfully deleted, false otherwise.
	 * @note      to directly access subsections, use a '.' like "root.section1.section2"
	 *            for keys that have a dot in their name, use '\\.'
	 */
	public bool DeleteSection(const char[] key_path) {
		if( this==null ) {
			return false;
		}
		return this.SetVal(key_path, .val_size = -1);
	}
	
	/**
	 * 
	 * name:      GetIntKeySize
	 * @param     key : integer of a string key.
	 * @return    size of the string key, -1 if failed or key is negative.
	 * @note      Useful for accessing values that are named by integer (from using <enum>)
	 */
	public int GetIntKeySize(int key) {
		if( key < 0 ) {
			return -1;
		}
		char key_str[12];
		IntToString(key, key_str, sizeof(key_str));
		return this.GetSize(key_str);
	}
	
	/**
	 * 
	 * name:      GetIntKey
	 * @param     key : integer of a string key.
	 * @return    num characters copied, 0 if failed or key is negative.
	 * @note      Useful for accessing values that are named by integer (from using <enum>)
	 */
	public int GetIntKey(int key, char[] buffer, int buf_size) {
		if( key < 0 ) {
			return 0;
		}
		char key_str[12];
		IntToString(key, key_str, sizeof(key_str));
		return this.Get(key_str, buffer, buf_size);
	}
	
	public bool SetIntKey(int key, const char[] str) {
		if( key < 0 ) {
			return false;
		}
		char key_str[12];
		IntToString(key, key_str, sizeof(key_str));
		return this.Set(key_str, str);
	}
	
	/**
	 * 
	 * name:      GetIntSection
	 * @param     key : integer of a string key.
	 * @return    ConfigMap of a section, null if failed.
	 * @note      Useful for accessing values that are named by integer (from using <enum>)
	 */
	public ConfigMap GetIntSection(int key) {
		if( key < 0 ) {
			return null;
		}
		char key_str[12];
		IntToString(key, key_str, sizeof(key_str));
		return this.GetSection(key_str);
	}

	public KeyValType GetIntKeyValType(int key) {
		if( key < 0 ) {
			return KeyValType_Null;
		}
		char key_str[12];
		IntToString(key, key_str, sizeof(key_str));
		return this.GetKeyValType(key_str);
	}

	public int GetIntKeyInt(int key, int& i, int base=10) {
		if( key < 0 ) {
			return 0;
		}
		char key_str[12];
		IntToString(key, key_str, sizeof(key_str));
		return this.GetInt(key_str, i, base);
	}
	public bool SetIntKeyInt(int key, int i, const char[] fmt="%i") {
		if( key < 0 ) {
			return false;
		}
		char key_str[12];
		IntToString(key, key_str, sizeof(key_str));
		return this.SetInt(key_str, i, fmt);
	}
	
	public int GetIntKeyFloat(int key, float& f) {
		if( key < 0 ) {
			return 0;
		}
		char key_str[12];
		IntToString(key, key_str, sizeof(key_str));
		return this.GetFloat(key_str, f);
	}
	public bool SetIntKeyFloat(int key, float f) {
		if( key < 0 ) {
			return false;
		}
		char key_str[12];
		IntToString(key, key_str, sizeof(key_str));
		return this.SetFloat(key_str, f);
	}
	
	public int GetIntKeyBool(int key, bool& b, bool simple=true) {
		if( key < 0 ) {
			return 0;
		}
		char key_str[12];
		IntToString(key, key_str, sizeof(key_str));
		return this.GetBool(key_str, b, simple);
	}
};

public SMCResult ConfigMap_OnNewSection(SMCParser smc, const char[] name, bool opt_quotes)
{
	/// if we hit a new (sub)section,
	/// push the old head and add a new head to write the subsection.
	if( g_kvstate.top != null ) {
		g_kvstate.cfgstack.Push(g_kvstate.top);
	}
	if( g_kvstate.curr_section[0] != 0 ) {
		g_kvstate.secstack.PushString(g_kvstate.curr_section);
	}
	
	g_kvstate.top = new StringMap();
	strcopy(g_kvstate.curr_section, sizeof(g_kvstate.curr_section), name);
	g_kvstate.enum_stack.Push(g_kvstate.enumer_local);
	g_kvstate.enum_stack.Push(g_kvstate.iota_local);
	g_kvstate.enumer_local = g_kvstate.iota_local = 0;
	return SMCParse_Continue;
}

public SMCResult ConfigMap_OnKeyValue(SMCParser smc, const char[] key, const char[] value, bool key_quotes, bool value_quotes)
{
	PackVal val;
	val.data = new DataPack();
	if( StrEqual(value, "<IOTA>") ) {
		char iota_val_str[15];
		int iota_val = g_kvstate.iota_global++;
		IntToString(iota_val, iota_val_str, sizeof iota_val_str);
		val.data.WriteString(iota_val_str);
		val.size = strlen(iota_val_str) + 1;
	} else if( StrEqual(value, "<iota>") ) {
		char iota_val_str[15];
		int iota_val = g_kvstate.iota_local++;
		IntToString(iota_val, iota_val_str, sizeof iota_val_str);
		val.data.WriteString(iota_val_str);
		val.size = strlen(iota_val_str) + 1;
	} else {
		val.data.WriteString(value);
		val.size = strlen(value) + 1;
	}
	val.tag = KeyValType_Value;
	
	if( StrEqual(key, "<ENUM>") ) {
		int enum_val = g_kvstate.enumer_global++;
		char enum_val_str[15]; IntToString(enum_val, enum_val_str, sizeof enum_val_str);
		g_kvstate.top.SetArray(enum_val_str, val, sizeof(val));
	} else if( StrEqual(key, "<enum>") ) {
		int enum_val = g_kvstate.enumer_local++;
		char enum_val_str[15]; IntToString(enum_val, enum_val_str, sizeof enum_val_str);
		g_kvstate.top.SetArray(enum_val_str, val, sizeof(val));
	} else {
		g_kvstate.top.SetArray(key, val, sizeof(val));
	}
	return SMCParse_Continue;
}

public SMCResult ConfigMap_OnEndSection(SMCParser smc)
{
	g_kvstate.iota_local = g_kvstate.enum_stack.Pop();
	g_kvstate.enumer_local = g_kvstate.enum_stack.Pop();
	/// if our stack isn't empty, pop back our older top
	/// and push the newer one into it as a new section.
	if( !g_kvstate.cfgstack.Empty ) {
		StringMap higher = g_kvstate.cfgstack.Pop();
		
		PackVal val;
		val.data = new DataPack();
		val.data.WriteCell(g_kvstate.top);
		val.size = sizeof(g_kvstate.top);
		val.tag = KeyValType_Section;
		
		if( StrEqual(g_kvstate.curr_section, "<ENUM>") ) {
			int enum_val = g_kvstate.enumer_global++;
			char enum_val_str[15]; IntToString(enum_val, enum_val_str, sizeof enum_val_str);
			higher.SetArray(enum_val_str, val, sizeof(val));
		} else if( StrEqual(g_kvstate.curr_section, "<enum>") ) {
			int enum_val = g_kvstate.enumer_local++;
			char enum_val_str[15]; IntToString(enum_val, enum_val_str, sizeof enum_val_str);
			higher.SetArray(enum_val_str, val, sizeof(val));
		} else {
			higher.SetArray(g_kvstate.curr_section, val, sizeof(val));
		}
		
		if( !g_kvstate.secstack.Empty ) {
			g_kvstate.secstack.PopString(g_kvstate.curr_section, sizeof(g_kvstate.curr_section));
		}
		g_kvstate.top = higher;
	}
	return SMCParse_Continue;
}

public SMCResult ConfigMap_OnCurrentLine(SMCParser smc, const char[] line, int lineno)
{
	return SMCParse_Continue;
}

/// ported from my C library: Harbol Config Parser.
stock bool ParseTargetPath(const char[] key, char[] buffer, int buffer_len)
{
	/// parse something like: "root.section1.section2.section3.\\..dotsection"
	int i = strlen(key) - 1;
	while( i > 0 ) {
		/// Allow escaping dots so we can use them in key-path iteration.
		if( key[i]=='.' ) {
			if( key[i-1]=='\\' ) {
				i--;
			} else {
				i++;
				break;
			}
		} else {
			i--;
		}
	}
	int n;
	/// now we save the target section and then use the resulting string.
	while( key[i] != 0 && n < buffer_len ) {
		if( key[i]=='\\' ) {
			i++;
			continue;
		}
		buffer[n++] = key[i++];
	}
	return n > 0;
}

stock void DeleteCfg(ConfigMap& cfg, bool clear_only=false) {
	if( cfg==null ) {
		return;
	}
	
	StringMapSnapshot snap = cfg.Snapshot();
	if( snap==null ) {
		return;
	}
	int entries = snap.Length;
	for( int i; i<entries; i++ ) {
		int strsize = snap.KeyBufferSize(i) + 1;
		char[] key_buffer = new char[strsize];
		snap.GetKey(i, key_buffer, strsize);
		PackVal val;
		cfg.GetArray(key_buffer, val, sizeof(val));
		switch( val.tag ) {
			case KeyValType_Value:
				delete val.data;
			case KeyValType_Section: {
				val.data.Reset();
				ConfigMap section = val.data.ReadCell();
				DeleteCfg(section);
				delete val.data;
			}
		}
	}
	delete snap;
	
	if( clear_only ) {
		cfg.Clear();
	} else {
		delete cfg;
	}
}

stock void PrintCfg(ConfigMap cfg) {
	if( cfg==null ) {
		return;
	}
	
	StringMapSnapshot snap = cfg.Snapshot();
	if( snap==null ) {
		return;
	}
	int entries = snap.Length;
	for( int i; i<entries; i++ ) {
		int strsize = snap.KeyBufferSize(i) + 1;
		char[] key_buffer = new char[strsize];
		snap.GetKey(i, key_buffer, strsize);
		PackVal val;
		cfg.GetArray(key_buffer, val, sizeof(val));
		switch( val.tag ) {
			case KeyValType_Value:
				PrintToServer("ConfigMap :: key: '%s', val.size: '%i'", key_buffer, val.size);
			case KeyValType_Section: {
				PrintToServer("ConfigMap :: \t\tkey: '%s', Section", key_buffer);
				val.data.Reset();
				ConfigMap section = val.data.ReadCell();
				PrintCfg(section);
			}
		}
	}
	delete snap;
}

static stock void ReplaceEscapeSeq(char[] str, int size)
{
	char list[][][] = {
		{ "\t", "\\t" },
		{ "\n", "\\n" },
		{ "\r", "\\r" }
	};
	for( int i; i<sizeof(list); i++ ) {
		ReplaceString(str, size, list[i][0], list[i][1]);
	}
}

static stock bool ConfigMapToFile(const ConfigMap cfg, const char[] sec_name, const File file, int deep = 0)
{
	StringMapSnapshot snap = cfg.Snapshot();
	if( snap==null ) {
		return false;
	}
	
	char[] tab = new char[deep];
	for( int i; i<deep; i++ ) {
		tab[i]='\t';
	}
	file.WriteLine("%s\"%s\" {", tab, sec_name);
	
	int size = snap.Length;
	for( int i; i<size; i++ ) {
		int strsize = snap.KeyBufferSize(i) + 1;
		char[] key = new char[strsize];
		snap.GetKey(i, key, strsize);
		PackVal pack;
		cfg.GetArray(key, pack, sizeof(pack));
		if( pack.tag==KeyValType_Null )
			continue;
		pack.data.Reset();
		switch( pack.tag ) {
			case KeyValType_Value: {
				int key_size = pack.size+10;
				char[] key_val = new char[key_size];
				pack.data.ReadString(key_val, key_size);
				ReplaceEscapeSeq(key_val, key_size);
				file.WriteLine("%s\t\"%s\"\t \"%s\"", tab, key, key_val);
			}
			case KeyValType_Section: {
				ConfigMap subsection = pack.data.ReadCell();
				if( !ConfigMapToFile(subsection, key, file, deep + 1) ) {
					delete snap;
					file.WriteLine("%s}", tab);
					return false;
				}
			}
		}
	}
	
	delete snap;
	file.WriteLine("%s}", tab);
	return true;
}

static stock bool CloneConfigMap(const ConfigMap cfg, ConfigMap new_cfg, Handle new_owner_pl)
{
	StringMapSnapshot snap = cfg.Snapshot();
	if( !snap ) {
		return false;
	}
	int size = snap.Length;
	for( int i; i<size; i++ ) {
		int strsize = snap.KeyBufferSize(i) + 1;
		char[] key_buffer = new char[strsize];
		snap.GetKey(i, key_buffer, strsize);
		PackVal pack;
		cfg.GetArray(key_buffer, pack, sizeof(pack));
		switch( pack.tag ) {
			case KeyValType_Value: {
				Handle data = pack.data;
				pack.data = view_as< DataPack >(CloneHandle(data, new_owner_pl));
				new_cfg.SetArray(key_buffer, pack, sizeof(pack));
			}
			case KeyValType_Section: {
				PackVal section_pack;
				section_pack.size = pack.size;
				section_pack.tag = pack.tag;
				ConfigMap new_subsec = view_as< ConfigMap >(new StringMap());
				
				DataPack val = new DataPack();
				val.WriteCell(new_subsec);
				section_pack.data = view_as< DataPack >(CloneHandle(val, new_owner_pl));
				delete val;
				
				new_cfg.SetArray(key_buffer, section_pack, sizeof(section_pack));
				
				pack.data.Reset();
				ConfigMap subsec = pack.data.ReadCell();
				
				if( !CloneConfigMap(subsec, new_subsec, new_owner_pl) ) {
					delete snap;
					return false;
				}
			}
		}
	}
	delete snap;
	return true;
}
