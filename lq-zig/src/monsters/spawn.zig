//! monsters/spawn.qc

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
const combat = @import("../combat.zig");
const ai = @import("../ai.zig");
const fight = @import("../fight.zig");

/// The `$frame` macros, numbered from 0 in declaration order.
const Frame = enum(u8) {
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
    run19,
    run20,
    run21,
    run22,
    run23,
    run24,
    run25,
    jump1,
    jump2,
    jump3,
    jump4,
    jump5,
    jump6,
    fly1,
    fly2,
    fly3,
    fly4,
    exp,
};

/// `$frame`, as a float.
inline fn fr(comptime frame: Frame) f32 {
    return @floatFromInt(@backingInt(frame));
}

/// The `[$frame, next]` prefix of a state function.
inline fn state(comptime frame: Frame, comptime next: anytype) void {
    q.setState(fr(frame), q.func(next));
}

pub export fn tbaby_stand1() void {
    state(.walk1, tbaby_stand1);
    ai.ai_stand();
}

pub export fn tbaby_hang1() void {
    state(.walk1, tbaby_hang1);
    ai.ai_stand();
}

pub export fn tbaby_walk1() void {
    state(.walk1, tbaby_walk2);
    ai.ai_turn();
}

pub export fn tbaby_walk2() void {
    state(.walk2, tbaby_walk3);
    ai.ai_turn();
}

pub export fn tbaby_walk3() void {
    state(.walk3, tbaby_walk4);
    ai.ai_turn();
}

pub export fn tbaby_walk4() void {
    state(.walk4, tbaby_walk5);
    ai.ai_turn();
}

pub export fn tbaby_walk5() void {
    state(.walk5, tbaby_walk6);
    ai.ai_turn();
}

pub export fn tbaby_walk6() void {
    state(.walk6, tbaby_walk7);
    ai.ai_turn();
}

pub export fn tbaby_walk7() void {
    state(.walk7, tbaby_walk8);
    ai.ai_turn();
}

pub export fn tbaby_walk8() void {
    state(.walk8, tbaby_walk9);
    ai.ai_turn();
}

pub export fn tbaby_walk9() void {
    state(.walk9, tbaby_walk10);
    ai.ai_turn();
}

pub export fn tbaby_walk10() void {
    state(.walk10, tbaby_walk11);
    ai.ai_turn();
}

pub export fn tbaby_walk11() void {
    state(.walk11, tbaby_walk12);
    ai.ai_walk(2);
}

pub export fn tbaby_walk12() void {
    state(.walk12, tbaby_walk13);
    ai.ai_walk(2);
}

pub export fn tbaby_walk13() void {
    state(.walk13, tbaby_walk14);
    ai.ai_walk(2);
}

pub export fn tbaby_walk14() void {
    state(.walk14, tbaby_walk15);
    ai.ai_walk(2);
}

pub export fn tbaby_walk15() void {
    state(.walk15, tbaby_walk16);
    ai.ai_walk(2);
}

pub export fn tbaby_walk16() void {
    state(.walk16, tbaby_walk17);
    ai.ai_walk(2);
}

pub export fn tbaby_walk17() void {
    state(.walk17, tbaby_walk18);
    ai.ai_walk(2);
}

pub export fn tbaby_walk18() void {
    state(.walk18, tbaby_walk19);
    ai.ai_walk(2);
}

pub export fn tbaby_walk19() void {
    state(.walk19, tbaby_walk20);
    ai.ai_walk(2);
}

pub export fn tbaby_walk20() void {
    state(.walk20, tbaby_walk21);
    ai.ai_walk(2);
}

pub export fn tbaby_walk21() void {
    state(.walk21, tbaby_walk22);
    ai.ai_walk(2);
}

pub export fn tbaby_walk22() void {
    state(.walk22, tbaby_walk23);
    ai.ai_walk(2);
}

pub export fn tbaby_walk23() void {
    state(.walk23, tbaby_walk24);
    ai.ai_walk(2);
}

pub export fn tbaby_walk24() void {
    state(.walk24, tbaby_walk25);
    ai.ai_walk(2);
}

pub export fn tbaby_walk25() void {
    state(.walk25, tbaby_walk1);
    ai.ai_walk(2);
}

pub export fn tbaby_run1() void {
    state(.run1, tbaby_run2);
    fight.ai_face();
}

pub export fn tbaby_run2() void {
    state(.run2, tbaby_run3);
    fight.ai_face();
}

pub export fn tbaby_run3() void {
    state(.run3, tbaby_run4);
    fight.ai_face();
}

pub export fn tbaby_run4() void {
    state(.run4, tbaby_run5);
    fight.ai_face();
}

pub export fn tbaby_run5() void {
    state(.run5, tbaby_run6);
    fight.ai_face();
}

pub export fn tbaby_run6() void {
    state(.run6, tbaby_run7);
    fight.ai_face();
}

pub export fn tbaby_run7() void {
    state(.run7, tbaby_run8);
    fight.ai_face();
}

pub export fn tbaby_run8() void {
    state(.run8, tbaby_run9);
    fight.ai_face();
}

pub export fn tbaby_run9() void {
    state(.run9, tbaby_run10);
    fight.ai_face();
}

pub export fn tbaby_run10() void {
    state(.run10, tbaby_run11);
    fight.ai_face();
}

pub export fn tbaby_run11() void {
    state(.run11, tbaby_run12);
    ai.ai_run(2);
}

pub export fn tbaby_run12() void {
    state(.run12, tbaby_run13);
    ai.ai_run(2);
}

pub export fn tbaby_run13() void {
    state(.run13, tbaby_run14);
    ai.ai_run(2);
}

pub export fn tbaby_run14() void {
    state(.run14, tbaby_run15);
    ai.ai_run(2);
}

pub export fn tbaby_run15() void {
    state(.run15, tbaby_run16);
    ai.ai_run(2);
}

pub export fn tbaby_run16() void {
    state(.run16, tbaby_run17);
    ai.ai_run(2);
}

pub export fn tbaby_run17() void {
    state(.run17, tbaby_run18);
    ai.ai_run(2);
}

pub export fn tbaby_run18() void {
    state(.run18, tbaby_run19);
    ai.ai_run(2);
}

pub export fn tbaby_run19() void {
    state(.run19, tbaby_run20);
    ai.ai_run(2);
}

pub export fn tbaby_run20() void {
    state(.run20, tbaby_run21);
    ai.ai_run(2);
}

pub export fn tbaby_run21() void {
    state(.run21, tbaby_run22);
    ai.ai_run(2);
}

pub export fn tbaby_run22() void {
    state(.run22, tbaby_run23);
    ai.ai_run(2);
}

pub export fn tbaby_run23() void {
    state(.run23, tbaby_run24);
    ai.ai_run(2);
}

pub export fn tbaby_run24() void {
    state(.run24, tbaby_run25);
    ai.ai_run(2);
}

pub export fn tbaby_run25() void {
    state(.run25, tbaby_run1);
    ai.ai_run(2);
}

pub export fn Tar_JumpTouch() void {
    const self = q.me();
    const other = q.other.get();

    if (other.takedamage != 0 and other.classname.neq(self.classname)) {
        if (q.vlen(self.velocity) > 400) {
            // The spawn can't deal leap damage to the player immediately after already doing do.
            // Solves some weird hit-detection issues where the spawn could insta-kill players or deal multiple hits at once.
            if (self.get(lq.count) < q.time.get()) {
                const ldmg = 10 + 10 * q.random();
                combat.T_Damage(other, self, self, ldmg);
                q.sound(self, lq.CHAN_WEAPON, S("blob/hit1.wav"), 1, lq.ATTN_NORM);
            }
            self.set(lq.count, q.time.get() + 0.3);
        }
    } else q.sound(self, lq.CHAN_WEAPON, S("blob/land1.wav"), 1, lq.ATTN_NORM);

    if (q.checkbottom(self) == 0) {
        if (q.has(self.flags, lq.FL_ONGROUND)) { // jump randomly to not get hung up
            self.touch = null;
            self.think = q.func(tbaby_run1);
            self.movetype = lq.MOVETYPE_STEP;
            self.nextthink = q.time.get() + 0.1;
        }

        return; // not on ground yet
    }

    self.touch = null;
    self.think = q.func(tbaby_jump1);
    self.nextthink = q.time.get() + 0.1;
}

pub export fn tbaby_fly1() void {
    state(.fly1, tbaby_fly2);
}

pub export fn tbaby_fly2() void {
    state(.fly2, tbaby_fly3);
}

pub export fn tbaby_fly3() void {
    state(.fly3, tbaby_fly4);
}

pub export fn tbaby_fly4() void {
    state(.fly4, tbaby_fly1);
    const self = q.me();
    self.set(lq.cnt, self.get(lq.cnt) + 1);

    if (self.get(lq.cnt) == 4) {
        tbaby_jump5();
    }
}

pub export fn tbaby_jump1() void {
    state(.jump1, tbaby_jump2);
    fight.ai_face();
}

pub export fn tbaby_jump2() void {
    state(.jump2, tbaby_jump3);
    fight.ai_face();
}

pub export fn tbaby_jump3() void {
    state(.jump3, tbaby_jump4);
    fight.ai_face();
}

pub export fn tbaby_jump4() void {
    state(.jump4, tbaby_jump5);
    fight.ai_face();
}

pub export fn tbaby_jump5() void {
    state(.jump5, tbaby_jump6);
    const self = q.me();
    self.movetype = lq.MOVETYPE_BOUNCE;
    self.touch = q.func(Tar_JumpTouch);
    subs.makevectors2(self.angles);
    self.origin[2] = self.origin[2] + 1;
    self.velocity = q.scale(q.v_forward.get(), 600) + q.vec(0, 0, 200);
    self.velocity[2] = self.velocity[2] + q.random() * 150;

    if (q.has(self.flags, lq.FL_ONGROUND))
        self.flags = self.flags - lq.FL_ONGROUND;

    self.set(lq.cnt, 0);
}

pub export fn tbaby_jump6() void {
    state(.jump6, tbaby_fly1);
}

pub export fn tbaby_die1() void {
    state(.exp, tbaby_die2);
    const self = q.me();
    self.takedamage = lq.DAMAGE_NO;
}

pub export fn tbaby_die2() void {
    state(.exp, tbaby_run1);
    const self = q.me();
    combat.T_RadiusDamage(self, self, 120, q.world.get(), S(""));

    q.sound(self, lq.CHAN_VOICE, S("blob/death1.wav"), 1, lq.ATTN_NORM);
    self.origin = @as(Vector, self.origin) - q.scale(q.normalize(self.velocity), 8);

    q.WriteByte(lq.MSG_BROADCAST, lq.SVC_TEMPENTITY);
    q.WriteByte(lq.MSG_BROADCAST, lq.TE_TAREXPLOSION);
    q.WriteCoord(lq.MSG_BROADCAST, self.origin[0]);
    q.WriteCoord(lq.MSG_BROADCAST, self.origin[1]);
    q.WriteCoord(lq.MSG_BROADCAST, self.origin[2]);

    weapons.BecomeExplosion();
}

/// QUAKED monster_tarbaby (1 0 0) (-16 -16 -24) (16 16 24) Ambush
/// {
///     model({"path": "progs/tarbaby.mdl", "skin": 0, "frame": 0});
/// }
pub export fn monster_tarbaby() void {
    const self = q.me();
    if (q.deathmatch.get() != 0) {
        q.remove(self);
        return;
    }

    _ = q.precache_model2(S("progs/tarbaby.mdl"));

    _ = q.precache_sound2(S("blob/death1.wav"));
    _ = q.precache_sound2(S("blob/hit1.wav"));
    _ = q.precache_sound2(S("blob/land1.wav"));
    _ = q.precache_sound2(S("blob/sight1.wav"));

    self.solid = lq.SOLID_SLIDEBOX;
    self.movetype = lq.MOVETYPE_STEP;

    q.setmodel(self, S("progs/tarbaby.mdl"));

    //gnounc
    self.noise = S("blob/sight1.wav"); //gnounc
    self.netname = S("Spawn");
    self.set(lq.killstring, S(loc.LOC_DEATH_TARBABY));

    q.setsize(self, q.vec(-16, -16, -24), q.vec(16, 16, 40));
    self.health = 80;
    self.max_health = 80;

    self.set(lq.th_stand, q.func(tbaby_stand1));
    self.set(lq.th_walk, q.func(tbaby_walk1));
    self.set(lq.th_run, q.func(tbaby_run1));
    self.set(lq.th_missile, q.func(tbaby_jump1));
    self.set(lq.th_melee, q.func(tbaby_jump1));
    self.set(lq.th_die, q.func(tbaby_die1));

    monsters.walkmonster_start();
}
