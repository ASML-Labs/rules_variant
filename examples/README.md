# `rules_variant` examples

Each example includes a `BUILD.bazel` file that demonstrates how to apply `rules_variant` for achieving multi-variant builds. 
`variant.spec.json` acts as the source for globally used rule variants across most examples, while `faulty.spec.json` is used in `local_variants` 
to showcase project-specific variants.

## Examples Overview

- **cc_complex**: This example showcases a complex scenario with multiple source files. It demonstrates conditional compilation based on the build 
  configuration specified in `variant.spec.json`. For more details, see [cc_complex README](cc_complex/README.md).
- **cc_simple**: Highlights the basic application of `rules_variant` with simple C++ targets. It shows how to build the same application in different 
  configurations using `variant.spec.json`. Instructions can be found in [cc_simple README](cc_simple/README.md).
- **local_variants**: Focuses on demonstrating the use of project-specific rule variants through `faulty.spec.json`. This example is key for understanding 
  how to define and use local variants within a project. See [local_variants README](local_variants/README.md) for how to use it.
- **print_info**: A utility example designed to print information about the build configurations, helping users understand how `rules_variant` processes 
  variant specifications. The details are in [print_info README](print_info/README.md).
- **copt_setting**: Demonstrates how to use compile-time options (`copt`) to build C binaries with different configurations such as `DEBUG`, `TEST`, and `PROD`. This example shows how to adjust compiler behavior for debugging, testing, and production readiness by specifying compile-time flags in `variant.spec.json`. For a detailed explanation, see [copt_setting README](copt_setting/README.md).
- **kitchen**: Demonstrates the use of `rules_variant` in a culinary-themed C++ project, illustrating how different configurations (variants of ingredients) can influence the outcome of the final product (dishes). This example provides a perspective on managing complex dependencies and configurations through variant selections. For more details, see [kitchen README](kitchen/README.md).
- **TV and Radio Channels**: This example demonstrates the use of `rules_variant` to configure TV and radio channels with content that varies based on the build configuration. It utilizes custom rules, macros, and genrules to showcase dynamic configuration adjustments. For more details, see [TV and Radio Channels README](tv_channels/README.md).
- **implicit_settings**: This example demonstrates the mechanism for augumenting variation specification with additional, implicitly defined variation points, applied uniformly for all supported variations [implicit_settings](implicit_settings/README.md)
- **variable_build_attributes**: This example demonstrates how to instantiate targets with variant-specific attributes. [variable_build_attributes](variable_build_attributes/README.md)
- **target_level_overrides**: This example demonstrates how to override build settings defined in variant spec on a target level. [target_level_overrides](target_level_overrides/README.md)
