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

                if (connector.props()) |props| {
                    const propValues = connector.propValues().?;

                    for (props, 0..) |propId, i| {
                        const propValueId = propValues[i];

                        var prop: libdrm.types.ModeGetProperty = .{
                            .propId = propId,
                        };
                        try prop.getAllocated(node.fd, alloc);
                        defer prop.deinit(alloc);

                        if (prop.flags.blob == 1) {
                            var blob: libdrm.types.ModeGetBlob = .{
                                .blobId = @intCast(propValueId),
                            };
                            if (blob.getAllocated(node.fd, alloc)) {
                                defer blob.deinit(alloc);

                                std.debug.print("{}\n", .{blob});
                            } else |err| {
                                std.debug.print("{s}\n", .{@errorName(err)});
                            }
                        }

                        std.debug.print("{}\n", .{prop});
                    }
                }

                std.debug.print("{} {?}\n", .{ connector, encoder });
            }
        }

        if (modeCardRes.crtcIds()) |crtcIds| {
            for (crtcIds) |crtcId| {
                const crtc = try node.getCrtc(crtcId);

                const fb = node.getFb2(crtc.fbId) catch null;
                std.debug.print("{} {?}\n", .{ crtc, fb });
            }
        }

        std.debug.print("{} {} {}\n", .{ node, version, modeCardRes });
    }
}
