import { describe, expect, it } from "vitest";
import {
  blankMatchForm,
  formToPayload,
  isoToLocalInput,
  matchToForm,
} from "./matchForm";
import type { Match } from "../types";

const baseMatch: Match = {
  id: 1,
  opponent_deck: "dragapult",
  opponent_deck_label: "Dragapult",
  result: "loss",
  game_mode: "in_person",
  game_mode_label: "In person",
  first_or_second: "second",
  reason_for_defeat: "unlucky",
  reason_for_defeat_label: "Unlucky",
  hand_quality: 4,
  number_of_mulligans: 1,
  description: "close game",
  played_at: "2026-01-15T20:30:00.000Z",
};

describe("matchForm", () => {
  it("drops reason_for_defeat when result is not a loss", () => {
    const payload = formToPayload({
      ...blankMatchForm,
      result: "win",
      reason_for_defeat: "unlucky",
      hand_quality: "3",
      played_at: "2026-01-15T10:00",
    });
    expect(payload.reason_for_defeat).toBeNull();
  });

  it("keeps reason_for_defeat when result is a loss", () => {
    const payload = formToPayload({
      ...blankMatchForm,
      result: "loss",
      reason_for_defeat: "unlucky",
      hand_quality: "3",
      played_at: "2026-01-15T10:00",
    });
    expect(payload.reason_for_defeat).toBe("unlucky");
  });

  it("coerces numeric fields and nulls empties", () => {
    const payload = formToPayload({
      ...blankMatchForm,
      result: "tie",
      hand_quality: "5",
      number_of_mulligans: "",
      played_at: "2026-01-15T10:00",
    });
    expect(payload.hand_quality).toBe(5);
    expect(payload.number_of_mulligans).toBeNull();
  });

  it("round-trips an existing match into form state", () => {
    const form = matchToForm(baseMatch);
    expect(form.opponent_deck).toBe("dragapult");
    expect(form.result).toBe("loss");
    expect(form.reason_for_defeat).toBe("unlucky");
    expect(form.hand_quality).toBe("4");
    expect(form.number_of_mulligans).toBe("1");
  });

  it("formats ISO timestamps for datetime-local inputs", () => {
    expect(isoToLocalInput(null)).toBe("");
    expect(isoToLocalInput("2026-01-15T20:30:00.000Z")).toMatch(
      /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/,
    );
  });
});
