const std = @import("std");

// const Block = struct {
//     heading: ?[]const u8,
//     start: []const u8,
//     text: []const u8,
//     end: ?[]const u8,
//     blocks: ?[*]Block,
// };

const heading = "] Code Region";
const sub_headings = [_][]const u8{
    "Critical sequence based on the simulation:",
    "Instruction Info:",
    "Dynamic Dispatch Stall Cycles:",
    "Dispatch Logic - number",
    "Schedulers - number of cycles",
    "Scheduler's queue usage:",
    "Retire Control Unit - number of cycles",
    "Total ROB Entries:",
    "Register File statistics:",
    "Resources:",
    "Timeline view:",
    "Average Wait times",
};

const StringIterator = struct {
    const Self = @This();

    slice: []const u8,
    index: usize,

    pub fn init(str: []const u8) Self {
        return Self{ .slice = str, .index = 0 };
    }

    pub fn next(iter: *Self) ?u8 {
        return if (iter.index >= iter.slice.len) null else blk: {
            const n = iter.index;
            iter.index += 1;
            break :blk n;
        };
    }

    pub fn findSubStr(self: *const Self, sub_str: []const u8) ?usize {
        return std.mem.indexOf(u8, self.slice, sub_str);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        _ = gpa.detectLeaks();
    }

    const args = try std.process.argsAlloc(allocator);

    if (args.len != 2) fatal("wrong number of arguments", .{});

    const source = try std.fs.cwd().openFile(args[1], .{ .mode = .read_only });
    const dest = try std.fs.cwd().createFile("llvm_mca_output.md", .{ .truncate = true });

    const input_buf = try allocator.alloc(u8, 1000);
    defer allocator.free(input_buf);

    var found_heading = false;
    var first_heading = true;

    while (try source.reader().readUntilDelimiterOrEof(input_buf, '\n')) |line| {
        var found_subheading = false;
        const line_iterator = StringIterator.init(line);

        if (line_iterator.findSubStr(heading)) |_| {
            found_heading = true;
            if (first_heading) {
                try dest.writer().print("<details><summary>{s}</summary>\n\n```", .{line[0 .. line.len - 1]});
                first_heading = false;
            } else {
                try dest.writer().print("\n```\n</details>\n\n</details>\n\n<details><summary>{s}</summary>\n\n```", .{line[0 .. line.len - 1]});
            }

            continue;
        }

        for (sub_headings) |sub_heading| {
            if (line_iterator.findSubStr(sub_heading)) |_| {
                found_subheading = true;
                if (found_heading) {
                    found_heading = false;
                    break try dest.writer().print("```\n\n<details><summary>{s}</summary>\n\n```\n", .{line[0 .. line.len - 1]});
                } else {
                    break try dest.writer().print("```\n</details>\n\n<details><summary>{s}</summary>\n\n```\n", .{line[0 .. line.len - 1]});
                }
            }
        }

        if (found_subheading) continue;

        try dest.writer().print("{s}", .{line});
    }

    try dest.writer().print("```\n</details>\n</details>\n", .{});

    dest.close();
    source.close();
}

fn fatal(comptime format: []const u8, args: anytype) noreturn {
    std.debug.print(format, args);
    std.process.exit(1);
}

test "find substring" {
    const str = "This is Sparta!";

    const iter = StringIterator.init(str);

    try std.testing.expectEqual(iter.findSubStr(str[0..4]), 0);
    try std.testing.expectEqual(iter.findSubStr(str), 0);
    try std.testing.expectEqual(iter.findSubStr(str[(str.len - 1)..]), str.len - 1);
}
