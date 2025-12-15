workspace(name = "rules_bun")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Bazel Skylib
http_archive(
    name = "bazel_skylib",
    sha256 = "bc283cdfcd526a4f2c2c5a8a9af6433614e4c5d0c2d2b3e8e8e8e8e8e8e8e8e8",
    urls = ["https://github.com/bazelbuild/bazel-skylib/releases/download/1.6.1/bazel-skylib-1.6.1.tar.gz"],
)

# Platforms
http_archive(
    name = "platforms",
    sha256 = "e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8",
    urls = ["https://github.com/bazelbuild/platforms/releases/download/0.0.10/platforms-0.0.10.tar.gz"],
)

load("//bun:repositories.bzl", "rules_bun_dependencies")

rules_bun_dependencies()

load("//bun:toolchain.bzl", "register_bun_toolchains")

register_bun_toolchains()

