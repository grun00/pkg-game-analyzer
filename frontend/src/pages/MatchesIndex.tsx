import { Link, useParams } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useDashboard, useMatches } from "../hooks/queries";
import MatchRow from "../components/MatchRow";
import { apiErrorMessage } from "../lib/errors";

export default function MatchesIndex() {
  const { t } = useTranslation("matches");
  const { t: tc } = useTranslation("common");
  const { id } = useParams();
  const db = useDashboard(id);
  const { data, isLoading, isError, error } = useMatches(id);

  if (isLoading)
    return (
      <div className="empty">
        <p>{t("index.loading")}</p>
      </div>
    );
  if (isError)
    return (
      <div className="empty">
        <p>{apiErrorMessage(error)}</p>
      </div>
    );

  const matches = data ?? [];

  return (
    <>
      <div className="page-hd">
        <div>
          <div className="breadcrumb">
            <Link to="/dashboards">{tc("nav.dashboards")}</Link> /{" "}
            <Link to={`/dashboards/${id}`}>{db.data?.name ?? "…"}</Link> /{" "}
            {t("index.breadcrumbMatches")}
          </div>
          <h1 className="page-title">{t("index.title")}</h1>
        </div>
        <Link to={`/dashboards/${id}/matches/new`} className="btn btn-g">
          {t("index.logMatch")}
        </Link>
      </div>

      {matches.length === 0 ? (
        <div className="empty">
          <p>{t("index.empty")}</p>
        </div>
      ) : (
        <div className="match-log">
          {matches.map((m) => (
            <MatchRow key={m.id} m={m} dashboardId={id!} showActions />
          ))}
        </div>
      )}
    </>
  );
}
