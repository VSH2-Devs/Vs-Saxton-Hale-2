# VSH 2 #

#### Current STABLE Version: *v1.3.6*
[![Master Build Status](https://travis-ci.org/Starblaster64/Vs-Saxton-Hale-2.svg?branch=master)](https://travis-ci.org/Starblaster64/Vs-Saxton-Hale-2)
#### Current UNSTABLE Version: *1.5.1*
[![Develop Build Status](https://travis-ci.org/Starblaster64/Vs-Saxton-Hale-2.svg?branch=develop)](https://travis-ci.org/Starblaster64/Vs-Saxton-Hale-2)
======
VSH2 is half-rewrite of VSH 1. VSH and FF2 were made as very bad frameworks and shoddy, hacky coding. VSH2 combines the best of both FF2 and VSH by not only having multiplayer boss support but also to make it easier to add new bosses and to give those bosses truly unique abilities and mechanics by giving the developer full, uninhibited power through code rather than configs.

**NB:** While VSH2 will work perfectly fine as-is out of the box as a VSH1 replacement, it was designed with capable SourcePawn **_developers_** in mind to make the most out of the coded-from-scratch framework! So don't expect to be able to easily modify/add bosses if you have no prior SourcePawn experience like you would with FF2.

======
### Why VSH2? ###

* VSH2 was created to facilitate easier boss additions to a VSH-esque gamemode while having extensive customisation capabilities, even more so than FF2.
* VSH2 operates through a series of Event Handling functions across different Boss and non-Boss actions which allows developers to control boss code at will.
* VSH2's game state is controlled through a singleton instance of the VSHGameMode methodmap.

### How do I get set up? ###

* Compile with spcomp
* VSH2 uses the same map configurations as FF2 and VSH and this is for compatibility reasons.
* Dependencies: TF2Items, MoreColors
 * Optional: TF2Attributes, SteamTools
* Compile plugin into .smx and put in addons/sourcemod/plugins folder
* Take a look at the [Wiki](https://github.com/Starblaster64/Vs-Saxton-Hale-2/wiki) to get started making your own boss!

### Who do I talk to? ###

* **Main Plugin Developer:** *Nergal the Ashurian/Assyrian* - https://forums.alliedmods.net/member.php?u=176545
* **Repository Manager and Contributor:** *Starblaster 64* - https://forums.alliedmods.net/member.php?u=261662


## Issue Progress ##
[![Issues/PRs in Ready](https://badge.waffle.io/Starblaster64/Vs-Saxton-Hale-2.svg?label=ready&title=Ready)](https://overv.io/Starblaster64/Vs-Saxton-Hale-2/)
[![Issues/PRs in In Progress](https://badge.waffle.io/Starblaster64/Vs-Saxton-Hale-2.svg?label=in%20progress&title=In%20Progress)](https://overv.io/Starblaster64/Vs-Saxton-Hale-2/)
[![Issues/PRs in On Hold](https://badge.waffle.io/Starblaster64/Vs-Saxton-Hale-2.svg?label=on%20hold&title=On%20Hold)](https://overv.io/Starblaster64/Vs-Saxton-Hale-2/)
