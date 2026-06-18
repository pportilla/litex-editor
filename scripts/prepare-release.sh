#!/usr/bin/env bash
set -euo pipefail

pkgname=minimal-latex-studio
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"

version="$(
  sed -n 's/^[[:space:]]*VERSION[[:space:]]\+\([0-9][0-9.]*\).*$/\1/p' CMakeLists.txt |
    head -n 1
)"

if [[ -z "$version" ]]; then
  printf 'Could not determine project version from CMakeLists.txt\n' >&2
  exit 1
fi

tag="v$version"
archive_dir="$project_root/dist-release"
archive="$archive_dir/$pkgname-$version.tar.gz"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  printf 'Release archives must be created from a git tag.\n' >&2
  printf 'Initialize/publish the upstream repository, commit the tree, then tag %s.\n' "$tag" >&2
  exit 1
fi

if ! git rev-parse --verify --quiet "$tag^{commit}" >/dev/null; then
  printf 'Missing release tag: %s\n' "$tag" >&2
  printf 'Create it with: git tag -s %s\n' "$tag" >&2
  exit 1
fi

mkdir -p "$archive_dir"
git archive --format=tar --prefix="$pkgname-$version/" "$tag" | gzip -n > "$archive"

checksum="$(sha256sum "$archive" | awk '{print $1}')"
printf '%s  %s\n' "$checksum" "$archive"

tmp="$(mktemp)"
awk -v checksum="$checksum" '
  /^sha256sums=\(/ {
    in_sums = 1
    print
    next
  }

  in_sums && /^[[:space:]]*'\''[^'\'']*'\''[[:space:]]*$/ {
    print "  '\''" checksum "'\''"
    replaced = 1
    in_sums = 0
    next
  }

  { print }

  END {
    if (!replaced) {
      print "Could not update sha256sums in packaging/arch/PKGBUILD" > "/dev/stderr"
      exit 1
    }
  }
' packaging/arch/PKGBUILD > "$tmp"
mv "$tmp" packaging/arch/PKGBUILD

(cd packaging/arch && makepkg --printsrcinfo > .SRCINFO)

printf '\nUpdated packaging/arch/PKGBUILD and packaging/arch/.SRCINFO.\n'
printf 'Upload %s as the v%s release asset before publishing the package.\n' "$archive" "$version"
