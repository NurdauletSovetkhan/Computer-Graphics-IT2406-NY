# Makefile for Spheres Merging Visualization Project
# Компилятор и флаги
CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -O2
DEBUGFLAGS = -g -DDEBUG

# Директории
SRC_DIR = src
BUILD_DIR = build
SHADER_DIR = shaders
LIB_DIR = $(SRC_DIR)/Libraries

# Пути к заголовочным файлам
INCLUDES = -I$(LIB_DIR)/include -I$(SRC_DIR)

# Библиотеки для линковки
LIBS = -L$(LIB_DIR)/lib -lglfw3 -lopengl32 -lgdi32 -luser32

# Исходные файлы
SOURCES = $(SRC_DIR)/main.cpp $(SRC_DIR)/utilities.cpp $(SRC_DIR)/glad.c
OBJECTS = $(BUILD_DIR)/main.o $(BUILD_DIR)/utilities.o $(BUILD_DIR)/glad.o

# Целевой исполняемый файл
TARGET = $(BUILD_DIR)/final-project.exe

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
	@if not exist "$(BUILD_DIR)" mkdir "$(BUILD_DIR)"
	@if not exist "$(BUILD_DIR)\shaders" mkdir "$(BUILD_DIR)\shaders"

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
	@copy "$(SHADER_DIR)\marching_cubes.vert" "$(BUILD_DIR)\shaders\" > nul 2>&1
	@copy "$(SHADER_DIR)\marching_cubes.geom" "$(BUILD_DIR)\shaders\" > nul 2>&1
	@copy "$(SHADER_DIR)\marching_cubes.frag" "$(BUILD_DIR)\shaders\" > nul 2>&1
	@echo "Shaders copied successfully!"

# Запуск программы
run: $(TARGET)
	@echo "Running application..."
	@cd $(BUILD_DIR) && final-project.exe

# Очистка файлов сборки
clean:
	@echo "Cleaning build files..."
	@if exist "$(BUILD_DIR)\*.o" del /q "$(BUILD_DIR)\*.o"
	@if exist "$(BUILD_DIR)\*.exe" del /q "$(BUILD_DIR)\*.exe"
	@if exist "$(BUILD_DIR)\shaders" rmdir /s /q "$(BUILD_DIR)\shaders"
	@echo "Clean completed!"

# Полная очистка включая директорию сборки
clean-all:
	@echo "Cleaning all build files..."
	@if exist "$(BUILD_DIR)" rmdir /s /q "$(BUILD_DIR)"
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