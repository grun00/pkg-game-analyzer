class Match < ApplicationRecord
  belongs_to :user

  OPPONENT_DECKS = {
    charizard_ex:        0,
    gardevoir_ex:        1,
    chien_pao_baxcalibur: 2,
    lost_box:            3,
    miraidon_ex:         4,
    raging_bolt:         5,
    roaring_moon:        6,
    regidrago_vstar:     7,
    iron_thorns:         8,
    snorlax_stall:       9,
    other:               10
  }.freeze

  enum :opponent_deck, OPPONENT_DECKS
  enum :result, { win: "win", loss: "loss" }, prefix: true

  validates :opponent_deck, presence: true
  validates :result, presence: true
  validates :hand_quality, presence: true,
                           numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :played_at, presence: true

  scope :wins,   -> { where(result: "win") }
  scope :losses, -> { where(result: "loss") }
  scope :recent, -> { order(played_at: :desc) }
end
