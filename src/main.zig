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
    const day = try std.fmt.parseInt(i32, if (v == null) "0" else v.?, 10);

    // Run it
    switch (day) {
        1 => try days.day1.run(arena.allocator()),
        2 => try days.day2.run(arena.allocator()),
        3 => try days.day3.run(arena.allocator()),
        4 => try days.day4.run(arena.allocator()),
        5 => try days.day5.run(arena.allocator()),
        6 => try days.day6.run(arena.allocator()),
        else => std.debug.print("Unknown day {d}\n", .{day}),
    }
}
