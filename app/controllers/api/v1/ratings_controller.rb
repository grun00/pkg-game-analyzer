module Api
  module V1
    class RatingsController < BaseController
      include ContentSerialization

      before_action :set_content

      # Upsert the current user's rating for the content. A user may only rate
      # content they can view (their own, or a followed creator's published content).
      def create
        return render_not_subscribed unless can_view?(@content)

        rating = @content.ratings.find_or_initialize_by(user: current_user)
        rating.update!(stars: rating_params[:stars])
        render json: content_json(@content.reload, current_user: current_user)
      end

      def destroy
        @content.ratings.where(user: current_user).destroy_all
        render json: content_json(@content.reload, current_user: current_user)
      end

      private

      def set_content
        @content = Content.includes(:ratings, :creator).find(params[:id])
      end

      def can_view?(content)
        return true if content.creator_id == current_user.id

        content.status_published? && current_user.subscriptions.exists?(creator_id: content.creator_id)
      end

      def render_not_subscribed
        render json: { error: I18n.t("errors.content.not_subscribed") }, status: :forbidden
      end

      def rating_params
        params.require(:rating).permit(:stars)
      end
    end
  end
end
