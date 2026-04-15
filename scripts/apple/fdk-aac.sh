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

mkdir -p "${BUILD_DIR}" || return 1
cd "${BUILD_DIR}" || return 1

if [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]]; then
  cmake -Wno-dev \
    -G "Unix Makefiles" \
    -DCMAKE_VERBOSE_MAKEFILE=0 \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    -DCMAKE_SYSROOT="${SDK_PATH}" \
    -DCMAKE_FIND_ROOT_PATH="${SDK_PATH}" \
    -DCMAKE_OSX_SYSROOT="$(get_sdk_name)" \
    -DCMAKE_OSX_ARCHITECTURES="$(get_cmake_osx_architectures)" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET="$(get_min_sdk_version)" \
    -DCMAKE_SYSTEM_NAME="${CMAKE_SYSTEM_NAME}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${LIB_INSTALL_PREFIX}" \
    -DCMAKE_C_COMPILER="$CC" \
    -DCMAKE_CXX_COMPILER="$CXX" \
    -DCMAKE_LINKER="$LD" \
    -DCMAKE_AR="$(xcrun --sdk "$(get_sdk_name)" -f ar)" \
    -DCMAKE_SYSTEM_PROCESSOR="$(get_target_cpu)" \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_PROGRAMS=OFF \
    "${BASEDIR}"/src/"${LIB_NAME}" || return 1
else
  # ios-cmake 目录与 ffmpeg-kit 目录平级（仅 iOS/tvOS 分支使用）
  cmake "${BASEDIR}"/src/"${LIB_NAME}" -Wno-dev \
    -G "Unix Makefiles" \
    -DCMAKE_TOOLCHAIN_FILE=../../../ios-cmake/ios.toolchain.cmake \
    -DPLATFORM="${PLATFORM}" \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_PROGRAMS=OFF \
    -DCMAKE_INSTALL_PREFIX="${LIB_INSTALL_PREFIX}" \
    -DDEPLOYMENT_TARGET=11.0 || return 1
fi

make -j$(get_cpu_count) || return 1

make install || return 1

# CREATE PACKAGE CONFIG MANUALLY

cp ${LIB_INSTALL_PREFIX}/lib/pkgconfig/fdk-aac.pc ${LIB_INSTALL_PREFIX}/../pkgconfig/fdk-aac.pc || return 1