//! world.qc
//!
//! Copyright (C) 1996-1997  Id Software, Inc.
//!
//! This program is free software; you can redistribute it and/or modify
//! it under the terms of the GNU General Public License as published by
//! the Free Software Foundation; either version 2 of the License, or
//! (at your option) any later version.
//!
//! This program is distributed in the hope that it will be useful,
//! but WITHOUT ANY WARRANTY; without even the implied warranty of
//! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//! GNU General Public License for more details.
//!
//! You should have received a copy of the GNU General Public License
//! along with this program; if not, write to the Free Software
//! Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//!
//! See file, 'COPYING', for details.

const q = @import("defs.zig");
const lq = @import("lq.zig");
const S = q.S;
const Entity = q.Entity;
const weapons = @import("weapons.zig");

pub export fn main() void {
    q.dprint(S("main function\n"));

    // these are just commands the the prog compiler to copy these files

    _ = q.precache_file(S("progs.dat"));
    _ = q.precache_file(S("gfx.wad"));
    _ = q.precache_file(S("quake.rc"));
    _ = q.precache_file(S("default.cfg"));

    _ = q.precache_file(S("end1.bin"));
    _ = q.precache_file2(S("end2.bin"));

    _ = q.precache_file(S("demo1.dem"));
    _ = q.precache_file(S("demo2.dem"));
    _ = q.precache_file(S("demo3.dem"));

    //
    // these are all of the lumps from the cached.ls files
    //
    _ = q.precache_file(S("gfx/palette.lmp"));
    _ = q.precache_file(S("gfx/colormap.lmp"));

    _ = q.precache_file2(S("gfx/pop.lmp"));

    _ = q.precache_file(S("gfx/complete.lmp"));
    _ = q.precache_file(S("gfx/inter.lmp"));

    _ = q.precache_file(S("gfx/ranking.lmp"));
    _ = q.precache_file(S("gfx/vidmodes.lmp"));
    _ = q.precache_file(S("gfx/finale.lmp"));
    _ = q.precache_file(S("gfx/conback.lmp"));
    _ = q.precache_file(S("gfx/qplaque.lmp"));

    _ = q.precache_file(S("gfx/menudot1.lmp"));
    _ = q.precache_file(S("gfx/menudot2.lmp"));
    _ = q.precache_file(S("gfx/menudot3.lmp"));
    _ = q.precache_file(S("gfx/menudot4.lmp"));
    _ = q.precache_file(S("gfx/menudot5.lmp"));
    _ = q.precache_file(S("gfx/menudot6.lmp"));

    _ = q.precache_file(S("gfx/menuplyr.lmp"));
    _ = q.precache_file(S("gfx/bigbox.lmp"));
    _ = q.precache_file(S("gfx/dim_modm.lmp"));
    _ = q.precache_file(S("gfx/dim_drct.lmp"));
    _ = q.precache_file(S("gfx/dim_ipx.lmp"));
    _ = q.precache_file(S("gfx/dim_tcp.lmp"));
    _ = q.precache_file(S("gfx/dim_mult.lmp"));
    _ = q.precache_file(S("gfx/mainmenu.lmp"));

    _ = q.precache_file(S("gfx/box_tl.lmp"));
    _ = q.precache_file(S("gfx/box_tm.lmp"));
    _ = q.precache_file(S("gfx/box_tr.lmp"));

    _ = q.precache_file(S("gfx/box_ml.lmp"));
    _ = q.precache_file(S("gfx/box_mm.lmp"));
    _ = q.precache_file(S("gfx/box_mm2.lmp"));
    _ = q.precache_file(S("gfx/box_mr.lmp"));

    _ = q.precache_file(S("gfx/box_bl.lmp"));
    _ = q.precache_file(S("gfx/box_bm.lmp"));
    _ = q.precache_file(S("gfx/box_br.lmp"));

    _ = q.precache_file(S("gfx/sp_menu.lmp"));
    _ = q.precache_file(S("gfx/ttl_sgl.lmp"));
    _ = q.precache_file(S("gfx/ttl_main.lmp"));
    _ = q.precache_file(S("gfx/ttl_cstm.lmp"));

    _ = q.precache_file(S("gfx/mp_menu.lmp"));

    _ = q.precache_file(S("gfx/netmen1.lmp"));
    _ = q.precache_file(S("gfx/netmen2.lmp"));
    _ = q.precache_file(S("gfx/netmen3.lmp"));
    _ = q.precache_file(S("gfx/netmen4.lmp"));
    _ = q.precache_file(S("gfx/netmen5.lmp"));

    _ = q.precache_file(S("gfx/sell.lmp"));

    _ = q.precache_file(S("gfx/help0.lmp"));
    _ = q.precache_file(S("gfx/help1.lmp"));
    _ = q.precache_file(S("gfx/help2.lmp"));
    _ = q.precache_file(S("gfx/help3.lmp"));
    _ = q.precache_file(S("gfx/help4.lmp"));
    _ = q.precache_file(S("gfx/help5.lmp"));

    _ = q.precache_file(S("gfx/pause.lmp"));
    _ = q.precache_file(S("gfx/loading.lmp"));

    _ = q.precache_file(S("gfx/p_option.lmp"));
    _ = q.precache_file(S("gfx/p_load.lmp"));
    _ = q.precache_file(S("gfx/p_save.lmp"));
    _ = q.precache_file(S("gfx/p_multi.lmp"));

    // sounds loaded by C code
    _ = q.precache_sound(S("misc/menu1.wav"));
    _ = q.precache_sound(S("misc/menu2.wav"));
    _ = q.precache_sound(S("misc/menu3.wav"));

    _ = q.precache_sound(S("ambience/water1.wav"));
    _ = q.precache_sound(S("ambience/wind2.wav"));

    // shareware
    _ = q.precache_file(S("maps/start.bsp"));

    _ = q.precache_file(S("maps/e1m1.bsp"));
    _ = q.precache_file(S("maps/e1m2.bsp"));
    _ = q.precache_file(S("maps/e1m3.bsp"));
    _ = q.precache_file(S("maps/e1m4.bsp"));
    _ = q.precache_file(S("maps/e1m5.bsp"));
    _ = q.precache_file(S("maps/e1m6.bsp"));
    _ = q.precache_file(S("maps/e1m7.bsp"));
    _ = q.precache_file(S("maps/e1m8.bsp"));

    // registered
    _ = q.precache_file2(S("gfx/pop.lmp"));

    _ = q.precache_file2(S("maps/e2m1.bsp"));
    _ = q.precache_file2(S("maps/e2m2.bsp"));
    _ = q.precache_file2(S("maps/e2m3.bsp"));
    _ = q.precache_file2(S("maps/e2m4.bsp"));
    _ = q.precache_file2(S("maps/e2m5.bsp"));
    _ = q.precache_file2(S("maps/e2m6.bsp"));
    _ = q.precache_file2(S("maps/e2m7.bsp"));

    _ = q.precache_file2(S("maps/e3m1.bsp"));
    _ = q.precache_file2(S("maps/e3m2.bsp"));
    _ = q.precache_file2(S("maps/e3m3.bsp"));
    _ = q.precache_file2(S("maps/e3m4.bsp"));
    _ = q.precache_file2(S("maps/e3m5.bsp"));
    _ = q.precache_file2(S("maps/e3m6.bsp"));
    _ = q.precache_file2(S("maps/e3m7.bsp"));

    _ = q.precache_file2(S("maps/e4m1.bsp"));
    _ = q.precache_file2(S("maps/e4m2.bsp"));
    _ = q.precache_file2(S("maps/e4m3.bsp"));
    _ = q.precache_file2(S("maps/e4m4.bsp"));
    _ = q.precache_file2(S("maps/e4m5.bsp"));
    _ = q.precache_file2(S("maps/e4m6.bsp"));
    _ = q.precache_file2(S("maps/e4m7.bsp"));
    _ = q.precache_file2(S("maps/e4m8.bsp"));

    _ = q.precache_file2(S("maps/end.bsp"));

    _ = q.precache_file2(S("maps/dm1.bsp"));
    _ = q.precache_file2(S("maps/dm2.bsp"));
    _ = q.precache_file2(S("maps/dm3.bsp"));
    _ = q.precache_file2(S("maps/dm4.bsp"));
    _ = q.precache_file2(S("maps/dm5.bsp"));
    _ = q.precache_file2(S("maps/dm6.bsp"));
}

pub const lastspawn = q.userGlobal(Entity, "lastspawn");

//=======================
/// QUAKED worldspawn (0 0 0) ?
/// Only used for the world entity.
/// Set message to the level name.
/// Set sounds to the cd track to play.
///
/// World Types:
/// 0: medieval
/// 1: metal
/// 2: base
//=======================
pub export fn worldspawn() void {
    const self = q.me();
    lastspawn.set(q.world.get());
    InitBodyQueue();

    // custom map attributes
    if (self.model.eql(S("maps/e1m8.bsp")) or self.model.eql(S("maps/lq_e1m8.bsp")))
        q.cvar_set(S("sv_gravity"), S("100"))
    else
        q.cvar_set(S("sv_gravity"), S("800"));

    // the area based ambient sounds MUST be the first precache_sounds

    // player precaches
    weapons.W_Precache(); // get weapon precaches

    // sounds used from C physics code
    _ = q.precache_sound(S("demon/dland2.wav")); // landing thud
    _ = q.precache_sound(S("misc/h2ohit1.wav")); // landing splash

    // setup precaches allways needed
    _ = q.precache_sound(S("items/itembk2.wav")); // item respawn sound
    _ = q.precache_sound(S("player/plyrjmp8.wav")); // player jump
    _ = q.precache_sound(S("player/land.wav")); // player landing
    _ = q.precache_sound(S("player/land2.wav")); // player hurt landing
    _ = q.precache_sound(S("player/drown1.wav")); // drowning pain
    _ = q.precache_sound(S("player/drown2.wav")); // drowning pain
    _ = q.precache_sound(S("player/gasp1.wav")); // gasping for air
    _ = q.precache_sound(S("player/gasp2.wav")); // taking breath
    _ = q.precache_sound(S("player/h2odeath.wav")); // drowning death

    _ = q.precache_sound(S("misc/talk.wav")); // talk
    _ = q.precache_sound(S("player/teledth1.wav")); // telefrag
    _ = q.precache_sound(S("misc/r_tele1.wav")); // teleport sounds
    _ = q.precache_sound(S("misc/r_tele2.wav"));
    _ = q.precache_sound(S("misc/r_tele3.wav"));
    _ = q.precache_sound(S("misc/r_tele4.wav"));
    _ = q.precache_sound(S("misc/r_tele5.wav"));
    _ = q.precache_sound(S("weapons/lock4.wav")); // ammo pick up
    _ = q.precache_sound(S("weapons/pkup.wav")); // weapon up
    _ = q.precache_sound(S("items/armor1.wav")); // armor up
    _ = q.precache_sound(S("weapons/lhit.wav")); //lightning
    _ = q.precache_sound(S("weapons/lstart.wav")); //lightning start
    _ = q.precache_sound(S("items/damage2.wav"));
    _ = q.precache_sound(S("items/damage3.wav"));

    _ = q.precache_sound(S("misc/power.wav")); //lightning for boss

    // player gib sounds
    _ = q.precache_sound(S("player/gib.wav")); // player gib sound
    _ = q.precache_sound(S("player/udeath.wav")); // player gib sound
    _ = q.precache_sound(S("player/tornoff2.wav")); // gib sound

    // player pain sounds

    _ = q.precache_sound(S("player/pain1.wav"));
    _ = q.precache_sound(S("player/pain2.wav"));
    _ = q.precache_sound(S("player/pain3.wav"));
    _ = q.precache_sound(S("player/pain4.wav"));
    _ = q.precache_sound(S("player/pain5.wav"));
    _ = q.precache_sound(S("player/pain6.wav"));

    // player death sounds
    _ = q.precache_sound(S("player/death1.wav"));
    _ = q.precache_sound(S("player/death2.wav"));
    _ = q.precache_sound(S("player/death3.wav"));
    _ = q.precache_sound(S("player/death4.wav"));
    _ = q.precache_sound(S("player/death5.wav"));

    _ = q.precache_sound(S("boss1/sight1.wav"));

    // ax sounds
    _ = q.precache_sound(S("weapons/ax1.wav")); // ax swoosh
    _ = q.precache_sound(S("player/axhit1.wav")); // ax hit meat
    _ = q.precache_sound(S("player/axhit2.wav")); // ax hit world

    _ = q.precache_sound(S("player/h2ojump.wav")); // player jumping into water
    _ = q.precache_sound(S("player/slimbrn2.wav")); // player enter slime
    _ = q.precache_sound(S("player/inh2o.wav")); // player enter water
    _ = q.precache_sound(S("player/inlava.wav")); // player enter lava
    _ = q.precache_sound(S("misc/outwater.wav")); // leaving water sound

    // Invulnerability sounds
    _ = q.precache_sound(S("items/protect.wav"));
    _ = q.precache_sound(S("items/protect2.wav"));
    _ = q.precache_sound(S("items/protect3.wav"));

    _ = q.precache_sound(S("player/lburn1.wav")); // lava burn
    _ = q.precache_sound(S("player/lburn2.wav")); // lava burn

    _ = q.precache_sound(S("misc/water1.wav")); // swimming
    _ = q.precache_sound(S("misc/water2.wav")); // swimming

    _ = q.precache_model(S("progs/player.mdl"));
    _ = q.precache_model(S("progs/eyes.mdl"));
    _ = q.precache_model(S("progs/h_player.mdl"));
    _ = q.precache_model(S("progs/gib1.mdl"));
    _ = q.precache_model(S("progs/gib2.mdl"));
    _ = q.precache_model(S("progs/gib3.mdl"));

    _ = q.precache_model(S("progs/s_bubble.spr")); // drowning bubbles
    _ = q.precache_model(S("progs/s_explod.spr")); // sprite explosion

    _ = q.precache_model(S("progs/v_axe.mdl"));
    _ = q.precache_model(S("progs/v_shot.mdl"));
    _ = q.precache_model(S("progs/v_nail.mdl"));
    _ = q.precache_model(S("progs/v_rock.mdl"));
    _ = q.precache_model(S("progs/v_shot2.mdl"));
    _ = q.precache_model(S("progs/v_nail2.mdl"));
    _ = q.precache_model(S("progs/v_rock2.mdl"));

    _ = q.precache_model(S("progs/bolt.mdl")); // for lightning gun
    _ = q.precache_model(S("progs/bolt2.mdl")); // for lightning gun
    _ = q.precache_model(S("progs/bolt3.mdl")); // for boss shock
    _ = q.precache_model(S("progs/lavaball.mdl")); // for testing

    _ = q.precache_model(S("progs/missile.mdl"));
    _ = q.precache_model(S("progs/grenade.mdl"));
    _ = q.precache_model(S("progs/spike.mdl"));
    _ = q.precache_model(S("progs/s_spike.mdl"));

    _ = q.precache_model(S("progs/backpack.mdl"));

    _ = q.precache_model(S("progs/zom_gib.mdl"));

    _ = q.precache_model(S("progs/v_light.mdl"));

    //
    // Setup light animation tables. 'a' is total darkness, 'z' is maxbright.
    //

    // 0 normal
    q.lightstyle(0, S("m"));

    // 1 FLICKER (first variety)
    q.lightstyle(1, S("mmnmmommommnonmmonqnmmo"));

    // 2 SLOW STRONG PULSE
    q.lightstyle(2, S("abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba"));

    // 3 CANDLE (first variety)
    q.lightstyle(3, S("mmmmmaaaaammmmmaaaaaabcdefgabcdefg"));

    // 4 FAST STROBE
    q.lightstyle(4, S("mamamamamama"));

    // 5 GENTLE PULSE 1
    q.lightstyle(5, S("jklmnopqrstuvwxyzyxwvutsrqponmlkj"));

    // 6 FLICKER (second variety)
    q.lightstyle(6, S("nmonqnmomnmomomno"));

    // 7 CANDLE (second variety)
    q.lightstyle(7, S("mmmaaaabcdefgmmmmaaaammmaamm"));

    // 8 CANDLE (third variety)
    q.lightstyle(8, S("mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa"));

    // 9 SLOW STROBE (fourth variety)
    q.lightstyle(9, S("aaaaaaaazzzzzzzz"));

    // 10 FLUORESCENT FLICKER
    q.lightstyle(10, S("mmamammmmammamamaaamammma"));

    // 11 SLOW PULSE NOT FADE TO BLACK
    q.lightstyle(11, S("abcdefghijklmnopqrrqponmlkjihgfedcba"));

    // styles 32-62 are assigned by the light program for switchable lights

    // 63 testing
    q.lightstyle(63, S("a"));
}

pub export fn StartFrame() void {
    lq.timelimit.set(q.cvar(S("timelimit")) * 60);
    lq.fraglimit.set(q.cvar(S("fraglimit")));
    q.deathmatch.set(q.cvar(S("deathmatch")));
    q.teamplay.set(q.cvar(S("teamplay")));
    lq.skill.set(q.cvar(S("skill")));
    lq.framecount.set(lq.framecount.get() + 1);
}

// ==============================================================================
//
// BODY QUE
//
// ==============================================================================

pub const bodyqueue_head = q.userGlobal(Entity, "bodyqueue_head");

pub export fn bodyqueue() void { // just here so spawn functions don't complain after the world
    // creates bodyqueues
}

pub export fn InitBodyQueue() void {
    bodyqueue_head.set(q.spawn());
    bodyqueue_head.get().classname = S("bodyqueue");
    bodyqueue_head.get().owner = q.spawn();
    bodyqueue_head.get().owner.classname = S("bodyqueue");
    bodyqueue_head.get().owner.owner = q.spawn();
    bodyqueue_head.get().owner.owner.classname = S("bodyqueue");
    bodyqueue_head.get().owner.owner.owner = q.spawn();
    bodyqueue_head.get().owner.owner.owner.classname = S("bodyqueue");
    bodyqueue_head.get().owner.owner.owner.owner = bodyqueue_head.get();
}

// make a body que entry for the given ent so the ent can be
// respawned elsewhere
pub export fn CopyToBodyQueue(ent: Entity) void {
    bodyqueue_head.get().angles = ent.angles;
    bodyqueue_head.get().model = ent.model;
    bodyqueue_head.get().modelindex = ent.modelindex;
    bodyqueue_head.get().frame = ent.frame;
    bodyqueue_head.get().colormap = ent.colormap;
    bodyqueue_head.get().movetype = ent.movetype;
    bodyqueue_head.get().velocity = ent.velocity;
    bodyqueue_head.get().flags = 0;
    q.setorigin(bodyqueue_head.get(), ent.origin);
    q.setsize(bodyqueue_head.get(), ent.mins, ent.maxs);
    bodyqueue_head.set(bodyqueue_head.get().owner);
}
