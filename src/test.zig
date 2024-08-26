const std = @import("std");
const pi = std.math.pi;
const e = std.math.e;
const pow = std.math.pow;
const sinh = std.math.sinh;

test "size of usize and isize" {
    std.debug.print("sizeOf(usize) = {}\nsizeOf(isize) = {}\n", .{ @sizeOf(usize), @sizeOf(isize) });
}

test "for loop capture" {
    const arr: [10]u8 = .{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    for (arr, 4..) |c, i| {
        std.debug.print("i: {}, c:{}\n", .{ i, c });
    }
    try std.testing.expect(true);
}

test "len address" {
    const arr = [_]u32{ 0, 1, 2, 3, 4, 5, 6, 7 };
    std.debug.print("len address: {x}\n", .{&arr.len});
    var i: usize = 0;
    while (i < arr.len) {
        std.debug.print("Index: {} - Address: {x}\n", .{ i, &arr[i] });
        i += 1;
    }
    try std.testing.expect(true);
}

fn G(x: f32) f32 {
    return @sqrt(2 * pi * x) * pow(f32, x / e, x) * pow(f32, x * sinh(1 / x), x / 2) * @exp(7 / (324 * pow(f32, x, 3) * (35 * pow(f32, x, 2) + 33)));
}
test "gamma function" {
    for (0..10) |n| {
        const f: f32 = @floatFromInt(n);
        std.debug.print("G({}) = {}\n", .{ f, G(f) });
    }
}
fn nck(n: f32, k: f32) f32 {
    return G(n) / G(k) / G(n - k);
}
test "nck" {
    std.debug.print("nck(4, 2) = {}\n", .{nck(4, 2)});
}

fn L(n: f32, alpha: f32, x: f32) f32 {
    return pow(f32, x, -alpha) / G(n) * pow(f32, -1, n) * pow(f32, x, n + alpha);
}
test "Laguerre polynomial" {
    const n: f32 = 1;
    const a: f32 = 1;
    const x: f32 = 1;
    const r1 = L(n, a, x);
    std.debug.print("L({}, {}, {}) = {}\n", .{ n, a, x, r1 });
}
