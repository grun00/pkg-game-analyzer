import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useState,
  type ReactNode,
} from "react";
import client from "../api/client";
import type { Role, User } from "../types";

interface AuthState {
  user: User | null;
  login: (email: string, password: string) => Promise<void>;
  register: (
    email: string,
    password: string,
    passwordConfirmation: string,
  ) => Promise<void>;
  logout: () => Promise<void>;
  updateUser: (user: User) => void;
}

const AuthContext = createContext<AuthState | undefined>(undefined);

function readStoredUser(): User | null {
  const raw = localStorage.getItem("user");
  if (!raw || !localStorage.getItem("jwt")) return null;
  try {
    return JSON.parse(raw) as User;
  } catch {
    return null;
  }
}

function captureToken(header: string | undefined) {
  if (header) {
    localStorage.setItem("jwt", header.replace(/^Bearer /i, ""));
  }
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(readStoredUser);

  const persistUser = useCallback((u: User) => {
    setUser(u);
    localStorage.setItem("user", JSON.stringify(u));
  }, []);

  const login = useCallback(
    async (email: string, password: string) => {
      const res = await client.post("/login", { user: { email, password } });
      captureToken(res.headers["authorization"] as string | undefined);
      persistUser(res.data.user);
    },
    [persistUser],
  );

  const register = useCallback(
    async (
      email: string,
      password: string,
      passwordConfirmation: string,
    ) => {
      const res = await client.post("/signup", {
        user: {
          email,
          password,
          password_confirmation: passwordConfirmation,
        },
      });
      captureToken(res.headers["authorization"] as string | undefined);
      persistUser(res.data.user);
    },
    [persistUser],
  );

  const logout = useCallback(async () => {
    try {
      await client.delete("/logout");
    } finally {
      localStorage.removeItem("jwt");
      localStorage.removeItem("user");
      setUser(null);
    }
  }, []);

  const value = useMemo(
    () => ({ user, login, register, logout, updateUser: persistUser }),
    [user, login, register, logout, persistUser],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

// eslint-disable-next-line react-refresh/only-export-components
export function useAuth(): AuthState {
  const ctx = useContext(AuthContext);
  if (!ctx) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return ctx;
}

// eslint-disable-next-line react-refresh/only-export-components
export function useRole(): {
  role: Role | null;
  isCreator: boolean;
  isAdmin: boolean;
} {
  const { user } = useAuth();
  return {
    role: user?.role ?? null,
    isCreator: user?.role === "content_creator",
    isAdmin: user?.role === "admin",
  };
}
