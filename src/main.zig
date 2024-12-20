const std = @import("std");
const days = @import("days.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();

    var args = std.process.args();

    _ = args.next().?; // Skip the program
    const v = args.next();
    const day = try std.fmt.parseInt(i32, v orelse "0", 10);

    // Run it
    switch (day) {
        1 => try days.day1.run(arena.allocator()),
        2 => try days.day2.run(arena.allocator()),
        3 => try days.day3.run(arena.allocator()),
        4 => try days.day4.run(arena.allocator()),
        5 => try days.day5.run(arena.allocator()),
        6 => try days.day6.run(arena.allocator()),
        7 => try days.day7.run(arena.allocator()),
        8 => try days.day8.run(arena.allocator()),
        9 => try days.day9.run(arena.allocator()),
        10 => try days.day10.run(arena.allocator()),
        11 => try days.day11.run(arena.allocator()),
        12 => try days.day12.run(arena.allocator()),
        13 => try days.day13.run(arena.allocator()),
        14 => try days.day14.run(arena.allocator()),
        15 => try days.day15.run(arena.allocator()),
        else => std.debug.print("Unknown day {d}\n", .{day}),
    }
}
