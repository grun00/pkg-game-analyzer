import { useTranslation } from "react-i18next";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import client from "../api/client";
import { usePendingCreatorRequests } from "../hooks/queries";
import { useFlash } from "../components/Flash";
import { apiErrors } from "../lib/errors";
import type { CreatorRequestStatus } from "../types";

export default function AdminDashboard() {
  const { t } = useTranslation("common");
  const queryClient = useQueryClient();
  const { notify } = useFlash();
  const { data: requests, isLoading } = usePendingCreatorRequests();

  const decide = useMutation({
    mutationFn: ({ id, status }: { id: number; status: CreatorRequestStatus }) =>
      client.patch(`/admin/creator_requests/${id}`, {
        creator_request: { status },
      }),
    onSuccess: (_res, { status }) => {
      queryClient.invalidateQueries({ queryKey: ["admin", "creator_requests"] });
      notify(
        "ok",
        status === "approved" ? t("admin.approved") : t("admin.rejected"),
      );
    },
    onError: (err) => notify("err", apiErrors(err)[0] ?? t("state.unexpectedError")),
  });

  if (isLoading)
    return (
      <div className="empty">
        <p>{t("state.loading")}</p>
      </div>
    );

  return (
    <>
      <div className="page-hd">
        <h1 className="page-title">{t("admin.title")}</h1>
      </div>

      {!requests || requests.length === 0 ? (
        <div className="empty">
          <p>{t("admin.empty")}</p>
        </div>
      ) : (
        <ul className="admin-requests">
          {requests.map((r) => (
            <li key={r.id} className="admin-request">
              <div className="admin-request-body">
                <strong>{r.user.email}</strong>
                <time>{new Date(r.created_at).toLocaleDateString()}</time>
                {r.message && <blockquote>{r.message}</blockquote>}
              </div>
              <div className="admin-request-actions">
                <button
                  type="button"
                  className="nav-btn nav-btn-g"
                  disabled={decide.isPending}
                  onClick={() => decide.mutate({ id: r.id, status: "approved" })}
                >
                  {t("admin.approve")}
                </button>
                <button
                  type="button"
                  className="nav-btn nav-btn-r"
                  disabled={decide.isPending}
                  onClick={() => decide.mutate({ id: r.id, status: "rejected" })}
                >
                  {t("admin.reject")}
                </button>
              </div>
            </li>
          ))}
        </ul>
      )}
    </>
  );
}
