const std = @import("std");
const days = @import("days.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();

    // Run it
    try days.day1.run(arena.allocator());
    try days.day2.run(arena.allocator());
    try days.day3.run(arena.allocator());
}
