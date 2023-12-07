# Intro
Created as a less convoluted and more performant alternative to `KeyValues`, `ConfigMap` allows a VSH2 addon or boss developer to have FF2-like flexibility and ease-of-use without the hassle and headache from the `KeyValues` API. Let's get started!

# API & Examples
Firstly, `ConfigMap` can only be used on text files, which is what we first use to construct a `ConfigMap` root handle:
```c++
ConfigMap cfg = new ConfigMap("configs/my_config.cfg");
```
**Note**: the `sourcemod` folder is ALWAYS the root directory here.

```c
ConfigMap ConfigMap(const char[] filename);
```

Let's assume `my_config.cfg` has the following config data within it:
```ini
"root" {
    "kv1": "value"
    "subsection": {
        "subkey": "subvalue"
    }
}
```

**WARNING: `cfg` can be `null` if the file wasn't found or something went wrong during parsing.**


## Accessing Data
### Grabbing Values
`ConfigMap` ONLY stores values as strings, these strings can be converted to `int` or `float` but are only stored as strings.
Let's try to get the value of key `"kv1"` which will be a string value of `"value"`.

The best practices of doing this is using a dynamic character array, we first retrieve the size of the value, create the array, then populate the array.

```c++
int value_len = cfg.GetSize("root.kv1");
char[] value_str = new char[value_len];
if( cfg.Get("root.kv1", value_str, value_len) > 0 ) {
    PrintToServer("%s", value_str);
}
```
The method `GetSize`
```c
int GetSize(const char[] key_path);
```
ALWAYS returns the length of the string value + 1 to account for the NULL terminator.


The method `Get`
```c
int Get(const char[] key_path, char[] buffer, int buf_size);
```
returns the number of characters written.

You probably noticed that to get `"value"`, we added a dot between "root" and "kv1", this is because `ConfigMap` let's you directly traverse sections to a specific key by using Python-style dot pathing.

**WARNING: if you have a key that uses a dot in it (like a URL or something), you must access it by using `\.` or you glitch/mistraverse the pathing.**

If you're trying to access a key such as `"mywebsite.com"`, then you'd have to use a string like `"mywebsite\.com"` to access the value.


### Grabbing Subsections
The Python-style pathing makes for great convenience over `KeyValues` but sometimes you don't want to always have to traverse section after section within a single, hardcoded string. To save on this and save on the overhead of iterating subsections, you can also conveniently grab a subsection! Let's grab the `"subsection"` subsection in the next example:
```c
ConfigMap GetSection(const char[] key_path);

...

ConfigMap subsection = cfg.GetSection("root.subsection");
```
* **Note**: it's a good idea to check if a grabbed subsection is `null`.
* **WARNING: DO NOT INDIVIDUALLY DELETE OR DESTROY THE SUBSECTIONS.**

By grabbing `subsection`, we easily access the value of `"subkey"` without too much overhead. Even though the overhead is less than that of `KeyValues`, it's good not to unnecessarily induce it.

### Checking Value Types
Sometimes we don't always know if a key is storing a section or a value or perhaps we want to allow the flexibility that a key could possibly _be_ either of those two. `ConfigMap` allows a developer to check the type of a key by using `GetKeyValType`.

```c
KeyValType GetKeyValType(const char[] key_path);
```

`GetKeyValType` returns 3 possible values within this enum:
```c
enum KeyValType {
	KeyValType_Null,
	KeyValType_Section,
	KeyValType_Value,
};
```

`KeyValType_Null` is only returned if the `ConfigMap` object is `null`, the key wasn't found, or there was a general failure. Otherwise, you will get whether the type is a Section or Value. Here's an example:

```c
switch( cfg.GetKeyValType(str_key) ) {
    case KeyValType_Value: {
        /// do something with string value.
    }
    case KeyValType_Section: {
        /// do something with section.
    }
    default: {
        /// handle null key!
    }
}
```

### Converting to `int` & `float`
For converting to the numerical types, we have two methods:
```c
int GetInt(const char[] key_path, int& i, int base=10);
int GetFloat(const char[] key_path, float& f);
```

Both `GetInt` & `GetFloat` return the number of characters read to create the number value. With `GetInt`, you get an optional numerical base so that one could parse non-decimal values like hexadecimal, octal, binary, or custom.

### Automatic Key Enumeration
Sometimes we can't always give a clear name for a key, the typical option is to just numerically name the key (such as):
```ini
"0": "value"
"1": "value"
"2": "value"
"3": "value"
```

A feature not present in `KeyValues` is a special token (two actually!) that help automate the 0-3 values within the keys. Simple use the token `<enum>` in place of the number key!:
```ini
"<enum>": "value"    /// key of 0
"<enum>": "value"    /// key of 1
"<enum>": "value"    /// key of 2
"<enum>": "value"    /// key of 3
```

There are two tokens specifically to help with this
* `<enum>` which is local to a (sub)section only.
* `<ENUM>` which preserves its number value across all sections.

Here's a better example to explain how `<enum>` and `<ENUM>` work:
```ini
"root": {
    "<ENUM>": "value"    /// key of 0
    "subsection1": {
        "<enum>": "value"    /// key of 0
        "<enum>": "value"    /// key of 1
        "<enum>": "value"    /// key of 2
    }
    "<ENUM>": "value"    /// key of 1
    "subsection2": {
        "<enum>": "value"    /// key of 0
        "<enum>": "value"    /// key of 1
        "subsubsection1": {
            "<enum>": "value" /// key of 0
            "<enum>": "value" /// key of 1
        }
        "<enum>": "value"    /// key of 2
        "<ENUM>": "value"    /// key of 2
    }
    "<ENUM>": "value"    /// key of 3
}
"<ENUM>": {    /// key of 4
    ...
}
```

Added for convience, `ConfigMap` also has methods that directly use integer values as the keys. These convience methods help reduce code required to take an integer, convert it to string, and use it to access `ConfigMap` sections.

The methods are:
```c
int GetIntKeySize(int key);

int GetIntKey(int key, char[] buffer, int buf_size);
bool SetIntKey(int key, const char[] str);

ConfigMap GetIntKeySection(int key);

KeyValType GetIntKeyValType(int key);

int GetIntKeyInt(int key, int& i, int base=10);
bool SetIntKeyInt(int key, int i);

int GetIntKeyFloat(int key, float& f);
bool SetIntKeyFloat(int key, float f);

int GetIntKeyBool(int key, bool& b, bool simple=true);
```

**Notice: The integer key based methods will NOT allow you to do python-style pathing like the string keys do.**

### Automatic Value Enumeration
So, what if we actually wanted something similar to `<enum>` but for values instead of keys?
For that, we have local and global iota! For local iota, `<iota>` and for global iota `<IOTA>`. They work exactly the same as `<enum>/<ENUM>` but their purpose is for use as values rather than keys.

* `<iota>` local to a (sub)section only.
* `<IOTA>` preserves its number value across all sections.

## Usage within VSH2
Within VSH2, `ConfigMap` is used (and useful) for a variety of different subsystems that make VSH2 do what it does best. A good example is managing the general download list inside `vsh2.cfg`:
```c++
char download_keys[][] = {
	"downloads.sounds",
	"downloads.models",
	"downloads.materials"
};

for( int i; i < sizeof(download_keys); i++ ) {
	ConfigMap download_map = g_vsh2.m_hCfg.GetSection(download_keys[i]);
	if( download_map != null ) {
		for( int n; n < download_map.Size; n++ ) {
			char index[10];
			Format(index, sizeof(index), "%i", n);
			int value_size = download_map.GetSize(index);
			char[] filepath = new char[value_size];
			if( download_map.Get(index, filepath, value_size) ) {
				switch( i ) {
					case 0: PrepareSound(filepath);
					case 1: PrepareModel(filepath);
					case 2: PrepareMaterial(filepath);
				}
			}
		}
	}
}
```

As you can see, `ConfigMap` really helps create quick download management compared to `KeyValues`. How about another example using the VSH2 help panels for the TF2 player classes?

[Link to Code](https://github.com/VSH2-Devs/Vs-Saxton-Hale-2/blob/develop/addons/sourcemod/scripting/modules/base.sp#L543-L564)
```c++
static char class_help[][] = {
	"help.unknown",
	"help.scout",
	"help.sniper",
	"help.soldier",
	"help.demo",
	"help.medic",
	"help.heavy",
	"help.pyro",
	"help.spy",
	"help.engie"
};

Panel panel = new Panel();
TFClassType tfclass = this.iTFClass;
int len = g_vsh2.m_hCfg.GetSize(class_help[tfclass]);
char[] helpstr = new char[len];
g_vsh2.m_hCfg.Get(class_help[tfclass], helpstr, len);
panel.SetTitle(helpstr);
panel.DrawItem("Exit");
panel.Send(this.index, HintPanel, 20);
delete panel;
```

Just like with the download management, `ConfigMap` helps make the help panel easy and simple to read and maintain but also allows a server operator to change the help string as needed without having to recompile VSH2!
