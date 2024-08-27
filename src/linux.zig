const std = @import("std");
const DynLib = std.DynLib;

extern "opengl32" fn glXGetProcAddress(name: [*:0]const u8) callconv(.C) *anyopaque;
