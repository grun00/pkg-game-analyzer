class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dashboard, only: %i[show edit update destroy]

  def index
    @dashboards = current_user.dashboards.order(created_at: :desc)
  end

  def show
    @stats = MatchStatsService.new(@dashboard.matches).call
  end

  def new
    @dashboard = current_user.dashboards.build
  end

  def create
    @dashboard = current_user.dashboards.build(dashboard_params)
    if @dashboard.save
      redirect_to @dashboard, notice: "Dashboard \"#{@dashboard.name}\" created!"
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @dashboard.update(dashboard_params)
      redirect_to @dashboard, notice: "Dashboard updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @dashboard.destroy
    redirect_to dashboards_path, notice: "Dashboard deleted."
  end

  private

  def set_dashboard
    @dashboard = current_user.dashboards.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboards_path, alert: "Dashboard not found."
  end

  def dashboard_params
    params.require(:dashboard).permit(:name)
  end
end
