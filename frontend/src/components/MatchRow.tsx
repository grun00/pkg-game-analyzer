import { Link } from "react-router-dom";
import { useTranslation } from "react-i18next";
import {
  enumLabel,
  resultColor,
  resultLabel,
  resultRow,
  stars,
  truncate,
} from "../lib/labels";
import { formatShortDate } from "../lib/format";
import type { Match } from "../types";

interface Props {
  m: Match;
  dashboardId: string;
  showActions?: boolean;
}

export default function MatchRow({ m, dashboardId, showActions }: Props) {
  const { t } = useTranslation("matches");
  return (
    <div className={`match-row ${resultRow(m.result)}`}>
      <span className={`match-ind ${resultColor(m.result)}`}>
        {resultLabel(m.result)}
      </span>
      <span className="match-deck">{enumLabel("opponent_deck", m.opponent_deck)}</span>
      <span className="match-hand">{stars(m.hand_quality)}</span>
      <span className="match-note">{truncate(m.description)}</span>
      <span className="match-date">{formatShortDate(m.played_at)}</span>
      {showActions && (
        <span className="db-card-acts">
          <Link
            to={`/dashboards/${dashboardId}/matches/${m.id}`}
            className="btn-ghost c-blue"
          >
            {t("row.view")}
          </Link>
          <Link
            to={`/dashboards/${dashboardId}/matches/${m.id}/edit`}
            className="btn-ghost c-gold"
          >
            {t("row.edit")}
          </Link>
        </span>
      )}
    </div>
  );
}
