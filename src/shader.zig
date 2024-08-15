const std = @import("std");
const c = @import("c.zig");

const panic = @import("panic.zig").panic;

/// Compile shader from string.
pub fn compileShader(shader_source: []const u8, shader_type: u32) u32 {
    var shader: u32 = undefined;
    shader = c.glCreateShader(shader_type);

    c.glShaderSource(shader, 1, @ptrCast(&shader_source), 0);
    c.glCompileShader(shader);

    var success: c_int = undefined;
    c.glGetShaderiv(shader, c.GL_COMPILE_STATUS, &success);

    if (success != c.GL_TRUE) {
        var log: [512]u8 = undefined;
        c.glGetShaderInfoLog(shader, 512, 0, @ptrCast(&log));
        // TODO: figure out how to set text error and return error here.
        panic("Shader compilation failed: {s}", .{log});
    }

    return shader;
}

/// Link vertex and fragment shaders into a program.
pub fn createProgram(vertex_shader: u32, fragment_shader: u32) u32 {
    var program: u32 = undefined;
    program = c.glCreateProgram();

    c.glAttachShader(program, vertex_shader);
    c.glAttachShader(program, fragment_shader);
    c.glLinkProgram(program);

    var success: i32 = undefined;
    var log: [512]u8 = undefined;
    c.glGetProgramiv(program, c.GL_LINK_STATUS, &success);

    if (success != c.GL_TRUE) {
        c.glGetProgramInfoLog(program, 512, 0, @ptrCast(&log));
        // TODO: figure out how to set text error and return error here.
        panic("Program linking failed: {s}", .{log});
    }

    c.glDeleteShader(vertex_shader);
    c.glDeleteShader(fragment_shader);

    return program;
}

pub inline fn getAttributeLocation(program: u32, size: i32, name: []const u8) i32 {
    const location = c.glGetAttribLocation(program, @ptrCast(name));

    if (location == -1) {
        // TODO: figure out how to set text error and return error here.
        panic("Failed to get a uniform location \"{s}\".", .{name});
    }

    c.glEnableVertexAttribArray(@intCast(location));
    c.glVertexAttribPointer(@intCast(location), size, c.GL_FLOAT, c.GL_FALSE, 0, @ptrFromInt(0));

    return location;
}

pub inline fn getUniformLocation(program: u32, name: []const u8) i32 {
    const location = c.glGetUniformLocation(program, @ptrCast(name));

    if (location == -1) {
        // TODO: figure out how to set text error and return error here.
        panic("Failed to get a uniform location \"{s}\". Make sure it is _used_ in the shader.", .{name});
    }

    return location;
}
