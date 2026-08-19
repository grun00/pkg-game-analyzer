import type { Match } from "../types";

export interface MatchFormState {
  opponent_deck: string;
  game_mode: string;
  result: string;
  reason_for_defeat: string;
  first_or_second: string;
  number_of_mulligans: string;
  hand_quality: string;
  description: string;
  played_at: string;
}

// Today's local date as "YYYY-MM-DD" for <input type="date">.
export function todayLocalDate(): string {
  const d = new Date();
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}

export const blankMatchForm: MatchFormState = {
  opponent_deck: "",
  game_mode: "in_person",
  result: "",
  reason_for_defeat: "",
  first_or_second: "uninformed",
  number_of_mulligans: "",
  hand_quality: "",
  description: "",
  played_at: todayLocalDate(),
};

// Convert an ISO timestamp to the value accepted by <input type="date">
// (local date, no time/zone): "YYYY-MM-DD".
export function isoToLocalInput(iso: string | null): string {
  if (!iso) return "";
  const d = new Date(iso);
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}

export function matchToForm(m: Match): MatchFormState {
  return {
    opponent_deck: m.opponent_deck ?? "",
    game_mode: m.game_mode ?? "in_person",
    result: m.result ?? "",
    reason_for_defeat: m.reason_for_defeat ?? "",
    first_or_second: m.first_or_second ?? "uninformed",
    number_of_mulligans:
      m.number_of_mulligans != null ? String(m.number_of_mulligans) : "",
    hand_quality: m.hand_quality != null ? String(m.hand_quality) : "",
    description: m.description ?? "",
    played_at: isoToLocalInput(m.played_at),
  };
}

export function formToPayload(form: MatchFormState): Record<string, unknown> {
  return {
    opponent_deck: form.opponent_deck,
    game_mode: form.game_mode,
    result: form.result,
    // Only send a defeat reason when the match was a loss.
    reason_for_defeat:
      form.result === "loss" && form.reason_for_defeat
        ? form.reason_for_defeat
        : null,
    first_or_second: form.first_or_second,
    number_of_mulligans:
      form.number_of_mulligans === ""
        ? null
        : Number(form.number_of_mulligans),
    hand_quality: form.hand_quality === "" ? null : Number(form.hand_quality),
    description: form.description,
    played_at: form.played_at ? localDateToIso(form.played_at) : null,
  };
}

// Convert a "YYYY-MM-DD" date-input value to an ISO timestamp at local midnight.
function localDateToIso(date: string): string {
  const [y, m, d] = date.split("-").map(Number);
  return new Date(y, m - 1, d).toISOString();
}
