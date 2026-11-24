//! monsters/fiend.qc

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
const combat = @import("../combat.zig");
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
    stand10,
    stand11,
    stand12,
    stand13,
    walk1,
    walk2,
    walk3,
    walk4,
    walk5,
    walk6,
    walk7,
    walk8,
    run1,
    run2,
    run3,
    run4,
    run5,
    run6,
    leap1,
    leap2,
    leap3,
    leap4,
    leap5,
    leap6,
    leap7,
    leap8,
    leap9,
    leap10,
    leap11,
    leap12,
    pain1,
    pain2,
    pain3,
    pain4,
    pain5,
    pain6,
    death1,
    death2,
    death3,
    death4,
    death5,
    death6,
    death7,
    death8,
    death9,
    attacka1,
    attacka2,
    attacka3,
    attacka4,
    attacka5,
    attacka6,
    attacka7,
    attacka8,
    attacka9,
    attacka10,
    attacka11,
    attacka12,
    attacka13,
    attacka14,
    attacka15,
};

/// `$frame`, as a float.
inline fn fr(comptime frame: Frame) f32 {
    return @floatFromInt(@backingInt(frame));
}

/// The `[$frame, next]` prefix of a state function.
inline fn state(comptime frame: Frame, comptime next: anytype) void {
    q.setState(fr(frame), q.func(next));
}

pub export fn demon1_stand1() void {
    state(.stand1, demon1_stand2);
    ai.ai_stand();
}

pub export fn demon1_stand2() void {
    state(.stand2, demon1_stand3);
    ai.ai_stand();
}

pub export fn demon1_stand3() void {
    state(.stand3, demon1_stand4);
    ai.ai_stand();
}

pub export fn demon1_stand4() void {
    state(.stand4, demon1_stand5);
    ai.ai_stand();
}

pub export fn demon1_stand5() void {
    state(.stand5, demon1_stand6);
    ai.ai_stand();
}

pub export fn demon1_stand6() void {
    state(.stand6, demon1_stand7);
    ai.ai_stand();
}

pub export fn demon1_stand7() void {
    state(.stand7, demon1_stand8);
    ai.ai_stand();
}

pub export fn demon1_stand8() void {
    state(.stand8, demon1_stand9);
    ai.ai_stand();
}

pub export fn demon1_stand9() void {
    state(.stand9, demon1_stand10);
    ai.ai_stand();
}

pub export fn demon1_stand10() void {
    state(.stand10, demon1_stand11);
    ai.ai_stand();
}

pub export fn demon1_stand11() void {
    state(.stand11, demon1_stand12);
    ai.ai_stand();
}

pub export fn demon1_stand12() void {
    state(.stand12, demon1_stand13);
    ai.ai_stand();
}

pub export fn demon1_stand13() void {
    state(.stand13, demon1_stand1);
    ai.ai_stand();
}

pub export fn demon1_walk1() void {
    state(.walk1, demon1_walk2);
    if (q.random() < 0.2)
        q.sound(q.me(), lq.CHAN_VOICE, S("demon/idle1.wav"), 1, lq.ATTN_IDLE);
    ai.ai_walk(8);
}

pub export fn demon1_walk2() void {
    state(.walk2, demon1_walk3);
    ai.ai_walk(6);
}

pub export fn demon1_walk3() void {
    state(.walk3, demon1_walk4);
    ai.ai_walk(6);
}

pub export fn demon1_walk4() void {
    state(.walk4, demon1_walk5);
    ai.ai_walk(7);
}

pub export fn demon1_walk5() void {
    state(.walk5, demon1_walk6);
    ai.ai_walk(4);
}

pub export fn demon1_walk6() void {
    state(.walk6, demon1_walk7);
    ai.ai_walk(6);
}

pub export fn demon1_walk7() void {
    state(.walk7, demon1_walk8);
    ai.ai_walk(10);
}

pub export fn demon1_walk8() void {
    state(.walk8, demon1_walk1);
    ai.ai_walk(10);
}

pub export fn demon1_run1() void {
    state(.run1, demon1_run2);
    if (q.random() < 0.2)
        q.sound(q.me(), lq.CHAN_VOICE, S("demon/idle1.wav"), 1, lq.ATTN_IDLE);
    ai.ai_run(20);
}

pub export fn demon1_run2() void {
    state(.run2, demon1_run3);
    ai.ai_run(15);
}

pub export fn demon1_run3() void {
    state(.run3, demon1_run4);
    ai.ai_run(36);
}

pub export fn demon1_run4() void {
    state(.run4, demon1_run5);
    ai.ai_run(20);
}

pub export fn demon1_run5() void {
    state(.run5, demon1_run6);
    ai.ai_run(15);
}

pub export fn demon1_run6() void {
    state(.run6, demon1_run1);
    ai.ai_run(36);
}

pub export fn demon1_jump1() void {
    state(.leap1, demon1_jump2);
    fight.ai_face();
}

pub export fn demon1_jump2() void {
    state(.leap2, demon1_jump3);
    fight.ai_face();
}

pub export fn demon1_jump3() void {
    state(.leap3, demon1_jump4);
    fight.ai_face();
}

pub export fn demon1_jump4() void {
    state(.leap4, demon1_jump5);
    const self = q.me();
    fight.ai_face();

    self.touch = q.func(Demon_JumpTouch);
    subs.makevectors2(self.angles);
    self.origin[2] = self.origin[2] + 1;
    self.velocity = q.scale(q.v_forward.get(), 600) + q.vec(0, 0, 250);

    if (q.has(self.flags, lq.FL_ONGROUND))
        self.flags = self.flags - lq.FL_ONGROUND;
}

pub export fn demon1_jump5() void {
    state(.leap5, demon1_jump6);
}

pub export fn demon1_jump6() void {
    state(.leap6, demon1_jump7);
}

pub export fn demon1_jump7() void {
    state(.leap7, demon1_jump8);
}

pub export fn demon1_jump8() void {
    state(.leap8, demon1_jump9);
}

pub export fn demon1_jump9() void {
    state(.leap9, demon1_jump10);
}

pub export fn demon1_jump10() void {
    state(.leap10, demon1_jump1);
    q.me().nextthink = q.time.get() + 3; // if three seconds pass, assume demon is stuck and jump again
}

pub export fn demon1_jump11() void {
    state(.leap11, demon1_jump12);
}

pub export fn demon1_jump12() void {
    state(.leap12, demon1_run1);
}

pub export fn demon1_atta1() void {
    state(.attacka1, demon1_atta2);
    fight.ai_charge(4);
}

pub export fn demon1_atta2() void {
    state(.attacka2, demon1_atta3);
    fight.ai_charge(0);
}

pub export fn demon1_atta3() void {
    state(.attacka3, demon1_atta4);
    fight.ai_charge(0);
}

pub export fn demon1_atta4() void {
    state(.attacka4, demon1_atta5);
    fight.ai_charge(1);
}

pub export fn demon1_atta5() void {
    state(.attacka5, demon1_atta6);
    fight.ai_charge(2);
    Demon_Melee(200);
}

pub export fn demon1_atta6() void {
    state(.attacka6, demon1_atta7);
    fight.ai_charge(1);
}

pub export fn demon1_atta7() void {
    state(.attacka7, demon1_atta8);
    fight.ai_charge(6);
}

pub export fn demon1_atta8() void {
    state(.attacka8, demon1_atta9);
    fight.ai_charge(8);
}

pub export fn demon1_atta9() void {
    state(.attacka9, demon1_atta10);
    fight.ai_charge(4);
}

pub export fn demon1_atta10() void {
    state(.attacka10, demon1_atta11);
    fight.ai_charge(2);
}

pub export fn demon1_atta11() void {
    state(.attacka11, demon1_atta12);
    Demon_Melee(-200);
}

pub export fn demon1_atta12() void {
    state(.attacka12, demon1_atta13);
    fight.ai_charge(5);
}

pub export fn demon1_atta13() void {
    state(.attacka13, demon1_atta14);
    fight.ai_charge(8);
}

pub export fn demon1_atta14() void {
    state(.attacka14, demon1_atta15);
    fight.ai_charge(4);
}

pub export fn demon1_atta15() void {
    state(.attacka15, demon1_run1);
    fight.ai_charge(4);
}

pub export fn demon1_pain1() void {
    state(.pain1, demon1_pain2);
}

pub export fn demon1_pain2() void {
    state(.pain2, demon1_pain3);
}

pub export fn demon1_pain3() void {
    state(.pain3, demon1_pain4);
}

pub export fn demon1_pain4() void {
    state(.pain4, demon1_pain5);
}

pub export fn demon1_pain5() void {
    state(.pain5, demon1_pain6);
}

pub export fn demon1_pain6() void {
    state(.pain6, demon1_run1);
}

pub export fn demon1_pain(attacker: Entity, damage: f32) void {
    _ = attacker;
    const self = q.me();
    if (q.fnEql(self.touch, q.func(Demon_JumpTouch)))
        return;

    if (self.get(lq.pain_finished) > q.time.get())
        return;

    self.set(lq.pain_finished, q.time.get() + 1);
    q.sound(self, lq.CHAN_VOICE, S("demon/dpain1.wav"), 1, lq.ATTN_NORM);

    if (q.random() * 200 > damage)
        return; // didn't flinch

    demon1_pain1();
}

pub export fn demon1_die1() void {
    state(.death1, demon1_die2);
    q.sound(q.me(), lq.CHAN_VOICE, S("demon/ddeath.wav"), 1, lq.ATTN_NORM);
}

pub export fn demon1_die2() void {
    state(.death2, demon1_die3);
}

pub export fn demon1_die3() void {
    state(.death3, demon1_die4);
}

pub export fn demon1_die4() void {
    state(.death4, demon1_die5);
}

pub export fn demon1_die5() void {
    state(.death5, demon1_die6);
}

pub export fn demon1_die6() void {
    state(.death6, demon1_die7);
    q.me().solid = lq.SOLID_NOT;
}

pub export fn demon1_die7() void {
    state(.death7, demon1_die8);
}

pub export fn demon1_die8() void {
    state(.death8, demon1_die9);
}

pub export fn demon1_die9() void {
    state(.death9, demon1_die9);
}

pub export fn demon_die() void {
    const self = q.me();
    // check for gib
    if (self.health < -80) {
        q.sound(self, lq.CHAN_VOICE, S("player/udeath.wav"), 1, lq.ATTN_NORM);
        player.ThrowHead(S("progs/h_demon.mdl"), self.health);
        player.ThrowGib(S("progs/gib1.mdl"), self.health);
        player.ThrowGib(S("progs/gib1.mdl"), self.health);
        player.ThrowGib(S("progs/gib1.mdl"), self.health);

        return;
    }

    // regular death
    demon1_die1();
}

pub export fn Demon_MeleeAttack() void {
    demon1_atta1();
}

/// QUAKED monster_demon1 (1 0 0) (-32 -32 -24) (32 32 64) Ambush
/// {
///     model({"path": "progs/demon.mdl", "skin": 0, "frame": 0});
/// }
pub export fn monster_demon1() void {
    const self = q.me();
    if (q.deathmatch.get() != 0) {
        q.remove(self);
        return;
    }
    _ = q.precache_model(S("progs/demon.mdl"));
    _ = q.precache_model(S("progs/h_demon.mdl"));

    _ = q.precache_sound(S("demon/ddeath.wav"));
    _ = q.precache_sound(S("demon/dhit2.wav"));
    _ = q.precache_sound(S("demon/djump.wav"));
    _ = q.precache_sound(S("demon/dpain1.wav"));
    _ = q.precache_sound(S("demon/idle1.wav"));
    _ = q.precache_sound(S("demon/sight2.wav"));

    self.solid = lq.SOLID_SLIDEBOX;
    self.movetype = lq.MOVETYPE_STEP;

    //gnounc
    q.setmodel(self, S("progs/demon.mdl"));
    self.noise = S("demon/sight2.wav");
    self.set(lq.killstring, S(loc.LOC_DEATH_DEMON1));

    q.setsize(self, lq.VEC_HULL2_MIN, lq.VEC_HULL2_MAX);
    self.health = 300;
    self.max_health = 300;

    self.set(lq.th_stand, q.func(demon1_stand1));
    self.set(lq.th_walk, q.func(demon1_walk1));
    self.set(lq.th_run, q.func(demon1_run1));
    self.set(lq.th_die, q.func(demon_die));
    self.set(lq.th_melee, q.func(Demon_MeleeAttack)); // one of two attacks
    self.set(lq.th_missile, q.func(demon1_jump1)); // jump attack
    self.set(lq.th_pain, q.func(demon1_pain));

    monsters.walkmonster_start();
}

/// CheckDemonMelee
///
/// Returns TRUE if a melee attack would hit right now
pub export fn CheckDemonMelee() f32 {
    if (fight.enemy_range.get() == lq.RANGE_MELEE) { // FIXME: check canreach
        q.me().set(lq.attack_state, lq.AS_MELEE);

        return lq.TRUE;
    }

    return lq.FALSE;
}

/// CheckDemonJump
pub export fn CheckDemonJump() f32 {
    const self = q.me();

    if (self.origin[2] + self.mins[2] > self.enemy.origin[2] + self.enemy.mins[2] + 0.75 * self.enemy.size[2])
        return lq.FALSE;

    if (self.origin[2] + self.maxs[2] < self.enemy.origin[2] + self.enemy.mins[2] + 0.25 * self.enemy.size[2])
        return lq.FALSE;

    var dist = @as(Vector, self.enemy.origin) - self.origin;
    dist[2] = 0;

    const d = q.vlen(dist);

    if (d < 100)
        return lq.FALSE;

    if (d > 200) {
        if (q.random() < 0.9)
            return lq.FALSE;
    }

    return lq.TRUE;
}

pub export fn DemonCheckAttack() f32 {
    const self = q.me();
    // if close enough for slashing, go for it
    if (CheckDemonMelee() != 0) {
        self.set(lq.attack_state, lq.AS_MELEE);
        return lq.TRUE;
    }

    if (CheckDemonJump() != 0) {
        self.set(lq.attack_state, lq.AS_MISSILE);
        q.sound(self, lq.CHAN_VOICE, S("demon/djump.wav"), 1, lq.ATTN_NORM);

        return lq.TRUE;
    }

    return lq.FALSE;
}

pub export fn Demon_Melee(side: f32) void {
    const self = q.me();

    fight.ai_face();
    _ = q.walkmove(self.ideal_yaw, 12); // allow a little closing

    const delta = @as(Vector, self.enemy.origin) - self.origin;

    if (q.vlen(delta) > 100)
        return;

    if (combat.CanDamage(self.enemy, self) == 0)
        return;

    q.sound(self, lq.CHAN_WEAPON, S("demon/dhit2.wav"), 1, lq.ATTN_NORM);
    const ldmg = 10 + 5 * q.random();
    combat.T_Damage(self.enemy, self, self, ldmg);

    subs.makevectors2(self.angles);
    weapons.SpawnMeatSpray(@as(Vector, self.origin) + q.scale(q.v_forward.get(), 16), q.scale(q.v_right.get(), side));
}

pub export fn Demon_JumpTouch() void {
    const self = q.me();
    const other = q.other.get();

    if (self.health <= 0)
        return;

    if (other.takedamage != 0) {
        if (q.vlen(self.velocity) > 400) {
            // The fiend can't deal leap damage to the player immediately after already doing do.
            // Solves some weird hit-detection issues where the fiend could insta-kill players or deal multiple hits at once.
            if (self.get(lq.count) < q.time.get()) {
                const ldmg = 40 + 10 * q.random();
                combat.T_Damage(other, self, self, ldmg);
            }
            self.set(lq.count, q.time.get() + 0.3);
        }
    }

    if (q.checkbottom(self) == 0) {
        if (q.has(self.flags, lq.FL_ONGROUND)) { // jump randomly to not get hung up
            self.touch = null;
            self.think = q.func(demon1_jump1);
            self.nextthink = q.time.get() + 0.1;
        }

        return; // not on ground yet
    }

    self.touch = null;
    self.think = q.func(demon1_jump11);
    self.nextthink = q.time.get() + 0.1;
}
