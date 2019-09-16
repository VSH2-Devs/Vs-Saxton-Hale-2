# VS Saxton Hale 2 (VSH2)

#### Current STABLE Version: *2.0.5*
[![Master Build Status](https://travis-ci.org/VSH2-Devs/Vs-Saxton-Hale-2.svg?branch=master)](https://travis-ci.org/VSH2-Devs/Vs-Saxton-Hale-2)
#### Current DEVELOPMENT Version: *2.2.4*
[![Develop Build Status](https://travis-ci.org/VSH2-Devs/Vs-Saxton-Hale-2.svg?branch=develop)](https://travis-ci.org/VSH2-Devs/Vs-Saxton-Hale-2)
======
VSH2 is rewrite of VSH 1. VSH and FF2 were made as very bad frameworks using shoddy, hacky coding. VSH2 combines the best of both FF2 and VSH by not only having multiplayer boss support but also to make it easier to add new bosses and give them truly unique abilities and mechanics through giving the developer full, uninhibited control by code rather than config files.

FF2's purpose was to be very easy to add bosses. Of course there's a trade off: FF2 is alot more difficult, if not impossible, to truly customize boss mechanics and abilities without having to recode parts of FF2 itself. VSH2, since it requires experience with SourcePawn, is somewhat more difficult for a newbie than FF2 to create new bosses but it rewards taking the harder route by allowing you to control every individual boss behavior and logic.

If you do require help in setting up the bosses or at least need some info on the API for boss building in VSH2, [have a look at the VSH2 wiki](https://github.com/VSH2-Devs/Vs-Saxton-Hale-2/wiki)

**NB:** While VSH2 will work perfectly fine as-is out of the box as a VSH1 replacement, it was designed with capable SourcePawn **_developers_** in mind to make the most out of the coded-from-scratch framework! So don't expect to be able to easily modify/add bosses if you have no prior SourcePawn experience like you would with FF2.
======

### Why VSH2?

* VSH2 was created to facilitate easier boss additions to a VSH-esque gamemode while having extensive customisation capabilities, even more so than FF2.
* VSH2 operates through a series of Event Handling functions across different Boss, non-Boss actions, and clear cut API which allows developers to control boss code at will and with ease.
* VSH2's game state is controlled through a singleton instance of the VSHGameMode methodmap which allows for easier management of the entire gamemode's state.
* VSH2 gives you the option to either hard code your new bosses directly into the plugin or use the API to build bosses as subplugins!

### How do I get set up?

* Compile with spcomp
* VSH2 uses the same map configurations as FF2 and VSH and this is for compatibility reasons.
* Dependencies: TF2Items, MoreColors
* Optional: TF2Attributes, SteamTools
* Compile plugin into .smx and put in addons/sourcemod/plugins folder
* Take a look at the [Wiki](https://github.com/VSH2-Devs/Vs-Saxton-Hale-2/wiki) to get started making your own boss!

### Who do I talk to?

* **Main Plugin Developer:** *Nergal the Ashurian/Assyrian* - https://forums.alliedmods.net/member.php?u=176545
* **Repository Manager and Contributor:** *Starblaster 64* - https://forums.alliedmods.net/member.php?u=261662
* **Contributor:** *Scags/RageNewb* 

### Contribution Rules
#### Code Format:
* single line comments that convey a message must have 3 slashes: `///`.
* multi-line comments that convey a message should have an extra beginning star: `/**`.
* properties, functions, & methods smaller than 20 lines of code should have the beginning `{` brace in K&R C style, for example: `ret func() {`
* local variable names should be in snake_case.
* property names must have a single-letter prefix of their type.
* functions, methods, methodmaps, enums, enum values,  must be named in PascalCase. Pascal_Case is also acceptable.
