import { useTranslation } from "react-i18next";
import type { DefeatReasonStats } from "../types";

export default function DefeatReasonCards({
  data,
}: {
  data: DefeatReasonStats;
}) {
  const { t } = useTranslation("matches");
  const cards = [
    ...data.reasons,
    { reason: "unspecified", label: t("defeat.unspecified"), count: data.unspecified },
  ];

  return (
    <div className="hq-grid">
      {cards.map((r) => (
        <div className="hq-card" key={r.reason}>
          <div className="hq-rate c-red">{r.count}</div>
          <div className="hq-count">{r.label}</div>
        </div>
      ))}
    </div>
  );
}
