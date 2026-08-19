interface Props {
  label: string;
  value: string | number;
  cls?: string;
}

export default function StatCard({ label, value, cls }: Props) {
  return (
    <div className="stat-card">
      <div className={`stat-val ${cls ?? ""}`}>{value}</div>
      <div className="stat-lbl">{label}</div>
    </div>
  );
}
