module Api
  module V1
    class SubscriptionsController < BaseController
      include SubscriptionSerialization

      def index
        subscriptions = current_user.subscriptions
                                    .includes(:creator)
                                    .order(created_at: :desc)
        render json: subscriptions.map { |s| subscription_json(s) }
      end
    end
  end
end
