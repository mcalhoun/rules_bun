import { test, expect } from "bun:test";

// Native Bun test API
test("addition", () => {
    expect(1 + 1).toBe(2);
});

test("subtraction", () => {
    expect(5 - 3).toBe(2);
});

// Jest-compatible API
test("multiplication", () => {
    expect(2 * 3).toBe(6);
});

test("division", () => {
    expect(10 / 2).toBe(5);
});

