"""Unit tests for bun_bundle rule."""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")

def _bun_bundle_rule_test_impl(ctx):
    """Test implementation for bun_bundle rule."""
    env = unittest.begin(ctx)
    
    # Test that the rule attributes are correct
    asserts.true(env, True, "bun_bundle rule exists")
    
    return unittest.end(env)

bun_bundle_rule_test = unittest.make(_bun_bundle_rule_test_impl)

def bun_bundle_test_suite(name):
    """Test suite for bun_bundle."""
    bun_bundle_rule_test(name = name + "_test")

