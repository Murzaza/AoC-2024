pub const day1 = @import("day1.zig");
pub const day2 = @import("day2.zig");
pub const day3 = @import("day3.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
