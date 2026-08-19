import { useState } from "react";
import { useTranslation } from "react-i18next";
import client from "../api/client";
import { useFlash } from "./Flash";
import { apiErrorMessage } from "../lib/errors";

interface Props {
  dashboardId: string;
  name: string;
}

export default function ExportButton({ dashboardId, name }: Props) {
  const { t } = useTranslation("matches");
  const [busy, setBusy] = useState(false);
  const { notify } = useFlash();

  async function download() {
    setBusy(true);
    try {
      const res = await client.get(`/dashboards/${dashboardId}/export`, {
        responseType: "blob",
      });
      const url = URL.createObjectURL(res.data as Blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = `${name.toLowerCase().replace(/[^a-z0-9]+/g, "-")}-matches-${new Date()
        .toISOString()
        .slice(0, 10)}.csv`;
      a.click();
      URL.revokeObjectURL(url);
    } catch (err) {
      notify("err", apiErrorMessage(err));
    } finally {
      setBusy(false);
    }
  }

  return (
    <button
      type="button"
      className="btn btn-r btn-sm"
      onClick={download}
      disabled={busy}
    >
      {busy ? t("export.busy") : t("export.button")}
    </button>
  );
}
