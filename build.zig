const std = @import("std");

const lib_name = "handmade";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // const options = b.addOptions();
    // options.addOption(bool, "NOTIGNORE", true);

    const platform = b.createModule(.{
        .source_file = .{ .path = "./code/handmade_platform.zig" },
    });

    const simd = b.createModule(.{
        .source_file = .{ .path = "./code/simd.zig" },
    });

    const asset_type_id = b.createModule(.{
        .source_file = .{ .path = "./code/handmade_asset_type_id.zig" },
    });

    const win32 = b.createModule(.{
        .source_file = .{ .path = "./code/zigwin32/win32.zig" },
    });

    const lib = b.addSharedLibrary(.{
        .name = lib_name,
        .root_source_file = .{ .path = "./code/handmade/handmade.zig" },
        .version = .{ .major = 0, .minor = 1, .patch = 0 },
        .target = target,
        .optimize = optimize,
    });

    lib.addModule("handmade_platform", platform);
    lib.addModule("handmade_asset_type_id", asset_type_id);
    lib.addModule("simd", simd);

    const exe = b.addExecutable(.{
        .name = "win32_handmade",
        .root_source_file = .{ .path = "./code/win32_handmade.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.addModule("win32", win32);
    exe.addModule("handmade_platform", platform);

    const lib_tests = b.addTest(.{
        .root_source_file = .{ .path = "./code/handmade/handmade_tests.zig" },
        .target = target,
        .optimize = optimize,
    });
    lib_tests.addModule("handmade_platform", platform);
    lib_tests.addModule("simd", simd);

    const asset_builder = b.addExecutable(.{
        .name = "asset_builder",
        .root_source_file = .{ .path = "./code/handmade/asset_builder.zig" },
        .target = target,
        .optimize = optimize,
    });
    asset_builder.addModule("handmade_asset_type_id", asset_type_id);
    asset_builder.addModule("handmade_platform", platform);

    const run_test = b.addRunArtifact(lib_tests);

    const test_step = b.step("test", "Run handmade tests");
    test_step.dependOn(&run_test.step);

    const build_step = b.step("lib", "Build the handmade lib");
    build_step.dependOn(&lib.step);

    const run_step = b.step("asset", "Build the asset builder");
    run_step.dependOn(&asset_builder.step);

    const exe_install_step = b.addInstallArtifact(exe, .{
        .dest_dir = .{ .override = .{ .custom = "../build" } }, // TODO: change prefix to build instead
        .pdb_dir = .{ .override = .{ .custom = "../build" } },
    });

    const lib_install_step = b.addInstallArtifact(lib, .{
        .dest_dir = .{ .override = .{ .custom = "../build" } },
        .pdb_dir = .{ .override = .{ .custom = "../build" } },
    });

    const asset_builder_install_step = b.addInstallArtifact(asset_builder, .{
        .dest_dir = .{ .override = .{ .custom = "../build" } },
        .pdb_dir = .{ .override = .{ .custom = "../build" } },
    });

    const asm_install_step = b.addInstallFile(lib.getEmittedAsm(), "../misc/handmade.s");

    b.getInstallStep().dependOn(&exe_install_step.step);
    b.getInstallStep().dependOn(&lib_install_step.step);
    b.getInstallStep().dependOn(&asset_builder_install_step.step);
    b.getInstallStep().dependOn(&asm_install_step.step);
}
