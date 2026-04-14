class MatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_match, only: %i[show edit update destroy]

  def index
    @matches = current_user.matches.recent
  end

  def show; end

  def new
    @match = current_user.matches.build(played_at: Time.current)
  end

  def create
    @match = current_user.matches.build(match_params)
    if @match.save
      redirect_to root_path, notice: "Match registered successfully!"
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @match.update(match_params)
      redirect_to root_path, notice: "Match updated successfully!"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @match.destroy
    redirect_to matches_path, notice: "Match deleted."
  end

  private

  def set_match
    @match = current_user.matches.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to matches_path, alert: "Match not found."
  end

  def match_params
    params.require(:match).permit(:opponent_deck, :result, :description, :hand_quality, :played_at)
  end
end
