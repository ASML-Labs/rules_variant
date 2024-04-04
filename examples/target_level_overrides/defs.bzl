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

load(
    "@bazel_skylib//rules:common_settings.bzl",
    "BuildSettingInfo",
)

_COLORS = {
    "black": "\033[1;90m",  # Black
    "red": "\033[1;91m",  # Red
    "off": "\033[0m",  # Text Reset
}
RowInfo = provider(doc = "", fields = ["line"])

script_template = (
    """#!/usr/bin/env -S -- tail -n +2 {contents}"""
)

def _impl(ctx):
    result = [
        "{row}:{indent}{columns}".format(
            row = ctx.label,
            indent = (80 - len(str(ctx.label))) * " ",
            columns = " ".join(
                [
                    "{color}■{off}".format(
                        color = _COLORS[str(bs[BuildSettingInfo].value)],
                        off = _COLORS["off"],
                    )
                    for bs in ctx.attr.columns
                ],
            ),
        ),
    ]
    for dep in ctx.attr.deps:
        result += dep[RowInfo].line

    script = ctx.actions.declare_file(
        "{}.print".format(ctx.label.name),
    )
    script_content = script_template.format(
        contents = "\n" + "\n".join(result),
    )
    ctx.actions.write(
        script,
        script_content,
        is_executable = True,
    )

    # Return the provider with result, visible to other rules.
    return [
        DefaultInfo(executable = script),
        RowInfo(line = result),
    ]

row = rule(
    implementation = _impl,
    attrs = {
        "columns": attr.label_list(
            providers = [BuildSettingInfo],
        ),
        "deps": attr.label_list(providers = [RowInfo]),
    },
    executable = True,
)
