module GameMeta
  GAME_TYPES = { pokemon: 0, magic: 1, riftbound: 2 }.freeze

  RIFTBOUND_DECKS = %i[ahri_nine_tailed_fox akali_rogue_assassin ambessa_matriarch_of_war
                       annie_dark_child azir_emperor_of_the_sands darius_hand_of_noxus
                       diana_scorn_of_the_moon draven_glorious_executioner ezreal_prodigal_explorer
                       fiora_grand_duelist garen_might_of_demacia irelia_blade_dancer
                       ivern_green_father jax_grandmaster_at_arms jayce_defender_of_tomorrow
                       jhin_virtuoso jinx_loose_cannon kaisa_daughter_of_the_void
                       khazix_voidreaver leblanc_deceiver lee_sin_blind_monk
                       leona_radiant_dawn lillia_bashful_bloom lucian_purifier
                       lux_lady_of_luminosity master_yi_wuju_bladesman master_yi_wuju_master
                       mel_souls_reflection miss_fortune_bounty_hunter nasus_curator_of_the_sands
                       ornn_fire_below_the_mountain poppy_keeper_of_the_hammer pyke_bloodharbor_ripper
                       reksai_void_burrower renata_glasc_chem_baroness renekton_butcher_of_the_sands
                       rengar_pridestalker rumble_mechanized_menace sett_the_boss
                       shen_eye_of_twilight sivir_battle_mistress teemo_swift_scout
                       vex_gloomist vi_piltover_enforcer viktor_herald_of_the_arcane
                       volibear_relentless_storm yasuo_unforgiven yordle_kennen_heart_of_the_tempest
                       zed_master_of_shadows other].freeze

  POKEMON_DECKS = (Match::OPPONENT_DECKS.keys - RIFTBOUND_DECKS + %i[other]).uniq.freeze

  RIFTBOUND_BATTLEFIELDS = Match::RIFTBOUND_BATTLEFIELDS.map(&:to_sym).freeze

  CONFIG = {
    pokemon:   { opponent_decks: POKEMON_DECKS,
                 game_modes: Match::GAME_MODES.keys.select { |k| %i[in_person tcg_live].include?(k) },
                 battlefields: [] },
    riftbound: { opponent_decks: RIFTBOUND_DECKS,
                 game_modes: %i[bo1 bo3],
                 battlefields: RIFTBOUND_BATTLEFIELDS },
    magic:     { opponent_decks: %i[other], game_modes: [], battlefields: [] }
  }.freeze

  def self.for(game_type)
    CONFIG.fetch(game_type.to_sym, CONFIG[:pokemon])
  end
end
