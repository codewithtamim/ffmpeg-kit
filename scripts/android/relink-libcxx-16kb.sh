#!/usr/bin/env bash
# NDK prebuilt libc++_shared.so for 32-bit ABIs is still linked with 4KB max page size
# (PT_LOAD align 2**12). Relink from libc++_static.a + libc++abi.a with 16KB so the AAR
# passes 16KB-page device checks. 64-bit NDK prebuilts already use 2**14.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
BASEDIR="${BASEDIR:-${REPO_ROOT}}"

if [[ -z "${ANDROID_NDK_ROOT:-}" ]]; then
  echo "ERROR: ANDROID_NDK_ROOT is not set" >&2
  exit 1
fi

PREBUILT_DIR="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt"
if [[ "$(uname -s)" == "Linux" ]]; then
  PREBUILT=linux-x86_64
elif [[ "$(uname -s)" == "Darwin" ]]; then
  PREBUILT=""
  for cand in darwin-arm64 darwin-x86_64; do
    if [[ -d "${PREBUILT_DIR}/${cand}" ]]; then
      PREBUILT="${cand}"
      break
    fi
  done
  if [[ -z "${PREBUILT}" ]]; then
    echo "ERROR: no darwin prebuilt under ${PREBUILT_DIR}" >&2
    exit 1
  fi
else
  echo "ERROR: unsupported host for libc++ relink" >&2
  exit 1
fi

BIN="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${PREBUILT}/bin"
SYS="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${PREBUILT}/sysroot"

# Use API 21 wrappers (present on current NDKs). OK when minSdk is 16 (LTS).
API_LEVEL="${ANDROID_LIBCXX_RELINK_API_LEVEL:-21}"

relink_one() {
  local out_dir="$1"
  local clangxx="$2"
  local sysroot_lib="$3"

  local dest="${BASEDIR}/android/libs/${out_dir}/libc++_shared.so"
  if [[ ! -f "${dest}" ]]; then
    echo "INFO: skip libc++ relink for ${out_dir}: ${dest} missing"
    return 0
  fi

  local libdir="${SYS}/usr/lib/${sysroot_lib}"
  if [[ ! -f "${libdir}/libc++_static.a" ]] || [[ ! -f "${libdir}/libc++abi.a" ]]; then
    echo "ERROR: missing libc++ static archives under ${libdir}" >&2
    exit 1
  fi

  local tmp="${dest}.16k.$$"
  "${BIN}/${clangxx}" -shared \
    -Wl,-soname,libc++_shared.so \
    -Wl,-z,max-page-size=16384 \
    -Wl,--whole-archive "${libdir}/libc++_static.a" "${libdir}/libc++abi.a" -Wl,--no-whole-archive \
    -Wl,--exclude-libs,ALL \
    -L"${libdir}" -lunwind \
    -nostdlib++ \
    -lc -lm -ldl -llog -latomic \
    -o "${tmp}"
  mv "${tmp}" "${dest}"
  echo "INFO: relinked libc++_shared.so (16KB pages) for ${out_dir}"
}

relink_one armeabi-v7a "armv7a-linux-androideabi${API_LEVEL}-clang++" arm-linux-androideabi
relink_one x86 "i686-linux-android${API_LEVEL}-clang++" i686-linux-android
