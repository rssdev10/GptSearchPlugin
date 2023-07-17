#!/bin/sh

set -e 
# set -o pipefail

mkdir -p sysimage

julia --startup-file=no -e 'using Pkg; Pkg.add("PackageCompiler")'
PKG_NAME=`julia  --project=@. --startup-file=no -e 'using Pkg; print(Pkg.project().name)'`
echo "Processing package: $PKG_NAME"

echo "Generating code trace file"
julia --project=@. --startup-file=no --trace-compile=sysimage/precompile.jl test/runtests.jl

echo "Generating binary image"
julia --project=@. --startup-file=no -e '
using PackageCompiler;
PackageCompiler.create_sysimage(:'"$PKG_NAME"';
    cpu_target="generic;sandybridge,-xsaveopt,clone_all;haswell,-rdrnd,base(1)",
    sysimage_path="sysimage/sysimage.so",
    precompile_statements_file="sysimage/precompile.jl")
'
