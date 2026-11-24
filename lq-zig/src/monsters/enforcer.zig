//! monsters/enforcer.qc

const q = @import("../defs.zig");
const lq = @import("../lq.zig");
const loc = @import("../localized_text.zig");
const S = q.S;
const Entity = q.Entity;
const Function = q.Function;
const String = q.String;
const Vector = q.Vector;
const monsters = @import("../monsters.zig");
const player = @import("../player.zig");
const misc = @import("../misc.zig");
const subs = @import("../subs.zig");
const ai = @import("../ai.zig");
const fight = @import("../fight.zig");
const items = @import("../items.zig");

/// The `$frame` macros, numbered from 0 in declaration order.
const Frame = enum(u8) {
    stand1,
    stand2,
    stand3,
    stand4,
    stand5,
    stand6,
    stand7,
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
    fdeath1,
    fdeath2,
    fdeath3,
    fdeath4,
    fdeath5,
    fdeath6,
    fdeath7,
    fdeath8,
    fdeath9,
    fdeath10,
    fdeath11,
    paina1,
    paina2,
    paina3,
    paina4,
    painb1,
    painb2,
    painb3,
    painb4,
    painb5,
    painc1,
    painc2,
    painc3,
    painc4,
    painc5,
    painc6,
    painc7,
    painc8,
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
    paind17,
    paind18,
    paind19,
};

/// `$frame`, as a float.
inline fn fr(comptime frame: Frame) f32 {
    return @floatFromInt(@backingInt(frame));
}

/// The `[$frame, next]` prefix of a state function.
inline fn state(comptime frame: Frame, comptime next: anytype) void {
    q.setState(fr(frame), q.func(next));
}

pub export fn enforcer_fire() void {
    const self = q.me();
    self.effects = q.bor(self.effects, lq.EF_MUZZLEFLASH);
    subs.makevectors2(self.angles);

    const org = @as(Vector, self.origin) + q.scale(q.v_forward.get(), 30) + q.scale(q.v_right.get(), 8.5) + q.vec(0, 0, 16);

    misc.LaunchLaser(org, @as(Vector, self.enemy.origin) - self.origin);
}

pub export fn enf_stand1() void {
    state(.stand1, enf_stand2);
    ai.ai_stand();
}

pub export fn enf_stand2() void {
    state(.stand2, enf_stand3);
    ai.ai_stand();
}

pub export fn enf_stand3() void {
    state(.stand3, enf_stand4);
    ai.ai_stand();
}

pub export fn enf_stand4() void {
    state(.stand4, enf_stand5);
    ai.ai_stand();
}

pub export fn enf_stand5() void {
    state(.stand5, enf_stand6);
    ai.ai_stand();
}

pub export fn enf_stand6() void {
    state(.stand6, enf_stand7);
    ai.ai_stand();
}

pub export fn enf_stand7() void {
    state(.stand7, enf_stand1);
    ai.ai_stand();
}

pub export fn enf_walk1() void {
    state(.walk1, enf_walk2);
    const self = q.me();
    if (q.random() < 0.2)
        q.sound(self, lq.CHAN_VOICE, S("enforcer/idle1.wav"), 1, lq.ATTN_IDLE);
    ai.ai_walk(2);
}

pub export fn enf_walk2() void {
    state(.walk2, enf_walk3);
    ai.ai_walk(4);
}

pub export fn enf_walk3() void {
    state(.walk3, enf_walk4);
    ai.ai_walk(4);
}

pub export fn enf_walk4() void {
    state(.walk4, enf_walk5);
    ai.ai_walk(3);
}

pub export fn enf_walk5() void {
    state(.walk5, enf_walk6);
    ai.ai_walk(1);
}

pub export fn enf_walk6() void {
    state(.walk6, enf_walk7);
    ai.ai_walk(2);
}

pub export fn enf_walk7() void {
    state(.walk7, enf_walk8);
    ai.ai_walk(2);
}

pub export fn enf_walk8() void {
    state(.walk8, enf_walk9);
    ai.ai_walk(1);
}

pub export fn enf_walk9() void {
    state(.walk9, enf_walk10);
    ai.ai_walk(2);
}

pub export fn enf_walk10() void {
    state(.walk10, enf_walk11);
    ai.ai_walk(4);
}

pub export fn enf_walk11() void {
    state(.walk11, enf_walk12);
    ai.ai_walk(4);
}

pub export fn enf_walk12() void {
    state(.walk12, enf_walk13);
    ai.ai_walk(1);
}

pub export fn enf_walk13() void {
    state(.walk13, enf_walk14);
    ai.ai_walk(2);
}

pub export fn enf_walk14() void {
    state(.walk14, enf_walk15);
    ai.ai_walk(3);
}

pub export fn enf_walk15() void {
    state(.walk15, enf_walk16);
    ai.ai_walk(4);
}

pub export fn enf_walk16() void {
    state(.walk16, enf_walk1);
    ai.ai_walk(2);
}

pub export fn enf_run1() void {
    state(.run1, enf_run2);
    const self = q.me();
    if (q.random() < 0.2)
        q.sound(self, lq.CHAN_VOICE, S("enforcer/idle1.wav"), 1, lq.ATTN_IDLE);
    ai.ai_run(18);
}

pub export fn enf_run2() void {
    state(.run2, enf_run3);
    ai.ai_run(14);
}

pub export fn enf_run3() void {
    state(.run3, enf_run4);
    ai.ai_run(7);
}

pub export fn enf_run4() void {
    state(.run4, enf_run5);
    ai.ai_run(12);
}

pub export fn enf_run5() void {
    state(.run5, enf_run6);
    ai.ai_run(14);
}

pub export fn enf_run6() void {
    state(.run6, enf_run7);
    ai.ai_run(14);
}

pub export fn enf_run7() void {
    state(.run7, enf_run8);
    ai.ai_run(7);
}

pub export fn enf_run8() void {
    state(.run8, enf_run1);
    ai.ai_run(11);
}

pub export fn enf_atk1() void {
    state(.attack1, enf_atk2);
    fight.ai_face();
}

pub export fn enf_atk2() void {
    state(.attack2, enf_atk3);
    fight.ai_face();
}

pub export fn enf_atk3() void {
    state(.attack3, enf_atk4);
    fight.ai_face();
}

pub export fn enf_atk4() void {
    state(.attack4, enf_atk5);
    fight.ai_face();
}

pub export fn enf_atk5() void {
    state(.attack5, enf_atk6);
    fight.ai_face();
}

pub export fn enf_atk6() void {
    state(.attack6, enf_atk7);
    enforcer_fire();
}

pub export fn enf_atk7() void {
    state(.attack7, enf_atk8);
    fight.ai_face();
}

pub export fn enf_atk8() void {
    state(.attack8, enf_atk9);
    fight.ai_face();
}

pub export fn enf_atk9() void {
    state(.attack5, enf_atk10);
    fight.ai_face();
}

pub export fn enf_atk10() void {
    state(.attack6, enf_atk11);
    enforcer_fire();
}

pub export fn enf_atk11() void {
    state(.attack7, enf_atk12);
    fight.ai_face();
}

pub export fn enf_atk12() void {
    state(.attack8, enf_atk13);
    fight.ai_face();
}

pub export fn enf_atk13() void {
    state(.attack9, enf_atk14);
    fight.ai_face();
}

pub export fn enf_atk14() void {
    state(.attack10, enf_run1);
    fight.ai_face();
    subs.SUB_CheckRefire(q.func(enf_atk1));
}

pub export fn enf_paina1() void {
    state(.paina1, enf_paina2);
}

pub export fn enf_paina2() void {
    state(.paina2, enf_paina3);
}

pub export fn enf_paina3() void {
    state(.paina3, enf_paina4);
}

pub export fn enf_paina4() void {
    state(.paina4, enf_run1);
}

pub export fn enf_painb1() void {
    state(.painb1, enf_painb2);
}

pub export fn enf_painb2() void {
    state(.painb2, enf_painb3);
}

pub export fn enf_painb3() void {
    state(.painb3, enf_painb4);
}

pub export fn enf_painb4() void {
    state(.painb4, enf_painb5);
}

pub export fn enf_painb5() void {
    state(.painb5, enf_run1);
}

pub export fn enf_painc1() void {
    state(.painc1, enf_painc2);
}

pub export fn enf_painc2() void {
    state(.painc2, enf_painc3);
}

pub export fn enf_painc3() void {
    state(.painc3, enf_painc4);
}

pub export fn enf_painc4() void {
    state(.painc4, enf_painc5);
}

pub export fn enf_painc5() void {
    state(.painc5, enf_painc6);
}

pub export fn enf_painc6() void {
    state(.painc6, enf_painc7);
}

pub export fn enf_painc7() void {
    state(.painc7, enf_painc8);
}

pub export fn enf_painc8() void {
    state(.painc8, enf_run1);
}

pub export fn enf_paind1() void {
    state(.paind1, enf_paind2);
}

pub export fn enf_paind2() void {
    state(.paind2, enf_paind3);
}

pub export fn enf_paind3() void {
    state(.paind3, enf_paind4);
}

pub export fn enf_paind4() void {
    state(.paind4, enf_paind5);
    ai.ai_painforward(2);
}

pub export fn enf_paind5() void {
    state(.paind5, enf_paind6);
    ai.ai_painforward(1);
}

pub export fn enf_paind6() void {
    state(.paind6, enf_paind7);
}

pub export fn enf_paind7() void {
    state(.paind7, enf_paind8);
}

pub export fn enf_paind8() void {
    state(.paind8, enf_paind9);
}

pub export fn enf_paind9() void {
    state(.paind9, enf_paind10);
}

pub export fn enf_paind10() void {
    state(.paind10, enf_paind11);
}

pub export fn enf_paind11() void {
    state(.paind11, enf_paind12);
    ai.ai_painforward(1);
}

pub export fn enf_paind12() void {
    state(.paind12, enf_paind13);
    ai.ai_painforward(1);
}

pub export fn enf_paind13() void {
    state(.paind13, enf_paind14);
    ai.ai_painforward(1);
}

pub export fn enf_paind14() void {
    state(.paind14, enf_paind15);
}

pub export fn enf_paind15() void {
    state(.paind15, enf_paind16);
}

pub export fn enf_paind16() void {
    state(.paind16, enf_paind17);
    ai.ai_pain(1);
}

pub export fn enf_paind17() void {
    state(.paind17, enf_paind18);
    ai.ai_pain(1);
}

pub export fn enf_paind18() void {
    state(.paind18, enf_paind19);
}

pub export fn enf_paind19() void {
    state(.paind19, enf_run1);
}

pub export fn enf_pain(attacker: Entity, damage: f32) void {
    _ = attacker;
    _ = damage;
    const self = q.me();

    const r = q.random();
    if (self.get(lq.pain_finished) > q.time.get())
        return;

    if (r < 0.5)
        q.sound(self, lq.CHAN_VOICE, S("enforcer/pain1.wav"), 1, lq.ATTN_NORM)
    else
        q.sound(self, lq.CHAN_VOICE, S("enforcer/pain2.wav"), 1, lq.ATTN_NORM);

    if (r < 0.2) {
        self.set(lq.pain_finished, q.time.get() + 1);
        enf_paina1();
    } else if (r < 0.4) {
        self.set(lq.pain_finished, q.time.get() + 1);
        enf_painb1();
    } else if (r < 0.7) {
        self.set(lq.pain_finished, q.time.get() + 1);
        enf_painc1();
    } else {
        self.set(lq.pain_finished, q.time.get() + 2);
        enf_paind1();
    }
}

pub export fn enf_die1() void {
    state(.death1, enf_die2);
}

pub export fn enf_die2() void {
    state(.death2, enf_die3);
}

pub export fn enf_die3() void {
    state(.death3, enf_die4);
    const self = q.me();
    self.solid = lq.SOLID_NOT;
    self.ammo_cells = 5;
    items.DropBackpack();
}

pub export fn enf_die4() void {
    state(.death4, enf_die5);
    ai.ai_forward(14);
}

pub export fn enf_die5() void {
    state(.death5, enf_die6);
    ai.ai_forward(2);
}

pub export fn enf_die6() void {
    state(.death6, enf_die7);
}

pub export fn enf_die7() void {
    state(.death7, enf_die8);
}

pub export fn enf_die8() void {
    state(.death8, enf_die9);
}

pub export fn enf_die9() void {
    state(.death9, enf_die10);
    ai.ai_forward(3);
}

pub export fn enf_die10() void {
    state(.death10, enf_die11);
    ai.ai_forward(5);
}

pub export fn enf_die11() void {
    state(.death11, enf_die12);
    ai.ai_forward(5);
}

pub export fn enf_die12() void {
    state(.death12, enf_die13);
    ai.ai_forward(5);
}

pub export fn enf_die13() void {
    state(.death13, enf_die14);
}

pub export fn enf_die14() void {
    state(.death14, enf_die14);
}

pub export fn enf_fdie1() void {
    state(.fdeath1, enf_fdie2);
}

pub export fn enf_fdie2() void {
    state(.fdeath2, enf_fdie3);
}

pub export fn enf_fdie3() void {
    state(.fdeath3, enf_fdie4);
    const self = q.me();
    self.solid = lq.SOLID_NOT;
    self.ammo_cells = 5;
    items.DropBackpack();
}

pub export fn enf_fdie4() void {
    state(.fdeath4, enf_fdie5);
}

pub export fn enf_fdie5() void {
    state(.fdeath5, enf_fdie6);
}

pub export fn enf_fdie6() void {
    state(.fdeath6, enf_fdie7);
}

pub export fn enf_fdie7() void {
    state(.fdeath7, enf_fdie8);
}

pub export fn enf_fdie8() void {
    state(.fdeath8, enf_fdie9);
}

pub export fn enf_fdie9() void {
    state(.fdeath9, enf_fdie10);
}

pub export fn enf_fdie10() void {
    state(.fdeath10, enf_fdie11);
}

pub export fn enf_fdie11() void {
    state(.fdeath11, enf_fdie11);
}

pub export fn enf_die() void {
    const self = q.me();
    // check for gib
    if (self.health < -35) {
        q.sound(self, lq.CHAN_VOICE, S("player/udeath.wav"), 1, lq.ATTN_NORM);
        player.ThrowHead(S("progs/h_mega.mdl"), self.health);
        player.ThrowGib(S("progs/gib1.mdl"), self.health);
        player.ThrowGib(S("progs/gib2.mdl"), self.health);
        player.ThrowGib(S("progs/gib3.mdl"), self.health);

        return;
    }

    // regular death
    q.sound(self, lq.CHAN_VOICE, S("enforcer/death1.wav"), 1, lq.ATTN_NORM);

    if (q.random() > 0.5)
        enf_die1()
    else
        enf_fdie1();
}

/// QUAKED monster_enforcer (1 0 0) (-16 -16 -24) (16 16 40) Ambush
/// {
///     model({"path": "progs/enforcer.mdl", "skin": 0, "frame": 0});
/// }
pub export fn monster_enforcer() void {
    const self = q.me();
    if (q.deathmatch.get() != 0) {
        q.remove(self);
        return;
    }

    _ = q.precache_model2(S("progs/enforcer.mdl"));
    _ = q.precache_model2(S("progs/h_mega.mdl"));
    _ = q.precache_model2(S("progs/laser.mdl"));

    _ = q.precache_sound2(S("enforcer/death1.wav"));
    _ = q.precache_sound2(S("enforcer/enfire.wav"));
    _ = q.precache_sound2(S("enforcer/enfstop.wav"));
    _ = q.precache_sound2(S("enforcer/idle1.wav"));
    _ = q.precache_sound2(S("enforcer/pain1.wav"));
    _ = q.precache_sound2(S("enforcer/pain2.wav"));
    _ = q.precache_sound2(S("enforcer/sight1.wav"));
    _ = q.precache_sound2(S("enforcer/sight2.wav"));
    _ = q.precache_sound2(S("enforcer/sight3.wav"));
    _ = q.precache_sound2(S("enforcer/sight4.wav"));

    self.solid = lq.SOLID_SLIDEBOX;
    self.movetype = lq.MOVETYPE_STEP;

    q.setmodel(self, S("progs/enforcer.mdl"));

    //gnounc
    self.netname = S("enforcer");
    self.set(lq.killstring, S(loc.LOC_DEATH_ENFORCER));
    self.noise = S("enforcer/sight1.wav"); //gnounc
    self.noise1 = S("enforcer/sight2.wav"); //gnounc
    self.noise2 = S("enforcer/sight3.wav"); //gnounc
    self.noise3 = S("enforcer/sight4.wav"); //gnounc

    q.setsize(self, q.vec(-16, -16, -24), q.vec(16, 16, 40));
    self.health = 80;
    self.max_health = 80;

    self.set(lq.th_stand, q.func(enf_stand1));
    self.set(lq.th_walk, q.func(enf_walk1));
    self.set(lq.th_run, q.func(enf_run1));
    self.set(lq.th_pain, q.func(enf_pain));
    self.set(lq.th_die, q.func(enf_die));
    self.set(lq.th_missile, q.func(enf_atk1));

    monsters.walkmonster_start();
}
