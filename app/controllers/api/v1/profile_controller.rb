module Api
  module V1
    class ProfileController < BaseController
      include UserSerialization

      def update
        role = profile_params[:role]
        unless User.roles.key?(role)
          return render json: { errors: [I18n.t("errors.invalid_role")] }, status: :unprocessable_content
        end

        current_user.update!(role: role)
        render json: { user: user_json(current_user) }, status: :ok
      end

      private

      def profile_params
        params.require(:user).permit(:role)
      end
    end
  end
end
