![VSH2 Logo by Nergal/Assyrianic](https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/efc8ece3-f4a3-4477-8ebb-cb9595fb9e58/ddiv9m4-cbc4d719-c2fd-4890-b62a-17be7f01210f.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcL2VmYzhlY2UzLWY0YTMtNDQ3Ny04ZWJiLWNiOTU5NWZiOWU1OFwvZGRpdjltNC1jYmM0ZDcxOS1jMmZkLTQ4OTAtYjYyYS0xN2JlN2YwMTIxMGYucG5nIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.JjuSnfGa4fwWanCRmVmvkaI5GV9u5PYReeJ9ll1AIBQ)

#### Current STABLE Version: *2.0.5*
[![Master Build Status](https://travis-ci.org/VSH2-Devs/Vs-Saxton-Hale-2.svg?branch=master)](https://travis-ci.org/VSH2-Devs/Vs-Saxton-Hale-2)
#### Current DEVELOPMENT Version: *2.12.1*
[![Develop Build Status](https://travis-ci.org/VSH2-Devs/Vs-Saxton-Hale-2.svg?branch=develop)](https://travis-ci.org/VSH2-Devs/Vs-Saxton-Hale-2)

#### Current DEVELOPMENT STATUS updated 4/12/22
Transitioning devs, documenting and testing 2.13 for final fixes for release.

**[VSH2 Addons Repository](https://github.com/VSH2-Devs/VSH2-Addons)**

NOTICE: This readme will be updated soon. Thank you for your patience!

VSH2 is a rewrite of VSH1. VSH1 and FF2 both had a very bad gamemode framework using shoddy, hacky coding. I could even go as far to say they probably had no framework at all nor any real structure to its code.

VSH2 actually has a structured, event-based framework which combines the best features of both FF2 and VSH1 by not only having multiplayer boss support but also to make it easier to add new bosses **and** give them truly unique abilities & mechanics through giving the developer full, uninhibited control by code rather than strictly config files.

FF2's purpose was to be very easy to add bosses in a generic, cookie-cutter manner. Of course there's a trade off: FF2 is alot more difficult, if not impossible, to truly customize boss mechanics & abilities without having to recode parts of FF2 itself. VSH2, since it requires at least some experience with SourcePawn, is somewhat more difficult for a newbie to create new bosses than if they were to use FF2 but choosing VSH2 rewards taking the harder route by allowing you to control damn near every individual boss behavior and logic.

If you do require help in setting up the bosses or at least need some info on the API for boss building, then take advantage of VSH2's vast API by [having a look at the VSH2 wiki](https://github.com/VSH2-Devs/Vs-Saxton-Hale-2/wiki)

**NB:** VSH2 will work perfectly fine as-is out of the box as a VSH1 replacement, but it was designed with capable SourcePawn **_developers_** in mind to make the most out of the coded-from-scratch framework!

### Why VSH2?

* VSH2 was created to facilitate easier boss additions to a VSH-esque gamemode while having extensive customisation capabilities, even more so than FF2.
* VSH2 operates through a series of Event Handling functions across different Boss, non-Boss actions, and clear cut API which allows developers to control boss code at will and with ease.
* VSH2's game state is controlled through a singleton instance of the VSHGameMode methodmap which allows for easier management of the entire gamemode's state.
* VSH2 has a vast API to build bosses as wide reaching as your imagination and TF2's limitations!
* 'ConfigMap' allows you to not only have the power of VSH2's API but have FF2-like configuration for a powerful combination of customization through code and config alike.

### How do I get set up?

* VSH2 uses the same map configurations as FF2 and VSH1 and this is for compatibility reasons.
* Dependencies: [TF2Items](https://builds.limetech.io/?project=tf2items), MoreColors, ConfigMap (MoreColors + ConfigMap are part of VSH2 repo).
* Optional Dependencies: [TF2Attributes](https://github.com/FlaminSarge/tf2attributes), [SteamTools](https://forums.alliedmods.net/showthread.php?t=170630)
* Compile the VSH2 script code with spcomp or upload the prebuild SMX binaries; which ever method you use, move the SMX binaries to your server's SourceMod 'plugins' directory (addons/sourcemod/plugins).
* Read the [Wiki](https://github.com/VSH2-Devs/Vs-Saxton-Hale-2/wiki) to get started making your own boss!
* If you're moving from FF2 to VSH2, we also have the VSH2-FF2 Compatibility Engine, [use this FF2 subplugin library, courtesy of 01Pollux](https://github.com/01Pollux/FF2-Library)

### Credits

* **Owner:** *Nergal the Ashurian/Assyrian* - https://forums.alliedmods.net/member.php?u=176545
* **Current Project Lead:** *mub* - https://steamcommunity.com/profiles/76561197961943948/
* **Repository Manager & Contributor:** *Starblaster 64* - https://forums.alliedmods.net/member.php?u=261662
* **Contributors:** *Scags/RageNewb* , *BatFoxKid* , *01Pollux/WhiteFalcon* .
* **Special thanks to** the communities and servers who used or currently use this mod!

### Contribution Rules
#### Code Format:
* Use New sourcepawn syntax (sourcemod 1.7+).
* Statements that require parentheses (such as 'if' statements) should have each side of the parentheses spaced out with the beginning parens touching the construct keyword, e.g. `construct( code/expression )`.
* Single line comments that convey a message must have 3 slashes: `///`.
* Multi-line comments that convey a message should have an extra beginning star: `/**`.
* Properties, functions, & methods smaller than 30 lines of code should have the beginning `{` brace in K&R C style, for example: `ret func() {`.
* Local variable names should be in snake_case.
* Property names must have a single-letter prefix of their type.
* Functions, methods, methodmaps, enums, enum values, must be named in PascalCase. Pascal_Case is also acceptable.
* Enum values used as flags may be upper-case.
