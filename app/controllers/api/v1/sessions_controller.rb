module Api
  module V1
    class SessionsController < Devise::SessionsController
      skip_before_action :verify_authenticity_token
      respond_to :json

      private

      def respond_with(resource, _opts = {})
        render json: { user: user_json(resource) }, status: :ok
      end

      def respond_to_on_destroy(*)
        head :no_content
      end

      def user_json(u)
        { id: u.id, email: u.email }
      end
    end
  end
end
