const std = @import("std");
const utils = @import("utils.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const sample_buffer = try utils.readFilePath(allocator, "data/day6/sample1.txt");
    defer allocator.free(sample_buffer);
    const sample_answer = try solve(allocator, sample_buffer);
    const expected_sample_answer = 3263827;
    if (sample_answer != expected_sample_answer) {
        return std.debug.print("Day 6 Part 2 expected sample answer: {d}, got: {d}\n", .{ expected_sample_answer, sample_answer });
    }
    std.debug.print("Day 6 Part 2 sample passed!\n", .{});

    const input_buffer = try utils.readFilePath(allocator, "data/day6/input.txt");
    defer allocator.free(input_buffer);
    const answer = try solve(allocator, input_buffer);
    std.debug.print("Day 6 Part 2 answer: {d}\n", .{answer});
}

const SolveError = error{
    InvalidOperator,
    NoSuchDigit,
};

const NumberString = struct {
    data: []const u8,
    starting_index: usize,

    pub fn numberAtIndex(self: *const NumberString, absolute_index: usize) !u8 {
        const self_end = self.starting_index + self.data.len - 1;

        if (self.starting_index > absolute_index or self_end < absolute_index) {
            return SolveError.NoSuchDigit;
        }

        const relative_index = absolute_index - self.starting_index;
        return self.data[relative_index];
    }
};

const MathProblem = struct {
    number_strings: std.ArrayList(NumberString),
    operator: u8,
    allocator: std.mem.Allocator,

    fn parseNumbers(self: *const MathProblem) !std.ArrayList(u64) {
        var longest_num: usize = 0;
        var lowest_starting_index: usize = 999999999;
        for (self.number_strings.items) |s| {
            longest_num = @max(s.data.len, longest_num);
            lowest_starting_index = @min(s.starting_index, lowest_starting_index);
        }

        var numbers: std.ArrayList(u64) = .empty;

        var i: usize = 0;
        while (i < longest_num) {
            var column_number: std.ArrayList(u8) = .empty;

            for (self.number_strings.items) |number_string| {
                const num = number_string.numberAtIndex(i + lowest_starting_index) catch |err| {
                    if (err == SolveError.NoSuchDigit) {
                        continue;
                    } else {
                        return err;
                    }
                };
                try column_number.append(self.allocator, num);
            }

            const parsed_column_number = try std.fmt.parseInt(u64, column_number.items, 10);
            column_number.deinit(self.allocator);

            try numbers.append(self.allocator, parsed_column_number);
            i += 1;
        }

        return numbers;
    }

    pub fn solve(self: *const MathProblem) !u64 {
        var answer: u64 = 0;
        const numbers = try self.parseNumbers();

        if (self.operator == '*') {
            answer = 1;
            for (numbers.items) |number| {
                answer *= number;
            }
        } else if (self.operator == '+') {
            for (numbers.items) |number| {
                answer += number;
            }
        } else {
            return SolveError.InvalidOperator;
        }

        @constCast(&numbers).deinit(self.allocator);

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
        var column_index: usize = 0;
        while (column_it.next()) |col| {
            if (col.len == 0) {
                column_index += 1;
                continue;
            }

            if (col.len == 1 and col[0] == '*') {
                math_problems.items[current_col_i].operator = '*';
            } else if (col.len == 1 and col[0] == '+') {
                math_problems.items[current_col_i].operator = '+';
            } else {
                if (!have_data) {
                    try math_problems.append(allocator, .{
                        .number_strings = .empty,
                        .operator = '?',
                        .allocator = allocator,
                    });
                }

                const number_string: NumberString = .{
                    .data = col,
                    .starting_index = column_index,
                };

                try math_problems.items[current_col_i].number_strings.append(allocator, number_string);
            }

            current_col_i += 1;
            column_index += col.len;
        }

        have_data = true;
        current_col_i = 0;
    }

    var grand_total: u64 = 0;

    for (math_problems.items) |problem| {
        grand_total += try problem.solve();
    }

    for (0..math_problems.items.len) |i| {
        math_problems.items[i].number_strings.deinit(allocator);
    }

    return grand_total;
}
