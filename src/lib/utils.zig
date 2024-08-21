const std = @import("std");
const c = @import("c.zig");

pub fn debug_max_vertex_attributes() void {
    // FIXME: mocking, as this is crashing with segfault
    //var max_vertex_attributes: c_int = 0;
    //c.glGetIntegerv(c.GL_MAX_VERTEX_ATTRIBS, &max_vertex_attributes);
    const max_vertex_attributes = 16;
    std.debug.print("Maximum nr of vertex attributes supported: {d}\n", .{max_vertex_attributes});
}
