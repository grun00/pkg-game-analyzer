import { useState, type FormEvent } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import client from "../api/client";
import { useMatch, useMeta } from "../hooks/queries";
import { useFlash } from "../components/Flash";
import { apiErrors } from "../lib/errors";
import RadioGroup from "../components/RadioGroup";
import type { Meta } from "../types";
import type { MatchFormState } from "../lib/matchForm";
import { blankMatchForm, matchToForm, formToPayload } from "../lib/matchForm";

interface FormProps {
  id?: string;
  matchId?: string;
  meta: Meta;
  initial: MatchFormState;
}

function MatchFormInner({ id, matchId, meta, initial }: FormProps) {
  const { t } = useTranslation("matches");
  const { t: tc } = useTranslation("common");
  const isEdit = !!matchId;
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { notify } = useFlash();
  const [form, setForm] = useState<MatchFormState>(initial);
  const [errors, setErrors] = useState<string[]>([]);

  const set = <K extends keyof MatchFormState>(
    key: K,
    value: MatchFormState[K],
  ) => setForm((f) => ({ ...f, [key]: value }));

  const save = useMutation({
    mutationFn: (payload: object) =>
      isEdit
        ? client.patch(`/dashboards/${id}/matches/${matchId}`, {
            match: payload,
          })
        : client.post(`/dashboards/${id}/matches`, { match: payload }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["matches", id] });
      queryClient.invalidateQueries({ queryKey: ["stats", id] });
      notify("ok", isEdit ? t("form.updated") : t("form.logged"));
      navigate(`/dashboards/${id}`);
    },
    onError: (err) => setErrors(apiErrors(err)),
  });

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setErrors([]);
    save.mutate(formToPayload(form));
  }

  return (
    <>
      <div className="page-hd">
        <div>
          <div className="breadcrumb">
            <Link to={`/dashboards/${id}/matches`}>
              {t("index.breadcrumbMatches")}
            </Link>{" "}
            / {isEdit ? t("form.breadcrumbEdit") : t("form.breadcrumbNew")}
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
          <label className="form-lbl">{t("form.opponentDeck")}</label>
          <select
            className="form-ctrl"
            value={form.opponent_deck}
            onChange={(e) => set("opponent_deck", e.target.value)}
            required
          >
            <option value="">{t("form.selectDeck")}</option>
            {meta.opponent_decks.map((o) => (
              <option key={o.value} value={o.value}>
                {o.label}
              </option>
            ))}
          </select>
        </div>

        <RadioGroup
          label={t("form.gameMode")}
          name="game_mode"
          options={meta.game_modes}
          value={form.game_mode}
          onChange={(v) => set("game_mode", v)}
        />

        <RadioGroup
          label={t("form.result")}
          name="result"
          options={meta.results}
          value={form.result}
          onChange={(v) => set("result", v)}
        />

        {form.result === "loss" && (
          <RadioGroup
            label={t("form.reasonForDefeat")}
            name="reason_for_defeat"
            options={meta.reasons_for_defeat}
            value={form.reason_for_defeat}
            onChange={(v) => set("reason_for_defeat", v)}
          />
        )}

        <RadioGroup
          label={t("form.firstOrSecond")}
          name="first_or_second"
          options={meta.first_or_second}
          value={form.first_or_second}
          onChange={(v) => set("first_or_second", v)}
        />

        <div className="form-grp">
          <label className="form-lbl" htmlFor="mulligans">
            {t("form.mulligans")}
          </label>
          <input
            id="mulligans"
            type="number"
            min={0}
            className="form-ctrl"
            value={form.number_of_mulligans}
            onChange={(e) => set("number_of_mulligans", e.target.value)}
          />
        </div>

        <div className="form-grp">
          <label className="form-lbl">{t("form.handQuality")}</label>
          <select
            className="form-ctrl"
            value={form.hand_quality}
            onChange={(e) => set("hand_quality", e.target.value)}
            required
          >
            <option value="">{t("form.selectHandQuality")}</option>
            {meta.hand_qualities.map((o) => (
              <option key={o.value} value={o.value}>
                {o.label}
              </option>
            ))}
          </select>
        </div>

        <div className="form-grp">
          <label className="form-lbl" htmlFor="description">
            {t("form.notes")}
          </label>
          <textarea
            id="description"
            className="form-ctrl"
            rows={3}
            value={form.description}
            onChange={(e) => set("description", e.target.value)}
          />
        </div>

        <div className="form-grp">
          <label className="form-lbl" htmlFor="played_at">
            {t("form.playedAt")}
          </label>
          <input
            id="played_at"
            type="date"
            className="form-ctrl"
            value={form.played_at}
            onChange={(e) => set("played_at", e.target.value)}
            required
          />
        </div>

        <button type="submit" className="form-submit" disabled={save.isPending}>
          {save.isPending ? tc("actions.saving") : tc("actions.submit")}
        </button>
      </form>
    </>
  );
}

export default function MatchForm() {
  const { t } = useTranslation("common");
  const { id, matchId } = useParams();
  const { data: meta, isLoading: metaLoading } = useMeta();
  const { data: existing, isLoading: matchLoading } = useMatch(id, matchId);

  if (metaLoading || !meta || (matchId && matchLoading))
    return (
      <div className="empty">
        <p>{t("state.loading")}</p>
      </div>
    );

  // key forces a fresh mount (and fresh initial state) when the record loads.
  return (
    <MatchFormInner
      key={existing?.id ?? "new"}
      id={id}
      matchId={matchId}
      meta={meta}
      initial={existing ? matchToForm(existing) : blankMatchForm}
    />
  );
}
