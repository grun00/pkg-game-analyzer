import { Navigate, Route, Routes } from "react-router-dom";
import Nav from "./components/Nav";
import { Flash } from "./components/Flash";
import ProtectedRoute from "./components/ProtectedRoute";
import CreatorRoute from "./components/CreatorRoute";
import SignIn from "./pages/SignIn";
import SignUp from "./pages/SignUp";
import DashboardsIndex from "./pages/DashboardsIndex";
import DashboardForm from "./pages/DashboardForm";
import DashboardShow from "./pages/DashboardShow";
import MatchesIndex from "./pages/MatchesIndex";
import MatchShow from "./pages/MatchShow";
import MatchForm from "./pages/MatchForm";
import CreatorDashboard from "./pages/CreatorDashboard";

export default function App() {
  return (
    <>
      <Nav />
      <Flash />
      <main className="main">
        <Routes>
          <Route path="/login" element={<SignIn />} />
          <Route path="/signup" element={<SignUp />} />
          <Route element={<ProtectedRoute />}>
            <Route path="/" element={<Navigate to="/dashboards" replace />} />
            <Route path="/dashboards" element={<DashboardsIndex />} />
            <Route path="/dashboards/new" element={<DashboardForm />} />
            <Route path="/dashboards/:id" element={<DashboardShow />} />
            <Route path="/dashboards/:id/edit" element={<DashboardForm />} />
            <Route
              path="/dashboards/:id/matches"
              element={<MatchesIndex />}
            />
            <Route
              path="/dashboards/:id/matches/new"
              element={<MatchForm />}
            />
            <Route
              path="/dashboards/:id/matches/:matchId"
              element={<MatchShow />}
            />
            <Route
              path="/dashboards/:id/matches/:matchId/edit"
              element={<MatchForm />}
            />
            <Route element={<CreatorRoute />}>
              <Route path="/creator" element={<CreatorDashboard />} />
            </Route>
          </Route>
          <Route path="*" element={<Navigate to="/dashboards" replace />} />
        </Routes>
      </main>
    </>
  );
}
