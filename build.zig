const std = @import("std");

const lib_name = "handmade";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const platform = b.createModule(.{
        .source_file = .{ .path = "./code/handmade_platform.zig"},
    });

    const simd = b.createModule(.{
        .source_file = .{ .path = "./code/simd.zig"},
    });

    const win32 = b.createModule(.{
        .source_file = .{ .path = "./code/zwin32/win32.zig"},
    });
    
    const lib = b.addSharedLibrary(.{
        .name = lib_name, 
        .root_source_file = .{ .path = "./code/handmade/handmade.zig" }, 
        .version = .{ .major = 0, .minor = 1, .patch = 0},
        .target = target,
        .optimize = optimize,
    });

    lib.addModule("handmade_platform", platform);
    lib.addModule("simd", simd);
    _ = lib.getEmittedAsm();

    const exe = b.addExecutable(.{
        .name = "win32_handmade",
        .root_source_file = .{ .path = "./code/win32_handmade.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.addModule("win32", win32);
    exe.addModule("handmade_platform", platform);
    _ = exe.getEmittedAsm();

    const lib_tests = b.addTest(.{
        .root_source_file = .{ .path = "./code/handmade/handmade_tests.zig" },
        .target = target,
        .optimize = optimize,
    });
    lib_tests.addModule("handmade_platform", platform);
    lib_tests.addModule("simd", simd);

    const run_test = b.addRunArtifact(lib_tests);

    const test_step = b.step("test", "Run handmade tests");
    test_step.dependOn(&run_test.step);

    const build_step = b.step("lib", "Build the handmade lib");
    build_step.dependOn(&lib.step);

    b.installArtifact(lib);
    b.installArtifact(exe);
}