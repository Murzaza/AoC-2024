const std = @import("std");
const tools = @import("tools.zig");

fn contains(list: []u64, item: u64) bool {
    for (list) |v| {
        if (v == item) return true;
    }

    return false;
}

fn has_intersection(a: []u64, b: []u64) bool {
    for (a) |i| {
        for (b) |j| {
            if (i == j) return true;
        }
    }

    return false;
}

fn compare(context: std.AutoHashMap(u64, std.ArrayList(u64)), lhs: u64, rhs: u64) bool {
    // lhs < rhs?
    if (context.contains(lhs)) {
        if (contains(context.get(lhs).?.items, rhs)) {
            return true;
        }
    }
    return false;
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !u64 {
    const data = try tools.read_file(allocator, input);

    var read_it = std.mem.tokenize(u8, data, "\n");

    var rules_map = std.AutoHashMap(u64, std.ArrayList(u64)).init(allocator);

    var read_rules = true;
    var acc: u64 = 0;
    while (read_it.next()) |line| {
        if (line.len > 5) {
            read_rules = false;
        }

        if (read_rules) {
            var rule = std.mem.splitScalar(u8, line, '|');
            const before = try std.fmt.parseInt(u64, rule.next().?, 10);
            const after = try std.fmt.parseInt(u64, rule.next().?, 10);

            if (rules_map.contains(before)) {
                if (!contains(rules_map.get(before).?.items, after)) {
                    var afters = rules_map.get(before).?;
                    try afters.append(after);
                    try rules_map.put(before, afters);
                }
            } else {
                var after_list = std.ArrayList(u64).init(allocator);
                try after_list.append(after);
                try rules_map.put(before, after_list);
            }
        } else { // Do the checking.
            var val_it = std.mem.tokenize(u8, line, ",");
            var list = std.ArrayList(u64).init(allocator);
            defer list.deinit();
            var intersection_free = true;
            while (val_it.next()) |val| {
                const v = try std.fmt.parseInt(u64, val, 10);
                const rules = if (rules_map.contains(v)) rules_map.get(v).?.items else std.ArrayList(u64).init(allocator).items;

                if (has_intersection(list.items, rules)) {
                    try list.append(v);
                    intersection_free = false;
                    std.mem.sort(u64, list.items, rules_map, compare);
                } else {
                    try list.append(v);
                }
            }

            if (!intersection_free) {
                acc += list.items[list.items.len / 2];
            }
        }
    }

    return acc;
}

fn part1(allocator: std.mem.Allocator, input: []const u8) !u64 {
    const data = try tools.read_file(allocator, input);

    var read_it = std.mem.tokenize(u8, data, "\n");

    var rules_map = std.AutoHashMap(u64, std.ArrayList(u64)).init(allocator);

    var read_rules = true;
    var acc: u64 = 0;
    while (read_it.next()) |line| {
        if (line.len > 5) {
            read_rules = false;
        }

        if (read_rules) {
            var rule = std.mem.splitScalar(u8, line, '|');
            const before = try std.fmt.parseInt(u64, rule.next().?, 10);
            const after = try std.fmt.parseInt(u64, rule.next().?, 10);

            if (rules_map.contains(before)) {
                if (!contains(rules_map.get(before).?.items, after)) {
                    var afters = rules_map.get(before).?;
                    try afters.append(after);
                    try rules_map.put(before, afters);
                }
            } else {
                var after_list = std.ArrayList(u64).init(allocator);
                try after_list.append(after);
                try rules_map.put(before, after_list);
            }
        } else { // Do the checking.
            var val_it = std.mem.tokenize(u8, line, ",");
            var list = std.ArrayList(u64).init(allocator);
            defer list.deinit();
            var intersection_free = true;
            while (val_it.next()) |val| {
                const v = try std.fmt.parseInt(u64, val, 10);
                const rules = if (rules_map.contains(v)) rules_map.get(v).?.items else std.ArrayList(u64).init(allocator).items;
                if (has_intersection(list.items, rules)) {
                    intersection_free = false;
                }
                try list.append(v);
            }

            if (intersection_free) {
                acc += list.items[list.items.len / 2];
            }
        }
    }

    return acc;
}

pub fn run(allocator: std.mem.Allocator) !void {
    const input = "inputs/day5.txt";

    std.debug.print("Day 5:\n", .{});

    const p1 = try part1(allocator, input);
    std.debug.print("\tPart 1: {d}\n", .{p1});

    const p2 = try part2(allocator, input);
    std.debug.print("\tPart 2: {d}\n", .{p2});
}

test "part 1" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const ans = try part1(arena.allocator(), "tests/day5.txt");
    try std.testing.expectEqual(143, ans);
}

test "part 2" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const ans = try part2(arena.allocator(), "tests/day5.txt");
    try std.testing.expectEqual(123, ans);
}
