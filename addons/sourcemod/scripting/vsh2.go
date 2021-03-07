/**
 * vsh2.go
 * 
 * Copyright 2020 Nirari Technologies, Alliedmodders LLC.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 */

package main

import (
	"sourcemod"
	"tf2_stocks"
)

const (
	MAXMESSAGE =            512
	MAX_PANEL_MSG =         512
	MAX_BOSS_NAME_SIZE =    64
	
	/** VSH2 Round States */
	StateDisabled = -1
	StateStarting = 0
	StateRunning  = 1
	StateEnding   = 2
	
	/** VSH2 Teams */
	VSH2Team_Unassigned = 0
	VSH2Team_Neutral    = 0
	VSH2Team_Spectator  = 1
	VSH2Team_Red        = 2
	VSH2Team_Boss       = 3
	
	/** VSH2 Default Bosses */
	VSH2Boss_Hale        = 0
	VSH2Boss_Vagineer    = 1
	VSH2Boss_CBS         = 2
	VSH2Boss_HHHjr       = 3
	VSH2Boss_Bunny       = 4
	MaxDefaultVSH2Bosses = 5
	
	/** Voice Clip Flags */
	VSH2_VOICE_BOSSENT = 1  /// use boss as entity to emit from.
	VSH2_VOICE_BOSSPOS = 2  /// use boss position for sound origin.
	VSH2_VOICE_TOALL   = 4  /// sound replay to each individual player.
	VSH2_VOICE_ALLCHAN = 8  /// if sound replay should use auto sound channel.
	VSH2_VOICE_ONCE    = 16 /// play a clip once to all. (does not cancel out 'VSH2_VOICE_TOALL')

	VSH2_VOICE_ALL =     (VSH2_VOICE_BOSSENT|VSH2_VOICE_BOSSPOS|VSH2_VOICE_TOALL|VSH2_VOICE_ALLCHAN|VSH2_VOICE_ONCE)

	/// For when boss does something like a superjump, etc.
	VSH2_VOICE_ABILITY = (VSH2_VOICE_BOSSENT|VSH2_VOICE_BOSSPOS|VSH2_VOICE_TOALL)

	/// For when boss does something like rage or special ability.
	VSH2_VOICE_RAGE =    (VSH2_VOICE_BOSSENT|VSH2_VOICE_BOSSPOS|VSH2_VOICE_TOALL|VSH2_VOICE_ALLCHAN)

	/// For when boss gets stabbed or goes on a killing spree.
	VSH2_VOICE_SPREE =   (0)
	VSH2_VOICE_STABBED = VSH2_VOICE_SPREE

	/// For when boss loses, wins, or introduces themselves like the mentlegen they are.
	VSH2_VOICE_WIN =     (VSH2_VOICE_ONCE|VSH2_VOICE_ALLCHAN)
	VSH2_VOICE_LOSE =    VSH2_VOICE_WIN
	VSH2_VOICE_INTRO =   VSH2_VOICE_WIN
	
	/// For when there's only one target left!
	VSH2_VOICE_LASTGUY = (VSH2_VOICE_BOSSPOS)
	
	PlayerHUD   = 0
	TimeLeftHUD = 1
	HealthHUD   = 2
	MaxVSH2HUDs = 3

	BannerBuff     = 1
	BannerDefBuff  = 2
	BannerHealBuff = 3
)


type (
	VSH2Player struct {
		userid, index, iHealth int
		hOwnerBoss, hUberTarget *VSH2Player
		bIsBoss, bIsMinion bool
	}
	PropName = [64]char
	BossName = [MAX_BOSS_NAME_SIZE]char
	BannerType int
)

func (VSH2Player) GetPropInt(name PropName) int
func (VSH2Player) GetPropFloat(name PropName) float
func (VSH2Player) GetPropAny(name PropName) any

func (VSH2Player) SetPropInt(name PropName, value int) bool
func (VSH2Player) SetPropFloat(name PropName, value float) bool
func (VSH2Player) SetPropAny(name PropName, value any) bool

func (VSH2Player) ConvertToMinion(spawntime float)
func (VSH2Player) SpawnWeapon(name string, index, level, qual int, att string) Entity
func (VSH2Player) GetWeaponSlotIndex(slot int) int
func (VSH2Player) SetWepInvis(alpha int)
func (VSH2Player) SetOverlay(overlay string)
func (VSH2Player) TeleToSpawn(team int) bool
func (VSH2Player) IncreaseHeadCount()
func (VSH2Player) SpawnSmallHealthPack(owner_team int)
func (VSH2Player) ForceTeamChange(team int)
func (VSH2Player) ClimbWall(weapon Entity, upwardVel, health float, attackdelay bool) bool
func (VSH2Player) HelpPanelClass()

func (VSH2Player) GetAmmoTable(wepslot int) int
func (VSH2Player) SetAmmoTable(wepslot, amount int)
func (VSH2Player) GetClipTable(wepslot int) int
func (VSH2Player) SetClipTable(wepslot, amount int)

func (VSH2Player) GetHealTarget() Entity
func (VSH2Player) GetHealPatient() VSH2Player
func (VSH2Player) IsNearDispenser() bool
func (VSH2Player) IsInRange(target Entity, dist float, trace bool) bool
func (VSH2Player) IsPlayerInRange(target VSH2Player, dist float, trace bool) bool
func (VSH2Player) GetPlayersInRange(players *[]VSH2Player, dist float, trace bool) int

func (VSH2Player) RemoveBack(indices []int, size int)
func (VSH2Player) FindBack(indices []int, size int) Entity
func (VSH2Player) ShootRocket(crit bool, position, angles Vec3, speed, dmg float, model string, arc bool) Entity
func (VSH2Player) Heal(health int, on_hud bool)
func (VSH2Player) GetTFClass() TFClassType
func (VSH2Player) AddTempAttrib(attrib int, val, dur float) bool

func (VSH2Player) ConvertToBoss()
func (VSH2Player) GiveRage(damage int)
func (VSH2Player) MakeBossAndSwitch(boss_type int, callEvent bool)
func (VSH2Player) DoGenericStun(dist float)
func (VSH2Player) StunPlayers(dist, stun_time float)
func (VSH2Player) StunBuildings(dist, stun_time float)
func (VSH2Player) RemoveAllItems(weapons bool)

func (VSH2Player) GetName(buffer BossName) bool
func (VSH2Player) SetName(buffer BossName) bool
func (VSH2Player) SuperJump(power, reset float)
func (VSH2Player) WeighDown(reset float)
func (VSH2Player) PlayVoiceClip(voiceclip string, flags int)
func (VSH2Player) PlayMusic(vol float, override string)
func (VSH2Player) StopMusic()

func (VSH2Player) SpeedThink(amnt, minspeed float)
func (VSH2Player) GlowThink(decrease float)
func (VSH2Player) SuperJumpThink(charging, jump_charge float) bool
func (VSH2Player) WeighDownThink(weighdown_time, increment float)


func VSH2_RegisterPlugin(plugin_name [64]char) int


type (
	VSH2HookType int
	VSH2HookCB   interface{}
)
const (
	OnCallDownloads = VSH2HookType(0)
	OnBossSelected
	OnTouchPlayer
	OnTouchBuilding
	OnBossThink
	OnBossModelTimer
	OnBossDeath
	OnBossEquipped
	OnBossInitialized
	OnMinionInitialized
	OnBossPlayIntro
	OnBossTakeDamage
	OnBossDealDamage
	OnPlayerKilled
	OnPlayerAirblasted
	OnTraceAttack
	OnBossMedicCall
	OnBossTaunt
	OnBossKillBuilding
	OnBossJarated
	OnMessageIntro
	OnBossPickUpItem
	OnVariablesReset
	OnUberDeployed
	OnUberLoop
	OnMusic
	OnRoundEndInfo
	OnLastPlayer
	OnBossHealthCheck
	OnControlPointCapped
	OnBossMenu
	OnPrepRedTeam
	OnPlayerHurt
	OnScoreTally
	OnItemOverride
	OnBossDealDamage_OnStomp
	OnBossDealDamage_OnHitDefBuff
	OnBossDealDamage_OnHitCritMmmph
	OnBossDealDamage_OnHitMedic
	OnBossDealDamage_OnHitDeadRinger
	OnBossDealDamage_OnHitCloakedSpy
	OnBossDealDamage_OnHitShield
	
	OnBossTakeDamage_OnStabbed
	OnBossTakeDamage_OnTelefragged
	OnBossTakeDamage_OnSwordTaunt
	OnBossTakeDamage_OnHeavyShotgun
	OnBossTakeDamage_OnSniped
	OnBossTakeDamage_OnThirdDegreed
	OnBossTakeDamage_OnHitSword
	OnBossTakeDamage_OnHitFanOWar
	OnBossTakeDamage_OnHitCandyCane
	OnBossTakeDamage_OnMarketGardened
	OnBossTakeDamage_OnPowerJack
	OnBossTakeDamage_OnKatana
	OnBossTakeDamage_OnAmbassadorHeadshot
	OnBossTakeDamage_OnDiamondbackManmelterCrit
	OnBossTakeDamage_OnHolidayPunch
	
	OnBossSuperJump
	OnBossDoRageStun
	OnBossWeighDown
	OnRPSTaunt
	OnBossAirShotProj
	OnBossTakeFallDamage
	OnBossGiveRage
	OnBossCalcHealth
	OnBossTakeDamage_OnTriggerHurt
	OnBossTakeDamage_OnMantreadsStomp
	OnBossThinkPost
	OnRedPlayerThink
	OnBossEquippedPost
	OnPlayerTakeFallDamage
	OnSoundHook
	OnRoundStart
	OnHelpMenu
	OnHelpMenuSelect
	OnDrawGameTimer
	OnPlayerClimb
	OnBossConditionChange
	OnBannerDeployed
	OnBannerEffect
	OnUberLoopEnd
	MaxVSH2Forwards
)

func VSH2_Hook(callbacktype VSH2HookType, callback VSH2HookCB)
func VSH2_Unhook(callbacktype VSH2HookType, callback VSH2HookCB)
func VSH2_HookEx(callbacktype VSH2HookType, callback VSH2HookCB) bool
func VSH2_UnhookEx(callbacktype VSH2HookType, callback VSH2HookCB) bool

func VSH2_GetMaxBosses() int
func VSH2_GetRandomBossType(boss_filter []int, filter_size int) int
func VSH2_GetBossIDs(registered_only bool) StringMap
func VSH2_GetBossID(name BossName) int
func VSH2_StopMusic(reset_time bool)


type VSHHealthBar struct {
	entity Entity
	iState, iPercent int
}

func (VSHHealthBar) SetHealthPercent(total_health, total_max_health int)


func VSH2GameMode_GetPropInt(name PropName) int
func VSH2GameMode_GetPropFloat(name PropName) float
func VSH2GameMode_GetPropAny(name PropName) any

func VSH2GameMode_SetPropInt(name PropName, value int)
func VSH2GameMode_SetPropFloat(name PropName, value float)
func VSH2GameMode_SetPropAny(name PropName, value any)

func VSH2GameMode_FindNextBoss() VSH2Player
func VSH2GameMode_GetRandomBoss(alive bool) VSH2Player
func VSH2GameMode_GetBossByType(alive bool, boss_type int) VSH2Player

func VSH2GameMode_CountMinions(alive bool) int
func VSH2GameMode_CountBosses(alive bool) int
func VSH2GameMode_GetTotalBossHealth() int
func VSH2GameMode_GetTotalRedPlayers() int
func VSH2GameMode_GetBosses(bosses *[]VSH2Player, alive bool) int
func VSH2GameMode_GetFighters(fighters *[]VSH2Player, alive bool) int
func VSH2GameMode_GetMinions(minions *[]VSH2Player, alive bool) int
func VSH2GameMode_GetBossesByType(bosses *[]VSH2Player, boss_type int, alive bool) int
func VSH2GameMode_GetQueue(players *[]VSH2Player) int

func VSH2GameMode_SearchForItemPacks()
func VSH2GameMode_UpdateBossHealth()
func VSH2GameMode_GetBossType()
func VSH2GameMode_GetHUDHandle(HUD_type int) Handle
func VSH2GameMode_IsVSHMap() bool


type VSH2GameMode struct {
	hNextBoss VSH2Player
	iTotalBossHealth, iLivingReds int
	hHUD Handle
	hHealthBar VSHHealthBar
}


func CheckDownload(file string)
func PrepareSound(sound_path string)
func DownloadSoundList(file_list []string, size int)
func PrecacheSoundList(file_list []string, size int)
func PrecacheScriptList(file_list []string, size int)
func PrepareMaterial(matpath string)
func DownloadMaterialList(file_list []string, size int)
func PrepareModel(model_path string, model_only bool) int
func IsStockSound(sample PathStr) bool
func IsVoiceLine(sample PathStr) bool
func ShuffleIndex(size, curr_index int) int
func MakePawnTimer(fn Function, thinktime float, args []any, len int, as_array bool)
func IsPastSavedTime(last_time float) bool
func IsWithinGoalTime(goal_time float) bool
func UpdateSavedTime(last_time *float, delta float)