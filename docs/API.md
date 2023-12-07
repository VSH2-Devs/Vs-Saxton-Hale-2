# Enums & Defines
## MAX_BOSS_NAME_SIZE (define)
`64`

## MAXMESSAGE
`512`

## MAX_PANEL_MSG
`512`

## VSH2 Round States (anonymous enum)
```c
StateDisabled = -1,
StateStarting = 0,
StateRunning  = 1,
StateEnding   = 2,
```

## VSH2 Teams (anonymous enum)
```c
VSH2Team_Unassigned=0,
VSH2Team_Neutral=0,
VSH2Team_Spectator,
VSH2Team_Red,
VSH2Team_Boss
```

## VSH2 Default Bosses (anonymous enum)
```c
VSH2Boss_Hale,
VSH2Boss_Vagineer,
VSH2Boss_CBS,
VSH2Boss_HHHjr,
VSH2Boss_Bunny,
MaxDefaultVSH2Bosses,
```

## Voice Clip Flags (anonymous enum)
```c
VSH2_VOICE_BOSSENT = 1, /// use boss as entity to emit from.
VSH2_VOICE_BOSSPOS = 2, /// use boss position for sound origin.
VSH2_VOICE_TOALL   = 4, /// sound replay to each individual player.
VSH2_VOICE_ALLCHAN = 8, /// if sound replay should use auto sound channel.
VSH2_VOICE_ONCE    = 16 /// play a clip once to all. (does not cancel out 'VSH2_VOICE_TOALL')
```

### Convenient, Ready-to-use Voice Flags
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

### HUDs (anonymous enum)
```
PlayerHUD
TimeLeftHUD
HealthHUD
MaxVSH2HUDs
```

### BannerType
```
BannerBuff
BannerDefBuff
BannerHealBuff
```

### Crit Flags (anonymous enum)
```
CRITFLAG_MINI  /// minicrits.
CRITFLAG_FULL  /// full crits.
CRITFLAG_STACK /// when healed by med, adds minicrits when full crits (for the fx).
```

### VSH2 Resource Types (anonymous enum)
```
ResourceSound,
ResourceModel,
ResourceMaterial,
MaxResourceTypes
```

## VSH2Player (methodmap)
### Native Properties
#### `userid`
returns userid of the player.

#### `index`
return the bare player index integer.

### `hOwnerBoss`
Convenient `VSH2Player` wrapper over `iOwnerBoss` property.

### `hUberTarget`
Convenient `VSH2Player` wrapper over `iUberTarget` property.

### `iHealth`
property wrapper over `GetClientHealth` and `SetEntityHealth`.

### `bIsBoss`
property wrapper over `bIsBoss` prop string.

### `hHealTarget`
property wrapper over `GetHealPatient`.

### Native Methods

```c
int GetPropInt(const char prop_name[64]);
float GetPropFloat(const char prop_name[64]);
any GetPropAny(const char prop_name[64]);

bool SetPropInt(const char prop_name[64], int value);
bool SetPropFloat(const char prop_name[64], float value);
bool SetPropAny(const char prop_name[64], any value);
```

For a list of available properties & more information on the methods, please see [The VSH2 Internal API Reference](https://github.com/VSH2-Devs/Vs-Saxton-Hale-2/wiki/VSH-2-Internal-API-Reference#properties).

```c
void ConvertToMinion(float spawntime);
int SpawnWeapon(char[] name, int index, int level, int qual, char[] att);
int GetWeaponSlotIndex(int slot);
void SetWepInvis(int alpha);
void SetOverlay(const char[] strOverlay);
bool TeleToSpawn(int team=0);
void IncreaseHeadCount();
void SpawnSmallHealthPack(int ownerteam=0);
void ForceTeamChange(int team);
bool ClimbWall(int weapon, float upwardVel, float health, bool attackdelay);
void HelpPanelClass();
int GetAmmoTable(int wepslot);
void SetAmmoTable(int wepslot, int amount);
int GetClipTable(int wepslot);
void SetClipTable(int wepslot, int amount);

int GetHealTarget();
VSH2Player GetHealPatient();
bool IsNearDispenser();
bool IsInRange(int target, float dist, bool pTrace=false);
bool IsPlayerInRange(VSH2Player target, float dist, bool pTrace=false);
int GetPlayersInRange(VSH2Player[] players, float dist, bool trace=false);
void RemoveBack(int[] indices, int len);
int FindBack(int[] indices, int len);
int ShootRocket(bool bCrit=false, float vPosition[3], float vAngles[3], float flSpeed, float dmg, const char[] model, bool arc=false);
void Heal(int health, bool on_hud=false, bool overridehp=false, int overheal_limit=0);
TFClassType GetTFClass();

/// NOTE: do not use this in 'OnPrepRedTeam' as spawning will remove attributes before you set it.
/// 
bool AddTempAttrib(int attrib, float val, float dur = -1.0);

void PlayMusic(float vol=100.0, const char[] override="");
void StopMusic();

/// Boss oriented methods
void ConvertToBoss();
void GiveRage(int damage);
void MakeBossAndSwitch(int type, bool run_event);
void DoGenericStun(float rageDist);
void StunPlayers(float rage_dist, float stun_time=5.0);
void StunBuildings(float rage_dist, float sentry_stun_time=8.0);
void RemoveAllItems();

bool GetName(const char buffer[MAX_BOSS_NAME_SIZE]);
bool SetName(const char name[MAX_BOSS_NAME_SIZE]);

void SuperJump(float power, float reset);
void WeighDown(float reset);

/** use the VSH2_VOICE_* flags above. */
void PlayVoiceClip(const char[] voiceclip, int flags);

void SpeedThink(float iota, float minspeed=100.0);
void GlowThink(float decrease);
bool SuperJumpThink(float charging, float jumpcharge, int buttons = (IN_ATTACK2|IN_DUCK));
void WeighDownThink(float weighdown_time, float incr, int buttons = IN_DUCK);

void PlayRandVoiceClipCfgMap(ConfigMap sect, int voice_flags);
```


## VSHHealthBar (methodmap)
### Properties
#### `entity`
returns the entity index of the healthbar.

#### `iState`
get/set the state of the healthbar.

#### `iPercent`
get/set the visual percentage of the healthbar. Setting is clamped between 0 and 255.

### Methods
#### `SetHealthPercent`
```c
void SetHealthPercent(int total_health, int total_max_health);
```
* Sets the `iPercent` property by calculating the percentage using the total boss health and total max health.


## VSH2 GameMode Natives
```c
int VSH2GameMode_GetPropInt(const char prop_name[64]);
float VSH2GameMode_GetPropFloat(const char prop_name[64]);
any VSH2GameMode_GetPropAny(const char prop_name[64]);

void VSH2GameMode_SetPropInt(const char prop_name[64], int value);
void VSH2GameMode_SetPropFloat(const char prop_name[64], float value);
void VSH2GameMode_SetPropAny(const char prop_name[64], any value);
```

For the list of properties available from the GameMode manager, please see [The GameMode Manager properties](https://github.com/VSH2-Devs/Vs-Saxton-Hale-2/wiki/VSH-2-Internal-API-Reference#properties-2).

```c
VSH2Player VSH2GameMode_FindNextBoss();
VSH2Player VSH2GameMode_GetRandomBoss(bool IsAlive);
VSH2Player VSH2GameMode_GetBossByType(bool IsAlive, int BossType);

int VSH2GameMode_CountMinions(bool IsAlive, VSH2Player ownerboss=0);
int VSH2GameMode_CountBosses(bool IsAlive);
int VSH2GameMode_GetTotalBossHealth();
int VSH2GameMode_GetTotalRedPlayers();
int VSH2GameMode_GetBosses(VSH2Player[] bosses, bool balive=true);
int VSH2GameMode_GetFighters(VSH2Player[] redplayers, bool balive=true);
int VSH2GameMode_GetMinions(VSH2Player[] minions, bool balive=true, VSH2Player ownerboss=0);
int VSH2GameMode_GetBossesByType(VSH2Player[] bosses, int type, bool balive=true);

/// has the `players` array sorted by DESCENDING order (first index is highest queue).
int VSH2GameMode_GetQueue(VSH2Player[] players);

void VSH2GameMode_SearchForItemPacks();
void VSH2GameMode_UpdateBossHealth();
void VSH2GameMode_GetBossType();

Handle VSH2GameMode_GetHUDHandle();

bool VSH2GameMode_IsVSHMap();
```
For more information on the GameMode native functions, please see the [Internal GameMode Methods](https://github.com/VSH2-Devs/Vs-Saxton-Hale-2/wiki/VSH-2-Internal-API-Reference#methods-2).

## VSH2GameMode (methodmap)
### Properties
#### `hNextBoss`
gets the next player that will become a boss.

#### `iTotalBossHealth`
gets the total health (not max health) of all living bosses.

#### `iLivingReds`
gets the number of living red players.

#### `hHUD`
gets the HUD handle.

#### `hHealthBar`
gets the healthbar entity (use with `VSHHealthBar` methodmap).

### Methods
```c
static int GetPropInt(const char prop_name[64]);
static any GetPropAny(const char prop_name[64]);
static float GetPropFloat(const char prop_name[64]);
static void SetProp(const char prop_name[64], any value);

static VSH2Player GetRandomBoss(bool is_alive);
static VSH2Player GetBossByType(bool is_alive, int boss_type);

static int CountMinions(bool is_alive, VSH2Player ownerboss=0);
static int CountBosses(bool is_alive);

static int GetBosses(VSH2Player[] bosses, bool balive=true);
static int GetFighters(VSH2Player[] redplayers, bool balive=true);
static int GetMinions(VSH2Player[] minions, bool balive=true, VSH2Player ownerboss=0);
static int GetBossesByType(VSH2Player[] bosses, int type, bool balive=true);
static int GetQueue(VSH2Player[] players);

static void SearchForItemPacks();
static void UpdateBossHealth();
static void SelectBossType();
static bool IsVSHMap();
```



## General VSH2 Natives
```c
int VSH2_RegisterPlugin(const char plugin_name[64]);
```
- Registers a plugin as a boss module, you do not need to register your plugin to use VSH2's event hooks.
Main focus of this native is to keep a head count of bosses and boss IDs.

```c
int VSH2_GetMaxBosses();
```
- returns the highest boss ID tracked by the VSH2 plugin, useful to see how many bosses are registered to the core VSH2 module.

```c
int VSH2_GetRandomBossType(int[] boss_filter, int filter_size=0);
```
- returns a randomly picked boss ID. `boss_filter` is used to exclude any boss ID from the randomization. Useful for trying to get a select pick of boss IDs.

```c
StringMap VSH2_GetBossIDs(bool registered_only=false);
```
- returns a StringMap of the bosses and their IDs. Set `registered_only` to true if you just need the IDs of custom-addon bosses. **The given StringMap must be freed when done with**.

```c
int VSH2_GetBossID(const char boss_name[MAX_BOSS_NAME_SIZE]);
```
- Returns the ID of a specific bossname, useful for example finding IDs of companions bosses at runtime.

```c
bool VSH2_GetBossNameByIndex(int index, char name_buffer[MAX_BOSS_NAME_SIZE]);
```
- Gets the name of a boss by index.

```c
void VSH2_StopMusic(bool reset_time=true);
```
- Stops the current background music, set `reset_time` to false if you don't want another song to immediately play.

```c
ConfigMap VSH2_GetConfigMap();
```
- Returns the internal ConfigMap instance.

## VSH2 Hook Types (anonymous enum)
```
OnCallDownloads=0,
OnBossSelected,
OnTouchPlayer,
OnTouchBuilding,
OnBossThink,
OnBossModelTimer,
OnBossDeath,
OnBossEquipped,
OnBossInitialized,
OnMinionInitialized,
OnBossPlayIntro,
OnBossTakeDamage,
OnBossDealDamage,
OnPlayerKilled,
OnPlayerAirblasted,
OnTraceAttack,
OnBossMedicCall,
OnBossTaunt,
OnBossKillBuilding,
OnBossJarated,
OnMessageIntro,
OnBossPickUpItem,
OnVariablesReset,
OnUberDeployed,
OnUberLoop,
OnMusic,
OnRoundEndInfo,
OnLastPlayer,
OnBossHealthCheck,
OnControlPointCapped,
OnBossMenu,
OnPrepRedTeam,
OnPlayerHurt,
OnScoreTally,
OnItemOverride,
OnBossDealDamage_OnStomp,
OnBossDealDamage_OnHitDefBuff,
OnBossDealDamage_OnHitCritMmmph,
OnBossDealDamage_OnHitMedic,
OnBossDealDamage_OnHitDeadRinger,
OnBossDealDamage_OnHitCloakedSpy,
OnBossDealDamage_OnHitShield,

OnBossTakeDamage_OnStabbed,
OnBossTakeDamage_OnTelefragged,
OnBossTakeDamage_OnSwordTaunt,
OnBossTakeDamage_OnHeavyShotgun,
OnBossTakeDamage_OnSniped,
OnBossTakeDamage_OnThirdDegreed,
OnBossTakeDamage_OnHitSword,
OnBossTakeDamage_OnHitFanOWar,
OnBossTakeDamage_OnHitCandyCane,
OnBossTakeDamage_OnMarketGardened,
OnBossTakeDamage_OnPowerJack,
OnBossTakeDamage_OnKatana,
OnBossTakeDamage_OnAmbassadorHeadshot,
OnBossTakeDamage_OnDiamondbackManmelterCrit,
OnBossTakeDamage_OnHolidayPunch,

OnBossSuperJump,
OnBossDoRageStun,
OnBossWeighDown,
OnRPSTaunt,
OnBossAirShotProj,
OnBossTakeFallDamage,
OnBossGiveRage,
OnBossCalcHealth,
OnBossTakeDamage_OnTriggerHurt,
OnBossTakeDamage_OnMantreadsStomp,
OnBossThinkPost,
OnRedPlayerThink,
OnBossEquippedPost,
OnPlayerTakeFallDamage,
OnSoundHook,
OnRoundStart,
OnHelpMenu,
OnHelpMenuSelect,
OnDrawGameTimer,
OnPlayerClimb,
OnBannerDeployed,
OnBannerEffect,
OnUberLoopEnd,
OnRedPlayerThinkPost,
OnRedPlayerHUD,
OnRedPlayerCrits,
OnShowStats,
```

## VSH2HookCB (function typeset)
```c
/**
 * OnBossSelected
 * OnBossThink
 * OnBossModelTimer
 * OnBossDeath
 * OnBossEquipped
 * OnBossEquippedPost -> Action has no effect on this forward.
 * OnBossInitialized
 * OnBossPlayIntro
 * OnBossMedicCall
 * OnBossTaunt
 * OnVariablesReset
 * OnPrepRedTeam
 * OnRedPlayerThink
 * OnLastPlayer - 'player' is a boss.
 * OnBossSuperJump
 * OnBossWeighDown
 * OnBossThinkPost -> Action has no effect on this forward.
 * OnRedPlayerThinkPost -> Action has no effect on this forward.
 */
function Action (VSH2Player player);
function void   (VSH2Player player);

/**
 * OnTouchPlayer - victim is boss, attacker is other player.
 * OnBossJarated
 * OnUberDeployed - Victim is medic, Attacker (Check if valid) is uber target
 * OnUberLoop - Victim is medic, Attacker (Check if valid) is uber target
 * OnRPSTaunt - victim is loser, attacker is winner.
 * OnMinionInitialized - victim is minion, attacker is the owner/master boss.
 * OnLastPlayer - "victim" is a boss, "attacker" is the last fighter/player.
 */
function Action (VSH2Player victim, VSH2Player attacker);
function void   (VSH2Player victim, VSH2Player attacker);

/// OnTouchBuilding
function Action (VSH2Player attacker, int BuildingRef);
function void   (VSH2Player attacker, int BuildingRef);

/// OnBossKillBuilding
function Action (VSH2Player attacker, int building, Event event);
function void   (VSH2Player attacker, int building, Event event);

/** Boss Specific OnTakeDamage hooks
 * OnBossTakeDamage -> use if your boss requires completely custom take damage code.
 * OnBossDealDamage -> use if your boss requires completely custom deal damage code.
 * OnBossDealDamage_OnStomp -> when boss mantread-stomps a player.
 * OnBossDealDamage_OnHitDefBuff -> hit's players buffed with Battalion's Backup banner.
 * OnBossDealDamage_OnHitCritMmmph -> hitting someone under phlog buff.
 * OnBossDealDamage_OnHitMedic -> hitting a medic.
 * OnBossDealDamage_OnHitDeadRinger -> hitting a spy that has Dead Ringer.
 * OnBossDealDamage_OnHitCloakedSpy -> hitting a spy that is cloaked.
 * OnBossDealDamage_OnHitShield -> hitting a player equipped with demoknight shield or razorback.
 *
 * OnBossTakeDamage_OnStabbed -> boss got backstabbed!
 * OnBossTakeDamage_OnTelefragged -> boss got telefragged
 * OnBossTakeDamage_OnSwordTaunt -> boss got hit by a demo sword swing taunt.
 * OnBossTakeDamage_OnHeavyShotgun -> boss got shot by a heavy weapons guy's shotgun.
 * OnBossTakeDamage_OnSniped -> Boss is shot with a sniper rifle.
 * OnBossTakeDamage_OnThirdDegreed -> Boss is hit with third degree pyro melee.
 * OnBossTakeDamage_OnHitSword -> Boss is hit with demo sword that accrues heads.
 * OnBossTakeDamage_OnHitFanOWar -> boss is hit with scout Fan O' War.
 * OnBossTakeDamage_OnHitCandyCane -> boss is hit with scout Candy Cane.
 * OnBossTakeDamage_OnMarketGardened -> boss is hit with market garden in midair.
 * OnBossTakeDamage_OnPowerJack -> boss is hit with power jack.
 * OnBossTakeDamage_OnKatana -> boss is hit with katana.
 * OnBossTakeDamage_OnAmbassadorHeadshot -> boss is headshotted with ambassador spy pistol.
 * OnBossTakeDamage_OnDiamondbackManmelterCrit -> boss is hit with a crit from manmelter or diamondback.
 * OnBossTakeDamage_OnHolidayPunch -> boss is hit with the Holiday Punch HWG melee.
 * OnBossAirShotProj -> when a boss was airshotted by a projectile.
 * OnBossTakeFallDamage
 * OnBossTakeDamage_OnTriggerHurt
 * OnBossTakeDamage_OnMantreadsStomp
 * OnPlayerTakeFallDamage -> when a red takes fall dmg.
 */
function Action (VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom);

/**
 * PlayerKilled
 * PlayerAirblasted - player is the airblaster
 * PlayerHurt
 */
function Action (VSH2Player player, VSH2Player victim, Event event);
function void   (VSH2Player player, VSH2Player victim, Event event);

/// OnTraceAttack
function Action (VSH2Player victim, VSH2Player attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup);
function void   (VSH2Player victim, VSH2Player attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup);

/// OnMessageIntro
function Action (VSH2Player player, char message[MAXMESSAGE]);
function void   (VSH2Player player, char message[MAXMESSAGE]);

/**
 * BossHealthCheck - bossBool determines if command user was the boss
 * RoundEndInfo - bossBool determines if boss won the round
 */
function Action (VSH2Player player, bool bossBool, char message[MAXMESSAGE]);
function void   (VSH2Player player, bool bossBool, char message[MAXMESSAGE]);

/// OnMusic
function Action (char song[PLATFORM_MAX_PATH], float& time, VSH2Player player);
function void   (char song[PLATFORM_MAX_PATH], float& time, VSH2Player player);
function Action (char song[PLATFORM_MAX_PATH], float& time, VSH2Player player, float& volume);
function void   (char song[PLATFORM_MAX_PATH], float& time, VSH2Player player, float& volume);

/// OnControlPointCapped
function Action (char cappers[MAXPLAYERS+1], int team);
function void   (char cappers[MAXPLAYERS+1], int team);
function Action (char cappers[MAXPLAYERS+1], int team, VSH2Player[] cappers, int capper_count);
function void   (char cappers[MAXPLAYERS+1], int team, VSH2Player[] cappers, int capper_count);

/// OnCallDownloads
function Action ();
function void   ();

/// OnBossPickUpItem -> player may or may not actually be a boss in this forward.
function Action (VSH2Player player, const char item[64]);
function void   (VSH2Player player, const char item[64]);

/// OnBossMenu
function void   (Menu& menu);
function void   (Menu& menu, VSH2Player player);

/// OnScoreTally
function Action (VSH2Player player, int& points_earned, int& queue_earned);
function void   (VSH2Player player, int& points_earned, int& queue_earned);

/// OnItemOverride
function Action (VSH2Player player, const char[] classname, int itemdef, Handle& item);
function void   (VSH2Player player, const char[] classname, int itemdef, Handle& item);
function Action (VSH2Player player, const char[] classname, int itemdef, TF2Item& item);
function void   (VSH2Player player, const char[] classname, int itemdef, TF2Item& item);

/// OnBossDoRageStun
function Action (VSH2Player player, float& distance);
function void   (VSH2Player player, float& distance);

/// OnBossGiveRage
function Action (VSH2Player player, int damage, float& calcd_rage);
function void   (VSH2Player player, int damage, float& calcd_rage);

/// OnBossCalcHealth
/// It's preferred that you use/modify the 'iMaxHealth' property instead.
function Action (VSH2Player player, int& max_health, int boss_count, int red_players);
function void   (VSH2Player player, int& max_health, int boss_count, int red_players);

/// OnSoundHook
function Action (VSH2Player player, char sample[PLATFORM_MAX_PATH], int& channel, float& volume, int& level, int& pitch, int& flags);
function void   (VSH2Player player, char sample[PLATFORM_MAX_PATH], int& channel, float& volume, int& level, int& pitch, int& flags);

/// OnRoundStart
function void   (VSH2Player[] bosses, int boss_count, VSH2Player[] red_players, int red_count);

/// OnHelpMenu
function void   (VSH2Player player, Menu menu);

/// OnHelpMenuSelect
function void   (VSH2Player player, Menu menu, int selection);

/// OnDrawGameTimer
function Action (int& seconds);
function void   (int& seconds);

/// OnPlayerClimb
function Action (VSH2Player player, int weapon, float& upwardvel, float& health, bool& attackdelay);
function void   (VSH2Player player, int weapon, float& upwardvel, float& health, bool& attackdelay);

/// OnBossConditionChange
function Action (VSH2Player player, const TFCond cond, bool removing);

/// OnBannerDeployed
/// 'owner' is the owner of the banner.
/// Returning other than `Plugin_Continue` has no effect
/// except preventing boss modules from getting this event.
function Action (VSH2Player owner, const BannerType banner);

/// OnBannerEffect
/// 'owner' is the owner of the banner.
/// 'player' is buffed by the banner.
/// Returning other than `Plugin_Continue` has no effect
/// except preventing boss modules from getting this event.
function Action (VSH2Player player, VSH2Player owner, const BannerType banner);

/// OnUberLoopEnd
/// target can be invalid so be careful.
function Action (VSH2Player medic, VSH2Player target, float& reset_charge);

/// OnRedPlayerHUD
function Action (VSH2Player player, char hud_text[PLAYER_HUD_SIZE]);
function void   (VSH2Player player, char hud_text[PLAYER_HUD_SIZE]);

/// OnRedPlayerCrits
function Action (VSH2Player player, int& crit_flags);
function void   (VSH2Player player, int& crit_flags);

/// OnShowStats
function Action (VSH2Player top_players[3]);
function void   (VSH2Player top_players[3]);
```

## VSH2 Hook Natives
```c
native void VSH2_Hook(int callbacktype, VSH2HookCB callback);
native bool VSH2_HookEx(int callbacktype, VSH2HookCB callback);

native void VSH2_Unhook(int callbacktype, VSH2HookCB callback);
native bool VSH2_UnhookEx(int callbacktype, VSH2HookCB callback);
```
- self explanatory hook and unhook natives. `callbacktype` is the VSH2 Hook Type enum value. `callback` is the name of a function that uses the required VSH2HookCB function prototype typesets above.

## VSH2 Stock/Helper Functions

### VSH2 Boss Asset & Code Helpers
```c
void CheckDownload(const char[] dlpath);
void PrepareSound(const char[] sound_path);
void DownloadSoundList(const char[][] file_list, int size);
void PrecacheSoundList(const char[][] file_list, int size);
void PrepareMaterial(const char[] matpath);
void DownloadMaterialList(const char[][] file_list, int size);
int  PrepareModel(const char[] model_path, bool model_only = false);
bool IsStockSound(char sample[PLATFORM_MAX_PATH]);
bool IsVoiceLine(char sample[PLATFORM_MAX_PATH]);
int  ShuffleIndex(int size, int curr_index);

/// packs an integer into a string buffer.
void PackItem(any key, char buffer[6]);
stock char[] PackCellToStr(any key);

/// Runs a function after a certain amount of time has elapsed with any amount of arguments.
void MakePawnTimer(Function func, float thinktime=0.1, const any[] args, int len, bool as_array=false);

/// useful for cooldowns & stuff that happens in a certain period of time.
bool IsPastSavedTime(float last_time);
bool IsWithinGoalTime(float goal_time);
void UpdateSavedTime(float& last_time, float delta=1.0);

bool IsIntInBounds(int val, int max, int min);
int  IntClamp(int val, int max, int min);

/**
 * Helper for preparing resources that are defined from a ConfigMap.
 * 
 * @param sect:       ConfigMap of the section for the materials.
 * @param resrc_type: enum value marking what type of resource we're preparing.
 * @noreturn
 * @note
 *
 * the structure of the section must use "<enum>" keys.
 * example:
 * "sound section" {
 *     "<enum>"   "sound1.mp3"
 *     ...
 *     "<enum>"   "soundN.mp3"
 * }
 * "material section" {
 *     "<enum>"   "skinRed"
 *     ...
 *     "<enum>"   "skinBlu"
 * }
 */
stock void PrepareAssetsFromCfgMap(ConfigMap sect, int resrc_type);
```
