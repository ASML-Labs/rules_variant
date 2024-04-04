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

# This file defines a custom Bazel rule that prints the target name and platform information during analysis.

_COLORS = {
    "Color_Off": "\033[0m",  # Text Reset
    "IBlue": "\033[0;94m",  # Blue
}

def _print(msg):
    """Prints a message in blue color.

    This function formats the given message with blue color for terminal output. It utilizes
    ANSI escape codes defined in the _COLORS dictionary.

    Args:
        msg: str, The message to be printed.
    """
    print(
        """

{IBlue}\t{msg}{Color_Off}

""".format(
            msg = msg,
            **_COLORS
        ),
    )

def _info_impl(ctx):
    """The implementation function for the custom Bazel rule.

    This function is called during the analysis phase of the build. It prints the target name
    and platform information using the _print function.

    Args:
        ctx: rule_context, The context of the rule that provides access to toolchains, attributes,
            and other rule-specific data.
    """

    # This function is called when the rule is analyzed.
    # You may use print for debugging.
    # buildifier: disable=print
    _print(
        "  TARGET: {}\n\tPLATFORM: {}".format(
            ctx.attr.name,
            ctx.fragments.platform.platform,
        ),
    )

info = rule(
    implementation = _info_impl,
    fragments = ["platform"],
    doc = "A rule that prints the target name and platform information during the analysis phase.",
)
