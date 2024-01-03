const std = @import("std");
const libdrm = @import("libdrm");

const alloc = std.heap.page_allocator;

pub fn main() !void {
    var iter = libdrm.Node.Iterator.init(alloc, .primary);

    while (iter.next()) |node| {
        defer node.deinit();

        const version = try node.getVersion();
        defer version.deinit(alloc);

        const modeCardRes = node.getModeCardRes() catch continue;
        defer modeCardRes.deinit(alloc);

        if (modeCardRes.connectorIds()) |connectorIds| {
            for (connectorIds) |connectorId| {
                const connector = try node.getConnector(connectorId);
                defer connector.deinit(alloc);

                const encoder = node.getEncoder(connector.encoderId) catch null;

                std.debug.print("{} {?}\n", .{ connector, encoder });
            }
        }

        if (modeCardRes.crtcIds()) |crtcIds| {
            for (crtcIds) |crtcId| {
                const crtc = try node.getCrtc(crtcId);
                std.debug.print("{}\n", .{crtc});
            }
        }

        std.debug.print("{} {} {}\n", .{ node, version, modeCardRes });
    }
}
