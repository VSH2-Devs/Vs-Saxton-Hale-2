
#include "modules/base.sp"	/* DO NOT DELETE/MODIFY THIS LINE */

#include "modules/gamemode.sp"
VSHGameMode gamemode;
/* VSHGameMode Singleton that controls the game state of the mod
Had to place it here because methodmaps can't be forward declared (yet) and neither can methodmap properties
*/

#include "modules/bosses/hale.sp"
#include "modules/bosses/vagineer.sp"
#include "modules/bosses/cbs.sp"
#include "modules/bosses/hhh.sp"
#include "modules/bosses/bunny.sp"
#include "modules/bosses/plague.sp"

