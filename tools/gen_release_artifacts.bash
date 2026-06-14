#! /usr/bin/env nix-shell
#! nix-shell --quiet ../default.nix
#! nix-shell -i bash
set -euo pipefail

# On github action runners the $RUNNER_TEMP is
# not cleaned betweeen job steps, however TMPDIR is.
OUT_DIR=$(mktemp -d -p ${RUNNER_TEMP:-"/tmp"})
pushd $(git rev-parse --show-toplevel) >/dev/null

# Get current version
echo "rules_variant-v$(cog get-version 2>/dev/null)" >${OUT_DIR}/version
VERSION="$(cat ${OUT_DIR}/version)"

# Generate release notes
RELEASE_NOTES="${OUT_DIR}/release_notes.md"
cog changelog --at "${VERSION}" >${RELEASE_NOTES} 2>/dev/null

# Create the tar.gz archive
# VERSION already contains rules_variant-v prefix!
ARCHIVE_NAME="${VERSION}.tar.gz"

# https://www.gnu.org/software/tar/manual/html_node/Reproducibility.html
# ^ Describes why and how we are ensuring archive reproducibility
function get_commit_time() {
  TZ=UTC0 git log -1 \
    --format=tformat:%cd \
    --date=format:%Y-%m-%dT%H:%M:%SZ \
    "$@"
}
# Each file gets the timestamp of latest commit in the repo
git ls-files | while read -r file; do
  commit_time=$(get_commit_time "$file")
  commit_time=${commit_time:-$(TZ=UTC0 date -r $file "+%Y-%m-%dT%H:%M:%SZ")}
  touch -md $commit_time "$file"
done

SOURCE_EPOCH=$(get_commit_time)
TARFLAGS="
  --sort=name --format=posix
  --pax-option=exthdr.name=%d/PaxHeaders/%f
  --pax-option=delete=atime,delete=ctime
  --clamp-mtime --mtime=$SOURCE_EPOCH
  --numeric-owner --owner=0 --group=0
  --mode=go+u,go-w
"
GZIPFLAGS="--no-name --best"
LC_ALL=C tar $TARFLAGS -c --to-stdout $(git ls-files) |
  gzip $GZIPFLAGS > "${OUT_DIR}/${ARCHIVE_NAME}"

ARCHIVE_SHA=$(sha256sum "${OUT_DIR}/${ARCHIVE_NAME}" | cut -f 1 -d' ')

# Enrich the release_notes.md with usage example
cat <<EOF >> ${RELEASE_NOTES}
## Usage example

### WORKSPACE

Paste this snippet into your \`WORKSPACE.bazel\` file:

\`\`\`starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "rules_variant",
    sha256 = "${ARCHIVE_SHA}",
    url = "https://github.com/ASML-Labs/rules_variant/releases/download/${VERSION}/${ARCHIVE_NAME}",
)

load("@rules_variant//variant/workspace:deps.bzl", "rules_variant_deps")
rules_variant_deps()
\`\`\`
EOF

popd >/dev/null

# Inform where to find artifacts
echo ${OUT_DIR}
