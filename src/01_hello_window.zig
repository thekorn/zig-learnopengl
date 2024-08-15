const std = @import("std");
const c = @import("c.zig");

pub fn main() !void {
    const width = 800;
    const height = 600;

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

    //_ = c.glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    while (c.glfwWindowShouldClose(window) == c.GL_FALSE) {
        processInput(window);
        c.glClearColor(0.2, 0.3, 0.3, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);

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
