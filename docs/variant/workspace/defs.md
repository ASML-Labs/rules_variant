<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Defines Bazel repository rules for setting up a variation map repository
and a variant map repository.

<a id="variant_maps_repository"></a>

## variant_maps_repository

<pre>
load("@rules_variant//variant/workspace:defs.bzl", "variant_maps_repository")

variant_maps_repository(<a href="#variant_maps_repository-name">name</a>, <a href="#variant_maps_repository-variation_map">variation_map</a>, <a href="#variant_maps_repository-variation_map_repository">variation_map_repository</a>, <a href="#variant_maps_repository-rule_prototypes">rule_prototypes</a>,
                        <a href="#variant_maps_repository-enable_variations_by_default">enable_variations_by_default</a>, <a href="#variant_maps_repository-enable_variants_by_default">enable_variants_by_default</a>,
                        <a href="#variant_maps_repository-zero_variant_strategy">zero_variant_strategy</a>, <a href="#variant_maps_repository-include_base_rule">include_base_rule</a>, <a href="#variant_maps_repository-extra_variation_points">extra_variation_points</a>,
                        <a href="#variant_maps_repository-validation_plugins">validation_plugins</a>)
</pre>

Creates a variant map repository with optional variation map and rule prototypes.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="variant_maps_repository-name"></a>name |  The name of the repository.   |  none |
| <a id="variant_maps_repository-variation_map"></a>variation_map |  An optional label pointing to a variation map file.   |  `None` |
| <a id="variant_maps_repository-variation_map_repository"></a>variation_map_repository |  An optional string specifying a variation map repository.   |  `None` |
| <a id="variant_maps_repository-rule_prototypes"></a>rule_prototypes |  A list of dictionaries describing the rules to include in the repository. Each dictionary should have the following keys: - kind: A dictionary specifying the 'name' and 'source' of the rule or macro. - executable: (Optional) A boolean indicating if the rule is executable.               Defaults to True if the rule name ends with '_binary'. - implicit_targets: (Optional) A list of patterns for implicit targets provided by the rule.                     Patterns can include placeholders like `{name}`, `{basename}`, and `{dirprefix}`. - extra_providers: (Optional) A list of additional providers to forward from the base rule or macro.                    Each provider should be a dictionary with 'name' and 'source' keys.   |  `None` |
| <a id="variant_maps_repository-enable_variations_by_default"></a>enable_variations_by_default |  A boolean controlling whether variations in the variation map file are enabled by default (True) or require explicit command-line specification (False).   |  `True` |
| <a id="variant_maps_repository-enable_variants_by_default"></a>enable_variants_by_default |  A boolean controlling whether the generated repository should expose rules as maps of variants (True) or re-export rules as-is (False).   |  `True` |
| <a id="variant_maps_repository-zero_variant_strategy"></a>zero_variant_strategy |  Defines the default configuration strategy for derivations without explicitly defined 'configs' attribute. Choices include: - "explicit": Derivations can only be addressed indirectly through other variant targets.               Indirect reference through glob target patterns like //:all or //... skips the target. - "implicit": Derivations can be addressed indirectly through other derived variants, inheriting their configuration.               Indirect reference through glob target patterns like //:all or //... and direct reference               builds the target using the current, global configuration. The zero_variant_strategy can be overridden per rule using the `zero_variant_strategy` attribute.   |  `"explicit"` |
| <a id="variant_maps_repository-include_base_rule"></a>include_base_rule |  bool, Controls whether to expose base rule.   |  `True` |
| <a id="variant_maps_repository-extra_variation_points"></a>extra_variation_points |  label_list, A list of labels pointing to JSON-formatted dictionaries with extra variation points and default values used to extend all variations specified in the variation map.   |  `None` |
| <a id="variant_maps_repository-validation_plugins"></a>validation_plugins |  Seq[Callable[Dict],None], List of functions that should be executed upon variation_map to validate its contents.   |  `None` |


<a id="variation_map_repository"></a>

## variation_map_repository

<pre>
load("@rules_variant//variant/workspace:defs.bzl", "variation_map_repository")

variation_map_repository(<a href="#variation_map_repository-name">name</a>, <a href="#variation_map_repository-variation_map">variation_map</a>, <a href="#variation_map_repository-extra_variation_points">extra_variation_points</a>, <a href="#variation_map_repository-enable_variations_by_default">enable_variations_by_default</a>,
                         <a href="#variation_map_repository-validation_plugins">validation_plugins</a>)
</pre>

Defines a variation map repository.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="variation_map_repository-name"></a>name |  string, The name of the variation map repository to create.   |  none |
| <a id="variation_map_repository-variation_map"></a>variation_map |  label, A label pointing to the variation map file.   |  none |
| <a id="variation_map_repository-extra_variation_points"></a>extra_variation_points |  label_list, A list of labels pointing to JSON-formatted dictionaries with extra variation points and default values used to extend all variations specified in the variation map.   |  `[]` |
| <a id="variation_map_repository-enable_variations_by_default"></a>enable_variations_by_default |  bool, Controls whether configurations in the variation map file are enabled by default (True) or require explicit command-line specification (False).   |  `True` |
| <a id="variation_map_repository-validation_plugins"></a>validation_plugins |  Seq[Callable[Dict],None], List of functions that should be executed upon variation_map to validate its contents.   |  `None` |


