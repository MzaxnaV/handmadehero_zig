const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});
    const exe = b.addExecutable("win32_handmade", "code/win32_handmade.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.setOutputDir("build");
    exe.addPackage(.{
        .name = "win32",
        .path = .{ .path = "./code/zigwin32/win32.zig" },
    });
    b.installArtifact(exe);
}