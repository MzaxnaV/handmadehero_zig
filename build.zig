const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    var exe = b.addExecutable("win32_handmade", "code/win32_handmade.zig");
    exe.setBuildMode(b.standardReleaseOptions());
    exe.setOutputDir("build");
    exe.addPackage(.{
        .name = "win32",
        .path = .{ .path = "./code/zigwin32/win32.zig" },
    });
    b.installArtifact(exe);
}
