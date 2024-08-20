// https://learnopengl.com/Getting-started/Hello-Window

const std = @import("std");
const c = @import("c.zig");

const vertexShaderSource: [:0]const u8 =
    \\#version 330 core
    \\layout (location = 0) in vec3 aPos;
    \\void main()
    \\{
    \\   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
    \\}
;

const orangeFragmentShaderSource: [:0]const u8 =
    \\#version 330 core
    \\out vec4 FragColor;
    \\void main()
    \\{
    \\   FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
    \\}
;

const yellowFragmentShaderSource: [:0]const u8 =
    \\#version 330 core
    \\out vec4 FragColor;
    \\void main()
    \\{
    \\   FragColor = vec4(1.0f, 1.0f, 0.2f, 1.0f);
    \\}
;

pub fn main() !void {
    const width = 800;
    const height = 600;

    const first_vertices = [9]f32{
        -1.0, -0.5, 0.0,
        -0.0, -0.5, 0.0,
        -0.5, 0.5,  0.0,
    };

    const second_vertices = [9]f32{
        // second
        0.0, -0.5, 0.0,
        1.0, -0.5, 0.0,
        0.5, 0.5,  0.0,
    };

    if (c.glfwInit() == c.GL_FALSE) {
        std.debug.panic("Failed to initialize GLFW", .{});
    }
    defer c.glfwTerminate();

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

    var vbos: [2]u32 = undefined;
    c.glGenBuffers(2, &vbos);

    var vaos: [2]u32 = undefined;
    c.glGenVertexArrays(2, &vaos);

    c.glBindVertexArray(vaos[0]);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, vbos[0]);
    c.glBufferData(c.GL_ARRAY_BUFFER, @intCast(first_vertices.len * @sizeOf(f32)), &first_vertices, c.GL_STATIC_DRAW);
    c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 3 * @sizeOf(f32), null);
    c.glEnableVertexAttribArray(0);

    c.glBindVertexArray(vaos[1]);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, vbos[1]);
    c.glBufferData(c.GL_ARRAY_BUFFER, @intCast(second_vertices.len * @sizeOf(f32)), &second_vertices, c.GL_STATIC_DRAW);
    c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 3 * @sizeOf(f32), null);
    c.glEnableVertexAttribArray(0);

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

    // orange shader aand program
    const orangeFragmentShader = c.glCreateShader(c.GL_FRAGMENT_SHADER);
    const orangeFragmentSrcPtr: ?[*]const u8 = orangeFragmentShaderSource.ptr;
    c.glShaderSource(orangeFragmentShader, 1, &orangeFragmentSrcPtr, null);
    c.glCompileShader(orangeFragmentShader);

    c.glGetShaderiv(orangeFragmentShader, c.GL_COMPILE_STATUS, &success);
    if (success == c.GL_FALSE) {
        var infoLog: [512]u8 = undefined;
        c.glGetShaderInfoLog(orangeFragmentShader, 512, null, &infoLog);
        std.debug.print("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n{s}\n", .{infoLog});
        return error.FailedToCompileShader;
    }

    const orangeShaderProgram = c.glCreateProgram();
    c.glAttachShader(orangeShaderProgram, vertexShader);
    c.glAttachShader(orangeShaderProgram, orangeFragmentShader);
    c.glLinkProgram(orangeShaderProgram);

    c.glGetProgramiv(orangeShaderProgram, c.GL_LINK_STATUS, &success);
    if (success == c.GL_FALSE) {
        var infoLog: [512]u8 = undefined;
        c.glGetProgramInfoLog(orangeShaderProgram, 512, null, &infoLog);
        std.debug.print("ERROR::SHADER::PROGRAM::LINKING_FAILED\n{s}\n", .{infoLog});
        return error.FailedToLinkShaderProgram;
    }

    // yellow shader aand program
    const yellowFragmentShader = c.glCreateShader(c.GL_FRAGMENT_SHADER);
    const yellowFragmentSrcPtr: ?[*]const u8 = yellowFragmentShaderSource.ptr;
    c.glShaderSource(yellowFragmentShader, 1, &yellowFragmentSrcPtr, null);
    c.glCompileShader(yellowFragmentShader);

    c.glGetShaderiv(yellowFragmentShader, c.GL_COMPILE_STATUS, &success);
    if (success == c.GL_FALSE) {
        var infoLog: [512]u8 = undefined;
        c.glGetShaderInfoLog(yellowFragmentShader, 512, null, &infoLog);
        std.debug.print("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n{s}\n", .{infoLog});
        return error.FailedToCompileShader;
    }

    const yellowShaderProgram = c.glCreateProgram();
    c.glAttachShader(yellowShaderProgram, vertexShader);
    c.glAttachShader(yellowShaderProgram, yellowFragmentShader);
    c.glLinkProgram(yellowShaderProgram);

    c.glGetProgramiv(yellowShaderProgram, c.GL_LINK_STATUS, &success);
    if (success == c.GL_FALSE) {
        var infoLog: [512]u8 = undefined;
        c.glGetProgramInfoLog(yellowShaderProgram, 512, null, &infoLog);
        std.debug.print("ERROR::SHADER::PROGRAM::LINKING_FAILED\n{s}\n", .{infoLog});
        return error.FailedToLinkShaderProgram;
    }

    c.glDeleteShader(vertexShader);
    c.glDeleteShader(orangeFragmentShader);
    c.glDeleteShader(yellowFragmentShader);

    while (c.glfwWindowShouldClose(window) == c.GL_FALSE) {
        processInput(window);
        c.glClearColor(0.2, 0.3, 0.3, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);

        c.glUseProgram(orangeShaderProgram);
        c.glBindVertexArray(vaos[0]);
        c.glDrawArrays(c.GL_TRIANGLES, 0, 6);

        c.glUseProgram(yellowShaderProgram);
        c.glBindVertexArray(vaos[1]);
        c.glDrawArrays(c.GL_TRIANGLES, 0, 6);

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
