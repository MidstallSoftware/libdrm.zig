const std = @import("std");
const Allocator = std.mem.Allocator;
const os = @import("../../os.zig");
const ModeInfo = @import("../mode.zig").ModeInfo;

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

    pub fn get(self: *ModeGetConnector, fd: std.posix.fd_t) !void {
        return switch (std.posix.errno(os.ioctl(fd, req, @intFromPtr(self)))) {
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

    pub fn getAllocated(self: *ModeGetConnector, fd: std.posix.fd_t, alloc: Allocator) !void {
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
