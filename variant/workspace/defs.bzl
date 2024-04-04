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

"""Defines Bazel repository rules for setting up a variation map repository
and a variant map repository.
"""

load("//variant/3rdparty/com_googlesource_android_platform_build_bazel/utils:schema_validation.scl", "validate")
load("//variant/workspace/private:schemas.scl", "schemas")
load("//variant/workspace/private:templates_factory.bzl", "template_generators")

def _common_template_expansion(
        ctx,
        variation_map,
        enable_variations_by_default,
        build_template_generator,
        defs_template_generator):
    """Expands common templates with configuration settings.

    Args:
        ctx: repository_ctx, The context of the repository rule execution.
        variation_map: dict, A dictionary of configuration settings.
        enable_variations_by_default: bool, Controls whether variations in the variation map file are enabled by default (True) or require explicit command-line specification (False).
        build_template_generator: function, A generator function for BUILD.bazel file.
        defs_template_generator: function, A generator function for defs.bzl file.
    """
    defs_template_generator.expand(
        "maps__init",
        variation_map = variation_map,
        repository_name = ctx.name,
    )
    build_template_generator.expand(
        "bindings__pre_transition_init",
        enable_variations_by_default = enable_variations_by_default,
        values = variation_map.keys(),
    )
    build_template_generator.expand("bindings__post_transition_init")

    # Setup post-transition bindings
    for name in variation_map.keys():
        build_template_generator.expand(
            "bindings__post_transition_binding",
            name = name,
            settings = {":variation": name},
        )
        defs_template_generator.expand(
            "maps__binding",
            name = name,
            repository_name = ctx.name,
        )

def _inject_unique_flag(ctx, variation_map):
    """Injects a unique string flag into the configuration dictionary.

    Args:
        ctx: The repository context.
        variation_map: The configuration dictionary.

    Returns:
        The updated configuration dictionary with the unique flag injected.
    """
    unique_flag = "@@{}//:variation".format(ctx.name)  # buildifier: disable=canonical-repository
    return {
        key: dict(value, **{unique_flag: key})
        for key, value in variation_map.items()
    }

def _safe_decode(ctx, file, schema, validation_plugins = None):
    decoded_file = json.decode(ctx.read(file))
    decoded_file.pop("__comments", None)

    validate(
        decoded_file,
        schema = schema,
        fail_on_error = True,
    )

    validation_plugins = validation_plugins if validation_plugins else []
    for vp in validation_plugins:
        vp(decoded_file)

    return decoded_file

def _inject_extra_variation_points(ctx, variation_map):
    """Injects additional variation points with default values to all variations in the map.

    Args:
        ctx: The repository context.
        variation_map: The configuration dictionary.

    Returns:
        The updated configuration dictionary with extra variation points injected.
    """
    extra_variation_points = {}
    for (
        extra_variation_points_spec_file
    ) in ctx.attr.extra_variation_points:
        extra_variation_points |= _safe_decode(
            ctx,
            file = extra_variation_points_spec_file,
            schema = schemas.variation_points,
        )
    return {
        variation: dict(
            extra_variation_points,
            **variation_points
        )
        for variation, variation_points in variation_map.items()
    }

def _init_template_generators(ctx):
    """Initializes and returns a dictionary of template generators.

    Args:
        ctx: repository_ctx, The context of the repository rule execution.

    Returns:
        A dictionary mapping template types to their initialized generator functions.
    """
    return {
        template_type: generator(writer = ctx.file, file_name = file_name)
        for template_type, (generator, file_name) in {
            "build": (
                template_generators.build_template_generator,
                "BUILD.bazel",
            ),
            "defs": (template_generators.defs_template_generator, "defs.bzl"),
            "rules": (
                template_generators.rules_template_generator,
                "rules.bzl",
            ),
            "workspace": (
                template_generators.workspace_template_generator,
                "WORKSPACE.bazel",
            ),
        }.items()
    }

def _variant_maps_repository_impl(ctx, validation_plugins = None):
    """Implementation of the variant repository rule.

    Args:
        ctx: repository_ctx, The context of the repository rule execution.
        validation_plugins: Seq[Callable[Dict],None], List of functions
        that should be executed upon variation_map to validate its contents.
    """
    variation_map = _safe_decode(
        ctx,
        file = ctx.attr.variation_map,
        schema = schemas.variation_map,
        validation_plugins = validation_plugins,
    )

    template_generators = _init_template_generators(ctx)

    if not ctx.attr.variation_map_repository:
        # Inject our unique string flag which allows post-transition selection
        variation_map = _inject_unique_flag(ctx, variation_map)

        # TODO(astachec): inject default variation points based on list of all
        # built-in, transitionable flags. This will allow end-users to apply
        # (any) configuration on a target level.
        variation_map = _inject_extra_variation_points(ctx, variation_map)
        _common_template_expansion(
            ctx,
            variation_map,
            ctx.attr.enable_variations_by_default,
            template_generators["build"],
            template_generators["defs"],
        )

    template_generators["rules"].expand(
        "load__config",
        variation_map_repository = ctx.attr.variation_map_repository,
    )

    rule_prototypes = json.decode(ctx.attr.rule_prototypes)

    # Guard dict to avoid duplications for the 'load' statements
    extra_provider_already_in_file = {}

    # expands "load" statements
    for rule_prototype in rule_prototypes:
        if rule_prototype["kind"]["source"] == "native":
            continue
        template_generators["rules"].expand(
            "load__symbol",
            **rule_prototype["kind"]
        )
        if not rule_prototype.get(
            "enable_variants_by_default",
            ctx.attr.enable_variants_by_default,
        ):
            continue
        for extra_provider in rule_prototype.get("extra_providers", []):
            if extra_provider["name"] in extra_provider_already_in_file:
                continue
            template_generators["rules"].expand(
                "load__symbol",
                **extra_provider
            )
            extra_provider_already_in_file[extra_provider["name"]] = None

    template_generators["rules"].expand("builder__variant")
    template_generators["rules"].expand("export__config")

    # expands module body
    for rule_prototype in rule_prototypes:
        rule_name = rule_prototype["kind"]["name"]
        if rule_prototype["kind"]["source"] == "native":
            template_generators["rules"].expand(
                "rule__native_alias",
                rule_name = rule_name,
            )

        if not rule_prototype.get(
            "enable_variants_by_default",
            ctx.attr.enable_variants_by_default,
        ):
            template_generators["rules"].expand(
                "rule__re_export",
                rule_name = rule_name,
            )
            continue

        template_generators["rules"].expand(
            "rule__variant_map",
            rule_name = rule_name,
        )
        for extra_provider in rule_prototype.get("extra_providers", []):
            template_generators["rules"].expand(
                "rule__providers",
                rule_name = rule_name,
                provider = extra_provider["name"],
            )
        for variation_name in variation_map:
            template_generators["rules"].expand(
                "rule__variant",
                variation_name = variation_name,
                rule_name = rule_name,
                executable = rule_prototype.get("executable", None),
                implicit_targets = rule_prototype.get("implicit_targets", None),
                reset_on_attrs = rule_prototype.get("reset_on_attrs", None),
                original_settings_target = "@{}//:original_settings".format(ctx.name),
            )
        template_generators["rules"].expand(
            "builder__derivation",
            rule_name = rule_name,
            zero_variant_strategy = rule_prototype.get(
                "zero_variant_strategy",
                ctx.attr.zero_variant_strategy,
            ),
            include_base_rule = rule_prototype.get(
                "include_base_rule",
                ctx.attr.include_base_rule,
            ),
        )

    template_generators["build"].expand("bzl_library")
    template_generators["build"].expand("original_settings")
    template_generators["workspace"].expand("workspace", name = ctx.name)
    for generator in template_generators.values():
        generator.write()

def _variation_map_repository_impl(ctx, validation_plugins = None):
    """Implementation of the variation map repository rule.

    Args:
        ctx: repository_ctx, The context of the repository rule execution.
        validation_plugins: Seq[Callable[Dict],None], List of functions
       that should be executed upon variation_map to validate its contents.
    """
    variation_map = _safe_decode(
        ctx,
        file = ctx.attr.variation_map,
        schema = schemas.variation_map,
        validation_plugins = validation_plugins,
    )

    # Inject our unique string flag which allows post-transition selection
    variation_map = _inject_unique_flag(ctx, variation_map)

    # TODO(astachec): inject default variation points based on list of all
    # built-in, transitionable flags. This will allow end-users to apply
    # (any) configuration on a target level.
    variation_map = _inject_extra_variation_points(ctx, variation_map)

    ctx.file("variant.spec.json", content = json.encode(variation_map))
    template_generators = _init_template_generators(ctx)

    _common_template_expansion(
        ctx,
        variation_map,
        ctx.attr.enable_variations_by_default,
        template_generators["build"],
        template_generators["defs"],
    )
    template_generators["workspace"].expand("workspace", name = ctx.name)
    for generator in template_generators.values():
        generator.write()

def _create_variation_map_repository_impl(validation_plugins = None):
    validation_plugins = validation_plugins
    return lambda ctx: (_variation_map_repository_impl(ctx, validation_plugins))

_variation_map_repository_attrs = {
    "enable_variations_by_default": attr.bool(mandatory = True),
    "extra_variation_points": attr.label_list(
        mandatory = False,
    ),
    "variation_map": attr.label(mandatory = True),
}

_variant_maps_repository_attrs = _variation_map_repository_attrs | {
    "enable_variants_by_default": attr.bool(mandatory = True),
    "include_base_rule": attr.bool(mandatory = True),
    "rule_prototypes": attr.string(mandatory = True),
    "variation_map_repository": attr.string(mandatory = False),
    "zero_variant_strategy": attr.string(mandatory = True),
}

def _create_variant_maps_repository_impl(validation_plugins = None):
    validation_plugins = validation_plugins
    return lambda ctx: (_variant_maps_repository_impl(ctx, validation_plugins))

def variant_maps_repository(
        name,
        variation_map = None,
        variation_map_repository = None,
        rule_prototypes = None,
        enable_variations_by_default = True,
        enable_variants_by_default = True,
        zero_variant_strategy = "explicit",
        include_base_rule = True,
        extra_variation_points = None,
        validation_plugins = None):
    """Creates a variant map repository with optional variation map and rule prototypes.

    Args:
        name: The name of the repository.
        variation_map: An optional label pointing to a variation map file.
        variation_map_repository: An optional string specifying a variation map repository.
        extra_variation_points: label_list, A list of labels pointing to JSON-formatted dictionaries with extra variation points and default values used to extend all variations specified in the variation map.
        rule_prototypes: A list of dictionaries describing the rules to include in the repository.
               Each dictionary should have the following keys:
               - kind: A dictionary specifying the 'name' and 'source' of the rule or macro.
               - executable: (Optional) A boolean indicating if the rule is executable.
                             Defaults to True if the rule name ends with '_binary'.
               - implicit_targets: (Optional) A list of patterns for implicit targets provided by the rule.
                                   Patterns can include placeholders like `{name}`, `{basename}`, and `{dirprefix}`.
               - extra_providers: (Optional) A list of additional providers to forward from the base rule or macro.
                                  Each provider should be a dictionary with 'name' and 'source' keys.
        enable_variations_by_default: A boolean controlling whether variations in the variation map file
                                    are enabled by default (True) or require explicit command-line specification (False).
        enable_variants_by_default: A boolean controlling whether the generated repository should expose rules as maps of variants (True) or re-export rules as-is (False).
        zero_variant_strategy: Defines the default configuration strategy for derivations without explicitly defined 'configs' attribute.
                            Choices include:
                            - "explicit": Derivations can only be addressed indirectly through other variant targets.
                                          Indirect reference through glob target patterns like //:all or //... skips the target.
                            - "implicit": Derivations can be addressed indirectly through other derived variants, inheriting their configuration.
                                          Indirect reference through glob target patterns like //:all or //... and direct reference
                                          builds the target using the current, global configuration.
                            The zero_variant_strategy can be overridden per rule using the `zero_variant_strategy` attribute.
        include_base_rule: bool, Controls whether to expose base rule.
        validation_plugins: Seq[Callable[Dict],None], List of functions that should be executed upon variation_map to validate its contents.
    """

    validate(
        rule_prototypes,
        schema = schemas.rule_prototypes,
        fail_on_error = True,
    )

    attrs = {
        "enable_variants_by_default": enable_variants_by_default,
        "enable_variations_by_default": enable_variations_by_default,
        "extra_variation_points": (
            fail(
                "Cannot use 'extra_variation_points' without 'variation_map'. Please specify variation map first.",
            ) if extra_variation_points != None and variation_map == None else extra_variation_points
        ),
        "include_base_rule": include_base_rule,
        "name": name,
        "rule_prototypes": (
            json.encode(rule_prototypes) if rule_prototypes != None else "[]"
        ),
        "variation_map": (
            fail(
                "Cannot specify both 'variation_map' and 'variation_map_repository'. Please specify only one.",
            ) if variation_map != None and variation_map_repository != None else (
                variation_map if variation_map != None else (
                    "{}//:variant.spec.json".format(variation_map_repository) if variation_map_repository != None else fail(
                        "Please specify one of the following attributes: 'variation_map' or 'variation_map_repository'",
                    )
                )
            )
        ),
        "variation_map_repository": variation_map_repository,
        "zero_variant_strategy": (
            lambda strategies: zero_variant_strategy if zero_variant_strategy in strategies else fail(
                "Unsupported zero_variant_strategy {}. Please chose one from {}".format(
                    zero_variant_strategy,
                    strategies,
                ),
            )
        )(strategies = ["explicit", "implicit"]),
    }
    _variant_maps_repository = repository_rule(
        implementation = _create_variant_maps_repository_impl(validation_plugins),
        attrs = _variant_maps_repository_attrs,
        doc = "Defines a repository rule for setting up a variant map repository with variation map and rule prototypes.",
    )
    _variant_maps_repository(**attrs)

def variation_map_repository(
        name,
        variation_map,
        extra_variation_points = [],
        enable_variations_by_default = True,
        validation_plugins = None):
    """Defines a variation map repository.

    Args:
        name: string, The name of the variation map repository to create.
        variation_map: label, A label pointing to the variation map file.
        extra_variation_points: label_list, A list of labels pointing to JSON-formatted dictionaries with extra variation points and default values used to extend all variations specified in the variation map.
        enable_variations_by_default: bool, Controls whether configurations in the variation map file are enabled by default (True) or require explicit command-line specification (False).
        validation_plugins: Seq[Callable[Dict],None], List of functions that should be executed upon variation_map to validate its contents.
    """
    _variation_map_repository = repository_rule(
        implementation = _create_variation_map_repository_impl(validation_plugins),
        attrs = _variation_map_repository_attrs,
        doc = "Defines a repository rule for creating a variation map repository.",
    )
    _variation_map_repository(
        name = name,
        variation_map = variation_map,
        extra_variation_points = extra_variation_points,
        enable_variations_by_default = enable_variations_by_default,
    )
