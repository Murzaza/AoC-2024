const std = @import("std");
const tools = @import("tools.zig");
const print = std.debug.print;
const fmtDuration = std.fmt.fmtDuration;
const Pos = tools.Pos;
const parseInt = std.fmt.parseInt;

const ClawGame = struct {
    A: Pos,
    B: Pos,
    T: Pos,
};

fn default_game() ClawGame {
    return ClawGame{
        .A = Pos{ .x = 0, .y = 0 },
        .B = Pos{ .x = 0, .y = 0 },
        .T = Pos{ .x = 0, .y = 0 },
    };
}

fn canWeWin(game: ClawGame, a: i64, b: i64) bool {
    const a_p = tools.scale(game.A, a);
    const b_p = tools.scale(game.B, b);
    const claw = tools.add(a_p, b_p);

    return std.meta.eql(claw, game.T);
}

fn calculateTokens(game: ClawGame) i64 {
    // Using Cramer's Rule
    // We assume here that the determinant can't be zero.
    const det = game.A.x * game.B.y - game.A.y * game.B.x;
    const a = @divTrunc((game.T.x * game.B.y - game.T.y * game.B.x), det);
    const b = @divTrunc((game.A.x * game.T.y - game.A.y * game.T.x), det);
    if (canWeWin(game, a, b)) {
        return a * 3 + b;
    }
    return 0;
}

fn exec(allocator: std.mem.Allocator, input: []const u8, part2: bool) !u64 {
    const data = try tools.read_file(allocator, input);
    var read_it = std.mem.tokenize(u8, data, "\n");
    var line_counter: u64 = 0;
    var curr_game = default_game();
    var games = std.ArrayList(ClawGame).init(allocator);
    while (read_it.next()) |line| {
        var it = std.mem.tokenizeAny(u8, line, ":,+= ");

        _ = it.next().?;
        _ = it.next().?;
        if (line_counter < 2) _ = it.next().?;

        const x = try parseInt(i64, it.next().?, 10);
        _ = it.next().?;
        const y = try parseInt(i64, it.next().?, 10);

        const v = Pos{ .x = x, .y = y };
        switch (line_counter) {
            0 => {
                curr_game.A = v;
                line_counter += 1;
            },
            1 => {
                curr_game.B = v;
                line_counter += 1;
            },
            2 => {
                if (part2) {
                    const adjust = Pos{ .x = 10000000000000, .y = 10000000000000 };
                    curr_game.T = tools.add(v, adjust);
                } else {
                    curr_game.T = v;
                }
                line_counter = 0;
                try games.append(curr_game);
                curr_game = default_game();
            },
            else => line_counter = 0,
        }
    }

    var tokens: u64 = 0;
    for (games.items) |game| {
        tokens += @intCast(calculateTokens(game));
    }

    return tokens;
}

pub fn run(allocator: std.mem.Allocator) !void {
    const input = "inputs/day13.txt";

    print("Day 13:\n", .{});

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

    const ans = try exec(arena.allocator(), "tests/day13.txt", false);
    try std.testing.expectEqual(480, ans);
}
