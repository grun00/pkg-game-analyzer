class Dashboard < ApplicationRecord
  belongs_to :user
  has_many :matches, dependent: :destroy

  enum :game_type, GameMeta::GAME_TYPES, prefix: true

  validates :name, presence: true
end
