const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    if (args.len < 2) {
        std.debug.print("Usage: wordc <filepath>\n", .{});
        std.log.err("Not enought arguments", .{});
        return;
    }

    var exlude_chars: []const u8 = "";
    if (args.len > 2 and std.mem.eql(u8, args[2], "--exclude-chars")) {
        if (args.len > 3) {
            exlude_chars = args[3];
        } else {
            std.debug.print("Missing argument for --exclude-chars flag", .{});
            return;
        }
    }

    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();

    const content = try file.reader().readAllAlloc(alloc, std.math.maxInt(usize));
    defer alloc.free(content);

    var count: usize = 0;
    var iter = std.mem.splitAny(u8, content, " \t\n\r");

    while (iter.next()) |word| {
        const clean_words = try removeExcludedChars(word, exlude_chars, alloc);
        if (clean_words.len > 1) {
            count += 1;
        }
    }

    std.debug.print("Count: {d}\n", .{count});
}
fn removeExcludedChars(word: []const u8, exclude_chars: []const u8, alloc: std.mem.Allocator) ![]const u8 {
    var cleaned_word = std.ArrayList(u8).init(alloc);
    defer cleaned_word.deinit();

    for (word) |char| {
        if (!std.mem.containsAtLeast(u8, exclude_chars, 1, &[_]u8{char})) {
            try cleaned_word.append(char);
        }
    }

    return cleaned_word.items;
}
