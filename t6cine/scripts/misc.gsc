/*
 *      T6Cine
 *      Miscellaneous functions
 */

#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\utils;
#include maps\mp\gametypes\_class;


// Actions
clone()
{ 
    self ClonePlayer( 1 );
}

drop()
{
    self endon( "disconnect" );
    self endon( "death" );
    self dropItem( self getCurrentWeapon() );
}

clear_bodies()
{
    for ( i = 0; i < 15; i++ )
    {
        clone = self ClonePlayer( 1 );
        clone delete();
        skipframe();
    }
}

expl_bullets()
{
    for( ;; )
    {
        self waittill( "weapon_fired" );
        if( GetDvarInt( "eb_explosive" ) > 0 ) RadiusDamage( at_crosshair( self ), GetDvarInt( "eb_explosive" ), 800, 800, self );
    }
}

magc_bullets()
{
    for( ;; )
    {
        self waittill( "weapon_fired" );
        foreach ( player in level.players )
        {
            if ( inside_fov( self, player, GetDvarInt( "eb_magic" ) ) && player != self )
                player thread [[level.callbackPlayerDamage]]( self, self, self.health, 8, "MOD_RIFLE_BULLET", self getCurrentWeapon(), ( 0, 0, 0 ), ( 0, 0, 0 ), "torso_upper", 0 );
        }
        foreach ( actor in level.actors )
        {
            if ( inside_fov( self, actor["hitbox"], GetDvarInt( "eb_magic" ) ) )
                actor["hitbox"] notify( "damage", actor["hitbox"].health, self );
        }
    }
}

viewhands( args )
{
    vh = args[0];
    self iPrintLn( "[" + level.HIGHLIGHT_COLOR + "T6Cine^7] Setting viewmodel to: " + level.COMMAND_COLOR + vh );
    self setViewmodel( vh );
    self.pers["viewmodel"] = vh;
}

reset_models()
{
    if( isdefined ( self.pers["fakeModel"] ) && self.pers["fakeModel"] != false ) 
    {
        skipframe();
        self detachAll();
        self [[game[self.pers["fakeTeam"] + "_model"][self.pers["fakeModel"]]]]();
    }

    if( isdefined ( self.pers["viewmodel"] ) )
        self setViewmodel( self.pers["viewmodel"] );
}


// Toggles
toggle_holding()
{
    level.BOT_WEAPHOLD ^= 1;
    self iPrintLn( "[" + level.HIGHLIGHT_COLOR + "T6Cine^7] Holding weapons on death: " + level.COMMAND_COLOR + bool( level.BOT_WEAPHOLD ) );

    if( !level.BOT_WEAPHOLD ) 
    {
        foreach( player in level.players )
            player.replica delete();
    }
}

toggle_freeze()
{
    level.BOT_FREEZE ^= 1;
    for ( i = 0; i < level.players.size; i++ )
    {
        if ( i == 0 )
        {
            continue;
        }
        player = level.players[i];
        player freezeControls( level.BOT_FREEZE );
    }
    self iPrintLn( "[" + level.HIGHLIGHT_COLOR + "T6Cine^7] Frozen bots: " + level.COMMAND_COLOR + bool( level.BOT_FREEZE ) );
}


// Spawners
spawn_model( args )
{
    model = args[0];
    anima = args[1];
    prop = spawn( "script_model", self.origin );
    prop.angles = ( 0, self.angles[1], 0 );
    prop setModel( model );

    //if( isDefined( anima ) )
        //prop scriptModelPlayAnim(anima);

    self iPrintLn( "[" + level.HIGHLIGHT_COLOR + "T6Cine^7] Spawned model: " + level.COMMAND_COLOR + model );
}

spawn_fx( args )
{
    fx = args[0];
    level._effect[fx] = loadfx( fx );
    playFX( level._effect[fx], at_crosshair( self ) );

    self iPrintLn( "[" + level.HIGHLIGHT_COLOR + "T6Cine^7] Spawned fx : " + level.COMMAND_COLOR + fx );
}


// Fog and Vision
change_vision( args )
{
    vision = args[0];
    VisionSetNaked( vision );
    self iPrintLn( "[" + level.HIGHLIGHT_COLOR + "T6Cine^7] Vision changed to: " + level.COMMAND_COLOR + vision );
}

change_fog( args )
{
    start       = int( args[0] );
    end         = int( args[1] );
    red         = int( args[2] );
    green       = int( args[3] );
    blue        = int( args[4] );
    opacity     = int( args[5] );
    setExpFog( 0, 0, 0, 0, 0, 0 );
    waitframe();
    setExpFog( start, end, red, green, blue, opacity );
}


// Text and Messages
welcome()
{
    wait 2;
    self IPrintLn( "Welcome to ^3Sass' Cinematic Mod" );
    self IPrintLn( "Ported to BO2 by ^3Forgive" );
	self IPrintLn( "Type ^3/about 1 ^7for more info" );
    self.isdone = true;
}

about()
{
    self giveWeapon( "briefcase_bomb_defuse_mp" );
	self SwitchToWeapon( "briefcase_bomb_defuse_mp" );
    while( self getCurrentWeapon() != "briefcase_bomb_defuse_mp" )
        waitframe();

    wait 0.55;
    setDvar( "scr_gameEnded", 1 );
    self setBlur( 15, 0.5 );
    VisionSetNaked( "mpintro", 0.4 );

    text = [];
    text[0] = elem( -50, 2,   "default",    "^3Sass' Cinematic Mod", 40 );
    text[1] = elem( -33, 1,   "default",    "Ported to BO2 by ^3Forgive", 30 );
    text[2] = elem( -9,  1.1, "default",      "^3Immensely and forever thankful for :", 20 );
    text[3] = elem( 7.5, 1.3, "default",    "Sass, Expert, Yoyo1love, Antiga", 15 );
    text[4] = elem( 170, 1, "default", "Press ^3[{weapnext}]^7 to close", 30 );

    self waittill_any( "weapon_switch_started" ,"weapon_fired", "death") ;

    foreach( t in text ) t SetPulseFX( 0, 0, 150 );

    self switchToWeapon( self getLastWeapon() );
    setDvar( "scr_gameEnded", !level.VISUAL_HUD );
    self setBlur( 0, 0.35 );
    VisionSetNaked( getDvar( "mapname" ), 0.5 );

    waitsec();
    self TakeWeapon( "briefcase_bomb_defuse_mp" );
    foreach( t in text ) t destroy();
}

elem( offset, size, font, text, pulse )
{
    elem = newClientHudElem( self );
    elem.horzAlign = "center";
    elem.vertAlign = "middle";
    elem.alignX = "center";
    elem.alignY = "middle";
    elem.y = offset;
    elem.font = font;
    elem.fontscale = size;
    elem.alpha = 1;
    elem.color = ( 1,1,1 );
    elem setText( text );
    elem SetPulseFX( pulse, 900000000, 9000 );
    return elem;
}