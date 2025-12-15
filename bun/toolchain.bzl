"""Bun toolchain registration."""

load("//bun/internal:bun_toolchain.bzl", "bun_repository", "bun_toolchain")
load("//toolchains:bun_toolchain.bzl", "BUN_TOOLCHAIN_NAME", "BUN_VERSION")

def register_bun_toolchains(version = None):
    """Register Bun toolchains.
    
    Args:
        version: Bun version to use (defaults to BUN_VERSION)
    """
    if version == None:
        version = BUN_VERSION
    
    bun_repository(
        name = "bun",
        version = version,
    )
    
    native.register_toolchains("@rules_bun//toolchains:bun_toolchain_impl")

