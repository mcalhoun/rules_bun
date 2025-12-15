"""Public API for rules_bun.

This module provides all the rules for using Bun with Bazel.
"""

load("//bun/internal:bun_binary.bzl", _bun_binary = "bun_binary")
load("//bun/internal:bun_test.bzl", _bun_test = "bun_test")
load("//bun/internal:bun_build.bzl", _bun_build = "bun_build")
load("//bun/internal:bun_install.bzl", _bun_install = "bun_install")
load("//bun/internal:bun_bundle.bzl", _bun_bundle = "bun_bundle")
load("//bun:toolchain.bzl", _register_bun_toolchains = "register_bun_toolchains")
load("//bun:repositories.bzl", _rules_bun_dependencies = "rules_bun_dependencies")

# Re-export all rules
bun_binary = _bun_binary
bun_test = _bun_test
bun_build = _bun_build
bun_install = _bun_install
bun_bundle = _bun_bundle

# Re-export setup functions
register_bun_toolchains = _register_bun_toolchains
rules_bun_dependencies = _rules_bun_dependencies

