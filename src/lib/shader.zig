const std = @import("std");
const c = @import("c.zig");

fn check_shader_error(shader: u32) !void {
    var success: c_int = undefined;
    c.glGetShaderiv(shader, c.GL_COMPILE_STATUS, &success);
    if (success == c.GL_FALSE) {
        var infoLog: [512]u8 = undefined;
        c.glGetShaderInfoLog(shader, 512, null, &infoLog);
        std.debug.print("ERROR::SHADER::COMPILATION_FAILED\n{s}\n", .{infoLog});
        return error.FailedToCompileShader;
    }
}

fn check_program_error(program: u32) !void {
    var success: c_int = undefined;
    c.glGetProgramiv(program, c.GL_LINK_STATUS, &success);
    if (success == c.GL_FALSE) {
        var infoLog: [512]u8 = undefined;
        c.glGetProgramInfoLog(program, 512, null, &infoLog);
        std.debug.print("ERROR::SHADER::PROGRAM::LINKING_FAILED\n{s}\n", .{infoLog});
        return error.FailedToLinkProgram;
    }
}

pub const Shader = struct {
    program_id: u32,

    pub fn create(vert_code: [:0]const u8, frag_code: [:0]const u8) !Shader {
        const vertexShader = c.glCreateShader(c.GL_VERTEX_SHADER);
        defer c.glDeleteShader(vertexShader);

        const vert_src_ptr: ?[*]const u8 = vert_code.ptr;
        c.glShaderSource(vertexShader, 1, &vert_src_ptr, null);
        c.glCompileShader(vertexShader);

        try check_shader_error(vertexShader);

        const fragmentShader = c.glCreateShader(c.GL_FRAGMENT_SHADER);
        defer c.glDeleteShader(fragmentShader);

        const fragmentSrcPtr: ?[*]const u8 = frag_code.ptr;
        c.glShaderSource(fragmentShader, 1, &fragmentSrcPtr, null);
        c.glCompileShader(fragmentShader);

        try check_shader_error(fragmentShader);

        const shaderProgram = c.glCreateProgram();
        c.glAttachShader(shaderProgram, vertexShader);
        c.glAttachShader(shaderProgram, fragmentShader);
        c.glLinkProgram(shaderProgram);
        try check_program_error(shaderProgram);

        return .{
            .program_id = shaderProgram,
        };
    }
    pub fn deinit(self: *Shader) void {
        c.glDeleteProgram(self.program_id);
    }
    pub fn use(self: *Shader) void {
        c.glUseProgram(self.program_id);
    }
    pub fn set_bool(self: *Shader, name: []const u8, value: bool) void {
        c.glUniform1i(c.glGetUniformLocation(self.program_id, name.ptr), value);
    }
    pub fn set_int(self: *Shader, name: []const u8, value: i32) void {
        c.glUniform1i(c.glGetUniformLocation(self.program_id, name.ptr), value);
    }
    pub fn set_float(self: *Shader, name: []const u8, value: f32) void {
        c.glUniform1f(c.glGetUniformLocation(self.program_id, name.ptr), value);
    }
    pub fn set_vec4_float(self: *Shader, name: []const u8, r: f32, g: f32, b: f32, a: f32) void {
        c.glUniform4f(c.glGetUniformLocation(self.program_id, name.ptr), r, g, b, a);
    }
};
