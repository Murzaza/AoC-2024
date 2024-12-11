const std = @import("std");
const tools = @import("tools.zig");
const AL = std.ArrayList;
const HM = std.AutoHashMap;
const print = std.debug.print;
const fmtDuration = std.fmt.fmtDuration;

fn splitEven(allocator: std.mem.Allocator, n: u128, digits: u64) ![]u128 {
    var halves = [2]u128{ n, 0 };
    var place: u128 = 1;
    for (0..digits / 2) |_| {
        const d = halves[0] % 10;
        halves[0] /= 10;
        halves[1] = place * d + halves[1];
        place *= 10;
    }
    return allocator.dupe(u128, &halves);
}

const CacheKey = struct {
    num: u128,
    blinks: u64,
};

fn blink(cache: *HM(CacheKey, u64), allocator: std.mem.Allocator, num: u128, blinks: u64) !u64 {
    const ck = CacheKey{ .num = num, .blinks = blinks };
    if (cache.get(ck)) |v| return v;

    if (blinks == 0) return 1;

    const nblinks = blinks - 1;

    if (num == 0) {
        const stones = try blink(cache, allocator, 1, nblinks);
        try cache.put(ck, stones);
        return stones;
    }

    const d = tools.countDigits(num);
    if (d % 2 == 0) {
        const stones = try splitEven(allocator, num, d);
        const front = try blink(cache, allocator, stones[0], nblinks);
        const back = try blink(cache, allocator, stones[1], nblinks);
        try cache.put(ck, front + back);
        return front + back;
    }

    const stone = num * 2024;
    const stones = try blink(cache, allocator, stone, nblinks);
    try cache.put(ck, stones);
    return stones;
}

fn exec(allocator: std.mem.Allocator, input: []const u8, blinks: u64) !u64 {
    const data = try tools.read_file(allocator, input);
    var tokens = std.mem.tokenizeAny(u8, data, " \n");
    var holder = AL(u128).init(allocator);
    while (tokens.next()) |tk| {
        try holder.append(try std.fmt.parseInt(u128, tk, 10));
    }

    const pebbles = try holder.toOwnedSlice();
    var cache = HM(CacheKey, u64).init(allocator);
    var acc: u64 = 0;
    for (pebbles) |p| {
        const v = try blink(&cache, allocator, p, blinks);
        acc += v;
    }
    return acc;
}

pub fn run(allocator: std.mem.Allocator) !void {
    const input = "inputs/day11.txt";
    print("Day 11:\n", .{});
    var t = try std.time.Timer.start();
    const p1 = try exec(allocator, input, 25);
    print("\tPart 1: {d} in {}\n", .{ p1, fmtDuration(t.read()) });

    t.reset();
    const p2 = try exec(allocator, input, 75);
    print("\tPart 2: {d} in {}\n", .{ p2, fmtDuration(t.read()) });
}

test "part 1" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const ans = try exec(arena.allocator(), "tests/day11.txt", 25);
    try std.testing.expectEqual(55312, ans);
}
