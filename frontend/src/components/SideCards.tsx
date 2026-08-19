import { useTranslation } from "react-i18next";
import type { FirstOrSecondStat } from "../types";

export default function SideCards({ rows }: { rows: FirstOrSecondStat[] }) {
  const { t } = useTranslation("matches");
  return (
    <div className="side-grid">
      {rows.map((r) => (
        <div
          className={`side-card ${r.side === "first" ? "side-card-1" : "side-card-2"}`}
          key={r.side}
        >
          <div className="side-lbl">{t(`side.${r.side}`, { defaultValue: r.side })}</div>
          <div className="side-rate">{r.win_rate}%</div>
          <div className="side-rec">
            {r.wins}W / {r.losses}L / {r.ties}T
          </div>
        </div>
      ))}
    </div>
  );
}
