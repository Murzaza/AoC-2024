const std = @import("std");
const tools = @import("tools.zig");
const Pos = tools.Pos;
const print = std.debug.print;
const fmtDuration = std.fmt.fmtDuration;
const ArrayList = std.ArrayList;
const Set = @import("ziglangSet").Set;

fn calculateRegion(plot: u8, pos: Pos, map: [][]const u8, covered: *Set(Pos), region: *u64) !u64 {
    if (!tools.legal(pos, map.len)) return 0;
    if (map[@intCast(pos.y)][@intCast(pos.x)] != plot) return 0;
    if (covered.contains(pos)) return 0;

    _ = try covered.add(pos);
    region.* += 1;

    const bordering_plots = [_]Pos{
        tools.add(pos, Pos{ .x = 0, .y = -1 }),
        tools.add(pos, Pos{ .x = 1, .y = 0 }),
        tools.add(pos, Pos{ .x = 0, .y = 1 }),
        tools.add(pos, Pos{ .x = -1, .y = 0 }),
    };

    var needs_fence: u64 = 4;
    for (bordering_plots) |p| {
        if (tools.legal(p, map.len)) {
            if (map[@intCast(p.y)][@intCast(p.x)] == plot) needs_fence -= 1;
        }
        if (!covered.contains(p))
            needs_fence += try calculateRegion(plot, p, map, covered, region);
    }

    return needs_fence;
}

fn calculateFencePrice(allocator: std.mem.Allocator, map: [][]const u8) !u64 {
    var covered = Set(Pos).init(allocator);
    defer covered.deinit();

    var price: u64 = 0;
    for (map, 0..) |line, y| {
        for (line, 0..) |plot, x| {
            const pos = Pos{ .x = @intCast(x), .y = @intCast(y) };
            if (!covered.contains(pos)) {
                var region: u64 = 0;
                const fences = try calculateRegion(plot, pos, map, &covered, &region);
                price += fences * region;
            }
        }
    }

    return price;
}

fn calculateRegionEdges(plot: u8, pos: Pos, map: [][]const u8, covered: *Set(Pos), region: *u64) !u64 {
    if (!tools.legal(pos, map.len)) return 0;
    if (map[@intCast(pos.y)][@intCast(pos.x)] != plot) return 0;
    if (covered.contains(pos)) return 0;

    _ = try covered.add(pos);
    region.* += 1;

    const bordering_plots = [_]Pos{
        tools.add(pos, Pos{ .x = 0, .y = -1 }),
        tools.add(pos, Pos{ .x = 1, .y = 0 }),
        tools.add(pos, Pos{ .x = 0, .y = 1 }),
        tools.add(pos, Pos{ .x = -1, .y = 0 }),
        tools.add(pos, Pos{ .x = 1, .y = -1 }),
        tools.add(pos, Pos{ .x = 1, .y = 1 }),
        tools.add(pos, Pos{ .x = -1, .y = 1 }),
        tools.add(pos, Pos{ .x = -1, .y = -1 }),
    };

    var dir = [_]bool{ true, true, true, true, true, true, true, true };

    var edges: u64 = 0;
    for (bordering_plots, 0..) |p, i| {
        if (tools.legal(p, map.len)) {
            if (map[@intCast(p.y)][@intCast(p.x)] == plot) dir[i] = false;
        }
        if (!covered.contains(p) and i < 4) // No diags on chasing regions.
            edges += try calculateRegionEdges(plot, p, map, covered, region);
    }

    const up = dir[0];
    const right = dir[1];
    const down = dir[2];
    const left = dir[3];
    const ur = dir[4];
    const dr = dir[5];
    const dl = dir[6];
    const ul = dir[7];

    if (up and right) edges += 1;
    if (up and left) edges += 1;
    if (down and right) edges += 1;
    if (down and left) edges += 1;

    if (!up and !right and ur) edges += 1;
    if (!up and !left and ul) edges += 1;
    if (!down and !left and dl) edges += 1;
    if (!down and !right and dr) edges += 1;

    return edges;
}

fn calculateFenceSalePrice(allocator: std.mem.Allocator, map: [][]const u8) !u64 {
    var covered = Set(Pos).init(allocator);
    defer covered.deinit();

    var price: u64 = 0;
    for (map, 0..) |line, y| {
        for (line, 0..) |plot, x| {
            const pos = Pos{ .x = @intCast(x), .y = @intCast(y) };
            if (!covered.contains(pos)) {
                var region: u64 = 0;
                const edges = try calculateRegionEdges(plot, pos, map, &covered, &region);
                price += edges * region;
            }
        }
    }

    return price;
}

fn exec(allocator: std.mem.Allocator, input: []const u8, part2: bool) !u64 {
    const data = try tools.read_file(allocator, input);
    var read_it = std.mem.tokenize(u8, data, "\n");

    var map_builder = ArrayList([]const u8).init(allocator);
    while (read_it.next()) |line| {
        try map_builder.append(line);
    }

    const map = try map_builder.toOwnedSlice();

    if (!part2)
        return try calculateFencePrice(allocator, map);

    return try calculateFenceSalePrice(allocator, map);
}

pub fn run(allocator: std.mem.Allocator) !void {
    const input = "inputs/day12.txt";

    print("Day 12:\n", .{});

    var t = try std.time.Timer.start();
    const p1 = try exec(allocator, input, false);
    print("\tPart 1: {d} in {}\n", .{ p1, fmtDuration(t.read()) });

    t.reset();
    const p2 = try exec(allocator, input, true);
    print("\tPart 2: {d} in {}\n", .{ p2, fmtDuration(t.read()) });
}

test "part 1" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const ans = exec(arena.allocator(), "tests/day12.txt", false);
    try std.testing.expectEqual(1930, ans);
}

test "part 2" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    var ans = exec(arena.allocator(), "tests/day12.txt", true);
    try std.testing.expectEqual(1206, ans);

    ans = exec(arena.allocator(), "tests/day12a.txt", true);
    try std.testing.expectEqual(80, ans);

    ans = exec(arena.allocator(), "tests/day12b.txt", true);
    try std.testing.expectEqual(236, ans);

    ans = exec(arena.allocator(), "tests/day12c.txt", true);
    try std.testing.expectEqual(368, ans);
}
