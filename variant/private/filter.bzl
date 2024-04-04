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

"""
This module provides functionality to create derivations with filtered attributes.

Example usage:
# defs.bzl
load(
    "@rules_some_variant_maps//:rules.bzl",
    "variations",
    _some = "some",
)
load(
    "@rules_variant//variant:defs.bzl",
    "filter_attrs"
)

def some(name, **kwargs):
    filter_attrs(
        func = _some,
        variations = variations,
        kwargs = kwargs
    )(name)

# BUILD.bazel
load(":defs.bzl", "some")

some(
    name = "buildable",
    variation = "noarch",
    deps_filter = {
        "noarch": [],
        "windows": ["better"],
        "linux": ["er"],
    },
    deps = [
       ":some.other",
       ":some.better",
    ]
)
"""

visibility("//variant")

def filter_attrs(*, func, kwargs, variations):
    """Filters out attributes ending with '_filter' and applies their logic to modify the original attribute values according to the current build variation.

    Args:
        func (callable): The original function to which filtered attributes will be applied.
        kwargs (dict): Original keyword arguments passed to the function, potentially containing
                       attributes to be filtered.
        variations (dict): A mapping of variation names to their corresponding values,
                           used to determine the current build variation.

    Returns:
        callable: A new function that wraps the original function (`func`) with filtered attributes,
                  ready to be called with additional keyword arguments.
    """

    def filtered_func(name, **additional_kwargs):
        # Merge original kwargs with additional_kwargs, giving precedence to additional_kwargs
        merged_kwargs = dict(kwargs, **additional_kwargs)

        # Initialize filtered_kwargs with attributes that do not end with '_filter'
        filtered_kwargs = {
            k: v
            for k, v in merged_kwargs.items()
            if not k.endswith("_filter")
        }

        for attr, value in merged_kwargs.items():
            if attr.endswith("_filter"):
                base_attr = attr[:-len("_filter")]
                if base_attr in filtered_kwargs:
                    attr_map = {
                        "//conditions:default": filtered_kwargs[base_attr],
                    }
                    for (
                        variation,
                        suffixes,
                    ) in value.items():
                        filtered_values = [
                            v
                            for v in filtered_kwargs[base_attr]
                            if any(
                                [
                                    v.endswith(suffix)
                                    for suffix in suffixes
                                ],
                            )
                        ]
                        attr_map[variations[variation]] = filtered_values
                    filtered_kwargs[base_attr] = select(
                        attr_map,
                    )

        # Call the original function with the name and filtered kwargs
        return func(name = name, **filtered_kwargs)

    return filtered_func
