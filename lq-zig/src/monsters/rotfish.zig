//! monsters/rotfish.qc

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
const combat = @import("../combat.zig");
const monsters = @import("../monsters.zig");

/// The `$frame` macros, numbered from 0 in declaration order.
const Frame = enum(u8) {
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
    death15,
    death16,
    death17,
    death18,
    death19,
    death20,
    death21,
    swim1,
    swim2,
    swim3,
    swim4,
    swim5,
    swim6,
    swim7,
    swim8,
    swim9,
    swim10,
    swim11,
    swim12,
    swim13,
    swim14,
    swim15,
    swim16,
    swim17,
    swim18,
    pain1,
    pain2,
    pain3,
    pain4,
    pain5,
    pain6,
    pain7,
    pain8,
    pain9,
};

/// `$frame`, as a float.
inline fn fr(comptime frame: Frame) f32 {
    return @floatFromInt(@backingInt(frame));
}

/// The `[$frame, next]` prefix of a state function.
inline fn state(comptime frame: Frame, comptime next: anytype) void {
    q.setState(fr(frame), q.func(next));
}

pub export fn f_stand1() void {
    state(.swim1, f_stand2);
    ai.ai_stand();
}

pub export fn f_stand2() void {
    state(.swim2, f_stand3);
    ai.ai_stand();
}

pub export fn f_stand3() void {
    state(.swim3, f_stand4);
    ai.ai_stand();
}

pub export fn f_stand4() void {
    state(.swim4, f_stand5);
    ai.ai_stand();
}

pub export fn f_stand5() void {
    state(.swim5, f_stand6);
    ai.ai_stand();
}

pub export fn f_stand6() void {
    state(.swim6, f_stand7);
    ai.ai_stand();
}

pub export fn f_stand7() void {
    state(.swim7, f_stand8);
    ai.ai_stand();
}

pub export fn f_stand8() void {
    state(.swim8, f_stand9);
    ai.ai_stand();
}

pub export fn f_stand9() void {
    state(.swim9, f_stand10);
    ai.ai_stand();
}

pub export fn f_stand10() void {
    state(.swim10, f_stand11);
    ai.ai_stand();
}

pub export fn f_stand11() void {
    state(.swim11, f_stand12);
    ai.ai_stand();
}

pub export fn f_stand12() void {
    state(.swim12, f_stand13);
    ai.ai_stand();
}

pub export fn f_stand13() void {
    state(.swim13, f_stand14);
    ai.ai_stand();
}

pub export fn f_stand14() void {
    state(.swim14, f_stand15);
    ai.ai_stand();
}

pub export fn f_stand15() void {
    state(.swim15, f_stand16);
    ai.ai_stand();
}

pub export fn f_stand16() void {
    state(.swim16, f_stand17);
    ai.ai_stand();
}

pub export fn f_stand17() void {
    state(.swim17, f_stand18);
    ai.ai_stand();
}

pub export fn f_stand18() void {
    state(.swim18, f_stand1);
    ai.ai_stand();
}

pub export fn f_walk1() void {
    state(.swim1, f_walk2);
    ai.ai_walk(8);
}

pub export fn f_walk2() void {
    state(.swim2, f_walk3);
    ai.ai_walk(8);
}

pub export fn f_walk3() void {
    state(.swim3, f_walk4);
    ai.ai_walk(8);
}

pub export fn f_walk4() void {
    state(.swim4, f_walk5);
    ai.ai_walk(8);
}

pub export fn f_walk5() void {
    state(.swim5, f_walk6);
    ai.ai_walk(8);
}

pub export fn f_walk6() void {
    state(.swim6, f_walk7);
    ai.ai_walk(8);
}

pub export fn f_walk7() void {
    state(.swim7, f_walk8);
    ai.ai_walk(8);
}

pub export fn f_walk8() void {
    state(.swim8, f_walk9);
    ai.ai_walk(8);
}

pub export fn f_walk9() void {
    state(.swim9, f_walk10);
    ai.ai_walk(8);
}

pub export fn f_walk10() void {
    state(.swim10, f_walk11);
    ai.ai_walk(8);
}

pub export fn f_walk11() void {
    state(.swim11, f_walk12);
    ai.ai_walk(8);
}

pub export fn f_walk12() void {
    state(.swim12, f_walk13);
    ai.ai_walk(8);
}

pub export fn f_walk13() void {
    state(.swim13, f_walk14);
    ai.ai_walk(8);
}

pub export fn f_walk14() void {
    state(.swim14, f_walk15);
    ai.ai_walk(8);
}

pub export fn f_walk15() void {
    state(.swim15, f_walk16);
    ai.ai_walk(8);
}

pub export fn f_walk16() void {
    state(.swim16, f_walk17);
    ai.ai_walk(8);
}

pub export fn f_walk17() void {
    state(.swim17, f_walk18);
    ai.ai_walk(8);
}

pub export fn f_walk18() void {
    state(.swim18, f_walk1);
    ai.ai_walk(8);
}

pub export fn f_run1() void {
    state(.swim1, f_run2);
    const self = q.me();
    ai.ai_run(12);
    if (q.random() < 0.5)
        q.sound(self, lq.CHAN_VOICE, S("fish/idle.wav"), 1, lq.ATTN_NORM);
}

pub export fn f_run2() void {
    state(.swim3, f_run3);
    ai.ai_run(12);
}

pub export fn f_run3() void {
    state(.swim5, f_run4);
    ai.ai_run(12);
}

pub export fn f_run4() void {
    state(.swim7, f_run5);
    ai.ai_run(12);
}

pub export fn f_run5() void {
    state(.swim9, f_run6);
    ai.ai_run(12);
}

pub export fn f_run6() void {
    state(.swim11, f_run7);
    ai.ai_run(12);
}

pub export fn f_run7() void {
    state(.swim13, f_run8);
    ai.ai_run(12);
}

pub export fn f_run8() void {
    state(.swim15, f_run9);
    ai.ai_run(12);
}

pub export fn f_run9() void {
    state(.swim17, f_run1);
    ai.ai_run(12);
}

pub export fn fish_melee() void {
    const self = q.me();

    if (self.enemy.isNull())
        return; // removed before stroke

    const delta = @as(Vector, self.enemy.origin) - self.origin;

    if (q.vlen(delta) > 60)
        return;

    q.sound(self, lq.CHAN_VOICE, S("fish/bite.wav"), 1, lq.ATTN_NORM);
    const ldmg = (q.random() + q.random()) * 3;
    combat.T_Damage(self.enemy, self, self, ldmg);
}

pub export fn f_attack1() void {
    state(.attack1, f_attack2);
    fight.ai_charge(10);
}

pub export fn f_attack2() void {
    state(.attack2, f_attack3);
    fight.ai_charge(10);
}

pub export fn f_attack3() void {
    state(.attack3, f_attack4);
    fish_melee();
}

pub export fn f_attack4() void {
    state(.attack4, f_attack5);
    fight.ai_charge(10);
}

pub export fn f_attack5() void {
    state(.attack5, f_attack6);
    fight.ai_charge(10);
}

pub export fn f_attack6() void {
    state(.attack6, f_attack7);
    fight.ai_charge(10);
}

pub export fn f_attack7() void {
    state(.attack7, f_attack8);
    fight.ai_charge(10);
}

pub export fn f_attack8() void {
    state(.attack8, f_attack9);
    fight.ai_charge(10);
}

pub export fn f_attack9() void {
    state(.attack9, f_attack10);
    fish_melee();
}

pub export fn f_attack10() void {
    state(.attack10, f_attack11);
    fight.ai_charge(10);
}

pub export fn f_attack11() void {
    state(.attack11, f_attack12);
    fight.ai_charge(10);
}

pub export fn f_attack12() void {
    state(.attack12, f_attack13);
    fight.ai_charge(10);
}

pub export fn f_attack13() void {
    state(.attack13, f_attack14);
    fight.ai_charge(10);
}

pub export fn f_attack14() void {
    state(.attack14, f_attack15);
    fight.ai_charge(10);
}

pub export fn f_attack15() void {
    state(.attack15, f_attack16);
    fish_melee();
}

pub export fn f_attack16() void {
    state(.attack16, f_attack17);
    fight.ai_charge(10);
}

pub export fn f_attack17() void {
    state(.attack17, f_attack18);
    fight.ai_charge(10);
}

pub export fn f_attack18() void {
    state(.attack18, f_run1);
    fight.ai_charge(10);
}

pub export fn f_death1() void {
    state(.death1, f_death2);
    const self = q.me();
    q.sound(self, lq.CHAN_VOICE, S("fish/death.wav"), 1, lq.ATTN_NORM);
}

pub export fn f_death2() void {
    state(.death2, f_death3);
    const self = q.me();
    self.solid = lq.SOLID_NOT; // gb, become nonsolid faster
}

pub export fn f_death3() void {
    state(.death3, f_death4);
}

pub export fn f_death4() void {
    state(.death4, f_death5);
}

pub export fn f_death5() void {
    state(.death5, f_death6);
}

pub export fn f_death6() void {
    state(.death6, f_death7);
}

pub export fn f_death7() void {
    state(.death7, f_death8);
}

pub export fn f_death8() void {
    state(.death8, f_death9);
}

pub export fn f_death9() void {
    state(.death9, f_death10);
}

pub export fn f_death10() void {
    state(.death10, f_death11);
}

pub export fn f_death11() void {
    state(.death11, f_death12);
}

pub export fn f_death12() void {
    state(.death12, f_death13);
}

pub export fn f_death13() void {
    state(.death13, f_death14);
}

pub export fn f_death14() void {
    state(.death14, f_death15);
}

pub export fn f_death15() void {
    state(.death15, f_death16);
}

pub export fn f_death16() void {
    state(.death16, f_death17);
}

pub export fn f_death17() void {
    state(.death17, f_death18);
}

pub export fn f_death18() void {
    state(.death18, f_death19);
}

pub export fn f_death19() void {
    state(.death19, f_death20);
}

pub export fn f_death20() void {
    state(.death20, f_death21);
}

pub export fn f_death21() void {
    state(.death21, f_death21);
}

pub export fn f_pain1() void {
    state(.pain1, f_pain2);
}

pub export fn f_pain2() void {
    state(.pain2, f_pain3);
    ai.ai_pain(6);
}

pub export fn f_pain3() void {
    state(.pain3, f_pain4);
    ai.ai_pain(6);
}

pub export fn f_pain4() void {
    state(.pain4, f_pain5);
    ai.ai_pain(6);
}

pub export fn f_pain5() void {
    state(.pain5, f_pain6);
    ai.ai_pain(6);
}

pub export fn f_pain6() void {
    state(.pain6, f_pain7);
    ai.ai_pain(6);
}

pub export fn f_pain7() void {
    state(.pain7, f_pain8);
    ai.ai_pain(6);
}

pub export fn f_pain8() void {
    state(.pain8, f_pain9);
    ai.ai_pain(6);
}

pub export fn f_pain9() void {
    state(.pain9, f_run1);
    ai.ai_pain(6);
}

pub export fn fish_pain(attacker: Entity, damage: f32) void {
    _ = attacker;
    _ = damage;
    // fish allways do pain frames
    f_pain1();
}

/// QUAKED monster_fish (1 0 0) (-16 -16 -24) (16 16 24) Ambush
/// {
///     model({"path": "progs/fish.mdl", "skin": 0, "frame": 0});
/// }
pub export fn monster_fish() void {
    const self = q.me();
    if (q.deathmatch.get() != 0) {
        q.remove(self);
        return;
    }

    _ = q.precache_model2(S("progs/fish.mdl"));

    _ = q.precache_sound2(S("fish/death.wav"));
    _ = q.precache_sound2(S("fish/bite.wav"));
    _ = q.precache_sound2(S("fish/idle.wav"));

    self.solid = lq.SOLID_SLIDEBOX;
    self.movetype = lq.MOVETYPE_STEP;

    q.setmodel(self, S("progs/fish.mdl"));

    //gnounc
    self.netname = S("Rotfish");
    self.noise = S("fish/idle.wav"); //gnounc   (for completeness..just in case)
    self.set(lq.killstring, S(loc.LOC_DEATH_FISH));

    q.setsize(self, q.vec(-16, -16, -24), q.vec(16, 16, 24));
    self.health = 25;
    self.max_health = 25;

    self.set(lq.th_stand, q.func(f_stand1));
    self.set(lq.th_walk, q.func(f_walk1));
    self.set(lq.th_run, q.func(f_run1));
    self.set(lq.th_die, q.func(f_death1));
    self.set(lq.th_pain, q.func(fish_pain));
    self.set(lq.th_melee, q.func(f_attack1));

    monsters.swimmonster_start();
}
