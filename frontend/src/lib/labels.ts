import i18n from "../i18n";
import type { Result } from "../types";

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

type EnumGroup =
  | "result"
  | "game_mode"
  | "first_or_second"
  | "reason_for_defeat"
  | "opponent_deck"
  | "battlefield";

export const enumLabel = (group: EnumGroup, key: string | null | undefined): string => {
  if (!key) return "";
  return i18n.t(`${group}.${key}`, { ns: "enums", defaultValue: key });
};

export const resultLabel = (r: Result | string): string => {
  const path = `result.${r}`;
  return i18n.exists(path, { ns: "enums" })
    ? i18n.t(path, { ns: "enums" })
    : r.toUpperCase();
};

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
