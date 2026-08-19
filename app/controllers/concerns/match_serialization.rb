module MatchSerialization
  extend ActiveSupport::Concern

  private

  def match_json(m)
    {
      id: m.id,
      opponent_deck: m.opponent_deck,
      opponent_deck_label: m.opponent_deck.to_s.humanize,
      result: m.result,
      game_mode: m.game_mode,
      game_mode_label: m.game_mode.to_s.humanize,
      first_or_second: m.first_or_second,
      reason_for_defeat: m.reason_for_defeat,
      reason_for_defeat_label: m.reason_for_defeat&.humanize,
      hand_quality: m.hand_quality,
      number_of_mulligans: m.number_of_mulligans,
      description: m.description,
      played_at: m.played_at&.iso8601
    }
  end
end
