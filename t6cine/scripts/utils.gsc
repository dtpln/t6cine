/*
 *      T6Cine
 *      Utilities
 */


#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\defaults;


// Macros
waitsec()   { wait 1; }
waitframe() { wait 0.05; }
skipframe() { waittillframeend; }

true_or_undef( cond )
{ if ( cond || !isdefined( cond ) ) return true; return false; }

defaultcase( cond, a, b )
{ if ( cond ) return a; return b; }

inarray( value, array, err )
{ foreach ( element in array ) { if ( element == value ) return true; } self iPrintLn( err ); return false; }

bool( value )
{ if ( value ) return "ON"; return "OFF"; }


// Create thread for player spawns
create_spawn_thread( callback, args )
{
    self endon( "disconnect" );
    for( ;; )
    {
        self waittill( "spawned_player" );
        if ( !isdefined( args ) ) 	
             self [[callback]]();
        else self [[callback]]( args );
    }
}


// Match Tweaks
skip_prematch()
{
    level.prematchPeriod = -1;
}

lod_tweaks()
{
    if( !level.VISUAL_LOD )  return;

    setDvar( "r_lodBiasRigid",   "-1000" );
    setDvar( "r_lodBiasSkinned", "-1000" );
}

hud_tweaks()
{
    setDvar( "g_TeamName_Allies",    "allies") ;
    setDvar( "g_TeamName_Axis",      "axis" );
    setDvar( "scr_gameEnded",        !level.VISUAL_HUD );
    setDvar( "sv_hostname", "^3Sass' Cinematic Mod ^7- Ported to BO2 by ^3Forgive" );
    setdvar( "didyouknow", "^3Sass' Cinematic Mod ^7- Ported to BO2 by ^3Forgive" );

    game["strings"]["objective_allies"] = "^3Sass' Cinematic Mod ^7- Ported to BO2 by ^3Forgive";
    game["strings"]["change_class"] = undefined;
}

match_tweaks()
{
    setDvar( "sv_cheats", 1 );
    if( level.MATCH_UNLIMITED_TIME )
        registerTimeLimit( 0 );

    if( level.MATCH_UNLIMITED_SCORE )
        registerScoreLimit( 0 );

    if( !level.INGAME_MUSIC ) 
    {
        game["music"]["spawn_allies"]       = undefined; 
        game["music"]["spawn_axis"]         = undefined; 
        game["dialog"]["gametype"]          = undefined;
        game["dialog"]["offense_obj"]       = undefined;
        game["dialog"]["defense_obj"]       = undefined; 
    }
    
    if( !level.SUNSET ) return;
        setDvar( "r_skyColorTemp", "2345" );
}

bots_tweaks() //    Useless in games that lack these dvars by default. -4g
{
    if( ( !self.isHost ) && level.BOT_FREEZE ) 
    {
        self freezecontrols( level.BOT_FREEZE );
    }
    else self freezecontrols( false );
}

score_tweaks()
{
    maps\mp\gametypes\_rank::registerScoreInfo( "kill",  level.MATCH_KILL_SCORE );

    if ( level.MATCH_KILL_BONUS )
    {
        maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 50 );
        maps\mp\gametypes\_rank::registerScoreInfo( "execution", 100 );
        maps\mp\gametypes\_rank::registerScoreInfo( "avenger", 50 );
        maps\mp\gametypes\_rank::registerScoreInfo( "defender", 50 );
        maps\mp\gametypes\_rank::registerScoreInfo( "posthumous", 25 );
        maps\mp\gametypes\_rank::registerScoreInfo( "revenge", 50 );
        maps\mp\gametypes\_rank::registerScoreInfo( "double", 50 );
        maps\mp\gametypes\_rank::registerScoreInfo( "triple", 75 );
        maps\mp\gametypes\_rank::registerScoreInfo( "multi", 100 );
        maps\mp\gametypes\_rank::registerScoreInfo( "buzzkill", 100 );
        maps\mp\gametypes\_rank::registerScoreInfo( "firstblood", 0 );
        maps\mp\gametypes\_rank::registerScoreInfo( "comeback", 100 );
        maps\mp\gametypes\_rank::registerScoreInfo( "longshot", 50 );
        maps\mp\gametypes\_rank::registerScoreInfo( "assistedsuicide", 100 );
        maps\mp\gametypes\_rank::registerScoreInfo( "knifethrow", 100 );
    }
    else 
    {
        maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 0 );
        maps\mp\gametypes\_rank::registerScoreInfo( "execution", 0 );
        maps\mp\gametypes\_rank::registerScoreInfo( "avenger", 0 );
        maps\mp\gametypes\_rank::registerScoreInfo( "defender", 0 );
        maps\mp\gametypes\_rank::registerScoreInfo( "posthumous", 0 );
        maps\mp\gametypes\_rank::registerScoreInfo( "revenge", 0 );
        maps\mp\gametypes\_rank::registerScoreInfo( "double", 0 );
        maps\mp\gametypes\_rank::registerScoreInfo( "triple", 0 );
        maps\mp\gametypes\_rank::registerScoreInfo( "multi", 0 );
        maps\mp\gametypes\_rank::registerScoreInfo( "buzzkill", 0 );
        maps\mp\gametypes\_rank::registerScoreInfo( "firstblood", 0 );
        maps\mp\gametypes\_rank::registerScoreInfo( "comeback", 0 );
        maps\mp\gametypes\_rank::registerScoreInfo( "longshot", 0 );
        maps\mp\gametypes\_rank::registerScoreInfo( "assistedsuicide", 0 );
        maps\mp\gametypes\_rank::registerScoreInfo( "knifethrow", 0 );
    }
}


// Weapons-Related Functions
camo_int( tracker )
{
    waitframe();
    switch ( tracker )
    {
        case "devgru":          return 01;      // DEVGRU
        case "atacsau":         return 02;      // A-TACS AU
        case "erdl":            return 03;      // ERDL
        case "siberia":         return 04;      // SIBERIA
        case "choco":           return 05;      // CHOCO
        case "blue":            return 06;      // BLUE TIGER
        case "bloodshot":       return 07;      // BLOODSHOT
        case "ghostex":         return 08;      // GHOSTEX : DELTA 6
        case "kryptek":         return 09;      // KRYPTEK: TYPHON
        case "carbon":          return 10;      // CARBON FIBER
        case "cherryblossom":   return 11;      // CHERRY BLOSSOM
        case "aow":             return 12;      // ART OF WAR
        case "artofwar":        return 12;      // ART OF WAR
        case "ronin":           return 13;      // RONIN
        case "skulls":          return 14;      // SKULLS
        case "gold":            return 15;      // GOLD
        case "diamond":         return 16;      // DIAMOND
        case "elite":           return 17;      // ELITE
        case "cedigital":       return 18;      // CE DIGITAL
        case "jungle":          return 19;      // JUNGLE WARFARE
        case "uk":              return 20;      // UK PUNK
        case "benjamins":       return 21;      // BENJAMINS
        case "dia":             return 22;      // DIA DE MUERTOS
        case "graffiti":        return 23;      // GRAFFITI
        case "kawaii":          return 24;      // KAWAII
        case "party":           return 25;      // PARTY ROCK
        case "zombies":         return 26;      // ZOMBIES
        case "viper":           return 27;      // VIPER
        case "bacon":           return 28;      // BACON
        case "ghosts":          return 29;      // GHOSTS
        case "paladin":         return 30;      // PALADIN
        case "cyborg":          return 31;      // CYBORG
        case "dragon":          return 32;      // DRAGON
        case "comic":           return 33;      // COMIC
        case "aqua":            return 34;      // AQUA
        case "breach":          return 35;      // BREACH
        case "coyote":          return 36;      // COYOTE
        case "glam":            return 37;      // GLAM
        case "rogue":           return 38;      // ROGUE
        case "pap":             return 39;      // PACK-A-PUNCH
        case "packapunch":      return 39;      // PACK-A-PUNCH
        case "deadmnanshand":   return 40;      // DEAD MAN'S HAND
        case "cards":           return 40;      // DEAD MAN'S HAND
        case "beast":           return 41;      // BEAST
        case "octane":          return 42;      // OCTANE
        case "weaponized115":   return 43;      // WEAPONIZED 115
        case "115":             return 43;      // WEAPONIZED 115
        case "weaponized":      return 43;      // WEAPONIZED 115
        case "afterlife":       return 44;      // AFTERLIFE
        case "aw":              return 45;      // ADVANCED WARFARE
        case "roxann":          return 45;      // ADVANCED WARFARE
        default:                return 00;
    }
}

// The mod used to use premade "weapon names" for bots spawns (ew), but now it's using actual weapon names
// Let's handle the old ones still, because I can already hear people losing their god damned mind after all this time
// Can also be used to make "shortcuts" if you're lazy like me hehe
legacy_classnames( weapon )
{
    switch ( weapon )
    {
        case "dsr":
            return "dsr50_mp";
        case "r700":
            return "remington700_mp";
        case "barrett":
        case "50":
            return "barrett_mp";
        case "deagle":
        case "deag":
            return "deserteagle_mp";
        case "m4":
            return "m4_mp";
        case "an94":
        case "an":
            return "an94_mp";
        default:
            return weapon;
    }
}

// Decided to use the same logic for picking bot models.
// Now you can use "sniper" or "assault" instead of SNIPER, ASSAULT, etc.
// Should stop people from crashing their games. -4g
legacy_modelnames( model )
{
    switch ( model ) 
    {
        case "sniper":
            return "rifle";
        case "assault":
            return "mg";
        case "smg":
            return "smg";
        case "lmg":
            return "spread";
        default:
            return model;
    }
}

take_offhands_tac()
{
    self takeweapon( "smoke_grenade_mp" );
    self takeweapon( "flash_grenade_mp" );
    self takeweapon( "concussion_grenade_mp" );
}

take_offhands_leth()
{
    self takeweapon( "flare_mp" );
    self takeweapon( "throwingknife_mp" );
    self takeweapon( "c4_mp" );
    self takeweapon( "claymore_mp" );
    self takeweapon( "semtex_mp" );
    self takeweapon( "frag_grenade_mp" );
}

is_akimbo( weapon )
{
    if ( isSubStr( weapon.name, "akimbo" ) )
        return true;
    return false;
}


// Player & Bots manipulation
is_bot()
{
    if (isdefined(self.pers["isBot"]) && self.pers["isBot"])
    {
        return true;
    }
    return false;
}

at_crosshair( ent )
{
    return BulletTrace( ent getTagOrigin( "tag_eye" ), anglestoforward( ent getPlayerAngles() ) * 100000, true, ent )["position"];
}

save_spawn()
{
    self.saved_origin = self.origin;
    self.saved_angles = self getPlayerAngles();
}

load_spawn()
{
    self setOrigin( self.saved_origin );
    self setPlayerAngles( self.saved_angles );
}

select_ents( ent, name, player )
{
    if ( isSubStr( ent.name, name ) || isSubStr( ent["name"], name )  || 
       ( name == "look" && inside_fov( player, ent["hitbox"], 10 ) )  || 
       ( name == "look" && inside_fov( player, ent, 10 ) )            || 
         name == undefined ) 
        return true;
    return false;
}

inside_fov( player, target, fov )
{
    normal = vectorNormalize( target.origin - player getEye() );
    forward = anglesToForward( player getPlayerAngles() );
    dot = vectorDot( forward, normal );
    return dot >= cos( fov );
}