pub const day1 = @import("day1.zig");
pub const day2 = @import("day2.zig");
pub const day3 = @import("day3.zig");
pub const day4 = @import("day4.zig");
pub const day5 = @import("day5.zig");
pub const day6 = @import("day6.zig");
pub const day7 = @import("day7.zig");
pub const day8 = @import("day8.zig");
pub const day9 = @import("day9.zig");
pub const day10 = @import("day10.zig");
pub const day11 = @import("day11.zig");
pub const day12 = @import("day12.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
