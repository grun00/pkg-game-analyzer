module GameMeta
  GAME_TYPES = { pokemon: 0, magic: 1, riftbound: 2 }.freeze

  RIFTBOUND_DECKS = %i[kaisa master_yi ahri viktor jinx lee_sin
                       yasuo vi darius volibear annie garen other].freeze

  POKEMON_DECKS = (Match::OPPONENT_DECKS.keys - RIFTBOUND_DECKS + %i[other]).uniq.freeze

  CONFIG = {
    pokemon:   { opponent_decks: POKEMON_DECKS,
                 game_modes: Match::GAME_MODES.keys.select { |k| %i[in_person tcg_live].include?(k) } },
    riftbound: { opponent_decks: RIFTBOUND_DECKS,
                 game_modes: %i[standard limited] },
    magic:     { opponent_decks: %i[other], game_modes: [] }
  }.freeze

  def self.for(game_type)
    CONFIG.fetch(game_type.to_sym, CONFIG[:pokemon])
  end
end
