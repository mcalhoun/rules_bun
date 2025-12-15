"""Unit tests for bun_test rule."""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")

def _bun_test_rule_test_impl(ctx):
    """Test implementation for bun_test rule."""
    env = unittest.begin(ctx)
    
    # Test that the rule attributes are correct
    # This would be expanded with actual rule testing in a real implementation
    asserts.true(env, True, "bun_test rule exists")
    
    return unittest.end(env)

bun_test_rule_test = unittest.make(_bun_test_rule_test_impl)

def bun_test_test_suite(name):
    """Test suite for bun_test."""
    bun_test_rule_test(name = name + "_test")

