const std = @import("std");
const tools = @import("tools.zig");
const mvzr = @import("mvzr");

fn part1(allocator: std.mem.Allocator, input: []const u8) !u64 {
    const data = try tools.read_file(allocator, input);
    const regex: mvzr.Regex = mvzr.compile("mul\\(([0-9]{1,3}),([0-9]{1,3})\\)").?;
    const num_re = mvzr.compile("\\d+").?;
    var reg_it = regex.iterator(data);
    var acc: u64 = 0;
    while (reg_it.next()) |match| {
        var num_it = num_re.iterator(match.slice);
        var local_acc: u64 = 1;
        while (num_it.next()) |n| {
            local_acc *= try std.fmt.parseInt(u64, n.slice, 10);
        }
        acc += local_acc;
    }
    return acc;
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !u64 {
    const data = try tools.read_file(allocator, input);
    const regex: mvzr.Regex = mvzr.compile("mul\\(([0-9]{1,3}),([0-9]{1,3})\\)|do\\(\\)|don't\\(\\)").?;
    const num_re = mvzr.compile("\\d+").?;
    var reg_it = regex.iterator(data);
    var acc: u64 = 0;
    var enabled = true;
    while (reg_it.next()) |match| {
        if (std.mem.eql(u8, match.slice, "do()")) {
            enabled = true;
        } else if (std.mem.eql(u8, match.slice, "don't()")) {
            enabled = false;
        } else {
            if (enabled) {
                var num_it = num_re.iterator(match.slice);
                var local_acc: u64 = 1;
                while (num_it.next()) |n| {
                    local_acc *= try std.fmt.parseInt(u64, n.slice, 10);
                }
                acc += local_acc;
            }
        }
    }
    return acc;
}

pub fn run(allocator: std.mem.Allocator) !void {
    const input = "inputs/day3.txt";

    std.debug.print("Day 3:\n", .{});

    const p1 = try part1(allocator, input);
    std.debug.print("\tPart 1: {d}\n", .{p1});

    const p2 = try part2(allocator, input);
    std.debug.print("\tPart 2: {d}\n", .{p2});
}

test "part1" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const ans = try part1(arena.allocator(), "tests/day3.txt");
    try std.testing.expectEqual(161, ans);
}

test "part2" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const ans = try part2(arena.allocator(), "tests/day3-2.txt");
    try std.testing.expectEqual(48, ans);
}
