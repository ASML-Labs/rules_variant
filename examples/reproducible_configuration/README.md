# Reproducible Configuration Example

This example demonstrates the process of reproducing a build configuration using `rules_variant` and a dumped configuration file (`dumped.spec.json`).

## Overview

The structure includes two directories: `original` and `reproduced`. The `original` directory's `BUILD.bazel` file specifies a build target with a particular configuration. The `reproduced` directory uses the `dumped.spec.json` to replicate the `original` build target. A separate set of variant rules, grouped under the `@dumped.configs` repository and defined in the `WORKSPACE.bazel` file, utilizes `dumped.spec.json` for repro-variant rule(s) generation.

## Usage

To reproduce a build configuration, execute the following steps:

1. Build the original target with a specific configuration:
   ```
   bazel build original:rhel8x64/main --variants=rhel8x64
   ```
   **Console output:**
   ```
   DEBUG:
   
             TARGET: rhel8x64/main_/main
           PLATFORM: @//bazel/platforms:fake_rhel8x64
   
   INFO: Analyzed target //reproducible_configuration/original:rhel8x64/main (7 packages loaded, 24 targets configured).
   INFO: Found 1 target...
   Target //reproducible_configuration/original:rhel8x64/main_with_cfg up-to-date (nothing to build)
   INFO: Elapsed time: 0.230s, Critical Path: 0.00s
   INFO: 1 process: 1 internal.
   INFO: Build completed successfully, 1 total action
   ```
2. Obtain the configuration ID for the build using `bazel config`:
   ```
   bazel config
   ```
   Identify the configuration ID from the output that corresponds to your build.

3. Dump the configuration into `dumped.spec.json` using the `config2variant.jq` tool:
   ```
   bazel config <config_id> --output=json | jq -f ../../tools/config2variant.jq > dumped.spec.json
   ```
4. Adjust the target definition in `reproduced/BUILD.bazel` to include the configuration hash (`dump_<hash>`) as demonstrated in the provided console output. This step ensures the `reproduced` build uses the correct configuration from `dumped.spec.json`.

5. Reproduce the build in the `reproduced` directory using the adjusted target and the `dumped.configs` repository:
   ```
   bazel build reproduced:dump_<hash>/main --@@dumped.configs//:variations=dump_<hash>
   ```
   **Console output:**
   ```
   DEBUG:
   
             TARGET: dump_a7b3/main_/main
           PLATFORM: @//bazel/platforms:fake_rhel8x64
   
   INFO: Analyzed target //reproducible_configuration/reproduced:dump_a7b3/main (2 packages loaded, 24 targets configured).
   INFO: Found 1 target...
   Target //reproducible_configuration/reproduced:dump_a7b3/main_with_cfg up-to-date (nothing to build)
   INFO: Elapsed time: 0.108s, Critical Path: 0.00s
   INFO: 1 process: 1 internal.
   INFO: Build completed successfully, 1 total action
   ```
