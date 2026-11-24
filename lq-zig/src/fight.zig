//! fight.qc
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
//! A monster is in fight mode if it thinks it can effectively attack itsenemy.
//! When it decides it can't attack, it goes into hunt mode.

const q = @import("defs.zig");
const lq = @import("lq.zig");
const loc = @import("localized_text.zig");
const S = q.S;
const Entity = q.Entity;
const Function = q.Function;
const String = q.String;
const Vector = q.Vector;
const subs = @import("subs.zig");
const combat = @import("combat.zig");
const knight = @import("monsters/knight.zig");

pub const enemy_vis = q.userGlobal(f32, "enemy_vis");

pub const enemy_infront = q.userGlobal(f32, "enemy_infront");

pub const enemy_range = q.userGlobal(f32, "enemy_range");

pub const enemy_yaw = q.userGlobal(f32, "enemy_yaw");

pub export fn knight_attack() void {
    const self = q.me();

    //decide if now is a good swing time
    const len = q.vlen(self.enemy.origin + @as(Vector, self.enemy.view_ofs) - (self.origin + @as(Vector, self.view_ofs)));

    if (len < 80)
        knight.knight_atk1()
    else
        knight.knight_runatk1();
}

//=============================================================================

/// CheckAttack
///
/// The player is in view, so decide to move or launch an attack
/// Returns FALSE if movement should continue
pub export fn CheckAttack() f32 {
    const self = q.me();
    var chance: f32 = undefined;

    const targ = self.enemy;

    // see if any entities are in the way of the shot
    const spot1 = self.origin + @as(Vector, self.view_ofs);
    const spot2 = targ.origin + @as(Vector, targ.view_ofs);

    q.traceline(spot1, spot2, lq.FALSE, self);

    if (q.trace_ent.get().neq(targ))
        return lq.FALSE; // don't have a clear shot

    if (q.trace_inopen.get() != 0 and q.trace_inwater.get() != 0)
        return lq.FALSE; // sight line crossed contents

    if (enemy_range.get() == lq.RANGE_MELEE) { // melee attack
        if (!q.fnIsNull(self.get(lq.th_melee))) {
            if (self.classname.eql(S("monster_knight")))
                knight_attack()
            else
                self.get(lq.th_melee).?();

            return lq.TRUE;
        }
    }

    // missile attack
    if (q.fnIsNull(self.get(lq.th_missile)))
        return lq.FALSE;

    if (q.time.get() < self.get(lq.attack_finished))
        return lq.FALSE;

    if (enemy_range.get() == lq.RANGE_FAR)
        return lq.FALSE;

    if (enemy_range.get() == lq.RANGE_MELEE) {
        chance = 0.9;
        self.set(lq.attack_finished, 0);
    } else if (enemy_range.get() == lq.RANGE_NEAR) {
        if (!q.fnIsNull(self.get(lq.th_melee)))
            chance = 0.2
        else
            chance = 0.4;
    } else if (enemy_range.get() == lq.RANGE_MID) {
        if (!q.fnIsNull(self.get(lq.th_melee)))
            chance = 0.05
        else
            chance = 0.1;
    } else chance = 0;

    if (q.random() < chance) {
        self.get(lq.th_missile).?();
        subs.SUB_AttackFinished(2 * q.random());

        return lq.TRUE;
    }

    return lq.FALSE;
}

/// ai_face
///
/// Stay facing the enemy
pub export fn ai_face() void {
    const self = q.me();
    self.ideal_yaw = q.vectoyaw(@as(Vector, self.enemy.origin) - self.origin);
    q.ChangeYaw();
}

/// ai_charge
///
/// The monster is in a melee attack, so get as close as possible to .enemy
pub export fn ai_charge(d: f32) void {
    ai_face();
    q.movetogoal(d); // done in C code...
}

pub export fn ai_charge_side() void {
    const self = q.me();

    // aim to the left of the enemy for a flyby
    self.ideal_yaw = q.vectoyaw(@as(Vector, self.enemy.origin) - self.origin);
    q.ChangeYaw();

    subs.makevectors2(self.angles);
    const dtemp = self.enemy.origin - q.scale(q.v_right.get(), 30);
    const heading = q.vectoyaw(dtemp - @as(Vector, self.origin));

    _ = q.walkmove(heading, 20);
}

/// ai_melee
pub export fn ai_melee() void {
    const self = q.me();

    if (self.enemy.isNull())
        return; // removed before stroke

    const delta = self.enemy.origin - @as(Vector, self.origin);

    if (q.vlen(delta) > 60)
        return;

    const ldmg = (q.random() + q.random() + q.random()) * 3;
    combat.T_Damage(self.enemy, self, self, ldmg);
}

pub export fn ai_melee_side() void {
    const self = q.me();

    if (self.enemy.isNull())
        return; // removed before stroke

    ai_charge_side();

    const delta = self.enemy.origin - @as(Vector, self.origin);

    if (q.vlen(delta) > 60)
        return;

    if (combat.CanDamage(self.enemy, self) == 0)
        return;
    const ldmg = (q.random() + q.random() + q.random()) * 3;
    combat.T_Damage(self.enemy, self, self, ldmg);
}

//=============================================================================

/// SoldierCheckAttack
///
/// The player is in view, so decide to move or launch an attack
/// Returns FALSE if movement should continue
pub export fn SoldierCheckAttack() f32 {
    const self = q.me();
    var chance: f32 = undefined;

    const targ = self.enemy;

    // see if any entities are in the way of the shot
    const spot1 = self.origin + @as(Vector, self.view_ofs);
    const spot2 = targ.origin + @as(Vector, targ.view_ofs);

    q.traceline(spot1, spot2, lq.FALSE, self);

    if (q.trace_inopen.get() != 0 and q.trace_inwater.get() != 0)
        return lq.FALSE; // sight line crossed contents

    if (q.trace_ent.get().neq(targ))
        return lq.FALSE; // don't have a clear shot

    // missile attack
    if (q.time.get() < self.get(lq.attack_finished))
        return lq.FALSE;

    if (enemy_range.get() == lq.RANGE_FAR)
        return lq.FALSE;

    if (enemy_range.get() == lq.RANGE_MELEE)
        chance = 0.9
    else if (enemy_range.get() == lq.RANGE_NEAR)
        chance = 0.4
    else if (enemy_range.get() == lq.RANGE_MID)
        chance = 0.05
    else
        chance = 0;

    if (q.random() < chance) {
        self.get(lq.th_missile).?();
        subs.SUB_AttackFinished(1 + q.random());

        if (q.random() < 0.3)
            self.set(lq.lefty, if (self.get(lq.lefty) == 0) lq.TRUE else lq.FALSE);

        return lq.TRUE;
    }

    return lq.FALSE;
}
//=============================================================================

/// ShamCheckAttack
///
/// The player is in view, so decide to move or launch an attack
/// Returns FALSE if movement should continue
pub export fn ShamCheckAttack() f32 {
    const self = q.me();

    if (enemy_range.get() == lq.RANGE_MELEE) {
        if (combat.CanDamage(self.enemy, self) != 0) {
            self.set(lq.attack_state, lq.AS_MELEE);
            return lq.TRUE;
        }
    }

    if (q.time.get() < self.get(lq.attack_finished))
        return lq.FALSE;

    if (enemy_vis.get() == 0)
        return lq.FALSE;

    const targ = self.enemy;

    // see if any entities are in the way of the shot
    const spot1 = self.origin + @as(Vector, self.view_ofs);
    const spot2 = targ.origin + @as(Vector, targ.view_ofs);

    if (q.vlen(spot1 - spot2) > 600)
        return lq.FALSE;

    q.traceline(spot1, spot2, lq.FALSE, self);

    if (q.trace_inopen.get() != 0 and q.trace_inwater.get() != 0)
        return lq.FALSE; // sight line crossed contents

    if (q.trace_ent.get().neq(targ)) {
        return lq.FALSE; // don't have a clear shot
    }

    // missile attack
    if (enemy_range.get() == lq.RANGE_FAR)
        return lq.FALSE;

    self.set(lq.attack_state, lq.AS_MISSILE);
    subs.SUB_AttackFinished(2 + 2 * q.random());

    return lq.TRUE;
}

//============================================================================

/// OgreCheckAttack
///
/// The player is in view, so decide to move or launch an attack
/// Returns FALSE if movement should continue
pub export fn OgreCheckAttack() f32 {
    const self = q.me();
    var chance: f32 = undefined;

    if (enemy_range.get() == lq.RANGE_MELEE) {
        if (combat.CanDamage(self.enemy, self) != 0) {
            self.set(lq.attack_state, lq.AS_MELEE);
            return lq.TRUE;
        }
    }

    if (q.time.get() < self.get(lq.attack_finished))
        return lq.FALSE;

    if (enemy_vis.get() == 0)
        return lq.FALSE;

    const targ = self.enemy;

    // see if any entities are in the way of the shot
    const spot1 = self.origin + @as(Vector, self.view_ofs);
    const spot2 = targ.origin + @as(Vector, targ.view_ofs);

    q.traceline(spot1, spot2, lq.FALSE, self);

    if (q.trace_inopen.get() != 0 and q.trace_inwater.get() != 0)
        return lq.FALSE; // sight line crossed contents

    if (q.trace_ent.get().neq(targ)) {
        return lq.FALSE; // don't have a clear shot
    }

    // missile attack
    if (q.time.get() < self.get(lq.attack_finished))
        return lq.FALSE;

    if (enemy_range.get() == lq.RANGE_FAR)
        return lq.FALSE
    else if (enemy_range.get() == lq.RANGE_NEAR)
        chance = 0.10
    else if (enemy_range.get() == lq.RANGE_MID)
        chance = 0.05
    else
        chance = 0;
    // `chance` is never used in the original.
    _ = &chance;

    self.set(lq.attack_state, lq.AS_MISSILE);
    subs.SUB_AttackFinished(1 + 2 * q.random());

    return lq.TRUE;
}
