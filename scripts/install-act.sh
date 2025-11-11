#!/usr/bin/env bash
set -euo pipefail

ACT_DEFAULT_INSTALL_DIR="${ACT_DEFAULT_INSTALL_DIR:-${HOME}/.local/bin}"
if [[ ":${PATH}:" != *":${ACT_DEFAULT_INSTALL_DIR}:"* ]]; then
  export PATH="${ACT_DEFAULT_INSTALL_DIR}:${PATH}"
fi

ACT_VERSION="${ACT_VERSION:-0.2.82}"
ACT_DEFAULT_INSTALL_DIR="${ACT_DEFAULT_INSTALL_DIR:-${HOME}/.local/bin}"

if [[ ":${PATH}:" != *":${ACT_DEFAULT_INSTALL_DIR}:"* ]]; then
  export PATH="${ACT_DEFAULT_INSTALL_DIR}:${PATH}"
fi

install_act() {
  if command -v act >/dev/null 2>&1; then
    echo "act already installed at $(command -v act)"
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1; then
    echo "Skipping act install: curl is not available."
    echo "Install curl (or act) manually and re-run this script."
    return 0
  fi

  local version="${1:-0.2.82}"
  local os
  case "$(uname -s)" in
    Linux) os="Linux" ;;
    Darwin) os="Darwin" ;;
    *)
      echo "Skipping act install: unsupported OS $(uname -s)."
      return 0
      ;;
  esac

  local arch
  case "$(uname -m)" in
    x86_64|amd64) arch="x86_64" ;;
    arm64|aarch64) arch="arm64" ;;
    armv7l) arch="armv7" ;;
    armv6l) arch="armv6" ;;
    i386|i686) arch="i386" ;;
    riscv64) arch="riscv64" ;;
    *)
      echo "Skipping act install: unsupported architecture $(uname -m)."
      return 0
      ;;
  esac

  local tarball="act_${os}_${arch}.tar.gz"
  local url="https://github.com/nektos/act/releases/download/v${version}/${tarball}"
  local tmpdir
  tmpdir="$(mktemp -d)"

  echo "Downloading act ${version} for ${os}/${arch}..."
  if ! curl -fsSL "${url}" -o "${tmpdir}/${tarball}"; then
    echo "Failed to download act from ${url}"
    rm -rf "${tmpdir}"
    return 1
  fi

  tar -xzf "${tmpdir}/${tarball}" -C "${tmpdir}" act
  mkdir -p "${ACT_DEFAULT_INSTALL_DIR}"
  mv -f "${tmpdir}/act" "${ACT_DEFAULT_INSTALL_DIR}/act"
  chmod +x "${ACT_DEFAULT_INSTALL_DIR}/act"
  rm -rf "${tmpdir}"

  if command -v act >/dev/null 2>&1; then
    echo "act installed: $(command -v act)"
  else
    echo "act installed to ${ACT_DEFAULT_INSTALL_DIR}/act."
    echo "Add 'export PATH=\"${ACT_DEFAULT_INSTALL_DIR}:\$PATH\"' to your shell rc file."
  fi
}

install_act "${ACT_VERSION}"
