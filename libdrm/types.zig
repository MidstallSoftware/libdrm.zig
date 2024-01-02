const builtin = @import("builtin");

pub usingnamespace switch (builtin.os.tag) {
    .linux => @import("types/linux.zig"),
    else => |t| @compileError("Unsupported OS " ++ @tagName(t)),
};
