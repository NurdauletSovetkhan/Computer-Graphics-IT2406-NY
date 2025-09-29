# Installation Guide for Linux

## Prerequisites

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install build-essential cmake git

# Install GLFW dependencies
sudo apt install libglfw3-dev libglfw3

# Install OpenGL development libraries
sudo apt install mesa-utils libglu1-mesa-dev freeglut3-dev mesa-common-dev

# Install X11 dependencies
sudo apt install libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev

# Additional dependencies
sudo apt install libgl1-mesa-dev libglu1-mesa-dev
```

### Fedora/RHEL/CentOS
```bash
sudo dnf groupinstall "Development Tools"
sudo dnf install cmake git

# Install GLFW
sudo dnf install glfw-devel

# Install OpenGL libraries
sudo dnf install mesa-libGL-devel mesa-libGLU-devel

# Install X11 dependencies
sudo dnf install libXrandr-devel libXinerama-devel libXcursor-devel libXi-devel
```

### Arch Linux
```bash
sudo pacman -S base-devel cmake git
sudo pacman -S glfw-x11 mesa glu
sudo pacman -S libxrandr libxinerama libxcursor libxi
```

## GLM Installation

GLM is header-only, you can install it via package manager or manually:

### Via Package Manager
```bash
# Ubuntu/Debian
sudo apt install libglm-dev

# Fedora
sudo dnf install glm-devel

# Arch
sudo pacman -S glm
```

### Manual Installation
```bash
# Download GLM
cd ~/Downloads
git clone https://github.com/g-truc/glm.git
cd glm

# Copy headers to your project
cp -r glm/ /path/to/your/project/src/Libraries/include/
```

## Building the Project

### Option 1: Using the Updated Makefile
```bash
# Clone the project
git clone <your-repo-url>
cd final-project

# Build
make release

# Or build debug version
make debug

# Run
make run
```

### Option 2: Using CMake (Recommended)
```bash
mkdir build && cd build
cmake ..
make -j$(nproc)

# Run
./final-project
```

## Troubleshooting

### Missing GLFW
If you get linker errors about GLFW:
```bash
# Try installing development package
sudo apt install libglfw3-dev  # Ubuntu/Debian
sudo dnf install glfw-devel     # Fedora
sudo pacman -S glfw-x11         # Arch
```

### Missing OpenGL
If you get OpenGL related errors:
```bash
# Install Mesa development packages
sudo apt install mesa-common-dev libgl1-mesa-dev
```

### X11 Related Issues
```bash
# Make sure X11 development packages are installed
sudo apt install xorg-dev
```

### Runtime Issues
If the program fails to run:
```bash
# Check if you have proper graphics drivers
glxinfo | grep "OpenGL version"

# For NVIDIA users, you might need
sudo apt install nvidia-driver-xxx  # Replace xxx with your driver version

# For AMD users
sudo apt install mesa-vulkan-drivers
```

## Project Structure After Setup
```
final-project/
├── build/                 # Build directory (created after compilation)
│   ├── final-project     # Executable (Linux)
│   └── shaders/          # Copied shader files
├── src/
│   ├── main.cpp
│   ├── utilities.cpp
│   ├── utilities.h
│   ├── glad.c
│   └── Libraries/        # Not needed for Linux system packages
├── shaders/              # Original shader files
├── Makefile             # Cross-platform Makefile
├── CMakeLists.txt       # CMake configuration
└── README.md
```

## Notes

- The updated Makefile automatically detects your OS (Linux/macOS/Windows)
- On Linux, it uses system-installed libraries instead of bundled ones
- GLAD source is included in the project, so you don't need to install it separately
- Make sure your graphics drivers support OpenGL 4.3 or higher