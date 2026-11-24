//! plats.qc
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
const Vector = q.Vector;
const combat = @import("combat.zig");
const subs = @import("subs.zig");

pub const PLAT_LOW_TRIGGER: f32 = 1;

pub export fn plat_spawn_inside_trigger() void {
    const self = q.me();

    //
    // middle trigger
    //
    const trigger = q.spawn();
    trigger.touch = q.func(plat_center_touch);
    trigger.movetype = lq.MOVETYPE_NONE;
    trigger.solid = lq.SOLID_TRIGGER;
    trigger.enemy = self;

    var tmin = self.mins + q.vec(25, 25, 0);
    var tmax = self.maxs - q.vec(25, 25, -8);
    tmin[2] = tmax[2] - (self.get(lq.pos1)[2] - self.get(lq.pos2)[2] + 8);

    if (q.has(self.spawnflags, PLAT_LOW_TRIGGER))
        tmax[2] = tmin[2] + 8;

    if (self.size[0] <= 50) {
        tmin[0] = (self.mins[0] + self.maxs[0]) / 2;
        tmax[0] = tmin[0] + 1;
    }

    if (self.size[1] <= 50) {
        tmin[1] = (self.mins[1] + self.maxs[1]) / 2;
        tmax[1] = tmin[1] + 1;
    }

    q.setsize(trigger, tmin, tmax);
}

pub export fn plat_hit_top() void {
    const self = q.me();
    q.sound(self, lq.CHAN_NO_PHS_ADD + lq.CHAN_VOICE, self.noise1, 1, lq.ATTN_NORM);
    self.set(lq.state, lq.STATE_TOP);
    self.think = q.func(plat_go_down);
    self.nextthink = self.ltime + 3;
}

pub export fn plat_hit_bottom() void {
    const self = q.me();
    q.sound(self, lq.CHAN_NO_PHS_ADD + lq.CHAN_VOICE, self.noise1, 1, lq.ATTN_NORM);
    self.set(lq.state, lq.STATE_BOTTOM);
}

pub export fn plat_go_down() void {
    const self = q.me();
    q.sound(self, lq.CHAN_VOICE, self.noise, 1, lq.ATTN_NORM);
    self.set(lq.state, lq.STATE_DOWN);
    subs.SUB_CalcMove(self.get(lq.pos2), self.get(lq.speed), q.func(plat_hit_bottom));
}

pub export fn plat_go_up() void {
    const self = q.me();
    q.sound(self, lq.CHAN_VOICE, self.noise, 1, lq.ATTN_NORM);
    self.set(lq.state, lq.STATE_UP);
    subs.SUB_CalcMove(self.get(lq.pos1), self.get(lq.speed), q.func(plat_hit_top));
}

pub export fn plat_center_touch() void {
    const other = q.other.get();
    if (other.classname.neq(S("player")))
        return;

    if (other.health <= 0)
        return;

    q.self.set(q.me().enemy);
    const self = q.me();

    if (self.get(lq.state) == lq.STATE_BOTTOM) {
        plat_go_up();
    } else if (self.get(lq.state) == lq.STATE_TOP)
        self.nextthink = self.ltime + 1; // delay going down
}

pub export fn plat_outside_touch() void {
    const other = q.other.get();
    if (other.classname.neq(S("player")))
        return;

    if (other.health <= 0)
        return;

    q.self.set(q.me().enemy);
    const self = q.me();

    if (self.get(lq.state) == lq.STATE_TOP)
        plat_go_down();
}

pub export fn plat_trigger_use() void {
    if (!q.fnIsNull(q.me().think))
        return; // allready activated

    plat_go_down();
}

pub export fn plat_crush() void {
    const self = q.me();

    combat.T_Damage(q.other.get(), self, self, 1);

    if (self.get(lq.state) == lq.STATE_UP) {
        plat_go_down();
    } else if (self.get(lq.state) == lq.STATE_DOWN) {
        plat_go_up();
    } else q.objerror(S("plat_crush: bad self.state\n"));
}

pub export fn plat_use() void {
    const self = q.me();
    self.use = null;

    if (self.get(lq.state) != lq.STATE_UP)
        q.objerror(S("plat_use: not in up state"));

    plat_go_down();
}

/// QUAKED func_plat (0 .5 .8) ? PLAT_LOW_TRIGGER
/// speed default 150
///
/// Plats are always drawn in the extended position, so they will light correctly.
///
/// If the plat is the target of another trigger or button, it will start out disabled in the extended position until it is trigger, when it will lower and become a normal plat.
///
/// If the "height" key is set, that will determine the amount the plat moves, instead of being implicitly determined by the model's height.
/// Set "sounds" to one of the following:
/// 1) base fast
/// 2) chain slow
pub export fn func_plat() void {
    const self = q.me();

    if (self.get(lq.t_length) == 0)
        self.set(lq.t_length, 80);

    if (self.get(lq.t_width) == 0)
        self.set(lq.t_width, 10);

    if (self.sounds == 0)
        self.sounds = 2;
    // FIX THIS TO LOAD A GENERIC PLAT SOUND

    if (self.sounds == 1) {
        _ = q.precache_sound(S("plats/plat1.wav"));
        _ = q.precache_sound(S("plats/plat2.wav"));
        self.noise = S("plats/plat1.wav");
        self.noise1 = S("plats/plat2.wav");
    }

    if (self.sounds == 2) {
        _ = q.precache_sound(S("plats/medplat1.wav"));
        _ = q.precache_sound(S("plats/medplat2.wav"));
        self.noise = S("plats/medplat1.wav");
        self.noise1 = S("plats/medplat2.wav");
    }

    self.set(lq.mangle, self.angles);
    self.angles = q.vec(0, 0, 0);

    self.classname = S("plat");
    self.solid = lq.SOLID_BSP;
    self.movetype = lq.MOVETYPE_PUSH;
    q.setorigin(self, self.origin);
    q.setmodel(self, self.model);
    q.setsize(self, self.mins, self.maxs);

    self.blocked = q.func(plat_crush);

    if (self.get(lq.speed) == 0)
        self.set(lq.speed, 150);

    // pos1 is the top position, pos2 is the bottom
    self.set(lq.pos1, self.origin);
    self.set(lq.pos2, self.origin);

    if (self.get(lq.height) != 0) {
        var p = self.get(lq.pos2);
        p[2] = self.origin[2] - self.get(lq.height);
        self.set(lq.pos2, p);
    } else {
        var p = self.get(lq.pos2);
        p[2] = self.origin[2] - self.size[2] + 8;
        self.set(lq.pos2, p);
    }

    self.use = q.func(plat_trigger_use);

    plat_spawn_inside_trigger(); // the "start moving" trigger

    if (self.targetname.neq(lq.string_null.get())) {
        self.set(lq.state, lq.STATE_UP);
        self.use = q.func(plat_use);
    } else {
        q.setorigin(self, self.get(lq.pos2));
        self.set(lq.state, lq.STATE_BOTTOM);
    }
}

//============================================================================

pub export fn train_blocked() void {
    const self = q.me();
    if (q.time.get() < self.get(lq.attack_finished))
        return;

    self.set(lq.attack_finished, q.time.get() + 0.5);
    const other = q.other.get();
    other.set(lq.deathtype, S("squish"));
    combat.T_Damage(other, self, self, self.get(lq.dmg));
}

pub export fn train_use() void {
    if (q.fnNeq(q.me().think, q.func(func_train_find)))
        return; // already activated

    train_next();
}

pub export fn train_wait() void {
    const self = q.me();
    if (self.get(lq.wait) != 0) {
        self.nextthink = self.ltime + self.get(lq.wait);
        q.sound(self, lq.CHAN_NO_PHS_ADD + lq.CHAN_VOICE, self.noise, 1, lq.ATTN_NORM);
    } else self.nextthink = self.ltime + 0.1;

    self.think = q.func(train_next);
}

pub export fn train_next() void {
    const self = q.me();

    const targ = q.find(q.world.get(), .targetname, self.target);
    self.target = targ.target;

    if (self.target.isNull())
        q.objerror(S("train_next: no next target"));

    if (targ.get(lq.wait) != 0) {
        self.set(lq.wait, targ.get(lq.wait));
    } else self.set(lq.wait, 0);

    q.sound(self, lq.CHAN_VOICE, self.noise1, 1, lq.ATTN_NORM);
    subs.SUB_CalcMove(@as(Vector, targ.origin) - self.mins, self.get(lq.speed), q.func(train_wait));
}

pub export fn func_train_find() void {
    const self = q.me();

    const targ = q.find(q.world.get(), .targetname, self.target);
    self.target = targ.target;
    q.setorigin(self, @as(Vector, targ.origin) - self.mins);

    if (self.targetname.isNull()) { // not triggered, so start immediately
        self.nextthink = self.ltime + 0.1;
        self.think = q.func(train_next);
    }
}

/// QUAKED func_train (0 .5 .8) ?
/// Trains are moving platforms that players can ride.
/// The targets origin specifies the min point of the train at each corner.
/// The train spawns at the first target it is pointing at.
/// If the train is the target of a button or trigger, it will not begin moving until activated.
/// speed default 100
/// dmg  default 2
/// sounds
/// 1) ratchet metal
pub export fn func_train() void {
    const self = q.me();

    if (self.get(lq.speed) == 0)
        self.set(lq.speed, 100);

    if (self.target.isNull())
        q.objerror(S("func_train without a target"));

    if (self.get(lq.dmg) == 0)
        self.set(lq.dmg, 2);

    if (self.sounds == 0) {
        self.noise = (S("misc/null.wav"));
        _ = q.precache_sound(S("misc/null.wav"));
        self.noise1 = (S("misc/null.wav"));
        _ = q.precache_sound(S("misc/null.wav"));
    }

    if (self.sounds == 1) {
        self.noise = (S("plats/train2.wav"));
        _ = q.precache_sound(S("plats/train2.wav"));
        self.noise1 = (S("plats/train1.wav"));
        _ = q.precache_sound(S("plats/train1.wav"));
    }

    self.set(lq.cnt, 1);
    self.solid = lq.SOLID_BSP;
    self.movetype = lq.MOVETYPE_PUSH;
    self.blocked = q.func(train_blocked);
    self.use = q.func(train_use);
    self.classname = S("train");

    q.setmodel(self, self.model);
    q.setsize(self, self.mins, self.maxs);
    q.setorigin(self, self.origin);

    // start trains on the second frame, to make sure their targets have had
    // a chance to spawn
    self.nextthink = self.ltime + 0.1;
    self.think = q.func(func_train_find);
}

//Code for the fixed teleporttrain written by c0burn and modified by ZungryWare
pub export fn teleporttrain_next() void {
    const self = q.me();
    q.setorigin(self, self.enemy.origin + q.vec(16, 16, 16));

    if (self.target.isNull()) {
        self.enemy = q.world.get();
        return;
    }
    self.enemy = q.find(q.world.get(), .targetname, self.target);
    if (self.enemy.classname.eql(S("path_corner"))) {
        const dir = q.normalize((self.enemy.origin + q.vec(16, 16, 16)) - self.origin);
        self.velocity = q.scale(dir, self.get(lq.speed));
        self.target = self.enemy.target;
    } else {
        q.objerror(S("unable to find target\n"));
        q.remove(self);
    }
    teleporttrain_calcmove();
}

pub export fn teleporttrain_wait() void {
    const self = q.me();
    var wait_time: f32 = undefined;
    if (self.enemy.get(lq.wait) > 0) {
        wait_time = self.enemy.get(lq.wait);
    } else wait_time = 0.1;

    self.velocity = q.vec(0, 0, 0);
    self.nextthink = q.time.get() + wait_time;
    self.think = q.func(teleporttrain_next);
}

pub export fn teleporttrain_calcmove() void {
    const self = q.me();

    const delta = (self.enemy.origin + q.vec(16, 16, 16)) - self.origin;
    const len = q.vlen(delta);
    const spd = q.vlen(self.velocity);
    self.nextthink = q.time.get() + (len / spd);
    self.think = q.func(teleporttrain_wait);
}

pub export fn teleporttrain_use() void {
    if (q.veq(q.me().velocity, q.vec(0, 0, 0))) {
        teleporttrain_next();
    }
}

pub export fn teleporttrain_find() void {
    const self = q.me();
    // always start positioned on the first path_corner
    self.enemy = q.find(q.world.get(), .targetname, self.target);
    if (self.enemy.classname.eql(S("path_corner"))) {
        q.setorigin(self, self.enemy.origin + q.vec(16, 16, 16));
        self.target = self.enemy.target;
    } else {
        q.objerror(S("unable to find target\n"));
        q.remove(self);
        return;
    }

    // not triggered, so start immediately
    if (self.targetname.isNull()) {
        teleporttrain_next();
    } else {
        self.use = q.func(teleporttrain_use);
    }
}

/// QUAKED misc_teleporttrain (.5 .5 .5) (-16 -16 -16) (16 16 16) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
/// { model("progs/teleport.mdl"); }
///
/// Teleporter target for final boss level. Must target a series of 'path_corner' entities.
/// It will position itself on its first target at map load.
/// If a targetname is set, it must be triggered to start moving, otherwise it will start automatically.
pub export fn misc_teleporttrain() void {
    const self = q.me();
    if (self.target.isNull()) {
        q.objerror(S("no target"));
        q.remove(self);
        return;
    }
    if (self.get(lq.speed) <= 0) {
        self.set(lq.speed, 100);
    }

    self.solid = lq.SOLID_NOT;
    self.movetype = lq.MOVETYPE_FLY;
    _ = q.precache_model(S("progs/teleport.mdl"));
    q.setmodel(self, S("progs/teleport.mdl"));
    q.setsize(self, q.vec(-16, -16, -16), q.vec(16, 16, 16));

    // Causes the ball to spin around like it was originally intended to.
    self.avelocity = q.vec(40, 80, 120);
    // self.avelocity = '100 200 300';

    self.think = q.func(teleporttrain_find);
    self.nextthink = q.time.get() + 0.1;
}
