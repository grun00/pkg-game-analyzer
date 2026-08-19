import { describe, expect, it } from "vitest";
import {
  resultColor,
  resultLabel,
  resultRow,
  stars,
  truncate,
} from "./labels";

describe("labels", () => {
  it("maps result to bracketed labels", () => {
    expect(resultLabel("win")).toBe("[WIN]");
    expect(resultLabel("loss")).toBe("[LOSS]");
    expect(resultLabel("tie")).toBe("[TIE]");
    expect(resultLabel("mystery")).toBe("MYSTERY");
  });

  it("maps result to color classes", () => {
    expect(resultColor("win")).toBe("c-green");
    expect(resultColor("loss")).toBe("c-red");
    expect(resultColor("tie")).toBe("c-blue");
    expect(resultColor("other")).toBe("c-dim");
  });

  it("maps result to row classes", () => {
    expect(resultRow("win")).toBe("row-win");
    expect(resultRow("loss")).toBe("row-loss");
    expect(resultRow("tie")).toBe("row-tie");
    expect(resultRow("other")).toBe("row-loss");
  });

  it("renders filled and empty stars", () => {
    expect(stars(3)).toBe("★★★☆☆");
    expect(stars(0)).toBe("☆☆☆☆☆");
    expect(stars(5)).toBe("★★★★★");
  });

  it("truncates long text with an ellipsis", () => {
    expect(truncate(null)).toBe("");
    expect(truncate("short")).toBe("short");
    expect(truncate("x".repeat(60), 10)).toBe(`${"x".repeat(10)}…`);
  });
});
