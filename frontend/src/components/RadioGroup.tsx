import type { EnumOption } from "../types";

interface Props {
  label: string;
  name: string;
  options: EnumOption[];
  value: string;
  onChange: (value: string) => void;
}

export default function RadioGroup({
  label,
  name,
  options,
  value,
  onChange,
}: Props) {
  return (
    <div className="form-grp">
      <label className="form-lbl">{label}</label>
      <div className="form-radios">
        {options.map((o) => (
          <label className="form-radio" key={String(o.value)}>
            <input
              type="radio"
              name={name}
              value={String(o.value)}
              checked={value === String(o.value)}
              onChange={(e) => onChange(e.target.value)}
            />
            {o.label}
          </label>
        ))}
      </div>
    </div>
  );
}
