const std = @import("std");
const builtin = @import("builtin");

pub const primaryDeviceName = switch (builtin.os.tag) {
    .openbsd => "drm",
    .linux => "card",
    else => |t| @compileError("Unsupported OS " ++ @tagName(t)),
};

pub const controlDeviceName = switch (builtin.os.tag) {
    .openbsd => "drmC",
    .linux => "controlD",
    else => |t| @compileError("Unsupported OS " ++ @tagName(t)),
};

pub const renderDeviceName = switch (builtin.os.tag) {
    .openbsd => "drmR",
    .linux => "renderD",
    else => |t| @compileError("Unsupported OS " ++ @tagName(t)),
};
