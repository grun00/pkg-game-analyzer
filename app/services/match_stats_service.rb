class MatchStatsService
  def initialize(matches)
    @matches = matches
  end

  def call
    {
      total: total,
      wins: wins,
      losses: losses,
      ties: ties,
      win_rate: win_rate,
      by_deck: by_deck,
      by_hand_quality: by_hand_quality,
      average_hand_quality: average_hand_quality,
      by_first_or_second: by_first_or_second,
      by_defeat_reason: by_defeat_reason,
      recent_matches: recent_matches
    }
  end

  private

  def total
    @matches.count
  end

  def wins
    @matches.wins.count
  end

  def losses
    @matches.losses.count
  end

  def ties
    @matches.ties.count
  end

  def win_rate
    decisive = wins + losses
    return 0.0 if decisive.zero?

    (wins.to_f / decisive * 100).round(1)
  end

  def by_deck
    Match::OPPONENT_DECKS.keys.filter_map do |deck|
      deck_matches = @matches.where(opponent_deck: deck)
      next if deck_matches.empty?

      deck_wins     = deck_matches.wins.count
      deck_losses   = deck_matches.losses.count
      deck_ties     = deck_matches.ties.count
      deck_total    = deck_matches.count
      deck_decisive = deck_wins + deck_losses
      deck_rate     = deck_decisive.zero? ? 0.0 : (deck_wins.to_f / deck_decisive * 100).round(1)

      {
        deck: deck,
        label: deck.to_s.humanize,
        total: deck_total,
        wins: deck_wins,
        losses: deck_losses,
        ties: deck_ties,
        win_rate: deck_rate,
        first: side_stats(deck_matches, :first),
        second: side_stats(deck_matches, :second)
      }
    end.sort_by { |d| -d[:total] }
  end

  def by_hand_quality
    (1..5).map do |quality|
      quality_matches  = @matches.where(hand_quality: quality)
      quality_wins     = quality_matches.wins.count
      quality_losses   = quality_matches.losses.count
      quality_total    = quality_matches.count
      quality_decisive = quality_wins + quality_losses
      quality_rate     = quality_decisive.zero? ? 0.0 : (quality_wins.to_f / quality_decisive * 100).round(1)

      {
        quality: quality,
        total: quality_total,
        wins: quality_wins,
        losses: quality_losses,
        ties: quality_matches.ties.count,
        win_rate: quality_rate
      }
    end
  end

  def side_stats(scope, side)
    side_matches = scope.where(first_or_second: side)
    total        = side_matches.count
    wins         = side_matches.wins.count
    losses       = side_matches.losses.count
    decisive     = wins + losses
    { total: total, wins: wins, losses: losses, ties: side_matches.ties.count,
      win_rate: decisive.zero? ? nil : (wins.to_f / decisive * 100).round(1) }
  end

  def by_first_or_second
    %i[first second].map do |side|
      side_matches  = @matches.where(first_or_second: side)
      side_wins     = side_matches.wins.count
      side_losses   = side_matches.losses.count
      side_total    = side_matches.count
      side_decisive = side_wins + side_losses
      side_rate     = side_decisive.zero? ? 0.0 : (side_wins.to_f / side_decisive * 100).round(1)

      {
        side: side,
        total: side_total,
        wins: side_wins,
        losses: side_losses,
        ties: side_matches.ties.count,
        win_rate: side_rate
      }
    end
  end

  def average_hand_quality
    return 0.0 if total.zero?

    @matches.average(:hand_quality).to_f.round(2)
  end

  def by_defeat_reason
    losses_scope = @matches.losses
    reasons = Match::DEFEAT_REASONS.keys.map do |reason|
      { reason: reason, label: reason.to_s.humanize, count: losses_scope.where(reason_for_defeat: reason).count }
    end
    unspecified = losses_scope.where(reason_for_defeat: nil).count
    { reasons: reasons, unspecified: unspecified }
  end

  def recent_matches
    @matches.recent.limit(5)
  end
end
