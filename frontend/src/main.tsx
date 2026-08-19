import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import "./styles/theme.css";
import App from "./App";
import { AuthProvider } from "./auth/AuthContext";
import { FlashProvider } from "./components/Flash";

const queryClient = new QueryClient({
  defaultOptions: {
    queries: { retry: false, refetchOnWindowFocus: false },
  },
});

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <FlashProvider>
          <AuthProvider>
            <App />
          </AuthProvider>
        </FlashProvider>
      </BrowserRouter>
    </QueryClientProvider>
  </StrictMode>,
);
