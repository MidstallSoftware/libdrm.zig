const std = @import("std");
const Allocator = std.mem.Allocator;
const os = @import("../../os.zig");

pub const ModeFbCmd = extern struct {
    fbId: u32 = 0,
    width: u32 = 0,
    height: u32 = 0,
    pitch: u32 = 0,
    bpp: u32 = 0,
    handle: u32 = 0,

    pub const reqGet = os.IOCTL.IOWR(0xAD, ModeFbCmd);
    pub const reqAdd = os.IOCTL.IOWR(0xAE, ModeFbCmd);
    pub const reqRemove = os.IOCTL.IOWR(0xAF, u32);

    pub fn get(self: *ModeFbCmd, fd: std.os.fd_t) !void {
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

    pub fn add(self: *ModeFbCmd, fd: std.os.fd_t) !void {
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

    pub fn remove(fd: std.os.fd_t, id: u32) !void {
        return switch (std.os.errno(os.ioctl(fd, reqGet, @intFromPtr(&id)))) {
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
