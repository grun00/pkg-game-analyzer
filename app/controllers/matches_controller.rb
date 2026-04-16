class MatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dashboard
  before_action :set_match, only: %i[show edit update destroy]

  def index
    @matches = @dashboard.matches.recent
  end

  def show; end

  def new
    @match = @dashboard.matches.build(played_at: Time.current)
  end

  def create
    @match = @dashboard.matches.build(match_params)
    if @match.save
      redirect_to @dashboard, notice: "Match registered successfully!"
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @match.update(match_params)
      redirect_to @dashboard, notice: "Match updated successfully!"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @match.destroy
    redirect_to dashboard_matches_path(@dashboard), notice: "Match deleted."
  end

  private

  def set_dashboard
    @dashboard = current_user.dashboards.find(params[:dashboard_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboards_path, alert: "Dashboard not found."
  end

  def set_match
    @match = @dashboard.matches.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_matches_path(@dashboard), alert: "Match not found."
  end

  def match_params
    params.require(:match).permit(:opponent_deck, :result, :description, :hand_quality, :played_at, :first_or_second, :reason_for_defeat)
  end
end
