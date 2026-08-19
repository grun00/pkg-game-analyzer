module Api
  module V1
    class DashboardsController < BaseController
      include MatchSerialization

      before_action :set_dashboard, only: %i[show update destroy export stats]

      def index
        render json: current_user.dashboards.order(created_at: :desc).map { |d| dashboard_summary(d) }
      end

      def show
        render json: dashboard_json(@dashboard)
      end

      def create
        d = current_user.dashboards.create!(dashboard_params)
        render json: dashboard_json(d), status: :created
      end

      def update
        @dashboard.update!(dashboard_params)
        render json: dashboard_json(@dashboard)
      end

      def destroy
        @dashboard.destroy
        head :no_content
      end

      def stats
        render json: serialize_stats(MatchStatsService.new(@dashboard.matches).call)
      end

      def export
        filename = "#{@dashboard.name.parameterize}-matches-#{Date.current.iso8601}.csv"
        send_data @dashboard.matches.to_csv, filename: filename, type: "text/csv"
      end

      private

      def set_dashboard
        @dashboard = current_user.dashboards.find(params[:id])
      end

      def dashboard_params
        params.require(:dashboard).permit(:name)
      end

      def dashboard_summary(d)
        m = d.matches
        wins = m.wins.count
        losses = m.losses.count
        decisive = wins + losses
        {
          id: d.id, name: d.name, created_at: d.created_at,
          matches_count: m.count, wins_count: wins,
          win_rate: decisive.zero? ? 0.0 : (wins.to_f / decisive * 100).round(1)
        }
      end

      def dashboard_json(d)
        { id: d.id, name: d.name, created_at: d.created_at, updated_at: d.updated_at }
      end

      # Convert MatchStatsService hash to JSON-safe structures.
      def serialize_stats(s)
        s.merge(recent_matches: s[:recent_matches].map { |m| match_json(m) })
      end
    end
  end
end
