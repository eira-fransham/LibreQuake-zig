//! monsters/scrag.qc

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
    hover1,
    hover2,
    hover3,
    hover4,
    hover5,
    hover6,
    hover7,
    hover8,
    hover9,
    hover10,
    hover11,
    hover12,
    hover13,
    hover14,
    hover15,
    fly1,
    fly2,
    fly3,
    fly4,
    fly5,
    fly6,
    fly7,
    fly8,
    fly9,
    fly10,
    fly11,
    fly12,
    fly13,
    fly14,
    magatt1,
    magatt2,
    magatt3,
    magatt4,
    magatt5,
    magatt6,
    magatt7,
    magatt8,
    magatt9,
    magatt10,
    magatt11,
    magatt12,
    magatt13,
    pain1,
    pain2,
    pain3,
    pain4,
    death1,
    death2,
    death3,
    death4,
    death5,
    death6,
    death7,
    death8,
};

/// `$frame`, as a float.
inline fn fr(comptime frame: Frame) f32 {
    return @floatFromInt(@backingInt(frame));
}

/// The `[$frame, next]` prefix of a state function.
inline fn state(comptime frame: Frame, comptime next: anytype) void {
    q.setState(fr(frame), q.func(next));
}

/// LaunchMissile
///
/// Sets the given entities velocity and angles so that it will hit self.enemy
/// if self.enemy maintains it's current velocity
/// 0.1 is moderately accurate, 0.0 is totally accurate
pub export fn LaunchMissile(missile: Entity, mspeed: f32, accuracy: f32) void {
    const self = q.me();

    subs.makevectors2(self.angles);

    // set missile speed
    var vec = @as(Vector, self.enemy.origin) + self.enemy.mins + q.scale(self.enemy.size, 0.7) - missile.origin;

    // calc aproximate time for missile to reach vec
    const fly = q.vlen(vec) / mspeed;

    // get the entities xy velocity
    var move: Vector = self.enemy.velocity;
    move[2] = 0;

    // project the target forward in time
    vec = vec + q.scale(move, fly);

    vec = q.normalize(vec);
    vec = vec + q.scale(q.scale(q.v_up.get(), accuracy), q.random() - 0.5) + q.scale(q.scale(q.v_right.get(), accuracy), q.random() - 0.5);

    missile.velocity = q.scale(vec, mspeed);

    missile.angles = q.vec(0, 0, 0);
    missile.angles[1] = q.vectoyaw(missile.velocity);

    // set missile duration
    missile.nextthink = q.time.get() + 5;
    missile.think = q.func(subs.SUB_Remove);
}

/// WizardCheckAttack
pub export fn WizardCheckAttack() f32 {
    const self = q.me();
    var chance: f32 = undefined;

    if (q.time.get() < self.get(lq.attack_finished))
        return lq.FALSE;

    if (fight.enemy_vis.get() == 0)
        return lq.FALSE;

    if (fight.enemy_range.get() == lq.RANGE_FAR) {
        if (self.get(lq.attack_state) != lq.AS_STRAIGHT) {
            self.set(lq.attack_state, lq.AS_STRAIGHT);
            wiz_run1();
        }
        return lq.FALSE;
    }

    const targ = self.enemy;

    // see if any entities are in the way of the shot
    const spot1 = @as(Vector, self.origin) + self.view_ofs;
    const spot2 = @as(Vector, targ.origin) + targ.view_ofs;

    q.traceline(spot1, spot2, lq.FALSE, self);

    if (q.trace_ent.get().neq(targ)) { // don't have a clear shot, so move to a side
        if (self.get(lq.attack_state) != lq.AS_STRAIGHT) {
            self.set(lq.attack_state, lq.AS_STRAIGHT);
            wiz_run1();
        }
        return lq.FALSE;
    }

    if (fight.enemy_range.get() == lq.RANGE_MELEE)
        chance = 0.9
    else if (fight.enemy_range.get() == lq.RANGE_NEAR)
        chance = 0.6
    else if (fight.enemy_range.get() == lq.RANGE_MID)
        chance = 0.2
    else
        chance = 0;

    if (q.random() < chance) {
        self.set(lq.attack_state, lq.AS_MISSILE);
        return lq.TRUE;
    }

    if (fight.enemy_range.get() == lq.RANGE_MID) {
        if (self.get(lq.attack_state) != lq.AS_STRAIGHT) {
            self.set(lq.attack_state, lq.AS_STRAIGHT);
            wiz_run1();
        }
    } else {
        if (self.get(lq.attack_state) != lq.AS_SLIDING) {
            self.set(lq.attack_state, lq.AS_SLIDING);
            wiz_side1();
        }
    }

    return lq.FALSE;
}

/// WizardAttackFinished
pub export fn WizardAttackFinished() void {
    const self = q.me();
    if (fight.enemy_range.get() >= lq.RANGE_MID or fight.enemy_vis.get() == 0) {
        self.set(lq.attack_state, lq.AS_STRAIGHT);
        self.think = q.func(wiz_run1);
    } else {
        self.set(lq.attack_state, lq.AS_SLIDING);
        self.think = q.func(wiz_side1);
    }
}

pub export fn Wiz_FastFire() void {
    const self = q.me();

    if (self.owner.health > 0) {
        self.owner.effects = q.bor(self.owner.effects, lq.EF_MUZZLEFLASH);

        subs.makevectors2(self.enemy.angles);
        const dst = @as(Vector, self.enemy.origin) - q.scale(self.movedir, 13);

        const vec = q.normalize(dst - self.origin);
        q.sound(self, lq.CHAN_WEAPON, S("wizard/wattack.wav"), 1, lq.ATTN_NORM);
        weapons.launch_spike(self.origin, vec);
        const newmis = lq.newmis.get();
        newmis.velocity = q.scale(vec, 600);
        newmis.owner = self.owner;
        newmis.classname = S("wizard_spike"); //changed it to be consistant --gnounc
        q.setmodel(newmis, S("progs/w_spike.mdl"));
        q.setsize(newmis, lq.VEC_ORIGIN, lq.VEC_ORIGIN);
    }

    q.remove(self);
}

pub export fn Wiz_StartFast() void {
    const self = q.me();

    q.sound(self, lq.CHAN_WEAPON, S("wizard/wattack.wav"), 1, lq.ATTN_NORM);
    self.v_angle = self.angles;
    subs.makevectors2(self.angles);

    var missile = q.spawn();
    missile.owner = self;
    missile.nextthink = q.time.get() + 0.6;
    q.setsize(missile, q.vec(0, 0, 0), q.vec(0, 0, 0));
    q.setorigin(missile, @as(Vector, self.origin) + q.vec(0, 0, 30) + q.scale(q.v_forward.get(), 14) + q.scale(q.v_right.get(), 14));
    missile.enemy = self.enemy;
    missile.nextthink = q.time.get() + 0.8;
    missile.think = q.func(Wiz_FastFire);
    missile.movedir = q.v_right.get();

    missile = q.spawn();
    missile.owner = self;
    missile.nextthink = q.time.get() + 1;
    q.setsize(missile, q.vec(0, 0, 0), q.vec(0, 0, 0));
    q.setorigin(missile, @as(Vector, self.origin) + q.vec(0, 0, 30) + q.scale(q.v_forward.get(), 14) + q.scale(q.v_right.get(), -14));
    missile.enemy = self.enemy;
    missile.nextthink = q.time.get() + 0.3;
    missile.think = q.func(Wiz_FastFire);
    missile.movedir = lq.VEC_ORIGIN - q.v_right.get();
}

pub export fn Wiz_idlesound() void {
    const self = q.me();
    const wr = q.random() * 5;

    if (self.get(lq.waitmin) < q.time.get()) {
        self.set(lq.waitmin, q.time.get() + 2);
        if (wr > 4.5)
            q.sound(self, lq.CHAN_VOICE, S("wizard/widle1.wav"), 1, lq.ATTN_IDLE);

        if (wr < 1.5)
            q.sound(self, lq.CHAN_VOICE, S("wizard/widle2.wav"), 1, lq.ATTN_IDLE);
    }
    return;
}

pub export fn wiz_stand1() void {
    state(.hover1, wiz_stand2);
    ai.ai_stand();
}

pub export fn wiz_stand2() void {
    state(.hover2, wiz_stand3);
    ai.ai_stand();
}

pub export fn wiz_stand3() void {
    state(.hover3, wiz_stand4);
    ai.ai_stand();
}

pub export fn wiz_stand4() void {
    state(.hover4, wiz_stand5);
    ai.ai_stand();
}

pub export fn wiz_stand5() void {
    state(.hover5, wiz_stand6);
    ai.ai_stand();
}

pub export fn wiz_stand6() void {
    state(.hover6, wiz_stand7);
    ai.ai_stand();
}

pub export fn wiz_stand7() void {
    state(.hover7, wiz_stand8);
    ai.ai_stand();
}

pub export fn wiz_stand8() void {
    state(.hover8, wiz_stand1);
    ai.ai_stand();
}

pub export fn wiz_walk1() void {
    state(.hover1, wiz_walk2);
    ai.ai_walk(8);
    Wiz_idlesound();
}

pub export fn wiz_walk2() void {
    state(.hover2, wiz_walk3);
    ai.ai_walk(8);
}

pub export fn wiz_walk3() void {
    state(.hover3, wiz_walk4);
    ai.ai_walk(8);
}

pub export fn wiz_walk4() void {
    state(.hover4, wiz_walk5);
    ai.ai_walk(8);
}

pub export fn wiz_walk5() void {
    state(.hover5, wiz_walk6);
    ai.ai_walk(8);
}

pub export fn wiz_walk6() void {
    state(.hover6, wiz_walk7);
    ai.ai_walk(8);
}

pub export fn wiz_walk7() void {
    state(.hover7, wiz_walk8);
    ai.ai_walk(8);
}

pub export fn wiz_walk8() void {
    state(.hover8, wiz_walk1);
    ai.ai_walk(8);
}

pub export fn wiz_side1() void {
    state(.hover1, wiz_side2);
    ai.ai_run(8);
    Wiz_idlesound();
}

pub export fn wiz_side2() void {
    state(.hover2, wiz_side3);
    ai.ai_run(8);
}

pub export fn wiz_side3() void {
    state(.hover3, wiz_side4);
    ai.ai_run(8);
}

pub export fn wiz_side4() void {
    state(.hover4, wiz_side5);
    ai.ai_run(8);
}

pub export fn wiz_side5() void {
    state(.hover5, wiz_side6);
    ai.ai_run(8);
}

pub export fn wiz_side6() void {
    state(.hover6, wiz_side7);
    ai.ai_run(8);
}

pub export fn wiz_side7() void {
    state(.hover7, wiz_side8);
    ai.ai_run(8);
}

pub export fn wiz_side8() void {
    state(.hover8, wiz_side1);
    ai.ai_run(8);
}

pub export fn wiz_run1() void {
    state(.fly1, wiz_run2);
    ai.ai_run(16);
    Wiz_idlesound();
}

pub export fn wiz_run2() void {
    state(.fly2, wiz_run3);
    ai.ai_run(16);
}

pub export fn wiz_run3() void {
    state(.fly3, wiz_run4);
    ai.ai_run(16);
}

pub export fn wiz_run4() void {
    state(.fly4, wiz_run5);
    ai.ai_run(16);
}

pub export fn wiz_run5() void {
    state(.fly5, wiz_run6);
    ai.ai_run(16);
}

pub export fn wiz_run6() void {
    state(.fly6, wiz_run7);
    ai.ai_run(16);
}

pub export fn wiz_run7() void {
    state(.fly7, wiz_run8);
    ai.ai_run(16);
}

pub export fn wiz_run8() void {
    state(.fly8, wiz_run9);
    ai.ai_run(16);
}

pub export fn wiz_run9() void {
    state(.fly9, wiz_run10);
    ai.ai_run(16);
}

pub export fn wiz_run10() void {
    state(.fly10, wiz_run11);
    ai.ai_run(16);
}

pub export fn wiz_run11() void {
    state(.fly11, wiz_run12);
    ai.ai_run(16);
}

pub export fn wiz_run12() void {
    state(.fly12, wiz_run13);
    ai.ai_run(16);
}

pub export fn wiz_run13() void {
    state(.fly13, wiz_run14);
    ai.ai_run(16);
}

pub export fn wiz_run14() void {
    state(.fly14, wiz_run1);
    ai.ai_run(16);
}

pub export fn wiz_fast1() void {
    state(.magatt1, wiz_fast2);
    fight.ai_face();
    Wiz_StartFast();
}

pub export fn wiz_fast2() void {
    state(.magatt2, wiz_fast3);
    fight.ai_face();
}

pub export fn wiz_fast3() void {
    state(.magatt3, wiz_fast4);
    fight.ai_face();
}

pub export fn wiz_fast4() void {
    state(.magatt4, wiz_fast5);
    fight.ai_face();
}

pub export fn wiz_fast5() void {
    state(.magatt5, wiz_fast6);
    fight.ai_face();
}

pub export fn wiz_fast6() void {
    state(.magatt6, wiz_fast7);
    fight.ai_face();
}

pub export fn wiz_fast7() void {
    state(.magatt5, wiz_fast8);
    fight.ai_face();
}

pub export fn wiz_fast8() void {
    state(.magatt4, wiz_fast9);
    fight.ai_face();
}

pub export fn wiz_fast9() void {
    state(.magatt3, wiz_fast10);
    fight.ai_face();
}

pub export fn wiz_fast10() void {
    state(.magatt2, wiz_run1);
    fight.ai_face();
    subs.SUB_AttackFinished(2);
    WizardAttackFinished();
}

pub export fn wiz_pain1() void {
    state(.pain1, wiz_pain2);
}

pub export fn wiz_pain2() void {
    state(.pain2, wiz_pain3);
}

pub export fn wiz_pain3() void {
    state(.pain3, wiz_pain4);
}

pub export fn wiz_pain4() void {
    state(.pain4, wiz_run1);
}

pub export fn wiz_death1() void {
    state(.death1, wiz_death2);
    const self = q.me();

    self.velocity[0] = -200 + 400 * q.random();
    self.velocity[1] = -200 + 400 * q.random();
    self.velocity[2] = 100 + 100 * q.random();
    self.flags = self.flags - q.band(self.flags, lq.FL_ONGROUND);
    q.sound(self, lq.CHAN_VOICE, S("wizard/wdeath.wav"), 1, lq.ATTN_NORM);
}

pub export fn wiz_death2() void {
    state(.death2, wiz_death3);
}

pub export fn wiz_death3() void {
    state(.death3, wiz_death4);
    q.me().solid = lq.SOLID_NOT;
}

pub export fn wiz_death4() void {
    state(.death4, wiz_death5);
}

pub export fn wiz_death5() void {
    state(.death5, wiz_death6);
}

pub export fn wiz_death6() void {
    state(.death6, wiz_death7);
}

pub export fn wiz_death7() void {
    state(.death7, wiz_death8);
}

pub export fn wiz_death8() void {
    state(.death8, wiz_death8);
}

pub export fn wiz_die() void {
    const self = q.me();
    // check for gib
    if (self.health < -40) {
        q.sound(self, lq.CHAN_VOICE, S("player/udeath.wav"), 1, lq.ATTN_NORM);
        player.ThrowHead(S("progs/h_wizard.mdl"), self.health);
        player.ThrowGib(S("progs/gib2.mdl"), self.health);
        player.ThrowGib(S("progs/gib2.mdl"), self.health);
        player.ThrowGib(S("progs/gib2.mdl"), self.health);
        return;
    }

    wiz_death1();
}

pub export fn Wiz_Pain(attacker: Entity, damage: f32) void {
    _ = attacker;
    q.sound(q.me(), lq.CHAN_VOICE, S("wizard/wpain.wav"), 1, lq.ATTN_NORM);
    if (q.random() * 70 > damage)
        return; // didn't flinch

    wiz_pain1();
}

pub export fn Wiz_Missile() void {
    wiz_fast1();
}

/// QUAKED monster_wizard (1 0 0) (-16 -16 -24) (16 16 40) Ambush
/// {
///     model({"path": "progs/wizard.mdl", "skin": 0, "frame": 0});
/// }
pub export fn monster_wizard() void {
    const self = q.me();
    if (q.deathmatch.get() != 0) {
        q.remove(self);
        return;
    }

    _ = q.precache_model(S("progs/wizard.mdl"));
    _ = q.precache_model(S("progs/h_wizard.mdl"));
    _ = q.precache_model(S("progs/w_spike.mdl"));

    _ = q.precache_sound(S("wizard/hit.wav")); // used by c code
    _ = q.precache_sound(S("wizard/wattack.wav"));
    _ = q.precache_sound(S("wizard/wdeath.wav"));
    _ = q.precache_sound(S("wizard/widle1.wav"));
    _ = q.precache_sound(S("wizard/widle2.wav"));
    _ = q.precache_sound(S("wizard/wpain.wav"));
    _ = q.precache_sound(S("wizard/wsight.wav"));

    self.solid = lq.SOLID_SLIDEBOX;
    self.movetype = lq.MOVETYPE_STEP;

    q.setmodel(self, S("progs/wizard.mdl"));

    //gnounc
    self.noise = S("wizard/wsight.wav"); //gnounc
    self.netname = S("Scrag");
    self.set(lq.killstring, S(loc.LOC_DEATH_WIZARD));

    q.setsize(self, q.vec(-16, -16, -24), q.vec(16, 16, 40));
    self.health = 80;
    self.max_health = 80;

    self.set(lq.th_stand, q.func(wiz_stand1));
    self.set(lq.th_walk, q.func(wiz_walk1));
    self.set(lq.th_run, q.func(wiz_run1));
    self.set(lq.th_missile, q.func(Wiz_Missile));
    self.set(lq.th_pain, q.func(Wiz_Pain));
    self.set(lq.th_die, q.func(wiz_die));

    monsters.flymonster_start();
}
