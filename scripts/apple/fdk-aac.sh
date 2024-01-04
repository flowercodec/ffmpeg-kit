#!/bin/bash

# ALWAYS CLEAN THE PREVIOUS BUILD
git clean -dfx 2>/dev/null 1>/dev/null

# OVERRIDE SYSTEM PROCESSOR
PLATFORM=""
case ${ARCH} in
arm64 | arm64e)
  # OS64 or SIMULATORARM64
  PLATFORM="OS64"
  ;;
arm64-simulator)
  PLATFORM="SIMULATORARM64"
  ;;
x86-64)
  # SIMULATOR64
  PLATFORM="SIMULATOR64"
  ;;
esac

# ios-cmake 目录与 ffmpeg-kit 目录平级

cmake -Wno-dev \
 -G "Unix Makefiles" \
 -DCMAKE_TOOLCHAIN_FILE=../../../ios-cmake/ios.toolchain.cmake \
 -DPLATFORM="${PLATFORM}" \
 -DBUILD_SHARED_LIBS=OFF \
 -DBUILD_PROGRAMS=OFF \
 -DCMAKE_INSTALL_PREFIX="${LIB_INSTALL_PREFIX}" \
 -DDEPLOYMENT_TARGET=11.0 || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# CREATE PACKAGE CONFIG MANUALLY

cp ${LIB_INSTALL_PREFIX}/lib/pkgconfig/fdk-aac.pc ${LIB_INSTALL_PREFIX}/../pkgconfig/fdk-aac.pc || return 1