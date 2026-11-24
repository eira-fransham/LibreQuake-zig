//! monsters.qc
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
//!
//! ALL MONSTERS SHOULD BE 1 0 0 IN COLOR

const q = @import("defs.zig");
const lq = @import("lq.zig");
const S = q.S;
const ai = @import("ai.zig");
const subs = @import("subs.zig");

/// monster_use
///
/// Using a monster makes it angry at the current activator
pub export fn monster_use() void {
    const self = q.me();
    const activator = lq.activator.get();
    if (!self.enemy.isNull())
        return;
    if (self.health <= 0)
        return;
    if (q.has(activator.items, lq.IT_INVISIBILITY))
        return;
    if (q.has(activator.flags, lq.FL_NOTARGET))
        return;
    if (activator.classname.neq(S("player")))
        return;

    // delay reaction so if the monster is teleported, its sound is still heard
    self.enemy = activator;
    self.nextthink = q.time.get() + 0.1;
    self.think = q.func(ai.FoundTarget);
}

/// monster_death_use
///
/// When a mosnter dies, it fires all of its targets with the current
/// enemy as activator.
pub export fn monster_death_use() void {
    const self = q.me();
    // fall to ground
    if (q.has(self.flags, lq.FL_FLY))
        self.flags = self.flags - lq.FL_FLY;
    if (q.has(self.flags, lq.FL_SWIM))
        self.flags = self.flags - lq.FL_SWIM;

    if (self.target.isNull())
        return;

    lq.activator.set(self.enemy);
    subs.SUB_UseTargets();
}

//============================================================================

/// The `self.target` handling shared by the `*_start_go` functions: as the
/// original, `else self.pausetime = 99999999;` only covers the assignment,
/// so `th_stand` runs after `th_walk` too.
pub export fn walkmonster_start_go() void {
    const self = q.me();
    self.origin[2] = self.origin[2] + 1; // raise off floor a bit
    _ = q.droptofloor();

    if (q.walkmove(0, 0) == 0) {
        q.dprint(S("walkmonster in wall at: "));
        q.dprint(q.vtos(self.origin));
        q.dprint(S("\n"));
    }

    self.takedamage = lq.DAMAGE_AIM;

    self.ideal_yaw = q.dot(self.angles, q.vec(0, 1, 0));
    if (self.yaw_speed == 0)
        self.yaw_speed = 20;
    self.view_ofs = q.vec(0, 0, 25);
    self.use = q.func(monster_use);

    self.flags = q.bor(self.flags, lq.FL_MONSTER);

    if (self.target.neq(lq.string_null.get())) {
        self.set(lq.movetarget, q.find(q.world.get(), .targetname, self.target));
        self.goalentity = self.get(lq.movetarget);
        self.ideal_yaw = q.vectoyaw(@as(q.Vector, self.goalentity.origin) - self.origin);
        if (self.get(lq.movetarget).isNull()) {
            q.dprint(S("Monster can't find target at "));
            q.dprint(q.vtos(self.origin));
            q.dprint(S("\n"));
        }
        // this used to be an objerror
        if (self.get(lq.movetarget).classname.eql(S("path_corner")))
            self.get(lq.th_walk).?()
        else
            self.set(lq.pausetime, 99999999.0);
        self.get(lq.th_stand).?();
    } else {
        self.set(lq.pausetime, 99999999.0);
        self.get(lq.th_stand).?();
    }

    // spread think times so they don't all happen at same time
    self.nextthink = self.nextthink + q.random() * 0.5;
}

pub export fn walkmonster_start() void {
    const self = q.me();
    // delay drop to floor to make sure all doors have been spawned
    // spread think times so they don't all happen at same time
    self.nextthink = self.nextthink + q.random() * 0.5 + 0.1; // Add 0.1 to fix statue bug
    self.think = q.func(walkmonster_start_go);
    q.total_monsters.set(q.total_monsters.get() + 1);
}

pub export fn flymonster_start_go() void {
    const self = q.me();
    self.takedamage = lq.DAMAGE_AIM;

    self.ideal_yaw = q.dot(self.angles, q.vec(0, 1, 0));
    if (self.yaw_speed == 0)
        self.yaw_speed = 10;
    self.view_ofs = q.vec(0, 0, 25);
    self.use = q.func(monster_use);

    self.flags = q.bor(self.flags, lq.FL_FLY);
    self.flags = q.bor(self.flags, lq.FL_MONSTER);

    if (q.walkmove(0, 0) == 0) {
        q.dprint(S("flymonster in wall at: "));
        q.dprint(q.vtos(self.origin));
        q.dprint(S("\n"));
    }

    if (self.target.neq(lq.string_null.get())) {
        self.set(lq.movetarget, q.find(q.world.get(), .targetname, self.target));
        self.goalentity = self.get(lq.movetarget);
        if (self.get(lq.movetarget).isNull()) {
            q.dprint(S("Monster can't find target at "));
            q.dprint(q.vtos(self.origin));
            q.dprint(S("\n"));
        }
        // this used to be an objerror
        if (self.get(lq.movetarget).classname.eql(S("path_corner")))
            self.get(lq.th_walk).?()
        else
            self.set(lq.pausetime, 99999999.0);
        self.get(lq.th_stand).?();
    } else {
        self.set(lq.pausetime, 99999999.0);
        self.get(lq.th_stand).?();
    }
}

pub export fn flymonster_start() void {
    const self = q.me();
    // spread think times so they don't all happen at same time
    self.nextthink = self.nextthink + q.random() * 0.5 + 0.1; // Add 0.1 to fix statue bug
    self.think = q.func(flymonster_start_go);
    q.total_monsters.set(q.total_monsters.get() + 1);
}

pub export fn swimmonster_start_go() void {
    const self = q.me();
    if (q.deathmatch.get() != 0) {
        q.remove(self);
        return;
    }

    self.takedamage = lq.DAMAGE_AIM;
    //  total_monsters = total_monsters + 1;  // gb, fish count bugfix

    self.ideal_yaw = q.dot(self.angles, q.vec(0, 1, 0));
    if (self.yaw_speed == 0)
        self.yaw_speed = 10;
    self.view_ofs = q.vec(0, 0, 10);
    self.use = q.func(monster_use);

    self.flags = q.bor(self.flags, lq.FL_SWIM);
    self.flags = q.bor(self.flags, lq.FL_MONSTER);

    if (self.target.neq(lq.string_null.get())) {
        self.set(lq.movetarget, q.find(q.world.get(), .targetname, self.target));
        self.goalentity = self.get(lq.movetarget);
        if (self.get(lq.movetarget).isNull()) {
            q.dprint(S("Monster can't find target at "));
            q.dprint(q.vtos(self.origin));
            q.dprint(S("\n"));
        }
        // this used to be an objerror
        self.ideal_yaw = q.vectoyaw(@as(q.Vector, self.goalentity.origin) - self.origin);
        self.get(lq.th_walk).?();
    } else {
        self.set(lq.pausetime, 99999999.0);
        self.get(lq.th_stand).?();
    }

    // spread think times so they don't all happen at same time
    self.nextthink = self.nextthink + q.random() * 0.5;
}

pub export fn swimmonster_start() void {
    const self = q.me();
    // spread think times so they don't all happen at same time
    self.nextthink = self.nextthink + q.random() * 0.5 + 0.1; // Add 0.1 to fix statue bug
    self.think = q.func(swimmonster_start_go);
    q.total_monsters.set(q.total_monsters.get() + 1);
}
