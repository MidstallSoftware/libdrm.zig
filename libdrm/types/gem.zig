const std = @import("std");
const Allocator = std.mem.Allocator;
const os = @import("../os.zig");

pub const GemClose = extern struct {
    handle: u32 = 0,
    pad: u32 = 0,

    pub const req = os.IOCTL.IOW(0x9, GemClose);

    pub fn get(self: *GemClose, fd: std.os.fd_t) !void {
        return switch (std.os.errno(os.ioctl(fd, req, @intFromPtr(self)))) {
            .SUCCESS => {},
            .BADF => error.NotOpenForWriting,
            .NOENT => error.NotFound,
            .FAULT => unreachable,
            .INVAL => unreachable,
            .NOTTY => error.NotATerminal,
            .OPNOTSUPP => error.NotSupported,
            else => |e| std.os.unexpectedErrno(e),
        };
    }
};

pub const GemFlink = extern struct {
    handle: u32 = 0,
    name: u32 = 0,

    pub const req = os.IOCTL.IOWR(0xA, GemFlink);

    pub fn get(self: *GemFlink, fd: std.os.fd_t) !void {
        return switch (std.os.errno(os.ioctl(fd, req, @intFromPtr(self)))) {
            .SUCCESS => {},
            .BADF => error.NotOpenForWriting,
            .NOENT => error.NotFound,
            .FAULT => unreachable,
            .INVAL => unreachable,
            .NOTTY => error.NotATerminal,
            .OPNOTSUPP => error.NotSupported,
            else => |e| std.os.unexpectedErrno(e),
        };
    }
};

pub const GemOpen = extern struct {
    name: u32 = 0,
    handle: u32 = 0,
    size: u64 = 0,

    pub const req = os.IOCTL.IOWR(0xB, GemOpen);

    pub fn get(self: *GemOpen, fd: std.os.fd_t) !void {
        return switch (std.os.errno(os.ioctl(fd, req, @intFromPtr(self)))) {
            .SUCCESS => {},
            .BADF => error.NotOpenForWriting,
            .NOENT => error.NotFound,
            .FAULT => unreachable,
            .INVAL => unreachable,
            .NOTTY => error.NotATerminal,
            .OPNOTSUPP => error.NotSupported,
            else => |e| std.os.unexpectedErrno(e),
        };
    }
};
