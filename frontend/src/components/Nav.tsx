import { Link, useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useAuth } from "../auth/AuthContext";
import { useFlash } from "./Flash";
import { SUPPORTED_LNGS } from "../i18n";

function LangSwitcher() {
  const { t, i18n } = useTranslation("common");

  function change(lng: string) {
    void i18n.changeLanguage(lng);
    document.documentElement.lang = lng;
  }

  return (
    <div className="nav-lang" role="group" aria-label={t("lang.label")}>
      {SUPPORTED_LNGS.map((lng) => (
        <button
          key={lng}
          type="button"
          className={`nav-lang-btn${i18n.resolvedLanguage === lng ? " is-active" : ""}`}
          aria-pressed={i18n.resolvedLanguage === lng}
          onClick={() => change(lng)}
        >
          {t(`lang.${lng}`)}
        </button>
      ))}
    </div>
  );
}

export default function Nav() {
  const { t } = useTranslation("common");
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const { notify } = useFlash();

  async function handleLogout() {
    await logout();
    notify("ok", t("nav.signedOut"));
    navigate("/login");
  }

  return (
    <nav className="nav">
      <Link to="/dashboards" className="nav-brand glitch">
        <img src="/logo.png" alt="" className="nav-brand-logo" aria-hidden="true" />
        {t("brand")}
      </Link>
      <div className="nav-links">
        <LangSwitcher />
        {user ? (
          <>
            <Link to="/dashboards" className="nav-link">
              {t("nav.dashboards")}
            </Link>
            <span className="nav-user">{user.email}</span>
            <button
              type="button"
              className="nav-btn nav-btn-r"
              onClick={handleLogout}
            >
              {t("nav.signOut")}
            </button>
          </>
        ) : (
          <>
            <Link to="/login" className="nav-btn nav-btn-g">
              {t("nav.signIn")}
            </Link>
            <Link to="/signup" className="nav-btn nav-btn-b">
              {t("nav.signUp")}
            </Link>
          </>
        )}
      </div>
    </nav>
  );
}
