rules_variant
---
[![ci](https://github.com/ASML-Labs/rules_variant/actions/workflows/ci.yaml/badge.svg)](https://github.com/ASML-Labs/rules_variant/actions/workflows/ci.yaml)

Codify and maintain Bazel build configurations in a single `.json` file.
Easily assign them to targets.

*Example*: Define a `cc_binary` target that is supposed to be compiled for
 two specific target platforms, with dedicated build settings for each.
**_Notice how_** code developer is not required to have in-depth understanding
 of each configuration - name is enough to use it effectively.


<table>
  <tr>
    <td>BUILD.bazel</td>
    <td>variant.spec.json</td>
  </tr>
  <tr>
<td>

```starlark
cc_binary(
  name = "hello",
  ...
  deps = [":libHello"],
  variations = [
    "rhel8x64",
    "wrl18ppce6500",
  ]
)

cc_library(
  name = "libHello",
  ...
  variations = [
    "rhel8x64",
    "wrl18ppce6500",
  ]
)
```

</td> 
<td>

```starlark
{
  "rhel8x64": {
    "compilation_mode": "opt",
    "force_pic": "false",
    "platform_suffix": "r8p",
    "platforms": "@examples//bazel/platforms:fake_rhel8x64"
  },
  "wrl18ppce6500": {
    "compilation_mode": "opt",
    "force_pic": "true",
    "platform_suffix": "w18p",
    "platforms": "@examples//bazel/platforms:fake_wrl18ppce6500",
  }
}
```

</td>
</tr>
</table>

## Table of contents

1. [Overview](#overview)
2. [What problems are being addressed](#what-problems-are-being-addressed)
3. [Examples](#examples)
4. [Glossary](#glossary)
5. [Similar projects](#similar-projects)

## Overview

`rules_variant` is a meta-ruleset that allows developers to easily manage and
build projects with multiple configurations. It transforms standard Bazel rules
 into variant rules, which can handle different configurations specified by the
 users. These configurations are defined in a JSON file, like `variant.spec.json`,
 making it straightforward to specify different build settings for various
 environments or platforms.

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

## What problems are being addressed?

1. **High skill floor for multiplatform build**: Bazel user has to have a relatively in-depth
  knowledge of Bazel and constraints/requirements of each Bazel configuration (target platform)
  they want to build target for. Said depth only grows with amount of special handling
  required by each platform. Effectively this means that to write a valid BUILD definitions,
  developer has to be up-to-date on both the code and the build system. `rules_variant`
  attempts to break this dependency, abstracting the configurations complexities behind
  'variant', which names is sufficient for the developer to correctly assign their
  code to given platform.
2. **Code duplication**: Historically, if Bazel repository contained a target destined
  to be build for multiple target platforms (will use different configurations) it was:
  (a) expected out of user to run the build mutliple times, each with correct set of flags
  for given platform; (b) containing duplicated definitions of said target, each with
  platform-specific constraints assigned to them; (c) containing macros effectively hiding
  (b) behind a pretty name. All of those approaches have downsides that the authors of the current
  ruleset find unacceptable - (a) puts undue burden of code developers (see point (1));
  (b) introduces a great risk of drift between how targets handle different platforms and
  encourages copy-paste; (c) makes it difficult for build-system users to know immediately
  how they should reference targets as dependencies. `rules_variant` aims to solve this
  problem by introducing an explicit binding to each configuration (on the level of BUILD
  definition) and by ensuring that name given in the target definition is always usable
  by other targets.
3. **Build setup / configuration drift**: Previous point outlined the common approach to
  multi-platforms, where build is performed multiple times with different build
  flags / settings. Such flags also may need to be set even when Bazel repository
  contain only one target platform. This introduces the problem of keeping those
  settings uniform across different enviroments - developers, CI etc. `rules_variant`
  solves this problem by assigning concrete configurations to targets, all of which are
  codified in versioned files. This ensures that all of required settings are set
  the same way across different enviornments.
4. **Readability**: With many other approaches to multiplatform builds, it is hard to
  quickly reason about what are the existing configurations and how they are applied to
  given targets. `rules_variant` makes that information explicit and localized directly in the
  BUILD definitions. 

## Examples

In the `rules_variant/examples` directory, you'll find practical examples
demonstrating how to use `rules_variant` in real projects. These examples cover a
range of scenarios, from simple to complex, showing how to define variant
configurations and use them to build projects. For instance, the `cc_complex` and
`cc_simple` examples illustrate how to set up projects with cross-variant
dependencies and explicit configuration transitions.

## Glossary

### Baseline
The standard version of a rule or macro that serves as the starting point for creating
variants.

### Rule Prototype
A description of a rule to be variant-ized, consisting of:
- **kind:** The name and source of the rule or macro.
- **executable:** *(Optional)* Whether the rule is executable; usually `true` for rules
  ending in `_binary`.
- **implicit_targets:** *(Optional)* Patterns for automatically included targets, using
  placeholders like `{name}`, `{basename}`, and `{dirprefix}`.
- **extra_providers:** *(Optional)* Additional providers to forward from the base rule or
  macro, each defined by a `name` and `source`.

### Variation Point
A specific aspect of a product where customization happens to produce a variant. A
variation point is equivalent to a Bazel build setting together with the set of values it
accepts. For example, a `platform` point that accepts `linux` or `windows`, or a
`cpp_standard` point that accepts `c++11` or `c++17`.

### Variation
A specific choice from the values of a variation point. For example, `windows` is a
variation of the `platform` point, and `c++17` is a variation of the `cpp_standard` point.

### Compound Variation
A set of choices across multiple variation points. In other words, a configuration.
A compound variation is a key/value map, for example:
```json
{
  "platform": "windows",
  "cpp_standard": "c++17"
}
```

### Variation Map
A mapping of unique labels to compound variations. For example:
```json
{
  "linux_platform_c++11_cpp_standard": {
    "platform": "linux",
    "cpp_standard": "c++11"
  },
  "linux_modern": {
    "platform": "linux",
    "cpp_standard": "c++17"
  },
  "windows": {
    "platform": "windows"
  },
  "legacy_cpp": {
    "cpp_standard": "c++11"
  },
  "windows_experimental": {
    "platform": "windows",
    "cpp_standard": "c++17"
  }
}
```

### Variation Map Repository
A virtual Bazel repository that provides the variation map and the tooling for applying
variations conditionally.

### Variant
The resulting form of a build rule after a variation or compound variation has been applied
to it. In other words, a configured build rule. For example, `cc_binary_windows_experimental` is
the variant of `cc_binary` with the compound variation
`{platform: "windows", cpp_standard: "c++17"}` applied.

### Variant Map
A mapping of all variants derived from a set of rule prototypes and a variation map. For
example:
```text
{
  linux_platform_c++11_cpp_standard: cc_binary_linux_platform_c++11_cpp_standard,
  linux_modern: cc_binary_linux_modern,
  windows: cc_binary_windows,
  legacy_cpp: cc_binary_legacy_cpp,
  windows_experimental: cc_binary_windows_experimental,
}
```

### Variant Maps Repository
A virtual repository that supplies variant maps and the tooling for conditionally
instantiating variants and their derivations.

### Derivation
A callable macro that produces instances of variants (configured targets). It accepts the
attributes of a base rule plus one of `variation` or `variations`.

For example, this `cc_binary` derivation:
```starlark
cc_binary(
    name = "main",
    srcs = ["main.c"],
    variations = [
        "windows_experimental",
        "linux_modern",
    ],
)
```
expands to:
```starlark
cc_binary(
    name = "main",
    srcs = ["main.c"],
    target_compatible_with = select({
        "@variation_map//:base_variation": ["@platforms//:incompatible"],
        "//conditions:default": [],
    }),
)
cc_binary_windows_experimental(
    name = "windows_experimental/main",
    srcs = ["main.c"],
    target_compatible_with = select({
        "@variation_map//:windows_experimental": [],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
)
cc_binary_linux_modern(
    name = "linux_modern/main",
    srcs = ["main.c"],
    target_compatible_with = select({
        "@variation_map//:linux_modern": [],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
)
```

### Binding
A condition that is satisfied by activating one or more variations.

### Binding Time
The time at which the decision about instantiating a binding must be made.

#### Pre-Transition Binding
Marks the build targets derived from active variations as compatible (buildable). A
pre-transition binding can be satisfied by several variations at the same time, that is every
variation enabled by default or named on the command line.

In the expanded derivation above, each variant target becomes compatible only when its
variation is active:
```starlark
cc_binary_windows_experimental(
    name = "windows_experimental/main",
    srcs = ["main.c"],
    target_compatible_with = select({
        "@variation_map//:windows_experimental": [],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
)
cc_binary_linux_modern(
    name = "linux_modern/main",
    srcs = ["main.c"],
    target_compatible_with = select({
        "@variation_map//:linux_modern": [],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
)
```
Building with `--variants=windows_experimental --variants=linux_modern` makes both
`windows_experimental/main` and `linux_modern/main` buildable at once.

#### Post-Transition Binding
Selectively applies a configurable attribute based on the single variation active in the
current evaluation context. Whereas a pre-transition binding can be satisfied by many
variations simultaneously (deciding *which targets are buildable*), a
post-transition binding is satisfied by exactly one variation at a time, and decides *how attributes of a configred target are evaluated*.

Post-transition bindings are usually consumed through the `variations` dictionary exposed by the
generated rules repository. Its keys map variation names to `config_setting` labels that can
be used in a `select()`, letting a single derivation vary its `srcs`, `deps`, `copt`, or any
other configurable attribute per variation:
```starlark
load("@my_variants//:rules.bzl", "cc_binary", "variations")

cc_binary(
    name = "main",
    srcs = select({
        variations["windows_experimental"]: ["main.windows.c"],
        variations["linux_modern"]: ["main.linux.c"],
        "//conditions:default": ["main.compat.c"],
    }),
    variations = [
        "windows_experimental",
        "linux_modern",
    ],
)
```
Here the two bindings work together: the `variations = [...]` attribute is the
pre-transition binding that produces the `windows_experimental/main` and `linux_modern/main` targets
and marks them buildable, while the `select(variations[...])` in `srcs` is the
post-transition binding. Once Bazel is actually building `windows_experimental/main`, only the
`windows_experimental` branch is active, so that variant compiles `main.windows.c`. Because a single
configured target resolves exactly one variation, only one branch of the `select` is ever
chosen per build.

## Similar projects

1. [with_cfg.bzl](https://github.com/fmeum/with_cfg.bzl) - `rules_variant` is effectively an opinionated "frontend" to this library, which provides a unified framework
that should work across all rules. You should decide to use it over `rules_variant` if You need to create Your own "glue" holding together the instrumented targets.
2. [auto_configured_builds](https://github.com/bazelbuild/examples/tree/main/configurations/auto_configured_builds) - this Bazel feature is solving the problem of
configuration / setup drift, as long as each target in your workspace file is not intended to be build multiple times with different configurations. You should decide
to use it over `rules_variant` if You do not need to use the same targets for multiple build configurations and do not need advanced capabilties to modify the rules
(including attributes) between configs.