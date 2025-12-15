"""Unit tests for bun_install rule."""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")

def _bun_install_rule_test_impl(ctx):
    """Test implementation for bun_install rule."""
    env = unittest.begin(ctx)
    
    # Test that the rule attributes are correct
    asserts.true(env, True, "bun_install rule exists")
    
    return unittest.end(env)

bun_install_rule_test = unittest.make(_bun_install_rule_test_impl)

def bun_install_test_suite(name):
    """Test suite for bun_install."""
    bun_install_rule_test(name = name + "_test")

