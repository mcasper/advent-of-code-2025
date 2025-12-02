const std = @import("std");

pub fn readFilePath(allocator: std.mem.Allocator, file_path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const stat = try file.stat();
    const file_size = stat.size;

    const contents_buffer = try allocator.alloc(u8, file_size);
    _ = try file.readAll(contents_buffer);
    return contents_buffer;
}

pub fn getcwd() ![std.fs.max_path_bytes]u8 {
    var buf: [std.fs.max_path_bytes]u8 = undefined;
    _ = try std.posix.getcwd(&buf);
    return buf;
}
