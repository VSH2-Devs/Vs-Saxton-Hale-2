
void NoPackPickup_OnItemSpawn(int entity)
{
	SDKHook(entity, SDKHook_StartTouch, NoPackPickup_OnItemTouch);
	SDKHook(entity, SDKHook_Touch, 		NoPackPickup_OnItemTouch);
}

static Action NoPackPickup_OnItemTouch(int entity, int client)
{
	if( 0 < client <= MaxClients && IsClientInGame(client) ) {
		FF2Player player = FF2Player(client);
		char classname[16];
		GetEntityClassname(entity, classname, sizeof(classname));
		if( StrContains(classname, "health") != -1 ) {
			if( player.GetPropAny("bNoHealthPacks") )
				return Plugin_Handled;
		}
		else if( StrContains(classname, "ammo") != -1 ) {
			if( player.GetPropAny("bNoAmmoPacks") )
				return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}