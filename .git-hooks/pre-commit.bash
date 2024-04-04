#!/usr/bin/env bash
# This file does linting only,
# to ensure that invocations of builds/tests are
# not unnecessarily repeated.
set -euo pipefail

# Heavily inspired by: https://releases.nixos.org/nix/nix-{ver}/install
oops() {
    echo "$0:" "$@" >&2
    exit 1
}

require_util() {
    command -v "$1" > /dev/null 2>&1 ||
        oops "you do not have '$1' installed, which I need to $2"
}

require_util cog "enfore git conventional commits standard"
require_util find "find Bazel files to feed into buildifier"
require_util nixfmt "enforce nix files formatting standards"
require_util statix "ensure trivial improvements to nix files are applied"
require_util buildifier "enforce consistent bazel files formatting"

# Redirect stdout to /dev/null
# This will keep terminal clear for runs without linting problems
exec 1>/dev/null

nixfmt --check $(find . -type f -name '*.nix' -a ! -path './nix/sources.nix')
statix check $(find . -type f -name '*.nix' -a ! -path './nix/sources.nix')

buildifier --mode check $(find .\
 \( -type f -name '*.bazel' -o \( -type f -name '*.bzl' -o -type f -name '*.scl' \) \)\
 ! -path '*.git/*' ! -path '*.bazel-*' ! -path '*source_android_platform_build_bazel*')

cog -q check
