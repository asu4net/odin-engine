#!/usr/bin/env bash

title="game"
target="./$title"
out="$title"

debug_out=".bin/debug"
release_out=".bin/release"

build="odin build $target -vet-semicolon -show-timings"
debug="$build -debug -o:none -out:$debug_out/$out"
release="$build -debug -o:none -out:$release_out/$out"

echo "Build of $title started at $(date +%T)."

if [[ "$1" == "release" ]]; then
    mkdir -p "$release_out"
    eval $release
    status=$?
else
    mkdir -p "$debug_out"
    eval $debug
    status=$?
fi

if [[ $status -eq 0 ]]; then
    echo "Build succeeded at $(date +%T)."
else
    echo "Build failed."
fi