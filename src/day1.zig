const std = @import("std");
const tools = @import("tools.zig");

fn part1(allocator: std.mem.Allocator, input: []const u8) !u64 {
    const data = try tools.read_file(allocator, input);
    var left = std.ArrayList(i32).init(allocator);
    var right = std.ArrayList(i32).init(allocator);

    var read_it = std.mem.tokenize(u8, data, "\n");

    while (read_it.next()) |line| {
        var split = std.mem.tokenizeScalar(u8, line, ' ');
        try left.append(try std.fmt.parseUnsigned(i32, split.next().?, 10));
        try right.append(try std.fmt.parseUnsigned(i32, split.next().?, 10));
    }

    std.mem.sort(i32, left.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, right.items, {}, comptime std.sort.asc(i32));

    var diff: u64 = 0;
    for (left.items, 0..) |_, i| {
        const l = left.items[i];
        const r = right.items[i];
        diff += @abs(l - r);
    }

    return diff;
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !u64 {
    const data = try tools.read_file(allocator, input);
    var left = std.ArrayList(i32).init(allocator);
    var right = std.ArrayList(i32).init(allocator);

    var left_map = std.AutoHashMap(i32, i32).init(allocator);

    var read_it = std.mem.tokenize(u8, data, "\n");

    while (read_it.next()) |line| {
        var split = std.mem.tokenizeScalar(u8, line, ' ');
        const l = try std.fmt.parseUnsigned(i32, split.next().?, 10);
        try left_map.put(l, 0);
        try left.append(l);
        try right.append(try std.fmt.parseUnsigned(i32, split.next().?, 10));
    }

    for (right.items) |r| {
        if (left_map.get(r)) |v| {
            try left_map.put(r, v + 1);
        }
    }

    var val: u64 = 0;
    for (left.items) |k| {
        const v = left_map.get(k).? * k;
        val += @abs(v);
    }

    return val;
}

pub fn run(allocator: std.mem.Allocator) !void {
    const input = "inputs/day1.txt";

    std.debug.print("Day 1:\n", .{});

    // Part 1
    var t = try std.time.Timer.start();
    const p1 = try part1(allocator, input);
    std.debug.print("\tPart 1: {d} in {}\n", .{ p1, std.fmt.fmtDuration(t.read()) });

    // Part 2
    t.reset();
    const p2 = try part2(allocator, input);
    std.debug.print("\tPart 2: {d} in {}\n", .{ p2, std.fmt.fmtDuration(t.read()) });
}

test "part1" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const ans = try part1(arena.allocator(), "tests/day1.txt");
    try std.testing.expectEqual(11, ans);
}

test "part2" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const ans = try part2(arena.allocator(), "tests/day1.txt");
    try std.testing.expectEqual(31, ans);
}
