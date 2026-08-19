import type { Result } from "../types";

const RESULT_LABELS: Record<string, string> = {
  win: "[WIN]",
  loss: "[LOSS]",
  tie: "[TIE]",
};

const RESULT_COLORS: Record<string, string> = {
  win: "c-green",
  loss: "c-red",
  tie: "c-blue",
};

const RESULT_ROWS: Record<string, string> = {
  win: "row-win",
  loss: "row-loss",
  tie: "row-tie",
};

export const resultLabel = (r: Result | string): string =>
  RESULT_LABELS[r] ?? r.toUpperCase();

export const resultColor = (r: Result | string): string =>
  RESULT_COLORS[r] ?? "c-dim";

export const resultRow = (r: Result | string): string =>
  RESULT_ROWS[r] ?? "row-loss";

export const stars = (n: number): string =>
  "★".repeat(n) + "☆".repeat(Math.max(0, 5 - n));

export const truncate = (text: string | null | undefined, len = 55): string => {
  if (!text) return "";
  return text.length > len ? `${text.slice(0, len)}…` : text;
};
