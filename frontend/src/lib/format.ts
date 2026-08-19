import i18n from "../i18n";

export function formatShortDate(iso: string | null | undefined): string {
  if (!iso) return "";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return "";
  return new Intl.DateTimeFormat(i18n.language, {
    year: "2-digit",
    month: "2-digit",
    day: "2-digit",
  }).format(d);
}
