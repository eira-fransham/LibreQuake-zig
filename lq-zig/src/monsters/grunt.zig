//! monsters/grunt.qc

const q = @import("../defs.zig");
const lq = @import("../lq.zig");
const loc = @import("../localized_text.zig");
const S = q.S;
const Entity = q.Entity;
const Function = q.Function;
const String = q.String;
const Vector = q.Vector;
const monsters = @import("../monsters.zig");
const weapons = @import("../weapons.zig");
const items = @import("../items.zig");
const player = @import("../player.zig");
const subs = @import("../subs.zig");
const ai = @import("../ai.zig");
const fight = @import("../fight.zig");

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
    deathc1,
    deathc2,
    deathc3,
    deathc4,
    deathc5,
    deathc6,
    deathc7,
    deathc8,
    deathc9,
    deathc10,
    deathc11,
    load1,
    load2,
    load3,
    load4,
    load5,
    load6,
    load7,
    load8,
    load9,
    load10,
    load11,
    pain1,
    pain2,
    pain3,
    pain4,
    pain5,
    pain6,
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
    run1,
    run2,
    run3,
    run4,
    run5,
    run6,
    run7,
    run8,
    shoot1,
    shoot2,
    shoot3,
    shoot4,
    shoot5,
    shoot6,
    shoot7,
    shoot8,
    shoot9,
    prowl_1,
    prowl_2,
    prowl_3,
    prowl_4,
    prowl_5,
    prowl_6,
    prowl_7,
    prowl_8,
    prowl_9,
    prowl_10,
    prowl_11,
    prowl_12,
    prowl_13,
    prowl_14,
    prowl_15,
    prowl_16,
    prowl_17,
    prowl_18,
    prowl_19,
    prowl_20,
    prowl_21,
    prowl_22,
    prowl_23,
    prowl_24,
};

/// `$frame`, as a float.
inline fn fr(comptime frame: Frame) f32 {
    return @floatFromInt(@backingInt(frame));
}

/// The `[$frame, next]` prefix of a state function.
inline fn state(comptime frame: Frame, comptime next: anytype) void {
    q.setState(fr(frame), q.func(next));
}

pub export fn army_stand1() void {
    state(.stand1, army_stand2);
    ai.ai_stand();
}

pub export fn army_stand2() void {
    state(.stand2, army_stand3);
    ai.ai_stand();
}

pub export fn army_stand3() void {
    state(.stand3, army_stand4);
    ai.ai_stand();
}

pub export fn army_stand4() void {
    state(.stand4, army_stand5);
    ai.ai_stand();
}

pub export fn army_stand5() void {
    state(.stand5, army_stand6);
    ai.ai_stand();
}

pub export fn army_stand6() void {
    state(.stand6, army_stand7);
    ai.ai_stand();
}

pub export fn army_stand7() void {
    state(.stand7, army_stand8);
    ai.ai_stand();
}

pub export fn army_stand8() void {
    state(.stand8, army_stand1);
    ai.ai_stand();
}

pub export fn army_walk1() void {
    state(.prowl_1, army_walk2);
    if (q.random() < 0.2)
        q.sound(q.me(), lq.CHAN_VOICE, S("soldier/idle.wav"), 1, lq.ATTN_IDLE);
    ai.ai_walk(1);
}

pub export fn army_walk2() void {
    state(.prowl_2, army_walk3);
    ai.ai_walk(1);
}

pub export fn army_walk3() void {
    state(.prowl_3, army_walk4);
    ai.ai_walk(1);
}

pub export fn army_walk4() void {
    state(.prowl_4, army_walk5);
    ai.ai_walk(1);
}

pub export fn army_walk5() void {
    state(.prowl_5, army_walk6);
    ai.ai_walk(2);
}

pub export fn army_walk6() void {
    state(.prowl_6, army_walk7);
    ai.ai_walk(3);
}

pub export fn army_walk7() void {
    state(.prowl_7, army_walk8);
    ai.ai_walk(4);
}

pub export fn army_walk8() void {
    state(.prowl_8, army_walk9);
    ai.ai_walk(4);
}

pub export fn army_walk9() void {
    state(.prowl_9, army_walk10);
    ai.ai_walk(2);
}

pub export fn army_walk10() void {
    state(.prowl_10, army_walk11);
    ai.ai_walk(2);
}

pub export fn army_walk11() void {
    state(.prowl_11, army_walk12);
    ai.ai_walk(2);
}

pub export fn army_walk12() void {
    state(.prowl_12, army_walk13);
    ai.ai_walk(1);
}

pub export fn army_walk13() void {
    state(.prowl_13, army_walk14);
    ai.ai_walk(0);
}

pub export fn army_walk14() void {
    state(.prowl_14, army_walk15);
    ai.ai_walk(1);
}

pub export fn army_walk15() void {
    state(.prowl_15, army_walk16);
    ai.ai_walk(1);
}

pub export fn army_walk16() void {
    state(.prowl_16, army_walk17);
    ai.ai_walk(1);
}

pub export fn army_walk17() void {
    state(.prowl_17, army_walk18);
    ai.ai_walk(3);
}

pub export fn army_walk18() void {
    state(.prowl_18, army_walk19);
    ai.ai_walk(3);
}

pub export fn army_walk19() void {
    state(.prowl_19, army_walk20);
    ai.ai_walk(3);
}

pub export fn army_walk20() void {
    state(.prowl_20, army_walk21);
    ai.ai_walk(3);
}

pub export fn army_walk21() void {
    state(.prowl_21, army_walk22);
    ai.ai_walk(2);
}

pub export fn army_walk22() void {
    state(.prowl_22, army_walk23);
    ai.ai_walk(1);
}

pub export fn army_walk23() void {
    state(.prowl_23, army_walk24);
    ai.ai_walk(1);
}

pub export fn army_walk24() void {
    state(.prowl_24, army_walk1);
    ai.ai_walk(1);
}

pub export fn army_run1() void {
    state(.run1, army_run2);
    if (q.random() < 0.2)
        q.sound(q.me(), lq.CHAN_VOICE, S("soldier/idle.wav"), 1, lq.ATTN_IDLE);
    ai.ai_run(11);
}

pub export fn army_run2() void {
    state(.run2, army_run3);
    ai.ai_run(15);
}

pub export fn army_run3() void {
    state(.run3, army_run4);
    ai.ai_run(10);
}

pub export fn army_run4() void {
    state(.run4, army_run5);
    ai.ai_run(10);
}

pub export fn army_run5() void {
    state(.run5, army_run6);
    ai.ai_run(8);
}

pub export fn army_run6() void {
    state(.run6, army_run7);
    ai.ai_run(15);
}

pub export fn army_run7() void {
    state(.run7, army_run8);
    ai.ai_run(10);
}

pub export fn army_run8() void {
    state(.run8, army_run1);
    ai.ai_run(8);
}

pub export fn army_atk1() void {
    state(.shoot1, army_atk2);
    fight.ai_face();
}

pub export fn army_atk2() void {
    state(.shoot2, army_atk3);
    fight.ai_face();
}

pub export fn army_atk3() void {
    state(.shoot3, army_atk4);
    fight.ai_face();
}

pub export fn army_atk4() void {
    state(.shoot4, army_atk5);
    fight.ai_face();
}

pub export fn army_atk5() void {
    state(.shoot5, army_atk6);
    fight.ai_face();
    army_fire();
    const self = q.me();
    self.effects = q.bor(self.effects, lq.EF_MUZZLEFLASH);
}

pub export fn army_atk6() void {
    state(.shoot6, army_atk7);
    fight.ai_face();
}

pub export fn army_atk7() void {
    state(.shoot7, army_atk8);
    fight.ai_face();
    subs.SUB_CheckRefire(q.func(army_atk1));
}

pub export fn army_atk8() void {
    state(.shoot8, army_atk9);
    fight.ai_face();
}

pub export fn army_atk9() void {
    state(.shoot9, army_run1);
    fight.ai_face();
}

pub export fn army_pain1() void {
    state(.pain1, army_pain2);
}

pub export fn army_pain2() void {
    state(.pain2, army_pain3);
}

pub export fn army_pain3() void {
    state(.pain3, army_pain4);
}

pub export fn army_pain4() void {
    state(.pain4, army_pain5);
}

pub export fn army_pain5() void {
    state(.pain5, army_pain6);
}

pub export fn army_pain6() void {
    state(.pain6, army_run1);
    ai.ai_pain(1);
}

pub export fn army_painb1() void {
    state(.painb1, army_painb2);
}

pub export fn army_painb2() void {
    state(.painb2, army_painb3);
    ai.ai_painforward(13);
}

pub export fn army_painb3() void {
    state(.painb3, army_painb4);
    ai.ai_painforward(9);
}

pub export fn army_painb4() void {
    state(.painb4, army_painb5);
}

pub export fn army_painb5() void {
    state(.painb5, army_painb6);
}

pub export fn army_painb6() void {
    state(.painb6, army_painb7);
}

pub export fn army_painb7() void {
    state(.painb7, army_painb8);
}

pub export fn army_painb8() void {
    state(.painb8, army_painb9);
}

pub export fn army_painb9() void {
    state(.painb9, army_painb10);
}

pub export fn army_painb10() void {
    state(.painb10, army_painb11);
}

pub export fn army_painb11() void {
    state(.painb11, army_painb12);
}

pub export fn army_painb12() void {
    state(.painb12, army_painb13);
    ai.ai_pain(2);
}

pub export fn army_painb13() void {
    state(.painb13, army_painb14);
}

pub export fn army_painb14() void {
    state(.painb14, army_run1);
}

pub export fn army_painc1() void {
    state(.painc1, army_painc2);
}

pub export fn army_painc2() void {
    state(.painc2, army_painc3);
    ai.ai_pain(1);
}

pub export fn army_painc3() void {
    state(.painc3, army_painc4);
}

pub export fn army_painc4() void {
    state(.painc4, army_painc5);
}

pub export fn army_painc5() void {
    state(.painc5, army_painc6);
    ai.ai_painforward(1);
}

pub export fn army_painc6() void {
    state(.painc6, army_painc7);
    ai.ai_painforward(1);
}

pub export fn army_painc7() void {
    state(.painc7, army_painc8);
}

pub export fn army_painc8() void {
    state(.painc8, army_painc9);
    ai.ai_pain(1);
}

pub export fn army_painc9() void {
    state(.painc9, army_painc10);
    ai.ai_painforward(4);
}

pub export fn army_painc10() void {
    state(.painc10, army_painc11);
    ai.ai_painforward(3);
}

pub export fn army_painc11() void {
    state(.painc11, army_painc12);
    ai.ai_painforward(6);
}

pub export fn army_painc12() void {
    state(.painc12, army_painc13);
    ai.ai_painforward(8);
}

pub export fn army_painc13() void {
    state(.painc13, army_run1);
}

pub export fn army_pain(attacker: Entity, damage: f32) void {
    _ = attacker;
    _ = damage;
    const self = q.me();

    if (self.get(lq.pain_finished) > q.time.get())
        return;

    const r = q.random();

    if (r < 0.2) {
        self.set(lq.pain_finished, q.time.get() + 0.6);
        army_pain1();
        q.sound(self, lq.CHAN_VOICE, S("soldier/pain1.wav"), 1, lq.ATTN_NORM);
    } else if (r < 0.6) {
        self.set(lq.pain_finished, q.time.get() + 1.1);
        army_painb1();
        q.sound(self, lq.CHAN_VOICE, S("soldier/pain2.wav"), 1, lq.ATTN_NORM);
    } else {
        self.set(lq.pain_finished, q.time.get() + 1.1);
        army_painc1();
        q.sound(self, lq.CHAN_VOICE, S("soldier/pain2.wav"), 1, lq.ATTN_NORM);
    }
}

pub export fn army_fire() void {
    fight.ai_face();

    const self = q.me();
    q.sound(self, lq.CHAN_WEAPON, S("soldier/sattck1.wav"), 1, lq.ATTN_NORM);

    // fire somewhat behind the player, so a dodging player is harder to hit
    const en = self.enemy;

    var dir = @as(Vector, en.origin) - q.scale(en.velocity, 0.2);
    dir = q.normalize(dir - self.origin);

    weapons.FireBullets(4, dir, q.vec(0.1, 0.1, 0), S(""));
}

pub export fn army_die1() void {
    state(.death1, army_die2);
}

pub export fn army_die2() void {
    state(.death2, army_die3);
}

pub export fn army_die3() void {
    state(.death3, army_die4);
    const self = q.me();
    self.solid = lq.SOLID_NOT;
    self.ammo_shells = 5;
    items.DropBackpack();
}

pub export fn army_die4() void {
    state(.death4, army_die5);
}

pub export fn army_die5() void {
    state(.death5, army_die6);
}

pub export fn army_die6() void {
    state(.death6, army_die7);
}

pub export fn army_die7() void {
    state(.death7, army_die8);
}

pub export fn army_die8() void {
    state(.death8, army_die9);
}

pub export fn army_die9() void {
    state(.death9, army_die10);
}

pub export fn army_die10() void {
    state(.death10, army_die10);
}

pub export fn army_cdie1() void {
    state(.deathc1, army_cdie2);
}

pub export fn army_cdie2() void {
    state(.deathc2, army_cdie3);
    ai.ai_back(5);
}

pub export fn army_cdie3() void {
    state(.deathc3, army_cdie4);
    const self = q.me();
    self.solid = lq.SOLID_NOT;
    self.ammo_shells = 5;
    items.DropBackpack();
    ai.ai_back(4);
}

pub export fn army_cdie4() void {
    state(.deathc4, army_cdie5);
    ai.ai_back(13);
}

pub export fn army_cdie5() void {
    state(.deathc5, army_cdie6);
    ai.ai_back(3);
}

pub export fn army_cdie6() void {
    state(.deathc6, army_cdie7);
    ai.ai_back(4);
}

pub export fn army_cdie7() void {
    state(.deathc7, army_cdie8);
}

pub export fn army_cdie8() void {
    state(.deathc8, army_cdie9);
}

pub export fn army_cdie9() void {
    state(.deathc9, army_cdie10);
}

pub export fn army_cdie10() void {
    state(.deathc10, army_cdie11);
}

pub export fn army_cdie11() void {
    state(.deathc11, army_cdie11);
}

pub export fn army_die() void {
    const self = q.me();
    // check for gib
    if (self.health < -35) {
        q.sound(self, lq.CHAN_VOICE, S("player/udeath.wav"), 1, lq.ATTN_NORM);
        player.ThrowHead(S("progs/h_guard.mdl"), self.health);
        player.ThrowGib(S("progs/gib1.mdl"), self.health);
        player.ThrowGib(S("progs/gib2.mdl"), self.health);
        player.ThrowGib(S("progs/gib3.mdl"), self.health);
        return;
    }

    // regular death
    q.sound(self, lq.CHAN_VOICE, S("soldier/death1.wav"), 1, lq.ATTN_NORM);
    if (q.random() < 0.5)
        army_die1()
    else
        army_cdie1();
}

/// QUAKED monster_army (1 0 0) (-16 -16 -24) (16 16 40) Ambush
/// {
///     model({"path": "progs/soldier.mdl", "skin": 0, "frame": 0});
/// }
pub export fn monster_army() void {
    const self = q.me();
    if (q.deathmatch.get() != 0) {
        q.remove(self);
        return;
    }

    _ = q.precache_model(S("progs/soldier.mdl"));
    _ = q.precache_model(S("progs/h_guard.mdl"));
    _ = q.precache_model(S("progs/gib1.mdl"));
    _ = q.precache_model(S("progs/gib2.mdl"));
    _ = q.precache_model(S("progs/gib3.mdl"));

    _ = q.precache_sound(S("soldier/death1.wav"));
    _ = q.precache_sound(S("soldier/idle.wav"));
    _ = q.precache_sound(S("soldier/pain1.wav"));
    _ = q.precache_sound(S("soldier/pain2.wav"));
    _ = q.precache_sound(S("soldier/sattck1.wav"));
    _ = q.precache_sound(S("soldier/sight1.wav"));

    _ = q.precache_sound(S("player/udeath.wav")); // gib death

    self.solid = lq.SOLID_SLIDEBOX;
    self.movetype = lq.MOVETYPE_STEP;

    q.setmodel(self, S("progs/soldier.mdl"));

    //gnounc
    self.noise = S("soldier/sight1.wav"); //gnounc
    self.netname = S("Grunt");
    self.set(lq.killstring, S(loc.LOC_DEATH_ARMY));

    q.setsize(self, q.vec(-16, -16, -24), q.vec(16, 16, 40));
    self.health = 30;
    self.max_health = 30;

    self.set(lq.th_stand, q.func(army_stand1));
    self.set(lq.th_walk, q.func(army_walk1));
    self.set(lq.th_run, q.func(army_run1));
    self.set(lq.th_missile, q.func(army_atk1));
    self.set(lq.th_pain, q.func(army_pain));
    self.set(lq.th_die, q.func(army_die));

    monsters.walkmonster_start();
}
