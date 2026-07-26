#!/usr/bin/env bash
#
# sync-aur.sh — publish packaging changes to the AUR.
#
# Workflow: edit the packaging files in this repo's ./aur/ directory, then run
# this script. It copies them into the AUR package repo, regenerates .SRCINFO,
# shows you the diff, and (after you confirm) commits and pushes.
#
# The AUR repo's real, computed `pkgver` is always preserved — the placeholder
# kept in ./aur/PKGBUILD (r1.0000000) is never published. This also means a
# no-op sync produces no commit, honouring the AUR rule against pkgver-only
# bumps for VCS packages.
#
# Usage:
#   ./sync-aur.sh ["commit message"]
#
# Env:
#   AUR_REPO   path to the AUR package clone (default: ~/git/sable-electron-git)
#   AUR_YES    set to 1 to skip the confirmation prompt

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/aur"
AUR_DIR="${AUR_REPO:-$HOME/git/sable-electron-git}"
COMMIT_MSG="${1:-Sync packaging from sable-electron wrapper}"

# --- sanity checks ---------------------------------------------------------
[ -d "$SRC_DIR" ]          || { echo "error: source dir not found: $SRC_DIR" >&2; exit 1; }
[ -f "$SRC_DIR/PKGBUILD" ] || { echo "error: $SRC_DIR/PKGBUILD missing" >&2; exit 1; }
[ -d "$AUR_DIR/.git" ]     || { echo "error: AUR repo not found: $AUR_DIR (set AUR_REPO=...)" >&2; exit 1; }
command -v makepkg >/dev/null || { echo "error: makepkg not found (are you on Arch?)" >&2; exit 1; }

if ! git -C "$AUR_DIR" remote -v | grep -q 'aur.archlinux.org'; then
  echo "warning: $AUR_DIR has no aur.archlinux.org remote — is this the right repo?" >&2
fi

# --- preserve the AUR repo's real pkgver BEFORE we overwrite the file -------
old_pkgver="$(grep -m1 '^pkgver=' "$AUR_DIR/PKGBUILD" 2>/dev/null || true)"

# --- copy managed files (everything in aur/ except .SRCINFO) ----------------
mapfile -t FILES < <(cd "$SRC_DIR" && find . -maxdepth 1 -type f ! -name .SRCINFO -printf '%P\n')
echo "Syncing: ${FILES[*]}"
for f in "${FILES[@]}"; do
  cp "$SRC_DIR/$f" "$AUR_DIR/$f"
done

# restore the real, computed pkgver (never publish the placeholder)
if [ -n "$old_pkgver" ]; then
  sed -i "s|^pkgver=.*|$old_pkgver|" "$AUR_DIR/PKGBUILD"
  echo "Preserved $old_pkgver"
fi

# --- regenerate .SRCINFO from the PKGBUILD ---------------------------------
( cd "$AUR_DIR" && makepkg --printsrcinfo > .SRCINFO )

# --- stage & review --------------------------------------------------------
cd "$AUR_DIR"
git add -- "${FILES[@]}" .SRCINFO
if git diff --cached --quiet; then
  echo "Nothing to publish — AUR repo already in sync."
  exit 0
fi

echo
echo "=== staged changes ==="
git --no-pager diff --cached
echo

if [ "${AUR_YES:-}" != "1" ]; then
  read -rp "Commit and push to the AUR? [y/N] " reply
  case "$reply" in
    [yY]|[yY][eE][sS]) ;;
    *) echo "Aborted. (Staged changes left in $AUR_DIR)"; exit 0 ;;
  esac
fi

git commit -m "$COMMIT_MSG"
git push
echo "Done — pushed to the AUR."
