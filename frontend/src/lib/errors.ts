import axios from "axios";
import i18n from "../i18n";

export function apiErrors(err: unknown): string[] {
  if (axios.isAxiosError(err)) {
    const data = err.response?.data as
      | { errors?: string[]; error?: string }
      | undefined;
    if (data?.errors?.length) return data.errors;
    if (data?.error) return [data.error];
    if (err.response?.status === 401)
      return [i18n.t("errors.invalidCredentials", { ns: "auth" })];
    return [err.message];
  }
  if (err instanceof Error) return [err.message];
  return [i18n.t("state.unexpectedError", { ns: "common" })];
}

export function apiErrorMessage(err: unknown): string {
  return apiErrors(err).join(", ");
}
