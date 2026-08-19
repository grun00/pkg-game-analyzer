import { useState, type FormEvent } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import client from "../api/client";
import { useDashboard } from "../hooks/queries";
import { useFlash } from "../components/Flash";
import { apiErrors } from "../lib/errors";

interface FormProps {
  id?: string;
  initialName: string;
}

function DashboardFormInner({ id, initialName }: FormProps) {
  const { t } = useTranslation("dashboards");
  const { t: tc } = useTranslation("common");
  const isEdit = !!id;
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { notify } = useFlash();
  const [name, setName] = useState(initialName);
  const [errors, setErrors] = useState<string[]>([]);

  const save = useMutation({
    mutationFn: (payload: { name: string }) =>
      isEdit
        ? client.patch(`/dashboards/${id}`, { dashboard: payload })
        : client.post("/dashboards", { dashboard: payload }),
    onSuccess: (res) => {
      queryClient.invalidateQueries({ queryKey: ["dashboards"] });
      if (isEdit)
        queryClient.invalidateQueries({ queryKey: ["dashboard", id] });
      notify("ok", isEdit ? t("form.updated") : t("form.created"));
      navigate(`/dashboards/${res.data.id}`);
    },
    onError: (err) => setErrors(apiErrors(err)),
  });

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setErrors([]);
    save.mutate({ name });
  }

  return (
    <>
      <div className="page-hd">
        <div>
          <div className="breadcrumb">
            <Link to="/dashboards">{tc("nav.dashboards")}</Link> /{" "}
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
          <label className="form-lbl" htmlFor="name">
            {t("form.name")}
          </label>
          <input
            id="name"
            type="text"
            className="form-ctrl"
            value={name}
            onChange={(e) => setName(e.target.value)}
            required
          />
        </div>
        <button type="submit" className="form-submit" disabled={save.isPending}>
          {save.isPending ? tc("actions.saving") : tc("actions.save")}
        </button>
      </form>
    </>
  );
}

export default function DashboardForm() {
  const { t } = useTranslation("common");
  const { id } = useParams();
  const { data: existing, isLoading } = useDashboard(id);

  if (id && isLoading)
    return (
      <div className="empty">
        <p>{t("state.loading")}</p>
      </div>
    );

  // key forces a fresh mount (and fresh initial state) when the record loads.
  return (
    <DashboardFormInner
      key={existing?.id ?? "new"}
      id={id}
      initialName={existing?.name ?? ""}
    />
  );
}
