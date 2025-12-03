const std = @import("std");
const utils = @import("utils.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const sample_buffer = try utils.readFilePath(allocator, "data/day3/sample1.txt");
    defer allocator.free(sample_buffer);
    const sample_answer = try solve(allocator, sample_buffer);
    const expected_sample_answer = 357;
    if (sample_answer != expected_sample_answer) {
        return std.debug.print("Day 3 Part 1 expected sample answer: {d}, got: {d}\n", .{ expected_sample_answer, sample_answer });
    }
    std.debug.print("Day 3 Part 1 sample passed!\n", .{});

    const input_buffer = try utils.readFilePath(allocator, "data/day3/input.txt");
    defer allocator.free(input_buffer);
    const answer = try solve(allocator, input_buffer);
    std.debug.print("Day 3 Part 1 answer: {d}\n", .{answer});
}

fn solve(_: std.mem.Allocator, input_buffer: []u8) !u64 {
    var total_joltage: u64 = 0;
    var line_it = std.mem.splitScalar(u8, input_buffer, '\n');
    while (line_it.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        const line_max_joltage = try max_joltage(line);
        std.debug.print("Line max joltage: {d}\n", .{line_max_joltage});
        total_joltage += line_max_joltage;
    }

    return total_joltage;
}

fn max_joltage(line: []const u8) !u64 {
    var biggest_first_number: u64 = 0;
    var biggest_second_number: u64 = 0;

    for (line, 0..) |char, i| {
        const char_slice: []const u8 = &[_]u8{char};
        const integer_value = try std.fmt.parseInt(u8, char_slice, 10);

        // Last number in the bank can never be the first number
        if (i < line.len - 1) {
            if (integer_value == biggest_first_number and integer_value > biggest_second_number) {
                biggest_second_number = integer_value;
            } else if (integer_value > biggest_first_number) {
                biggest_first_number = integer_value;
                biggest_second_number = 0;
            }
        }
    }

    return (biggest_first_number * 10) + biggest_second_number;
}
