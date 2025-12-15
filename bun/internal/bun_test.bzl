"""bun_test rule implementation with full Bazel test framework integration."""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_tools//platforms:platform_common.bzl", "platform_common")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def _get_bun_toolchain(ctx):
    """Get the Bun toolchain from the current context."""
    return ctx.toolchains["@rules_bun//bun:toolchain_type"]

def _bun_test_impl(ctx):
    """Implementation of the bun_test rule."""
    bun_toolchain = _get_bun_toolchain(ctx)
    bun_binary = bun_toolchain.bun_binary
    
    # Get test files
    test_files = ctx.files.srcs
    if not test_files:
        fail("bun_test requires at least one test file in srcs")
    
    # Collect all source files and dependencies
    srcs = ctx.files.srcs
    deps = depset(
        direct = srcs,
        transitive = [dep[DefaultInfo].files for dep in ctx.attr.deps],
    )
    
    # Create runfiles
    runfiles = ctx.runfiles(
        files = [bun_binary] + srcs,
        transitive_files = deps,
    )
    
    # Add transitive runfiles from dependencies
    for dep in ctx.attr.deps:
        runfiles = runfiles.merge(dep[DefaultInfo].default_runfiles)
    
    # Add data files
    for data_file in ctx.files.data:
        runfiles = runfiles.merge(ctx.runfiles(files = [data_file]))
    
    # Build test command
    # Bun test command: bun test [files...] [options]
    test_script = ctx.actions.declare_file(ctx.label.name + "_test.sh")
    
    # Generate XML output for Bazel test framework
    test_output = ctx.actions.declare_file(ctx.label.name + "_test_output.xml")
    
    # Build the test script
    test_files_str = " ".join([f.short_path for f in test_files])
    
    script_content = """#!/bin/bash
set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${{BASH_SOURCE[0]}}")" && pwd)"
BUN_BINARY="${{SCRIPT_DIR}}/{bun_binary_path}"
TEST_OUTPUT="${{SCRIPT_DIR}}/{test_output_path}"

# Set environment variables
{env_vars}

# Run Bun test with XML output
# Bun's test runner supports --reporter flag for different output formats
# We'll use a custom reporter script to generate Bazel-compatible XML
"${{BUN_BINARY}}" test {test_files} \\
    --reporter json \\
    --timeout {timeout} \\
    {test_filter} \\
    > "${{TEST_OUTPUT}}.json" 2>&1 || TEST_EXIT_CODE=$?

# Convert Bun test output to Bazel XML format
# This is a simplified version - in production, you'd want a more robust converter
cat > "${{TEST_OUTPUT}}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuites>
  <testsuite name="{test_name}" tests="1" failures="0" errors="0" time="0">
    <testcase name="bun_test" classname="{test_name}" time="0">
EOF

if [ -z "${{TEST_EXIT_CODE:-}}" ]; then
    echo '      <system-out>Tests passed</system-out>' >> "${{TEST_OUTPUT}}"
else
    echo '      <failure message="Test failed">' >> "${{TEST_OUTPUT}}"
    cat "${{TEST_OUTPUT}}.json" >> "${{TEST_OUTPUT}}" || true
    echo '</failure>' >> "${{TEST_OUTPUT}}"
fi

cat >> "${{TEST_OUTPUT}}" <<EOF
    </testcase>
  </testsuite>
</testsuites>
EOF

# Exit with the test result
exit ${{TEST_EXIT_CODE:-0}}
""".format(
        bun_binary_path = bun_binary.short_path,
        test_output_path = test_output.short_path,
        test_files = test_files_str,
        test_name = ctx.label.name,
        timeout = ctx.attr.timeout or "30000",
        test_filter = "--test-name-pattern " + ctx.attr.test_filter if ctx.attr.test_filter else "",
        env_vars = "\n".join([
            "export {}={}".format(k, v)
            for k, v in ctx.attr.env.items()
        ]) if ctx.attr.env else "",
    )
    
    ctx.actions.write(
        output = test_script,
        content = script_content,
        is_executable = True,
    )
    
    return [
        DefaultInfo(
            executable = test_script,
            runfiles = runfiles,
            files = depset([test_script, test_output]),
        ),
        # TestEnvironment is provided by Bazel's testing framework
        # We'll use the env attribute directly in the script
        OutputGroupInfo(
            # Bazel expects test output in a specific location
            test_output = depset([test_output]),
        ),
    ]

bun_test = rule(
    implementation = _bun_test_impl,
    test = True,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".test.js", ".test.ts", ".spec.js", ".spec.ts", ".test.jsx", ".test.tsx", ".spec.jsx", ".spec.tsx"],
            mandatory = True,
            doc = "Test files to run",
        ),
        "deps": attr.label_list(
            doc = "Dependencies",
        ),
        "data": attr.label_list(
            allow_files = True,
            doc = "Data files to include in runfiles",
        ),
        "env": attr.string_dict(
            doc = "Environment variables for the test",
        ),
        "timeout": attr.string(
            default = "moderate",
            values = ["short", "moderate", "long", "eternal"],
            doc = "Test timeout",
        ),
        "test_filter": attr.string(
            doc = "Filter tests by name pattern",
        ),
        "size": attr.string(
            default = "medium",
            values = ["small", "medium", "large", "enormous"],
            doc = "Test size",
        ),
        "tags": attr.string_list(
            doc = "Test tags",
        ),
        "flaky": attr.bool(
            default = False,
            doc = "Whether the test is flaky",
        ),
    },
    toolchains = ["@rules_bun//bun:toolchain_type"],
    doc = "Run tests using Bun's test runner with Bazel test framework integration",
)

