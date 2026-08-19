import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";
import { useFlash } from "./Flash";

export default function Nav() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const { notify } = useFlash();

  async function handleLogout() {
    await logout();
    notify("ok", "Signed out");
    navigate("/login");
  }

  return (
    <nav className="nav">
      <Link to="/dashboards" className="nav-brand glitch">
        ⚡ TRAINER_OS
      </Link>
      <div className="nav-links">
        {user ? (
          <>
            <Link to="/dashboards" className="nav-link">
              Dashboards
            </Link>
            <span className="nav-user">{user.email}</span>
            <button
              type="button"
              className="nav-btn nav-btn-r"
              onClick={handleLogout}
            >
              Sign out
            </button>
          </>
        ) : (
          <>
            <Link to="/login" className="nav-btn nav-btn-g">
              Sign in
            </Link>
            <Link to="/signup" className="nav-btn nav-btn-b">
              Sign up
            </Link>
          </>
        )}
      </div>
    </nav>
  );
}
