const std = @import("std");
const tools = @import("tools.zig");

const Equation = struct {
    target: u64,
    numbers: []u64,
};

fn concatNums(a: u64, b: u64) u64 {
    var mult: u64 = 10;
    while (mult <= b) {
        mult *= 10;
    }

    const val = (a * mult) + b;
    return val;
}

fn canEquate(eq: Equation, idx: usize, acc: u64, part2: bool) bool {
    if (eq.target == acc and idx == eq.numbers.len) {
        return true;
    } else if (eq.target < acc) {
        return false;
    } else if (idx >= eq.numbers.len) {
        return false;
    }

    const num = eq.numbers[idx];
    // add
    var worked = canEquate(eq, idx + 1, acc + num, part2);
    // multiply
    if (!worked) {
        worked = canEquate(eq, idx + 1, acc * num, part2);
    }

    if (!worked and part2) {
        worked = canEquate(eq, idx + 1, concatNums(acc, num), part2);
    }

    return worked;
}

fn part1(allocator: std.mem.Allocator, input: []const u8, part2: bool) !u64 {
    const data = try tools.read_file(allocator, input);

    var read_it = std.mem.tokenize(u8, data, "\n");
    var list = std.ArrayList(u64).init(allocator);
    var eq_list = std.ArrayList(Equation).init(allocator);

    while (read_it.next()) |line| {
        var tokens = std.mem.tokenizeAny(u8, line, ": ");
        const target = try std.fmt.parseInt(u64, tokens.next().?, 10);
        while (tokens.next()) |num| {
            try list.append(try std.fmt.parseInt(u64, num, 10));
        }

        const eq = Equation{ .target = target, .numbers = try list.toOwnedSlice() };
        try eq_list.append(eq);
    }

    var acc: u64 = 0;
    for (eq_list.items) |eq| {
        var works = false;
        if (canEquate(eq, 0, 0, part2)) {
            works = true;
            acc += eq.target;
        }

        //std.debug.print("{any} {any}\n", .{ eq.numbers, works });
    }

    return acc;
}

pub fn run(allocator: std.mem.Allocator) !void {
    const input = "inputs/day7.txt";

    std.debug.print("Day 7:\n", .{});

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

    const ans = part1(arena.allocator(), "tests/day7.txt", false);
    try std.testing.expectEqual(3749, ans);
}

test "part 2" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const ans = part1(arena.allocator(), "tests/day7.txt", true);
    try std.testing.expectEqual(11387, ans);
}
