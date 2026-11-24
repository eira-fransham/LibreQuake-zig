//! monsters/hellknight.qc

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
const subs = @import("../subs.zig");
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
    run1,
    run2,
    run3,
    run4,
    run5,
    run6,
    run7,
    run8,
    pain1,
    pain2,
    pain3,
    pain4,
    pain5,
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
    deathb1,
    deathb2,
    deathb3,
    deathb4,
    deathb5,
    deathb6,
    deathb7,
    deathb8,
    deathb9,
    char_a1,
    char_a2,
    char_a3,
    char_a4,
    char_a5,
    char_a6,
    char_a7,
    char_a8,
    char_a9,
    char_a10,
    char_a11,
    char_a12,
    char_a13,
    char_a14,
    char_a15,
    char_a16,
    magica1,
    magica2,
    magica3,
    magica4,
    magica5,
    magica6,
    magica7,
    magica8,
    magica9,
    magica10,
    magica11,
    magica12,
    magica13,
    magica14,
    magicb1,
    magicb2,
    magicb3,
    magicb4,
    magicb5,
    magicb6,
    magicb7,
    magicb8,
    magicb9,
    magicb10,
    magicb11,
    magicb12,
    magicb13,
    char_b1,
    char_b2,
    char_b3,
    char_b4,
    char_b5,
    char_b6,
    slice1,
    slice2,
    slice3,
    slice4,
    slice5,
    slice6,
    slice7,
    slice8,
    slice9,
    slice10,
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
    w_attack1,
    w_attack2,
    w_attack3,
    w_attack4,
    w_attack5,
    w_attack6,
    w_attack7,
    w_attack8,
    w_attack9,
    w_attack10,
    w_attack11,
    w_attack12,
    w_attack13,
    w_attack14,
    w_attack15,
    w_attack16,
    w_attack17,
    w_attack18,
    w_attack19,
    w_attack20,
    w_attack21,
    w_attack22,
    magicc1,
    magicc2,
    magicc3,
    magicc4,
    magicc5,
    magicc6,
    magicc7,
    magicc8,
    magicc9,
    magicc10,
    magicc11,
};

/// `$frame`, as a float.
inline fn fr(comptime frame: Frame) f32 {
    return @floatFromInt(@backingInt(frame));
}

/// The `[$frame, next]` prefix of a state function.
inline fn state(comptime frame: Frame, comptime next: anytype) void {
    q.setState(fr(frame), q.func(next));
}

pub export fn hknight_shot(offset: f32) void {
    const self = q.me();

    var offang = q.vectoangles(@as(Vector, self.enemy.origin) - self.origin);
    offang[1] = offang[1] + offset * 6;

    q.makevectors(offang);

    const org = @as(Vector, self.origin) + self.mins + q.scale(self.size, 0.5) + q.scale(q.v_forward.get(), 20);

    // set missile speed
    var vec = q.normalize(q.v_forward.get());
    vec[2] = 0 - vec[2] + (q.random() - 0.5) * 0.1;

    weapons.launch_spike(org, vec);
    const newmis = lq.newmis.get();
    newmis.classname = S("knight_spike"); //changed it to be consistant --gnounc
    q.setmodel(newmis, S("progs/k_spike.mdl"));
    q.setsize(newmis, lq.VEC_ORIGIN, lq.VEC_ORIGIN);
    newmis.velocity = q.scale(vec, 300);
    q.sound(self, lq.CHAN_WEAPON, S("hknight/attack1.wav"), 1, lq.ATTN_NORM);
}

pub export fn CheckForCharge() void {
    const self = q.me();
    // check for mad charge
    if (fight.enemy_vis.get() == 0)
        return;

    if (q.time.get() < self.get(lq.attack_finished))
        return;

    if (q.fabs(self.origin[2] - self.enemy.origin[2]) > 20)
        return; // too much height change

    if (q.vlen(@as(Vector, self.origin) - self.enemy.origin) < 80)
        return; // use regular attack

    // charge
    subs.SUB_AttackFinished(2);
    hknight_char_a1();
}

pub export fn CheckContinueCharge() void {
    const self = q.me();
    if (q.time.get() > self.get(lq.attack_finished)) {
        subs.SUB_AttackFinished(3);
        hknight_run1();
        return; // done charging
    }

    if (q.random() > 0.5)
        q.sound(self, lq.CHAN_WEAPON, S("knight/sword2.wav"), 1, lq.ATTN_NORM)
    else
        q.sound(self, lq.CHAN_WEAPON, S("knight/sword1.wav"), 1, lq.ATTN_NORM);
}

pub export fn hknight_stand1() void {
    state(.stand1, hknight_stand2);
    ai.ai_stand();
}

pub export fn hknight_stand2() void {
    state(.stand2, hknight_stand3);
    ai.ai_stand();
}

pub export fn hknight_stand3() void {
    state(.stand3, hknight_stand4);
    ai.ai_stand();
}

pub export fn hknight_stand4() void {
    state(.stand4, hknight_stand5);
    ai.ai_stand();
}

pub export fn hknight_stand5() void {
    state(.stand5, hknight_stand6);
    ai.ai_stand();
}

pub export fn hknight_stand6() void {
    state(.stand6, hknight_stand7);
    ai.ai_stand();
}

pub export fn hknight_stand7() void {
    state(.stand7, hknight_stand8);
    ai.ai_stand();
}

pub export fn hknight_stand8() void {
    state(.stand8, hknight_stand9);
    ai.ai_stand();
}

pub export fn hknight_stand9() void {
    state(.stand9, hknight_stand1);
    ai.ai_stand();
}

pub export fn hknight_walk1() void {
    state(.walk1, hknight_walk2);
    hk_idle_sound();
    ai.ai_walk(2);
}

pub export fn hknight_walk2() void {
    state(.walk2, hknight_walk3);
    ai.ai_walk(5);
}

pub export fn hknight_walk3() void {
    state(.walk3, hknight_walk4);
    ai.ai_walk(5);
}

pub export fn hknight_walk4() void {
    state(.walk4, hknight_walk5);
    ai.ai_walk(4);
}

pub export fn hknight_walk5() void {
    state(.walk5, hknight_walk6);
    ai.ai_walk(4);
}

pub export fn hknight_walk6() void {
    state(.walk6, hknight_walk7);
    ai.ai_walk(2);
}

pub export fn hknight_walk7() void {
    state(.walk7, hknight_walk8);
    ai.ai_walk(2);
}

pub export fn hknight_walk8() void {
    state(.walk8, hknight_walk9);
    ai.ai_walk(3);
}

pub export fn hknight_walk9() void {
    state(.walk9, hknight_walk10);
    ai.ai_walk(3);
}

pub export fn hknight_walk10() void {
    state(.walk10, hknight_walk11);
    ai.ai_walk(4);
}

pub export fn hknight_walk11() void {
    state(.walk11, hknight_walk12);
    ai.ai_walk(3);
}

pub export fn hknight_walk12() void {
    state(.walk12, hknight_walk13);
    ai.ai_walk(4);
}

pub export fn hknight_walk13() void {
    state(.walk13, hknight_walk14);
    ai.ai_walk(6);
}

pub export fn hknight_walk14() void {
    state(.walk14, hknight_walk15);
    ai.ai_walk(2);
}

pub export fn hknight_walk15() void {
    state(.walk15, hknight_walk16);
    ai.ai_walk(2);
}

pub export fn hknight_walk16() void {
    state(.walk16, hknight_walk17);
    ai.ai_walk(4);
}

pub export fn hknight_walk17() void {
    state(.walk17, hknight_walk18);
    ai.ai_walk(3);
}

pub export fn hknight_walk18() void {
    state(.walk18, hknight_walk19);
    ai.ai_walk(3);
}

pub export fn hknight_walk19() void {
    state(.walk19, hknight_walk20);
    ai.ai_walk(3);
}

pub export fn hknight_walk20() void {
    state(.walk20, hknight_walk1);
    ai.ai_walk(2);
}

pub export fn hknight_run1() void {
    state(.run1, hknight_run2);
    hk_idle_sound();
    ai.ai_run(20);
    CheckForCharge();
}

pub export fn hknight_run2() void {
    state(.run2, hknight_run3);
    ai.ai_run(25);
}

pub export fn hknight_run3() void {
    state(.run3, hknight_run4);
    ai.ai_run(18);
}

pub export fn hknight_run4() void {
    state(.run4, hknight_run5);
    ai.ai_run(16);
}

pub export fn hknight_run5() void {
    state(.run5, hknight_run6);
    ai.ai_run(14);
}

pub export fn hknight_run6() void {
    state(.run6, hknight_run7);
    ai.ai_run(25);
}

pub export fn hknight_run7() void {
    state(.run7, hknight_run8);
    ai.ai_run(21);
}

pub export fn hknight_run8() void {
    state(.run8, hknight_run1);
    ai.ai_run(13);
}

pub export fn hknight_pain1() void {
    state(.pain1, hknight_pain2);
    const self = q.me();
    q.sound(self, lq.CHAN_VOICE, S("hknight/pain1.wav"), 1, lq.ATTN_NORM);
}

pub export fn hknight_pain2() void {
    state(.pain2, hknight_pain3);
}

pub export fn hknight_pain3() void {
    state(.pain3, hknight_pain4);
}

pub export fn hknight_pain4() void {
    state(.pain4, hknight_pain5);
}

pub export fn hknight_pain5() void {
    state(.pain5, hknight_run1);
}

pub export fn hknight_die1() void {
    state(.death1, hknight_die2);
    ai.ai_forward(10);
}

pub export fn hknight_die2() void {
    state(.death2, hknight_die3);
    ai.ai_forward(8);
}

pub export fn hknight_die3() void {
    state(.death3, hknight_die4);
    const self = q.me();
    self.solid = lq.SOLID_NOT;
    ai.ai_forward(7);
}

pub export fn hknight_die4() void {
    state(.death4, hknight_die5);
}

pub export fn hknight_die5() void {
    state(.death5, hknight_die6);
}

pub export fn hknight_die6() void {
    state(.death6, hknight_die7);
}

pub export fn hknight_die7() void {
    state(.death7, hknight_die8);
}

pub export fn hknight_die8() void {
    state(.death8, hknight_die9);
    ai.ai_forward(10);
}

pub export fn hknight_die9() void {
    state(.death9, hknight_die10);
    ai.ai_forward(11);
}

pub export fn hknight_die10() void {
    state(.death10, hknight_die11);
}

pub export fn hknight_die11() void {
    state(.death11, hknight_die12);
}

pub export fn hknight_die12() void {
    state(.death12, hknight_die12);
}

pub export fn hknight_dieb1() void {
    state(.deathb1, hknight_dieb2);
}

pub export fn hknight_dieb2() void {
    state(.deathb2, hknight_dieb3);
}

pub export fn hknight_dieb3() void {
    state(.deathb3, hknight_dieb4);
    const self = q.me();
    self.solid = lq.SOLID_NOT;
}

pub export fn hknight_dieb4() void {
    state(.deathb4, hknight_dieb5);
}

pub export fn hknight_dieb5() void {
    state(.deathb5, hknight_dieb6);
}

pub export fn hknight_dieb6() void {
    state(.deathb6, hknight_dieb7);
}

pub export fn hknight_dieb7() void {
    state(.deathb7, hknight_dieb8);
}

pub export fn hknight_dieb8() void {
    state(.deathb8, hknight_dieb9);
}

pub export fn hknight_dieb9() void {
    state(.deathb9, hknight_dieb9);
}

pub export fn hknight_die() void {
    const self = q.me();
    // check for gib
    if (self.health < -40) {
        q.sound(self, lq.CHAN_VOICE, S("player/udeath.wav"), 1, lq.ATTN_NORM);
        player.ThrowHead(S("progs/h_hellkn.mdl"), self.health);
        player.ThrowGib(S("progs/gib1.mdl"), self.health);
        player.ThrowGib(S("progs/gib2.mdl"), self.health);
        player.ThrowGib(S("progs/gib3.mdl"), self.health);

        return;
    }

    // regular death
    q.sound(self, lq.CHAN_VOICE, S("hknight/death1.wav"), 1, lq.ATTN_NORM);

    if (q.random() > 0.5)
        hknight_die1()
    else
        hknight_dieb1();
}

pub export fn hknight_magica1() void {
    state(.magica1, hknight_magica2);
    fight.ai_face();
}

pub export fn hknight_magica2() void {
    state(.magica2, hknight_magica3);
    fight.ai_face();
}

pub export fn hknight_magica3() void {
    state(.magica3, hknight_magica4);
    fight.ai_face();
}

pub export fn hknight_magica4() void {
    state(.magica4, hknight_magica5);
    fight.ai_face();
}

pub export fn hknight_magica5() void {
    state(.magica5, hknight_magica6);
    fight.ai_face();
}

pub export fn hknight_magica6() void {
    state(.magica6, hknight_magica7);
    fight.ai_face();
}

pub export fn hknight_magica7() void {
    state(.magica7, hknight_magica8);
    hknight_shot(-2);
}

pub export fn hknight_magica8() void {
    state(.magica8, hknight_magica9);
    hknight_shot(-1);
}

pub export fn hknight_magica9() void {
    state(.magica9, hknight_magica10);
    hknight_shot(0);
}

pub export fn hknight_magica10() void {
    state(.magica10, hknight_magica11);
    hknight_shot(1);
}

pub export fn hknight_magica11() void {
    state(.magica11, hknight_magica12);
    hknight_shot(2);
}

pub export fn hknight_magica12() void {
    state(.magica12, hknight_magica13);
    hknight_shot(3);
}

pub export fn hknight_magica13() void {
    state(.magica13, hknight_magica14);
    fight.ai_face();
}

pub export fn hknight_magica14() void {
    state(.magica14, hknight_run1);
    fight.ai_face();
}

pub export fn hknight_magicb1() void {
    state(.magicb1, hknight_magicb2);
    fight.ai_face();
}

pub export fn hknight_magicb2() void {
    state(.magicb2, hknight_magicb3);
    fight.ai_face();
}

pub export fn hknight_magicb3() void {
    state(.magicb3, hknight_magicb4);
    fight.ai_face();
}

pub export fn hknight_magicb4() void {
    state(.magicb4, hknight_magicb5);
    fight.ai_face();
}

pub export fn hknight_magicb5() void {
    state(.magicb5, hknight_magicb6);
    fight.ai_face();
}

pub export fn hknight_magicb6() void {
    state(.magicb6, hknight_magicb7);
    fight.ai_face();
}

pub export fn hknight_magicb7() void {
    state(.magicb7, hknight_magicb8);
    hknight_shot(-2);
}

pub export fn hknight_magicb8() void {
    state(.magicb8, hknight_magicb9);
    hknight_shot(-1);
}

pub export fn hknight_magicb9() void {
    state(.magicb9, hknight_magicb10);
    hknight_shot(0);
}

pub export fn hknight_magicb10() void {
    state(.magicb10, hknight_magicb11);
    hknight_shot(1);
}

pub export fn hknight_magicb11() void {
    state(.magicb11, hknight_magicb12);
    hknight_shot(2);
}

pub export fn hknight_magicb12() void {
    state(.magicb12, hknight_magicb13);
    hknight_shot(3);
}

pub export fn hknight_magicb13() void {
    state(.magicb13, hknight_run1);
    fight.ai_face();
}

pub export fn hknight_magicc1() void {
    state(.magicc1, hknight_magicc2);
    fight.ai_face();
}

pub export fn hknight_magicc2() void {
    state(.magicc2, hknight_magicc3);
    fight.ai_face();
}

pub export fn hknight_magicc3() void {
    state(.magicc3, hknight_magicc4);
    fight.ai_face();
}

pub export fn hknight_magicc4() void {
    state(.magicc4, hknight_magicc5);
    fight.ai_face();
}

pub export fn hknight_magicc5() void {
    state(.magicc5, hknight_magicc6);
    fight.ai_face();
}

pub export fn hknight_magicc6() void {
    state(.magicc6, hknight_magicc7);
    hknight_shot(-2);
}

pub export fn hknight_magicc7() void {
    state(.magicc7, hknight_magicc8);
    hknight_shot(-1);
}

pub export fn hknight_magicc8() void {
    state(.magicc8, hknight_magicc9);
    hknight_shot(0);
}

pub export fn hknight_magicc9() void {
    state(.magicc9, hknight_magicc10);
    hknight_shot(1);
}

pub export fn hknight_magicc10() void {
    state(.magicc10, hknight_magicc11);
    hknight_shot(2);
}

pub export fn hknight_magicc11() void {
    state(.magicc11, hknight_run1);
    hknight_shot(3);
}

pub export fn hknight_char_a1() void {
    state(.char_a1, hknight_char_a2);
    fight.ai_charge(20);
}

pub export fn hknight_char_a2() void {
    state(.char_a2, hknight_char_a3);
    fight.ai_charge(25);
}

pub export fn hknight_char_a3() void {
    state(.char_a3, hknight_char_a4);
    fight.ai_charge(18);
}

pub export fn hknight_char_a4() void {
    state(.char_a4, hknight_char_a5);
    fight.ai_charge(16);
}

pub export fn hknight_char_a5() void {
    state(.char_a5, hknight_char_a6);
    fight.ai_charge(14);
}

pub export fn hknight_char_a6() void {
    state(.char_a6, hknight_char_a7);
    fight.ai_charge(20);
    fight.ai_melee();
}

pub export fn hknight_char_a7() void {
    state(.char_a7, hknight_char_a8);
    fight.ai_charge(21);
    fight.ai_melee();
}

pub export fn hknight_char_a8() void {
    state(.char_a8, hknight_char_a9);
    fight.ai_charge(13);
    fight.ai_melee();
}

pub export fn hknight_char_a9() void {
    state(.char_a9, hknight_char_a10);
    fight.ai_charge(20);
    fight.ai_melee();
}

pub export fn hknight_char_a10() void {
    state(.char_a10, hknight_char_a11);
    fight.ai_charge(20);
    fight.ai_melee();
}

pub export fn hknight_char_a11() void {
    state(.char_a11, hknight_char_a12);
    fight.ai_charge(18);
    fight.ai_melee();
}

pub export fn hknight_char_a12() void {
    state(.char_a12, hknight_char_a13);
    fight.ai_charge(16);
}

pub export fn hknight_char_a13() void {
    state(.char_a13, hknight_char_a14);
    fight.ai_charge(14);
}

pub export fn hknight_char_a14() void {
    state(.char_a14, hknight_char_a15);
    fight.ai_charge(25);
}

pub export fn hknight_char_a15() void {
    state(.char_a15, hknight_char_a16);
    fight.ai_charge(21);
}

pub export fn hknight_char_a16() void {
    state(.char_a16, hknight_run1);
    fight.ai_charge(13);
}

pub export fn hknight_char_b1() void {
    state(.char_b1, hknight_char_b2);
    CheckContinueCharge();
    fight.ai_charge(23);
    fight.ai_melee();
}

pub export fn hknight_char_b2() void {
    state(.char_b2, hknight_char_b3);
    fight.ai_charge(17);
    fight.ai_melee();
}

pub export fn hknight_char_b3() void {
    state(.char_b3, hknight_char_b4);
    fight.ai_charge(12);
    fight.ai_melee();
}

pub export fn hknight_char_b4() void {
    state(.char_b4, hknight_char_b5);
    fight.ai_charge(22);
    fight.ai_melee();
}

pub export fn hknight_char_b5() void {
    state(.char_b5, hknight_char_b6);
    fight.ai_charge(18);
    fight.ai_melee();
}

pub export fn hknight_char_b6() void {
    state(.char_b6, hknight_char_b1);
    fight.ai_charge(8);
    fight.ai_melee();
}

pub export fn hknight_slice1() void {
    state(.slice1, hknight_slice2);
    fight.ai_charge(9);
}

pub export fn hknight_slice2() void {
    state(.slice2, hknight_slice3);
    fight.ai_charge(6);
}

pub export fn hknight_slice3() void {
    state(.slice3, hknight_slice4);
    fight.ai_charge(13);
}

pub export fn hknight_slice4() void {
    state(.slice4, hknight_slice5);
    fight.ai_charge(4);
}

pub export fn hknight_slice5() void {
    state(.slice5, hknight_slice6);
    fight.ai_charge(7);
    fight.ai_melee();
}

pub export fn hknight_slice6() void {
    state(.slice6, hknight_slice7);
    fight.ai_charge(15);
    fight.ai_melee();
}

pub export fn hknight_slice7() void {
    state(.slice7, hknight_slice8);
    fight.ai_charge(8);
    fight.ai_melee();
}

pub export fn hknight_slice8() void {
    state(.slice8, hknight_slice9);
    fight.ai_charge(2);
    fight.ai_melee();
}

pub export fn hknight_slice9() void {
    state(.slice9, hknight_slice10);
    fight.ai_melee();
}

pub export fn hknight_slice10() void {
    state(.slice10, hknight_run1);
    fight.ai_charge(3);
}

pub export fn hknight_smash1() void {
    state(.smash1, hknight_smash2);
    fight.ai_charge(1);
}

pub export fn hknight_smash2() void {
    state(.smash2, hknight_smash3);
    fight.ai_charge(13);
}

pub export fn hknight_smash3() void {
    state(.smash3, hknight_smash4);
    fight.ai_charge(9);
}

pub export fn hknight_smash4() void {
    state(.smash4, hknight_smash5);
    fight.ai_charge(11);
}

pub export fn hknight_smash5() void {
    state(.smash5, hknight_smash6);
    fight.ai_charge(10);
    fight.ai_melee();
}

pub export fn hknight_smash6() void {
    state(.smash6, hknight_smash7);
    fight.ai_charge(7);
    fight.ai_melee();
}

pub export fn hknight_smash7() void {
    state(.smash7, hknight_smash8);
    fight.ai_charge(12);
    fight.ai_melee();
}

pub export fn hknight_smash8() void {
    state(.smash8, hknight_smash9);
    fight.ai_charge(2);
    fight.ai_melee();
}

pub export fn hknight_smash9() void {
    state(.smash9, hknight_smash10);
    fight.ai_charge(3);
    fight.ai_melee();
}

pub export fn hknight_smash10() void {
    state(.smash10, hknight_smash11);
    fight.ai_charge(0);
}

pub export fn hknight_smash11() void {
    state(.smash11, hknight_run1);
    fight.ai_charge(0);
}

pub export fn hknight_watk1() void {
    state(.w_attack1, hknight_watk2);
    fight.ai_charge(2);
}

pub export fn hknight_watk2() void {
    state(.w_attack2, hknight_watk3);
    fight.ai_charge(0);
}

pub export fn hknight_watk3() void {
    state(.w_attack3, hknight_watk4);
    fight.ai_charge(0);
}

pub export fn hknight_watk4() void {
    state(.w_attack4, hknight_watk5);
    fight.ai_melee();
}

pub export fn hknight_watk5() void {
    state(.w_attack5, hknight_watk6);
    fight.ai_melee();
}

pub export fn hknight_watk6() void {
    state(.w_attack6, hknight_watk7);
    fight.ai_melee();
}

pub export fn hknight_watk7() void {
    state(.w_attack7, hknight_watk8);
    fight.ai_charge(1);
}

pub export fn hknight_watk8() void {
    state(.w_attack8, hknight_watk9);
    fight.ai_charge(4);
}

pub export fn hknight_watk9() void {
    state(.w_attack9, hknight_watk10);
    fight.ai_charge(5);
}

pub export fn hknight_watk10() void {
    state(.w_attack10, hknight_watk11);
    fight.ai_charge(3);
    fight.ai_melee();
}

pub export fn hknight_watk11() void {
    state(.w_attack11, hknight_watk12);
    fight.ai_charge(2);
    fight.ai_melee();
}

pub export fn hknight_watk12() void {
    state(.w_attack12, hknight_watk13);
    fight.ai_charge(2);
    fight.ai_melee();
}

pub export fn hknight_watk13() void {
    state(.w_attack13, hknight_watk14);
    fight.ai_charge(0);
}

pub export fn hknight_watk14() void {
    state(.w_attack14, hknight_watk15);
    fight.ai_charge(0);
}

pub export fn hknight_watk15() void {
    state(.w_attack15, hknight_watk16);
    fight.ai_charge(0);
}

pub export fn hknight_watk16() void {
    state(.w_attack16, hknight_watk17);
    fight.ai_charge(1);
}

pub export fn hknight_watk17() void {
    state(.w_attack17, hknight_watk18);
    fight.ai_charge(1);
    fight.ai_melee();
}

pub export fn hknight_watk18() void {
    state(.w_attack18, hknight_watk19);
    fight.ai_charge(3);
    fight.ai_melee();
}

pub export fn hknight_watk19() void {
    state(.w_attack19, hknight_watk20);
    fight.ai_charge(4);
    fight.ai_melee();
}

pub export fn hknight_watk20() void {
    state(.w_attack20, hknight_watk21);
    fight.ai_charge(6);
}

pub export fn hknight_watk21() void {
    state(.w_attack21, hknight_watk22);
    fight.ai_charge(7);
}

pub export fn hknight_watk22() void {
    state(.w_attack22, hknight_run1);
    fight.ai_charge(3);
}

pub export fn hk_idle_sound() void {
    const self = q.me();
    if (q.random() < 0.2)
        q.sound(self, lq.CHAN_VOICE, S("hknight/idle.wav"), 1, lq.ATTN_NORM);
}

pub export fn hknight_pain(attacker: Entity, damage: f32) void {
    _ = attacker;
    const self = q.me();
    if (self.get(lq.pain_finished) > q.time.get())
        return;

    q.sound(self, lq.CHAN_VOICE, S("hknight/pain1.wav"), 1, lq.ATTN_NORM);

    if (q.time.get() - self.get(lq.pain_finished) > 5) { // always go into pain frame if it has been a while
        hknight_pain1();
        self.set(lq.pain_finished, q.time.get() + 1);

        return;
    }

    if ((q.random() * 30 > damage))
        return; // didn't flinch

    self.set(lq.pain_finished, q.time.get() + 1);
    hknight_pain1();
}

pub const hknight_type = q.userGlobal(f32, "hknight_type");

pub export fn hknight_melee() void {
    const self = q.me();
    hknight_type.set(hknight_type.get() + 1);

    q.sound(self, lq.CHAN_WEAPON, S("hknight/slash1.wav"), 1, lq.ATTN_NORM);
    if (hknight_type.get() == 1)
        hknight_slice1()
    else if (hknight_type.get() == 2)
        hknight_smash1()
    else if (hknight_type.get() == 3) {
        hknight_watk1();
        hknight_type.set(0);
    }
}

/// QUAKED monster_hell_knight (1 0 0) (-16 -16 -24) (16 16 40) Ambush
/// {
///     model({"path": "progs/hknight.mdl", "skin": 0, "frame": 0});
/// }
pub export fn monster_hell_knight() void {
    const self = q.me();
    if (q.deathmatch.get() != 0) {
        q.remove(self);
        return;
    }

    _ = q.precache_model2(S("progs/hknight.mdl"));
    _ = q.precache_model2(S("progs/k_spike.mdl"));
    _ = q.precache_model2(S("progs/h_hellkn.mdl"));

    _ = q.precache_sound2(S("hknight/attack1.wav"));
    _ = q.precache_sound2(S("hknight/death1.wav"));
    _ = q.precache_sound2(S("hknight/pain1.wav"));
    _ = q.precache_sound2(S("hknight/sight1.wav"));
    _ = q.precache_sound(S("hknight/hit.wav")); // used by C code, so don't sound2
    _ = q.precache_sound2(S("hknight/slash1.wav"));
    _ = q.precache_sound2(S("hknight/idle.wav"));
    _ = q.precache_sound2(S("hknight/grunt.wav"));

    _ = q.precache_sound(S("knight/sword1.wav"));
    _ = q.precache_sound(S("knight/sword2.wav"));

    self.solid = lq.SOLID_SLIDEBOX;
    self.movetype = lq.MOVETYPE_STEP;

    q.setmodel(self, S("progs/hknight.mdl"));

    //gnounc
    self.noise = S("hknight/sight1.wav"); //gnounc
    self.netname = S("Hell Knight");
    self.set(lq.killstring, S(loc.LOC_DEATH_HELL_KNIGHT));

    q.setsize(self, q.vec(-16, -16, -24), q.vec(16, 16, 40));
    self.health = 250;
    self.max_health = 250;

    self.set(lq.th_stand, q.func(hknight_stand1));
    self.set(lq.th_walk, q.func(hknight_walk1));
    self.set(lq.th_run, q.func(hknight_run1));
    self.set(lq.th_melee, q.func(hknight_melee));
    self.set(lq.th_missile, q.func(hknight_magicc1));
    self.set(lq.th_pain, q.func(hknight_pain));
    self.set(lq.th_die, q.func(hknight_die));

    monsters.walkmonster_start();
}
