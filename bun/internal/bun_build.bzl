"""bun_build rule implementation for bundling."""

load("@bazel_skylib//lib:paths.bzl", "paths")

def _get_bun_toolchain(ctx):
    """Get the Bun toolchain from the current context."""
    return ctx.toolchains["@rules_bun//bun:toolchain_type"]

def _bun_build_impl(ctx):
    """Implementation of the bun_build rule."""
    bun_toolchain = _get_bun_toolchain(ctx)
    bun_binary = bun_toolchain.bun_binary
    
    # Get entry point
    entry_point = ctx.file.entry_point
    if not entry_point:
        fail("bun_build requires an entry_point")
    
    # Determine output file
    output = ctx.outputs.out
    if not output:
        # Default output name based on entry point
        output_name = ctx.label.name + ".js"
        output = ctx.actions.declare_file(output_name)
    
    # Collect source files
    srcs = ctx.files.srcs
    deps = depset(
        direct = [entry_point] + srcs,
        transitive = [dep[DefaultInfo].files for dep in ctx.attr.deps],
    )
    
    # Build command arguments
    args = ctx.actions.args()
    args.add("build")
    args.add(entry_point.path)
    args.add("--outfile", output.path)
    
    # Output format
    if ctx.attr.format:
        args.add("--format", ctx.attr.format)
    
    # Target platform
    if ctx.attr.target:
        args.add("--target", ctx.attr.target)
    
    # Minify
    if ctx.attr.minify:
        args.add("--minify")
    
    # Source maps
    if ctx.attr.sourcemap:
        args.add("--sourcemap")
    
    # External dependencies
    if ctx.attr.external:
        args.add_all("--external", ctx.attr.external)
    
    # Run the build
    ctx.actions.run(
        executable = bun_binary,
        arguments = [args],
        inputs = depset([entry_point] + srcs, transitive = [dep[DefaultInfo].files for dep in ctx.attr.deps]),
        outputs = [output],
        mnemonic = "BunBuild",
        progress_message = "Building %s with Bun" % entry_point.short_path,
    )
    
    return [
        DefaultInfo(
            files = depset([output]),
        ),
    ]

bun_build = rule(
    implementation = _bun_build_impl,
    attrs = {
        "entry_point": attr.label(
            allow_single_file = [".js", ".ts", ".jsx", ".tsx", ".mjs"],
            mandatory = True,
            doc = "The entry point file to bundle",
        ),
        "srcs": attr.label_list(
            allow_files = [".js", ".ts", ".jsx", ".tsx", ".mjs", ".json"],
            doc = "Additional source files",
        ),
        "deps": attr.label_list(
            doc = "Dependencies",
        ),
        "out": attr.output(
            doc = "Output file name",
        ),
        "format": attr.string(
            values = ["esm", "cjs", "iife"],
            doc = "Output format: esm, cjs, or iife",
        ),
        "target": attr.string(
            values = ["browser", "bun", "node"],
            doc = "Target platform",
        ),
        "minify": attr.bool(
            default = False,
            doc = "Minify the output",
        ),
        "sourcemap": attr.string(
            values = ["none", "inline", "external"],
            doc = "Source map generation",
        ),
        "external": attr.string_list(
            doc = "External dependencies to exclude from bundle",
        ),
    },
    toolchains = ["@rules_bun//bun:toolchain_type"],
    doc = "Bundle JavaScript/TypeScript files using Bun",
)

