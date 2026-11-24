//! monsters/shambler.qc

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
    stand14,
    stand15,
    stand16,
    stand17,
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
    run1,
    run2,
    run3,
    run4,
    run5,
    run6,
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
    smash12,
    swingr1,
    swingr2,
    swingr3,
    swingr4,
    swingr5,
    swingr6,
    swingr7,
    swingr8,
    swingr9,
    swingl1,
    swingl2,
    swingl3,
    swingl4,
    swingl5,
    swingl6,
    swingl7,
    swingl8,
    swingl9,
    magic1,
    magic2,
    magic3,
    magic4,
    magic5,
    magic6,
    magic7,
    magic8,
    magic9,
    magic10,
    magic11,
    magic12,
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
    death10,
    death11,
};

/// `$frame`, as a float.
inline fn fr(comptime frame: Frame) f32 {
    return @floatFromInt(@backingInt(frame));
}

/// The `[$frame, next]` prefix of a state function.
inline fn state(comptime frame: Frame, comptime next: anytype) void {
    q.setState(fr(frame), q.func(next));
}

pub export fn sham_stand1() void {
    state(.stand1, sham_stand2);
    ai.ai_stand();
}

pub export fn sham_stand2() void {
    state(.stand2, sham_stand3);
    ai.ai_stand();
}

pub export fn sham_stand3() void {
    state(.stand3, sham_stand4);
    ai.ai_stand();
}

pub export fn sham_stand4() void {
    state(.stand4, sham_stand5);
    ai.ai_stand();
}

pub export fn sham_stand5() void {
    state(.stand5, sham_stand6);
    ai.ai_stand();
}

pub export fn sham_stand6() void {
    state(.stand6, sham_stand7);
    ai.ai_stand();
}

pub export fn sham_stand7() void {
    state(.stand7, sham_stand8);
    ai.ai_stand();
}

pub export fn sham_stand8() void {
    state(.stand8, sham_stand9);
    ai.ai_stand();
}

pub export fn sham_stand9() void {
    state(.stand9, sham_stand10);
    ai.ai_stand();
}

pub export fn sham_stand10() void {
    state(.stand10, sham_stand11);
    ai.ai_stand();
}

pub export fn sham_stand11() void {
    state(.stand11, sham_stand12);
    ai.ai_stand();
}

pub export fn sham_stand12() void {
    state(.stand12, sham_stand13);
    ai.ai_stand();
}

pub export fn sham_stand13() void {
    state(.stand13, sham_stand14);
    ai.ai_stand();
}

pub export fn sham_stand14() void {
    state(.stand14, sham_stand15);
    ai.ai_stand();
}

pub export fn sham_stand15() void {
    state(.stand15, sham_stand16);
    ai.ai_stand();
}

pub export fn sham_stand16() void {
    state(.stand16, sham_stand17);
    ai.ai_stand();
}

pub export fn sham_stand17() void {
    state(.stand17, sham_stand1);
    ai.ai_stand();
}

pub export fn sham_walk1() void {
    state(.walk1, sham_walk2);
    ai.ai_walk(10);
}

pub export fn sham_walk2() void {
    state(.walk2, sham_walk3);
    ai.ai_walk(9);
}

pub export fn sham_walk3() void {
    state(.walk3, sham_walk4);
    ai.ai_walk(9);
}

pub export fn sham_walk4() void {
    state(.walk4, sham_walk5);
    ai.ai_walk(5);
}

pub export fn sham_walk5() void {
    state(.walk5, sham_walk6);
    ai.ai_walk(6);
}

pub export fn sham_walk6() void {
    state(.walk6, sham_walk7);
    ai.ai_walk(12);
}

pub export fn sham_walk7() void {
    state(.walk7, sham_walk8);
    ai.ai_walk(8);
}

pub export fn sham_walk8() void {
    state(.walk8, sham_walk9);
    ai.ai_walk(3);
}

pub export fn sham_walk9() void {
    state(.walk9, sham_walk10);
    ai.ai_walk(13);
}

pub export fn sham_walk10() void {
    state(.walk10, sham_walk11);
    ai.ai_walk(9);
}

pub export fn sham_walk11() void {
    state(.walk11, sham_walk12);
    ai.ai_walk(7);
}

pub export fn sham_walk12() void {
    state(.walk12, sham_walk1);
    ai.ai_walk(7);

    if (q.random() > 0.8)
        q.sound(q.me(), lq.CHAN_VOICE, S("shambler/sidle.wav"), 1, lq.ATTN_IDLE);
}

pub export fn sham_run1() void {
    state(.run1, sham_run2);
    ai.ai_run(20);
}

pub export fn sham_run2() void {
    state(.run2, sham_run3);
    ai.ai_run(24);
}

pub export fn sham_run3() void {
    state(.run3, sham_run4);
    ai.ai_run(20);
}

pub export fn sham_run4() void {
    state(.run4, sham_run5);
    ai.ai_run(20);
}

pub export fn sham_run5() void {
    state(.run5, sham_run6);
    ai.ai_run(24);
}

pub export fn sham_run6() void {
    state(.run6, sham_run1);
    ai.ai_run(20);
    if (q.random() > 0.8)
        q.sound(q.me(), lq.CHAN_VOICE, S("shambler/sidle.wav"), 1, lq.ATTN_IDLE);
}

pub export fn sham_smash1() void {
    state(.smash1, sham_smash2);
    q.sound(q.me(), lq.CHAN_VOICE, S("shambler/melee1.wav"), 1, lq.ATTN_NORM);
    fight.ai_charge(2);
}

pub export fn sham_smash2() void {
    state(.smash2, sham_smash3);
    fight.ai_charge(6);
}

pub export fn sham_smash3() void {
    state(.smash3, sham_smash4);
    fight.ai_charge(6);
}

pub export fn sham_smash4() void {
    state(.smash4, sham_smash5);
    fight.ai_charge(5);
}

pub export fn sham_smash5() void {
    state(.smash5, sham_smash6);
    fight.ai_charge(4);
}

pub export fn sham_smash6() void {
    state(.smash6, sham_smash7);
    fight.ai_charge(1);
}

pub export fn sham_smash7() void {
    state(.smash7, sham_smash8);
    fight.ai_charge(0);
}

pub export fn sham_smash8() void {
    state(.smash8, sham_smash9);
    fight.ai_charge(0);
}

pub export fn sham_smash9() void {
    state(.smash9, sham_smash10);
    fight.ai_charge(0);
}

pub export fn sham_smash10() void {
    state(.smash10, sham_smash11);
    const self = q.me();

    if (self.enemy.isNull())
        return;

    fight.ai_charge(0);

    const delta = @as(Vector, self.enemy.origin) - self.origin;

    if (q.vlen(delta) > 100)
        return;

    if (combat.CanDamage(self.enemy, self) == 0)
        return;

    const ldmg = (q.random() + q.random() + q.random()) * 40;
    combat.T_Damage(self.enemy, self, self, ldmg);
    q.sound(self, lq.CHAN_VOICE, S("shambler/smack.wav"), 1, lq.ATTN_NORM);

    weapons.SpawnMeatSpray(@as(Vector, self.origin) + q.scale(q.v_forward.get(), 16), q.scale(q.v_right.get(), weapons.crandom() * 100));
    weapons.SpawnMeatSpray(@as(Vector, self.origin) + q.scale(q.v_forward.get(), 16), q.scale(q.v_right.get(), weapons.crandom() * 100));
}

pub export fn sham_smash11() void {
    state(.smash11, sham_smash12);
    fight.ai_charge(5);
}

pub export fn sham_smash12() void {
    state(.smash12, sham_run1);
    fight.ai_charge(4);
}

pub export fn ShamClaw(side: f32) void {
    const self = q.me();

    if (self.enemy.isNull())
        return;

    fight.ai_charge(10);

    const delta = @as(Vector, self.enemy.origin) - self.origin;

    if (q.vlen(delta) > 100)
        return;

    const ldmg = (q.random() + q.random() + q.random()) * 20;
    combat.T_Damage(self.enemy, self, self, ldmg);
    q.sound(self, lq.CHAN_VOICE, S("shambler/smack.wav"), 1, lq.ATTN_NORM);

    if (side != 0) {
        subs.makevectors2(self.angles);
        weapons.SpawnMeatSpray(@as(Vector, self.origin) + q.scale(q.v_forward.get(), 16), q.scale(q.v_right.get(), side));
    }
}

pub export fn sham_swingl1() void {
    state(.swingl1, sham_swingl2);
    q.sound(q.me(), lq.CHAN_VOICE, S("shambler/melee2.wav"), 1, lq.ATTN_NORM);
    fight.ai_charge(5);
}

pub export fn sham_swingl2() void {
    state(.swingl2, sham_swingl3);
    fight.ai_charge(3);
}

pub export fn sham_swingl3() void {
    state(.swingl3, sham_swingl4);
    fight.ai_charge(7);
}

pub export fn sham_swingl4() void {
    state(.swingl4, sham_swingl5);
    fight.ai_charge(3);
}

pub export fn sham_swingl5() void {
    state(.swingl5, sham_swingl6);
    fight.ai_charge(7);
}

pub export fn sham_swingl6() void {
    state(.swingl6, sham_swingl7);
    fight.ai_charge(9);
}

pub export fn sham_swingl7() void {
    state(.swingl7, sham_swingl8);
    fight.ai_charge(5);
    ShamClaw(250);
}

pub export fn sham_swingl8() void {
    state(.swingl8, sham_swingl9);
    fight.ai_charge(4);
}

pub export fn sham_swingl9() void {
    state(.swingl9, sham_run1);
    fight.ai_charge(8);
    if (q.random() < 0.5)
        q.me().think = q.func(sham_swingr1);
}

pub export fn sham_swingr1() void {
    state(.swingr1, sham_swingr2);
    q.sound(q.me(), lq.CHAN_VOICE, S("shambler/melee1.wav"), 1, lq.ATTN_NORM);
    fight.ai_charge(1);
}

pub export fn sham_swingr2() void {
    state(.swingr2, sham_swingr3);
    fight.ai_charge(8);
}

pub export fn sham_swingr3() void {
    state(.swingr3, sham_swingr4);
    fight.ai_charge(14);
}

pub export fn sham_swingr4() void {
    state(.swingr4, sham_swingr5);
    fight.ai_charge(7);
}

pub export fn sham_swingr5() void {
    state(.swingr5, sham_swingr6);
    fight.ai_charge(3);
}

pub export fn sham_swingr6() void {
    state(.swingr6, sham_swingr7);
    fight.ai_charge(6);
}

pub export fn sham_swingr7() void {
    state(.swingr7, sham_swingr8);
    fight.ai_charge(6);
    ShamClaw(-250);
}

pub export fn sham_swingr8() void {
    state(.swingr8, sham_swingr9);
    fight.ai_charge(3);
}

pub export fn sham_swingr9() void {
    state(.swingr9, sham_run1);
    fight.ai_charge(1);
    fight.ai_charge(10);
    if (q.random() < 0.5)
        q.me().think = q.func(sham_swingl1);
}

pub export fn sham_melee() void {
    const chance = q.random();

    if (chance > 0.6 or q.me().health == 600)
        sham_smash1()
    else if (chance > 0.3)
        sham_swingr1()
    else
        sham_swingl1();
}

pub export fn CastLightning() void {
    const self = q.me();

    self.effects = q.bor(self.effects, lq.EF_MUZZLEFLASH);

    fight.ai_face();

    const org = @as(Vector, self.origin) + q.vec(0, 0, 40);

    var dir = @as(Vector, self.enemy.origin) + q.vec(0, 0, 16) - org;
    dir = q.normalize(dir);

    q.traceline(org, @as(Vector, self.origin) + q.scale(dir, 600), lq.TRUE, self);

    q.WriteByte(lq.MSG_BROADCAST, lq.SVC_TEMPENTITY);
    q.WriteByte(lq.MSG_BROADCAST, lq.TE_LIGHTNING1);
    q.WriteEntity(lq.MSG_BROADCAST, self);
    q.WriteCoord(lq.MSG_BROADCAST, org[0]);
    q.WriteCoord(lq.MSG_BROADCAST, org[1]);
    q.WriteCoord(lq.MSG_BROADCAST, org[2]);
    q.WriteCoord(lq.MSG_BROADCAST, q.trace_endpos.get()[0]);
    q.WriteCoord(lq.MSG_BROADCAST, q.trace_endpos.get()[1]);
    q.WriteCoord(lq.MSG_BROADCAST, q.trace_endpos.get()[2]);

    weapons.LightningDamage(org, q.trace_endpos.get(), self, 10);
}

pub export fn sham_magic1() void {
    state(.magic1, sham_magic2);
    fight.ai_face();
    q.sound(q.me(), lq.CHAN_WEAPON, S("shambler/sattck1.wav"), 1, lq.ATTN_NORM);
}

pub export fn sham_magic2() void {
    state(.magic2, sham_magic3);
    fight.ai_face();
}

pub export fn sham_magic3() void {
    state(.magic3, sham_magic4);
    const self = q.me();
    fight.ai_face();
    self.nextthink = self.nextthink + 0.2;

    self.effects = q.bor(self.effects, lq.EF_MUZZLEFLASH);
    fight.ai_face();
    self.owner = q.spawn();
    const o = self.owner;
    q.setmodel(o, S("progs/s_light.mdl"));
    q.setorigin(o, self.origin);
    o.angles = self.angles;
    o.nextthink = q.time.get() + 0.7;
    o.think = q.func(subs.SUB_Remove);
}

pub export fn sham_magic4() void {
    state(.magic4, sham_magic5);
    const self = q.me();
    self.effects = q.bor(self.effects, lq.EF_MUZZLEFLASH);
    self.owner.frame = 1;
}

pub export fn sham_magic5() void {
    state(.magic5, sham_magic6);
    const self = q.me();
    self.effects = q.bor(self.effects, lq.EF_MUZZLEFLASH);
    self.owner.frame = 2;
}

pub export fn sham_magic6() void {
    state(.magic6, sham_magic9);
    const self = q.me();
    q.remove(self.owner);
    self.owner = q.world.get(); // Fixes shambler-grenade bug
    CastLightning();
    q.sound(self, lq.CHAN_WEAPON, S("shambler/sboom.wav"), 1, lq.ATTN_NORM);
}

pub export fn sham_magic9() void {
    state(.magic9, sham_magic10);
    CastLightning();
}

pub export fn sham_magic10() void {
    state(.magic10, sham_magic11);
    CastLightning();
}

pub export fn sham_magic11() void {
    state(.magic11, sham_magic12);
    if (lq.skill.get() == 3)
        CastLightning();
}

pub export fn sham_magic12() void {
    state(.magic12, sham_run1);
}

pub export fn sham_pain1() void {
    state(.pain1, sham_pain2);
}

pub export fn sham_pain2() void {
    state(.pain2, sham_pain3);
}

pub export fn sham_pain3() void {
    state(.pain3, sham_pain4);
}

pub export fn sham_pain4() void {
    state(.pain4, sham_pain5);
}

pub export fn sham_pain5() void {
    state(.pain5, sham_pain6);
}

pub export fn sham_pain6() void {
    state(.pain6, sham_run1);
}

pub export fn sham_pain(attacker: Entity, damage: f32) void {
    _ = attacker;
    const self = q.me();
    q.sound(self, lq.CHAN_VOICE, S("shambler/shurt2.wav"), 1, lq.ATTN_NORM);

    if (self.health <= 0)
        return; // already dying, don't go into pain frame

    if (q.random() * 400 > damage)
        return; // didn't flinch

    if (self.get(lq.pain_finished) > q.time.get())
        return;

    self.set(lq.pain_finished, q.time.get() + 2);

    // Fixes shambler-grenade bug
    if (!self.owner.isNull())
        self.owner.frame = 2;
    self.owner = q.world.get();

    sham_pain1();
}

pub export fn sham_death1() void {
    state(.death1, sham_death2);
}

pub export fn sham_death2() void {
    state(.death2, sham_death3);
}

pub export fn sham_death3() void {
    state(.death3, sham_death4);
    q.me().solid = lq.SOLID_NOT;
}

pub export fn sham_death4() void {
    state(.death4, sham_death5);
}

pub export fn sham_death5() void {
    state(.death5, sham_death6);
}

pub export fn sham_death6() void {
    state(.death6, sham_death7);
}

pub export fn sham_death7() void {
    state(.death7, sham_death8);
}

pub export fn sham_death8() void {
    state(.death8, sham_death9);
}

pub export fn sham_death9() void {
    state(.death9, sham_death10);
}

pub export fn sham_death10() void {
    state(.death10, sham_death11);
}

pub export fn sham_death11() void {
    state(.death11, sham_death11);
}

pub export fn sham_die() void {
    const self = q.me();
    // check for gib
    if (self.health < -60) {
        q.sound(self, lq.CHAN_VOICE, S("player/udeath.wav"), 1, lq.ATTN_NORM);
        player.ThrowHead(S("progs/h_shams.mdl"), self.health);
        player.ThrowGib(S("progs/gib1.mdl"), self.health);
        player.ThrowGib(S("progs/gib2.mdl"), self.health);
        player.ThrowGib(S("progs/gib3.mdl"), self.health);

        return;
    }

    // regular death
    q.sound(self, lq.CHAN_VOICE, S("shambler/sdeath.wav"), 1, lq.ATTN_NORM);
    sham_death1();
}

/// QUAKED monster_shambler (1 0 0) (-32 -32 -24) (32 32 64) Ambush
/// {
///     model({"path": "progs/shambler.mdl", "skin": 0, "frame": 0});
/// }
pub export fn monster_shambler() void {
    const self = q.me();
    if (q.deathmatch.get() != 0) {
        q.remove(self);
        return;
    }

    _ = q.precache_model(S("progs/shambler.mdl"));
    _ = q.precache_model(S("progs/s_light.mdl"));
    _ = q.precache_model(S("progs/h_shams.mdl"));
    _ = q.precache_model(S("progs/bolt.mdl"));

    _ = q.precache_sound(S("shambler/sattck1.wav"));
    _ = q.precache_sound(S("shambler/sboom.wav"));
    _ = q.precache_sound(S("shambler/sdeath.wav"));
    _ = q.precache_sound(S("shambler/shurt2.wav"));
    _ = q.precache_sound(S("shambler/sidle.wav"));
    _ = q.precache_sound(S("shambler/ssight.wav"));
    _ = q.precache_sound(S("shambler/melee1.wav"));
    _ = q.precache_sound(S("shambler/melee2.wav"));
    _ = q.precache_sound(S("shambler/smack.wav"));

    self.solid = lq.SOLID_SLIDEBOX;
    self.movetype = lq.MOVETYPE_STEP;
    q.setmodel(self, S("progs/shambler.mdl"));

    //gnounc
    self.noise = S("shambler/ssight.wav"); //gnounc
    self.netname = S("Shambler");
    self.set(lq.killstring, S(loc.LOC_DEATH_SHAMBLER));

    q.setsize(self, lq.VEC_HULL2_MIN, lq.VEC_HULL2_MAX);
    self.health = 600;
    self.max_health = 600;

    self.set(lq.th_stand, q.func(sham_stand1));
    self.set(lq.th_walk, q.func(sham_walk1));
    self.set(lq.th_run, q.func(sham_run1));
    self.set(lq.th_die, q.func(sham_die));
    self.set(lq.th_melee, q.func(sham_melee));
    self.set(lq.th_missile, q.func(sham_magic1));
    self.set(lq.th_pain, q.func(sham_pain));

    monsters.walkmonster_start();
}
