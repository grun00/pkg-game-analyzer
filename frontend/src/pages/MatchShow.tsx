import { Link, useNavigate, useParams } from "react-router-dom";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import client from "../api/client";
import { useMatch } from "../hooks/queries";
import { useFlash } from "../components/Flash";
import { resultColor, resultLabel, stars } from "../lib/labels";
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
      notify("ok", "Match deleted");
      navigate(`/dashboards/${id}/matches`);
    },
    onError: (err) => notify("err", apiErrorMessage(err)),
  });

  if (isLoading)
    return (
      <div className="empty">
        <p>Loading…</p>
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
            <Link to={`/dashboards/${id}/matches`}>Matches</Link> / #{m.id}
          </div>
          <h1 className="page-title">{m.opponent_deck_label}</h1>
        </div>
        <div className="db-card-acts">
          <Link
            to={`/dashboards/${id}/matches/${m.id}/edit`}
            className="btn btn-b btn-sm"
          >
            Edit
          </Link>
          <button
            type="button"
            className="btn btn-r btn-sm"
            onClick={() => {
              if (window.confirm("Delete this match?")) destroy.mutate();
            }}
          >
            Delete
          </button>
        </div>
      </div>

      <div className="match-detail">
        <Row label="Result">
          <span className={resultColor(m.result)}>
            {resultLabel(m.result)}
          </span>
        </Row>
        <Row label="Game Mode">{m.game_mode_label}</Row>
        {m.first_or_second !== "uninformed" && (
          <Row label="First / Second">
            {m.first_or_second === "first" ? "1st" : "2nd"}
          </Row>
        )}
        <Row label="Hand Quality">
          {stars(m.hand_quality)} {m.hand_quality}/5
        </Row>
        {m.number_of_mulligans != null && (
          <Row label="Mulligans">{m.number_of_mulligans}</Row>
        )}
        {m.result === "loss" && m.reason_for_defeat_label && (
          <Row label="Reason for Defeat">{m.reason_for_defeat_label}</Row>
        )}
        {m.description && <Row label="Notes">{m.description}</Row>}
      </div>
    </>
  );
}
