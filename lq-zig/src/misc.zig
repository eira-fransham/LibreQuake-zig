//! misc.qc
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
const loc = @import("localized_text.zig");
const S = q.S;
const Vector = q.Vector;
const subs = @import("subs.zig");
const combat = @import("combat.zig");
const weapons = @import("weapons.zig");

/// QUAKED info_null (0 0.5 0) (-4 -4 -4) (4 4 4)
/// Used as a positional target for spotlights, etc.
pub export fn info_null() void {
    q.remove(q.me());
}

/// QUAKED info_notnull (0 0.5 0) (-4 -4 -4) (4 4 4)
/// Used as a positional target for lightning.
pub export fn info_notnull() void {}

//============================================================================

pub const START_OFF: f32 = 1;

pub export fn light_use() void {
    const self = q.me();
    if (q.has(self.spawnflags, START_OFF)) {
        q.lightstyle(self.get(lq.style), S("m"));
        self.spawnflags = self.spawnflags - START_OFF;
    } else {
        q.lightstyle(self.get(lq.style), S("a"));
        self.spawnflags = self.spawnflags + START_OFF;
    }
}

/// QUAKED light (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
/// Non-displayed light.
/// Default light value is 300
/// Default style is 0
/// If targeted, it will toggle between on or off.
pub export fn light() void {
    const self = q.me();
    if (self.targetname.isNull()) { // inert light
        q.remove(self);
        return;
    }

    if (self.get(lq.style) >= 32) {
        self.use = q.func(light_use);

        if (q.has(self.spawnflags, START_OFF))
            q.lightstyle(self.get(lq.style), S("a"))
        else
            q.lightstyle(self.get(lq.style), S("m"));
    }
}

/// QUAKED light_fluoro (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
/// Non-displayed light.
/// Default light value is 300
/// Default style is 0
/// If targeted, it will toggle between on or off.
/// Makes steady fluorescent humming sound
pub export fn light_fluoro() void {
    const self = q.me();
    if (self.get(lq.style) >= 32) {
        self.use = q.func(light_use);

        if (q.has(self.spawnflags, START_OFF))
            q.lightstyle(self.get(lq.style), S("a"))
        else
            q.lightstyle(self.get(lq.style), S("m"));
    }

    _ = q.precache_sound(S("ambience/fl_hum1.wav"));
    q.ambientsound(self.origin, S("ambience/fl_hum1.wav"), 0.5, lq.ATTN_STATIC);
}

/// QUAKED light_fluorospark (0 1 0) (-8 -8 -8) (8 8 8)
/// Non-displayed light.
/// Default light value is 300
/// Default style is 10
/// Makes sparking, broken fluorescent sound
pub export fn light_fluorospark() void {
    const self = q.me();
    if (self.get(lq.style) == 0)
        self.set(lq.style, 10);

    _ = q.precache_sound(S("ambience/buzz1.wav"));
    q.ambientsound(self.origin, S("ambience/buzz1.wav"), 0.5, lq.ATTN_STATIC);
}

/// QUAKED light_globe (0 1 0) (-8 -8 -8) (8 8 8)
/// Sphere globe light.
/// Default light value is 300
/// Default style is 0
pub export fn light_globe() void {
    const self = q.me();
    _ = q.precache_model(S("progs/s_light.spr"));
    q.setmodel(self, S("progs/s_light.spr"));
    q.makestatic(self);
}

pub export fn FireAmbient() void {
    const self = q.me();
    _ = q.precache_sound(S("ambience/fire1.wav"));

    // attenuate fast
    q.ambientsound(self.origin, S("ambience/fire1.wav"), 0.5, lq.ATTN_STATIC);
}

/// QUAKED light_torch_small_walltorch (0 .5 0) (-10 -10 -20) (10 10 20)
/// {
///     model({"path": "progs/flame.mdl", "skin": 0, "frame": 0});
/// }
/// Short wall torch
/// Default light value is 200
/// Default style is 0
pub export fn light_torch_small_walltorch() void {
    const self = q.me();
    _ = q.precache_model(S("progs/flame.mdl"));
    q.setmodel(self, S("progs/flame.mdl"));
    FireAmbient();
    q.makestatic(self);
}

/// QUAKED light_flame_large_yellow (0 1 0) (-10 -10 -12) (12 12 18)
/// {
///     model({"path": "progs/flame2.mdl", "skin": 0, "frame": 1});
/// }
/// Large yellow flame ball
pub export fn light_flame_large_yellow() void {
    const self = q.me();
    _ = q.precache_model(S("progs/flame2.mdl"));
    q.setmodel(self, S("progs/flame2.mdl"));
    self.frame = 1;
    FireAmbient();
    q.makestatic(self);
}

/// QUAKED light_flame_small_yellow (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
/// {
///     model({"path": "progs/flame2.mdl", "skin": 0, "frame": 0});
/// }
/// Small yellow flame ball
pub export fn light_flame_small_yellow() void {
    const self = q.me();
    _ = q.precache_model(S("progs/flame2.mdl"));
    q.setmodel(self, S("progs/flame2.mdl"));
    FireAmbient();
    q.makestatic(self);
}

/// QUAKED light_flame_small_white (0 1 0) (-10 -10 -40) (10 10 40) START_OFF
/// {
///     model({"path": "progs/flame2.mdl", "skin": 0, "frame": 0});
/// }
/// Small white flame ball
pub export fn light_flame_small_white() void {
    const self = q.me();
    _ = q.precache_model(S("progs/flame2.mdl"));
    q.setmodel(self, S("progs/flame2.mdl"));
    FireAmbient();
    q.makestatic(self);
}

//============================================================================

/// QUAKED misc_fireball (0 .5 .8) (-8 -8 -8) (8 8 8)
/// Lava Balls
pub export fn misc_fireball() void {
    const self = q.me();
    _ = q.precache_model(S("progs/lavaball.mdl"));
    self.classname = S("fireball");
    self.nextthink = q.time.get() + (q.random() * 5);
    self.think = q.func(fire_fly);

    if (self.get(lq.speed) == 0)
        self.set(lq.speed, 1000);
}

pub export fn fire_fly() void {
    const self = q.me();

    const fireball = q.spawn();
    fireball.solid = lq.SOLID_TRIGGER;
    fireball.movetype = lq.MOVETYPE_TOSS;
    fireball.velocity = q.vec(0, 0, 1000);
    fireball.velocity[0] = (q.random() * 100) - 50;
    fireball.velocity[1] = (q.random() * 100) - 50;
    fireball.velocity[2] = self.get(lq.speed) + (q.random() * 200);
    fireball.classname = S("fireball");
    q.setmodel(fireball, S("progs/lavaball.mdl"));
    q.setsize(fireball, q.vec(0, 0, 0), q.vec(0, 0, 0));
    q.setorigin(fireball, self.origin);
    fireball.nextthink = q.time.get() + 5;
    fireball.think = q.func(subs.SUB_Remove);
    fireball.touch = q.func(fire_touch);

    fireball.netname = S("lava ball");
    fireball.set(lq.killstring, S(loc.LOC_DEATH_FIREBALL));

    self.nextthink = q.time.get() + (q.random() * 5) + 3;
    self.think = q.func(fire_fly);
}

pub export fn fire_touch() void {
    const self = q.me();
    combat.T_Damage(q.other.get(), self, self, 20);
    q.remove(self);
}

//============================================================================

pub export fn barrel_explode() void {
    const self = q.me();
    self.takedamage = lq.DAMAGE_NO;
    self.classname = S("explo_box");
    combat.T_RadiusDamage(self, self, 160, q.world.get(), S(""));

    q.sound(self, lq.CHAN_VOICE, S("weapons/r_exp3.wav"), 1, lq.ATTN_NORM);
    q.particle(self.origin, q.vec(0, 0, 0), 75, 255);

    self.origin[2] = self.origin[2] + 32;
    weapons.BecomeExplosion();
}

/// QUAKED misc_explobox (0 .5 .8) (0 0 0) (32 32 64)
/// TESTING THING
pub export fn misc_explobox() void {
    const self = q.me();

    self.solid = lq.SOLID_BBOX;
    self.movetype = lq.MOVETYPE_NONE;
    _ = q.precache_model(S("maps/b_explob.bsp"));
    q.setmodel(self, S("maps/b_explob.bsp"));
    q.setsize(self, q.vec(0, 0, 0), q.vec(32, 32, 64));
    _ = q.precache_sound(S("weapons/r_exp3.wav"));
    self.health = 20;
    self.set(lq.th_die, q.func(barrel_explode));
    self.takedamage = lq.DAMAGE_AIM;

    //gnounc
    self.netname = S("exploding barrel");
    self.set(lq.killstring, S(loc.LOC_DEATH_EXPLO_BOX));

    self.origin[2] = self.origin[2] + 2;
    const oldz = self.origin[2];
    _ = q.droptofloor();

    if (oldz - self.origin[2] > 250) {
        q.dprint(S("item fell out of level at "));
        q.dprint(q.vtos(self.origin));
        q.dprint(S("\n"));
        q.remove(self);
    }
}

/// QUAKED misc_explobox2 (0 .5 .8) (0 0 0) (32 32 64)
/// Smaller exploding box, REGISTERED ONLY
pub export fn misc_explobox2() void {
    const self = q.me();

    self.solid = lq.SOLID_BBOX;
    self.movetype = lq.MOVETYPE_NONE;
    _ = q.precache_model2(S("maps/b_exbox2.bsp"));
    q.setmodel(self, S("maps/b_exbox2.bsp"));
    q.setsize(self, q.vec(0, 0, 0), q.vec(32, 32, 32));
    _ = q.precache_sound(S("weapons/r_exp3.wav"));
    self.health = 20;
    self.set(lq.th_die, q.func(barrel_explode));
    self.takedamage = lq.DAMAGE_AIM;

    //gnounc
    self.netname = S("exploding barrel");
    self.set(lq.killstring, S(loc.LOC_DEATH_EXPLO_BOX));

    self.origin[2] = self.origin[2] + 2;
    const oldz = self.origin[2];
    _ = q.droptofloor();

    if (oldz - self.origin[2] > 250) {
        q.dprint(S("item fell out of level at "));
        q.dprint(q.vtos(self.origin));
        q.dprint(S("\n"));
        q.remove(self);
    }
}

//============================================================================

pub const SPAWNFLAG_SUPERSPIKE: f32 = 1;

pub const SPAWNFLAG_LASER: f32 = 2;

pub export fn Laser_Touch() void {
    const self = q.me();
    const other = q.other.get();

    if (other.eql(self.owner))
        return; // don't explode on owner

    if (q.pointcontents(self.origin) == lq.CONTENT_SKY) {
        q.remove(self);
        return;
    }

    q.sound(self, lq.CHAN_WEAPON, S("enforcer/enfstop.wav"), 1, lq.ATTN_STATIC);
    const org: Vector = self.origin - q.scale(q.normalize(self.velocity), 8);

    if (other.health != 0) {
        weapons.SpawnBlood(org, q.scale(self.velocity, 0.2), 15);
        other.set(lq.deathtype, S("laser"));
        combat.T_Damage(other, self, self.owner, 15);
    } else {
        q.WriteByte(lq.MSG_BROADCAST, lq.SVC_TEMPENTITY);
        q.WriteByte(lq.MSG_BROADCAST, lq.TE_GUNSHOT);
        q.WriteCoord(lq.MSG_BROADCAST, org[0]);
        q.WriteCoord(lq.MSG_BROADCAST, org[1]);
        q.WriteCoord(lq.MSG_BROADCAST, org[2]);
    }

    q.remove(self);
}

pub export fn LaunchLaser(org: Vector, vec: Vector) void {
    const self = q.me();
    if (self.classname.eql(S("monster_enforcer")))
        q.sound(self, lq.CHAN_WEAPON, S("enforcer/enfire.wav"), 1, lq.ATTN_NORM);

    const dir = q.normalize(vec);

    lq.newmis.set(q.spawn());
    const newmis = lq.newmis.get();
    newmis.classname = S("enforcer_laser"); //gnounc
    newmis.owner = self;
    newmis.movetype = lq.MOVETYPE_FLY;
    newmis.solid = lq.SOLID_BBOX;
    newmis.effects = lq.EF_DIMLIGHT;

    q.setmodel(newmis, S("progs/laser.mdl"));
    q.setsize(newmis, q.vec(0, 0, 0), q.vec(0, 0, 0));

    q.setorigin(newmis, org);

    newmis.velocity = q.scale(dir, 600);
    newmis.angles = q.vectoangles(newmis.velocity);

    newmis.nextthink = q.time.get() + 5;
    newmis.think = q.func(subs.SUB_Remove);
    newmis.touch = q.func(Laser_Touch);
}

pub export fn spikeshooter_use() void {
    const self = q.me();
    if (q.has(self.spawnflags, SPAWNFLAG_LASER)) {
        q.sound(self, lq.CHAN_VOICE, S("enforcer/enfire.wav"), 1, lq.ATTN_NORM);
        LaunchLaser(self.origin, self.movedir);
    } else {
        q.sound(self, lq.CHAN_VOICE, S("weapons/spike2.wav"), 1, lq.ATTN_NORM);
        weapons.launch_spike(self.origin, self.movedir);
        lq.newmis.get().velocity = q.scale(self.movedir, 500);

        if (q.has(self.spawnflags, SPAWNFLAG_SUPERSPIKE))
            lq.newmis.get().touch = q.func(weapons.superspike_touch);
    }
}

pub export fn shooter_think() void {
    const self = q.me();
    spikeshooter_use();
    self.nextthink = q.time.get() + self.get(lq.wait);
    lq.newmis.get().velocity = q.scale(self.movedir, 500);
}

/// QUAKED trap_spikeshooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
/// When triggered, fires a spike in the direction set in QuakeEd.
/// Laser is only for REGISTERED.
pub export fn trap_spikeshooter() void {
    const self = q.me();
    subs.SetMovedir();
    self.use = q.func(spikeshooter_use);

    //gnounc
    self.netname = S("spike trap");

    if (q.has(self.spawnflags, SPAWNFLAG_LASER)) {
        self.set(lq.killstring, S(loc.LOC_DEATH_TRAP_LASER));

        _ = q.precache_model2(S("progs/laser.mdl"));

        _ = q.precache_sound2(S("enforcer/enfire.wav"));
        _ = q.precache_sound2(S("enforcer/enfstop.wav"));
    } else {
        self.set(lq.killstring, S(loc.LOC_DEATH_TRAP_SPIKE));
        _ = q.precache_sound(S("weapons/spike2.wav"));
    }
}

/// QUAKED trap_shooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
/// Continuously fires spikes.
/// "wait" time between spike (1.0 default)
/// "nextthink" delay before firing first spike, so multiple shooters can be stagered.
pub export fn trap_shooter() void {
    const self = q.me();
    trap_spikeshooter();

    if (self.get(lq.wait) == 0)
        self.set(lq.wait, 1);

    self.nextthink = self.nextthink + self.get(lq.wait) + self.ltime;
    self.think = q.func(shooter_think);
}

// ===============================================================================
//
//
// ===============================================================================

/// QUAKED air_bubbles (0 .5 .8) (-8 -8 -8) (8 8 8)
///
/// testing air bubbles
pub export fn air_bubbles() void {
    const self = q.me();
    if (q.deathmatch.get() != 0) {
        q.remove(self);
        return;
    }

    _ = q.precache_model(S("progs/s_bubble.spr"));
    self.nextthink = q.time.get() + 1;
    self.think = q.func(make_bubbles);
}

pub export fn make_bubbles() void {
    const self = q.me();

    const bubble = q.spawn();
    q.setmodel(bubble, S("progs/s_bubble.spr"));
    q.setorigin(bubble, self.origin);
    bubble.movetype = lq.MOVETYPE_NOCLIP;
    bubble.solid = lq.SOLID_NOT;
    bubble.velocity = q.vec(0, 0, 15);
    bubble.nextthink = q.time.get() + 0.5;
    bubble.think = q.func(bubble_bob);
    bubble.touch = q.func(bubble_remove);
    bubble.classname = S("bubble");
    bubble.frame = 0;
    bubble.set(lq.cnt, 0);
    q.setsize(bubble, q.vec(-8, -8, -8), q.vec(8, 8, 8));
    self.nextthink = q.time.get() + q.random() + 0.5;
    self.think = q.func(make_bubbles);
}

pub export fn bubble_split() void {
    const self = q.me();
    const bubble = q.spawn();
    q.setmodel(bubble, S("progs/s_bubble.spr"));
    q.setorigin(bubble, self.origin);
    bubble.movetype = lq.MOVETYPE_NOCLIP;
    bubble.solid = lq.SOLID_NOT;
    bubble.velocity = self.velocity;
    bubble.nextthink = q.time.get() + 0.5;
    bubble.think = q.func(bubble_bob);
    bubble.touch = q.func(bubble_remove);
    bubble.classname = S("bubble");
    bubble.frame = 1;
    bubble.set(lq.cnt, 10);
    q.setsize(bubble, q.vec(-8, -8, -8), q.vec(8, 8, 8));
    self.frame = 1;
    self.set(lq.cnt, 10);

    if (self.waterlevel != 3)
        q.remove(self);
}

pub export fn bubble_remove() void {
    const self = q.me();
    if (q.other.get().classname.eql(self.classname))
        return;

    q.remove(self);
}

pub export fn bubble_bob() void {
    const self = q.me();

    self.set(lq.cnt, self.get(lq.cnt) + 1);
    if (self.get(lq.cnt) == 4)
        bubble_split();

    if (self.get(lq.cnt) == 20)
        q.remove(self);

    var rnd1 = self.velocity[0] + (-10 + (q.random() * 20));
    var rnd2 = self.velocity[1] + (-10 + (q.random() * 20));
    var rnd3 = self.velocity[2] + 10 + q.random() * 10;

    if (rnd1 > 10)
        rnd1 = 5;

    if (rnd1 < -10)
        rnd1 = -5;

    if (rnd2 > 10)
        rnd2 = 5;

    if (rnd2 < -10)
        rnd2 = -5;

    if (rnd3 < 10)
        rnd3 = 15;

    if (rnd3 > 30)
        rnd3 = 25;

    self.velocity[0] = rnd1;
    self.velocity[1] = rnd2;
    self.velocity[2] = rnd3;

    self.nextthink = q.time.get() + 0.5;
    self.think = q.func(bubble_bob);
}

// ~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>
// ~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~

/// QUAKED viewthing (0 .5 .8) (-8 -8 -8) (8 8 8)
///
/// Just for the debugging level.  Don't use
pub export fn viewthing() void {
    const self = q.me();
    self.movetype = lq.MOVETYPE_NONE;
    self.solid = lq.SOLID_NOT;
    _ = q.precache_model(S("progs/player.mdl"));
    q.setmodel(self, S("progs/player.mdl"));
}

// ==============================================================================
//
// SIMPLE BMODELS
//
// ==============================================================================

pub export fn func_wall_use() void { // change to alternate textures
    const self = q.me();
    self.frame = 1 - self.frame;
}

/// QUAKED func_wall (0 .5 .8) ?
/// This is just a solid wall if not inhibitted
pub export fn func_wall() void {
    const self = q.me();
    self.angles = q.vec(0, 0, 0);
    self.movetype = lq.MOVETYPE_PUSH; // so it doesn't get pushed by anything
    self.solid = lq.SOLID_BSP;
    self.use = q.func(func_wall_use);
    q.setmodel(self, self.model);
}

/// QUAKED func_illusionary (0 .5 .8) ?
/// A simple entity that looks solid but lets you walk through it.
pub export fn func_illusionary() void {
    const self = q.me();
    self.angles = q.vec(0, 0, 0);
    self.movetype = lq.MOVETYPE_NONE;
    self.solid = lq.SOLID_NOT;
    q.setmodel(self, self.model);
    q.makestatic(self);
}

/// QUAKED func_episodegate (0 .5 .8) ? E1 E2 E3 E4
/// This bmodel will appear if the episode has allready been completed, so players can't reenter it.
pub export fn func_episodegate() void {
    const self = q.me();
    if (!q.has(q.serverflags.get(), self.spawnflags))
        return; // can still enter episode

    self.angles = q.vec(0, 0, 0);
    self.movetype = lq.MOVETYPE_PUSH; // so it doesn't get pushed by anything
    self.solid = lq.SOLID_BSP;
    self.use = q.func(func_wall_use);
    q.setmodel(self, self.model);
}

/// QUAKED func_bossgate (0 .5 .8) ?
/// This bmodel appears unless players have all of the episode sigils.
pub export fn func_bossgate() void {
    const self = q.me();
    if (q.band(q.serverflags.get(), 15) == 15)
        return; // all episodes completed

    self.angles = q.vec(0, 0, 0);
    self.movetype = lq.MOVETYPE_PUSH; // so it doesn't get pushed by anything
    self.solid = lq.SOLID_BSP;
    self.use = q.func(func_wall_use);
    q.setmodel(self, self.model);
}

//============================================================================
/// QUAKED ambient_suck_wind (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
pub export fn ambient_suck_wind() void {
    _ = q.precache_sound(S("ambience/suck1.wav"));
    q.ambientsound(q.me().origin, S("ambience/suck1.wav"), 1, lq.ATTN_STATIC);
}

/// QUAKED ambient_drone (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
pub export fn ambient_drone() void {
    _ = q.precache_sound(S("ambience/drone6.wav"));
    q.ambientsound(q.me().origin, S("ambience/drone6.wav"), 0.5, lq.ATTN_STATIC);
}

/// QUAKED ambient_flouro_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
pub export fn ambient_flouro_buzz() void {
    _ = q.precache_sound(S("ambience/buzz1.wav"));
    q.ambientsound(q.me().origin, S("ambience/buzz1.wav"), 1, lq.ATTN_STATIC);
}

/// QUAKED ambient_drip (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
pub export fn ambient_drip() void {
    _ = q.precache_sound(S("ambience/drip1.wav"));
    q.ambientsound(q.me().origin, S("ambience/drip1.wav"), 0.5, lq.ATTN_STATIC);
}

/// QUAKED ambient_comp_hum (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
pub export fn ambient_comp_hum() void {
    _ = q.precache_sound(S("ambience/comp1.wav"));
    q.ambientsound(q.me().origin, S("ambience/comp1.wav"), 1, lq.ATTN_STATIC);
}

/// QUAKED ambient_thunder (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
pub export fn ambient_thunder() void {
    const self = q.me();
    _ = q.precache_sound(S("ambience/thunder1.wav"));

    if (self.targetname.neq(lq.string_null.get())) {
        self.use = q.func(thunder_think);
    } else {
        self.nextthink = q.time.get() + q.random() * 10 + 1;
        self.think = q.func(thunder_think);
    }
}

pub export fn thunder_think() void {
    const self = q.me();
    q.sound(self, lq.CHAN_VOICE, S("ambience/thunder1.wav"), 1, 0.5);

    if (self.targetname.isNull()) {
        self.nextthink = q.time.get() + q.random() * 10 + 1;
        self.think = q.func(thunder_think);
    }
}

/// QUAKED ambient_light_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
pub export fn ambient_light_buzz() void {
    _ = q.precache_sound(S("ambience/fl_hum1.wav"));
    q.ambientsound(q.me().origin, S("ambience/fl_hum1.wav"), 0.5, lq.ATTN_STATIC);
}

/// QUAKED ambient_swamp1 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
pub export fn ambient_swamp1() void {
    _ = q.precache_sound(S("ambience/swamp1.wav"));
    q.ambientsound(q.me().origin, S("ambience/swamp1.wav"), 0.5, lq.ATTN_STATIC);
}

/// QUAKED ambient_swamp2 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
pub export fn ambient_swamp2() void {
    _ = q.precache_sound(S("ambience/swamp2.wav"));
    q.ambientsound(q.me().origin, S("ambience/swamp2.wav"), 0.5, lq.ATTN_STATIC);
}

//============================================================================

pub export fn noise_think() void {
    const self = q.me();
    self.nextthink = q.time.get() + 0.5;
    q.sound(self, 1, S("enforcer/enfire.wav"), 1, lq.ATTN_NORM);
    q.sound(self, 2, S("enforcer/enfstop.wav"), 1, lq.ATTN_NORM);
    q.sound(self, 3, S("enforcer/sight1.wav"), 1, lq.ATTN_NORM);
    q.sound(self, 4, S("enforcer/sight2.wav"), 1, lq.ATTN_NORM);
    q.sound(self, 5, S("enforcer/sight3.wav"), 1, lq.ATTN_NORM);
    q.sound(self, 6, S("enforcer/sight4.wav"), 1, lq.ATTN_NORM);
    q.sound(self, 7, S("enforcer/pain1.wav"), 1, lq.ATTN_NORM);
}

/// QUAKED misc_noisemaker (1 0.5 0) (-10 -10 -10) (10 10 10)
///
/// For optimzation testing, starts a lot of sounds.
pub export fn misc_noisemaker() void {
    const self = q.me();
    _ = q.precache_sound2(S("enforcer/enfire.wav"));
    _ = q.precache_sound2(S("enforcer/enfstop.wav"));
    _ = q.precache_sound2(S("enforcer/sight1.wav"));
    _ = q.precache_sound2(S("enforcer/sight2.wav"));
    _ = q.precache_sound2(S("enforcer/sight3.wav"));
    _ = q.precache_sound2(S("enforcer/sight4.wav"));
    _ = q.precache_sound2(S("enforcer/pain1.wav"));
    _ = q.precache_sound2(S("enforcer/pain2.wav"));
    _ = q.precache_sound2(S("enforcer/death1.wav"));
    _ = q.precache_sound2(S("enforcer/idle1.wav"));

    self.nextthink = q.time.get() + 0.1 + q.random();
    self.think = q.func(noise_think);
}
