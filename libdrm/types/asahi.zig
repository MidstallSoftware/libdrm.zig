const std = @import("std");
const Allocator = std.mem.Allocator;
const os = @import("../os.zig");

pub const ParamsGlobal = extern struct {
    features: u64,
    gpu_generation: u32,
    gpu_variant: u32,
    gpu_revision: u32,
    chip_id: u32,
    num_dies: u32,
    num_clusters_total: u32,
    num_cores_per_cluster: u32,
    max_frequency_khz: u32,
    core_masks: [64]u64,
    vm_start: u64,
    vm_end: u64,
    vm_kernel_min_size: u64,
    max_commands_per_submission: u32,
    max_attachments: u32,
    command_timestamp_frequency_hz: u64,
};

pub const GetParams = extern struct {
    group: u32,
    pad: u32 = 0,
    pointer: u64,
    size: u64,

    pub const req = os.IOCTL.IOWR(0x40, GetParams);

    pub fn get(self: *GetParams, fd: std.posix.fd_t) !void {
        return switch (std.posix.errno(os.ioctl(fd, req, @intFromPtr(self)))) {
            .SUCCESS => {},
            .ACCES => error.AccessDenied,
            .PERM => error.PermissionDenied,
            .BADF => error.NotOpenForWriting,
            .NOENT => error.NotFound,
            .FAULT => unreachable,
            .INVAL => unreachable,
            .NOTTY => error.NotATerminal,
            .OPNOTSUPP => error.NotSupported,
            else => |e| std.posix.unexpectedErrno(e),
        };
    }
};

pub const GetTime = extern struct {
    flags: u64 = 0,
    gpu_timestamp: u64 = 0,

    pub const req = os.IOCTL.IOWR(0x41, GetTime);

    pub fn get(self: *GetTime, fd: std.posix.fd_t) !void {
        return switch (std.posix.errno(os.ioctl(fd, req, @intFromPtr(self)))) {
            .SUCCESS => {},
            .ACCES => error.AccessDenied,
            .PERM => error.PermissionDenied,
            .BADF => error.NotOpenForWriting,
            .NOENT => error.NotFound,
            .FAULT => unreachable,
            .INVAL => unreachable,
            .NOTTY => error.NotATerminal,
            .OPNOTSUPP => error.NotSupported,
            else => |e| std.posix.unexpectedErrno(e),
        };
    }
};
