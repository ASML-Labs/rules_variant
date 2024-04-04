# local_variants Example

This example demonstrates the use of project-specific variant rules to build C++ binaries with configurations defined in `faulty.spec.json`.

## Overview

The `BUILD.bazel` file defines a `cc_binary` target named `main`, utilizing a custom `cc_binary` rule provided by the `goto.fail` repository. This variant of `cc_binary` is exclusive to this workspace and is designed to showcase the building of targets under project-specific configurations, such as `rhel8x64_broken` and `wrl6x64_broken`.

## Usage

To build and run the examples, use the following commands:

### Building with Global Variants

Attempting to build with a global variant that does not match the project-specific configurations will not trigger the building of the `main` target:

```bash
bazel build :all --variants=rhel8x64
```

This command completes successfully but skips the `main` target as the specified variant does not match any project-specific configurations.

### Building with Project-Specific Variants

To build using a project-specific variant, utilize the `--broken_variants` flag alias defined in `.bazelrc`:

- **Building `rhel8x64_broken` Variant:**

  ```bash
  bazel build :all --broken_variants=rhel8x64_broken
  ```

  This command attempts to build the `rhel8x64_broken/main` target. However, due to the configuration specified in `faulty.spec.json`, the build may fail if the platform or toolchain is not correctly set up to handle the "broken" configurations.

### Understanding `faulty.spec.json`

The `faulty.spec.json` file defines project-specific configurations that simulate broken or incorrect build settings for demonstration purposes. For example:

```json
{
  "rhel8x64_broken": {
    "compilation_mode": "dbg",
    "platform_suffix": "r8b",
    "platforms": "@examples//bazel/platforms:broken_rhel8x64"
  },
  "wrl6x64_broken": {
    "compilation_mode": "dbg",
    "platform_suffix": "w6b",
    "platforms": "@examples//bazel/platforms:broken_wrl6x64"
  }
}
```

This JSON structure specifies two configurations, `rhel8x64_broken` and `wrl6x64_broken`, each with a unique platform and compilation mode intended to represent faulty or special-case scenarios.
