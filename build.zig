const std = @import("std");

const lib_name = "handmade";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // ----------------------------------------------------------------------------------------------------
    // Options --------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------

    const options = b.addOptions();
    // NOTE (Manav)L for now this are independent of OptimizeMode
    options.addOption(bool, "IGNORE", false);
    options.addOption(bool, "HANDMADE_INTERNAL", true);
    options.addOption(bool, "HANDMADE_SLOW", true);

    // ----------------------------------------------------------------------------------------------------
    // Modules --------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------

    // TODO (Manav): Should I split handmade hero code into small modules?
    const platform = b.createModule(.{
        .root_source_file = b.path("./code/handmade_platform.zig"),
    });

    const simd = b.createModule(.{
        .root_source_file = b.path("./code/simd.zig"),
        .optimize = .ReleaseFast,
    });

    const debug = b.addModule("debug", .{
        .root_source_file = b.path("./code/handmade/handmade_debug.zig"),
        .optimize = .ReleaseFast,
        .imports = &.{
            .{ .name = "handmade_platform", .module = platform },
        },
    });

    const win32 = b.dependency("zigwin32", .{}).module("zigwin32");

    // ----------------------------------------------------------------------------------------------------
    // Build targets --------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------

    const stb_truetype_data = "#define STB_TRUETYPE_IMPLEMENTATION\n#include <stb_truetype.h>\n";
    const misc_build_path: std.Build.LazyPath = .{ .src_path = .{ .owner = b, .sub_path = "data" } };

    // ----------------------------------------------------------------------------------------------------
    // Tools - asset builder ------------------------------------------------------------------------------
    const asset_builder = b.addExecutable(.{
        .name = "asset_builder",
        .root_source_file = b.path("./code/handmade/asset_builder.zig"),
        .target = target,
        .optimize = optimize,
    });
    asset_builder.root_module.addImport("win32", win32);
    asset_builder.root_module.addImport("handmade_platform", platform);
    asset_builder.root_module.addCSourceFile(.{
        // NOTE: Need to add a source file to make zig compile the stb_truetype implementation
        .file = b.addWriteFiles().add("std_truetype.c", stb_truetype_data),
        .flags = &.{""},
    });
    asset_builder.root_module.addIncludePath(b.path("./code/handmade/"));
    asset_builder.root_module.link_libc = true;

    const asset_builder_install_step = b.addInstallArtifact(asset_builder, .{
        .dest_dir = .{ .override = .prefix },
        .pdb_dir = .{ .override = .prefix },
    });
    const run_step = b.step("asset", "Build the asset builder");
    run_step.dependOn(&asset_builder_install_step.step);

    b.getInstallStep().dependOn(&asset_builder_install_step.step);

    // ----------------------------------------------------------------------------------------------------
    // Tools - generate wav -------------------------------------------------------------------------------

    const gen_wav_tool = b.addSystemCommand(&.{"py"});
    gen_wav_tool.setCwd(misc_build_path);
    gen_wav_tool.addFileArg(b.path("code/tools/gen_wav.py"));

    const run_gen_wav_tool = b.step("gen_wav", "Run the wav generator");
    run_gen_wav_tool.dependOn(&gen_wav_tool.step);

    // ----------------------------------------------------------------------------------------------------
    // Handmade library -----------------------------------------------------------------------------------
    const lib = b.addSharedLibrary(.{
        .name = lib_name,
        .root_source_file = b.path("./code/handmade/handmade.zig"),
        .version = .{ .major = 0, .minor = 1, .patch = 0 },
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addImport("handmade_platform", platform);
    lib.root_module.addImport("simd", simd);
    lib.root_module.addImport("debug", debug);

    const lib_install_step = b.addInstallArtifact(lib, .{
        .dest_dir = .{ .override = .prefix },
        .pdb_dir = .{ .override = .prefix },
        .implib_dir = .{ .override = .prefix },
    });

    const build_step = b.step("lib", "Build the handmade lib");
    build_step.dependOn(&lib_install_step.step);
    build_step.dependOn(&b.addInstallFile(lib.getEmittedAsm(), "handmade.s").step);

    b.getInstallStep().dependOn(&lib_install_step.step);

    // ----------------------------------------------------------------------------------------------------
    // Handmade exe ---------------------------------------------------------------------------------------
    const exe = b.addExecutable(.{
        .name = "win32_handmade",
        .root_source_file = b.path("./code/win32_handmade.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("win32", win32);
    exe.root_module.addImport("handmade_platform", platform);

    const exe_install_step = b.addInstallArtifact(exe, .{
        .dest_dir = .{ .override = .prefix },
        .pdb_dir = .{ .override = .prefix },
    });

    b.getInstallStep().dependOn(&exe_install_step.step);

    // ----------------------------------------------------------------------------------------------------
    // Tests ----------------------------------------------------------------------------------------------
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
}
