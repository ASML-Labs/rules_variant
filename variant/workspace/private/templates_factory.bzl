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

"""This module provides template generators for various Bazel-related files.

It loads necessary functions and template parts from other Starlark files and creates
partial functions for generating templates using the specified template parts.

The available template generators are:
- `build_template_generator`: Generates templates for BUILD.bazel files.
- `workspace_template_generator`: Generates templates for WORKSPACE.bazel files.
- `defs_template_generator`: Generates templates for defs.bzl files.
- `rules_template_generator`: Generates templates for rules.bzl files.

Usage:
    generator = template_generators.build_template_generator(
        writer = write_file,
        file_name = "BUILD.bazel"
    )
    generator.expand("header")
    generator.expand("rule", name = "my_rule")
    generator.write()
"""

load(
    "//variant/workspace/private:template_generator.bzl",
    "make_template_generator",
)
load(
    "//variant/workspace/private/templates:BUILD.bazel.scl",
    _build_template_parts = "parts",
)
load(
    "//variant/workspace/private/templates:defs.bzl.scl",
    _defs_template_parts = "parts",
)
load(
    "//variant/workspace/private/templates:rules.bzl.scl",
    _rules_template_parts = "parts",
)
load(
    "//variant/workspace/private/templates:WORKSPACE.bazel.scl",
    _workspace_template_parts = "parts",
)

def _create_partial_function(template_parts):
    """Creates a partial function for template generation.

    This function returns a partial function that, when called, will generate a template
    using the specified template parts and any additional arguments provided at call time.

    Args:
        template_parts: The parts of the template to be used for creation.

    Returns:
        A partial function that creates a template using the provided parts and additional arguments.
    """
    return lambda **kwargs: make_template_generator(
        parts = template_parts,
        **kwargs
    )

template_generators = struct(
    build_template_generator = _create_partial_function(_build_template_parts),
    workspace_template_generator = _create_partial_function(
        _workspace_template_parts,
    ),
    defs_template_generator = _create_partial_function(_defs_template_parts),
    rules_template_generator = _create_partial_function(_rules_template_parts),
)
