# Makefile for Spheres Merging Visualization Project
# Определение операционной системы
UNAME_S := $(shell uname -s)

# Компилятор и базовые флаги
CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -O2 -Wno-unused-parameter
DEBUGFLAGS = -g -DDEBUG

# Директории
SRC_DIR = src
BUILD_DIR = build
SHADER_DIR = shaders
LIB_DIR = $(SRC_DIR)/Libraries

# Пути к заголовочным файлам
INCLUDES = -I$(LIB_DIR)/include -I$(SRC_DIR)

# Определение библиотек в зависимости от ОС
ifeq ($(UNAME_S),Linux)
    # Linux настройки
    LIBS = -lglfw -lGL -lGLU -ldl -lpthread -lX11 -lXrandr -lXinerama -lXcursor -lm
    TARGET_EXT = 
    COPY_CMD = cp
    MKDIR_CMD = mkdir -p
    RM_CMD = rm -rf
else ifeq ($(UNAME_S),Darwin)
    # macOS настройки
    LIBS = -lglfw -framework OpenGL -framework Cocoa -framework IOKit -framework CoreVideo
    TARGET_EXT = 
    COPY_CMD = cp
    MKDIR_CMD = mkdir -p
    RM_CMD = rm -rf
else
    # Windows настройки (MinGW/MSYS2)
    LIBS = -L$(LIB_DIR)/lib -lglfw3 -lopengl32 -lgdi32 -luser32
    TARGET_EXT = .exe
    COPY_CMD = copy
    MKDIR_CMD = mkdir
    RM_CMD = rmdir /s /q
endif

# Исходные файлы
SOURCES = $(SRC_DIR)/main.cpp $(SRC_DIR)/utilities.cpp $(SRC_DIR)/glad.c
OBJECTS = $(BUILD_DIR)/main.o $(BUILD_DIR)/utilities.o $(BUILD_DIR)/glad.o

# Целевой исполняемый файл
TARGET = $(BUILD_DIR)/final-project$(TARGET_EXT)

# Шейдеры для копирования
SHADERS = $(SHADER_DIR)/marching_cubes.vert $(SHADER_DIR)/marching_cubes.geom $(SHADER_DIR)/marching_cubes.frag

# Цель по умолчанию
.PHONY: all clean debug release run cmake-build cmake-clean install help

all: release

# Релизная сборка
release: CXXFLAGS += -DNDEBUG
release: $(TARGET) copy-shaders

# Отладочная сборка  
debug: CXXFLAGS += $(DEBUGFLAGS)
debug: $(TARGET) copy-shaders

# Создание исполняемого файла
$(TARGET): $(BUILD_DIR) $(OBJECTS)
	@echo "Linking $(TARGET)..."
	$(CXX) $(OBJECTS) -o $(TARGET) $(LIBS)
	@echo "Build completed successfully!"

# Создание директории сборки
$(BUILD_DIR):
	@echo "Creating build directory..."
	@$(MKDIR_CMD) $(BUILD_DIR) 2>/dev/null || true
	@$(MKDIR_CMD) $(BUILD_DIR)/shaders 2>/dev/null || true

# Компиляция main.cpp
$(BUILD_DIR)/main.o: $(SRC_DIR)/main.cpp $(SRC_DIR)/utilities.h
	@echo "Compiling main.cpp..."
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $(SRC_DIR)/main.cpp -o $(BUILD_DIR)/main.o

# Компиляция utilities.cpp
$(BUILD_DIR)/utilities.o: $(SRC_DIR)/utilities.cpp $(SRC_DIR)/utilities.h
	@echo "Compiling utilities.cpp..."
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $(SRC_DIR)/utilities.cpp -o $(BUILD_DIR)/utilities.o

# Компиляция glad.c
$(BUILD_DIR)/glad.o: $(SRC_DIR)/glad.c
	@echo "Compiling glad.c..."
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $(SRC_DIR)/glad.c -o $(BUILD_DIR)/glad.o

# Копирование шейдеров
copy-shaders: $(BUILD_DIR)
	@echo "Copying shaders..."
	@$(COPY_CMD) $(SHADER_DIR)/marching_cubes.vert $(BUILD_DIR)/shaders/ 2>/dev/null || true
	@$(COPY_CMD) $(SHADER_DIR)/marching_cubes.geom $(BUILD_DIR)/shaders/ 2>/dev/null || true
	@$(COPY_CMD) $(SHADER_DIR)/marching_cubes.frag $(BUILD_DIR)/shaders/ 2>/dev/null || true
	@echo "Shaders copied successfully!"

# Запуск программы
run: $(TARGET)
	@echo "Running application..."
	@cd $(BUILD_DIR) && ./final-project$(TARGET_EXT)

# Очистка файлов сборки
clean:
	@echo "Cleaning build files..."
	@$(RM_CMD) $(BUILD_DIR)/*.o 2>/dev/null || true
	@$(RM_CMD) $(BUILD_DIR)/final-project$(TARGET_EXT) 2>/dev/null || true
	@$(RM_CMD) $(BUILD_DIR)/shaders 2>/dev/null || true
	@echo "Clean completed!"

# Полная очистка включая директорию сборки
clean-all:
	@echo "Cleaning all build files..."
	@$(RM_CMD) $(BUILD_DIR) 2>/dev/null || true
	@echo "Full clean completed!"

# Сборка с помощью CMake (рекомендуется)
cmake-build:
	@echo "Building with CMake..."
	@if not exist "build" mkdir build
	@cd build && cmake .. -G "Visual Studio 17 2022" -A x64
	@cd build && cmake --build . --config Debug
	@echo "CMake build completed!"

# Очистка CMake файлов
cmake-clean:
	@echo "Cleaning CMake build files..."
	@if exist "build\CMakeCache.txt" del /q "build\CMakeCache.txt"
	@if exist "build\CMakeFiles" rmdir /s /q "build\CMakeFiles"
	@echo "CMake clean completed!"

# Установка зависимостей (информационная цель)
install:
	@echo "Dependencies installation guide:"
	@echo "1. GLFW: Download from https://www.glfw.org/download.html"
	@echo "2. GLM: Download from https://github.com/g-truc/glm/releases"
	@echo "3. GLAD: Generate from https://glad.dav1d.de/"
	@echo "4. Place libraries in src/Libraries/ directory"
	@echo "5. Ensure Visual Studio or MinGW-w64 is installed"

# Помощь по использованию
help:
	@echo "Available targets:"
	@echo "  all          - Build release version (default)"
	@echo "  release      - Build optimized release version"
	@echo "  debug        - Build debug version with symbols"
	@echo "  run          - Build and run the application"
	@echo "  clean        - Remove object files and executable"
	@echo "  clean-all    - Remove entire build directory"
	@echo "  cmake-build  - Build using CMake (recommended)"
	@echo "  cmake-clean  - Clean CMake generated files"
	@echo "  install      - Show dependency installation guide"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Example usage:"
	@echo "  make release   # Build optimized version"
	@echo "  make debug     # Build debug version"
	@echo "  make run       # Build and run"
	@echo "  make clean     # Clean build files"

# Переменные окружения для отладки
print-vars:
	@echo "Build configuration:"
	@echo "CXX = $(CXX)"
	@echo "CXXFLAGS = $(CXXFLAGS)"
	@echo "INCLUDES = $(INCLUDES)"
	@echo "LIBS = $(LIBS)"
	@echo "SOURCES = $(SOURCES)"
	@echo "TARGET = $(TARGET)"