class CreatorRequest < ApplicationRecord
  belongs_to :user

  enum :status, { pending: 0, approved: 1, rejected: 2 }, prefix: true

  validates :proposed_bio, length: { maximum: User::BIO_MAX_LENGTH }, allow_nil: true

  validate :no_other_pending_request, on: :create

  private

  def no_other_pending_request
    return unless user

    if user.creator_requests.status_pending.where.not(id: id).exists?
      errors.add(:base, I18n.t("errors.creator_request.already_pending"))
    end
  end
end
