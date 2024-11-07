#!/bin/sh

if [ $# -eq 0 -o $# -ne 2 -o "$1" = '-h' -o "$1" = '--help' ]; then
    cat >&2 << EOF
USAGE: $0 compilation-output-source source-dir

Use this to convert the output of compilation for an eclipse project to the
compile_commands.json used by clangd.
Will output compile_commands.json's content to stdout
compilation-output-source: text file containing the compilation output
                           use "-" for stdin
source-dir: working directory during compilation
            (like .../project/Debug_FLASH)
EOF
    exit 1
fi

ccout="$1"
ccdir="$(cygpath -am "$2")"
if [ ! -d "$ccdir" ]; then
    echo "dir '$ccdir' not found. Aborting" 1>&2
    exit 2
fi

toolchain='C:/NXP/S32Ds.3.5/S32DS/build_tools/gcc_v10.2/gcc-10.2-arm32-eabi/bin'
grep arm-none-eabi "$ccout" \
    | sed "s;arm-none-eabi;${toolchain}/arm-none-eabi;g" \
    | grep -wE 'arm-none-eabi-(gcc|g\+\+|clang)' \
    | jq -nR '[inputs|{directory:"'"$ccdir"'", command:., file: match(" [^ ]+$").string[1:]|gsub("\""; "")}]'
