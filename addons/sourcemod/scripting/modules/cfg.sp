/**
 * cfg.sp
 * 
 * Copyright [2019-2020] Nergal the Ashurian
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


enum KeyValType {
	KeyValType_Null,     /// nil
	KeyValType_Section,  /// StringMap : char[*][*]
	KeyValType_Value,    /// char[*]
};

enum struct PackVal {
	DataPack data;
	int size;
	KeyValType tag;
}


enum struct KeyValState {
	SMCParser parser;
	
	/// Stack to store old StringMap tops to pop back later.
	ArrayStack cfgstack;
	
	/// store old (sub)section names.
	ArrayStack secstack;
	
	/// the current StringMap instance we're working with.
	StringMap top;
	
	char curr_section[PLATFORM_MAX_PATH];
}

static KeyValState g_kvstate;


methodmap ConfigMap < StringMap {
	public ConfigMap(const char[] filename) {
		char path[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, path, sizeof(path), filename);
		
		g_kvstate.cfgstack = new ArrayStack();
		g_kvstate.secstack = new ArrayStack(PLATFORM_MAX_PATH);
		g_kvstate.top = new StringMap();
		
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
			if( g_kvstate.top != null )
				DeleteCfg(view_as< ConfigMap >(g_kvstate.top));
		}
		delete g_kvstate.parser;
		delete g_kvstate.cfgstack;
		delete g_kvstate.secstack;
		
		StringMap cfg = g_kvstate.top;
		if( g_kvstate.top != null )
			g_kvstate.top = null;
		return view_as< ConfigMap >(cfg);
	}
	
	public bool GetVal(const char[] key, PackVal valbuf)
	{
		if( this==null )
			return false;
		
		/// first check if we're getting a singular value OR we iterate through a sectional path.
		int dot = FindCharInString(key, '.');
		/// Patch: dot and escaped dot glitching out the hashmap hashing...
		if( dot == -1 || (dot > 0 && key[dot-1] == '\\') ) {
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
					if( n<PLATFORM_MAX_PATH )
						curr_section[n++] = key[i++];
				} else if( key[i]=='.' ) {
					i++;
					break;
				} else {
					if( n<PLATFORM_MAX_PATH )
						curr_section[n++] = key[i++];
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
	
	/**
	 * 
	 * name:      GetSize
	 * @param     key_path : key path to the data you need.
	 * @return    size of the string value.
	 * @note      to directly access subsections, use a '.' like "root.section.key"
	 *            for keys that have a dot in their name, use '\\.'
	 */
	public int GetSize(const char[] key_path) {
		if( this==null )
			return 0;
		
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
	 * @return    true if successful, false otherwise.
	 * @note      to directly access subsections, use a '.' like "root.section.key"
	 *            for keys that have a dot in their name, use '\\.'
	 */
	public bool Get(const char[] key_path, char[] buffer, int buf_size) {
		if( this==null || buf_size==0 )
			return false;
		PackVal val;
		bool result = this.GetVal(key_path, val);
		if( result && val.tag==KeyValType_Value ) {
			val.data.Reset();
			char[] src_buf = new char[val.size];
			val.data.ReadString(src_buf, val.size);
			strcopy(buffer, buf_size, src_buf);
			return true;
		}
		return false;
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
		if( this==null )
			return null;
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
		if( this==null )
			return KeyValType_Null;
		PackVal val;
		return( this.GetVal(key_path, val) ) ? val.tag : KeyValType_Null;
	}
};

public SMCResult ConfigMap_OnNewSection(SMCParser smc, const char[] name, bool opt_quotes)
{
	/// if we hit a new (sub)section,
	/// push the old head and add a new head to write the subsection.
	if( g_kvstate.top != null )
		g_kvstate.cfgstack.Push(g_kvstate.top);
	if( g_kvstate.curr_section[0] != 0 )
		g_kvstate.secstack.PushString(g_kvstate.curr_section);
	
	g_kvstate.top = new StringMap();
	strcopy(g_kvstate.curr_section, sizeof(g_kvstate.curr_section), name);
	return SMCParse_Continue;
}

public SMCResult ConfigMap_OnKeyValue(SMCParser smc, const char[] key, const char[] value, bool key_quotes, bool value_quotes)
{
	PackVal val;
	val.data = new DataPack();
	val.data.WriteString(value);
	val.size = strlen(value) + 1;
	val.tag = KeyValType_Value;
	
	g_kvstate.top.SetArray(key, val, sizeof(val));
	return SMCParse_Continue;
}

public SMCResult ConfigMap_OnEndSection(SMCParser smc)
{
	/// if our stack isn't empty, pop back our older top
	/// and push the newer one into it as a new section.
	if( !g_kvstate.cfgstack.Empty ) {
		StringMap higher = g_kvstate.cfgstack.Pop();
		
		PackVal val;
		val.data = new DataPack();
		val.data.WriteCell(g_kvstate.top);
		val.size = sizeof(g_kvstate.top);
		val.tag = KeyValType_Section;
		
		higher.SetArray(g_kvstate.curr_section, val, sizeof(val));
		if( !g_kvstate.secstack.Empty )
			g_kvstate.secstack.PopString(g_kvstate.curr_section, sizeof(g_kvstate.curr_section));
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
		/// Patch: allow keys to use dot without interfering with dot path.
		/// check if we hit a dot.
		if( key[i]=='.' ) {
			/// if we hit a dot, check if the previous char is an "escape" char.
			if( key[i-1]=='\\' )
				i--;
			else {
				i++;
				break;
			}
		} else i--;
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

void DeleteCfg(ConfigMap& cfg, bool clear_only=false) {
	if( cfg==null )
		return;
	
	StringMapSnapshot snap = cfg.Snapshot();
	if( !snap )
		return;
	
	int entries = snap.Length;
	for( int i; i<entries; i++ ) {
		int strsize = snap.KeyBufferSize(i);
		char[] key_buffer = new char[strsize + 1];
		snap.GetKey(i, key_buffer, strsize + 1);
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
	
	if( clear_only )
		cfg.Clear();
	else delete cfg;
}

public void PrintCfg(ConfigMap cfg) {
	if( cfg==null )
		return;
	StringMapSnapshot snap = cfg.Snapshot();
	if( !snap )
		return;
	
	int entries = snap.Length;
	for( int i; i<entries; i++ ) {
		int strsize = snap.KeyBufferSize(i);
		char[] key_buffer = new char[strsize + 1];
		snap.GetKey(i, key_buffer, strsize + 1);
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
