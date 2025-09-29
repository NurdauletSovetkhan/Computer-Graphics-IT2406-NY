# final-project/CMakeLists.txt

cmake_minimum_required(VERSION 3.10)
project(final-project C CXX)

# Установка стандартов C++: чисто и современно
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# --- Настройка Вывода (Сразу куда надо) ---
# Настраиваем директории вывода для всех целей в проекте. 
# CMake будет использовать CMAKE_BUILD_TYPE (Debug/Release) автоматически.
# Результат будет в: build/Debug/final-project.exe
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}/Debug")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/Release")

# --- Исходники и Исполняемый файл ---
# Исходники лежат в папке src
add_executable(final-project 
    ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp 
    ${CMAKE_CURRENT_SOURCE_DIR}/src/utilities.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/glad.c
)

# --- Пути Заголовков (Header Paths) ---
# Используем target_include_directories, чтобы не засорять глобальное пространство.
target_include_directories(final-project 
    PRIVATE 
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Libraries/include  # Для GLFW/GLM
    ${CMAKE_CURRENT_SOURCE_DIR}/src                    # Для доступа к собственным хедерам (если есть)
) 

# --- Линковка (Libraries) ---
# PRIVATE означает, что линковка нужна только этой цели (final-project)
target_link_libraries(final-project 
    PRIVATE
    # Здесь предполагается, что glfw3.lib лежит в src/Libraries/lib/
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Libraries/lib/glfw3.lib
    opengl32 
    Gdi32 
    User32
)

# --- Копирование Шейдеров ---
# Копируем шейдеры в папку сборки для правильной работы приложения
file(COPY 
    ${CMAKE_CURRENT_SOURCE_DIR}/shaders/
    DESTINATION 
    ${CMAKE_BINARY_DIR}/Debug/shaders/
)