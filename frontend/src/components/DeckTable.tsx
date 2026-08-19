import type { DeckStat } from "../types";

const pct = (v: number | null): string => (v === null ? "—" : `${v}%`);

export default function DeckTable({ rows }: { rows: DeckStat[] }) {
  return (
    <table className="term-table">
      <thead>
        <tr>
          <th>Deck</th>
          <th className="tc">Total</th>
          <th className="tc">W</th>
          <th className="tc">L</th>
          <th className="tc">T</th>
          <th className="tc">Win%</th>
          <th className="tc">1st%</th>
          <th className="tc">2nd%</th>
          <th>Bar</th>
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
