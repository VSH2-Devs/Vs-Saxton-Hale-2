/**
 * FF2SoundIdentity:
 *
 * path = full song path name
 * name = > "slot*_*": <key position>_<value>
 * 		  > "song name"
 *		  > String To Replace or unused for "catch_phrase"
 * artist = empty or contains artist's name
 * time = 0.0, or song duration
 */

enum struct FF2SoundIdentity  {
	char path[PLATFORM_MAX_PATH];
	char name[32];
	char artist[32];
	float time;
	
	void Init(const char[] path, float time, const char[] name = "", const char[] artist = "Unknown artist") {
		strcopy(this.path, sizeof(FF2SoundIdentity::path), path);
		strcopy(this.name, sizeof(FF2SoundIdentity::name), name);
		strcopy(this.artist, sizeof(FF2SoundIdentity::artist), artist);
		this.time = time;
	}
	
	void PrintToAll() {
		if( !this.name[0] )
			return;
		for( int i=1;i<MaxClients;i++ ) {
			if( IsClientInGame(i) ) {
				FPrintToChat(i, "Now Playing {blue}%s{default} - {orange}%s{default}", this.name, this.artist);
			}
		}
	}
}

/**
 * FF2SoundList:
 *
 * Dynamic array of FF2SoundIdentity
 */
methodmap FF2SoundList < ArrayList {
	property bool Empty {
		public get() {
			return( !this.Length );
		}
	}
	
	public FF2SoundList() {
		return( view_as< FF2SoundList >(new ArrayList(sizeof(FF2SoundIdentity))) );
	}
	
	public bool At(int idx, FF2SoundIdentity snd_id) {
		return( this.GetArray(idx, snd_id, sizeof(FF2SoundIdentity)) != 0 );
	}
	
	public bool RandomSound(FF2SoundIdentity snd_id) {
		if( !this.Empty ) {
			int rand = GetURandomInt() % this.Length;
			return( this.At(rand, snd_id) );
		}
		return false;
	}
	
	public bool Seek(const char[] path_name, FF2SoundIdentity snd_id) {
		if( !this.Empty ) {
			for( int i = 0; i < this.Length; i++ ) {
				this.At(i, snd_id);
				if( !strcmp(path_name, snd_id.path) )
					return true;
			}
		}
		return false;
	}
}

/**
 * FF2SoundHash:
 *
 * Key: 	"sound_*"
 * Value: 	FF2SoundList
 */
methodmap FF2SoundHash < StringMap  {
	public FF2SoundHash() {
		return( view_as< FF2SoundHash >(new StringMap()) );
	}
	
	public FF2SoundList GetOrCreateList(const char[] key) {
		FF2SoundList list;
		if( this.GetValue(key, list) && list ) {
			return( list );
		}
		
		list = new FF2SoundList();
		this.SetValue(key, list);
		return( list );
	}
	
	public FF2SoundList GetList(const char[] key) {
		FF2SoundList list;
		if( this.GetValue(key, list) && list ) {
			return( list );
		}
		
		return null;
	}
	
	public void Delete(const char[] key) {
		FF2SoundList list;
		if( this.GetValue(key, list) ) {
			delete list;
		}
		this.Remove(key);
	}
	
	public void DeleteAll() {
		StringMapSnapshot snap = this.Snapshot();
		
		char name[48];
		FF2SoundList list;
		
		for( int i = snap.Length - 1; i >= 0; i-- ) {
			snap.GetKey(i, name, sizeof(name));
			if( this.GetValue(name, list) ) {
				delete list;
			}
		}
		this.Clear();
		delete snap;
	}
}
