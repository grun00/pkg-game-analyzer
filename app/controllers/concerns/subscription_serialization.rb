module SubscriptionSerialization
  extend ActiveSupport::Concern
  include UserSerialization

  private

  def creator_json(creator, subscribed:)
    {
      id: creator.id,
      email: creator.email,
      role: creator.role,
      subscribed: subscribed
    }
  end

  def subscription_json(subscription)
    {
      id: subscription.id,
      created_at: subscription.created_at,
      creator: user_json(subscription.creator)
    }
  end
end
