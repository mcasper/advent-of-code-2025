const std = @import("std");
const utils = @import("utils.zig");

const MyError = error{WeirdRangeSize};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const sample_buffer = try utils.readFilePath(allocator, "data/day2/sample1.txt");
    defer allocator.free(sample_buffer);
    const sample_answer = try solve(allocator, sample_buffer);
    const expected_sample_answer = 1227775554;
    if (sample_answer != expected_sample_answer) {
        return std.debug.print("Day 2 Part 1 expected sample answer: {d}, got: {d}\n", .{ expected_sample_answer, sample_answer });
    }
    std.debug.print("Day 2 Part 1 sample passed!\n", .{});

    const input_buffer = try utils.readFilePath(allocator, "data/day2/input.txt");
    defer allocator.free(input_buffer);
    const answer = try solve(allocator, input_buffer);
    std.debug.print("Day 2 Part 1 answer: {d}\n", .{answer});
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

            var id_str = try allocator.alloc(u8, buf_size);
            defer allocator.free(id_str);
            _ = try std.fmt.bufPrint(id_str, "{}", .{current_num});

            if (@rem(id_str.len, 2) == 0) {
                if (std.mem.eql(u8, id_str[0..(id_str.len / 2)], id_str[(id_str.len / 2)..])) {
                    invalid_id_sum += current_num;
                }
            }

            current_num += 1;
        }
    }

    return invalid_id_sum;
}
