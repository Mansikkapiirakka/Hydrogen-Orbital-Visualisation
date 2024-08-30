A simple OpenGL and zig based project for rendering hydrogen atom orbitals.

## Building the project

* Install the [zig compiler](https://github.com/ziglang/zig)
* Open your command-linel and run the command `zig build run` in the root directory

## OS support

Currently only windows is supported natively.
On linux the program should run using wine.

## Known issues

The shaders were tested using an NVIDIA GPU(GTX 1060).
NVIDIAs shader compiler is very lenient and will compile shaders that do not meet the [specification](https://registry.khronos.org/OpenGL/specs/gl/GLSLangSpec.4.50.pdf).
This might lead to a failure to compile the shaders on non NVIDIA GPUs.
The error message for the shader compiler is printed in the terminal. You will have to modify the shader code using the error messages as your guide.

## Currently available orbitals

### 1S orbital

(l = 0, m = 0)

![image](https://github.com/user-attachments/assets/daa4b765-eff7-4bee-914f-dd0c5db18987)

### 2S orbital

(l = 0, m = 0)

![image](https://github.com/user-attachments/assets/7c8336e3-d9e2-47cf-b394-8b3526135e3c)

### 2S orbital

(l = 1, m = 0)

![image](https://github.com/user-attachments/assets/e1411e41-521d-4c99-951b-f49ae0aeaa21)

### 3S orbital

(l = 1, m = 0)

![image](https://github.com/user-attachments/assets/517e54fe-db85-4938-854e-728accb4eaff)
