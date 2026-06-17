#!/usr/bin/env bash
set -euo pipefail

# scripts/apply_patches.sh
# Aplica patches armazenados em patches/ usando git am quando possível

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PATCH_DIR="$REPO_DIR/patches"

if [ ! -d "$PATCH_DIR" ]; then
  echo "No patches directory found at $PATCH_DIR"
  exit 0
fi

cd "$REPO_DIR"

for p in "$PATCH_DIR"/*.patch; do
  [ -e "$p" ] || continue
  echo "Applying patch: $p"
  # Prefer git am, fallback to git apply
  if git am --signoff < "$p"; then
    echo "applied $p with git am"
  else
    echo "git am failed, trying git apply"
    git apply --index "$p" || { echo "failed to apply $p"; exit 1; }
    git commit -m "Apply patch $(basename "$p")" --no-edit || true
  fi
done

echo "All patches applied."
