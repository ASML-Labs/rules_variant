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

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

def _impl(ctx):
    return [
        CcInfo(
            compilation_context = cc_common.create_compilation_context(
                defines = depset(
                    [
                        "{}={}".format(
                            ctx.attr.build_setting.label.name.upper(),
                            str(ctx.attr.build_setting[BuildSettingInfo].value),
                        ),
                    ],
                ),
            ),
        ),
    ]

cc_define = rule(
    implementation = _impl,
    attrs = {
        "build_setting": attr.label(
            doc = "Build setting (flag) to construct the header from.",
            mandatory = True,
        ),
    },
)
