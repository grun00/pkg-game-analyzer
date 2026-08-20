import { Link } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useContents } from "../hooks/queries";
import { useRole } from "../auth/AuthContext";
import { apiErrors } from "../lib/errors";
import { stars } from "../lib/labels";
import type { Content } from "../types";

export default function ContentIndex() {
  const { t } = useTranslation("content");
  const { data, isLoading, isError, error } = useContents();
  const { isCreator } = useRole();

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

  const contents = data ?? [];

  return (
    <>
      <div className="page-hd">
        <h1 className="page-title">{t("index.title")}</h1>
        {isCreator && (
          <Link to="/contents/new" className="btn btn-g">
            {t("index.new")}
          </Link>
        )}
      </div>

      {contents.length === 0 ? (
        <div className="empty">
          <p>{t("index.empty")}</p>
        </div>
      ) : (
        <div className="db-grid">
          {contents.map((c: Content) => (
            <div className="db-card" key={c.id}>
              <div className="db-card-hd">
                <Link to={`/contents/${c.id}`} className="db-card-name">
                  {c.title}
                </Link>
                <span className="c-dim">{t(`type.${c.content_type}`)}</span>
              </div>
              <p className="c-dim">
                {c.creator.name}
                {c.status === "draft" && ` · ${t("status.draft")}`}
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
