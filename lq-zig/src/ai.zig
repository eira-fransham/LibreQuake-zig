//! ai.qc
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
//! .enemy
//! Will be world if not currently angry at anyone.
//!
//! .movetarget
//! The next path spot to walk toward.  If .enemy, ignore .movetarget.
//! When an enemy is killed, the monster will try to return to it's path.
//!
//! .hunt_time
//! Set to time + something when the player is in sight, but movement straight for
//! him is blocked.  This causes the monster to use wall following code for
//! movement direction instead of sighting on the player.
//!
//! .ideal_yaw
//! A yaw angle of the intended direction, which will be turned towards at up
//! to 45 deg / state.  If the enemy is in view and hunt_time is not active,
//! this will be the exact line towards the enemy.
//!
//! .pausetime
//! A monster will leave it's stand state and head towards it's .movetarget when
//! time > .pausetime.
//!
//! walkmove(angle, speed) primitive is all or nothing

const q = @import("defs.zig");
const lq = @import("lq.zig");
const loc = @import("localized_text.zig");
const S = q.S;
const Entity = q.Entity;
const Function = q.Function;
const String = q.String;
const Vector = q.Vector;
const subs = @import("subs.zig");
const fight = @import("fight.zig");
const rottweiler = @import("monsters/rottweiler.zig");
const scrag = @import("monsters/scrag.zig");
const fiend = @import("monsters/fiend.zig");

//
// globals
//

//
// when a monster becomes angry at a player, that monster will be used
// as the sight target the next frame so that monsters near that one
// will wake up even if they wouldn't have noticed the player
//
pub const sight_entity = q.userGlobal(Entity, "sight_entity");

pub const sight_entity_time = q.userGlobal(f32, "sight_entity_time");

// ==============================================================================
//
// MOVETARGET CODE
//
// The angle of the movetarget effects standing and bowing direction, but has no effect on movement, which allways heads to the next target.
//
// targetname
// must be present.  The name of this movetarget.
//
// target
// the next spot to move to.  If not present, stop here for good.
//
// pausetime
// The number of seconds to spend standing or bowing for path_stand or path_bow
//
// ==============================================================================

pub export fn movetarget_f() void {
    const self = q.me();
    if (self.targetname.isNull())
        q.objerror(S("monster_movetarget: no targetname"));

    self.solid = lq.SOLID_TRIGGER;
    self.touch = q.func(t_movetarget);
    q.setsize(self, q.vec(-8, -8, -8), q.vec(8, 8, 8));
}

/// QUAKED path_corner (0.5 0.3 0) (-8 -8 -8) (8 8 8)
/// Monsters will continue walking towards the next target corner.
pub export fn path_corner() void {
    movetarget_f();
}

/// t_movetarget
///
/// Something has bumped into a movetarget.  If it is a monster
/// moving towards it, change the next destination and continue.
pub export fn t_movetarget() void {
    if (q.other.get().get(lq.movetarget).neq(q.self.get()))
        return;

    if (!q.other.get().enemy.isNull())
        return; // fighting, not following a path

    const temp = q.self.get();
    q.self.set(q.other.get());
    q.other.set(temp);

    const self = q.me();
    const other = q.other.get();

    if (self.classname.eql(S("monster_ogre")))
        q.sound(self, lq.CHAN_VOICE, S("ogre/ogdrag.wav"), 1, lq.ATTN_IDLE); // play chainsaw drag sound

    //dprint ("t_movetarget\n");
    self.set(lq.movetarget, q.find(q.world.get(), .targetname, other.target));
    self.goalentity = self.get(lq.movetarget);
    self.ideal_yaw = q.vectoyaw(@as(Vector, self.goalentity.origin) - self.origin);
    if (self.get(lq.movetarget).isNull()) {
        self.set(lq.pausetime, q.time.get() + 999999);
        self.get(lq.th_stand).?();
        return;
    }
}

//============================================================================

/// range
///
/// returns the range catagorization of an entity reletive to self
/// 0 melee range, will become hostile even if back is turned
/// 1 visibility and infront, or visibility and show hostile
/// 2 infront and show hostile
/// 3 only triggered by damage
pub export fn range(targ: Entity) f32 {
    const self = q.me();
    const spot1 = self.origin + @as(Vector, self.view_ofs);
    const spot2 = targ.origin + @as(Vector, targ.view_ofs);

    const r = q.vlen(spot1 - spot2);
    if (r < 120)
        return lq.RANGE_MELEE;
    if (r < 500)
        return lq.RANGE_NEAR;
    if (r < 1000)
        return lq.RANGE_MID;
    return lq.RANGE_FAR;
}

/// visible
///
/// returns 1 if the entity is visible to self, even if not infront ()
pub export fn visible(targ: Entity) f32 {
    const self = q.me();
    const spot1 = self.origin + @as(Vector, self.view_ofs);
    const spot2 = targ.origin + @as(Vector, targ.view_ofs);
    q.traceline(spot1, spot2, lq.TRUE, self); // see through other monsters

    if (q.trace_inopen.get() != 0 and q.trace_inwater.get() != 0)
        return lq.FALSE; // sight line crossed contents

    if (q.trace_fraction.get() == 1)
        return lq.TRUE;
    return lq.FALSE;
}

/// infront
///
/// returns 1 if the entity is in front (in sight) of self
pub export fn infront(targ: Entity) f32 {
    const self = q.me();

    subs.makevectors2(self.angles);
    const vec = q.normalize(targ.origin - @as(Vector, self.origin));
    const dot = q.dot(vec, q.v_forward.get());

    if (dot > 0.3) {
        return lq.TRUE;
    }
    return lq.FALSE;
}

//============================================================================

pub export fn HuntTarget() void {
    const self = q.me();
    self.goalentity = self.enemy;
    self.think = self.get(lq.th_run);
    self.ideal_yaw = q.vectoyaw(@as(Vector, self.enemy.origin) - self.origin);
    self.nextthink = q.time.get() + 0.1;
    subs.SUB_AttackFinished(1); // wait a while before first attack
}

pub export fn FoundTarget() void {
    const self = q.me();
    if (self.enemy.classname.eql(S("player"))) { // let other monsters see this monster for a while
        sight_entity.set(self);
        sight_entity_time.set(q.time.get());
    }

    self.set(lq.show_hostile, q.time.get() + 1); // wake up other monsters

    //gnounc
    if (self.classname.eql(S("enforcer"))) {
        const rsnd = q.rint(q.random() * 3);
        if (rsnd == 1)
            q.sound(self, lq.CHAN_BODY, self.noise, 1, lq.ATTN_NORM)
        else if (rsnd == 2)
            q.sound(self, lq.CHAN_BODY, self.noise1, 1, lq.ATTN_NORM)
        else if (rsnd == 0)
            q.sound(self, lq.CHAN_BODY, self.noise2, 1, lq.ATTN_NORM)
        else
            q.sound(self, lq.CHAN_BODY, self.get(lq.noise4), 1, lq.ATTN_NORM);
    } else q.sound(self, lq.CHAN_BODY, self.noise, 1, lq.ATTN_NORM);

    HuntTarget();
}

/// FindTarget
///
/// Self is currently not attacking anything, so try to find a target
///
/// Returns TRUE if an enemy was sighted
///
/// When a player fires a missile, the point of impact becomes a fakeplayer so
/// that monsters that see the impact will respond as if they had seen the
/// player.
///
/// To avoid spending too much time, only a single client (or fakeclient) is
/// checked each frame.  This means multi player games will have slightly
/// slower noticing monsters.
pub export fn FindTarget() f32 {
    const self = q.me();
    var client: Entity = undefined;

    // if the first spawnflag bit is set, the monster will only wake up on
    // really seeing the player, not another monster getting angry

    // spawnflags & 3 is a big hack, because zombie crucified used the first
    // spawn flag prior to the ambush flag, and I forgot about it, so the second
    // spawn flag works as well
    if (sight_entity_time.get() >= q.time.get() - 0.1 and !q.has(self.spawnflags, 3)) {
        client = sight_entity.get();
        if (client.enemy.eql(self.enemy))
            return lq.TRUE;
    } else {
        client = q.checkclient();
        if (client.isNull())
            return lq.FALSE; // current check entity isn't in PVS
    }

    // Fix for the bug that causes enemies to play their awaken sound every frame
    if (client.health <= 0)
        return lq.FALSE;

    if (client.classname.neq(S("player")))
        if (client.enemy.health <= 0)
            return lq.FALSE;

    if (client.eql(self.enemy))
        return lq.FALSE;

    if (q.has(client.flags, lq.FL_NOTARGET))
        return lq.FALSE;

    if (q.has(client.items, lq.IT_INVISIBILITY))
        return lq.FALSE;

    const r = range(client);
    if (r == lq.RANGE_FAR)
        return lq.FALSE;

    if (visible(client) == 0)
        return lq.FALSE;

    if (r == lq.RANGE_NEAR) {
        if (client.get(lq.show_hostile) < q.time.get() and infront(client) == 0)
            return lq.FALSE;
    } else if (r == lq.RANGE_MID) {
        if ( // client.show_hostile < time ||
        infront(client) == 0)
            return lq.FALSE;
    }

    //
    // got one
    //
    self.enemy = client;
    if (self.enemy.classname.neq(S("player"))) {
        self.enemy = self.enemy.enemy;
        if (self.enemy.classname.neq(S("player"))) {
            self.enemy = q.world.get();
            return lq.FALSE;
        }
    }

    FoundTarget();

    return lq.TRUE;
}

//=============================================================================

pub export fn ai_forward(dist: f32) void {
    _ = q.walkmove(q.me().angles[1], dist);
}

pub export fn ai_back(dist: f32) void {
    _ = q.walkmove((q.me().angles[1] + 180), dist);
}

/// ai_pain
///
/// stagger back a bit
pub export fn ai_pain(dist: f32) void {
    ai_back(dist);
}

/// ai_painforward
///
/// stagger back a bit
pub export fn ai_painforward(dist: f32) void {
    _ = q.walkmove(q.me().ideal_yaw, dist);
}

/// ai_walk
///
/// The monster is walking it's beat
pub export fn ai_walk(dist: f32) void {
    lq.movedist.set(dist);

    // check for noticing a player
    if (FindTarget() != 0)
        return;

    q.movetogoal(dist);
}

/// ai_stand
///
/// The monster is staying in one place for a while, with slight angle turns
pub export fn ai_stand() void {
    if (FindTarget() != 0)
        return;

    const self = q.me();
    if (q.time.get() > self.get(lq.pausetime)) {
        self.get(lq.th_walk).?();
        return;
    }

    // change angle slightly

}

/// ai_turn
///
/// don't move, but turn towards ideal_yaw
pub export fn ai_turn() void {
    if (FindTarget() != 0)
        return;

    q.ChangeYaw();
}

//=============================================================================

/// ChooseTurn
pub export fn ChooseTurn(dest3: Vector) void {
    const self = q.me();
    var dir: Vector = self.origin - dest3;
    var newdir: Vector = undefined;

    newdir[0] = q.trace_plane_normal_y.get();
    newdir[1] = 0 - q.trace_plane_normal_x.get();
    newdir[2] = 0;

    if (q.dot(dir, newdir) > 0) {
        dir[0] = 0 - q.trace_plane_normal_y.get();
        dir[1] = q.trace_plane_normal_x.get();
    } else {
        dir[0] = q.trace_plane_normal_y.get();
        dir[1] = 0 - q.trace_plane_normal_x.get();
    }

    dir[2] = 0;
    self.ideal_yaw = q.vectoyaw(dir);
}

/// FacingIdeal
pub export fn FacingIdeal() f32 {
    const self = q.me();
    const delta = subs.anglemod(self.angles[1] - self.ideal_yaw);
    if (delta > 45 and delta < 315)
        return lq.FALSE;
    return lq.TRUE;
}

//=============================================================================

pub export fn CheckAnyAttack() f32 {
    const self = q.me();
    if (fight.enemy_vis.get() == 0)
        return lq.FALSE;
    if (self.classname.eql(S("monster_army")))
        return fight.SoldierCheckAttack();
    if (self.classname.eql(S("monster_ogre")))
        return fight.OgreCheckAttack();
    if (self.classname.eql(S("monster_shambler")))
        return fight.ShamCheckAttack();
    if (self.classname.eql(S("monster_demon1")))
        return fiend.DemonCheckAttack();
    if (self.classname.eql(S("monster_dog")))
        return rottweiler.DogCheckAttack();
    if (self.classname.eql(S("monster_wizard")))
        return scrag.WizardCheckAttack();
    return fight.CheckAttack();
}

/// ai_run_melee
///
/// Turn and close until within an angle to launch a melee attack
pub export fn ai_run_melee() void {
    const self = q.me();
    self.ideal_yaw = fight.enemy_yaw.get();
    q.ChangeYaw();

    if (FacingIdeal() != 0) {
        self.get(lq.th_melee).?();
        self.set(lq.attack_state, lq.AS_STRAIGHT);
    }
}

/// ai_run_missile
///
/// Turn in place until within an angle to launch a missile attack
pub export fn ai_run_missile() void {
    const self = q.me();
    self.ideal_yaw = fight.enemy_yaw.get();
    q.ChangeYaw();
    if (FacingIdeal() != 0) {
        self.get(lq.th_missile).?();
        self.set(lq.attack_state, lq.AS_STRAIGHT);
    }
}

/// ai_run_slide
///
/// Strafe sideways, but stay at aproximately the same range
pub export fn ai_run_slide() void {
    const self = q.me();
    var ofs: f32 = undefined;

    self.ideal_yaw = fight.enemy_yaw.get();
    q.ChangeYaw();
    if (self.get(lq.lefty) != 0)
        ofs = 90
    else
        ofs = -90;

    if (q.walkmove(self.ideal_yaw + ofs, lq.movedist.get()) != 0)
        return;

    self.set(lq.lefty, 1 - self.get(lq.lefty));

    _ = q.walkmove(self.ideal_yaw - ofs, lq.movedist.get());
}

/// ai_run
///
/// The monster has an enemy it is trying to kill
pub export fn ai_run(dist: f32) void {
    const self = q.me();

    lq.movedist.set(dist);
    // see if the enemy is dead
    if (self.enemy.health <= 0) {
        self.enemy = q.world.get();
        // FIXME: look all around for other targets
        if (self.get(lq.oldenemy).health > 0) {
            self.enemy = self.get(lq.oldenemy);
            HuntTarget();
        } else {
            if (!self.get(lq.movetarget).isNull())
                self.get(lq.th_walk).?()
            else
                self.get(lq.th_stand).?();
            return;
        }
    }

    self.set(lq.show_hostile, q.time.get() + 1); // wake up other monsters

    // check knowledge of enemy
    fight.enemy_vis.set(visible(self.enemy));
    if (fight.enemy_vis.get() != 0)
        self.set(lq.search_time, q.time.get() + 5);

    // look for other coop players
    if (q.coop.get() != 0 and self.get(lq.search_time) < q.time.get()) {
        if (FindTarget() != 0)
            return;
    }

    fight.enemy_infront.set(infront(self.enemy));
    fight.enemy_range.set(range(self.enemy));
    fight.enemy_yaw.set(q.vectoyaw(@as(Vector, self.enemy.origin) - self.origin));

    if (self.get(lq.attack_state) == lq.AS_MISSILE) {
        ai_run_missile();
        return;
    }
    if (self.get(lq.attack_state) == lq.AS_MELEE) {
        ai_run_melee();
        return;
    }

    if (CheckAnyAttack() != 0)
        return; // beginning an attack

    if (self.get(lq.attack_state) == lq.AS_SLIDING) {
        ai_run_slide();
        return;
    }

    // head straight in
    q.movetogoal(dist); // done in C code...
}
