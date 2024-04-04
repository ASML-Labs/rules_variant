#!/usr/bin/env bash

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

set -e

args=$@

function log_output {
  echo -e "\033[1;33mTEST: $1\033[0m"
}

_bazel() {
    printf -v cmd_str '%q ' "$@"; log_output "bazel $cmd_str $args"
    bazel $* $args
}

_bazel run //tv_channels:sports/channel
_bazel run //tv_channels:weather/channel
_bazel run //tv_channels:channel

_bazel build //kitchen:spaghetti_al_pomodoro \
  --@@rules_kitchen//:variations=chopped \
  --@@rules_kitchen//:variations=delicate \
  --@@rules_kitchen//:variations=fresh \
  --@@rules_kitchen//:variations=mild \
  --platforms=@examples//bazel/platforms:fake_rhel8x64
_bazel build //kitchen:rustic_tomato_soup \
  --@@rules_kitchen//:variations=whole \
  --@@rules_kitchen//:variations=dried \
  --platforms=@examples//bazel/platforms:fake_rhel8x64
_bazel build //kitchen:gourmet_pizza \
  --@@rules_kitchen//:variations=crushed \
  --@@rules_kitchen//:variations=dense \
  --@@rules_kitchen//:variations=sharp \
  --@@rules_kitchen//:variations=fresh \
  --platforms=@examples//bazel/platforms:fake_rhel8x64

_bazel build //print_info:all \
  --variants=rhel8x64 \
  --variants=wrl18ppce6500_dev \
  --variants=wrl6x64_dbg
_bazel build //print_info:all \
  --variants=rhel8x64 \
  --variants=wrl18ppce6500_dev
_bazel build //print_info:all \
  --variants=rhel8x64

_bazel build //copt_setting:DEBUG/main \
  --variants=DEBUG
_bazel build //copt_setting:TEST/main \
  --variants=TEST
_bazel build //copt_setting:PROD/main \
  --variants=PROD
_bazel build //copt_setting:all \
  --variants=DEBUG \
  --variants=TEST \
  --variants=PROD

_bazel build //cc_simple:rhel8x64/main \
  --variants=rhel8x64
_bazel build //cc_simple:wrl6x64/main \
  --variants=wrl6x64
_bazel build //cc_simple:wrl18ppce6500/main \
  --variants=wrl18ppce6500
_bazel build //cc_simple:combined \
  --variants=rhel8x64 \
  --variants=wrl6x64 \
  --variants=wrl18ppce6500
_bazel build //cc_simple:rhel8x64/main \
  --variants=rhel8x64 \
  --variants=wrl6x64 \
  --variants=wrl18ppce6500
_bazel build //cc_simple:wrl6x64/main \
  --variants=rhel8x64 \
  --variants=wrl6x64 \
  --variants=wrl18ppce6500
_bazel build //cc_simple:wrl18ppce6500/main \
  --variants=rhel8x64 \
  --variants=wrl6x64 \
  --variants=wrl18ppce6500

_bazel build //cc_complex:all
_bazel build //cc_complex:all \
  --variants=wrl6x64_dev
_bazel build //cc_complex:all \
  --variants=wrl6x64_dev \
  --variants=rhel8x64_dev
_bazel build //cc_complex:rhel8x64_dev/greeting \
  --variants=rhel8x64_dev
_bazel build //cc_complex:rhel8x64_dev/greeting //cc_complex:wrl6x64_dev/greeting \
  --variants=rhel8x64_dev \
  --variants=wrl6x64_dev

_bazel build //implicit_settings:all
_bazel build //variable_build_attributes:all
_bazel build //target_level_overrides:all
