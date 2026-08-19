import { stars } from "../lib/labels";
import type { HandQualityStat } from "../types";

export default function HandQualityCards({
  rows,
}: {
  rows: HandQualityStat[];
}) {
  return (
    <div className="hq-grid">
      {rows.map((r) => (
        <div className="hq-card" key={r.quality}>
          <div className="hq-stars">{stars(r.quality)}</div>
          <div className="hq-rate">{r.win_rate}%</div>
          <div className="hq-count">
            {r.wins}W / {r.losses}L / {r.ties}T
          </div>
        </div>
      ))}
    </div>
  );
}
