export type Role = "regular" | "content_creator" | "admin";

export interface User {
  id: number;
  email: string;
  role: Role;
  name: string | null;
  bio: string | null;
}

export type CreatorRequestStatus = "pending" | "approved" | "rejected";

export interface CreatorRequest {
  id: number;
  status: CreatorRequestStatus;
  message: string | null;
  proposed_name: string | null;
  proposed_bio: string | null;
  created_at: string;
  updated_at: string;
  user: User;
}

// Public creator representation. Never includes the creator's email.
export interface PublicCreator {
  id: number;
  name: string;
  bio: string | null;
  role: Role;
}

export interface Creator extends PublicCreator {
  subscribed: boolean;
  contents?: Content[];
}

export interface Subscription {
  id: number;
  created_at: string;
  creator: PublicCreator;
}

export type ContentType = "article" | "guide";
export type ContentStatus = "draft" | "published";
export type GameType = "pokemon" | "magic" | "riftbound";

export interface Content {
  id: number;
  title: string;
  body: string;
  content_type: ContentType;
  status: ContentStatus;
  game_type: GameType;
  published_at: string | null;
  created_at: string;
  updated_at: string;
  creator: PublicCreator;
  average_rating: number;
  ratings_count: number;
  my_rating: number | null;
}

export interface Dashboard {
  id: number;
  name: string;
  game_type: GameType;
  created_at: string;
  updated_at: string;
}

export interface DashboardSummary {
  id: number;
  name: string;
  game_type: GameType;
  created_at: string;
  matches_count: number;
  wins_count: number;
  win_rate: number;
}

export type Result = "win" | "loss" | "tie";
export type FirstOrSecond = "uninformed" | "first" | "second";

export interface Match {
  id: number;
  opponent_deck: string;
  result: Result;
  game_mode: string;
  first_or_second: FirstOrSecond;
  reason_for_defeat: string | null;
  hand_quality: number;
  number_of_mulligans: number | null;
  description: string | null;
  played_at: string | null;
}

export interface SideStat {
  total: number;
  wins: number;
  losses: number;
  ties: number;
  win_rate: number | null;
}

export interface DeckStat {
  deck: string;
  label: string;
  total: number;
  wins: number;
  losses: number;
  ties: number;
  win_rate: number;
  first: SideStat;
  second: SideStat;
}

export interface HandQualityStat {
  quality: number;
  total: number;
  wins: number;
  losses: number;
  ties: number;
  win_rate: number;
}

export interface FirstOrSecondStat {
  side: "first" | "second";
  total: number;
  wins: number;
  losses: number;
  ties: number;
  win_rate: number;
}

export interface DefeatReason {
  reason: string;
  label: string;
  count: number;
}

export interface DefeatReasonStats {
  reasons: DefeatReason[];
  unspecified: number;
}

export interface Stats {
  total: number;
  wins: number;
  losses: number;
  ties: number;
  win_rate: number;
  by_deck: DeckStat[];
  by_hand_quality: HandQualityStat[];
  average_hand_quality: number;
  by_first_or_second: FirstOrSecondStat[];
  by_defeat_reason: DefeatReasonStats;
  recent_matches: Match[];
}

export interface EnumOption {
  value: string | number;
  label: string;
}

export interface Meta {
  opponent_decks: EnumOption[];
  results: EnumOption[];
  game_modes: EnumOption[];
  first_or_second: EnumOption[];
  reasons_for_defeat: EnumOption[];
  hand_qualities: EnumOption[];
}
