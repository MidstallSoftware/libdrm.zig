const std = @import("std");
const libdrm = @import("libdrm");

const alloc = std.heap.page_allocator;

pub fn main() !void {
    var iter = libdrm.Node.Iterator.init(alloc, .primary);

    while (iter.next()) |node| {
        defer node.deinit();

        const version = try node.getVersion();
        defer version.deinit(alloc);

        const busId = try node.getBusId();
        defer alloc.free(busId);

        std.debug.print("{} {}\n", .{ node, version });
    }
}
