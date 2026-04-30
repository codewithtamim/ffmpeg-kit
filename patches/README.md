# Android FFmpeg-Kit Patches

This directory contains patches to fix build issues when building FFmpeg-Kit for Android with modern toolchains (CMake 4.x, GNU C23).

## Overview

These patches are automatically applied during the GitHub Actions workflow (`build-android-release.yml`) after library sources are downloaded.

## Patches

| Patch File | Purpose | Target File |
|------------|---------|-------------|
| `ffmpeg-kit-shine-l3mdct-h.patch` | Fix C23 prototype error - adds missing parameter to function declaration | `src/shine/src/lib/l3mdct.h` |
| `ffmpeg-kit-xvid-encoder-h-c23-bool.patch` | Fix C23 `bool` typedef conflict - conditionally use `<stdbool.h>` | `src/xvidcore/xvidcore/src/encoder.h` |
| `ffmpeg-kit-gnutls-configure-ac-gettext.patch` | Remove duplicate `AM_GNU_GETTEXT_REQUIRE_VERSION` macro causing autopoint failures | `src/gnutls/configure.ac` |
| `ffmpeg-kit-chromaprint-cmake.patch` | Bump `cmake_minimum_required` to 3.5 for CMake 4.x compatibility | `src/chromaprint/CMakeLists.txt` |
| `ffmpeg-kit-jpeg-cmake.patch` | Bump `cmake_minimum_required` to 3.5 for CMake 4.x compatibility | `src/jpeg/CMakeLists.txt` |
| `ffmpeg-kit-libpng-cmake.patch` | Bump `cmake_minimum_required` and `cmake_policy` to 3.5 | `src/libpng/CMakeLists.txt` |
| `ffmpeg-kit-libsamplerate-cmake.patch` | Bump minimum version in 3.x range to 3.5 | `src/libsamplerate/CMakeLists.txt` |
| `ffmpeg-kit-libsndfile-cmake.patch` | Bump minimum version in 3.x range to 3.5 | `src/libsndfile/CMakeLists.txt` |
| `ffmpeg-kit-libvidstab-cmake.patch` | Bump `cmake_minimum_required` to 3.5 for CMake 4.x compatibility | `src/libvidstab/CMakeLists.txt` |
| `ffmpeg-kit-snappy-cmake.patch` | Bump `cmake_minimum_required` to 3.5 for CMake 4.x compatibility | `src/snappy/CMakeLists.txt` |
| `ffmpeg-kit-soxr-cmake.patch` | Bump `cmake_minimum_required` to 3.5 for CMake 4.x compatibility | `src/soxr/CMakeLists.txt` |
| `ffmpeg-kit-srt-cmake.patch` | Bump `cmake_minimum_required` to 3.5 for CMake 4.x compatibility | `src/srt/CMakeLists.txt` |
| `ffmpeg-kit-tiff-cmake.patch` | Bump `cmake_minimum_required` and `cmake_policy` to 3.5 | `src/tiff/CMakeLists.txt` |
| `ffmpeg-kit-sdl-cmake.patch` | Bump `cmake_minimum_required` to 3.5 for CMake 4.x compatibility | `src/sdl/CMakeLists.txt` |
| `ffmpeg-kit-x265-cmake.patch` | Fix CMake policies for CMake 4.x compatibility | `tools/patch/cmake/x265/CMakeLists.txt` |

## How It Works

1. **Pre-download patches** (like x265) are applied before sources are downloaded
2. **Post-download patches** are applied by `android-apply-patches.sh` after `downloaded_library_sources` is called in `android.sh`
3. Each patch has a fallback mechanism using sed/perl if the patch command fails

## Usage

These patches are automatically applied by the GitHub Actions workflow. To manually apply:

```bash
export ANDROID_PATCH_ROOT=$(pwd)
export BASEDIR=$(pwd)
bash patches/android-apply-patches.sh
```

## References

These patches are derived from the original FFmpeg-Kit SPM patches for Apple platforms, adapted for Android builds.
