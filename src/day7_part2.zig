const std = @import("std");
const utils = @import("utils.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const sample_buffer = try utils.readFilePath(allocator, "data/day7/sample1.txt");
    defer allocator.free(sample_buffer);
    const sample_answer = try solve(allocator, sample_buffer);
    const expected_sample_answer = 40;
    if (sample_answer != expected_sample_answer) {
        return std.debug.print("Day 7 Part 2 expected sample answer: {d}, got: {d}\n", .{ expected_sample_answer, sample_answer });
    }
    std.debug.print("Day 7 Part 2 sample passed!\n", .{});

    const input_buffer = try utils.readFilePath(allocator, "data/day7/input.txt");
    defer allocator.free(input_buffer);
    const answer = try solve(allocator, input_buffer);
    std.debug.print("Day 7 Part 2 answer: {d}\n", .{answer});
}

const MapError = error{
    InvalidChar,
};

const Beam = struct {
    point: Point,
    weight: u64,

    pub fn new(point: Point, weight: u64) Beam {
        return .{ .point = point, .weight = weight };
    }
};

const Point = struct {
    x: usize,
    y: usize,

    pub fn new(x: usize, y: usize) Point {
        return .{ .x = x, .y = y };
    }
};

fn solve(allocator: std.mem.Allocator, input_buffer: []u8) !u64 {
    var splitter_map: std.ArrayList(std.ArrayList(u8)) = .empty;
    var current_beams: std.ArrayList(Beam) = .empty;

    var line_it = std.mem.splitScalar(u8, input_buffer, '\n');
    var line_y: usize = 0;
    while (line_it.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var line_map: std.ArrayList(u8) = .empty;

        for (line, 0..) |char, x| {
            if (char == 'S') {
                try current_beams.append(allocator, Beam.new(Point.new(x, line_y), 1));
            }

            try line_map.append(allocator, char);
        }

        try splitter_map.append(allocator, line_map);
        line_y += 1;
    }

    const starting_y = current_beams.items[0].point.y;
    for (0..splitter_map.items.len) |y| {
        if (y < starting_y) {
            continue;
        }
        if (y == splitter_map.items.len - 1) {
            continue;
        }

        var new_beams_map = std.AutoHashMap(Point, u64).init(allocator);
        defer new_beams_map.deinit();

        for (current_beams.items) |beam| {
            const next_char = splitter_map.items[y + 1].items[beam.point.x];
            if (next_char == '.') {
                if (new_beams_map.get(Point.new(beam.point.x, y + 1))) |existing| {
                    try new_beams_map.put(Point.new(beam.point.x, y + 1), existing + beam.weight);
                } else {
                    try new_beams_map.put(Point.new(beam.point.x, y + 1), beam.weight);
                }
            } else if (next_char == '^') {
                const new_left = Point.new(beam.point.x - 1, y + 1);
                if (new_beams_map.get(new_left)) |existing| {
                    try new_beams_map.put(new_left, existing + beam.weight);
                } else {
                    try new_beams_map.put(new_left, beam.weight);
                }

                const new_right = Point.new(beam.point.x + 1, y + 1);
                if (new_beams_map.get(new_right)) |existing| {
                    try new_beams_map.put(new_right, existing + beam.weight);
                } else {
                    try new_beams_map.put(new_right, beam.weight);
                }
            } else {
                return MapError.InvalidChar;
            }
        }

        current_beams.clearAndFree(allocator);
        var new_beams_map_it = new_beams_map.iterator();
        while (new_beams_map_it.next()) |entry| {
            try current_beams.append(allocator, Beam.new(entry.key_ptr.*, entry.value_ptr.*));
        }
    }

    var unique_paths: u64 = 0;
    for (current_beams.items) |beam| {
        unique_paths += beam.weight;
    }

    for (0..splitter_map.items.len) |i| {
        splitter_map.items[i].deinit(allocator);
    }
    splitter_map.deinit(allocator);
    current_beams.deinit(allocator);

    return unique_paths;
}
