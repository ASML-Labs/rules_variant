# rules_variant

`rules_variant` is a meta-ruleset that allows developers to easily manage and build
projects with multiple configurations. It transforms standard Bazel rules into
variant rules, which can handle different configurations specified by the users.
These configurations are defined in a JSON file, like `variant.spec.json`, making it
straightforward to specify different build settings for various environments or
platforms.

The process is simple: users define their desired configurations in a JSON file, and
`rules_variant` uses this file to generate variant rules. These rules can then be
used in BUILD files to build the project in different configurations, such as debug
or release modes for different platforms. This approach keeps the variant rules and
targets very similar to their non-variant counterparts, minimizing complexity and
making it easier to maintain the project.

`rules_variant` leverages the `with_cfg.bzl` utility to dynamically create these new
rules based on the specified configurations. It's designed to be easy to use,
allowing for clear and concise definition of configuration transitions without adding
significant overhead to the build graph.

## Examples

In the `rules_variant/examples` directory, you'll find practical examples
demonstrating how to use `rules_variant` in real projects. These examples cover a
range of scenarios, from simple to complex, showing how to define variant
configurations and use them to build projects. For instance, the `cc_complex` and
`cc_simple` examples illustrate how to set up projects with cross-variant
dependencies and explicit configuration transitions.

## Glossary

### Baseline
A baseline is the standard version of a rule or macro that serves as the starting point
for creating variants.

### Rule Prototype
A list of rule descriptions that include:
- **kind:** The name and source of the rule or macro.
- **executable:** (Optional) Indicates if the rule is executable, usually true for
  rules ending with '_binary'.
- **implicit_targets:** (Optional) Patterns for automatically included targets, using
  placeholders like `{name}`, `{basename}`, and `{dirprefix}`.
- **extra_providers:** (Optional) Additional providers that extend the base rule or
  macro, each defined by 'name' and 'source'.

### Variation
A variation represents differences in a workspace that can be built with different
settings, such as:
- Using `platforms` command-line flag set to either `linux` or `windows`.
- Using `cpp_standard` command-line flag set to either `c++11` or `c++17`.

Examples of variations include:
- `linux_platform_c++11_cpp_standard`
- `linux_platform_c++17_cpp_standard`
- `windows_platform_c++11_cpp_standard`
- `windows_platform_c++17_cpp_standard`

#### Variation Map
A mapping of unique labels to dictionaries that define variation points and their valid
options. This map helps manage different configurations or compound variations.

#### Variation Map Repository
A virtual repository in Bazel that provides the variation map and tools for applying
variations conditionally.

### Variant
A variant is a specific version of a rule that has unique characteristics, leading to
different outcomes based on the options applied. For example, a `cc_binary` rule
variant might disable optimization for the Windows platform.

#### Variant Map
A collection of all variants derived from a rule prototype, including specific bindings
for conditional instantiation of these variants.

#### Variant Maps Repository
A virtual repository that supplies variant maps and tools for conditional instantiation
and management of variants, including their derivations.

### Derivation
A callable that represents an innstance of a specific variant of a rule plus input
attributes like `src` and `deps`. It can also be seen as equivalent of a configured target.

### Binding
A condition that determines a variation point. It "activates" a specific variant.
From the end-user perspective, bindings are defined using `variations` attribute passed
to a derivation callable.

#### Pre-Transition Binding
A setting that denotes the currently enabled variations, marking compatible
derivations as directly accessible build targets. Defined using `variations` attribute
of a derivation target.

#### Post-Transition Binding
A setting that specifies a single enabled variation from the current evaluation
context, allowing for selective application of configurable attributes in the variant
derivation. For example, a specific binding, extracted from `variants` dictionary can
be used in a `select` statement of a variant derivation to use a different source 
file in target `src` attribute depending on currently enabled variation.
