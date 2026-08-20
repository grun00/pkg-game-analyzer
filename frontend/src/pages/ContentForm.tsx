import { useState, type FormEvent } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import client from "../api/client";
import { useContent } from "../hooks/queries";
import { useFlash } from "../components/Flash";
import { apiErrors } from "../lib/errors";
import type { Content, ContentStatus, ContentType } from "../types";

interface FormState {
  title: string;
  body: string;
  content_type: ContentType;
  status: ContentStatus;
}

const BLANK: FormState = {
  title: "",
  body: "",
  content_type: "article",
  status: "draft",
};

function ContentFormInner({
  id,
  initial,
}: {
  id?: string;
  initial: FormState;
}) {
  const { t } = useTranslation("content");
  const { t: tc } = useTranslation("common");
  const isEdit = !!id;
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { notify } = useFlash();
  const [form, setForm] = useState<FormState>(initial);
  const [errors, setErrors] = useState<string[]>([]);

  const set = <K extends keyof FormState>(key: K, value: FormState[K]) =>
    setForm((f) => ({ ...f, [key]: value }));

  const save = useMutation({
    mutationFn: (payload: FormState) =>
      isEdit
        ? client.patch(`/contents/${id}`, { content: payload })
        : client.post("/contents", { content: payload }),
    onSuccess: (res) => {
      queryClient.invalidateQueries({ queryKey: ["contents"] });
      if (isEdit) queryClient.invalidateQueries({ queryKey: ["content", id] });
      notify("ok", isEdit ? t("form.updated") : t("form.created"));
      const savedId = (res.data as Content).id;
      navigate(`/contents/${savedId}`);
    },
    onError: (err) => setErrors(apiErrors(err)),
  });

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setErrors([]);
    save.mutate(form);
  }

  return (
    <>
      <div className="page-hd">
        <div>
          <div className="breadcrumb">
            <Link to="/contents">{t("index.title")}</Link> /{" "}
            {isEdit ? t("form.breadcrumbEdit") : t("form.breadcrumbNew")}
          </div>
          <h1 className="page-title">
            {isEdit ? t("form.titleEdit") : t("form.titleNew")}
          </h1>
        </div>
      </div>

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
          <label className="form-lbl" htmlFor="title">
            {t("form.title")}
          </label>
          <input
            id="title"
            className="form-ctrl"
            value={form.title}
            onChange={(e) => set("title", e.target.value)}
            required
          />
        </div>

        <div className="form-grp">
          <label className="form-lbl" htmlFor="content_type">
            {t("form.type")}
          </label>
          <select
            id="content_type"
            className="form-ctrl"
            value={form.content_type}
            onChange={(e) => set("content_type", e.target.value as ContentType)}
          >
            <option value="article">{t("type.article")}</option>
            <option value="guide">{t("type.guide")}</option>
          </select>
        </div>

        <div className="form-grp">
          <label className="form-lbl" htmlFor="status">
            {t("form.status")}
          </label>
          <select
            id="status"
            className="form-ctrl"
            value={form.status}
            onChange={(e) => set("status", e.target.value as ContentStatus)}
          >
            <option value="draft">{t("status.draft")}</option>
            <option value="published">{t("status.published")}</option>
          </select>
        </div>

        <div className="form-grp">
          <label className="form-lbl" htmlFor="body">
            {t("form.body")}
          </label>
          <textarea
            id="body"
            className="form-ctrl"
            rows={16}
            value={form.body}
            onChange={(e) => set("body", e.target.value)}
            placeholder={t("form.bodyPlaceholder")}
            required
          />
          <p className="form-hint">{t("form.markdownHint")}</p>
        </div>

        <button type="submit" className="form-submit" disabled={save.isPending}>
          {save.isPending ? tc("actions.saving") : tc("actions.save")}
        </button>
      </form>
    </>
  );
}

export default function ContentForm() {
  const { t } = useTranslation("common");
  const { id } = useParams();
  const { data: existing, isLoading } = useContent(id);

  if (id && isLoading)
    return (
      <div className="empty">
        <p>{t("state.loading")}</p>
      </div>
    );

  const initial: FormState = existing
    ? {
        title: existing.title,
        body: existing.body,
        content_type: existing.content_type,
        status: existing.status,
      }
    : BLANK;

  return <ContentFormInner key={existing?.id ?? "new"} id={id} initial={initial} />;
}
