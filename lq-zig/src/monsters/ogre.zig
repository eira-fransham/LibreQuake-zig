//! monsters/ogre.qc
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
//! OGRE

const q = @import("../defs.zig");
const lq = @import("../lq.zig");
const loc = @import("../localized_text.zig");
const S = q.S;
const Entity = q.Entity;
const Function = q.Function;
const String = q.String;
const Vector = q.Vector;
const ai = @import("../ai.zig");
const combat = @import("../combat.zig");
const fight = @import("../fight.zig");
const items = @import("../items.zig");
const monsters = @import("../monsters.zig");
const player = @import("../player.zig");
const subs = @import("../subs.zig");
const weapons = @import("../weapons.zig");

/// The `$frame` macros, numbered from 0 in declaration order.
const Frame = enum(u8) {
    stand1,
    stand2,
    stand3,
    stand4,
    stand5,
    stand6,
    stand7,
    stand8,
    stand9,
    walk1,
    walk2,
    walk3,
    walk4,
    walk5,
    walk6,
    walk7,
    walk8,
    walk9,
    walk10,
    walk11,
    walk12,
    walk13,
    walk14,
    walk15,
    walk16,
    run1,
    run2,
    run3,
    run4,
    run5,
    run6,
    run7,
    run8,
    swing1,
    swing2,
    swing3,
    swing4,
    swing5,
    swing6,
    swing7,
    swing8,
    swing9,
    swing10,
    swing11,
    swing12,
    swing13,
    swing14,
    smash1,
    smash2,
    smash3,
    smash4,
    smash5,
    smash6,
    smash7,
    smash8,
    smash9,
    smash10,
    smash11,
    smash12,
    smash13,
    smash14,
    shoot1,
    shoot2,
    shoot3,
    shoot4,
    shoot5,
    shoot6,
    pain1,
    pain2,
    pain3,
    pain4,
    pain5,
    painb1,
    painb2,
    painb3,
    painc1,
    painc2,
    painc3,
    painc4,
    painc5,
    painc6,
    paind1,
    paind2,
    paind3,
    paind4,
    paind5,
    paind6,
    paind7,
    paind8,
    paind9,
    paind10,
    paind11,
    paind12,
    paind13,
    paind14,
    paind15,
    paind16,
    paine1,
    paine2,
    paine3,
    paine4,
    paine5,
    paine6,
    paine7,
    paine8,
    paine9,
    paine10,
    paine11,
    paine12,
    paine13,
    paine14,
    paine15,
    death1,
    death2,
    death3,
    death4,
    death5,
    death6,
    death7,
    death8,
    death9,
    death10,
    death11,
    death12,
    death13,
    death14,
    bdeath1,
    bdeath2,
    bdeath3,
    bdeath4,
    bdeath5,
    bdeath6,
    bdeath7,
    bdeath8,
    bdeath9,
    bdeath10,
    pull1,
    pull2,
    pull3,
    pull4,
    pull5,
    pull6,
    pull7,
    pull8,
    pull9,
    pull10,
    pull11,
};

/// `$frame`, as a float.
inline fn fr(comptime frame: Frame) f32 {
    return @floatFromInt(@backingInt(frame));
}

/// The `[$frame, next]` prefix of a state function.
inline fn state(comptime frame: Frame, comptime next: anytype) void {
    q.setState(fr(frame), q.func(next));
}

pub export fn OgreGrenadeExplode() void {
    const self = q.me();
    combat.T_RadiusDamage(self, self.owner, 40, q.world.get(), S(""));
    q.sound(self, lq.CHAN_VOICE, S("weapons/r_exp3.wav"), 1, lq.ATTN_NORM);

    q.WriteByte(lq.MSG_BROADCAST, lq.SVC_TEMPENTITY);
    q.WriteByte(lq.MSG_BROADCAST, lq.TE_EXPLOSION);
    q.WriteCoord(lq.MSG_BROADCAST, self.origin[0]);
    q.WriteCoord(lq.MSG_BROADCAST, self.origin[1]);
    q.WriteCoord(lq.MSG_BROADCAST, self.origin[2]);

    self.velocity = q.vec(0, 0, 0);
    self.touch = null;
    q.setmodel(self, S("progs/s_explod.spr"));
    self.solid = lq.SOLID_NOT;
    weapons.s_explode1();
}

pub export fn OgreGrenadeTouch() void {
    const self = q.me();
    const other = q.other.get();
    if (other.eql(self.owner))
        return; // don't explode on owner

    if (other.takedamage == lq.DAMAGE_AIM) {
        OgreGrenadeExplode();
        return;
    }

    q.sound(self, lq.CHAN_VOICE, S("weapons/bounce.wav"), 1, lq.ATTN_NORM); // bounce sound

    if (q.veq(self.velocity, q.vec(0, 0, 0)))
        self.avelocity = q.vec(0, 0, 0);
}

/// OgreFireGrenade
pub export fn OgreFireGrenade() void {
    const self = q.me();

    self.effects = q.bor(self.effects, lq.EF_MUZZLEFLASH);

    q.sound(self, lq.CHAN_WEAPON, S("weapons/grenade.wav"), 1, lq.ATTN_NORM);

    const missile = q.spawn();
    missile.classname = S("ogre_grenade"); //gnounc
    missile.owner = self;
    missile.movetype = lq.MOVETYPE_BOUNCE;
    missile.solid = lq.SOLID_BBOX;

    // set missile speed

    subs.makevectors2(self.angles);

    missile.velocity = q.normalize(@as(Vector, self.enemy.origin) - self.origin);
    missile.velocity = q.scale(missile.velocity, 600);
    missile.velocity[2] = 200;

    missile.avelocity = q.vec(300, 300, 300);

    missile.angles = q.vectoangles(missile.velocity);

    missile.touch = q.func(OgreGrenadeTouch);

    // set missile duration
    missile.nextthink = q.time.get() + 2.5;
    missile.think = q.func(OgreGrenadeExplode);

    q.setmodel(missile, S("progs/grenade.mdl"));
    q.setsize(missile, q.vec(0, 0, 0), q.vec(0, 0, 0));
    q.setorigin(missile, self.origin);
}

//=============================================================================

/// chainsaw
///
/// FIXME
pub export fn chainsaw(side: f32) void {
    const self = q.me();

    if (self.enemy.isNull())
        return;

    if (combat.CanDamage(self.enemy, self) == 0)
        return;

    fight.ai_charge(10);

    const delta = @as(Vector, self.enemy.origin) - self.origin;

    if (q.vlen(delta) > 100)
        return;

    const ldmg = (q.random() + q.random() + q.random()) * 4;
    combat.T_Damage(self.enemy, self, self, ldmg);

    if (side != 0) {
        subs.makevectors2(self.angles);
        if (side == 1)
            weapons.SpawnMeatSpray(self.origin + q.scale(q.v_forward.get(), 16), q.scale(q.v_right.get(), weapons.crandom() * 100))
        else
            weapons.SpawnMeatSpray(self.origin + q.scale(q.v_forward.get(), 16), q.scale(q.v_right.get(), side));
    }
}

pub export fn ogre_stand1() void {
    state(.stand1, ogre_stand2);
    ai.ai_stand();
}

pub export fn ogre_stand2() void {
    state(.stand2, ogre_stand3);
    ai.ai_stand();
}

pub export fn ogre_stand3() void {
    state(.stand3, ogre_stand4);
    ai.ai_stand();
}

pub export fn ogre_stand4() void {
    state(.stand4, ogre_stand5);
    ai.ai_stand();
}

pub export fn ogre_stand5() void {
    state(.stand5, ogre_stand6);
    if (q.random() < 0.2)
        q.sound(q.me(), lq.CHAN_VOICE, S("ogre/ogidle.wav"), 1, lq.ATTN_IDLE);

    ai.ai_stand();
}

pub export fn ogre_stand6() void {
    state(.stand6, ogre_stand7);
    ai.ai_stand();
}

pub export fn ogre_stand7() void {
    state(.stand7, ogre_stand8);
    ai.ai_stand();
}

pub export fn ogre_stand8() void {
    state(.stand8, ogre_stand9);
    ai.ai_stand();
}

pub export fn ogre_stand9() void {
    state(.stand9, ogre_stand1);
    ai.ai_stand();
}

pub export fn ogre_walk1() void {
    state(.walk1, ogre_walk2);
    ai.ai_walk(3);
}

pub export fn ogre_walk2() void {
    state(.walk2, ogre_walk3);
    ai.ai_walk(2);
}

pub export fn ogre_walk3() void {
    state(.walk3, ogre_walk4);
    ai.ai_walk(2);

    if (q.random() < 0.2)
        q.sound(q.me(), lq.CHAN_VOICE, S("ogre/ogidle.wav"), 1, lq.ATTN_IDLE);
}

pub export fn ogre_walk4() void {
    state(.walk4, ogre_walk5);
    ai.ai_walk(2);
}

pub export fn ogre_walk5() void {
    state(.walk5, ogre_walk6);
    ai.ai_walk(2);
}

pub export fn ogre_walk6() void {
    state(.walk6, ogre_walk7);
    ai.ai_walk(5);

    if (q.random() < 0.1)
        q.sound(q.me(), lq.CHAN_VOICE, S("ogre/ogdrag.wav"), 1, lq.ATTN_IDLE);
}

pub export fn ogre_walk7() void {
    state(.walk7, ogre_walk8);
    ai.ai_walk(3);
}

pub export fn ogre_walk8() void {
    state(.walk8, ogre_walk9);
    ai.ai_walk(2);
}

pub export fn ogre_walk9() void {
    state(.walk9, ogre_walk10);
    ai.ai_walk(3);
}

pub export fn ogre_walk10() void {
    state(.walk10, ogre_walk11);
    ai.ai_walk(1);
}

pub export fn ogre_walk11() void {
    state(.walk11, ogre_walk12);
    ai.ai_walk(2);
}

pub export fn ogre_walk12() void {
    state(.walk12, ogre_walk13);
    ai.ai_walk(3);
}

pub export fn ogre_walk13() void {
    state(.walk13, ogre_walk14);
    ai.ai_walk(3);
}

pub export fn ogre_walk14() void {
    state(.walk14, ogre_walk15);
    ai.ai_walk(3);
}

pub export fn ogre_walk15() void {
    state(.walk15, ogre_walk16);
    ai.ai_walk(3);
}

pub export fn ogre_walk16() void {
    state(.walk16, ogre_walk1);
    ai.ai_walk(4);
}

pub export fn ogre_run1() void {
    state(.run1, ogre_run2);
    ai.ai_run(9);

    if (q.random() < 0.2)
        q.sound(q.me(), lq.CHAN_VOICE, S("ogre/ogidle2.wav"), 1, lq.ATTN_IDLE);
}

pub export fn ogre_run2() void {
    state(.run2, ogre_run3);
    ai.ai_run(12);
}

pub export fn ogre_run3() void {
    state(.run3, ogre_run4);
    ai.ai_run(8);
}

pub export fn ogre_run4() void {
    state(.run4, ogre_run5);
    ai.ai_run(22);
}

pub export fn ogre_run5() void {
    state(.run5, ogre_run6);
    ai.ai_run(16);
}

pub export fn ogre_run6() void {
    state(.run6, ogre_run7);
    ai.ai_run(4);
}

pub export fn ogre_run7() void {
    state(.run7, ogre_run8);
    ai.ai_run(13);
}

pub export fn ogre_run8() void {
    state(.run8, ogre_run1);
    ai.ai_run(24);
}

pub export fn ogre_swing1() void {
    state(.swing1, ogre_swing2);
    fight.ai_charge(11);
    q.sound(q.me(), lq.CHAN_WEAPON, S("ogre/ogsawatk.wav"), 1, lq.ATTN_NORM);
}

pub export fn ogre_swing2() void {
    state(.swing2, ogre_swing3);
    fight.ai_charge(1);
}

pub export fn ogre_swing3() void {
    state(.swing3, ogre_swing4);
    fight.ai_charge(4);
}

pub export fn ogre_swing4() void {
    state(.swing4, ogre_swing5);
    fight.ai_charge(13);
}

pub export fn ogre_swing5() void {
    state(.swing5, ogre_swing6);
    fight.ai_charge(9);
    chainsaw(0);
    const self = q.me();
    self.angles[1] = self.angles[1] + q.random() * 25;
}

pub export fn ogre_swing6() void {
    state(.swing6, ogre_swing7);
    chainsaw(200);
    const self = q.me();
    self.angles[1] = self.angles[1] + q.random() * 25;
}

pub export fn ogre_swing7() void {
    state(.swing7, ogre_swing8);
    chainsaw(0);
    const self = q.me();
    self.angles[1] = self.angles[1] + q.random() * 25;
}

pub export fn ogre_swing8() void {
    state(.swing8, ogre_swing9);
    chainsaw(0);
    const self = q.me();
    self.angles[1] = self.angles[1] + q.random() * 25;
}

pub export fn ogre_swing9() void {
    state(.swing9, ogre_swing10);
    chainsaw(0);
    const self = q.me();
    self.angles[1] = self.angles[1] + q.random() * 25;
}

pub export fn ogre_swing10() void {
    state(.swing10, ogre_swing11);
    chainsaw(-200);
    const self = q.me();
    self.angles[1] = self.angles[1] + q.random() * 25;
}

pub export fn ogre_swing11() void {
    state(.swing11, ogre_swing12);
    chainsaw(0);
    const self = q.me();
    self.angles[1] = self.angles[1] + q.random() * 25;
}

pub export fn ogre_swing12() void {
    state(.swing12, ogre_swing13);
    fight.ai_charge(3);
}

pub export fn ogre_swing13() void {
    state(.swing13, ogre_swing14);
    fight.ai_charge(8);
}

pub export fn ogre_swing14() void {
    state(.swing14, ogre_run1);
    fight.ai_charge(9);
}

pub export fn ogre_smash1() void {
    state(.smash1, ogre_smash2);
    fight.ai_charge(6);
    q.sound(q.me(), lq.CHAN_WEAPON, S("ogre/ogsawatk.wav"), 1, lq.ATTN_NORM);
}

pub export fn ogre_smash2() void {
    state(.smash2, ogre_smash3);
    fight.ai_charge(0);
}

pub export fn ogre_smash3() void {
    state(.smash3, ogre_smash4);
    fight.ai_charge(0);
}

pub export fn ogre_smash4() void {
    state(.smash4, ogre_smash5);
    fight.ai_charge(1);
}

pub export fn ogre_smash5() void {
    state(.smash5, ogre_smash6);
    fight.ai_charge(4);
}

pub export fn ogre_smash6() void {
    state(.smash6, ogre_smash7);
    fight.ai_charge(4);
    chainsaw(0);
}

pub export fn ogre_smash7() void {
    state(.smash7, ogre_smash8);
    fight.ai_charge(4);
    chainsaw(0);
}

pub export fn ogre_smash8() void {
    state(.smash8, ogre_smash9);
    fight.ai_charge(10);
    chainsaw(0);
}

pub export fn ogre_smash9() void {
    state(.smash9, ogre_smash10);
    fight.ai_charge(13);
    chainsaw(0);
}

pub export fn ogre_smash10() void {
    state(.smash10, ogre_smash11);
    chainsaw(1);
}

pub export fn ogre_smash11() void {
    state(.smash11, ogre_smash12);
    fight.ai_charge(2);
    chainsaw(0);
    const self = q.me();
    self.nextthink = self.nextthink + q.random() * 0.2;
} // slight variation

pub export fn ogre_smash12() void {
    state(.smash12, ogre_smash13);
    fight.ai_charge(0);
}

pub export fn ogre_smash13() void {
    state(.smash13, ogre_smash14);
    fight.ai_charge(4);
}

pub export fn ogre_smash14() void {
    state(.smash14, ogre_run1);
    fight.ai_charge(12);
}

pub export fn ogre_nail1() void {
    state(.shoot1, ogre_nail2);
    fight.ai_face();
}

pub export fn ogre_nail2() void {
    state(.shoot2, ogre_nail3);
    fight.ai_face();
}

pub export fn ogre_nail3() void {
    state(.shoot2, ogre_nail4);
    fight.ai_face();
}

pub export fn ogre_nail4() void {
    state(.shoot3, ogre_nail5);
    fight.ai_face();
    OgreFireGrenade();
}

pub export fn ogre_nail5() void {
    state(.shoot4, ogre_nail6);
    fight.ai_face();
}

pub export fn ogre_nail6() void {
    state(.shoot5, ogre_nail7);
    fight.ai_face();
}

pub export fn ogre_nail7() void {
    state(.shoot6, ogre_run1);
    fight.ai_face();
}

pub export fn ogre_pain1() void {
    state(.pain1, ogre_pain2);
}

pub export fn ogre_pain2() void {
    state(.pain2, ogre_pain3);
}

pub export fn ogre_pain3() void {
    state(.pain3, ogre_pain4);
}

pub export fn ogre_pain4() void {
    state(.pain4, ogre_pain5);
}

pub export fn ogre_pain5() void {
    state(.pain5, ogre_run1);
}

pub export fn ogre_painb1() void {
    state(.painb1, ogre_painb2);
}

pub export fn ogre_painb2() void {
    state(.painb2, ogre_painb3);
}

pub export fn ogre_painb3() void {
    state(.painb3, ogre_run1);
}

pub export fn ogre_painc1() void {
    state(.painc1, ogre_painc2);
}

pub export fn ogre_painc2() void {
    state(.painc2, ogre_painc3);
}

pub export fn ogre_painc3() void {
    state(.painc3, ogre_painc4);
}

pub export fn ogre_painc4() void {
    state(.painc4, ogre_painc5);
}

pub export fn ogre_painc5() void {
    state(.painc5, ogre_painc6);
}

pub export fn ogre_painc6() void {
    state(.painc6, ogre_run1);
}

pub export fn ogre_paind1() void {
    state(.paind1, ogre_paind2);
}

pub export fn ogre_paind2() void {
    state(.paind2, ogre_paind3);
    ai.ai_pain(10);
}

pub export fn ogre_paind3() void {
    state(.paind3, ogre_paind4);
    ai.ai_pain(9);
}

pub export fn ogre_paind4() void {
    state(.paind4, ogre_paind5);
    ai.ai_pain(4);
}

pub export fn ogre_paind5() void {
    state(.paind5, ogre_paind6);
}

pub export fn ogre_paind6() void {
    state(.paind6, ogre_paind7);
}

pub export fn ogre_paind7() void {
    state(.paind7, ogre_paind8);
}

pub export fn ogre_paind8() void {
    state(.paind8, ogre_paind9);
}

pub export fn ogre_paind9() void {
    state(.paind9, ogre_paind10);
}

pub export fn ogre_paind10() void {
    state(.paind10, ogre_paind11);
}

pub export fn ogre_paind11() void {
    state(.paind11, ogre_paind12);
}

pub export fn ogre_paind12() void {
    state(.paind12, ogre_paind13);
}

pub export fn ogre_paind13() void {
    state(.paind13, ogre_paind14);
}

pub export fn ogre_paind14() void {
    state(.paind14, ogre_paind15);
}

pub export fn ogre_paind15() void {
    state(.paind15, ogre_paind16);
}

pub export fn ogre_paind16() void {
    state(.paind16, ogre_run1);
}

pub export fn ogre_paine1() void {
    state(.paine1, ogre_paine2);
}

pub export fn ogre_paine2() void {
    state(.paine2, ogre_paine3);
    ai.ai_pain(10);
}

pub export fn ogre_paine3() void {
    state(.paine3, ogre_paine4);
    ai.ai_pain(9);
}

pub export fn ogre_paine4() void {
    state(.paine4, ogre_paine5);
    ai.ai_pain(4);
}

pub export fn ogre_paine5() void {
    state(.paine5, ogre_paine6);
}

pub export fn ogre_paine6() void {
    state(.paine6, ogre_paine7);
}

pub export fn ogre_paine7() void {
    state(.paine7, ogre_paine8);
}

pub export fn ogre_paine8() void {
    state(.paine8, ogre_paine9);
}

pub export fn ogre_paine9() void {
    state(.paine9, ogre_paine10);
}

pub export fn ogre_paine10() void {
    state(.paine10, ogre_paine11);
}

pub export fn ogre_paine11() void {
    state(.paine11, ogre_paine12);
}

pub export fn ogre_paine12() void {
    state(.paine12, ogre_paine13);
}

pub export fn ogre_paine13() void {
    state(.paine13, ogre_paine14);
}

pub export fn ogre_paine14() void {
    state(.paine14, ogre_paine15);
}

pub export fn ogre_paine15() void {
    state(.paine15, ogre_run1);
}

pub export fn ogre_pain(attacker: Entity, damage: f32) void {
    _ = attacker;
    _ = damage;
    const self = q.me();

    // don't make multiple pain sounds right after each other
    if (self.get(lq.pain_finished) > q.time.get())
        return;

    q.sound(self, lq.CHAN_VOICE, S("ogre/ogpain1.wav"), 1, lq.ATTN_NORM);

    const r = q.random();

    if (r < 0.25) {
        ogre_pain1();
        self.set(lq.pain_finished, q.time.get() + 1);
    } else if (r < 0.5) {
        ogre_painb1();
        self.set(lq.pain_finished, q.time.get() + 1);
    } else if (r < 0.75) {
        ogre_painc1();
        self.set(lq.pain_finished, q.time.get() + 1);
    } else if (r < 0.88) {
        ogre_paind1();
        self.set(lq.pain_finished, q.time.get() + 2);
    } else {
        ogre_paine1();
        self.set(lq.pain_finished, q.time.get() + 2);
    }
}

pub export fn ogre_die1() void {
    state(.death1, ogre_die2);
}

pub export fn ogre_die2() void {
    state(.death2, ogre_die3);
}

pub export fn ogre_die3() void {
    state(.death3, ogre_die4);
    const self = q.me();
    self.solid = lq.SOLID_NOT;
    self.ammo_rockets = 2;
    items.DropBackpack();
}

pub export fn ogre_die4() void {
    state(.death4, ogre_die5);
}

pub export fn ogre_die5() void {
    state(.death5, ogre_die6);
}

pub export fn ogre_die6() void {
    state(.death6, ogre_die7);
}

pub export fn ogre_die7() void {
    state(.death7, ogre_die8);
}

pub export fn ogre_die8() void {
    state(.death8, ogre_die9);
}

pub export fn ogre_die9() void {
    state(.death9, ogre_die10);
}

pub export fn ogre_die10() void {
    state(.death10, ogre_die11);
}

pub export fn ogre_die11() void {
    state(.death11, ogre_die12);
}

pub export fn ogre_die12() void {
    state(.death12, ogre_die13);
}

pub export fn ogre_die13() void {
    state(.death13, ogre_die14);
}

pub export fn ogre_die14() void {
    state(.death14, ogre_die14);
}

pub export fn ogre_bdie1() void {
    state(.bdeath1, ogre_bdie2);
}

pub export fn ogre_bdie2() void {
    state(.bdeath2, ogre_bdie3);
    ai.ai_forward(5);
}

pub export fn ogre_bdie3() void {
    state(.bdeath3, ogre_bdie4);
    const self = q.me();
    self.solid = lq.SOLID_NOT;
    self.ammo_rockets = 2;
    items.DropBackpack();
}

pub export fn ogre_bdie4() void {
    state(.bdeath4, ogre_bdie5);
    ai.ai_forward(1);
}

pub export fn ogre_bdie5() void {
    state(.bdeath5, ogre_bdie6);
    ai.ai_forward(3);
}

pub export fn ogre_bdie6() void {
    state(.bdeath6, ogre_bdie7);
    ai.ai_forward(7);
}

pub export fn ogre_bdie7() void {
    state(.bdeath7, ogre_bdie8);
    ai.ai_forward(25);
}

pub export fn ogre_bdie8() void {
    state(.bdeath8, ogre_bdie9);
}

pub export fn ogre_bdie9() void {
    state(.bdeath9, ogre_bdie10);
}

pub export fn ogre_bdie10() void {
    state(.bdeath10, ogre_bdie10);
}

pub export fn ogre_die() void {
    const self = q.me();

    // check for gib
    if (self.health < -80) {
        q.sound(self, lq.CHAN_VOICE, S("player/udeath.wav"), 1, lq.ATTN_NORM);
        player.ThrowHead(S("progs/h_ogre.mdl"), self.health);
        player.ThrowGib(S("progs/gib3.mdl"), self.health);
        player.ThrowGib(S("progs/gib3.mdl"), self.health);
        player.ThrowGib(S("progs/gib3.mdl"), self.health);

        return;
    }

    q.sound(self, lq.CHAN_VOICE, S("ogre/ogdth.wav"), 1, lq.ATTN_NORM);

    if (q.random() < 0.5)
        ogre_die1()
    else
        ogre_bdie1();
}

pub export fn ogre_melee() void {
    if (q.random() > 0.5)
        ogre_smash1()
    else
        ogre_swing1();
}

/// QUAKED monster_ogre (1 0 0) (-32 -32 -24) (32 32 64) Ambush
/// {
///     model({"path": "progs/ogre.mdl", "skin": 0, "frame": 0});
/// }
pub export fn monster_ogre() void {
    const self = q.me();

    if (q.deathmatch.get() != 0) {
        q.remove(self);
        return;
    }

    _ = q.precache_model(S("progs/ogre.mdl"));
    _ = q.precache_model(S("progs/h_ogre.mdl"));
    _ = q.precache_model(S("progs/grenade.mdl"));

    _ = q.precache_sound(S("ogre/ogdrag.wav"));
    _ = q.precache_sound(S("ogre/ogdth.wav"));
    _ = q.precache_sound(S("ogre/ogidle.wav"));
    _ = q.precache_sound(S("ogre/ogidle2.wav"));
    _ = q.precache_sound(S("ogre/ogpain1.wav"));
    _ = q.precache_sound(S("ogre/ogsawatk.wav"));
    _ = q.precache_sound(S("ogre/ogwake.wav"));

    self.solid = lq.SOLID_SLIDEBOX;
    self.movetype = lq.MOVETYPE_STEP;

    q.setmodel(self, S("progs/ogre.mdl"));

    //gnounc
    self.noise = S("ogre/ogwake.wav"); //gnounc
    self.netname = S("Ogre");
    self.set(lq.killstring, S(loc.LOC_DEATH_OGRE));

    q.setsize(self, lq.VEC_HULL2_MIN, lq.VEC_HULL2_MAX);
    self.health = 200;
    self.max_health = 200;

    self.set(lq.th_stand, q.func(ogre_stand1));
    self.set(lq.th_walk, q.func(ogre_walk1));
    self.set(lq.th_run, q.func(ogre_run1));
    self.set(lq.th_die, q.func(ogre_die));
    self.set(lq.th_melee, q.func(ogre_melee));
    self.set(lq.th_missile, q.func(ogre_nail1));
    self.set(lq.th_pain, q.func(ogre_pain));

    monsters.walkmonster_start();
}

pub export fn monster_ogre_marksman() void {
    monster_ogre();
}
