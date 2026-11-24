//! monsters/rottweiler.qc

const q = @import("../defs.zig");
const lq = @import("../lq.zig");
const loc = @import("../localized_text.zig");
const S = q.S;
const Entity = q.Entity;
const Function = q.Function;
const String = q.String;
const Vector = q.Vector;
const monsters = @import("../monsters.zig");
const combat = @import("../combat.zig");
const subs = @import("../subs.zig");
const player = @import("../player.zig");
const ai = @import("../ai.zig");
const fight = @import("../fight.zig");

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
    death1,
    death2,
    death3,
    death4,
    death5,
    death6,
    death7,
    death8,
    death9,
    deathb1,
    deathb2,
    deathb3,
    deathb4,
    deathb5,
    deathb6,
    deathb7,
    deathb8,
    deathb9,
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
    painb15,
    painb16,
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
    leap1,
    leap2,
    leap3,
    leap4,
    leap5,
    leap6,
    leap7,
    leap8,
    leap9,
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
};

/// `$frame`, as a float.
inline fn fr(comptime frame: Frame) f32 {
    return @floatFromInt(@backingInt(frame));
}

/// The `[$frame, next]` prefix of a state function.
inline fn state(comptime frame: Frame, comptime next: anytype) void {
    q.setState(fr(frame), q.func(next));
}

/// dog_bite
pub export fn dog_bite() void {
    const self = q.me();

    if (self.enemy.isNull())
        return;

    fight.ai_charge(10);

    if (combat.CanDamage(self.enemy, self) == 0)
        return;

    const delta = @as(Vector, self.enemy.origin) - self.origin;

    if (q.vlen(delta) > 100)
        return;

    const ldmg = (q.random() + q.random() + q.random()) * 8;
    combat.T_Damage(self.enemy, self, self, ldmg);
}

pub export fn Dog_JumpTouch() void {
    const self = q.me();
    const other = q.other.get();

    if (self.health <= 0)
        return;

    if (other.takedamage != 0) {
        if (q.vlen(self.velocity) > 300) {
            // The dog can't deal leap damage to the player immediately after already doing do.
            // Solves some weird hit-detection issues where the dog could insta-kill players or deal multiple hits at once.
            if (self.get(lq.count) < q.time.get()) {
                const ldmg = 10 + 10 * q.random();
                combat.T_Damage(other, self, self, ldmg);
            }
            self.set(lq.count, q.time.get() + 0.3);
        }
    }

    if (q.checkbottom(self) == 0) {
        if (q.has(self.flags, lq.FL_ONGROUND)) { // jump randomly to not get hung up
            self.touch = null;
            self.think = q.func(dog_leap1);
            self.nextthink = q.time.get() + 0.1;
        }

        return; // not on ground yet
    }

    self.touch = null;
    self.think = q.func(dog_run1);
    self.nextthink = q.time.get() + 0.1;
}

pub export fn dog_stand1() void {
    state(.stand1, dog_stand2);
    ai.ai_stand();
}

pub export fn dog_stand2() void {
    state(.stand2, dog_stand3);
    ai.ai_stand();
}

pub export fn dog_stand3() void {
    state(.stand3, dog_stand4);
    ai.ai_stand();
}

pub export fn dog_stand4() void {
    state(.stand4, dog_stand5);
    ai.ai_stand();
}

pub export fn dog_stand5() void {
    state(.stand5, dog_stand6);
    ai.ai_stand();
}

pub export fn dog_stand6() void {
    state(.stand6, dog_stand7);
    ai.ai_stand();
}

pub export fn dog_stand7() void {
    state(.stand7, dog_stand8);
    ai.ai_stand();
}

pub export fn dog_stand8() void {
    state(.stand8, dog_stand9);
    ai.ai_stand();
}

pub export fn dog_stand9() void {
    state(.stand9, dog_stand1);
    ai.ai_stand();
}

pub export fn dog_walk1() void {
    state(.walk1, dog_walk2);
    if (q.random() < 0.2)
        q.sound(q.me(), lq.CHAN_VOICE, S("dog/idle.wav"), 1, lq.ATTN_IDLE);
    ai.ai_walk(8);
}

pub export fn dog_walk2() void {
    state(.walk2, dog_walk3);
    ai.ai_walk(8);
}

pub export fn dog_walk3() void {
    state(.walk3, dog_walk4);
    ai.ai_walk(8);
}

pub export fn dog_walk4() void {
    state(.walk4, dog_walk5);
    ai.ai_walk(8);
}

pub export fn dog_walk5() void {
    state(.walk5, dog_walk6);
    ai.ai_walk(8);
}

pub export fn dog_walk6() void {
    state(.walk6, dog_walk7);
    ai.ai_walk(8);
}

pub export fn dog_walk7() void {
    state(.walk7, dog_walk8);
    ai.ai_walk(8);
}

pub export fn dog_walk8() void {
    state(.walk8, dog_walk1);
    ai.ai_walk(8);
}

pub export fn dog_run1() void {
    state(.run1, dog_run2);
    if (q.random() < 0.2)
        q.sound(q.me(), lq.CHAN_VOICE, S("dog/idle.wav"), 1, lq.ATTN_IDLE);
    ai.ai_run(16);
}

pub export fn dog_run2() void {
    state(.run2, dog_run3);
    ai.ai_run(32);
}

pub export fn dog_run3() void {
    state(.run3, dog_run4);
    ai.ai_run(32);
}

pub export fn dog_run4() void {
    state(.run4, dog_run5);
    ai.ai_run(20);
}

pub export fn dog_run5() void {
    state(.run5, dog_run6);
    ai.ai_run(64);
}

pub export fn dog_run6() void {
    state(.run6, dog_run7);
    ai.ai_run(32);
}

pub export fn dog_run7() void {
    state(.run7, dog_run8);
    ai.ai_run(16);
}

pub export fn dog_run8() void {
    state(.run8, dog_run9);
    ai.ai_run(32);
}

pub export fn dog_run9() void {
    state(.run9, dog_run10);
    ai.ai_run(32);
}

pub export fn dog_run10() void {
    state(.run10, dog_run11);
    ai.ai_run(20);
}

pub export fn dog_run11() void {
    state(.run11, dog_run12);
    ai.ai_run(64);
}

pub export fn dog_run12() void {
    state(.run12, dog_run1);
    ai.ai_run(32);
}

pub export fn dog_atta1() void {
    state(.attack1, dog_atta2);
    fight.ai_charge(10);
}

pub export fn dog_atta2() void {
    state(.attack2, dog_atta3);
    fight.ai_charge(10);
}

pub export fn dog_atta3() void {
    state(.attack3, dog_atta4);
    fight.ai_charge(10);
}

pub export fn dog_atta4() void {
    state(.attack4, dog_atta5);
    q.sound(q.me(), lq.CHAN_VOICE, S("dog/dattack1.wav"), 1, lq.ATTN_NORM);
    dog_bite();
}

pub export fn dog_atta5() void {
    state(.attack5, dog_atta6);
    fight.ai_charge(10);
}

pub export fn dog_atta6() void {
    state(.attack6, dog_atta7);
    fight.ai_charge(10);
}

pub export fn dog_atta7() void {
    state(.attack7, dog_atta8);
    fight.ai_charge(10);
}

pub export fn dog_atta8() void {
    state(.attack8, dog_run1);
    fight.ai_charge(10);
}

pub export fn dog_leap1() void {
    state(.leap1, dog_leap2);
    fight.ai_face();
}

pub export fn dog_leap2() void {
    state(.leap2, dog_leap3);
    const self = q.me();
    fight.ai_face();

    self.touch = q.func(Dog_JumpTouch);
    subs.makevectors2(self.angles);
    self.origin[2] = self.origin[2] + 1;
    self.velocity = q.scale(q.v_forward.get(), 300) + q.vec(0, 0, 200);

    if (q.has(self.flags, lq.FL_ONGROUND))
        self.flags = self.flags - lq.FL_ONGROUND;
}

pub export fn dog_leap3() void {
    state(.leap3, dog_leap4);
}

pub export fn dog_leap4() void {
    state(.leap4, dog_leap5);
}

pub export fn dog_leap5() void {
    state(.leap5, dog_leap6);
}

pub export fn dog_leap6() void {
    state(.leap6, dog_leap7);
}

pub export fn dog_leap7() void {
    state(.leap7, dog_leap8);
}

pub export fn dog_leap8() void {
    state(.leap8, dog_leap9);
}

pub export fn dog_leap9() void {
    state(.leap9, dog_leap9);
}

pub export fn dog_pain1() void {
    state(.pain1, dog_pain2);
}

pub export fn dog_pain2() void {
    state(.pain2, dog_pain3);
}

pub export fn dog_pain3() void {
    state(.pain3, dog_pain4);
}

pub export fn dog_pain4() void {
    state(.pain4, dog_pain5);
}

pub export fn dog_pain5() void {
    state(.pain5, dog_pain6);
}

pub export fn dog_pain6() void {
    state(.pain6, dog_run1);
}

pub export fn dog_painb1() void {
    state(.painb1, dog_painb2);
}

pub export fn dog_painb2() void {
    state(.painb2, dog_painb3);
}

pub export fn dog_painb3() void {
    state(.painb3, dog_painb4);
    ai.ai_pain(4);
}

pub export fn dog_painb4() void {
    state(.painb4, dog_painb5);
    ai.ai_pain(12);
}

pub export fn dog_painb5() void {
    state(.painb5, dog_painb6);
    ai.ai_pain(12);
}

pub export fn dog_painb6() void {
    state(.painb6, dog_painb7);
    ai.ai_pain(2);
}

pub export fn dog_painb7() void {
    state(.painb7, dog_painb8);
}

pub export fn dog_painb8() void {
    state(.painb8, dog_painb9);
    ai.ai_pain(4);
}

pub export fn dog_painb9() void {
    state(.painb9, dog_painb10);
}

pub export fn dog_painb10() void {
    state(.painb10, dog_painb11);
    ai.ai_pain(10);
}

pub export fn dog_painb11() void {
    state(.painb11, dog_painb12);
}

pub export fn dog_painb12() void {
    state(.painb12, dog_painb13);
}

pub export fn dog_painb13() void {
    state(.painb13, dog_painb14);
}

pub export fn dog_painb14() void {
    state(.painb14, dog_painb15);
}

pub export fn dog_painb15() void {
    state(.painb15, dog_painb16);
}

pub export fn dog_painb16() void {
    state(.painb16, dog_run1);
}

pub export fn dog_pain() void {
    q.sound(q.me(), lq.CHAN_VOICE, S("dog/dpain1.wav"), 1, lq.ATTN_NORM);

    if (q.random() > 0.5)
        dog_pain1()
    else
        dog_painb1();
}

pub export fn dog_die1() void {
    state(.death1, dog_die2);
}

pub export fn dog_die2() void {
    state(.death2, dog_die3);
}

pub export fn dog_die3() void {
    state(.death3, dog_die4);
}

pub export fn dog_die4() void {
    state(.death4, dog_die5);
}

pub export fn dog_die5() void {
    state(.death5, dog_die6);
}

pub export fn dog_die6() void {
    state(.death6, dog_die7);
}

pub export fn dog_die7() void {
    state(.death7, dog_die8);
}

pub export fn dog_die8() void {
    state(.death8, dog_die9);
}

pub export fn dog_die9() void {
    state(.death9, dog_die9);
}

pub export fn dog_dieb1() void {
    state(.deathb1, dog_dieb2);
}

pub export fn dog_dieb2() void {
    state(.deathb2, dog_dieb3);
}

pub export fn dog_dieb3() void {
    state(.deathb3, dog_dieb4);
}

pub export fn dog_dieb4() void {
    state(.deathb4, dog_dieb5);
}

pub export fn dog_dieb5() void {
    state(.deathb5, dog_dieb6);
}

pub export fn dog_dieb6() void {
    state(.deathb6, dog_dieb7);
}

pub export fn dog_dieb7() void {
    state(.deathb7, dog_dieb8);
}

pub export fn dog_dieb8() void {
    state(.deathb8, dog_dieb9);
}

pub export fn dog_dieb9() void {
    state(.deathb9, dog_dieb9);
}

pub export fn dog_die() void {
    const self = q.me();
    // check for gib
    if (self.health < -35) {
        q.sound(self, lq.CHAN_VOICE, S("player/udeath.wav"), 1, lq.ATTN_NORM);
        player.ThrowGib(S("progs/gib3.mdl"), self.health);
        player.ThrowGib(S("progs/gib3.mdl"), self.health);
        player.ThrowGib(S("progs/gib3.mdl"), self.health);
        player.ThrowHead(S("progs/h_dog.mdl"), self.health);
        return;
    }

    // regular death
    q.sound(self, lq.CHAN_VOICE, S("dog/ddeath.wav"), 1, lq.ATTN_NORM);
    self.solid = lq.SOLID_NOT;

    if (q.random() > 0.5)
        dog_die1()
    else
        dog_dieb1();
}

/// CheckDogMelee
///
/// Returns TRUE if a melee attack would hit right now
pub export fn CheckDogMelee() f32 {
    if (fight.enemy_range.get() == lq.RANGE_MELEE) { // FIXME: check canreach
        q.me().set(lq.attack_state, lq.AS_MELEE);

        return lq.TRUE;
    }

    return lq.FALSE;
}

/// CheckDogJump
pub export fn CheckDogJump() f32 {
    const self = q.me();

    if (self.origin[2] + self.mins[2] > self.enemy.origin[2] + self.enemy.mins[2] + 0.75 * self.enemy.size[2])
        return lq.FALSE;

    if (self.origin[2] + self.maxs[2] < self.enemy.origin[2] + self.enemy.mins[2] + 0.25 * self.enemy.size[2])
        return lq.FALSE;

    var dist = @as(Vector, self.enemy.origin) - self.origin;
    dist[2] = 0;

    const d = q.vlen(dist);

    if (d < 80)
        return lq.FALSE;

    if (d > 150)
        return lq.FALSE;

    return lq.TRUE;
}

pub export fn DogCheckAttack() f32 {
    // if close enough for slashing, go for it
    if (CheckDogMelee() != 0) {
        q.me().set(lq.attack_state, lq.AS_MELEE);
        return lq.TRUE;
    }

    if (CheckDogJump() != 0) {
        q.me().set(lq.attack_state, lq.AS_MISSILE);
        return lq.TRUE;
    }

    return lq.FALSE;
}

/// QUAKED monster_dog (1 0 0) (-32 -32 -24) (32 32 40) Ambush
/// {
///     model({"path": "progs/dog.mdl", "skin": 0, "frame": 0});
/// }
pub export fn monster_dog() void {
    const self = q.me();
    if (q.deathmatch.get() != 0) {
        q.remove(self);
        return;
    }
    _ = q.precache_model(S("progs/h_dog.mdl"));
    _ = q.precache_model(S("progs/dog.mdl"));

    _ = q.precache_sound(S("dog/dattack1.wav"));
    _ = q.precache_sound(S("dog/ddeath.wav"));
    _ = q.precache_sound(S("dog/dpain1.wav"));
    _ = q.precache_sound(S("dog/dsight.wav"));
    _ = q.precache_sound(S("dog/idle.wav"));

    self.solid = lq.SOLID_SLIDEBOX;
    self.movetype = lq.MOVETYPE_STEP;

    q.setmodel(self, S("progs/dog.mdl"));

    //gnounc
    self.noise = S("dog/dsight.wav");
    self.netname = S("Rottweiler");
    self.set(lq.killstring, S(loc.LOC_DEATH_DOG));

    q.setsize(self, q.vec(-32, -32, -24), q.vec(32, 32, 40));
    self.health = 25;
    self.max_health = 25;

    self.set(lq.th_stand, q.func(dog_stand1));
    self.set(lq.th_walk, q.func(dog_walk1));
    self.set(lq.th_run, q.func(dog_run1));
    // `(void(entity attacker, float damage)) dog_pain` in the original.
    self.set(lq.th_pain, q.func(dog_pain));
    self.set(lq.th_die, q.func(dog_die));
    self.set(lq.th_melee, q.func(dog_atta1));
    self.set(lq.th_missile, q.func(dog_leap1));

    monsters.walkmonster_start();
}
