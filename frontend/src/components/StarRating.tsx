interface StarRatingProps {
  value: number | null;
  onRate?: (stars: number) => void;
  disabled?: boolean;
  readOnly?: boolean;
}

// Interactive 1-5 star control reusing the CRT --gold styling. When readOnly it
// renders a static star row; otherwise each star is a button that rates.
export default function StarRating({
  value,
  onRate,
  disabled = false,
  readOnly = false,
}: StarRatingProps) {
  const current = value ?? 0;

  if (readOnly) {
    return (
      <span className="star-rating star-rating-ro" aria-hidden="true">
        {[1, 2, 3, 4, 5].map((n) => (
          <span key={n} className={n <= current ? "star-on" : "star-off"}>
            {n <= current ? "★" : "☆"}
          </span>
        ))}
      </span>
    );
  }

  return (
    <span className="star-rating" role="group">
      {[1, 2, 3, 4, 5].map((n) => (
        <button
          key={n}
          type="button"
          className={`star-btn ${n <= current ? "star-on" : "star-off"}`}
          disabled={disabled}
          aria-label={`${n}`}
          aria-pressed={n === current}
          onClick={() => onRate?.(n)}
        >
          {n <= current ? "★" : "☆"}
        </button>
      ))}
    </span>
  );
}
