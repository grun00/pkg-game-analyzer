import i18n from "i18next";
import { initReactI18next } from "react-i18next";
import LanguageDetector from "i18next-browser-languagedetector";

import enCommon from "./locales/en/common.json";
import enAuth from "./locales/en/auth.json";
import enDashboards from "./locales/en/dashboards.json";
import enMatches from "./locales/en/matches.json";
import enEnums from "./locales/en/enums.json";
import enSubscriptions from "./locales/en/subscriptions.json";
import enContent from "./locales/en/content.json";

import ptCommon from "./locales/pt-BR/common.json";
import ptAuth from "./locales/pt-BR/auth.json";
import ptDashboards from "./locales/pt-BR/dashboards.json";
import ptMatches from "./locales/pt-BR/matches.json";
import ptEnums from "./locales/pt-BR/enums.json";
import ptSubscriptions from "./locales/pt-BR/subscriptions.json";
import ptContent from "./locales/pt-BR/content.json";

export const SUPPORTED_LNGS = ["en", "pt-BR"] as const;

// Default locale, kept in sync with the backend's APP_DEFAULT_LOCALE via
// VITE_DEFAULT_LOCALE. Falls back to "en" when unset or unsupported.
const envDefault = import.meta.env.VITE_DEFAULT_LOCALE as string | undefined;
const DEFAULT_LNG = SUPPORTED_LNGS.includes(
  envDefault as (typeof SUPPORTED_LNGS)[number],
)
  ? (envDefault as string)
  : "en";

const resources = {
  en: {
    common: enCommon,
    auth: enAuth,
    dashboards: enDashboards,
    matches: enMatches,
    enums: enEnums,
    subscriptions: enSubscriptions,
    content: enContent,
  },
  "pt-BR": {
    common: ptCommon,
    auth: ptAuth,
    dashboards: ptDashboards,
    matches: ptMatches,
    enums: ptEnums,
    subscriptions: ptSubscriptions,
    content: ptContent,
  },
} as const;

i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources,
    fallbackLng: DEFAULT_LNG,
    supportedLngs: SUPPORTED_LNGS as unknown as string[],
    ns: [
      "common",
      "auth",
      "dashboards",
      "matches",
      "enums",
      "subscriptions",
      "content",
    ],
    defaultNS: "common",
    detection: {
      order: ["localStorage", "navigator"],
      lookupLocalStorage: "lang",
      caches: ["localStorage"],
    },
    interpolation: { escapeValue: false },
  });

export default i18n;
