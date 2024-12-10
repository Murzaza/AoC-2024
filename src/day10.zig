const std = @import("std");
const tools = @import("tools.zig");
const Set = @import("ziglangSet").Set;
const print = std.debug.print;
const fmtDuration = std.fmt.fmtDuration;
const parseInt = std.fmt.parseInt;
const charToDigit = std.fmt.charToDigit;

const Pos = struct {
    x: u64,
    y: u64,
};

fn findPeaks(map: [][]u64, curr: Pos, v: u64, peaks: *Set(Pos)) !void {
    if (v == 9) {
        _ = try peaks.add(curr);
        return;
    } else if (v > 9) {
        //Why are we here?
        return;
    }

    //Up
    if (curr.y > 0 and map[curr.y - 1][curr.x] == v + 1) {
        try findPeaks(map, Pos{ .x = curr.x, .y = curr.y - 1 }, v + 1, peaks);
    }

    //Down
    if (curr.y < map.len - 1 and map[curr.y + 1][curr.x] == v + 1) {
        try findPeaks(map, Pos{ .x = curr.x, .y = curr.y + 1 }, v + 1, peaks);
    }

    //Right
    if (curr.x < map[0].len - 1 and map[curr.y][curr.x + 1] == v + 1) {
        try findPeaks(map, Pos{ .x = curr.x + 1, .y = curr.y }, v + 1, peaks);
    }

    //Left
    if (curr.x > 0 and map[curr.y][curr.x - 1] == v + 1) {
        try findPeaks(map, Pos{ .x = curr.x - 1, .y = curr.y }, v + 1, peaks);
    }
}

fn getTrailHeadScores(map: [][]u64, trailheads: *std.AutoHashMap(Pos, Set(Pos))) !void {
    var th_it = trailheads.iterator();
    while (th_it.next()) |th| {
        try findPeaks(map, th.key_ptr.*, 0, th.value_ptr);
    }
}

fn part1(allocator: std.mem.Allocator, input: []const u8) !u64 {
    const data = try tools.read_file(allocator, input);
    var read_it = std.mem.tokenize(u8, data, "\n");

    var map_creator = std.ArrayList([]u64).init(allocator);
    var trailheads = std.AutoHashMap(Pos, Set(Pos)).init(allocator);

    var y: u64 = 0;
    while (read_it.next()) |line| {
        var line_holder = std.ArrayList(u64).init(allocator);
        defer line_holder.deinit();
        for (line, 0..) |c, x| {
            try line_holder.append(try charToDigit(c, 10));
            if (c == '0') {
                try trailheads.put(Pos{ .x = x, .y = y }, Set(Pos).init(allocator));
            }
        }
        try map_creator.append(try line_holder.toOwnedSlice());
        y += 1;
    }

    const map = try map_creator.toOwnedSlice();

    try getTrailHeadScores(map, &trailheads);

    var acc: u64 = 0;
    var th_it = trailheads.iterator();
    while (th_it.next()) |th| {
        acc += th.value_ptr.cardinality();
    }
    return acc;
}

fn findPeaks2(map: [][]u64, curr: Pos, v: u64, peaks: *u64) void {
    if (v == 9) {
        peaks.* += 1;
        return;
    } else if (v > 9) {
        //Why are we here?
        return;
    }

    //Up
    if (curr.y > 0 and map[curr.y - 1][curr.x] == v + 1) {
        findPeaks2(map, Pos{ .x = curr.x, .y = curr.y - 1 }, v + 1, peaks);
    }

    //Down
    if (curr.y < map.len - 1 and map[curr.y + 1][curr.x] == v + 1) {
        findPeaks2(map, Pos{ .x = curr.x, .y = curr.y + 1 }, v + 1, peaks);
    }

    //Right
    if (curr.x < map[0].len - 1 and map[curr.y][curr.x + 1] == v + 1) {
        findPeaks2(map, Pos{ .x = curr.x + 1, .y = curr.y }, v + 1, peaks);
    }

    //Left
    if (curr.x > 0 and map[curr.y][curr.x - 1] == v + 1) {
        findPeaks2(map, Pos{ .x = curr.x - 1, .y = curr.y }, v + 1, peaks);
    }
}

fn getTrailHeadRatings(map: [][]u64, trailheads: *std.AutoHashMap(Pos, u64)) void {
    var th_it = trailheads.iterator();
    while (th_it.next()) |th| {
        findPeaks2(map, th.key_ptr.*, 0, th.value_ptr);
    }
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !u64 {
    const data = try tools.read_file(allocator, input);
    var read_it = std.mem.tokenize(u8, data, "\n");

    var map_creator = std.ArrayList([]u64).init(allocator);
    var trailheads = std.AutoHashMap(Pos, u64).init(allocator);

    var y: u64 = 0;
    while (read_it.next()) |line| {
        var line_holder = std.ArrayList(u64).init(allocator);
        defer line_holder.deinit();
        for (line, 0..) |c, x| {
            try line_holder.append(try charToDigit(c, 10));
            if (c == '0') {
                try trailheads.put(Pos{ .x = x, .y = y }, 0);
            }
        }
        try map_creator.append(try line_holder.toOwnedSlice());
        y += 1;
    }

    const map = try map_creator.toOwnedSlice();

    getTrailHeadRatings(map, &trailheads);

    var acc: u64 = 0;
    var th_it = trailheads.iterator();
    while (th_it.next()) |th| {
        acc += th.value_ptr.*;
    }

    return acc;
}

pub fn run(allocator: std.mem.Allocator) !void {
    const input = "inputs/day10.txt";

    print("Day 10:\n", .{});

    var t = try std.time.Timer.start();
    const p1 = try part1(allocator, input);
    print("\tPart 1: {d} in {}\n", .{ p1, fmtDuration(t.read()) });

    t.reset();
    const p2 = try part2(allocator, input);
    print("\tPart 2: {d} in {}\n", .{ p2, fmtDuration(t.read()) });
}

test "part 1" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const ans = try part1(arena.allocator(), "tests/day10.txt");
    try std.testing.expectEqual(36, ans);
}

test "part 2" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const ans = try part2(arena.allocator(), "tests/day10.txt");
    try std.testing.expectEqual(81, ans);
}
