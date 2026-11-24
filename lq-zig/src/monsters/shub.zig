//! monsters/shub.qc

const q = @import("../defs.zig");
const lq = @import("../lq.zig");
const loc = @import("../localized_text.zig");
const S = q.S;
const Entity = q.Entity;
const Function = q.Function;
const String = q.String;
const Vector = q.Vector;
const player = @import("../player.zig");
const client = @import("../client.zig");

/// The `$frame` macros, numbered from 0 in declaration order.
const Frame = enum(u8) {
    old1,
    old2,
    old3,
    old4,
    old5,
    old6,
    old7,
    old8,
    old9,
    old10,
    old11,
    old12,
    old13,
    old14,
    old15,
    old16,
    old17,
    old18,
    old19,
    old20,
    old21,
    old22,
    old23,
    old24,
    old25,
    old26,
    old27,
    old28,
    old29,
    old30,
    old31,
    old32,
    old33,
    old34,
    old35,
    old36,
    old37,
    old38,
    old39,
    old40,
    old41,
    old42,
    old43,
    old44,
    old45,
    old46,
    shake1,
    shake2,
    shake3,
    shake4,
    shake5,
    shake6,
    shake7,
    shake8,
    shake9,
    shake10,
    shake11,
    shake12,
    shake13,
    shake14,
    shake15,
    shake16,
    shake17,
    shake18,
    shake19,
    shake20,
    shake21,
};

/// `$frame`, as a float.
inline fn fr(comptime frame: Frame) f32 {
    return @floatFromInt(@backingInt(frame));
}

/// The `[$frame, next]` prefix of a state function.
inline fn state(comptime frame: Frame, comptime next: anytype) void {
    q.setState(fr(frame), q.func(next));
}

pub const shub = q.userGlobal(Entity, "shub");

pub export fn old_idle1() void {
    state(.old1, old_idle2);
}

pub export fn old_idle2() void {
    state(.old2, old_idle3);
}

pub export fn old_idle3() void {
    state(.old3, old_idle4);
}

pub export fn old_idle4() void {
    state(.old4, old_idle5);
}

pub export fn old_idle5() void {
    state(.old5, old_idle6);
}

pub export fn old_idle6() void {
    state(.old6, old_idle7);
}

pub export fn old_idle7() void {
    state(.old7, old_idle8);
}

pub export fn old_idle8() void {
    state(.old8, old_idle9);
}

pub export fn old_idle9() void {
    state(.old9, old_idle10);
}

pub export fn old_idle10() void {
    state(.old10, old_idle11);
}

pub export fn old_idle11() void {
    state(.old11, old_idle12);
}

pub export fn old_idle12() void {
    state(.old12, old_idle13);
}

pub export fn old_idle13() void {
    state(.old13, old_idle14);
}

pub export fn old_idle14() void {
    state(.old14, old_idle15);
}

pub export fn old_idle15() void {
    state(.old15, old_idle16);
}

pub export fn old_idle16() void {
    state(.old16, old_idle17);
}

pub export fn old_idle17() void {
    state(.old17, old_idle18);
}

pub export fn old_idle18() void {
    state(.old18, old_idle19);
}

pub export fn old_idle19() void {
    state(.old19, old_idle20);
}

pub export fn old_idle20() void {
    state(.old20, old_idle21);
}

pub export fn old_idle21() void {
    state(.old21, old_idle22);
}

pub export fn old_idle22() void {
    state(.old22, old_idle23);
}

pub export fn old_idle23() void {
    state(.old23, old_idle24);
}

pub export fn old_idle24() void {
    state(.old24, old_idle25);
}

pub export fn old_idle25() void {
    state(.old25, old_idle26);
}

pub export fn old_idle26() void {
    state(.old26, old_idle27);
}

pub export fn old_idle27() void {
    state(.old27, old_idle28);
}

pub export fn old_idle28() void {
    state(.old28, old_idle29);
}

pub export fn old_idle29() void {
    state(.old29, old_idle30);
}

pub export fn old_idle30() void {
    state(.old30, old_idle31);
}

pub export fn old_idle31() void {
    state(.old31, old_idle32);
}

pub export fn old_idle32() void {
    state(.old32, old_idle33);
}

pub export fn old_idle33() void {
    state(.old33, old_idle34);
}

pub export fn old_idle34() void {
    state(.old34, old_idle35);
}

pub export fn old_idle35() void {
    state(.old35, old_idle36);
}

pub export fn old_idle36() void {
    state(.old36, old_idle37);
}

pub export fn old_idle37() void {
    state(.old37, old_idle38);
}

pub export fn old_idle38() void {
    state(.old38, old_idle39);
}

pub export fn old_idle39() void {
    state(.old39, old_idle40);
}

pub export fn old_idle40() void {
    state(.old40, old_idle41);
}

pub export fn old_idle41() void {
    state(.old41, old_idle42);
}

pub export fn old_idle42() void {
    state(.old42, old_idle43);
}

pub export fn old_idle43() void {
    state(.old43, old_idle44);
}

pub export fn old_idle44() void {
    state(.old44, old_idle45);
}

pub export fn old_idle45() void {
    state(.old45, old_idle46);
}

pub export fn old_idle46() void {
    state(.old46, old_idle1);
}

pub export fn old_thrash1() void {
    state(.shake1, old_thrash2);
    q.lightstyle(0, S("m"));
}

pub export fn old_thrash2() void {
    state(.shake2, old_thrash3);
    q.lightstyle(0, S("k"));
}

pub export fn old_thrash3() void {
    state(.shake3, old_thrash4);
    q.lightstyle(0, S("k"));
}

pub export fn old_thrash4() void {
    state(.shake4, old_thrash5);
    q.lightstyle(0, S("i"));
}

pub export fn old_thrash5() void {
    state(.shake5, old_thrash6);
    q.lightstyle(0, S("g"));
}

pub export fn old_thrash6() void {
    state(.shake6, old_thrash7);
    q.lightstyle(0, S("e"));
}

pub export fn old_thrash7() void {
    state(.shake7, old_thrash8);
    q.lightstyle(0, S("c"));
}

pub export fn old_thrash8() void {
    state(.shake8, old_thrash9);
    q.lightstyle(0, S("a"));
}

pub export fn old_thrash9() void {
    state(.shake9, old_thrash10);
    q.lightstyle(0, S("c"));
}

pub export fn old_thrash10() void {
    state(.shake10, old_thrash11);
    q.lightstyle(0, S("e"));
}

pub export fn old_thrash11() void {
    state(.shake11, old_thrash12);
    q.lightstyle(0, S("g"));
}

pub export fn old_thrash12() void {
    state(.shake12, old_thrash13);
    q.lightstyle(0, S("i"));
}

pub export fn old_thrash13() void {
    state(.shake13, old_thrash14);
    q.lightstyle(0, S("k"));
}

pub export fn old_thrash14() void {
    state(.shake14, old_thrash15);
    q.lightstyle(0, S("m"));
}

pub export fn old_thrash15() void {
    state(.shake15, old_thrash16);
    const self = q.me();
    q.lightstyle(0, S("m"));
    self.set(lq.cnt, self.get(lq.cnt) + 1);
    if (self.get(lq.cnt) != 3)
        self.think = q.func(old_thrash1);
}

pub export fn old_thrash16() void {
    state(.shake16, old_thrash17);
    q.lightstyle(0, S("g"));
}

pub export fn old_thrash17() void {
    state(.shake17, old_thrash18);
    q.lightstyle(0, S("c"));
}

pub export fn old_thrash18() void {
    state(.shake18, old_thrash19);
    q.lightstyle(0, S("b"));
}

pub export fn old_thrash19() void {
    state(.shake19, old_thrash20);
    q.lightstyle(0, S("a"));
}

pub export fn old_thrash20() void {
    state(.shake20, old_thrash20);
    finale_4();
}

pub export fn finale_1() void {
    const self = q.me();

    client.intermission_exittime.set(q.time.get() + 10000000); // never allow exit
    client.intermission_running.set(1);

    // find the intermission spot
    const pos = q.find(q.world.get(), .classname, S("info_intermission"));

    if (pos.isNull())
        q.@"error"(S("no info_intermission"));

    var pl = q.find(q.world.get(), .classname, S("misc_teleporttrain"));

    if (pl.isNull())
        q.@"error"(S("no teleporttrain"));
    q.remove(pl);

    q.WriteByte(lq.MSG_ALL, lq.SVC_FINALE);
    q.WriteString(lq.MSG_ALL, lq.string_null.get());

    pl = q.find(q.world.get(), .classname, S("player"));

    while (pl.neq(q.world.get())) {
        pl.view_ofs = q.vec(0, 0, 0);
        // (Sets `other.v_angle`, not `pl.v_angle`, as in the original.)
        q.other.get().v_angle = pos.get(lq.mangle);
        pl.angles = q.other.get().v_angle;
        pl.fixangle = lq.TRUE; // turn this way immediately
        pl.set(lq.map, self.get(lq.map));
        pl.nextthink = q.time.get() + 0.5;
        pl.takedamage = lq.DAMAGE_NO;
        pl.solid = lq.SOLID_NOT;
        pl.movetype = lq.MOVETYPE_NONE;
        pl.modelindex = 0;
        q.setorigin(pl, pos.origin);
        pl = q.find(pl, .classname, S("player"));
    }

    // make fake versions of all players as standins, and move the real
    // players to the intermission spot

    // wait for 1 second
    const timer = q.spawn();
    timer.nextthink = q.time.get() + 1;
    timer.think = q.func(finale_2);
}

pub export fn finale_2() void {
    const self = q.me();

    // start a teleport splash inside shub

    const o = @as(Vector, shub.get().origin) - q.vec(0, 100, 0);
    q.WriteByte(lq.MSG_BROADCAST, lq.SVC_TEMPENTITY);
    q.WriteByte(lq.MSG_BROADCAST, lq.TE_TELEPORT);
    q.WriteCoord(lq.MSG_BROADCAST, o[0]);
    q.WriteCoord(lq.MSG_BROADCAST, o[1]);
    q.WriteCoord(lq.MSG_BROADCAST, o[2]);

    q.sound(shub.get(), lq.CHAN_VOICE, S("misc/r_tele1.wav"), 1, lq.ATTN_NORM);

    self.nextthink = q.time.get() + 2;
    self.think = q.func(finale_3);
}

pub export fn finale_3() void {
    // start shub thrashing wildly
    shub.get().think = q.func(old_thrash1);
    q.sound(shub.get(), lq.CHAN_VOICE, S("boss2/death.wav"), 1, lq.ATTN_NORM);
    q.lightstyle(0, S("abcdefghijklmlkjihgfedcb"));
}

pub export fn finale_4() void {
    const self = q.me();
    // throw tons of meat chunks

    q.sound(self, lq.CHAN_VOICE, S("boss2/pop2.wav"), 1, lq.ATTN_NORM);

    var oldo: Vector = self.origin;

    var z: f32 = 16;
    while (z <= 144) {
        var x: f32 = -64;
        while (x <= 64) {
            var y: f32 = -64;
            while (y <= 64) {
                self.origin[0] = oldo[0] + x;
                self.origin[1] = oldo[1] + y;
                self.origin[2] = oldo[2] + z;

                const r = q.random();

                if (r < 0.3)
                    player.ThrowGib(S("progs/gib1.mdl"), -999)
                else if (r < 0.6)
                    player.ThrowGib(S("progs/gib2.mdl"), -999)
                else
                    player.ThrowGib(S("progs/gib3.mdl"), -999);
                y = y + 32;
            }

            x = x + 32;
        }

        z = z + 96;
    }

    // start the end text
    q.WriteByte(lq.MSG_ALL, lq.SVC_FINALE);
    q.WriteString(lq.MSG_ALL, S(loc.LOC_EPILOGUE_FINALE));

    // put a player model down
    const n = q.spawn();
    q.setmodel(n, S("progs/player.mdl"));
    oldo = oldo - q.vec(32, 264, 0);
    q.setorigin(n, oldo);
    n.angles = q.vec(0, 290, 0);
    n.frame = 1;

    q.remove(self);

    // switch cd track
    q.WriteByte(lq.MSG_ALL, lq.SVC_CDTRACK);
    q.WriteByte(lq.MSG_ALL, 3);
    q.WriteByte(lq.MSG_ALL, 3);
    q.lightstyle(0, S("m"));
}

/// QUAKED monster_oldone (1 0 0) (-16 -16 -24) (16 16 32)
/// {
///     model({"path": "progs/oldone.mdl", "skin": 0, "frame": 0});
/// }
pub export fn monster_oldone() void {
    const self = q.me();
    if (q.deathmatch.get() != 0) {
        q.remove(self);
        return;
    }

    _ = q.precache_model2(S("progs/oldone.mdl"));

    _ = q.precache_sound2(S("boss2/death.wav"));
    _ = q.precache_sound2(S("boss2/idle.wav"));
    _ = q.precache_sound2(S("boss2/sight.wav"));
    _ = q.precache_sound2(S("boss2/pop2.wav"));

    self.solid = lq.SOLID_SLIDEBOX;
    self.movetype = lq.MOVETYPE_STEP;

    //gnounc
    q.setmodel(self, S("progs/oldone.mdl"));
    self.netname = S("Shub-Niggurath");
    self.set(lq.killstring, S(loc.LOC_DEATH_OLDONE));

    q.setsize(self, q.vec(-160, -128, -24), q.vec(160, 128, 256));

    self.health = 40000; // kill by telefrag
    self.max_health = 40000; // kill by telefrag
    self.think = q.func(old_idle1);
    self.nextthink = q.time.get() + 0.1;
    self.takedamage = lq.DAMAGE_YES;
    self.set(lq.th_pain, null);
    self.set(lq.th_die, q.func(finale_1));
    shub.set(self);

    q.total_monsters.set(q.total_monsters.get() + 1);
}
