import { useState, type FormEvent } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";
import { apiErrors } from "../lib/errors";

export default function SignUp() {
  const { register } = useAuth();
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmation, setConfirmation] = useState("");
  const [errors, setErrors] = useState<string[]>([]);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setErrors([]);
    setSubmitting(true);
    try {
      await register(email, password, confirmation);
      navigate("/dashboards");
    } catch (err) {
      setErrors(apiErrors(err));
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="auth-wrap">
      <div className="auth-box">
        <div className="auth-bar">// NEW TRAINER REGISTRATION</div>
        <form className="auth-body" onSubmit={handleSubmit}>
          <h1 className="auth-title">Sign Up</h1>
          {errors.length > 0 && (
            <div className="devise-errors">
              <ul>
                {errors.map((msg) => (
                  <li key={msg}>{msg}</li>
                ))}
              </ul>
            </div>
          )}
          <div className="form-grp">
            <label className="form-lbl" htmlFor="email">
              Trainer ID
            </label>
            <input
              id="email"
              type="email"
              className="form-ctrl"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              autoComplete="email"
              required
            />
          </div>
          <div className="form-grp">
            <label className="form-lbl" htmlFor="password">
              Access Code
            </label>
            <input
              id="password"
              type="password"
              className="form-ctrl"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              autoComplete="new-password"
              required
            />
          </div>
          <div className="form-grp">
            <label className="form-lbl" htmlFor="confirmation">
              Confirm Access Code
            </label>
            <input
              id="confirmation"
              type="password"
              className="form-ctrl"
              value={confirmation}
              onChange={(e) => setConfirmation(e.target.value)}
              autoComplete="new-password"
              required
            />
          </div>
          <button type="submit" className="form-submit" disabled={submitting}>
            {submitting ? "Registering…" : "[ Register ]"}
          </button>
          <div className="auth-links">
            <Link to="/login">Existing trainer? Sign in</Link>
          </div>
        </form>
      </div>
    </div>
  );
}
