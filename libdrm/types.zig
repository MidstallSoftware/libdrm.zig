const std = @import("std");
const Allocator = std.mem.Allocator;
const os = @import("os.zig");

pub const amdgpu = @import("types/amdgpu.zig");
pub const asahi = @import("types/asahi.zig");

pub usingnamespace @import("types/base.zig");
pub usingnamespace @import("types/gem.zig");
pub usingnamespace @import("types/map.zig");
pub usingnamespace @import("types/mode.zig");
pub usingnamespace @import("types/mode/crtc.zig");
pub usingnamespace @import("types/mode/conn.zig");
pub usingnamespace @import("types/mode/fb.zig");
pub usingnamespace @import("types/mode/plane.zig");
pub usingnamespace @import("types/mode/props.zig");

pub const Event = union(Type) {
    vblank: VBlank,
    flipComplete: VBlank,
    crtcSeq: CrtcSeq,

    pub const Base = extern struct {
        type: Type = undefined,
        length: u32 = 0,
    };

    pub const VBlank = extern struct {
        userData: u64 = 0,
        tvSec: u32 = 0,
        tvUsec: u32 = 0,
        seq: u64 = 0,
        crtcId: u32 = 0,
    };

    pub const CrtcSeq = extern struct {
        userData: u64 = 0,
        timeNs: i64 = 0,
        seq: u64 = 0,
    };

    pub const Type = enum(u32) {
        vblank = 0x1,
        flipComplete = 0x2,
        crtcSeq = 0x3,
    };

    pub fn read(self: *Event, fd: std.os.fd_t) !void {
        var base: Base = undefined;
        _ = try std.os.read(fd, std.mem.asBytes(&base));

        self.* = switch (base.type) {
            .vblank => blk: {
                var vblank: VBlank = undefined;
                _ = try std.os.read(fd, std.mem.asBytes(&vblank));
                break :blk .{ .vblank = vblank };
            },
            .flipComplete => blk: {
                var vblank: VBlank = undefined;
                _ = try std.os.read(fd, std.mem.asBytes(&vblank));
                break :blk .{ .flipComplete = vblank };
            },
            .crtcSeq => blk: {
                var crtcSeq: CrtcSeq = undefined;
                _ = try std.os.read(fd, std.mem.asBytes(&crtcSeq));
                break :blk .{ .crtcSeq = crtcSeq };
            },
        };
    }
};
