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
This module provides functionality to create targets derived from variants of rules.
"""

visibility("//variant")

# buildifier: disable=unnamed-macro
def derivation_builder(
        variant_map,
        zero_variant_strategy,
        include_base_rule,
        variation_map):
    """Returns a closure that creates variant derivation based on provided variants of a rule.

    Args:
        variant_map: dict, A collection of all variants derived from a rule prototype, including specific bindings
             for conditional instantiation of these variants.
        zero_variant_strategy: string, Control argument defining behavior of unconfigured derivations.
        include_base_rule: bool, Controls whether to expose base rule.
        variation_map: dict, The parsed variation_spec data.

    Returns:
        A lambda function that takes a list of variations and additional keyword arguments,
        and creates variant derivations based on the specified variations.
    """
    return lambda **kwargs: __make_derivations(
        variant_map,
        variation_map,
        zero_variant_strategy,
        include_base_rule,
        **kwargs
    )

def _find_matching_variations(variations, filter_items, variation_map):
    """ Returns a list of variations that match with the given filter 

    Example:
        variation_map = {"var_1",{"key":"A"}, "var_2"{"key","B"}}
        variations = ["var_1", "var_2"]
        filter_items = [{"key":"A"}]
        returns ["var_1"]

    For simplicity reasons, current implementation checks if any of the dicts in any of
    the lists provided as filter_items match. So filter_items = [{"key":"A"}, {"key":"B"}]
    would return both variations in the example above.
    """
    matches = []
    for var in variations:
        for filter_item in filter_items:
            for k, v in filter_item.items():
                if k in variation_map[var] and variation_map[var][k] == v:
                    matches.append(var)
    return matches

def __make_derivations(
        variant_map,
        variation_map,
        zero_variant_strategy,
        include_base_rule,
        *,
        variation = None,
        variations = [],
        variant_args = {},
        is_override_rule = False,
        **kwargs):
    """Creates variant derivations for each legal variation provided.

    This function creates a variant derivation for each of legal variations provided
    based on the corresponding variant and binding defined in `variant_map`.

    In case no variations are specified, create a base rule according to defined zero variant control mode:
      - "implicit": creates base rule which can be instantiated without configuration
      - "explicit": creates base rule which can only be instantiated via other derivations only

    Args:
        variation: string, A single legal variation for which variant derivations will be created exclusively.
        variations: list, A list of legal variations for which variant derivations will be created,
        variant_map: dict, A collection of all variants derived from a rule prototype, including specific bindings
             for conditional instantiation of these variants.
        variation_map: dict, The parsed variation_spec data.
        zero_variant_strategy: string, Control argument defining behavior of unconfigured derivations.
        include_base_rule: bool, Controls whether to expose base rule.
        variant_args: dict, variation-name keyed dictionary of keyword arguments to extend or overwrite when instantiating a matching variant. For example, `dict(linux = dict(tags = ["test"]), windows = dict(visibility = ["//visibility:public"]))`.
        is_override_rule: bool, Controls rule type of derived variants. If set to True, instead of variants of a "normal" rule, macro will render variants of an override rule. Override rules act as explicit transition points that re-export already registered targets, but with a different configuration(s) applied.
        **kwargs: dict, Additional keyword arguments to pass to each target creation.

    Raises:
        Fail: If a both `variation` and `variations` are specified at the same time
    """
    if variation and variations:
        fail("Cannot specify both 'variation' and 'variations'. Please specify only one.")
    if variant_args and not variations:
        fail("Cannot use 'variant_args' without 'variations'.")
    if not variation and not variations:
        if is_override_rule:
            fail("Cannot override settings for the base rule. Please specify either 'variation' or 'variations' argument.")
        if not include_base_rule:
            fail("Cannot proceed without at least one rule to register. Please specify either 'variation' or 'variations' argument, and/or set `include_base_rule` to True in the rule prototype.")

    if "filter_variations" in kwargs:
        filter_variations = kwargs.pop("filter_variations")
        if "include" in filter_variations:
            matches = _find_matching_variations(variations, filter_variations["include"], variation_map)
            variations = [v for v in variations if v in matches]
        if "exclude" in filter_variations:
            matches = _find_matching_variations(variations, filter_variations["exclude"], variation_map)
            variations = [v for v in variations if v not in matches]

    # TODO(agondek|astachec): explain / refactor the boolean check below,
    # as it is not clear or easy to follow.
    if not variation and include_base_rule and not is_override_rule:
        standard_args = dict(**kwargs)
        standard_args.pop("build_settings", None)
        variant = variant_map["base"]
        variant.rule(
            target_compatible_with = (
                ["@platforms//:incompatible"] if variant_args else select(
                    # disable base target completely if variant_args are in use
                    {
                        variant.pre_transition_binding_condition: (
                            ["@platforms//:incompatible"] if zero_variant_strategy == "explicit" else []
                        ),
                        "//conditions:default": [],
                    },
                )
            ),
            **(standard_args | dict(
                tags = kwargs.get("tags", []) + ["unconfigured"] + (["disabled-by-variant_args"] if variant_args else []),
                deprecation = (
                    # prints warning whenever this target is reffered to
                    "\n".join((
                        "\033[1;33m",  # Yellow
                        'Values specified in the "variant_args" attribute:',
                        "{variant_args}\n",
                        "are not applicable to the non-variant target:",
                        '{indent}"{non_variant_target}"\n',
                        "Please refer to one of variant targets instead:",
                        "{variant_targets}",
                        "\033[0m",  # Text Reset
                    )).format(
                        indent = 4 * " ",
                        variant_args = "{{\n{lines}\n}}".format(
                            lines = ",\n".join([
                                '{indent}"{key}": {value}'.format(
                                    indent = 4 * " ",
                                    key = k,
                                    value = v,
                                )
                                for (k, v) in variant_args.items()
                            ]),
                        ),
                        non_variant_target = native.package_relative_label(kwargs.get("name")),
                        variant_targets = "[\n{lines}\n]".format(
                            lines = ",\n".join(
                                [
                                    '{indent}"{variant_target}"'.format(
                                        indent = 4 * " ",
                                        variant_target = native.package_relative_label(
                                            "{v}/{target_name}".format(
                                                v = v,
                                                target_name = kwargs.get("name"),
                                            ),
                                        ),
                                    )
                                    for v in variations
                                ],
                            ),
                        ),
                    ) if variant_args else None
                ),
            ))
        )

    if variation and not variations:
        __make_derivation(
            variation,
            variant_map,
            is_exclusive_variation = True,
            is_override_rule = is_override_rule,
            **(kwargs | variant_args.get(variation, {}))
        )

    for variation in variations:
        __make_derivation(
            variation,
            variant_map,
            is_override_rule = is_override_rule,
            **(kwargs | variant_args.get(variation, {}))
        )

def __make_derivation(
        variation,
        variant_map,
        is_exclusive_variation = False,
        is_override_rule = False,
        **kwargs):
    """Creates a single variant derivation based on the specified variation.

    This function uses the variant and binding associated with the given variation
    to create a variant derivation.

    Args:
        variation: string, The name of the variation for the derivation.
        variant_map: dict, A collection of all variants derived from a rule prototype, including specific bindings
             for conditional instantiation of these variants.
        is_exclusive_variation: bool, Indicates whether the variation should be exclusive.
        is_override_rule: bool, Controls rule type of derived variants. If set to True, instead of variants of a "normal" rule, macro will render variants of an override rule. Override rules act as explicit transition points that re-export already registered targets, but with a different configuration(s) applied.
        **kwargs: dict, Additional keyword arguments for target creation, including the target's name.

    Raises:
        Fail: If the specified variation does not exist in `variant_map`.
    """
    if variation not in variant_map:
        fail("Variation '{}' does not exist.".format(variation))

    name = kwargs.pop("name")
    actual = native.package_relative_label(name)
    if is_exclusive_variation:
        variant_name = actual.name
    else:
        variant_name = "{variation}/{name}".format(
            variation = variation,
            name = actual.name,
        )

    variant = variant_map[variation]
    variant_rule = (variant.override_rule if is_override_rule else variant.rule)
    variant_rule(
        name = variant_name,
        target_compatible_with = select(
            {
                variant.pre_transition_binding_condition: [],
                "//conditions:default": ["@platforms//:incompatible"],
            },
        ),
        **kwargs
    )
