import { Link, useParams } from "react-router-dom";
import { useDashboard, useMatches } from "../hooks/queries";
import MatchRow from "../components/MatchRow";
import { apiErrorMessage } from "../lib/errors";

export default function MatchesIndex() {
  const { id } = useParams();
  const db = useDashboard(id);
  const { data, isLoading, isError, error } = useMatches(id);

  if (isLoading)
    return (
      <div className="empty">
        <p>Loading matches…</p>
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
            <Link to="/dashboards">Dashboards</Link> /{" "}
            <Link to={`/dashboards/${id}`}>{db.data?.name ?? "…"}</Link> /
            Matches
          </div>
          <h1 className="page-title">All Matches</h1>
        </div>
        <Link to={`/dashboards/${id}/matches/new`} className="btn btn-g">
          + Log Match
        </Link>
      </div>

      {matches.length === 0 ? (
        <div className="empty">
          <p>No matches recorded yet</p>
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
