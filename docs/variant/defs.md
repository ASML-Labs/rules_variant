<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Public interface

<a id="derivation_builder"></a>

## derivation_builder

<pre>
load("@rules_variant//variant:defs.bzl", "derivation_builder")

derivation_builder(<a href="#derivation_builder-variant_map">variant_map</a>, <a href="#derivation_builder-zero_variant_strategy">zero_variant_strategy</a>, <a href="#derivation_builder-include_base_rule">include_base_rule</a>, <a href="#derivation_builder-variation_map">variation_map</a>)
</pre>

Returns a closure that creates variant derivation based on provided variants of a rule.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="derivation_builder-variant_map"></a>variant_map |  dict, A collection of all variants derived from a rule prototype, including specific bindings for conditional instantiation of these variants.   |  none |
| <a id="derivation_builder-zero_variant_strategy"></a>zero_variant_strategy |  string, Control argument defining behavior of unconfigured derivations.   |  none |
| <a id="derivation_builder-include_base_rule"></a>include_base_rule |  bool, Controls whether to expose base rule.   |  none |
| <a id="derivation_builder-variation_map"></a>variation_map |  dict, The parsed variation_spec data.   |  none |

**RETURNS**

A lambda function that takes a list of variations and additional keyword arguments,
  and creates variant derivations based on the specified variations.


<a id="filter_attrs"></a>

## filter_attrs

<pre>
load("@rules_variant//variant:defs.bzl", "filter_attrs")

filter_attrs(*, <a href="#filter_attrs-func">func</a>, <a href="#filter_attrs-kwargs">kwargs</a>, <a href="#filter_attrs-variations">variations</a>)
</pre>

Filters out attributes ending with '_filter' and applies their logic to modify the original attribute values according to the current build variation.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="filter_attrs-func"></a>func |  The original function to which filtered attributes will be applied.   |  none |
| <a id="filter_attrs-kwargs"></a>kwargs |  Original keyword arguments passed to the function, potentially containing attributes to be filtered.   |  none |
| <a id="filter_attrs-variations"></a>variations |  A mapping of variation names to their corresponding values, used to determine the current build variation.   |  none |

**RETURNS**

callable: A new function that wraps the original function (`func`) with filtered attributes,
            ready to be called with additional keyword arguments.


<a id="flags.bool_flag"></a>

## flags.bool_flag

<pre>
load("@rules_variant//variant:defs.bzl", "flags")

flags.bool_flag(<a href="#flags.bool_flag-name">name</a>, <a href="#flags.bool_flag-default">default</a>, <a href="#flags.bool_flag-public">public</a>)
</pre>

Create a boolean flag and corresponding config_settings.

bool_flag is a Bazel Macro that defines a boolean flag with the given name two config_settings,
one for True, one for False. Reminder that Bazel has special syntax for unsetting boolean flags,
but this does not work well with aliases.
https://docs.bazel.build/versions/main/skylark/config.html#using-build-settings-on-the-command-line
Thus it is best to define both an "enabled" alias and a "disabled" alias.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="flags.bool_flag-name"></a>name |  string, the name of the flag to create and use for the config_settings   |  none |
| <a id="flags.bool_flag-default"></a>default |  boolean, if the flag should default to on or off.   |  none |
| <a id="flags.bool_flag-public"></a>public |  boolean, if the flag should be usable from other packages or if it is meant to be combined with some other constraint.   |  `True` |


<a id="flags.string_flag_with_values"></a>

## flags.string_flag_with_values

<pre>
load("@rules_variant//variant:defs.bzl", "flags")

flags.string_flag_with_values(<a href="#flags.string_flag_with_values-name">name</a>, <a href="#flags.string_flag_with_values-values">values</a>, <a href="#flags.string_flag_with_values-default">default</a>, <a href="#flags.string_flag_with_values-multiple">multiple</a>, <a href="#flags.string_flag_with_values-enable_all">enable_all</a>, <a href="#flags.string_flag_with_values-visibility">visibility</a>)
</pre>

Create a string flag and corresponding config_settings.

string_flag_with_values is a Bazel Macro that defines a flag with the given name and a set
of valid values for that flag. For each value, a config_setting is defined with the name
of the value, associated with the created flag.
This is defined to make the BUILD.bazel file easier to read w/o the boilerplate of defining
a string_flag rule and n config_settings
https://docs.bazel.build/versions/main/skylark/macros.html


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="flags.string_flag_with_values-name"></a>name |  string, the name of the flag to create and use for the config_settings   |  none |
| <a id="flags.string_flag_with_values-values"></a>values |  list of strings, the valid values for this flag to be set to.   |  none |
| <a id="flags.string_flag_with_values-default"></a>default |  string, whatever the default value should be if the flag is not set. Can be empty string for both a string_flag and a multi_string flag.   |  `""` |
| <a id="flags.string_flag_with_values-multiple"></a>multiple |  boolean, True if the flag should be able to be set multiple times on the CLI.   |  `False` |
| <a id="flags.string_flag_with_values-enable_all"></a>enable_all |  boolean, True if by all supported values should be set by default.   |  `True` |
| <a id="flags.string_flag_with_values-visibility"></a>visibility |  list of Label, defines visiblility of user-facing config settings.   |  `["//:__subpackages__"]` |


<a id="variant_builder"></a>

## variant_builder

<pre>
load("@rules_variant//variant:defs.bzl", "variant_builder")

variant_builder(<a href="#variant_builder-variation_map">variation_map</a>)
</pre>

Returns a closure that builds variants of a given rule based on variations.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="variant_builder-variation_map"></a>variation_map |  dict, A dictionary mapping variation names to their options.   |  none |

**RETURNS**

A lambda function that takes rule prototype object, a variation name,
  plus label to a target which stores original settings and returns
  a built variant of a rule based on the provided prototype, configured according to
  options specified by the selected variation.


