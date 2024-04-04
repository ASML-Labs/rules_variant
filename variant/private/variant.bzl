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
This module provides functionality to create variants of rules.
"""

load("@with_cfg.bzl", "validate_and_get_attr_name", "with_cfg")

visibility("//variant")

def make_wrapper(
        *,
        transitioning_alias,
        values):
    return lambda *, name, exports, **kwargs: _wrapper(
        name = name,
        exports = exports,
        kwargs = kwargs,
        transitioning_alias = transitioning_alias,
        values = values,
    )

def _wrapper(
        *,
        name,
        exports,
        kwargs,
        transitioning_alias,
        values):
    build_settings = kwargs.pop("build_settings", {})

    late_bound_settings = {
        (Label(late_bound_setting) if late_bound_setting[0] in ("/", "@", ":") else late_bound_setting): late_bound_setting_value
        for late_bound_setting, late_bound_setting_value in build_settings.items()
    }
    alias_attrs = {
        validate_and_get_attr_name(setting): value
        for setting, value in (
            values |
            {
                late_bound_setting: late_bound_setting_value
                for late_bound_setting, late_bound_setting_value in late_bound_settings.items()
                if late_bound_setting in values
            }
        ).items()
    }

    transitioning_alias(
        name = name,
        exports = exports,
        **(alias_attrs | kwargs)
    )

def variant_builder(variation_map):
    """Returns a closure that builds variants of a given rule based on variations.

    Args:
        variation_map: dict, A dictionary mapping variation names to their options.

    Returns:
        A lambda function that takes rule prototype object, a variation name,
        plus label to a target which stores original settings and returns
        a built variant of a rule based on the provided prototype, configured according to
        options specified by the selected variation.
    """
    return lambda rule_prototype, original_settings_target, variation_name: __make_variant(
        rule_prototype,
        original_settings_target,
        variation_name,
        variation_map,
    )

def __make_variant(rule_prototype, original_settings_target, variation_name, variation_map):
    """Creates a variant of a rule based on the given variation.

    This function applies variation specific options to a rule prototype, which can then
    be used to instantiate targets derived from the previously created rule variant.

    Args:
        rule_prototype: dict, Information about the rule to be created. Expected to contain
                        the base rule definition that variation options will modify.
        original_settings_target: target, Stores the original settings modified
                        by a "resettable" rule constructed with with_cfg.
        variation_name: string, The name of the variation to apply. Must exist in `variation_map`.
        variation_map: dict, A dictionary of all available variations, mapping variation
                       names to their options.

    Returns:
        A variant of a rule with variation options applied.

    Raises:
        Fail: If the specified variation does not exist in `variation_map`.
    """

    if variation_name not in variation_map:
        fail("Variation '{}' not found in available variations.".format(variation_name))

    reset_on_attrs = rule_prototype.pop("reset_on_attrs")

    variant = with_cfg(**rule_prototype)
    for option, value in variation_map[variation_name].items():
        if value and value != "null":
            option = (
                Label(option) if option.lstrip("-").startswith(("@", "/", ":")) else option
            )
            variant.set(option, value)

    if reset_on_attrs:
        variant.resettable(Label(original_settings_target))
        variant.reset_on_attrs(*reset_on_attrs)

    wrapper, transitioning_alias = variant.build()
    override_wrapper = make_wrapper(
        transitioning_alias = transitioning_alias,
        values = {(
            Label(option) if option.lstrip("-").startswith(("@", "/", ":")) else option
        ): value for option, value in variation_map[variation_name].items()},
    )
    return wrapper, transitioning_alias, override_wrapper
