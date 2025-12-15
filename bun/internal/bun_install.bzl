"""bun_install rule implementation for package management."""

load("@bazel_skylib//lib:paths.bzl", "paths")

def _get_bun_toolchain(ctx):
    """Get the Bun toolchain from the current context."""
    return ctx.toolchains["@rules_bun//bun:toolchain_type"]

def _bun_install_impl(ctx):
    """Implementation of the bun_install rule."""
    bun_toolchain = _get_bun_toolchain(ctx)
    bun_binary = bun_toolchain.bun_binary
    
    # Get package.json
    package_json = ctx.file.package_json
    if not package_json:
        fail("bun_install requires a package_json file")
    
    # Output directory for installed packages
    node_modules = ctx.actions.declare_directory(ctx.label.name + "_node_modules")
    
    # Lockfile handling
    lockfile = None
    if ctx.file.lockfile:
        lockfile = ctx.file.lockfile
    
    # Build install command
    args = ctx.actions.args()
    args.add("install")
    
    if lockfile:
        args.add("--lockfile", lockfile.path)
    
    # Run bun install
    # Note: In a real implementation, this would need to handle the install
    # in a way that works with Bazel's sandboxing. This is a simplified version.
    ctx.actions.run(
        executable = bun_binary,
        arguments = [args],
        inputs = [package_json] + ([lockfile] if lockfile else []),
        outputs = [node_modules],
        working_directory = package_json.dirname,
        mnemonic = "BunInstall",
        progress_message = "Installing npm packages with Bun",
    )
    
    # Create a provider for npm packages
    # This is a simplified version - in production, you'd want to parse
    # package.json and create proper providers for each package
    return [
        DefaultInfo(
            files = depset([node_modules]),
        ),
    ]

bun_install = rule(
    implementation = _bun_install_impl,
    attrs = {
        "package_json": attr.label(
            allow_single_file = ["package.json"],
            mandatory = True,
            doc = "package.json file",
        ),
        "lockfile": attr.label(
            allow_single_file = ["bun.lockb", "package-lock.json", "yarn.lock"],
            doc = "Lockfile (bun.lockb, package-lock.json, or yarn.lock)",
        ),
        "install_peers": attr.bool(
            default = True,
            doc = "Install peer dependencies",
        ),
        "production": attr.bool(
            default = False,
            doc = "Install only production dependencies",
        ),
    },
    toolchains = ["@rules_bun//bun:toolchain_type"],
    doc = "Install npm packages using Bun's package manager",
)

