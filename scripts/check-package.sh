#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"

cmake -B build -S . -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build
ctest --test-dir build --output-on-failure
clang-tidy src/main.cpp -p build --removed-arg=-mno-direct-extern-access --quiet
desktop-file-validate resources/applications/io.github.pportilla.litex-editor.desktop
appstreamcli validate --no-net resources/metainfo/io.github.pportilla.litex-editor.metainfo.xml
namcap packaging/arch/PKGBUILD
