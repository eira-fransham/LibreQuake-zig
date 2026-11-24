//! monsters/knight.qc

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
    stand9,
    runb1,
    runb2,
    runb3,
    runb4,
    runb5,
    runb6,
    runb7,
    runb8,
    runattack1,
    runattack2,
    runattack3,
    runattack4,
    runattack5,
    runattack6,
    runattack7,
    runattack8,
    runattack9,
    runattack10,
    runattack11,
    pain1,
    pain2,
    pain3,
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
    attackb1,
    attackb2,
    attackb3,
    attackb4,
    attackb5,
    attackb6,
    attackb7,
    attackb8,
    attackb9,
    attackb10,
    attackb11,
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
    kneel1,
    kneel2,
    kneel3,
    kneel4,
    kneel5,
    standing2,
    standing3,
    standing4,
    standing5,
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
    deathb1,
    deathb2,
    deathb3,
    deathb4,
    deathb5,
    deathb6,
    deathb7,
    deathb8,
    deathb9,
    deathb10,
    deathb11,
};

/// `$frame`, as a float.
inline fn fr(comptime frame: Frame) f32 {
    return @floatFromInt(@backingInt(frame));
}

/// The `[$frame, next]` prefix of a state function.
inline fn state(comptime frame: Frame, comptime next: anytype) void {
    q.setState(fr(frame), q.func(next));
}

pub export fn knight_stand1() void {
    state(.stand1, knight_stand2);
    ai.ai_stand();
}

pub export fn knight_stand2() void {
    state(.stand2, knight_stand3);
    ai.ai_stand();
}

pub export fn knight_stand3() void {
    state(.stand3, knight_stand4);
    ai.ai_stand();
}

pub export fn knight_stand4() void {
    state(.stand4, knight_stand5);
    ai.ai_stand();
}

pub export fn knight_stand5() void {
    state(.stand5, knight_stand6);
    ai.ai_stand();
}

pub export fn knight_stand6() void {
    state(.stand6, knight_stand7);
    ai.ai_stand();
}

pub export fn knight_stand7() void {
    state(.stand7, knight_stand8);
    ai.ai_stand();
}

pub export fn knight_stand8() void {
    state(.stand8, knight_stand9);
    ai.ai_stand();
}

pub export fn knight_stand9() void {
    state(.stand9, knight_stand1);
    ai.ai_stand();
}

pub export fn knight_walk1() void {
    state(.walk1, knight_walk2);
    if (q.random() < 0.2)
        q.sound(q.me(), lq.CHAN_VOICE, S("knight/idle.wav"), 1, lq.ATTN_IDLE);
    ai.ai_walk(3);
}

pub export fn knight_walk2() void {
    state(.walk2, knight_walk3);
    ai.ai_walk(2);
}

pub export fn knight_walk3() void {
    state(.walk3, knight_walk4);
    ai.ai_walk(3);
}

pub export fn knight_walk4() void {
    state(.walk4, knight_walk5);
    ai.ai_walk(4);
}

pub export fn knight_walk5() void {
    state(.walk5, knight_walk6);
    ai.ai_walk(3);
}

pub export fn knight_walk6() void {
    state(.walk6, knight_walk7);
    ai.ai_walk(3);
}

pub export fn knight_walk7() void {
    state(.walk7, knight_walk8);
    ai.ai_walk(3);
}

pub export fn knight_walk8() void {
    state(.walk8, knight_walk9);
    ai.ai_walk(4);
}

pub export fn knight_walk9() void {
    state(.walk9, knight_walk10);
    ai.ai_walk(3);
}

pub export fn knight_walk10() void {
    state(.walk10, knight_walk11);
    ai.ai_walk(3);
}

pub export fn knight_walk11() void {
    state(.walk11, knight_walk12);
    ai.ai_walk(2);
}

pub export fn knight_walk12() void {
    state(.walk12, knight_walk13);
    ai.ai_walk(3);
}

pub export fn knight_walk13() void {
    state(.walk13, knight_walk14);
    ai.ai_walk(4);
}

pub export fn knight_walk14() void {
    state(.walk14, knight_walk1);
    ai.ai_walk(3);
}

pub export fn knight_run1() void {
    state(.runb1, knight_run2);
    if (q.random() < 0.2)
        q.sound(q.me(), lq.CHAN_VOICE, S("knight/idle.wav"), 1, lq.ATTN_IDLE);
    ai.ai_run(16);
}

pub export fn knight_run2() void {
    state(.runb2, knight_run3);
    ai.ai_run(20);
}

pub export fn knight_run3() void {
    state(.runb3, knight_run4);
    ai.ai_run(13);
}

pub export fn knight_run4() void {
    state(.runb4, knight_run5);
    ai.ai_run(7);
}

pub export fn knight_run5() void {
    state(.runb5, knight_run6);
    ai.ai_run(16);
}

pub export fn knight_run6() void {
    state(.runb6, knight_run7);
    ai.ai_run(20);
}

pub export fn knight_run7() void {
    state(.runb7, knight_run8);
    ai.ai_run(14);
}

pub export fn knight_run8() void {
    state(.runb8, knight_run1);
    ai.ai_run(6);
}

pub export fn knight_runatk1() void {
    state(.runattack1, knight_runatk2);
    if (q.random() > 0.5)
        q.sound(q.me(), lq.CHAN_WEAPON, S("knight/sword2.wav"), 1, lq.ATTN_NORM)
    else
        q.sound(q.me(), lq.CHAN_WEAPON, S("knight/sword1.wav"), 1, lq.ATTN_NORM);
    fight.ai_charge(20);
}

pub export fn knight_runatk2() void {
    state(.runattack2, knight_runatk3);
    fight.ai_charge_side();
}

pub export fn knight_runatk3() void {
    state(.runattack3, knight_runatk4);
    fight.ai_charge_side();
}

pub export fn knight_runatk4() void {
    state(.runattack4, knight_runatk5);
    fight.ai_charge_side();
}

pub export fn knight_runatk5() void {
    state(.runattack5, knight_runatk6);
    fight.ai_melee_side();
}

pub export fn knight_runatk6() void {
    state(.runattack6, knight_runatk7);
    fight.ai_melee_side();
}

pub export fn knight_runatk7() void {
    state(.runattack7, knight_runatk8);
    fight.ai_melee_side();
}

pub export fn knight_runatk8() void {
    state(.runattack8, knight_runatk9);
    fight.ai_melee_side();
}

pub export fn knight_runatk9() void {
    state(.runattack9, knight_runatk10);
    fight.ai_melee_side();
}

pub export fn knight_runatk10() void {
    state(.runattack10, knight_runatk11);
    fight.ai_charge_side();
}

pub export fn knight_runatk11() void {
    state(.runattack11, knight_run1);
    fight.ai_charge(10);
}

pub export fn knight_atk1() void {
    state(.attackb1, knight_atk2);
    q.sound(q.me(), lq.CHAN_WEAPON, S("knight/sword1.wav"), 1, lq.ATTN_NORM);
    fight.ai_charge(0);
}

pub export fn knight_atk2() void {
    state(.attackb2, knight_atk3);
    fight.ai_charge(7);
}

pub export fn knight_atk3() void {
    state(.attackb3, knight_atk4);
    fight.ai_charge(4);
}

pub export fn knight_atk4() void {
    state(.attackb4, knight_atk5);
    fight.ai_charge(0);
}

pub export fn knight_atk5() void {
    state(.attackb5, knight_atk6);
    fight.ai_charge(3);
}

pub export fn knight_atk6() void {
    state(.attackb6, knight_atk7);
    fight.ai_charge(4);
    fight.ai_melee();
}

pub export fn knight_atk7() void {
    state(.attackb7, knight_atk8);
    fight.ai_charge(1);
    fight.ai_melee();
}

pub export fn knight_atk8() void {
    state(.attackb8, knight_atk9);
    fight.ai_charge(3);
    fight.ai_melee();
}

pub export fn knight_atk9() void {
    state(.attackb9, knight_atk10);
    fight.ai_charge(1);
}

pub export fn knight_atk10() void {
    state(.attackb10, knight_run1);
    fight.ai_charge(5);
}

pub export fn knight_pain1() void {
    state(.pain1, knight_pain2);
}

pub export fn knight_pain2() void {
    state(.pain2, knight_pain3);
}

pub export fn knight_pain3() void {
    state(.pain3, knight_run1);
}

pub export fn knight_painb1() void {
    state(.painb1, knight_painb2);
    ai.ai_painforward(0);
}

pub export fn knight_painb2() void {
    state(.painb2, knight_painb3);
    ai.ai_painforward(3);
}

pub export fn knight_painb3() void {
    state(.painb3, knight_painb4);
}

pub export fn knight_painb4() void {
    state(.painb4, knight_painb5);
}

pub export fn knight_painb5() void {
    state(.painb5, knight_painb6);
    ai.ai_painforward(2);
}

pub export fn knight_painb6() void {
    state(.painb6, knight_painb7);
    ai.ai_painforward(4);
}

pub export fn knight_painb7() void {
    state(.painb7, knight_painb8);
    ai.ai_painforward(2);
}

pub export fn knight_painb8() void {
    state(.painb8, knight_painb9);
    ai.ai_painforward(5);
}

pub export fn knight_painb9() void {
    state(.painb9, knight_painb10);
    ai.ai_painforward(5);
}

pub export fn knight_painb10() void {
    state(.painb10, knight_painb11);
    ai.ai_painforward(0);
}

pub export fn knight_painb11() void {
    state(.painb11, knight_run1);
}

pub export fn knight_pain(attacker: Entity, damage: f32) void {
    _ = attacker;
    _ = damage;
    const self = q.me();

    if (self.get(lq.pain_finished) > q.time.get())
        return;

    const r = q.random();

    q.sound(self, lq.CHAN_VOICE, S("knight/khurt.wav"), 1, lq.ATTN_NORM);
    if (r < 0.85) {
        knight_pain1();
        self.set(lq.pain_finished, q.time.get() + 1);
    } else {
        knight_painb1();
        self.set(lq.pain_finished, q.time.get() + 1);
    }
}

pub export fn knight_bow1() void {
    state(.kneel1, knight_bow2);
    ai.ai_turn();
}

pub export fn knight_bow2() void {
    state(.kneel2, knight_bow3);
    ai.ai_turn();
}

pub export fn knight_bow3() void {
    state(.kneel3, knight_bow4);
    ai.ai_turn();
}

pub export fn knight_bow4() void {
    state(.kneel4, knight_bow5);
    ai.ai_turn();
}

pub export fn knight_bow5() void {
    state(.kneel5, knight_bow5);
    ai.ai_turn();
}

pub export fn knight_bow6() void {
    state(.kneel4, knight_bow7);
    ai.ai_turn();
}

pub export fn knight_bow7() void {
    state(.kneel3, knight_bow8);
    ai.ai_turn();
}

pub export fn knight_bow8() void {
    state(.kneel2, knight_bow9);
    ai.ai_turn();
}

pub export fn knight_bow9() void {
    state(.kneel1, knight_bow10);
    ai.ai_turn();
}

pub export fn knight_bow10() void {
    state(.walk1, knight_walk1);
    ai.ai_turn();
}

pub export fn knight_die1() void {
    state(.death1, knight_die2);
}

pub export fn knight_die2() void {
    state(.death2, knight_die3);
}

pub export fn knight_die3() void {
    state(.death3, knight_die4);
    q.me().solid = lq.SOLID_NOT;
}

pub export fn knight_die4() void {
    state(.death4, knight_die5);
}

pub export fn knight_die5() void {
    state(.death5, knight_die6);
}

pub export fn knight_die6() void {
    state(.death6, knight_die7);
}

pub export fn knight_die7() void {
    state(.death7, knight_die8);
}

pub export fn knight_die8() void {
    state(.death8, knight_die9);
}

pub export fn knight_die9() void {
    state(.death9, knight_die10);
}

pub export fn knight_die10() void {
    state(.death10, knight_die10);
}

pub export fn knight_dieb1() void {
    state(.deathb1, knight_dieb2);
}

pub export fn knight_dieb2() void {
    state(.deathb2, knight_dieb3);
}

pub export fn knight_dieb3() void {
    state(.deathb3, knight_dieb4);
    q.me().solid = lq.SOLID_NOT;
}

pub export fn knight_dieb4() void {
    state(.deathb4, knight_dieb5);
}

pub export fn knight_dieb5() void {
    state(.deathb5, knight_dieb6);
}

pub export fn knight_dieb6() void {
    state(.deathb6, knight_dieb7);
}

pub export fn knight_dieb7() void {
    state(.deathb7, knight_dieb8);
}

pub export fn knight_dieb8() void {
    state(.deathb8, knight_dieb9);
}

pub export fn knight_dieb9() void {
    state(.deathb9, knight_dieb10);
}

pub export fn knight_dieb10() void {
    state(.deathb10, knight_dieb11);
}

pub export fn knight_dieb11() void {
    state(.deathb11, knight_dieb11);
}

pub export fn knight_die() void {
    const self = q.me();
    // check for gib
    if (self.health < -40) {
        q.sound(self, lq.CHAN_VOICE, S("player/udeath.wav"), 1, lq.ATTN_NORM);
        player.ThrowHead(S("progs/h_knight.mdl"), self.health);
        player.ThrowGib(S("progs/gib1.mdl"), self.health);
        player.ThrowGib(S("progs/gib2.mdl"), self.health);
        player.ThrowGib(S("progs/gib3.mdl"), self.health);

        return;
    }

    // regular death
    q.sound(self, lq.CHAN_VOICE, S("knight/kdeath.wav"), 1, lq.ATTN_NORM);

    if (q.random() < 0.5)
        knight_die1()
    else
        knight_dieb1();
}

/// QUAKED monster_knight (1 0 0) (-16 -16 -24) (16 16 40) Ambush
/// {
///     model({"path": "progs/knight.mdl", "skin": 0, "frame": 0});
/// }
pub export fn monster_knight() void {
    const self = q.me();
    if (q.deathmatch.get() != 0) {
        q.remove(self);
        return;
    }

    _ = q.precache_model(S("progs/knight.mdl"));
    _ = q.precache_model(S("progs/h_knight.mdl"));

    _ = q.precache_sound(S("knight/kdeath.wav"));
    _ = q.precache_sound(S("knight/khurt.wav"));
    _ = q.precache_sound(S("knight/ksight.wav"));
    _ = q.precache_sound(S("knight/sword1.wav"));
    _ = q.precache_sound(S("knight/sword2.wav"));
    _ = q.precache_sound(S("knight/idle.wav"));

    self.solid = lq.SOLID_SLIDEBOX;
    self.movetype = lq.MOVETYPE_STEP;

    q.setmodel(self, S("progs/knight.mdl"));

    //gnounc
    self.noise = S("knight/ksight.wav"); //gnounc
    self.netname = S("Knight");
    self.set(lq.killstring, S(loc.LOC_DEATH_KNIGHT));

    q.setsize(self, q.vec(-16, -16, -24), q.vec(16, 16, 40));
    self.health = 75;
    self.max_health = 75;

    self.set(lq.th_stand, q.func(knight_stand1));
    self.set(lq.th_walk, q.func(knight_walk1));
    self.set(lq.th_run, q.func(knight_run1));
    self.set(lq.th_melee, q.func(knight_atk1));
    self.set(lq.th_pain, q.func(knight_pain));
    self.set(lq.th_die, q.func(knight_die));

    monsters.walkmonster_start();
}
