# Designing New or Old Parts of VSH2's systems.


* Customizable singular, straight-forward data should be made as ConVars.

* Customizable complex and related data should be a config section.
	* Consider bitflags, enumerated sections, and/or enumerated keys.

* Any data handled internally by an event/message but isn't controlled by ConVar or config should likely be designed as a forward.
	* Make sure to explore other avenues of design before creating a new forward for the VSH2 system.

* Addon modules _always_ have a guaranteed priority over boss modules. Maintain this priority.

* Always THINK "is this customizable?" and "how can a dev and/or server op change/customize this?".
	* The motto of VSH2 is to be customizable, as much as possible.
	* If it helps, think Customer Service and Product Service.

* Sometimes a design takes alot of work to implement and make customizable.
	* If it is too much, consider the other options to make it customizable.
	* Consider if the data of the system can be represented by ConVars, configs, bitflags, or other structures.

* Inter-plugin work needs to be done through the VSH2 Module System.

* Think: "how can I make this feature customizable so that it's less painful for me and less painful for the end-user?"


## Case Study :: The Ability System

VSH2's ability system is setup using a combination of `StringMap`s and bit vectors. Very simple yet powerful system. There are 3 aspects to the ability system: Giving abilities, Removing all/some ablities, and Checking if the player has the ability, all done by the string name of the ability.

Addons can define their own abilities and dictate their behavior through VSH2's variety of events and natives. Addons do this by first registering their ability by a name. The registered name is then checked, validated, and internally assigned an ability bit ID. That ability bit ID is then placed into a `StringMap` using the ability's registered name for later retrieval since [hash]maps are the best data structure for mapping lengths of data to a specific set of values.

