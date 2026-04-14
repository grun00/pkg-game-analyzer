require "rails_helper"

RSpec.describe Match, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:opponent_deck) }
    it { is_expected.to validate_presence_of(:result) }
    it { is_expected.to validate_presence_of(:hand_quality) }
    it { is_expected.to validate_presence_of(:played_at) }

    it { is_expected.to validate_numericality_of(:hand_quality)
                          .only_integer
                          .is_greater_than_or_equal_to(1)
                          .is_less_than_or_equal_to(5) }
  end

  describe "enums" do
    it "defines opponent_deck enum with all expected decks" do
      expected_decks = %w[charizard_ex gardevoir_ex chien_pao_baxcalibur lost_box miraidon_ex
                          raging_bolt roaring_moon regidrago_vstar iron_thorns snorlax_stall other]
      expect(Match.opponent_decks.keys).to match_array(expected_decks)
    end

    it "defines result enum with win and loss" do
      expect(Match.results.keys).to match_array(%w[win loss])
    end

    it "raises an ArgumentError for an invalid result" do
      expect { build(:match, result: "draw") }.to raise_error(ArgumentError)
    end

    it "raises an ArgumentError for an invalid opponent_deck" do
      expect { build(:match, opponent_deck: "pikachu") }.to raise_error(ArgumentError)
    end
  end

  describe "scopes" do
    let(:user) { create(:user) }

    before do
      create(:match, :win,  user: user)
      create(:match, :win,  user: user)
      create(:match, :loss, user: user)
    end

    it ".wins returns only won matches" do
      expect(Match.wins.count).to eq(2)
    end

    it ".losses returns only lost matches" do
      expect(Match.losses.count).to eq(1)
    end

    it ".recent orders by played_at descending" do
      user2  = create(:user)
      oldest = create(:match, user: user2, played_at: 10.days.ago)
      newest = create(:match, user: user2, played_at: 1.day.ago)
      scoped = user2.matches.recent
      expect(scoped.first).to eq(newest)
      expect(scoped.last).to eq(oldest)
    end
  end

  describe "factory" do
    it "is valid with default attributes" do
      expect(build(:match)).to be_valid
    end

    it "win trait produces a winning match" do
      expect(build(:match, :win).result).to eq("win")
    end

    it "loss trait produces a losing match" do
      expect(build(:match, :loss).result).to eq("loss")
    end
  end
end
