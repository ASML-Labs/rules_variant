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

{
  localSystem ? builtins.currentSystem,
  ...
}@args:
let
  external_sources = import ./nix/sources.nix;
  nixpkgs = import external_sources.nixpkgs {
    inherit localSystem;
    config = { };
  };
  devShell = nixpkgs.mkShell {
    name = "rules_variant-dev_shell";
    packages = with nixpkgs; [
      bashInteractive
      bazelisk
      bazel-buildtools
      cocogitto
      findutils
      git
      helix
      niv
      nixfmt
      statix
      zlib
    ];
    # The following trick allows different tools, to 'find' bazelisk as bazel
    shellHook = ''
      mkdir -p .bazelisk-bin
      ln -f -s ${nixpkgs.bazelisk}/bin/bazelisk .bazelisk-bin/bazel
      export PATH="$(realpath .bazelisk-bin)/:$PATH"
    '';
  };
in
{
  inherit devShell nixpkgs;
}
