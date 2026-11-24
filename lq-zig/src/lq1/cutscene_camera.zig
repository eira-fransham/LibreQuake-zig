//! lq1/cutscene_camera.qc
//!
//! Copyright (C) 2024 Ivy Bowling <motolegacy@proton.me>
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

const q = @import("../defs.zig");
const lq = @import("../lq.zig");
const loc = @import("../localized_text.zig");
const S = q.S;
const Entity = q.Entity;

pub const LQ_MAXCAMERAS: f32 = 3;

pub const cameras_in_world = q.userGlobal(f32, "cameras_in_world");

pub const clients_at_camera = q.userGlobal(f32, "clients_at_camera");

pub const time_between_cameras = q.userGlobal(f32, "time_between_cameras");

/// LQ_SpawnCamera
pub export fn LQ_SpawnCamera() void {
    const self = q.me();
    if (q.cvar(S("developer")) == 0) {
        lq.bprint(lq.PRINT_HIGH, S(loc.LOC_LQ_ISDEVELOPER));
        lq.bprint(lq.PRINT_HIGH, S("\n"));
        return;
    }

    if (cameras_in_world.get() >= LQ_MAXCAMERAS) {
        lq.bprint(lq.PRINT_HIGH, S(loc.LOC_LQ_CAMERAS_MAX));
        lq.bprint(lq.PRINT_HIGH, S("\n"));
        return;
    }

    // (Unset if no case matches, which can't happen after the check above.)
    var camera_targetname = lq.string_null.get();
    const camera = q.spawn();
    camera.classname = S("lq_camera");

    switch (@as(i32, @intFromFloat(cameras_in_world.get()))) {
        0 => camera_targetname = S("lq_camera_1"),
        1 => camera_targetname = S("lq_camera_2"),
        2 => camera_targetname = S("lq_camera_3"),
        else => {},
    }

    camera.targetname = camera_targetname;

    q.setorigin(camera, self.origin);
    camera.angles = self.v_angle;

    cameras_in_world.set(cameras_in_world.get() + 1);

    lq.bprint(lq.PRINT_HIGH, S(loc.LOC_LQ_CAMERA_SPAWN_A));
    lq.bprint(lq.PRINT_HIGH, q.ftos(LQ_MAXCAMERAS - cameras_in_world.get()));
    lq.bprint(lq.PRINT_HIGH, S(loc.LOC_LQ_CAMERA_SPAWN_B));
    lq.bprint(lq.PRINT_HIGH, S("\n"));
}

/// LQ_AppendCameraTime
pub export fn LQ_AppendCameraTime(time_addition: f32) void {
    if (q.cvar(S("developer")) == 0) {
        lq.bprint(lq.PRINT_HIGH, S(loc.LOC_LQ_ISDEVELOPER));
        lq.bprint(lq.PRINT_HIGH, S("\n"));
        return;
    }

    time_between_cameras.set(time_between_cameras.get() + time_addition);

    if (time_between_cameras.get() <= 0)
        time_between_cameras.set(1);

    lq.bprint(lq.PRINT_HIGH, S(loc.LOC_LQ_CAMERA_TIME_A));
    lq.bprint(lq.PRINT_HIGH, q.ftos(time_between_cameras.get()));
    lq.bprint(lq.PRINT_HIGH, S(loc.LOC_LQ_CAMERA_TIME_B));
    lq.bprint(lq.PRINT_HIGH, S("\n"));
}

/// LQ_ChangeCamera
pub export fn LQ_ChangeCamera() void {
    const self = q.me();
    // If there's only one camera in the world,
    // don't bother. Stick here.
    if (cameras_in_world.get() == 1)
        return;

    // (Uninitialised in the original; `world` if no camera is found.)
    var camera = q.world.get();

    // Look for second camera if at first
    if (clients_at_camera.get() == 1) {
        camera = q.find(q.world.get(), .targetname, S("lq_camera_2"));
        clients_at_camera.set(2);
    } else {
        // At camera 3, go back to one.
        if (clients_at_camera.get() == 3) {
            camera = q.find(q.world.get(), .targetname, S("lq_camera_1"));
            clients_at_camera.set(1);
        }
        // We're at camera 2, try to find a 3rd
        if (clients_at_camera.get() == 2) {
            camera = q.find(q.world.get(), .targetname, S("lq_camera_3"));
            clients_at_camera.set(3);
        }
        // No dice, only two. go to one.
        if (camera.eql(q.world.get())) {
            camera = q.find(q.world.get(), .targetname, S("lq_camera_1"));
            clients_at_camera.set(1);
        }
    }

    var players = q.find(q.world.get(), .classname, S("player"));

    while (players.neq(q.world.get())) {
        // Plop at the camera
        q.setorigin(players, camera.origin);
        players.v_angle = camera.angles;
        players.angles = players.v_angle;

        // Set up camera change
        self.nextthink = q.time.get() + time_between_cameras.get();

        players = q.find(players, .classname, S("player"));
    }
}

/// LQ_PlayCameras
pub export fn LQ_PlayCameras() void {
    if (q.cvar(S("developer")) == 0) {
        lq.bprint(lq.PRINT_HIGH, S(loc.LOC_LQ_ISDEVELOPER));
        lq.bprint(lq.PRINT_HIGH, S("\n"));
        return;
    }

    const camera = q.find(q.world.get(), .targetname, S("lq_camera_1"));

    if (camera.eql(q.world.get())) {
        lq.bprint(lq.PRINT_HIGH, S(loc.LOC_LQ_CAMERA_NONE));
        lq.bprint(lq.PRINT_HIGH, S("\n"));
        return;
    }

    // We're at the first camera
    clients_at_camera.set(1);

    // Default time to 1 second
    if (time_between_cameras.get() == 0)
        time_between_cameras.set(1);

    // Tell the engine to turn on intermission 3
    q.WriteByte(lq.MSG_ALL, lq.SVC_CUTSCENE);
    q.WriteString(lq.MSG_ALL, S("")); // No message :)

    var players = q.find(q.world.get(), .classname, S("player"));

    while (players.neq(q.world.get())) {
        // Make the player static-ish
        players.view_ofs = q.vec(0, 0, 0);
        players.fixangle = lq.TRUE;
        players.takedamage = lq.DAMAGE_NO;
        players.solid = lq.SOLID_NOT;
        players.movetype = lq.MOVETYPE_NONE;
        players.modelindex = 0;

        // Plop them at camera one
        q.setorigin(players, camera.origin);
        players.v_angle = camera.angles;
        players.angles = players.v_angle;

        // Set up camera change
        camera.think = q.func(LQ_ChangeCamera);
        camera.nextthink = q.time.get() + time_between_cameras.get();

        players = q.find(players, .classname, S("player"));
    }
}
