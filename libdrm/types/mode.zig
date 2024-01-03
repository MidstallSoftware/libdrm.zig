const std = @import("std");
const Allocator = std.mem.Allocator;
const os = @import("../os.zig");

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
