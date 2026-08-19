import { Link } from "react-router-dom";
import { resultColor, resultLabel, resultRow, stars, truncate } from "../lib/labels";
import type { Match } from "../types";

interface Props {
  m: Match;
  dashboardId: string;
  showActions?: boolean;
}

function formatDate(iso: string | null): string {
  if (!iso) return "";
  const d = new Date(iso);
  return d.toLocaleDateString(undefined, {
    year: "2-digit",
    month: "2-digit",
    day: "2-digit",
  });
}

export default function MatchRow({ m, dashboardId, showActions }: Props) {
  return (
    <div className={`match-row ${resultRow(m.result)}`}>
      <span className={`match-ind ${resultColor(m.result)}`}>
        {resultLabel(m.result)}
      </span>
      <span className="match-deck">{m.opponent_deck_label}</span>
      <span className="match-hand">{stars(m.hand_quality)}</span>
      <span className="match-note">{truncate(m.description)}</span>
      <span className="match-date">{formatDate(m.played_at)}</span>
      {showActions && (
        <span className="db-card-acts">
          <Link
            to={`/dashboards/${dashboardId}/matches/${m.id}`}
            className="btn-ghost c-blue"
          >
            View
          </Link>
          <Link
            to={`/dashboards/${dashboardId}/matches/${m.id}/edit`}
            className="btn-ghost c-gold"
          >
            Edit
          </Link>
        </span>
      )}
    </div>
  );
}
