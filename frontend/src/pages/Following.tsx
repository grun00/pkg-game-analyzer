import { Link } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useSubscriptions } from "../hooks/queries";
import { apiErrors } from "../lib/errors";
import type { Subscription } from "../types";

export default function Following() {
  const { t } = useTranslation("subscriptions");
  const { data, isLoading, isError, error } = useSubscriptions();

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

  const subscriptions = data ?? [];

  return (
    <>
      <div className="page-hd">
        <h1 className="page-title">{t("following.title")}</h1>
      </div>

      {subscriptions.length === 0 ? (
        <div className="empty">
          <p>{t("following.empty")}</p>
          <Link to="/creators" className="btn btn-g">
            {t("following.browse")}
          </Link>
        </div>
      ) : (
        <div className="db-grid">
          {subscriptions.map((s: Subscription) => (
            <div className="db-card" key={s.id}>
              <div className="db-card-hd">
                <Link to={`/creators/${s.creator.id}`} className="db-card-name">
                  {s.creator.email}
                </Link>
              </div>
              <p className="c-dim">
                {t("following.since")}:{" "}
                {new Date(s.created_at).toLocaleDateString()}
              </p>
            </div>
          ))}
        </div>
      )}
    </>
  );
}
