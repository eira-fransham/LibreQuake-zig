//! monsters/chthon.qc
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
//! BOSS-ONE

const q = @import("../defs.zig");
const lq = @import("../lq.zig");
const loc = @import("../localized_text.zig");
const S = q.S;
const Entity = q.Entity;
const Function = q.Function;
const String = q.String;
const Vector = q.Vector;
const fight = @import("../fight.zig");
const subs = @import("../subs.zig");
const weapons = @import("../weapons.zig");
const doors = @import("../doors.zig");

/// The `$frame` macros, numbered from 0 in declaration order.
const Frame = enum(u8) {
    rise1,
    rise2,
    rise3,
    rise4,
    rise5,
    rise6,
    rise7,
    rise8,
    rise9,
    rise10,
    rise11,
    rise12,
    rise13,
    rise14,
    rise15,
    rise16,
    rise17,
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
    walk20,
    walk21,
    walk22,
    walk23,
    walk24,
    walk25,
    walk26,
    walk27,
    walk28,
    walk29,
    walk30,
    walk31,
    death1,
    death2,
    death3,
    death4,
    death5,
    death6,
    death7,
    death8,
    death9,
    attack1,
    attack2,
    attack3,
    attack4,
    attack5,
    attack6,
    attack7,
    attack8,
    attack9,
    attack10,
    attack11,
    attack12,
    attack13,
    attack14,
    attack15,
    attack16,
    attack17,
    attack18,
    attack19,
    attack20,
    attack21,
    attack22,
    attack23,
    shocka1,
    shocka2,
    shocka3,
    shocka4,
    shocka5,
    shocka6,
    shocka7,
    shocka8,
    shocka9,
    shocka10,
    shockb1,
    shockb2,
    shockb3,
    shockb4,
    shockb5,
    shockb6,
    shockc1,
    shockc2,
    shockc3,
    shockc4,
    shockc5,
    shockc6,
    shockc7,
    shockc8,
    shockc9,
    shockc10,
};

/// `$frame`, as a float.
inline fn fr(comptime frame: Frame) f32 {
    return @floatFromInt(@backingInt(frame));
}

/// The `[$frame, next]` prefix of a state function.
inline fn state(comptime frame: Frame, comptime next: anytype) void {
    q.setState(fr(frame), q.func(next));
}

pub export fn boss_face() void {
    const self = q.me();
    // go for another player if multi player
    if (self.enemy.health <= 0 or q.random() < 0.02) {
        self.enemy = q.find(self.enemy, .classname, S("player"));

        if (self.enemy.isNull())
            self.enemy = q.find(self.enemy, .classname, S("player"));
    }

    fight.ai_face();
}

pub export fn boss_rise1() void {
    state(.rise1, boss_rise2);
    const self = q.me();
    q.sound(self, lq.CHAN_WEAPON, S("boss1/out1.wav"), 1, lq.ATTN_NORM);
}

pub export fn boss_rise2() void {
    state(.rise2, boss_rise3);
    const self = q.me();
    q.sound(self, lq.CHAN_VOICE, S("boss1/sight1.wav"), 1, lq.ATTN_NORM);
}

pub export fn boss_rise3() void {
    state(.rise3, boss_rise4);
}

pub export fn boss_rise4() void {
    state(.rise4, boss_rise5);
}

pub export fn boss_rise5() void {
    state(.rise5, boss_rise6);
}

pub export fn boss_rise6() void {
    state(.rise6, boss_rise7);
}

pub export fn boss_rise7() void {
    state(.rise7, boss_rise8);
}

pub export fn boss_rise8() void {
    state(.rise8, boss_rise9);
}

pub export fn boss_rise9() void {
    state(.rise9, boss_rise10);
}

pub export fn boss_rise10() void {
    state(.rise10, boss_rise11);
}

pub export fn boss_rise11() void {
    state(.rise11, boss_rise12);
}

pub export fn boss_rise12() void {
    state(.rise12, boss_rise13);
}

pub export fn boss_rise13() void {
    state(.rise13, boss_rise14);
}

pub export fn boss_rise14() void {
    state(.rise14, boss_rise15);
}

pub export fn boss_rise15() void {
    state(.rise15, boss_rise16);
}

pub export fn boss_rise16() void {
    state(.rise16, boss_rise17);
}

pub export fn boss_rise17() void {
    state(.rise17, boss_missile1);
}

pub export fn boss_idle1() void {
    state(.walk1, boss_idle2);
    // look for other players
}

pub export fn boss_idle2() void {
    state(.walk2, boss_idle3);
    boss_face();
}

pub export fn boss_idle3() void {
    state(.walk3, boss_idle4);
    boss_face();
}

pub export fn boss_idle4() void {
    state(.walk4, boss_idle5);
    boss_face();
}

pub export fn boss_idle5() void {
    state(.walk5, boss_idle6);
    boss_face();
}

pub export fn boss_idle6() void {
    state(.walk6, boss_idle7);
    boss_face();
}

pub export fn boss_idle7() void {
    state(.walk7, boss_idle8);
    boss_face();
}

pub export fn boss_idle8() void {
    state(.walk8, boss_idle9);
    boss_face();
}

pub export fn boss_idle9() void {
    state(.walk9, boss_idle10);
    boss_face();
}

pub export fn boss_idle10() void {
    state(.walk10, boss_idle11);
    boss_face();
}

pub export fn boss_idle11() void {
    state(.walk11, boss_idle12);
    boss_face();
}

pub export fn boss_idle12() void {
    state(.walk12, boss_idle13);
    boss_face();
}

pub export fn boss_idle13() void {
    state(.walk13, boss_idle14);
    boss_face();
}

pub export fn boss_idle14() void {
    state(.walk14, boss_idle15);
    boss_face();
}

pub export fn boss_idle15() void {
    state(.walk15, boss_idle16);
    boss_face();
}

pub export fn boss_idle16() void {
    state(.walk16, boss_idle17);
    boss_face();
}

pub export fn boss_idle17() void {
    state(.walk17, boss_idle18);
    boss_face();
}

pub export fn boss_idle18() void {
    state(.walk18, boss_idle19);
    boss_face();
}

pub export fn boss_idle19() void {
    state(.walk19, boss_idle20);
    boss_face();
}

pub export fn boss_idle20() void {
    state(.walk20, boss_idle21);
    boss_face();
}

pub export fn boss_idle21() void {
    state(.walk21, boss_idle22);
    boss_face();
}

pub export fn boss_idle22() void {
    state(.walk22, boss_idle23);
    boss_face();
}

pub export fn boss_idle23() void {
    state(.walk23, boss_idle24);
    boss_face();
}

pub export fn boss_idle24() void {
    state(.walk24, boss_idle25);
    boss_face();
}

pub export fn boss_idle25() void {
    state(.walk25, boss_idle26);
    boss_face();
}

pub export fn boss_idle26() void {
    state(.walk26, boss_idle27);
    boss_face();
}

pub export fn boss_idle27() void {
    state(.walk27, boss_idle28);
    boss_face();
}

pub export fn boss_idle28() void {
    state(.walk28, boss_idle29);
    boss_face();
}

pub export fn boss_idle29() void {
    state(.walk29, boss_idle30);
    boss_face();
}

pub export fn boss_idle30() void {
    state(.walk30, boss_idle31);
    boss_face();
}

pub export fn boss_idle31() void {
    state(.walk31, boss_idle1);
    boss_face();
}

pub export fn boss_missile1() void {
    state(.attack1, boss_missile2);
    boss_face();
}

pub export fn boss_missile2() void {
    state(.attack2, boss_missile3);
    boss_face();
}

pub export fn boss_missile3() void {
    state(.attack3, boss_missile4);
    boss_face();
}

pub export fn boss_missile4() void {
    state(.attack4, boss_missile5);
    boss_face();
}

pub export fn boss_missile5() void {
    state(.attack5, boss_missile6);
    boss_face();
}

pub export fn boss_missile6() void {
    state(.attack6, boss_missile7);
    boss_face();
}

pub export fn boss_missile7() void {
    state(.attack7, boss_missile8);
    boss_face();
}

pub export fn boss_missile8() void {
    state(.attack8, boss_missile9);
    boss_face();
}

pub export fn boss_missile9() void {
    state(.attack9, boss_missile10);
    boss_missile(q.vec(100, 100, 200));
}

pub export fn boss_missile10() void {
    state(.attack10, boss_missile11);
    boss_face();
}

pub export fn boss_missile11() void {
    state(.attack11, boss_missile12);
    boss_face();
}

pub export fn boss_missile12() void {
    state(.attack12, boss_missile13);
    boss_face();
}

pub export fn boss_missile13() void {
    state(.attack13, boss_missile14);
    boss_face();
}

pub export fn boss_missile14() void {
    state(.attack14, boss_missile15);
    boss_face();
}

pub export fn boss_missile15() void {
    state(.attack15, boss_missile16);
    boss_face();
}

pub export fn boss_missile16() void {
    state(.attack16, boss_missile17);
    boss_face();
}

pub export fn boss_missile17() void {
    state(.attack17, boss_missile18);
    boss_face();
}

pub export fn boss_missile18() void {
    state(.attack18, boss_missile19);
    boss_face();
}

pub export fn boss_missile19() void {
    state(.attack19, boss_missile20);
    boss_face();
}

pub export fn boss_missile20() void {
    state(.attack20, boss_missile21);
    boss_missile(q.vec(100, -100, 200));
}

pub export fn boss_missile21() void {
    state(.attack21, boss_missile22);
    boss_face();
}

pub export fn boss_missile22() void {
    state(.attack22, boss_missile23);
    boss_face();
}

pub export fn boss_missile23() void {
    state(.attack23, boss_missile1);
    boss_face();
}

pub export fn boss_shocka1() void {
    state(.shocka1, boss_shocka2);
}

pub export fn boss_shocka2() void {
    state(.shocka2, boss_shocka3);
}

pub export fn boss_shocka3() void {
    state(.shocka3, boss_shocka4);
}

pub export fn boss_shocka4() void {
    state(.shocka4, boss_shocka5);
}

pub export fn boss_shocka5() void {
    state(.shocka5, boss_shocka6);
}

pub export fn boss_shocka6() void {
    state(.shocka6, boss_shocka7);
}

pub export fn boss_shocka7() void {
    state(.shocka7, boss_shocka8);
}

pub export fn boss_shocka8() void {
    state(.shocka8, boss_shocka9);
}

pub export fn boss_shocka9() void {
    state(.shocka9, boss_shocka10);
}

pub export fn boss_shocka10() void {
    state(.shocka10, boss_missile1);
}

pub export fn boss_shockb1() void {
    state(.shockb1, boss_shockb2);
}

pub export fn boss_shockb2() void {
    state(.shockb2, boss_shockb3);
}

pub export fn boss_shockb3() void {
    state(.shockb3, boss_shockb4);
}

pub export fn boss_shockb4() void {
    state(.shockb4, boss_shockb5);
}

pub export fn boss_shockb5() void {
    state(.shockb5, boss_shockb6);
}

pub export fn boss_shockb6() void {
    state(.shockb6, boss_shockb7);
}

pub export fn boss_shockb7() void {
    state(.shockb1, boss_shockb8);
}

pub export fn boss_shockb8() void {
    state(.shockb2, boss_shockb9);
}

pub export fn boss_shockb9() void {
    state(.shockb3, boss_shockb10);
}

pub export fn boss_shockb10() void {
    state(.shockb4, boss_missile1);
}

pub export fn boss_shockc1() void {
    state(.shockc1, boss_shockc2);
}

pub export fn boss_shockc2() void {
    state(.shockc2, boss_shockc3);
}

pub export fn boss_shockc3() void {
    state(.shockc3, boss_shockc4);
}

pub export fn boss_shockc4() void {
    state(.shockc4, boss_shockc5);
}

pub export fn boss_shockc5() void {
    state(.shockc5, boss_shockc6);
}

pub export fn boss_shockc6() void {
    state(.shockc6, boss_shockc7);
}

pub export fn boss_shockc7() void {
    state(.shockc7, boss_shockc8);
}

pub export fn boss_shockc8() void {
    state(.shockc8, boss_shockc9);
}

pub export fn boss_shockc9() void {
    state(.shockc9, boss_shockc10);
}

pub export fn boss_shockc10() void {
    state(.shockc10, boss_death1);
}

pub export fn boss_death1() void {
    state(.death1, boss_death2);
    const self = q.me();
    q.sound(self, lq.CHAN_VOICE, S("boss1/death.wav"), 1, lq.ATTN_NORM);
}

pub export fn boss_death2() void {
    state(.death2, boss_death3);
}

pub export fn boss_death3() void {
    state(.death3, boss_death4);
}

pub export fn boss_death4() void {
    state(.death4, boss_death5);
}

pub export fn boss_death5() void {
    state(.death5, boss_death6);
}

pub export fn boss_death6() void {
    state(.death6, boss_death7);
}

pub export fn boss_death7() void {
    state(.death7, boss_death8);
}

pub export fn boss_death8() void {
    state(.death8, boss_death9);
}

pub export fn boss_death9() void {
    state(.death9, boss_death10);
    const self = q.me();
    q.sound(self, lq.CHAN_BODY, S("boss1/out1.wav"), 1, lq.ATTN_NORM);
    q.WriteByte(lq.MSG_BROADCAST, lq.SVC_TEMPENTITY);
    q.WriteByte(lq.MSG_BROADCAST, lq.TE_LAVASPLASH);
    q.WriteCoord(lq.MSG_BROADCAST, self.origin[0]);
    q.WriteCoord(lq.MSG_BROADCAST, self.origin[1]);
    q.WriteCoord(lq.MSG_BROADCAST, self.origin[2]);
}

pub export fn boss_death10() void {
    state(.death9, boss_death10);
    q.killed_monsters.set(q.killed_monsters.get() + 1);
    q.WriteByte(lq.MSG_ALL, lq.SVC_KILLEDMONSTER); // FIXME: reliable broadcast
    subs.SUB_UseTargets();
    q.remove(q.me());
}

pub export fn boss_missile(p: Vector) void {
    const self = q.me();

    const offang = q.vectoangles(@as(Vector, self.enemy.origin) - self.origin);
    q.makevectors(offang);

    const org = self.origin + q.scale(q.v_forward.get(), p[0]) + q.scale(q.v_right.get(), p[1]) + q.scale(q.vec(0, 0, 1), p[2]);

    // lead the player on hard mode
    var vec: Vector = undefined;
    var d: Vector = undefined;
    if (lq.skill.get() > 1) {
        const t = q.vlen(self.enemy.origin - org) / 300;
        vec = self.enemy.velocity;
        vec[2] = 0;
        d = self.enemy.origin + q.scale(vec, t);
    } else {
        d = self.enemy.origin;
    }

    vec = q.normalize(d - org);

    weapons.launch_spike(org, vec);
    const newmis = lq.newmis.get();
    newmis.classname = S("chthon_lavaball");
    q.setmodel(newmis, S("progs/lavaball.mdl"));
    newmis.avelocity = q.vec(200, 100, 300);
    q.setsize(newmis, lq.VEC_ORIGIN, lq.VEC_ORIGIN);
    newmis.velocity = q.scale(vec, 300);
    newmis.touch = q.func(weapons.T_MissileTouch); // rocket explosion
    q.sound(self, lq.CHAN_WEAPON, S("boss1/throw.wav"), 1, lq.ATTN_NORM);

    // check for dead enemy
    if (self.enemy.health <= 0)
        boss_idle1();
}

pub export fn boss_awake() void {
    const self = q.me();
    self.solid = lq.SOLID_SLIDEBOX;
    self.movetype = lq.MOVETYPE_STEP;
    self.takedamage = lq.DAMAGE_NO;

    q.setmodel(self, S("progs/boss.mdl"));

    //gnounc
    self.netname = S("Chthon");
    self.set(lq.killstring, S(loc.LOC_DEATH_BOSS));

    q.setsize(self, q.vec(-128, -128, -24), q.vec(128, 128, 256));

    if (lq.skill.get() == 0)
        self.health = 1
    else
        self.health = 3;

    self.enemy = lq.activator.get();

    q.WriteByte(lq.MSG_BROADCAST, lq.SVC_TEMPENTITY);
    q.WriteByte(lq.MSG_BROADCAST, lq.TE_LAVASPLASH);
    q.WriteCoord(lq.MSG_BROADCAST, self.origin[0]);
    q.WriteCoord(lq.MSG_BROADCAST, self.origin[1]);
    q.WriteCoord(lq.MSG_BROADCAST, self.origin[2]);

    self.yaw_speed = 20;
    boss_rise1();
}

pub export fn monster_boss() void {
    const self = q.me();
    if (q.deathmatch.get() != 0) {
        q.remove(self);
        return;
    }

    _ = q.precache_model(S("progs/boss.mdl"));
    _ = q.precache_model(S("progs/lavaball.mdl"));

    _ = q.precache_sound(S("weapons/rocket1i.wav"));
    _ = q.precache_sound(S("boss1/out1.wav"));
    _ = q.precache_sound(S("boss1/sight1.wav"));
    _ = q.precache_sound(S("misc/power.wav"));
    _ = q.precache_sound(S("boss1/throw.wav"));
    _ = q.precache_sound(S("boss1/pain.wav"));
    _ = q.precache_sound(S("boss1/death.wav"));

    q.total_monsters.set(q.total_monsters.get() + 1);

    self.use = q.func(boss_awake);
}

pub const le1 = q.userGlobal(Entity, "le1");

pub const le2 = q.userGlobal(Entity, "le2");

pub const lightning_end = q.userGlobal(f32, "lightning_end");

pub export fn lightning_fire() void {
    if (q.time.get() >= lightning_end.get()) { // done here, put the terminals back up
        q.self.set(le1.get());
        doors.door_go_down();
        q.self.set(le2.get());
        doors.door_go_down();

        return;
    }

    const l1 = le1.get();
    const l2 = le2.get();

    var p1 = q.scale(@as(Vector, l1.mins) + l1.maxs, 0.5);
    p1[2] = l1.absmin[2] - 16;

    var p2 = q.scale(@as(Vector, l2.mins) + l2.maxs, 0.5);
    p2[2] = l2.absmin[2] - 16;

    // compensate for length of bolt
    p2 = p2 - q.scale(q.normalize(p2 - p1), 100);

    const self = q.me();
    self.nextthink = q.time.get() + 0.1;
    self.think = q.func(lightning_fire);

    q.WriteByte(lq.MSG_ALL, lq.SVC_TEMPENTITY);
    q.WriteByte(lq.MSG_ALL, lq.TE_LIGHTNING3);
    q.WriteEntity(lq.MSG_ALL, q.world.get());
    q.WriteCoord(lq.MSG_ALL, p1[0]);
    q.WriteCoord(lq.MSG_ALL, p1[1]);
    q.WriteCoord(lq.MSG_ALL, p1[2]);
    q.WriteCoord(lq.MSG_ALL, p2[0]);
    q.WriteCoord(lq.MSG_ALL, p2[1]);
    q.WriteCoord(lq.MSG_ALL, p2[2]);
}

pub export fn lightning_use() void {
    if (lightning_end.get() >= q.time.get() + 1)
        return;

    le1.set(q.find(q.world.get(), .target, S("lightning")));
    le2.set(q.find(le1.get(), .target, S("lightning")));
    if (le1.get().isNull() or le2.get().isNull()) {
        q.dprint(S("missing lightning targets\n"));
        return;
    }
    const l1 = le1.get();
    const l2 = le2.get();
    //someone should probably have commented what this long ass statement means - gnounc.
    if ((l1.get(lq.state) != lq.STATE_TOP and l1.get(lq.state) != lq.STATE_BOTTOM) or (l2.get(lq.state) != lq.STATE_TOP and l2.get(lq.state) != lq.STATE_BOTTOM) or (l1.get(lq.state) != l2.get(lq.state)))
        return;

    // don't let the electrodes go back up until the bolt is done
    l1.nextthink = -1;
    l2.nextthink = -1;
    lightning_end.set(q.time.get() + 1);

    q.sound(q.me(), lq.CHAN_VOICE, S("misc/power.wav"), 1, lq.ATTN_NORM);
    lightning_fire();

    // advance the boss pain if down
    q.self.set(q.find(q.world.get(), .classname, S("monster_boss")));
    const self = q.me();

    if (self.isNull())
        return;

    self.enemy = lq.activator.get();

    if (le1.get().get(lq.state) == lq.STATE_TOP and self.health > 0) {
        q.sound(self, lq.CHAN_VOICE, S("boss1/pain.wav"), 1, lq.ATTN_NORM);
        self.health = self.health - 1;

        if (self.health >= 2)
            boss_shocka1()
        else if (self.health == 1)
            boss_shockb1()
        else if (self.health == 0)
            boss_shockc1();
    }
}

pub export fn event_lightning() void {
    const self = q.me();
    self.use = q.func(lightning_use);
}
