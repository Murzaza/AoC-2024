const std = @import("std");
const tools = @import("tools.zig");

fn is_increasing(list: []i32) bool {
    var prev = list[0];
    for (list[1..]) |item| {
        const v = item - prev;
        if (v < 1 or v > 3) {
            return false;
        }
        prev = item;
    }

    return true;
}

fn is_decreasing(list: []i32) bool {
    var prev = list[0];
    for (list[1..]) |item| {
        const v = prev - item;
        if (v < 1 or v > 3) {
            return false;
        }
        prev = item;
    }

    return true;
}

fn part1(allocator: std.mem.Allocator, input: []const u8) !u64 {
    const data = try tools.read_file(allocator, input);

    var read_it = std.mem.tokenize(u8, data, "\n");

    var safe: u64 = 0;

    while (read_it.next()) |line| {
        var line_it = std.mem.tokenizeScalar(u8, line, ' ');
        var list = std.ArrayList(i32).init(allocator);
        defer list.deinit();
        while (line_it.next()) |level| {
            try list.append(try std.fmt.parseUnsigned(i32, level, 10));
        }

        if (is_increasing(list.items) or is_decreasing(list.items)) {
            safe += 1;
        }
    }

    return safe;
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !u64 {
    const data = try tools.read_file(allocator, input);
    var read_it = std.mem.tokenize(u8, data, "\n");
    var safe: u64 = 0;

    while (read_it.next()) |line| {
        var line_it = std.mem.tokenizeScalar(u8, line, ' ');
        var list = std.ArrayList(i32).init(allocator);
        defer list.deinit();
        while (line_it.next()) |level| {
            try list.append(try std.fmt.parseUnsigned(i32, level, 10));
        }

        if (is_increasing(list.items) or is_decreasing(list.items)) {
            safe += 1;
        } else {
            // Okay fine we brute force
            if (is_increasing(list.items[1..]) or is_decreasing(list.items[1..]) or is_increasing(list.items[0 .. list.items.len - 1]) or is_decreasing(list.items[0 .. list.items.len - 1])) {
                safe += 1;
            } else {
                for (1..(list.items.len - 1)) |i| {
                    const before = list.items[0..i];
                    const after = list.items[i + 1 ..];
                    const new = try std.mem.concat(allocator, i32, &[_][]const i32{ before, after });
                    if (is_increasing(new) or is_decreasing(new)) {
                        safe += 1;
                        break;
                    }
                }
            }
        }
    }

    return safe;
}

pub fn run(allocator: std.mem.Allocator) !void {
    const input = "inputs/day2.txt";

    std.debug.print("Day 2:\n", .{});

    // Part 1
    const p1 = try part1(allocator, input);
    std.debug.print("\tPart 1: {d}\n", .{p1});

    // Part 2
    const p2 = try part2(allocator, input);
    std.debug.print("\tPart 2: {d}\n", .{p2});
}

test "part1" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const ans = try part1(arena.allocator(), "tests/day2.txt");
    try std.testing.expectEqual(2, ans);
}

test "part2" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const ans = try part2(arena.allocator(), "tests/day2.txt");
    try std.testing.expectEqual(4, ans);

    // Custom test cases
    const ans2 = try part2(arena.allocator(), "tests/cDay2.txt");
    try std.testing.expectEqual(6, ans2);
}
