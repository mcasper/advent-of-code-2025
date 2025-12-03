const std = @import("std");
const utils = @import("utils.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const sample_buffer = try utils.readFilePath(allocator, "data/day3/sample1.txt");
    defer allocator.free(sample_buffer);
    const sample_answer = try solve(allocator, sample_buffer);
    const expected_sample_answer = 3121910778619;
    if (sample_answer != expected_sample_answer) {
        return std.debug.print("Day 3 Part 2 expected sample answer: {d}, got: {d}\n", .{ expected_sample_answer, sample_answer });
    }
    std.debug.print("Day 3 Part 2 sample passed!\n", .{});

    const input_buffer = try utils.readFilePath(allocator, "data/day3/input.txt");
    defer allocator.free(input_buffer);
    const answer = try solve(allocator, input_buffer);
    std.debug.print("Day 3 Part 2 answer: {d}\n", .{answer});
}

fn solve(allocator: std.mem.Allocator, input_buffer: []u8) !u64 {
    var total_joltage: u64 = 0;
    var line_it = std.mem.splitScalar(u8, input_buffer, '\n');
    while (line_it.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        const line_max_joltage = try max_joltage(allocator, line);
        total_joltage += line_max_joltage;
    }

    return total_joltage;
}

fn max_joltage(allocator: std.mem.Allocator, line: []const u8) !u64 {
    const numbers = try allocator.alloc(u64, line.len);
    defer allocator.free(numbers);

    for (line, 0..) |char, i| {
        const char_slice: []const u8 = &[_]u8{char};
        const integer_value = try std.fmt.parseInt(u8, char_slice, 10);
        numbers[i] = integer_value;
    }

    var largest_joltage_possible: u64 = 0;
    var digit_index: usize = 0;
    var last_digit_index: usize = 0;
    const max_digit_index: usize = 11;

    while (digit_index <= max_digit_index) {
        const num_digits_remaining = max_digit_index - digit_index;
        const largest_number_result = find_largest_number(numbers[last_digit_index..(line.len - num_digits_remaining)]);

        largest_joltage_possible += (largest_number_result.number * std.math.pow(u64, 10, max_digit_index - digit_index));
        last_digit_index += largest_number_result.index + 1;
        digit_index += 1;
    }

    return largest_joltage_possible;
}

fn find_largest_number(numbers: []const u64) struct { number: u64, index: usize } {
    var largest_number: u64 = 0;
    var largest_number_index: usize = 0;

    for (numbers, 0..) |number, i| {
        if (number > largest_number) {
            largest_number = number;
            largest_number_index = i;
        }
    }

    return .{ .number = largest_number, .index = largest_number_index };
}
