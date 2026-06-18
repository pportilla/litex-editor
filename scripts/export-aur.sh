#!/usr/bin/env bash
set -euo pipefail

pkgname=minimal-latex-studio
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"

if grep -q "'SKIP'" packaging/arch/PKGBUILD; then
  printf 'Refusing to export AUR package while sha256sums contains SKIP.\n' >&2
  printf 'Run scripts/prepare-release.sh after creating the release tag.\n' >&2
  exit 1
fi

output_dir="$project_root/dist-aur/$pkgname"
rm -rf "$output_dir"
mkdir -p "$output_dir"

install -m 0644 packaging/arch/PKGBUILD "$output_dir/PKGBUILD"
install -m 0644 packaging/arch/.SRCINFO "$output_dir/.SRCINFO"
install -m 0644 packaging/arch/.nvchecker.toml "$output_dir/.nvchecker.toml"
install -m 0644 packaging/arch/README.md "$output_dir/README.md"
install -m 0644 packaging/arch/REUSE.toml "$output_dir/REUSE.toml"
cp -R packaging/arch/LICENSES "$output_dir/LICENSES"

printf 'AUR package files exported to %s\n' "$output_dir"
printf 'Review, commit, and push those files to ssh://aur@aur.archlinux.org/%s.git\n' "$pkgname"
