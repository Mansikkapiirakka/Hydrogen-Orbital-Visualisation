const std = @import("std");
const builtin = @import("builtin");
const fs = std.fs;

const GLConstant = struct {
    name: Word,
    value: Word,
};

const Word = struct {
    head: usize,
    tail: usize,
};

fn word(input: []const u8, j: usize) ?Word {
    //std.debug.print("j: {}, len: {}\n", .{ j, input.len });
    const head: usize = for (input[j..input.len], j..) |c, i| {
        if (c == ' ' or c == '\n') continue;
        break i;
    } else return null;

    const tail: usize = for (input[head..input.len], head..) |c, i| {
        //std.debug.print("{}\n", .{i});
        if (c != ' ' and c != '\n') continue;
        break i + 1;
    } else input.len;
    //std.debug.print("tail - head: {}\n", .{tail - head});
    return Word{
        .head = head,
        .tail = tail,
    };
}

fn parse_constant(input: []const u8, j: usize) ?GLConstant {
    const name = word(input, j) orelse return null;
    if (input[name.tail - 1] != ' ') return null;

    std.debug.print("{s}\n", .{input[name.head..name.tail]});
    const value = word(input, name.tail - 1) orelse return null;
    if (value.tail < input.len and input[value.tail - 1] != '\n') return null;

    return GLConstant{
        .name = name,
        .value = value,
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer {
        if (gpa.deinit() == .leak) @panic("Memory Leak");
    }
    var constants = std.ArrayList(GLConstant).init(alloc);
    defer constants.deinit();

    const file_path = "C:/Users/Amor/source/zig-gl/src/glcorearb.h";
    const file = try fs.openFileAbsolute(file_path, .{});
    defer file.close();
    const input = try file.readToEndAlloc(alloc, 500_000);
    defer alloc.free(input);

    //Getting them constants
    var i: usize = 0;
    while (i < input.len) {
        if (i < input.len - 2 and !std.mem.eql(u8, input[i .. i + 2], "#d")) {
            i += 1;
            continue;
        }
        i += 7;
        if (i > input.len) break;
        if (parse_constant(input, i)) |c| {
            i = c.value.tail - 1;
            try constants.append(c);
        }
        i += 1;
    }
    const output = try fs.createFileAbsolute("C:/Users/Amor/source/zig-gl/src/gl.zig", .{});
    defer output.close();

    for (constants.items) |c| {
        const declaration = try std.mem.concat(alloc, u8, &[_][]const u8{
            "pub const ",
            input[c.name.head .. c.name.tail - 1],
            ": u32 = ",
            input[c.value.head .. c.value.tail - 1],
            ";\n",
        });
        defer alloc.free(declaration);
        _ = try output.write(declaration);
        //std.debug.print("{s}", .{declaration});
    }
}

test "sanity check" {
    try std.testing.expect(std.mem.eql(u8, "#d", "#d"));
}
