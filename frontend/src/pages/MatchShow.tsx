import { Link, useNavigate, useParams } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import client from "../api/client";
import { useMatch } from "../hooks/queries";
import { useFlash } from "../components/Flash";
import { enumLabel, resultColor, resultLabel, stars } from "../lib/labels";
import { apiErrorMessage } from "../lib/errors";

function Row({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div>
      <div className="detail-lbl">{label}</div>
      <div className="detail-val">{children}</div>
    </div>
  );
}

export default function MatchShow() {
  const { t } = useTranslation("matches");
  const { t: tc } = useTranslation("common");
  const { id, matchId } = useParams();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { notify } = useFlash();
  const { data: m, isLoading, isError, error } = useMatch(id, matchId);

  const destroy = useMutation({
    mutationFn: () =>
      client.delete(`/dashboards/${id}/matches/${matchId}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["matches", id] });
      queryClient.invalidateQueries({ queryKey: ["stats", id] });
      notify("ok", t("show.deleted"));
      navigate(`/dashboards/${id}/matches`);
    },
    onError: (err) => notify("err", apiErrorMessage(err)),
  });

  if (isLoading)
    return (
      <div className="empty">
        <p>{tc("state.loading")}</p>
      </div>
    );
  if (isError || !m)
    return (
      <div className="empty">
        <p>{apiErrorMessage(error)}</p>
      </div>
    );

  return (
    <>
      <div className="page-hd">
        <div>
          <div className="breadcrumb">
            <Link to={`/dashboards/${id}/matches`}>
              {t("show.breadcrumbMatches")}
            </Link>{" "}
            / #{m.id}
          </div>
          <h1 className="page-title">
            {enumLabel("opponent_deck", m.opponent_deck)}
          </h1>
        </div>
        <div className="db-card-acts">
          <Link
            to={`/dashboards/${id}/matches/${m.id}/edit`}
            className="btn btn-b btn-sm"
          >
            {tc("actions.edit")}
          </Link>
          <button
            type="button"
            className="btn btn-r btn-sm"
            onClick={() => {
              if (window.confirm(t("show.confirmDelete"))) destroy.mutate();
            }}
          >
            {tc("actions.delete")}
          </button>
        </div>
      </div>

      <div className="match-detail">
        <Row label={t("show.result")}>
          <span className={resultColor(m.result)}>
            {resultLabel(m.result)}
          </span>
        </Row>
        <Row label={t("show.gameMode")}>
          {enumLabel("game_mode", m.game_mode)}
        </Row>
        {m.first_or_second !== "uninformed" && (
          <Row label={t("show.firstOrSecond")}>
            {m.first_or_second === "first" ? t("show.first") : t("show.second")}
          </Row>
        )}
        <Row label={t("show.handQuality")}>
          {stars(m.hand_quality)} {m.hand_quality}/5
        </Row>
        {m.number_of_mulligans != null && (
          <Row label={t("show.mulligans")}>{m.number_of_mulligans}</Row>
        )}
        {m.result === "loss" && m.reason_for_defeat && (
          <Row label={t("show.reasonForDefeat")}>
            {enumLabel("reason_for_defeat", m.reason_for_defeat)}
          </Row>
        )}
        {m.description && <Row label={t("show.notes")}>{m.description}</Row>}
      </div>
    </>
  );
}
