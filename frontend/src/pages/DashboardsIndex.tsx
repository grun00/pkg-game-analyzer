import { Link } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import client from "../api/client";
import { useDashboards } from "../hooks/queries";
import { useFlash } from "../components/Flash";
import { apiErrorMessage } from "../lib/errors";
import type { DashboardSummary } from "../types";

export default function DashboardsIndex() {
  const { t } = useTranslation("dashboards");
  const { t: tc } = useTranslation("common");
  const { data, isLoading, isError, error } = useDashboards();
  const queryClient = useQueryClient();
  const { notify } = useFlash();

  const destroy = useMutation({
    mutationFn: (id: number) => client.delete(`/dashboards/${id}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["dashboards"] });
      notify("ok", t("index.deleted"));
    },
    onError: (err) => notify("err", apiErrorMessage(err)),
  });

  function handleDelete(d: DashboardSummary) {
    if (window.confirm(t("index.confirmDelete", { name: d.name }))) {
      destroy.mutate(d.id);
    }
  }

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

  const dashboards = data ?? [];

  return (
    <>
      <div className="page-hd">
        <h1 className="page-title">{t("index.title")}</h1>
        <Link to="/dashboards/new" className="btn btn-g">
          {t("index.new")}
        </Link>
      </div>

      {dashboards.length === 0 ? (
        <div className="empty">
          <p>{t("index.empty")}</p>
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
                    {tc("actions.edit")}
                  </Link>
                  <button
                    type="button"
                    className="btn-ghost c-red"
                    onClick={() => handleDelete(d)}
                  >
                    {tc("actions.delete")}
                  </button>
                </div>
              </div>
              <div className="db-card-stats">
                <span>
                  <span className="c-dim">{t("index.total")}</span>{" "}
                  {d.matches_count}
                </span>
                <span>
                  <span className="c-green">{t("index.wins")}</span>{" "}
                  {d.wins_count}
                </span>
                <span>
                  <span className="c-gold">{t("index.rate")}</span> {d.win_rate}%
                </span>
              </div>
              <Link to={`/dashboards/${d.id}`} className="db-card-link">
                {t("index.access")}
              </Link>
            </div>
          ))}
        </div>
      )}
    </>
  );
}
