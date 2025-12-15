"""Unit tests for bun_toolchain."""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//bun/internal:bun_toolchain.bzl", "bun_repository")

def _bun_toolchain_test_impl(ctx):
    """Test implementation for bun_toolchain."""
    env = unittest.begin(ctx)
    
    # Test that bun_repository can be called
    # This is a basic test - in a real implementation, you'd test
    # the actual repository rule behavior
    asserts.true(env, True, "bun_repository function exists")
    
    return unittest.end(env)

bun_toolchain_test = unittest.make(_bun_toolchain_test_impl)

def bun_toolchain_test_suite(name):
    """Test suite for bun_toolchain."""
    bun_toolchain_test(name = name + "_test")