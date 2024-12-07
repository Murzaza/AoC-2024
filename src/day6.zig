const std = @import("std");
const tools = @import("tools.zig");
const Set = @import("ziglangSet").Set;

const Pos = struct {
    x: u64,
    y: u64,
};

const Dir = enum {
    up,
    right,
    down,
    left,
};

const Hist = struct {
    pos: Pos,
    dir: Dir,
};

fn calculateMoves(guard: *Pos, dir: Dir, map: std.ArrayList([]const u8), set: *Set(Pos)) error{ Gone, OutOfMemory }!void {
    switch (dir) {
        Dir.up => {
            while (guard.y > 0) {
                if (map.items[guard.y - 1][guard.x] != '#') {
                    guard.y -= 1;
                    _ = try set.add(guard.*);
                } else {
                    // We've hit an object stop.
                    break;
                }
            }

            if (guard.y == 0) return error.Gone;
        },
        Dir.right => {
            while (guard.x < map.items[0].len - 1) {
                if (map.items[guard.y][guard.x + 1] != '#') {
                    guard.x += 1;
                    _ = try set.add(guard.*);
                } else {
                    // We've hit an object stop.
                    break;
                }
            }

            if (guard.x == map.items[0].len - 1) return error.Gone;
        },
        Dir.down => {
            while (guard.y < map.items.len - 1) {
                if (map.items[guard.y + 1][guard.x] != '#') {
                    guard.y += 1;
                    _ = try set.add(guard.*);
                } else {
                    // We've hit an object stop.
                    break;
                }
            }

            if (guard.y == map.items.len - 1) return error.Gone;
        },
        Dir.left => {
            while (guard.x > 0) {
                if (map.items[guard.y][guard.x - 1] != '#') {
                    guard.x -= 1;
                    _ = try set.add(guard.*);
                } else {
                    // We've hit an object stop.
                    break;
                }
            }

            if (guard.x == 0) return error.Gone;
        },
    }
}

fn countLoops(guard: *Pos, dir: Dir, map: *Set(Pos), set: *Set(Hist), max: u64) error{ Gone, OutOfMemory, Loop }!void {
    switch (dir) {
        Dir.up => {
            while (guard.y > 0) {
                const new = Pos{ .x = guard.x, .y = guard.y - 1 };
                if (!map.contains(new)) {
                    guard.y -= 1;
                    const added = try set.add(Hist{ .pos = guard.*, .dir = dir });
                    if (!added) return error.Loop;
                } else {
                    // We've hit an object stop.
                    break;
                }
            }

            if (guard.y == 0) return error.Gone;
        },
        Dir.right => {
            while (guard.x < max) {
                const new = Pos{ .x = guard.x + 1, .y = guard.y };
                if (!map.contains(new)) {
                    guard.x += 1;
                    const added = try set.add(Hist{ .pos = guard.*, .dir = dir });
                    if (!added) return error.Loop;
                } else {
                    // We've hit an object stop.
                    break;
                }
            }

            if (guard.x == max) return error.Gone;
        },
        Dir.down => {
            while (guard.y < max) {
                const new = Pos{ .x = guard.x, .y = guard.y + 1 };
                if (!map.contains(new)) {
                    guard.y += 1;
                    const added = try set.add(Hist{ .pos = guard.*, .dir = dir });
                    if (!added) return error.Loop;
                } else {
                    // We've hit an object stop.
                    break;
                }
            }

            if (guard.y == max) return error.Gone;
        },
        Dir.left => {
            while (guard.x > 0) {
                const new = Pos{ .x = guard.x - 1, .y = guard.y };
                if (!map.contains(new)) {
                    guard.x -= 1;
                    const added = try set.add(Hist{ .pos = guard.*, .dir = dir });
                    if (!added) return error.Loop;
                } else {
                    // We've hit an object stop.
                    break;
                }
            }

            if (guard.x == 0) return error.Gone;
        },
    }
}

fn part1(allocator: std.mem.Allocator, input: []const u8) !u64 {
    const data = try tools.read_file(allocator, input);

    var read_it = std.mem.tokenize(u8, data, "\n");

    var map = std.ArrayList([]const u8).init(allocator);
    var guard = Pos{ .x = 0, .y = 0 };
    var y: usize = 0;

    while (read_it.next()) |line| {
        for (line, 0..) |c, x| {
            if (c == '^') {
                guard = Pos{ .x = x, .y = y };
            }
        }
        try map.append(line);
        y += 1;
    }

    const dirs = [_]Dir{
        Dir.up,
        Dir.right,
        Dir.down,
        Dir.left,
    };
    var dir_idx: usize = 0;

    var set = Set(Pos).init(allocator);
    _ = try set.add(guard);

    while (true) {
        calculateMoves(&guard, dirs[dir_idx], map, &set) catch {
            break;
        };
        dir_idx = (dir_idx + 1) % dirs.len;
    }
    return set.cardinality();
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !u64 {
    const data = try tools.read_file(allocator, input);

    var read_it = std.mem.tokenize(u8, data, "\n");

    var map = std.ArrayList([]const u8).init(allocator);
    var guard = Pos{ .x = 0, .y = 0 };
    var starting = Pos{ .x = 0, .y = 0 };
    var y: usize = 0;
    var objs = Set(Pos).init(allocator);

    while (read_it.next()) |line| {
        for (line, 0..) |c, x| {
            if (c == '^') {
                guard = Pos{ .x = x, .y = y };
                starting = guard;
            } else if (c == '#') {
                _ = try objs.add(Pos{ .x = x, .y = y });
            }
        }
        try map.append(line);
        y += 1;
    }

    const dirs = [_]Dir{
        Dir.up,
        Dir.right,
        Dir.down,
        Dir.left,
    };

    var dir_idx: usize = 0;

    var set = Set(Pos).init(allocator);
    _ = try set.add(guard);

    // Get the path taken.
    while (true) {
        calculateMoves(&guard, dirs[dir_idx], map, &set) catch {
            break;
        };
        dir_idx = (dir_idx + 1) % dirs.len;
    }

    var loops: u64 = 0;
    var loop = Set(Hist).init(allocator);
    const max = y;

    var set_it = set.iterator();

    while (set_it.next()) |new_obj| {
        if (std.meta.eql(new_obj.*, starting)) {
            continue;
        }

        var nobjs = try objs.clone();
        _ = try nobjs.add(new_obj.*);
        guard = starting;

        var curr: usize = 0;
        while (true) {
            countLoops(&guard, dirs[curr], &nobjs, &loop, max) catch |e| {
                if (e == error.Loop) {
                    loops += 1;
                }
                break;
            };

            curr = (curr + 1) % dirs.len;
        }

        loop.clearRetainingCapacity();
    }
    return loops;
}

pub fn run(allocator: std.mem.Allocator) !void {
    const input = "inputs/day6.txt";

    std.debug.print("Day 6:\n", .{});

    var t = try std.time.Timer.start();
    const p1 = try part1(allocator, input);
    std.debug.print("\tPart 1: {d} in {}\n", .{ p1, std.fmt.fmtDuration(t.read()) });

    t.reset();
    const p2 = try part2(allocator, input);
    std.debug.print("\tPart 2: {d} in {}\n", .{ p2, std.fmt.fmtDuration(t.read()) });
}

test "part 1" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const ans = try part1(arena.allocator(), "tests/day6.txt");
    try std.testing.expectEqual(41, ans);
}

test "part 2" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const ans = try part2(arena.allocator(), "tests/day6.txt");
    try std.testing.expectEqual(6, ans);
}
