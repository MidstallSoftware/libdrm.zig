const std = @import("std");
const builtin = @import("builtin");

pub const primaryDeviceName = switch (builtin.os.tag) {
    .openbsd => "drm",
    .linux => "card",
    else => |t| @compileError("Unsupported OS " ++ @tagName(t)),
};

pub const controlDeviceName = switch (builtin.os.tag) {
    .openbsd => "drmC",
    .linux => "controlD",
    else => |t| @compileError("Unsupported OS " ++ @tagName(t)),
};

pub const renderDeviceName = switch (builtin.os.tag) {
    .openbsd => "drmR",
    .linux => "renderD",
    else => |t| @compileError("Unsupported OS " ++ @tagName(t)),
};

pub const ioctl = switch (builtin.os.tag) {
    .linux => std.os.linux.ioctl,
    else => |t| @compileError("Unsupported OS " ++ @tagName(t)),
};

pub const IOCTL = switch (builtin.os.tag) {
    .linux => struct {
        pub fn IO(nr: u8) u32 {
            return std.os.linux.IOCTL.IO('d', nr);
        }

        pub fn IOR(nr: u8, comptime T: type) u32 {
            return std.os.linux.IOCTL.IOR('d', nr, T);
        }

        pub fn IOW(nr: u8, comptime T: type) u32 {
            return std.os.linux.IOCTL.IOW('d', nr, T);
        }

        pub fn IOWR(nr: u8, comptime T: type) u32 {
            return std.os.linux.IOCTL.IOWR('d', nr, T);
        }
    },
    else => |t| @compileError("Unsupported OS " ++ @tagName(t)),
};
