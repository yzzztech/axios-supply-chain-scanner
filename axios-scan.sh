#!/usr/bin/env bash
# axios-scan.sh — Detect the March 2026 axios npm supply-chain compromise
#
# Checks for:
#   - axios@1.14.1  (malicious)
#   - axios@0.30.4  (malicious)
#   - plain-crypto-js  (malicious dependency dropped by the above)
#
# Usage:  ./axios-scan.sh [path]     (defaults to $HOME)
# Refs:   https://www.wiz.io/blog/axios-npm-compromised-in-supply-chain-attack

set -u

ROOT="${1:-$HOME}"
RED=$'\033[0;31m'; GRN=$'\033[0;32m'; YLW=$'\033[1;33m'; BLD=$'\033[1m'; RST=$'\033[0m'

echo "${BLD}axios supply-chain scanner${RST}"
echo "Scanning: $ROOT"
echo "Looking for: axios@1.14.1, axios@0.30.4, plain-crypto-js"
echo

hits=0
scanned=0

# Find all manifests/lockfiles, skipping noisy dirs
while IFS= read -r f; do
  scanned=$((scanned+1))

  # Look for the malicious dependency name (strongest signal)
  if grep -q "plain-crypto-js" "$f" 2>/dev/null; then
    echo "${RED}[COMPROMISED]${RST} plain-crypto-js found in: $f"
    hits=$((hits+1))
    continue
  fi

  # Look for the exact bad axios versions
  if grep -Eq '"axios"[[:space:]]*:[[:space:]]*"?\^?~?(1\.14\.1|0\.30\.4)"?|axios@(1\.14\.1|0\.30\.4)|/axios/-/axios-(1\.14\.1|0\.30\.4)|axios[[:space:]]+(1\.14\.1|0\.30\.4)' "$f" 2>/dev/null; then
    echo "${RED}[COMPROMISED]${RST} malicious axios version in: $f"
    hits=$((hits+1))
  fi
done < <(find "$ROOT" \
  \( -name node_modules -o -name .venv -o -name .git -o -name Library -o -name .bun -o -name .cache \) -prune -o \
  -type f \( -name package.json -o -name package-lock.json -o -name yarn.lock -o -name pnpm-lock.yaml \) -print 2>/dev/null)

echo
echo "Scanned $scanned manifest/lockfile(s)."

if [ "$hits" -eq 0 ]; then
  echo "${GRN}${BLD}CLEAN:${RST} No compromised axios artifacts found."
  exit 0
else
  echo "${RED}${BLD}FOUND $hits compromised file(s)!${RST}"
  echo
  echo "${YLW}Next steps:${RST}"
  echo "  1. Pin axios to a safe version (e.g. 1.13.6) in package.json"
  echo "  2. Delete node_modules and lockfile, then reinstall clean"
  echo "  3. Rotate any secrets/tokens touched by affected machines or CI"
  echo "  4. Treat the host as potentially compromised — scan for unknown"
  echo "     outbound connections and review postinstall logs since 2026-03-31"
  exit 1
fi
