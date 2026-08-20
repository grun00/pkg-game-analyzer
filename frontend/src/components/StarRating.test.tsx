import { describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import StarRating from "./StarRating";

describe("StarRating", () => {
  it("renders five star buttons when interactive", () => {
    render(<StarRating value={0} onRate={() => {}} />);
    expect(screen.getAllByRole("button")).toHaveLength(5);
  });

  it("marks the current rating as pressed", () => {
    render(<StarRating value={3} onRate={() => {}} />);
    const pressed = screen
      .getAllByRole("button")
      .filter((b) => b.getAttribute("aria-pressed") === "true");
    expect(pressed).toHaveLength(1);
    expect(pressed[0]).toHaveAttribute("aria-label", "3");
  });

  it("calls onRate with the clicked star value", () => {
    const onRate = vi.fn();
    render(<StarRating value={null} onRate={onRate} />);
    fireEvent.click(screen.getByLabelText("4"));
    expect(onRate).toHaveBeenCalledWith(4);
  });

  it("does not render buttons in read-only mode", () => {
    render(<StarRating value={2} readOnly />);
    expect(screen.queryByRole("button")).toBeNull();
  });

  it("disables the buttons when disabled", () => {
    render(<StarRating value={1} onRate={() => {}} disabled />);
    screen
      .getAllByRole("button")
      .forEach((b) => expect(b).toBeDisabled());
  });
});
