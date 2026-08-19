import { Navigate, Outlet } from "react-router-dom";
import { useRole } from "../auth/AuthContext";

export default function CreatorRoute() {
  const { isCreator } = useRole();
  return isCreator ? <Outlet /> : <Navigate to="/dashboards" replace />;
}
