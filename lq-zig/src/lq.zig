//! The game section of LibreQuake's `defs.qc` ("VARS NOT REFERENCED BY C
//! CODE"): constants, globals and entity fields, as built for NetQuake
//! (`__LIBREQUAKE__` defined, `__QW__` not). The engine's own globals, fields
//! and builtins are in `defs.zig`.

const q = @import("defs.zig");
const Entity = q.Entity;
const Function = q.Function;
const String = q.String;
const Vector = q.Vector;
const userField = q.userField;
const userGlobal = q.userGlobal;

//
// constants
//

pub const FALSE: f32 = 0;
pub const TRUE: f32 = 1;

// edict.flags
pub const FL_FLY: f32 = 1;
pub const FL_SWIM: f32 = 2;
pub const FL_CLIENT: f32 = 8; // set for all client edicts
pub const FL_INWATER: f32 = 16; // for enter / leave water splash
pub const FL_MONSTER: f32 = 32;
pub const FL_GODMODE: f32 = 64; // player cheat
pub const FL_NOTARGET: f32 = 128; // player cheat
pub const FL_ITEM: f32 = 256; // extra wide size for bonus items
pub const FL_ONGROUND: f32 = 512; // standing on something
pub const FL_PARTIALGROUND: f32 = 1024; // not all corners are valid
pub const FL_WATERJUMP: f32 = 2048; // player jumping out of water
pub const FL_JUMPRELEASED: f32 = 4096; // for jump debouncing

// edict.movetype values
pub const MOVETYPE_NONE: f32 = 0; // never moves
//#define MOVETYPE_ANGLENOCLIP 1
//#define MOVETYPE_ANGLECLIP 2
pub const MOVETYPE_WALK: f32 = 3; // players only
pub const MOVETYPE_STEP: f32 = 4; // discrete, not real time unless fall
pub const MOVETYPE_FLY: f32 = 5;
pub const MOVETYPE_TOSS: f32 = 6; // gravity
pub const MOVETYPE_PUSH: f32 = 7; // no clip to world, push and crush
pub const MOVETYPE_NOCLIP: f32 = 8;
pub const MOVETYPE_FLYMISSILE: f32 = 9; // fly with extra size against monsters
pub const MOVETYPE_BOUNCE: f32 = 10;
pub const MOVETYPE_BOUNCEMISSILE: f32 = 11; // bounce with extra size

// edict.solid values
pub const SOLID_NOT: f32 = 0; // no interaction with other objects
pub const SOLID_TRIGGER: f32 = 1; // touch on edge, but not blocking
pub const SOLID_BBOX: f32 = 2; // touch on edge, block
pub const SOLID_SLIDEBOX: f32 = 3; // touch on edge, but not an onground
pub const SOLID_BSP: f32 = 4; // bsp clip, touch on edge, block

// range values
pub const RANGE_MELEE: f32 = 0;
pub const RANGE_NEAR: f32 = 1;
pub const RANGE_MID: f32 = 2;
pub const RANGE_FAR: f32 = 3;

// deadflag values

pub const DEAD_NO: f32 = 0;
pub const DEAD_DYING: f32 = 1;
pub const DEAD_DEAD: f32 = 2;
pub const DEAD_RESPAWNABLE: f32 = 3;

// takedamage values

pub const DAMAGE_NO: f32 = 0;
pub const DAMAGE_YES: f32 = 1;
pub const DAMAGE_AIM: f32 = 2;

// items
pub const IT_AXE: f32 = 4096;
pub const IT_SHOTGUN: f32 = 1;
pub const IT_SUPER_SHOTGUN: f32 = 2;
pub const IT_NAILGUN: f32 = 4;
pub const IT_SUPER_NAILGUN: f32 = 8;
pub const IT_GRENADE_LAUNCHER: f32 = 16;
pub const IT_ROCKET_LAUNCHER: f32 = 32;
pub const IT_LIGHTNING: f32 = 64;
pub const IT_EXTRA_WEAPON: f32 = 128;

pub const IT_SHELLS: f32 = 256;
pub const IT_NAILS: f32 = 512;
pub const IT_ROCKETS: f32 = 1024;
pub const IT_CELLS: f32 = 2048;

pub const IT_ARMOR1: f32 = 8192;
pub const IT_ARMOR2: f32 = 16384;
pub const IT_ARMOR3: f32 = 32768;
pub const IT_SUPERHEALTH: f32 = 65536;

pub const IT_KEY1: f32 = 131072;
pub const IT_KEY2: f32 = 262144;

pub const IT_INVISIBILITY: f32 = 524288;
pub const IT_INVULNERABILITY: f32 = 1048576;
pub const IT_SUIT: f32 = 2097152;
pub const IT_QUAD: f32 = 4194304;

// point content values

pub const CONTENT_EMPTY: f32 = -1;
pub const CONTENT_SOLID: f32 = -2;
pub const CONTENT_WATER: f32 = -3;
pub const CONTENT_SLIME: f32 = -4;
pub const CONTENT_LAVA: f32 = -5;
pub const CONTENT_SKY: f32 = -6;

pub const STATE_TOP: f32 = 0;
pub const STATE_BOTTOM: f32 = 1;
pub const STATE_UP: f32 = 2;
pub const STATE_DOWN: f32 = 3;

pub const VEC_ORIGIN: Vector = .{ 0, 0, 0 };
pub const VEC_HULL_MIN: Vector = .{ -16, -16, -24 };
pub const VEC_HULL_MAX: Vector = .{ 16, 16, 32 };

pub const VEC_HULL2_MIN: Vector = .{ -32, -32, -24 };
pub const VEC_HULL2_MAX: Vector = .{ 32, 32, 64 };

// protocol bytes
pub const SVC_TEMPENTITY: f32 = 23;
pub const SVC_KILLEDMONSTER: f32 = 27;
pub const SVC_FOUNDSECRET: f32 = 28;
pub const SVC_INTERMISSION: f32 = 30;
pub const SVC_FINALE: f32 = 31;
pub const SVC_CDTRACK: f32 = 32;
pub const SVC_SELLSCREEN: f32 = 33;

pub const SVC_CUTSCENE: f32 = 34;

pub const TE_SPIKE: f32 = 0;
pub const TE_SUPERSPIKE: f32 = 1;
pub const TE_GUNSHOT: f32 = 2;
pub const TE_EXPLOSION: f32 = 3;
pub const TE_TAREXPLOSION: f32 = 4;
pub const TE_LIGHTNING1: f32 = 5;
pub const TE_LIGHTNING2: f32 = 6;
pub const TE_WIZSPIKE: f32 = 7;
pub const TE_KNIGHTSPIKE: f32 = 8;
pub const TE_LIGHTNING3: f32 = 9;
pub const TE_LAVASPLASH: f32 = 10;
pub const TE_TELEPORT: f32 = 11;

// sound channels
// channel 0 never willingly overrides
// other channels (1-7) allways override a playing sound on that channel
pub const CHAN_AUTO: f32 = 0;
pub const CHAN_WEAPON: f32 = 1;
pub const CHAN_VOICE: f32 = 2;
pub const CHAN_ITEM: f32 = 3;
pub const CHAN_BODY: f32 = 4;

pub const CHAN_NO_PHS_ADD: f32 = 0;

pub const ATTN_NONE: f32 = 0;
pub const ATTN_NORM: f32 = 1;
pub const ATTN_IDLE: f32 = 2;
pub const ATTN_STATIC: f32 = 3;

// update types

pub const UPDATE_GENERAL: f32 = 0;
pub const UPDATE_STATIC: f32 = 1;
pub const UPDATE_BINARY: f32 = 2;
pub const UPDATE_TEMP: f32 = 3;

// entity effects

pub const EF_BRIGHTFIELD: f32 = 1;
pub const EF_MUZZLEFLASH: f32 = 2;
pub const EF_BRIGHTLIGHT: f32 = 4;
pub const EF_DIMLIGHT: f32 = 8;

// messages
pub const MSG_BROADCAST: f32 = 0; // unreliable to all
pub const MSG_ONE: f32 = 1; // reliable to one (msg_entity)
pub const MSG_ALL: f32 = 2; // reliable to all
pub const MSG_INIT: f32 = 3; // write to the init string

// message levels
pub const PRINT_LOW: f32 = 0; // pickup messages
pub const PRINT_MEDIUM: f32 = 1; // death messages
pub const PRINT_HIGH: f32 = 2; // critical messages
pub const PRINT_CHAT: f32 = 3; // also goes to chat console

pub const AS_STRAIGHT: f32 = 1;
pub const AS_SLIDING: f32 = 2;
pub const AS_MELEE: f32 = 3;
pub const AS_MISSILE: f32 = 4;

//================================================

//
// globals
//

pub const movedist = userGlobal(f32, "movedist");

pub const gameover = userGlobal(f32, "gameover"); // set when a rule exits

pub const string_null = userGlobal(String, "string_null"); // null string, nothing should be held here

pub const newmis = userGlobal(Entity, "newmis"); // launch_spike sets this after spawning it

pub const activator = userGlobal(Entity, "activator"); // the entity that activated a trigger or brush

pub const damage_attacker = userGlobal(Entity, "damage_attacker"); // set by T_Damage
pub const damage_inflictor = userGlobal(Entity, "damage_inflictor");
pub const framecount = userGlobal(f32, "framecount");

//
// cvars checked each frame
//
pub const skill = userGlobal(f32, "skill");
pub const timelimit = userGlobal(f32, "timelimit");
pub const fraglimit = userGlobal(f32, "fraglimit");

//================================================

//
// world fields (FIXME: make globals)
//
pub const wad = userField(String, "wad");
pub const map = userField(String, "map");
pub const worldtype = userField(f32, "worldtype"); // 0=medieval 1=metal 2=base

//================================================

pub const killtarget = userField(String, "killtarget");

//
// quakeed fields
//
pub const light_lev = userField(f32, "light_lev"); // not used by game, but parsed by light util
pub const style = userField(f32, "style");

//
// monster ai
//
pub const th_stand = userField(?Function, "th_stand");
pub const th_walk = userField(?Function, "th_walk");
pub const th_run = userField(?Function, "th_run");
pub const th_missile = userField(?Function, "th_missile");
pub const th_melee = userField(?Function, "th_melee");
/// `.void(entity attacker, float damage) th_pain`; call with `callAs(ThPain, ...)`.
pub const th_pain = userField(?Function, "th_pain");
pub const ThPain = fn (Entity, f32) callconv(.c) void;
pub const th_die = userField(?Function, "th_die");

pub const oldenemy = userField(Entity, "oldenemy"); // mad at this player before taking damage

pub const speed = userField(f32, "speed");

pub const lefty = userField(f32, "lefty");

pub const search_time = userField(f32, "search_time");
pub const attack_state = userField(f32, "attack_state");

//
// player only fields
//
pub const voided = userField(f32, "voided");
pub const walkframe = userField(f32, "walkframe");

// Zoid Additions
pub const maxspeed = userField(f32, "maxspeed"); // Used to set Maxspeed on a player
pub const gravity = userField(f32, "gravity"); // Gravity Multiplier (0 to 1.0)

pub const attack_finished = userField(f32, "attack_finished");
pub const pain_finished = userField(f32, "pain_finished");

pub const invincible_finished = userField(f32, "invincible_finished");
pub const invisible_finished = userField(f32, "invisible_finished");
pub const super_damage_finished = userField(f32, "super_damage_finished");
pub const radsuit_finished = userField(f32, "radsuit_finished");

pub const invincible_time = userField(f32, "invincible_time");
pub const invincible_sound = userField(f32, "invincible_sound");
pub const invisible_time = userField(f32, "invisible_time");
pub const invisible_sound = userField(f32, "invisible_sound");
pub const super_time = userField(f32, "super_time");
pub const super_sound = userField(f32, "super_sound");
pub const rad_time = userField(f32, "rad_time");
pub const fly_sound = userField(f32, "fly_sound");

pub const axhitme = userField(f32, "axhitme");

pub const show_hostile = userField(f32, "show_hostile"); // set to time+0.2 whenever a client fires a
// weapon or takes damage.  Used to alert
// monsters that otherwise would let the player go
pub const jump_flag = userField(f32, "jump_flag"); // player jump flag
pub const swim_flag = userField(f32, "swim_flag"); // player swimming sound flag
pub const air_finished = userField(f32, "air_finished"); // when time > air_finished, start drowning
pub const bubble_count = userField(f32, "bubble_count"); // keeps track of the number of bubbles
pub const deathtype = userField(String, "deathtype"); // keeps track of how the player died

//
// object stuff
//
pub const mdl = userField(String, "mdl");
pub const mangle = userField(Vector, "mangle"); // angle at start

// `.vector oldorigin` is redeclared here in the original ("only used by
// secret door"); it is the system field `.oldorigin`.

pub const t_length = userField(f32, "t_length");
pub const t_width = userField(f32, "t_width");

//
// doors, etc
//
pub const dest = userField(Vector, "dest");
pub const dest1 = userField(Vector, "dest1");
pub const dest2 = userField(Vector, "dest2");
pub const wait = userField(f32, "wait"); // time from firing to restarting
pub const delay = userField(f32, "delay"); // time from activation to firing
pub const trigger_field = userField(Entity, "trigger_field"); // door's trigger entity
pub const noise4 = userField(String, "noise4");

//
// monsters
//
pub const pausetime = userField(f32, "pausetime");
pub const movetarget = userField(Entity, "movetarget");

//
// doors
//
pub const aflag = userField(f32, "aflag");
pub const dmg = userField(f32, "dmg"); // damage done by door when hit

//
// misc
//
pub const cnt = userField(f32, "cnt"); // misc flag

//
// subs
//
pub const think1 = userField(?Function, "think1");
pub const finaldest = userField(Vector, "finaldest");
pub const finalangle = userField(Vector, "finalangle");

//
// triggers
//
pub const count = userField(f32, "count"); // for counting triggers

//
// plats / doors / buttons
//
pub const lip = userField(f32, "lip");
pub const state = userField(f32, "state");
pub const pos1 = userField(Vector, "pos1");
pub const pos2 = userField(Vector, "pos2"); // top and bottom positions
pub const height = userField(f32, "height");

//
// sounds
//
pub const waitmin = userField(f32, "waitmin");
pub const waitmax = userField(f32, "waitmax");
pub const distance = userField(f32, "distance");
pub const volume = userField(f32, "volume");

//additions. --gnounc
pub const killstring = userField(String, "killstring"); //the message a monster or item leaves when it kills you "was mauled by a rottweiler" etc. //gnounc

//pitch (angles_x) is inverted in quake due to a bug
//use makevectors2 for monsters with nonzero pitch
//anyone encountering this comment with a better understanding should update the comment to be more informative and useful to modders --gnounc
// (`makevectors2` is defined in `ai.zig`.)

// ============================================================================
//
// NetQuake versions of the QuakeWorld-only builtins, as `defs.qc` defines
// them when `__QW__` isn't.
//
// ============================================================================

/// NQ doesn't support print levels for console prints, so we just have it
/// ignore the print level.
pub fn bprint(level: f32, s: String) void {
    _ = level;
    q.bprint(s);
}

pub fn sprint(client: Entity, level: f32, s: String) void {
    _ = level;
    q.sprint(client, s);
}

/// logfrag is supported in QW, but not NQ. We just have NQ define it as an
/// empty function.
pub fn logfrag(killer: Entity, killee: Entity) void {
    _ = killer;
    _ = killee;
}
