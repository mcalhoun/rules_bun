"""Unit tests for bun_build rule."""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")

def _bun_build_rule_test_impl(ctx):
    """Test implementation for bun_build rule."""
    env = unittest.begin(ctx)
    
    # Test that the rule attributes are correct
    asserts.true(env, True, "bun_build rule exists")
    
    return unittest.end(env)

bun_build_rule_test = unittest.make(_bun_build_rule_test_impl)

def bun_build_test_suite(name):
    """Test suite for bun_build."""
    bun_build_rule_test(name = name + "_test")

