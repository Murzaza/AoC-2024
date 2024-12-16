const std = @import("std");
const tools = @import("tools.zig");
const Pos = tools.Pos;
const print = std.debug.print;
const fmtDura = std.fmt.fmtDuration;
const Set = @import("ziglangSet").Set;

const Item = enum {
    Box,
    Wall,
    Empty,
    Robot,
};

fn isInstruction(c: u8) bool {
    return c == '<' or c == '>' or c == '^' or c == 'v';
}

fn charToItem(c: u8) Item {
    return switch (c) {
        '#' => Item.Wall,
        'O' => Item.Box,
        '@' => Item.Robot,
        else => Item.Empty,
    };
}

fn charToInstruction(c: u8) Pos {
    return switch (c) {
        '<' => Pos{ .x = -1, .y = 0 },
        '>' => Pos{ .x = 1, .y = 0 },
        'v' => Pos{ .x = 0, .y = 1 },
        '^' => Pos{ .x = 0, .y = -1 },
        else => Pos{ .x = 0, .y = 0 },
    };
}

fn moveBox(pos: Pos, inst: Pos, map: *[][]Item) bool {
    const next = tools.add(pos, inst);
    var update = false;
    const next_item = map.*[@intCast(next.y)][@intCast(next.x)];
    switch (next_item) {
        Item.Empty => update = true,
        Item.Box => update = moveBox(next, inst, map),
        Item.Wall => update = false,
        else => {},
    }

    if (update) {
        // Move box
        var x: usize = @intCast(next.x);
        var y: usize = @intCast(next.y);
        map.*[y][x] = Item.Box;

        // Leave previous
        x = @intCast(pos.x);
        y = @intCast(pos.y);
        map.*[y][x] = Item.Empty;
    }

    return update;
}

fn move(robot: *Pos, inst: Pos, map: *[][]Item) void {
    const new_place = tools.add(robot.*, inst);
    const item = map.*[@intCast(new_place.y)][@intCast(new_place.x)];

    var update = false;
    switch (item) {
        Item.Wall => update = false,
        Item.Empty => update = true,
        Item.Box => update = moveBox(new_place, inst, map),
        else => {},
    }

    if (update) {
        robot.*.x = new_place.x;
        robot.*.y = new_place.y;
    }
}

fn calculateGps(map: [][]Item) u64 {
    var gps: u64 = 0;
    for (map, 0..) |line, y| {
        for (line, 0..) |item, x| {
            if (item == Item.Box) {
                gps += 100 * y + x;
            }
        }
    }

    return gps;
}

fn part1(allocator: std.mem.Allocator, input: []const u8) !u64 {
    const data = try tools.read_file(allocator, input);
    var read_it = std.mem.tokenize(u8, data, "\n");

    var map_builder = std.ArrayList([]Item).init(allocator);
    var robot = Pos{ .x = 0, .y = 0 };
    var instructions = std.ArrayList(Pos).init(allocator);

    var y: i64 = 0;
    while (read_it.next()) |line| {
        if (isInstruction(line[0])) {
            for (line) |c| {
                try instructions.append(charToInstruction(c));
            }
        } else {
            var map_line = std.ArrayList(Item).init(allocator);
            for (line, 0..) |c, x| {
                const item = charToItem(c);
                switch (item) {
                    Item.Robot => {
                        robot.x = @intCast(x);
                        robot.y = y;
                        try map_line.append(Item.Empty);
                    },
                    else => try map_line.append(item),
                }
            }
            try map_builder.append(try map_line.toOwnedSlice());
        }
        y += 1;
    }

    var map = try map_builder.toOwnedSlice();

    for (instructions.items) |inst| {
        move(&robot, inst, &map);
    }

    return calculateGps(map);
}

pub fn run(allocator: std.mem.Allocator) !void {
    const input = "inputs/day15.txt";

    print("Day 15:\n", .{});

    var t = try std.time.Timer.start();
    const p1 = try part1(allocator, input);
    print("\tPart 1: {d} in {}\n", .{ p1, fmtDura(t.read()) });
}

test "part 1" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const ans = try part1(arena.allocator(), "tests/day15.txt");
    try std.testing.expectEqual(10092, ans);
}
