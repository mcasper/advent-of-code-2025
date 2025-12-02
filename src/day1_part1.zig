const std = @import("std");
const utils = @import("utils.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const sample_buffer = try utils.readFilePath(allocator, "data/day1/sample1.txt");
    defer allocator.free(sample_buffer);
    const sample_answer = try solve(allocator, sample_buffer);
    const expected_sample_answer = 3;
    if (sample_answer != expected_sample_answer) {
        return std.debug.print("Day 1 Part 1 expected sample answer: {d}, got: {d}\n", .{ expected_sample_answer, sample_answer });
    }

    const input_buffer = try utils.readFilePath(allocator, "data/day1/input.txt");
    defer allocator.free(input_buffer);
    const answer = try solve(allocator, input_buffer);
    std.debug.print("Day 1 Part 1 answer: {d}\n", .{answer});
}

fn solve(_: std.mem.Allocator, input_buffer: []u8) !u64 {
    var current_position: i64 = 50;
    var num_times_zero: u64 = 0;

    var line_it = std.mem.splitScalar(u8, input_buffer, '\n');
    while (line_it.next()) |line| {
        if (line.len > 0) {
            switch (line[0]) {
                'L' => {
                    const distance = try std.fmt.parseInt(u32, line[1..], 10);
                    current_position -= distance;
                    while (current_position < 0) {
                        current_position += 100;
                    }
                },
                'R' => {
                    const distance = try std.fmt.parseInt(u32, line[1..], 10);
                    current_position += distance;
                    while (current_position > 99) {
                        current_position -= 100;
                    }
                },
                else => {
                    std.debug.print("what??\n", .{});
                },
            }

            if (current_position == 0) {
                num_times_zero += 1;
            }
        }
    }

    return num_times_zero;
}
