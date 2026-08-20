require "rails_helper"

RSpec.describe GameMeta do
  describe "GAME_TYPES" do
    it "maps the three supported games to integers" do
      expect(described_class::GAME_TYPES).to eq(pokemon: 0, magic: 1, riftbound: 2)
    end
  end

  describe ".for" do
    it "returns riftbound decks and modes for riftbound" do
      cfg = described_class.for(:riftbound)
      expect(cfg[:opponent_decks]).to include(:kaisa_daughter_of_the_void, :other)
      expect(cfg[:opponent_decks]).not_to include(:dragapult)
      expect(cfg[:game_modes]).to eq(%i[bo1 bo3])
    end

    it "returns pokemon decks disjoint from riftbound legends" do
      cfg = described_class.for(:pokemon)
      expect(cfg[:opponent_decks]).to include(:dragapult, :other)
      expect(cfg[:opponent_decks]).not_to include(:kaisa_daughter_of_the_void)
    end

    it "returns only the other deck and no modes for magic" do
      cfg = described_class.for(:magic)
      expect(cfg[:opponent_decks]).to eq(%i[other])
      expect(cfg[:game_modes]).to eq([])
    end

    it "falls back to pokemon for an unknown game type" do
      expect(described_class.for(:unknown)).to eq(described_class.for(:pokemon))
    end

    it "accepts a string game type" do
      expect(described_class.for("riftbound")).to eq(described_class.for(:riftbound))
    end
  end
end
