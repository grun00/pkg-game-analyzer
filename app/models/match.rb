class Match < ApplicationRecord
  belongs_to :dashboard
  delegate :user, to: :dashboard

  OPPONENT_DECKS = {
    dragapult:        0,
    dragapult_dusknoir:        1,
    dragapult_blaziken: 2,
    tera_box:            3,
    team_rockets:         4,
    raging_bolt:         5,
    alakazam:        6,
    mega_lucario:     7,
    absol:         8,
    green_ogerpon:       9,
    clefairy_box:               10,
    garchomp:               11,
    ns_zoroark:               12,
    mega_starmie:               13,
    kengaskhan:               14,
    other:               15
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
