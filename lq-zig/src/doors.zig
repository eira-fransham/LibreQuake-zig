//! doors.qc
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
const Entity = q.Entity;
const Vector = q.Vector;
const combat = @import("combat.zig");
const subs = @import("subs.zig");

pub const DOOR_START_OPEN: f32 = 1;

pub const DOOR_DONT_LINK: f32 = 4;

pub const DOOR_GOLD_KEY: f32 = 8;

pub const DOOR_SILVER_KEY: f32 = 16;

pub const DOOR_TOGGLE: f32 = 32;

// Doors are similar to buttons, but can spawn a fat trigger field around them
// to open without a touch, and they link together to form simultanious
// double/quad doors.
//
// Door.owner is the master door.  If there is only one door, it points to itself.
// If multiple doors, all will point to a single one.
//
// Door.enemy chains from the master door through all doors linked in the chain.

// =============================================================================
//
// THINK FUNCTIONS
//
// =============================================================================

pub export fn door_blocked() void {
    const self = q.me();
    const other = q.other.get();
    other.set(lq.deathtype, S("squish"));
    combat.T_Damage(other, self, self.goalentity, self.get(lq.dmg));

    // if a door has a negative wait, it would never come back if blocked,
    // so let it just squash the object to death real fast
    if (self.get(lq.wait) >= 0) {
        if (self.get(lq.state) == lq.STATE_DOWN) {
            door_go_up();
        } else door_go_down();
    }
}

pub export fn door_hit_top() void {
    const self = q.me();
    q.sound(self, lq.CHAN_NO_PHS_ADD + lq.CHAN_VOICE, self.noise1, 1, lq.ATTN_NORM);
    self.set(lq.state, lq.STATE_TOP);

    if (q.has(self.spawnflags, DOOR_TOGGLE))
        return; // don't come down automatically

    self.think = q.func(door_go_down);
    self.nextthink = self.ltime + self.get(lq.wait);
}

pub export fn door_hit_bottom() void {
    const self = q.me();
    q.sound(self, lq.CHAN_NO_PHS_ADD + lq.CHAN_VOICE, self.noise1, 1, lq.ATTN_NORM);
    self.set(lq.state, lq.STATE_BOTTOM);
}

pub export fn door_go_down() void {
    const self = q.me();
    q.sound(self, lq.CHAN_VOICE, self.noise2, 1, lq.ATTN_NORM);

    if (self.max_health != 0) {
        self.takedamage = lq.DAMAGE_YES;
        self.health = self.max_health;
    }

    self.set(lq.state, lq.STATE_DOWN);
    subs.SUB_CalcMove(self.get(lq.pos1), self.get(lq.speed), q.func(door_hit_bottom));
}

pub export fn door_go_up() void {
    const self = q.me();
    if (self.get(lq.state) == lq.STATE_UP)
        return; // allready going up

    if (self.get(lq.state) == lq.STATE_TOP) { // reset top wait time
        self.nextthink = self.ltime + self.get(lq.wait);
        return;
    }

    q.sound(self, lq.CHAN_VOICE, self.noise2, 1, lq.ATTN_NORM);
    self.set(lq.state, lq.STATE_UP);
    subs.SUB_CalcMove(self.get(lq.pos2), self.get(lq.speed), q.func(door_hit_top));

    subs.SUB_UseTargets();
}

// =============================================================================
//
// ACTIVATION FUNCTIONS
//
// =============================================================================

pub export fn door_fire() void {
    var self = q.me();

    if (self.owner.neq(self))
        q.objerror(S("door_fire: self.owner != self"));

    // play use key sound
    if (self.items != 0)
        q.sound(self, lq.CHAN_ITEM, self.get(lq.noise4), 1, lq.ATTN_NORM); // gb, door unlock sound bugfix

    self.message = lq.string_null.get(); // no more message
    const oself = self;

    if (q.has(self.spawnflags, DOOR_TOGGLE)) {
        if (self.get(lq.state) == lq.STATE_UP or self.get(lq.state) == lq.STATE_TOP) {
            const starte = self;
            while (true) {
                door_go_down();
                q.self.set(q.me().enemy);
                self = q.me();
                if (!((self.neq(starte)) and (self.neq(q.world.get())))) break;
            }

            q.self.set(oself);
            return;
        }
    }

    // trigger all paired doors
    const starte = self;
    while (true) {
        self.goalentity = lq.activator.get(); // Who fired us
        door_go_up();
        q.self.set(q.me().enemy);
        self = q.me();
        if (!((self.neq(starte)) and (self.neq(q.world.get())))) break;
    }

    q.self.set(oself);
}

pub export fn door_use() void {
    const self = q.me();

    self.message = lq.string_null.get(); // door message are for touch only
    self.owner.message = lq.string_null.get();
    self.enemy.message = lq.string_null.get();
    const oself = self;
    q.self.set(self.owner);
    door_fire();
    q.self.set(oself);
}

pub export fn door_trigger_touch() void {
    const self = q.me();
    const other = q.other.get();
    if (other.health <= 0)
        return;

    if (q.time.get() < self.get(lq.attack_finished))
        return;

    self.set(lq.attack_finished, q.time.get() + 1);

    lq.activator.set(other);

    q.self.set(self.owner);
    door_use();
}

pub export fn door_killed() void {
    const oself = q.self.get();
    q.self.set(oself.owner);
    const self = q.me();
    self.health = self.max_health;
    self.takedamage = lq.DAMAGE_NO; // wil be reset upon return
    door_use();
    q.self.set(oself);
}

/// door_touch
///
/// Prints messages and opens key doors
pub export fn door_touch() void {
    const self = q.me();
    const other = q.other.get();
    if (other.classname.neq(S("player")))
        return;

    if (self.owner.get(lq.attack_finished) > q.time.get())
        return;

    self.owner.set(lq.attack_finished, q.time.get() + 2);

    if (self.owner.message.neq(lq.string_null.get())) {
        q.centerprint(other, self.owner.message);
        q.sound(other, lq.CHAN_VOICE, S("misc/talk.wav"), 1, lq.ATTN_NORM);
    }

    // key door stuff
    if (self.items == 0)
        return;

    // FIXME: blink key on player's status bar
    if (q.band(self.items, other.items) != self.items) {
        const worldtype = q.world.get().get(lq.worldtype);
        if (self.owner.items == lq.IT_KEY1) {
            if (worldtype == 2) {
                q.centerprint3(other, S(loc.LOC_KEY_NEED), S("the "), S(loc.LOC_KEY_NAME_SILVER_CARD));
                q.sound(self, lq.CHAN_VOICE, self.noise3, 1, lq.ATTN_NORM);
            } else if (worldtype == 1) {
                q.centerprint3(other, S(loc.LOC_KEY_NEED), S("the "), S(loc.LOC_KEY_NAME_SILVER_RUNE));
                q.sound(self, lq.CHAN_VOICE, self.noise3, 1, lq.ATTN_NORM);
            } else if (worldtype == 0) {
                q.centerprint3(other, S(loc.LOC_KEY_NEED), S("the "), S(loc.LOC_KEY_NAME_SILVER));
                q.sound(self, lq.CHAN_VOICE, self.noise3, 1, lq.ATTN_NORM);
            }
        } else {
            if (worldtype == 2) {
                q.centerprint3(other, S(loc.LOC_KEY_NEED), S("the "), S(loc.LOC_KEY_NAME_GOLD_CARD));
                q.sound(self, lq.CHAN_VOICE, self.noise3, 1, lq.ATTN_NORM);
            } else if (worldtype == 1) {
                q.centerprint3(other, S(loc.LOC_KEY_NEED), S("the "), S(loc.LOC_KEY_NAME_GOLD_RUNE));
                q.sound(self, lq.CHAN_VOICE, self.noise3, 1, lq.ATTN_NORM);
            } else if (worldtype == 0) {
                q.centerprint3(other, S(loc.LOC_KEY_NEED), S("the "), S(loc.LOC_KEY_NAME_GOLD));
                q.sound(self, lq.CHAN_VOICE, self.noise3, 1, lq.ATTN_NORM);
            }
        }

        return;
    }

    other.items = other.items - self.items;
    self.touch = null;

    if (!self.enemy.isNull())
        self.enemy.touch = null; // get paired door

    door_use();
}

// =============================================================================
//
// SPAWNING FUNCTIONS
//
// =============================================================================

pub export fn spawn_field(fmins: Vector, fmaxs: Vector) Entity {
    const self = q.me();

    const trigger = q.spawn();
    trigger.movetype = lq.MOVETYPE_NONE;
    trigger.solid = lq.SOLID_TRIGGER;
    trigger.owner = self;
    trigger.touch = q.func(door_trigger_touch);

    const t1 = fmins;
    const t2 = fmaxs;
    q.setsize(trigger, t1 - q.vec(60, 60, 8), t2 + q.vec(60, 60, 8));

    return (trigger);
}

pub export fn EntitiesTouching(e1: Entity, e2: Entity) f32 {
    if (e1.mins[0] > e2.maxs[0])
        return lq.FALSE;

    if (e1.mins[1] > e2.maxs[1])
        return lq.FALSE;

    if (e1.mins[2] > e2.maxs[2])
        return lq.FALSE;

    if (e1.maxs[0] < e2.mins[0])
        return lq.FALSE;

    if (e1.maxs[1] < e2.mins[1])
        return lq.FALSE;

    if (e1.maxs[2] < e2.mins[2])
        return lq.FALSE;

    return lq.TRUE;
}

/// LinkDoors
pub export fn LinkDoors() void {
    var self = q.me();

    if (!self.enemy.isNull())
        return; // already linked by another door

    if (q.has(self.spawnflags, 4)) {
        self.enemy = self;
        self.owner = self;
        return; // don't want to link this door
    }

    var cmins: Vector = self.mins;
    var cmaxs: Vector = self.maxs;

    const starte = self;
    var t = self;

    while (true) {
        self.owner = starte; // master door

        if (self.health != 0)
            starte.health = self.health;

        if (self.targetname.neq(lq.string_null.get()))
            starte.targetname = self.targetname;

        if (self.message.neq(lq.string_null.get()))
            starte.message = self.message;

        t = q.find(t, .classname, self.classname);
        if (t.isNull()) {
            self.enemy = starte; // make the chain a loop

            // shootable, fired, or key doors just needed the owner/enemy links,
            // they don't spawn a field
            q.self.set(self.owner);
            self = q.me();

            if (self.health != 0)
                return;

            if (self.targetname.neq(lq.string_null.get()))
                return;

            if (self.items != 0)
                return;

            self.owner.set(lq.trigger_field, spawn_field(cmins, cmaxs));

            return;
        }

        if (EntitiesTouching(self, t) != 0) {
            if (!t.enemy.isNull())
                q.objerror(S("cross connected doors"));

            self.enemy = t;
            q.self.set(t);
            self = q.me();

            if (t.mins[0] < cmins[0])
                cmins[0] = t.mins[0];

            if (t.mins[1] < cmins[1])
                cmins[1] = t.mins[1];

            if (t.mins[2] < cmins[2])
                cmins[2] = t.mins[2];

            if (t.maxs[0] > cmaxs[0])
                cmaxs[0] = t.maxs[0];

            if (t.maxs[1] > cmaxs[1])
                cmaxs[1] = t.maxs[1];

            if (t.maxs[2] > cmaxs[2])
                cmaxs[2] = t.maxs[2];
        }
    }
}

/// QUAKED func_door (0 .5 .8) ? START_OPEN x DOOR_DONT_LINK GOLD_KEY SILVER_KEY TOGGLE
/// if two doors touch, they are assumed to be connected and operate as a unit.
///
/// TOGGLE causes the door to wait in both the start and end states for a trigger event.
///
/// START_OPEN causes the door to move to its destination when spawned, and operate in reverse.  It is used to temporarily or permanently close off an area when triggered (not usefull for touch or takedamage doors).
///
/// Key doors are allways wait -1.
///
/// "message"    is printed when the door is touched if it is a trigger door and it hasn't been fired yet
/// "angle"      determines the opening direction
/// "targetname" if set, no touch field will be spawned and a remote button or trigger field activates the door.
/// "health"     if set, door must be shot open
/// "speed"      movement speed (100 default)
/// "wait"       wait before returning (3 default, -1 = never return)
/// "lip"        lip remaining at end of move (8 default)
/// "dmg"        damage to inflict when blocked (2 default)
/// "sounds"
/// 0)  no sound
/// 1)  stone
/// 2)  base
/// 3)  stone chain
/// 4)  screechy metal
pub export fn func_door() void {
    const self = q.me();

    const worldtype = q.world.get().get(lq.worldtype);
    if (worldtype == 0) {
        _ = q.precache_sound(S("doors/medtry.wav"));
        _ = q.precache_sound(S("doors/meduse.wav"));
        self.noise3 = S("doors/medtry.wav");
        self.set(lq.noise4, S("doors/meduse.wav"));
    } else if (worldtype == 1) {
        _ = q.precache_sound(S("doors/runetry.wav"));
        _ = q.precache_sound(S("doors/runeuse.wav"));
        self.noise3 = S("doors/runetry.wav");
        self.set(lq.noise4, S("doors/runeuse.wav"));
    } else if (worldtype == 2) {
        _ = q.precache_sound(S("doors/basetry.wav"));
        _ = q.precache_sound(S("doors/baseuse.wav"));
        self.noise3 = S("doors/basetry.wav");
        self.set(lq.noise4, S("doors/baseuse.wav"));
    } else {
        q.dprint(S("no worldtype set!\n"));
    }

    if (self.sounds == 0) {
        _ = q.precache_sound(S("misc/null.wav"));
        _ = q.precache_sound(S("misc/null.wav"));
        self.noise1 = S("misc/null.wav");
        self.noise2 = S("misc/null.wav");
    }

    if (self.sounds == 1) {
        _ = q.precache_sound(S("doors/drclos4.wav"));
        _ = q.precache_sound(S("doors/doormv1.wav"));
        self.noise1 = S("doors/drclos4.wav");
        self.noise2 = S("doors/doormv1.wav");
    }

    if (self.sounds == 2) {
        _ = q.precache_sound(S("doors/hydro1.wav"));
        _ = q.precache_sound(S("doors/hydro2.wav"));
        self.noise2 = S("doors/hydro1.wav");
        self.noise1 = S("doors/hydro2.wav");
    }

    if (self.sounds == 3) {
        _ = q.precache_sound(S("doors/stndr1.wav"));
        _ = q.precache_sound(S("doors/stndr2.wav"));
        self.noise2 = S("doors/stndr1.wav");
        self.noise1 = S("doors/stndr2.wav");
    }

    if (self.sounds == 4) {
        _ = q.precache_sound(S("doors/ddoor1.wav"));
        _ = q.precache_sound(S("doors/ddoor2.wav"));
        self.noise1 = S("doors/ddoor2.wav");
        self.noise2 = S("doors/ddoor1.wav");
    }

    subs.SetMovedir();

    self.max_health = self.health;
    self.solid = lq.SOLID_BSP;
    self.movetype = lq.MOVETYPE_PUSH;
    q.setorigin(self, self.origin);
    q.setmodel(self, self.model);
    self.classname = S("door");

    self.blocked = q.func(door_blocked);
    self.use = q.func(door_use);

    if (q.has(self.spawnflags, DOOR_SILVER_KEY))
        self.items = lq.IT_KEY1;

    if (q.has(self.spawnflags, DOOR_GOLD_KEY))
        self.items = lq.IT_KEY2;

    if (self.get(lq.speed) == 0)
        self.set(lq.speed, 100);

    if (self.get(lq.wait) == 0)
        self.set(lq.wait, 3);

    if (self.get(lq.lip) == 0)
        self.set(lq.lip, 8);

    if (self.get(lq.dmg) == 0)
        self.set(lq.dmg, 2);

    self.set(lq.pos1, self.origin);
    self.set(lq.pos2, self.get(lq.pos1) + q.scale(self.movedir, q.fabs(q.dot(self.movedir, self.size)) - self.get(lq.lip)));

    // DOOR_START_OPEN is to allow an entity to be lighted in the closed position
    // but spawn in the open position
    if (q.has(self.spawnflags, DOOR_START_OPEN)) {
        q.setorigin(self, self.get(lq.pos2));
        self.set(lq.pos2, self.get(lq.pos1));
        self.set(lq.pos1, self.origin);
    }

    self.set(lq.state, lq.STATE_BOTTOM);

    if (self.health != 0) {
        self.takedamage = lq.DAMAGE_YES;
        self.set(lq.th_die, q.func(door_killed));
    }

    if (self.items != 0)
        self.set(lq.wait, -1);

    self.touch = q.func(door_touch);

    // LinkDoors can't be done until all of the doors have been spawned, so
    // the sizes can be detected properly.
    self.think = q.func(LinkDoors);
    self.nextthink = self.ltime + 0.1;
}

// =============================================================================
//
// SECRET DOORS
//
// =============================================================================

pub const SECRET_OPEN_ONCE: f32 = 1; // stays open

pub const SECRET_1ST_LEFT: f32 = 2; // 1st move is left of arrow

pub const SECRET_1ST_DOWN: f32 = 4; // 1st move is down from arrow

pub const SECRET_NO_SHOOT: f32 = 8; // only opened by trigger

pub const SECRET_YES_SHOOT: f32 = 16; // shootable even if targeted

pub export fn fd_secret_use() void {
    const self = q.me();

    self.health = 10000;

    // exit if still moving around...
    if (!q.veq(self.origin, self.oldorigin))
        return;

    self.message = lq.string_null.get(); // no more message

    subs.SUB_UseTargets(); // fire all targets / killtargets

    if (!q.has(self.spawnflags, SECRET_NO_SHOOT)) {
        self.set(lq.th_pain, null);
        self.takedamage = lq.DAMAGE_NO;
    }

    self.velocity = q.vec(0, 0, 0);

    // Make a sound, wait a little...
    q.sound(self, lq.CHAN_VOICE, self.noise1, 1, lq.ATTN_NORM);
    self.nextthink = self.ltime + 0.1;

    const temp = 1 - q.band(self.spawnflags, SECRET_1ST_LEFT); // 1 or -1
    q.makevectors(self.get(lq.mangle));

    if (self.get(lq.t_width) == 0) {
        if (q.has(self.spawnflags, SECRET_1ST_DOWN)) {
            self.set(lq.t_width, q.fabs(q.dot(q.v_up.get(), self.size)));
        } else self.set(lq.t_width, q.fabs(q.dot(q.v_right.get(), self.size)));
    }

    if (self.get(lq.t_length) == 0)
        self.set(lq.t_length, q.fabs(q.dot(q.v_forward.get(), self.size)));

    if (q.has(self.spawnflags, SECRET_1ST_DOWN)) {
        self.set(lq.dest1, self.origin - q.scale(q.v_up.get(), self.get(lq.t_width)));
    } else self.set(lq.dest1, self.origin + q.scale(q.v_right.get(), self.get(lq.t_width) * temp));

    self.set(lq.dest2, self.get(lq.dest1) + q.scale(q.v_forward.get(), self.get(lq.t_length)));
    subs.SUB_CalcMove(self.get(lq.dest1), self.get(lq.speed), q.func(fd_secret_move1));
    q.sound(self, lq.CHAN_VOICE, self.noise2, 1, lq.ATTN_NORM);
}

/// Wait after first movement...
pub export fn fd_secret_move1() void {
    const self = q.me();
    self.nextthink = self.ltime + 1.0;
    self.think = q.func(fd_secret_move2);
    q.sound(self, lq.CHAN_VOICE, self.noise3, 1, lq.ATTN_NORM);
}

/// Start moving sideways w/sound...
pub export fn fd_secret_move2() void {
    const self = q.me();
    q.sound(self, lq.CHAN_VOICE, self.noise2, 1, lq.ATTN_NORM);
    subs.SUB_CalcMove(self.get(lq.dest2), self.get(lq.speed), q.func(fd_secret_move3));
}

/// Wait here until time to go back...
pub export fn fd_secret_move3() void {
    const self = q.me();
    q.sound(self, lq.CHAN_VOICE, self.noise3, 1, lq.ATTN_NORM);

    if (!q.has(self.spawnflags, SECRET_OPEN_ONCE)) {
        self.nextthink = self.ltime + self.get(lq.wait);
        self.think = q.func(fd_secret_move4);
    }
}

/// Move backward...
pub export fn fd_secret_move4() void {
    const self = q.me();
    q.sound(self, lq.CHAN_VOICE, self.noise2, 1, lq.ATTN_NORM);
    subs.SUB_CalcMove(self.get(lq.dest1), self.get(lq.speed), q.func(fd_secret_move5));
}

/// Wait 1 second...
pub export fn fd_secret_move5() void {
    const self = q.me();
    self.nextthink = self.ltime + 1.0;
    self.think = q.func(fd_secret_move6);
    q.sound(self, lq.CHAN_VOICE, self.noise3, 1, lq.ATTN_NORM);
}

pub export fn fd_secret_move6() void {
    const self = q.me();
    q.sound(self, lq.CHAN_VOICE, self.noise2, 1, lq.ATTN_NORM);
    subs.SUB_CalcMove(self.oldorigin, self.get(lq.speed), q.func(fd_secret_done));
}

pub export fn fd_secret_done() void {
    const self = q.me();
    if (self.targetname.isNull() or q.has(self.spawnflags, SECRET_YES_SHOOT)) {
        self.health = 10000;
        self.takedamage = lq.DAMAGE_YES;
        self.set(lq.th_pain, q.func(fd_secret_use));
        self.set(lq.th_die, q.func(fd_secret_use)); //copypasta'd directly from gpl'd qw source on github. -- secret door kill crash fix
    }
    q.sound(self, lq.CHAN_NO_PHS_ADD + lq.CHAN_VOICE, self.noise3, 1, lq.ATTN_NORM);
}

pub export fn secret_blocked() void {
    const self = q.me();
    if (q.time.get() < self.get(lq.attack_finished))
        return;

    self.set(lq.attack_finished, q.time.get() + 0.5);
    const other = q.other.get();
    other.set(lq.deathtype, S("squish"));
    combat.T_Damage(other, self, self, self.get(lq.dmg));
}

/// secret_touch
///
/// Prints messages
pub export fn secret_touch() void {
    const self = q.me();
    const other = q.other.get();
    if (other.classname.neq(S("player")))
        return;

    if (self.get(lq.attack_finished) > q.time.get())
        return;

    self.set(lq.attack_finished, q.time.get() + 2);

    if (self.message.neq(lq.string_null.get())) {
        q.centerprint(other, self.message);
        q.sound(other, lq.CHAN_BODY, S("misc/talk.wav"), 1, lq.ATTN_NORM);
    }
}

/// QUAKED func_door_secret (0 .5 .8) ? open_once 1st_left 1st_down no_shoot always_shoot
/// Basic secret door. Slides back, then to the side. Angle determines direction.
/// wait  = # of seconds before coming back
/// 1st_left = 1st move is left of arrow
/// 1st_down = 1st move is down from arrow
/// always_shoot = even if targeted, keep shootable
/// t_width = override WIDTH to move back (or height if going down)
/// t_length = override LENGTH to move sideways
/// "dmg"        damage to inflict when blocked (2 default)
///
/// If a secret door has a targetname, it will only be opened by it's botton or trigger, not by damage.
/// "sounds"
/// 1) medieval
/// 2) metal
/// 3) base
pub export fn func_door_secret() void {
    const self = q.me();

    if (self.sounds == 0)
        self.sounds = 3;

    if (self.sounds == 1) {
        _ = q.precache_sound(S("doors/latch2.wav"));
        _ = q.precache_sound(S("doors/winch2.wav"));
        _ = q.precache_sound(S("doors/drclos4.wav"));
        self.noise1 = S("doors/latch2.wav");
        self.noise2 = S("doors/winch2.wav");
        self.noise3 = S("doors/drclos4.wav");
    }

    if (self.sounds == 2) {
        _ = q.precache_sound(S("doors/airdoor1.wav"));
        _ = q.precache_sound(S("doors/airdoor2.wav"));
        self.noise2 = S("doors/airdoor1.wav");
        self.noise1 = S("doors/airdoor2.wav");
        self.noise3 = S("doors/airdoor2.wav");
    }

    if (self.sounds == 3) {
        _ = q.precache_sound(S("doors/basesec1.wav"));
        _ = q.precache_sound(S("doors/basesec2.wav"));
        self.noise2 = S("doors/basesec1.wav");
        self.noise1 = S("doors/basesec2.wav");
        self.noise3 = S("doors/basesec2.wav");
    }

    if (self.get(lq.dmg) == 0)
        self.set(lq.dmg, 2);

    // Magic formula...
    self.set(lq.mangle, self.angles);
    self.angles = q.vec(0, 0, 0);
    self.solid = lq.SOLID_BSP;
    self.movetype = lq.MOVETYPE_PUSH;
    self.classname = S("door");
    q.setmodel(self, self.model);
    q.setorigin(self, self.origin);

    self.touch = q.func(secret_touch);
    self.blocked = q.func(secret_blocked);
    self.set(lq.speed, 50);
    self.use = q.func(fd_secret_use);

    if (self.targetname.isNull() or q.has(self.spawnflags, SECRET_YES_SHOOT)) {
        self.health = 10000;
        self.takedamage = lq.DAMAGE_YES;
        self.set(lq.th_pain, q.func(fd_secret_use));
    }

    self.oldorigin = self.origin;

    if (self.get(lq.wait) == 0)
        self.set(lq.wait, 5); // 5 seconds before closing
}
