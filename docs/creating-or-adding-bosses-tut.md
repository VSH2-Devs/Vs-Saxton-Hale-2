# Intro
VSH2 was designed and structured for easily adding/modifying bosses. VSH2 gives you the option to add/modify bosses INTERNALLY to the core plugin OR you could take advantage of VSH2's API to create bosses as addons!

The benefits to creating bosses as addons aka modules is that having your boss code separate from the VSH2 plugin allows you a different type of flexibility from internally coding your bosses. Through the use of VSH2's advanced hooking system and API, you can still have the power to create unique bosses.

**This tutorial assumes that you've already read or at least know some of** [VSH2's API](https://github.com/VSH2-Devs/Vs-Saxton-Hale-2/wiki/VSH2-API).

# Getting Started
Creating an addon module for VSH2, whether it's a boss or some other type of addon, requires that all addons must include `vsh2.inc`

```c
#include <sourcemod>
#include <vsh2>
```
For addons to work properly, you cannot use `OnPluginStart` but you can use `OnLibraryAdded`, this is so we can make sure that VSH2 itself has already been loaded.
```c
int g_iBossID;
public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		g_iBossID = VSH2_RegisterPlugin("my_boss_name");
	}
}
```
Inside `OnLibraryAdded`, if you are creating specifically a boss addon, you must register it using `VSH2_RegisterPlugin`, otherwise you still need to load VSH2 Hooks for the addon which is coming up next. Note that we have a global integer `g_iBossID`, this is because `VSH2_RegisterPlugin` returns the runtime ID that is assigned to the addon!

## Hooking Functions to Addons
The important step to making your addon work, whether it's a boss or not, is you need to hook specific forwards for use. This method is exactly the same as hooking SDKHooks functions.

[Here's a list of available forwards that you can hook!](https://github.com/VSH2-Devs/Vs-Saxton-Hale-2/wiki/VSH2-API#vsh2-hook-types-anonymous-enum).

To hook to a function, we use the `VSH2_Hook`/`VSH2_Unhook` functions in the API.
```c
native void VSH2_Hook(const int callbacktype, VSH2HookCB callback);
```
Within our example boss addon, let's say we wanted to hook `OnBossThink` for whatever reason.

We look at `VSH2HookCB` for the typeset that `OnBossThink` uses:
```c
/*
	OnBossThink
*/
function void (const VSH2Player Player);
```
So to use the `OnBossThink` forward, we need to implement a function that follows the typeset function signature for `OnBossThink`.

```c
int g_iBossID;
public void MyBoss_OnBossThink(const VSH2Player boss)
{
	int client = boss.index;
	if( !IsPlayerAlive(client) || boss.GetPropInt("iBossType") != g_iBossID )
		return;
	/// execute our boss' think code here!
}

public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		g_iBossID = VSH2_RegisterPlugin("my_custom_boss");
		if( !VSH2_HookEx(OnBossThink, MyBoss_OnBossThink) )
			LogError("Error loading OnBossThink forwards for MyBoss addon.");
	}
}
```
In the above example, we use `VSH2_HookEx` to make sure that the hook was successful; you could simply use `VSH2_Hook` but it's nice to be safe at times! As you can see in the above example, we created our boss think forward function and hooked it to `OnBossThink`, now every time the boss think function runs, our think function will be called!

# Adding your Boss to menus
Given that VSH2 has built in support for Boss data in menus, it'd be very convenient for our boss to show up in menus like `!setboss` or `!hale_special`.

To achieve this, we hook to a forward called `OnBossMenu`:
```c
VSH2_Hook(OnBossMenu, MyBoss_OnBossMenu);
```
which is invoked when boss-oriented menus are executed.

To actually make our boss available from the boss menu, we use a method that uses the boss' dynamically given Boss ID but in a maintainable way by converting its given value to a string as the boss ID. Like so:
```c
public void MyBoss_OnBossMenu(Menu& menu)
{
	char tostr[10]; IntToString(g_iBossID, tostr, sizeof(tostr));
	menu.AddItem(tostr, "My Boss");
}
```
So when the menu user selects your boss, the dynamic Boss ID will be carried over.

For a full template/example code that can be modified, please have a look at and/or copy the [VSH2 Boss Template](https://github.com/VSH2-Devs/Vs-Saxton-Hale-2/blob/develop/addons/sourcemod/scripting/vsh2boss_template.sp).
