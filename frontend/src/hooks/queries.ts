import { useQuery } from "@tanstack/react-query";
import client from "../api/client";
import type {
  Creator,
  CreatorRequest,
  Dashboard,
  DashboardSummary,
  Match,
  Meta,
  Stats,
  Subscription,
} from "../types";

export function useMeta() {
  return useQuery<Meta>({
    queryKey: ["meta"],
    queryFn: () => client.get("/meta").then((r) => r.data),
    staleTime: 1000 * 60 * 60,
  });
}

export function useDashboards() {
  return useQuery<DashboardSummary[]>({
    queryKey: ["dashboards"],
    queryFn: () => client.get("/dashboards").then((r) => r.data),
  });
}

export function useDashboard(id: string | undefined) {
  return useQuery<Dashboard>({
    queryKey: ["dashboard", id],
    queryFn: () => client.get(`/dashboards/${id}`).then((r) => r.data),
    enabled: !!id,
  });
}

export function useStats(id: string | undefined) {
  return useQuery<Stats>({
    queryKey: ["stats", id],
    queryFn: () => client.get(`/dashboards/${id}/stats`).then((r) => r.data),
    enabled: !!id,
  });
}

export function useMatches(dashboardId: string | undefined) {
  return useQuery<Match[]>({
    queryKey: ["matches", dashboardId],
    queryFn: () =>
      client.get(`/dashboards/${dashboardId}/matches`).then((r) => r.data),
    enabled: !!dashboardId,
  });
}

export function useMatch(
  dashboardId: string | undefined,
  matchId: string | undefined,
) {
  return useQuery<Match>({
    queryKey: ["match", dashboardId, matchId],
    queryFn: () =>
      client
        .get(`/dashboards/${dashboardId}/matches/${matchId}`)
        .then((r) => r.data),
    enabled: !!dashboardId && !!matchId,
  });
}

export function useMyCreatorRequests() {
  return useQuery<CreatorRequest[]>({
    queryKey: ["creator_requests"],
    queryFn: () => client.get("/creator_requests").then((r) => r.data),
  });
}

export function usePendingCreatorRequests(enabled = true) {
  return useQuery<CreatorRequest[]>({
    queryKey: ["admin", "creator_requests"],
    queryFn: () => client.get("/admin/creator_requests").then((r) => r.data),
    enabled,
  });
}

export function useCreators() {
  return useQuery<Creator[]>({
    queryKey: ["creators"],
    queryFn: () => client.get("/creators").then((r) => r.data),
  });
}

export function useCreator(id: string | undefined) {
  return useQuery<Creator>({
    queryKey: ["creator", id],
    queryFn: () => client.get(`/creators/${id}`).then((r) => r.data),
    enabled: !!id,
  });
}

export function useSubscriptions() {
  return useQuery<Subscription[]>({
    queryKey: ["subscriptions"],
    queryFn: () => client.get("/subscriptions").then((r) => r.data),
  });
}
