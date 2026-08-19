import { useState, type FormEvent } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useAuth } from "../auth/AuthContext";
import { apiErrors } from "../lib/errors";

export default function SignIn() {
  const { t } = useTranslation("auth");
  const { login } = useAuth();
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [remember, setRemember] = useState(false);
  const [errors, setErrors] = useState<string[]>([]);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setErrors([]);
    setSubmitting(true);
    try {
      await login(email, password);
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
        <div className="auth-bar">{t("signIn.bar")}</div>
        <form className="auth-body" onSubmit={handleSubmit}>
          <h1 className="auth-title">{t("signIn.title")}</h1>
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
              {t("signIn.trainerId")}
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
              {t("signIn.accessCode")}
            </label>
            <input
              id="password"
              type="password"
              className="form-ctrl"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              autoComplete="current-password"
              required
            />
          </div>
          <label className="form-radio">
            <input
              type="checkbox"
              checked={remember}
              onChange={(e) => setRemember(e.target.checked)}
            />
            {t("signIn.remember")}
          </label>
          <button type="submit" className="form-submit" disabled={submitting}>
            {submitting ? t("signIn.submitting") : t("signIn.submit")}
          </button>
          <div className="auth-links">
            <Link to="/signup">{t("signIn.toSignUp")}</Link>
          </div>
        </form>
      </div>
    </div>
  );
}
