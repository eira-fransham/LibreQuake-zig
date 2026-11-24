//! client.qc
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

const combat = @import("combat.zig");
const deathmatch_settings = @import("deathmatch_settings.zig");
const player = @import("player.zig");
const subs = @import("subs.zig");
const triggers = @import("triggers.zig");
const weapons = @import("weapons.zig");
const world = @import("world.zig");

pub const modelindex_eyes = q.userGlobal(f32, "modelindex_eyes");

pub const modelindex_player = q.userGlobal(f32, "modelindex_player");

// =============================================================================
//
//                 LEVEL CHANGING / INTERMISSION
//
// =============================================================================

pub const nextmap = q.userGlobal(String, "nextmap");

pub const intermission_running = q.userGlobal(f32, "intermission_running");

pub const intermission_exittime = q.userGlobal(f32, "intermission_exittime");

/// QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16)
/// This is the camera point for the intermission.
/// Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch roll yaw'
pub export fn info_intermission() void {}

pub export fn SetChangeParms() void {
    const self = q.me();
    if (self.health <= 0) {
        SetNewParms();
        return;
    }

    // remove items
    self.items = self.items - q.band(self.items, q.bor(q.bor(q.bor(q.bor(q.bor(lq.IT_KEY1, lq.IT_KEY2), lq.IT_INVISIBILITY), lq.IT_INVULNERABILITY), lq.IT_SUIT), lq.IT_QUAD));

    // cap super health
    if (self.health > 100)
        self.health = 100;

    if (self.health < 50)
        self.health = 50;

    q.parm1.set(self.items);
    q.parm2.set(self.health);
    q.parm3.set(self.armorvalue);

    if (self.ammo_shells < 25) {
        q.parm4.set(25);
    } else {
        q.parm4.set(self.ammo_shells);
    }

    q.parm5.set(self.ammo_nails);
    q.parm6.set(self.ammo_rockets);
    q.parm7.set(self.ammo_cells);
    q.parm8.set(self.weapon);
    q.parm9.set(self.armortype * 100);

    q.parm16.set(q.band(q.serverflags.get(), 15));
}

pub export fn SetNewParms() void {
    q.parm1.set(q.bor(lq.IT_SHOTGUN, lq.IT_AXE));
    q.parm2.set(100);
    q.parm3.set(0);
    q.parm4.set(25);
    q.parm5.set(0);
    q.parm6.set(0);
    q.parm7.set(0);
    q.parm8.set(1);
    q.parm9.set(0);
    q.parm16.set(q.band(q.serverflags.get(), 15));
}

pub export fn DecodeLevelParms() void {
    const self = q.me();
    if (q.serverflags.get() != 0 and q.world.get().model.eql(S("maps/start.bsp"))) {
        SetNewParms(); // take away all stuff on starting new episode
    } else if (q.deathmatch.get() != 0) {
        SetNewParms();
    }

    self.items = q.parm1.get();
    self.health = q.parm2.get();
    self.armorvalue = q.parm3.get();
    self.ammo_shells = q.parm4.get();
    self.ammo_nails = q.parm5.get();
    self.ammo_rockets = q.parm6.get();
    self.ammo_cells = q.parm7.get();
    self.weapon = q.parm8.get();
    self.armortype = q.parm9.get() * 0.01;

    q.serverflags.set(q.bor(q.serverflags.get(), q.parm16.get()));
}

/// FindIntermission
///
/// Returns the entity to view from
pub export fn FindIntermission() Entity {
    // look for info_intermission first
    var spot = q.find(q.world.get(), .classname, S("info_intermission"));
    if (!spot.isNull()) { // pick a random one
        var cyc = q.random() * 4;
        while (cyc > 1) {
            spot = q.find(spot, .classname, S("info_intermission"));

            if (spot.isNull())
                spot = q.find(spot, .classname, S("info_intermission"));
            cyc = cyc - 1;
        }

        return spot;
    }

    // then look for the start position
    spot = q.find(q.world.get(), .classname, S("info_player_start"));
    if (!spot.isNull())
        return spot;

    // testinfo_player_start is only found in regioned levels
    spot = q.find(q.world.get(), .classname, S("testplayerstart"));
    if (!spot.isNull())
        return spot;

    q.objerror(S("FindIntermission: no spot"));

    return q.world.get();
}

pub export fn GotoNextMap() void {
    if (q.cvar(S("samelevel")) != 0) { // if samelevel is set, stay on same level
        q.changelevel(q.mapname.get());
    } else {
        q.changelevel(nextmap.get());
    }
}

// cypress (09 mar 2024) -- use struct for epilogue levels.
const IntermissionLevel = struct {
    map_name: []const u8,
    cd_track: f32,
    epilogue_text: []const u8,
    /// `null` is `__NULL__`.
    freeware_text: ?[]const u8,
};

const intermission_levels = [_]IntermissionLevel{
    .{ .map_name = "maps/lq_e0m7.bsp", .cd_track = 2, .epilogue_text = loc.LOC_EPILOGUE_0, .freeware_text = null },
    .{ .map_name = "maps/lq_e1m7.bsp", .cd_track = 2, .epilogue_text = loc.LOC_EPILOGUE_1, .freeware_text = loc.LOC_EPILOGUE_1_FREEWARE },
    .{ .map_name = "maps/lq_e2m6.bsp", .cd_track = 2, .epilogue_text = loc.LOC_EPILOGUE_2, .freeware_text = null },
    .{ .map_name = "maps/lq_e3m6.bsp", .cd_track = 2, .epilogue_text = loc.LOC_EPILOGUE_3, .freeware_text = null },
    .{ .map_name = "maps/lq_e4m7.bsp", .cd_track = 2, .epilogue_text = loc.LOC_EPILOGUE_4, .freeware_text = null },
};
// --cypress

pub export fn ExitIntermission() void {
    // skip any text in deathmatch
    if (q.deathmatch.get() != 0) {
        GotoNextMap();
        return;
    }

    intermission_exittime.set(q.time.get() + 1);
    intermission_running.set(intermission_running.get() + 1);

    //
    // run some text if at the end of an episode
    //
    if (intermission_running.get() == 2) {
        // cypress (09 mar 2024) -- use struct for epilogue levels.
        inline for (intermission_levels) |entry| {
            if (q.world.get().model.eql(S(entry.map_name))) {
                q.WriteByte(lq.MSG_ALL, lq.SVC_CDTRACK);
                q.WriteByte(lq.MSG_ALL, entry.cd_track); // [cdtrack]
                q.WriteByte(lq.MSG_ALL, 3); // [looptrack], unused.

                q.WriteByte(lq.MSG_ALL, lq.SVC_FINALE);

                const freeware_text = if (entry.freeware_text) |t| S(t) else lq.string_null.get();
                if (q.cvar(S("registered")) == 0 and freeware_text.neq(lq.string_null.get())) {
                    q.WriteString(lq.MSG_ALL, freeware_text);
                } else {
                    q.WriteString(lq.MSG_ALL, S(entry.epilogue_text));
                }
                return;
            }
        }
        // --cypress

        GotoNextMap();
    }

    if (intermission_running.get() == 3) {
        if (q.cvar(S("registered")) == 0) { // shareware episode has been completed, go to sell screen
            q.WriteByte(lq.MSG_ALL, lq.SVC_SELLSCREEN);

            return;
        }

        if (q.band(q.serverflags.get(), 15) == 15) {
            q.WriteByte(lq.MSG_ALL, lq.SVC_FINALE);
            q.WriteString(lq.MSG_ALL, S(loc.LOC_EPILOGUE_RUNES));

            return;
        }
    }

    GotoNextMap();
}

/// IntermissionThink
///
/// When the player presses attack or jump, change to the next level
pub export fn IntermissionThink() void {
    const self = q.me();
    if (q.time.get() < intermission_exittime.get())
        return;

    if (self.button0 == 0 and self.button1 == 0 and self.button2 == 0)
        return;

    ExitIntermission();
}

pub export fn execute_changelevel() void {
    intermission_running.set(1);

    // enforce a wait time before allowing changelevel
    if (q.deathmatch.get() != 0) {
        intermission_exittime.set(q.time.get() + 5);
    } else {
        intermission_exittime.set(q.time.get() + 2);
    }

    const pos = FindIntermission();

    q.other.set(q.find(q.world.get(), .classname, S("player")));

    while (q.other.get().neq(q.world.get())) {
        const other = q.other.get();
        other.view_ofs = q.vec(0, 0, 0);
        other.v_angle = pos.get(lq.mangle);
        other.angles = other.v_angle;
        other.fixangle = lq.TRUE; // turn this way immediately
        other.nextthink = q.time.get() + 0.5;
        other.takedamage = lq.DAMAGE_NO;
        other.solid = lq.SOLID_NOT;
        other.movetype = lq.MOVETYPE_NONE;
        other.modelindex = 0;
        q.setorigin(other, pos.origin);
        q.other.set(q.find(other, .classname, S("player")));
    }

    q.WriteByte(lq.MSG_ALL, lq.SVC_CDTRACK);
    q.WriteByte(lq.MSG_ALL, 3);
    q.WriteByte(lq.MSG_ALL, 3);
    q.WriteByte(lq.MSG_ALL, lq.SVC_INTERMISSION);
}

pub export fn changelevel_touch() void {
    const self = q.me();
    const other = q.other.get();
    if (other.classname.neq(S("player")))
        return;

    if ((q.cvar(S("noexit")) == 1) or ((q.cvar(S("noexit")) == 2) and (q.mapname.get().neq(S("start"))))) {
        combat.T_Damage(other, self, self, 50000);
        return;
    }

    if (q.deathmatch.get() != 0 or q.coop.get() != 0) {
        lq.bprint(lq.PRINT_HIGH, other.netname);
        lq.bprint(lq.PRINT_HIGH, S(loc.LOC_CLIENT_EXIT_LEVEL));
        lq.bprint(lq.PRINT_HIGH, S("\n"));
    }

    nextmap.set(self.get(lq.map));

    subs.SUB_UseTargets();

    if (q.has(self.spawnflags, 1) and (q.deathmatch.get() == 0)) { // NO_INTERMISSION
        GotoNextMap();

        return;
    }

    self.touch = null;

    // we can't move people right now, because touch functions are called
    // in the middle of C movement code, so set a think time to do it
    self.think = q.func(execute_changelevel);
    self.nextthink = q.time.get() + 0.1;
}

/// QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION
/// When the player touches this, he gets sent to the map listed in the "map" variable.
/// Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission
/// spot and display stats.
pub export fn trigger_changelevel() void {
    const self = q.me();
    if (self.get(lq.map).isNull())
        q.objerror(S("changelevel trigger doesn't have map"));

    //gnounc
    self.netname = S("changelevel");
    self.set(lq.killstring, S(loc.LOC_DEATH_LEAVE));

    subs.InitTrigger();
    self.touch = q.func(changelevel_touch);
}

// =============================================================================
//
//                 PLAYER GAME EDGE FUNCTIONS
//
// =============================================================================

// called by ClientKill and DeadThink
pub export fn respawn() void {
    const self = q.me();
    if (q.coop.get() != 0) {
        // make a copy of the dead body for appearances sake
        world.CopyToBodyQueue(self);
        // get the spawn parms as they were at level start
        q.setspawnparms(self);
        // respawn
        PutClientInServer();
    } else if (q.deathmatch.get() != 0) {
        // make a copy of the dead body for appearances sake
        world.CopyToBodyQueue(self);
        // respawn
        PutClientInServer();
    } else { // restart the entire server
        q.localcmd(S("restart\n"));
    }
}

/// ClientKill
///
/// Player entered the suicide command
pub export fn ClientKill() void {
    const self = q.me();
    lq.bprint(lq.PRINT_MEDIUM, self.netname);
    lq.bprint(lq.PRINT_MEDIUM, S(loc.LOC_DEATH_SUICIDE));
    lq.bprint(lq.PRINT_MEDIUM, S("\n"));
    player.set_suicide_frame();
    self.modelindex = modelindex_player.get();
    lq.logfrag(self, self);
    self.frags = self.frags - 2; // extra penalty
    respawn();
}

pub export fn CheckSpawnPoint(v: Vector) f32 {
    _ = v;
    return lq.FALSE;
}

/// SelectSpawnPoint
///
/// Returns the entity to spawn at
pub export fn SelectSpawnPoint() Entity {
    var numspots: f32 = 0;
    var totalspots: f32 = 0;

    // testinfo_player_start is only found in regioned levels
    var spot = q.find(q.world.get(), .classname, S("testplayerstart"));
    if (!spot.isNull())
        return spot;

    // choose a info_player_deathmatch point
    if (q.coop.get() != 0) {
        world.lastspawn.set(q.find(world.lastspawn.get(), .classname, S("info_player_coop")));
        if (world.lastspawn.get().eql(q.world.get()))
            world.lastspawn.set(q.find(world.lastspawn.get(), .classname, S("info_player_start")));
        if (world.lastspawn.get().neq(q.world.get()))
            return world.lastspawn.get();
    } else if (q.deathmatch.get() != 0) {

        // ok, find all spots that don't have players nearby
        var spots = q.world.get();
        spot = q.find(q.world.get(), .classname, S("info_player_deathmatch"));

        while (!spot.isNull()) {
            totalspots = totalspots + 1;

            var thing = q.findradius(spot.origin, 84);
            var pcount: f32 = 0;

            while (!thing.isNull()) {
                if (thing.classname.eql(S("player")))
                    pcount = pcount + 1;

                thing = thing.chain;
            }

            if (pcount == 0) {
                spot.goalentity = spots;
                spots = spot;
                numspots = numspots + 1;
            }

            // Get the next spot in the chain
            spot = q.find(spot, .classname, S("info_player_deathmatch"));
        }
        totalspots = totalspots - 1;

        if (numspots == 0) {
            // ack, they are all full, just pick one at random
            totalspots = q.rint((q.random() * totalspots));
            spot = q.find(q.world.get(), .classname, S("info_player_deathmatch"));

            while (totalspots > 0) {
                totalspots = totalspots - 1;
                spot = q.find(spot, .classname, S("info_player_deathmatch"));
            }
            return spot;
        }

        // We now have the number of spots available on the map in numspots
        // Generate a random number between 1 and numspots
        numspots = numspots - 1;

        numspots = q.rint((q.random() * numspots));

        spot = spots;
        while (numspots > 0) {
            spot = spot.goalentity;
            numspots = numspots - 1;
        }

        return spot;
    }

    if (q.serverflags.get() != 0) { // return with a rune to start
        spot = q.find(q.world.get(), .classname, S("info_player_start2"));

        if (!spot.isNull())
            return spot;
    }

    spot = q.find(q.world.get(), .classname, S("info_player_start"));
    if (spot.isNull())
        q.@"error"(S("PutClientInServer: no info_player_start on level"));

    return spot;
}

/// PutClientInServer
///
/// called each time a player is spawned
pub export fn PutClientInServer() void {
    const self = q.me();

    self.classname = S("player");
    self.health = 100;
    self.takedamage = lq.DAMAGE_AIM;
    self.solid = lq.SOLID_SLIDEBOX;
    self.movetype = lq.MOVETYPE_WALK;
    self.set(lq.show_hostile, 0);
    self.max_health = 100;
    self.flags = lq.FL_CLIENT;
    self.set(lq.air_finished, q.time.get() + 12);
    self.set(lq.dmg, 2); // initial water damage
    self.set(lq.super_damage_finished, 0);
    self.set(lq.radsuit_finished, 0);
    self.set(lq.invisible_finished, 0);
    self.set(lq.invincible_finished, 0);
    self.effects = 0;
    self.set(lq.invincible_time, 0);

    DecodeLevelParms();

    weapons.W_SetCurrentAmmo();

    self.set(lq.attack_finished, q.time.get());
    self.set(lq.th_pain, q.func(player.player_pain));
    self.set(lq.th_die, q.func(player.PlayerDie));

    self.deadflag = lq.DEAD_NO;
    // pausetime is set by teleporters to keep the player from moving a while
    self.set(lq.pausetime, 0);

    const spot = SelectSpawnPoint();

    self.origin = spot.origin + q.vec(0, 0, 1);
    self.angles = spot.angles;
    self.fixangle = lq.TRUE; // turn this way immediately

    // oh, this is a hack!
    q.setmodel(self, S("progs/eyes.mdl"));
    modelindex_eyes.set(self.modelindex);

    q.setmodel(self, S("progs/player.mdl"));
    modelindex_player.set(self.modelindex);

    q.setsize(self, lq.VEC_HULL_MIN, lq.VEC_HULL_MAX);

    self.view_ofs = q.vec(0, 0, 22);

    self.velocity = q.vec(0, 0, 0);

    player.player_stand1();

    if (q.deathmatch.get() != 0 or q.coop.get() != 0) {
        subs.makevectors2(self.angles);
        triggers.spawn_tfog(self.origin + q.scale(q.v_forward.get(), 20));
    }

    triggers.spawn_tdeath(self.origin, self);

    q.stuffcmd(self, S("-attack\n")); // Supa, prevent shooting after respawning in MP

    // Deathmatch 4 starting items
    if (deathmatch_settings.deathmatch_supermode()) {
        self.items = self.items - q.band(self.items, q.bor(q.bor(lq.IT_ARMOR1, lq.IT_ARMOR2), lq.IT_ARMOR3)) + lq.IT_ARMOR3;
        self.armorvalue = 200;
        self.armortype = 0.8;
        self.health = 250;
        self.items = q.bor(self.items, lq.IT_INVULNERABILITY);
        self.set(lq.invincible_time, 1);
        self.set(lq.invincible_finished, q.time.get() + 3);
    }

    // Deathmatch 5 starting items
    if (deathmatch_settings.deathmatch_supermode2()) {
        self.items = self.items - q.band(self.items, q.bor(q.bor(lq.IT_ARMOR1, lq.IT_ARMOR2), lq.IT_ARMOR3)) + lq.IT_ARMOR3;
        self.armorvalue = 200;
        self.armortype = 0.8;
        self.health = 200;
        self.items = q.bor(self.items, lq.IT_INVULNERABILITY);
        self.set(lq.invincible_time, 1);
        self.set(lq.invincible_finished, q.time.get() + 3);
    }

    if (deathmatch_settings.deathmatch_no_shotgun() != 0) {
        self.items = self.items - q.band(self.items, lq.IT_SHOTGUN);
        self.ammo_shells = 0;
    }

    if (deathmatch_settings.deathmatch_starting_nailgun() != 0) {
        self.items = q.bor(self.items, lq.IT_NAILGUN);
        self.ammo_nails = 80;
        self.weapon = lq.IT_NAILGUN;
    }
    if (deathmatch_settings.deathmatch_starting_super_shotgun() != 0) {
        self.items = q.bor(self.items, lq.IT_SUPER_SHOTGUN);
        self.ammo_shells = 30;
        self.weapon = lq.IT_SUPER_SHOTGUN;
    }
    if (deathmatch_settings.deathmatch_starting_super_nailgun() != 0) {
        self.items = q.bor(self.items, lq.IT_SUPER_NAILGUN);
        self.ammo_nails = 80;
        self.weapon = lq.IT_SUPER_NAILGUN;
    }
    if (deathmatch_settings.deathmatch_starting_grenade_launcher() != 0) {
        self.items = q.bor(self.items, lq.IT_GRENADE_LAUNCHER);
        self.ammo_rockets = 10;
        self.weapon = lq.IT_GRENADE_LAUNCHER;
    }
    if (deathmatch_settings.deathmatch_starting_lightning_gun() != 0) {
        self.items = q.bor(self.items, lq.IT_LIGHTNING);
        self.ammo_cells = 30;
        self.weapon = lq.IT_LIGHTNING;
    }
    if (deathmatch_settings.deathmatch_starting_rocket_launcher() != 0) {
        self.items = q.bor(self.items, lq.IT_ROCKET_LAUNCHER);
        self.ammo_rockets = 10;
        self.weapon = lq.IT_ROCKET_LAUNCHER;
    }

    if (deathmatch_settings.deathmatch_unlimited_ammo() != 0) {
        self.ammo_nails = 255;
        self.ammo_shells = 255;
        self.ammo_rockets = 255;
        self.ammo_cells = 255;
    }

    // Axes only
    if (deathmatch_settings.deathmatch_axe_only() != 0) {
        self.ammo_nails = 0;
        self.ammo_shells = 0;
        self.ammo_rockets = 0;
        self.ammo_cells = 0;
        self.items = self.items - q.band(self.items, q.bor(q.bor(q.bor(q.bor(q.bor(q.bor(
            lq.IT_SHOTGUN,
            lq.IT_SUPER_SHOTGUN,
        ), lq.IT_NAILGUN), lq.IT_SUPER_NAILGUN), lq.IT_GRENADE_LAUNCHER), lq.IT_ROCKET_LAUNCHER), lq.IT_LIGHTNING));
        self.weapon = lq.IT_AXE;
    }

    weapons.W_SetCurrentAmmo();
}

// =============================================================================
//
//                 QUAKED FUNCTIONS
//
// =============================================================================

/// QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24)
/// {
///     model({"path": "progs/player.mdl", "skin": 0, "frame": 0});
/// }
/// The normal starting point for a level.
pub export fn info_player_start() void {}

/// QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24)
/// {
///     model({"path": "progs/player.mdl", "skin": 0, "frame": 0});
/// }
/// Only used on start map for the return point from an episode.
pub export fn info_player_start2() void {}

/// saved out by quaked in region mode
pub export fn testplayerstart() void {}

/// QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24)
/// {
///     model({"path": "progs/player.mdl", "skin": 0, "frame": 0});
/// }
/// potential spawning position for deathmatch games
pub export fn info_player_deathmatch() void {}

/// QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24)
/// {
///     model({"path": "progs/player.mdl", "skin": 0, "frame": 0});
/// }
/// potential spawning position for coop games
pub export fn info_player_coop() void {}

// =============================================================================
//
// RULES
//
// =============================================================================

/// go to the next level for deathmatch
pub export fn NextLevel() void {
    var o: Entity = undefined;

    if (nextmap.get().neq(lq.string_null.get()))
        return; // already done

    if (q.mapname.get().eql(S("start"))) {
        if (q.cvar(S("registered")) == 0) {
            q.mapname.set(S("lq_e1m1"));
        } else if (!q.has(q.serverflags.get(), 1)) {
            q.mapname.set(S("lq_e1m1"));
            q.serverflags.set(q.bor(q.serverflags.get(), 1));
        } else if (!q.has(q.serverflags.get(), 2)) {
            q.mapname.set(S("lq_e2m1"));
            q.serverflags.set(q.bor(q.serverflags.get(), 2));
        } else if (!q.has(q.serverflags.get(), 4)) {
            q.mapname.set(S("lq_e3m1"));
            q.serverflags.set(q.bor(q.serverflags.get(), 4));
        } else if (!q.has(q.serverflags.get(), 8)) {
            q.mapname.set(S("lq_e4m1"));
            q.serverflags.set(q.serverflags.get() - 7);
        }

        o = q.spawn();
        o.set(lq.map, q.mapname.get());
    } else {
        // find a trigger changelevel
        o = q.find(q.world.get(), .classname, S("trigger_changelevel"));

        if (o.isNull() or q.mapname.get().eql(S("start"))) { // go back to same map if no trigger_changelevel
            o = q.spawn();
            o.set(lq.map, q.mapname.get());
        }
    }

    nextmap.set(o.get(lq.map));
    lq.gameover.set(lq.TRUE); // gb

    if (o.nextthink < q.time.get()) {
        o.think = q.func(execute_changelevel);
        o.nextthink = q.time.get() + 0.1;
    }
}

/// CheckRules
///
/// Exit deathmatch games upon conditions
pub export fn CheckRules() void {
    const self = q.me();
    if (lq.gameover.get() != 0) // someone else quit the game already
        return;

    if (lq.timelimit.get() != 0 and q.time.get() >= lq.timelimit.get()) {
        NextLevel();
        return;
    }

    if (lq.fraglimit.get() != 0 and self.frags >= lq.fraglimit.get()) {
        NextLevel();
        return;
    }
}

//============================================================================

pub export fn PlayerDeathThink() void {
    const self = q.me();

    if (q.has(self.flags, lq.FL_ONGROUND)) {
        var forward = q.vlen(self.velocity);
        forward = forward - 20;

        if (forward <= 0) {
            self.velocity = q.vec(0, 0, 0);
        } else {
            self.velocity = q.scale(q.normalize(self.velocity), forward);
        }
    }

    // Anti-stall: If the player has been dead for too long, auto-respawn them against their will
    if (q.deathmatch.get() != 0 and (q.time.get() > self.get(lq.search_time) + 10)) {
        respawn();
        return;
    }

    // wait for all buttons released
    if (self.deadflag == lq.DEAD_DEAD) {
        if (self.button2 != 0 or self.button1 != 0 or self.button0 != 0)
            return;

        self.deadflag = lq.DEAD_RESPAWNABLE;

        return;
    }

    // wait for any button down
    if (self.button2 == 0 and self.button1 == 0 and self.button0 == 0)
        return;

    self.button0 = 0;
    self.button1 = 0;
    self.button2 = 0;
    respawn();
}

pub export fn PlayerJump() void {
    const self = q.me();
    if (q.has(self.flags, lq.FL_WATERJUMP))
        return;

    if (self.waterlevel >= 2) {
        if (self.watertype == lq.CONTENT_WATER) {
            self.velocity[2] = 100;
        } else if (self.watertype == lq.CONTENT_SLIME) {
            self.velocity[2] = 80;
        } else {
            self.velocity[2] = 50;
        }

        // play swimming sound
        if (self.get(lq.swim_flag) < q.time.get()) {
            self.set(lq.swim_flag, q.time.get() + 1);

            if (q.random() < 0.5) {
                q.sound(self, lq.CHAN_BODY, S("misc/water1.wav"), 1, lq.ATTN_NORM);
            } else {
                q.sound(self, lq.CHAN_BODY, S("misc/water2.wav"), 1, lq.ATTN_NORM);
            }
        }

        return;
    }

    if (!q.has(self.flags, lq.FL_ONGROUND))
        return;

    if (!q.has(self.flags, lq.FL_JUMPRELEASED))
        return; // don't pogo stick

    self.flags = self.flags - q.band(self.flags, lq.FL_JUMPRELEASED);

    self.button2 = 0;
    // player jumping sound
    q.sound(self, lq.CHAN_AUTO, S("player/plyrjmp8.wav"), 1, lq.ATTN_NORM);

    self.flags = self.flags - lq.FL_ONGROUND; // don't stairwalk
    self.velocity[2] = self.velocity[2] + 270;
}

/// WaterMove
pub const dmgtime = q.userField(f32, "dmgtime");

pub export fn WaterMove() void {
    const self = q.me();
    if (self.movetype == lq.MOVETYPE_NOCLIP)
        return;

    if (self.health < 0)
        return;

    if (self.waterlevel != 3) {
        if (self.get(lq.air_finished) < q.time.get()) {
            q.sound(self, lq.CHAN_VOICE, S("player/gasp2.wav"), 1, lq.ATTN_NORM);
        } else if (self.get(lq.air_finished) < q.time.get() + 9) {
            q.sound(self, lq.CHAN_VOICE, S("player/gasp1.wav"), 1, lq.ATTN_NORM);
        }
        self.set(lq.air_finished, q.time.get() + 12);
        self.set(lq.dmg, 2);
    } else if (self.get(lq.air_finished) < q.time.get()) { // drown!
        if (self.get(lq.pain_finished) < q.time.get()) {
            self.set(lq.dmg, self.get(lq.dmg) + 2);

            if (self.get(lq.dmg) > 15)
                self.set(lq.dmg, 10);

            self.set(lq.deathtype, S("drowning"));
            combat.T_Damage(self, q.world.get(), q.world.get(), self.get(lq.dmg));
            self.set(lq.pain_finished, q.time.get() + 1);
        }
    }

    if (self.waterlevel == 0) {
        if (q.has(self.flags, lq.FL_INWATER)) {
            // play leave water sound
            q.sound(self, lq.CHAN_BODY, S("misc/outwater.wav"), 1, lq.ATTN_NORM);
            self.flags = self.flags - lq.FL_INWATER;
        }

        return;
    }

    if (self.watertype == lq.CONTENT_LAVA) { // do damage
        if (self.get(dmgtime) < q.time.get()) {
            if (self.get(lq.radsuit_finished) > q.time.get()) {
                self.set(dmgtime, q.time.get() + 1);
            } else {
                self.set(dmgtime, q.time.get() + 0.2);
            }

            self.set(lq.deathtype, S("lava"));
            combat.T_Damage(self, q.world.get(), q.world.get(), 10 * self.waterlevel);
        }
    } else if (self.watertype == lq.CONTENT_SLIME) { // do damage
        if (self.get(dmgtime) < q.time.get() and self.get(lq.radsuit_finished) < q.time.get()) {
            self.set(dmgtime, q.time.get() + 1);
            self.set(lq.deathtype, S("slime"));
            combat.T_Damage(self, q.world.get(), q.world.get(), 4 * self.waterlevel);
        }
    }

    if (!q.has(self.flags, lq.FL_INWATER)) {

        // player enter water sound

        if (self.watertype == lq.CONTENT_LAVA)
            q.sound(self, lq.CHAN_BODY, S("player/inlava.wav"), 1, lq.ATTN_NORM);

        if (self.watertype == lq.CONTENT_WATER)
            q.sound(self, lq.CHAN_BODY, S("player/inh2o.wav"), 1, lq.ATTN_NORM);

        if (self.watertype == lq.CONTENT_SLIME)
            q.sound(self, lq.CHAN_BODY, S("player/slimbrn2.wav"), 1, lq.ATTN_NORM);

        self.flags = self.flags + lq.FL_INWATER;
        self.set(dmgtime, 0);
    }

    if (!q.has(self.flags, lq.FL_WATERJUMP))
        self.velocity = self.velocity - q.scale(self.velocity, 0.8 * self.waterlevel * q.frametime.get());
}

pub export fn CheckWaterJump() void {
    const self = q.me();

    // check for a jump-out-of-water
    subs.makevectors2(self.angles);
    var start: Vector = self.origin;
    start[2] = start[2] + 8;
    q.v_forward_z.set(0);
    _ = q.normalize(q.v_forward.get());
    var end = start + q.scale(q.v_forward.get(), 24);
    q.traceline(start, end, lq.TRUE, self);

    if (q.trace_fraction.get() < 1) { // solid at waist
        start[2] = start[2] + self.maxs[2] - 8;
        end = start + q.scale(q.v_forward.get(), 24);
        self.movedir = q.scale(q.trace_plane_normal.get(), -50);
        q.traceline(start, end, lq.TRUE, self);

        if (q.trace_fraction.get() == 1) { // open at eye level
            self.flags = q.bor(self.flags, lq.FL_WATERJUMP);
            self.velocity[2] = 225;
            self.flags = self.flags - q.band(self.flags, lq.FL_JUMPRELEASED);
            self.teleport_time = q.time.get() + 2; // safety net

            return;
        }
    }
}

/// PlayerPreThink
///
/// Called every frame before physics are run
pub export fn PlayerPreThink() void {
    const self = q.me();
    if (intermission_running.get() != 0) {
        IntermissionThink(); // otherwise a button could be missed between
        return; // the think tics
    }

    if (q.veq(self.view_ofs, q.vec(0, 0, 0)))
        return; // intermission or finale

    q.makevectors(self.v_angle); // is this still used

    if (q.deathmatch.get() != 0 or q.coop.get() != 0) // gb, this is a waste in SP
        CheckRules();

    WaterMove();

    if (self.waterlevel == 2)
        CheckWaterJump();

    if (self.deadflag >= lq.DEAD_DEAD) {
        PlayerDeathThink();
        return;
    }

    if (self.deadflag == lq.DEAD_DYING)
        return; // dying, so do nothing

    if (self.button2 != 0) {
        PlayerJump();
    } else {
        self.flags = q.bor(self.flags, lq.FL_JUMPRELEASED);
    }

    // teleporters can force a non-moving pause time
    if (q.time.get() < self.get(lq.pausetime))
        self.velocity = q.vec(0, 0, 0);

    if (q.time.get() > self.get(lq.attack_finished) and self.currentammo == 0 and self.weapon != lq.IT_AXE) {
        self.weapon = weapons.W_BestWeapon();
        weapons.W_SetCurrentAmmo();
    }
}

/// CheckPowerups
///
/// Check for turning off powerups
pub export fn CheckPowerups() void {
    const self = q.me();
    if (self.health <= 0)
        return;

    // invisibility
    if (self.get(lq.invisible_finished) != 0) {
        // sound and screen flash when items starts to run out
        if (self.get(lq.invisible_sound) < q.time.get()) {
            q.sound(self, lq.CHAN_AUTO, S("items/inv3.wav"), 0.5, lq.ATTN_IDLE);
            self.set(lq.invisible_sound, q.time.get() + ((q.random() * 3) + 1));
        }

        if (self.get(lq.invisible_finished) < q.time.get() + 3) {
            if (self.get(lq.invisible_time) == 1) {
                lq.sprint(self, lq.PRINT_HIGH, S(loc.LOC_ITEM_FADE_SHADRING));
                lq.sprint(self, lq.PRINT_HIGH, S("\n"));
                q.stuffcmd(self, S("bf\n"));
                q.sound(self, lq.CHAN_AUTO, S("items/inv2.wav"), 1, lq.ATTN_NORM);
                self.set(lq.invisible_time, q.time.get() + 1);
            }

            if (self.get(lq.invisible_time) < q.time.get()) {
                self.set(lq.invisible_time, q.time.get() + 1);
                q.stuffcmd(self, S("bf\n"));
            }
        }

        if (self.get(lq.invisible_finished) < q.time.get()) { // just stopped
            self.items = self.items - lq.IT_INVISIBILITY;
            self.set(lq.invisible_finished, 0);
            self.set(lq.invisible_time, 0);
        }

        // use the eyes
        self.frame = 0;
        self.modelindex = modelindex_eyes.get();
    } else {
        self.modelindex = modelindex_player.get(); // don't use eyes
    }

    // invincibility
    if (self.get(lq.invincible_finished) != 0) {
        // sound and screen flash when items starts to run out
        if (self.get(lq.invincible_finished) < q.time.get() + 3) {
            if (self.get(lq.invincible_time) == 1) {
                lq.sprint(self, lq.PRINT_HIGH, S(loc.LOC_ITEM_FADE_PENTPROT));
                lq.sprint(self, lq.PRINT_HIGH, S("\n"));
                q.stuffcmd(self, S("bf\n"));
                q.sound(self, lq.CHAN_AUTO, S("items/protect2.wav"), 1, lq.ATTN_NORM);
                self.set(lq.invincible_time, q.time.get() + 1);
            }

            if (self.get(lq.invincible_time) < q.time.get()) {
                self.set(lq.invincible_time, q.time.get() + 1);
                q.stuffcmd(self, S("bf\n"));
            }
        }

        if (self.get(lq.invincible_finished) < q.time.get()) { // just stopped
            self.items = self.items - lq.IT_INVULNERABILITY;
            self.set(lq.invincible_time, 0);
            self.set(lq.invincible_finished, 0);
        }
        if (self.get(lq.invincible_finished) > q.time.get()) {
            self.effects = q.bor(self.effects, lq.EF_DIMLIGHT);
        } else {
            self.effects = self.effects - q.band(self.effects, lq.EF_DIMLIGHT);
        }
    }

    // super damage
    if (self.get(lq.super_damage_finished) != 0) {

        // sound and screen flash when items starts to run out
        if (self.get(lq.super_damage_finished) < q.time.get() + 3) {
            if (self.get(lq.super_time) == 1) {
                if (deathmatch_settings.deathmatch_supermode()) {
                    lq.sprint(self, lq.PRINT_HIGH, S(loc.LOC_ITEM_FADE_OCTDMG));
                } else {
                    lq.sprint(self, lq.PRINT_HIGH, S(loc.LOC_ITEM_FADE_QUADDMG));
                }
                lq.sprint(self, lq.PRINT_HIGH, S("\n"));
                q.stuffcmd(self, S("bf\n"));
                q.sound(self, lq.CHAN_AUTO, S("items/damage2.wav"), 1, lq.ATTN_NORM);
                self.set(lq.super_time, q.time.get() + 1);
            }

            if (self.get(lq.super_time) < q.time.get()) {
                self.set(lq.super_time, q.time.get() + 1);
                q.stuffcmd(self, S("bf\n"));
            }
        }

        if (self.get(lq.super_damage_finished) < q.time.get()) { // just stopped
            self.items = self.items - lq.IT_QUAD;
            if (deathmatch_settings.deathmatch_supermode()) {
                self.ammo_cells = 255;
                self.armorvalue = 1;
                self.armortype = 0.8;
                self.health = 100;
            }
            self.set(lq.super_damage_finished, 0);
            self.set(lq.super_time, 0);
        }
        if (self.get(lq.super_damage_finished) > q.time.get()) {
            self.effects = q.bor(self.effects, lq.EF_DIMLIGHT);
        } else {
            self.effects = self.effects - q.band(self.effects, lq.EF_DIMLIGHT);
        }
    }

    // suit
    if (self.get(lq.radsuit_finished) != 0) {
        self.set(lq.air_finished, q.time.get() + 12); // don't drown

        // sound and screen flash when items starts to run out
        if (self.get(lq.radsuit_finished) < q.time.get() + 3) {
            if (self.get(lq.rad_time) == 1) {
                lq.sprint(self, lq.PRINT_HIGH, S(loc.LOC_ITEM_FADE_BIOSUIT));
                lq.sprint(self, lq.PRINT_HIGH, S("\n"));
                q.stuffcmd(self, S("bf\n"));
                q.sound(self, lq.CHAN_AUTO, S("items/suit2.wav"), 1, lq.ATTN_NORM);
                self.set(lq.rad_time, q.time.get() + 1);
            }

            if (self.get(lq.rad_time) < q.time.get()) {
                self.set(lq.rad_time, q.time.get() + 1);
                q.stuffcmd(self, S("bf\n"));
            }
        }

        if (self.get(lq.radsuit_finished) < q.time.get()) { // just stopped
            self.items = self.items - lq.IT_SUIT;
            self.set(lq.rad_time, 0);
            self.set(lq.radsuit_finished, 0);
        }
    }
}

/// PlayerPostThink
///
/// Called every frame after physics are run
pub export fn PlayerPostThink() void {
    const self = q.me();
    if (q.veq(self.view_ofs, q.vec(0, 0, 0)))
        return; // intermission or finale

    if (self.deadflag != 0)
        return;

    // check to see if player landed and play landing sound
    if ((self.get(lq.jump_flag) < -300) and q.has(self.flags, lq.FL_ONGROUND) and (self.health > 0)) {
        if (self.watertype == lq.CONTENT_WATER) {
            q.sound(self, lq.CHAN_BODY, S("player/h2ojump.wav"), 1, lq.ATTN_NORM);
        } else if (self.get(lq.jump_flag) < -650) {
            self.set(lq.deathtype, S("falling")); // Moved up so it happens before damage    // ZungryWare
            combat.T_Damage(self, q.world.get(), q.world.get(), 5);
            q.sound(self, lq.CHAN_VOICE, S("player/land2.wav"), 1, lq.ATTN_NORM);
        } else {
            q.sound(self, lq.CHAN_VOICE, S("player/land.wav"), 1, lq.ATTN_NORM);
        }

        self.set(lq.jump_flag, 0);
    }

    if (!q.has(self.flags, lq.FL_ONGROUND))
        self.set(lq.jump_flag, self.velocity[2]);

    CheckPowerups();

    weapons.W_WeaponFrame(); // do weapon stuff
}

/// ClientConnect
///
/// called when a player connects to a server
pub export fn ClientConnect() void {
    const self = q.me();
    lq.bprint(lq.PRINT_HIGH, self.netname);
    lq.bprint(lq.PRINT_HIGH, S(loc.LOC_CLIENT_JOIN));
    lq.bprint(lq.PRINT_HIGH, S("\n"));

    // a client connecting during an intermission can cause problems
    if (intermission_running.get() != 0)
        ExitIntermission();
}

/// ClientDisconnect
///
/// called when a player disconnects from a server
pub export fn ClientDisconnect() void {
    const self = q.me();
    if (lq.gameover.get() != 0)
        return;

    // if the level end trigger has been activated, just return
    // since they aren't *really* leaving

    // let everyone else know
    lq.bprint(lq.PRINT_HIGH, self.netname);
    lq.bprint(lq.PRINT_HIGH, S(loc.LOC_CLIENT_DISCON_A));
    lq.bprint(lq.PRINT_HIGH, q.ftos(self.frags));
    lq.bprint(lq.PRINT_HIGH, S(loc.LOC_CLIENT_DISCON_B));
    lq.bprint(lq.PRINT_HIGH, S("\n"));
    q.sound(self, lq.CHAN_BODY, S("player/tornoff2.wav"), 1, lq.ATTN_NONE);
    player.set_suicide_frame();
}

/// ClientObituary
///
/// called when a player dies
pub export fn ClientObituary(targ: Entity, attacker: Entity) void {
    const PRINT_MEDIUM = lq.PRINT_MEDIUM;
    const bprint = lq.bprint;

    // gb
    const attackerteam = attacker.team;
    const targteam = targ.team;
    const on_team: f32 = if (attackerteam != 0) 1 else 0;

    var deathstring = lq.string_null.get();
    var deathstring2 = lq.string_null.get();

    var rnum = q.random();

    if (targ.get(lq.deathtype).eql(S("selfwater"))) {
        bprint(PRINT_MEDIUM, targ.netname);
        bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_DISCHARGE_SELF));
        bprint(PRINT_MEDIUM, S("\n"));
        targ.frags = targ.frags - 1;
        return;
    }

    if (targ.classname.eql(S("player"))) {
        if (attacker.classname.eql(S("teledeath")) or attacker.classname.eql(S("teledeath3"))) {
            bprint(PRINT_MEDIUM, targ.netname);
            bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_TELEFRAG));
            bprint(PRINT_MEDIUM, attacker.owner.netname);
            bprint(PRINT_MEDIUM, S("\n"));

            attacker.owner.frags = attacker.owner.frags + 1;
            lq.logfrag(attacker.owner, targ);

            return;
        }

        if (attacker.classname.eql(S("teledeath2"))) {
            bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_DEFLECT_A));
            bprint(PRINT_MEDIUM, targ.netname);
            bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_DEFLECT_B));
            bprint(PRINT_MEDIUM, attacker.owner.netname);
            bprint(PRINT_MEDIUM, S("\n"));

            attacker.owner.frags = attacker.owner.frags + 1;
            lq.logfrag(attacker.owner, targ);

            return;
        }

        if (attacker.classname.eql(S("trigger_hurt"))) {
            // Custom death messages for trigger_hurt
            if (attacker.get(lq.dmg) == 666000) {
                bprint(PRINT_MEDIUM, targ.netname);

                if (q.random() < 0.01) {
                    bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_FALL2));
                } else {
                    bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_FALL1));
                }

                bprint(PRINT_MEDIUM, S("\n"));
                return;
            }

            if (attacker.get(lq.dmg) == 666001) {
                bprint(PRINT_MEDIUM, targ.netname);

                if (q.random() < 0.01) {
                    bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_SPACE2));
                } else {
                    bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_SPACE1));
                }

                bprint(PRINT_MEDIUM, S("\n"));
                return;
            }

            if (attacker.get(lq.dmg) == 666002) {
                bprint(PRINT_MEDIUM, targ.netname);

                if (q.random() < 0.01) {
                    bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_VOID2));
                } else {
                    bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_VOID1));
                }

                bprint(PRINT_MEDIUM, S("\n"));
                return;
            }
        }

        if (targ.get(lq.deathtype).eql(S("squish"))) {
            if (q.teamplay.get() != 0 and targteam == attackerteam and on_team != 0 and targ.neq(attacker)) {
                lq.logfrag(attacker, attacker);
                attacker.frags = attacker.frags - 1;
                bprint(PRINT_MEDIUM, attacker.netname);
                bprint(PRINT_MEDIUM, S(loc.LOC_TEAMKILL_SQUISH));
                bprint(PRINT_MEDIUM, S("\n"));
                return;
            } else if (attacker.classname.eql(S("player")) and attacker.neq(targ)) {
                bprint(PRINT_MEDIUM, targ.netname);
                bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_SQUISH2));
                bprint(PRINT_MEDIUM, attacker.netname);
                bprint(PRINT_MEDIUM, S("\n"));
                lq.logfrag(attacker, targ);
                attacker.frags = attacker.frags + 1;
                return;
            } else {
                lq.logfrag(targ, targ);
                targ.frags = targ.frags - 1; // killed self
                bprint(PRINT_MEDIUM, targ.netname);
                bprint(PRINT_MEDIUM, S(" was squished\n"));
                return;
            }
        }

        if (attacker.classname.eql(S("player"))) {
            if (targ.eql(attacker)) {
                // killed self
                lq.logfrag(attacker, attacker);
                attacker.frags = attacker.frags - 1;
                bprint(PRINT_MEDIUM, targ.netname);

                if (targ.get(lq.deathtype).eql(S("grenade"))) {
                    bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_SELF_GRENADE));
                    bprint(PRINT_MEDIUM, S("\n"));
                } else if (targ.get(lq.deathtype).eql(S("rocket"))) {
                    bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_SELF_ROCKET));
                    bprint(PRINT_MEDIUM, S("\n"));
                } else if (targ.get(lq.deathtype).eql(S("discharge"))) {
                    if (targ.watertype == lq.CONTENT_SLIME) {
                        bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_DISCHARGE_SLIME));
                    } else if (targ.watertype == lq.CONTENT_LAVA) {
                        bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_DISCHARGE_LAVA));
                    } else {
                        bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_DISCHARGE_WATER));
                    }

                    bprint(PRINT_MEDIUM, S("\n"));
                    return;
                } else {
                    bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_SELF_OTHER));
                    bprint(PRINT_MEDIUM, S("\n"));
                }
                return;
            } else if ((q.teamplay.get() != 0) and (targteam == attackerteam) and on_team != 0) { // gb
                if (rnum < 0.25) {
                    deathstring = S(loc.LOC_TEAMKILL_1);
                } else if (rnum < 0.50) {
                    deathstring = S(loc.LOC_TEAMKILL_2);
                } else if (rnum < 0.75) {
                    deathstring = S(loc.LOC_TEAMKILL_3);
                } else {
                    deathstring = S(loc.LOC_TEAMKILL_4);
                }

                bprint(PRINT_MEDIUM, attacker.netname);
                bprint(PRINT_MEDIUM, deathstring);
                bprint(PRINT_MEDIUM, S("\n"));
                attacker.frags = attacker.frags - 1;
                //ZOID 12-13-96:  killing a teammate logs as suicide
                lq.logfrag(attacker, attacker);
                return;
            } else {
                lq.logfrag(attacker, targ);
                attacker.frags = attacker.frags + 1;

                const attacker_weapon = attacker.weapon;
                _ = attacker_weapon;

                // Axe
                if (targ.get(lq.deathtype).eql(S("axe"))) {
                    deathstring = S(loc.LOC_DEATH_AXE_1A);
                    deathstring2 = S(loc.LOC_DEATH_AXE_1B);

                    if (attacker.get(lq.super_damage_finished) > 0) {
                        deathstring = S(loc.LOC_DEATH_AXE_QA);
                        deathstring2 = S(loc.LOC_DEATH_AXE_QB);
                    } else if (q.random() < 0.01) {
                        deathstring = S(loc.LOC_DEATH_AXE_2A);
                        deathstring2 = S(loc.LOC_DEATH_AXE_2B);
                    }
                }

                // Shotgun
                else if (targ.get(lq.deathtype).eql(S("shotgun"))) {
                    deathstring = S(loc.LOC_DEATH_SHOTGUN_1A);
                    deathstring2 = S(loc.LOC_DEATH_SHOTGUN_1B);

                    if (attacker.get(lq.super_damage_finished) > 0) {
                        deathstring = S(loc.LOC_DEATH_SHOTGUN_QA);
                        deathstring2 = S(loc.LOC_DEATH_SHOTGUN_QB);
                    } else if (q.random() < 0.01) {
                        deathstring = S(loc.LOC_DEATH_SHOTGUN_2A);
                        deathstring2 = S(loc.LOC_DEATH_SHOTGUN_2B);
                    }
                }

                // Super Shotgun
                else if (targ.get(lq.deathtype).eql(S("supershotgun"))) {
                    deathstring = S(loc.LOC_DEATH_SUPER_SHOTGUN_1A);
                    deathstring2 = S(loc.LOC_DEATH_SUPER_SHOTGUN_1B);

                    if (attacker.get(lq.super_damage_finished) > 0) {
                        deathstring = S(loc.LOC_DEATH_SUPER_SHOTGUN_QA);
                        deathstring2 = S(loc.LOC_DEATH_SUPER_SHOTGUN_QB);
                    } else if (q.random() < 0.01) {
                        deathstring = S(loc.LOC_DEATH_SUPER_SHOTGUN_2A);
                        deathstring2 = S(loc.LOC_DEATH_SUPER_SHOTGUN_2B);
                    }
                }

                // Nailgun
                else if (targ.get(lq.deathtype).eql(S("nail"))) {
                    deathstring = S(loc.LOC_DEATH_NAILGUN_1A);
                    deathstring2 = S(loc.LOC_DEATH_NAILGUN_1B);

                    if (attacker.get(lq.super_damage_finished) > 0) {
                        deathstring = S(loc.LOC_DEATH_NAILGUN_QA);
                        deathstring2 = S(loc.LOC_DEATH_NAILGUN_QB);
                    } else if (q.random() < 0.01) {
                        deathstring = S(loc.LOC_DEATH_NAILGUN_2A);
                        deathstring2 = S(loc.LOC_DEATH_NAILGUN_2B);
                    }
                }

                // Super Nailgun
                else if (targ.get(lq.deathtype).eql(S("supernail"))) {
                    deathstring = S(loc.LOC_DEATH_SUPER_NAILGUN_1A);
                    deathstring2 = S(loc.LOC_DEATH_SUPER_NAILGUN_1B);

                    if (attacker.get(lq.super_damage_finished) > 0) {
                        deathstring = S(loc.LOC_DEATH_SUPER_NAILGUN_QA);
                        deathstring2 = S(loc.LOC_DEATH_SUPER_NAILGUN_QB);
                    } else if (q.random() < 0.01) {
                        deathstring = S(loc.LOC_DEATH_SUPER_NAILGUN_2A);
                        deathstring2 = S(loc.LOC_DEATH_SUPER_NAILGUN_2B);
                    }
                }

                // Grenade Launcher
                else if (targ.get(lq.deathtype).eql(S("grenade"))) {
                    deathstring = S(loc.LOC_DEATH_GRENADE_LAUNCHER_1A);
                    deathstring2 = S(loc.LOC_DEATH_GRENADE_LAUNCHER_1B);

                    if (attacker.get(lq.super_damage_finished) > 0) {
                        deathstring = S(loc.LOC_DEATH_GRENADE_LAUNCHER_QA);
                        deathstring2 = S(loc.LOC_DEATH_GRENADE_LAUNCHER_QB);
                    } else if (targ.health < -40) {
                        deathstring = S(loc.LOC_DEATH_GRENADE_LAUNCHER_GA);
                        deathstring2 = S(loc.LOC_DEATH_GRENADE_LAUNCHER_GB);
                    } else if (q.random() < 0.01) {
                        deathstring = S(loc.LOC_DEATH_GRENADE_LAUNCHER_2A);
                        deathstring2 = S(loc.LOC_DEATH_GRENADE_LAUNCHER_2B);
                    }
                }

                // Rocket Launcher
                else if (targ.get(lq.deathtype).eql(S("rocket"))) {
                    deathstring = S(loc.LOC_DEATH_ROCKET_LAUNCHER_1A);
                    deathstring2 = S(loc.LOC_DEATH_ROCKET_LAUNCHER_1B);

                    if (attacker.get(lq.super_damage_finished) > 0) {
                        deathstring = S(loc.LOC_DEATH_ROCKET_LAUNCHER_Q1A);
                        deathstring2 = S(loc.LOC_DEATH_ROCKET_LAUNCHER_Q1B);
                    } else if (targ.health < -40) {
                        deathstring = S(loc.LOC_DEATH_ROCKET_LAUNCHER_GA);
                        deathstring2 = S(loc.LOC_DEATH_ROCKET_LAUNCHER_GB);
                    } else if (q.random() < 0.01) {
                        deathstring = S(loc.LOC_DEATH_ROCKET_LAUNCHER_2A);
                        deathstring2 = S(loc.LOC_DEATH_ROCKET_LAUNCHER_2B);
                    }
                }

                // Lightning Gun
                else if (targ.get(lq.deathtype).eql(S("lightning"))) {
                    deathstring = S(loc.LOC_DEATH_LIGHTNING_1A);
                    deathstring2 = S(loc.LOC_DEATH_LIGHTNING_1B);

                    if (attacker.get(lq.super_damage_finished) > 0) {
                        deathstring = S(loc.LOC_DEATH_LIGHTNING_QA);
                        deathstring2 = S(loc.LOC_DEATH_LIGHTNING_QB);
                    } else if (q.random() < 0.01) {
                        deathstring = S(loc.LOC_DEATH_LIGHTNING_2A);
                        deathstring2 = S(loc.LOC_DEATH_LIGHTNING_2B);
                    }
                }

                // Lightning Gun Discharge
                else if (targ.get(lq.deathtype).eql(S("discharge"))) {
                    deathstring = S(loc.LOC_DEATH_LIGHTNING_DA);
                    deathstring2 = S(loc.LOC_DEATH_LIGHTNING_DB);
                }

                // Unknown Cause
                else {
                    deathstring = S(loc.LOC_DEATH_KILL);
                    deathstring2 = S(loc.LOC_DEATH_KILL);
                }

                bprint(PRINT_MEDIUM, targ.netname);
                bprint(PRINT_MEDIUM, deathstring);
                bprint(PRINT_MEDIUM, attacker.netname);
                bprint(PRINT_MEDIUM, deathstring2);
                bprint(PRINT_MEDIUM, S("\n"));
            }
            return;
        } else {
            lq.logfrag(targ, targ);
            targ.frags = targ.frags - 1; // killed self
            bprint(PRINT_MEDIUM, targ.netname);

            if (attacker.solid == lq.SOLID_BSP and attacker.neq(q.world.get())) {
                bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_SQUISH));
                bprint(PRINT_MEDIUM, S("\n"));
                return;
            }

            if (targ.get(lq.deathtype).eql(S("falling"))) {
                targ.set(lq.deathtype, lq.string_null.get());

                if (q.random() < 0.01) {
                    bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_FALL2));
                } else {
                    bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_FALL1));
                }

                bprint(PRINT_MEDIUM, S("\n"));
                return;
            }

            if (targ.get(lq.deathtype).eql(S("drowning"))) {
                rnum = q.random();

                if (rnum < 0.5) {
                    bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_DROWN1));
                    bprint(PRINT_MEDIUM, S("\n"));
                } else {
                    bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_DROWN2));
                    bprint(PRINT_MEDIUM, S("\n"));
                }

                return;
            }

            if (targ.get(lq.deathtype).eql(S("slime"))) {
                if (q.random() < 0.5) {
                    bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_SLIME1));
                    bprint(PRINT_MEDIUM, S("\n"));
                } else {
                    bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_SLIME2));
                    bprint(PRINT_MEDIUM, S("\n"));
                }
                return;
            }

            if (targ.get(lq.deathtype).eql(S("lava"))) {
                if (targ.health < -15) {
                    bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_LAVA3));
                    bprint(PRINT_MEDIUM, S("\n"));
                    return;
                }

                if (q.random() < 0.5) {
                    bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_LAVA1));
                    bprint(PRINT_MEDIUM, S("\n"));
                } else {
                    bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_LAVA2));
                    bprint(PRINT_MEDIUM, S("\n"));
                }
                return;
            }

            //FIXME string_nul ??? maybe not necessary    //gnounc
            // yes, a null-check makes sense here       //SavageX
            if (attacker.get(lq.killstring).neq(lq.string_null.get())) { //gnounc
                bprint(PRINT_MEDIUM, attacker.get(lq.killstring));
                bprint(PRINT_MEDIUM, S("\n")); // Added since killstrings in LOC don't have \n    // ZungryWare
                return;
            }

            bprint(PRINT_MEDIUM, S(loc.LOC_DEATH_OTHER));
            bprint(PRINT_MEDIUM, S("\n"));
        }
    }
}
