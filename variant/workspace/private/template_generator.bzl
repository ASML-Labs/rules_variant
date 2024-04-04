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

"""This module provides a template generator for creating files from template parts.

The `make_template_generator` function creates a template builder that can expand
template parts into a single file. It supports dynamic content generation by
formatting template parts with provided keyword arguments.

Usage:
    generator = make_template_generator(
        parts = template_parts,
        writer = write_file,
        file_name = "output.txt"
    )
    generator.expand("header", title="My Document")
    generator.expand("body", content="Hello, world!")
    generator.write()
"""

def make_template_generator(*, parts, writer, file_name):
    """Creates a template builder for generating files from template parts.

    Initializes a template builder capable of expanding template parts into a single
    file. It supports dynamic content generation by formatting template parts with provided
    keyword arguments.

    Args:
        parts: struct, A struct where each field represents a part of the template.
        writer: function, A function to write content to a file given its name.
        file_name: string, The name of the file to be generated.

    Returns:
        A struct with `expand` and `write` methods for building and writing the template content.
    """
    content = []

    def expand(shard, **kwargs):
        """Expands a template shard with provided arguments and appends it to the content.

        Args:
            shard: string, The name of the shard to expand.
            **kwargs: dict, Keyword arguments for formatting the shard.

        Raises:
            Fail: If the specified shard does not exist in `parts`.
        """
        shard_content = getattr(parts, shard, None)
        if shard_content == None:
            fail(
                "No such shard {shard} in {parts}".format(
                    shard = shard,
                    parts = dir(parts),
                ),
            )
        content.append(shard_content.format(**kwargs).rstrip())

    def write():
        """Writes the accumulated content to the specified file."""
        writer(file_name, "".join(content))

    # Automatically expand the base part of the template.
    expand("base")

    return struct(
        expand = expand,
        write = write,
    )
