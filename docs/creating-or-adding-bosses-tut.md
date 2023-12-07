# Intro
VSH2 was designed and structured for easily adding/modifying bosses via subplugins called *boss modules*. The benefits to creating bosses as modules is having your boss code work separate from the VSH2 plugin which allows you to use VSH2's advanced hook system and API so you can have the power to create unique bosses.

**This tutorial assumes that you've already read or at least know some of** [VSH2's API](https://github.com/VSH2-Devs/Vs-Saxton-Hale-2/wiki/VSH2-API).

# Getting Started
Creating a module for VSH2, whether it's a boss or some other type of addon, requires including `vsh2.inc`.

```c
#include <sourcemod>
#include <vsh2>
```
For addons to work properly, you cannot use `OnPluginStart` so you have to use `OnLibraryAdded`, this is so we can make sure that VSH2 itself has already been loaded or else you'll get nicely spammed error logs.

Here's an example of how to do a custom boss module for VSH2:
```c
enum struct MyBoss {
	int          id;
	VSH2GameMode gm;
	ConfigMap    cfg;
}
MyBoss my_boss;


public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		my_boss.cfg = new ConfigMap("configs/saxton_hale/boss_cfgs/my_boss.cfg");
		if( my_boss.cfg==null ) {
			LogError("[VSH 2] ERROR :: **** couldn't find 'configs/saxton_hale/boss_cfgs/my_boss.cfg'. Failed to register My Boss. ****");
			return;
		}
		char plugin_name_str[MAX_BOSS_NAME_SIZE];
		my_boss.cfg.Get("plugin name", plugin_name_str, sizeof(plugin_name_str));
		my_boss.id = VSH2_RegisterPlugin(plugin_name_str);
	}
}
```
Inside `OnLibraryAdded`, what we do first is create a global enum-struct variable to help manage the module-wide data that needs to be shared between code and hook functions. The enum-struct *should* have at least an id of type `int` and a `ConfigMap` instance (this is assuming you want your boss to have a custom boss config file). In the example, we also add an instance of the `VSH2GameMode` for whenever our boss requires data or behavior from the Gamemode manager.

Another thing that I can encourage is that you don't have to completely rely on `ConfigMap` by also adding `ConVar`s to your boss module for simpler data customization. Use `ConfigMap` for more structured, customizable data.

We also write the code so that we try to load in the custom boss config file and stop the boss registration if it doesn't exist. That way we don't accidentally load in a boss with invalid data! If the boss config file failed to load in whatever way, we will get an error log of it so that the server operator(s) can be notified of the issue.

**Anything that goes wrong in your code SHOULD be logged for later investigation.**

If we were able to load the custom boss config file without issues, next we must register our boss module using `VSH2_RegisterPlugin`; however we still need to setup our VSH2 Hooks for the addon which is coming up next. Note that the value of `my_boss.id` is because `VSH2_RegisterPlugin` returns the runtime ID that is assigned to the boss module.

## Hooking Functions to Addons
The important step to making your boss module (or addon) work is you need to hook specific VSH2 events for use. This method is exactly the same as hooking SDKHooks functions. When it comes to a boss, you can use *any* VSH2 event hook to run specific actions whether it's for a passive mechanic, active mechanic, both, or more!

[Here's a list of available forwards that you can hook!](https://github.com/VSH2-Devs/Vs-Saxton-Hale-2/wiki/VSH2-API#vsh2-hook-types-anonymous-enum).

To hook to a function, we use the `VSH2_Hook`/`VSH2_Unhook` functions in the API.
```c
native void VSH2_Hook(int callbacktype, VSH2HookCB callback);
```
Within our example boss module, let's say we wanted to hook `OnBossThink` so that we can run boss specific code every 0.1 seconds.
We look at `VSH2HookCB` for the typeset that `OnBossThink` uses:
```c
/**
	OnBossThink
 */
function void (VSH2Player Player);
```
So to use the `OnBossThink` forward, we need to implement a function that follows the typeset function signature for `OnBossThink`.

```c
enum struct MyBoss {
	int          id;
	VSH2GameMode gm;
	ConfigMap    cfg;
}
MyBoss my_boss;


public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		my_boss.cfg = new ConfigMap("configs/saxton_hale/boss_cfgs/my_boss.cfg");
		if( my_boss.cfg==null ) {
			LogError("[VSH 2] ERROR :: **** couldn't find 'configs/saxton_hale/boss_cfgs/my_boss.cfg'. Failed to register My Boss. ****");
			return;
		}
		char plugin_name_str[MAX_BOSS_NAME_SIZE];
		my_boss.cfg.Get("plugin name", plugin_name_str, sizeof(plugin_name_str));
		my_boss.id = VSH2_RegisterPlugin(plugin_name_str);
	}
}

public void MyBoss_OnBossThink(VSH2Player player) {
	int client = player.index;
	if( !IsPlayerAlive(client) || player.GetPropInt("iBossType") != my_boss.id )
		return;
	
	/// execute our boss' think code here!
}
```
In the above example, we use `VSH2_HookEx` to make sure that the hook was successful; you could simply use `VSH2_Hook` but it's nice to be safe at times! As shown in the above example, we created our boss think function and hooked it to the `OnBossThink` VSH2 event, now every time the boss think function runs, our think function will be called with it!


For multiple boss event hooks where you need to constantly check if the boss type of the player is equal to the boss ID of your boss module, it's recommended that you make a stock function that does this for you:
```c
stock bool IsMyBoss(VSH2Player player) {
	return player.GetPropInt("iBossType") == my_boss.id;
}
```

Now the above boss think code can be revamped like so:
```c
public void MyBoss_OnBossThink(VSH2Player player) {
	int client = player.index;
	if( !IsPlayerAlive(client) || !IsMyBoss(player) )
		return;
	
	/// execute our boss' think code here!
}
```

**Note** - for `OnBossThink`, you don't have to check if the player is a boss, this is because Boss-specific VSH2 events will **only** ever activate for boss players.


# Adding your Boss to menus
Given that VSH2 has built-in support for Boss data in menus, it'd be very convenient for our boss to show up in menus like `!setboss` or `!hale_special`.

To achieve this, we hook to a forward called `OnBossMenu`:
```c
VSH2_Hook(OnBossMenu, MyBoss_OnBossMenu);
```
which is invoked when boss-oriented menus are executed.

To actually make our boss available from the boss menu, we use a method that uses the boss' dynamically given Boss ID but in a maintainable way by converting its given value to a string as the boss ID as well as using `ConfigMap` to make the boss' menu name customizable. Like so:
```c
public void MyBoss_OnBossMenu(Menu& menu) {
	char tostr[10]; IntToString(my_boss.id, tostr, sizeof(tostr));
	int menu_name_len = my_boss.cfg.GetSize("menu name");
	char[] menu_name_str = new char[menu_name_len];
	my_boss.cfg.Get("menu name", menu_name_str, menu_name_len);
	menu.AddItem(tostr, menu_name_str);
}
```
So when the menu user selects your boss, the dynamic Boss ID will be used as the menu ID data.


# Handling Boss Assets

An extremely crucial part of creating any boss is dealing with how to handle a boss' assets such as the model(s), each model(s) skin(s), and sound or music. VSH2 also helps you out in this regard in two ways: The hand-coded way and the `ConfigMap` way.

Since the above boss code example has been using `ConfigMap`, we will handle boss assets through the boss config file. To get started, we need our boss module to hook to a VSH2 event called `OnCallDownloads`:
```c
/// this code is inside of `OnLibraryAdded`.
if( !VSH2_HookEx(OnCallDownloads, MyBoss_OnCallDownloads) )
	LogError("Error loading OnCallDownloads forwards for My Boss module.");

...

public void MyBoss_OnCallDownloads() {
	int boss_mdl_len = my_boss.cfg.GetSize("model");
	char[] boss_mdl_str = new char[boss_mdl_len];
	if( my_boss.cfg.Get("model", boss_mdl_str, boss_mdl_len) > 0 ) {
		PrepareModel(boss_mdl_str);
	}
	
	/// model skins.
	ConfigMap skins = my_boss.cfg.GetSection("skins");
	PrepareAssetsFromCfgMap(skins, ResourceMaterial);
	
	ConfigMap sounds_sect = my_boss.cfg.GetSection("sounds");
	if( sounds_sect != null ) {
		PrepareAssetsFromCfgMap(sounds_sect.GetSection("intro"),      ResourceSound);
		PrepareAssetsFromCfgMap(sounds_sect.GetSection("rage"),       ResourceSound);
		PrepareAssetsFromCfgMap(sounds_sect.GetSection("jump"),       ResourceSound);
		PrepareAssetsFromCfgMap(sounds_sect.GetSection("backstab"),   ResourceSound);
		PrepareAssetsFromCfgMap(sounds_sect.GetSection("death"),      ResourceSound);
		PrepareAssetsFromCfgMap(sounds_sect.GetSection("lastplayer"), ResourceSound);
		PrepareAssetsFromCfgMap(sounds_sect.GetSection("kill"),       ResourceSound);
		PrepareAssetsFromCfgMap(sounds_sect.GetSection("spree"),      ResourceSound);
		PrepareAssetsFromCfgMap(sounds_sect.GetSection("win"),        ResourceSound);
		PrepareAssetsFromCfgMap(sounds_sect.GetSection("music"),      ResourceSound);
	}
}
```

From VSH2, we have a `ConfigMap`-based convenient helper called `PrepareAssetsFromCfgMap` which helps automate iterating through a section of the `ConfigMap` that contains files for downloading. The 2nd parameter let's us tell the code what kind of file we're setting up for downloading.

However, it's **very** important to know that the helper function assumes the config section is enumerated, example of what I mean:
```
"boss" {
	...
	"sounds" {
		"intro" {
			"<enum>" "path/file1.mp3"
			"<enum>" "path/file2.mp3"
			"<enum>" "path/file3.mp3"
			...
			"<enum>" "path/fileN.mp3"
		}
	}
	...
}
```

In the code, we're getting the entire `sounds` subsection and then getting each individual subsections from `sound`. Each value in `intro` **MUST** be enumerated from 0 to max values. Use the `"<enum>"` key to automate it so you don't have to manually number things.

If you have files that aren't enumerated (boss with only a single, simple model), then you'll have to set it up for download by hand:
```c
int boss_mdl_len = my_boss.cfg.GetSize("model");
char[] boss_mdl_str = new char[boss_mdl_len];
if( my_boss.cfg.Get("model", boss_mdl_str, boss_mdl_len) > 0 ) {
	PrepareModel(boss_mdl_str);
}
```

The above code is using a config file that has a key called "model" in a section called "boss":
```
"boss" {
	...
	"model"  "path/my_boss.mdl"
	...
}
```

the code `PrepareModel(boss_mdl_str);` is what will then set up the boss' model for download.


### Using ConfigMap-based Assets in code
Obviously it's not enough to just set up the assets for download but what about actually putting them to use? This is where we get into using the VSH2 event hook `OnBossModelTimer`! In order to make sure that boss' keep their models (in case things go wrong), the boss models get refreshed in use. `OnBossModelTimer` is also where we utilize our boss model for the player-boss to use:


```c
/// In `OnLibraryAdded`.
if( !VSH2_HookEx(OnBossModelTimer, MyBoss_OnBossModelTimer) )
	LogError("Error loading OnBossModelTimer forwards for My Boss module.");

...

public void MyBoss_OnBossModelTimer(VSH2Player player) {
	if( !IsMyBoss(player) ) {
		return;
	}
	
	int client = player.index;
	int boss_mdl_len = my_boss.cfg.GetSize("model");
	char[] boss_mdl = new char[boss_mdl_len];
	my_boss.cfg.Get("model", boss_mdl, boss_mdl_len);
	SetVariantString(boss_mdl);
	AcceptEntityInput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
}
```

With the help of `ConfigMap`, the boss model can be then changed and updated at any time with the changes taking effect as soon as the `OnBossModelTimer` event activates. So we have models taken care of, what about our multitude of sounds that are also divided up into their own subsections? Luckily, we don't need to hook anymore VSH2 events to accomplish this but we do have a `ConfigMap`-based helper **method** for the `VSH2Player` class that'll take care of this situation:

```c
/// VSH2Player
void PlayRandVoiceClipCfgMap(ConfigMap sect, int voice_flags);
```

`PlayRandVoiceClipCfgMap` works exactly like `PlayVoiceClip` with the difference being that you give the method an enumerated subsection of sounds from `ConfigMap` to randomly choose from instead of a specific sound file. Another thing is that `PlayRandVoiceClipCfgMap` checks if the subsection is null so you don't have to.



For a full template/example code that can be modified, please have a look at and/or copy the [VSH2 Boss Template](https://github.com/VSH2-Devs/Vs-Saxton-Hale-2/blob/develop/addons/sourcemod/scripting/vsh2boss_template.sp).
