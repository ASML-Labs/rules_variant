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

## Similar projects

1. [with_cfg.bzl](https://github.com/fmeum/with_cfg.bzl) - `rules_variant` is effectively an opinionated "frontend" to this library, which provides a unified framework
that should work across all rules. You should decide to use it over `rules_variant` if You need to create Your own "glue" holding together the instrumented targets.
2. [auto_configured_builds](https://github.com/bazelbuild/examples/tree/main/configurations/auto_configured_builds) - this Bazel feature is solving the problem of
configuration / setup drift, as long as each target in your workspace file is not intended to be build multiple times with different configurations. You should decide
to use it over `rules_variant` if You do not need to use the same targets for multiple build configurations and do not need advanced capabilties to modify the rules
(including attributes) between configs.

