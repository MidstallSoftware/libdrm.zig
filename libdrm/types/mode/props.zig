const std = @import("std");
const Allocator = std.mem.Allocator;
const os = @import("../../os.zig");

pub const ModeGetBlob = extern struct {
    blobId: u32 = 0,
    len: u32 = 0,
    dataPtr: u64 = 0,

    pub const req = os.IOCTL.IOWR(0xAC, ModeGetBlob);

    pub fn get(self: *ModeGetBlob, fd: std.posix.fd_t) !void {
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

    pub fn getAllocated(self: *ModeGetBlob, fd: std.posix.fd_t, alloc: Allocator) !void {
        try self.get(fd);

        errdefer self.deinit(alloc);
        if (self.len > 0) self.dataPtr = @intFromPtr((try alloc.alloc(u8, self.len)).ptr);

        try self.get(fd);
    }

    pub fn deinit(self: *const ModeGetBlob, alloc: Allocator) void {
        if (self.data()) |v| alloc.free(v);
    }

    pub fn format(self: *const ModeGetBlob, comptime _: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = options;

        try writer.writeAll(@typeName(ModeGetBlob));
        try writer.print("{{ .blobId = {}, .len = {}", .{
            self.blobId,
            self.len,
        });

        if (self.data()) |v| try writer.print(", .data = {any}", .{v});

        try writer.writeAll(" }");
    }

    fn fieldPointer(self: *const ModeGetBlob, comptime field: std.meta.FieldEnum(ModeGetBlob), comptime T: type, count: u32) ?[]const T {
        if (@field(self, @tagName(field)) == 0) return null;
        return @as([*]T, @ptrFromInt(@field(self, @tagName(field))))[0..count];
    }

    pub inline fn data(self: *const ModeGetBlob) ?[]const u8 {
        return self.fieldPointer(.dataPtr, u8, self.len);
    }
};

pub const ModePropertyEnum = extern struct {
    value: u64 = 0,
    name: [32]u8 = undefined,

    pub fn format(self: *const ModePropertyEnum, comptime _: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = options;

        try writer.writeAll(@typeName(ModePropertyEnum));
        try writer.print("{{ .value = {}, .name = \"{s}\" }}", .{
            self.value,
            self.name,
        });
    }
};

pub const ModeGetProperty = extern struct {
    valuesPtr: u64 = 0,
    enumBlobPtr: u64 = 0,
    propId: u32 = 0,
    flags: Flags = undefined,
    name: [32]u8 = undefined,
    countValues: u32 = 0,
    countEnumBlobs: u32 = 0,

    pub const req = os.IOCTL.IOWR(0xAA, ModeGetProperty);

    pub const Flags = packed struct(u32) {
        pending: u1,
        range: u1,
        immutable: u1,
        @"enum": u1,
        blob: u1,
        bitmask: u1,
        __future: u26,
    };

    pub fn get(self: *ModeGetProperty, fd: std.posix.fd_t) !void {
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

    pub fn getAllocated(self: *ModeGetProperty, fd: std.posix.fd_t, alloc: Allocator) !void {
        try self.get(fd);

        errdefer self.deinit(alloc);
        if (self.countValues > 0 and self.flags.blob == 0) self.valuesPtr = @intFromPtr((try alloc.alloc(u64, self.countValues)).ptr);
        if (self.countEnumBlobs > 0) {
            if (self.flags.@"enum" == 1) {
                self.enumBlobPtr = @intFromPtr((try alloc.alloc(ModePropertyEnum, self.countEnumBlobs)).ptr);
            } else if (self.flags.blob == 1) {
                self.valuesPtr = @intFromPtr((try alloc.alloc(u32, self.countEnumBlobs)).ptr);
                self.enumBlobPtr = @intFromPtr((try alloc.alloc(u32, self.countEnumBlobs)).ptr);
            }
        }

        try self.get(fd);
    }

    pub fn deinit(self: *const ModeGetProperty, alloc: Allocator) void {
        if (self.values()) |v| alloc.free(v);
        if (self.enums()) |v| alloc.free(v);
        if (self.blobValues()) |v| alloc.free(v);
        if (self.blobs()) |v| alloc.free(v);
    }

    pub fn format(self: *const ModeGetProperty, comptime _: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = options;

        try writer.writeAll(@typeName(ModeGetProperty));
        try writer.print("{{ .propId = {}, .flags = {}, .name = \"{s}\"", .{
            self.propId,
            self.flags,
            self.name,
        });

        if (self.values()) |v| try writer.print(", .values = {any}", .{v});
        if (self.enums()) |v| try writer.print(", .enums = {any}", .{v});
        if (self.blobValues()) |v| try writer.print(", .blobValues = {any}", .{v});
        if (self.blobs()) |v| try writer.print(", .blobs = {any}", .{v});

        try writer.writeAll(" }");
    }

    fn fieldPointer(self: *const ModeGetProperty, comptime field: std.meta.FieldEnum(ModeGetProperty), comptime T: type, count: u32) ?[]const T {
        if (@field(self, @tagName(field)) == 0) return null;
        return @as([*]T, @ptrFromInt(@field(self, @tagName(field))))[0..count];
    }

    pub inline fn values(self: *const ModeGetProperty) ?[]const u64 {
        return if (self.flags.blob == 1) null else self.fieldPointer(.valuesPtr, u64, self.countValues);
    }

    pub inline fn enums(self: *const ModeGetProperty) ?[]const ModePropertyEnum {
        return if (self.flags.@"enum" == 1) self.fieldPointer(.enumBlobPtr, ModePropertyEnum, self.countEnumBlobs) else null;
    }

    pub inline fn blobValues(self: *const ModeGetProperty) ?[]const u32 {
        return if (self.flags.blob == 1) self.fieldPointer(.valuesPtr, u32, self.countEnumBlobs) else null;
    }

    pub inline fn blobs(self: *const ModeGetProperty) ?[]const u32 {
        return if (self.flags.blob == 1) self.fieldPointer(.enumBlobPtr, u32, self.countEnumBlobs) else null;
    }
};
