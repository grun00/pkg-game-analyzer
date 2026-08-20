import { Link, useNavigate, useParams } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import ReactMarkdown from "react-markdown";
import client from "../api/client";
import { useContent } from "../hooks/queries";
import { useAuth } from "../auth/AuthContext";
import { useFlash } from "../components/Flash";
import StarRating from "../components/StarRating";
import { apiErrors } from "../lib/errors";

export default function ContentShow() {
  const { t } = useTranslation("content");
  const { t: tc } = useTranslation("common");
  const { id } = useParams();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { user } = useAuth();
  const { notify } = useFlash();
  const { data: content, isLoading, isError, error } = useContent(id);

  const rate = useMutation({
    mutationFn: (starsValue: number) =>
      client.post(`/contents/${id}/rating`, { rating: { stars: starsValue } }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content", id] });
      queryClient.invalidateQueries({ queryKey: ["contents"] });
      notify("ok", t("flash.rated"));
    },
    onError: (err) => notify("err", apiErrors(err)[0] ?? ""),
  });

  const destroy = useMutation({
    mutationFn: () => client.delete(`/contents/${id}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["contents"] });
      notify("ok", t("flash.deleted"));
      navigate("/contents");
    },
    onError: (err) => notify("err", apiErrors(err)[0] ?? ""),
  });

  if (isLoading)
    return (
      <div className="empty">
        <p>{t("show.loading")}</p>
      </div>
    );
  if (isError || !content)
    return (
      <div className="empty">
        <p>{apiErrors(error)[0]}</p>
      </div>
    );

  const isOwner = user?.id === content.creator.id;

  return (
    <>
      <div className="page-hd">
        <div>
          <div className="breadcrumb">
            <Link to="/contents">{t("show.back")}</Link> / {content.title}
          </div>
          <h1 className="page-title">{content.title}</h1>
          <p className="c-dim">
            {content.creator.name} · {t(`type.${content.content_type}`)}
            {content.status === "draft" && ` · ${t("status.draft")}`}
          </p>
        </div>
        {isOwner && (
          <div className="page-hd-actions">
            <Link to={`/contents/${content.id}/edit`} className="btn btn-b">
              {tc("actions.edit")}
            </Link>
            <button
              type="button"
              className="btn btn-r"
              disabled={destroy.isPending}
              onClick={() => destroy.mutate()}
            >
              {tc("actions.delete")}
            </button>
          </div>
        )}
      </div>

      <div className="content-body">
        <ReactMarkdown>{content.body}</ReactMarkdown>
      </div>

      <div className="content-rate">
        <span className="form-lbl">{t("show.yourRating")}</span>
        <StarRating
          value={content.my_rating}
          disabled={rate.isPending}
          onRate={(s) => rate.mutate(s)}
        />
        <p className="c-dim">
          {t("show.average")}: {content.average_rating} ({content.ratings_count})
        </p>
      </div>
    </>
  );
}
