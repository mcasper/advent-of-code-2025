const std = @import("std");
const utils = @import("utils.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const sample_buffer = try utils.readFilePath(allocator, "data/day4/sample1.txt");
    defer allocator.free(sample_buffer);
    const sample_answer = try solve(allocator, sample_buffer);
    const expected_sample_answer = 9999999999; // DEFINE ME
    if (sample_answer != expected_sample_answer) {
        return std.debug.print("Day 4 Part 2 expected sample answer: {d}, got: {d}\n", .{ expected_sample_answer, sample_answer });
    }
    std.debug.print("Day 4 Part 2 sample passed!\n", .{});

    const input_buffer = try utils.readFilePath(allocator, "data/day4/input.txt");
    defer allocator.free(input_buffer);
    const answer = try solve(allocator, input_buffer);
    std.debug.print("Day 4 Part 2 answer: {d}\n", .{answer});
}

fn solve(_: std.mem.Allocator, _: []u8) !u64 {
  return 0;
}
