#!/bin/bash

# ALWAYS CLEAN THE PREVIOUS BUILD
git clean -dfx 2>/dev/null 1>/dev/null

# OVERRIDE SYSTEM PROCESSOR
SYSTEM_PROCESSOR=""
SYSTEM_LEVEL=21
case ${ARCH} in
arm-v7a | arm-v7a-neon)
  SYSTEM_PROCESSOR="armeabi-v7a"
  SYSTEM_LEVEL=16
  ;;
arm64-v8a)
  SYSTEM_PROCESSOR="arm64-v8a"
  ;;
x86-64)
  SYSTEM_PROCESSOR="x86_64"
  ;;
esac

mkdir build
cd build
cmake ../ -Wno-dev \
 -DCMAKE_SYSTEM_NAME=Android \
 -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake \
 -DANDROID_NDK=${ANDROID_NDK_ROOT} \
 -DANDROID_ABI="${SYSTEM_PROCESSOR}" \
 -DBUILD_SHARED_LIBS=OFF \
 -DBUILD_PROGRAMS=OFF \
 -DCMAKE_INSTALL_PREFIX="${LIB_INSTALL_PREFIX}" \
 -DANDROID_NATIVE_API_LEVEL=${SYSTEM_LEVEL} || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

cd ..

# CREATE PACKAGE CONFIG MANUALLY

cp ${LIB_INSTALL_PREFIX}/lib/pkgconfig/sdl2.pc ${LIB_INSTALL_PREFIX}/../pkgconfig/sdl2.pc || return 1
