module Api
  module V1
    class MatchesController < BaseController
      include MatchSerialization

      before_action :set_dashboard
      before_action :set_match, only: %i[show update destroy]

      def index
        render json: @dashboard.matches.recent.map { |m| match_json(m) }
      end

      def show
        render json: match_json(@match)
      end

      def create
        m = @dashboard.matches.create!(match_params)
        render json: match_json(m), status: :created
      end

      def update
        @match.update!(match_params)
        render json: match_json(@match)
      end

      def destroy
        @match.destroy
        head :no_content
      end

      private

      def set_dashboard
        @dashboard = current_user.dashboards.find(params[:dashboard_id])
      end

      def set_match
        @match = @dashboard.matches.find(params[:id])
      end

      def match_params
        params.require(:match).permit(:opponent_deck, :result, :description, :hand_quality,
          :played_at, :first_or_second, :reason_for_defeat, :number_of_mulligans, :game_mode,
          :my_battlefield, :opponent_battlefield)
      end
    end
  end
end
