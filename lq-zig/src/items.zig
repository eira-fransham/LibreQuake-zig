//! items.qc
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
const weapons = @import("weapons.zig");
const deathmatch_settings = @import("deathmatch_settings.zig");

// ALL LIGHTS SHOULD BE 0 1 0 IN COLOR ALL OTHER ITEMS SHOULD
// BE .8 .3 .4 IN COLOR

pub export fn SUB_regen() void {
    const self = q.me();
    self.model = self.get(lq.mdl); // restore original model
    self.solid = lq.SOLID_TRIGGER; // allow it to be touched again
    q.sound(self, lq.CHAN_VOICE, S("items/itembk2.wav"), 1, lq.ATTN_NORM); // play respawn sound
    q.setorigin(self, self.origin);
}

/// QUAKED noclass (0 0 0) (-8 -8 -8) (8 8 8)
/// prints a warning message when spawned
pub export fn noclass() void {
    const self = q.me();
    q.dprint(S("noclass spawned at"));
    q.dprint(q.vtos(self.origin));
    q.dprint(S("\n"));
    q.remove(self);
}

// ================
// Dropped powerups
// ================

pub export fn q_touch() void {
    const self = q.me();
    const other = q.other.get();

    if (other.classname.neq(S("player")))
        return;
    if (other.health <= 0)
        return;

    self.set(lq.mdl, self.model);

    q.sound(other, lq.CHAN_VOICE, self.noise, 1, lq.ATTN_NORM);
    q.stuffcmd(other, S("bf\n"));
    self.solid = lq.SOLID_NOT;
    other.items = q.bor(other.items, lq.IT_QUAD);
    self.model = lq.string_null.get();
    if (q.deathmatch.get() == 4) {
        other.armortype = 0;
        other.armorvalue = 0 * 0.01;
        other.ammo_cells = 0;
    }

    // do the apropriate action
    other.set(lq.super_time, 1);
    other.set(lq.super_damage_finished, self.get(lq.cnt));

    const s = q.ftos(q.rint(other.get(lq.super_damage_finished) - q.time.get()));

    lq.bprint(lq.PRINT_LOW, other.netname);
    if (q.deathmatch.get() == 4)
        lq.bprint(lq.PRINT_LOW, S(" recovered an OctaPower with "))
    else
        lq.bprint(lq.PRINT_LOW, S(" recovered a Quad with "));
    lq.bprint(lq.PRINT_LOW, s);
    lq.bprint(lq.PRINT_LOW, S(" seconds remaining!\n"));

    lq.activator.set(other);
    subs.SUB_UseTargets(); // fire all targets / killtargets
}

pub export fn DropQuad(timeleft: f32) void {
    const self = q.me();
    const item = q.spawn();
    item.origin = self.origin;

    item.velocity[2] = 300;
    item.velocity[0] = -100 + (q.random() * 200);
    item.velocity[1] = -100 + (q.random() * 200);

    item.flags = lq.FL_ITEM;
    item.solid = lq.SOLID_TRIGGER;
    item.movetype = lq.MOVETYPE_TOSS;
    item.noise = S("items/damage.wav");
    q.setmodel(item, S("progs/quaddama.mdl"));
    q.setsize(item, q.vec(-16, -16, -24), q.vec(16, 16, 32));
    item.set(lq.cnt, q.time.get() + timeleft);
    item.touch = q.func(q_touch);
    item.nextthink = q.time.get() + timeleft; // remove it with the time left on it
    item.think = q.func(subs.SUB_Remove);
}

pub export fn r_touch() void {
    const self = q.me();
    const other = q.other.get();

    if (other.classname.neq(S("player")))
        return;
    if (other.health <= 0)
        return;

    self.set(lq.mdl, self.model);

    q.sound(other, lq.CHAN_VOICE, self.noise, 1, lq.ATTN_NORM);
    q.stuffcmd(other, S("bf\n"));
    self.solid = lq.SOLID_NOT;
    other.items = q.bor(other.items, lq.IT_INVISIBILITY);
    self.model = lq.string_null.get();

    // do the apropriate action
    other.set(lq.invisible_time, 1);
    other.set(lq.invisible_finished, self.get(lq.cnt));
    const s = q.ftos(q.rint(other.get(lq.invisible_finished) - q.time.get()));
    lq.bprint(lq.PRINT_LOW, other.netname);
    lq.bprint(lq.PRINT_LOW, S(" recovered a Ring with "));
    lq.bprint(lq.PRINT_LOW, s);
    lq.bprint(lq.PRINT_LOW, S(" seconds remaining!\n"));

    lq.activator.set(other);
    subs.SUB_UseTargets(); // fire all targets / killtargets
}

pub export fn DropRing(timeleft: f32) void {
    const self = q.me();
    const item = q.spawn();
    item.origin = self.origin;

    item.velocity[2] = 300;
    item.velocity[0] = -100 + (q.random() * 200);
    item.velocity[1] = -100 + (q.random() * 200);

    item.flags = lq.FL_ITEM;
    item.solid = lq.SOLID_TRIGGER;
    item.movetype = lq.MOVETYPE_TOSS;
    item.noise = S("items/inv1.wav");
    q.setmodel(item, S("progs/invisibl.mdl"));
    q.setsize(item, q.vec(-16, -16, -24), q.vec(16, 16, 32));
    item.set(lq.cnt, q.time.get() + timeleft);
    item.touch = q.func(r_touch);
    item.nextthink = q.time.get() + timeleft; // remove after 30 seconds
    item.think = q.func(subs.SUB_Remove);
}

/// PlaceItem
///
/// plants the object on the floor
pub export fn PlaceItem() void {
    const self = q.me();
    self.set(lq.mdl, self.model); // so it can be restored on respawn
    self.flags = lq.FL_ITEM; // make extra wide
    self.solid = lq.SOLID_TRIGGER;
    self.movetype = lq.MOVETYPE_TOSS;
    self.velocity = q.vec(0, 0, 0);
    self.origin[2] = self.origin[2] + 6;
    // (`oldz = self.origin_z;` is never used in the original.)

    if (q.droptofloor() == 0) {
        q.dprint(S("Bonus item fell out of level at "));
        q.dprint(q.vtos(self.origin));
        q.dprint(S("\n"));
        q.remove(self);

        return;
    }
}

/// StartItem
///
/// Sets the clipping size and plants the object on the floor
pub export fn StartItem() void {
    const self = q.me();
    self.nextthink = q.time.get() + 0.2; // items start after other solids
    self.think = q.func(PlaceItem);
}

// =========================================================================
//
// HEALTH BOX
//
// =========================================================================

/// T_Heal: add health to an entity, limiting health to max_health
/// "ignore" will ignore max_health limit
pub export fn T_Heal(e: Entity, healamount_: f32, ignore: f32) f32 {
    if (e.health <= 0)
        return 0;

    if ((ignore == 0) and (e.health >= e.max_health))
        return 0;

    const amount = q.ceil(healamount_);

    e.health = e.health + amount;

    if ((ignore == 0) and (e.health >= e.max_health))
        e.health = e.max_health;

    if (e.health > 250)
        e.health = 250;

    return 1;
}

/// QUAKED item_health (.3 .3 1) (0 0 0) (32 32 32) rotten megahealth
/// {
///     model({"path": "maps/b_bh10.bsp", "skin": 0, "frame": 0});
/// }
/// Health box. Normally gives 25 points.
/// Rotten box heals 5-10 points,
/// megahealth will add 100 health, then
/// rot you down to your maximum health limit,
/// one point per second.
pub const H_ROTTEN: f32 = 1;

pub const H_MEGA: f32 = 2;

pub const healamount = q.userField(f32, "healamount");

pub const healtype = q.userField(f32, "healtype");

pub export fn item_health() void {
    const self = q.me();
    if (deathmatch_settings.deathmatch_no_health() != 0)
        return;

    if (q.has(self.spawnflags, H_ROTTEN)) {
        _ = q.precache_model(S("maps/b_bh10.bsp"));

        _ = q.precache_sound(S("items/r_item1.wav"));
        q.setmodel(self, S("maps/b_bh10.bsp"));
        self.noise = S("items/r_item1.wav");
        self.set(healamount, 15);
        self.set(healtype, 0);
    } else if (q.has(self.spawnflags, H_MEGA)) {
        if (deathmatch_settings.deathmatch_no_mega_health() != 0)
            return;

        _ = q.precache_model(S("maps/b_bh100.bsp"));
        _ = q.precache_sound(S("items/r_item2.wav"));
        q.setmodel(self, S("maps/b_bh100.bsp"));
        self.noise = S("items/r_item2.wav");
        self.set(healamount, 100);
        self.set(healtype, 2);
    } else {
        _ = q.precache_model(S("maps/b_bh25.bsp"));
        _ = q.precache_sound(S("items/health1.wav"));
        q.setmodel(self, S("maps/b_bh25.bsp"));
        self.noise = S("items/health1.wav");
        self.set(healamount, 25);
        self.set(healtype, 1);
    }

    self.touch = q.func(health_touch);
    q.setsize(self, q.vec(0, 0, 0), q.vec(32, 32, 56));
    StartItem();
}

pub export fn health_touch() void {
    const self = q.me();
    const other = q.other.get();

    if (deathmatch_settings.deathmatch_supermode()) {
        if (other.get(lq.invincible_time) > 0)
            return;
    }

    if (other.classname.neq(S("player")))
        return;

    if (self.get(healtype) == 2) // Megahealth?  Ignore max_health...
    {
        if (other.health >= 250)
            return;
        if (T_Heal(other, self.get(healamount), 1) == 0)
            return;
    } else {
        if (T_Heal(other, self.get(healamount), 0) == 0)
            return;
    }

    lq.sprint(other, lq.PRINT_LOW, S(loc.LOC_ITEM_PICKUP_HEALTH));
    const s = q.ftos(self.get(healamount));
    lq.sprint(other, lq.PRINT_LOW, s);
    lq.sprint(other, lq.PRINT_LOW, S(loc.LOC_ITEM_TYPE_HEALTH));
    lq.sprint(other, lq.PRINT_LOW, S("\n"));

    // health touch sound
    q.sound(other, lq.CHAN_ITEM, self.noise, 1, lq.ATTN_NORM);

    q.stuffcmd(other, S("bf\n"));

    self.model = lq.string_null.get();
    self.solid = lq.SOLID_NOT;

    // Megahealth = rot down the player's super health
    if (self.get(healtype) == 2 and !deathmatch_settings.deathmatch_supermode()) {
        other.items = q.bor(other.items, lq.IT_SUPERHEALTH);
        self.owner = other;
        self.nextthink = q.time.get() + 5;
        self.think = q.func(item_megahealth_rot);
    } else {
        if (deathmatch_settings.deathmatch_item_respawn()) // deathmatch 2 is the silly old rules
        {
            self.nextthink = q.time.get() + 20;
            self.think = q.func(SUB_regen);
        }
    }

    lq.activator.set(other);
    subs.SUB_UseTargets(); // fire all targets / killtargets
}

pub export fn item_megahealth_rot() void {
    const self = q.me();
    q.other.set(self.owner);
    const other = q.other.get();

    if (other.health > other.max_health) {
        other.health = other.health - 1;
        self.nextthink = q.time.get() + 1;

        return;
    }

    // it is possible for a player to die and respawn between rots, so don't
    // just blindly subtract the flag off
    other.items = other.items - q.band(other.items, lq.IT_SUPERHEALTH);

    if (deathmatch_settings.deathmatch_item_respawn()) // deathmatch 2 is silly old rules
    {
        self.nextthink = q.time.get() + 20;
        self.think = q.func(SUB_regen);
    }
}

// ===============================================================================
//
// ARMOR
//
// ===============================================================================

pub export fn armor_touch() void {
    const self = q.me();
    const other = q.other.get();
    var @"type": f32 = 0.3;
    var value: f32 = 100;
    var bit: f32 = lq.IT_ARMOR1;

    if (other.health <= 0)
        return;

    if (other.classname.neq(S("player")))
        return;

    if (deathmatch_settings.deathmatch_supermode()) {
        if (other.get(lq.invincible_time) > 0)
            return;
    }

    // cypress (07 feb 2024) -- adopted switch
    if (self.classname.eql(S("item_armor1"))) {
        @"type" = 0.3;
        value = 100;
        bit = lq.IT_ARMOR1;
    } else if (self.classname.eql(S("item_armor2"))) {
        @"type" = 0.6;
        value = 150;
        bit = lq.IT_ARMOR2;
    } else if (self.classname.eql(S("item_armorInv"))) {
        @"type" = 0.8;
        value = 200;
        bit = lq.IT_ARMOR3;
    }

    if (other.armortype * other.armorvalue >= @"type" * value)
        return;

    other.armortype = @"type";
    other.armorvalue = value;
    other.items = other.items - q.band(other.items, q.bor(q.bor(lq.IT_ARMOR1, lq.IT_ARMOR2), lq.IT_ARMOR3)) + bit;

    self.solid = lq.SOLID_NOT;
    self.model = lq.string_null.get();

    if (deathmatch_settings.deathmatch_item_respawn())
        self.nextthink = q.time.get() + 20;

    self.think = q.func(SUB_regen);

    lq.sprint(other, lq.PRINT_LOW, S(loc.LOC_ITEM_PICKUP_NORMAL));
    lq.sprint(other, lq.PRINT_LOW, q.ftos(value));
    lq.sprint(other, lq.PRINT_LOW, S(loc.LOC_ITEM_TYPE_ARMOR));
    lq.sprint(other, lq.PRINT_LOW, S("\n"));

    // armor touch sound
    q.sound(other, lq.CHAN_ITEM, S("items/armor1.wav"), 1, lq.ATTN_NORM);
    q.stuffcmd(other, S("bf\n"));

    lq.activator.set(other);
    subs.SUB_UseTargets(); // fire all targets / killtargets
}

/// QUAKED item_armor1 (0 .5 .8) (-16 -16 0) (16 16 32)
/// {
///     model({"path": "progs/armor.mdl", "skin": 0, "frame": 0});
/// }
pub export fn item_armor1() void {
    const self = q.me();
    if (deathmatch_settings.deathmatch_no_armor() != 0)
        return;

    self.touch = q.func(armor_touch);
    _ = q.precache_model(S("progs/armor.mdl"));
    q.setmodel(self, S("progs/armor.mdl"));
    self.skin = 0;
    q.setsize(self, q.vec(-16, -16, 0), q.vec(16, 16, 56));
    StartItem();
}

/// QUAKED item_armor2 (0 .5 .8) (-16 -16 0) (16 16 32)
/// {
///     model({"path": "progs/armor.mdl", "skin": 1, "frame": 0});
/// }
pub export fn item_armor2() void {
    const self = q.me();
    if (deathmatch_settings.deathmatch_no_armor() != 0)
        return;

    self.touch = q.func(armor_touch);
    _ = q.precache_model(S("progs/armor.mdl"));
    q.setmodel(self, S("progs/armor.mdl"));
    self.skin = 1;
    q.setsize(self, q.vec(-16, -16, 0), q.vec(16, 16, 56));
    StartItem();
}

/// QUAKED item_armorInv (0 .5 .8) (-16 -16 0) (16 16 32)
/// {
///     model({"path": "progs/armor.mdl", "skin": 2, "frame": 0});
/// }
pub export fn item_armorInv() void {
    const self = q.me();
    if (deathmatch_settings.deathmatch_no_armor() != 0)
        return;

    self.touch = q.func(armor_touch);
    _ = q.precache_model(S("progs/armor.mdl"));
    q.setmodel(self, S("progs/armor.mdl"));
    self.skin = 2;
    q.setsize(self, q.vec(-16, -16, 0), q.vec(16, 16, 56));
    StartItem();
}

// ===============================================================================
//
// WEAPONS
//
// ===============================================================================

pub export fn bound_other_ammo() void {
    const other = q.other.get();
    if (deathmatch_settings.deathmatch_unlimited_ammo() != 0) {
        other.ammo_shells = 255;
        other.ammo_nails = 255;
        other.ammo_rockets = 255;
        other.ammo_cells = 255;
    } else {
        if (other.ammo_shells > 100)
            other.ammo_shells = 100;

        if (other.ammo_nails > 200)
            other.ammo_nails = 200;

        if (other.ammo_rockets > 100)
            other.ammo_rockets = 100;

        if (other.ammo_cells > 100)
            other.ammo_cells = 100;
    }
}

pub export fn RankForWeapon(w: f32) f32 {
    if (w == lq.IT_LIGHTNING)
        return 1;

    if (w == lq.IT_ROCKET_LAUNCHER)
        return 2;

    if (w == lq.IT_SUPER_NAILGUN)
        return 3;

    if (w == lq.IT_GRENADE_LAUNCHER)
        return 4;

    if (w == lq.IT_SUPER_SHOTGUN)
        return 5;

    if (w == lq.IT_NAILGUN)
        return 6;

    return 7;
}

//copypasta'd directly from gpl'd qw source on github.
pub export fn WeaponCode(w: f32) f32 {
    if (w == lq.IT_SUPER_SHOTGUN)
        return 3;

    if (w == lq.IT_NAILGUN)
        return 4;

    if (w == lq.IT_SUPER_NAILGUN)
        return 5;

    if (w == lq.IT_GRENADE_LAUNCHER)
        return 6;

    if (w == lq.IT_ROCKET_LAUNCHER)
        return 7;

    if (w == lq.IT_LIGHTNING)
        return 8;

    return 1;
}

/// Deathmatch_Weapon
///
/// Deathmatch weapon change rules for picking up a weapon
///
/// .float        ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
pub export fn Deathmatch_Weapon(old: f32, new: f32) void {
    _ = old;
    const self = q.me();

    // change self.weapon if desired
    const or_ = RankForWeapon(self.weapon);
    const nr = RankForWeapon(new);

    if (nr < or_)
        self.weapon = new;
}

/// weapon_touch
pub export fn weapon_touch() void {
    var self = q.me();
    const other = q.other.get();
    var new = other.items;

    if (!q.has(other.flags, lq.FL_CLIENT))
        return;

    // if the player was using his best weapon, change up to the new one if better
    var stemp = q.self.get();
    q.self.set(other);
    _ = weapons.W_BestWeapon(); // (`best` is never used in the original.)
    q.self.set(stemp);
    self = q.me();

    const leave: f32 = if (deathmatch_settings.deathmatch_weapon_stay() or q.coop.get() != 0) 1 else 0;

    // (`hadammo` is set in each case but never used in the original.)
    if (self.classname.eql(S("weapon_nailgun"))) {
        if (leave != 0 and q.has(other.items, lq.IT_NAILGUN))
            return;

        new = lq.IT_NAILGUN;
        other.ammo_nails = other.ammo_nails + 30;
    } else if (self.classname.eql(S("weapon_supernailgun"))) {
        if (leave != 0 and q.has(other.items, lq.IT_SUPER_NAILGUN))
            return;

        new = lq.IT_SUPER_NAILGUN;
        other.ammo_nails = other.ammo_nails + 30;
    } else if (self.classname.eql(S("weapon_supershotgun"))) {
        if (leave != 0 and q.has(other.items, lq.IT_SUPER_SHOTGUN))
            return;

        new = lq.IT_SUPER_SHOTGUN;
        other.ammo_shells = other.ammo_shells + 5;
    } else if (self.classname.eql(S("weapon_rocketlauncher"))) {
        if (leave != 0 and q.has(other.items, lq.IT_ROCKET_LAUNCHER))
            return;

        new = lq.IT_ROCKET_LAUNCHER;
        other.ammo_rockets = other.ammo_rockets + 5;
    } else if (self.classname.eql(S("weapon_grenadelauncher"))) {
        if (leave != 0 and q.has(other.items, lq.IT_GRENADE_LAUNCHER))
            return;

        new = lq.IT_GRENADE_LAUNCHER;
        other.ammo_rockets = other.ammo_rockets + 5;
    } else if (self.classname.eql(S("weapon_lightning"))) {
        if (leave != 0 and q.has(other.items, lq.IT_LIGHTNING))
            return;

        new = lq.IT_LIGHTNING;
        other.ammo_cells = other.ammo_cells + 15;
    } else q.objerror(S("weapon_touch: unknown classname"));

    lq.sprint(other, lq.PRINT_LOW, S(loc.LOC_ITEM_PICKUP_NORMAL));
    lq.sprint(other, lq.PRINT_LOW, S("the "));
    lq.sprint(other, lq.PRINT_LOW, self.netname);
    lq.sprint(other, lq.PRINT_LOW, S("\n"));
    // weapon touch sound
    q.sound(other, lq.CHAN_ITEM, S("weapons/pkup.wav"), 1, lq.ATTN_NORM);
    q.stuffcmd(other, S("bf\n"));

    bound_other_ammo();

    // change to the weapon
    const old = other.items;
    other.items = q.bor(other.items, new);

    stemp = q.self.get();
    q.self.set(other);
    self = q.me();

    if (q.deathmatch.get() == 0)
        self.weapon = new
    else
        Deathmatch_Weapon(old, new);

    weapons.W_SetCurrentAmmo();

    q.self.set(stemp);
    self = q.me();

    if (leave != 0)
        return;

    // remove it in single player, or setup for respawning in deathmatch
    self.model = lq.string_null.get();
    self.solid = lq.SOLID_NOT;

    if (q.deathmatch.get() != 0 and !deathmatch_settings.deathmatch_weapon_stay())
        self.nextthink = q.time.get() + 30;

    self.think = q.func(SUB_regen);

    lq.activator.set(other);
    subs.SUB_UseTargets(); // fire all targets / killtargets
}

/// QUAKED weapon_supershotgun (0 .5 .8) (-16 -16 0) (16 16 32)
/// {
///     model({"path": "progs/g_shot.mdl", "skin": 0, "frame": 0});
/// }
pub export fn weapon_supershotgun() void {
    const self = q.me();
    if (deathmatch_settings.deathmatch_no_weapons_on_map() != 0 or deathmatch_settings.deathmatch_no_super_shotgun_on_map() != 0)
        return;

    _ = q.precache_model(S("progs/g_shot.mdl"));
    q.setmodel(self, S("progs/g_shot.mdl"));
    self.weapon = lq.IT_SUPER_SHOTGUN;
    self.netname = S(loc.LOC_WEAPON_NAME_SUPER_SHOTGUN);
    self.touch = q.func(weapon_touch);
    q.setsize(self, q.vec(-16, -16, 0), q.vec(16, 16, 56));
    StartItem();
}

/// QUAKED weapon_nailgun (0 .5 .8) (-16 -16 0) (16 16 32)
/// {
///     model({"path": "progs/g_nail.mdl", "skin": 0, "frame": 0});
/// }
pub export fn weapon_nailgun() void {
    const self = q.me();
    if (deathmatch_settings.deathmatch_no_weapons_on_map() != 0 or deathmatch_settings.deathmatch_no_nailgun_on_map() != 0)
        return;

    _ = q.precache_model(S("progs/g_nail.mdl"));
    q.setmodel(self, S("progs/g_nail.mdl"));
    self.weapon = lq.IT_NAILGUN;
    self.netname = S(loc.LOC_WEAPON_NAME_NAILGUN);
    self.touch = q.func(weapon_touch);
    q.setsize(self, q.vec(-16, -16, 0), q.vec(16, 16, 56));
    StartItem();
}

/// QUAKED weapon_supernailgun (0 .5 .8) (-16 -16 0) (16 16 32)
/// {
///     model({"path": "progs/g_nail2.mdl", "skin": 0, "frame": 0});
/// }
pub export fn weapon_supernailgun() void {
    const self = q.me();
    if (deathmatch_settings.deathmatch_no_weapons_on_map() != 0 or deathmatch_settings.deathmatch_no_super_nailgun_on_map() != 0)
        return;

    _ = q.precache_model(S("progs/g_nail2.mdl"));
    q.setmodel(self, S("progs/g_nail2.mdl"));
    self.weapon = lq.IT_SUPER_NAILGUN;
    self.netname = S(loc.LOC_WEAPON_NAME_SUPER_NAILGUN);
    self.touch = q.func(weapon_touch);
    q.setsize(self, q.vec(-16, -16, 0), q.vec(16, 16, 56));
    StartItem();
}

/// QUAKED weapon_grenadelauncher (0 .5 .8) (-16 -16 0) (16 16 32)
/// {
///     model({"path": "progs/g_rock.mdl", "skin": 0, "frame": 0});
/// }
pub export fn weapon_grenadelauncher() void {
    const self = q.me();
    if (deathmatch_settings.deathmatch_no_weapons_on_map() != 0 or deathmatch_settings.deathmatch_no_grenade_launcher_on_map() != 0)
        return;

    _ = q.precache_model(S("progs/g_rock.mdl"));
    q.setmodel(self, S("progs/g_rock.mdl"));
    self.weapon = lq.IT_GRENADE_LAUNCHER;
    self.netname = S(loc.LOC_WEAPON_NAME_GRENADE_LAUNCH);
    self.touch = q.func(weapon_touch);
    q.setsize(self, q.vec(-16, -16, 0), q.vec(16, 16, 56));
    StartItem();
}

/// QUAKED weapon_rocketlauncher (0 .5 .8) (-16 -16 0) (16 16 32)
/// {
///     model({"path": "progs/g_rock2.mdl", "skin": 0, "frame": 0});
/// }
pub export fn weapon_rocketlauncher() void {
    const self = q.me();
    if (deathmatch_settings.deathmatch_no_weapons_on_map() != 0 or deathmatch_settings.deathmatch_no_rocket_launcher_on_map() != 0)
        return;

    _ = q.precache_model(S("progs/g_rock2.mdl"));
    q.setmodel(self, S("progs/g_rock2.mdl"));
    self.weapon = lq.IT_ROCKET_LAUNCHER;
    self.netname = S(loc.LOC_WEAPON_NAME_ROCKET_LAUNCH);
    self.touch = q.func(weapon_touch);
    q.setsize(self, q.vec(-16, -16, 0), q.vec(16, 16, 56));
    StartItem();
}

/// QUAKED weapon_lightning (0 .5 .8) (-16 -16 0) (16 16 32)
/// {
///     model({"path": "progs/g_light.mdl", "skin": 0, "frame": 0});
/// }
pub export fn weapon_lightning() void {
    const self = q.me();
    if (deathmatch_settings.deathmatch_no_weapons_on_map() != 0 or deathmatch_settings.deathmatch_no_lightning_gun_on_map() != 0)
        return;

    _ = q.precache_model(S("progs/g_light.mdl"));
    q.setmodel(self, S("progs/g_light.mdl"));
    self.weapon = lq.IT_LIGHTNING;
    self.netname = S(loc.LOC_WEAPON_NAME_THUNDERBOLT);
    self.touch = q.func(weapon_touch);
    q.setsize(self, q.vec(-16, -16, 0), q.vec(16, 16, 56));
    StartItem();
}

// ===============================================================================
//
// AMMO
//
// ===============================================================================

pub export fn ammo_touch() void {
    var self = q.me();
    const other = q.other.get();

    if (other.classname.neq(S("player")))
        return;

    if (other.health <= 0)
        return;

    // if the player was using his best weapon, change up to the new one if better
    var stemp = q.self.get();
    q.self.set(other);
    const best = weapons.W_BestWeapon();
    q.self.set(stemp);
    self = q.me();

    // shotgun
    if (self.weapon == 1) {
        if (other.ammo_shells >= 100)
            return;

        other.ammo_shells = other.ammo_shells + self.get(lq.aflag);
    }

    // spikes
    if (self.weapon == 2) {
        if (other.ammo_nails >= 200)
            return;

        other.ammo_nails = other.ammo_nails + self.get(lq.aflag);
    }

    //    rockets
    if (self.weapon == 3) {
        if (other.ammo_rockets >= 100)
            return;

        other.ammo_rockets = other.ammo_rockets + self.get(lq.aflag);
    }

    //    cells
    if (self.weapon == 4) {
        if (other.ammo_cells >= 100)
            return;
        other.ammo_cells = other.ammo_cells + self.get(lq.aflag);
    }

    bound_other_ammo();

    // Print message
    lq.sprint(other, lq.PRINT_LOW, S(loc.LOC_ITEM_PICKUP_NORMAL));
    lq.sprint(other, lq.PRINT_LOW, q.ftos(self.get(lq.aflag)));
    lq.sprint(other, lq.PRINT_LOW, S(" "));
    lq.sprint(other, lq.PRINT_LOW, self.netname);
    lq.sprint(other, lq.PRINT_LOW, S("\n"));

    // ammo touch sound
    q.sound(other, lq.CHAN_ITEM, S("weapons/lock4.wav"), 1, lq.ATTN_NORM);
    q.stuffcmd(other, S("bf\n"));

    // change to a better weapon if appropriate
    if (other.weapon == best) {
        stemp = q.self.get();
        q.self.set(other);
        self = q.me();
        self.weapon = weapons.W_BestWeapon();
        weapons.W_SetCurrentAmmo();
        q.self.set(stemp);
    }

    // if changed current ammo, update it
    stemp = q.self.get();
    q.self.set(other);
    weapons.W_SetCurrentAmmo();
    q.self.set(stemp);
    self = q.me();

    // remove it in single player, or setup for respawning in deathmatch
    self.model = lq.string_null.get();
    self.solid = lq.SOLID_NOT;

    if (deathmatch_settings.deathmatch_item_respawn()) {
        self.think = q.func(SUB_regen);
        if (deathmatch_settings.deathmatch_slow_ammo())
            self.nextthink = q.time.get() + 30
        else
            self.nextthink = q.time.get() + 15;
    }

    lq.activator.set(other);
    subs.SUB_UseTargets(); // fire all targets / killtargets
}

pub const WEAPON_BIG2: f32 = 1;

/// QUAKED item_shells (0 .5 .8) (0 0 0) (32 32 32) big
/// {
///     model({"path": "maps/b_shell1.bsp", "skin": 0, "frame": 0});
/// }
pub export fn item_shells() void {
    const self = q.me();
    if (deathmatch_settings.deathmatch_no_shell_pickups() != 0)
        return;

    self.touch = q.func(ammo_touch);

    if (q.has(self.spawnflags, WEAPON_BIG2)) {
        _ = q.precache_model(S("maps/b_shell1.bsp"));
        q.setmodel(self, S("maps/b_shell1.bsp"));
        self.set(lq.aflag, 40);
    } else {
        _ = q.precache_model(S("maps/b_shell0.bsp"));
        q.setmodel(self, S("maps/b_shell0.bsp"));
        self.set(lq.aflag, 20);
    }

    self.weapon = 1;
    self.netname = S(loc.LOC_WEAPON_AMMO_SHELLS);
    q.setsize(self, q.vec(0, 0, 0), q.vec(32, 32, 56));
    StartItem();
}

/// QUAKED item_spikes (0 .5 .8) (0 0 0) (32 32 32) big
/// {
///     model({"path": "maps/b_nail1.bsp", "skin": 0, "frame": 0});
/// }
pub export fn item_spikes() void {
    const self = q.me();
    if (deathmatch_settings.deathmatch_no_nail_pickups() != 0)
        return;

    self.touch = q.func(ammo_touch);

    if (q.has(self.spawnflags, WEAPON_BIG2)) {
        _ = q.precache_model(S("maps/b_nail1.bsp"));
        q.setmodel(self, S("maps/b_nail1.bsp"));
        self.set(lq.aflag, 50);
    } else {
        _ = q.precache_model(S("maps/b_nail0.bsp"));
        q.setmodel(self, S("maps/b_nail0.bsp"));
        self.set(lq.aflag, 25);
    }

    self.weapon = 2;
    self.netname = S(loc.LOC_WEAPON_AMMO_NAILS);
    q.setsize(self, q.vec(0, 0, 0), q.vec(32, 32, 56));
    StartItem();
}

/// QUAKED item_rockets (0 .5 .8) (0 0 0) (32 32 32) big
/// {
///     model({"path": "maps/b_rock1.bsp", "skin": 0, "frame": 0});
/// }
pub export fn item_rockets() void {
    const self = q.me();
    if (deathmatch_settings.deathmatch_no_rocket_pickups() != 0)
        return;

    self.touch = q.func(ammo_touch);

    if (q.has(self.spawnflags, WEAPON_BIG2)) {
        _ = q.precache_model(S("maps/b_rock1.bsp"));
        q.setmodel(self, S("maps/b_rock1.bsp"));
        self.set(lq.aflag, 10);
    } else {
        _ = q.precache_model(S("maps/b_rock0.bsp"));
        q.setmodel(self, S("maps/b_rock0.bsp"));
        self.set(lq.aflag, 5);
    }

    self.weapon = 3;
    self.netname = S(loc.LOC_WEAPON_AMMO_ROCKETS);
    q.setsize(self, q.vec(0, 0, 0), q.vec(32, 32, 56));
    StartItem();
}

/// QUAKED item_cells (0 .5 .8) (0 0 0) (32 32 32) big
/// {
///     model({"path": "maps/b_batt1.bsp", "skin": 0, "frame": 0});
/// }
pub export fn item_cells() void {
    const self = q.me();
    if (deathmatch_settings.deathmatch_no_cell_pickups() != 0)
        return;

    self.touch = q.func(ammo_touch);

    if (q.has(self.spawnflags, WEAPON_BIG2)) {
        _ = q.precache_model(S("maps/b_batt1.bsp"));
        q.setmodel(self, S("maps/b_batt1.bsp"));
        self.set(lq.aflag, 12);
    } else {
        _ = q.precache_model(S("maps/b_batt0.bsp"));
        q.setmodel(self, S("maps/b_batt0.bsp"));
        self.set(lq.aflag, 6);
    }

    self.weapon = 4;
    self.netname = S(loc.LOC_WEAPON_AMMO_CELLS);
    q.setsize(self, q.vec(0, 0, 0), q.vec(32, 32, 56));
    StartItem();
}

/// QUAKED item_weapon (0 .5 .8) (0 0 0) (32 32 32) shotgun rocket spikes big
/// DO NOT USE THIS!!!! IT WILL BE REMOVED!
pub const WEAPON_SHOTGUN: f32 = 1;

pub const WEAPON_ROCKET: f32 = 2;

pub const WEAPON_SPIKES: f32 = 4;

pub const WEAPON_BIG: f32 = 8;

pub export fn item_weapon() void {
    const self = q.me();
    self.touch = q.func(ammo_touch);

    if (q.has(self.spawnflags, WEAPON_SHOTGUN)) {
        if (q.has(self.spawnflags, WEAPON_BIG)) {
            _ = q.precache_model(S("maps/b_shell1.bsp"));
            q.setmodel(self, S("maps/b_shell1.bsp"));
            self.set(lq.aflag, 40);
        } else {
            _ = q.precache_model(S("maps/b_shell0.bsp"));
            q.setmodel(self, S("maps/b_shell0.bsp"));
            self.set(lq.aflag, 20);
        }
        self.weapon = 1;
        self.netname = S(loc.LOC_WEAPON_AMMO_SHELLS);
    }

    if (q.has(self.spawnflags, WEAPON_SPIKES)) {
        if (q.has(self.spawnflags, WEAPON_BIG)) {
            _ = q.precache_model(S("maps/b_nail1.bsp"));
            q.setmodel(self, S("maps/b_nail1.bsp"));
            self.set(lq.aflag, 40);
        } else {
            _ = q.precache_model(S("maps/b_nail0.bsp"));
            q.setmodel(self, S("maps/b_nail0.bsp"));
            self.set(lq.aflag, 20);
        }
        self.weapon = 2;
        self.netname = S(loc.LOC_WEAPON_AMMO_NAILS);
    }

    if (q.has(self.spawnflags, WEAPON_ROCKET)) {
        if (q.has(self.spawnflags, WEAPON_BIG)) {
            _ = q.precache_model(S("maps/b_rock1.bsp"));
            q.setmodel(self, S("maps/b_rock1.bsp"));
            self.set(lq.aflag, 10);
        } else {
            _ = q.precache_model(S("maps/b_rock0.bsp"));
            q.setmodel(self, S("maps/b_rock0.bsp"));
            self.set(lq.aflag, 5);
        }
        self.weapon = 3;
        self.netname = S(loc.LOC_WEAPON_AMMO_ROCKETS);
    }

    q.setsize(self, q.vec(0, 0, 0), q.vec(32, 32, 56));
    StartItem();
}

// ===============================================================================
//
// KEYS
//
// ===============================================================================

pub export fn key_touch() void {
    const self = q.me();
    const other = q.other.get();

    if (other.classname.neq(S("player")))
        return;

    if (other.health <= 0)
        return;

    if (q.has(other.items, self.items))
        return;

    lq.sprint(other, lq.PRINT_LOW, S(loc.LOC_ITEM_PICKUP_NORMAL));
    lq.sprint(other, lq.PRINT_LOW, self.netname);
    lq.sprint(other, lq.PRINT_LOW, S("\n"));

    q.sound(other, lq.CHAN_ITEM, self.noise, 1, lq.ATTN_NORM);
    q.stuffcmd(other, S("bf\n"));
    other.items = q.bor(other.items, self.items);

    if (q.coop.get() == 0) {
        self.solid = lq.SOLID_NOT;
        self.model = lq.string_null.get();
    }

    lq.activator.set(other);
    subs.SUB_UseTargets(); // fire all targets / killtargets
}

pub export fn key_setsounds() void {
    const self = q.me();
    if (q.world.get().get(lq.worldtype) == 0) {
        _ = q.precache_sound(S("misc/medkey.wav"));
        self.noise = S("misc/medkey.wav");
    }

    if (q.world.get().get(lq.worldtype) == 1) {
        _ = q.precache_sound(S("misc/runekey.wav"));
        self.noise = S("misc/runekey.wav");
    }

    if (q.world.get().get(lq.worldtype) == 2) {
        _ = q.precache_sound2(S("misc/basekey.wav"));
        self.noise = S("misc/basekey.wav");
    }
}

/// QUAKED item_key1 (0 .5 .8) (-16 -16 -24) (16 16 32)
/// {
///     model({"path": "progs/w_s_key.mdl", "skin": 0, "frame": 0});
/// }
/// SILVER key
/// In order for keys to work
/// you MUST set your maps
/// worldtype to one of the
/// following:
/// 0: medieval
/// 1: metal
/// 2: base
pub export fn item_key1() void {
    const self = q.me();
    if (q.world.get().get(lq.worldtype) == 0) {
        _ = q.precache_model(S("progs/w_s_key.mdl"));
        q.setmodel(self, S("progs/w_s_key.mdl"));
        self.netname = S(loc.LOC_KEY_NAME_SILVER);
    } else if (q.world.get().get(lq.worldtype) == 1) {
        _ = q.precache_model(S("progs/m_s_key.mdl"));
        q.setmodel(self, S("progs/m_s_key.mdl"));
        self.netname = S(loc.LOC_KEY_NAME_SILVER_RUNE);
    } else if (q.world.get().get(lq.worldtype) == 2) {
        _ = q.precache_model2(S("progs/b_s_key.mdl"));
        q.setmodel(self, S("progs/b_s_key.mdl"));
        self.netname = S(loc.LOC_KEY_NAME_SILVER_CARD);
    }

    key_setsounds();
    self.touch = q.func(key_touch);
    self.items = lq.IT_KEY1;
    q.setsize(self, q.vec(-16, -16, -24), q.vec(16, 16, 32));
    StartItem();
}

/// QUAKED item_key2 (0 .5 .8) (-16 -16 -24) (16 16 32)
/// {
///     model({"path": "progs/w_g_key.mdl", "skin": 0, "frame": 0});
/// }
/// GOLD key
/// In order for keys to work
/// you MUST set your maps
/// worldtype to one of the
/// following:
/// 0: medieval
/// 1: metal
/// 2: base
pub export fn item_key2() void {
    const self = q.me();
    if (q.world.get().get(lq.worldtype) == 0) {
        _ = q.precache_model(S("progs/w_g_key.mdl"));
        q.setmodel(self, S("progs/w_g_key.mdl"));
        self.netname = S(loc.LOC_KEY_NAME_GOLD);
    }

    if (q.world.get().get(lq.worldtype) == 1) {
        _ = q.precache_model(S("progs/m_g_key.mdl"));
        q.setmodel(self, S("progs/m_g_key.mdl"));
        self.netname = S(loc.LOC_KEY_NAME_GOLD_RUNE);
    }

    if (q.world.get().get(lq.worldtype) == 2) {
        _ = q.precache_model2(S("progs/b_g_key.mdl"));
        q.setmodel(self, S("progs/b_g_key.mdl"));
        self.netname = S(loc.LOC_KEY_NAME_GOLD_CARD);
    }

    key_setsounds();
    self.touch = q.func(key_touch);
    self.items = lq.IT_KEY2;
    q.setsize(self, q.vec(-16, -16, -24), q.vec(16, 16, 32));
    StartItem();
}

// ===============================================================================
//
// END OF LEVEL RUNES
//
// ===============================================================================

pub export fn sigil_touch() void {
    const self = q.me();
    const other = q.other.get();

    if (other.classname.neq(S("player")))
        return;

    if (other.health <= 0)
        return;

    var msg: String = undefined;

    // Announce collection of rune
    if (q.has(self.spawnflags, 1))
        msg = S(loc.LOC_RUNE_LQ_BLOOD)
    else if (q.has(self.spawnflags, 2))
        msg = S(loc.LOC_RUNE_LQ_BONE)
    else if (q.has(self.spawnflags, 4))
        msg = S(loc.LOC_RUNE_LQ_MIND)
    else if (q.has(self.spawnflags, 8))
        msg = S(loc.LOC_RUNE_LQ_SOUL)
    else
        msg = lq.string_null.get();

    if (msg.neq(lq.string_null.get())) {
        lq.bprint(lq.PRINT_HIGH, other.netname);
        lq.bprint(lq.PRINT_HIGH, msg);
        lq.bprint(lq.PRINT_HIGH, S("\n"));
        q.centerprint2(other, S(loc.LOC_RUNE_LQ_YOU), msg);
    }

    q.sound(other, lq.CHAN_ITEM, self.noise, 1, lq.ATTN_NORM);
    q.stuffcmd(other, S("bf\n"));
    self.solid = lq.SOLID_NOT;
    self.model = lq.string_null.get();
    q.serverflags.set(q.bor(q.serverflags.get(), q.band(self.spawnflags, 15)));
    self.classname = lq.string_null.get(); // so rune doors won't find it

    lq.activator.set(other);
    subs.SUB_UseTargets(); // fire all targets / killtargets
}

/// QUAKED item_sigil (0 .5 .8) (-16 -16 -24) (16 16 32) E1 E2 E3 E4
/// {
///     model({"path": "progs/end1.mdl", "skin": 0, "frame": 0});
/// }
/// End of level sigil, pick up to end episode and return to jrstart.
pub export fn item_sigil() void {
    const self = q.me();
    if (self.spawnflags == 0)
        q.objerror(S("no spawnflags"));

    _ = q.precache_sound(S("misc/runekey.wav"));
    self.noise = S("misc/runekey.wav");

    if (q.has(self.spawnflags, 1)) {
        _ = q.precache_model(S("progs/end1.mdl"));
        q.setmodel(self, S("progs/end1.mdl"));
    }

    if (q.has(self.spawnflags, 2)) {
        _ = q.precache_model2(S("progs/end2.mdl"));
        q.setmodel(self, S("progs/end2.mdl"));
    }

    if (q.has(self.spawnflags, 4)) {
        _ = q.precache_model2(S("progs/end3.mdl"));
        q.setmodel(self, S("progs/end3.mdl"));
    }

    if (q.has(self.spawnflags, 8)) {
        _ = q.precache_model2(S("progs/end4.mdl"));
        q.setmodel(self, S("progs/end4.mdl"));
    }

    self.touch = q.func(sigil_touch);
    q.setsize(self, q.vec(-16, -16, -24), q.vec(16, 16, 32));
    StartItem();
}

// ===============================================================================
//
// POWERUPS
//
// ===============================================================================

pub export fn powerup_touch() void {
    const self = q.me();
    const other = q.other.get();

    if (other.classname.neq(S("player")))
        return;

    if (other.health <= 0)
        return;

    lq.sprint(other, lq.PRINT_LOW, S(loc.LOC_ITEM_PICKUP_NORMAL));
    lq.sprint(other, lq.PRINT_LOW, self.netname);
    lq.sprint(other, lq.PRINT_LOW, S("\n"));

    if (q.deathmatch.get() != 0) {
        self.set(lq.mdl, self.model);

        if ((self.classname.eql(S("item_artifact_invulnerability"))) or (self.classname.eql(S("item_artifact_invisibility"))))
            self.nextthink = q.time.get() + 60 * 5
        else
            self.nextthink = q.time.get() + 60;

        self.think = q.func(SUB_regen);
    }

    q.sound(other, lq.CHAN_AUTO, self.noise, 1, lq.ATTN_NORM);
    q.stuffcmd(other, S("bf\n"));
    self.solid = lq.SOLID_NOT;
    other.items = q.bor(other.items, self.items);
    self.model = lq.string_null.get();

    // do the apropriate action
    if (self.classname.eql(S("item_artifact_envirosuit"))) {
        other.set(lq.rad_time, 1);
        other.set(lq.radsuit_finished, q.time.get() + 30);
    }

    if (self.classname.eql(S("item_artifact_invulnerability"))) {
        other.set(lq.invincible_time, 1);
        other.set(lq.invincible_finished, q.time.get() + 30);
    }

    if (self.classname.eql(S("item_artifact_invisibility"))) {
        other.set(lq.invisible_time, 1);
        other.set(lq.invisible_finished, q.time.get() + 30);
    }

    if (self.classname.eql(S("item_artifact_super_damage"))) {
        if (deathmatch_settings.deathmatch_supermode()) {
            other.armortype = 0;
            other.armorvalue = 0;
            other.ammo_cells = 0;
        }
        other.set(lq.super_time, 1);
        other.set(lq.super_damage_finished, q.time.get() + 30);
    }

    lq.activator.set(other);
    subs.SUB_UseTargets(); // fire all targets / killtargets
}

/// QUAKED item_artifact_invulnerability (0 .5 .8) (-16 -16 -24) (16 16 32)
/// {
///     model({"path": "progs/invulner.mdl", "skin": 0, "frame": 0});
/// }
/// Player is invulnerable for 30 seconds
pub export fn item_artifact_invulnerability() void {
    const self = q.me();
    if (deathmatch_settings.deathmatch_no_powerups() != 0)
        return;

    self.touch = q.func(powerup_touch);

    _ = q.precache_model(S("progs/invulner.mdl"));
    _ = q.precache_sound(S("items/protect.wav"));
    _ = q.precache_sound(S("items/protect2.wav"));
    _ = q.precache_sound(S("items/protect3.wav"));
    self.noise = S("items/protect.wav");
    q.setmodel(self, S("progs/invulner.mdl"));
    self.netname = S(loc.LOC_ITEM_NAME_PENTPROT);
    self.items = lq.IT_INVULNERABILITY;
    q.setsize(self, q.vec(-16, -16, -24), q.vec(16, 16, 32));
    StartItem();
}

/// QUAKED item_artifact_envirosuit (0 .5 .8) (-16 -16 -24) (16 16 32)
/// {
///     model({"path": "progs/suit.mdl", "skin": 0, "frame": 0});
/// }
/// Player takes no damage from water or slime for 30 seconds
pub export fn item_artifact_envirosuit() void {
    const self = q.me();
    self.touch = q.func(powerup_touch);

    _ = q.precache_model(S("progs/suit.mdl"));
    _ = q.precache_sound(S("items/suit.wav"));
    _ = q.precache_sound(S("items/suit2.wav"));
    self.noise = S("items/suit.wav");
    q.setmodel(self, S("progs/suit.mdl"));
    self.netname = S(loc.LOC_ITEM_NAME_BIOSUIT);
    self.items = lq.IT_SUIT;
    q.setsize(self, q.vec(-16, -16, -24), q.vec(16, 16, 32));
    StartItem();
}

/// QUAKED item_artifact_invisibility (0 .5 .8) (-16 -16 -24) (16 16 32)
/// {
///     model({"path": "progs/invisibl.mdl", "skin": 0, "frame": 0});
/// }
/// Player is invisible for 30 seconds
pub export fn item_artifact_invisibility() void {
    const self = q.me();
    if (deathmatch_settings.deathmatch_no_powerups() != 0)
        return;

    self.touch = q.func(powerup_touch);

    _ = q.precache_model(S("progs/invisibl.mdl"));
    _ = q.precache_sound(S("items/inv1.wav"));
    _ = q.precache_sound(S("items/inv2.wav"));
    _ = q.precache_sound(S("items/inv3.wav"));
    self.noise = S("items/inv1.wav");
    q.setmodel(self, S("progs/invisibl.mdl"));
    self.netname = S(loc.LOC_ITEM_NAME_SHADRING);
    self.items = lq.IT_INVISIBILITY;
    q.setsize(self, q.vec(-16, -16, -24), q.vec(16, 16, 32));
    StartItem();
}

/// QUAKED item_artifact_super_damage (0 .5 .8) (-16 -16 -24) (16 16 32)
/// {
///     model({"path": "progs/quaddama.mdl", "skin": 0, "frame": 0});
/// }
/// The next attack from the player will do 4x damage
pub export fn item_artifact_super_damage() void {
    const self = q.me();
    if (deathmatch_settings.deathmatch_no_powerups() != 0)
        return;

    self.touch = q.func(powerup_touch);

    _ = q.precache_model(S("progs/quaddama.mdl"));
    _ = q.precache_sound(S("items/damage.wav"));
    self.noise = S("items/damage.wav");
    q.setmodel(self, S("progs/quaddama.mdl"));

    if (deathmatch_settings.deathmatch_supermode())
        self.netname = S(loc.LOC_ITEM_NAME_OCTDMG)
    else
        self.netname = S(loc.LOC_ITEM_NAME_QUADDMG);
    self.items = lq.IT_QUAD;
    q.setsize(self, q.vec(-16, -16, -24), q.vec(16, 16, 32));
    StartItem();
}

// ===============================================================================
//
// PLAYER BACKPACKS
//
// ===============================================================================

//the entirety of BackpackTouch
//copypasta'd directly from gpl'd qw source on github.
pub export fn BackpackTouch() void {
    var self = q.me();
    const other = q.other.get();

    if (deathmatch_settings.deathmatch_supermode()) {
        if (other.get(lq.invincible_time) > 0)
            return;
    }

    if (other.classname.neq(S("player")))
        return;

    if (other.health <= 0)
        return;

    var acount: f32 = 0;
    lq.sprint(other, lq.PRINT_LOW, S(loc.LOC_ITEM_PICKUP_NORMAL));

    // Deathmatch 4 functionality
    if (deathmatch_settings.deathmatch_supermode()) {
        other.health = other.health + 10;
        lq.sprint(other, lq.PRINT_LOW, S("10"));
        lq.sprint(other, lq.PRINT_LOW, S(loc.LOC_ITEM_PICKUP_ADD_HEALTH));
        lq.sprint(other, lq.PRINT_LOW, S("\n"));
        if ((other.health > 250) and (other.health < 300))
            q.sound(other, lq.CHAN_ITEM, S("items/protect3.wav"), 1, lq.ATTN_NORM)
        else
            q.sound(other, lq.CHAN_ITEM, S("weapons/lock4.wav"), 1, lq.ATTN_NORM);
        q.stuffcmd(other, S("bf\n"));
        q.remove(self);

        if (other.health > 299) {
            if (other.get(lq.invincible_time) != 1) {
                other.set(lq.invincible_time, 1);
                other.set(lq.invincible_finished, q.time.get() + 30);
                other.items = q.bor(other.items, lq.IT_INVULNERABILITY);

                other.set(lq.super_time, 1);
                other.set(lq.super_damage_finished, q.time.get() + 30);
                other.items = q.bor(other.items, lq.IT_QUAD);

                other.ammo_cells = 0;

                q.sound(other, lq.CHAN_VOICE, S("boss1/sight1.wav"), 1, lq.ATTN_NORM);
                q.stuffcmd(other, S("bf\n"));
                lq.bprint(lq.PRINT_HIGH, other.netname);
                lq.bprint(lq.PRINT_HIGH, S(loc.LOC_BONUS_POWERS));
                lq.bprint(lq.PRINT_HIGH, S("\n"));
            }
        }
        q.self.set(other);
        return;
    }

    if (self.items != 0) {
        if (q.band(other.items, self.items) == 0) {
            acount = 1;
            lq.sprint(other, lq.PRINT_LOW, self.netname);
        }
    }

    // if the player was using his best weapon, change up to the new one if better
    const stemp = q.self.get();
    q.self.set(other);
    _ = weapons.W_BestWeapon(); // (`best` is never used in the original.)
    q.self.set(stemp);
    self = q.me();

    // change weapons
    other.ammo_shells = other.ammo_shells + self.ammo_shells;
    other.ammo_nails = other.ammo_nails + self.ammo_nails;
    other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
    other.ammo_cells = other.ammo_cells + self.ammo_cells;

    var new = self.items;
    if (new == 0)
        new = other.weapon;

    const old = other.items;
    other.items = q.bor(other.items, self.items);

    bound_other_ammo();

    var s: String = undefined;
    if (self.ammo_shells != 0) {
        if (acount != 0)
            lq.sprint(other, lq.PRINT_LOW, S(", "));

        acount = 1;
        s = q.ftos(self.ammo_shells);
        lq.sprint(other, lq.PRINT_LOW, s);
        lq.sprint(other, lq.PRINT_LOW, S(" "));
        lq.sprint(other, lq.PRINT_LOW, S(loc.LOC_WEAPON_AMMO_SHELLS));
    }

    if (self.ammo_nails != 0) {
        if (acount != 0)
            lq.sprint(other, lq.PRINT_LOW, S(", "));

        acount = 1;
        s = q.ftos(self.ammo_nails);
        lq.sprint(other, lq.PRINT_LOW, s);
        lq.sprint(other, lq.PRINT_LOW, S(" "));
        lq.sprint(other, lq.PRINT_LOW, S(loc.LOC_WEAPON_AMMO_NAILS));
    }

    if (self.ammo_rockets != 0) {
        if (acount != 0)
            lq.sprint(other, lq.PRINT_LOW, S(", "));

        acount = 1;
        s = q.ftos(self.ammo_rockets);
        lq.sprint(other, lq.PRINT_LOW, s);
        lq.sprint(other, lq.PRINT_LOW, S(" "));
        lq.sprint(other, lq.PRINT_LOW, S(loc.LOC_WEAPON_AMMO_ROCKETS));
    }
    if (self.ammo_cells != 0) {
        if (acount != 0)
            lq.sprint(other, lq.PRINT_LOW, S(", "));

        acount = 1;
        s = q.ftos(self.ammo_cells);
        lq.sprint(other, lq.PRINT_LOW, s);
        lq.sprint(other, lq.PRINT_LOW, S(" "));
        lq.sprint(other, lq.PRINT_LOW, S(loc.LOC_WEAPON_AMMO_CELLS));
    }

    // sprint (other, PRINT_LOW, LOC_ITEM_FROM_BACKPACK);
    lq.sprint(other, lq.PRINT_LOW, S("\n"));

    // If backpack has a grenade or rocket launcher in it, fill it with at least five rockets
    if (deathmatch_settings.deathmatch_backpack_min_rockets() and ((WeaponCode(new) == 6) or (WeaponCode(new) == 7)) and (other.ammo_rockets < 5))
        other.ammo_rockets = 5;

    // backpack touch sound
    q.sound(other, lq.CHAN_ITEM, S("weapons/lock4.wav"), 1, lq.ATTN_NORM);
    q.stuffcmd(other, S("bf\n"));

    q.remove(self);
    q.self.set(other);
    self = q.me();

    // change to the weapon
    if (q.has(self.flags, lq.FL_INWATER)) {
        if (new != lq.IT_LIGHTNING) {
            Deathmatch_Weapon(old, new);
        }
    } else {
        Deathmatch_Weapon(old, new);
    }

    weapons.W_SetCurrentAmmo();
}

/// DropBackpack
pub export fn DropBackpack() void {
    const self = q.me();

    if ((self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells) == 0)
        return; // nothing in it

    const item = q.spawn();
    item.origin = self.origin - q.vec(0, 0, 24);

    item.items = self.weapon;

    if (item.items == lq.IT_AXE)
        item.netname = S(loc.LOC_WEAPON_NAME_AXE)
    else if (item.items == lq.IT_SHOTGUN)
        item.netname = S(loc.LOC_WEAPON_NAME_SHOTGUN)
    else if (item.items == lq.IT_SUPER_SHOTGUN)
        item.netname = S(loc.LOC_WEAPON_NAME_SUPER_SHOTGUN)
    else if (item.items == lq.IT_NAILGUN)
        item.netname = S(loc.LOC_WEAPON_NAME_NAILGUN)
    else if (item.items == lq.IT_SUPER_NAILGUN)
        item.netname = S(loc.LOC_WEAPON_NAME_SUPER_NAILGUN)
    else if (item.items == lq.IT_GRENADE_LAUNCHER)
        item.netname = S(loc.LOC_WEAPON_NAME_GRENADE_LAUNCH)
    else if (item.items == lq.IT_ROCKET_LAUNCHER)
        item.netname = S(loc.LOC_WEAPON_NAME_ROCKET_LAUNCH)
    else if (item.items == lq.IT_LIGHTNING)
        item.netname = S(loc.LOC_WEAPON_NAME_THUNDERBOLT)
    else
        item.netname = S(loc.LOC_ITEM_NAME_BACKPACK);

    item.ammo_shells = self.ammo_shells;
    item.ammo_nails = self.ammo_nails;
    item.ammo_rockets = self.ammo_rockets;
    item.ammo_cells = self.ammo_cells;

    item.velocity[2] = 300;
    item.velocity[0] = -100 + (q.random() * 200);
    item.velocity[1] = -100 + (q.random() * 200);

    item.flags = lq.FL_ITEM;
    item.solid = lq.SOLID_TRIGGER;
    item.movetype = lq.MOVETYPE_TOSS;
    q.setmodel(item, S("progs/backpack.mdl"));
    q.setsize(item, q.vec(-16, -16, 0), q.vec(16, 16, 56));
    item.touch = q.func(BackpackTouch);

    item.nextthink = q.time.get() + 120; // remove after 2 minutes
    item.think = q.func(subs.SUB_Remove);
}
