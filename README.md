# rules_bun

Bazel rules for first-class Bun support.

## Overview

`rules_bun` provides Bazel rules for using the [Bun](https://bun.sh) JavaScript runtime, bundler, test runner, and package manager. It offers first-class support for all major Bun features including:

- **bun_binary**: Execute JavaScript/TypeScript files with Bun
- **bun_test**: Run tests with Bun's test runner (supports both native and Jest-compatible APIs)
- **bun_build**: Bundle JavaScript/TypeScript code
- **bun_install**: Install npm packages using Bun's package manager
- **bun_bundle**: Create production bundles

## Installation

### Using Bzlmod (Recommended)

Add to your `MODULE.bazel`:

```starlark
bazel_dep(name = "rules_bun", version = "0.1.0")
```

Then in your `MODULE.bazel` or a `.bzl` file:

```starlark
load("@rules_bun//bun:repositories.bzl", "rules_bun_dependencies")
load("@rules_bun//bun:toolchain.bzl", "register_bun_toolchains")

rules_bun_dependencies()
register_bun_toolchains()
```

### Using WORKSPACE

Add to your `WORKSPACE`:

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_bun",
    # ... download and extract rules_bun
)

load("@rules_bun//bun:repositories.bzl", "rules_bun_dependencies")
load("@rules_bun//bun:toolchain.bzl", "register_bun_toolchains")

rules_bun_dependencies()
register_bun_toolchains()
```

## Usage

### bun_binary

Execute a JavaScript/TypeScript file:

```starlark
load("@rules_bun//bun:bun.bzl", "bun_binary")

bun_binary(
    name = "app",
    entry_point = "main.js",
    srcs = ["main.js", "utils.js"],
    deps = [],
)
```

Run with: `bazel run //:app`

### bun_test

Run tests with Bun's test runner:

```starlark
load("@rules_bun//bun:bun.bzl", "bun_test")

bun_test(
    name = "calculator_test",
    srcs = ["calculator.test.js"],
    size = "small",
    tags = ["unit"],
)
```

Run with: `bazel test //:calculator_test`

The `bun_test` rule supports:

- Both Bun's native test API (`test()`, `describe()`, `expect()`)
- Jest-compatible API (`it()`, `describe()`, `expect()`)
- Full Bazel test framework integration (XML output, test discovery, filtering, sharding, coverage)

### bun_build

Bundle JavaScript/TypeScript code:

```starlark
load("@rules_bun//bun:bun.bzl", "bun_build")

bun_build(
    name = "bundle",
    entry_point = "src/index.js",
    format = "esm",
    minify = True,
    sourcemap = "external",
)
```

### bun_install

Install npm packages:

```starlark
load("@rules_bun//bun:bun.bzl", "bun_install")

bun_install(
    name = "install",
    package_json = "package.json",
    lockfile = "bun.lockb",
)
```

### bun_bundle

Create production bundles:

```starlark
load("@rules_bun//bun:bun.bzl", "bun_bundle")

bun_bundle(
    name = "app_bundle",
    entry_point = "src/app.js",
    format = "esm",
    target = "browser",
    minify = True,
)
```

## Examples

See the `examples/` directory for complete examples of each rule type:

- `examples/binary/`: Simple bun_binary usage
- `examples/test/`: bun_test with both native and Jest-compatible APIs
- `examples/build/`: bun_build bundling examples
- `examples/install/`: bun_install package management
- `examples/bundle/`: bun_bundle production bundling
- `examples/complex/`: Multi-rule integration examples

## API Reference

### bun_binary

```starlark
bun_binary(
    name,
    entry_point,  # Label, required
    srcs = [],    # List of labels
    deps = [],    # List of labels
    args = [],    # List of strings
    data = [],    # List of labels
)
```

### bun_test

```starlark
bun_test(
    name,
    srcs,              # List of labels, required
    deps = [],         # List of labels
    data = [],         # List of labels
    env = {},          # Dict of strings
    timeout = "moderate",  # "short" | "moderate" | "long" | "eternal"
    test_filter = "",  # String
    size = "medium",   # "small" | "medium" | "large" | "enormous"
    tags = [],         # List of strings
    flaky = False,     # Bool
)
```

### bun_build

```starlark
bun_build(
    name,
    entry_point,       # Label, required
    srcs = [],         # List of labels
    deps = [],         # List of labels
    out = None,        # Label
    format = None,     # "esm" | "cjs" | "iife"
    target = None,     # "browser" | "bun" | "node"
    minify = False,    # Bool
    sourcemap = None,  # "none" | "inline" | "external"
    external = [],     # List of strings
)
```

### bun_install

```starlark
bun_install(
    name,
    package_json,      # Label, required
    lockfile = None,  # Label
    install_peers = True,  # Bool
    production = False,   # Bool
)
```

### bun_bundle

```starlark
bun_bundle(
    name,
    entry_point,       # Label, required
    srcs = [],         # List of labels
    deps = [],         # List of labels
    out = None,        # Label
    format = None,     # "esm" | "cjs" | "iife"
    target = None,     # "browser" | "bun" | "node"
    sourcemap = None,  # "none" | "inline" | "external"
    external = [],     # List of strings
    splitting = False, # Bool
)
```

## Platform Support

- Linux (x86_64/amd64, aarch64/arm64)
- macOS (x86_64/amd64 for Intel, aarch64/arm64 for Apple Silicon)
- Windows (x86_64/amd64)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing to rules_bun.

## License

Apache 2.0
