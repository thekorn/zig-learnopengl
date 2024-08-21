// https://learnopengl.com/Getting-started/Hello-Window

const std = @import("std");
const c = @import("lib/c.zig");
const utils = @import("lib/utils.zig");

const vertexShaderSource: [:0]const u8 =
    \\#version 330 core
    \\layout (location = 0) in vec3 aPos;
    \\
    \\out vec4 vertexColor;
    \\
    \\void main()
    \\{
    \\   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
    \\   vertexColor = vec4(0.5, 0.0, 0.0, 1.0);
    \\}
;

const fragmentShaderSource: [:0]const u8 =
    \\#version 330 core
    \\out vec4 FragColor;
    \\
    \\uniform vec4 ourColor;
    \\
    \\void main()
    \\{
    \\   FragColor = ourColor;
    \\}
;

pub fn main() !void {
    const width = 800;
    const height = 600;

    const vertices = [9]f32{
        -0.5, -0.5, 0.0,
        0.5,  -0.5, 0.0,
        0.0,  0.5,  0.0,
    };

    if (c.glfwInit() == c.GL_FALSE) {
        std.debug.panic("Failed to initialize GLFW", .{});
    }
    defer c.glfwTerminate();

    utils.debug_max_vertex_attributes();

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);

    // Needed on MacOS.
    c.glfwWindowHint(c.GLFW_OPENGL_FORWARD_COMPAT, c.GL_TRUE);

    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    const window = c.glfwCreateWindow(width, height, "LearnOpenGL", null, null) orelse {
        std.log.err("Failed to create window", .{});
        return error.FailedToCreateWindow;
    };
    c.glfwMakeContextCurrent(window);

    _ = c.glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    var vbo: u32 = undefined;
    c.glGenBuffers(1, &vbo);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);
    c.glBufferData(c.GL_ARRAY_BUFFER, @intCast(vertices.len * @sizeOf(f32)), &vertices, c.GL_STATIC_DRAW);

    const vertexShader = c.glCreateShader(c.GL_VERTEX_SHADER);
    const vertexSrcPtr: ?[*]const u8 = vertexShaderSource.ptr;
    c.glShaderSource(vertexShader, 1, &vertexSrcPtr, null);
    c.glCompileShader(vertexShader);

    var success: c_int = undefined;
    c.glGetShaderiv(vertexShader, c.GL_COMPILE_STATUS, &success);
    if (success == c.GL_FALSE) {
        var infoLog: [512]u8 = undefined;
        c.glGetShaderInfoLog(vertexShader, 512, null, &infoLog);
        std.debug.print("ERROR::SHADER::VERTEX::COMPILATION_FAILED\n{s}\n", .{infoLog});
        return error.FailedToCompileShader;
    }

    const fragmentShader = c.glCreateShader(c.GL_FRAGMENT_SHADER);
    const fragmentSrcPtr: ?[*]const u8 = fragmentShaderSource.ptr;
    c.glShaderSource(fragmentShader, 1, &fragmentSrcPtr, null);
    c.glCompileShader(fragmentShader);

    c.glGetShaderiv(fragmentShader, c.GL_COMPILE_STATUS, &success);
    if (success == c.GL_FALSE) {
        var infoLog: [512]u8 = undefined;
        c.glGetShaderInfoLog(fragmentShader, 512, null, &infoLog);
        std.debug.print("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n{s}\n", .{infoLog});
        return error.FailedToCompileShader;
    }

    const shaderProgram = c.glCreateProgram();
    c.glAttachShader(shaderProgram, vertexShader);
    c.glAttachShader(shaderProgram, fragmentShader);
    c.glLinkProgram(shaderProgram);

    c.glGetProgramiv(shaderProgram, c.GL_LINK_STATUS, &success);
    if (success == c.GL_FALSE) {
        var infoLog: [512]u8 = undefined;
        c.glGetProgramInfoLog(shaderProgram, 512, null, &infoLog);
        std.debug.print("ERROR::SHADER::PROGRAM::LINKING_FAILED\n{s}\n", .{infoLog});
        return error.FailedToLinkShaderProgram;
    }
    c.glDeleteShader(vertexShader);
    c.glDeleteShader(fragmentShader);

    var vao: u32 = undefined;
    c.glGenVertexArrays(1, &vao);
    c.glBindVertexArray(vao);

    c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);
    c.glBufferData(c.GL_ARRAY_BUFFER, @intCast(vertices.len * @sizeOf(f32)), &vertices, c.GL_STATIC_DRAW);
    c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 3 * @sizeOf(f32), null);
    c.glEnableVertexAttribArray(0);

    while (c.glfwWindowShouldClose(window) == c.GL_FALSE) {
        processInput(window);
        c.glClearColor(0.2, 0.3, 0.3, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);

        c.glUseProgram(shaderProgram);

        const time_value = c.glfwGetTime();
        const green_value: f32 = @floatCast((@sin(time_value) / 2.0) + 0.5);
        const vertexColorLocation = c.glGetUniformLocation(shaderProgram, "ourColor");
        c.glUniform4f(vertexColorLocation, 0.0, green_value, 0.0, 1.0);

        c.glBindVertexArray(vao);
        c.glDrawArrays(c.GL_TRIANGLES, 0, 3);

        // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
        // -------------------------------------------------------------------------------
        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }
}

fn processInput(window: *c.GLFWwindow) void {
    if (c.glfwGetKey(window, c.GLFW_KEY_ESCAPE) == c.GLFW_PRESS) {
        c.glfwSetWindowShouldClose(window, c.GL_TRUE);
    }
}

fn framebuffer_size_callback(window: ?*c.GLFWwindow, width: c_int, height: c_int) callconv(.C) void {
    _ = window;
    c.glViewport(0, 0, @intCast(width), @intCast(height));
}
