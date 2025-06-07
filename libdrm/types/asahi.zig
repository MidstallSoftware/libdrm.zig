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

    pub const req = os.IOCTL.IOW(0x40, GetParams);

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

pub const VmCreate = extern struct {
    kernel_start: u64,
    kernel_end: u64,
    vm_id: u32 = 0,
    pad: u32 = 0,

    pub const req = os.IOCTL.IOWR(0x42, VmCreate);

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

pub const VmDestroy = extern struct {
    vm_id: u32 = 0,
    pad: u32 = 0,

    pub const req = os.IOCTL.IOW(0x43, VmDestroy);

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

pub const GemCreate = extern struct {
    size: u64,
    flags: Flags = .{},
    vm_id: u32 = 0,
    handle: u32,
    pad: u32 = 0,

    pub const Flags = packed struct(u32) {
        writeback: u1 = 0,
        private: u1 = 0,
        pad: u30 = 0,
    };

    pub const req = os.IOCTL.IOWR(0x45, GemCreate);

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

pub const GemMmapOffset = extern struct {
    handle: u32,
    flags: u32 = 0,
    offset: u64,

    pub const req = os.IOCTL.IOWR(0x46, GemMmapOffset);

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

pub const GemBindOp = extern struct {
    flags: Flags = .{},
    handle: u32,
    offset: u64,
    range: u64,
    addr: u64,

    pub const Flags = packed struct(u32) {
        unbind: u1 = 0,
        read: u1 = 0,
        write: u1 = 0,
        single_page: u1 = 0,
        pad: u28 = 0,
    };
};

pub const VmBind = extern struct {
    vm_id: u32,
    num_binds: u32,
    stride: u32,
    pad: u32 = 0,
    userptr: u64,

    pub const req = os.IOCTL.IOW(0x44, VmBind);

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

pub const GemBindObject = extern struct {
    op: Op,
    flags: Flags,

    pub const Op = enum(u32) {
        bind = 0,
        unbind = 1,
    };

    pub const Flags = packed struct(u32) {
        usage_timestamps: u1 = 0,
        pad: u31 = 0,
    };

    pub const req = os.IOCTL.IOWR(0x46, GemBindObject);

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

pub const QueueCreate = extern struct {
    flags: Flags = .{},
    vm_id: u32 = 0,
    priority: Priority,
    usc_exec_base: u64,

    pub const Flags = packed struct(u32) {
        pad: u32 = 0,
    };

    pub const Priority = enum(u32) {
        low = 0,
        medium = 1,
        high = 2,
        realtime = 3,
    };

    pub const req = os.IOCTL.IOWR(0x48, QueueCreate);

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

pub const QueueDestroy = extern struct {
    queue_id: u32,
    pad: u32 = 0,

    pub const req = os.IOCTL.IOW(0x49, QueueCreate);

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

pub const Sync = extern struct {
    sync_type: Type,
    handle: u32 = 0,
    timeline_value: u64,

    pub const Type = enum(u32) {
        syncobj = 0,
        timeline_syncobj = 1,
    };
};

pub const Command = struct {
    pub const Header = extern struct {
        cmd_type: Type,
        size: u16,
        vdm_barrier: u16,
        cdm_barrier: u16,

        pub const Type = enum(u32) {
            render = 0,
            compute = 1,
            set_vertex_attachments = 2,
            set_fragment_attachments = 3,
            set_compute_attachments = 4,
        };
    };

    pub const Render = extern struct {
        flags: Flags,
        isp_zls_pixels: u32,
        vdm_ctrl_stream_base: u32,
        vertex_helper: HelperProgram,
        fragment_helper: HelperProgram,
        isp_scissor_base: u64,
        isp_dbias_base: u64,
        isp_oclqry_base: u64,
        depth: ZlsBuffer,
        stencil: ZlsBuffer,
        zls_ctrl: u64,
        ppp_multisamplectl: u64,
        sampler_heap: u64,
        ppp_ctrl: u32,
        width_px: u16,
        height_px: u16,
        layers: u16,
        sampler_count: u16,
        utile_width_px: u8,
        utile_height_px: u8,
        samples: u8,
        sample_size_b: u8,
        isp_merge_upper_x: u32,
        isp_merge_upper_y: u32,
        bg: BgEot,
        eot: BgEot,
        partial_bg: BgEot,
        partial_eot: BgEot,
        isp_bgobjdep: u32,
        isp_bgobjvals: u32,
        ts_vtx: Timestamps,
        ts_frag: Timestamps,

        pub const Flags = packed struct(u32) {};
    };

    pub const Compute = extern struct {
        flags: u32,
        sampler_count: u32,
        cdm_ctrl_stream_base: u64,
        cdm_ctrl_stream_end: u64,
        sampler_heap: u64,
        helper: HelperProgram,
        ts: Timestamps,
    };

    pub const HelperProgram = extern struct {
        binary: u32,
        cfg: u32,
        data: u64,
    };

    pub const ZlsBuffer = extern struct {
        base: u64,
        comp_base: u64,
        stride: u32,
        comp_stride: u32,
    };

    pub const BgEot = extern struct {
        usc: u32,
        rsrc_spec: u32,
    };

    pub const Timestamp = extern struct {
        handle: u32,
        offset: u32,
    };

    pub const Timestamps = extern struct {
        start: Timestamp,
        end: Timestamp,
    };
};

pub const Submit = extern struct {
    syncs: u64,
    cmdbuf: u64,
    flags: u32,
    queue_id: u32,
    in_sync_count: u32,
    out_sync_count: u32 = 0,
    cmdbuf_size: u32,
    pad: u32 = 0,

    pub const req = os.IOCTL.IOW(0x4A, Submit);

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

pub const Attachment = extern struct {
    pointer: u64,
    size: u64,
    pad: u32 = 0,
    flags: u32,
};
