//! weapons.qc
//!
//! Copyright (C) 1996-1997  Id Software, Inc.
//!
//! This program is free software; you can redistribute it and/or modify
//! it under the terms of the GNU General Public License as published by
//! the Free Software Foundation; either version 2 of the License, or
//! (at your option) any later version.
//!
//! This program is distributed in the hope that it will be useful,
//! but WITHOUT ANY WARRANTY; without even the implied warranty of
//! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//! GNU General Public License for more details.
//!
//! You should have received a copy of the GNU General Public License
//! along with this program; if not, write to the Free Software
//! Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//!
//! See file, 'COPYING', for details.

const q = @import("defs.zig");
const lq = @import("lq.zig");
const loc = @import("localized_text.zig");
const S = q.S;
const Entity = q.Entity;
const Function = q.Function;
const String = q.String;
const Vector = q.Vector;
const subs = @import("subs.zig");
const combat = @import("combat.zig");
const player = @import("player.zig");
const deathmatch_settings = @import("deathmatch_settings.zig");
const cutscene_camera = @import("lq1/cutscene_camera.zig");

/// called by worldspawn
pub export fn W_Precache() void {
    _ = q.precache_sound(S("weapons/r_exp3.wav")); // new rocket explosion
    _ = q.precache_sound(S("weapons/rocket1i.wav")); // spike gun
    _ = q.precache_sound(S("weapons/sgun1.wav"));
    _ = q.precache_sound(S("weapons/guncock.wav")); // player shotgun
    _ = q.precache_sound(S("weapons/ric1.wav")); // ricochet (used in c code)
    _ = q.precache_sound(S("weapons/ric2.wav")); // ricochet (used in c code)
    _ = q.precache_sound(S("weapons/ric3.wav")); // ricochet (used in c code)
    _ = q.precache_sound(S("weapons/spike2.wav")); // super spikes
    _ = q.precache_sound(S("weapons/tink1.wav")); // spikes tink (used in c code)
    _ = q.precache_sound(S("weapons/grenade.wav")); // grenade launcher
    _ = q.precache_sound(S("weapons/bounce.wav")); // grenade bounce
    _ = q.precache_sound(S("weapons/shotgn2.wav")); // super shotgun
}

pub export fn crandom() f32 {
    return 2 * (q.random() - 0.5);
}

pub export fn wall_velocity() Vector {
    const self = q.me();
    var vel: Vector = undefined;

    vel = q.normalize(self.velocity);
    vel = q.normalize(vel + q.scale(q.v_up.get(), q.random() - 0.5) + q.scale(q.v_right.get(), q.random() - 0.5));
    vel = vel + q.scale(q.trace_plane_normal.get(), 2);
    vel = q.scale(vel, 200);

    return vel;
}

/// SpawnMeatSpray
pub export fn SpawnMeatSpray(org: Vector, vel: Vector) void {
    const self = q.me();

    const missile = q.spawn();
    missile.owner = self;
    missile.movetype = lq.MOVETYPE_BOUNCE;
    missile.solid = lq.SOLID_NOT;

    subs.makevectors2(self.angles);

    missile.velocity = vel;
    missile.velocity[2] = missile.velocity[2] + 250 + 50 * q.random();

    missile.avelocity = q.vec(3000, 1000, 2000);

    // set missile duration
    missile.nextthink = q.time.get() + 1;
    missile.think = q.func(subs.SUB_Remove);

    q.setmodel(missile, S("progs/zom_gib.mdl"));
    q.setsize(missile, q.vec(0, 0, 0), q.vec(0, 0, 0));
    q.setorigin(missile, org);
}

/// SpawnBlood
pub export fn SpawnBlood(org: Vector, vel: Vector, damage: f32) void {
    q.particle(org, q.scale(vel, 0.1), 73, damage * 2);
}

/// SpawnPuff
pub export fn SpawnPuff(org: Vector, count: f32) void {
    _ = count;
    q.WriteByte(lq.MSG_BROADCAST, lq.SVC_TEMPENTITY);
    q.WriteByte(lq.MSG_BROADCAST, lq.TE_GUNSHOT);
    q.WriteCoord(lq.MSG_BROADCAST, org[0]);
    q.WriteCoord(lq.MSG_BROADCAST, org[1]);
    q.WriteCoord(lq.MSG_BROADCAST, org[2]);
}

/// spawn_touchblood
pub export fn spawn_touchblood(damage: f32) void {
    const self = q.me();

    const vel = q.scale(wall_velocity(), 0.2);
    SpawnBlood(self.origin + q.scale(vel, 0.01), vel, damage);
}

pub export fn SmallKick() void {
    q.me().punchangle[0] = -2;
}

pub export fn BigKick() void {
    q.me().punchangle[0] = -4;
}

/// W_FireAxe
pub export fn W_FireAxe() void {
    const self = q.me();

    q.makevectors(self.v_angle);
    const source = self.origin + q.vec(0, 0, 22);
    q.traceline(source, source + q.scale(q.v_forward.get(), 64), lq.FALSE, self);
    if (q.trace_fraction.get() == 1.0)
        return;

    const org = q.trace_endpos.get() - q.scale(q.v_forward.get(), 4);

    if (q.trace_ent.get().takedamage != 0) {
        q.trace_ent.get().set(lq.axhitme, 1);
        SpawnBlood(org, q.vec(0, 0, 0), 20);
        q.trace_ent.get().set(lq.deathtype, S("axe"));
        if (deathmatch_settings.deathmatch_buffed_axe() != 0)
            combat.T_Damage(q.trace_ent.get(), self, self, 75)
        else
            combat.T_Damage(q.trace_ent.get(), self, self, 20);
    } else { // hit wall
        q.sound(self, lq.CHAN_WEAPON, S("player/axhit2.wav"), 1, lq.ATTN_NORM);
        SpawnPuff(org, 3);
    }
}

// ==============================================================================
//
// MULTI-DAMAGE
//
// Collects multiple small damages into a single damage
//
// ==============================================================================

pub const multi_ent = q.userGlobal(Entity, "multi_ent");

pub const multi_damage = q.userGlobal(f32, "multi_damage");

pub export fn ClearMultiDamage() void {
    multi_ent.set(q.world.get());
    multi_damage.set(0);
}

pub export fn ApplyMultiDamage() void {
    if (multi_ent.get().isNull())
        return;

    const self = q.me();
    combat.T_Damage(multi_ent.get(), self, self, multi_damage.get());
}

pub export fn AddMultiDamage(hit: Entity, damage: f32) void {
    if (hit.isNull())
        return;

    if (hit.neq(multi_ent.get())) {
        ApplyMultiDamage();
        multi_damage.set(damage);
        multi_ent.set(hit);
    } else multi_damage.set(multi_damage.get() + damage);
}

// ==============================================================================
//
// BULLETS
//
// ==============================================================================

/// TraceAttack
pub export fn TraceAttack(damage: f32, dir: Vector, dtype: String) void {
    var vel: Vector = undefined;

    vel = q.normalize(dir + q.scale(q.v_up.get(), crandom()) + q.scale(q.v_right.get(), crandom()));
    vel = vel + q.scale(q.trace_plane_normal.get(), 2);
    vel = q.scale(vel, 200);

    const org = q.trace_endpos.get() - q.scale(dir, 4);

    if (q.trace_ent.get().takedamage != 0) {
        SpawnBlood(org, q.scale(vel, 0.2), damage);

        q.trace_ent.get().set(lq.deathtype, dtype);
        AddMultiDamage(q.trace_ent.get(), damage);
    } else {
        SpawnPuff(org, 1);
    }
}

/// FireBullets
///
/// Used by shotgun, super shotgun, and enemy soldier firing
/// Go to the trouble of combining multiple pellets into a single damage call.
pub export fn FireBullets(shotcount: f32, dir: Vector, spread: Vector, dtype: String) void {
    const self = q.me();
    var count = shotcount;

    q.makevectors(self.v_angle);

    const src = self.origin + q.scale(q.v_forward.get(), 10) + q.vec(0, 0, 22);

    ClearMultiDamage();

    while (count > 0) {
        const direction = dir + q.scale(q.v_right.get(), crandom() * spread[0]) + q.scale(q.v_up.get(), crandom() * spread[1]);

        q.traceline(src, src + q.scale(direction, 2048), lq.FALSE, self);
        if (q.trace_fraction.get() != 1.0)
            TraceAttack(4, direction, dtype);

        count = count - 1;
    }
    ApplyMultiDamage();
}

/// W_FireShotgun
pub export fn W_FireShotgun() void {
    const self = q.me();

    q.sound(self, lq.CHAN_WEAPON, S("weapons/guncock.wav"), 1, lq.ATTN_NORM);

    SmallKick();

    if (deathmatch_settings.deathmatch_unlimited_ammo() == 0) {
        self.ammo_shells = self.ammo_shells - 1;
        self.currentammo = self.ammo_shells;
    }

    const dir = q.aim(self, 100000);
    FireBullets(6, dir, q.vec(0.04, 0.04, 0), S("shotgun"));
}

/// W_FireSuperShotgun
pub export fn W_FireSuperShotgun() void {
    const self = q.me();

    if (self.currentammo == 1) {
        W_FireShotgun();
        return;
    }

    q.sound(self, lq.CHAN_WEAPON, S("weapons/shotgn2.wav"), 1, lq.ATTN_NORM);

    BigKick();

    if (deathmatch_settings.deathmatch_unlimited_ammo() == 0) {
        self.ammo_shells = self.ammo_shells - 2;
        self.currentammo = self.ammo_shells;
    }

    const dir = q.aim(self, 100000);
    FireBullets(14, dir, q.vec(0.14, 0.08, 0), S("supershotgun"));
}

// ==============================================================================
//
// ROCKETS
//
// ==============================================================================

pub export fn s_explode1() void {
    q.setState(0, q.func(s_explode2));
}

pub export fn s_explode2() void {
    q.setState(1, q.func(s_explode3));
}

pub export fn s_explode3() void {
    q.setState(2, q.func(s_explode4));
}

pub export fn s_explode4() void {
    q.setState(3, q.func(s_explode5));
}

pub export fn s_explode5() void {
    q.setState(4, q.func(s_explode6));
}

pub export fn s_explode6() void {
    q.setState(5, q.func(subs.SUB_Remove));
}

pub export fn BecomeExplosion() void {
    const self = q.me();
    self.movetype = lq.MOVETYPE_NONE;
    self.velocity = q.vec(0, 0, 0);
    self.touch = null;
    q.setmodel(self, S("progs/s_explod.spr"));
    self.solid = lq.SOLID_NOT;
    s_explode1();
}

pub export fn MissileExplode() void {
    const self = q.me();
    q.WriteByte(lq.MSG_BROADCAST, lq.SVC_TEMPENTITY);
    q.WriteByte(lq.MSG_BROADCAST, lq.TE_EXPLOSION);
    q.WriteCoord(lq.MSG_BROADCAST, self.origin[0]);
    q.WriteCoord(lq.MSG_BROADCAST, self.origin[1]);
    q.WriteCoord(lq.MSG_BROADCAST, self.origin[2]);

    BecomeExplosion();
}

pub export fn T_MissileTouch() void {
    const self = q.me();
    const other = q.other.get();

    if (other.eql(self.owner))
        return; // don't explode on owner

    if (self.get(lq.voided) != 0) {
        return;
    }
    self.set(lq.voided, 1);

    if (q.pointcontents(self.origin) == lq.CONTENT_SKY) {
        q.remove(self);
        return;
    }

    var damg = 100 + q.random() * 20;

    if (other.health != 0) {
        other.set(lq.deathtype, S("rocket"));
        if (other.classname.eql(S("monster_shambler")))
            damg = damg * 0.5; // mostly immune
        combat.T_Damage(other, self, self.owner, damg);
    }

    // don't do radius damage to the other, because all the damage
    // was done in the impact
    combat.T_RadiusDamage(self, self.owner, 120, other, S("rocket"));

    self.origin = self.origin - q.scale(q.normalize(self.velocity), 8);

    MissileExplode();
}

/// W_FireRocket
pub export fn W_FireRocket() void {
    const self = q.me();

    if (deathmatch_settings.deathmatch_unlimited_ammo() == 0) {
        self.ammo_rockets = self.ammo_rockets - 1;
        self.currentammo = self.ammo_rockets;
    }

    q.sound(self, lq.CHAN_WEAPON, S("weapons/sgun1.wav"), 1, lq.ATTN_NORM);

    SmallKick();

    lq.newmis.set(q.spawn());
    const newmis = lq.newmis.get();
    newmis.owner = self;
    newmis.movetype = lq.MOVETYPE_FLYMISSILE;
    newmis.solid = lq.SOLID_BBOX;

    // set missile speed
    q.makevectors(self.v_angle);
    newmis.velocity = q.aim(self, 1000);
    newmis.velocity = q.scale(newmis.velocity, 1000);
    newmis.angles = q.vectoangles(newmis.velocity);

    newmis.touch = q.func(T_MissileTouch);
    newmis.set(lq.voided, 0);

    // set missile duration
    newmis.nextthink = q.time.get() + 5;
    newmis.think = q.func(subs.SUB_Remove);
    newmis.classname = S("rocket");

    q.setmodel(newmis, S("progs/missile.mdl"));
    q.setsize(newmis, q.vec(0, 0, 0), q.vec(0, 0, 0));
    q.setorigin(newmis, self.origin + q.scale(q.v_forward.get(), 8) + q.vec(0, 0, 16));
}

// ===============================================================================
//
// LIGHTNING
//
// ===============================================================================

pub export fn LightningHit(from: Entity, damage: f32) void {
    q.particle(q.trace_endpos.get(), q.vec(0, 0, 100), 15, damage * 4);

    q.trace_ent.get().set(lq.deathtype, S("lightning"));
    combat.T_Damage(q.trace_ent.get(), from, from, damage);
}

/// LightningDamage
pub export fn LightningDamage(p1: Vector, p2: Vector, from: Entity, damage: f32) void {
    const self = q.me();
    var e1: Entity = undefined;
    var e2: Entity = undefined;
    var f: Vector = undefined;

    f = p2 - p1;
    _ = q.normalize(f);
    f[0] = 0 - f[1];
    f[1] = f[0];
    f[2] = 0;
    f = q.scale(f, 16);

    e1 = q.world.get();
    e2 = e1;

    q.traceline(p1, p2, lq.FALSE, self);
    if (q.trace_ent.get().takedamage != 0) {
        LightningHit(from, damage);
        if (self.classname.eql(S("player"))) {
            if (q.other.get().classname.eql(S("player")))
                q.trace_ent.get().velocity[2] = q.trace_ent.get().velocity[2] + 400;
        }
    }

    e1 = q.trace_ent.get();

    q.traceline(p1 + f, p2 + f, lq.FALSE, self);
    if (q.trace_ent.get().neq(e1) and q.trace_ent.get().takedamage != 0) {
        LightningHit(from, damage);
    }

    e2 = q.trace_ent.get();

    q.traceline(p1 - f, p2 - f, lq.FALSE, self);
    if (q.trace_ent.get().neq(e1) and q.trace_ent.get().neq(e2) and q.trace_ent.get().takedamage != 0) {
        LightningHit(from, damage);
    }
}

pub export fn W_FireLightning() void {
    const self = q.me();

    if (self.ammo_cells < 1) {
        self.weapon = W_BestWeapon();
        W_SetCurrentAmmo();
        return;
    }

    // explode if under water
    if (self.waterlevel > 1) {
        if (deathmatch_settings.deathmatch_supermode() or deathmatch_settings.deathmatch_supermode2()) {
            self.set(lq.deathtype, S("selfwater"));
            combat.T_Damage(self, self, self.owner, 4000);
        } else {
            const cells = self.ammo_cells;
            self.ammo_cells = 0;
            W_SetCurrentAmmo();
            combat.T_RadiusDamage(self, self, 35 * cells, q.world.get(), S("discharge"));
            return;
        }
    }

    if (self.get(lq.t_width) < q.time.get()) {
        q.sound(self, lq.CHAN_WEAPON, S("weapons/lhit.wav"), 1, lq.ATTN_NORM);
        self.set(lq.t_width, q.time.get() + 0.6);
    }

    SmallKick();

    if (deathmatch_settings.deathmatch_unlimited_ammo() == 0) {
        self.ammo_cells = self.ammo_cells - 1;
        self.currentammo = self.ammo_cells;
    }

    const org = self.origin + q.vec(0, 0, 16);

    q.traceline(org, org + q.scale(q.v_forward.get(), 600), lq.TRUE, self);

    q.WriteByte(lq.MSG_BROADCAST, lq.SVC_TEMPENTITY);
    q.WriteByte(lq.MSG_BROADCAST, lq.TE_LIGHTNING2);
    q.WriteEntity(lq.MSG_BROADCAST, self);
    q.WriteCoord(lq.MSG_BROADCAST, org[0]);
    q.WriteCoord(lq.MSG_BROADCAST, org[1]);
    q.WriteCoord(lq.MSG_BROADCAST, org[2]);
    q.WriteCoord(lq.MSG_BROADCAST, q.trace_endpos.get()[0]);
    q.WriteCoord(lq.MSG_BROADCAST, q.trace_endpos.get()[1]);
    q.WriteCoord(lq.MSG_BROADCAST, q.trace_endpos.get()[2]);

    LightningDamage(self.origin, q.trace_endpos.get() + q.scale(q.v_forward.get(), 4), self, 30);
}

//=============================================================================

pub export fn GrenadeExplode() void {
    const self = q.me();

    if (self.get(lq.voided) != 0) {
        return;
    }
    self.set(lq.voided, 1);

    combat.T_RadiusDamage(self, self.owner, 120, q.world.get(), S("grenade"));

    MissileExplode();
}

pub export fn GrenadeTouch() void {
    const self = q.me();
    const other = q.other.get();

    if (other.eql(self.owner))
        return; // don't explode on owner
    if (other.takedamage == lq.DAMAGE_AIM) {
        GrenadeExplode();
        return;
    }

    // This check fixes the sound effect bug when a grenade is riding a descending lift
    if (self.get(lq.count) == 0 or q.time.get() - self.get(lq.count) > 0.05) {
        q.sound(self, lq.CHAN_WEAPON, S("weapons/bounce.wav"), 1, lq.ATTN_NORM); // bounce sound
    }
    self.set(lq.count, q.time.get());

    if (q.veq(self.velocity, q.vec(0, 0, 0)))
        self.avelocity = q.vec(0, 0, 0);
}

/// W_FireGrenade
pub export fn W_FireGrenade() void {
    const self = q.me();

    if (deathmatch_settings.deathmatch_unlimited_ammo() == 0) {
        self.ammo_rockets = self.ammo_rockets - 1;
        self.currentammo = self.ammo_rockets;
    }

    q.sound(self, lq.CHAN_WEAPON, S("weapons/grenade.wav"), 1, lq.ATTN_NORM);

    SmallKick();

    lq.newmis.set(q.spawn());
    const newmis = lq.newmis.get();
    newmis.owner = self;
    newmis.movetype = lq.MOVETYPE_BOUNCE;
    newmis.solid = lq.SOLID_BBOX;
    newmis.classname = S("grenade");

    // set missile speed

    q.makevectors(self.v_angle);

    if (self.v_angle[0] != 0) {
        newmis.velocity = q.scale(q.v_forward.get(), 600) + q.scale(q.v_up.get(), 200) + q.scale(q.scale(q.v_right.get(), crandom()), 10) + q.scale(q.scale(q.v_up.get(), crandom()), 10);
    } else {
        newmis.velocity = q.aim(self, 10000);
        newmis.velocity = q.scale(newmis.velocity, 600);
        newmis.velocity[2] = 200;
    }

    newmis.avelocity = q.vec(300, 300, 300);

    newmis.angles = q.vectoangles(newmis.velocity);

    newmis.touch = q.func(GrenadeTouch);

    // set missile duration
    newmis.nextthink = q.time.get() + 2.5;
    newmis.think = q.func(GrenadeExplode);

    q.setmodel(newmis, S("progs/grenade.mdl"));
    q.setsize(newmis, q.vec(0, 0, 0), q.vec(0, 0, 0));
    q.setorigin(newmis, self.origin);
}

//=============================================================================

/// launch_spike
///
/// Used for both the player and the ogre
pub export fn launch_spike(org: Vector, dir: Vector) void {
    const self = q.me();

    lq.newmis.set(q.spawn());
    const newmis = lq.newmis.get();
    newmis.owner = self;
    newmis.movetype = lq.MOVETYPE_FLYMISSILE;
    newmis.solid = lq.SOLID_BBOX;

    newmis.angles = q.vectoangles(dir);

    newmis.touch = q.func(spike_touch);
    newmis.classname = S("spike");
    newmis.think = q.func(subs.SUB_Remove);
    newmis.nextthink = q.time.get() + 6;
    q.setmodel(newmis, S("progs/spike.mdl"));
    q.setsize(newmis, lq.VEC_ORIGIN, lq.VEC_ORIGIN);
    q.setorigin(newmis, org);

    newmis.velocity = q.scale(dir, 1000);
}

pub export fn W_FireSuperSpikes() void {
    const self = q.me();

    q.sound(self, lq.CHAN_WEAPON, S("weapons/spike2.wav"), 1, lq.ATTN_NORM);
    self.set(lq.attack_finished, q.time.get() + 0.2);

    if (deathmatch_settings.deathmatch_unlimited_ammo() == 0) {
        self.ammo_nails = self.ammo_nails - 2;
        self.currentammo = self.ammo_nails;
    }

    const dir = q.aim(self, 1000);
    launch_spike(self.origin + q.vec(0, 0, 16), dir);
    const newmis = lq.newmis.get();
    newmis.classname = S("super_spike"); //so we know the difference --gnounc
    newmis.touch = q.func(superspike_touch);
    q.setmodel(newmis, S("progs/s_spike.mdl"));
    q.setsize(newmis, lq.VEC_ORIGIN, lq.VEC_ORIGIN);

    SmallKick();
}

pub export fn W_FireSpikes(ox: f32) void {
    const self = q.me();

    q.makevectors(self.v_angle);

    if (self.ammo_nails >= 2 and self.weapon == lq.IT_SUPER_NAILGUN) {
        W_FireSuperSpikes();
        return;
    }

    if (self.ammo_nails < 1) {
        self.weapon = W_BestWeapon();
        W_SetCurrentAmmo();
        return;
    }

    q.sound(self, lq.CHAN_WEAPON, S("weapons/rocket1i.wav"), 1, lq.ATTN_NORM);
    self.set(lq.attack_finished, q.time.get() + 0.2);

    if (deathmatch_settings.deathmatch_unlimited_ammo() == 0) {
        self.ammo_nails = self.ammo_nails - 1;
        self.currentammo = self.ammo_nails;
    }

    const dir = q.aim(self, 1000);
    launch_spike(self.origin + q.vec(0, 0, 16) + q.scale(q.v_right.get(), ox), dir);

    SmallKick();
}

pub export fn spike_touch() void {
    const self = q.me();
    const other = q.other.get();
    var te_type: f32 = undefined;

    if (other.eql(self.owner))
        return;

    if (other.solid == lq.SOLID_TRIGGER)
        return; // trigger field, do nothing

    if (self.get(lq.voided) != 0) {
        return;
    }
    self.set(lq.voided, 1);

    if (q.pointcontents(self.origin) == lq.CONTENT_SKY) {
        q.remove(self);
        return;
    }

    // hit something that bleeds
    if (other.takedamage != 0) {
        spawn_touchblood(9);
        other.set(lq.deathtype, S("nail"));
        combat.T_Damage(other, self, self.owner, 9);
    } else {
        if (self.classname.eql(S("wizard_spike")))
            te_type = lq.TE_WIZSPIKE
        else if (self.classname.eql(S("knight_spike")))
            te_type = lq.TE_KNIGHTSPIKE
        else
            te_type = lq.TE_SPIKE;

        q.WriteByte(lq.MSG_BROADCAST, lq.SVC_TEMPENTITY);
        q.WriteByte(lq.MSG_BROADCAST, te_type);
        q.WriteCoord(lq.MSG_BROADCAST, self.origin[0]);
        q.WriteCoord(lq.MSG_BROADCAST, self.origin[1]);
        q.WriteCoord(lq.MSG_BROADCAST, self.origin[2]);
    }

    q.remove(self);
}

pub export fn superspike_touch() void {
    const self = q.me();
    const other = q.other.get();

    if (other.eql(self.owner))
        return;

    if (other.solid == lq.SOLID_TRIGGER)
        return; // trigger field, do nothing

    if (self.get(lq.voided) != 0) {
        return;
    }
    self.set(lq.voided, 1);

    if (q.pointcontents(self.origin) == lq.CONTENT_SKY) {
        q.remove(self);
        return;
    }

    // hit something that bleeds
    if (other.takedamage != 0) {
        spawn_touchblood(18);
        other.set(lq.deathtype, S("supernail"));
        combat.T_Damage(other, self, self.owner, 18);
    } else {
        q.WriteByte(lq.MSG_BROADCAST, lq.SVC_TEMPENTITY);
        q.WriteByte(lq.MSG_BROADCAST, lq.TE_SUPERSPIKE);
        q.WriteCoord(lq.MSG_BROADCAST, self.origin[0]);
        q.WriteCoord(lq.MSG_BROADCAST, self.origin[1]);
        q.WriteCoord(lq.MSG_BROADCAST, self.origin[2]);
    }

    q.remove(self);
}

// ===============================================================================
//
// PLAYER WEAPON USE
//
// ===============================================================================

pub export fn W_SetCurrentAmmo() void {
    const self = q.me();

    player.player_run(); // get out of any weapon firing states
    self.weaponframe = 0;

    self.items = self.items - q.band(self.items, q.bor(q.bor(q.bor(lq.IT_SHELLS, lq.IT_NAILS), lq.IT_ROCKETS), lq.IT_CELLS));

    if (self.weapon == lq.IT_AXE) {
        self.currentammo = 0;
        self.weaponmodel = S("progs/v_axe.mdl");
    } else if (self.weapon == lq.IT_SHOTGUN) {
        self.currentammo = self.ammo_shells;
        self.weaponmodel = S("progs/v_shot.mdl");
        self.items = q.bor(self.items, lq.IT_SHELLS);
    } else if (self.weapon == lq.IT_SUPER_SHOTGUN) {
        self.currentammo = self.ammo_shells;
        self.weaponmodel = S("progs/v_shot2.mdl");
        self.items = q.bor(self.items, lq.IT_SHELLS);
    } else if (self.weapon == lq.IT_NAILGUN) {
        self.currentammo = self.ammo_nails;
        self.weaponmodel = S("progs/v_nail.mdl");
        self.items = q.bor(self.items, lq.IT_NAILS);
    } else if (self.weapon == lq.IT_SUPER_NAILGUN) {
        self.currentammo = self.ammo_nails;
        self.weaponmodel = S("progs/v_nail2.mdl");
        self.items = q.bor(self.items, lq.IT_NAILS);
    } else if (self.weapon == lq.IT_GRENADE_LAUNCHER) {
        self.currentammo = self.ammo_rockets;
        self.weaponmodel = S("progs/v_rock.mdl");
        self.items = q.bor(self.items, lq.IT_ROCKETS);
    } else if (self.weapon == lq.IT_ROCKET_LAUNCHER) {
        self.currentammo = self.ammo_rockets;
        self.weaponmodel = S("progs/v_rock2.mdl");
        self.items = q.bor(self.items, lq.IT_ROCKETS);
    } else if (self.weapon == lq.IT_LIGHTNING) {
        self.currentammo = self.ammo_cells;
        self.weaponmodel = S("progs/v_light.mdl");
        self.items = q.bor(self.items, lq.IT_CELLS);
    } else {
        self.currentammo = 0;
        self.weaponmodel = lq.string_null.get();
    }
}

pub export fn W_BestWeapon() f32 {
    const self = q.me();

    const it = self.items;

    if (self.waterlevel < 1 and self.ammo_cells >= 1 and q.has(it, lq.IT_LIGHTNING))
        return lq.IT_LIGHTNING
    else if (self.ammo_nails >= 2 and q.has(it, lq.IT_SUPER_NAILGUN))
        return lq.IT_SUPER_NAILGUN
    else if (self.ammo_shells >= 2 and q.has(it, lq.IT_SUPER_SHOTGUN))
        return lq.IT_SUPER_SHOTGUN
    else if (self.ammo_nails >= 1 and q.has(it, lq.IT_NAILGUN))
        return lq.IT_NAILGUN
    else if (self.ammo_shells >= 1 and q.has(it, lq.IT_SHOTGUN))
        return lq.IT_SHOTGUN;

    return lq.IT_AXE;
}

//gnounc
//wanted to get rid of the horrible triple negative when reading the call to checkNoAmmo.
//also it was unclear what checkNoAmmo should return for no ammo
pub export fn W_hasNoAmmo() f32 {
    const self = q.me();

    if (self.currentammo != 0)
        return lq.FALSE; //player has ammo --gnounc

    if (self.weapon == lq.IT_AXE)
        return lq.FALSE; //the axe doesnt need ammo. so we lie. Player Totally has ammo..Promise! --gnounc

    self.weapon = W_BestWeapon();

    W_SetCurrentAmmo();

    // drop the weapon down
    return lq.TRUE;
}

/// W_Attack
///
/// An attack impulse can be triggered now
pub export fn W_Attack() void {
    const self = q.me();

    if (W_hasNoAmmo() != 0)
        return;

    q.makevectors(self.v_angle); // calculate forward angle for velocity
    self.set(lq.show_hostile, q.time.get() + 1); // wake monsters up

    if (self.weapon == lq.IT_AXE) {
        q.sound(self, lq.CHAN_WEAPON, S("weapons/ax1.wav"), 1, lq.ATTN_NORM);
        const r = q.random();
        if (r < 0.25)
            player.player_axe1()
        else if (r < 0.5)
            player.player_axeb1()
        else if (r < 0.75)
            player.player_axec1()
        else
            player.player_axed1();
        self.set(lq.attack_finished, q.time.get() + 0.5);
    } else if (self.weapon == lq.IT_SHOTGUN) {
        player.player_shot1();
        W_FireShotgun();
        self.set(lq.attack_finished, q.time.get() + 0.5);
    } else if (self.weapon == lq.IT_SUPER_SHOTGUN) {
        player.player_shot1();
        W_FireSuperShotgun();
        self.set(lq.attack_finished, q.time.get() + 0.7);
    } else if (self.weapon == lq.IT_NAILGUN) {
        player.player_nail1();
    } else if (self.weapon == lq.IT_SUPER_NAILGUN) {
        player.player_nail1();
    } else if (self.weapon == lq.IT_GRENADE_LAUNCHER) {
        player.player_rocket1();
        W_FireGrenade();
        self.set(lq.attack_finished, q.time.get() + 0.6);
    } else if (self.weapon == lq.IT_ROCKET_LAUNCHER) {
        player.player_rocket1();
        W_FireRocket();
        self.set(lq.attack_finished, q.time.get() + 0.8);
    } else if (self.weapon == lq.IT_LIGHTNING) {
        player.player_light1();
        self.set(lq.attack_finished, q.time.get() + 0.1);
        q.sound(self, lq.CHAN_AUTO, S("weapons/lstart.wav"), 1, lq.ATTN_NORM);
    }
}

/// W_ChangeWeapon
/// cypress (07 feb 2024) -- added wep parm
pub export fn W_ChangeWeapon(wep: f32) void {
    const self = q.me();
    var fl: f32 = undefined;
    var am: f32 = undefined;

    fl = self.items;
    am = 0;

    // cypress (07 feb 2024) -- made a switch statement.
    switch (@as(i32, @intFromFloat(wep))) {
        1 => {
            fl = lq.IT_AXE;
        },
        2 => {
            fl = lq.IT_SHOTGUN;

            if (self.ammo_shells < 1)
                am = 1;
        },
        3 => {
            fl = lq.IT_SUPER_SHOTGUN;

            if (self.ammo_shells < 2)
                am = 1;
        },
        4 => {
            fl = lq.IT_NAILGUN;

            if (self.ammo_nails < 1)
                am = 1;
        },
        5 => {
            fl = lq.IT_SUPER_NAILGUN;

            if (self.ammo_nails < 2)
                am = 1;
        },
        6 => {
            fl = lq.IT_GRENADE_LAUNCHER;

            if (self.ammo_rockets < 1)
                am = 1;
        },
        7 => {
            fl = lq.IT_ROCKET_LAUNCHER;

            if (self.ammo_rockets < 1)
                am = 1;
        },
        8 => {
            fl = lq.IT_LIGHTNING;

            if (self.ammo_cells < 1)
                am = 1;
        },
        else => {},
    }
    // cypress end

    if (!q.has(self.items, fl)) { // don't have the weapon or the ammo
        lq.sprint(self, lq.PRINT_HIGH, S(loc.LOC_WEAPON_INVALID));
        lq.sprint(self, lq.PRINT_HIGH, S("\n"));
        return;
    }

    if (am != 0) { // don't have the ammo
        lq.sprint(self, lq.PRINT_HIGH, S(loc.LOC_WEAPON_NOAMMO));
        lq.sprint(self, lq.PRINT_HIGH, S("\n"));
        return;
    }

    //
    // set weapon, set ammo
    //
    self.weapon = fl;
    W_SetCurrentAmmo();
}

/// CheatCommand
pub export fn CheatCommand() void {
    const self = q.me();

    if (q.deathmatch.get() != 0 or q.coop.get() != 0)
        return;

    self.ammo_rockets = 100;
    self.ammo_nails = 200;
    self.ammo_shells = 100;
    self.items = q.bor(q.bor(q.bor(q.bor(q.bor(q.bor(q.bor(q.bor(q.bor(self.items, lq.IT_AXE), lq.IT_SHOTGUN), lq.IT_SUPER_SHOTGUN), lq.IT_NAILGUN), lq.IT_SUPER_NAILGUN), lq.IT_GRENADE_LAUNCHER), lq.IT_ROCKET_LAUNCHER), lq.IT_KEY1), lq.IT_KEY2);

    self.ammo_cells = 100;
    self.items = q.bor(self.items, lq.IT_LIGHTNING);

    self.weapon = lq.IT_ROCKET_LAUNCHER;
    self.impulse = 0;
    W_SetCurrentAmmo();
}

/// CycleWeaponCommand
///
/// Go to the next weapon with ammo
pub export fn CycleWeaponCommand() void {
    const self = q.me();
    var am: f32 = undefined;

    const it = self.items;
    _ = it;
    self.impulse = 0;

    while (true) {
        am = 0;

        if (self.weapon == lq.IT_LIGHTNING) {
            self.weapon = lq.IT_AXE;
        } else if (self.weapon == lq.IT_AXE) {
            self.weapon = lq.IT_SHOTGUN;

            if (self.ammo_shells < 1)
                am = 1;
        } else if (self.weapon == lq.IT_SHOTGUN) {
            self.weapon = lq.IT_SUPER_SHOTGUN;

            if (self.ammo_shells < 2)
                am = 1;
        } else if (self.weapon == lq.IT_SUPER_SHOTGUN) {
            self.weapon = lq.IT_NAILGUN;

            if (self.ammo_nails < 1)
                am = 1;
        } else if (self.weapon == lq.IT_NAILGUN) {
            self.weapon = lq.IT_SUPER_NAILGUN;

            if (self.ammo_nails < 2)
                am = 1;
        } else if (self.weapon == lq.IT_SUPER_NAILGUN) {
            self.weapon = lq.IT_GRENADE_LAUNCHER;

            if (self.ammo_rockets < 1)
                am = 1;
        } else if (self.weapon == lq.IT_GRENADE_LAUNCHER) {
            self.weapon = lq.IT_ROCKET_LAUNCHER;

            if (self.ammo_rockets < 1)
                am = 1;
        } else if (self.weapon == lq.IT_ROCKET_LAUNCHER) {
            self.weapon = lq.IT_LIGHTNING;

            if (self.ammo_cells < 1)
                am = 1;
        }

        if (q.has(self.items, self.weapon) and am == 0) {
            W_SetCurrentAmmo();
            return;
        }
    }
}

/// CycleWeaponReverseCommand
///
/// Go to the prev weapon with ammo
pub export fn CycleWeaponReverseCommand() void {
    const self = q.me();
    var am: f32 = undefined;

    const it = self.items;
    self.impulse = 0;

    while (true) {
        am = 0;

        if (self.weapon == lq.IT_LIGHTNING) {
            self.weapon = lq.IT_ROCKET_LAUNCHER;

            if (self.ammo_rockets < 1)
                am = 1;
        } else if (self.weapon == lq.IT_ROCKET_LAUNCHER) {
            self.weapon = lq.IT_GRENADE_LAUNCHER;

            if (self.ammo_rockets < 1)
                am = 1;
        } else if (self.weapon == lq.IT_GRENADE_LAUNCHER) {
            self.weapon = lq.IT_SUPER_NAILGUN;

            if (self.ammo_nails < 2)
                am = 1;
        } else if (self.weapon == lq.IT_SUPER_NAILGUN) {
            self.weapon = lq.IT_NAILGUN;

            if (self.ammo_nails < 1)
                am = 1;
        } else if (self.weapon == lq.IT_NAILGUN) {
            self.weapon = lq.IT_SUPER_SHOTGUN;

            if (self.ammo_shells < 2)
                am = 1;
        } else if (self.weapon == lq.IT_SUPER_SHOTGUN) {
            self.weapon = lq.IT_SHOTGUN;

            if (self.ammo_shells < 1)
                am = 1;
        } else if (self.weapon == lq.IT_SHOTGUN) {
            self.weapon = lq.IT_AXE;
        } else if (self.weapon == lq.IT_AXE) {
            self.weapon = lq.IT_LIGHTNING;

            if (self.ammo_cells < 1)
                am = 1;
        }

        if (q.has(it, self.weapon) and am == 0) {
            W_SetCurrentAmmo();
            return;
        }
    }
}

/// ServerflagsCommand
///
/// Just for development
pub export fn ServerflagsCommand() void {
    q.serverflags.set(q.serverflags.get() * 2 + 1);
}

pub export fn QuadCheat() void {
    const self = q.me();

    if (q.deathmatch.get() != 0 or q.coop.get() != 0)
        return;

    self.set(lq.super_time, 1);
    self.set(lq.super_damage_finished, q.time.get() + 30);
    self.items = q.bor(self.items, lq.IT_QUAD);
    q.dprint(S("quad cheat\n"));
}

pub const ID_IMPULSE_CHEAT: f32 = 9;

pub const ID_IMPULSE_CYCLEFORWARD: f32 = 10;

pub const ID_IMPULSE_SERVERFLAGS: f32 = 11;

pub const ID_IMPULSE_CYCLEREVERSE: f32 = 12;

pub const ID_IMPULSE_QUADCHEAT: f32 = 255;

pub const LQ_IMPULSE_SPAWNCAM: f32 = 200;

pub const LQ_IMPULSE_CAMTIMEINC: f32 = 201;

pub const LQ_IMPULSE_CAMTIMEDEC: f32 = 202;

pub const LQ_IMPULSE_PLAYCAMERAS: f32 = 203;

pub export fn ImpulseCommands() void {
    const self = q.me();

    // cypress (07 feb 2024) -- pass self.impulse
    // to W_ChangeWeapon for a small perf boost.
    if (self.impulse >= 1 and self.impulse <= 8)
        W_ChangeWeapon(self.impulse);

    // cypress (07 feb 2024) -- made a switch
    // The original has two `case LQ_IMPULSE_CAMTIMEDEC:` labels (the first was
    // presumably meant to be LQ_IMPULSE_CAMTIMEINC). The first one wins, so the
    // second (`LQ_AppendCameraTime(-5)`) is unreachable.
    const impulse = self.impulse;
    if (impulse == ID_IMPULSE_CHEAT) {
        CheatCommand();
    } else if (impulse == ID_IMPULSE_CYCLEFORWARD) {
        CycleWeaponCommand();
    } else if (impulse == ID_IMPULSE_SERVERFLAGS) {
        ServerflagsCommand();
    } else if (impulse == ID_IMPULSE_CYCLEREVERSE) {
        CycleWeaponReverseCommand();
    } else if (impulse == ID_IMPULSE_QUADCHEAT) {
        QuadCheat();
    } else if (impulse == LQ_IMPULSE_SPAWNCAM) {
        cutscene_camera.LQ_SpawnCamera();
    } else if (impulse == LQ_IMPULSE_CAMTIMEDEC) {
        cutscene_camera.LQ_AppendCameraTime(5);
    } else if (impulse == LQ_IMPULSE_PLAYCAMERAS) {
        cutscene_camera.LQ_PlayCameras();
    }

    self.impulse = 0;
}

/// W_WeaponFrame
///
/// Called every frame so impulse events can be handled as well as possible
pub export fn W_WeaponFrame() void {
    const self = q.me();

    if (q.time.get() < self.get(lq.attack_finished))
        return;

    if (self.impulse != 0) // gb, stop wasting performance
        ImpulseCommands();

    // check for attack
    if (self.button0 != 0) {
        SuperDamageSound();
        W_Attack();
    }
}

/// SuperDamageSound
///
/// Plays sound if needed
pub export fn SuperDamageSound() void {
    const self = q.me();

    if (self.get(lq.super_damage_finished) > q.time.get()) {
        if (self.get(lq.super_sound) < q.time.get()) {
            self.set(lq.super_sound, q.time.get() + 1);
            q.sound(self, lq.CHAN_BODY, S("items/damage3.wav"), 1, lq.ATTN_NORM);
        }
    }
    return;
}
