const std = @import("std");

pub fn main() !void {
    const answer = try solve();
    std.debug.print("Day 1 Part 2 answer: {d}\n", .{answer});
}

fn solve() !u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input_buffer = try readFilePath(allocator, "data/day1/input.txt");
    defer allocator.free(input_buffer);

    var current_position: i64 = 50;
    var num_times_zero: u64 = 0;

    var line_it = std.mem.splitScalar(u8, input_buffer, '\n');
    while (line_it.next()) |line| {
        if (line.len > 0) {
            switch (line[0]) {
                'L' => {
                    const distance = try std.fmt.parseInt(u32, line[1..], 10);
                    const laps = distance / 100;
                    const before_position = current_position;
                    current_position -= @rem(distance, 100);
                    num_times_zero += laps;

                    if (current_position < 0) {
                        current_position += 100;
                        if (before_position != 0 and current_position != 0) {
                            num_times_zero += 1;
                        }
                    }
                },
                'R' => {
                    const distance = try std.fmt.parseInt(u32, line[1..], 10);
                    const laps = distance / 100;
                    const before_position = current_position;
                    current_position += @rem(distance, 100);
                    num_times_zero += laps;

                    if (current_position > 99) {
                        current_position -= 100;
                        if (before_position != 0 and current_position != 0) {
                            num_times_zero += 1;
                        }
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

fn getcwd() ![std.fs.max_path_bytes]u8 {
    var buf: [std.fs.max_path_bytes]u8 = undefined;
    _ = try std.posix.getcwd(&buf);
    return buf;
}

fn readFilePath(allocator: std.mem.Allocator, file_path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const stat = try file.stat();
    const file_size = stat.size;

    const contents_buffer = try allocator.alloc(u8, file_size);
    _ = try file.readAll(contents_buffer);
    return contents_buffer;
}
