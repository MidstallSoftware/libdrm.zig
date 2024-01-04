const std = @import("std");
const Allocator = std.mem.Allocator;
const os = @import("../os.zig");

pub const GemCreate = extern union {
    in: In,
    out: Out,

    pub const req = os.IOCTL.IOWR(0x40, GemCreate);

    pub fn get(self: *GemCreate, fd: std.os.fd_t) !void {
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

    pub const DomainFlags = packed struct(u64) {
        cpu: u1 = 0,
        gtt: u1 = 0,
        vram: u1 = 0,
        gds: u1 = 0,
        gwd: u1 = 0,
        oa: u1 = 0,
        padding: u58 = 0,
    };

    pub const In = extern struct {
        boSize: u64 = 0,
        alignment: u64 = 0,
        domains: u64 = 0,
        domainFlags: DomainFlags = .{},
    };

    pub const Out = extern struct {
        handle: u32 = 0,
        pad: u32 = 0,
    };
};

pub const GemMmap = extern union {
    in: In,
    out: Out,

    pub const req = os.IOCTL.IOWR(0x41, GemMmap);

    pub fn get(self: *GemMmap, fd: std.os.fd_t) !void {
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

    pub const In = extern struct {
        handle: u32 = 0,
        pad: u32 = 0,
    };

    pub const Out = extern struct {
        addr: u64 = 0,
    };
};
