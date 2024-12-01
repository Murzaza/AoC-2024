const std = @import("std");
//const data = @embedFile("tests/test.txt");

pub fn read_file(allocator: std.mem.Allocator, file_path: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const stat = try file.stat();
    const file_size = stat.size;

    return try file.reader().readAllAlloc(allocator, file_size);
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
