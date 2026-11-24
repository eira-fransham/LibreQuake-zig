//! combat.qc
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
const String = q.String;
const Vector = q.Vector;
const ai = @import("ai.zig");
const client = @import("client.zig");
const dm = @import("deathmatch_settings.zig");
const monsters = @import("monsters.zig");
const subs = @import("subs.zig");

//============================================================================

/// CanDamage
///
/// Returns true if the inflictor can directly damage the target.  Used for
/// explosions and melee attacks.
pub export fn CanDamage(targ: Entity, inflictor: Entity) f32 {
    const self = q.me();
    // bmodels need special checking because their origin is 0,0,0
    if (targ.movetype == lq.MOVETYPE_PUSH) {
        q.traceline(inflictor.origin, q.scale(@as(Vector, targ.absmin) + targ.absmax, 0.5), lq.TRUE, self);
        if (q.trace_fraction.get() == 1)
            return lq.TRUE;

        if (q.trace_ent.get().eql(targ))
            return lq.TRUE;

        return lq.FALSE;
    }

    q.traceline(inflictor.origin, targ.origin, lq.TRUE, self);

    if (q.trace_fraction.get() == 1)
        return lq.TRUE;

    q.traceline(inflictor.origin, targ.origin + q.vec(15, 15, 0), lq.TRUE, self);

    if (q.trace_fraction.get() == 1)
        return lq.TRUE;

    q.traceline(inflictor.origin, targ.origin + q.vec(-15, -15, 0), lq.TRUE, self);

    if (q.trace_fraction.get() == 1)
        return lq.TRUE;

    q.traceline(inflictor.origin, targ.origin + q.vec(-15, 15, 0), lq.TRUE, self);

    if (q.trace_fraction.get() == 1)
        return lq.TRUE;

    q.traceline(inflictor.origin, targ.origin + q.vec(15, -15, 0), lq.TRUE, self);

    if (q.trace_fraction.get() == 1)
        return lq.TRUE;

    return lq.FALSE;
}

/// Killed
pub export fn Killed(targ: Entity, attacker: Entity) void {
    const oself = q.self.get();
    q.self.set(targ);
    const self = q.me();

    if (self.health < -99)
        self.health = -99; // don't let sbar look bad if a player

    if (self.movetype == lq.MOVETYPE_PUSH or self.movetype == lq.MOVETYPE_NONE) { // doors, triggers, etc
        self.get(lq.th_die).?();
        q.self.set(oself);

        return;
    }

    self.enemy = attacker;

    // bump the monster counter
    if (q.has(self.flags, lq.FL_MONSTER)) {
        q.killed_monsters.set(q.killed_monsters.get() + 1);
        q.WriteByte(lq.MSG_ALL, lq.SVC_KILLEDMONSTER);
    }

    client.ClientObituary(self, attacker);

    self.takedamage = lq.DAMAGE_NO;
    self.touch = null;
    self.effects = 0;

    monsters.monster_death_use();
    self.get(lq.th_die).?();

    q.self.set(oself);
}

/// T_Damage
///
/// The damage is coming from inflictor, but get mad at attacker
/// This should be the only function that ever reduces health.
pub export fn T_Damage(targ: Entity, inflictor: Entity, attacker: Entity, damage_: f32) void {
    var damage = damage_;

    if (targ.takedamage == 0)
        return;

    const temp_deathtype = targ.get(lq.deathtype);
    targ.set(lq.deathtype, lq.string_null.get());

    //gnounc -- shub kill crash fix.
    if (targ.classname.eql(S("monster_oldone")) and damage < 9999)
        return;

    // used by buttons and triggers to set activator for target firing
    lq.damage_attacker.set(attacker);

    // check for quad damage powerup on the attacker
    if (attacker.get(lq.super_damage_finished) > q.time.get() and inflictor.classname.neq(S("door"))) {
        if (dm.deathmatch_supermode()) {
            damage = damage * 8;
        } else {
            damage = damage * 4;
        }
    }

    // save damage based on the target's armor level
    var save = q.ceil(targ.armortype * damage);

    if (save >= targ.armorvalue) {
        save = targ.armorvalue;
        targ.armortype = 0; // lost all armor
        targ.items = targ.items - q.band(targ.items, q.bor(q.bor(lq.IT_ARMOR1, lq.IT_ARMOR2), lq.IT_ARMOR3));
    }

    targ.armorvalue = targ.armorvalue - save;
    const take = q.ceil(damage - save);

    // add to the damage total for clients, which will be sent as a single
    // message at the end of the frame
    // FIXME: remove after combining shotgun blasts?
    if (q.has(targ.flags, lq.FL_CLIENT)) {
        targ.dmg_take = targ.dmg_take + take;
        targ.dmg_save = targ.dmg_save + save;
        targ.dmg_inflictor = inflictor;
    }

    lq.damage_inflictor.set(inflictor);

    // figure momentum add
    if ((inflictor.neq(q.world.get())) and (targ.movetype == lq.MOVETYPE_WALK)) {
        var dir = targ.origin - q.scale(@as(Vector, inflictor.absmin) + inflictor.absmax, 0.5);
        dir = q.normalize(dir);
        targ.velocity = targ.velocity + q.scale(dir, damage * 8);

        const rj = dm.deathmatch_rocket_jump_multiplier();
        if ((rj > 1) and ((attacker.classname.eql(S("player"))) and (targ.classname.eql(S("player")))) and (attacker.netname.eql(targ.netname)))
            targ.velocity = targ.velocity + q.scale(dir, damage * rj);
    }

    // check for godmode or invincibility
    if (q.has(targ.flags, lq.FL_GODMODE))
        return;

    if (targ.get(lq.invincible_finished) >= q.time.get()) {
        // (The original checks and sets `self.invincible_sound`, not `targ`'s.)
        const self = q.me();
        if (self.get(lq.invincible_sound) < q.time.get()) {
            q.sound(targ, lq.CHAN_ITEM, S("items/protect3.wav"), 1, lq.ATTN_NORM);
            self.set(lq.invincible_sound, q.time.get() + 2);
        }

        return;
    }

    // team play damage avoidance
    const attackerteam = attacker.team;
    const targteam = targ.team;
    const on_team = attackerteam != 0;

    if ((q.teamplay.get() == 1) and (targteam == attackerteam) and
        (attacker.classname.eql(S("player"))) and on_team and
        inflictor.classname.neq(S("door")))
        return;

    if ((q.teamplay.get() == 3) and (targteam == attackerteam) and
        (attacker.classname.eql(S("player"))) and on_team and
        (targ.neq(attacker)) and inflictor.classname.neq(S("door")))
        return;

    // do the damage
    targ.health = targ.health - take;

    if (targ.health <= 0) {
        targ.set(lq.deathtype, temp_deathtype);
        Killed(targ, attacker);
        return;
    }

    //react to the damage
    const oldself = q.self.get();
    q.self.set(targ);
    const self = q.me();

    if ((q.has(self.flags, lq.FL_MONSTER)) and attacker.neq(q.world.get())) {
        //get mad unless of the same class (except for soldiers)
        if (self.neq(attacker) and attacker.neq(self.enemy)) {
            if ((self.classname.neq(attacker.classname)) or (self.classname.eql(S("monster_army")))) {
                if (self.enemy.classname.eql(S("player")))
                    self.set(lq.oldenemy, self.enemy);

                self.enemy = attacker;
                ai.FoundTarget();
            }
        }
    }

    if (!q.fnIsNull(self.get(lq.th_pain))) {
        q.callAs(lq.ThPain, self.get(lq.th_pain).?)(attacker, take);
        // nightmare mode monsters don't go into pain frames often
        if (lq.skill.get() == 3)
            self.set(lq.pain_finished, q.time.get() + 5);
    }

    q.self.set(oldself);
}

/// T_RadiusDamage
pub export fn T_RadiusDamage(inflictor: Entity, attacker: Entity, damage: f32, ignore: Entity, dtype: String) void {
    var head = q.findradius(inflictor.origin, damage + 40);

    while (!head.isNull()) {
        if (head.neq(ignore)) {
            if (head.takedamage != 0) {
                const org = head.origin + q.scale(@as(Vector, head.mins) + head.maxs, 0.5);
                var points = 0.5 * q.vlen(inflictor.origin - org);

                if (points < 0)
                    points = 0;

                points = damage - points;

                if (head.eql(attacker))
                    points = points * 0.5;

                if (points > 0) {
                    if (CanDamage(head, inflictor) != 0) {
                        head.set(lq.deathtype, dtype);
                        // shambler takes half damage from all explosions
                        if (head.classname.eql(S("monster_shambler"))) {
                            T_Damage(head, inflictor, attacker, points * 0.5);
                        } else {
                            T_Damage(head, inflictor, attacker, points);
                        }
                    }
                }
            }
        }
        head = head.chain;
    }
}

/// T_BeamDamage
pub export fn T_BeamDamage(attacker: Entity, damage: f32) void {
    var head = q.findradius(attacker.origin, damage + 40);

    while (!head.isNull()) {
        if (head.takedamage != 0) {
            var points = 0.5 * q.vlen(@as(Vector, attacker.origin) - head.origin);
            if (points < 0)
                points = 0;

            points = damage - points;

            if (head.eql(attacker))
                points = points * 0.5;

            if (points > 0) {
                if (CanDamage(head, attacker) != 0) {
                    if (head.classname.eql(S("monster_shambler"))) {
                        T_Damage(head, attacker, attacker, points * 0.5);
                    } else {
                        T_Damage(head, attacker, attacker, points);
                    }
                }
            }
        }
        head = head.chain;
    }
}
