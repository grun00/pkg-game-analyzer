import { Link, useParams } from "react-router-dom";
import { useDashboard, useStats } from "../hooks/queries";
import StatCard from "../components/StatCard";
import DeckTable from "../components/DeckTable";
import HandQualityCards from "../components/HandQualityCards";
import SideCards from "../components/SideCards";
import DefeatReasonCards from "../components/DefeatReasonCards";
import MatchRow from "../components/MatchRow";
import ExportButton from "../components/ExportButton";
import { stars } from "../lib/labels";
import { apiErrorMessage } from "../lib/errors";

export default function DashboardShow() {
  const { id } = useParams();
  const db = useDashboard(id);
  const stats = useStats(id);

  if (db.isLoading || stats.isLoading)
    return (
      <div className="empty">
        <p>Loading…</p>
      </div>
    );
  if (db.isError || stats.isError || !db.data || !stats.data)
    return (
      <div className="empty">
        <p>{apiErrorMessage(db.error ?? stats.error)}</p>
      </div>
    );

  const { data: dashboard } = db;
  const { data: s } = stats;

  return (
    <>
      <div className="page-hd">
        <div>
          <div className="breadcrumb">
            <Link to="/dashboards">Dashboards</Link> / {dashboard.name}
          </div>
          <h1 className="page-title">{dashboard.name}</h1>
          <div className="page-sub">
            <Link
              className="btn btn-b btn-sm"
              to={`/dashboards/${id}/matches`}
            >
              All Matches
            </Link>{" "}
            <Link
              className="btn btn-g btn-sm"
              to={`/dashboards/${id}/matches/new`}
            >
              + Log Match
            </Link>{" "}
            <ExportButton dashboardId={id!} name={dashboard.name} />
          </div>
        </div>
      </div>

      {s.total === 0 ? (
        <div className="empty">
          <p>No matches recorded yet</p>
        </div>
      ) : (
        <>
          <div className="stat-grid">
            <StatCard label="Total" value={s.total} />
            <StatCard label="Wins" value={s.wins} cls="c-green" />
            <StatCard label="Losses" value={s.losses} cls="c-red" />
            <StatCard label="Ties" value={s.ties} cls="c-blue" />
            <StatCard label="Win Rate" value={`${s.win_rate}%`} cls="c-gold" />
            <StatCard
              label="Avg Hand"
              value={stars(Math.round(s.average_hand_quality))}
            />
          </div>

          <h2 className="sec-lbl">Results by Opponent Deck</h2>
          <DeckTable rows={s.by_deck} />

          <h2 className="sec-lbl">Win Rate by Hand Quality</h2>
          <HandQualityCards rows={s.by_hand_quality} />

          <h2 className="sec-lbl">Going First vs Second</h2>
          <SideCards rows={s.by_first_or_second} />

          <h2 className="sec-lbl">Reasons for Defeat</h2>
          <DefeatReasonCards data={s.by_defeat_reason} />

          <h2 className="sec-lbl">Recent Battles</h2>
          <div className="match-log">
            {s.recent_matches.map((m) => (
              <MatchRow key={m.id} m={m} dashboardId={id!} showActions />
            ))}
          </div>
        </>
      )}
    </>
  );
}
