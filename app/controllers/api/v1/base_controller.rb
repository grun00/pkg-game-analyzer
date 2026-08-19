module Api
  module V1
    class BaseController < ActionController::API
      include LocaleSelection

      before_action :authenticate_user!

      rescue_from ActiveRecord::RecordNotFound do |_e|
        render json: { error: I18n.t("errors.not_found") }, status: :not_found
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
      end
    end
  end
end
