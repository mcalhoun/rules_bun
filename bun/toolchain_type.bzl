"""Toolchain type definition for Bun."""

load("@bazel_tools//platforms:platform_common.bzl", "platform_common")

# Toolchain type for Bun
toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

