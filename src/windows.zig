const std = @import("std");
const DynLib = std.DynLib;
const win = std.os.windows;

pub const HWND = win.HANDLE;
pub const HINSTANCE = win.HANDLE;
pub const HICON = win.HANDLE;
pub const HCURSOR = HICON;
pub const HBRUSH = win.HANDLE;
pub const INT = c_int;
pub const UINT = c_uint;
pub const UINT_PTR = *c_uint;
pub const WPARAM = UINT_PTR;
pub const LONG_PTR = *c_long;
pub const LPARAM = LONG_PTR;
pub const LRESULT = LONG_PTR;
pub const LPCSTR = [*:0]const u8;
pub const DWORD = c_ulong;
pub const WNDPROC = *const fn (win.HWND, win.UINT, win.WPARAM, win.LPARAM) callconv(.C) win.LRESULT;
pub const WORD = c_ushort;

pub const COLOR_WINDOW: DWORD = 5;

pub const CS_OWNDC: c_uint = 0x20;

pub const PFD_DRAW_TO_WINDOW: c_ulong = 0x00000004;
pub const PFD_SUPPORT_OPENGL: c_ulong = 0x00000020;
pub const PFD_DOUBLEBUFFER: c_ulong = 0x00000001;
pub const PFD_TYPE_RGBA: u8 = 0;

pub const WS_SYSMENU: c_uint = 0x00080000;
pub const WS_SIZEBOX: c_uint = 0x00040000;
pub const WS_MINIMIZEBOX: c_uint = 0x00020000;
pub const WS_MAXIMIZEBOX: c_uint = 0x00010000;

pub const WM_CLOSE: c_uint = 0x0010;
pub const WM_DESTROY: c_uint = 0x0002;
pub const WM_CREATE: c_uint = 0x0001;
pub const WM_MOUSE_WHEEL: u32 = 0x020A;
pub const WM_LBUTTONDOWN: u32 = 0x0201;
pub const WM_RBUTTONDOWN: u32 = 0x0204;
pub const WM_SIZE: u32 = 0x0005;

pub const GL_MAJOR_VERSION: u32 = 0x821B;
pub const GL_MINOR_VERSION: u32 = 0x821C;
pub const GL_COLOR_BUFFER_BIT: u32 = 0x4000;

pub const MSG = extern struct {
    hwnd: HWND,
    message: UINT,
    wParam: WPARAM,
    lParam: LPARAM,
    time: DWORD,
    pt: win.POINT,
    lPrivate: DWORD,
};

pub const WNDCLASSEXA = extern struct {
    cbSize: u32 = @sizeOf(WNDCLASSEXA),
    style: u32 = 0,
    lpfnWndProc: WNDPROC,
    cbClsExtra: i32 = 0,
    cbWndExtra: i32 = 0,
    hInstance: HINSTANCE,
    hIcon: ?HICON = null,
    hCursor: ?HCURSOR = null,
    hbrBackground: ?win.HBRUSH = null,
    lpszMenuName: ?LPCSTR = null,
    lpszClassName: LPCSTR,
    hIconSm: ?HICON = null,
};

pub const PixelFormatDescriptor = extern struct {
    nSize: c_ushort = @sizeOf(PixelFormatDescriptor),
    nVersion: c_ushort = 0,
    dwFlags: c_ulong = 0,
    iPixelType: u8 = 0,
    cColorBits: u8 = 0,
    cRedBits: u8 = 0,
    cRedShift: u8 = 0,
    cGreenBits: u8 = 0,
    cGreenShift: u8 = 0,
    cBlueBits: u8 = 0,
    cBlueShift: u8 = 0,
    cAlphaBits: u8 = 0,
    cAlphaShift: u8 = 0,
    cAccumBits: u8 = 0,
    cAccumRedBits: u8 = 0,
    cAccumGreenBits: u8 = 0,
    cAccumBlueBits: u8 = 0,
    cAccumAlphaBits: u8 = 0,
    cDepthBits: u8 = 0,
    cStencilBits: u8 = 0,
    cAuxBuffers: u8 = 0,
    iLayerType: u8 = 0,
    bReserved: u8 = 0,
    dwLayerMask: c_ulong = 0,
    dwVisibleMask: c_ulong = 0,
    dwDamageMask: c_ulong = 0,
};
