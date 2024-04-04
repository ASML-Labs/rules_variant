# Tools for `rules_variant`

## `config2variant.jq`

`config2variant.jq` is a script designed to process the output of `bazel config` it into a format that is compatible with `rules_variant`.

### Usage

1. **List Available Configs**: Initially, run `bazel build` to compile your project, followed by `bazel config` to list all available configuration hashes.
2. **Convert Selected Config**: For the desired configuration, execute `bazel config <config hash> --output=json | jq -f config2variant.jq > variant.spec.json` to generate a `variant.spec.json`.
3. **Build Targets Using Configuration**: Finally, build your targets using the previously dumped configuration by running a command like `bazel build :dump-fd67/main --variants=dump-fd67`, specifying the variant according to the generated specification.
