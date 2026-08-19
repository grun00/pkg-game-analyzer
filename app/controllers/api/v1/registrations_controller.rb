module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      skip_before_action :verify_authenticity_token
      respond_to :json

      private

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render json: { user: { id: resource.id, email: resource.email } }, status: :created
        else
          render json: { errors: resource.errors.full_messages }, status: :unprocessable_content
        end
      end
    end
  end
end
