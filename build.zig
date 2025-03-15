const std = @import("std");

const lib_name = "handmade";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // ----------------------------------------------------------------------------------------------------
    // Options --------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------

    // NOTE (Manav): keep our tool options separate
    const preprocess_options = b.addOptions();
    preprocess_options.addOption(bool, "PROFILE", true);

    const build_options = b.addOptions();
    // NOTE (Manav): for now this are independent of OptimizeMode
    build_options.addOption(bool, "ignore", true); // NOTE: true to ignore sections of code.
    build_options.addOption(bool, "HANDMADE_INTERNAL", true);
    build_options.addOption(bool, "HANDMADE_SLOW", true);
    build_options.addOption(u32, "TRANSLATION_UNIT_INDEX", 0);

    const self_compilation = b.option(bool, "self_compilation", "Flag to check recompiling") orelse false;

    // ----------------------------------------------------------------------------------------------------
    // Modules --------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------

    const platform = b.createModule(.{
        .root_source_file = b.path("code/handmade_platform.zig"),
    });
    platform.addOptions("options", build_options);

    const intrinsics = b.createModule(.{
        .root_source_file = b.path("code/handmade/handmade_intrinsics.zig"),
        .imports = &.{
            .{ .name = "handmade_platform", .module = platform },
        },
        .optimize = .ReleaseFast,
    });

    const win32 = b.dependency("zigwin32", .{}).module("win32");

    // ----------------------------------------------------------------------------------------------------
    // Build targets --------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------

    const stb_truetype_data = "#define STB_TRUETYPE_IMPLEMENTATION\n#include <stb_truetype.h>\n";
    const misc_build_path: std.Build.LazyPath = .{ .src_path = .{ .owner = b, .sub_path = "misc" } };
    const data_build_path: std.Build.LazyPath = .{ .src_path = .{ .owner = b, .sub_path = "data" } };
    const code_build_path: std.Build.LazyPath = .{ .src_path = .{ .owner = b, .sub_path = "code/handmade/" } };

    // ----------------------------------------------------------------------------------------------------
    // Tools - process timed blocks -----------------------------------------------------------------------

    const preprocess_profile = b.addExecutable(.{
        .name = "prepocess_profile",
        .root_source_file = b.path("code/tools/preprocess_profile.zig"),
        .target = b.graph.host,
        .optimize = .ReleaseSafe,
    });

    preprocess_profile.root_module.addOptions("config", preprocess_options);

    const run_prepocess_profile = b.addRunArtifact(preprocess_profile);
    run_prepocess_profile.setCwd(code_build_path);

    const prepocess_profile_test = b.addTest(.{
        .root_source_file = b.path("code/tools/preprocess_profile.zig"),
        .target = b.graph.host,
        .optimize = .ReleaseSafe,
    });

    const run_prepocess_profile_test = b.addRunArtifact(prepocess_profile_test);

    // ----------------------------------------------------------------------------------------------------
    // Handmade library -----------------------------------------------------------------------------------
    const lib = b.addSharedLibrary(.{
        .name = lib_name,
        .root_source_file = b.path("code/handmade/handmade.zig"),
        .version = .{ .major = 0, .minor = 1, .patch = 0 },
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addImport("handmade_platform", platform);
    lib.root_module.addImport("intrinsics", intrinsics);

    if (!self_compilation) {
        lib.step.dependOn(&run_prepocess_profile.step);
    }

    const lib_install_step = b.addInstallArtifact(lib, .{
        .dest_dir = .{ .override = .prefix },
        .pdb_dir = .{ .override = .prefix },
        .implib_dir = .{ .override = .prefix },
    });

    const lib_build_step = b.step("lib", "Build the handmade lib");
    lib_build_step.dependOn(&lib_install_step.step);

    b.getInstallStep().dependOn(&lib_install_step.step);

    // ----------------------------------------------------------------------------------------------------
    // Handmade exe ---------------------------------------------------------------------------------------
    const exe = b.addExecutable(.{
        .name = "win32_handmade",
        .root_source_file = b.path("code/win32_handmade.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("win32", win32);
    exe.root_module.addImport("handmade_platform", platform);
    exe.step.dependOn(&run_prepocess_profile.step);

    const exe_install_step = b.addInstallArtifact(exe, .{
        .dest_dir = .{ .override = .prefix },
        .pdb_dir = .{ .override = .prefix },
    });

    b.getInstallStep().dependOn(&exe_install_step.step);

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
    asset_builder.root_module.addImport("intrinsics", intrinsics);

    asset_builder.root_module.addCSourceFile(.{
        // NOTE: Need to add a source file to make zig compile the stb_truetype implementation
        .file = b.addWriteFiles().add("std_truetype.c", stb_truetype_data),
        .flags = &.{""},
    });
    asset_builder.root_module.addIncludePath(b.path("code/handmade/"));
    asset_builder.root_module.link_libc = true;

    const asset_builder_install_step = b.addInstallArtifact(asset_builder, .{
        .dest_dir = .{ .override = .prefix },
        .pdb_dir = .{ .override = .prefix },
    });
    const asset_builder_step = b.step("asset", "Build the asset builder");
    asset_builder_step.dependOn(&asset_builder_install_step.step);

    b.getInstallStep().dependOn(&asset_builder_install_step.step);

    // ----------------------------------------------------------------------------------------------------
    // Tools - generate wav -------------------------------------------------------------------------------

    const run_gen_wave = b.addSystemCommand(&.{"py"});
    run_gen_wave.setCwd(data_build_path);
    run_gen_wave.addFileArg(b.path("code/tools/gen_wav.py"));

    const gen_wave_step = b.step("gen_wav", "Run the wav generator");
    gen_wave_step.dependOn(&run_gen_wave.step);

    // ----------------------------------------------------------------------------------------------------
    // Tools - parse llvm ---------------------------------------------------------------------------------

    const llvm_mca = b.addSystemCommand(&.{ "llvm-mca", "-all-stats", "-all-views" });
    llvm_mca.addFileArg(lib.getEmittedAsm());

    const output = llvm_mca.captureStdOut();

    const llvm_mca_parser = b.addExecutable(.{
        .name = "parse_llvm_mca",
        .root_source_file = b.path("code/tools/parse_llvm_mca.zig"),
        .target = b.graph.host,
        .optimize = .ReleaseSafe,
    });

    const run_llvm_mca_parser = b.addRunArtifact(llvm_mca_parser);
    run_llvm_mca_parser.setCwd(misc_build_path);
    run_llvm_mca_parser.addFileArg(output);

    const llvm_mca_parser_step = b.step("parse_llvm_mca", "Parse llvm-mca output generator");
    llvm_mca_parser_step.dependOn(&run_llvm_mca_parser.step);

    const llvm_mca_parser_test = b.addTest(.{
        .root_source_file = b.path("code/tools/parse_llvm_mca.zig"),
        .target = b.graph.host,
        .optimize = .ReleaseSafe,
    });

    const run_llvm_mca_parser_test = b.addRunArtifact(llvm_mca_parser_test);

    // ----------------------------------------------------------------------------------------------------
    // Tests ----------------------------------------------------------------------------------------------
    const lib_tests = b.addTest(.{
        .root_source_file = b.path("code/handmade/handmade_tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib_tests.root_module.addImport("handmade_platform", platform);
    lib_tests.root_module.addImport("intrinsics", intrinsics);

    const run_lib_test = b.addRunArtifact(lib_tests);

    const test_step = b.step("test", "Run handmade tests");
    test_step.dependOn(&run_lib_test.step);
    test_step.dependOn(&run_llvm_mca_parser_test.step);
    test_step.dependOn(&run_prepocess_profile_test.step);
}
