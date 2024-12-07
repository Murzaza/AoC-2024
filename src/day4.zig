const std = @import("std");
const tools = @import("tools.zig");

fn searchForXmas(list: std.ArrayList([]const u8), x: usize, y: usize) u64 {
    const up = y >= 3;
    const down = y <= list.items.len - 4;
    const left = x >= 3;
    const right = x <= list.items[0].len - 4;

    var found: u64 = 0;
    // Check up
    if (up) {
        const m = list.items[y - 1][x] == 'M';
        const a = list.items[y - 2][x] == 'A';
        const s = list.items[y - 3][x] == 'S';
        if (m and a and s) found += 1;
    }
    // Check down
    if (down) {
        const m = list.items[y + 1][x] == 'M';
        const a = list.items[y + 2][x] == 'A';
        const s = list.items[y + 3][x] == 'S';
        if (m and a and s) found += 1;
    }

    // Check right
    if (right) {
        const m = list.items[y][x + 1] == 'M';
        const a = list.items[y][x + 2] == 'A';
        const s = list.items[y][x + 3] == 'S';
        if (m and a and s) found += 1;
    }

    // Check left
    if (left) {
        const m = list.items[y][x - 1] == 'M';
        const a = list.items[y][x - 2] == 'A';
        const s = list.items[y][x - 3] == 'S';
        if (m and a and s) found += 1;
    }

    // Check diag r u
    if (right and up) {
        const m = list.items[y - 1][x + 1] == 'M';
        const a = list.items[y - 2][x + 2] == 'A';
        const s = list.items[y - 3][x + 3] == 'S';
        if (m and a and s) found += 1;
    }

    // Check diag r d
    if (right and down) {
        const m = list.items[y + 1][x + 1] == 'M';
        const a = list.items[y + 2][x + 2] == 'A';
        const s = list.items[y + 3][x + 3] == 'S';
        if (m and a and s) found += 1;
    }

    // Check diag l d
    if (left and down) {
        const m = list.items[y + 1][x - 1] == 'M';
        const a = list.items[y + 2][x - 2] == 'A';
        const s = list.items[y + 3][x - 3] == 'S';
        if (m and a and s) found += 1;
    }

    // Check diag l u
    if (left and up) {
        const m = list.items[y - 1][x - 1] == 'M';
        const a = list.items[y - 2][x - 2] == 'A';
        const s = list.items[y - 3][x - 3] == 'S';
        if (m and a and s) found += 1;
    }

    return found;
}

fn liveMas(list: std.ArrayList([]const u8), x: usize, y: usize) u64 {
    const up = y >= 1;
    const down = y <= list.items.len - 2;
    const left = x >= 1;
    const right = x <= list.items[0].len - 2;

    var found: u64 = 0;

    // Check diag r u
    if (right and up and down and left) {
        var l_cross = false;
        var m = list.items[y - 1][x - 1] == 'M';
        var s = list.items[y + 1][x + 1] == 'S';
        if (m and s) l_cross = true;

        m = list.items[y + 1][x + 1] == 'M';
        s = list.items[y - 1][x - 1] == 'S';
        if (m and s) l_cross = true;

        var r_cross = false;
        m = list.items[y - 1][x + 1] == 'M';
        s = list.items[y + 1][x - 1] == 'S';
        if (m and s) r_cross = true;

        m = list.items[y + 1][x - 1] == 'M';
        s = list.items[y - 1][x + 1] == 'S';
        if (m and s) r_cross = true;

        if (l_cross and r_cross) found += 1;
    }

    return found;
}

fn part1(allocator: std.mem.Allocator, input: []const u8) !u64 {
    const data = try tools.read_file(allocator, input);
    var data_list = std.ArrayList([]const u8).init(allocator);

    var read_it = std.mem.tokenize(u8, data, "\n");

    while (read_it.next()) |line| {
        try data_list.append(line);
    }

    var xmas: u64 = 0;
    for (data_list.items, 0..) |line, y| {
        for (line, 0..) |c, x| {
            if (c == 'X') xmas += searchForXmas(data_list, x, y);
        }
    }

    return xmas;
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !u64 {
    const data = try tools.read_file(allocator, input);
    var data_list = std.ArrayList([]const u8).init(allocator);

    var read_it = std.mem.tokenize(u8, data, "\n");

    while (read_it.next()) |line| {
        try data_list.append(line);
    }

    var xmas: u64 = 0;
    for (data_list.items, 0..) |line, y| {
        for (line, 0..) |c, x| {
            if (c == 'A') xmas += liveMas(data_list, x, y);
        }
    }

    return xmas;
}

pub fn run(allocator: std.mem.Allocator) !void {
    const input = "inputs/day4.txt";

    std.debug.print("Day 4:\n", .{});

    var t = try std.time.Timer.start();
    const p1 = try part1(allocator, input);
    std.debug.print("\tPart 1: {d} in {}\n", .{ p1, std.fmt.fmtDuration(t.read()) });

    t.reset();
    const p2 = try part2(allocator, input);
    std.debug.print("\tPart 2: {d} in {}\n", .{ p2, std.fmt.fmtDuration(t.read()) });
}

test "part1" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const ans = try part1(arena.allocator(), "tests/day4.txt");
    try std.testing.expectEqual(18, ans);
}

test "part2" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const ans = try part2(arena.allocator(), "tests/day4.txt");
    try std.testing.expectEqual(9, ans);
}
