module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      include UserSerialization

      skip_before_action :verify_authenticity_token
      respond_to :json

      private

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render json: { user: user_json(resource) }, status: :created
        else
          render json: { errors: resource.errors.full_messages }, status: :unprocessable_content
        end
      end
    end
  end
end
