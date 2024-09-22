cmake_minimum_required(VERSION 3.16)

project(AdeptTestWidgets VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Widgets Sql Core HttpServer)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Widgets Sql Core HttpServer)

set(PROJECT_SOURCES
        MainWindow.ui

        main.cpp

        MainWindow.h
        MainWindow.cpp

        DataBase/DBManager.h
        DataBase/DBManager.cpp

        DataBase/QueryExecutor.h
        DataBase/QueryExecutor.cpp

        Server/AdeptServer.h
        Server/AdeptServer.cpp
)

qt_add_executable(AdeptTestWidgets
    MANUAL_FINALIZATION
    ${PROJECT_SOURCES}
)

target_link_libraries(AdeptTestWidgets PRIVATE
    Qt${QT_VERSION_MAJOR}::Widgets
    Qt${QT_VERSION_MAJOR}::Sql
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::HttpServer
)

if(QT_VERSION_MAJOR EQUAL 6)
    qt_finalize_executable(AdeptTestWidgets)
endif()
