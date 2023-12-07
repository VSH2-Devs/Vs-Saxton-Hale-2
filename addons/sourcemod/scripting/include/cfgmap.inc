/**
 * cfgmap.inc
 * 
 * Copyright [2022] Nergal the Ashurian
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


enum KeyValType {
	KeyValType_Null,    /// nil
	KeyValType_Section, /// StringMap : char[*][*]
	KeyValType_Value,   /// char[*]
};

typeset CustomKVParse {
	function Action (KeyValState kvstate, const char[] key, const char[] value, bool key_quotes, bool value_quotes);
	function void   (KeyValState kvstate, const char[] key, const char[] value, bool key_quotes, bool value_quotes);
}

typedef ConfigMapSectionFilter = function bool(const char[] name, ConfigMap cursection);
typedef ConfigMapMathVarFunc   = function void(const char[] var_name, int var_name_len, float &f, any data);


enum struct KeyValState {
	SMCParser parser;
	
	/// Stack to store old StringMap tops to pop back later.
	ArrayStack cfgstack;
	
	/// store old (sub)section names.
	ArrayStack secstack;
	
	/// store old (sub)section enum values.
	ArrayStack enum_stack;
	
	/// the current StringMap instance we're working with.
	StringMap top;
	
	/// holds data for use in the math expressions.
	any                  data;
	ConfigMapMathVarFunc math_func;
	
	char curr_section[PLATFORM_MAX_PATH];
	char filename[PLATFORM_MAX_PATH];
	char filepath[PLATFORM_MAX_PATH];
	
	int enum_global; /// for keeping track of <ENUM> value.
	int enum_local;  /// for keeping track of <enum> value.
	int iota_global; /// for keeping track of <IOTA> value.
	int iota_local;  /// for keeping track of <iota> value.
	int key_num;
	
	/// currently unused but kept for future.
	int value_len_limit; /// helps keep memory usage low by having a value size limit.
	
	Function parse_fn;
	
	bool debug_mode;
}

static KeyValState g_kvstate;

methodmap ConfigMap < StringMap {
	public ConfigMap(
		const char[]         filename,
		CustomKVParse        parse_func=INVALID_FUNCTION,
		bool                 debug_mode=false,
		ConfigMapMathVarFunc math_func=INVALID_FUNCTION,
		any                  data=0
	) {
		char path[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, path, sizeof(path), filename);
		
		strcopy(g_kvstate.filename, sizeof(g_kvstate.filename), filename);
		g_kvstate.filepath    = path;
		g_kvstate.cfgstack    = new ArrayStack();
		g_kvstate.enum_stack  = new ArrayStack();
		g_kvstate.secstack    = new ArrayStack(PLATFORM_MAX_PATH);
		g_kvstate.top         = new StringMap();
		g_kvstate.debug_mode  = debug_mode;
		if( g_kvstate.debug_mode ) {
			LogMessage("ConfigMap Debug :: Allocated Main CFG Map | Handle: '%i'", g_kvstate.top);
		}
		g_kvstate.enum_global = g_kvstate.iota_global = 0;
		g_kvstate.enum_local  = g_kvstate.iota_local = 0;
		g_kvstate.parse_fn    = parse_func;
		g_kvstate.key_num     = 0;
		g_kvstate.data        = data;
		g_kvstate.math_func   = math_func;
		
		g_kvstate.parser = new SMCParser();
		g_kvstate.parser.OnEnterSection = ConfigMap_OnNewSection;
		g_kvstate.parser.OnKeyValue     = ConfigMap_OnKeyValue;
		g_kvstate.parser.OnLeaveSection = ConfigMap_OnEndSection;
		g_kvstate.parser.OnRawLine      = ConfigMap_OnCurrentLine;
		
		SMCError err  = g_kvstate.parser.ParseFile(path);
		StringMap cfg = g_kvstate.top;
		delete g_kvstate.parser;
		delete g_kvstate.cfgstack;
		delete g_kvstate.secstack;
		delete g_kvstate.enum_stack;
		
		//PrintCfg(view_as< ConfigMap >(g_kvstate.top));
		if( err != SMCError_Okay ) {
			char buffer[64];
			if( g_kvstate.parser.GetErrorString(err, buffer, sizeof(buffer)) ) {
				LogError("ConfigMap Err (%s) :: **** %s ****", path, buffer);
			} else {
				LogError("ConfigMap Err (%s) :: **** Unknown Fatal Parse Error ****", path);
			}
			
			if( g_kvstate.top != null ) {
				DeleteCfg(view_as< ConfigMap >(cfg));
				g_kvstate.top = null;
			}
		}
		
		if( g_kvstate.top != null ) {
			cfg.SetString("__ConfigMap::filename__", filename);
			cfg.SetString("__ConfigMap::filepath__", path);
			cfg.SetValue("__ConfigMap::last_change_time__", GetFileTime(path, FileTime_LastChange));
			g_kvstate.top = null;
		}
		ConfigMap final_cfg = view_as< ConfigMap >(cfg);
		CfgInterpStrings(final_cfg, final_cfg);
		return final_cfg;
	}
	
	public static ConfigMap Make() {
		return view_as< ConfigMap >( new StringMap() );
	}
	
	property KeyValType KVType {
		public get() {
			KeyValType kvt; this.GetValue("__ConfigMap::kvtype__", kvt);
			return kvt;
		}
		public set(KeyValType kvt) {
			this.SetValue("__ConfigMap::kvtype__", kvt);
		}
	}
	property ConfigMap Section {
		public get() {
			if( this.KVType != KeyValType_Section ) {
				return null;
			}
			ConfigMap sect; this.GetValue("__ConfigMap::value__", sect);
			return sect;
		}
		public set(ConfigMap sect) {
			this.KVType = KeyValType_Section;
			this.SetValue("__ConfigMap::value__", sect);
			//this.Remove("__ConfigMap::int__");
			//this.Remove("__ConfigMap::float__");
			//this.Remove("__ConfigMap::bool__");
		}
	}
	property int Size {
		public get() {
			if( this==null ) {
				return -1;
			}
			int size; this.GetValue("__ConfigMap::size__", size);
			return size;
		}
		public set(int size) {
			this.SetValue("__ConfigMap::size__", size);
		}
	}
	property int Len {
		public get() {
			if( this==null ) {
				return -1;
			}
			int len; this.GetValue("__ConfigMap::len__", len);
			return len;
		}
		public set(int len) {
			this.SetValue("__ConfigMap::len__", len + 1);
		}
	}
	/*
	property ConfigMap Parent {
		public get() {
			if( this==null ) {
				return null;
			}
			ConfigMap parent; this.GetValue("__ConfigMap::parent__", parent);
			return parent;
		}
	}
	*/
	
	public bool SetStr(const char[] str, int len=0) {
		this.KVType = KeyValType_Value;
		this.Len = len==0? strlen(str) : len;
		return this.SetString("__ConfigMap::value__", str);
	}
	public bool GetStr(char[] buf, int len) {
		if( this.KVType != KeyValType_Value ) {
			return false;
		}
		return this.GetString("__ConfigMap::value__", buf, len);
	}
	public bool GetKey(int index, char[] buf, int len) {
		char final_key[30]; Format(final_key, sizeof(final_key), "__ConfigMap::key%i__", index);
		return this.GetString(final_key, buf, len);
	}
	public int GetKeySize(int index) {
		char final_key[30]; Format(final_key, sizeof(final_key), "__ConfigMap::key%i_len__", index);
		int i = -1; this.GetValue(final_key, i);
		return i;
	}
	public bool SetKey(int index, const char[] str, int len=0) {
		char final_key[30]; Format(final_key, sizeof(final_key), "__ConfigMap::key%i__", index);
		//int new_len = (len==0? strlen(str) : len) + (num_dots * 2) + 1;
		//char[] escaped_str = new char[new_len + 1];
		//strcopy(escaped_str, new_len, str);
		//LogMessage("CfgMap::SetKey - Before str : '%s'", escaped_str);
		//ReplaceString(escaped_str, new_len, ".", "\\.");
		//LogMessage("CfgMap::SetKey - After str : '%s'", escaped_str);
		
		bool insert_res = this.SetString(final_key, str);
		int key_len = len==0? strlen(str) : len;
		Format(final_key, sizeof(final_key), "__ConfigMap::key%i_len__", index);
		//int num_dots = CountChars(str, '.');
		//Format(final_key, sizeof(final_key), "__ConfigMap::key%i_dots__", num_dots);
		return this.SetValue(final_key, key_len + 1) && insert_res;
	}
	
	public bool CfgFileChanged() {
		if( this==null ) {
			return false;
		}
		char filepath[PLATFORM_MAX_PATH];
		this.GetString("__ConfigMap::filepath__", filepath, sizeof(filepath));
		int saved_file_time; this.GetValue("__ConfigMap::last_change_time__", saved_file_time);
		return saved_file_time != GetFileTime(filepath, FileTime_LastChange);
	}
	
	public ConfigMap GetValSimple(const char[] key) {
		ConfigMap val;
		if( this.GetValue(key, val) && val.KVType != KeyValType_Null ) {
			return val;
		}
		return null;
	}
	
	public ConfigMap GetValComplex(const char[] key) {
		if( key[0]==0 ) {
			return null;
		}
		/// not a singular value, iterate to the
		/// specific section then parse the target key first.
		int i; /// used for `key`.
		char target_section[PLATFORM_MAX_PATH];
		ParseTargetPath(key, target_section, sizeof(target_section));
		ConfigMap itermap = this;
		while( itermap != null ) {
			char curr_section[PLATFORM_MAX_PATH];
			int n;
			while( key[i] != 0 ) {
				if( key[i]=='\\' && key[i+1] != 0 && key[i+1]=='.' ) {
					i++;
					if( n < PLATFORM_MAX_PATH ) {
						curr_section[n++] = key[i++];
					}
				} else if( key[i]=='.' ) {
					i++;
					break;
				} else {
					if( n < PLATFORM_MAX_PATH ) {
						curr_section[n++] = key[i++];
					}
				}
			}
			ConfigMap val;
			//LogMessage("ConfigMap::GetVal :: curr_section = '%s' | target_section = '%s'", curr_section, target_section);
			if( !itermap.GetValue(curr_section, val) ) {
				break;
			} else if( StrEqual(curr_section, target_section) ) {
				return val;
			} else if( val.KVType==KeyValType_Section ) {
				itermap = val.Section;
			}
		}
		return null;
	}
	
	public ConfigMap GetVal(const char[] key) {
		if( this==null ) {
			return null;
		}
		ConfigMap val = this.GetValSimple(key);
		return( val != null )? val : this.GetValComplex(key);
	}
	
	public bool SetVal(const char[] key, const char[] val_str="", int val_size=0) {
		if( this==null || key[0]==0 ) {
			return false;
		}
		
		/// if "do_erase" is set true, "SetVal" will behave as "RemoveVal", iterate and recursively delete the elements.
		bool do_erase = val_size < 0;
		/// first check if we're getting a singular value OR we iterate through a sectional path.
		int dot = FindCharInString(key, '.');
		/// Patch: dot and escaped dot glitching out the hashmap hashing...
		if( dot == -1 || (dot > 0 && key[dot-1]=='\\') ) {
			ConfigMap val;
			bool result = this.GetValue(key, val);
			if( result && val != null ) {
				KeyValType tag = val.KVType;
				if( tag != KeyValType_Null ) {
					if( do_erase ) {
						if( tag==KeyValType_Section ) {
							ConfigMap cfg = val.Section;
							DeleteCfg(cfg);
						}
						delete val;
						this.Remove(key);
					} else if( tag==KeyValType_Value ) {
						val.SetStr(val_str, val_size);
					}
					return true;
				}
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
			char curr_section[PLATFORM_MAX_PATH];
			
			/// Patch: allow keys to use dot without interfering with dot path.
			int n;
			while( key[i] != 0 ) {
				if( key[i]=='\\' && key[i+1] != 0 && key[i+1]=='.' ) {
					i++;
					if( n < PLATFORM_MAX_PATH ) {
						curr_section[n++] = key[i++];
					}
				} else if( key[i]=='.' ) {
					i++;
					break;
				} else {
					if( n < PLATFORM_MAX_PATH ) {
						curr_section[n++] = key[i++];
					}
				}
			}
			ConfigMap val;
			bool result = itermap.GetValue(curr_section, val);
			if( !result ) {
				break;
			} else if( StrEqual(curr_section, target_section) ) {
				if( !do_erase ) {
					val.SetStr(val_str, val_size);
				} else {
					if( val.KVType==KeyValType_Section ) {
						ConfigMap cfg = val.Section;
						DeleteCfg(cfg);
					}
					delete val;
					itermap.Remove(curr_section);
				}
				return true;
			} else if( val.KVType==KeyValType_Section ) {
				itermap = val.Section;
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
		ConfigMap val = this.GetVal(key_path);
		return( val != null && val.KVType==KeyValType_Value )? val.Len : 0;
	}
	
	/**
	 *
	 * name:      GetSectionSize
	 * @param     key_path : key path to the section.
	 * @return    entries in the section.
	 * @note      to directly access subsections, use a '.' like "root.section.key"
	 *
	 */
	public int GetSectionSize(const char[] key_path) {
		if( this==null ) {
			return 0;
		}
		
		ConfigMap val = this.GetVal(key_path);
		if( val==null || val.KVType != KeyValType_Section ) {
			return 0;
		}
		return val.Section.Size;
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
		if( this==null || buf_size <= 0 ) {
			return 0;
		}
		
		ConfigMap val = this.GetVal(key_path);
		//LogMessage("ConfigMap::Get :: key_path == '%s' | val handle: '%i'", key_path, val);
		if( val != null && val.KVType==KeyValType_Value ) {
			int len = val.Len;
			char[] src_buf = new char[len];
			val.GetStr(src_buf, len);
			//LogMessage("ConfigMap::Get :: src_buf == '%s'", src_buf);
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
		ConfigMap val = this.GetVal(key_path);
		if( val != null && val.KVType==KeyValType_Section ) {
			return val.Section;
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
		ConfigMap val = this.GetVal(key_path);
		return( val != null )? val.KVType : KeyValType_Null;
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
		ConfigMap val = this.GetVal(key_path);
		if( val != null && val.KVType==KeyValType_Value ) {
			if( val.GetValue("__ConfigMap::int__", i) ) {
				return val.Len - 1;
			}
			int len = val.Len;
			char[] strval = new char[len];
			val.GetStr(strval, len);
			int num_chars = StringToIntEx(strval, i, base);
			val.SetValue("__ConfigMap::int__", i);
			return num_chars;
		}
		return 0;
	}
	
	public int GetIntEx(const char[] key_path, int default_val, int base=10, int &num_chars=0) {
		num_chars = this.GetInt(key_path, default_val, base);
		return default_val;
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
	public bool SetInt(const char[] key_path, int i) {
		if( this==null ) {
			return false;
		}
		
		ConfigMap val = this.GetVal(key_path);
		if( val==null || val.KVType != KeyValType_Value ) {
			return false;
		}
		char val_str[12]; IntToString(i, val_str, sizeof(val_str));
		val.SetStr(val_str);
		return val.SetValue("__ConfigMap::int__", i);
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
		
		ConfigMap val = this.GetVal(key_path);
		if( val != null && val.KVType==KeyValType_Value ) {
			if( val.GetValue("__ConfigMap::float__", f) ) {
				return val.Len - 1;
			}
			int len = val.Len;
			char[] strval = new char[len];
			val.GetStr(strval, len);
			int num_chars = StringToFloatEx(strval, f);
			val.SetValue("__ConfigMap::float__", f);
			return num_chars;
		}
		return 0;
	}
	
	public float GetFloatEx(const char[] key_path, float default_val, int &num_chars=0) {
		num_chars = this.GetFloat(key_path, default_val);
		return default_val;
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
		ConfigMap val = this.GetVal(key_path);
		if( val==null || val.KVType != KeyValType_Value ) {
			return false;
		}
		char val_str[40]; FloatToString(f, val_str, sizeof(val_str));
		val.SetStr(val_str);
		return val.SetValue("__ConfigMap::float__", f);
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
		ConfigMap val = this.GetVal(key_path);
		if( val != null && val.KVType==KeyValType_Value ) {
			if( val.GetValue("__ConfigMap::bool__", b) ) {
				return val.Len - 1;
			}
			char strval[2]; val.GetStr(strval, sizeof(strval)-1);
			if( simple ) {
				b = StringToInt(strval) != 0;
			} else {
				if( strval[0]=='T' || strval[0]=='t' || strval[0]=='1' ) {
					b = true;
				} else if( strval[0] == 'F' || strval[0] == 'f' || strval[0] == '0' ) {
					b = false;
				} else {
					return 0;
				}
			}
			val.SetValue("__ConfigMap::bool__", b);
			return val.Len - 1;
		}
		return 0;
	}
	
	public bool GetBoolEx(const char[] key_path, bool default_val, bool simple=true, int &num_chars=0) {
		num_chars = this.GetBool(key_path, default_val, simple);
		return default_val;
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
		char key_str[12]; IntToString(key, key_str, sizeof(key_str));
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
		char key_str[12]; IntToString(key, key_str, sizeof(key_str));
		return this.Get(key_str, buffer, buf_size);
	}
	
	public bool SetIntKey(int key, const char[] str) {
		if( key < 0 ) {
			return false;
		}
		char key_str[12]; IntToString(key, key_str, sizeof(key_str));
		return this.Set(key_str, str);
	}
	
	/**
	 * 
	 * name:      GetIntKeySection
	 * @param     key : integer of a string key.
	 * @return    ConfigMap of a section, null if failed.
	 * @note      Useful for accessing values that are named by integer (from using <enum>)
	 */
	public ConfigMap GetIntKeySection(int key) {
		if( key < 0 ) {
			return null;
		}
		char key_str[12]; IntToString(key, key_str, sizeof(key_str));
		return this.GetSection(key_str);
	}
	
	public KeyValType GetIntKeyValType(int key) {
		if( key < 0 ) {
			return KeyValType_Null;
		}
		char key_str[12]; IntToString(key, key_str, sizeof(key_str));
		return this.GetKeyValType(key_str);
	}
	
	public int GetIntKeyInt(int key, int& i, int base=10) {
		if( key < 0 ) {
			return 0;
		}
		char key_str[12]; IntToString(key, key_str, sizeof(key_str));
		return this.GetInt(key_str, i, base);
	}
	public bool SetIntKeyInt(int key, int i) {
		if( key < 0 ) {
			return false;
		}
		char key_str[12]; IntToString(key, key_str, sizeof(key_str));
		return this.SetInt(key_str, i);
	}
	public int GetIntKeyIntEx(int key, int default_val, int base=10, int &num_chars=0) {
		num_chars = this.GetIntKeyInt(key, default_val, base);
		return default_val;
	}
	
	public int GetIntKeyFloat(int key, float& f) {
		if( key < 0 ) {
			return 0;
		}
		char key_str[12]; IntToString(key, key_str, sizeof(key_str));
		return this.GetFloat(key_str, f);
	}
	public bool SetIntKeyFloat(int key, float f) {
		if( key < 0 ) {
			return false;
		}
		char key_str[12]; IntToString(key, key_str, sizeof(key_str));
		return this.SetFloat(key_str, f);
	}
	public float GetIntKeyFloatEx(int key, float default_val, int &num_chars=0) {
		num_chars = this.GetIntKeyFloat(key, default_val);
		return default_val;
	}
	
	public int GetIntKeyBool(int key, bool& b, bool simple=true) {
		if( key < 0 ) {
			return 0;
		}
		char key_str[12]; IntToString(key, key_str, sizeof(key_str));
		return this.GetBool(key_str, b, simple);
	}
	public bool GetIntKeyBoolEx(int key, bool default_val, bool simple=true, int &num_chars=0) {
		num_chars = this.GetIntKeyBool(key, default_val, simple);
		return default_val;
	}
	
	/// this is used with .Size property.
	/**
	 * int size = cfg.Size;
	 * ConfigMap[] sects = new ConfigMap[size];
	 * int num_sections = cfg.GetSections(sects, filter);
	 */
	public int GetSections(ConfigMap[] buffer, ConfigMapSectionFilter fn_filter=INVALID_FUNCTION) {
		if( this==null ) {
			return 0;
		}
		
		int count;
		int entries = this.Size;
		for( int i; i < entries; i++ ) {
			int key_len = this.GetKeySize(i);
			char[] key_buffer = new char[key_len + 1];
			this.GetKey(i, key_buffer, key_len);
			ConfigMap sect = this.GetSection(key_buffer);
			if( sect==null ) {
				continue;
			}
			
			if( fn_filter != INVALID_FUNCTION ) {
				Call_StartFunction(null, fn_filter);
				Call_PushString(key_buffer);
				Call_PushCell(sect);
				bool res; Call_Finish(res);
				if( !res ) {
					continue;
				}
			}
			buffer[count] = sect;
			count++;
		}
		return count;
	}
	
	public bool GetKeyAsInt(int index, int &i, int base=10) {
		if( this==null ) {
			return false;
		}
		int key_len = this.GetKeySize(index);
		if( key_len <= 1 ) {
			return false;
		}
		
		char[] key = new char[key_len + 1];
		if( !this.GetKey(index, key, key_len) ) {
			return false;
		}
		int num_chars = StringToIntEx(key, i, base);
		return num_chars > 0;
	}
	public int GetKeyAsIntEx(int index, int default_val, int base=10) {
		this.GetKeyAsInt(index, default_val, base);
		return default_val;
	}
	
	public bool GetKeyAsFloat(int index, float &f) {
		if( this==null ) {
			return false;
		}
		int key_len = this.GetKeySize(index);
		if( key_len <= 1 ) {
			return false;
		}
		
		char[] key = new char[key_len + 1];
		if( !this.GetKey(index, key, key_len) ) {
			return false;
		}
		int num_chars = StringToFloatEx(key, f);
		return num_chars > 0;
	}
	public float GetKeyAsFloatEx(int index, float default_val) {
		this.GetKeyAsFloat(index, default_val);
		return default_val;
	}
	
	public float CalcMath(const char[] key_path, ConfigMapMathVarFunc math_func=INVALID_FUNCTION, any data=0) {
		float f = view_as< float >(view_as< any >( -1 ));
		if( this==null ) {
			return f;
		}
		
		ConfigMap val = this.GetVal(key_path);
		if( val != null && val.KVType==KeyValType_Value ) {
			int len = val.Len;
			char[] expr = new char[len];
			val.GetStr(expr, len);
			f = ParseExpr(expr, math_func, data);
		}
		return f;
	}
	
	public int GetSectionNameSize(const char[] key_path) {
		int size;
		if( key_path[0]==0 ) {
			this.GetValue("__ConfigMap::sect_name_len__", size);
			return size;
		}
		
		ConfigMap val = this.GetVal(key_path);
		if( val != null ) {
			val.GetValue("__ConfigMap::sect_name_len__", size);
		}
		return size;
	}
	
	public bool GetSectionName(const char[] key_path, char[] buffer, int len) {
		if( key_path[0]==0 ) {
			return this.GetString("__ConfigMap::sect_name__", buffer, len);
		}
		
		ConfigMap val = this.GetVal(key_path);
		return( val != null )? val.GetString("__ConfigMap::sect_name__", buffer, len) : false;
	}
};


public SMCResult ConfigMap_OnNewSection(SMCParser smc, const char[] name, bool opt_quotes) {
	/// if we hit a new (sub)section,
	/// push the old head and add a new head to write the subsection.
	if( g_kvstate.top != null ) {
		g_kvstate.cfgstack.Push(g_kvstate.top);
	}
	if( g_kvstate.curr_section[0] != 0 ) {
		g_kvstate.secstack.PushString(g_kvstate.curr_section);
	}
	
	g_kvstate.top = new StringMap();
	if( g_kvstate.debug_mode ) {
		LogMessage("ConfigMap Debug :: Allocated Map for Section '%s'", name);
	}
	strcopy(g_kvstate.curr_section, sizeof(g_kvstate.curr_section), name);
	g_kvstate.enum_stack.Push(g_kvstate.enum_local);
	g_kvstate.enum_stack.Push(g_kvstate.iota_local);
	g_kvstate.enum_stack.Push(g_kvstate.key_num);
	g_kvstate.enum_local = g_kvstate.iota_local = g_kvstate.key_num = 0;
	return SMCParse_Continue;
}


stock int GetSubStringLen(const char[] text, int end, bool include_end=false) {
	int i;
	while( text[i] != 0 && text[i] != end ) {
		i++;
	}
	if( include_end && text[i]==end ) {
		i++;
	}
	return i + 1;
}
stock void ParseSubString(const char[] text, char[] buffer, int end, bool include_end=false) {
	int i;
	for( ; text[i] != 0 && text[i] != end; i++ ) {
		buffer[i] = text[i];
	}
	if( include_end && text[i]==end ) {
		buffer[i] = text[i];
	}
}

static stock void CfgCheckMathExprs(char[] new_value, int val_size) {
	int math_op = StrContains(new_value, "<math", false);
	if( math_op != -1 ) {
		int expression_idx = math_op + strlen("<math");
		int expression_len = GetSubStringLen(new_value[expression_idx], '>');
		if( g_kvstate.debug_mode ) {
			LogMessage("CfgMath:: expression_len = %i | new_value: '%s'", expression_len, new_value);
		}
		char[] expression = new char[expression_len];
		ParseSubString(new_value[expression_idx], expression, '>');
		if( g_kvstate.debug_mode ) {
			LogMessage("CfgMath:: Expr: '%s'", expression);
		}
		float result = ParseExpr(expression, g_kvstate.math_func, g_kvstate.data);
		char result_str[40]; Format(result_str, sizeof(result_str), "%f", result);
		
		int full_expr_len = expression_len + strlen("<math") + 1;
		char[] full_expr = new char[full_expr_len + 1];
		Format(full_expr, full_expr_len, "<math%s>", expression);
		ReplaceString(new_value, val_size, full_expr, result_str);
		if( g_kvstate.debug_mode ) {
			LogMessage("CfgMath:: Expr: '%s' :: Result = %f | new_value :: '%s'", expression, result, new_value);
		}
	}
}

public SMCResult ConfigMap_OnKeyValue(SMCParser smc, const char[] key, const char[] value, bool key_quotes, bool value_quotes) {
	if( g_kvstate.parse_fn != INVALID_FUNCTION ) {
		Action act;
		Call_StartFunction(null, g_kvstate.parse_fn);
		Call_PushArray(g_kvstate, sizeof(g_kvstate));
		Call_PushString(key);
		Call_PushString(value);
		Call_PushCell(key_quotes);
		Call_PushCell(value_quotes);
		Call_Finish(act);
		if( act > Plugin_Continue ) {
			return SMCParse_Continue;
		}
	}
	
	if( StrEqual(key, "<INCLUDE>", false) ) {
		/// prevent infinite self-including.
		if( StrEqual(g_kvstate.filename, value) ) {
			LogError("ConfigMap Warning (%s) :: **** caught infinite self-inclusion '%s' ****", g_kvstate.filepath, value);
			return SMCParse_Continue;
		}
		KeyValState old_kvstate;
		old_kvstate = g_kvstate;
		ConfigMap outter_file = new ConfigMap(value);
		g_kvstate = old_kvstate;
		if( outter_file==null ) {
			LogError("ConfigMap Warning (%s) :: **** failed to include '%s' ****", g_kvstate.filepath, value);
			return SMCParse_Continue;
		}
		
		ConfigMap val = ConfigMap.Make();
		val.Section = outter_file;
		if( g_kvstate.debug_mode ) {
			LogMessage("ConfigMap Debug :: Allocated ConfigMap for key: '%s' | Handle: '%i'", key, val);
		}
		g_kvstate.top.SetValue(value, val);
		view_as< ConfigMap >(g_kvstate.top).SetKey(g_kvstate.key_num, value);
		view_as< ConfigMap >(g_kvstate.top).Size++;
		g_kvstate.key_num++;
		return SMCParse_Continue;
	}
	
	ConfigMap val = ConfigMap.Make();
	if( g_kvstate.debug_mode ) {
		LogMessage("ConfigMap Debug :: Allocated ConfigMap for key: '%s' of value: '%s' | Handle: '%i'", key, value, val);
	}
	
	if( StrEqual(value, "<FILE>", false) ) {
		val.SetStr(g_kvstate.filepath);
	} else {
		int val_size = strlen(value) + 1;
		char[] new_value = new char[val_size];
		strcopy(new_value, val_size, value);
		if( StrContains(new_value, "<IOTA>") != -1 ) {
			int iota_val = g_kvstate.iota_global++;
			char iota_val_str[12]; IntToString(iota_val, iota_val_str, sizeof(iota_val_str));
			ReplaceString(new_value, val_size, "<IOTA>", iota_val_str);
		} else if( StrContains(new_value, "<iota>") != -1 ) {
			int iota_val = g_kvstate.iota_local++;
			char iota_val_str[12]; IntToString(iota_val, iota_val_str, sizeof(iota_val_str));
			ReplaceString(new_value, val_size, "<iota>", iota_val_str);
		}
		CfgCheckMathExprs(new_value, val_size);
		val.SetStr(new_value);
	}
	
	int key_size = strlen(key) + 1;
	char[] new_key = new char[key_size];
	strcopy(new_key, key_size, key);
	if( StrContains(key, "<ENUM>") != -1 ) {
		int enum_val = g_kvstate.enum_global++;
		char enum_val_str[12]; IntToString(enum_val, enum_val_str, sizeof(enum_val_str));
		ReplaceString(new_key, key_size-1, "<ENUM>", enum_val_str);
	} else if( StrContains(key, "<enum>") != -1 ) {
		int enum_val = g_kvstate.enum_local++;
		char enum_val_str[12]; IntToString(enum_val, enum_val_str, sizeof(enum_val_str));
		ReplaceString(new_key, key_size-1, "<enum>", enum_val_str);
	}
	CfgCheckMathExprs(new_key, key_size);
	g_kvstate.top.SetValue(new_key, val);
	view_as< ConfigMap >(g_kvstate.top).SetKey(g_kvstate.key_num, new_key);
	view_as< ConfigMap >(g_kvstate.top).Size++;
	g_kvstate.key_num++;
	return SMCParse_Continue;
}

public SMCResult ConfigMap_OnEndSection(SMCParser smc) {
	g_kvstate.key_num    = g_kvstate.enum_stack.Pop();
	g_kvstate.iota_local = g_kvstate.enum_stack.Pop();
	g_kvstate.enum_local = g_kvstate.enum_stack.Pop();
	
	/// if our stack isn't empty, pop back our older top
	/// and push the newer one into it as a new section.
	if( !g_kvstate.cfgstack.Empty ) {
		StringMap higher = g_kvstate.cfgstack.Pop();
		ConfigMap val = ConfigMap.Make();
		val.Section = view_as< ConfigMap >(g_kvstate.top);
		if( g_kvstate.debug_mode ) {
			LogMessage("ConfigMap Debug :: Allocated ConfigMap to store Section: '%s' | Handle: '%i'", g_kvstate.curr_section, val);
		}
		
		if( StrContains(g_kvstate.curr_section, "<ENUM>") != -1 ) {
			int enum_val = g_kvstate.enum_global++;
			char enum_val_str[12]; IntToString(enum_val, enum_val_str, sizeof(enum_val_str));
			ReplaceString(g_kvstate.curr_section, sizeof(g_kvstate.curr_section), "<ENUM>", enum_val_str);
		} else if( StrContains(g_kvstate.curr_section, "<enum>") != -1 ) {
			int enum_val = g_kvstate.enum_local++;
			char enum_val_str[12]; IntToString(enum_val, enum_val_str, sizeof(enum_val_str));
			ReplaceString(g_kvstate.curr_section, sizeof(g_kvstate.curr_section), "<enum>", enum_val_str);
		}
		CfgCheckMathExprs(g_kvstate.curr_section, sizeof(g_kvstate.curr_section));
		val.SetString("__ConfigMap::sect_name__", g_kvstate.curr_section);
		val.SetValue("__ConfigMap::sect_name_len__", strlen(g_kvstate.curr_section) + 1);
		higher.SetValue(g_kvstate.curr_section, val);
		view_as< ConfigMap >(higher).SetKey(g_kvstate.key_num, g_kvstate.curr_section);
		view_as< ConfigMap >(higher).Size++;
		g_kvstate.key_num++;
		if( !g_kvstate.secstack.Empty ) {
			g_kvstate.secstack.PopString(g_kvstate.curr_section, sizeof(g_kvstate.curr_section));
		}
		g_kvstate.top = higher;
	}
	return SMCParse_Continue;
}

public SMCResult ConfigMap_OnCurrentLine(SMCParser smc, const char[] line, int lineno) {
	return SMCParse_Continue;
}

/// ported from my C library: Harbol Config Parser.
stock bool ParseTargetPath(const char[] key, char[] buffer, int buffer_len, int sep='.') {
	/// parse something like: "root.section1.section2.section3.\\..dotsection"
	int i = strlen(key) - 1;
	while( i > 0 ) {
		/// Allow escaping separators so we can use them in key-path iteration.
		if( key[i]==sep ) {
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
	
	/// now we save the target section and then use the resulting string.
	int n;
	while( i > 0 && key[i] != 0 && n < buffer_len ) {
		if( key[i]=='\\' ) {
			i++;
			continue;
		}
		buffer[n] = key[i];
		n++; i++;
	}
	return n > 0;
}

stock void DeleteCfg(ConfigMap& cfg, bool clear_only=false, bool debug_mode=false) {
	if( cfg==null ) {
		return;
	}
	
	StringMapSnapshot snap = cfg.Snapshot();
	if( snap==null ) {
		return;
	}
	
	int entries = snap.Length;
	for( int i; i < entries; i++ ) {
		int strsize = snap.KeyBufferSize(i) + 1;
		char[] key_buffer = new char[strsize];
		snap.GetKey(i, key_buffer, strsize);
		if( IsForbiddenKey(key_buffer) ) {
			continue;
		}
		
		ConfigMap val;
		if( !cfg.GetValue(key_buffer, val) ) {
			continue;
		}
		
		switch( val.KVType ) {
			case KeyValType_Value: {
				delete val;
				if( debug_mode ) {
					LogMessage("DeleteCfg :: Deleted Value '%s'", key_buffer);
				}
			}
			case KeyValType_Section: {
				ConfigMap section = val.Section;
				DeleteCfg(section, false, debug_mode);
				delete val;
				if( debug_mode ) {
					LogMessage("DeleteCfg :: Deleted Section '%s'", key_buffer);
				}
			}
		}
		if( !clear_only ) {
			cfg.Remove(key_buffer);
		}
	}
	delete snap;
	
	if( clear_only ) {
		cfg.Clear();
	} else {
		delete cfg;
	}
}

static stock bool IsForbiddenKey(const char[] key) {
	return !strncmp(key, "__", 2);
}

stock void PrintCfg(ConfigMap cfg, int tabs=0) {
	if( cfg==null ) {
		return;
	}
	
	StringMapSnapshot snap = cfg.Snapshot();
	if( snap==null ) {
		return;
	}
	
	int entries = snap.Length;
	char[] tab_str = new char[tabs + 1];
	for( int n; n < tabs; n++ ) {
		tab_str[n] = '\t';
	}
	for( int i; i < entries; i++ ) {
		int strsize = snap.KeyBufferSize(i) + 1;
		char[] key_buffer = new char[strsize];
		snap.GetKey(i, key_buffer, strsize);
		if( IsForbiddenKey(key_buffer) ) {
			continue;
		}
		ConfigMap val; cfg.GetValue(key_buffer, val);
		switch( val.KVType ) {
			case KeyValType_Value: {
				int curr_value_len = val.Len;
				char[] curr_value = new char[curr_value_len + 1];
				val.GetStr(curr_value, curr_value_len);
				PrintToServer("ConfigMap :: %sKey: '%s' | length: '%i' | ConfigMap Handle: '%i' | Value: '%s'", tab_str, key_buffer, val.Len, val, curr_value);
			}
			case KeyValType_Section: {
				PrintToServer("ConfigMap :: %sSection: '%s' | ConfigMap Handle: '%i", tab_str, key_buffer, val);
				ConfigMap section = val.Section;
				PrintCfg(section, tabs + 1);
			}
		}
	}
	delete snap;
}

stock bool ReloadCfg(ConfigMap &cfg) {
	char filename[PLATFORM_MAX_PATH];
	cfg.GetString("__ConfigMap::filename__", filename, sizeof(filename));
	DeleteCfg(cfg);
	cfg = new ConfigMap(filename);
	return true;
}

static stock void ReplaceEscapeSeq(char[] str, int size) {
	char list[][][] = {
		{ "\t", "\\t" },
		{ "\n", "\\n" },
		{ "\r", "\\r" }
	};
	for( int i; i < sizeof(list); i++ ) {
		ReplaceString(str, size, list[i][0], list[i][1]);
	}
}

static stock bool ConfigMapToFile(ConfigMap cfg, const char[] sec_name, File file, int deep=0) {
	StringMapSnapshot snap = cfg.Snapshot();
	if( snap==null ) {
		return false;
	}
	
	char[] tab = new char[deep];
	for( int i; i < deep; i++ ) {
		tab[i] = '\t';
	}
	
	file.WriteLine("%s\"%s\" {", tab, sec_name);
	int size = snap.Length;
	for( int i; i < size; i++ ) {
		int strsize = snap.KeyBufferSize(i) + 1;
		char[] key = new char[strsize];
		snap.GetKey(i, key, strsize);
		if( IsForbiddenKey(key) ) {
			continue;
		}
		
		ConfigMap pack; cfg.GetValue(key, pack);
		switch( pack.KVType ) {
			case KeyValType_Value: {
				int key_size = pack.Len+10;
				char[] key_val = new char[key_size];
				pack.GetStr(key_val, key_size);
				ReplaceEscapeSeq(key_val, key_size);
				file.WriteLine("%s\t\"%s\"\t \"%s\"", tab, key, key_val);
			}
			case KeyValType_Section: {
				ConfigMap subsection = pack.Section;
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


static stock void CfgInterpStrings(ConfigMap root, ConfigMap curr_cfg) {
	if( curr_cfg==null ) {
		return;
	}
	
	if( g_kvstate.debug_mode ) {
		char filename[PLATFORM_MAX_PATH];
		root.GetString("__ConfigMap::filename__", filename, sizeof(filename));
		LogMessage("CfgInterpStrings :: name of root :: '%s'", filename);
	}
	
	int len = curr_cfg.Size;
	if( len <= 0 ) {
		return;
	}
	if( g_kvstate.debug_mode ) {
		LogMessage("CfgInterpStrings :: number of items in current sect:: '%i'", len);
	}
	for( int i; i < len; ) {
		int key_len = curr_cfg.GetKeySize(i);
		char[] key = new char[key_len + 1];
		curr_cfg.GetKey(i, key, key_len);
		if( g_kvstate.debug_mode ) {
			LogMessage("CfgInterpStrings :: key '%s' | key_len '%i' @ index: %i", key, key_len, i);
		}
		ConfigMap cfg_of_key = curr_cfg.GetVal(key);
		if( cfg_of_key==null ) {
			LogError("CfgMap::CfgInterpStrings :: '%s' gave null value.", key);
			i++;
			continue;
		}
		KeyValType kvt = cfg_of_key.KVType;
		if( g_kvstate.debug_mode ) {
			LogMessage("CfgInterpStrings :: kvt '%i'", kvt);
		}
		{
			int interp_idx = StrContains(key, "{");
			if( interp_idx >= 0 && StrContains(key, "}") != -1 ) {
				/// "{keks} hi"
				int interp_len = GetSubStringLen(key[interp_idx + 1], '}');
				char[] interp_str = new char[interp_len + 1];
				ParseSubString(key[interp_idx + 1], interp_str, '}');
				
				int idx;
				bool using_local = interp_str[0]=='.';
				idx += view_as< int >(using_local);
				ConfigMap using_cfg = using_local? curr_cfg : root;
				int value_len = using_cfg.GetSize(interp_str[idx]);
				char[] value = new char[value_len + 1];
				using_cfg.Get(interp_str[idx], value, value_len);
				
				int replace_len = interp_len + 2;
				char[] replace = new char[replace_len + 1];
				Format(replace, replace_len, "{%s}", interp_str);
				
				int new_key_len = key_len + value_len;
				char[] new_key = new char[new_key_len + 1];
				Format(new_key, new_key_len, "%s", key);
				ReplaceString(new_key, new_key_len, replace, value);
				if( g_kvstate.debug_mode ) {
					LogMessage("CfgInterpStrings :: old key:: '%s' | new key:: '%s'", key, new_key);
				}
				curr_cfg.Remove(key);
				curr_cfg.SetValue(new_key, cfg_of_key);
				curr_cfg.SetKey(i, new_key);
				continue;
			}
		}
		switch( kvt ) {
			case KeyValType_Section: {
				ConfigMap sect = cfg_of_key.Section;
				CfgInterpStrings(root, sect);
			}
			case KeyValType_Value: {
				int curr_value_len = cfg_of_key.Len;
				char[] curr_value = new char[curr_value_len + 1];
				cfg_of_key.GetStr(curr_value, curr_value_len);
				int interp_idx = StrContains(curr_value, "{");
				if( g_kvstate.debug_mode ) {
					LogMessage("CfgInterpStrings :: value '%s' -> interp_idx:: '%i'", curr_value, interp_idx);
				}
				if( interp_idx >= 0 && StrContains(curr_value, "}") != -1 ) {
					/// "{keks} hi"
					int interp_len = GetSubStringLen(curr_value[interp_idx + 1], '}');
					char[] interp_str = new char[interp_len + 1];
					ParseSubString(curr_value[interp_idx + 1], interp_str, '}');
					
					int idx;
					bool using_local = interp_str[0]=='.';
					idx += view_as< int >(using_local);
					ConfigMap using_cfg = using_local? curr_cfg : root;
					int value_len = using_cfg.GetSize(interp_str[idx]);
					char[] value = new char[value_len + 1];
					using_cfg.Get(interp_str[idx], value, value_len);
					
					int replace_len = interp_len + 2;
					char[] replace = new char[replace_len + 1];
					Format(replace, replace_len, "{%s}", interp_str);
					
					int new_value_len = curr_value_len + value_len;
					char[] new_value = new char[new_value_len + 1];
					Format(new_value, new_value_len, "%s", curr_value);
					ReplaceString(new_value, new_value_len, replace, value);
					if( g_kvstate.debug_mode ) {
						LogMessage("CfgInterpStrings :: old value:: '%s' | new value:: '%s'", curr_value, new_value);
					}
					curr_cfg.SetVal(key, new_value, new_value_len);
					continue;
				}
			}
		}
		i++;
	}
}


enum {
	TokenInvalid,
	TokenVar, TokenNum,
	
	/// builtin functions.
	TokenSin, TokenCos, TokenTan,
	TokenArcSin, TokenArcCos, TokenArcTan,
	TokenLog,
	TokenFloor, TokenRound, TokenCeil, TokenFraction,
	TokenToRad, TokenToDegree, TokenRandom, TokenRandomI,
	
	/// builtin constants.
	TokenE, TokenPi, TokenURand,
	
	TokenLParen, TokenRParen,
	TokenLBrack, TokenRBrack,
	TokenPlus, TokenSub,
	TokenMul, TokenDiv,
	TokenPow,
};

enum {
	LEXEME_SIZE=64,
	dot_flag = 1,
};

enum struct Token {
	char  lexeme[LEXEME_SIZE];
	int   size;
	int   tag;
	float val;
}

enum struct LexState {
	Token tok;
	int   i;
}


/** CfgMath by Nergal.
Expression Grammar (hint PEMDAS):
```ebnf
Expr        = AddExpr .
AddExpr     = MulExpr *( ('+' | '-') MulExpr ) .
MulExpr     = PowExpr *( ('*' | '/') PowExpr ) .
PowExpr     = PrefixExpr *( '^' PrefixExpr ) .
PrefixExpr  = *( '-' | '+' ) PostFixExpr .
PostfixExpr = *( ident ( '(' | '[' )? PowExpr , PrefixExpr ) | Factor .
Factor      = number | ident | 'e' (Euler's constant) | 'pi' | 'urand' | '(' Expr ')' | '[' Expr ']' .
```
 */

/// Expr = AddExpr .
static stock float ParseExpr(const char[] expression, ConfigMapMathVarFunc fn_math=INVALID_FUNCTION, any data) {
	LexState ls; GetToken(ls, expression);
	return ParseAddExpr(ls, expression, fn_math, data);
}

/// AddExpr = MulExpr *( ('+' | '-') MulExpr ) .
static stock float ParseAddExpr(LexState ls, const char[] expression, ConfigMapMathVarFunc fn_math=INVALID_FUNCTION, any data) {
	float val = ParseMulExpr(ls, expression, fn_math, data);
	if( ls.tok.tag==TokenPlus || ls.tok.tag==TokenSub ) {
		while( ls.tok.tag==TokenPlus || ls.tok.tag==TokenSub ) {
			int t = ls.tok.tag;
			GetToken(ls, expression);
			switch( t ) {
				case TokenPlus: {
					val += ParseMulExpr(ls, expression, fn_math, data);
				}
				case TokenSub: {
					val -= ParseMulExpr(ls, expression, fn_math, data);
				}
			}
		}
	}
	return val;
}

/// MulExpr = PowExpr *( ('*' | '/') PowExpr ) .
static stock float ParseMulExpr(LexState ls, const char[] expression, ConfigMapMathVarFunc fn_math=INVALID_FUNCTION, any data) {
	float val = ParsePowExpr(ls, expression, fn_math, data);
	if( ls.tok.tag==TokenMul || ls.tok.tag==TokenDiv ) {
		while( ls.tok.tag==TokenMul || ls.tok.tag==TokenDiv ) {
			int t = ls.tok.tag;
			GetToken(ls, expression);
			switch( t ) {
				case TokenMul: {
					val *= ParsePowExpr(ls, expression, fn_math, data);
				}
				case TokenDiv: {
					val /= ParsePowExpr(ls, expression, fn_math, data);
				}
			}
		}
	}
	return val;
}

/// PowExpr = PrefixExpr *( '^' PrefixExpr ) .
static stock float ParsePowExpr(LexState ls, const char[] expression, ConfigMapMathVarFunc fn_math=INVALID_FUNCTION, any data) {
	float val = ParseFnExpr(ls, expression, fn_math, data);
	if( ls.tok.tag==TokenPow ) {
		while( ls.tok.tag==TokenPow ) {
			GetToken(ls, expression);
			val = Pow(val, ParseFnExpr(ls, expression, fn_math, data));
		}
	}
	return val;
}

/// PrefixExpr = *( '-' | '+' ) Factor .
static stock float ParsePrefixExpr(LexState ls, const char[] expression, ConfigMapMathVarFunc fn_math=INVALID_FUNCTION, any data) {
	if( ls.tok.tag==TokenSub ) {
		GetToken(ls, expression);
		return -ParsePrefixExpr(ls, expression, fn_math, data);
	} else if( ls.tok.tag==TokenPlus ) {
		GetToken(ls, expression);
		return FloatAbs(ParsePrefixExpr(ls, expression, fn_math, data));
	}
	return ParseFactor(ls, expression, fn_math, data);
}

/// PostfixExpr = *( ident ) ( '(' | '[' )? _ , PowExpr | PrefixExpr .
static stock float ParseFnExpr(LexState ls, const char[] expression, ConfigMapMathVarFunc fn_math=INVALID_FUNCTION, any data) {
	switch( ls.tok.tag ) {
		case TokenSin: {
			GetToken(ls, expression);
			float val = (ls.tok.tag==TokenLParen || ls.tok.tag==TokenLBrack)? ParseFnExpr(ls, expression, fn_math, data) : ParsePowExpr(ls, expression, fn_math, data);
			return Sine(val);
		}
		case TokenArcSin: {
			GetToken(ls, expression);
			float val = (ls.tok.tag==TokenLParen || ls.tok.tag==TokenLBrack)? ParseFnExpr(ls, expression, fn_math, data) : ParsePowExpr(ls, expression, fn_math, data);
			return ArcSine(val);
		}
		case TokenCos: {
			GetToken(ls, expression);
			float val = (ls.tok.tag==TokenLParen || ls.tok.tag==TokenLBrack)? ParseFnExpr(ls, expression, fn_math, data) : ParsePowExpr(ls, expression, fn_math, data);
			return Cosine(val);
		}
		case TokenArcCos: {
			GetToken(ls, expression);
			float val = (ls.tok.tag==TokenLParen || ls.tok.tag==TokenLBrack)? ParseFnExpr(ls, expression, fn_math, data) : ParsePowExpr(ls, expression, fn_math, data);
			return ArcCosine(val);
		}
		case TokenTan: {
			GetToken(ls, expression);
			float val = (ls.tok.tag==TokenLParen || ls.tok.tag==TokenLBrack)? ParseFnExpr(ls, expression, fn_math, data) : ParsePowExpr(ls, expression, fn_math, data);
			return Tangent(val);
		}
		case TokenArcTan: {
			GetToken(ls, expression);
			float val = (ls.tok.tag==TokenLParen || ls.tok.tag==TokenLBrack)? ParseFnExpr(ls, expression, fn_math, data) : ParsePowExpr(ls, expression, fn_math, data);
			return ArcTangent(val);
		}
		case TokenLog: {
			GetToken(ls, expression);
			float val = (ls.tok.tag==TokenLParen || ls.tok.tag==TokenLBrack)? ParseFnExpr(ls, expression, fn_math, data) : ParsePowExpr(ls, expression, fn_math, data);
			return Logarithm(val);
		}
		case TokenFloor: {
			GetToken(ls, expression);
			float val = (ls.tok.tag==TokenLParen || ls.tok.tag==TokenLBrack)? ParseFnExpr(ls, expression, fn_math, data) : ParsePowExpr(ls, expression, fn_math, data);
			return RoundToFloor(val) + 0.0;
		}
		case TokenRound: {
			GetToken(ls, expression);
			float val = (ls.tok.tag==TokenLParen || ls.tok.tag==TokenLBrack)? ParseFnExpr(ls, expression, fn_math, data) : ParsePowExpr(ls, expression, fn_math, data);
			return RoundFloat(val) + 0.0;
		}
		case TokenCeil: {
			GetToken(ls, expression);
			float val = (ls.tok.tag==TokenLParen || ls.tok.tag==TokenLBrack)? ParseFnExpr(ls, expression, fn_math, data) : ParsePowExpr(ls, expression, fn_math, data);
			return RoundToCeil(val) + 0.0;
		}
		case TokenFraction: {
			GetToken(ls, expression);
			float val = (ls.tok.tag==TokenLParen || ls.tok.tag==TokenLBrack)? ParseFnExpr(ls, expression, fn_math, data) : ParsePowExpr(ls, expression, fn_math, data);
			return FloatFraction(val);
		}
		case TokenToRad: {
			GetToken(ls, expression);
			float val = (ls.tok.tag==TokenLParen || ls.tok.tag==TokenLBrack)? ParseFnExpr(ls, expression, fn_math, data) : ParsePowExpr(ls, expression, fn_math, data);
			return DegToRad(val);
		}
		case TokenToDegree: {
			GetToken(ls, expression);
			float val = (ls.tok.tag==TokenLParen || ls.tok.tag==TokenLBrack)? ParseFnExpr(ls, expression, fn_math, data) : ParsePowExpr(ls, expression, fn_math, data);
			return RadToDeg(val);
		}
		case TokenRandom: {
			GetToken(ls, expression);
			float val = (ls.tok.tag==TokenLParen || ls.tok.tag==TokenLBrack)? ParseFnExpr(ls, expression, fn_math, data) : ParsePowExpr(ls, expression, fn_math, data);
			return GetRandomFloat(0.0, val);
		}
		case TokenRandomI: {
			GetToken(ls, expression);
			float val = (ls.tok.tag==TokenLParen || ls.tok.tag==TokenLBrack)? ParseFnExpr(ls, expression, fn_math, data) : ParsePowExpr(ls, expression, fn_math, data);
			return float( GetRandomInt(0, RoundFloat(val)) );
		}
	}
	return ParsePrefixExpr(ls, expression, fn_math, data);
}

/// Factor  = number | ident | '(' Expr ')' | '[' Expr ']' .
static stock float ParseFactor(LexState ls, const char[] expression, ConfigMapMathVarFunc fn_math=INVALID_FUNCTION, any data) {
	float __NAN__ = view_as< float >(view_as< any >( -1 ));
	switch( ls.tok.tag ) {
		case TokenNum: {
			float f = ls.tok.val;
			GetToken(ls, expression);
			return f;
		}
		case TokenVar: {
			char lexeme[LEXEME_SIZE]; lexeme = ls.tok.lexeme;
			int len = ls.tok.size;
			GetToken(ls, expression);
			
			float f = __NAN__;
			if( StrEqual(lexeme, "iota") ) {
				f = float(g_kvstate.iota_local);
			} else if( StrEqual(lexeme, "IOTA") ) {
				f = float(g_kvstate.iota_global);
			} else if( StrEqual(lexeme, "ENUM") ) {
				f = float(g_kvstate.enum_global);
			} else if( StrEqual(lexeme, "enum") ) {
				f = float(g_kvstate.enum_local);
			}
			
			/// void(const char[] var_name, int var_name_len, float &f, any data);
			if( view_as< any >(f) == -1 && fn_math != INVALID_FUNCTION ) {
				Call_StartFunction(null, fn_math);
				Call_PushString(lexeme);
				Call_PushCell(len);
				Call_PushFloatRef(f);
				Call_PushCell(data);
				Call_Finish();
			}
			return f;
		}
		case TokenE: {
			GetToken(ls, expression);
			/// from `expf(1.f);`
			any eulers_constant_hex = 0x402df854;
			return eulers_constant_hex;
		}
		case TokenPi: {
			GetToken(ls, expression);
			/// from `acosf(-1.f);`
			any pi_hex = 0x40490fdb;
			return pi_hex;
		}
		case TokenURand: {
			GetToken(ls, expression);
			return GetURandomFloat();
		}
		case TokenLParen: {
			GetToken(ls, expression);
			float f = ParseAddExpr(ls, expression, fn_math, data);
			if( ls.tok.tag != TokenRParen ) {
				LogError("ConfigMap-Math :: expected ')' bracket but got '%s'", ls.tok.lexeme);
				return __NAN__;
			}
			GetToken(ls, expression);
			return f;
		}
		case TokenLBrack: {
			GetToken(ls, expression);
			float f = ParseAddExpr(ls, expression, fn_math, data);
			if( ls.tok.tag != TokenRBrack ) {
				LogError("ConfigMap-Math :: expected ']' bracket but got '%s'", ls.tok.lexeme);
				return __NAN__;
			}
			GetToken(ls, expression);
			return f;
		}
	}
	return __NAN__;
}

/*
static stock bool LexBinary(LexState ls, const char[] expression) {
	while( expression[ls.i] != 0 && (IsCharNumeric(expression[ls.i])) ) {
		switch( expression[ls.i] ) {
			case '0', '1': {
				ls.tok.lexeme[ls.tok.size++] = expression[ls.i++];
			}
			default: {
				ls.tok.lexeme[ls.tok.size++] = expression[ls.i++];
				LogError("ConfigMap-Math :: invalid binary literal: '%s'", ls.tok.lexeme);
				return false;
			}
		}
	}
	return true;
}
static stock bool LexOctal(LexState ls, const char[] expression) {
	while( expression[ls.i] != 0 && (IsCharNumeric(expression[ls.i])) ) {
		switch( expression[ls.i] ) {
			case '0', '1', '2', '3', '4', '5', '6', '7': {
				ls.tok.lexeme[ls.tok.size++] = expression[ls.i++];
			}
			default: {
				ls.tok.lexeme[ls.tok.size++] = expression[ls.i++];
				LogError("ConfigMap-Math :: invalid octal literal: '%s'", ls.tok.lexeme);
				return false;
			}
		}
	}
	return true;
}

static stock bool LexHex(LexState ls, const char[] expression) {
	while( expression[ls.i] != 0 && (IsCharNumeric(expression[ls.i]) || IsCharAlpha(expression[ls.i])) ) {
		switch( expression[ls.i] ) {
			case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
				'a', 'b', 'c', 'd', 'e', 'f',
				'A', 'B', 'C', 'D', 'E', 'F': {
				ls.tok.lexeme[ls.tok.size++] = expression[ls.i++];
			}
			default: {
				ls.tok.lexeme[ls.tok.size++] = expression[ls.i++];
				LogError("ConfigMap-Math :: invalid hex literal: '%s'", ls.tok.lexeme);
				return false;
			}
		}
	}
	return true;
}
*/

static stock bool LexDec(LexState ls, const char[] expression) {
	int lit_flags = 0;
	while( expression[ls.i] != 0 && (IsCharNumeric(expression[ls.i]) || expression[ls.i]=='.') ) {
		switch( expression[ls.i] ) {
			case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9': {
				ls.tok.lexeme[ls.tok.size++] = expression[ls.i++];
			}
			case '.': {
				if( lit_flags & dot_flag ) {
					LogError("ConfigMap-Math :: extra dot in decimal literal");
					return false;
				}
				ls.tok.lexeme[ls.tok.size++] = expression[ls.i++];
				lit_flags |= dot_flag;
			}
			default: {
				ls.tok.lexeme[ls.tok.size++] = expression[ls.i++];
				LogError("ConfigMap-Math :: invalid decimal literal: '%s'", ls.tok.lexeme);
				return false;
			}
		}
	}
	return true;
}

static stock void GetToken(LexState ls, const char[] expression, bool &res=true) {
	int len = strlen(expression);
	Token empty; ls.tok = empty;
	while( ls.i < len ) {
		switch( expression[ls.i] ) {
			case ' ', '\t', '\n', '\r': {
				ls.i++;
			}
			case '0': { /// possible hex, octal, binary, or float.
				ls.tok.tag = TokenNum;
				ls.i++;
				switch( expression[ls.i] ) {
					/*
					case 'b', 'B': {
						/// Binary.
						ls.i++;
						if( LexBinary(ls, expression) ) {
							ls.tok.val = StringToInt(ls.tok.lexeme, 2) + 0.0;
						}
						return;
					}
					case 'o', 'O': {
						/// Octal.
						ls.i++;
						if( LexOctal(ls, expression) ) {
							ls.tok.val = StringToInt(ls.tok.lexeme, 8) + 0.0;
						}
						return;
					}
					case 'x', 'X': {
						/// Hex.
						ls.i++;
						if( LexHex(ls, expression) ) {
							ls.tok.val = StringToInt(ls.tok.lexeme, 16) + 0.0;
						}
						return;
					}*/
					case '.', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9': {
						/// Decimal/Float.
						if( LexDec(ls, expression) ) {
							ls.tok.val = StringToFloat(ls.tok.lexeme);
						}
						return;
					}
				}
			}
			case '.', '1', '2', '3', '4', '5', '6', '7', '8', '9': {
				ls.tok.tag = TokenNum;
				/// Decimal/Float.
				if( LexDec(ls, expression) ) {
					ls.tok.val = StringToFloat(ls.tok.lexeme);
				}
				return;
			}
			case '(': {
				ls.tok.lexeme[ls.tok.size++] = expression[ls.i++];
				ls.tok.tag = TokenLParen;
				return;
			}
			case ')': {
				ls.tok.lexeme[ls.tok.size++] = expression[ls.i++];
				ls.tok.tag = TokenRParen;
				return;
			}
			case '[': {
				ls.tok.lexeme[ls.tok.size++] = expression[ls.i++];
				ls.tok.tag = TokenLBrack;
				return;
			}
			case ']': {
				ls.tok.lexeme[ls.tok.size++] = expression[ls.i++];
				ls.tok.tag = TokenRBrack;
				return;
			}
			case '+': {
				ls.tok.lexeme[ls.tok.size++] = expression[ls.i++];
				ls.tok.tag = TokenPlus;
				return;
			}
			case '-': {
				ls.tok.lexeme[ls.tok.size++] = expression[ls.i++];
				ls.tok.tag = TokenSub;
				return;
			}
			case '*': {
				ls.tok.lexeme[ls.tok.size++] = expression[ls.i++];
				ls.tok.tag = TokenMul;
				return;
			}
			case '/': {
				ls.tok.lexeme[ls.tok.size++] = expression[ls.i++];
				ls.tok.tag = TokenDiv;
				return;
			}
			case '^': {
				ls.tok.lexeme[ls.tok.size++] = expression[ls.i++];
				ls.tok.tag = TokenPow;
				return;
			}
			case 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z': {
				while( expression[ls.i] != 0 && (IsCharAlpha(expression[ls.i]) || expression[ls.i]=='_') ) {
					ls.tok.lexeme[ls.tok.size++] = expression[ls.i++];
				}
				
				static const char builtin_names[][] = {
					"sin", "cos", "tan",
					"arcsin", "arccos", "arctan",
					"log", "floor", "round", "ceil", "fraction",
					"radians", "degress", "random", "irandom",
					
					/// variables
					"e", "pi", "urand"
				};
				
				int builtin_name = TokenSin;
				for( int i; i < sizeof(builtin_names); i++ ) {
					if( StrEqual(ls.tok.lexeme, builtin_names[i]) ) {
						ls.tok.tag = builtin_name;
						return;
					}
					builtin_name++;
				}
				ls.tok.tag = TokenVar;
				return;
			}
			default: {
				ls.tok.lexeme[ls.tok.size++] = expression[ls.i++];
				LogError("ConfigMap-Math :: invalid expression token '%s'.", ls.tok.lexeme);
				res = false;
				return;
			}
		}
	}
}

static stock int RemoveString(char[] str, const char[] src) {
	int j;
	int src_len = strlen(src);
	if( src_len <= 0 ) {
		return j;
	}
	for( int i; str[i] != 0; i++ ) {
		if( !strncmp(str[i], src, src_len-1) ) {
			i += src_len-1;
			continue;
		}
		str[j] = str[i];
		j++;
	}
	str[j] = 0;
	return j;
}

static stock int TrimChars(char[] str, const char[] chrs) {
	int j;
	for( int i; str[i] != 0; i++ ) {
		if( FindCharInString(chrs, str[i]) == -1 ) {
			str[j] = str[i];
			j++;
		}
	}
	str[j] = 0;
	return j;
}

static stock int RemoveAllWhiteSpace(char[] str) {
	int j;
	for( int i; str[i] != 0; i++ ) {
		if( !IsCharSpace(str[i]) ) {
			str[j] = str[i];
			j++;
		}
	}
	str[j] = 0;
	return j;
}

static stock int CountChars(const char[] str, int c) {
	int k;
	for( int i; str[i] != 0; i++ ) {
		k += view_as< int >(str[i]==c);
	}
	return k;
}