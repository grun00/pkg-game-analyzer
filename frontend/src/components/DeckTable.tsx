import { useTranslation } from "react-i18next";
import type { DeckStat } from "../types";

const pct = (v: number | null): string => (v === null ? "—" : `${v}%`);

export default function DeckTable({ rows }: { rows: DeckStat[] }) {
  const { t } = useTranslation("matches");
  return (
    <table className="term-table">
      <thead>
        <tr>
          <th>{t("deckTable.deck")}</th>
          <th className="tc">{t("deckTable.total")}</th>
          <th className="tc">{t("deckTable.w")}</th>
          <th className="tc">{t("deckTable.l")}</th>
          <th className="tc">{t("deckTable.t")}</th>
          <th className="tc">{t("deckTable.winPct")}</th>
          <th className="tc">{t("deckTable.firstPct")}</th>
          <th className="tc">{t("deckTable.secondPct")}</th>
          <th>{t("deckTable.bar")}</th>
        </tr>
      </thead>
      <tbody>
        {rows.map((r) => (
          <tr key={r.deck}>
            <td>{r.label}</td>
            <td className="tc">{r.total}</td>
            <td className="tc c-green">{r.wins}</td>
            <td className="tc c-red">{r.losses}</td>
            <td className="tc c-blue">{r.ties}</td>
            <td className="tc c-gold">{r.win_rate}%</td>
            <td className="tc">{pct(r.first.win_rate)}</td>
            <td className="tc">{pct(r.second.win_rate)}</td>
            <td>
              <div className="bar">
                <div
                  className="bar-fill"
                  style={{ width: `${r.win_rate}%` }}
                />
              </div>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
