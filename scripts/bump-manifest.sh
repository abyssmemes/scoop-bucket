#!/usr/bin/env bash
# Refresh contextd.json from a contextverse GitHub release.
#
# Usage:
#   ./scripts/bump-manifest.sh v0.0.2
set -euo pipefail

TAG="${1:-}"
[[ -n "$TAG" ]] || { echo "usage: $0 <tag>  (e.g. v0.0.2)" >&2; exit 1; }
REPO="${CONTEXTVERSE_REPO:-orkcom-tech/contextverse}"
VER="${TAG#v}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="${ROOT}/contextd.json"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "==> Fetching checksums for ${TAG} from ${REPO}"
gh release download "$TAG" --repo "$REPO" --pattern checksums.txt --dir "$TMP"
SUMS="${TMP}/checksums.txt"

sha() {
  local file="$1"
  awk -v f="$file" '$2 == f { print $1; exit }' "$SUMS"
}

WIN_AMD64="$(sha "contextd_${VER}_windows_amd64.zip")"
WIN_ARM64="$(sha "contextd_${VER}_windows_arm64.zip")"

[[ -n "$WIN_AMD64" ]] || { echo "missing checksum for windows_amd64.zip" >&2; exit 1; }
[[ -n "$WIN_ARM64" ]] || { echo "missing checksum for windows_arm64.zip" >&2; exit 1; }

BASE="https://github.com/${REPO}/releases/download/${TAG}"

cat >"$MANIFEST" <<EOF
{
  "version": "${VER}",
  "description": "Portable, vendor-neutral context for AI (contextd)",
  "homepage": "https://github.com/${REPO}",
  "license": "BUSL-1.1",
  "architecture": {
    "64bit": {
      "url": "${BASE}/contextd_${VER}_windows_amd64.zip",
      "hash": "${WIN_AMD64}",
      "bin": "contextd.exe"
    },
    "arm64": {
      "url": "${BASE}/contextd_${VER}_windows_arm64.zip",
      "hash": "${WIN_ARM64}",
      "bin": "contextd.exe"
    }
  },
  "checkver": {
    "github": "https://github.com/${REPO}"
  },
  "autoupdate": {
    "architecture": {
      "64bit": {
        "url": "https://github.com/${REPO}/releases/download/v\$version/contextd_\$version_windows_amd64.zip"
      },
      "arm64": {
        "url": "https://github.com/${REPO}/releases/download/v\$version/contextd_\$version_windows_arm64.zip"
      }
    },
    "hash": {
      "url": "https://github.com/${REPO}/releases/download/v\$version/checksums.txt"
    }
  },
  "notes": [
    "contextd is licensed under BUSL-1.1 (source-available).",
    "Quick start: contextd init solo ; then contextd activate in a project."
  ]
}
EOF

echo "==> Wrote ${MANIFEST} for ${TAG}"
