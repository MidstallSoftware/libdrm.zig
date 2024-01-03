const std = @import("std");
const Allocator = std.mem.Allocator;
const os = @import("../../os.zig");

pub const ModeSetPlane = extern struct {
    planeId: u32 = 0,
    crtcId: u32 = 0,
    fbId: u32 = 0,
    flags: u32 = 0,
    crtcX: i32 = 0,
    crtcY: i32 = 0,
    crtcWidth: u32 = 0,
    crtcHeight: u32 = 0,
    srcX: i32 = 0,
    srcY: i32 = 0,
    srcWidth: u32 = 0,
    srcHeight: u32 = 0,

    pub const req = os.IOCTL.IOWR(0xB7, ModeSetPlane);

    pub fn set(self: *ModeSetPlane, fd: std.os.fd_t) !void {
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

pub const ModeGetPlane = extern struct {
    planeId: u32 = 0,
    crtcId: u32 = 0,
    fbId: u32 = 0,
    possibleCrtcs: u32 = 0,
    gammaSize: u32 = 0,
    countFormatTypes: u32 = 0,
    formatTypesPtr: u64 = 0,

    pub const req = os.IOCTL.IOWR(0xB6, ModeGetPlane);

    pub fn get(self: *ModeGetPlane, fd: std.os.fd_t) !void {
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

    pub fn getAllocated(self: *ModeGetPlane, fd: std.os.fd_t, alloc: Allocator) !void {
        try self.get(fd);

        errdefer self.deinit(alloc);
        if (self.countFormatTypes > 0) self.formatTypesPtr = @intFromPtr((try alloc.alloc(u32, self.countFormatTypes)).ptr);

        try self.get(fd);
    }

    pub fn deinit(self: *const ModeGetPlane, alloc: Allocator) void {
        if (self.formatTypes()) |v| alloc.free(v);
    }

    pub fn format(self: *const ModeGetPlane, comptime _: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = options;

        try writer.writeAll(@typeName(ModeGetPlane));
        try writer.print("{{ .planeId = {}, .crtcId = {}, .fbId = {}, .possibleCrtcs = {}, .gammaSize = {}", .{
            self.planeId,
            self.crtcId,
            self.fbId,
            self.possibleCrtcs,
            self.gammaSize,
        });

        if (self.formatTypes()) |v| try writer.print(", .formatTypes = {any}", .{v});

        try writer.writeAll(" }");
    }

    fn fieldPointer(self: *const ModeGetPlane, comptime field: std.meta.FieldEnum(ModeGetPlane), comptime T: type, count: u32) ?[]const T {
        if (@field(self, @tagName(field)) == 0) return null;
        return @as([*]T, @ptrFromInt(@field(self, @tagName(field))))[0..count];
    }

    pub inline fn formatTypes(self: *const ModeGetPlane) ?[]const u32 {
        return self.fieldPointer(.formatTypesPtr, u32, self.countFormatTypes);
    }
};
