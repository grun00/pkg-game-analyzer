module Api
  module V1
    class MetaController < BaseController
      def index
        render json: {
          opponent_decks: options(Match::OPPONENT_DECKS.keys).sort_by { |o| o[:label] },
          results: %w[win loss tie].map { |k| { value: k, label: k.upcase } },
          game_modes: options(Match::GAME_MODES.keys),
          first_or_second: options(%i[uninformed first second]),
          reasons_for_defeat: options(Match::DEFEAT_REASONS.keys),
          hand_qualities: (1..5).map { |n| { value: n, label: "#{n} #{'★' * n}" } }
        }
      end

      private

      def options(keys)
        keys.map { |k| { value: k.to_s, label: k.to_s.humanize } }
      end
    end
  end
end
