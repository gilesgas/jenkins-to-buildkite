import { expect, test } from "vitest";
import { sum } from "./index.js";

test("adds numbers correctly", async () => {
    const result = sum(1, 2);
    expect(result).toBe(3);
});
