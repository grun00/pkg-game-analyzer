module Api
  module V1
    class MetaController < BaseController
      def index
        cfg = GameMeta.for(resolved_game_type)
        render json: {
          opponent_decks: options(:opponent_deck, cfg[:opponent_decks]).sort_by { |o| o[:label] },
          results: options(:result, %w[win loss tie]),
          game_modes: options(:game_mode, cfg[:game_modes]),
          first_or_second: options(:first_or_second, %i[uninformed first second]),
          reasons_for_defeat: options(:reason_for_defeat, Match::DEFEAT_REASONS.keys),
          hand_qualities: (1..5).map { |n| { value: n, label: "#{n} #{'★' * n}" } },
          battlefields: options(:battlefield, cfg[:battlefields] || []).sort_by { |o| o[:label] }
        }
      end

      private

      def resolved_game_type
        gt = params[:game_type].to_s
        GameMeta::GAME_TYPES.key?(gt.to_sym) ? gt : "pokemon"
      end

      def options(group, keys)
        keys.map { |k| { value: k.to_s, label: I18n.t("enums.#{group}.#{k}") } }
      end
    end
  end
end
