
#include "base.sp"	/* DO NOT DELETE/MODIFY THIS LINE */

#include "gamemode.sp"
VSHGameMode gamemode;
/* VSHGameMode Singleton that controls the game state of the mod
Had to place it here because methodmaps can't be forward declared (yet) and neither can methodmap properties
*/

#include "bosses/hale.sp"
#include "bosses/vagineer.sp"
#include "bosses/cbs.sp"
#include "bosses/hhh.sp"
#include "bosses/bunny.sp"
#include "bosses/plague.sp"
