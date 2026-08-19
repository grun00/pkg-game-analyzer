import { Link } from "react-router-dom";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import client from "../api/client";
import { useDashboards } from "../hooks/queries";
import { useFlash } from "../components/Flash";
import { apiErrorMessage } from "../lib/errors";
import type { DashboardSummary } from "../types";

export default function DashboardsIndex() {
  const { data, isLoading, isError, error } = useDashboards();
  const queryClient = useQueryClient();
  const { notify } = useFlash();

  const destroy = useMutation({
    mutationFn: (id: number) => client.delete(`/dashboards/${id}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["dashboards"] });
      notify("ok", "Dashboard deleted");
    },
    onError: (err) => notify("err", apiErrorMessage(err)),
  });

  function handleDelete(d: DashboardSummary) {
    if (window.confirm(`Delete dashboard "${d.name}"? This cannot be undone.`)) {
      destroy.mutate(d.id);
    }
  }

  if (isLoading)
    return (
      <div className="empty">
        <p>Loading dashboards…</p>
      </div>
    );
  if (isError)
    return (
      <div className="empty">
        <p>{apiErrorMessage(error)}</p>
      </div>
    );

  const dashboards = data ?? [];

  return (
    <>
      <div className="page-hd">
        <h1 className="page-title">Dashboards</h1>
        <Link to="/dashboards/new" className="btn btn-g">
          + New Dashboard
        </Link>
      </div>

      {dashboards.length === 0 ? (
        <div className="empty">
          <p>No dashboards yet — create one to start tracking</p>
        </div>
      ) : (
        <div className="db-grid">
          {dashboards.map((d) => (
            <div className="db-card" key={d.id}>
              <div className="db-card-hd">
                <span className="db-card-name">{d.name}</span>
                <div className="db-card-acts">
                  <Link
                    to={`/dashboards/${d.id}/edit`}
                    className="btn-ghost c-blue"
                  >
                    Edit
                  </Link>
                  <button
                    type="button"
                    className="btn-ghost c-red"
                    onClick={() => handleDelete(d)}
                  >
                    Delete
                  </button>
                </div>
              </div>
              <div className="db-card-stats">
                <span>
                  <span className="c-dim">TOTAL</span> {d.matches_count}
                </span>
                <span>
                  <span className="c-green">W</span> {d.wins_count}
                </span>
                <span>
                  <span className="c-gold">RATE</span> {d.win_rate}%
                </span>
              </div>
              <Link to={`/dashboards/${d.id}`} className="db-card-link">
                Access
              </Link>
            </div>
          ))}
        </div>
      )}
    </>
  );
}
