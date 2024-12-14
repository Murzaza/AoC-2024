const std = @import("std");

pub fn read_file(allocator: std.mem.Allocator, file_path: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const stat = try file.stat();
    const file_size = stat.size;

    return try file.reader().readAllAlloc(allocator, file_size);
}

pub fn countDigits(n: u128) u64 {
    return std.math.log10_int(n) + 1;
}

pub const Pos = struct {
    x: i64,
    y: i64,
};

pub fn add(a: Pos, b: Pos) Pos {
    return Pos{ .x = a.x + b.x, .y = a.y + b.y };
}

pub fn scale(a: Pos, s: i64) Pos {
    return Pos{ .x = a.x * s, .y = a.y * s };
}

pub fn mod(a: Pos, x: i64, y: i64) Pos {
    return Pos{ .x = @mod(a.x, x), .y = @mod(a.y, y) };
}

pub fn legal(a: Pos, max: u64) bool {
    return a.x >= 0 and a.x < max and a.y >= 0 and a.y < max;
}

pub fn variance(a: []i64) i64 {
    var sum: i64 = 0;
    for (a) |i| {
        sum += i;
    }
    var len: i64 = @intCast(a.len);
    const mean: i64 = @divTrunc(sum, len);

    sum = 0;
    for (a) |i| {
        sum += std.math.pow(i64, i - mean, 2);
    }

    len = @intCast(a.len - 1);
    return @divTrunc(sum, len);
}

pub fn inverse_mod(n: i64, m: i64) i64 {
    for (1..@intCast(m)) |x| {
        const b: i64 = @intCast(x);
        if (@mod(n * b, m) == 1) {
            return @intCast(x);
        }
    }
    return 0;
}

test "pos" {
    const a = Pos{ .x = 1, .y = 1 };
    const b = Pos{ .x = 1, .y = 0 };

    const expected = Pos{ .x = 2, .y = 1 };
    try std.testing.expectEqual(expected, add(a, b));
}

test "reader" {
    var lines: usize = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const data = try read_file(gpa.allocator(), "tests/test.txt");
    defer gpa.allocator().free(data);

    var readIter = std.mem.tokenize(u8, data, "\n");

    while (readIter.next()) |_| {
        lines = lines + 1;
    }

    try std.testing.expectEqual(@as(usize, 2), lines);
}

test "countDigits" {
    const two = 12;
    const four = 1234;
    const ten = 1234567890;

    try std.testing.expectEqual(2, countDigits(two));
    try std.testing.expectEqual(4, countDigits(four));
    try std.testing.expectEqual(10, countDigits(ten));
}
