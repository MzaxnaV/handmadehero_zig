const std = @import("std");

const lib_name = "handmade";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // const options = b.addOptions();
    // options.addOption(bool, "NOTIGNORE", true);

    const platform = b.createModule(.{
        .root_source_file = b.path("./code/handmade_platform.zig"),
    });

    const simd = b.createModule(.{
        .root_source_file = b.path("./code/simd.zig"),
    });

    const win32 = b.dependency("zigwin32", .{}).module("zigwin32");

    const lib = b.addSharedLibrary(.{
        .name = lib_name,
        .root_source_file = b.path("./code/handmade/handmade.zig"),
        .version = .{ .major = 0, .minor = 1, .patch = 0 },
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addImport("handmade_platform", platform);
    lib.root_module.addImport("simd", simd);

    const lib_tests = b.addTest(.{
        .root_source_file = b.path("./code/handmade/handmade_tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib_tests.root_module.addImport("handmade_platform", platform);
    lib_tests.root_module.addImport("simd", simd);

    const run_test = b.addRunArtifact(lib_tests);

    const test_step = b.step("test", "Run handmade tests");
    test_step.dependOn(&run_test.step);

    const exe = b.addExecutable(.{
        .name = "win32_handmade",
        .root_source_file = b.path("./code/win32_handmade.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("win32", win32);
    exe.root_module.addImport("handmade_platform", platform);

    const stb_truetype_data = "#define STB_TRUETYPE_IMPLEMENTATION\n#include <stb_truetype.h>\n";

    const asset_builder = b.addExecutable(.{
        .name = "asset_builder",
        .root_source_file = b.path("./code/handmade/asset_builder.zig"),
        .target = target,
        .optimize = optimize,
    });
    asset_builder.root_module.addImport("handmade_platform", platform);
    asset_builder.root_module.addCSourceFile(.{ // NOTE: Need to add a source file to make zig compile the stb_truetype implementation
        .file = b.addWriteFiles().add("std_truetype.c", stb_truetype_data),
        .flags = &.{""},
    });
    asset_builder.root_module.addIncludePath(b.path("./code/handmade/"));
    asset_builder.root_module.link_libc = true;

    const exe_install_step = b.addInstallArtifact(exe, .{
        .dest_dir = .{ .override = .{ .custom = "../build" } }, // TODO: change prefix to build instead
        .pdb_dir = .{ .override = .{ .custom = "../build" } },
    });

    const lib_install_step = b.addInstallArtifact(lib, .{
        .dest_dir = .{ .override = .{ .custom = "../build" } },
        .pdb_dir = .{ .override = .{ .custom = "../build" } },
    });
    const build_step = b.step("lib", "Build the handmade lib");
    build_step.dependOn(&lib_install_step.step);

    const asset_builder_install_step = b.addInstallArtifact(asset_builder, .{
        .dest_dir = .{ .override = .{ .custom = "../build" } },
        .pdb_dir = .{ .override = .{ .custom = "../build" } },
    });
    const run_step = b.step("asset", "Build the asset builder");
    run_step.dependOn(&asset_builder_install_step.step);

    const asm_install_step = b.addInstallFile(lib.getEmittedAsm(), "../misc/handmade.s");

    b.getInstallStep().dependOn(&lib_install_step.step);
    b.getInstallStep().dependOn(&asm_install_step.step);
    b.getInstallStep().dependOn(&asset_builder_install_step.step);
    b.getInstallStep().dependOn(&exe_install_step.step);
}
