import { Navigate, Outlet } from "react-router-dom";
import { useRole } from "../auth/AuthContext";

export default function AdminRoute() {
  const { isAdmin } = useRole();
  return isAdmin ? <Outlet /> : <Navigate to="/dashboards" replace />;
}
