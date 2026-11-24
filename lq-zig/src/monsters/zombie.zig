//! monsters/zombie.qc
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
//! ZOMBIE

const q = @import("../defs.zig");
const lq = @import("../lq.zig");
const loc = @import("../localized_text.zig");
const S = q.S;
const Entity = q.Entity;
const Function = q.Function;
const String = q.String;
const Vector = q.Vector;
const ai = @import("../ai.zig");
const fight = @import("../fight.zig");
const player = @import("../player.zig");
const combat = @import("../combat.zig");
const subs = @import("../subs.zig");
const monsters = @import("../monsters.zig");

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
    stand10,
    stand11,
    stand12,
    stand13,
    stand14,
    stand15,
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
    walk17,
    walk18,
    walk19,
    run1,
    run2,
    run3,
    run4,
    run5,
    run6,
    run7,
    run8,
    run9,
    run10,
    run11,
    run12,
    run13,
    run14,
    run15,
    run16,
    run17,
    run18,
    atta1,
    atta2,
    atta3,
    atta4,
    atta5,
    atta6,
    atta7,
    atta8,
    atta9,
    atta10,
    atta11,
    atta12,
    atta13,
    attb1,
    attb2,
    attb3,
    attb4,
    attb5,
    attb6,
    attb7,
    attb8,
    attb9,
    attb10,
    attb11,
    attb12,
    attb13,
    attb14,
    attc1,
    attc2,
    attc3,
    attc4,
    attc5,
    attc6,
    attc7,
    attc8,
    attc9,
    attc10,
    attc11,
    attc12,
    paina1,
    paina2,
    paina3,
    paina4,
    paina5,
    paina6,
    paina7,
    paina8,
    paina9,
    paina10,
    paina11,
    paina12,
    painb1,
    painb2,
    painb3,
    painb4,
    painb5,
    painb6,
    painb7,
    painb8,
    painb9,
    painb10,
    painb11,
    painb12,
    painb13,
    painb14,
    painb15,
    painb16,
    painb17,
    painb18,
    painb19,
    painb20,
    painb21,
    painb22,
    painb23,
    painb24,
    painb25,
    painb26,
    painb27,
    painb28,
    painc1,
    painc2,
    painc3,
    painc4,
    painc5,
    painc6,
    painc7,
    painc8,
    painc9,
    painc10,
    painc11,
    painc12,
    painc13,
    painc14,
    painc15,
    painc16,
    painc17,
    painc18,
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
    paine16,
    paine17,
    paine18,
    paine19,
    paine20,
    paine21,
    paine22,
    paine23,
    paine24,
    paine25,
    paine26,
    paine27,
    paine28,
    paine29,
    paine30,
    cruc_1,
    cruc_2,
    cruc_3,
    cruc_4,
    cruc_5,
    cruc_6,
};

/// `$frame`, as a float.
inline fn fr(comptime frame: Frame) f32 {
    return @floatFromInt(@backingInt(frame));
}

/// The `[$frame, next]` prefix of a state function.
inline fn state(comptime frame: Frame, comptime next: anytype) void {
    q.setState(fr(frame), q.func(next));
}

pub const SPAWN_CRUCIFIED: f32 = 1;

pub const inpain = q.userField(f32, "inpain");

pub export fn zombie_stand1() void {
    state(.stand1, zombie_stand2);
    ai.ai_stand();
}

pub export fn zombie_stand2() void {
    state(.stand2, zombie_stand3);
    ai.ai_stand();
}

pub export fn zombie_stand3() void {
    state(.stand3, zombie_stand4);
    ai.ai_stand();
}

pub export fn zombie_stand4() void {
    state(.stand4, zombie_stand5);
    ai.ai_stand();
}

pub export fn zombie_stand5() void {
    state(.stand5, zombie_stand6);
    ai.ai_stand();
}

pub export fn zombie_stand6() void {
    state(.stand6, zombie_stand7);
    ai.ai_stand();
}

pub export fn zombie_stand7() void {
    state(.stand7, zombie_stand8);
    ai.ai_stand();
}

pub export fn zombie_stand8() void {
    state(.stand8, zombie_stand9);
    ai.ai_stand();
}

pub export fn zombie_stand9() void {
    state(.stand9, zombie_stand10);
    ai.ai_stand();
}

pub export fn zombie_stand10() void {
    state(.stand10, zombie_stand11);
    ai.ai_stand();
}

pub export fn zombie_stand11() void {
    state(.stand11, zombie_stand12);
    ai.ai_stand();
}

pub export fn zombie_stand12() void {
    state(.stand12, zombie_stand13);
    ai.ai_stand();
}

pub export fn zombie_stand13() void {
    state(.stand13, zombie_stand14);
    ai.ai_stand();
}

pub export fn zombie_stand14() void {
    state(.stand14, zombie_stand15);
    ai.ai_stand();
}

pub export fn zombie_stand15() void {
    state(.stand15, zombie_stand1);
    ai.ai_stand();
}

pub export fn zombie_cruc1() void {
    state(.cruc_1, zombie_cruc2);
    const self = q.me();
    if (q.random() < 0.1)
        q.sound(self, lq.CHAN_VOICE, S("zombie/idle_w2.wav"), 1, lq.ATTN_STATIC);
}

pub export fn zombie_cruc2() void {
    state(.cruc_2, zombie_cruc3);
    const self = q.me();
    self.nextthink = q.time.get() + 0.1 + q.random() * 0.1;
}

pub export fn zombie_cruc3() void {
    state(.cruc_3, zombie_cruc4);
    const self = q.me();
    self.nextthink = q.time.get() + 0.1 + q.random() * 0.1;
}

pub export fn zombie_cruc4() void {
    state(.cruc_4, zombie_cruc5);
    const self = q.me();
    self.nextthink = q.time.get() + 0.1 + q.random() * 0.1;
}

pub export fn zombie_cruc5() void {
    state(.cruc_5, zombie_cruc6);
    const self = q.me();
    self.nextthink = q.time.get() + 0.1 + q.random() * 0.1;
}

pub export fn zombie_cruc6() void {
    state(.cruc_6, zombie_cruc1);
    const self = q.me();
    self.nextthink = q.time.get() + 0.1 + q.random() * 0.1;
}

pub export fn zombie_walk1() void {
    state(.walk1, zombie_walk2);
    ai.ai_walk(0);
}

pub export fn zombie_walk2() void {
    state(.walk2, zombie_walk3);
    ai.ai_walk(2);
}

pub export fn zombie_walk3() void {
    state(.walk3, zombie_walk4);
    ai.ai_walk(3);
}

pub export fn zombie_walk4() void {
    state(.walk4, zombie_walk5);
    ai.ai_walk(2);
}

pub export fn zombie_walk5() void {
    state(.walk5, zombie_walk6);
    ai.ai_walk(1);
}

pub export fn zombie_walk6() void {
    state(.walk6, zombie_walk7);
    ai.ai_walk(0);
}

pub export fn zombie_walk7() void {
    state(.walk7, zombie_walk8);
    ai.ai_walk(0);
}

pub export fn zombie_walk8() void {
    state(.walk8, zombie_walk9);
    ai.ai_walk(0);
}

pub export fn zombie_walk9() void {
    state(.walk9, zombie_walk10);
    ai.ai_walk(0);
}

pub export fn zombie_walk10() void {
    state(.walk10, zombie_walk11);
    ai.ai_walk(0);
}

pub export fn zombie_walk11() void {
    state(.walk11, zombie_walk12);
    ai.ai_walk(2);
}

pub export fn zombie_walk12() void {
    state(.walk12, zombie_walk13);
    ai.ai_walk(2);
}

pub export fn zombie_walk13() void {
    state(.walk13, zombie_walk14);
    ai.ai_walk(1);
}

pub export fn zombie_walk14() void {
    state(.walk14, zombie_walk15);
    ai.ai_walk(0);
}

pub export fn zombie_walk15() void {
    state(.walk15, zombie_walk16);
    ai.ai_walk(0);
}

pub export fn zombie_walk16() void {
    state(.walk16, zombie_walk17);
    ai.ai_walk(0);
}

pub export fn zombie_walk17() void {
    state(.walk17, zombie_walk18);
    ai.ai_walk(0);
}

pub export fn zombie_walk18() void {
    state(.walk18, zombie_walk19);
    ai.ai_walk(0);
}

pub export fn zombie_walk19() void {
    state(.walk19, zombie_walk1);
    const self = q.me();
    ai.ai_walk(0);
    if (q.random() < 0.2)
        q.sound(self, lq.CHAN_VOICE, S("zombie/z_idle.wav"), 1, lq.ATTN_IDLE);
}

pub export fn zombie_run1() void {
    state(.run1, zombie_run2);
    const self = q.me();
    ai.ai_run(1);
    self.set(inpain, 0);
}

pub export fn zombie_run2() void {
    state(.run2, zombie_run3);
    ai.ai_run(1);
}

pub export fn zombie_run3() void {
    state(.run3, zombie_run4);
    ai.ai_run(0);
}

pub export fn zombie_run4() void {
    state(.run4, zombie_run5);
    ai.ai_run(1);
}

pub export fn zombie_run5() void {
    state(.run5, zombie_run6);
    ai.ai_run(2);
}

pub export fn zombie_run6() void {
    state(.run6, zombie_run7);
    ai.ai_run(3);
}

pub export fn zombie_run7() void {
    state(.run7, zombie_run8);
    ai.ai_run(4);
}

pub export fn zombie_run8() void {
    state(.run8, zombie_run9);
    ai.ai_run(4);
}

pub export fn zombie_run9() void {
    state(.run9, zombie_run10);
    ai.ai_run(2);
}

pub export fn zombie_run10() void {
    state(.run10, zombie_run11);
    ai.ai_run(0);
}

pub export fn zombie_run11() void {
    state(.run11, zombie_run12);
    ai.ai_run(0);
}

pub export fn zombie_run12() void {
    state(.run12, zombie_run13);
    ai.ai_run(0);
}

pub export fn zombie_run13() void {
    state(.run13, zombie_run14);
    ai.ai_run(2);
}

pub export fn zombie_run14() void {
    state(.run14, zombie_run15);
    ai.ai_run(4);
}

pub export fn zombie_run15() void {
    state(.run15, zombie_run16);
    ai.ai_run(6);
}

pub export fn zombie_run16() void {
    state(.run16, zombie_run17);
    ai.ai_run(7);
}

pub export fn zombie_run17() void {
    state(.run17, zombie_run18);
    ai.ai_run(3);
}

pub export fn zombie_run18() void {
    state(.run18, zombie_run1);
    const self = q.me();
    ai.ai_run(8);
    if (q.random() < 0.2)
        q.sound(self, lq.CHAN_VOICE, S("zombie/z_idle.wav"), 1, lq.ATTN_IDLE);
    if (q.random() > 0.8)
        q.sound(self, lq.CHAN_VOICE, S("zombie/z_idle1.wav"), 1, lq.ATTN_IDLE);
}

pub export fn ZombieGrenadeTouch() void {
    const self = q.me();
    const other = q.other.get();
    if (other.eql(self.owner))
        return; // don't explode on owner

    if (other.takedamage != 0) {
        combat.T_Damage(other, self, self.owner, 10);
        q.sound(self, lq.CHAN_WEAPON, S("zombie/z_hit.wav"), 1, lq.ATTN_NORM);
        q.remove(self);
        return;
    }

    q.sound(self, lq.CHAN_WEAPON, S("zombie/z_miss.wav"), 1, lq.ATTN_NORM); // bounce sound
    self.velocity = q.vec(0, 0, 0);
    self.avelocity = q.vec(0, 0, 0);
    self.touch = q.func(subs.SUB_Remove);
}

pub export fn ZombieFireGrenade(st: Vector) void {
    const self = q.me();

    q.sound(self, lq.CHAN_WEAPON, S("zombie/z_shot1.wav"), 1, lq.ATTN_NORM);

    const missile = q.spawn();
    missile.classname = S("zombie_grenade"); //gnounc
    missile.owner = self;
    missile.movetype = lq.MOVETYPE_BOUNCE;
    missile.solid = lq.SOLID_BBOX;

    // calc org
    const org = self.origin + q.scale(q.v_forward.get(), st[0]) + q.scale(q.v_right.get(), st[1]) + q.scale(q.v_up.get(), st[2] - 24);

    // set missile speed

    subs.makevectors2(self.angles);

    missile.velocity = q.normalize(self.enemy.origin - org);
    missile.velocity = q.scale(missile.velocity, 600);
    missile.velocity[2] = 200;

    missile.avelocity = q.vec(3000, 1000, 2000);

    missile.touch = q.func(ZombieGrenadeTouch);

    // set missile duration
    missile.nextthink = q.time.get() + 2.5;
    missile.think = q.func(subs.SUB_Remove);

    q.setmodel(missile, S("progs/zom_gib.mdl"));
    q.setsize(missile, q.vec(0, 0, 0), q.vec(0, 0, 0));
    q.setorigin(missile, org);
}

pub export fn zombie_atta1() void {
    state(.atta1, zombie_atta2);
    fight.ai_face();
}

pub export fn zombie_atta2() void {
    state(.atta2, zombie_atta3);
    fight.ai_face();
}

pub export fn zombie_atta3() void {
    state(.atta3, zombie_atta4);
    fight.ai_face();
}

pub export fn zombie_atta4() void {
    state(.atta4, zombie_atta5);
    fight.ai_face();
}

pub export fn zombie_atta5() void {
    state(.atta5, zombie_atta6);
    fight.ai_face();
}

pub export fn zombie_atta6() void {
    state(.atta6, zombie_atta7);
    fight.ai_face();
}

pub export fn zombie_atta7() void {
    state(.atta7, zombie_atta8);
    fight.ai_face();
}

pub export fn zombie_atta8() void {
    state(.atta8, zombie_atta9);
    fight.ai_face();
}

pub export fn zombie_atta9() void {
    state(.atta9, zombie_atta10);
    fight.ai_face();
}

pub export fn zombie_atta10() void {
    state(.atta10, zombie_atta11);
    fight.ai_face();
}

pub export fn zombie_atta11() void {
    state(.atta11, zombie_atta12);
    fight.ai_face();
}

pub export fn zombie_atta12() void {
    state(.atta12, zombie_atta13);
    fight.ai_face();
}

pub export fn zombie_atta13() void {
    state(.atta13, zombie_run1);
    fight.ai_face();
    ZombieFireGrenade(q.vec(-10, -22, 30));
}

pub export fn zombie_attb1() void {
    state(.attb1, zombie_attb2);
    fight.ai_face();
}

pub export fn zombie_attb2() void {
    state(.attb2, zombie_attb3);
    fight.ai_face();
}

pub export fn zombie_attb3() void {
    state(.attb3, zombie_attb4);
    fight.ai_face();
}

pub export fn zombie_attb4() void {
    state(.attb4, zombie_attb5);
    fight.ai_face();
}

pub export fn zombie_attb5() void {
    state(.attb5, zombie_attb6);
    fight.ai_face();
}

pub export fn zombie_attb6() void {
    state(.attb6, zombie_attb7);
    fight.ai_face();
}

pub export fn zombie_attb7() void {
    state(.attb7, zombie_attb8);
    fight.ai_face();
}

pub export fn zombie_attb8() void {
    state(.attb8, zombie_attb9);
    fight.ai_face();
}

pub export fn zombie_attb9() void {
    state(.attb9, zombie_attb10);
    fight.ai_face();
}

pub export fn zombie_attb10() void {
    state(.attb10, zombie_attb11);
    fight.ai_face();
}

pub export fn zombie_attb11() void {
    state(.attb11, zombie_attb12);
    fight.ai_face();
}

pub export fn zombie_attb12() void {
    state(.attb12, zombie_attb13);
    fight.ai_face();
}

pub export fn zombie_attb13() void {
    state(.attb13, zombie_attb14);
    fight.ai_face();
}

pub export fn zombie_attb14() void {
    state(.attb13, zombie_run1);
    fight.ai_face();
    ZombieFireGrenade(q.vec(-10, -24, 29));
}

pub export fn zombie_attc1() void {
    state(.attc1, zombie_attc2);
    fight.ai_face();
}

pub export fn zombie_attc2() void {
    state(.attc2, zombie_attc3);
    fight.ai_face();
}

pub export fn zombie_attc3() void {
    state(.attc3, zombie_attc4);
    fight.ai_face();
}

pub export fn zombie_attc4() void {
    state(.attc4, zombie_attc5);
    fight.ai_face();
}

pub export fn zombie_attc5() void {
    state(.attc5, zombie_attc6);
    fight.ai_face();
}

pub export fn zombie_attc6() void {
    state(.attc6, zombie_attc7);
    fight.ai_face();
}

pub export fn zombie_attc7() void {
    state(.attc7, zombie_attc8);
    fight.ai_face();
}

pub export fn zombie_attc8() void {
    state(.attc8, zombie_attc9);
    fight.ai_face();
}

pub export fn zombie_attc9() void {
    state(.attc9, zombie_attc10);
    fight.ai_face();
}

pub export fn zombie_attc10() void {
    state(.attc10, zombie_attc11);
    fight.ai_face();
}

pub export fn zombie_attc11() void {
    state(.attc11, zombie_attc12);
    fight.ai_face();
}

pub export fn zombie_attc12() void {
    state(.attc12, zombie_run1);
    fight.ai_face();
    ZombieFireGrenade(q.vec(-12, -19, 29));
}

pub export fn zombie_missile() void {
    const r = q.random();

    if (r < 0.3)
        zombie_atta1()
    else if (r < 0.6)
        zombie_attb1()
    else
        zombie_attc1();
}

pub export fn zombie_paina1() void {
    state(.paina1, zombie_paina2);
    const self = q.me();
    q.sound(self, lq.CHAN_VOICE, S("zombie/z_pain.wav"), 1, lq.ATTN_NORM);
}

pub export fn zombie_paina2() void {
    state(.paina2, zombie_paina3);
    ai.ai_painforward(3);
}

pub export fn zombie_paina3() void {
    state(.paina3, zombie_paina4);
    ai.ai_painforward(1);
}

pub export fn zombie_paina4() void {
    state(.paina4, zombie_paina5);
    ai.ai_pain(1);
}

pub export fn zombie_paina5() void {
    state(.paina5, zombie_paina6);
    ai.ai_pain(3);
}

pub export fn zombie_paina6() void {
    state(.paina6, zombie_paina7);
    ai.ai_pain(1);
}

pub export fn zombie_paina7() void {
    state(.paina7, zombie_paina8);
}

pub export fn zombie_paina8() void {
    state(.paina8, zombie_paina9);
}

pub export fn zombie_paina9() void {
    state(.paina9, zombie_paina10);
}

pub export fn zombie_paina10() void {
    state(.paina10, zombie_paina11);
}

pub export fn zombie_paina11() void {
    state(.paina11, zombie_paina12);
}

pub export fn zombie_paina12() void {
    state(.paina12, zombie_run1);
}

pub export fn zombie_painb1() void {
    state(.painb1, zombie_painb2);
    const self = q.me();
    q.sound(self, lq.CHAN_VOICE, S("zombie/z_pain1.wav"), 1, lq.ATTN_NORM);
}

pub export fn zombie_painb2() void {
    state(.painb2, zombie_painb3);
    ai.ai_pain(2);
}

pub export fn zombie_painb3() void {
    state(.painb3, zombie_painb4);
    ai.ai_pain(8);
}

pub export fn zombie_painb4() void {
    state(.painb4, zombie_painb5);
    ai.ai_pain(6);
}

pub export fn zombie_painb5() void {
    state(.painb5, zombie_painb6);
    ai.ai_pain(2);
}

pub export fn zombie_painb6() void {
    state(.painb6, zombie_painb7);
}

pub export fn zombie_painb7() void {
    state(.painb7, zombie_painb8);
}

pub export fn zombie_painb8() void {
    state(.painb8, zombie_painb9);
}

pub export fn zombie_painb9() void {
    state(.painb9, zombie_painb10);
    const self = q.me();
    q.sound(self, lq.CHAN_BODY, S("zombie/z_fall.wav"), 1, lq.ATTN_NORM);
}

pub export fn zombie_painb10() void {
    state(.painb10, zombie_painb11);
}

pub export fn zombie_painb11() void {
    state(.painb11, zombie_painb12);
}

pub export fn zombie_painb12() void {
    state(.painb12, zombie_painb13);
}

pub export fn zombie_painb13() void {
    state(.painb13, zombie_painb14);
}

pub export fn zombie_painb14() void {
    state(.painb14, zombie_painb15);
}

pub export fn zombie_painb15() void {
    state(.painb15, zombie_painb16);
}

pub export fn zombie_painb16() void {
    state(.painb16, zombie_painb17);
}

pub export fn zombie_painb17() void {
    state(.painb17, zombie_painb18);
}

pub export fn zombie_painb18() void {
    state(.painb18, zombie_painb19);
}

pub export fn zombie_painb19() void {
    state(.painb19, zombie_painb20);
}

pub export fn zombie_painb20() void {
    state(.painb20, zombie_painb21);
}

pub export fn zombie_painb21() void {
    state(.painb21, zombie_painb22);
}

pub export fn zombie_painb22() void {
    state(.painb22, zombie_painb23);
}

pub export fn zombie_painb23() void {
    state(.painb23, zombie_painb24);
}

pub export fn zombie_painb24() void {
    state(.painb24, zombie_painb25);
}

pub export fn zombie_painb25() void {
    state(.painb25, zombie_painb26);
    ai.ai_painforward(1);
}

pub export fn zombie_painb26() void {
    state(.painb26, zombie_painb27);
}

pub export fn zombie_painb27() void {
    state(.painb27, zombie_painb28);
}

pub export fn zombie_painb28() void {
    state(.painb28, zombie_run1);
}

pub export fn zombie_painc1() void {
    state(.painc1, zombie_painc2);
    const self = q.me();
    q.sound(self, lq.CHAN_VOICE, S("zombie/z_pain1.wav"), 1, lq.ATTN_NORM);
}

pub export fn zombie_painc2() void {
    state(.painc2, zombie_painc3);
}

pub export fn zombie_painc3() void {
    state(.painc3, zombie_painc4);
    ai.ai_pain(3);
}

pub export fn zombie_painc4() void {
    state(.painc4, zombie_painc5);
    ai.ai_pain(1);
}

pub export fn zombie_painc5() void {
    state(.painc5, zombie_painc6);
}

pub export fn zombie_painc6() void {
    state(.painc6, zombie_painc7);
}

pub export fn zombie_painc7() void {
    state(.painc7, zombie_painc8);
}

pub export fn zombie_painc8() void {
    state(.painc8, zombie_painc9);
}

pub export fn zombie_painc9() void {
    state(.painc9, zombie_painc10);
}

pub export fn zombie_painc10() void {
    state(.painc10, zombie_painc11);
}

pub export fn zombie_painc11() void {
    state(.painc11, zombie_painc12);
    ai.ai_painforward(1);
}

pub export fn zombie_painc12() void {
    state(.painc12, zombie_painc13);
    ai.ai_painforward(1);
}

pub export fn zombie_painc13() void {
    state(.painc13, zombie_painc14);
}

pub export fn zombie_painc14() void {
    state(.painc14, zombie_painc15);
}

pub export fn zombie_painc15() void {
    state(.painc15, zombie_painc16);
}

pub export fn zombie_painc16() void {
    state(.painc16, zombie_painc17);
}

pub export fn zombie_painc17() void {
    state(.painc17, zombie_painc18);
}

pub export fn zombie_painc18() void {
    state(.painc18, zombie_run1);
}

pub export fn zombie_paind1() void {
    state(.paind1, zombie_paind2);
    const self = q.me();
    q.sound(self, lq.CHAN_VOICE, S("zombie/z_pain.wav"), 1, lq.ATTN_NORM);
}

pub export fn zombie_paind2() void {
    state(.paind2, zombie_paind3);
}

pub export fn zombie_paind3() void {
    state(.paind3, zombie_paind4);
}

pub export fn zombie_paind4() void {
    state(.paind4, zombie_paind5);
}

pub export fn zombie_paind5() void {
    state(.paind5, zombie_paind6);
}

pub export fn zombie_paind6() void {
    state(.paind6, zombie_paind7);
}

pub export fn zombie_paind7() void {
    state(.paind7, zombie_paind8);
}

pub export fn zombie_paind8() void {
    state(.paind8, zombie_paind9);
}

pub export fn zombie_paind9() void {
    state(.paind9, zombie_paind10);
    ai.ai_pain(1);
}

pub export fn zombie_paind10() void {
    state(.paind10, zombie_paind11);
}

pub export fn zombie_paind11() void {
    state(.paind11, zombie_paind12);
}

pub export fn zombie_paind12() void {
    state(.paind12, zombie_paind13);
}

pub export fn zombie_paind13() void {
    state(.paind13, zombie_run1);
}

pub export fn zombie_paine1() void {
    state(.paine1, zombie_paine2);
    const self = q.me();
    q.sound(self, lq.CHAN_VOICE, S("zombie/z_pain.wav"), 1, lq.ATTN_NORM);
    self.health = 60;
}

pub export fn zombie_paine2() void {
    state(.paine2, zombie_paine3);
    ai.ai_pain(8);
}

pub export fn zombie_paine3() void {
    state(.paine3, zombie_paine4);
    ai.ai_pain(5);
}

pub export fn zombie_paine4() void {
    state(.paine4, zombie_paine5);
    ai.ai_pain(3);
}

pub export fn zombie_paine5() void {
    state(.paine5, zombie_paine6);
    ai.ai_pain(1);
}

pub export fn zombie_paine6() void {
    state(.paine6, zombie_paine7);
    ai.ai_pain(2);
}

pub export fn zombie_paine7() void {
    state(.paine7, zombie_paine8);
    ai.ai_pain(1);
}

pub export fn zombie_paine8() void {
    state(.paine8, zombie_paine9);
    ai.ai_pain(1);
}

pub export fn zombie_paine9() void {
    state(.paine9, zombie_paine10);
    ai.ai_pain(2);
}

pub export fn zombie_paine10() void {
    state(.paine10, zombie_paine11);
    const self = q.me();
    q.sound(self, lq.CHAN_BODY, S("zombie/z_fall.wav"), 1, lq.ATTN_NORM);
    self.solid = lq.SOLID_NOT;
}

pub export fn zombie_paine11() void {
    state(.paine11, zombie_paine12);
    const self = q.me();
    self.nextthink = self.nextthink + 5;
    self.health = 60;
}

pub export fn zombie_paine12() void {
    state(.paine12, zombie_paine13);
    const self = q.me();

    // see if ok to stand up
    self.health = 60;
    q.sound(self, lq.CHAN_VOICE, S("zombie/z_idle.wav"), 1, lq.ATTN_IDLE);
    self.solid = lq.SOLID_SLIDEBOX;

    if (q.walkmove(0, 0) == 0) {
        self.set(lq.count, self.get(lq.count) + 1);
        if (self.get(lq.count) > 5) {
            // This is a fix for the bug where zombies sometimes will be stuck in their fallen state infinitely due to sloped geometry
            // If they fail to revive 5 times, put them out of their misery
            // Only works if no players are within a certain distance of it, so you can't just stand on top of the zombie to kill it
            var t = q.world.get();
            var shouldKill: f32 = 1;
            while (true) {
                // Go through each player
                t = q.nextent(t);
                if (t.classname.neq(S("player")))
                    break;

                // Check to make sure the player isn't close by
                if (q.vlen(@as(Vector, t.origin) - self.origin) < 128) {
                    shouldKill = 0;
                    break;
                }
            }
            // If all players are a certain distance away, kill the zombie.
            if (shouldKill != 0) {
                self.set(lq.count, 0);
                combat.T_Damage(self, self, self, 60);
                return;
            }
        }
        self.think = q.func(zombie_paine11);
        self.solid = lq.SOLID_NOT;
        return;
    } else {
        self.set(lq.count, 0);
        return;
    }
}

pub export fn zombie_paine13() void {
    state(.paine13, zombie_paine14);
}

pub export fn zombie_paine14() void {
    state(.paine14, zombie_paine15);
}

pub export fn zombie_paine15() void {
    state(.paine15, zombie_paine16);
}

pub export fn zombie_paine16() void {
    state(.paine16, zombie_paine17);
}

pub export fn zombie_paine17() void {
    state(.paine17, zombie_paine18);
}

pub export fn zombie_paine18() void {
    state(.paine18, zombie_paine19);
}

pub export fn zombie_paine19() void {
    state(.paine19, zombie_paine20);
}

pub export fn zombie_paine20() void {
    state(.paine20, zombie_paine21);
}

pub export fn zombie_paine21() void {
    state(.paine21, zombie_paine22);
}

pub export fn zombie_paine22() void {
    state(.paine22, zombie_paine23);
}

pub export fn zombie_paine23() void {
    state(.paine23, zombie_paine24);
}

pub export fn zombie_paine24() void {
    state(.paine24, zombie_paine25);
}

pub export fn zombie_paine25() void {
    state(.paine25, zombie_paine26);
    ai.ai_painforward(5);
}

pub export fn zombie_paine26() void {
    state(.paine26, zombie_paine27);
    ai.ai_painforward(3);
}

pub export fn zombie_paine27() void {
    state(.paine27, zombie_paine28);
    ai.ai_painforward(1);
}

pub export fn zombie_paine28() void {
    state(.paine28, zombie_paine29);
    ai.ai_pain(1);
}

pub export fn zombie_paine29() void {
    state(.paine29, zombie_paine30);
}

pub export fn zombie_paine30() void {
    state(.paine30, zombie_run1);
}

pub export fn zombie_die() void {
    const self = q.me();
    q.sound(self, lq.CHAN_VOICE, S("zombie/z_gib.wav"), 1, lq.ATTN_NORM);
    player.ThrowHead(S("progs/h_zombie.mdl"), self.health);
    player.ThrowGib(S("progs/gib1.mdl"), self.health);
    player.ThrowGib(S("progs/gib2.mdl"), self.health);
    player.ThrowGib(S("progs/gib3.mdl"), self.health);
}

pub export fn zombie_pain(attacker: Entity, take: f32) void {
    _ = attacker;
    const self = q.me();

    self.health = 60; // allways reset health

    if (take < 9)
        return; // totally ignore

    if (self.get(inpain) == 2)
        return; // down on ground, so don't reset any counters

    // go down immediately if a big enough hit
    if (take >= 25) {
        self.set(inpain, 2);
        zombie_paine1();
        return;
    }

    if (self.get(inpain) != 0) {
        // if hit again in next gre seconds while not in pain frames, definately drop
        self.set(lq.pain_finished, q.time.get() + 3);
        return; // currently going through an animation, don't change
    }

    if (self.get(lq.pain_finished) > q.time.get()) {
        // hit again, so drop down
        self.set(inpain, 2);
        zombie_paine1();
        return;
    }

    // gp into one of the fast pain animations
    self.set(inpain, 1);

    const r = q.random();
    if (r < 0.25)
        zombie_paina1()
    else if (r < 0.5)
        zombie_painb1()
    else if (r < 0.75)
        zombie_painc1()
    else
        zombie_paind1();
}

pub export fn monster_zombie() void {
    const self = q.me();
    if (q.deathmatch.get() != 0) {
        q.remove(self);
        return;
    }

    _ = q.precache_model(S("progs/zombie.mdl"));
    _ = q.precache_model(S("progs/h_zombie.mdl"));
    _ = q.precache_model(S("progs/zom_gib.mdl"));

    _ = q.precache_sound(S("zombie/z_idle.wav"));
    _ = q.precache_sound(S("zombie/z_idle1.wav"));
    _ = q.precache_sound(S("zombie/z_shot1.wav"));
    _ = q.precache_sound(S("zombie/z_gib.wav"));
    _ = q.precache_sound(S("zombie/z_pain.wav"));
    _ = q.precache_sound(S("zombie/z_pain1.wav"));
    _ = q.precache_sound(S("zombie/z_fall.wav"));
    _ = q.precache_sound(S("zombie/z_miss.wav"));
    _ = q.precache_sound(S("zombie/z_hit.wav"));
    _ = q.precache_sound(S("zombie/idle_w2.wav"));

    self.solid = lq.SOLID_SLIDEBOX;
    self.movetype = lq.MOVETYPE_STEP;

    q.setmodel(self, S("progs/zombie.mdl"));

    //gnounc
    self.noise = S("zombie/z_idle.wav"); //gnounc
    self.netname = S("zombie");
    self.set(lq.killstring, S(loc.LOC_DEATH_ZOMBIE));

    q.setsize(self, q.vec(-16, -16, -24), q.vec(16, 16, 40));
    self.health = 60;
    self.max_health = 60;

    self.set(lq.th_stand, q.func(zombie_stand1));
    self.set(lq.th_walk, q.func(zombie_walk1));
    self.set(lq.th_run, q.func(zombie_run1));
    self.set(lq.th_pain, q.func(zombie_pain));
    self.set(lq.th_die, q.func(zombie_die));
    self.set(lq.th_missile, q.func(zombie_missile));

    if (q.has(self.spawnflags, SPAWN_CRUCIFIED)) {
        self.movetype = lq.MOVETYPE_NONE;
        zombie_cruc1();
    } else monsters.walkmonster_start();
}
