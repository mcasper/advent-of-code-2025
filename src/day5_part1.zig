const std = @import("std");
const utils = @import("utils.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const sample_buffer = try utils.readFilePath(allocator, "data/day5/sample1.txt");
    defer allocator.free(sample_buffer);
    const sample_answer = try solve(allocator, sample_buffer);
    const expected_sample_answer = 3;
    if (sample_answer != expected_sample_answer) {
        return std.debug.print("Day 5 Part 1 expected sample answer: {d}, got: {d}\n", .{ expected_sample_answer, sample_answer });
    }
    std.debug.print("Day 5 Part 1 sample passed!\n", .{});

    const input_buffer = try utils.readFilePath(allocator, "data/day5/input.txt");
    defer allocator.free(input_buffer);
    const answer = try solve(allocator, input_buffer);
    std.debug.print("Day 5 Part 1 answer: {d}\n", .{answer});
}

const FreshRange = struct {
    start: u64,
    end: u64,

    pub fn new(s: u64, e: u64) FreshRange {
        return .{ .start = s, .end = e };
    }

    pub fn includes(self: *const FreshRange, id: u64) bool {
        return self.start <= id and self.end >= id;
    }
};

fn solve(allocator: std.mem.Allocator, input_buffer: []u8) !u64 {
    var fresh_ranges: std.ArrayList(FreshRange) = .empty;
    defer fresh_ranges.deinit(allocator);

    var fresh_ingredient_count: u64 = 0;

    var parsing_ranges = true;
    var line_it = std.mem.splitScalar(u8, input_buffer, '\n');
    while (line_it.next()) |line| {
        if (line.len == 0) {
            parsing_ranges = false;
            continue;
        }

        if (parsing_ranges) {
            var range_it = std.mem.splitScalar(u8, line, '-');

            const range_start = range_it.next();
            const range_start_i = try std.fmt.parseInt(u64, range_start.?, 10);
            const range_end = range_it.next();
            const range_end_i = try std.fmt.parseInt(u64, range_end.?, 10);

            try fresh_ranges.append(allocator, FreshRange.new(range_start_i, range_end_i));
        } else {
            const ingredient_id = try std.fmt.parseInt(u64, line, 10);

            var is_fresh = false;
            for (fresh_ranges.items) |fresh_range| {
                if (fresh_range.includes(ingredient_id)) {
                    is_fresh = true;
                }
            }

            if (is_fresh) {
                fresh_ingredient_count += 1;
            }
        }
    }

    return fresh_ingredient_count;
}
