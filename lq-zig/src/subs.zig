//! subs.qc
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
const Function = q.Function;
const Vector = q.Vector;
const ai = @import("ai.zig");

pub export fn SUB_Remove() void {
    q.remove(q.me());
}

pub export fn SUB_Null() void {}

//pitch (angles_x) is inverted in quake due to a bug
//use makevectors2 for monsters with nonzero pitch
//anyone encountering this comment with a better understanding should update the comment to be more informative and useful to modders --gnounc
pub export fn makevectors2(ang: Vector) void {
    var a = ang;
    a[0] = a[0] * -1;
    q.makevectors(a);
}

pub export fn anglemod(v: f32) f32 {
    var x = v;
    while (x >= 360)
        x = x - 360;
    while (x < 0)
        x = x + 360;
    return x;
}

/// QuakeEd only writes a single float for angles (bad idea), so up and down
/// are just constant angles.
pub export fn SetMovedir() void {
    const self = q.me();
    if (q.veq(self.angles, q.vec(0, -1, 0))) {
        self.movedir = q.vec(0, 0, 1);
    } else if (q.veq(self.angles, q.vec(0, -2, 0))) {
        self.movedir = q.vec(0, 0, -1);
    } else {
        q.makevectors(self.angles);
        self.movedir = q.v_forward.get();
    }

    self.angles = q.vec(0, 0, 0);
}

/// InitTrigger
pub export fn InitTrigger() void {
    const self = q.me();
    // trigger angles are used for one-way touches.  An angle of 0 is assumed
    // to mean no restrictions, so use a yaw of 360 instead.
    if (!q.veq(self.angles, q.vec(0, 0, 0)))
        SetMovedir();

    self.solid = lq.SOLID_TRIGGER;
    q.setmodel(self, self.model); // set size and link into world
    self.movetype = lq.MOVETYPE_NONE;
    self.modelindex = 0;
    self.model = lq.string_null.get();
}

/// SUB_CalcMove
///
/// calculate self.velocity and self.nextthink to reach dest from
/// self.origin traveling at speed
pub export fn SUB_CalcMoveEnt(ent: Entity, tdest: Vector, tspeed: f32, func: Function) void {
    const stemp = q.self.get();
    q.self.set(ent);

    SUB_CalcMove(tdest, tspeed, func);
    q.self.set(stemp);
}

pub export fn SUB_CalcMove(tdest: Vector, tspeed: f32, func: Function) void {
    const self = q.me();

    if (tspeed == 0)
        q.objerror(S("No speed is defined!"));

    self.set(lq.think1, func);
    self.set(lq.finaldest, tdest);
    self.think = q.func(SUB_CalcMoveDone);

    if (q.veq(tdest, self.origin)) {
        self.velocity = q.vec(0, 0, 0);
        self.nextthink = self.ltime + 0.1;
        return;
    }

    // set destdelta to the vector needed to move
    const vdestdelta = tdest - self.origin;

    // calculate length of vector
    const len = q.vlen(vdestdelta);

    // divide by speed to get time to reach dest
    const traveltime = len / tspeed;

    if (traveltime < 0.1) {
        self.velocity = q.vec(0, 0, 0);
        self.nextthink = self.ltime + 0.1;
        return;
    }

    // set nextthink to trigger a think when dest is reached
    self.nextthink = self.ltime + traveltime;

    // scale the destdelta vector by the time spent traveling to get velocity
    self.velocity = q.scale(vdestdelta, 1 / traveltime); // qcc won't take vec/float
}

/// After moving, set origin to exact final destination
pub export fn SUB_CalcMoveDone() void {
    const self = q.me();
    q.setorigin(self, self.get(lq.finaldest));
    self.velocity = q.vec(0, 0, 0);
    self.nextthink = -1;

    if (!q.fnIsNull(self.get(lq.think1)))
        self.get(lq.think1).?();
}

/// SUB_CalcAngleMove
///
/// calculate self.avelocity and self.nextthink to reach destangle from
/// self.angles rotating
///
/// The calling function should make sure self.think is valid
pub export fn SUB_CalcAngleMoveEnt(ent: Entity, destangle: Vector, tspeed: f32, func: Function) void {
    const stemp = q.self.get();
    q.self.set(ent);
    SUB_CalcAngleMove(destangle, tspeed, func);
    q.self.set(stemp);
}

pub export fn SUB_CalcAngleMove(destangle: Vector, tspeed: f32, func: Function) void {
    const self = q.me();

    if (tspeed == 0)
        q.objerror(S("No speed is defined!"));

    // set destdelta to the vector needed to move
    const destdelta = destangle - self.angles;

    // calculate length of vector
    const len = q.vlen(destdelta);

    // divide by speed to get time to reach dest
    const traveltime = len / tspeed;

    // set nextthink to trigger a think when dest is reached
    self.nextthink = self.ltime + traveltime;

    // scale the destdelta vector by the time spent traveling to get velocity
    self.avelocity = q.scale(destdelta, 1 / traveltime);

    self.set(lq.think1, func);
    self.set(lq.finalangle, destangle);
    self.think = q.func(SUB_CalcAngleMoveDone);
}

/// After rotating, set angle to exact final angle
pub export fn SUB_CalcAngleMoveDone() void {
    const self = q.me();
    self.angles = self.get(lq.finalangle);
    self.avelocity = q.vec(0, 0, 0);
    self.nextthink = -1;

    if (!q.fnIsNull(self.get(lq.think1)))
        self.get(lq.think1).?();
}

//=============================================================================

pub export fn DelayThink() void {
    const self = q.me();
    lq.activator.set(self.enemy);
    SUB_UseTargets();
    q.remove(self);
}

/// SUB_UseTargets
///
/// the global "activator" should be set to the entity that initiated the
/// firing.
///
/// If self.delay is set, a DelayedUse entity will be created that will
/// actually do the SUB_UseTargets after that many seconds have passed.
///
/// Centerprints any self.message to the activator.
///
/// Removes all entities with a targetname that match self.killtarget, and
/// removes them, so some events can remove other triggers.
///
/// Search for (string)targetname in all entities that match
/// (string)self.target and call their .use function
pub export fn SUB_UseTargets() void {
    const self = q.me();

    //
    // check for a delay
    //
    if (self.get(lq.delay) != 0) {
        // create a temp object to fire at a later time
        const t = q.spawn();
        t.classname = S("DelayedUse");
        t.nextthink = q.time.get() + self.get(lq.delay);
        t.think = q.func(DelayThink);
        t.enemy = lq.activator.get();
        t.message = self.message;
        t.set(lq.killtarget, self.get(lq.killtarget));
        t.target = self.target;

        return;
    }

    //
    // print the message
    //
    const activator = lq.activator.get();
    if (activator.classname.eql(S("player")) and self.message.neq(lq.string_null.get())) {
        q.centerprint(activator, self.message);

        if (self.noise.isNull())
            q.sound(activator, lq.CHAN_VOICE, S("misc/talk.wav"), 1, lq.ATTN_NORM);
    }

    //
    // kill the killtagets
    //
    if (self.get(lq.killtarget).neq(lq.string_null.get())) {
        var t = q.world.get();

        while (true) {
            t = q.find(t, .targetname, self.get(lq.killtarget));

            if (t.isNull())
                return;

            q.remove(t);
        }
    }

    //
    // fire targets
    //
    if (self.target.neq(lq.string_null.get())) {
        const act = lq.activator.get();
        var t = q.world.get();

        while (true) {
            t = q.find(t, .targetname, self.target);
            if (t.isNull()) {
                return;
            }

            const stemp = q.self.get();
            const otemp = q.other.get();
            q.self.set(t);
            q.other.set(stemp);

            if (!q.fnIsNull(t.use))
                t.use.?();

            q.self.set(stemp);
            q.other.set(otemp);
            lq.activator.set(act);
        }
    }
}

/// in nightmare mode, all attack_finished times become 0
/// some monsters refire twice automatically
pub export fn SUB_AttackFinished(normal: f32) void {
    const self = q.me();
    self.set(lq.cnt, 0); // refire count for nightmare

    if (lq.skill.get() != 3)
        self.set(lq.attack_finished, q.time.get() + normal);
}

pub export fn SUB_CheckRefire(thinkst: Function) void {
    const self = q.me();
    if (lq.skill.get() != 3)
        return;

    if (self.get(lq.cnt) == 1)
        return;

    if (ai.visible(self.enemy) == 0)
        return;

    self.set(lq.cnt, 1);
    self.think = thinkst;
}
