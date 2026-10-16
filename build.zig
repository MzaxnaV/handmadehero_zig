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

    const emit_mca = b.option(bool, "mca", "Emit lib asm for llvm-mca") orelse false;

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

    const win32 = b.dependency("zigwin32", .{}).module("win32");

    // ----------------------------------------------------------------------------------------------------
    // Build targets --------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------

    const misc_build_path = b.path("misc");
    const data_build_path = b.path("data");
    const code_build_path = b.path("code/handmade");
    // ----------------------------------------------------------------------------------------------------
    // Tools - process timed blocks -----------------------------------------------------------------------

    const preprocess_profile_root_module = b.createModule(.{
        .root_source_file = b.path("code/tools/preprocess_profile.zig"),
        .target = b.graph.host,
        .optimize = .ReleaseSafe,
    });

    const preprocess_profile = b.addExecutable(.{
        .name = "preprocess_profile",
        .root_module = preprocess_profile_root_module,
    });

    preprocess_profile.root_module.addOptions("config", preprocess_options);

    const run_preprocess_profile = b.addRunArtifact(preprocess_profile);
    run_preprocess_profile.setCwd(code_build_path);

    const preprocess_profile_test = b.addTest(.{
        .root_module = preprocess_profile_root_module,
    });

    const run_preprocess_profile_test = b.addRunArtifact(preprocess_profile_test);

    // ----------------------------------------------------------------------------------------------------
    // Handmade library -----------------------------------------------------------------------------------
    const lib = b.addLibrary(.{
        .linkage = .dynamic,
        .name = lib_name,
        .root_module = b.createModule(.{
            .root_source_file = b.path("code/handmade/handmade.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "platform", .module = platform }},
        }),
        .version = .{ .major = 0, .minor = 1, .patch = 0 },
    });

    if (!self_compilation) {
        lib.step.dependOn(&run_preprocess_profile.step);
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
        .root_module = b.createModule(.{
            .root_source_file = b.path("code/win32_handmade.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "platform", .module = platform },
                .{ .name = "win32", .module = win32 },
            },
        }),
    });

    exe.step.dependOn(&run_preprocess_profile.step);

    const exe_install_step = b.addInstallArtifact(exe, .{
        .dest_dir = .{ .override = .prefix },
        .pdb_dir = .{ .override = .prefix },
    });

    b.getInstallStep().dependOn(&exe_install_step.step);

    // ----------------------------------------------------------------------------------------------------
    // Tools - asset builder ------------------------------------------------------------------------------
    const asset_builder = b.addExecutable(.{
        .name = "asset_builder",
        .root_module = b.createModule(.{
            .root_source_file = b.path("./code/handmade/asset_builder.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "platform", .module = platform },
                .{ .name = "win32", .module = win32 },
            },
        }),
    });

    const std_truetype_c = b.addTranslateC(.{
        .root_source_file = b.path("code/handmade//stb_truetype.h"),
        .target = target,
        .optimize = optimize,
    });

    asset_builder.root_module.addImport("stb_truetype", std_truetype_c.createModule());
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

    const llvm_mca_parser_root_module = b.createModule(.{
        .root_source_file = b.path("code/tools/parse_llvm_mca.zig"),
        .target = b.graph.host,
        .optimize = .ReleaseSafe,
    });

    const llvm_mca_parser_step = b.step("parse_llvm_mca", "Parse llvm-mca output generator (requires -Dmca)");

    // NOTE (Manav): getEmittedAsm() makes every lib compile also emit asm, so only request it when asked for.
    if (emit_mca) {
        const llvm_mca = b.addSystemCommand(&.{ "llvm-mca", "-all-stats", "-all-views" });
        llvm_mca.addFileArg(lib.getEmittedAsm());

        const output = llvm_mca.captureStdOut(.{});

        const llvm_mca_parser = b.addExecutable(.{
            .name = "parse_llvm_mca",
            .root_module = llvm_mca_parser_root_module,
        });

        const run_llvm_mca_parser = b.addRunArtifact(llvm_mca_parser);
        run_llvm_mca_parser.setCwd(misc_build_path);
        run_llvm_mca_parser.addFileArg(output);

        llvm_mca_parser_step.dependOn(&run_llvm_mca_parser.step);
    } else {
        const fail = b.addFail("parse_llvm_mca needs the lib asm, rerun with -Dmca");
        llvm_mca_parser_step.dependOn(&fail.step);
    }

    const llvm_mca_parser_test = b.addTest(.{
        .root_module = llvm_mca_parser_root_module,
    });

    const run_llvm_mca_parser_test = b.addRunArtifact(llvm_mca_parser_test);

    // ----------------------------------------------------------------------------------------------------
    // Tests ----------------------------------------------------------------------------------------------
    const lib_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("code/handmade/handmade_tests.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "platform", .module = platform },
            },
        }),
    });
    lib_tests.root_module.addImport("platform", platform);

    const run_lib_test = b.addRunArtifact(lib_tests);

    const test_step = b.step("test", "Run handmade tests");
    test_step.dependOn(&run_lib_test.step);
    test_step.dependOn(&run_llvm_mca_parser_test.step);
    test_step.dependOn(&run_preprocess_profile_test.step);
}
