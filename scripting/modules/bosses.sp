
#include "base.sp"	/* DO NOT DELETE/MODIFY THIS LINE */

#include "gamemode.sp"
VSHGameMode gamemode;
/* VSHGameMode Singleton that controls the game state of the mod
Had to place it here because methodmaps can't be forward declared (yet) and neither can methodmap properties
*/

#include "hale.sp"
#include "vagineer.sp"
#include "cbs.sp"
#include "hhh.sp"
#include "bunny.sp"
#include "plague.sp"	// Example of how to do bosses that use minions
