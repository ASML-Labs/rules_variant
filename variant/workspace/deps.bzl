# Copyright (c) 2026, ASML Netherlands B.V.
# All rights reserved
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Loads external repositores needed by rules_variant

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def rules_variant_deps():
    " Fetch 3rdparty dependencies "
    http_archive(
        name = "with_cfg.bzl",
        sha256 = "81a8714ad1542ce6bd69c8e32bf3c4123f137854e6b676d099d8a709348eee56",
        strip_prefix = "with_cfg.bzl-0.6.0",
        url = "https://github.com/fmeum/with_cfg.bzl/releases/download/v0.6.0/with_cfg.bzl-v0.6.0.tar.gz",
        patches = [
            "@rules_variant//variant/3rdparty/with_cfg.bzl:0001-do-not-attach-toolchains-exec_compatible_with-attrib.patch",
            "@rules_variant//variant/3rdparty/with_cfg.bzl:0002-fix-settings-encoding-for-transitions.patch",
            "@rules_variant//variant/3rdparty/with_cfg.bzl:0003-adds-CcSharedLibraryInfo-to-default-providers.patch",
            "@rules_variant//variant/3rdparty/with_cfg.bzl:0004-feat-late-bound-build-settings.patch",
            "@rules_variant//variant/3rdparty/with_cfg.bzl:0005-feat-mark-settings.bzl-as-public.patch",
        ],
        patch_args = ["-p1"],
    )
