class Content < ApplicationRecord
  CONTENT_TYPES = { article: 0, guide: 1 }.freeze
  STATUSES = { draft: 0, published: 1 }.freeze

  enum :content_type, CONTENT_TYPES, prefix: true
  enum :status, STATUSES, prefix: true
  enum :game_type, GameMeta::GAME_TYPES, prefix: true

  belongs_to :creator, class_name: "User"
  has_many :ratings, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true

  scope :published, -> { status_published }
  scope :recent, -> { order(created_at: :desc) }

  before_save :sync_published_at

  private

  # Stamp published_at the first time a content goes live, and clear it if it
  # is reverted to a draft.
  def sync_published_at
    return unless status_changed?

    self.published_at = status_published? ? (published_at || Time.current) : nil
  end
end
