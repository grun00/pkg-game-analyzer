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
    festival_lead:            16,
    grimmsnarl:               17,
    monkidori_froslass:       18,
    team_rocket_honchcrow:    19,
    crustle:                  20,
    okidogi:                  21,
    ceruledge:                22,
    slowpoke:                 23,
    slop_box:                 24,
    other:               15
  }.freeze

  DEFEAT_REASONS = { unknown: 0, minor_misplay: 1, major_misplay: 2, disconnected: 3, unlucky: 4 }.freeze

  enum :opponent_deck, OPPONENT_DECKS
  enum :result, { win: "win", loss: "loss" }, prefix: true
  enum :first_or_second, { uninformed: 0, first: 1, second: 2 }, prefix: true
  enum :reason_for_defeat, DEFEAT_REASONS, prefix: true

  validates :opponent_deck, presence: true
  validates :result, presence: true
  validates :hand_quality, presence: true,
                           numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :played_at, presence: true
  validates :number_of_mulligans, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  scope :wins,   -> { where(result: "win") }
  scope :losses, -> { where(result: "loss") }
  scope :recent, -> { order(played_at: :desc) }
end
