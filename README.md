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
