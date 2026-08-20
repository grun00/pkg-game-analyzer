module SubscriptionSerialization
  extend ActiveSupport::Concern

  private

  # Public creator representation. Never exposes the creator's email.
  def public_creator_json(creator)
    {
      id: creator.id,
      name: creator.display_name,
      bio: creator.bio,
      role: creator.role
    }
  end

  def creator_json(creator, subscribed:)
    public_creator_json(creator).merge(subscribed: subscribed)
  end

  def subscription_json(subscription)
    {
      id: subscription.id,
      created_at: subscription.created_at,
      creator: public_creator_json(subscription.creator)
    }
  end
end
