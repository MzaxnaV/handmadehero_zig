const std = @import("std");

const lib_name = "handmade";

pub fn build(b: *std.build.Builder) void {
    const pkgs = struct {
        const win32 = std.build.Pkg{
            .name = "win32",
            .path = .{ .path = "./code/zigwin32/win32.zig" },
        };

        const common = std.build.Pkg{
            .name = "handmade_common",
            .path = .{ .path = "./code/handmade_common.zig" },
        };
    };

    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});
    const options = b.addOptions();
    options.addOption(bool, "IGNORE", true);

    const lib = b.addSharedLibrary(lib_name, "code/handmade.zig", b.version(1, 0, 0));
    lib.setTarget(target);
    lib.setBuildMode(mode);
    lib.addPackage(pkgs.common);

    lib.setOutputDir("build");
    lib.addOptions("build_consts", options);

    lib.install();

    const exe = b.addExecutable("win32_handmade", "code/win32_handmade.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.addPackage(pkgs.win32);
    exe.addPackage(pkgs.common);

    exe.setOutputDir("build");
    exe.addOptions("build_consts", options);

    b.installArtifact(exe);
}
