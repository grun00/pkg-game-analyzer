import { beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, screen, waitFor } from "@testing-library/react";
import { Route, Routes } from "react-router-dom";
import type { Meta } from "../types";

const get = vi.fn();

vi.mock("../api/client", () => ({
  default: { get: (...args: unknown[]) => get(...args) },
}));

import MatchForm from "./MatchForm";
import { renderWithProviders } from "../test/renderWithProviders";

const meta: Meta = {
  opponent_decks: [{ value: "dragapult", label: "Dragapult" }],
  results: [
    { value: "win", label: "WIN" },
    { value: "loss", label: "LOSS" },
    { value: "tie", label: "TIE" },
  ],
  game_modes: [{ value: "in_person", label: "In person" }],
  first_or_second: [{ value: "uninformed", label: "Uninformed" }],
  reasons_for_defeat: [{ value: "unlucky", label: "Unlucky" }],
  hand_qualities: [{ value: 3, label: "3 ★★★" }],
};

describe("MatchForm", () => {
  beforeEach(() => {
    get.mockReset();
    get.mockImplementation((url: string) => {
      if (url === "/dashboards/1")
        return Promise.resolve({
          data: {
            id: 1,
            name: "D",
            game_type: "pokemon",
            created_at: "",
            updated_at: "",
          },
        });
      if (url === "/meta") return Promise.resolve({ data: meta });
      return Promise.reject(new Error(`unexpected ${url}`));
    });
  });

  it("shows the defeat reason only after selecting a loss result", async () => {
    renderWithProviders(
      <Routes>
        <Route path="/dashboards/:id/matches/new" element={<MatchForm />} />
      </Routes>,
      { route: "/dashboards/1/matches/new" },
    );

    await waitFor(() =>
      expect(screen.getByText("Log Match")).toBeInTheDocument(),
    );

    // Reason-for-defeat is hidden by default.
    expect(screen.queryByText("Reason for Defeat")).not.toBeInTheDocument();

    // Selecting LOSS reveals it.
    fireEvent.click(screen.getByLabelText("LOSS"));
    expect(screen.getByText("Reason for Defeat")).toBeInTheDocument();

    // Switching back to WIN hides it again.
    fireEvent.click(screen.getByLabelText("WIN"));
    expect(screen.queryByText("Reason for Defeat")).not.toBeInTheDocument();
  });
});
