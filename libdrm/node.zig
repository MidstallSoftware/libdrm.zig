const std = @import("std");
const Allocator = std.mem.Allocator;
const builtin = @import("builtin");
const os = @import("os.zig");
const types = @import("types.zig");
const Self = @This();

const major: u16 = switch (builtin.os.tag) {
    .dragonfly => 145,
    .netbsd => 34,
    .openbsd => if (builtin.cpu.arch == .x86) 88 else 87,
    .linux => 226,
    else => |t| @compileError("DRM major is not supported on " ++ @tagName(t)),
};

pub const Type = enum(u8) {
    primary = 0,
    control = 1,
    render = 2,

    pub fn getMinorBase(self: Type) ?u8 {
        return switch (self) {
            .primary => 0,
            .render => 128,
            else => null,
        };
    }

    pub fn getDeviceName(self: Type) ?[]const u8 {
        return switch (self) {
            .primary => os.primaryDeviceName,
            .control => os.controlDeviceName,
            .render => os.renderDeviceName,
        };
    }
};

pub const Kind = enum {
    busid,
    name,
};

pub const Iterator = struct {
    allocator: Allocator,
    type: Type,
    index: u6 = 0,

    pub fn init(alloc: Allocator, t: Type) Iterator {
        return .{ .allocator = alloc, .type = t };
    }

    pub fn next(self: *Iterator) ?Self {
        if (self.index == 64) return null;

        const base = self.type.getMinorBase() orelse return null;
        const minor = base + self.index;

        const node = openMinor(self.allocator, minor, self.type) catch null;
        self.index += 1;
        return node;
    }
};

allocator: Allocator,
fd: std.posix.fd_t,

pub fn open(alloc: Allocator, name: ?[]const u8, busid: ?[]const u8) !Self {
    return openWithType(alloc, name, busid, .primary);
}

pub fn openWithType(alloc: Allocator, name: ?[]const u8, busid: ?[]const u8, t: Type) !Self {
    if (busid) |b| {
        if (openBy(alloc, b, .busid, t) catch null) |r| return r;
    }

    if (name) |n| return try openBy(alloc, n, .name, t);
    return error.InvalidParams;
}

pub fn openMinor(alloc: Allocator, minor: u8, t: Type) !Self {
    const devName = t.getDeviceName() orelse return error.InvalidType;

    var buff = [_]u8{0} ** std.posix.PATH_MAX;
    _ = try std.fmt.bufPrint(&buff, "/dev/dri/{s}{}", .{ devName, minor });

    var end: usize = 0;
    while (buff[end] != 0) : (end += 1) {}

    return .{
        .allocator = alloc,
        .fd = (try std.fs.openFileAbsolute(buff[0..end], .{
            .mode = .read_write,
        })).handle,
    };
}

pub fn openBy(alloc: Allocator, kindValue: []const u8, kind: Kind, t: Type) !Self {
    var iter = Iterator.init(alloc, t);

    while (iter.next()) |node| {
        errdefer node.deinit();

        switch (kind) {
            .name => {
                const version = try node.getVersion();
                defer version.deinit(alloc);

                if (std.mem.eql(u8, version.name[0..version.nameLen], kindValue)) return node;
            },
            .busid => {
                var version = types.SetVersion{
                    .diMajor = 1,
                    .diMinor = 4,
                    .ddMajor = -1,
                    .ddMinor = -1,
                };

                version.set(node.fd) catch {
                    version = .{
                        .diMajor = 1,
                        .diMinor = 1,
                        .ddMajor = -1,
                        .ddMinor = -1,
                    };
                    try version.set(node.fd);
                };

                const busId = try node.getBusId();
                defer alloc.free(busId);

                if (std.mem.eql(u8, busId, kindValue)) return node;
            },
        }
    }

    return error.NamedNotFound;
}

pub fn deinit(self: *const Self) void {
    std.posix.close(self.fd);
}

pub fn getVersion(self: *const Self) !types.Version {
    var version: types.Version = .{};
    try version.getAllocated(self.fd, self.allocator);
    return version;
}

pub fn getBusId(self: *const Self) ![]const u8 {
    var unique: types.Unique = .{};
    try unique.getAllocated(self.fd, self.allocator);
    return unique.value[0..unique.len];
}

pub fn getModeCardRes(self: *const Self) !types.ModeCardRes {
    var modeCardRes: types.ModeCardRes = .{};
    try modeCardRes.getAllocated(self.fd, self.allocator);
    return modeCardRes;
}

pub fn getConnector(self: *const Self, id: u32) !types.ModeGetConnector {
    var connector: types.ModeGetConnector = .{
        .connectorId = id,
    };
    try connector.getAllocated(self.fd, self.allocator);
    return connector;
}

pub fn getEncoder(self: *const Self, id: u32) !types.ModeGetEncoder {
    var encoder: types.ModeGetEncoder = .{
        .encoderId = id,
    };
    try encoder.get(self.fd);
    return encoder;
}

pub fn getCrtc(self: *const Self, id: u32) !types.ModeGetCrtc {
    var crtc: types.ModeGetCrtc = .{
        .crtcId = id,
    };
    try crtc.get(self.fd);
    return crtc;
}

pub fn getFb(self: *const Self, id: u32) !types.ModeFbCmd {
    var fb: types.ModeFbCmd = .{
        .fbId = id,
    };
    try fb.get(self.fd);
    return fb;
}

pub fn getFb2(self: *const Self, id: u32) !types.ModeFbCmd2 {
    var fb: types.ModeFbCmd2 = .{
        .fbId = id,
    };
    try fb.get(self.fd);
    return fb;
}

pub fn getEvent(self: *const Self) !types.Event {
    var ev: types.Event = undefined;
    try ev.read(self.fd);
    return ev;
}
