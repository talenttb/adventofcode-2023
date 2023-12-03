const std = @import("std");
const clap = @import("clap");

//global funcs
const debug = std.debug;
const io = std.io;
const ascii = std.ascii;
// const print = stdout.print;
const stringFmt = std.fmt.allocPrint;
// const openDir = std.fs.openDirAbsolute;

//global mem
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = gpa.allocator();
// const Allocator = std.mem.Allocator;
// var g_heap = std.heap.ArenaAllocator.init(std.heap.page_allocator);
// var g_mem = g_heap.allocator();
// const alloc = g_mem.alloc;
// const free = g_mem.free;

pub fn main() !void {
    const params = comptime clap.parseParamsComptime(
        \\-p, --part <usize>   An option parameter, which takes a value.
        \\-f, --file <str>   An option parameter, which takes a value.
        \\
    );
    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag,
    }) catch |err| {
        // Report useful error and exit
        diag.report(io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    debug.print("Run with file: {s}\n", .{res.args.file.?});
    const path = try std.fmt.allocPrint(alloc, "inputs/{s}", .{res.args.file.?});
    defer alloc.free(path);

    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    var arr = std.ArrayList(u8).init(alloc);
    defer arr.deinit();

    var data = std.ArrayList([]u8).init(alloc);
    defer data.deinit();

    // var line_count: usize = 0;
    // var byte_count: usize = 0;
    while (true) {
        reader.streamUntilDelimiter(arr.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        // line_count += 1;
        // byte_count += arr.items.len;
        const result = try alloc.dupe(u8, arr.items);
        errdefer alloc.free(result);
        try data.append(result);
        arr.clearRetainingCapacity();
    }
    // debug.print("{d} lines, {d} bytes\n", .{ line_count, byte_count });

    // for (data.items) |entry| {
    //     debug.print("{any}\n", .{entry});
    // }

    switch (res.args.part.?) {
        1 => {
            debug.print("Run part: 1\n", .{});
            const result = part1(data);
            debug.print("Ans is: {any}\n", .{result});
        },
        2 => {
            debug.print("Run part: 2\n", .{});
            const result = part2(data);
            debug.print("Ans is: {any}\n", .{result});
        },
        else => unreachable,
    }
}

fn part1(data: std.ArrayList([]u8)) i32 {
    var result: i32 = 0;
    for (data.items) |entry| {
        // debug.print("{any}\n", .{entry});
        // first number from left
        var i: usize = 0;
        var end: usize = entry.len;
        const l2r = while (i < end) : (i += 1) {
            if (ascii.isDigit(entry[i])) {
                break entry[i];
            }
        } else 0;
        var l2r_value: i32 = @as(i32, @intCast(l2r)) - @as(i32, @intCast('0'));

        i = entry.len - 1;
        const r2l = while (i >= 0) : (i -= 1) {
            if (ascii.isDigit(entry[i])) {
                break entry[i];
            }
        } else 0;
        var r2l_value: i32 = @as(i32, @intCast(r2l)) - @as(i32, @intCast('0'));
        debug.print("{d} & {d}\n", .{ l2r_value, r2l_value });

        result += l2r_value * 10 + r2l_value;
    }
    return result;
}

fn part2(data: std.ArrayList([]u8)) i32 {
    var result: i32 = 0;

    const Checker = struct { key: []const u8, value: i32 };
    const checkers = [_]Checker{
        Checker{ .key = "1", .value = 1 },
        Checker{ .key = "one", .value = 1 },
        Checker{ .key = "2", .value = 2 },
        Checker{ .key = "two", .value = 2 },
        Checker{ .key = "3", .value = 3 },
        Checker{ .key = "three", .value = 3 },
        Checker{ .key = "4", .value = 4 },
        Checker{ .key = "four", .value = 4 },
        Checker{ .key = "5", .value = 5 },
        Checker{ .key = "five", .value = 5 },
        Checker{ .key = "6", .value = 6 },
        Checker{ .key = "six", .value = 6 },
        Checker{ .key = "7", .value = 7 },
        Checker{ .key = "seven", .value = 7 },
        Checker{ .key = "8", .value = 8 },
        Checker{ .key = "eight", .value = 8 },
        Checker{ .key = "9", .value = 9 },
        Checker{ .key = "nine", .value = 9 },
    };

    for (data.items, 0..) |entry, idx| {
        // debug.print("{any}\n", .{entry});
        // first number from left
        var i: usize = 0;
        var end: usize = entry.len;
        var l2r: ?i32 = null;
        while (i <= end) : (i += 1) {
            for (checkers) |c| {
                if (std.mem.indexOf(u8, entry[0..i], c.key)) |_| {
                    l2r = c.value;
                    break;
                }
            }
            if (l2r != null) {
                break;
            }
        }
        // debug.print("{d}\n", .{l2r.?});

        // var l2r_value: i32 = @as(i32, @intCast(l2r.?)) - @as(i32, @intCast('0'));

        var r2l: ?i32 = null;
        i = entry.len - 1;
        while (i >= 0) : (i -= 1) {
            for (checkers) |c| {
                if (std.mem.indexOf(u8, entry[i..entry.len], c.key)) |_| {
                    r2l = c.value;
                    break;
                }
            }
            if (r2l != null) {
                break;
            }
        }
        // debug.print("{d}\n", .{r2l.?});
        // var r2l_value: i32 = @as(i32, @intCast(r2l.?)) - @as(i32, @intCast('0'));
        _ = idx;
        // debug.print("{d}: {d} & {d}\n", .{ idx, l2r.?, r2l.? });

        result += l2r.? * 10 + r2l.?;
    }
    return result;
}
