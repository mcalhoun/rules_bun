"""Bun toolchain implementation and repository rules."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@bazel_tools//platforms:platform_common.bzl", "ToolchainInfo")

_BUILD_FILE_CONTENT = """\
load("@rules_bun//bun/internal:bun_toolchain.bzl", "bun_toolchain")

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "bun_binary",
    srcs = ["bun"],
    visibility = ["//visibility:public"],
)

bun_toolchain(
    name = "bun_toolchain_impl",
    bun_binary = ":bun_binary",
    bun_version = "{version}",
)
"""

def _bun_platform_os(rctx):
    """Detect the OS platform."""
    os_name = rctx.os.name.lower()
    if os_name.startswith("mac os"):
        return "darwin"
    elif os_name.startswith("windows"):
        return "windows"
    else:
        return "linux"

def _bun_platform_arch(rctx):
    """Detect the CPU architecture."""
    arch = rctx.os.arch.lower()
    if arch in ["amd64", "x86_64"]:
        return "x64"
    elif arch in ["arm64", "aarch64"]:
        return "aarch64"
    else:
        return "x64"  # default

def _bun_platform_suffix(rctx):
    """Get the platform suffix for Bun binary."""
    os_name = _bun_platform_os(rctx)
    arch = _bun_platform_arch(rctx)
    
    if os_name == "darwin":
        if arch == "aarch64":
            return "darwin-aarch64"
        else:
            return "darwin-x64"
    elif os_name == "windows":
        return "windows-x64.exe"
    else:  # linux
        if arch == "aarch64":
            return "linux-aarch64"
        else:
            return "linux-x64"

def _bun_repository_impl(rctx):
    """Repository rule implementation for fetching Bun binary."""
    version = rctx.attr.version
    platform_suffix = _bun_platform_suffix(rctx)
    
    # Bun release URL pattern: https://github.com/oven-sh/bun/releases/download/bun-v{version}/bun-{platform}.zip
    url = "https://github.com/oven-sh/bun/releases/download/bun-v{version}/bun-{platform}.zip".format(
        version = version,
        platform = platform_suffix,
    )
    
    # Download and extract the binary
    rctx.download_and_extract(
        url = url,
        output = ".",
        stripPrefix = "",
    )
    
    # Create BUILD file
    rctx.file("BUILD.bazel", _BUILD_FILE_CONTENT.format(version = version))

_bun_repository = repository_rule(
    implementation = _bun_repository_impl,
    attrs = {
        "version": attr.string(
            mandatory = True,
            doc = "Bun version to download (e.g., '1.0.0')",
        ),
    },
    doc = "Downloads and extracts the Bun binary for the current platform.",
)

def bun_repository(name, version, **kwargs):
    """Declare a Bun repository.
    
    Args:
        name: Repository name
        version: Bun version (e.g., "1.0.0")
        **kwargs: Additional arguments passed to the repository rule
    """
    _bun_repository(
        name = name,
        version = version,
        **kwargs
    )

def _bun_toolchain_impl(ctx):
    """Implementation of the Bun toolchain."""
    bun_binary = ctx.file.bun_binary
    
    return [
        ToolchainInfo(
            bun_binary = bun_binary,
            bun_version = ctx.attr.bun_version,
        ),
    ]

bun_toolchain = rule(
    implementation = _bun_toolchain_impl,
    attrs = {
        "bun_binary": attr.label(
            allow_single_file = True,
            mandatory = True,
            doc = "The Bun binary executable",
        ),
        "bun_version": attr.string(
            mandatory = True,
            doc = "The Bun version",
        ),
    },
    doc = "Toolchain for running Bun",
)

