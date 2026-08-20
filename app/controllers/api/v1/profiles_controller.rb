module Api
  module V1
    class ProfilesController < BaseController
      include UserSerialization

      before_action :require_creator!

      def update
        current_user.update!(profile_params)
        render json: user_json(current_user)
      end

      private

      def profile_params
        params.require(:profile).permit(:name, :bio)
      end
    end
  end
end
