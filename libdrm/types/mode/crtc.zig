const std = @import("std");
const Allocator = std.mem.Allocator;
const os = @import("../../os.zig");
const ModeInfo = @import("../mode.zig").ModeInfo;

pub const ModeCrtcPageFlip = extern struct {
    crtcId: u32 = 0,
    fbId: u32 = 0,
    flags: u32 = 0,
    reserved: u32 = 0,
    userData: u64 = 0,

    pub const req = os.IOCTL.IOWR(0xB0, ModeCrtcPageFlip);

    pub fn exec(self: *ModeCrtcPageFlip, fd: std.os.fd_t) !void {
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

pub const ModeGetCrtc = extern struct {
    setConnectorsPtr: u64 = 0,
    countConnectors: u32 = 0,
    crtcId: u32 = 0,
    fbId: u32 = 0,
    x: u32 = 0,
    y: u32 = 0,
    gammaSize: u32 = 0,
    modeValid: u32 = 0,
    mode: ModeInfo = .{},

    pub const reqGet = os.IOCTL.IOWR(0xA1, ModeGetCrtc);
    pub const reqSet = os.IOCTL.IOWR(0xA2, ModeGetCrtc);

    pub fn get(self: *ModeGetCrtc, fd: std.posix.fd_t) !void {
        return switch (std.posix.errno(os.ioctl(fd, reqGet, @intFromPtr(self)))) {
            .SUCCESS => {},
            .BADF => error.NotOpenForWriting,
            .NOENT => error.NotFound,
            .FAULT => unreachable,
            .INVAL => unreachable,
            .NOTTY => error.NotATerminal,
            .OPNOTSUPP => error.NotSupported,
            else => |e| std.posix.unexpectedErrno(e),
        };
    }

    pub fn set(self: *const ModeGetCrtc, fd: std.posix.fd_t) !void {
        return switch (std.posix.errno(os.ioctl(fd, reqSet, @intFromPtr(self)))) {
            .SUCCESS => {},
            .BADF => error.NotOpenForWriting,
            .NOENT => error.NotFound,
            .FAULT => unreachable,
            .INVAL => unreachable,
            .NOTTY => error.NotATerminal,
            .OPNOTSUPP => error.NotSupported,
            else => |e| std.posix.unexpectedErrno(e),
        };
    }

    fn fieldPointer(self: *const ModeGetCrtc, comptime field: std.meta.FieldEnum(ModeGetCrtc), comptime T: type, count: u32) ?[]const T {
        if (@field(self, @tagName(field)) == 0) return null;
        return @as([*]T, @ptrFromInt(@field(self, @tagName(field))))[0..count];
    }

    pub inline fn setConnectors(self: *const ModeGetCrtc) ?[]const u32 {
        return self.fieldPointer(.setConnectorsPtr, u32, self.countConnectors);
    }
};
