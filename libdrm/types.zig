const std = @import("std");
const Allocator = std.mem.Allocator;
const os = @import("os.zig");

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

    pub fn get(self: *ModeGetCrtc, fd: std.os.fd_t) !void {
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

    pub fn set(self: *const ModeGetCrtc, fd: std.os.fd_t) !void {
        return switch (std.os.errno(os.ioctl(fd, reqSet, @intFromPtr(self)))) {
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

    fn fieldPointer(self: *const ModeGetCrtc, comptime field: std.meta.FieldEnum(ModeGetCrtc), comptime T: type, count: u32) ?[]const T {
        if (@field(self, @tagName(field)) == 0) return null;
        return @as([*]T, @ptrFromInt(@field(self, @tagName(field))))[0..count];
    }

    pub inline fn setConnectors(self: *const ModeGetCrtc) ?[]const u32 {
        return self.fieldPointer(.setConnectorsPtr, u32, self.countConnectors);
    }
};

pub const ModeGetEncoder = extern struct {
    encoderId: u32 = 0,
    encoderType: u32 = 0,
    crtcId: u32 = 0,
    possibleCrtcs: u32 = 0,
    possibleClones: u32 = 0,

    pub const req = os.IOCTL.IOWR(0xA6, ModeGetEncoder);

    pub fn get(self: *ModeGetEncoder, fd: std.os.fd_t) !void {
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

pub const ModeInfo = extern struct {
    clock: u32 = 0,
    hdisplay: u16 = 0,
    hsyncStart: u16 = 0,
    hsyncEnd: u16 = 0,
    htotal: u16 = 0,
    hskew: u16 = 0,
    vdisplay: u16 = 0,
    vsyncStart: u16 = 0,
    vsyncEnd: u16 = 0,
    vtotal: u16 = 0,
    vscan: u16 = 0,
    vrefresh: u32 = 0,
    flags: u32 = 0,
    type: u32 = 0,
    name: [32]u8 = undefined,

    pub fn format(self: *const ModeInfo, comptime _: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = options;

        try writer.writeAll(@typeName(ModeInfo));
        try writer.print("{{ .clock = {}, .hdisplay = {}, .hsyncStart = {}, .hsyncEnd = {}, .hskew = {}, .vdisplay = {}, .vsyncStart = {}, .vsyncEnd = {}, .vtotal = {}, .vscan = {}, .vrefresh = {}, .flags = {}, .type = {}, .name = \"{s}\" }}", .{
            self.clock,
            self.hdisplay,
            self.hsyncStart,
            self.hsyncEnd,
            self.hskew,
            self.vdisplay,
            self.vsyncStart,
            self.vsyncEnd,
            self.vtotal,
            self.vscan,
            self.vrefresh,
            self.flags,
            self.type,
            self.name,
        });
    }
};

pub const ModeGetConnector = extern struct {
    encoderIdPtr: u64 = 0,
    modesPtr: u64 = 0,
    propsPtr: u64 = 0,
    propsValuesPtr: u64 = 0,
    countModes: u32 = 0,
    countProps: u32 = 0,
    countEncoders: u32 = 0,
    encoderId: u32 = 0,
    connectorId: u32 = 0,
    connectorType: Type = undefined,
    connectorTypeId: u32 = 0,
    connection: u32 = 0,
    mmWidth: u32 = 0,
    mmHeight: u32 = 0,
    subpixel: u32 = 0,
    pad: u32 = 0,

    pub const req = os.IOCTL.IOWR(0xA7, ModeGetConnector);

    pub fn get(self: *ModeGetConnector, fd: std.os.fd_t) !void {
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

    pub fn getAllocated(self: *ModeGetConnector, fd: std.os.fd_t, alloc: Allocator) !void {
        try self.get(fd);

        errdefer self.deinit(alloc);
        if (self.countProps > 0) {
            self.propsPtr = @intFromPtr((try alloc.alloc(u32, self.countProps)).ptr);
            self.propsValuesPtr = @intFromPtr((try alloc.alloc(u64, self.countProps)).ptr);
        }

        if (self.countModes > 0) self.modesPtr = @intFromPtr((try alloc.alloc(ModeInfo, self.countModes)).ptr);
        if (self.countEncoders > 0) self.encoderIdPtr = @intFromPtr((try alloc.alloc(u32, self.countEncoders)).ptr);

        try self.get(fd);
    }

    pub fn deinit(self: *const ModeGetConnector, alloc: Allocator) void {
        if (self.props()) |v| alloc.free(v);
        if (self.propValues()) |v| alloc.free(v);
        if (self.modes()) |v| alloc.free(v);
        if (self.encoderIds()) |v| alloc.free(v);
    }

    pub fn format(self: *const ModeGetConnector, comptime _: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = options;

        try writer.writeAll(@typeName(ModeGetConnector));
        try writer.print("{{ .encoderId = {}, .connectorId = {}, .connectorType = {s}, .connectorTypeId = {}, .connection = {}, .mmWidth = {}, .mmHeight = {}, .subpixel = {}", .{
            self.encoderId,
            self.connectorId,
            @tagName(self.connectorType),
            self.connectorTypeId,
            self.connection,
            self.mmWidth,
            self.mmHeight,
            self.subpixel,
        });

        if (self.props()) |v| try writer.print(", .props = {any}", .{v});
        if (self.propValues()) |v| try writer.print(", .propValues = {any}", .{v});
        if (self.modes()) |v| try writer.print(", .modes = {any}", .{v});
        if (self.encoderIds()) |v| try writer.print(", .encoderIds = {any}", .{v});

        try writer.writeAll(" }");
    }

    fn fieldPointer(self: *const ModeGetConnector, comptime field: std.meta.FieldEnum(ModeGetConnector), comptime T: type, count: u32) ?[]const T {
        if (@field(self, @tagName(field)) == 0) return null;
        return @as([*]T, @ptrFromInt(@field(self, @tagName(field))))[0..count];
    }

    pub inline fn props(self: *const ModeGetConnector) ?[]const u32 {
        return self.fieldPointer(.propsPtr, u32, self.countProps);
    }

    pub inline fn propValues(self: *const ModeGetConnector) ?[]const u64 {
        return self.fieldPointer(.propsValuesPtr, u64, self.countProps);
    }

    pub inline fn modes(self: *const ModeGetConnector) ?[]const ModeInfo {
        return self.fieldPointer(.modesPtr, ModeInfo, self.countModes);
    }

    pub inline fn encoderIds(self: *const ModeGetConnector) ?[]const u32 {
        return self.fieldPointer(.encoderIdPtr, u32, self.countEncoders);
    }

    pub const Type = enum(u32) {
        unknown = 0,
        vga = 1,
        dvii = 2,
        dvid = 3,
        dvia = 4,
        composite = 5,
        svideo = 6,
        lvds = 7,
        component = 8,
        din9Pin = 9,
        displayPort = 10,
        hdmiA = 11,
        hdmiB = 12,
        tv = 13,
        eDP = 14,
        virtual = 15,
        dsi = 16,
        dpi = 17,
        writeback = 18,
        spi = 19,
        usb = 20,
    };
};

pub const ModeCardRes = extern struct {
    fbIdPtr: u64 = 0,
    crtcIdPtr: u64 = 0,
    connectorIdPtr: u64 = 0,
    encoderIdPtr: u64 = 0,
    countFbs: u32 = 0,
    countCrtcs: u32 = 0,
    countConnectors: u32 = 0,
    countEncoders: u32 = 0,
    minWidth: u32 = 0,
    maxWidth: u32 = 0,
    minHeight: u32 = 0,
    maxHeight: u32 = 0,

    pub const req = os.IOCTL.IOWR(0xA0, ModeCardRes);

    pub fn get(self: *ModeCardRes, fd: std.os.fd_t) !void {
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

    fn fieldPointer(self: *const ModeCardRes, comptime field: std.meta.FieldEnum(ModeCardRes), comptime T: type, count: u32) ?[]const T {
        if (@field(self, @tagName(field)) == 0) return null;
        return @as([*]T, @ptrFromInt(@field(self, @tagName(field))))[0..count];
    }

    pub fn getAllocated(self: *ModeCardRes, fd: std.os.fd_t, alloc: Allocator) !void {
        try self.get(fd);

        errdefer self.deinit(alloc);
        if (self.countFbs > 0) self.fbIdPtr = @intFromPtr((try alloc.alloc(u32, self.countFbs)).ptr);
        if (self.countCrtcs > 0) self.crtcIdPtr = @intFromPtr((try alloc.alloc(u32, self.countCrtcs)).ptr);
        if (self.countConnectors > 0) self.connectorIdPtr = @intFromPtr((try alloc.alloc(u32, self.countConnectors)).ptr);
        if (self.countEncoders > 0) self.encoderIdPtr = @intFromPtr((try alloc.alloc(u32, self.countEncoders)).ptr);

        try self.get(fd);
    }

    pub fn deinit(self: *const ModeCardRes, alloc: Allocator) void {
        if (self.fbIds()) |v| alloc.free(v);
        if (self.crtcIds()) |v| alloc.free(v);
        if (self.connectorIds()) |v| alloc.free(v);
        if (self.encoderIds()) |v| alloc.free(v);
    }

    pub fn format(self: *const ModeCardRes, comptime _: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = options;

        try writer.writeAll(@typeName(ModeCardRes));
        try writer.print("{{ .minWidth = {}, .maxWidth = {}, .minHeight = {}, .maxHeight = {}", .{
            self.minWidth,
            self.maxWidth,
            self.minHeight,
            self.maxHeight,
        });

        if (self.fbIds()) |v| try writer.print(", .fbIds = {any}", .{v});
        if (self.crtcIds()) |v| try writer.print(", .crtcIds = {any}", .{v});
        if (self.connectorIds()) |v| try writer.print(", .connectorIds = {any}", .{v});
        if (self.encoderIds()) |v| try writer.print(", .encoderIds = {any}", .{v});

        try writer.writeAll(" }");
    }

    pub inline fn fbIds(self: *const ModeCardRes) ?[]const u32 {
        return self.fieldPointer(.fbIdPtr, u32, self.countFbs);
    }

    pub inline fn crtcIds(self: *const ModeCardRes) ?[]const u32 {
        return self.fieldPointer(.crtcIdPtr, u32, self.countCrtcs);
    }

    pub inline fn connectorIds(self: *const ModeCardRes) ?[]const u32 {
        return self.fieldPointer(.connectorIdPtr, u32, self.countConnectors);
    }

    pub inline fn encoderIds(self: *const ModeCardRes) ?[]const u32 {
        return self.fieldPointer(.encoderIdPtr, u32, self.countEncoders);
    }
};

pub const Unique = extern struct {
    len: usize = 0,
    value: [*]u8 = undefined,

    pub const req = os.IOCTL.IOWR(0x1, Unique);

    pub fn get(self: *Unique, fd: std.os.fd_t) !void {
        return switch (std.os.errno(os.ioctl(fd, req, @intFromPtr(self)))) {
            .SUCCESS => {},
            .BADF => error.NotOpenForWriting,
            .NOENT => error.NotFound,
            .FAULT => unreachable,
            .INVAL => unreachable,
            .NOTTY => error.NotATerminal,
            else => |e| std.os.unexpectedErrno(e),
        };
    }

    pub fn getAllocated(self: *Unique, fd: std.os.fd_t, alloc: Allocator) !void {
        try self.get(fd);

        errdefer self.deinit(alloc);
        if (self.len > 0) self.value = @ptrCast(try alloc.alloc(u8, self.len));

        try self.get(fd);
    }

    pub fn deinit(self: *const Unique, alloc: Allocator) void {
        if (@intFromPtr(self.value) > 0) alloc.free(self.value[0..self.len]);
    }

    pub fn format(self: *const Unique, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        if (@intFromPtr(self.value) > 0) {
            try std.fmt.formatText(self.value[0..self.len], fmt, options, writer);
        } else {
            try writer.writeAll("null");
        }
    }
};

pub const SetVersion = extern struct {
    diMajor: c_int,
    diMinor: c_int,
    ddMajor: c_int,
    ddMinor: c_int,

    pub const req = os.IOCTL.IOWR(0x7, SetVersion);

    pub fn set(self: *Version, fd: std.os.fd_t) !void {
        return switch (std.os.errno(os.ioctl(fd, req, @intFromPtr(self)))) {
            .SUCCESS => {},
            .BADF => error.NotOpenForWriting,
            .NOENT => error.NotFound,
            .FAULT => unreachable,
            .INVAL => unreachable,
            .NOTTY => error.NotATerminal,
            else => |e| std.os.unexpectedErrno(e),
        };
    }
};

pub const Version = extern struct {
    major: c_int = 0,
    minor: c_int = 0,
    patchlevel: c_int = 0,
    nameLen: usize = 0,
    name: [*]u8 = undefined,
    dateLen: usize = 0,
    date: [*]u8 = undefined,
    descLen: usize = 0,
    desc: [*]u8 = undefined,

    pub const req = os.IOCTL.IOWR(0, Version);

    pub fn get(self: *Version, fd: std.os.fd_t) !void {
        return switch (std.os.errno(os.ioctl(fd, req, @intFromPtr(self)))) {
            .SUCCESS => {},
            .BADF => error.NotOpenForWriting,
            .NOENT => error.NotFound,
            .FAULT => unreachable,
            .INVAL => unreachable,
            .NOTTY => error.NotATerminal,
            else => |e| std.os.unexpectedErrno(e),
        };
    }

    pub fn getAllocated(self: *Version, fd: std.os.fd_t, alloc: Allocator) !void {
        try self.get(fd);

        errdefer self.deinit(alloc);
        if (self.nameLen > 0) self.name = @ptrCast(try alloc.alloc(u8, self.nameLen));
        if (self.dateLen > 0) self.date = @ptrCast(try alloc.alloc(u8, self.dateLen));
        if (self.descLen > 0) self.desc = @ptrCast(try alloc.alloc(u8, self.descLen));

        try self.get(fd);
    }

    pub fn deinit(self: *const Version, alloc: Allocator) void {
        if (@intFromPtr(self.name) > 0) alloc.free(self.name[0..self.nameLen]);
        if (@intFromPtr(self.date) > 0) alloc.free(self.date[0..self.dateLen]);
        if (@intFromPtr(self.desc) > 0) alloc.free(self.desc[0..self.descLen]);
    }

    pub fn format(self: *const Version, comptime _: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = options;

        try writer.writeAll(@typeName(Version));
        try writer.print("{{ .major = {}, .minor = {}, .patchlevel = {}", .{
            self.major,
            self.minor,
            self.patchlevel,
        });

        if (@intFromPtr(self.name) > 0) {
            try writer.print(", .name = \"{s}\"", .{
                self.name[0..self.nameLen],
            });
        }

        if (@intFromPtr(self.date) > 0) {
            try writer.print(", .date = \"{s}\"", .{
                self.date[0..self.dateLen],
            });
        }

        if (@intFromPtr(self.desc) > 0) {
            try writer.print(", .desc = \"{s}\"", .{
                self.desc[0..self.descLen],
            });
        }

        try writer.writeAll(" }");
    }
};
