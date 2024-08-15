const std = @import("std");

fn linkLibs(exe: *std.Build.Step.Compile) void {
    const framework_path: std.Build.LazyPath = .{ .cwd_relative = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks" };

    exe.linkLibC();
    exe.linkSystemLibrary("glfw");
    exe.linkFramework("OpenGL");
    exe.addSystemFrameworkPath(framework_path);
}

const SubCommand = struct {
    name: []const u8,
    src: std.Build.LazyPath,
    description: []const u8,

    pub fn build(self: SubCommand, alloc: std.mem.Allocator, b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !void {
        const exe = b.addExecutable(.{
            .name = self.name,
            .root_source_file = self.src,
            .target = target,
            .optimize = optimize,
        });

        linkLibs(exe);
        b.installArtifact(exe);
        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const alloc_buf = try std.fmt.allocPrint(alloc, "Run {s}", .{self.name});

        defer alloc.free(alloc_buf);

        const run_step = b.step(self.name, alloc_buf);
        run_step.dependOn(&run_cmd.step);

        //const exe_unit_tests = b.addTest(.{
        //    .root_source_file = b.path("src/main.zig"),
        //    .target = target,
        //    .optimize = optimize,
        //});

        //const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
        //const test_step = b.step("test", "Run unit tests");
        //test_step.dependOn(&run_exe_unit_tests.step);
    }
};

pub fn build(b: *std.Build) void {
    const commands = [_]SubCommand{.{ .name = "hello_window", .src = b.path("src/01_hello_window.zig"), .description = "Hello GLFW Window" }};
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const alloc = gpa.allocator();

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    for (commands) |cmd| {
        cmd.build(alloc, b, target, optimize) catch std.log.err("Failed to build: {s}", .{cmd.name});
    }
}
