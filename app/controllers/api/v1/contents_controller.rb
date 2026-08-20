module Api
  module V1
    class ContentsController < BaseController
      include ContentSerialization

      before_action :require_creator!, only: %i[create]
      before_action :set_content, only: %i[show update destroy]
      before_action :require_owner!, only: %i[update destroy]

      def index
        render json: visible_contents.map { |c| content_json(c, current_user: current_user) }
      end

      def show
        return render_not_subscribed unless can_view?(@content)

        render json: content_json(@content, current_user: current_user)
      end

      def create
        content = current_user.contents.create!(content_params)
        render json: content_json(content, current_user: current_user), status: :created
      end

      def update
        @content.update!(content_params)
        render json: content_json(@content, current_user: current_user)
      end

      def destroy
        @content.destroy
        head :no_content
      end

      private

      # Published content from creators the user follows, plus everything the
      # user authored themselves (drafts included). Eager-load ratings + creator
      # to avoid N+1 in serialization.
      def visible_contents
        followed = Content.where(creator_id: subscribed_creator_ids).status_published
        own = Content.where(creator_id: current_user.id)

        Content.includes(:ratings, :creator)
               .merge(followed.or(own))
               .recent
      end

      def set_content
        @content = Content.includes(:ratings, :creator).find(params[:id])
      end

      def require_owner!
        return if @content.creator_id == current_user.id

        render json: { error: I18n.t("errors.forbidden") }, status: :forbidden
      end

      # Owners always see their own content; others need a published status and
      # an active subscription to the creator.
      def can_view?(content)
        return true if content.creator_id == current_user.id

        content.status_published? && subscribed_to?(content.creator_id)
      end

      def subscribed_creator_ids
        current_user.subscriptions.pluck(:creator_id)
      end

      def subscribed_to?(creator_id)
        current_user.subscriptions.exists?(creator_id: creator_id)
      end

      def render_not_subscribed
        render json: { error: I18n.t("errors.content.not_subscribed") }, status: :forbidden
      end

      def content_params
        params.require(:content).permit(:title, :body, :content_type, :status)
      end
    end
  end
end
