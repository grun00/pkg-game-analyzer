import { Link, useParams } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import client from "../api/client";
import { useCreator } from "../hooks/queries";
import { useFlash } from "../components/Flash";
import { apiErrors } from "../lib/errors";

export default function CreatorShow() {
  const { t } = useTranslation("subscriptions");
  const { t: tc } = useTranslation("common");
  const { id } = useParams();
  const { data: creator, isLoading, isError, error } = useCreator(id);
  const queryClient = useQueryClient();
  const { notify } = useFlash();

  const toggle = useMutation({
    mutationFn: (subscribed: boolean) =>
      subscribed
        ? client.delete(`/creators/${id}/subscribe`)
        : client.post(`/creators/${id}/subscribe`),
    onSuccess: (_res, subscribed) => {
      queryClient.invalidateQueries({ queryKey: ["creator", id] });
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
        <p>{t("show.loading")}</p>
      </div>
    );
  if (isError || !creator)
    return (
      <div className="empty">
        <p>{apiErrors(error)[0]}</p>
      </div>
    );

  return (
    <>
      <div className="page-hd">
        <div>
          <div className="breadcrumb">
            <Link to="/creators">{t("show.backToCreators")}</Link> /{" "}
            {creator.email}
          </div>
          <h1 className="page-title">{creator.email}</h1>
        </div>
        <button
          type="button"
          className={`btn ${creator.subscribed ? "btn-r" : "btn-g"}`}
          disabled={toggle.isPending}
          onClick={() => toggle.mutate(creator.subscribed)}
        >
          {creator.subscribed
            ? t("actions.unsubscribe")
            : t("actions.subscribe")}
        </button>
      </div>

      <p className="c-dim">
        {tc("profile.role")}: {tc(`roles.contentCreator`)}
      </p>
    </>
  );
}
