cmake_minimum_required(VERSION 3.25)

project(minimal-latex-studio
    VERSION 0.1.0
    DESCRIPTION "LiTeX, a native minimal LaTeX editor, compiler, PDF previewer, and terminal"
    HOMEPAGE_URL "https://github.com/pportilla/minimal-latex-studio"
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_AUTOMOC ON)

include(GNUInstallDirs)
include(CTest)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets)
find_package(PkgConfig REQUIRED)
pkg_check_modules(POPPLER_QT6 REQUIRED IMPORTED_TARGET poppler-qt6)
find_package(qtermwidget6 REQUIRED)

add_executable(minimal-latex-studio
    src/main.cpp
)

target_compile_definitions(minimal-latex-studio
    PRIVATE
        APP_VERSION="${PROJECT_VERSION}"
)

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(minimal-latex-studio
        PRIVATE
            -Wall
            -Wextra
            -Wpedantic
    )
endif()

target_link_libraries(minimal-latex-studio
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Widgets
        PkgConfig::POPPLER_QT6
        qtermwidget6
)

install(TARGETS minimal-latex-studio
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
)

install(FILES resources/applications/io.github.pportilla.minimal-latex-studio.desktop
    DESTINATION "${CMAKE_INSTALL_DATADIR}/applications"
)

install(FILES resources/minimal-latex-studio.svg
    DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/scalable/apps"
)

install(FILES resources/themes/smart-modern.json
    DESTINATION "${CMAKE_INSTALL_DATADIR}/minimal-latex-studio/themes"
)

install(FILES resources/metainfo/io.github.pportilla.minimal-latex-studio.metainfo.xml
    DESTINATION "${CMAKE_INSTALL_DATADIR}/metainfo"
)

if(BUILD_TESTING)
    find_program(DESKTOP_FILE_VALIDATE desktop-file-validate)
    if(DESKTOP_FILE_VALIDATE)
        add_test(
            NAME validate-desktop-file
            COMMAND "${DESKTOP_FILE_VALIDATE}"
                    "${CMAKE_CURRENT_SOURCE_DIR}/resources/applications/io.github.pportilla.minimal-latex-studio.desktop"
        )
    endif()

    find_program(APPSTREAMCLI appstreamcli)
    if(APPSTREAMCLI)
        add_test(
            NAME validate-appstream-metadata
            COMMAND "${APPSTREAMCLI}" validate --no-net
                    "${CMAKE_CURRENT_SOURCE_DIR}/resources/metainfo/io.github.pportilla.minimal-latex-studio.metainfo.xml"
        )
    endif()
endif()
