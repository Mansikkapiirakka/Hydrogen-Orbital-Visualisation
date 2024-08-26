const std = @import("std");
const dynlib = std.DynLib;
var gl: dynlib = undefined;

pub fn init() !dynlib {
    gl = try dynlib.open("opengl32");
    try Functions.load();
}
pub fn deinit() void {
    gl.close();
}

const FnName = struct {
    const GetIntegerv = "glGetIntegerv";
    const Clear = "glClear";
    const ClearColor = "glClearColor";
    const GenBuffers = "glGenBuffers";
    const BindBuffers = "glBindBuffers";
    const BufferData = "glBufferData";
    const EnableVertexAttribArray = "glEnableVertexAttribArray";
    const DisableVertexAttribArray = "glDisableVertexAttribArray";
    const DrawArrays = "glDrawArrays";
};
const FnSig = struct {
    const GetIntegerv = *const fn (pname: u32, out: *i32) void;
    const Clear = *const fn (mask: u32) void;
    const ClearColor = *const fn (red: f32, green: f32, blue: f32, alpha: f32) void;
    const Genbuffers = *const fn (n: u32, buffers: *u32) void;
    const BindBuffer = *const fn (target: u32, buffer: u32) void;
    const BufferData = *const fn (target: u32, size: usize, data: *anyopaque, usage: u32) void;
    const EnableVertexAttribArray = *const fn (index: u32) void;
    const DisableVertexAttribArray = *const fn (index: u32) void;
    const VeretexAttribPointer = *const fn (index: u32, size: i32, T: u32, normalized: u32, stride: u32, ptr: usize) void;
    const DrawArrays = *const fn (mode: u32, first: i32, count: u32) void;
};

pub const Functions = struct {
    var arr = []Fn{
        .{ .name = FnName.GetIntegerv, .sig = FnSig.GetIntegerv },
        .{ .name = FnName.Clear, .sig = FnSig.Clear },
        .{ .name = FnName.ClearColor, .sig = FnSig.ClearColor },
        .{ .name = FnName.GenBuffers, .sig = FnSig.GenBuffers },
        .{ .name = FnName.Bindbuffers, .sig = FnSig.BindBuffers },
        .{ .name = FnName.BufferData, .sig = FnSig.BufferData },
        .{ .name = FnName.EnableVertexAttribArray, .sig = FnSig.EnableVertexAttribArray },
        .{ .name = FnName.DisableVertexAttribArray, .sig = FnSig.DisableVertexAttribArray },
        .{ .name = FnName.DrawArrays, .sig = FnSig.DrawArrays },
    };
    pub fn GetIntegerv(pname: u32, out: *i32) void {
        arr[0](pname, out);
    }
    pub fn Clear(mask: u32) void {
        arr[1](mask);
    }
    pub fn ClearColor(r: f32, g: f32, b: f32, a: f32) void {
        arr[2](r, g, b, a);
    }
    pub fn GenBuffers(n: u32, buffers: *u32) void {
        arr[3](n, buffers);
    }
    pub fn BindBuffer(target: u32, buffer: u32) void {
        arr[4](target, buffer);
    }
    pub fn BufferData(target: u32, size: usize, data: *anyopaque, usage: u32) void {
        arr[5](target, size, data, usage);
    }
    pub fn EnableVertexAttribArray(index: u32) void {
        arr[6](index);
    }
    pub fn DisableVertexAttribArray(index: u32) void {
        arr[7](index);
    }
    pub fn VertexAttribPointer(index: u32, size: i32, T: u32, normalized: u32, stride: u32, ptr: *anyopaque) void {
        arr[8](index, size, T, normalized, stride, ptr);
    }
    pub fn DrawArrays(mode: u32, first: i32, count: u32) void {
        arr[9](mode, first, count);
    }

    fn load(self: *Functions, lib: dynlib) !void {
        for (self.arr) |func| {
            func.ptr = try lib.lookup(func.sig, func.name);
        }
    }
};

const Fn = struct {
    name: []u8,
    sig: type,
    ptr: type = undefined,
};

test "Size of function pointers" {
    std.debug.print("{}\n", .{@sizeOf(Fn)});
    try std.testing.expect(true);
}
