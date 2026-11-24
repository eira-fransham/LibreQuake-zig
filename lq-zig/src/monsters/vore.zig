//! monsters/vore.qc

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
    attack9,
    attack10,
    attack11,
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
};

/// `$frame`, as a float.
inline fn fr(comptime frame: Frame) f32 {
    return @floatFromInt(@backingInt(frame));
}

/// The `[$frame, next]` prefix of a state function.
inline fn state(comptime frame: Frame, comptime next: anytype) void {
    q.setState(fr(frame), q.func(next));
}

pub export fn shal_stand() void {
    state(.walk1, shal_stand);
    ai.ai_stand();
}

pub export fn shal_walk1() void {
    state(.walk2, shal_walk2);
    const self = q.me();
    if (q.random() < 0.2)
        q.sound(self, lq.CHAN_VOICE, S("shalrath/idle.wav"), 1, lq.ATTN_IDLE);
    ai.ai_walk(6);
}

pub export fn shal_walk2() void {
    state(.walk3, shal_walk3);
    ai.ai_walk(4);
}

pub export fn shal_walk3() void {
    state(.walk4, shal_walk4);
    ai.ai_walk(0);
}

pub export fn shal_walk4() void {
    state(.walk5, shal_walk5);
    ai.ai_walk(0);
}

pub export fn shal_walk5() void {
    state(.walk6, shal_walk6);
    ai.ai_walk(0);
}

pub export fn shal_walk6() void {
    state(.walk7, shal_walk7);
    ai.ai_walk(0);
}

pub export fn shal_walk7() void {
    state(.walk8, shal_walk8);
    ai.ai_walk(5);
}

pub export fn shal_walk8() void {
    state(.walk9, shal_walk9);
    ai.ai_walk(6);
}

pub export fn shal_walk9() void {
    state(.walk10, shal_walk10);
    ai.ai_walk(5);
}

pub export fn shal_walk10() void {
    state(.walk11, shal_walk11);
    ai.ai_walk(0);
}

pub export fn shal_walk11() void {
    state(.walk12, shal_walk12);
    ai.ai_walk(4);
}

pub export fn shal_walk12() void {
    state(.walk1, shal_walk1);
    ai.ai_walk(5);
}

pub export fn shal_run1() void {
    state(.walk2, shal_run2);
    const self = q.me();
    if (q.random() < 0.2)
        q.sound(self, lq.CHAN_VOICE, S("shalrath/idle.wav"), 1, lq.ATTN_IDLE);
    ai.ai_run(6);
}

pub export fn shal_run2() void {
    state(.walk3, shal_run3);
    ai.ai_run(4);
}

pub export fn shal_run3() void {
    state(.walk4, shal_run4);
    ai.ai_run(0);
}

pub export fn shal_run4() void {
    state(.walk5, shal_run5);
    ai.ai_run(0);
}

pub export fn shal_run5() void {
    state(.walk6, shal_run6);
    ai.ai_run(0);
}

pub export fn shal_run6() void {
    state(.walk7, shal_run7);
    ai.ai_run(0);
}

pub export fn shal_run7() void {
    state(.walk8, shal_run8);
    ai.ai_run(5);
}

pub export fn shal_run8() void {
    state(.walk9, shal_run9);
    ai.ai_run(6);
}

pub export fn shal_run9() void {
    state(.walk10, shal_run10);
    ai.ai_run(5);
}

pub export fn shal_run10() void {
    state(.walk11, shal_run11);
    ai.ai_run(0);
}

pub export fn shal_run11() void {
    state(.walk12, shal_run12);
    ai.ai_run(4);
}

pub export fn shal_run12() void {
    state(.walk1, shal_run1);
    ai.ai_run(5);
}

pub export fn shal_attack1() void {
    state(.attack1, shal_attack2);
    const self = q.me();
    q.sound(self, lq.CHAN_VOICE, S("shalrath/attack.wav"), 1, lq.ATTN_NORM);
    fight.ai_face();
}

pub export fn shal_attack2() void {
    state(.attack2, shal_attack3);
    fight.ai_face();
}

pub export fn shal_attack3() void {
    state(.attack3, shal_attack4);
    fight.ai_face();
}

pub export fn shal_attack4() void {
    state(.attack4, shal_attack5);
    fight.ai_face();
}

pub export fn shal_attack5() void {
    state(.attack5, shal_attack6);
    fight.ai_face();
}

pub export fn shal_attack6() void {
    state(.attack6, shal_attack7);
    fight.ai_face();
}

pub export fn shal_attack7() void {
    state(.attack7, shal_attack8);
    fight.ai_face();
}

pub export fn shal_attack8() void {
    state(.attack8, shal_attack9);
    fight.ai_face();
}

pub export fn shal_attack9() void {
    state(.attack9, shal_attack10);
    ShalMissile();
}

pub export fn shal_attack10() void {
    state(.attack10, shal_attack11);
    fight.ai_face();
}

pub export fn shal_attack11() void {
    state(.attack11, shal_run1);
}

pub export fn shal_pain1() void {
    state(.pain1, shal_pain2);
}

pub export fn shal_pain2() void {
    state(.pain2, shal_pain3);
}

pub export fn shal_pain3() void {
    state(.pain3, shal_pain4);
}

pub export fn shal_pain4() void {
    state(.pain4, shal_pain5);
}

pub export fn shal_pain5() void {
    state(.pain5, shal_run1);
}

pub export fn shal_death1() void {
    state(.death1, shal_death2);
}

pub export fn shal_death2() void {
    state(.death2, shal_death3);
}

pub export fn shal_death3() void {
    state(.death3, shal_death4);
}

pub export fn shal_death4() void {
    state(.death4, shal_death5);
}

pub export fn shal_death5() void {
    state(.death5, shal_death6);
}

pub export fn shal_death6() void {
    state(.death6, shal_death7);
}

pub export fn shal_death7() void {
    state(.death7, shal_death7);
}

pub export fn shalrath_pain() void {
    const self = q.me();
    if (self.get(lq.pain_finished) > q.time.get())
        return;

    q.sound(self, lq.CHAN_VOICE, S("shalrath/pain.wav"), 1, lq.ATTN_NORM);
    shal_pain1();
    self.set(lq.pain_finished, q.time.get() + 3);
}

pub export fn shalrath_die() void {
    const self = q.me();
    // check for gib
    if (self.health < -90) {
        q.sound(self, lq.CHAN_VOICE, S("player/udeath.wav"), 1, lq.ATTN_NORM);
        player.ThrowHead(S("progs/h_shal.mdl"), self.health);
        player.ThrowGib(S("progs/gib1.mdl"), self.health);
        player.ThrowGib(S("progs/gib2.mdl"), self.health);
        player.ThrowGib(S("progs/gib3.mdl"), self.health);

        return;
    }

    q.sound(self, lq.CHAN_VOICE, S("shalrath/death.wav"), 1, lq.ATTN_NORM);
    shal_death1();
    self.solid = lq.SOLID_NOT;
    // insert death sounds here
}

pub export fn ShalMissile() void {
    const self = q.me();

    const dir = q.normalize((@as(Vector, self.enemy.origin) + q.vec(0, 0, 10)) - self.origin);
    const dist = q.vlen(@as(Vector, self.enemy.origin) - self.origin);
    var flytime = dist * 0.002;

    if (flytime < 0.1)
        flytime = 0.1;

    self.effects = q.bor(self.effects, lq.EF_MUZZLEFLASH);
    q.sound(self, lq.CHAN_WEAPON, S("shalrath/attack2.wav"), 1, lq.ATTN_NORM);

    const missile = q.spawn();
    missile.classname = S("vore_ball"); //gnounc
    missile.owner = self;

    missile.solid = lq.SOLID_BBOX;
    missile.movetype = lq.MOVETYPE_FLYMISSILE;
    q.setmodel(missile, S("progs/v_spike.mdl"));

    q.setsize(missile, q.vec(0, 0, 0), q.vec(0, 0, 0));

    missile.origin = @as(Vector, self.origin) + q.vec(0, 0, 10);
    missile.velocity = q.scale(dir, 400);
    missile.avelocity = q.vec(300, 300, 300);
    missile.nextthink = flytime + q.time.get();
    missile.think = q.func(ShalHome);
    missile.enemy = self.enemy;
    missile.touch = q.func(ShalMissileTouch);
}

pub export fn ShalHome() void {
    const self = q.me();
    const vtemp = @as(Vector, self.enemy.origin) + q.vec(0, 0, 10);

    if (self.enemy.health < 1) {
        q.remove(self);
        return;
    }

    const dir = q.normalize(vtemp - self.origin);

    if (lq.skill.get() == 3)
        self.velocity = q.scale(dir, 350)
    else
        self.velocity = q.scale(dir, 250);

    self.nextthink = q.time.get() + 0.2;
    self.think = q.func(ShalHome);
}

pub export fn ShalMissileTouch() void {
    const self = q.me();
    const other = q.other.get();
    if (other.eql(self.owner))
        return; // don't explode on owner

    if (other.classname.eql(S("monster_zombie")))
        combat.T_Damage(other, self, self, 110);

    combat.T_RadiusDamage(self, self.owner, 40, q.world.get(), S(""));
    q.sound(self, lq.CHAN_WEAPON, S("weapons/r_exp3.wav"), 1, lq.ATTN_NORM);

    q.WriteByte(lq.MSG_BROADCAST, lq.SVC_TEMPENTITY);
    q.WriteByte(lq.MSG_BROADCAST, lq.TE_EXPLOSION);
    q.WriteCoord(lq.MSG_BROADCAST, self.origin[0]);
    q.WriteCoord(lq.MSG_BROADCAST, self.origin[1]);
    q.WriteCoord(lq.MSG_BROADCAST, self.origin[2]);

    self.velocity = q.vec(0, 0, 0);
    self.touch = null;
    q.setmodel(self, S("progs/s_explod.spr"));
    self.solid = lq.SOLID_NOT;
    weapons.s_explode1();
}

/// QUAKED monster_shalrath (1 0 0) (-32 -32 -24) (32 32 48) Ambush
/// {
///     model({"path": "progs/shalrath.mdl", "skin": 0, "frame": 0});
/// }
pub export fn monster_shalrath() void {
    const self = q.me();
    if (q.deathmatch.get() != 0) {
        q.remove(self);
        return;
    }

    _ = q.precache_model2(S("progs/shalrath.mdl"));
    _ = q.precache_model2(S("progs/h_shal.mdl"));
    _ = q.precache_model2(S("progs/v_spike.mdl"));

    _ = q.precache_sound2(S("shalrath/attack.wav"));
    _ = q.precache_sound2(S("shalrath/attack2.wav"));
    _ = q.precache_sound2(S("shalrath/death.wav"));
    _ = q.precache_sound2(S("shalrath/idle.wav"));
    _ = q.precache_sound2(S("shalrath/pain.wav"));
    _ = q.precache_sound2(S("shalrath/sight.wav"));

    self.solid = lq.SOLID_SLIDEBOX;
    self.movetype = lq.MOVETYPE_STEP;

    q.setmodel(self, S("progs/shalrath.mdl"));

    //gnounc
    self.noise = S("shalrath/sight.wav"); //gnounc
    self.netname = S("Vore");
    self.set(lq.killstring, S(loc.LOC_DEATH_SHALRATH));

    q.setsize(self, lq.VEC_HULL2_MIN, lq.VEC_HULL2_MAX);
    self.health = 400;
    self.max_health = 400;

    self.set(lq.th_stand, q.func(shal_stand));
    self.set(lq.th_walk, q.func(shal_walk1));
    self.set(lq.th_run, q.func(shal_run1));
    self.set(lq.th_die, q.func(shalrath_die));
    // `(void(entity attacker, float damage)) shalrath_pain` in the original:
    // stored as `th_pain` though it takes no parameters.
    self.set(lq.th_pain, q.func(shalrath_pain));
    self.set(lq.th_missile, q.func(shal_attack1));

    self.think = q.func(monsters.walkmonster_start);
    self.nextthink = q.time.get() + 0.1 + q.random() * 0.1;
}
