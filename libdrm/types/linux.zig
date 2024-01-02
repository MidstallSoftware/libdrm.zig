const std = @import("std");
const Allocator = std.mem.Allocator;

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

    pub const req = std.os.linux.IOCTL.IOWR('d', 0, Version);

    pub fn get(self: *Version, fd: std.os.fd_t) !void {
        return switch (std.os.linux.getErrno(std.os.linux.ioctl(fd, req, @intFromPtr(self)))) {
            .SUCCESS => {},
            .BADF => error.NotOpenForWriting,
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
