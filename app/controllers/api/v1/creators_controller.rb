module Api
  module V1
    class CreatorsController < BaseController
      include SubscriptionSerialization

      before_action :set_creator, only: %i[show subscribe unsubscribe]

      def index
        creators = User.where(role: :content_creator).order(:email)
        subscribed_ids = current_user.subscriptions.pluck(:creator_id).to_set
        render json: creators.map { |c| creator_json(c, subscribed: subscribed_ids.include?(c.id)) }
      end

      def show
        render json: creator_json(@creator, subscribed: subscribed_to?(@creator))
      end

      def subscribe
        current_user.subscriptions.create!(creator: @creator)
        render json: creator_json(@creator, subscribed: true), status: :created
      end

      def unsubscribe
        current_user.subscriptions.where(creator: @creator).destroy_all
        render json: creator_json(@creator, subscribed: false)
      end

      private

      def set_creator
        @creator = User.where(role: :content_creator).find(params[:id])
      end

      def subscribed_to?(creator)
        current_user.subscriptions.exists?(creator: creator)
      end
    end
  end
end
