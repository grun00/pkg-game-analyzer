class Subscription < ApplicationRecord
  belongs_to :subscriber, class_name: "User"
  belongs_to :creator, class_name: "User"

  validates :subscriber_id, uniqueness: { scope: :creator_id }
  validate :creator_must_be_creator
  validate :cannot_subscribe_to_self

  private

  def creator_must_be_creator
    return if creator&.role_content_creator?

    errors.add(:creator, I18n.t("errors.subscription.not_a_creator"))
  end

  def cannot_subscribe_to_self
    return unless subscriber_id && creator_id
    return unless subscriber_id == creator_id

    errors.add(:base, I18n.t("errors.subscription.cannot_subscribe_to_self"))
  end
end
