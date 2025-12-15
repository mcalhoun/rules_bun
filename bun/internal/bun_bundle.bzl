"""bun_bundle rule implementation for production bundling."""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_tools//platforms:platform_common.bzl", "platform_common")

def _get_bun_toolchain(ctx):
    """Get the Bun toolchain from the current context."""
    return ctx.toolchains["@rules_bun//bun:toolchain_type"]

def _bun_bundle_impl(ctx):
    """Implementation of the bun_bundle rule."""
    bun_toolchain = _get_bun_toolchain(ctx)
    bun_binary = bun_toolchain.bun_binary
    
    # Get entry point
    entry_point = ctx.file.entry_point
    if not entry_point:
        fail("bun_bundle requires an entry_point")
    
    # Determine output file
    output = ctx.outputs.out
    if not output:
        output_name = ctx.label.name + ".bundle.js"
        output = ctx.actions.declare_file(output_name)
    
    # Collect source files
    srcs = ctx.files.srcs
    deps = depset(
        direct = [entry_point] + srcs,
        transitive = [dep[DefaultInfo].files for dep in ctx.attr.deps],
    )
    
    # Build command arguments for production bundling
    args = ctx.actions.args()
    args.add("build")
    args.add(entry_point.path)
    args.add("--outfile", output.path)
    
    # Production optimizations
    args.add("--minify")
    
    # Output format
    if ctx.attr.format:
        args.add("--format", ctx.attr.format)
    else:
        # Default to standalone for production bundles
        args.add("--format", "esm")
    
    # Target platform
    if ctx.attr.target:
        args.add("--target", ctx.attr.target)
    
    # Source maps (external for production)
    if ctx.attr.sourcemap:
        args.add("--sourcemap", ctx.attr.sourcemap)
    else:
        args.add("--sourcemap", "external")
    
    # External dependencies
    if ctx.attr.external:
        args.add_all("--external", ctx.attr.external)
    
    # Splitting (for code splitting)
    if ctx.attr.splitting:
        args.add("--splitting")
    
    # Run the bundle
    ctx.actions.run(
        executable = bun_binary,
        arguments = [args],
        inputs = depset([entry_point] + srcs, transitive = [dep[DefaultInfo].files for dep in ctx.attr.deps]),
        outputs = [output],
        mnemonic = "BunBundle",
        progress_message = "Bundling %s with Bun" % entry_point.short_path,
    )
    
    return [
        DefaultInfo(
            files = depset([output]),
        ),
    ]

bun_bundle = rule(
    implementation = _bun_bundle_impl,
    attrs = {
        "entry_point": attr.label(
            allow_single_file = [".js", ".ts", ".jsx", ".tsx", ".mjs"],
            mandatory = True,
            doc = "The entry point file to bundle",
        ),
        "srcs": attr.label_list(
            allow_files = [".js", ".ts", ".jsx", ".tsx", ".mjs", ".json", ".css", ".html"],
            doc = "Additional source files and assets",
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
        "sourcemap": attr.string(
            values = ["none", "inline", "external"],
            doc = "Source map generation",
        ),
        "external": attr.string_list(
            doc = "External dependencies to exclude from bundle",
        ),
        "splitting": attr.bool(
            default = False,
            doc = "Enable code splitting",
        ),
    },
    toolchains = ["@rules_bun//bun:toolchain_type"],
    doc = "Create production bundles using Bun",
)

