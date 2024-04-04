#!/usr/bin/env bash

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

# This script processes the output of `bazel cquery --output=graph` to generate a Graphviz graph
# with nodes representing differently configured variants of an abstract configuration.
# Each node is colorized based on its configuration hash.
# Example use: bazel cquery //implicit_settings/... --nobuild_manual_tests --output=graph --nograph:factored | ../../tools/configviz/color_mapper.sh > graph.dot

set -euo pipefail

LABEL_TEMPLATE='<<TABLE BORDER=\"0\" CELLBORDER=\"1\" CELLSPACING=\"0\"><TR><TD BGCOLOR=\"white\">%s<\/TD><\/TR><\/TABLE>>'
STYLE_TEMPLATE='fillcolor=\"#\3\",color=black,style=\"filled,solid\"'

declare -a nouns
declare -a adjectives
declare -A config_nodes
declare -A all_edges
declare -A hash_name_map
declare -A ellipse_nodes

hash_to_name() {
  local unbracked="${1//[(]/}"
  unbracked="${unbracked//[)]/}"
  local hash_int=$((16#$unbracked))
  local noun_index=$((hash_int % ${#nouns[@]}))
  local adjective_index=$((hash_int % ${#adjectives[@]}))
  local adjective="${adjectives[adjective_index]//[[:space:]]/}"
  local noun="${nouns[noun_index]//[[:space:]]/}"
  echo "(${adjective}_${noun})"
}

generate_sed_script() {
  local grouped_output="$1"
  local config_node_template=""
  if [[ "$grouped_output" != "grouped" ]]; then
    config_node_template="\n\\1(\\3)\" [label=${LABEL_TEMPLATE//%s/\\3 \(\\3\)},${STYLE_TEMPLATE},shape=ellipse]"
  fi
  echo "s/(null)/(213700)/g;/->/!{
    s@\(.*\"\)\(.*\) (\(.*\)).*@\\1\\2 (\\3)\" [label=${LABEL_TEMPLATE//%s/\\2},${STYLE_TEMPLATE}]\
    ${config_node_template}@
  }"
}

process_input() {
  local input_file="$1"
  local sed_script="$2"
  local grouped_output="$3"

  while IFS= read -r line; do
    while read -r hash; do
      [[ -z "$hash" ]] && continue
      local name=$(hash_to_name "$hash")
      local unbracked="${hash//[(]/}"
      unbracked="${unbracked//[)]/}"
      hash_name_map["$name"]="$unbracked"
      line=${line//"$hash"/$name}
      local config_name="${name//[(]/}"
      config_name="${config_name//[)]/} - $unbracked"
      if [[ "$line" =~ "->" ]]; then
        all_edges["$line"]=1
      else
        config_nodes["$config_name"]+="    $line\n"
        [[ "$grouped_output" != "grouped" ]] && ellipse_nodes["$name"]="$line"
      fi
    done <<< "$(
      grep -o '([a-f0-9]\{6\})' <<< "$line" \
          | uniq
    )"
  done < <(
    sed -E 's/\(([0-9a-fA-F]{6})[0-9a-fA-F]\)/(\1)/g' "$input_file" \
      | sed -e "$sed_script" "$input_file"
    )
}

generate_graph_output() {
  local grouped_output="$1"
  echo "digraph CG {"
  echo "  graph [splines=ortho, nodesep=0.6, ranksep=1, pad=0.5, rankdir=TB, clusterrank=local, overlap=false];"
  echo "  overlap=false;"
  echo "  node [shape=box];"

  if [[ "$grouped_output" == "grouped" ]]; then
    for config in "${!config_nodes[@]}"; do
      echo "  subgraph cluster_${config//[^a-zA-Z0-9_]/_} {"
      echo "    label=\"$config\";"
      echo -e "${config_nodes[$config]}" | sed '/([a-f0-9]\{6\})/d'
      echo "  }"
    done
  else
    echo "  subgraph cluster_targets {"
    echo "    label=\"Targets\";"
    for node in "${!config_nodes[@]}"; do
      echo -e "${config_nodes[$node]}" | sed '/shape=ellipse/d'
    done
    echo "    targets [style=invis];"
    echo "  }"
    echo "  subgraph cluster_configs {"
    echo "    label=\"Configs\";"
    for node in "${!ellipse_nodes[@]}"; do
      echo "    ${ellipse_nodes[$node]}"
    done
    echo "    configs [style=invis];"
    echo "  }"
    echo "  configs -> targets [style=invis];"
  fi

  for edge in "${!all_edges[@]}"; do
    local origin_node="${edge%%\)\" ->*}"
    local origin_hash_name="${origin_node##*\(}"
    local target_node="${edge##*-> *\(}"
    local target_hash_name="${target_node%%\)*}"
    [[ "$target_hash_name" =~ [0-9] ]] && continue
    local origin_color="${hash_name_map["($origin_hash_name)"]:="000000"}"
    echo "$edge [color=\"#$origin_color\"]"
  done
  echo "}"
}

display_help() {
  echo "Usage: $0 [-h] [-g grouped|ungrouped] [input_file]"
  echo "  -h  Display this help message."
  echo "  -g  Specify the output grouping: 'grouped' or 'ungrouped'. Default is 'grouped'."
  echo "  input_file  Specify the input file. Default is '/dev/stdin'."
}

main() {
  local grouped_output="grouped"
  local input_file="/dev/stdin"

  while getopts ":hg:" opt; do
    case $opt in
      h) echo "Usage: $0 [-h] [-g grouped|ungrouped] [input_file]"; exit 0 ;;
      g) grouped_output="${OPTARG}" ;;
      \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
      :)
        echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
    esac
  done
  shift $((OPTIND - 1))
  [[ $# -gt 0 ]] && input_file="$1"

  mapfile -t nouns < "$(dirname "$0")/nouns.txt"
  mapfile -t adjectives < "$(dirname "$0")/adjectives.txt"

  local sed_script=$(generate_sed_script "$grouped_output")
  process_input "$input_file" "$sed_script" "$grouped_output"
  generate_graph_output "$grouped_output"
}

main "$@"

