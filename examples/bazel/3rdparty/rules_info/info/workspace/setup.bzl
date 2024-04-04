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

def rules_info_setup(**k):
    """Sets up a variant repository with an info rule.

    Args:
        **k: dict, Additional keyword arguments that are passed to the `variant_maps_repository` function
            to configure the variant repository beyond the default setup.

    """
    variant_maps_repository(
        name = "rules_info_variant_map",
        rule_prototypes = [
            {
                "kind": {
                    "name": "info",
                    "source": "@rules_info//info/private:info.bzl",
                },
                "executable": False,
                "implicit_targets": [],
                "extra_providers": [],
            },
        ],
        **k
    )
