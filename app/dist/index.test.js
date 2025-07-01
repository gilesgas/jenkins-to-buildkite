import { expect, test } from "vitest";
import { countTheRs } from "./index.js";

test("correctly computes the number of `r`s in a string", async () => {
    const result = countTheRs("strawberry");
    expect(result).toBe(3);
});
