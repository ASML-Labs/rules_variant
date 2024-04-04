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

load("@rules_variant//variant/workspace:defs.bzl", "variant_maps_repository")

def rules_example_cc_setup(**k):
    """Sets up the example C/C++ rules variant repository.

    Args:
        **k: dict, Additional keyword arguments passed to the `variant_maps_repository` function.
            These arguments can be used to specify other configurations such as 'variation_map',
            'variation_map_repo', etc.

    """
    variant_maps_repository(
        name = "rules_example_cc_variant_map",
        rule_prototypes = [
            {
                "kind": {
                    "name": "cc_binary",
                    "source": "@rules_cc//cc:defs.bzl",
                },
                "executable": True,
                "implicit_targets": [],
                "extra_providers": [],
            },
            {
                "include_base_rule": True,
                "kind": {
                    "name": "cc_library",
                    "source": "@rules_cc//cc:defs.bzl",
                },
                "executable": False,
                "implicit_targets": [],
                "extra_providers": [],
            },
        ],
        **k
    )
