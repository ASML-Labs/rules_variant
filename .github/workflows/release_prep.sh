#! /usr/bin/env bash
set -euo pipefail

# The existance of this file is mandated by
# the github action used for generation of
# a github release (and its attestation.)
# https://github.com/bazel-contrib/.github/blob/1d798ff015ed0696433e01e2c3ccbb2abefadad7/.github/workflows/release_ruleset.yaml
#
# It is supposed to output release notes to stdout

cat ./release_notes.md
