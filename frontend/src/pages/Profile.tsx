import { useState, type FormEvent } from "react";
import { useTranslation } from "react-i18next";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import client from "../api/client";
import { useAuth, useRole } from "../auth/AuthContext";
import { useMyCreatorRequests } from "../hooks/queries";
import { useFlash } from "../components/Flash";
import { apiErrors } from "../lib/errors";

export default function Profile() {
  const { t } = useTranslation("common");
  const { user } = useAuth();
  const { role, isCreator, isAdmin } = useRole();
  const queryClient = useQueryClient();
  const { notify } = useFlash();
  const { data: requests, isLoading } = useMyCreatorRequests();
  const [message, setMessage] = useState("");
  const [errors, setErrors] = useState<string[]>([]);

  const pending = requests?.find((r) => r.status === "pending");
  const canApply = !isCreator && !isAdmin && !pending;

  const apply = useMutation({
    mutationFn: (payload: { message: string }) =>
      client.post("/creator_requests", { creator_request: payload }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["creator_requests"] });
      notify("ok", t("profile.submitted"));
      setMessage("");
    },
    onError: (err) => setErrors(apiErrors(err)),
  });

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setErrors([]);
    apply.mutate({ message });
  }

  const roleLabel =
    role === "admin"
      ? t("roles.admin")
      : isCreator
        ? t("roles.contentCreator")
        : t("roles.regular");

  return (
    <>
      <div className="page-hd">
        <h1 className="page-title">{t("profile.title")}</h1>
      </div>

      <dl className="profile-meta">
        <dt className="form-lbl">{t("profile.email")}</dt>
        <dd>{user?.email}</dd>
        <dt className="form-lbl">{t("profile.role")}</dt>
        <dd>{roleLabel}</dd>
      </dl>

      <section className="profile-creator">
        <h2 className="page-subtitle">{t("profile.creatorHeading")}</h2>

        {isCreator && <p className="empty">{t("profile.alreadyCreator")}</p>}

        {pending && !isCreator && (
          <p className="empty">{t("profile.pending")}</p>
        )}

        {!isLoading && canApply && (
          <form className="term-form" onSubmit={handleSubmit}>
            {errors.length > 0 && (
              <div className="form-errors">
                <ul>
                  {errors.map((msg) => (
                    <li key={msg}>{msg}</li>
                  ))}
                </ul>
              </div>
            )}
            <div className="form-grp">
              <label className="form-lbl" htmlFor="message">
                {t("profile.messageLabel")}
              </label>
              <textarea
                id="message"
                className="form-ctrl"
                rows={4}
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                placeholder={t("profile.messagePlaceholder")}
              />
            </div>
            <button
              type="submit"
              className="form-submit"
              disabled={apply.isPending}
            >
              {apply.isPending ? t("actions.saving") : t("profile.applyCta")}
            </button>
          </form>
        )}

        {!isLoading && requests && requests.length > 0 && (
          <ul className="profile-history">
            {requests.map((r) => (
              <li key={r.id}>
                <span className={`badge badge-${r.status}`}>
                  {t(`profile.status.${r.status}`)}
                </span>{" "}
                <time>{new Date(r.created_at).toLocaleDateString()}</time>
              </li>
            ))}
          </ul>
        )}
      </section>
    </>
  );
}
