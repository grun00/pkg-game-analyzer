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
  result: "loss",
  game_mode: "in_person",
  first_or_second: "second",
  reason_for_defeat: "unlucky",
  hand_quality: 4,
  number_of_mulligans: 1,
  my_battlefield: null,
  opponent_battlefield: null,
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
      played_at: "2026-01-15",
    });
    expect(payload.reason_for_defeat).toBeNull();
  });

  it("keeps reason_for_defeat when result is a loss", () => {
    const payload = formToPayload({
      ...blankMatchForm,
      result: "loss",
      reason_for_defeat: "unlucky",
      hand_quality: "3",
      played_at: "2026-01-15",
    });
    expect(payload.reason_for_defeat).toBe("unlucky");
  });

  it("coerces numeric fields and nulls empties", () => {
    const payload = formToPayload({
      ...blankMatchForm,
      result: "tie",
      hand_quality: "5",
      number_of_mulligans: "",
      played_at: "2026-01-15",
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
    expect(form.my_battlefield).toBe("");
    expect(form.opponent_battlefield).toBe("");
  });

  it("maps battlefields to/from payload, nulling empties", () => {
    const form = matchToForm({
      ...baseMatch,
      my_battlefield: "kinkou_temple",
      opponent_battlefield: "void_gate",
    });
    expect(form.my_battlefield).toBe("kinkou_temple");
    expect(form.opponent_battlefield).toBe("void_gate");

    const payload = formToPayload({
      ...blankMatchForm,
      result: "win",
      hand_quality: "3",
      played_at: "2026-01-15",
    });
    expect(payload.my_battlefield).toBeNull();
    expect(payload.opponent_battlefield).toBeNull();
  });

  it("formats ISO timestamps for date inputs", () => {
    expect(isoToLocalInput(null)).toBe("");
    expect(isoToLocalInput("2026-01-15T20:30:00.000Z")).toMatch(
      /^\d{4}-\d{2}-\d{2}$/,
    );
  });

  it("defaults a blank form's played_at to today's date", () => {
    expect(blankMatchForm.played_at).toMatch(/^\d{4}-\d{2}-\d{2}$/);
  });

  it("defaults a blank form's number_of_mulligans to 0", () => {
    expect(blankMatchForm.number_of_mulligans).toBe("0");
    const payload = formToPayload({
      ...blankMatchForm,
      result: "win",
      hand_quality: "3",
      played_at: "2026-01-15",
    });
    expect(payload.number_of_mulligans).toBe(0);
  });
});
