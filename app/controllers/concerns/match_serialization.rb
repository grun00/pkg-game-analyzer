module MatchSerialization
  extend ActiveSupport::Concern

  private

  def match_json(m)
    {
      id: m.id,
      opponent_deck: m.opponent_deck,
      result: m.result,
      game_mode: m.game_mode,
      first_or_second: m.first_or_second,
      reason_for_defeat: m.reason_for_defeat,
      hand_quality: m.hand_quality,
      number_of_mulligans: m.number_of_mulligans,
      my_battlefield: m.my_battlefield,
      opponent_battlefield: m.opponent_battlefield,
      description: m.description,
      played_at: m.played_at&.iso8601
    }
  end
end
