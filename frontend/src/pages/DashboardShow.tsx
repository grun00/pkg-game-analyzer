import { Link, useParams } from "react-router-dom";
import { useTranslation } from "react-i18next";
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
  const { t } = useTranslation("dashboards");
  const { t: tc } = useTranslation("common");
  const { id } = useParams();
  const db = useDashboard(id);
  const stats = useStats(id);

  if (db.isLoading || stats.isLoading)
    return (
      <div className="empty">
        <p>{tc("state.loading")}</p>
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
            <Link to="/dashboards">{tc("nav.dashboards")}</Link> /{" "}
            {dashboard.name}
          </div>
          <h1 className="page-title">{dashboard.name}</h1>
          <div className="page-sub">
            <Link
              className="btn btn-b btn-sm"
              to={`/dashboards/${id}/matches`}
            >
              {t("show.allMatches")}
            </Link>{" "}
            <Link
              className="btn btn-g btn-sm"
              to={`/dashboards/${id}/matches/new`}
            >
              {t("show.logMatch")}
            </Link>{" "}
            <ExportButton dashboardId={id!} name={dashboard.name} />
          </div>
        </div>
      </div>

      {s.total === 0 ? (
        <div className="empty">
          <p>{t("show.emptyMatches")}</p>
        </div>
      ) : (
        <>
          <div className="stat-grid">
            <StatCard label={t("show.statTotal")} value={s.total} />
            <StatCard label={t("show.statWins")} value={s.wins} cls="c-green" />
            <StatCard label={t("show.statLosses")} value={s.losses} cls="c-red" />
            <StatCard label={t("show.statTies")} value={s.ties} cls="c-blue" />
            <StatCard
              label={t("show.statWinRate")}
              value={`${s.win_rate}%`}
              cls="c-gold"
            />
            <StatCard
              label={t("show.statAvgHand")}
              value={stars(Math.round(s.average_hand_quality))}
            />
          </div>

          <h2 className="sec-lbl">{t("show.secByDeck")}</h2>
          <DeckTable rows={s.by_deck} />

          <h2 className="sec-lbl">{t("show.secByHandQuality")}</h2>
          <HandQualityCards rows={s.by_hand_quality} />

          <h2 className="sec-lbl">{t("show.secFirstVsSecond")}</h2>
          <SideCards rows={s.by_first_or_second} />

          <h2 className="sec-lbl">{t("show.secReasonsForDefeat")}</h2>
          <DefeatReasonCards data={s.by_defeat_reason} />

          <h2 className="sec-lbl">{t("show.secRecentBattles")}</h2>
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
