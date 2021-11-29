#!/bin/bash
set -e

script_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

cd "$script_dir"

sp_executable="$1"
out_path="$script_dir/addons/sourcemod/plugins"
include_paths=""
sp_optimize="-O2"
sp_verbose="-v2"

for a in "${@:2}"
do
    case $a in -i=*)
        include_paths="$include_paths $a"
    esac
done

for script in "${@:2}"
do
    case $script in *sp)
        script_name="${script%.*}"
        script_name="${script_name##*/}"
        outArg="-o=$out_path/$script_name.smx"

        echo start compiling "'$script'"
        "$sp_executable" $script "$outArg" $include_paths $sp_optimize $sp_verbose
    esac
done
