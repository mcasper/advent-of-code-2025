const std = @import("std");
const utils = @import("utils.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const sample_buffer = try utils.readFilePath(allocator, "data/day5/sample1.txt");
    defer allocator.free(sample_buffer);
    const sample_answer = try solve(allocator, sample_buffer);
    const expected_sample_answer = 14;
    if (sample_answer != expected_sample_answer) {
        return std.debug.print("Day 5 Part 2 expected sample answer: {d}, got: {d}\n", .{ expected_sample_answer, sample_answer });
    }
    std.debug.print("Day 5 Part 2 sample passed!\n", .{});

    const input_buffer = try utils.readFilePath(allocator, "data/day5/input.txt");
    defer allocator.free(input_buffer);
    const answer = try solve(allocator, input_buffer);
    std.debug.print("Day 5 Part 2 answer: {d}\n", .{answer});
}

const FreshRange = struct {
    start: u64,
    end: u64,

    pub fn new(s: u64, e: u64) FreshRange {
        return .{ .start = s, .end = e };
    }

    pub fn overlap(self: *const FreshRange, other: *const FreshRange) u64 {
        const overlap_start = @max(self.start, other.start);
        const overlap_end = @min(self.end, other.end);

        if (overlap_start <= overlap_end) {
            return overlap_end - overlap_start;
        } else {
            return 0;
        }
    }

    pub fn size(self: *const FreshRange) u64 {
        return self.end - self.start + 1;
    }
};

fn sortByStart(context: void, a: FreshRange, b: FreshRange) bool {
    _ = context; // Context is unused in this example
    return a.start < b.start;
}

fn solve(allocator: std.mem.Allocator, input_buffer: []u8) !u64 {
    var fresh_ranges: std.ArrayList(FreshRange) = .empty;
    defer fresh_ranges.deinit(allocator);

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

            const range = FreshRange.new(range_start_i, range_end_i);
            try fresh_ranges.append(allocator, range);
        }
    }

    // combine ranges
    var combined_ranges: std.ArrayList(FreshRange) = .empty;
    defer combined_ranges.deinit(allocator);

    std.sort.insertion(FreshRange, fresh_ranges.items, {}, sortByStart);
    var current_range = fresh_ranges.items[0];
    for (fresh_ranges.items[1..]) |range| {
        if (range.start <= current_range.end) {
            // some overlap, extend
            current_range.end = @max(range.end, current_range.end);
        } else {
            // no overlap, add to combined
            try combined_ranges.append(allocator, current_range);
            current_range = range;
        }
    }

    try combined_ranges.append(allocator, current_range);

    var fresh_ingredient_count: u64 = 0;
    for (combined_ranges.items) |range| {
        fresh_ingredient_count += range.size();
    }

    return fresh_ingredient_count;
}
