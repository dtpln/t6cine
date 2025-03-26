/*
 *      T6Cine
 *      Player-related functions
 */

#include scripts\utils;

// Ammo Regen
playerRegenAmmo()
{
    if( !level.PLAYER_AMMO ) return;

    self thread regenAmmo();
    self thread regenEquip();
}

regenAmmo()
{
    self endon( "disconnect" );
    for ( ;; )
    {
        self notifyOnPlayerCommand( "reload", "+reload" );
        self waittill( "reload" );
        wait 2;

        self giveMaxAmmo( self getCurrentWeapon() );
    }
}

regenEquip()
{
    self endon( "disconnect" );
    for ( ;; )
    {
        self waittill( "grenade_fire", grenade, name );
        waittillframeend;

        self setWeaponAmmoClip( name, 1 );
        self GiveMaxAmmo( name );
    }
}

// Movement Tweaks
movementTweaks()
{
    if( !level.PLAYER_MOVEMENT ) return;

    setDvar( "jump_slowdownEnable", "0" );
    setDvar( "scr_giveperk", "specialty_falldamage" );
    setDvar( "scr_giveperk", "specialty_marathon" ); // Marathon
}