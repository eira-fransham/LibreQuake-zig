//! deathmatch_settings.qc -- Centralized location for defining which deathmatch
//! settings are in which modes

const q = @import("defs.zig");
const lq = @import("lq.zig");

/// Weapons stay when picked up
pub inline fn deathmatch_weapon_stay() bool {
    return q.deathmatch.get() >= 2;
}

/// Items respawn after a timer
pub inline fn deathmatch_item_respawn() bool {
    return q.deathmatch.get() != 0 and (q.deathmatch.get() != 2);
}

/// Ammo pickups take twice as long to respawn
pub inline fn deathmatch_slow_ammo() bool {
    return q.deathmatch.get() == 1;
}

/// When picking up a backpack that contains a Rocket or Grenade Launcher, set the
/// player's rocket count to 5 if they have less than 5
pub inline fn deathmatch_backpack_min_rockets() bool {
    return q.deathmatch.get() >= 3;
}

/// All of the special rules that apply in deathmatch 4
pub inline fn deathmatch_supermode() bool {
    return q.deathmatch.get() == 4;
}

/// All of the special rules that apply in deathmatch 5
pub inline fn deathmatch_supermode2() bool {
    return q.deathmatch.get() == 5;
}

/// Increases the axe's damage from 20 to 75
pub export fn deathmatch_buffed_axe() f32 {
    if (deathmatch_supermode() or deathmatch_supermode2())
        return lq.TRUE;

    return lq.FALSE;
}

/// Restricts players to axes only
pub export fn deathmatch_axe_only() f32 {
    return lq.FALSE;
}

/// Shotgun is removed from players' starting items
pub export fn deathmatch_no_shotgun() f32 {
    return lq.FALSE;
}

/// Super Shotgun is removed from players' starting items
pub export fn deathmatch_no_super_shotgun() f32 {
    return lq.FALSE;
}

/// Nailgun is removed from players' starting items
pub export fn deathmatch_no_nailgun() f32 {
    return lq.FALSE;
}

/// Super Nailgun is removed from players' starting items
pub export fn deathmatch_no_super_nailgun() f32 {
    return lq.FALSE;
}

/// Grenade Launcher is removed from players' starting items
pub export fn deathmatch_no_grenade_launcher() f32 {
    return lq.FALSE;
}

/// Rocket Launcher is removed from players' starting items
pub export fn deathmatch_no_rocket_launcher() f32 {
    return lq.FALSE;
}

/// Lightning Gun is removed from players' starting items
pub export fn deathmatch_no_lightning_gun() f32 {
    return lq.FALSE;
}

/// Players start with the Super Shotgun
pub export fn deathmatch_starting_super_shotgun() f32 {
    if (deathmatch_no_super_shotgun() != 0)
        return lq.FALSE;

    if (deathmatch_supermode() or deathmatch_supermode2())
        return lq.TRUE;

    return lq.FALSE;
}

/// Players start with the Super Nailgun
pub export fn deathmatch_starting_nailgun() f32 {
    if (deathmatch_no_nailgun() != 0)
        return lq.FALSE;

    if (deathmatch_supermode() or deathmatch_supermode2())
        return lq.TRUE;

    return lq.FALSE;
}

/// Players start with the Super Nailgun
pub export fn deathmatch_starting_super_nailgun() f32 {
    if (deathmatch_no_super_nailgun() != 0)
        return lq.FALSE;

    if (deathmatch_supermode() or deathmatch_supermode2())
        return lq.TRUE;

    return lq.FALSE;
}

/// Players start with the Grenade Launcher
pub export fn deathmatch_starting_grenade_launcher() f32 {
    if (deathmatch_no_grenade_launcher() != 0)
        return lq.FALSE;

    if (deathmatch_supermode2())
        return lq.TRUE;

    return lq.FALSE;
}

/// Players start with the Rocket Launcher
pub export fn deathmatch_starting_rocket_launcher() f32 {
    if (deathmatch_no_rocket_launcher() != 0)
        return lq.FALSE;

    if (deathmatch_supermode() or deathmatch_supermode2())
        return lq.TRUE;

    return lq.FALSE;
}

/// Players start with the Lightning Gun
pub export fn deathmatch_starting_lightning_gun() f32 {
    if (deathmatch_no_lightning_gun() != 0)
        return lq.FALSE;

    if (deathmatch_supermode() or deathmatch_supermode2())
        return lq.TRUE;

    return lq.FALSE;
}

/// Players have unlimited ammo
pub export fn deathmatch_unlimited_ammo() f32 {
    if (deathmatch_supermode())
        return lq.TRUE;

    return lq.FALSE;
}

/// Super Shotgun is removed on map load
pub export fn deathmatch_no_super_shotgun_on_map() f32 {
    if (deathmatch_no_super_shotgun() != 0)
        return lq.TRUE;

    if (deathmatch_starting_super_shotgun() != 0)
        return lq.TRUE;

    return lq.FALSE;
}

/// Nailgun is removed from players' starting items
pub export fn deathmatch_no_nailgun_on_map() f32 {
    if (deathmatch_no_nailgun() != 0)
        return lq.TRUE;

    if (deathmatch_starting_nailgun() != 0)
        return lq.TRUE;

    return lq.FALSE;
}

/// Super Nailgun is removed from players' starting items
pub export fn deathmatch_no_super_nailgun_on_map() f32 {
    if (deathmatch_no_super_nailgun() != 0)
        return lq.TRUE;

    if (deathmatch_starting_super_nailgun() != 0)
        return lq.TRUE;

    return lq.FALSE;
}

/// Grenade Launcher is removed from players' starting items
pub export fn deathmatch_no_grenade_launcher_on_map() f32 {
    if (deathmatch_no_grenade_launcher() != 0)
        return lq.TRUE;

    if (deathmatch_starting_grenade_launcher() != 0)
        return lq.TRUE;

    return lq.FALSE;
}

/// Rocket Launcher is removed from players' starting items
pub export fn deathmatch_no_rocket_launcher_on_map() f32 {
    if (deathmatch_no_rocket_launcher() != 0)
        return lq.TRUE;

    if (deathmatch_starting_rocket_launcher() != 0)
        return lq.TRUE;

    return lq.FALSE;
}

/// Lightning Gun is removed from players' starting items
pub export fn deathmatch_no_lightning_gun_on_map() f32 {
    if (deathmatch_no_lightning_gun() != 0)
        return lq.TRUE;

    if (deathmatch_starting_lightning_gun() != 0)
        return lq.TRUE;

    return lq.FALSE;
}

/// Weapons are removed on map load
pub export fn deathmatch_no_weapons_on_map() f32 {
    if (deathmatch_supermode() or deathmatch_supermode2() or deathmatch_axe_only() != 0)
        return lq.TRUE;

    return lq.FALSE;
}

/// Ammo pickups are removed on map load
pub export fn deathmatch_no_ammo_pickups() f32 {
    if (deathmatch_unlimited_ammo() != 0 or deathmatch_axe_only() != 0)
        return lq.TRUE;

    return lq.FALSE;
}

/// Shell pickups are removed on map load
pub export fn deathmatch_no_shell_pickups() f32 {
    if (deathmatch_no_ammo_pickups() != 0)
        return lq.TRUE;

    if (deathmatch_no_shotgun() != 0 and deathmatch_no_super_shotgun() != 0)
        return lq.TRUE;

    if (deathmatch_no_weapons_on_map() != 0 and (deathmatch_starting_super_shotgun() == 0))
        return lq.TRUE;

    return lq.FALSE;
}

/// Nail pickups are removed on map load
pub export fn deathmatch_no_nail_pickups() f32 {
    if (deathmatch_no_ammo_pickups() != 0)
        return lq.TRUE;

    if (deathmatch_no_nailgun() != 0 and deathmatch_no_super_nailgun() != 0)
        return lq.TRUE;

    if (deathmatch_no_weapons_on_map() != 0 and (deathmatch_starting_nailgun() == 0) and (deathmatch_starting_super_nailgun() == 0))
        return lq.TRUE;

    return lq.FALSE;
}

/// Rocket pickups are removed on map load
pub export fn deathmatch_no_rocket_pickups() f32 {
    if (deathmatch_no_ammo_pickups() != 0)
        return lq.TRUE;

    if (deathmatch_no_grenade_launcher() != 0 and deathmatch_no_rocket_launcher() != 0)
        return lq.TRUE;

    if (deathmatch_no_weapons_on_map() != 0 and (deathmatch_starting_grenade_launcher() == 0) and (deathmatch_starting_rocket_launcher() == 0))
        return lq.TRUE;

    return lq.FALSE;
}

/// Cell pickups are removed on map load
pub export fn deathmatch_no_cell_pickups() f32 {
    if (deathmatch_no_ammo_pickups() != 0)
        return lq.TRUE;

    if (deathmatch_no_lightning_gun() != 0)
        return lq.TRUE;

    if (deathmatch_no_weapons_on_map() != 0 and (deathmatch_starting_lightning_gun() == 0))
        return lq.TRUE;

    return lq.FALSE;
}

/// Powerups are removed on map load
pub export fn deathmatch_no_powerups() f32 {
    return lq.FALSE;
}

/// Armor pickups are removed on map load
pub export fn deathmatch_no_armor() f32 {
    return lq.FALSE;
}

/// Health pickups are removed on map load
pub export fn deathmatch_no_health() f32 {
    return lq.FALSE;
}

/// Mega-health pickups are removed on map load
pub export fn deathmatch_no_mega_health() f32 {
    return lq.FALSE;
}

/// Stops players from dropping backpacks on death
pub export fn deathmatch_no_backpacks() f32 {
    return lq.FALSE;
}

/// Quad is dropped on death
pub export fn deathmatch_drop_quad() f32 {
    if (q.deathmatch.get() == 0)
        return lq.FALSE;

    return lq.TRUE;
}

/// Ring is dropped on death
pub export fn deathmatch_drop_ring() f32 {
    if (q.deathmatch.get() == 0)
        return lq.FALSE;

    return lq.TRUE;
}

/// Multiplier for explosion force from rocket and grenade jumps
pub export fn deathmatch_rocket_jump_multiplier() f32 {
    if (q.deathmatch.get() == 0)
        return 0;

    return 0;
}
