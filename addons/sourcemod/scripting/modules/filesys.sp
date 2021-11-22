/** File System Parsers
 * This code is from Updater, being adapted for use as a boss package manager.
 */

enum {
	MAX_URL_LENGTH = 256
};

/// Strip filename from path.
void StripPathFilename(char[] path) {
	strcopy(path, FindCharInString(path, '/', true) + 1, path);
}

/// Return the filename and extension from a given path.
stock void GetPathBasename(char[] path, char[] buffer, int maxlength) {
	int check = -1;
	if( (check = FindCharInString(path, '/', true)) != -1
		|| (check = FindCharInString(path, '\\', true)) != -1
	) {
		strcopy(buffer, maxlength, path[check+1]);
	} else {
		strcopy(buffer, maxlength, path);
	}
}

/// Add http protocol to url if it's missing.
void PrefixURL(char[] buffer, int maxlength, const char[] url)
{
	if( strncmp(url, "http://", 7) != 0 && strncmp(url, "https://", 8) != 0 ) {
		Format(buffer, maxlength, "http://%s", url);
	} else {
		strcopy(buffer, maxlength, url);
	}
}

/// Split URL into hostname, location, and filename. No trailing slashes.
void ParseURL(const char[] url, char[] host, int maxHost, char[] location, int maxLoc, char[] filename, int maxName)
{
	/// Strip url prefix.
	int idx = StrContains(url, "://");
	idx = (idx != -1) ? idx + 3 : 0;
	
	char dirs[16][64];
	int total = ExplodeString(url[idx], "/", dirs, sizeof(dirs), sizeof(dirs[]));
	
	/// host
	Format(host, maxHost, "%s", dirs[0]);
	
	/// location
	location[0] = '\0';
	for( int i = 1; i < total - 1; i++ ) {
		Format(location, maxLoc, "%s/%s", location, dirs[i]);
	}
	
	/// filename
	Format(filename, maxName, "%s", dirs[total-1]);
}

/// Converts Updater SMC file paths into paths relative to the game folder.
void ParseSMCPathForLocal(const char[] path, char[] buffer, int maxlength)
{
	char dirs[16][64];
	int total = ExplodeString(path, "/", dirs, sizeof(dirs), sizeof(dirs[]));
	if( StrEqual(dirs[0], "Path_SM") ) {
		BuildPath(Path_SM, buffer, maxlength, "");
	} else { /// Path_Mod
		buffer[0] = '\0';
	}
	
	/// Construct the path and create directories if needed.
	for( int i=1; i < total - 1; i++ ) {
		Format(buffer, maxlength, "%s%s/", buffer, dirs[i]);
		if( !DirExists(buffer) ) {
			CreateDirectory(buffer, 511);
		}
	}
	
	/// Add the filename to the end of the path.
	Format(buffer, maxlength, "%s%s", buffer, dirs[total-1]);
}

/// Converts Updater SMC file paths into paths relative to the plugin's update URL.
void ParseSMCPathForDownload(const char[] path, char[] buffer, int maxlength)
{
	char dirs[16][64];
	int total = ExplodeString(path, "/", dirs, sizeof(dirs), sizeof(dirs[]));
	
	/// Construct the path.
	buffer[0] = '\0';
	for( int i=1; i < total; i++ ) {
		Format(buffer, maxlength, "%s/%s", buffer, dirs[i]);
	}
}

void ParseSMCFilePack(const char[] urlprefix, const char[] url, int index, DataPack hPack, ArrayList hFiles)
{
	/// Prepare URL
	char dest[PLATFORM_MAX_PATH], sBuffer[MAX_URL_LENGTH];
	GetURL(index, urlprefix, sizeof(urlprefix));
	StripPathFilename(urlprefix);
	hPack.Reset();
	while( IsPackReadable(hPack, 1) ) {
		ReadPackString(hPack, sBuffer, sizeof(sBuffer));
		
		/// Merge url.
		ParseSMCPathForDownload(sBuffer, url, sizeof(url));
		Format(url, sizeof(url), "%s%s", urlprefix, url);
		
		/// Make sure the current plugin path matches the update.
		ParseSMCPathForLocal(sBuffer, dest, sizeof(dest));
		
		char sLocalBase[64], sPluginBase[64], sFilename[64];
		GetPathBasename(dest, sLocalBase, sizeof(sLocalBase));
		GetPathBasename(sFilename, sPluginBase, sizeof(sPluginBase));
		
		if( StrEqual(sLocalBase, sPluginBase) ) {
			StripPathFilename(dest);
			Format(dest, sizeof(dest), "%s/%s", dest, sFilename);
		}
		
		/// Save the file location for later.
		hFiles.PushString(dest);
		
		/// Add temporary file extension.
		Format(dest, sizeof(dest), "%s.%s", dest, "temp");
		
		/// Begin downloading file.
		AddToDownloadQueue(index, url, dest);
	}
}

stock void StringToLower(char[] input) {
	int length = strlen(input);
	for( int i; i < length; i++ ) {
		input[i] = CharToLower(input[i]);
	}
}