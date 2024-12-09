const std = @import("std");
const tools = @import("tools.zig");

const BlockType = enum {
    File,
    Free,
};

const Block = struct { type: BlockType, value: u64 };

const FileLoc = struct {
    start: usize,
    size: usize,
};

fn computeChecksum(disk: []Block) u64 {
    var checkSum: u64 = 0;
    for (disk, 0..) |block, i| {
        checkSum += block.value * i;
    }

    return checkSum;
}

fn rearrangeDisk(disk: *[]Block) void {
    var front: usize = 0;
    var back: usize = disk.len - 1;
    while (disk.*[front].type == BlockType.File and front < disk.len) {
        front += 1;
    }
    while (disk.*[back].type == BlockType.Free and back > 0) {
        back -= 1;
    }

    while (front < back) {
        const holder = disk.*[front];
        disk.*[front] = disk.*[back];
        disk.*[back] = holder;

        // Align indices...
        while (disk.*[front].type == BlockType.File and front < disk.len) {
            front += 1;
        }
        while (disk.*[back].type == BlockType.Free and back > 0) {
            back -= 1;
        }
    }
}

fn findFileInBack(disk: []Block, last: usize) FileLoc {
    if (last == 0) return FileLoc{ .size = 0, .start = 0 };
    var start = last - 1;
    while (disk[start].type == BlockType.Free and start > 0) {
        start -= 1;
    }

    const fid = disk[start].value;

    var size: usize = 1;
    var peek = start - 1;

    while (disk[peek].type == BlockType.File and disk[peek].value == fid) {
        start = peek;
        size += 1;
        if (peek == 0) {
            break;
        }
        peek -= 1;
    }

    return FileLoc{ .start = start, .size = size };
}

fn findFreeSpaceWithSize(disk: []Block, size: usize) usize {
    var i: usize = 0;
    while (i < disk.len) {
        if (disk[i].type == BlockType.Free) {
            var curr_id: usize = i;
            var curr_size: usize = 0;
            while (curr_id < disk.len and disk[curr_id].type == BlockType.Free) {
                curr_size += 1;
                if (curr_size == size) {
                    return i;
                }
                curr_id += 1;
            }
            // If we haven't returned it means that we didn't find enough space, so let's bump the
            // index to our last position to save cycles.
            i = curr_id;
        }
        i += 1;
    }

    return disk.len;
}

fn rearrangeDiskByFiles(disk: *[]Block) void {
    var file_loc = findFileInBack(disk.*, disk.len);
    while (file_loc.start != 0) {
        const free_start = findFreeSpaceWithSize(disk.*, file_loc.size);
        if (free_start < disk.len and free_start < file_loc.start) {
            // We have space!
            for (0..file_loc.size) |i| {
                const h = disk.*[free_start + i];
                disk.*[free_start + i] = disk.*[file_loc.start + i];
                disk.*[file_loc.start + i] = h;
            }
        }
        file_loc = findFileInBack(disk.*, file_loc.start);
    }
}

fn part1(allocator: std.mem.Allocator, input: []const u8, part2: bool) !u64 {
    const data = try tools.read_file(allocator, input);

    var read_it = std.mem.tokenize(u8, data, "\n");

    var disk = std.ArrayList(Block).init(allocator);
    var file: bool = true;
    var fid: u64 = 0;
    while (read_it.next()) |line| {
        for (line) |c| {
            const size = try std.fmt.charToDigit(c, 10);
            const block = if (file) Block{ .type = BlockType.File, .value = fid } else Block{ .type = BlockType.Free, .value = 0 };
            for (0..size) |_| {
                try disk.append(block);
            }

            if (file) fid += 1;
            file = !file;
        }
    }

    var slice = try disk.toOwnedSlice();
    if (!part2) {
        rearrangeDisk(&slice);
    } else {
        rearrangeDiskByFiles(&slice);
    }
    //std.debug.print("Final: {any}\n", .{slice});
    return computeChecksum(slice);
}

pub fn run(allocator: std.mem.Allocator) !void {
    const input = "inputs/day9.txt";

    std.debug.print("Day 9:\n", .{});

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

    const ans = try part1(arena.allocator(), "tests/day9.txt", false);
    try std.testing.expectEqual(1928, ans);
}

test "part 2" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const ans = try part1(arena.allocator(), "tests/day9.txt", true);
    try std.testing.expectEqual(2858, ans);
}
