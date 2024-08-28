const std = @import("std");
const win = std.os.windows;
const window = @import("windows.zig");
const gl = @import("gl.zig");

const WM_CREATE: win.UINT = 0x0001;

extern "user32" fn RegisterClassExA(*window.WNDCLASSEXA) callconv(.C) win.ATOM;
extern "user32" fn CreateWindowExA(dwExStyle: win.DWORD, lpClassName: ?win.LPCSTR, lpWindowName: ?win.LPCSTR, dwStyle: win.DWORD, x: i32, y: i32, nWidth: i32, nHeight: i32, hWndParent: ?win.HWND, hMenu: ?win.HMENU, hInstance: ?win.HINSTANCE, lpParam: ?win.LPVOID) callconv(.C) win.HWND;
extern "user32" fn ShowWindow(hwnd: win.HWND, nCmdShow: c_int) callconv(.C) win.BOOL;
extern "user32" fn GetLastError() callconv(.C) win.DWORD;
extern "user32" fn DefWindowProcA(hwnd: win.HWND, message: win.UINT, wParam: win.WPARAM, lParam: win.LPARAM) callconv(.C) win.LRESULT;
extern "user32" fn GetMessageA(lpMsg: *window.MSG, hWnd: ?win.HWND, wMsgFilterMin: win.UINT, wMsgFilterMax: win.UINT) callconv(.C) win.BOOL;
extern "user32" fn TranslateMessage(msg: *window.MSG) callconv(.C) win.BOOL;
extern "user32" fn DispatchMessageA(msg: *window.MSG) callconv(.C) win.BOOL;
extern "user32" fn PostQuitMessage(exit_code: c_int) callconv(.C) void;
extern "user32" fn GetDC(hwnd: win.HWND) callconv(.C) win.HDC;
extern "user32" fn GetClientRect(hwnd: win.HWND, *win.RECT) win.BOOL;

extern "gdi32" fn ChoosePixelFormat(hdc: win.HDC, pfd: *window.PixelFormatDescriptor) callconv(.C) c_int;
extern "gdi32" fn SetPixelFormat(hdc: win.HDC, format: c_int, pfd: *window.PixelFormatDescriptor) callconv(.C) win.BOOL;
extern "gdi32" fn SwapBuffers(hdc: win.HDC) callconv(.C) win.BOOL;

extern "opengl32" fn wglCreateContext(hdc: win.HDC) callconv(.C) win.HGLRC;
extern "opengl32" fn wglMakeCurrent(hdc: win.HDC, hglrc: win.HGLRC) callconv(.C) win.BOOL;
extern "opengl32" fn wglDeleteContext(ctx: win.HGLRC) callconv(.C) win.BOOL;

var pfd: window.PixelFormatDescriptor = .{
    .nVersion = 1,
    .dwFlags = window.PFD_DRAW_TO_WINDOW | window.PFD_SUPPORT_OPENGL | window.PFD_DOUBLEBUFFER,
    .iPixelType = window.PFD_TYPE_RGBA,
    .cColorBits = 32,
    .cDepthBits = 24,
    .cStencilBits = 8,
};

const iVec2 = extern struct { x: i32, y: i32 };
const Vec3 = extern struct { x: f32, y: f32, z: f32 };
const Vec4 = extern struct { x: f32, y: f32, z: f32, w: f32 };

const Uniform1f = struct {
    handle: i32 = 0,
    name: [:0]const u8,
    value: f32 = 0,

    fn set(self: *Uniform1f, f: f32) void {
        gl.Uniform1f(self.handle, f);
        self.value = f;
    }
};

const Uniform1ui = struct {
    handle: i32 = 0,
    name: [:0]const u8,
    value: u32 = 0,

    fn set(self: *Uniform1ui, u: u32) void {
        gl.Uniform1ui(self.handle, u);
        self.value = u;
    }
};

const Uniform1i = struct {
    handle: i32 = 0,
    name: [:0]const u8,
    value: i32 = 0,

    fn set(self: *Uniform1i, i: i32) void {
        gl.Uniform1i(self.handle, i);
        self.value = i;
    }
};

const Uniform2i = struct {
    handle: i32 = 0,
    name: [:0]const u8,
    value: [2]i32 = .{ 0, 0 },

    fn set(self: *Uniform2i, v0: i32, v1: i32) void {
        gl.Uniform2i(self.handle, v0, v1);
        self.value = [2]i32{ v0, v1 };
    }
};

const Shader = struct {
    handle: u32,

    fn create(shader_type: u32) Shader {
        return Shader{ .handle = gl.CreateShader(shader_type) };
    }

    fn attach(self: *Shader, program: u32) void {
        gl.AttachShader(program, self.handle);
    }

    fn compile(self: *Shader, str: [*:0]const u8) !void {
        var l = [1]i32{-1};
        const source = [1][*:0]const u8{str};

        gl.ShaderSource(self.handle, 1, @constCast(&source), @as([*]i32, &l));
        gl.CompileShader(self.handle);
        var res: i32 = 1;
        gl.GetShaderiv(self.handle, gl.GL_COMPILE_STATUS, &res);
        if (res == gl.GL_FALSE) {
            var info_log: [1024]u8 = undefined;
            var len: u32 = 1;
            gl.GetShaderInfoLog(self.handle, info_log.len, &len, &info_log);
            std.debug.print("{s}\n", .{info_log[0..len]});
            return error.FailedToCompileShader;
        }
    }
};

const Program = struct {
    handle: u32,

    fn create() Program {
        return Program{ .handle = gl.CreateProgram() };
    }

    fn link(self: *Program) void {
        var status: i32 = 1;
        gl.LinkProgram(self.handle);
        gl.GetProgramiv(self.handle, gl.GL_LINK_STATUS, &status);
        if (status == 0) {
            var error_log: [1024]u8 = undefined;
            var len: u32 = 1;
            gl.GetProgramInfoLog(self.handle, error_log.len, &len, &error_log);
            std.debug.print("{s}\n", .{error_log[0..len]});
        }
    }

    fn validate(self: *Program) void {
        var status: i32 = 1;
        gl.ValidateProgram(self.handle);
        gl.GetProgramiv(self.handle, gl.GL_VALIDATE_STATUS, &status);
        if (status == 0) {
            var error_log: [1024]u8 = undefined;
            var len: u32 = 1;
            gl.GetProgramInfoLog(self.handle, error_log.len, &len, &error_log);
            std.debug.print("{s}\n", .{error_log[0..len]});
        }
    }

    fn use(self: *Program) void {
        gl.UseProgram(self.handle);
    }
};

const shader = struct {
    var fragment: Shader = undefined;
    var vertex: Shader = undefined;
};

const uniform = struct {
    var scale: Uniform1f = .{ .name = "scale" };
    var orbital: Uniform1i = .{ .name = "orbital" };
    var screen_xy: Uniform2i = .{ .name = "screen_xy" };
};

const prog = struct {
    var p1: Program = undefined;
};

fn relativePath(allocator: std.mem.Allocator, path_name: []const u8) ![]u8 {
    const dir_path = try std.fs.selfExeDirPathAlloc(allocator);
    defer allocator.free(dir_path);
    //std.debug.print("{s}\n", .{dir_path});
    var dir = try std.fs.openDirAbsolute(std.fs.path.dirname(dir_path) orelse "", .{});
    defer dir.close();
    return try dir.realpathAlloc(allocator, path_name);
}

///Callee owns memory
fn openFileRelative(allocator: std.mem.Allocator, path: []const u8) !std.fs.File {
    const path_absolute = try relativePath(allocator, path);
    defer allocator.free(path_absolute);
    return try std.fs.openFileAbsolute(path_absolute, .{});
}

fn event_loop() void {
    var msg: window.MSG = undefined;
    while (GetMessageA(&msg, null, 0, 0) > 0) {
        _ = TranslateMessage(&msg);
        _ = DispatchMessageA(&msg);
        render();
    }
}

fn render() void {
    gl.Clear(gl.GL_COLOR_BUFFER_BIT);
    gl.EnableVertexAttribArray(0);
    gl.VertexAttribPointer(0, 3, gl.GL_FLOAT, gl.GL_FALSE, 0, 0);
    gl.DrawArrays(gl.GL_TRIANGLES, 0, 6);
    gl.DisableVertexAttribArray(0);

    _ = SwapBuffers(ctx.hdc);
}

fn createVBO() void {
    var vertices = [6]Vec3{
        .{ .x = -1, .y = 1, .z = 0 },
        .{ .x = 1, .y = 1, .z = 0 },
        .{ .x = 1, .y = -1, .z = 0 },
        .{ .x = 1, .y = -1, .z = 0 },
        .{ .x = -1, .y = -1, .z = 0 },
        .{ .x = -1, .y = 1, .z = 0 },
    };
    var VBO: [1]u32 = undefined;
    gl.GenBuffers(1, &VBO);
    gl.BindBuffer(gl.GL_ARRAY_BUFFER, VBO[0]);
    gl.BufferData(gl.GL_ARRAY_BUFFER, vertices.len * @sizeOf(Vec3), &vertices, gl.GL_STATIC_DRAW);
}

fn createContext() !void {
    const format = ChoosePixelFormat(ctx.hdc, &pfd);
    _ = SetPixelFormat(ctx.hdc, format, &pfd);
    ctx.gl = wglCreateContext(ctx.hdc);
    _ = wglMakeCurrent(ctx.hdc, ctx.gl);
    gl.init() catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return error.Error;
    };
}

var alloc: std.mem.Allocator = undefined;
fn init_gl(hwnd: win.HWND) !void {
    ctx.hdc = GetDC(hwnd);
    try createContext();
    var ma_version: i32 = 0;
    var mi_version: i32 = 0;
    gl.GetIntegerv(gl.GL_MAJOR_VERSION, &ma_version);
    gl.GetIntegerv(gl.GL_MINOR_VERSION, &mi_version);
    std.debug.print("OpengGl version: {}.{}\n", .{ ma_version, mi_version });
    createVBO();
    prog.p1 = Program.create();
    const f_source = @embedFile("shaders/fragment.frag");
    const v_source = @embedFile("shaders/vertex.vert");
    shader.fragment = Shader.create(gl.GL_FRAGMENT_SHADER);
    try shader.fragment.compile(f_source);
    shader.fragment.attach(prog.p1.handle);
    shader.vertex = Shader.create(gl.GL_VERTEX_SHADER);
    try shader.vertex.compile(v_source);
    shader.vertex.attach(prog.p1.handle);
    prog.p1.link();
    prog.p1.validate();
    prog.p1.use();

    uniform.scale.handle = gl.GetUniformLocation(prog.p1.handle, uniform.scale.name).?;
    uniform.orbital.handle = gl.GetUniformLocation(prog.p1.handle, uniform.orbital.name).?;
    uniform.screen_xy.handle = gl.GetUniformLocation(prog.p1.handle, uniform.screen_xy.name).?;
    uniform.scale.set(0.8);
}

const ctx = struct {
    var gl: win.HGLRC = undefined;
    var hdc: win.HDC = undefined;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = ctx.gpa.allocator();
};

pub fn wWinMain(hInstance: win.HINSTANCE, hPrevInstance: ?win.HINSTANCE, lpCmdLine: win.PWSTR, nCmdShow: win.INT) win.INT {
    _ = hPrevInstance;
    _ = lpCmdLine;
    defer if (ctx.gpa.deinit() == .leak) {
        @panic("WE leaking");
    };

    var wc: window.WNDCLASSEXA = .{
        .lpfnWndProc = WndProc,
        .hInstance = hInstance,
        .lpszClassName = "CheckOpenGlVersion",
        .style = window.CS_OWNDC,
    };

    _ = RegisterClassExA(&wc);
    const width: i32 = 600;
    const height: i32 = width;
    const style = window.WS_MAXIMIZEBOX | window.WS_MINIMIZEBOX | window.WS_SIZEBOX | window.WS_SIZEBOX | window.WS_SYSMENU;
    const hwnd = CreateWindowExA(0, wc.lpszClassName, "Hydrogen Atom Electron Orbitals", style, 100, 100, width, height, null, null, hInstance, null);
    _ = ShowWindow(hwnd, nCmdShow);

    defer gl.deinit();

    event_loop();
    return 0;
}

fn size(comptime T: type, arr: []const T) usize {
    return @sizeOf(T) * arr.len;
}

pub fn WndProc(hwnd: win.HWND, msg: win.UINT, wParam: win.WPARAM, lParam: win.LPARAM) callconv(.C) win.LRESULT {
    switch (msg) {
        window.WM_CREATE => {
            init_gl(hwnd) catch |err| {
                std.debug.print("{}\n", .{err});
                return -1;
            };
            std.debug.print("n = 1, l = 0, m = 0\n", .{});
        },
        window.WM_DESTROY => {
            _ = wglDeleteContext(ctx.gl);
            PostQuitMessage(0);
        },
        window.WM_MOUSE_WHEEL => {
            const Delta: i16 = @truncate(@as(isize, (@bitCast(wParam >> 16))));
            if (Delta < 0) {
                uniform.scale.set(std.math.clamp(uniform.scale.value * 0.8, 0.0, 10.0));
            } else uniform.scale.set(std.math.clamp(uniform.scale.value / 0.8, 0.0, 10.0));

            //std.debug.print("M-wheel: {}\n", .{dir});
        },
        window.WM_LBUTTONDOWN => {
            if (uniform.orbital.value == 3) {
                uniform.orbital.set(0);
            } else uniform.orbital.set(uniform.orbital.value + 1);
            print_hint();
        },
        window.WM_RBUTTONDOWN => {
            if (uniform.orbital.value == 0) {
                uniform.orbital.set(3);
            } else uniform.orbital.set(uniform.orbital.value - 1);
            print_hint();
        },
        window.WM_SIZE => {
            const p: usize = @as(usize, @bitCast(lParam));
            const x: u16 = @truncate(p);
            const y: u16 = @truncate(p >> 16);
            gl.Viewport(0, 0, x, y);
            uniform.screen_xy.set(x, y);
            //const err = gl.GetError();
            //std.debug.print("err: {}\n", .{err});
        },
        else => return DefWindowProcA(hwnd, msg, wParam, lParam),
    }
    return DefWindowProcA(hwnd, msg, wParam, lParam);
}

fn print_hint() void {
    const orb = switch (uniform.orbital.value) {
        0 => "n = 1, l = 0, m = 0",
        1 => "n = 2, l = 0, m = 0",
        2 => "n = 2, l = 1, m = 0",
        3 => "n = 3, l = 1, m = 0",
        else => "???",
    };
    std.debug.print("{s}\n", .{orb});
}

pub fn main() !void {
    _ = std.start.call_wWinMain();
}
