const SourceLocation = @import("std").builtin.SourceLocation;

pub const record = struct {
    fileName: []const u8 = "",
    functionName: []const u8 = "",

    lineNumber: u32 = 0,

    counts: packed struct(u64) {
        hit: u32 = 0,
        cycle: u32 = 0,
    } = .{},
};

pub fn __rdtsc() u64 {
    var low: u32 = 0;
    var high: u32 = 0;

    asm volatile ("rdtsc"
        : [low] "={eax}" (low),
          [high] "={edx}" (high),
    );

    return (@as(u64, high) << 32) | @as(u64, low);
}

/// NOTE (Manav): We don't need two sets of theses because of how `TIMED_BLOCK()` works
pub var recordArray = [1]record{.{}} ** __COUNTER__();

/// The function at call site  will be replaced, using a preprocesing tool, with
/// ```
/// debug.TIMED_BLOCK(...);
/// // AUTOGENERATED ----------------------------------------------------------
/// var __t_blk__#counter = debug.TIMED_BLOCK__impl(#counter, @src()).Init(...);
/// defer __t_blk__#counter.End()
/// // AUTOGENERATED ----------------------------------------------------------
/// ```
/// - #counter will be generated based on `TIMED_BLOCK` call sites.
/// - debug is assumed to be imported at the very top.
pub inline fn TIMED_BLOCK(_: struct { hitCount: u32 = 1 }) void {}

/// The function definition is replaced with
/// ```
/// // AUTOGENERATED ----------------------------------------------------------
/// {
///     return #counter;
/// }
/// // AUTOGENERATED ----------------------------------------------------------
/// ```
/// where #counter is the total no. of TIMED_BLOCK callsites.
pub fn __COUNTER__() comptime_int
// AUTOGENERATED ----------------------------------------------------------
{
    return 37; // TODO (Manav): for now this is hardcoded, use process_timed_block to remove it
}
// AUTOGENERATED ----------------------------------------------------------

/// It relies on `__counter__` is to be supplied at build time using a preprocessing tool,
/// called everytime lib is built. For now use this with hardcoded `__counter__` values until we have one
// NOTE (Manav): zig (0.13) by design, doesn't allow for a way to have a global comptime counter and we don't have unity build.
pub fn TIMED_BLOCK__impl(comptime __counter__: usize, comptime source: SourceLocation) type {
    return struct {
        const Self = @This();

        pub inline fn Init(args: struct { hitCount: u32 = 1 }) Self {
            var self = Self{
                .record = &recordArray[__counter__],
                .startCycles = 0,
                .hitCount = args.hitCount,
            };

            self.record.fileName = source.file;
            self.record.lineNumber = source.line;
            self.record.functionName = source.fn_name;

            self.startCycles = __rdtsc();

            return self;
        }

        pub inline fn End(self: *Self) void {
            const delta: u64 = __rdtsc() - self.startCycles | @as(u64, self.hitCount) << 32;
            _ = @atomicRmw(u64, @as(*u64, @ptrCast(&self.record.counts)), .Add, delta, .seq_cst);
        }

        record: *record,
        startCycles: u64,
        hitCount: u32,
    };
}
