# General Boss and Player API
## methodmap BasePlayer - applies to both bosses and non-bosses
### Properties
```c++
int userid
```
- returns userid of the player

```c++
int index
```
- returns entity index of the player

```c++
int iQueue
```
- get/set the Queue points of a player (this uses the array as backup while saving to cookies)

```c++
int iPresetType
```
- get/set the preferred boss type of the player (this uses the array as backup while saving to cookies) 

```c++
int iKills
```
- get/set the amount of kills a player got

```c++
int iHits
```
- get/set the amount of times a player got hit

```c++
int iLives
```
- get/set the amount of lives a player gets

```c++
int iState
```
- get/set the state of a player (this data can mean any kind of state for anything)

```c++
int iDamage
```
- get/set the damage a player did to a boss

```c++
int iAirDamage
```
- get/set the damage a player did with the AirStrike weapon

```c++
int iSongPick
```
- get/set the preferred song/background theme for the player

```c++
int iOwnerBoss
```
- gets the entity index of the boss who owns this player (Set this property using the boss' userid)

```c++
int iUberTarget
```
- get/set the target of a medic's uber, (use userid when setting this property)

```c++
int iShieldDmg
```
- get/set the amount of damage done when not having a shield, this property is primarily to track demoman shield regeneration.

```c++
int iClimbs
```
- get/set the amount of climbs a player did.

```c++
TFClassType iTFClass
```
- gets the player's TF2 class.

```c++
bool bIsMinion
```
- get/set if a player is a minion to a boss (use in conjunction with `iOwnerBoss` so you can identify what boss made this player into a minion).

```c++
bool bInJump
```
- get/set if a player is jumping

```c++
bool bNoMusic
```
- get/set if a player can hear the boss music/background theme

```c++
float flGlowtime
```
- get/set the time when a player is glowing or not (use in conjunction with `bGlow`)

```c++
float flLastHit
```
- get/set the last time a player was hit

```c++
float flLastShot
```
- get/set the last time a player fired/swung their weapon

```c++
float flMusicTime
```
- get/set the amount of time a song is (this is for setting how long background music is) to the player.

### Methods
```c++
BasePlayer(int ind, bool uid=false)
```
- constructor for `BasePlayer`, gives you the option to make an instance using a player's entity index or, if uid is set to true, a player's userid.

```c++
void ConvertToMinion(float time)
```
- converts a player to a minion, automatically sets `bIsMinion` to true

```c++
int SpawnWeapon(char[] name, int index, int level, int qual, char[] att)
```
- spawns a weapon to a player

```c++
int getAmmotable(int wepslot)
```
- gets the ammo table for a player's weapon in a weapon slot

```c++
 void setAmmotable(int wepslot, int val)
```
- sets the ammo table for a player's weapon in a weapon slot

```c++
 int getCliptable(int wepslot)
```
- gets the clip table for a player's weapon in a weapon slot

```c++
 void setCliptable(int wepslot, int val)
```
- sets the clip table for a player's weapon in a weapon slot

```c++
 int GetWeaponSlotIndex(int slot)
```
- gets the item index of a weapon by weapon slot

```c++
 void SetWepInvis(int alpha)
```
- sets the alpha of a weapon so it can be transparent (255 for no transparent, 0 for completely invisible)

```c++
 void SetOverlay(const char[] strOverlay)
```
- puts an overlay on a player's screen

```c++
 void TeleToSpawn(int team = 0)
```
- teleports a player to spawn, depending what team spawn.

```c++
 void IncreaseHeadCount(bool addhealth=true, int head_count=1)
```
- if using demoman swords, increases the head count and applies the buff

```c++
 void SpawnSmallHealthPack(int ownerteam=0)
```
- spawns a health pack at a player's origin

```c++
 void ForceTeamChange(int team)
```
- forces a player to change to a different team

```c++
 void ClimbWall(int weapon, float upwardvel, float health, bool attackdelay)
```
- makes a player climb a wall as long the wall is 90 degrees (more or less).

```c++
 void HelpPanelClass()
```
- sends a help panel to a player telling them about the class and their changes based on what class the player is.

```c++
 int GetHealTarget()
```
- gets the player index of the current healing target.

```c++
 bool IsNearDispenser()
```
- checks if the player is being healed/supplied by a dispenser.

```c++
bool IsInRange(int target, float dist, bool pTrace=false)
```
- checks if the player is in range of a specific entity, `pTrace` being false means ignoring objects between the entities.

```c++
void RemoveBack(int[] indices, int len)
```
- Removes a set/array of cosmetic-based items from the player (like mantreads for instance).

```c++
int FindBack(int[] indices, int len)
```
- finds an item within a set/array of cosmetic-based items from the player (like mantreads for instance).

```c++
int ShootRocket(bool bCrit=false, float vPosition[3], float vAngles[3], float flSpeed, float dmg, const char[] model, bool arc=false)
```
- shoots a rocket-like, arc-able projectile from the player.

```c++
void Heal(int health, bool on_hud=false, bool overridehp=false, int overheal_limit=0)
```
- heals the player with option to show the health gained on the hud.

```c++
void PlayMusic(float vol, const char[] override="");
```
- starts playing music to the player, `vol` for volume.

```c++
void void StopMusic();
```
- stop music that is playing to the player.

## methodmap BasePlayer - derives from `BaseFigher`, this is the methodmap all bosses (must) inherit from
### Properties
```c++
int iHealth
```
- get/set the current health of the boss

```c++
int iMaxHealth
```
- get/set the maximum health of the boss (primarily used for damage and various calculations)

```c++
int iBossType
```
- get/set the Boss type, it's extremely important to set the player's boss type when making them into a boss.

```c++
int iStabbed
```
- get/set the amount of times the individual boss has been backstabbed

```c++
int iMarketted
```
- get/set the amount of times the individual boss has been market gardened

```c++
int iDifficulty
```
- get/set the difficulty setting of a boss (primarily unused)

```c++
bool bIsBoss
```
- get if a player is a boss.

```c++
bool bUsedUltimate
```
- get/set if a boss used a rare ability, primarily used for abilities like rage that are only useable once but of course, you can always reset it.

```c++
bool bSuperCharge
```
- get/set if a boss can do a super-duper jump, can be repurposed for other abilities just like `bUsedUltimate`.

```c++
float flSpeed
```
- get/set the speed of the boss, this is primarily used for health-based movement speed.

```c++
float flCharge
```
- get/set the right click or crouching ability charge. Depends how you coded your boss so it can charge via right click or crouching.

```c++
float flRAGE
```
- get/set the rage ability, automatically clamps between 0.0 and 100.0

```c++
float flKillSpree
```
- this is for getting when a boss has killed a certain amount of people under `flKillingSpree`'s time. Look in `bosses/hale.sp` to understand what this means.

```c++
float flWeighDown
```
- get/set the charge for doing the weighdown ability.

You can actually use `flWeighDown` or any others to control a completely different ability.
Or even better, make your own if necessary.
### Methods
```c++
 BasePlayer(int ind, bool uid = false)
```
- constructor to make a player as an instance of `BasePlayer`, works the same as the constructor for `BasePlayer` see ` BasePlayer(int ind, bool uid=false)` on how to use.

```c++
 void ConvertToBoss()
```
- this method sets the `bIsBoss` property depending what `bSetOnSpawn` is set to, sets `flRAGE` to 0.0 and calls `_MakePlayerBoss`. It's preferred to use `MakeBossAndSwitch` over this method.

```c++
 void GiveRage(int damage)
```
- generic health based calculated method to give rage to the boss, the formula works as `damage/sqrt(currentHealth)*1.76`. If necessary, you can make your own for your custom bosses

```c++
 void MakeBossAndSwitch(int type, bool callEvent)
```
- This function sets `bSetOnSpawn` to true, sets the boss type based on what `type` is, calls `ConvertToBoss()`, and forces the player to be team switched to BLU. Use this method over `ConvertToBoss()`. New in 1.3.0 Beta - `callEvent` let's you control if you want `MakeBossAndSwitch` to call the `OnBossSelected` event.

```c++
 void DoGenericStun(float rageDist)
```
- generic rage stun that's commonly used by many VSH/FF2 bosses but as a function. `rageDist` specifies the max distance radius, anyone (players, buildings) within the radius will be stunned.

```c++
 void RemoveAllItems()
```
- removes **ALL** (cosmetics and weapons, etc) items from the boss' person. Removes weapons and their associated cosmetics, Demoman shield cosmetic, wearable cosmetics, and MvM powerup canteens.

```c++
bool GetName(char buffer[MAX_BOSS_NAME_SIZE])
```
- Gets the set name of the boss, `MAX_BOSS_NAME_SIZE` is 64 bytes large.

```c++
bool SetName(char name[MAX_BOSS_NAME_SIZE])
```
- Sets the name of the boss, `MAX_BOSS_NAME_SIZE` is 64 bytes large.

```c++
void SuperJump(float power, float reset)
```
- performs the generic super jump ability.

```c++
void WeighDown(float reset)
```
- performs the generic weighdown ability.

```c++
void PlayVoiceClip(const char[] vclip, int flags)
```
- player a boss specific voice clip, using different voice flags for effects.

Available Voice flags:
```
VSH2_VOICE_ALL
VSH2_VOICE_ABILITY
VSH2_VOICE_RAGE
VSH2_VOICE_SPREE
VSH2_VOICE_STABBED
VSH2_VOICE_WIN
VSH2_VOICE_LOSE
VSH2_VOICE_INTRO
VSH2_VOICE_LASTGUY
```

# Gamemode Manager API (modules/gamemode.sp)
## methodmap VSHGameMode - controls the VSH mod and functionality
### Properties
```c++
int iRoundState
```
- get/set the current Round State of the gamemode. Here's the enum for it.

```c++
enum /** VSH2 Round States */ {
	StateDisabled = -1,
	StateStarting = 0,
	StateRunning = 1,
	StateEnding = 2,
};
```

```c++
int iSpecial
```
- get/set the predetermined boss type to be used when a player becomes a boss (this is overrode if the player set their boss OR if the admin used the set special commands to forcefully change it. If `iSpecial` is -1, then it'll pick a random boss between 0 and `g_vshgm.MAXBOSS` define)

```c++
int iPrevSpecial
``` - get/set the previous `iSpecial` from the round before.

```c++
VSHHealthBar iHealthBar
```
- gets/set the healthbar (please don't touch this unless you know what you're doing)

```c++
int iHealthBar.iState
```
- get/set the state of the healthbar which usually just changes its color...

```c++
int iHealthBar.iPercent
```
- get/set the percentage byte of the health bar from 0 to 255, setting the health bar automatically clamps the value between 0 and 255 so you can set it with unsafe numbers if you care.

```c++
int iTotalMaxHealth
```
- get/set the Total Max health for all current bosses.

```c++
int iTimeLeft
```
- get/set the time left for the last player showdown timer.

```c++
int iRoundCount
```
- get/set the amount of rounds that have been played

```c++
int iHealthChecks
```
- get/set the amount of times players have used the Check Health command.

```c++
int iCaptures
```
- get/set the amount of times the Arena control point has been captured.

```c++
bool bSteam
```
- if steam tools is included and enabled, get/set if the plugin should use Steam (this is mainly for setting the game server's description to something else)

```c++
bool bTF2Attribs
```
- if TF2Attributes is included and compiled with VSH2, this gets/sets if the plugin will use TF2Attributes natives.

```c++
bool bPointReady
```
- get/set if the control point is ready.

```c++
bool bMedieval
```
- get/set if Medieval Mode VSH2 is enabled.

```c++
bool bDoors
```
- get/set if the map doors must be forced open.

```c++
bool bTeleToSpawn
```
- get/set if bosses should be teleported back to spawn when hitting a `trigger_hurt`.

```c++
float flHealthTime
```
- get/set the last time a health check was performed.

```c++
float flMusicTime
```
- get/set the amount of time a song is (this is for setting how long background music is)

```c++
float flRoundStartTime
```
- gets the time when the round started. Unchanged until next round starts.

```c++
BasePlayer hNextBoss
```
- get/set the handle of a `BasePlayer` instance to be the next chosen boss player (**ALWAYS CHECK IF THIS IS 0**). **THIS IS NOT A HANDLE TYPE**.

### Methods
```c++
BasePlayer GetRandomBoss(bool balive)
```
- gets a random boss and allows you to get a living or dead boss

```c++
BasePlayer GetBossByType(bool balive, int type)
```
- this is the same as `GetRandomBoss` but it allows you to also get a random boss by type.

```c++
void CheckArena(bool type)
```
- presets the Arena control point enable time.

```c++
int GetQueue(BasePlayer[] players)
```
- populates a player array and sorts it by queue points.

```c++
BasePlayer FindNextBoss()
```
- gets the player that will become the next boss via queue points.

```c++
int CountMinions(bool balive, BasePlayer ownerboss=0)
```
- counts all players that have `bIsMinion` set to true and allows you to count living or dead.

```c++
int CountBosses(bool balive)
```
- same as `CountMinions` but for bosses, you check if you want to count only living bosses.

```c++
int GetTotalBossHealth()
```
- returns the total current boss health of each individual boss.

```c++
void SearchForItemPacks()
```
- scans the map for ammo and health packs to replace and if there's none, it'll spawn health and ammo packs in the player spawn.

```c++
void UpdateBossHealth()
```
- self explanatory, gets the total boss health and does a percentage calculation between 0 and 255 and sets the healthbar based on that.

```c++
void GetBossType()
```
- sets the next boss type for the new round. This is only called in `RoundStart` event.

```c++
bool IsVSHMap()
```
- checks if the map is a valid VSH map.

```c++
void CheckDoors()
```
- checks the saxton hale config whether the map must force its doors to be open.

```c++
void CheckTeleToSpawn()
```
- checks if the map requires that bosses be teleported to spawn if they hit a `trigger_hurt`.

```c++
static int GetBosses(BasePlayer[] bossarray, bool balive)
```
- gets bosses by filling in a buffer and returns the amount of bosses filled into the buffer, can also filter by living bosses.

```c++
static int GetFighters(BasePlayer[] redarray, bool balive)
```
- gets the RED players by filling in a buffer and returns the amount of RED players filled into the buffer, can also filter by living players.

```c++
static int GetMinions(BasePlayer[] marray, bool balive, BasePlayer ownerboss=0)
```
- gets the minions by filling in a buffer and returns the amount of minions filled into the buffer, can also filter by living minions.