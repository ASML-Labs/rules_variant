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

# Capture the first 4 characters of the configHash value from the input
# and prefix it with "dump-" to use as the configuration name.
("dump_" + .configHash[0:4]) as $configName |

# Construct the output object using the modified configName as a dynamic key.
{
  ($configName): (
    # Reduce the fragmentOptions array to a single object,
    # combining options from all fragments.
    reduce .fragmentOptions[] as $fragment ({}; . + (
      # Iterate over each key-value pair in the options object of the fragment
      $fragment.options
      | with_entries(
          # Select entries based on specified conditions:
          # - Keys should not start with "incompatible", "experimental", or "@"
          # - Keys should not contain spaces
          # - Exclude specific keys: "action_env", "modify_execution_info", "apk_signing_method", "flag_alias", "strip"
          select(
            (.key | type == "string") and
            (.key | test("^(incompatible|experimental|@)| ") | not) and
            .key != "action_env" and
            .key != "modify_execution_info" and
            .key != "apk_signing_method" and
            .key != "flag_alias" and
            .key != "strip"
          )
          # For values that are string representations of arrays,
          # attempt to parse them as JSON arrays. If parsing fails,
          # manually process the string to split it into an array.
          | .value |= (
            if type == "string" and startswith("[") and endswith("]") then
              (fromjson? // (gsub("^\\[|\\]$"; "") | split(", ") | map(select(. != ""))))
            else
              .
            end
          )
        )
      # Check if the current entry is "platforms" and if its value starts with "//"
      # If so, prepend "@" to the value
      | if .platforms? then
          .platforms |= map(
            if startswith("//") then
              "@\(.)"
            else
              .
            end
          )
        else
          .
        end
    ))
  )
}

