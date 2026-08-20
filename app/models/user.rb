class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  enum :role, { regular: 0, content_creator: 1, admin: 2 }, prefix: true

  BIO_MAX_LENGTH = 200

  validates :bio, length: { maximum: BIO_MAX_LENGTH }, allow_nil: true

  has_many :dashboards, dependent: :destroy
  has_many :matches, through: :dashboards
  has_many :creator_requests, dependent: :destroy

  has_many :subscriptions, foreign_key: :subscriber_id, dependent: :destroy
  has_many :subscribed_creators, through: :subscriptions, source: :creator
  has_many :subscriber_subscriptions, class_name: "Subscription", foreign_key: :creator_id, dependent: :destroy
  has_many :subscribers, through: :subscriber_subscriptions, source: :subscriber

  has_many :contents, foreign_key: :creator_id, class_name: "Content", dependent: :destroy
  has_many :ratings, dependent: :destroy

  def display_name
    name.presence || "Creator ##{id}"
  end
end
