import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useRef,
  useState,
  type ReactNode,
} from "react";

type FlashKind = "ok" | "err";

interface FlashMessage {
  kind: FlashKind;
  text: string;
}

interface FlashState {
  message: FlashMessage | null;
  notify: (kind: FlashKind, text: string) => void;
  clear: () => void;
}

const FlashContext = createContext<FlashState | undefined>(undefined);

export function FlashProvider({ children }: { children: ReactNode }) {
  const [message, setMessage] = useState<FlashMessage | null>(null);
  const timeoutRef = useRef<number | undefined>(undefined);

  const notify = useCallback((kind: FlashKind, text: string) => {
    setMessage({ kind, text });
    window.clearTimeout(timeoutRef.current);
    timeoutRef.current = window.setTimeout(() => setMessage(null), 5000);
  }, []);

  const clear = useCallback(() => setMessage(null), []);

  const value = useMemo(
    () => ({ message, notify, clear }),
    [message, notify, clear],
  );

  return (
    <FlashContext.Provider value={value}>{children}</FlashContext.Provider>
  );
}

// eslint-disable-next-line react-refresh/only-export-components
export function useFlash(): FlashState {
  const ctx = useContext(FlashContext);
  if (!ctx) {
    throw new Error("useFlash must be used within a FlashProvider");
  }
  return ctx;
}

export function Flash() {
  const { message } = useFlash();
  if (!message) return null;
  return (
    <div className={`flash flash-${message.kind}`}>{message.text}</div>
  );
}
