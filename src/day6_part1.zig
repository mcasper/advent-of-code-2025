const std = @import("std");
const utils = @import("utils.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const sample_buffer = try utils.readFilePath(allocator, "data/day6/sample1.txt");
    defer allocator.free(sample_buffer);
    const sample_answer = try solve(allocator, sample_buffer);
    const expected_sample_answer = 4277556;
    if (sample_answer != expected_sample_answer) {
        return std.debug.print("Day 6 Part 1 expected sample answer: {d}, got: {d}\n", .{ expected_sample_answer, sample_answer });
    }
    std.debug.print("Day 6 Part 1 sample passed!\n", .{});

    const input_buffer = try utils.readFilePath(allocator, "data/day6/input.txt");
    defer allocator.free(input_buffer);
    const answer = try solve(allocator, input_buffer);
    std.debug.print("Day 6 Part 1 answer: {d}\n", .{answer});
}

const SolveError = error{
    InvalidOperator,
};

const MathProblem = struct {
    numbers: std.ArrayList(u64),
    operator: u8,

    pub fn solve(self: *const MathProblem) !u64 {
        var answer: u64 = 0;

        if (self.operator == '*') {
            answer = 1;
            for (self.numbers.items) |number| {
                answer *= number;
            }
        } else if (self.operator == '+') {
            for (self.numbers.items) |number| {
                answer += number;
            }
        } else {
            return SolveError.InvalidOperator;
        }

        return answer;
    }
};

fn solve(allocator: std.mem.Allocator, input_buffer: []u8) !u64 {
    var math_problems: std.ArrayList(MathProblem) = .empty;
    defer math_problems.deinit(allocator);

    var have_data = false;
    var current_col_i: usize = 0;
    var line_it = std.mem.splitScalar(u8, input_buffer, '\n');
    while (line_it.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var column_it = std.mem.splitScalar(u8, line, ' ');
        while (column_it.next()) |col| {
            if (col.len == 0) {
                continue;
            }

            if (col.len == 1 and col[0] == '*') {
                math_problems.items[current_col_i].operator = '*';
            } else if (col.len == 1 and col[0] == '+') {
                math_problems.items[current_col_i].operator = '+';
            } else {
                const number = try std.fmt.parseInt(u64, col, 10);

                if (!have_data) {
                    try math_problems.append(allocator, .{
                        .numbers = .empty,
                        .operator = '?',
                    });
                }

                try math_problems.items[current_col_i].numbers.append(allocator, number);
            }

            current_col_i += 1;
        }

        have_data = true;
        current_col_i = 0;
    }

    var grand_total: u64 = 0;

    for (math_problems.items) |problem| {
        grand_total += try problem.solve();
    }

    for (0..math_problems.items.len) |i| {
        math_problems.items[i].numbers.deinit(allocator);
    }

    return grand_total;
}
