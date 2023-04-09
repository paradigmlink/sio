const Builder = @import("std").build.Builder;
const builtin = @import("builtin");
const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    //const target = b.standardTargetOptions(.{});

    const target = .{
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 },
        .os_tag = .freestanding,
        .abi = .eabi,
    };

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.

    const mode = b.standardReleaseOptions();

    const elf = b.addExecutable("stm32l0-blink.elf", "src/startup.zig");
    elf.setTarget(target);
    elf.setBuildMode(mode);

    const vector_obj = b.addObject("vector", "src/vector.zig");
    vector_obj.setTarget(target);
    vector_obj.setBuildMode(mode);

    elf.addObject(vector_obj);
    elf.setLinkerScriptPath(.{ .path = "src/linker.ld" });

    const bin = b.addInstallRaw(elf, "stm32l0-blink.bin", .{});
    const bin_step = b.step("bin", "Generate binary file to be flashed");
    bin_step.dependOn(&bin.step);

    const flash_cmd = b.addSystemCommand(&[_][]const u8{
        "probe-run",
        "--chip",
        "STM32L071KBTx",
        b.getInstallPath(bin.dest_dir, bin.dest_filename),
    });
    flash_cmd.step.dependOn(&bin.step);
    const flash_step = b.step("flash", "Flash and run the app on your STM32F4Discovery");
    flash_step.dependOn(&flash_cmd.step);

    b.default_step.dependOn(&elf.step);
    b.installArtifact(elf);
}
