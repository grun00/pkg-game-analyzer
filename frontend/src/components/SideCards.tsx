import type { FirstOrSecondStat } from "../types";

const LABELS: Record<string, string> = {
  first: "Going First",
  second: "Going Second",
};

export default function SideCards({ rows }: { rows: FirstOrSecondStat[] }) {
  return (
    <div className="side-grid">
      {rows.map((r) => (
        <div
          className={`side-card ${r.side === "first" ? "side-card-1" : "side-card-2"}`}
          key={r.side}
        >
          <div className="side-lbl">{LABELS[r.side] ?? r.side}</div>
          <div className="side-rate">{r.win_rate}%</div>
          <div className="side-rec">
            {r.wins}W / {r.losses}L / {r.ties}T
          </div>
        </div>
      ))}
    </div>
  );
}
