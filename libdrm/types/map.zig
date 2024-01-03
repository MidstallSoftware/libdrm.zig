const std = @import("std");
const Allocator = std.mem.Allocator;
const os = @import("../os.zig");

pub const Map = extern struct {
    offset: c_ulong = 0,
    size: c_ulong = 0,
    type: Type = undefined,
    flags: u8 = 0,
    handle: usize = 0,
    mtrr: c_int = 0,

    pub const reqGet = os.IOCTL.IOWR(0x4, Map);
    pub const reqAdd = os.IOCTL.IOWR(0x15, Map);
    pub const reqRemove = os.IOCTL.IOWR(0x1B, Map);

    pub fn get(self: *Map, fd: std.os.fd_t) !void {
        return switch (std.os.errno(os.ioctl(fd, reqGet, @intFromPtr(self)))) {
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

    pub fn add(self: *Map, fd: std.os.fd_t) !void {
        return switch (std.os.errno(os.ioctl(fd, reqAdd, @intFromPtr(self)))) {
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

    pub fn remove(self: *Map, fd: std.os.fd_t) !void {
        return switch (std.os.errno(os.ioctl(fd, reqRemove, @intFromPtr(self)))) {
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

    pub const Type = enum(u8) {
        framebuffer = 0,
        registers = 1,
        shm = 2,
        agp = 3,
        scatterGather = 4,
        consistent = 5,
    };

    pub const Flags = enum(u8) {
        restricted = 1,
        readOnly = 2,
        locked = 3,
        kernel = 8,
        writeCombining = 0x10,
        containsLock = 0x20,
        removable = 0x40,
        driver = 0x80,
    };
};
