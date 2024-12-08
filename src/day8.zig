const std = @import("std");
const tools = @import("tools.zig");
const AHM = std.AutoHashMap;
const Set = @import("ziglangSet").Set;

const Pos = struct {
    x: i64,
    y: i64,
};

fn getNewPos(orig: Pos, next: Pos) Pos {
    const dx: i64 = next.x - orig.x;
    const dy: i64 = next.y - orig.y;

    return Pos{ .x = next.x + dx, .y = next.y + dy };
}

fn acceptable(cut: Pos, max: i64) bool {
    return if (cut.x < 0 or cut.x >= max or cut.y < 0 or cut.y >= max) false else true;
}

fn findAntinodes(ants: AHM(u8, std.ArrayList(Pos)), anti: *Set(Pos), max: i64) !void {
    var it = ants.iterator();
    while (it.next()) |entry| {
        var v = entry.value_ptr.*;
        for (v.items, 0..v.items.len) |a, i| {
            if (i == v.items.len - 1) continue;
            for (v.items[i + 1 ..]) |b| {
                const j = getNewPos(a, b);
                if (acceptable(j, max)) _ = try anti.add(j);

                const k = getNewPos(b, a);
                if (acceptable(k, max)) _ = try anti.add(k);
            }
        }
    }
}

fn findAntinodes2(ants: AHM(u8, std.ArrayList(Pos)), anti: *Set(Pos), max: i64) !void {
    var it = ants.iterator();
    while (it.next()) |entry| {
        var v = entry.value_ptr.*;
        for (v.items, 0..v.items.len) |a, i| {
            if (i == v.items.len - 1) continue;
            for (v.items[i + 1 ..]) |b| {
                //These two are in line with themselves:
                _ = try anti.add(a);
                _ = try anti.add(b);

                var j = getNewPos(a, b);
                var prev = b;
                while (acceptable(j, max)) {
                    _ = try anti.add(j);
                    const mid = getNewPos(prev, j);
                    prev = j;
                    j = mid;
                }

                var k = getNewPos(b, a);
                prev = a;
                while (acceptable(k, max)) {
                    _ = try anti.add(k);
                    const mid = getNewPos(prev, k);
                    prev = k;
                    k = mid;
                }
            }
        }
    }
}

fn part1(allocator: std.mem.Allocator, input: []const u8, part2: bool) !u64 {
    const data = try tools.read_file(allocator, input);

    var read_it = std.mem.tokenize(u8, data, "\n");
    var antennas = AHM(u8, std.ArrayList(Pos)).init(allocator);

    var y: i64 = 0;
    while (read_it.next()) |line| {
        for (line, 0..) |c, x| {
            if (c != '.') {
                var list = if (antennas.contains(c)) antennas.get(c).? else std.ArrayList(Pos).init(allocator);
                try list.append(Pos{ .x = @intCast(x), .y = y });
                try antennas.put(c, list);
            }
        }
        y += 1;
    }

    var antinodes = Set(Pos).init(allocator);

    // Do something...
    if (!part2) {
        try findAntinodes(antennas, &antinodes, y);
    } else {
        try findAntinodes2(antennas, &antinodes, y);
    }

    return antinodes.cardinality();
}

pub fn run(allocator: std.mem.Allocator) !void {
    const input = "inputs/day8.txt";

    var t = try std.time.Timer.start();
    const p1 = try part1(allocator, input, false);
    std.debug.print("\tPart 1: {d} in {}\n", .{ p1, std.fmt.fmtDuration(t.read()) });

    t.reset();
    const p2 = try part1(allocator, input, true);
    std.debug.print("\tPart 2: {d} in {}\n", .{ p2, std.fmt.fmtDuration(t.read()) });
}

test "part 1" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const ans = try part1(arena.allocator(), "tests/day8.txt", false);
    try std.testing.expectEqual(14, ans);
}

test "part 2" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const ans = try part1(arena.allocator(), "tests/day8.txt", true);
    try std.testing.expectEqual(34, ans);
}

test "part 2c" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const ans = try part1(arena.allocator(), "tests/day8c.txt", true);
    try std.testing.expectEqual(9, ans);
}
