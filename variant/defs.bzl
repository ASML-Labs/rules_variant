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

""" Public interface """

load("//variant/private:derivation.bzl", _derivation_builder = "derivation_builder")
load("//variant/private:filter.bzl", _filter_attrs = "filter_attrs")
load("//variant/private:flags.bzl", _flags = "flags")
load("//variant/private:variant.bzl", _variant_builder = "variant_builder")

visibility("public")

variant_builder = _variant_builder
derivation_builder = _derivation_builder
flags = _flags
filter_attrs = _filter_attrs
