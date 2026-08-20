require "csv"

class Match < ApplicationRecord
  belongs_to :dashboard
  delegate :user, to: :dashboard

  CSV_HEADERS = %w[
    id opponent_deck result game_mode first_or_second reason_for_defeat
    hand_quality number_of_mulligans my_battlefield opponent_battlefield
    description played_at created_at updated_at
  ].freeze

  RIFTBOUND_BATTLEFIELDS = %w[
    abandoned_hall altar_of_blood altar_to_unity amateur_recital aspirants_climb
    back_alley_bar bandle_tree black_flame_altar dragon_roost dusk_rose_lab
    emperors_dais forbidding_waste forge_of_the_fluft forgotten_library
    forgotten_monument fortified_position frozen_fortress gardens_of_becoming
    grove_of_the_god_willow hall_of_legends hallowed_tomb heisho_shell_of_the_world
    kinkou_temple marai_spire minefield monastery_of_hirana mystic_vortex
    navori_fighting_pit obelisk_of_power ornns_forge piltovan_forge power_nexus
    protective_sands ravenbloom_conservatory reavers_row reckoners_arena rippers_bay
    risen_altar rockfall_path sandswept_tomb seat_of_power shadow_temple
    sigil_of_the_storm star_spring startipped_peak sunken_temple targons_peak
    the_academy the_arenas_greatest the_candlelit_sanctum the_dreaming_tree
    the_grand_plaza the_papertree threshold_of_the_gray trapping_grounds
    treasure_hoard trifarian_war_camp valley_of_idols vaults_of_helia veiled_temple
    vilemaws_lair void_gate windswept_hillock zaun_warrens
  ].freeze

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
    greninja_ex:              25,
    mega_excradrill:          26,
    other:               15,
    kaisa:                    27,
    master_yi:                28,
    ahri:                     29,
    viktor:                   30,
    jinx:                     31,
    lee_sin:                  32,
    yasuo:                    33,
    vi:                       34,
    darius:                   35,
    volibear:                 36,
    annie:                    37,
    garen:                    38,
    ahri_nine_tailed_fox: 39,
    akali_rogue_assassin: 40,
    ambessa_matriarch_of_war: 41,
    annie_dark_child: 42,
    azir_emperor_of_the_sands: 43,
    darius_hand_of_noxus: 44,
    diana_scorn_of_the_moon: 45,
    draven_glorious_executioner: 46,
    ezreal_prodigal_explorer: 47,
    fiora_grand_duelist: 48,
    garen_might_of_demacia: 49,
    irelia_blade_dancer: 50,
    ivern_green_father: 51,
    jax_grandmaster_at_arms: 52,
    jayce_defender_of_tomorrow: 53,
    jhin_virtuoso: 54,
    jinx_loose_cannon: 55,
    kaisa_daughter_of_the_void: 56,
    khazix_voidreaver: 57,
    leblanc_deceiver: 58,
    lee_sin_blind_monk: 59,
    leona_radiant_dawn: 60,
    lillia_bashful_bloom: 61,
    lucian_purifier: 62,
    lux_lady_of_luminosity: 63,
    master_yi_wuju_bladesman: 64,
    master_yi_wuju_master: 65,
    mel_souls_reflection: 66,
    miss_fortune_bounty_hunter: 67,
    nasus_curator_of_the_sands: 68,
    ornn_fire_below_the_mountain: 69,
    poppy_keeper_of_the_hammer: 70,
    pyke_bloodharbor_ripper: 71,
    reksai_void_burrower: 72,
    renata_glasc_chem_baroness: 73,
    renekton_butcher_of_the_sands: 74,
    rengar_pridestalker: 75,
    rumble_mechanized_menace: 76,
    sett_the_boss: 77,
    shen_eye_of_twilight: 78,
    sivir_battle_mistress: 79,
    teemo_swift_scout: 80,
    vex_gloomist: 81,
    vi_piltover_enforcer: 82,
    viktor_herald_of_the_arcane: 83,
    volibear_relentless_storm: 84,
    yasuo_unforgiven: 85,
    yordle_kennen_heart_of_the_tempest: 86,
    zed_master_of_shadows: 87
  }.freeze

  DEFEAT_REASONS = { unknown: 0, minor_misplay: 1, major_misplay: 2, disconnected: 3, unlucky: 4 }.freeze

  GAME_MODES = { in_person: 0, tcg_live: 1, standard: 2, limited: 3, bo1: 4, bo3: 5 }.freeze

  enum :opponent_deck, OPPONENT_DECKS
  enum :result, { win: "win", loss: "loss", tie: "tie" }, prefix: true
  enum :first_or_second, { uninformed: 0, first: 1, second: 2 }, prefix: true
  enum :reason_for_defeat, DEFEAT_REASONS, prefix: true
  enum :game_mode, GAME_MODES, prefix: true

  validates :opponent_deck, presence: true
  validates :result, presence: true
  validates :hand_quality, presence: true,
                           numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :played_at, presence: true
  validates :number_of_mulligans, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :my_battlefield, inclusion: { in: RIFTBOUND_BATTLEFIELDS }, allow_nil: true
  validates :opponent_battlefield, inclusion: { in: RIFTBOUND_BATTLEFIELDS }, allow_nil: true

  before_validation :nullify_blank_battlefields

  scope :wins,   -> { where(result: "win") }
  scope :losses, -> { where(result: "loss") }
  scope :ties,   -> { where(result: "tie") }
  scope :recent, -> { order(played_at: :desc) }

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << CSV_HEADERS.map { |h| I18n.t("match.csv_headers.#{h}") }
      recent.each { |match| csv << match.to_csv_row }
    end
  end

  def to_csv_row
    [
      id,
      I18n.t("enums.opponent_deck.#{opponent_deck}"),
      I18n.t("enums.result.#{result}"),
      I18n.t("enums.game_mode.#{game_mode}"),
      I18n.t("enums.first_or_second.#{first_or_second}"),
      reason_for_defeat && I18n.t("enums.reason_for_defeat.#{reason_for_defeat}"),
      hand_quality,
      number_of_mulligans,
      my_battlefield && I18n.t("enums.battlefield.#{my_battlefield}"),
      opponent_battlefield && I18n.t("enums.battlefield.#{opponent_battlefield}"),
      description,
      played_at&.iso8601,
      created_at&.iso8601,
      updated_at&.iso8601
    ]
  end

  private

  def nullify_blank_battlefields
    self.my_battlefield = nil if my_battlefield.blank?
    self.opponent_battlefield = nil if opponent_battlefield.blank?
  end
end
