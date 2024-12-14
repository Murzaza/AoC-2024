const std = @import("std");
const tools = @import("tools.zig");
const Pos = tools.Pos;
const print = std.debug.print;
const fmtDuration = std.fmt.fmtDuration;
const parseInt = std.fmt.parseInt;

const Robot = struct {
    pos: Pos,
    velocity: Pos,
};

fn getNewPosition(robot: Robot, sec: i64, max_x: i64, max_y: i64) Pos {
    const total_move = tools.scale(robot.velocity, sec);
    const new_pos = tools.add(robot.pos, total_move);
    return tools.mod(new_pos, max_x, max_y);
}

fn assignToQuadrant(robot: Robot, max_x: i64, max_y: i64, quadrants: *[4]u64) void {
    const final_pos = getNewPosition(robot, 100, max_x, max_y);

    const half_x = @divTrunc(max_x, 2);
    const half_y = @divTrunc(max_y, 2);

    if (0 <= final_pos.x and final_pos.x < half_x and 0 <= final_pos.y and final_pos.y < half_y) {
        quadrants.*[0] += 1;
    } else if (half_x < final_pos.x and final_pos.x < max_x and 0 <= final_pos.y and final_pos.y < half_y) {
        quadrants.*[1] += 1;
    } else if (0 <= final_pos.x and final_pos.x < half_x and half_y < final_pos.y and final_pos.y < max_y) {
        quadrants.*[2] += 1;
    } else if (half_x < final_pos.x and final_pos.x < max_x and half_y < final_pos.y and final_pos.y < max_y) {
        quadrants.*[3] += 1;
    }
}

fn part1(allocator: std.mem.Allocator, input: []const u8, max_x: i64, max_y: i64, part2: bool) !u64 {
    const data = try tools.read_file(allocator, input);
    var read_it = std.mem.tokenize(u8, data, "\n");

    var robots = std.ArrayList(Robot).init(allocator);

    while (read_it.next()) |line| {
        var tokens = std.mem.tokenizeAny(u8, line, "=, ");
        _ = tokens.next().?;
        const pos = Pos{
            .x = try parseInt(i64, tokens.next().?, 10),
            .y = try parseInt(i64, tokens.next().?, 10),
        };
        _ = tokens.next().?;
        const vel = Pos{
            .x = try parseInt(i64, tokens.next().?, 10),
            .y = try parseInt(i64, tokens.next().?, 10),
        };

        const r = Robot{ .pos = pos, .velocity = vel };
        try robots.append(r);
    }

    if (!part2) {
        var quadrants = [4]u64{ 0, 0, 0, 0 };
        for (robots.items) |robot| {
            assignToQuadrant(robot, max_x, max_y, &quadrants);
        }

        var prod: u64 = 1;

        for (quadrants) |q| {
            prod *= q;
        }

        return prod;
    }

    // Part 2 - Using Variances to find the odd duck and the Chinese Remainder Theorem to solve.
    // See Here: https://old.reddit.com/r/adventofcode/comments/1he0asr/2024_day_14_part_2_why_have_fun_with_image/m1zzfsh/

    // Calculate variance for each time step 0 - max_y.
    var x_variances = std.ArrayList(i64).init(allocator);
    var y_variances = std.ArrayList(i64).init(allocator);

    for (0..@intCast(max_y + 1)) |sec| {
        var robot_pos = std.ArrayList(Pos).init(allocator);
        for (robots.items) |robot| {
            const p = getNewPosition(robot, @intCast(sec), max_x, max_y);
            try robot_pos.append(p);
        }
        var xs = std.ArrayList(i64).init(allocator);
        var ys = std.ArrayList(i64).init(allocator);
        for (robot_pos.items) |robo| {
            try xs.append(robo.x);
            try ys.append(robo.y);
        }
        try x_variances.append(tools.variance(xs.items));
        try y_variances.append(tools.variance(ys.items));
    }

    var bx: i64 = 0;
    var xvar: i64 = x_variances.items[0];
    var by: i64 = 0;
    var yvar: i64 = y_variances.items[0];
    for (1..x_variances.items.len) |i| {
        const mxv = x_variances.items[i];
        if (mxv < xvar) {
            bx = @intCast(i);
            xvar = mxv;
        }

        const myv = y_variances.items[i];
        if (myv < yvar) {
            by = @intCast(i);
            yvar = myv;
        }
    }

    var t: u64 = 0;
    const inv_max_x = tools.inverse_mod(max_x, max_y);
    t = @intCast(bx + (@mod(inv_max_x * (by - bx), max_y) * max_x));
    return t;
}

pub fn run(allocator: std.mem.Allocator) !void {
    const input = "inputs/day14.txt";

    print("Day 14:\n", .{});

    var t = try std.time.Timer.start();
    const p1 = try part1(allocator, input, 101, 103, false);
    print("\tPart 1: {d} in {}\n", .{ p1, fmtDuration(t.read()) });

    t.reset();
    const p2 = try part1(allocator, input, 101, 103, true);
    print("\tPart 2: {d} in {}\n", .{ p2, fmtDuration(t.read()) });
}

test "part 1" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const ans = try part1(arena.allocator(), "tests/day14.txt", 11, 7, false);
    try std.testing.expectEqual(12, ans);
}
