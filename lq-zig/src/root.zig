//! progs.src: every file of LibreQuake's NetQuake game code, in the
//! original order. Their exported functions make up the progs.

const defs = @import("defs.zig");

const files = .{
    @import("defs.zig"),
    @import("lq.zig"),
    @import("localized_text.zig"),
    @import("deathmatch_settings.zig"),
    @import("subs.zig"),
    @import("fight.zig"),
    @import("ai.zig"),
    @import("lq1/cutscene_camera.zig"),
    @import("combat.zig"),
    @import("items.zig"),
    @import("weapons.zig"),
    @import("world.zig"),
    @import("client.zig"),
    @import("player.zig"),
    @import("monsters.zig"),
    @import("doors.zig"),
    @import("buttons.zig"),
    @import("triggers.zig"),
    @import("plats.zig"),
    @import("misc.zig"),
    @import("monsters/ogre.zig"),
    @import("monsters/fiend.zig"),
    @import("monsters/shambler.zig"),
    @import("monsters/knight.zig"),
    @import("monsters/grunt.zig"),
    @import("monsters/scrag.zig"),
    @import("monsters/rottweiler.zig"),
    @import("monsters/zombie.zig"),
    @import("monsters/chthon.zig"),
    @import("monsters/spawn.zig"),
    @import("monsters/hellknight.zig"),
    @import("monsters/rotfish.zig"),
    @import("monsters/vore.zig"),
    @import("monsters/enforcer.zig"),
    @import("monsters/shub.zig"),
};

comptime {
    // Every QuakeC global and field exists in the progs, used or not.
    for (files) |f| defs.declareUserDefs(f);
}

test {
    inline for (files) |f| _ = f;
}
