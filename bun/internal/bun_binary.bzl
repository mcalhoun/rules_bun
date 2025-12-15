"""bun_binary rule implementation."""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_tools//platforms:platform_common.bzl", "platform_common")

def _get_bun_toolchain(ctx):
    """Get the Bun toolchain from the current context."""
    return ctx.toolchains["@rules_bun//bun:toolchain_type"]

def _bun_binary_impl(ctx):
    """Implementation of the bun_binary rule."""
    bun_toolchain = _get_bun_toolchain(ctx)
    bun_binary = bun_toolchain.bun_binary
    
    # Get the entry point
    entry_point = ctx.file.entry_point
    entry_point_path = entry_point.short_path
    
    # Collect all source files
    srcs = ctx.files.srcs
    deps = depset(
        direct = [entry_point] + srcs,
        transitive = [dep[DefaultInfo].files for dep in ctx.attr.deps],
    )
    
    # Create runfiles
    runfiles = ctx.runfiles(
        files = [bun_binary, entry_point] + srcs,
        transitive_files = deps,
    )
    
    # Add transitive runfiles from dependencies
    for dep in ctx.attr.deps:
        runfiles = runfiles.merge(dep[DefaultInfo].default_runfiles)
    
    # Build the command
    args = ctx.actions.args()
    args.add("run")
    args.add(entry_point_path)
    
    # Add user-provided arguments
    args.add_all(ctx.attr.args)
    
    # Create the executable script
    executable = ctx.actions.declare_file(ctx.label.name + ".sh")
    
    # Build the script content
    script_content = """#!/bin/bash
set -e
# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${{BASH_SOURCE[0]}}")" && pwd)"
# Run Bun with the entry point
exec "${{SCRIPT_DIR}}/{bun_binary_path}" run "${{SCRIPT_DIR}}/{entry_point_path}" "$@"
""".format(
        bun_binary_path = bun_binary.short_path,
        entry_point_path = entry_point_path,
    )
    
    ctx.actions.write(
        output = executable,
        content = script_content,
        is_executable = True,
    )
    
    return [
        DefaultInfo(
            executable = executable,
            runfiles = runfiles,
            files = depset([executable]),
        ),
    ]

bun_binary = rule(
    implementation = _bun_binary_impl,
    attrs = {
        "entry_point": attr.label(
            allow_single_file = [".js", ".ts", ".jsx", ".tsx", ".mjs"],
            mandatory = True,
            doc = "The entry point file to execute",
        ),
        "srcs": attr.label_list(
            allow_files = [".js", ".ts", ".jsx", ".tsx", ".mjs", ".json"],
            doc = "Additional source files",
        ),
        "deps": attr.label_list(
            doc = "Dependencies",
        ),
        "args": attr.string_list(
            doc = "Arguments to pass to the entry point",
        ),
        "data": attr.label_list(
            allow_files = True,
            doc = "Data files to include in runfiles",
        ),
    },
    executable = True,
    toolchains = ["@rules_bun//bun:toolchain_type"],
    doc = "Execute a JavaScript/TypeScript file using Bun",
)

