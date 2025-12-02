const std = @import("std");
const utils = @import("utils.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const sample_buffer = try utils.readFilePath(allocator, "data/day2/sample1.txt");
    defer allocator.free(sample_buffer);
    const sample_answer = try solve(allocator, sample_buffer);
    const expected_sample_answer = 4174379265;
    if (sample_answer != expected_sample_answer) {
        return std.debug.print("Day 2 Part 2 expected sample answer: {d}, got: {d}\n", .{ expected_sample_answer, sample_answer });
    }
    std.debug.print("Day 2 Part 2 sample passed!\n", .{});

    const input_buffer = try utils.readFilePath(allocator, "data/day2/input.txt");
    defer allocator.free(input_buffer);
    const answer = try solve(allocator, input_buffer);
    std.debug.print("Day 2 Part 2 answer: {d}\n", .{answer});
}

fn solve(allocator: std.mem.Allocator, input: []u8) !u64 {
    const stripped_input = std.mem.trimRight(u8, input, "\n");

    var invalid_id_sum: u64 = 0;
    var range_it = std.mem.splitScalar(u8, stripped_input, ',');

    while (range_it.next()) |range| {
        var id_it = std.mem.splitScalar(u8, range, '-');

        const range_start = try std.fmt.parseInt(u64, id_it.next().?, 10);
        const range_end = try std.fmt.parseInt(u64, id_it.next().?, 10);
        var current_num = range_start;

        while (current_num <= range_end) {
            var buf_size: usize = 1;
            var rem = current_num;
            while (rem > 9) {
                buf_size += 1;
                rem = rem / 10;
            }

            const id_str = try allocator.alloc(u8, buf_size);
            defer allocator.free(id_str);
            _ = try std.fmt.bufPrint(id_str, "{}", .{current_num});

            if (is_only_repeating_sequences(id_str)) {
                invalid_id_sum += current_num;
            }

            current_num += 1;
        }
    }

    return invalid_id_sum;
}

fn is_only_repeating_sequences(id_str: []u8) bool {
    const max_sequence_size = id_str.len / 2;
    var current_sequence_size: usize = 1;

    while (current_sequence_size <= max_sequence_size) {
        if (@rem(id_str.len, current_sequence_size) != 0) {
            current_sequence_size += 1;
            continue;
        }

        const num_chunks = id_str.len / current_sequence_size;
        var all_match = true;
        for (1..num_chunks) |chunk_i| {
            const offset = chunk_i * current_sequence_size;
            if (!std.mem.eql(u8, id_str[0..current_sequence_size], id_str[offset .. offset + current_sequence_size])) {
                all_match = false;
            }
        }

        if (all_match) {
            return true;
        }

        current_sequence_size += 1;
    }

    return false;
}
