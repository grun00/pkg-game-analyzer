import { Link } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import client from "../api/client";
import { useCreators } from "../hooks/queries";
import { useFlash } from "../components/Flash";
import { apiErrors } from "../lib/errors";
import type { Creator } from "../types";

export default function CreatorsIndex() {
  const { t } = useTranslation("subscriptions");
  const { data, isLoading, isError, error } = useCreators();
  const queryClient = useQueryClient();
  const { notify } = useFlash();

  const toggle = useMutation({
    mutationFn: ({ id, subscribed }: { id: number; subscribed: boolean }) =>
      subscribed
        ? client.delete(`/creators/${id}/subscribe`)
        : client.post(`/creators/${id}/subscribe`),
    onSuccess: (_res, { subscribed }) => {
      queryClient.invalidateQueries({ queryKey: ["creators"] });
      queryClient.invalidateQueries({ queryKey: ["subscriptions"] });
      notify(
        "ok",
        subscribed ? t("flash.unsubscribed") : t("flash.subscribed"),
      );
    },
    onError: (err) => notify("err", apiErrors(err)[0] ?? ""),
  });

  if (isLoading)
    return (
      <div className="empty">
        <p>{t("index.loading")}</p>
      </div>
    );
  if (isError)
    return (
      <div className="empty">
        <p>{apiErrors(error)[0]}</p>
      </div>
    );

  const creators = data ?? [];

  return (
    <>
      <div className="page-hd">
        <h1 className="page-title">{t("index.title")}</h1>
      </div>

      {creators.length === 0 ? (
        <div className="empty">
          <p>{t("index.empty")}</p>
        </div>
      ) : (
        <div className="db-grid">
          {creators.map((c: Creator) => (
            <div className="db-card" key={c.id}>
              <div className="db-card-hd">
                <Link to={`/creators/${c.id}`} className="db-card-name">
                  {c.email}
                </Link>
                <button
                  type="button"
                  className={`btn ${c.subscribed ? "btn-r" : "btn-g"}`}
                  disabled={toggle.isPending}
                  onClick={() =>
                    toggle.mutate({ id: c.id, subscribed: c.subscribed })
                  }
                >
                  {c.subscribed
                    ? t("actions.unsubscribe")
                    : t("actions.subscribe")}
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </>
  );
}
