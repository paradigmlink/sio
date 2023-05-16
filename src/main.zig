const std = @import("std");
const builtin = @import("builtin");
const root = @import("root");
const io = std.io;
const fs = std.fs;
const mem = std.mem;
const process = std.process;
const Allocator = mem.Allocator;
const ArrayList = std.ArrayList;
//const cleanExit = process.cleanExit;


const tokenizer = @import("tokenizer.zig");
const build_options = @import("build_options");

pub const max_src_size = std.math.maxInt(u32);

pub fn fatal(comptime format: []const u8, args: anytype) noreturn {
    std.log.err(format, args);
    process.exit(1);
}

pub const debug_extensions_enabled = builtin.mode == .Debug;

pub const Color = enum {
    auto,
    off,
    on,
};


const normal_usage =
    \\Usage: sio [command] [options]
    \\
    \\Commands:
    \\
    \\  token-check      Analyse output of tokenize step
    \\
    \\General Options:
    \\
    \\  -h, --help       Print command-specific usage
    \\
;


const usage = normal_usage;

var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{
    .stack_trace_frames = build_options.mem_leak_frames,
}){};

pub fn main() anyerror!void {
    const use_gpa = true;
    const gpa = gpa: {
        if (use_gpa) {
            break :gpa general_purpose_allocator.allocator();
        }
        break :gpa std.heap.raw_c_allocator;
    };
    defer if (use_gpa) {
        _ = general_purpose_allocator.deinit();
    };
    var arena_instance = std.heap.ArenaAllocator.init(gpa);
    defer arena_instance.deinit();
    const arena = arena_instance.allocator();

    const args = try process.argsAlloc(arena);

    return mainArgs(gpa, arena, args);
}

pub fn mainArgs(gpa: Allocator, arena: Allocator, args: []const []const u8) !void {
    if (args.len <= 1) {
        std.log.info("{s}", .{usage});
        fatal("expected command argument", .{});
    }
    const cmd = args[1];
    const cmd_args = args[2..];
    if (mem.eql(u8, cmd, "token-check")) {
        return cmdAstCheck(gpa, arena, cmd_args);
    } else {
        std.log.info("{s}", .{usage});
        fatal("unknown command: {s}", .{args[1]});
    }
}

const usage_tokenize_check =
    \\Usage: zig tokenize-check [file]
    \\
    \\    Given a .sio source file, reports any compile errors that can be
    \\    ascertained on the basis of the source code alone, without target
    \\    information or type checking.
    \\
    \\    If [file] is omitted, stdin is used.
    \\
    \\Options:
    \\  -h, --help            Print this help and exit
    \\  --color [auto|off|on] Enable or disable colored error messages
    \\  -t                    (debug option) Output ZIR in text form to stdout
    \\
    \\
;


pub fn cmdAstCheck(
    gpa: Allocator,
    arena: Allocator,
    args: []const []const u8,
) !void {

    _ = gpa;
    _ = arena;
    _ = args;
}

fn readSourceFileToEndAlloc(
    allocator: Allocator,
    input: *const fs.File,
    size_hint: ?usize,
) ![:0]u8 {
    const source_code = input.readToEndAllocOptions(
        allocator,
        max_src_size,
        size_hint,
        @alignOf(u16),
        0,
    ) catch |err| switch (err) {
        error.ConnectionResetByPeer => unreachable,
        error.ConnectionTimedOut => unreachable,
        error.NotOpenForReading => unreachable,
        else => |e| return e,
    };
    errdefer allocator.free(source_code);

    // Detect unsupported file types with their Byte Order Mark
    const unsupported_boms = [_][]const u8{
        "\xff\xfe\x00\x00", // UTF-32 little endian
        "\xfe\xff\x00\x00", // UTF-32 big endian
        "\xfe\xff", // UTF-16 big endian
    };
    for (unsupported_boms) |bom| {
        if (mem.startsWith(u8, source_code, bom)) {
            return error.UnsupportedEncoding;
        }
    }

    // If the file starts with a UTF-16 little endian BOM, translate it to UTF-8
    if (mem.startsWith(u8, source_code, "\xff\xfe")) {
        const source_code_utf16_le = mem.bytesAsSlice(u16, source_code);
        const source_code_utf8 = std.unicode.utf16leToUtf8AllocZ(allocator, source_code_utf16_le) catch |err| switch (err) {
            error.DanglingSurrogateHalf => error.UnsupportedEncoding,
            error.ExpectedSecondSurrogateHalf => error.UnsupportedEncoding,
            error.UnexpectedSecondSurrogateHalf => error.UnsupportedEncoding,
            else => |e| return e,
        };

        allocator.free(source_code);
        return source_code_utf8;
    }

    return source_code;
}

fn get_tty_conf(color: Color) std.debug.TTY.Config {
    return switch (color) {
        .auto => std.debug.detectTTYConfig(std.io.getStdErr()),
        .on => .escape_codes,
        .off => .no_color,
    };
}

fn renderOptions(color: Color) std.zig.ErrorBundle.RenderOptions {
    const ttyconf = get_tty_conf(color);
    return .{
        .ttyconf = ttyconf,
        .include_source_line = ttyconf != .no_color,
        .include_reference_trace = ttyconf != .no_color,
    };
}
