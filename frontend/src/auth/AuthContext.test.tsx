import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { act, renderHook } from "@testing-library/react";
import type { ReactNode } from "react";

const post = vi.fn();
const del = vi.fn();

vi.mock("../api/client", () => ({
  default: {
    post: (...args: unknown[]) => post(...args),
    delete: (...args: unknown[]) => del(...args),
  },
}));

import { AuthProvider, useAuth } from "./AuthContext";

const wrapper = ({ children }: { children: ReactNode }) => (
  <AuthProvider>{children}</AuthProvider>
);

describe("AuthContext", () => {
  beforeEach(() => {
    localStorage.clear();
    post.mockReset();
    del.mockReset();
  });

  afterEach(() => localStorage.clear());

  it("stores the JWT from the Authorization header on login", async () => {
    post.mockResolvedValueOnce({
      headers: { authorization: "Bearer abc.def.ghi" },
      data: { user: { id: 1, email: "trainer@pkm.test" } },
    });

    const { result } = renderHook(() => useAuth(), { wrapper });

    await act(async () => {
      await result.current.login("trainer@pkm.test", "password123");
    });

    expect(post).toHaveBeenCalledWith("/login", {
      user: { email: "trainer@pkm.test", password: "password123" },
    });
    expect(localStorage.getItem("jwt")).toBe("abc.def.ghi");
    expect(result.current.user).toEqual({ id: 1, email: "trainer@pkm.test" });
  });

  it("sends password_confirmation on register", async () => {
    post.mockResolvedValueOnce({
      headers: { authorization: "Bearer tok" },
      data: { user: { id: 2, email: "new@pkm.test" } },
    });

    const { result } = renderHook(() => useAuth(), { wrapper });

    await act(async () => {
      await result.current.register("new@pkm.test", "password123", "password123");
    });

    expect(post).toHaveBeenCalledWith("/signup", {
      user: {
        email: "new@pkm.test",
        password: "password123",
        password_confirmation: "password123",
      },
    });
    expect(localStorage.getItem("jwt")).toBe("tok");
  });

  it("clears storage on logout", async () => {
    localStorage.setItem("jwt", "tok");
    localStorage.setItem("user", JSON.stringify({ id: 1, email: "a@b.c" }));
    del.mockResolvedValueOnce({});

    const { result } = renderHook(() => useAuth(), { wrapper });

    await act(async () => {
      await result.current.logout();
    });

    expect(del).toHaveBeenCalledWith("/logout");
    expect(localStorage.getItem("jwt")).toBeNull();
    expect(localStorage.getItem("user")).toBeNull();
    expect(result.current.user).toBeNull();
  });
});
