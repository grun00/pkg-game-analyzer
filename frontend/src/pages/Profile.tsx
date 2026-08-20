import { useState, type FormEvent } from "react";
import { useTranslation } from "react-i18next";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import client from "../api/client";
import { useAuth, useRole } from "../auth/AuthContext";
import { useMyCreatorRequests } from "../hooks/queries";
import { useFlash } from "../components/Flash";
import { apiErrors } from "../lib/errors";
import type { User } from "../types";

const BIO_MAX = 200;

export default function Profile() {
  const { t } = useTranslation("common");
  const { user, updateUser } = useAuth();
  const { role, isCreator, isAdmin } = useRole();
  const queryClient = useQueryClient();
  const { notify } = useFlash();
  const { data: requests, isLoading } = useMyCreatorRequests();
  const [message, setMessage] = useState("");
  const [proposedName, setProposedName] = useState("");
  const [proposedBio, setProposedBio] = useState("");
  const [errors, setErrors] = useState<string[]>([]);

  const [name, setName] = useState(user?.name ?? "");
  const [bio, setBio] = useState(user?.bio ?? "");
  const [profileErrors, setProfileErrors] = useState<string[]>([]);

  const pending = requests?.find((r) => r.status === "pending");
  const canApply = !isCreator && !isAdmin && !pending;

  const apply = useMutation({
    mutationFn: (payload: {
      message: string;
      proposed_name: string;
      proposed_bio: string;
    }) => client.post("/creator_requests", { creator_request: payload }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["creator_requests"] });
      notify("ok", t("profile.submitted"));
      setMessage("");
      setProposedName("");
      setProposedBio("");
    },
    onError: (err) => setErrors(apiErrors(err)),
  });

  const saveProfile = useMutation({
    mutationFn: (payload: { name: string; bio: string }) =>
      client
        .patch("/profile", { profile: payload })
        .then((r) => r.data as User),
    onSuccess: (updated) => {
      updateUser(updated);
      queryClient.invalidateQueries({ queryKey: ["creators"] });
      queryClient.invalidateQueries({ queryKey: ["subscriptions"] });
      notify("ok", t("profile.creatorProfile.saved"));
    },
    onError: (err) => setProfileErrors(apiErrors(err)),
  });

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setErrors([]);
    apply.mutate({
      message,
      proposed_name: proposedName,
      proposed_bio: proposedBio,
    });
  }

  function handleSaveProfile(e: FormEvent) {
    e.preventDefault();
    setProfileErrors([]);
    saveProfile.mutate({ name, bio });
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

      {isCreator && (
        <section className="profile-creator">
          <h2 className="page-subtitle">
            {t("profile.creatorProfile.heading")}
          </h2>
          <p className="c-dim">{t("profile.creatorProfile.hint")}</p>
          <form className="term-form" onSubmit={handleSaveProfile}>
            {profileErrors.length > 0 && (
              <div className="form-errors">
                <ul>
                  {profileErrors.map((msg) => (
                    <li key={msg}>{msg}</li>
                  ))}
                </ul>
              </div>
            )}
            <div className="form-grp">
              <label className="form-lbl" htmlFor="name">
                {t("profile.nameLabel")}
              </label>
              <input
                id="name"
                className="form-ctrl"
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder={t("profile.namePlaceholder")}
              />
            </div>
            <div className="form-grp">
              <label className="form-lbl" htmlFor="bio">
                {t("profile.bioLabel")}
              </label>
              <textarea
                id="bio"
                className="form-ctrl"
                rows={3}
                maxLength={BIO_MAX}
                value={bio}
                onChange={(e) => setBio(e.target.value)}
                placeholder={t("profile.bioPlaceholder")}
              />
              <span className="form-hint c-dim">
                {bio.length}/{BIO_MAX}
              </span>
            </div>
            <button
              type="submit"
              className="form-submit"
              disabled={saveProfile.isPending}
            >
              {saveProfile.isPending ? t("actions.saving") : t("actions.save")}
            </button>
          </form>
        </section>
      )}

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
              <label className="form-lbl" htmlFor="proposedName">
                {t("profile.nameLabel")}
              </label>
              <input
                id="proposedName"
                className="form-ctrl"
                type="text"
                value={proposedName}
                onChange={(e) => setProposedName(e.target.value)}
                placeholder={t("profile.namePlaceholder")}
              />
            </div>
            <div className="form-grp">
              <label className="form-lbl" htmlFor="proposedBio">
                {t("profile.bioLabel")}
              </label>
              <textarea
                id="proposedBio"
                className="form-ctrl"
                rows={3}
                maxLength={BIO_MAX}
                value={proposedBio}
                onChange={(e) => setProposedBio(e.target.value)}
                placeholder={t("profile.bioPlaceholder")}
              />
              <span className="form-hint c-dim">
                {proposedBio.length}/{BIO_MAX}
              </span>
            </div>
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
