import { Link } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import client from "../api/client";
import { useContents } from "../hooks/queries";
import { useAuth } from "../auth/AuthContext";
import { useFlash } from "../components/Flash";
import { apiErrors } from "../lib/errors";
import { stars } from "../lib/labels";
import type { Content } from "../types";

export default function CreatorDashboard() {
  const { t } = useTranslation("content");
  const { t: tc } = useTranslation("common");
  const { data, isLoading, isError, error } = useContents();
  const { user } = useAuth();
  const queryClient = useQueryClient();
  const { notify } = useFlash();

  const destroy = useMutation({
    mutationFn: (id: number) => client.delete(`/contents/${id}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["contents"] });
      notify("ok", t("flash.deleted"));
    },
    onError: (err) => notify("err", apiErrors(err)[0] ?? ""),
  });

  function handleDelete(c: Content) {
    if (window.confirm(t("manager.confirmDelete", { title: c.title }))) {
      destroy.mutate(c.id);
    }
  }

  if (isLoading)
    return (
      <div className="empty">
        <p>{t("manager.loading")}</p>
      </div>
    );
  if (isError)
    return (
      <div className="empty">
        <p>{apiErrors(error)[0]}</p>
      </div>
    );

  const mine = (data ?? []).filter((c) => c.creator.id === user?.id);

  return (
    <>
      <div className="page-hd">
        <h1 className="page-title">{t("manager.title")}</h1>
        <Link to="/contents/new" className="btn btn-g">
          {t("manager.new")}
        </Link>
      </div>

      {mine.length === 0 ? (
        <div className="empty">
          <p>{t("manager.empty")}</p>
        </div>
      ) : (
        <div className="db-grid">
          {mine.map((c) => (
            <div className="db-card" key={c.id}>
              <div className="db-card-hd">
                <Link to={`/contents/${c.id}`} className="db-card-name">
                  {c.title}
                </Link>
                <div className="db-card-acts">
                  <Link
                    to={`/contents/${c.id}/edit`}
                    className="btn-ghost c-blue"
                  >
                    {tc("actions.edit")}
                  </Link>
                  <button
                    type="button"
                    className="btn-ghost c-red"
                    onClick={() => handleDelete(c)}
                  >
                    {tc("actions.delete")}
                  </button>
                </div>
              </div>
              <p className="c-dim">
                {t(`type.${c.content_type}`)} ·{" "}
                {t(`status.${c.status}`)}
              </p>
              <p className="content-rating">
                <span className="star-rating-ro">
                  {stars(Math.round(c.average_rating))}
                </span>{" "}
                {c.average_rating} ({c.ratings_count})
              </p>
            </div>
          ))}
        </div>
      )}
    </>
  );
}
