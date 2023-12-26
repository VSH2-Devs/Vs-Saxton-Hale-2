#if defined _goomba_included_
  #endinput
#endif
#define _goomba_included_

public SharedPlugin:__pl_goomba =
{
	name = "goomba",
	file = "goomba.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

public __pl_goomba_SetNTVOptional()
{
    MarkNativeAsOptional("GoombaStomp");
    MarkNativeAsOptional("CheckStompImmunity");
    MarkNativeAsOptional("PlayStompSound");
    MarkNativeAsOptional("PlayStompReboundSound");
    MarkNativeAsOptional("EmitStompParticles");
}

/**
 * @brief Called right before the stomp
 *
 * @param attacker          Player doing the stomp
 * @param victim            Player being stomped
 * @param damageMultiplier  Damage multiplier based on the actual victim's life
 * @param damageBonus       Damage bonus
 * @param JumpPower         Rebound jump power
 * @return                  Plugin_Handled to block the stomp, Plugin_Changed to modify the damage
 */
forward Action:OnStomp(attacker, victim, &Float:damageMultiplier, &Float:damageBonus, &Float:JumpPower);

/**
 * @brief Called after the stomp if it was successful
 *
 * @param attacker          Player doing the stomp
 * @param victim            Player being stomped
 * @param damageMultiplier  Damage multiplier based on the actual victim's life
 * @param damageBonus       Damage bonus
 * @param JumpPower         Rebound jump power
 * @noreturn
 */
forward OnStompPost(attacker, victim, Float:damageMultiplier, Float:damageBonus, Float:jumpPower);

/**
 * @brief Stomp 
 *
 * @param attacker              Player doing the stomp
 * @param victim                Player being stomped
 * @param    damageMultiplier   Damage inflicted based on the victim's health (default: goomba_dmg_lifemultiplier)
 * @param    damageBonus        Damage bonus after damageMultiplier calculation (default: goomba_dmg_add)
 * @param    jumpPower          Jump power of the rebound (default: goomba_rebound_power)
 * @return                      True if the stomp was successful, false otherwise.
 */
native bool:GoombaStomp(attacker, victim, ...);

/**
 * @param attacker          Player doing the stomp
 * @param victim            Player being stomped
 * @return                  Bit flags combination based on the attacker and victim's immunity preferences
 */
native CheckStompImmunity(attacker, victim);

/**
 * @brief Play the stomped sound to the specified client
 *
 * @param client            Client to play the stomped sound to.
 * @noreturn
 */
native PlayStompSound(client);

/**
 * @brief Play the rebound sound from the specified client to everyone
 *
 * @param client            Player to play the rebound sound from.
 * @noreturn
 */
native PlayStompReboundSound(client);

/**
 * @brief Attach the rebound particles on the specified player
 *
 * @param client            Player to attach the particles on
 * @noreturn
 */
native EmitStompParticles(client);

#define GOOMBA_IMMUNFLAG_NONE           0
#define GOOMBA_IMMUNFLAG_ATTACKER       (1 << 0)
#define GOOMBA_IMMUNFLAG_VICTIM         (1 << 1