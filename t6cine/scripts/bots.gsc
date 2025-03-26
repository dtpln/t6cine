/*
 *      T6Cine
 *      Bots functions
 */


#include common_scripts\utility;
#include scripts\utils;
#include maps\mp\_utility;
#include maps\mp\gametypes\_class;
#include maps\mp\teams\_teams;


add( args )
{
    weapon  = args[0];
    team    = args[1];
    camo    = args[2];
    model   = args[3];

    ent = addTestClient();
    ent persistence();
    ent spawnme(self, weapon, team, camo );

    create_kill_params();
}

persistence()
{
    self.pers["isBot"]      = true;     // is bot
    self.pers["isStaring"]  = false;    // is in "staring mode"
    self.pers["fakeModel"]  = false;    // has the bot's model been changed?
}

spawnme( owner, weapon, team, camo )
{
    while ( !isdefined( self.pers["team"] ) ) skipframe();

    weapon = legacy_classnames( weapon );
    if( !isDefined( weapon ) )
            weapon = "an94_mp";

  if ( isdefined( team ) && ( team == "allies" || team == "axis" ) ) 
        self notify( "menuresponse", game["menu_team"], team );
    else {
        self notify( "menuresponse", game["menu_team"], level.otherTeam[level.players[0].team] );
        camo = team;
    }

    if ( !isdefined( camo ) ) //|| !isValidCamo( camo ) )
        camo = 0;

    skipframe();

    self notify( "menuresponse", "changeclass", "custom0" );

    loadout = create_loadout( weapon, camo );
    self thread create_spawn_thread( scripts\bots::give_loadout_on_spawn, loadout );
    self thread create_spawn_thread( scripts\bots::attach_weapons, loadout );

    self waittill( "spawned_player" );
    self setOrigin( at_crosshair( owner ) );
    self setPlayerAngles( owner.angles + ( 0, 180, 0 ) );

    self save_spawn();
    self thread create_spawn_thread( scripts\utils::load_spawn );
    self thread create_spawn_thread( scripts\misc::reset_models );
    self scripts\player::playerRegenAmmo();

    if( level.BOT_SPAWNCLEAR )
        self thread create_spawn_thread( scripts\misc::clear_bodies );
    
    self freezeControls( level.BOT_FREEZE );
    self clearPerks();
}

// Move a bot
move( args )
{
    name = args[0];
    foreach( player in level.players )
    {
        if( issubstr( player.name, args[0] ) ) 
        {
            player setOrigin( at_crosshair( self ) );
            player save_spawn();
            player freezeControls( level.BOT_FREEZE );
        }
    }
}

aim( args )
{
    name = args[0];
    foreach( player in level.players )
    {
        if( issubstr( player.name, args[0] ) )
        {
            player thread doaim();
            wait 0.5;
            player notify( "stopaim" );
        }
    }
}

stare( args )
{
    name = args[0];
    foreach( player in level.players )
    {
        if( issubstr( player.name, args[0] ) )
        {
            player.pers["isStaring"] ^= 1;
            if ( player.pers["isStaring"] ) player thread doaim();
            else player notify( "stopaim" );
        }
    }
}

model( args )
{
    name  = args[0];
    model = args[1];
    team  = args[2];

    model = legacy_modelnames( model );

    foreach( player in level.players )
    {
        if( issubstr( player.name, args[0] ) )
        {
            player.pers["fakeTeam"]  = team;
            player.pers["fakeModel"] = model;

            player detachAll();
            skipframe();
            player[[ game["set_player_model"][team][model] ]]();

            if( isdefined ( player.pers["viewmodel"] ) )
                player setViewmodel( player.pers["viewmodel"] );
        }
    }
}

doaim()
{
    self endon( "disconnect" );
    self endon( "stopaim" );

    for ( ;; )
    {
        wait .05;
        target = undefined;

        foreach( player in level.players )
        {
            if ( ( player == self ) || ( level.teamBased && self.pers["team"] == player.pers["team"] ) || ( !isAlive( player) ) )
                continue;

            if ( isDefined( target ) ) 
            {
                if ( closer ( self getTagOrigin( "j_head" ), player getTagOrigin( "j_head" ), target getTagOrigin( "j_head" ) ) )
                    target = player;
            }
            else target = player;
        }

        if ( isDefined( target ) )
            self setPlayerAngles( VectorToAngles( ( target getTagOrigin( "j_head" ) ) - ( self getTagOrigin( "j_head" ) ) ) );
    }
}

killBot( args )
{
    name = args[0];
    mode = args[1];
    foreach( player in level.players )
    {
        if( issubstr( player.name, args[0] ) )
        {
            parameters  = strTok( level.killparams[mode], ":" );
            fx          = parameters[0];
            tag         = player getTagOrigin( parameters[1] );
            hitloc      = parameters[2];

            playFXOnTag( getFX( fx ), self, tag );
            player thread [[level.callbackPlayerDamage]]( player, player, 2147483600, 8, "MOD_RIFLE_BULLET", self getCurrentWeapon(), tag, tag, hitloc, 0, 0 ); 
        }
    }
}

delay( args )
{
    setDvar( "scr_killcam_time",      level.BOT_SPAWN_DELAY/2 );
    setDvar( "scr_killcam_posttime",  level.BOT_SPAWN_DELAY/2 );
}

create_loadout( weapon, camo )
{
    loadout         = spawnstruct();
    loadout.primary = weapon;
    loadout.camo    = camo;
    return loadout;
}

attach_weapons( loadout )
{
    wait .1; // take the wait from misc\reset_models() into account
    if ( level.BOT_WEAPHOLD && self is_bot() )
    {
        self.replica = getWeaponModel( loadout.primary, camo_int( loadout.camo ) );
        self attach( self.replica, "tag_weapon_right", true );
    }
}

// Change bot weapon
weapon( args )
{
    name    = args[0];
    weapon  = args[1];
    camo    = args[2]; // Camo name, reference function camo_int.

    foreach( player in level.players )
    {
        if( issubstr( player.name, args[0] ) )
        {
            player create_loadout( weapon, camo );
            self dropItem( self getCurrentWeapon() );
            player giveWeapon( weapon, is_akimbo( weapon ), camo_int( camo ) );
            player setSpawnWeapon( weapon );
            wait 1;

            player thread attach_weapons();
        }
    }
}

create_kill_params()
{
    level.killparams                = [];
    level.killparams["body"]        = "flesh_body:body:pelvis";
    level.killparams["head"]        = "flesh_body:head:head";
    level.killparams["shotgun"]     = "flesh_body:j_knee_ri:body";
    level.killparams["butterfly"]   = "fx_insects_butterfly_flutter:body:torso";
}

give_loadout_on_spawn( loadout )
{
    self takeAllWeapons();
    self giveWeapon( loadout.primary, is_akimbo( loadout.primary ), camo_int( loadout.camo ) );
    self setSpawnWeapon( loadout.primary );
    self detachAll();
    self maps\mp\teams\_teams::set_player_model( self.team, loadout.primary );
}