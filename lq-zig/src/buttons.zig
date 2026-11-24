//! buttons.qc
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
//!
//! button and multiple button

const q = @import("defs.zig");
const lq = @import("lq.zig");
const S = q.S;
const subs = @import("subs.zig");

pub export fn button_wait() void {
    const self = q.me();
    self.set(lq.state, lq.STATE_TOP);
    self.nextthink = self.ltime + self.get(lq.wait);
    self.think = q.func(button_return);
    lq.activator.set(self.enemy);
    subs.SUB_UseTargets();
    self.frame = 1; // use alternate textures
}

pub export fn button_done() void {
    q.me().set(lq.state, lq.STATE_BOTTOM);
}

pub export fn button_return() void {
    const self = q.me();
    self.set(lq.state, lq.STATE_DOWN);
    subs.SUB_CalcMove(self.get(lq.pos1), self.get(lq.speed), q.func(button_done));
    self.frame = 0; // use normal textures

    if (self.health != 0)
        self.takedamage = lq.DAMAGE_YES; // can be shot again
}

pub export fn button_blocked() void {
    // do nothing, just don't ome all the way back out
}

pub export fn button_fire() void {
    const self = q.me();
    if (self.get(lq.state) == lq.STATE_UP or self.get(lq.state) == lq.STATE_TOP)
        return;

    q.sound(self, lq.CHAN_VOICE, self.noise, 1, lq.ATTN_NORM);

    self.set(lq.state, lq.STATE_UP);
    subs.SUB_CalcMove(self.get(lq.pos2), self.get(lq.speed), q.func(button_wait));
}

pub export fn button_use() void {
    q.me().enemy = lq.activator.get();
    button_fire();
}

pub export fn button_touch() void {
    const other = q.other.get();
    if (other.classname.neq(S("player")))
        return;

    q.me().enemy = other;
    button_fire();
}

pub export fn button_killed() void {
    const self = q.me();
    self.enemy = lq.damage_attacker.get();
    self.health = self.max_health;
    self.takedamage = lq.DAMAGE_NO; // wil be reset upon return
    button_fire();
}

/// QUAKED func_button (0 .5 .8) ?
/// When a button is touched, it moves some distance in the direction of it's angle, triggers all of it's targets, waits some time, then returns to it's original position where it can be triggered again.
///
/// "angle"     determines the opening direction
/// "target"    all entities with a matching targetname will be used
/// "speed"     override the default 40 speed
/// "wait"      override the default 1 second wait (-1 = never return)
/// "lip"       override the default 4 pixel lip remaining at end of move
/// "health"    if set, the button must be killed instead of touched
/// "sounds"
/// 0) steam metal
/// 1) wooden clunk
/// 2) metallic click
/// 3) in-out
pub export fn func_button() void {
    const self = q.me();

    if (self.sounds == 0) {
        _ = q.precache_sound(S("buttons/airbut1.wav"));
        self.noise = S("buttons/airbut1.wav");
    }

    if (self.sounds == 1) {
        _ = q.precache_sound(S("buttons/switch21.wav"));
        self.noise = S("buttons/switch21.wav");
    }

    if (self.sounds == 2) {
        _ = q.precache_sound(S("buttons/switch02.wav"));
        self.noise = S("buttons/switch02.wav");
    }

    if (self.sounds == 3) {
        _ = q.precache_sound(S("buttons/switch04.wav"));
        self.noise = S("buttons/switch04.wav");
    }

    subs.SetMovedir();

    self.movetype = lq.MOVETYPE_PUSH;
    self.solid = lq.SOLID_BSP;
    q.setmodel(self, self.model);

    self.blocked = q.func(button_blocked);
    self.use = q.func(button_use);

    if (self.health != 0) {
        self.max_health = self.health;
        self.set(lq.th_die, q.func(button_killed));
        self.takedamage = lq.DAMAGE_YES;
    } else self.touch = q.func(button_touch);

    if (self.get(lq.speed) == 0)
        self.set(lq.speed, 40);

    if (self.get(lq.wait) == 0)
        self.set(lq.wait, 1);

    if (self.get(lq.lip) == 0)
        self.set(lq.lip, 4);

    self.set(lq.state, lq.STATE_BOTTOM);

    self.set(lq.pos1, self.origin);
    self.set(lq.pos2, self.get(lq.pos1) + q.scale(self.movedir, q.fabs(q.dot(self.movedir, self.size)) - self.get(lq.lip)));
}
