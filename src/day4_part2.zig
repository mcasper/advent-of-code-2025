const std = @import("std");
const utils = @import("utils.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const sample_buffer = try utils.readFilePath(allocator, "data/day4/sample1.txt");
    defer allocator.free(sample_buffer);
    const sample_answer = try solve(allocator, sample_buffer);
    const expected_sample_answer = 43;
    if (sample_answer != expected_sample_answer) {
        return std.debug.print("Day 4 Part 2 expected sample answer: {d}, got: {d}\n", .{ expected_sample_answer, sample_answer });
    }
    std.debug.print("Day 4 Part 2 sample passed!\n", .{});

    const input_buffer = try utils.readFilePath(allocator, "data/day4/input.txt");
    defer allocator.free(input_buffer);
    const answer = try solve(allocator, input_buffer);
    std.debug.print("Day 4 Part 2 answer: {d}\n", .{answer});
}

fn solve(allocator: std.mem.Allocator, input_buffer: []u8) !u64 {
    var map: std.ArrayList(std.ArrayList(u8)) = .empty;
    defer map.deinit(allocator);

    var line_it = std.mem.splitScalar(u8, input_buffer, '\n');
    while (line_it.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var char_row: std.ArrayList(u8) = .empty;
        for (line) |char| {
            try char_row.append(allocator, char);
        }

        try map.append(allocator, char_row);
    }

    var reachable_items: u64 = 0;

    var working = true;

    while (working) {
        var removed_count: usize = 0;

        for (map.items, 0..) |row, y| {
            for (row.items, 0..) |item, x| {
                if (item == '@' and try forklift_can_access(map, x, y)) {
                    reachable_items += 1;
                    removed_count += 1;
                    map.items[y].items[x] = '.';
                }
            }
        }

        working = removed_count > 0;
    }

    for (0..map.items.len) |i| {
        map.items[i].deinit(allocator);
    }

    return reachable_items;
}

fn forklift_can_access(map: std.ArrayList(std.ArrayList(u8)), x: usize, y: usize) !bool {
    var surrounding_paper: usize = 0;
    const max_y = map.items.len - 1;
    const max_x = map.items[0].items.len - 1;
    const int_x: i32 = @intCast(x);
    const int_y: i32 = @intCast(y);

    for ([_]i8{ -1, 0, 1 }) |y_delta| {
        for ([_]i8{ -1, 0, 1 }) |x_delta| {
            if (y_delta == 0 and x_delta == 0) {
                continue;
            }

            const new_x = int_x + x_delta;
            const new_y = int_y + y_delta;

            if (new_x < 0 or new_y < 0 or new_x > max_x or new_y > max_y) {
                continue;
            }

            const usize_new_y: usize = @intCast(new_y);
            const usize_new_x: usize = @intCast(new_x);

            if (map.items[usize_new_y].items[usize_new_x] == '@') {
                surrounding_paper += 1;
            }
        }
    }

    return surrounding_paper < 4;
}
