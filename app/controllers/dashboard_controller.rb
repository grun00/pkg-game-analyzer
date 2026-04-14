class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @stats = MatchStatsService.new(current_user.matches).call
  end
end
