# learnOpenGL in zig

My journey following the [learnOpenGL](https://learnopengl.com/) tutorials in zig.

## Run each chapter

```bash
$ zig build hello_window
```

## development

In order to make  implementation easier, translate the c code to zig:

```bash
$ zig translate-c $(pkg-config --cflags glfw3) src/cImports.h  > translated_c.zig
```

In order to create a local env, with proper versions of zig, zls and glfw you can use nix to create a dev shell

```bash
$ nix develop -c zsh
```

## debugging using lldb

run bin using lldb

```bash
$ lldb ./zig-out/bin/shaders_6.7
(lldb) target create "./zig-out/bin/shaders_6.7"
Current executable set to '/Users/thekorn/devel/github.com/thekorn/zig-learnopengl/zig-out/bin/shaders_6.7' (arm64).
(lldb) breakpoint set -f shader.zig -l 38
Breakpoint 1: where = shaders_6.7`lib.shader.Shader.create + 220 at shader.zig:39:48, address = 0x0000000100001404
(lldb) r
Process 45400 launched: '/Users/thekorn/devel/github.com/thekorn/zig-learnopengl/zig-out/bin/shaders_6.7' (arm64)
Maximum nr of vertex attributes supported: 16
2024-08-21 12:53:37.078226+0200 shaders_6.7[45400:2512915] flock failed to lock list file (/var/folders/jj/nppjk2p91652kl8z71xwrxrr0000gn/C//com.apple.metal/16777235_594/functions.list): errno = 35
Process 45400 stopped
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
    frame #0: 0x0000000100001404 shaders_6.7`lib.shader.Shader.create(vert_code=(ptr = "#version 330 core\nlayout(location = 0) in vec3 aPos;\n\nvoid main()\n{\n    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n}\n", len = 123), frag_code=(ptr = "#version 330 core\nout vec4 FragColor;\n\nuniform vec4 ourColor;\n\nvoid main()\n{\n    FragColor = ourColor;\n}\n", len = 105)) at shader.zig:39:48
   36
   37           try check_shader_error(vertexShader);
   38
-> 39           const fragmentShader = c.glCreateShader(c.GL_FRAGMENT_SHADER);
   40           defer c.glDeleteShader(fragmentShader);
   41
   42           const fragmentSrcPtr: ?[*]const u8 = frag_code.ptr;
Target 0: (shaders_6.7) stopped.
(lldb) frame variable
([]u8) vert_code = (ptr = "#version 330 core\nlayout(location = 0) in vec3 aPos;\n\nvoid main()\n{\n    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n}\n", len = 123)
([]u8) frag_code = (ptr = "#version 330 core\nout vec4 FragColor;\n\nuniform vec4 ourColor;\n\nvoid main()\n{\n    FragColor = ourColor;\n}\n", len = 105)
(unsigned int) vertexShader = 1
(unsigned char *) vert_src_ptr = 0x0000000100098f84 "#version 330 core\nlayout(location = 0) in vec3 aPos;\n\nvoid main()\n{\n    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n}\n"
(unsigned int) fragmentShader = 0
(unsigned char *) fragmentSrcPtr = 0x00000001380325a8 ""
(unsigned int) shaderProgram = 1
(lldb)
```
