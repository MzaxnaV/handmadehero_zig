const std = @import("std");

const lib_name = "handmade";

pub fn build(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});

    const options = b.addOptions();
    options.addOption(bool, "NOT_IGNORE", true);
    options.addOption(bool, "HANDMADE_INTERNAL", true);
    options.addOption(bool, "HANDMADE_SLOW", true); // TODO: let build mode decide it's value

    const platform = std.build.Pkg{
        .name = "handmade_platform",
        .path = .{ .path = "./code/handmade_platform.zig" },
        .dependencies = &[_]std.build.Pkg{.{
            .name = "build_consts",
            .path = options.getSource(),
        }},
    };

    const simd = std.build.Pkg{
        .name = "simd",
        .path = .{ .path = "./code/simd.zig" },
    };

    const win32 = std.build.Pkg{
        .name = "win32",
        .path = .{ .path = "./code/zigwin32/win32.zig" },
    };

    const lib = b.addSharedLibrary(lib_name, "code/handmade/handmade.zig", b.version(1, 0, 0));
    lib.setTarget(target);
    lib.setBuildMode(mode);
    lib.addPackage(platform);
    lib.addPackage(simd);
    lib.emit_asm = .{ .emit_to = "misc/handmade.s" };
    lib.setOutputDir("build");
    lib.addOptions("build_consts", options);

    const exe = b.addExecutable("win32_handmade", "code/win32_handmade.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.addPackage(win32);
    exe.addPackage(platform);
    exe.setOutputDir("build");
    exe.addOptions("build_consts", options);

    var lib_tests = b.addTest("code/handmade/handmade_tests.zig");
    lib_tests.setBuildMode(mode);
    lib_tests.addPackage(platform);
    lib_tests.addPackage(simd);

    const test_step = b.step("test", "Run handmade tests");
    test_step.dependOn(&lib_tests.step);

    const build_step = b.step("lib", "Build the handmade lib");
    build_step.dependOn(&lib.step);

    b.installArtifact(lib);
    b.installArtifact(exe);
}
