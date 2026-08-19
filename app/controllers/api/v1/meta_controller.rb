module Api
  module V1
    class MetaController < BaseController
      def index
        render json: {
          opponent_decks: options(:opponent_deck, Match::OPPONENT_DECKS.keys).sort_by { |o| o[:label] },
          results: options(:result, %w[win loss tie]),
          game_modes: options(:game_mode, Match::GAME_MODES.keys),
          first_or_second: options(:first_or_second, %i[uninformed first second]),
          reasons_for_defeat: options(:reason_for_defeat, Match::DEFEAT_REASONS.keys),
          hand_qualities: (1..5).map { |n| { value: n, label: "#{n} #{'★' * n}" } }
        }
      end

      private

      def options(group, keys)
        keys.map { |k| { value: k.to_s, label: I18n.t("enums.#{group}.#{k}") } }
      end
    end
  end
end
